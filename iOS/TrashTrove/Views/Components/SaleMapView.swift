import SwiftUI
import MapKit

struct SaleMapView: View {
    let sales: [GarageSale]
    var showsUserLocation: Bool = true
    var initialCenter: CLLocationCoordinate2D?
    var initialSpan: MKCoordinateSpan?
    var onSaleSelected: ((GarageSale) -> Void)?

    @State private var selectedSale: GarageSale?
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $cameraPosition, selection: $selectedSale) {
            if showsUserLocation {
                UserAnnotation()
            }

            ForEach(locatableSales) { sale in
                Annotation(
                    sale.title,
                    coordinate: CLLocationCoordinate2D(
                        latitude: sale.latitude ?? 0,
                        longitude: sale.longitude ?? 0
                    ),
                    anchor: .bottom
                ) {
                    saleAnnotationView(for: sale)
                }
                .tag(sale)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .onAppear {
            configureInitialPosition()
        }
        .onChange(of: selectedSale) { _, newValue in
            if let sale = newValue {
                onSaleSelected?(sale)
            }
        }
        .accessibilityLabel("Map showing \(locatableSales.count) sale\(locatableSales.count == 1 ? "" : "s")")
    }

    // MARK: - Annotation View

    private func saleAnnotationView(for sale: GarageSale) -> some View {
        VStack(spacing: 0) {
            if selectedSale == sale {
                calloutView(for: sale)
                    .transition(.scale.combined(with: .opacity))
            }

            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundStyle(Color.treasure600)
                .background(
                    Circle()
                        .fill(.white)
                        .frame(width: 24, height: 24)
                )
        }
        .animation(.easeInOut(duration: 0.2), value: selectedSale)
        .onTapGesture {
            withAnimation {
                if selectedSale == sale {
                    selectedSale = nil
                } else {
                    selectedSale = sale
                }
            }
        }
        .accessibilityLabel("\(sale.title), \(sale.city), \(sale.state)")
        .accessibilityHint("Double tap to select this sale")
    }

    private func calloutView(for sale: GarageSale) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(sale.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.primary)
                .lineLimit(1)

            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 9))
                Text(sale.formattedDate)
                    .font(.system(size: 10))
            }
            .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 9))
                Text(sale.formattedTimeRange)
                    .font(.system(size: 10))
            }
            .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
        .frame(maxWidth: 180)
    }

    // MARK: - Helpers

    private var locatableSales: [GarageSale] {
        sales.filter { $0.hasLocation }
    }

    private func configureInitialPosition() {
        if let center = initialCenter {
            let span = initialSpan ?? MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
        } else if locatableSales.count == 1, let sale = locatableSales.first {
            let coord = CLLocationCoordinate2D(
                latitude: sale.latitude ?? 0,
                longitude: sale.longitude ?? 0
            )
            cameraPosition = .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ))
        } else {
            cameraPosition = .automatic
        }
    }
}

// MARK: - Convenience Initializer for Single Sale

extension SaleMapView {
    /// Creates a map view for a single sale on the detail page.
    init(sale: GarageSale, showsUserLocation: Bool = true) {
        self.init(
            sales: [sale],
            showsUserLocation: showsUserLocation,
            initialCenter: sale.hasLocation
                ? CLLocationCoordinate2D(latitude: sale.latitude!, longitude: sale.longitude!)
                : nil,
            initialSpan: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
}

// MARK: - Preview

#Preview("Single Sale Map") {
    let sale = GarageSale(
        id: UUID(),
        title: "Weekend Garage Sale",
        description: "Great finds!",
        categories: ["Furniture"],
        address: "456 Oak Ave",
        city: "Austin",
        state: "TX",
        zip: "78701",
        latitude: 30.2672,
        longitude: -97.7431,
        saleDate: "2026-04-05",
        startTime: "08:00",
        endTime: "14:00",
        photos: [],
        sellerName: "John",
        sellerEmail: "john@example.com",
        createdAt: "2026-04-01T12:00:00Z",
        isActive: true,
        manageToken: nil,
        distanceMiles: nil
    )

    SaleMapView(sale: sale)
        .frame(height: 300)
}

#Preview("Multi Sale Map") {
    let sales = [
        GarageSale(
            id: UUID(), title: "Sale 1", description: "", categories: [],
            address: "123 Main", city: "Austin", state: "TX", zip: "78701",
            latitude: 30.2672, longitude: -97.7431,
            saleDate: "2026-04-05", startTime: "08:00", endTime: "14:00",
            photos: [], sellerName: "A", sellerEmail: "a@b.com",
            createdAt: "2026-04-01", isActive: true, manageToken: nil, distanceMiles: nil
        ),
        GarageSale(
            id: UUID(), title: "Sale 2", description: "", categories: [],
            address: "456 Elm", city: "Austin", state: "TX", zip: "78702",
            latitude: 30.2750, longitude: -97.7400,
            saleDate: "2026-04-05", startTime: "09:00", endTime: "15:00",
            photos: [], sellerName: "B", sellerEmail: "b@c.com",
            createdAt: "2026-04-01", isActive: true, manageToken: nil, distanceMiles: nil
        ),
    ]

    SaleMapView(sales: sales)
        .frame(height: 400)
}
