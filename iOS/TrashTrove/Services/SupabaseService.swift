import Foundation
import os

// MARK: - Configuration

enum APIConfig {
    static let baseURL = "https://trashtrove.app"
    static let apiBaseURL = "\(baseURL)/api"
    // Supabase anon key - safe to embed in client apps (RLS enforces security)
    static let supabaseAnonKey = "REPLACE_WITH_SUPABASE_ANON_KEY"
}

// MARK: - Error Types

enum SupabaseError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(Error)
    case encodingError(Error)
    case rateLimited(retryAfter: Int?)
    case notFound
    case unauthorized
    case serverError
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .httpError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .decodingError(let error):
            return "Failed to parse server response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .notFound:
            return "The requested resource was not found."
        case .unauthorized:
            return "You are not authorized to perform this action."
        case .serverError:
            return "An internal server error occurred. Please try again."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Response Types

private struct SalesResponse: Decodable {
    let sales: [GarageSale]
    let total: Int?
}

private struct SingleSaleResponse: Decodable {
    let sale: GarageSale
}

private struct CreateSaleResponse: Decodable {
    let id: UUID
    let manageToken: String

    enum CodingKeys: String, CodingKey {
        case id
        case manageToken = "manage_token"
    }
}

private struct UploadResponse: Decodable {
    let url: String
    let thumbnail: String?
}

private struct ErrorResponse: Decodable {
    let error: String
}

private struct MessageResponse: Decodable {
    let success: Bool?
    let message: String?
}

// MARK: - SupabaseService

final class SupabaseService: @unchecked Sendable {

    static let shared = SupabaseService()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let logger = Logger(subsystem: "app.trashtrove", category: "SupabaseService")

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        config.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]
        session = URLSession(configuration: config)

        decoder = JSONDecoder()
        // Models use explicit CodingKeys, but this helps with any ad-hoc decoding
        decoder.dateDecodingStrategy = .iso8601

        encoder = JSONEncoder()
    }

    // MARK: - Fetch Upcoming Sales

    /// Fetches upcoming sales ordered by date ascending.
    func fetchUpcomingSales(limit: Int = 20) async throws -> [GarageSale] {
        var components = urlComponents(path: "/api/sales")
        components.queryItems = [
            URLQueryItem(name: "limit", value: String(min(limit, 50))),
            URLQueryItem(name: "offset", value: "0"),
        ]

        let response: SalesResponse = try await performRequest(components: components)
        return response.sales
    }

    // MARK: - Fetch Single Sale

    /// Fetches a single sale by ID including its photos.
    func fetchSale(id: UUID) async throws -> GarageSale {
        let components = urlComponents(path: "/api/sales/\(id.uuidString)")
        let response: SingleSaleResponse = try await performRequest(components: components)
        return response.sale
    }

    // MARK: - Fetch Sales by State

    /// Fetches active sales filtered by state and optionally city.
    func fetchSalesByState(_ state: String, city: String? = nil) async throws -> [GarageSale] {
        var components = urlComponents(path: "/api/sales")
        var queryItems = [
            URLQueryItem(name: "state", value: state.uppercased()),
            URLQueryItem(name: "limit", value: "50"),
        ]
        if let city, !city.isEmpty {
            queryItems.append(URLQueryItem(name: "city", value: city))
        }
        components.queryItems = queryItems

        let response: SalesResponse = try await performRequest(components: components)
        return response.sales
    }

    // MARK: - Search Sales

    /// Full-text search across sales.
    func searchSales(query: String, limit: Int = 20, offset: Int = 0) async throws -> (sales: [GarageSale], total: Int) {
        var components = urlComponents(path: "/api/sales")
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(min(limit, 50))),
            URLQueryItem(name: "offset", value: String(offset)),
        ]

        let response: SalesResponse = try await performRequest(components: components)
        return (sales: response.sales, total: response.total ?? response.sales.count)
    }

    // MARK: - Fetch Nearby Sales

    /// Fetches sales near the given coordinates using the server-side RPC.
    func fetchNearbySales(lat: Double, lng: Double, radiusMiles: Int = 25) async throws -> [GarageSale] {
        guard (-90...90).contains(lat), (-180...180).contains(lng) else {
            throw SupabaseError.invalidURL
        }

        var components = urlComponents(path: "/api/sales/nearby")
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lng", value: String(lng)),
            URLQueryItem(name: "radius", value: String(min(max(radiusMiles, 1), 100))),
        ]

        let response: SalesResponse = try await performRequest(components: components)
        return response.sales
    }

    // MARK: - Create Sale

    /// Creates a new garage sale listing and returns its ID and manage token.
    func createSale(_ input: CreateSaleInput, photoURLs: [String] = []) async throws -> (id: UUID, manageToken: String) {
        let components = urlComponents(path: "/api/sales")

        // Build the JSON body matching the API's expected snake_case keys
        var body: [String: Any] = [
            "title": input.title,
            "description": input.description,
            "categories": input.categories,
            "address": input.address,
            "city": input.city,
            "state": input.state.uppercased(),
            "zip": input.zip,
            "sale_date": input.saleDate,
            "start_time": input.startTime,
            "end_time": input.endTime,
            "seller_name": input.sellerName,
            "seller_email": input.sellerEmail,
        ]
        if !photoURLs.isEmpty {
            body["photoUrls"] = photoURLs
        }

        let jsonData = try JSONSerialization.data(withJSONObject: body)
        let response: CreateSaleResponse = try await performRequest(
            components: components,
            method: "POST",
            body: jsonData
        )

        return (id: response.id, manageToken: response.manageToken)
    }

    // MARK: - Contact Seller

    /// Sends a contact message to the seller of a given sale.
    func sendContactMessage(saleId: UUID, name: String, email: String, message: String) async throws {
        let components = urlComponents(path: "/api/sales/\(saleId.uuidString)/contact")

        let body: [String: String] = [
            "name": name,
            "email": email,
            "message": message,
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: body)

        let _: MessageResponse = try await performRequest(
            components: components,
            method: "POST",
            body: jsonData
        )
    }

    // MARK: - Report Sale

    /// Reports a sale for review.
    func reportSale(saleId: UUID, reason: String, details: String? = nil) async throws {
        let components = urlComponents(path: "/api/sales/\(saleId.uuidString)/report")

        var body: [String: String] = ["reason": reason]
        if let details, !details.isEmpty {
            body["details"] = details
        }
        let jsonData = try JSONSerialization.data(withJSONObject: body)

        let _: MessageResponse = try await performRequest(
            components: components,
            method: "POST",
            body: jsonData
        )
    }

    // MARK: - Upload Photo

    /// Uploads an image and returns the public URL.
    func uploadPhoto(imageData: Data) async throws -> String {
        guard let url = URL(string: "\(APIConfig.apiBaseURL)/upload") else {
            throw SupabaseError.invalidURL
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        // Build multipart body
        var bodyData = Data()
        bodyData.append(contentsOf: "--\(boundary)\r\n".utf8)
        bodyData.append(contentsOf: "Content-Disposition: form-data; name=\"file\"; filename=\"photo.jpg\"\r\n".utf8)
        bodyData.append(contentsOf: "Content-Type: image/jpeg\r\n\r\n".utf8)
        bodyData.append(imageData)
        bodyData.append(contentsOf: "\r\n--\(boundary)--\r\n".utf8)
        request.httpBody = bodyData

        let (data, response) = try await performRawRequest(request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }

        if httpResponse.statusCode == 429 {
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
            throw SupabaseError.rateLimited(retryAfter: retryAfter)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = (try? decoder.decode(ErrorResponse.self, from: data))?.error ?? "Upload failed"
            throw SupabaseError.httpError(statusCode: httpResponse.statusCode, message: message)
        }

        let uploadResponse = try decoder.decode(UploadResponse.self, from: data)
        return uploadResponse.url
    }

    // MARK: - Fetch State Counts

    /// Fetches the count of active upcoming sales per state.
    /// Uses the standard sales endpoint grouped client-side.
    func fetchStateCounts() async throws -> [String: Int] {
        // Fetch a broad set of sales and group by state client-side
        var components = urlComponents(path: "/api/sales")
        components.queryItems = [
            URLQueryItem(name: "limit", value: "50"),
        ]

        let response: SalesResponse = try await performRequest(components: components)

        var counts: [String: Int] = [:]
        for sale in response.sales {
            counts[sale.state, default: 0] += 1
        }
        return counts
    }

    // MARK: - Private Helpers

    private func urlComponents(path: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = URL(string: APIConfig.baseURL)?.host ?? "trashtrove.app"
        components.path = path
        return components
    }

    private func performRequest<T: Decodable>(
        components: URLComponents,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> T {
        guard let url = components.url else {
            throw SupabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body

        if method != "GET" {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await performRawRequest(request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }

        logger.debug("[\(method)] \(url.absoluteString) -> \(httpResponse.statusCode)")

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401, 403:
            throw SupabaseError.unauthorized
        case 404:
            throw SupabaseError.notFound
        case 429:
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
            throw SupabaseError.rateLimited(retryAfter: retryAfter)
        case 500...599:
            let message = (try? decoder.decode(ErrorResponse.self, from: data))?.error ?? "Server error"
            throw SupabaseError.serverError
        default:
            let message = (try? decoder.decode(ErrorResponse.self, from: data))?.error ?? "Unknown error"
            throw SupabaseError.httpError(statusCode: httpResponse.statusCode, message: message)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error("Decoding failed: \(error.localizedDescription)")
            throw SupabaseError.decodingError(error)
        }
    }

    private func performRawRequest(_ request: URLRequest, maxRetries: Int = 3) async throws -> (Data, URLResponse) {
        var lastError: Error?
        for attempt in 0...maxRetries {
            do {
                return try await session.data(for: request)
            } catch let error as URLError where error.code == .timedOut || error.code == .networkConnectionLost || error.code == .notConnectedToInternet {
                lastError = error
                if attempt < maxRetries {
                    let delay = UInt64(pow(2.0, Double(attempt))) * 1_000_000_000 // exponential backoff
                    logger.warning("Request failed (attempt \(attempt + 1)/\(maxRetries + 1)), retrying in \(pow(2.0, Double(attempt)))s...")
                    try await Task.sleep(nanoseconds: delay)
                }
            } catch let error as URLError {
                logger.error("Network error: \(error.localizedDescription)")
                throw SupabaseError.networkError(error)
            } catch {
                throw SupabaseError.networkError(error)
            }
        }
        throw SupabaseError.networkError(lastError ?? URLError(.unknown))
    }
}
