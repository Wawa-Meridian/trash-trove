import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String = "Search sales..."
    var onSubmit: (() -> Void)?

    @State private var debounceTask: Task<Void, Never>?
    @FocusState private var isFocused: Bool

    /// Optional debounced callback triggered after the user stops typing.
    var onDebouncedChange: ((String) -> Void)?

    /// Debounce interval in seconds.
    var debounceInterval: TimeInterval = 0.4

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .font(.body)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit {
                    onSubmit?()
                }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .accessibilityLabel(placeholder)

            if !text.isEmpty {
                Button {
                    text = ""
                    onDebouncedChange?("")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Clear search")
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.15), value: text.isEmpty)
        .onChange(of: text) { _, newValue in
            debounceTask?.cancel()
            debounceTask = Task {
                try? await Task.sleep(for: .seconds(debounceInterval))
                guard !Task.isCancelled else { return }
                onDebouncedChange?(newValue)
            }
        }
    }
}

// MARK: - Preview

#Preview("Search Bar") {
    struct SearchBarPreview: View {
        @State var query = ""

        var body: some View {
            VStack(spacing: 20) {
                SearchBarView(text: $query, placeholder: "Search garage sales...")

                SearchBarView(text: .constant("Furniture"), placeholder: "Search...")

                Text("Query: \(query)")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    return SearchBarPreview()
}
