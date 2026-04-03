import Foundation

struct SalePhoto: Codable, Identifiable, Equatable {
    let id: UUID
    let saleId: UUID
    let url: String
    let caption: String?
    let displayOrder: Int

    enum CodingKeys: String, CodingKey {
        case id
        case saleId = "sale_id"
        case url
        case caption
        case displayOrder = "display_order"
    }

    var imageURL: URL? {
        URL(string: url)
    }

    static func == (lhs: SalePhoto, rhs: SalePhoto) -> Bool {
        lhs.id == rhs.id
    }
}
