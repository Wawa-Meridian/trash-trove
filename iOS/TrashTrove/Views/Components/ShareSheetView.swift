import SwiftUI

struct ShareSheetView: View {
    let sale: GarageSale

    var body: some View {
        ShareLink(
            item: shareURL,
            subject: Text(sale.title),
            message: Text(shareMessage)
        ) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        .accessibilityLabel("Share this sale")
        .accessibilityHint("Opens share sheet for \(sale.title)")
    }

    private var shareURL: URL {
        URL(string: "https://trashtrove.app/sale/\(sale.id.uuidString)")!
    }

    private var shareMessage: Text {
        Text("Check out this garage sale: \(sale.title) in \(sale.city), \(sale.state) on \(sale.formattedDate)")
    }
}

/// A button-styled share view for use in toolbars or standalone placements.
struct ShareButton: View {
    let sale: GarageSale
    var style: ShareButtonStyle = .icon

    enum ShareButtonStyle {
        case icon
        case label
        case compact
    }

    var body: some View {
        let url = URL(string: "https://trashtrove.app/sale/\(sale.id.uuidString)")!

        ShareLink(
            item: url,
            subject: Text(sale.title),
            message: Text("Check out this garage sale: \(sale.title) in \(sale.city), \(sale.state)")
        ) {
            switch style {
            case .icon:
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .medium))
            case .label:
                Label("Share Sale", systemImage: "square.and.arrow.up")
            case .compact:
                HStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.caption)
                    Text("Share")
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(Color.treasure600)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.treasure50)
                .clipShape(Capsule())
            }
        }
        .accessibilityLabel("Share \(sale.title)")
    }
}

// MARK: - Preview

#Preview("Share Sheet") {
    let sale = GarageSale(
        id: UUID(),
        title: "Big Weekend Yard Sale",
        description: "Come find treasures!",
        categories: ["Furniture", "Electronics"],
        address: "789 Pine St",
        city: "Portland",
        state: "OR",
        zip: "97201",
        latitude: 45.5152,
        longitude: -122.6784,
        saleDate: "2026-04-05",
        startTime: "09:00",
        endTime: "15:00",
        photos: [],
        sellerName: "Mike",
        sellerEmail: "mike@example.com",
        createdAt: "2026-04-01",
        isActive: true,
        manageToken: nil,
        distanceMiles: nil
    )

    VStack(spacing: 20) {
        ShareSheetView(sale: sale)
        ShareButton(sale: sale, style: .icon)
        ShareButton(sale: sale, style: .label)
        ShareButton(sale: sale, style: .compact)
    }
    .padding()
}
