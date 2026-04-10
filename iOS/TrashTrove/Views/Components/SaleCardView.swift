import SwiftUI

struct SaleCardView: View {
    let sale: GarageSale
    var distanceMiles: Double?
    var isFavorited: Bool = false
    var onFavoriteToggle: (() -> Void)?

    @State private var isPressed = false

    var body: some View {
        NavigationLink(value: sale) {
            VStack(alignment: .leading, spacing: 0) {
                photoSection
                detailsSection
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Photo Section

    private var photoSection: some View {
        ZStack(alignment: .topTrailing) {
            coverPhoto
                .aspectRatio(4.0 / 3.0, contentMode: .fill)
                .clipped()

            // Overlays
            VStack {
                HStack {
                    if let distance = effectiveDistance {
                        distanceBadge(distance)
                    }
                    Spacer()
                    favoriteButton
                }
                .padding(10)

                Spacer()

                HStack {
                    Spacer()
                    if sale.photos.count > 0 {
                        photoCountBadge
                    }
                }
                .padding(10)
            }
        }
    }

    @ViewBuilder
    private var coverPhoto: some View {
        if let photo = sale.primaryPhoto, let url = photo.imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    photoPlaceholder
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.treasure50)
                @unknown default:
                    photoPlaceholder
                }
            }
        } else {
            photoPlaceholder
        }
    }

    private var photoPlaceholder: some View {
        ZStack {
            Color.treasure50
            Image(systemName: "camera")
                .font(.title)
                .foregroundStyle(Color.treasure300)
        }
    }

    private var favoriteButton: some View {
        Button {
            onFavoriteToggle?()
        } label: {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isFavorited ? .red : .white)
                .frame(width: 34, height: 34)
                .background(.black.opacity(0.45))
                .clipShape(Circle())
        }
        .accessibilityLabel(isFavorited ? "Remove from favorites" : "Add to favorites")
    }

    private func distanceBadge(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.forestGreen.opacity(0.85))
            .clipShape(Capsule())
            .accessibilityLabel("Distance: \(text)")
    }

    private var photoCountBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "photo")
                .font(.caption2)
            Text("\(sale.photos.count) photos")
                .font(.caption2.weight(.medium))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.black.opacity(0.55))
        .clipShape(Capsule())
        .accessibilityLabel("\(sale.photos.count) photos")
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(sale.title)
                .font(.headline)
                .foregroundStyle(Color.primary)
                .lineLimit(2)

            HStack(spacing: 4) {
                Image(systemName: "mappin")
                    .font(.caption)
                    .foregroundStyle(Color.treasure600)
                Text("\(sale.city), \(sale.state)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Location: \(sale.city), \(sale.state)")

            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundStyle(Color.treasure600)
                    Text(sale.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundStyle(Color.treasure600)
                    Text(sale.formattedTimeRange)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Date: \(sale.formattedDate), Time: \(sale.formattedTimeRange)")

            categoryPills
        }
        .padding(12)
    }

    @ViewBuilder
    private var categoryPills: some View {
        if !sale.categories.isEmpty {
            HStack(spacing: 6) {
                let visibleCategories = Array(sale.categories.prefix(3))
                let overflow = sale.categories.count - 3

                ForEach(visibleCategories, id: \.self) { category in
                    CategoryBadgeView(label: category)
                }

                if overflow > 0 {
                    Text("+\(overflow)")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.treasure700)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.treasure50)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: - Helpers

    private var effectiveDistance: String? {
        if let dist = distanceMiles {
            if dist < 0.1 {
                return "Nearby"
            } else if dist < 10 {
                return String(format: "%.1f mi", dist)
            } else {
                return String(format: "%.0f mi", dist)
            }
        }
        return sale.formattedDistance
    }

    private var accessibilityDescription: String {
        var parts = [sale.title, "\(sale.city), \(sale.state)", sale.formattedDate, sale.formattedTimeRange]
        if let dist = effectiveDistance {
            parts.append(dist)
        }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Preview

#Preview("Sale Card") {
    let sampleSale = GarageSale(
        id: UUID(),
        title: "Huge Moving Sale - Everything Must Go!",
        description: "Lots of great items at low prices.",
        categories: ["Furniture", "Electronics", "Kitchen & Dining", "Books"],
        address: "123 Main St",
        city: "Austin",
        state: "TX",
        zip: "78701",
        latitude: 30.2672,
        longitude: -97.7431,
        saleDate: "2026-04-05",
        startTime: "08:00",
        endTime: "14:00",
        photos: [],
        sellerName: "Jane Doe",
        sellerEmail: "jane@example.com",
        createdAt: "2026-04-01T12:00:00Z",
        isActive: true,
        manageToken: nil,
        distanceMiles: 2.3
    )

    NavigationStack {
        ScrollView {
            SaleCardView(sale: sampleSale, distanceMiles: 2.3)
                .padding()
        }
    }
}
