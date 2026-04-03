import Foundation

struct CreateSaleInput: Codable {
    var title: String
    var description: String
    var categories: [String]
    var address: String
    var city: String
    var state: String
    var zip: String
    var saleDate: String
    var startTime: String
    var endTime: String
    var sellerName: String
    var sellerEmail: String

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case categories
        case address
        case city
        case state
        case zip
        case saleDate = "sale_date"
        case startTime = "start_time"
        case endTime = "end_time"
        case sellerName = "seller_name"
        case sellerEmail = "seller_email"
    }

    static var empty: CreateSaleInput {
        CreateSaleInput(
            title: "",
            description: "",
            categories: [],
            address: "",
            city: "",
            state: "",
            zip: "",
            saleDate: "",
            startTime: "08:00",
            endTime: "14:00",
            sellerName: "",
            sellerEmail: ""
        )
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        !categories.isEmpty &&
        !address.trimmingCharacters(in: .whitespaces).isEmpty &&
        !city.trimmingCharacters(in: .whitespaces).isEmpty &&
        state.count == 2 &&
        !zip.trimmingCharacters(in: .whitespaces).isEmpty &&
        !saleDate.isEmpty &&
        !startTime.isEmpty &&
        !endTime.isEmpty &&
        !sellerName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !sellerEmail.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
