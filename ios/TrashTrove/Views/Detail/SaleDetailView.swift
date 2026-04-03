import SwiftUI
import MapKit

struct SaleDetailView: View {

    @StateObject private var viewModel: SaleDetailViewModel
    @Environment(\.dismiss) private var dismiss

    @FocusState private var focusedField: ContactField?

    private enum ContactField: Hashable {
        case name, email, message
    }

    // MARK: - Init

    init(saleId: UUID) {
        _viewModel = StateObject(wrappedValue: SaleDetailViewModel(saleId: saleId))
    }

    // MARK: - Body

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.sale == nil {
                loadingView
            } else if let error = viewModel.error, viewModel.sale == nil {
                errorView(error)
            } else if let sale = viewModel.sale {
                saleContent(sale)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                        Text("Back")
                    }
                }
                .foregroundStyle(.treasure600)
                .accessibilityLabel("Go back")
            }
        }
        .sheet(isPresented: $viewModel.showReportSheet) {
            reportSheet
        }
        .task {
            viewModel.loadFavoriteState()
            await viewModel.loadSale()
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(.treasure600)
            Text("Loading sale details...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading sale details")
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.treasure600)
            Text("Something went wrong")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.bold)
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Try Again") {
                Task { await viewModel.loadSale() }
            }
            .buttonStyle(.borderedProminent)
            .tint(.treasure600)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Sale Content

    private func saleContent(_ sale: GarageSale) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Photo Gallery
                photoGallery(sale)

                VStack(alignment: .leading, spacing: 20) {
                    // Title + Favorite
                    titleSection(sale)

                    // Category Badges
                    categoryBadges(sale.categories)

                    // Share Button
                    shareButton(sale)

                    // Date & Time Card
                    dateTimeCard(sale)

                    // Location Card
                    locationCard(sale)

                    // Seller Info Card
                    sellerCard(sale)

                    // Contact Seller
                    contactSection(sale)

                    // About This Sale
                    aboutSection(sale)

                    // Report Button
                    reportButton

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Photo Gallery

    @State private var currentPhotoIndex = 0

    private func photoGallery(_ sale: GarageSale) -> some View {
        let sortedPhotos = sale.photos.sorted { $0.displayOrder < $1.displayOrder }

        return Group {
            if sortedPhotos.isEmpty {
                // Placeholder when no photos
                ZStack {
                    Rectangle()
                        .fill(Color.treasure50)
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 40))
                            .foregroundStyle(.treasure300)
                        Text("No photos available")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 260)
                .accessibilityLabel("No photos available for this sale")
            } else {
                ZStack(alignment: .bottom) {
                    TabView(selection: $currentPhotoIndex) {
                        ForEach(Array(sortedPhotos.enumerated()), id: \.element.id) { index, photo in
                            AsyncImage(url: photo.imageURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    placeholderImage
                                case .empty:
                                    ProgressView()
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                @unknown default:
                                    placeholderImage
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .clipped()
                            .tag(index)
                            .accessibilityLabel("Photo \(index + 1) of \(sortedPhotos.count)")
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 300)

                    // Custom page indicators
                    if sortedPhotos.count > 1 {
                        HStack(spacing: 6) {
                            ForEach(0..<sortedPhotos.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPhotoIndex ? Color.white : Color.white.opacity(0.5))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, 12)
                    }
                }
            }
        }
    }

    private var placeholderImage: some View {
        ZStack {
            Color.treasure50
            Image(systemName: "photo")
                .font(.system(size: 32))
                .foregroundStyle(.treasure300)
        }
    }

    // MARK: - Title + Favorite

    private func titleSection(_ sale: GarageSale) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(sale.title)
                .font(.custom("Georgia", size: 26))
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            Button {
                viewModel.toggleFavorite()
            } label: {
                Image(systemName: viewModel.isFavorited ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundStyle(viewModel.isFavorited ? .red : .secondary)
                    .symbolEffect(.bounce, value: viewModel.isFavorited)
            }
            .accessibilityLabel(viewModel.isFavorited ? "Remove from favorites" : "Add to favorites")
        }
    }

    // MARK: - Category Badges

    private func categoryBadges(_ categories: [String]) -> some View {
        Group {
            if !categories.isEmpty {
                FlowLayoutView(spacing: 8) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.treasure50)
                            .foregroundStyle(.treasure700)
                            .clipShape(Capsule())
                            .accessibilityLabel("Category: \(category)")
                    }
                }
            }
        }
    }

    // MARK: - Share Button

    private func shareButton(_ sale: GarageSale) -> some View {
        Group {
            if let url = viewModel.shareURL {
                ShareLink(
                    item: url,
                    subject: Text(sale.title),
                    message: Text("Check out this garage sale: \(sale.title)")
                ) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.treasure600)
                }
                .accessibilityLabel("Share this sale")
            }
        }
    }

    // MARK: - Date & Time Card

    private func dateTimeCard(_ sale: GarageSale) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.title3)
                    .foregroundStyle(.treasure600)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(sale.formattedDate)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Date: \(sale.formattedDate)")

            HStack(spacing: 12) {
                Image(systemName: "clock")
                    .font(.title3)
                    .foregroundStyle(.treasure600)
                    .frame(width: 24)
                Text(sale.formattedTimeRange)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Time: \(sale.formattedTimeRange)")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.treasure50)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Location Card

    private func locationCard(_ sale: GarageSale) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.title3)
                    .foregroundStyle(.treasure600)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Address")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(sale.address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(sale.city), \(sale.state) \(sale.zip)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Address: \(sale.fullAddress)")

            // Map View
            if let lat = sale.latitude, let lng = sale.longitude {
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                Map(initialPosition: .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )) {
                    Marker(sale.title, coordinate: coordinate)
                        .tint(.treasure600)
                }
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .allowsHitTesting(false)
                .accessibilityLabel("Map showing sale location")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }

    // MARK: - Seller Card

    private func sellerCard(_ sale: GarageSale) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.title)
                .foregroundStyle(.treasure600)
            VStack(alignment: .leading, spacing: 2) {
                Text("Seller")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(sale.sellerName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Seller: \(sale.sellerName)")
    }

    // MARK: - Contact Seller Section

    private func contactSection(_ sale: GarageSale) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Expandable header
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.isContactExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(.treasure600)
                    Text("Contact \(sale.sellerName)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(viewModel.isContactExpanded ? 90 : 0))
                }
                .padding(16)
            }
            .accessibilityLabel("Contact seller")
            .accessibilityHint(viewModel.isContactExpanded ? "Collapse contact form" : "Expand contact form")

            if viewModel.isContactExpanded {
                VStack(alignment: .leading, spacing: 14) {
                    if viewModel.contactSent {
                        // Success message
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.forestGreen)
                            Text("Message sent! The seller will get back to you via email.")
                                .font(.subheadline)
                                .foregroundStyle(.forestGreen)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.forest50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .accessibilityLabel("Message sent successfully")
                    } else {
                        // Name
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Name")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("Jane Smith", text: $viewModel.contactName)
                                .textContentType(.name)
                                .submitLabel(.next)
                                .focused($focusedField, equals: .name)
                                .onSubmit { focusedField = .email }
                                .padding(12)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .accessibilityLabel("Your name")
                        }

                        // Email
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Email")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("jane@example.com", text: $viewModel.contactEmail)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .submitLabel(.next)
                                .focused($focusedField, equals: .email)
                                .onSubmit { focusedField = .message }
                                .padding(12)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .accessibilityLabel("Your email address")
                        }

                        // Message
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Message")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextEditor(text: $viewModel.contactMessage)
                                .focused($focusedField, equals: .message)
                                .frame(minHeight: 80)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .accessibilityLabel("Your message to the seller")
                        }

                        // Validation hint
                        if let hint = viewModel.contactValidationMessage {
                            Text(hint)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        // Error
                        if let error = viewModel.contactError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        // Send Button
                        Button {
                            focusedField = nil
                            Task { await viewModel.sendContact() }
                        } label: {
                            HStack(spacing: 8) {
                                if viewModel.isSendingContact {
                                    ProgressView()
                                        .tint(.white)
                                        .controlSize(.small)
                                }
                                Text(viewModel.isSendingContact ? "Sending..." : "Send Message")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(viewModel.isContactFormValid ? Color.treasure600 : Color.treasure300)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .disabled(!viewModel.isContactFormValid || viewModel.isSendingContact)
                        .accessibilityLabel("Send contact message")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }

    // MARK: - About Section

    private func aboutSection(_ sale: GarageSale) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About This Sale")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)

            Text(sale.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 8)
    }

    // MARK: - Report Button

    private var reportButton: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.bottom, 16)

            HStack {
                Spacer()
                Button {
                    viewModel.showReportSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "flag")
                        Text("Report This Listing")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Report this listing")
            }
        }
    }

    // MARK: - Report Sheet

    private var reportSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.reportSent {
                    // Success
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.forestGreen)
                        Text("Report Submitted")
                            .font(.custom("Georgia", size: 20))
                            .fontWeight(.bold)
                        Text("Thank you. We will review this listing shortly.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Report submitted successfully")
                } else {
                    Text("Why are you reporting this listing?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Picker("Reason", selection: $viewModel.reportReason) {
                        ForEach(ReportReason.allCases) { reason in
                            Text(reason.displayName).tag(reason)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Report reason")

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Additional Details (optional)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextEditor(text: $viewModel.reportDetails)
                            .frame(minHeight: 80)
                            .padding(8)
                            .scrollContentBackground(.hidden)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    if let error = viewModel.reportError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Button {
                        Task { await viewModel.sendReport() }
                    } label: {
                        HStack(spacing: 8) {
                            if viewModel.isSendingReport {
                                ProgressView()
                                    .tint(.white)
                                    .controlSize(.small)
                            }
                            Text(viewModel.isSendingReport ? "Submitting..." : "Submit Report")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.treasure600)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(viewModel.isSendingReport)
                    .accessibilityLabel("Submit report")

                    Spacer()
                }
            }
            .padding(20)
            .navigationTitle("Report Listing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showReportSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Flow Layout (category pills)

struct FlowLayoutView: Layout {

    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            guard index < result.positions.count else { break }
            let position = result.positions[index]
            subview.place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private struct LayoutResult {
        var positions: [CGPoint]
        var size: CGSize
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> LayoutResult {
        let containerWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > containerWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxWidth = max(maxWidth, currentX - spacing)
        }

        return LayoutResult(
            positions: positions,
            size: CGSize(width: maxWidth, height: currentY + lineHeight)
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SaleDetailView(saleId: UUID())
    }
}
