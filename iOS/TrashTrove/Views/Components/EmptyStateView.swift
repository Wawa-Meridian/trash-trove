import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionLabel: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundStyle(Color.treasure300)
                .accessibilityHidden(true)

            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let actionLabel, let action {
                Button(action: action) {
                    Text(actionLabel)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.treasure600)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 8)
                .accessibilityLabel(actionLabel)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
}

// MARK: - Convenience Presets

extension EmptyStateView {
    /// Empty state for when no sales are found in search results.
    static func noResults(onClear: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Sales Found",
            message: "Try adjusting your search or browse by state to find garage sales near you.",
            actionLabel: onClear != nil ? "Clear Search" : nil,
            action: onClear
        )
    }

    /// Empty state for when no sales exist in a state.
    static func noSalesInState(stateName: String) -> EmptyStateView {
        EmptyStateView(
            icon: "map",
            title: "No Sales in \(stateName)",
            message: "There are no upcoming garage sales listed in \(stateName) right now. Check back soon!",
            actionLabel: nil,
            action: nil
        )
    }

    /// Empty state for when no favorites have been saved.
    static func noFavorites(onBrowse: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "heart",
            title: "No Favorites Yet",
            message: "Tap the heart icon on any sale to save it here for quick access.",
            actionLabel: onBrowse != nil ? "Browse Sales" : nil,
            action: onBrowse
        )
    }

    /// Empty state for a network error.
    static func networkError(onRetry: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "wifi.slash",
            title: "Connection Problem",
            message: "We could not load sales right now. Please check your internet connection and try again.",
            actionLabel: onRetry != nil ? "Try Again" : nil,
            action: onRetry
        )
    }
}

// MARK: - Previews

#Preview("Empty State - Generic") {
    EmptyStateView(
        icon: "tray",
        title: "Nothing Here",
        message: "There is nothing to display right now.",
        actionLabel: "Refresh",
        action: {}
    )
}

#Preview("Empty State - No Results") {
    EmptyStateView.noResults { }
}

#Preview("Empty State - Network Error") {
    EmptyStateView.networkError { }
}

#Preview("Empty State - No Favorites") {
    EmptyStateView.noFavorites()
}
