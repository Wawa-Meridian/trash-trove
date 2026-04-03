import SwiftUI
import MapKit

struct NearbyView: View {
    @StateObject private var viewModel = NearbyViewModel()
    @EnvironmentObject var locationService: LocationService

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.locationState {
                case .loading:
                    loadingState
                case .denied:
                    deniedState
                case .ready:
                    readyState
                }
            }
            .navigationTitle("Nearby Sales")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                AnalyticsService.shared.trackScreen("Nearby")
                viewModel.setup(locationService: locationService)
                viewModel.checkLocationAndLoad()
            }
        }
    }

    // MARK: - Loading State

    private var loadingState: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Requesting your location...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel("Requesting location access")
    }

    // MARK: - Denied State

    private var deniedState: some View {
        VStack(spacing: 24) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text("Location Access Required")
                .font(.custom("Georgia", size: 24))
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)

            Text("Enable location services in Settings to discover garage sales near you.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 12) {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open Settings", systemImage: "gear")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.treasureGold600)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityLabel("Open device settings to enable location")

                NavigationLink(destination: BrowseView()) {
                    Text("Browse Sales Instead")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.treasureGold600)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.treasureGold600.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityLabel("Browse all garage sales by state")
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Ready State

    private var readyState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                mapSection
                radiusSelector
                salesSection
            }
            .padding(.vertical, 16)
        }
        .refreshable {
            await viewModel.loadNearbySales()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Garage Sales Near You")
                .font(.custom("Georgia", size: 28))
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)

            if viewModel.isLoading {
                Text("Searching...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("\(viewModel.sales.count) sale\(viewModel.sales.count == 1 ? "" : "s") within \(viewModel.radius) miles")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Map

    private var mapSection: some View {
        Group {
            if case .ready(let coordinate) = viewModel.locationState {
                NearbyMapView(
                    center: coordinate,
                    sales: viewModel.sales,
                    radiusMiles: viewModel.radius
                )
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                .padding(.horizontal, 16)
                .accessibilityLabel("Map showing \(viewModel.sales.count) nearby garage sales")
            }
        }
    }

    // MARK: - Radius Selector

    private var radiusSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Search Radius")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach([10, 25, 50, 100], id: \.self) { miles in
                        radiusButton(miles: miles)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Search radius selector")
    }

    private func radiusButton(miles: Int) -> some View {
        Button {
            viewModel.updateRadius(miles)
        } label: {
            Text("\(miles) mi")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(viewModel.radius == miles ? .white : .treasureGold600)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(viewModel.radius == miles ? Color.treasureGold600 : Color.treasureGold600.opacity(0.12))
                .clipShape(Capsule())
        }
        .accessibilityLabel("\(miles) miles radius")
        .accessibilityAddTraits(viewModel.radius == miles ? .isSelected : [])
    }

    // MARK: - Sales Section

    private var salesSection: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .accessibilityLabel("Loading nearby sales")
            } else if let error = viewModel.error {
                errorView(message: error)
            } else if viewModel.sales.isEmpty {
                emptyState
            } else {
                salesGrid
            }
        }
    }

    private var salesGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
        ]

        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.sales) { sale in
                NavigationLink(destination: SaleDetailView(saleId: sale.id)) {
                    ZStack(alignment: .topTrailing) {
                        SaleCardView(sale: sale)

                        if let distance = sale.formattedDistance {
                            Text("\(distance) away")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.forestGreen.opacity(0.9))
                                .clipShape(Capsule())
                                .padding(8)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(sale.title), \(sale.formattedDistance ?? "") away")
            }
        }
        .padding(.horizontal, 16)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text("No Sales Nearby")
                .font(.custom("Georgia", size: 22))
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)

            Text("There are no garage sales within \(viewModel.radius) miles of your location.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let nextRadius = viewModel.nextLargerRadius {
                Button {
                    viewModel.updateRadius(nextRadius)
                } label: {
                    Label("Expand to \(nextRadius) miles", systemImage: "arrow.up.left.and.arrow.down.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.treasureGold600)
                        .clipShape(Capsule())
                }
                .accessibilityLabel("Expand search to \(nextRadius) miles")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    await viewModel.loadNearbySales()
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.treasureGold600)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Nearby Map View

struct NearbyMapView: UIViewRepresentable {
    let center: CLLocationCoordinate2D
    let sales: [GarageSale]
    let radiusMiles: Int

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.isRotateEnabled = false
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Set region based on radius
        let radiusMeters = Double(radiusMiles) * 1609.34
        let region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: radiusMeters * 2,
            longitudinalMeters: radiusMeters * 2
        )
        mapView.setRegion(region, animated: true)

        // Update annotations
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })

        let annotations = sales.compactMap { sale -> MKPointAnnotation? in
            guard let lat = sale.latitude, let lng = sale.longitude else { return nil }
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            annotation.title = sale.title
            annotation.subtitle = sale.formattedDistance
            return annotation
        }
        mapView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }

            let identifier = "SalePin"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)

            view.annotation = annotation
            view.markerTintColor = UIColor(Color.treasureGold600)
            view.glyphImage = UIImage(systemName: "tag.fill")
            view.canShowCallout = true

            return view
        }
    }
}

#Preview {
    NearbyView()
}
