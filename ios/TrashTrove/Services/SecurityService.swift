import Foundation
import Security
import CryptoKit
import os

// MARK: - SecurityService

final class SecurityService: @unchecked Sendable {

    static let shared = SecurityService()

    private let logger = Logger(subsystem: "app.trashtrove", category: "Security")

    private init() {}

    // MARK: - Certificate Pinning

    /// Returns a URLSession configured with certificate pinning for trashtrove.app.
    func pinnedURLSession(delegate: URLSessionDelegate? = nil) -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let pinningDelegate = delegate ?? CertificatePinningDelegate()
        return URLSession(configuration: config, delegate: pinningDelegate, delegateQueue: nil)
    }

    // MARK: - Input Sanitization

    /// Strips HTML tags from a string.
    func stripHTML(_ input: String) -> String {
        guard !input.isEmpty else { return input }
        // Remove HTML tags
        let stripped = input.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression,
            range: nil
        )
        // Decode common HTML entities
        return stripped
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
    }

    /// Limits a string to a given length, trimming whitespace.
    func sanitizeString(_ input: String, maxLength: Int) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let stripped = stripHTML(trimmed)
        if stripped.count > maxLength {
            return String(stripped.prefix(maxLength))
        }
        return stripped
    }

    // MARK: - Rate Limiting (In-Memory)

    private struct RateLimitEntry {
        var timestamps: [Date]
    }

    private var rateLimits: [String: RateLimitEntry] = [:]
    private let rateLimitQueue = DispatchQueue(label: "app.trashtrove.ratelimit")

    /// Pre-defined rate limit categories matching the web backend.
    enum RateLimitCategory: String {
        case createSale = "sales"          // 5 per hour
        case upload = "upload"              // 30 per hour
        case report = "report"             // 5 per hour
        case contact = "contact"           // 10 per hour

        var maxRequests: Int {
            switch self {
            case .createSale: return 5
            case .upload: return 30
            case .report: return 5
            case .contact: return 10
            }
        }

        var windowSeconds: TimeInterval {
            3600 // 1 hour for all categories
        }
    }

    struct RateLimitResult {
        let allowed: Bool
        let remaining: Int
        let resetsAt: Date?
    }

    /// Checks and records a rate limit hit. Returns whether the request is allowed.
    func checkRateLimit(_ category: RateLimitCategory) -> RateLimitResult {
        rateLimitQueue.sync {
            let key = category.rawValue
            let now = Date()
            let windowStart = now.addingTimeInterval(-category.windowSeconds)

            var entry = rateLimits[key] ?? RateLimitEntry(timestamps: [])

            // Remove expired timestamps
            entry.timestamps.removeAll { $0 < windowStart }

            let remaining = max(0, category.maxRequests - entry.timestamps.count)

            if entry.timestamps.count >= category.maxRequests {
                let oldestInWindow = entry.timestamps.first
                let resetsAt = oldestInWindow?.addingTimeInterval(category.windowSeconds)
                rateLimits[key] = entry
                logger.warning("Rate limit exceeded for \(category.rawValue)")
                return RateLimitResult(allowed: false, remaining: 0, resetsAt: resetsAt)
            }

            entry.timestamps.append(now)
            rateLimits[key] = entry
            return RateLimitResult(allowed: true, remaining: remaining - 1, resetsAt: nil)
        }
    }

    /// Resets rate limit tracking (useful for testing).
    func resetRateLimits() {
        rateLimitQueue.sync {
            rateLimits.removeAll()
        }
    }

    // MARK: - Jailbreak Detection

    /// Returns true if the device appears to be jailbroken.
    /// This is a best-effort heuristic and not foolproof.
    var isJailbroken: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        // Check for common jailbreak files
        let suspiciousPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/",
            "/usr/bin/ssh",
            "/private/var/stash",
            "/Applications/Sileo.app",
        ]

        for path in suspiciousPaths {
            if FileManager.default.fileExists(atPath: path) {
                logger.warning("Jailbreak indicator found: \(path)")
                return true
            }
        }

        // Check if we can write to a protected path
        let testPath = "/private/jailbreak_test_\(UUID().uuidString)"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            logger.warning("Jailbreak detected: able to write to protected path")
            return true
        } catch {
            // Expected on non-jailbroken devices
        }

        // Check if we can open a Cydia URL scheme
        if let url = URL(string: "cydia://package/com.example.package"),
           UIApplication.shared.canOpenURL(url) {
            return true
        }

        return false
        #endif
    }

    // MARK: - Keychain Helpers

    enum KeychainError: LocalizedError {
        case duplicateEntry
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case dataConversionError

        var errorDescription: String? {
            switch self {
            case .duplicateEntry:
                return "Item already exists in keychain."
            case .itemNotFound:
                return "Item not found in keychain."
            case .unexpectedStatus(let status):
                return "Keychain error: \(status)"
            case .dataConversionError:
                return "Failed to convert keychain data."
            }
        }
    }

    private let keychainServicePrefix = "app.trashtrove"

    /// Saves a string value to the keychain.
    func keychainSave(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.dataConversionError
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainServicePrefix,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        // Delete any existing item first
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            logger.error("Keychain save failed for key '\(key)': \(status)")
            throw KeychainError.unexpectedStatus(status)
        }

        logger.debug("Saved to keychain: \(key)")
    }

    /// Reads a string value from the keychain.
    func keychainRead(key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainServicePrefix,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unexpectedStatus(status)
        }

        guard let data = result as? Data, let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.dataConversionError
        }

        return string
    }

    /// Deletes a value from the keychain.
    func keychainDelete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainServicePrefix,
            kSecAttrAccount as String: key,
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    /// Convenience: save a manage token for a sale.
    func saveManageToken(_ token: String, forSaleId saleId: UUID) throws {
        try keychainSave(key: "manage_token_\(saleId.uuidString)", value: token)
    }

    /// Convenience: retrieve a manage token for a sale.
    func getManageToken(forSaleId saleId: UUID) -> String? {
        try? keychainRead(key: "manage_token_\(saleId.uuidString)")
    }

    /// Convenience: delete a manage token for a sale.
    func deleteManageToken(forSaleId saleId: UUID) {
        try? keychainDelete(key: "manage_token_\(saleId.uuidString)")
    }

    // MARK: - Content Validation

    /// Validates an email address format.
    func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: email)
    }

    /// Validates a US ZIP code (5-digit or ZIP+4 format).
    func isValidZIP(_ zip: String) -> Bool {
        let pattern = #"^\d{5}(-\d{4})?$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: zip)
    }

    /// Checks for obvious profanity placeholders / test strings.
    /// This is a lightweight client-side filter; real filtering should happen server-side.
    func containsProfanityPlaceholder(_ text: String) -> Bool {
        let lowered = text.lowercased()
        let blockedPatterns = [
            "test1234",
            "asdfasdf",
            "aaaaaaa",
            "lorem ipsum",
            "xxx",
            "fuck",
            "shit",
        ]
        return blockedPatterns.contains { lowered.contains($0) }
    }

    /// Validates that a US state code is a recognized 2-letter abbreviation.
    func isValidStateCode(_ code: String) -> Bool {
        let states: Set<String> = [
            "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
            "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
            "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
            "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
            "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY",
            "DC", "PR", "VI", "GU", "AS", "MP",
        ]
        return states.contains(code.uppercased())
    }
}

// MARK: - Certificate Pinning Delegate

final class CertificatePinningDelegate: NSObject, URLSessionDelegate {

    private let logger = Logger(subsystem: "app.trashtrove", category: "CertPinning")

    // SHA-256 hashes of the public keys for trashtrove.app certificate chain.
    // Update these when certificates are rotated.
    private let pinnedPublicKeyHashes: Set<String> = [
        // Placeholder - replace with actual public key hashes before release
        "REPLACE_WITH_ACTUAL_PUBLIC_KEY_HASH_BASE64",
    ]

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Verify the server trust is valid
        var error: CFError?
        let isValid = SecTrustEvaluateWithError(serverTrust, &error)

        guard isValid else {
            logger.error("Server trust evaluation failed: \(String(describing: error))")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // If no real hashes are configured, skip pinning (development mode)
        if pinnedPublicKeyHashes.contains("REPLACE_WITH_ACTUAL_PUBLIC_KEY_HASH_BASE64") {
            logger.warning("Certificate pinning not configured - using default trust evaluation")
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            return
        }

        // Check each certificate in the chain against our pinned hashes
        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        var pinMatched = false

        for index in 0..<certificateCount {
            guard let certificate = SecTrustCopyCertificateChain(serverTrust)?[index] as? SecCertificate else {
                continue
            }

            // Extract the public key and hash it
            if let publicKey = SecCertificateCopyKey(certificate),
               let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as? Data {
                let hash = SHA256.hash(data: publicKeyData)
                let hashString = Data(hash).base64EncodedString()

                if pinnedPublicKeyHashes.contains(hashString) {
                    pinMatched = true
                    break
                }
            }
        }

        if pinMatched {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            logger.error("Certificate pinning failed - no matching public key found")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
