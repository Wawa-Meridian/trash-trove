import Foundation

enum ReportReason: String, Codable, CaseIterable, Identifiable {
    case spam
    case scam
    case inappropriate
    case duplicate
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .spam: return "Spam"
        case .scam: return "Scam"
        case .inappropriate: return "Inappropriate"
        case .duplicate: return "Duplicate"
        case .other: return "Other"
        }
    }
}

struct SaleReport: Codable {
    let id: UUID?
    let saleId: UUID
    let reason: ReportReason
    let details: String?

    enum CodingKeys: String, CodingKey {
        case id
        case saleId = "sale_id"
        case reason
        case details
    }
}
