import Foundation
import Combine
import SwiftUI
import PhotosUI

@MainActor
final class CreateSaleViewModel: ObservableObject {

    // MARK: - Basic Info

    @Published var title = ""
    @Published var description = ""

    // MARK: - Categories

    @Published var selectedCategories: Set<String> = []

    // MARK: - Photos

    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var photoData: [Data] = []
    @Published var photoPreviews: [UIImage] = []
    @Published var isLoadingPhotos = false

    // MARK: - Location

    @Published var address = ""
    @Published var city = ""
    @Published var state = ""
    @Published var zip = ""

    // MARK: - Date & Time

    @Published var saleDate: Date
    @Published var startTime: Date
    @Published var endTime: Date

    // MARK: - Your Info

    @Published var sellerName = ""
    @Published var sellerEmail = ""

    // MARK: - Submission State

    @Published var isSubmitting = false
    @Published var error: String?
    @Published var validationErrors: [String] = []
    @Published var createdSaleId: UUID?
    @Published var manageToken: String?

    // MARK: - Private

    private let supabase = SupabaseService.shared
    private let security = SecurityService.shared

    // MARK: - Init

    init() {
        // Default date to next Saturday
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        // weekday: 1 = Sunday, 7 = Saturday
        let daysUntilSaturday = (7 - weekday + 7) % 7
        let nextSaturday = calendar.date(byAdding: .day, value: daysUntilSaturday == 0 ? 7 : daysUntilSaturday, to: today) ?? today
        self.saleDate = calendar.startOfDay(for: nextSaturday)

        // Default times: 8:00 AM - 2:00 PM
        var startComponents = calendar.dateComponents([.year, .month, .day], from: today)
        startComponents.hour = 8
        startComponents.minute = 0
        self.startTime = calendar.date(from: startComponents) ?? today

        var endComponents = startComponents
        endComponents.hour = 14
        endComponents.minute = 0
        self.endTime = calendar.date(from: endComponents) ?? today
    }

    // MARK: - Computed

    var isSuccess: Bool {
        createdSaleId != nil && manageToken != nil
    }

    var manageURL: String? {
        guard let id = createdSaleId, let token = manageToken else { return nil }
        return "\(APIConfig.baseURL)/sale/\(id.uuidString)/manage?token=\(token)"
    }

    // MARK: - Category Toggle

    func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }

    // MARK: - Photo Management

    func loadPhotos() async {
        isLoadingPhotos = true

        var newData: [Data] = []
        var newPreviews: [UIImage] = []

        for item in selectedPhotos {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                continue
            }
            // Compress to JPEG for upload
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                newData.append(jpegData)
                newPreviews.append(image)
            }
        }

        photoData = newData
        photoPreviews = newPreviews
        isLoadingPhotos = false
    }

    func removePhoto(at index: Int) {
        guard index >= 0, index < photoPreviews.count else { return }
        if index < selectedPhotos.count {
            selectedPhotos.remove(at: index)
        }
        if index < photoData.count {
            photoData.remove(at: index)
        }
        photoPreviews.remove(at: index)
    }

    // MARK: - Validation

    func validate() -> Bool {
        var errors: [String] = []

        // Title
        if title.trimmed.count < 3 {
            errors.append("Title must be at least 3 characters.")
        }

        // Description
        if description.trimmed.count < 10 {
            errors.append("Description must be at least 10 characters.")
        }

        // Categories
        if selectedCategories.isEmpty {
            errors.append("Select at least one category.")
        }

        // Address
        if address.trimmed.count < 5 {
            errors.append("Enter a valid street address (5+ characters).")
        }

        // City
        if city.trimmed.count < 2 {
            errors.append("Enter a city name.")
        }

        // State
        if state.isEmpty {
            errors.append("Select a state.")
        }

        // ZIP
        if !zip.trimmed.isValidZipCode {
            errors.append("Enter a valid 5-digit ZIP code.")
        }

        // Date must be today or later
        if saleDate < Calendar.current.startOfDay(for: Date()) {
            errors.append("Sale date must be today or in the future.")
        }

        // End time after start time
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: startTime)
        let startMinute = calendar.component(.minute, from: startTime)
        let endHour = calendar.component(.hour, from: endTime)
        let endMinute = calendar.component(.minute, from: endTime)
        if endHour < startHour || (endHour == startHour && endMinute <= startMinute) {
            errors.append("End time must be after start time.")
        }

        // Seller name
        if sellerName.trimmed.count < 2 {
            errors.append("Enter your name (at least 2 characters).")
        }

        // Seller email
        if !sellerEmail.trimmed.isValidEmail {
            errors.append("Enter a valid email address.")
        }

        validationErrors = errors
        return errors.isEmpty
    }

    // MARK: - Submit

    func submit() async {
        guard validate() else { return }

        isSubmitting = true
        error = nil

        do {
            // Upload photos
            var photoURLs: [String] = []
            for data in photoData {
                let url = try await supabase.uploadPhoto(imageData: data)
                photoURLs.append(url)
            }

            // Format date and times
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            let saleDateString = dateFormatter.string(from: saleDate)

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            timeFormatter.locale = Locale(identifier: "en_US_POSIX")
            let startTimeString = timeFormatter.string(from: startTime)
            let endTimeString = timeFormatter.string(from: endTime)

            let input = CreateSaleInput(
                title: security.sanitizeString(title.trimmed, maxLength: 200),
                description: security.sanitizeString(description.trimmed, maxLength: 2000),
                categories: Array(selectedCategories),
                address: security.sanitizeString(address.trimmed, maxLength: 200),
                city: security.sanitizeString(city.trimmed, maxLength: 100),
                state: state.uppercased(),
                zip: zip.trimmed,
                saleDate: saleDateString,
                startTime: startTimeString,
                endTime: endTimeString,
                sellerName: security.sanitizeString(sellerName.trimmed, maxLength: 100),
                sellerEmail: sellerEmail.trimmed.lowercased()
            )

            let result = try await supabase.createSale(input, photoURLs: photoURLs)

            createdSaleId = result.id
            manageToken = result.manageToken

            // Save manage token to UserDefaults (Keychain equivalent for prototype)
            saveManageToken(saleId: result.id, token: result.manageToken)
        } catch let err as SupabaseError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to create sale. Please try again."
        }

        isSubmitting = false
    }

    // MARK: - Token Storage

    private func saveManageToken(saleId: UUID, token: String) {
        // Save to Keychain for secure storage
        try? security.saveManageToken(token, forSaleId: saleId)
    }
}
