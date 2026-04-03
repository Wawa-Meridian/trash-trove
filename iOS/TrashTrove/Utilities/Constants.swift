import SwiftUI

// MARK: - API Configuration

enum API {
    static let baseURL = "https://trashtrove.app/api"

    static let salesEndpoint = "\(baseURL)/sales"
    static let nearbySalesEndpoint = "\(baseURL)/sales/nearby"
    static let contactEndpoint = "\(baseURL)/contact"
    static let reportEndpoint = "\(baseURL)/report"

    static func saleEndpoint(id: UUID) -> String {
        "\(salesEndpoint)/\(id.uuidString)"
    }

    static func salePhotosEndpoint(id: UUID) -> String {
        "\(salesEndpoint)/\(id.uuidString)/photos"
    }
}

// MARK: - Rate Limits

enum RateLimit {
    static let maxRequestsPerMinute = 60
    static let maxCreateSalesPerHour = 5
    static let maxContactMessagesPerHour = 10
    static let maxReportsPerHour = 5
}

// MARK: - Sale Categories

let SALE_CATEGORIES: [String] = [
    "Furniture",
    "Clothing",
    "Electronics",
    "Books",
    "Toys & Games",
    "Kitchen & Dining",
    "Tools & Hardware",
    "Sports & Outdoors",
    "Collectibles & Antiques",
    "Baby & Kids",
    "Home Decor",
    "Garden & Patio",
    "Vehicles & Parts",
    "Musical Instruments",
    "Art & Crafts",
    "Jewelry & Accessories",
    "Everything Must Go",
    "Other"
]

// MARK: - US States

let US_STATES: [String: String] = [
    "AL": "Alabama",
    "AK": "Alaska",
    "AZ": "Arizona",
    "AR": "Arkansas",
    "CA": "California",
    "CO": "Colorado",
    "CT": "Connecticut",
    "DE": "Delaware",
    "DC": "District of Columbia",
    "FL": "Florida",
    "GA": "Georgia",
    "HI": "Hawaii",
    "ID": "Idaho",
    "IL": "Illinois",
    "IN": "Indiana",
    "IA": "Iowa",
    "KS": "Kansas",
    "KY": "Kentucky",
    "LA": "Louisiana",
    "ME": "Maine",
    "MD": "Maryland",
    "MA": "Massachusetts",
    "MI": "Michigan",
    "MN": "Minnesota",
    "MS": "Mississippi",
    "MO": "Missouri",
    "MT": "Montana",
    "NE": "Nebraska",
    "NV": "Nevada",
    "NH": "New Hampshire",
    "NJ": "New Jersey",
    "NM": "New Mexico",
    "NY": "New York",
    "NC": "North Carolina",
    "ND": "North Dakota",
    "OH": "Ohio",
    "OK": "Oklahoma",
    "OR": "Oregon",
    "PA": "Pennsylvania",
    "RI": "Rhode Island",
    "SC": "South Carolina",
    "SD": "South Dakota",
    "TN": "Tennessee",
    "TX": "Texas",
    "UT": "Utah",
    "VT": "Vermont",
    "VA": "Virginia",
    "WA": "Washington",
    "WV": "West Virginia",
    "WI": "Wisconsin",
    "WY": "Wyoming"
]

/// Sorted array of state codes for display in pickers
let US_STATE_CODES: [String] = US_STATES.keys.sorted()

// MARK: - Color Palette

extension Color {

    // MARK: Treasure (Gold)

    static let treasure50  = Color(hex: 0xFDF8F0)
    static let treasure100 = Color(hex: 0xF9EDDB)
    static let treasure200 = Color(hex: 0xF2D8B4)
    static let treasure300 = Color(hex: 0xE9BD83)
    static let treasure400 = Color(hex: 0xDF9C4F)
    static let treasure500 = Color(hex: 0xD6832E)
    static let treasure600 = Color(hex: 0xC76B23)
    static let treasure700 = Color(hex: 0xA5521F)
    static let treasure800 = Color(hex: 0x854220)
    static let treasure900 = Color(hex: 0x6C371D)
    static let treasure950 = Color(hex: 0x3A1B0D)

    /// Primary gold accent color (treasure 500)
    static let treasureGoldPrimary = treasure500

    // Convenience aliases used by views
    static let treasureGold50 = treasure50
    static let treasureGold600 = treasure600
    static let treasureGold800 = treasure800
    static let treasureGold900 = treasure900

    // MARK: Forest (Green)

    static let forest50  = Color(hex: 0xF0FDF4)
    static let forest100 = Color(hex: 0xDCFCE7)
    static let forest200 = Color(hex: 0xBBF7D0)
    static let forest300 = Color(hex: 0x86EFAC)
    static let forest400 = Color(hex: 0x4ADE80)
    static let forest500 = Color(hex: 0x22C55E)
    static let forest600 = Color(hex: 0x16A34A)
    static let forest700 = Color(hex: 0x15803D)
    static let forest800 = Color(hex: 0x166534)
    static let forest900 = Color(hex: 0x14532D)
    static let forest950 = Color(hex: 0x052E16)

    /// Primary green accent color (forest 600)
    static let forestGreenPrimary = forest600

    // Convenience aliases used by views
    static let forestGreen50 = forest50
    static let forestGreen600 = forest600
}
