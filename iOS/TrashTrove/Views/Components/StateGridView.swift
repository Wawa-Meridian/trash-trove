import SwiftUI

struct StateGridView: View {
    var saleCounts: [String: Int] = [:]
    var onStateSelected: ((String, String) -> Void)?

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]

    private var sortedStates: [(code: String, name: String)] {
        US_STATES
            .map { (code: $0.key, name: $0.value) }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(sortedStates, id: \.code) { state in
                NavigationLink(value: StateDestination(code: state.code, name: state.name)) {
                    stateCell(code: state.code, name: state.name)
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(stateCellAccessibilityLabel(code: state.code, name: state.name))
                .accessibilityHint("Double tap to browse sales in \(state.name)")
            }
        }
    }

    // MARK: - State Cell

    private func stateCell(code: String, name: String) -> some View {
        VStack(spacing: 4) {
            Text(code)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.treasure600)

            Text(name)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            if let count = saleCounts[code], count > 0 {
                Text("\(count) sale\(count == 1 ? "" : "s")")
                    .font(.system(size: 10, weight: .medium, design: .default))
                    .foregroundStyle(Color.forestGreen)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Accessibility

    private func stateCellAccessibilityLabel(code: String, name: String) -> String {
        var label = "\(name), \(code)"
        if let count = saleCounts[code], count > 0 {
            label += ", \(count) sale\(count == 1 ? "" : "s")"
        }
        return label
    }
}

// MARK: - Navigation Destination

struct StateDestination: Hashable {
    let code: String
    let name: String
}

// MARK: - Preview

#Preview("State Grid") {
    NavigationStack {
        ScrollView {
            StateGridView(saleCounts: [
                "TX": 42,
                "CA": 128,
                "NY": 85,
                "FL": 63,
            ])
            .padding()
        }
        .navigationTitle("Browse by State")
    }
}
