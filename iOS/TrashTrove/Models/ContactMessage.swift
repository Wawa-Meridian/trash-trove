import Foundation

struct ContactMessage: Codable {
    let id: UUID?
    let saleId: UUID
    let senderName: String
    let senderEmail: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case id
        case saleId = "sale_id"
        case senderName = "sender_name"
        case senderEmail = "sender_email"
        case message
    }
}
