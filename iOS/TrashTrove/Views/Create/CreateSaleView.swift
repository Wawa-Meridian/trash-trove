import SwiftUI
import PhotosUI

struct CreateSaleView: View {

    @StateObject private var viewModel = CreateSaleViewModel()
    @Environment(\.dismiss) private var dismiss

    @FocusState private var focusedField: FormField?

    private enum FormField: Hashable {
        case title, description
        case address, city, zip
        case sellerName, sellerEmail
    }

    // MARK: - Body

    var body: some View {
        Group {
            if viewModel.isSuccess {
                successView
            } else {
                formView
            }
        }
        .navigationTitle("List Your Sale")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Success View

    private var successView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer(minLength: 40)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.forestGreen)
                    .accessibilityHidden(true)

                Text("Your Sale Has Been Listed!")
                    .font(.custom("Georgia", size: 24))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text("Save the link below to manage your listing. This is the only way to edit or delete your sale later.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Manage URL card
                if let url = viewModel.manageURL {
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "link")
                                .foregroundStyle(.forestGreen)
                            Text(url)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .truncationMode(.middle)
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.forest50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        Button {
                            UIPasteboard.general.string = url
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.on.doc")
                                Text("Copy Manage Link")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.forestGreen)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .accessibilityLabel("Copy manage link to clipboard")
                    }
                    .padding(.horizontal, 24)
                }

                // View listing button
                if let saleId = viewModel.createdSaleId {
                    NavigationLink {
                        SaleDetailView(saleId: saleId)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "eye")
                            Text("View Your Listing")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.treasure600)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, 24)
                    .accessibilityLabel("View your new listing")
                }

                Spacer(minLength: 40)
            }
            .padding(.top, 20)
        }
    }

    // MARK: - Form View

    private var formView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Share your sale details and let shoppers know what treasures you have.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Basic Info
                basicInfoSection

                // Categories
                categoriesSection

                // Photos
                photosSection

                // Location
                locationSection

                // Date & Time
                dateTimeSection

                // Your Info
                yourInfoSection

                // Validation Errors
                if !viewModel.validationErrors.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(viewModel.validationErrors, id: \.self) { error in
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Validation errors: \(viewModel.validationErrors.joined(separator: ". "))")
                }

                // API Error
                if let error = viewModel.error {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Submit Button
                Button {
                    focusedField = nil
                    Task { await viewModel.submit() }
                } label: {
                    HStack(spacing: 8) {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .tint(.white)
                                .controlSize(.small)
                            Text("Creating Your Sale...")
                        } else {
                            Image(systemName: "checkmark.circle")
                            Text("List My Garage Sale")
                        }
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.treasure600)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(viewModel.isSubmitting)
                .accessibilityLabel(viewModel.isSubmitting ? "Creating your sale" : "List my garage sale")

                Spacer(minLength: 32)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Basic Info Section

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Basic Info")

            VStack(alignment: .leading, spacing: 4) {
                Text("Sale Title")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("e.g. Big Moving Sale - Everything Must Go!", text: $viewModel.title)
                    .focused($focusedField, equals: .title)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .description }
                    .textContentType(.name)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityLabel("Sale title")
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Description")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextEditor(text: $viewModel.description)
                    .focused($focusedField, equals: .description)
                    .frame(minHeight: 100)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityLabel("Sale description")
                Text("Describe what kinds of items you're selling, any highlights, pricing info, etc.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("What Are You Selling?")

            FlowLayoutView(spacing: 8) {
                ForEach(SALE_CATEGORIES, id: \.self) { category in
                    Button {
                        viewModel.toggleCategory(category)
                    } label: {
                        Text(category)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedCategories.contains(category)
                                    ? Color.treasure600
                                    : Color(.systemGray6)
                            )
                            .foregroundStyle(
                                viewModel.selectedCategories.contains(category)
                                    ? .white
                                    : .primary
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(
                                        viewModel.selectedCategories.contains(category)
                                            ? Color.treasure600
                                            : Color(.systemGray4),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .accessibilityLabel(category)
                    .accessibilityAddTraits(viewModel.selectedCategories.contains(category) ? .isSelected : [])
                }
            }

            if !viewModel.selectedCategories.isEmpty {
                Text("\(viewModel.selectedCategories.count) selected")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Photos Section

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                sectionHeader("Photos")
                Spacer()
                Text("up to 10")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            PhotosPicker(
                selection: $viewModel.selectedPhotos,
                maxSelectionCount: 10,
                matching: .images,
                photoLibrary: .shared()
            ) {
                VStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 28))
                        .foregroundStyle(.treasure400)
                    Text("Add Photos")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.treasure600)
                    Text("JPG or PNG, up to 5 MB each")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                        .foregroundStyle(Color(.systemGray4))
                )
            }
            .onChange(of: viewModel.selectedPhotos) { _, _ in
                Task { await viewModel.loadPhotos() }
            }
            .accessibilityLabel("Add photos, \(viewModel.photoPreviews.count) of 10 selected")

            // Loading
            if viewModel.isLoadingPhotos {
                HStack {
                    ProgressView()
                        .controlSize(.small)
                    Text("Loading photos...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Preview grid
            if !viewModel.photoPreviews.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 8)
                ], spacing: 8) {
                    ForEach(Array(viewModel.photoPreviews.enumerated()), id: \.offset) { index, image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .accessibilityLabel("Photo \(index + 1)")

                            Button {
                                viewModel.removePhoto(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.white, .red)
                                    .shadow(radius: 2)
                            }
                            .offset(x: 6, y: -6)
                            .accessibilityLabel("Remove photo \(index + 1)")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Location Section

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Location")

            VStack(alignment: .leading, spacing: 4) {
                Text("Street Address")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("123 Main St", text: $viewModel.address)
                    .focused($focusedField, equals: .address)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .city }
                    .textContentType(.streetAddressLine1)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityLabel("Street address")
            }

            HStack(spacing: 10) {
                // City
                VStack(alignment: .leading, spacing: 4) {
                    Text("City")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Springfield", text: $viewModel.city)
                        .focused($focusedField, equals: .city)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .zip }
                        .textContentType(.addressCity)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .accessibilityLabel("City")
                }

                // State Picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("State")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("State", selection: $viewModel.state) {
                        Text("Select...").tag("")
                        ForEach(US_STATE_CODES, id: \.self) { code in
                            Text(US_STATES[code] ?? code).tag(code)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityLabel("State")
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("ZIP Code")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("12345", text: $viewModel.zip)
                    .focused($focusedField, equals: .zip)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .sellerName }
                    .keyboardType(.numberPad)
                    .textContentType(.postalCode)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 140)
                    .accessibilityLabel("ZIP code")
            }
        }
    }

    // MARK: - Date & Time Section

    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Date & Time")

            VStack(alignment: .leading, spacing: 4) {
                Text("Sale Date")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                DatePicker(
                    "Sale Date",
                    selection: $viewModel.saleDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(.treasure600)
                .accessibilityLabel("Sale date")
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    DatePicker(
                        "Start Time",
                        selection: $viewModel.startTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(.treasure600)
                    .accessibilityLabel("Start time")
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("End Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    DatePicker(
                        "End Time",
                        selection: $viewModel.endTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(.treasure600)
                    .accessibilityLabel("End time")
                }

                Spacer()
            }
        }
    }

    // MARK: - Your Info Section

    private var yourInfoSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Your Info")

            VStack(alignment: .leading, spacing: 4) {
                Text("Your Name")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Jane Smith", text: $viewModel.sellerName)
                    .focused($focusedField, equals: .sellerName)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .sellerEmail }
                    .textContentType(.name)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityLabel("Your name")
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Email")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("jane@example.com", text: $viewModel.sellerEmail)
                    .focused($focusedField, equals: .sellerEmail)
                    .submitLabel(.done)
                    .onSubmit { focusedField = nil }
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityLabel("Your email address")
                Text("We'll send confirmation and contact messages to this email.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.primary)
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CreateSaleView()
    }
}
