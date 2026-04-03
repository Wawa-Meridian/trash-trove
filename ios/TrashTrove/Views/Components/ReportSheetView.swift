import SwiftUI

struct ReportSheetView: View {
    let saleId: UUID
    var onDismiss: (() -> Void)?
    var onSubmit: ((SaleReport) async throws -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var selectedReason: ReportReason?
    @State private var details: String = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if showSuccess {
                    successView
                } else {
                    reportForm
                }
            }
            .navigationTitle("Report This Listing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                        onDismiss?()
                    }
                    .accessibilityLabel("Cancel report")
                }
            }
        }
        .interactiveDismissDisabled(isSubmitting)
    }

    // MARK: - Report Form

    private var reportForm: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Why are you reporting this listing?")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)

                reasonList

                detailsSection

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 4)
                }

                submitButton
            }
            .padding()
        }
    }

    private var reasonList: some View {
        VStack(spacing: 0) {
            ForEach(ReportReason.allCases) { reason in
                Button {
                    selectedReason = reason
                } label: {
                    HStack {
                        Image(systemName: selectedReason == reason ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(selectedReason == reason ? Color.treasure600 : .secondary)
                            .font(.system(size: 20))

                        Text(reason.displayName)
                            .font(.body)
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(reason.displayName)
                .accessibilityAddTraits(selectedReason == reason ? .isSelected : [])

                if reason != ReportReason.allCases.last {
                    Divider()
                }
            }
        }
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Additional Details (optional)")
                .font(.subheadline.weight(.medium))

            TextEditor(text: $details)
                .font(.body)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(.separator), lineWidth: 0.5)
                )
                .accessibilityLabel("Additional details about this report")
        }
    }

    private var submitButton: some View {
        Button {
            Task { await submitReport() }
        } label: {
            HStack {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Submit Report")
                        .font(.body.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(selectedReason != nil ? Color.treasure600 : Color.gray.opacity(0.4))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(selectedReason == nil || isSubmitting)
        .accessibilityLabel("Submit report")
        .accessibilityHint(selectedReason == nil ? "Select a reason first" : "Double tap to submit your report")
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.forestGreen)

            Text("Report Submitted")
                .font(.title3.weight(.semibold))

            Text("Thank you for helping keep TrashTrove safe. We will review this listing shortly.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Done") {
                dismiss()
                onDismiss?()
            }
            .font(.body.weight(.medium))
            .foregroundStyle(Color.treasure600)
            .padding(.top, 8)

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Report submitted successfully. Thank you for helping keep TrashTrove safe.")
    }

    // MARK: - Actions

    @MainActor
    private func submitReport() async {
        guard let reason = selectedReason else { return }
        errorMessage = nil
        isSubmitting = true

        let report = SaleReport(
            id: nil,
            saleId: saleId,
            reason: reason,
            details: details.trimmed.isEmpty ? nil : details.trimmed
        )

        do {
            try await onSubmit?(report)
            withAnimation {
                showSuccess = true
            }
        } catch {
            errorMessage = "Failed to submit report. Please try again."
        }

        isSubmitting = false
    }
}

// MARK: - Preview

#Preview("Report Sheet") {
    ReportSheetView(saleId: UUID()) { report in
        try await Task.sleep(for: .seconds(1))
    }
}
