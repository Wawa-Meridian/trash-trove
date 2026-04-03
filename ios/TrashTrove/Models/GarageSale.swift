import Foundation

struct GarageSale: Codable, Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let categories: [String]
    let address: String
    let city: String
    let state: String
    let zip: String
    let latitude: Double?
    let longitude: Double?
    let saleDate: String
    let startTime: String
    let endTime: String
    let photos: [SalePhoto]
    let sellerName: String
    let sellerEmail: String
    let createdAt: String
    let isActive: Bool
    let manageToken: String?
    let distanceMiles: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case categories
        case address
        case city
        case state
        case zip
        case latitude
        case longitude
        case saleDate = "sale_date"
        case startTime = "start_time"
        case endTime = "end_time"
        case photos
        case sellerName = "seller_name"
        case sellerEmail = "seller_email"
        case createdAt = "created_at"
        case isActive = "is_active"
        case manageToken = "manage_token"
        case distanceMiles = "distance_miles"
    }

    // MARK: - Computed Properties

    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        guard let date = formatter.date(from: saleDate) else { return saleDate }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .long
        displayFormatter.timeStyle = .none
        return displayFormatter.string(from: date)
    }

    var formattedTimeRange: String {
        "\(formattedTime(startTime)) - \(formattedTime(endTime))"
    }

    var fullAddress: String {
        "\(address), \(city), \(state) \(zip)"
    }

    var hasLocation: Bool {
        latitude != nil && longitude != nil
    }

    var formattedDistance: String? {
        guard let miles = distanceMiles else { return nil }
        if miles < 0.1 {
            return "Nearby"
        } else if miles < 10 {
            return String(format: "%.1f mi", miles)
        } else {
            return String(format: "%.0f mi", miles)
        }
    }

    var primaryPhoto: SalePhoto? {
        photos.sorted { $0.displayOrder < $1.displayOrder }.first
    }

    var saleDateAsDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.date(from: saleDate)
    }

    // MARK: - Helpers

    private func formattedTime(_ time: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm"
        guard let date = inputFormatter.date(from: time) else { return time }
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        return outputFormatter.string(from: date)
    }

    // MARK: - Equatable

    static func == (lhs: GarageSale, rhs: GarageSale) -> Bool {
        lhs.id == rhs.id
    }
}
