import Foundation
import Combine
import SwiftUI

@MainActor
final class SaleDetailViewModel: ObservableObject {

    // MARK: - Sale State

    @Published var sale: GarageSale?
    @Published var isLoading = false
    @Published var error: String?

    // MARK: - Contact Form

    @Published var contactName = ""
    @Published var contactEmail = ""
    @Published var contactMessage = ""
    @Published var isSendingContact = false
    @Published var contactSent = false
    @Published var contactError: String?

    // MARK: - Report

    @Published var showReportSheet = false
    @Published var reportReason: ReportReason = .spam
    @Published var reportDetails = ""
    @Published var isSendingReport = false
    @Published var reportSent = false
    @Published var reportError: String?

    // MARK: - Favorite

    @Published var isFavorited = false

    // MARK: - Contact Section Expand

    @Published var isContactExpanded = false

    // MARK: - Private

    private let saleId: UUID
    private let supabase = SupabaseService.shared

    // MARK: - Init

    init(saleId: UUID) {
        self.saleId = saleId
    }

    // MARK: - Load Sale

    func loadSale() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        do {
            sale = try await supabase.fetchSale(id: saleId)
        } catch let err as SupabaseError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load sale details. Please try again."
        }

        isLoading = false
    }

    // MARK: - Contact Form Validation

    var isContactFormValid: Bool {
        contactName.trimmed.count >= 2 &&
        contactEmail.trimmed.isValidEmail &&
        contactMessage.trimmed.count >= 5
    }

    var contactValidationMessage: String? {
        if contactName.trimmed.count < 2 && !contactName.isEmpty {
            return "Name must be at least 2 characters."
        }
        if !contactEmail.isEmpty && !contactEmail.trimmed.isValidEmail {
            return "Enter a valid email address."
        }
        if !contactMessage.isEmpty && contactMessage.trimmed.count < 5 {
            return "Message must be at least 5 characters."
        }
        return nil
    }

    // MARK: - Send Contact

    func sendContact() async {
        guard isContactFormValid else { return }
        isSendingContact = true
        contactError = nil

        let security = SecurityService.shared
        let sanitizedName = security.sanitizeString(contactName.trimmed, maxLength: 100)
        let sanitizedEmail = contactEmail.trimmed.lowercased()
        let sanitizedMessage = security.sanitizeString(contactMessage.trimmed, maxLength: 1000)

        do {
            try await supabase.sendContactMessage(
                saleId: saleId,
                name: sanitizedName,
                email: sanitizedEmail,
                message: sanitizedMessage
            )
            contactSent = true
            contactName = ""
            contactEmail = ""
            contactMessage = ""
        } catch let err as SupabaseError {
            contactError = err.errorDescription
        } catch {
            contactError = "Failed to send message. Please try again."
        }

        isSendingContact = false
    }

    // MARK: - Send Report

    func sendReport() async {
        isSendingReport = true
        reportError = nil

        let sanitizedDetails = reportDetails.trimmed

        do {
            try await supabase.reportSale(
                saleId: saleId,
                reason: reportReason.rawValue,
                details: sanitizedDetails.isEmpty ? nil : sanitizedDetails
            )
            reportSent = true
        } catch let err as SupabaseError {
            reportError = err.errorDescription
        } catch {
            reportError = "Failed to send report. Please try again."
        }

        isSendingReport = false
    }

    // MARK: - Favorite Toggle

    func toggleFavorite() {
        FavoritesService.shared.toggle(saleId: saleId)
        isFavorited = FavoritesService.shared.isFavorite(saleId: saleId)
    }

    func loadFavoriteState() {
        isFavorited = FavoritesService.shared.isFavorite(saleId: saleId)
    }

    // MARK: - Share URL

    var shareURL: URL? {
        URL(string: "\(APIConfig.baseURL)/sale/\(saleId.uuidString)")
    }
}
