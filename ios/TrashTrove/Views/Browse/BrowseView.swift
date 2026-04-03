import SwiftUI

struct BrowseView: View {
    @State private var stateCounts: [String: Int] = [:]
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
                stateGridSection
            }
            .padding(.vertical, 16)
        }
        .navigationTitle("Browse Garage Sales")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadStateCounts()
        }
        .onAppear {
            AnalyticsService.shared.trackScreen("Browse")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select a state to find garage sales near you.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - State Grid

    private var stateGridSection: some View {
        Group {
            if isLoading {
                ProgressView("Loading states...")
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .accessibilityLabel("Loading state listings")
            } else {
                StateGridView(stateCounts: stateCounts)
                    .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Data Loading

    private func loadStateCounts() async {
        guard stateCounts.isEmpty else { return }
        isLoading = true
        do {
            stateCounts = try await SupabaseService.shared.fetchStateCounts()
        } catch {
            // Counts are optional; grid still renders without them
        }
        isLoading = false
    }
}

// MARK: - State Grid View

struct StateGridView: View {
    let stateCounts: [String: Int]

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(USState.allStates) { state in
                NavigationLink(destination: StateSalesView(stateCode: state.code, stateName: state.name)) {
                    stateCell(state)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(state.name), \(stateCounts[state.code] ?? 0) sales")
            }
        }
    }

    private func stateCell(_ state: USState) -> some View {
        VStack(spacing: 4) {
            Text(state.code)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(state.name)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            if let count = stateCounts[state.code], count > 0 {
                Text("\(count)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.treasureGold600)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
    }
}

// MARK: - US State Model

struct USState: Identifiable {
    let code: String
    let name: String

    var id: String { code }

    static let allStates: [USState] = [
        USState(code: "AL", name: "Alabama"),
        USState(code: "AK", name: "Alaska"),
        USState(code: "AZ", name: "Arizona"),
        USState(code: "AR", name: "Arkansas"),
        USState(code: "CA", name: "California"),
        USState(code: "CO", name: "Colorado"),
        USState(code: "CT", name: "Connecticut"),
        USState(code: "DE", name: "Delaware"),
        USState(code: "DC", name: "District of Columbia"),
        USState(code: "FL", name: "Florida"),
        USState(code: "GA", name: "Georgia"),
        USState(code: "HI", name: "Hawaii"),
        USState(code: "ID", name: "Idaho"),
        USState(code: "IL", name: "Illinois"),
        USState(code: "IN", name: "Indiana"),
        USState(code: "IA", name: "Iowa"),
        USState(code: "KS", name: "Kansas"),
        USState(code: "KY", name: "Kentucky"),
        USState(code: "LA", name: "Louisiana"),
        USState(code: "ME", name: "Maine"),
        USState(code: "MD", name: "Maryland"),
        USState(code: "MA", name: "Massachusetts"),
        USState(code: "MI", name: "Michigan"),
        USState(code: "MN", name: "Minnesota"),
        USState(code: "MS", name: "Mississippi"),
        USState(code: "MO", name: "Missouri"),
        USState(code: "MT", name: "Montana"),
        USState(code: "NE", name: "Nebraska"),
        USState(code: "NV", name: "Nevada"),
        USState(code: "NH", name: "New Hampshire"),
        USState(code: "NJ", name: "New Jersey"),
        USState(code: "NM", name: "New Mexico"),
        USState(code: "NY", name: "New York"),
        USState(code: "NC", name: "North Carolina"),
        USState(code: "ND", name: "North Dakota"),
        USState(code: "OH", name: "Ohio"),
        USState(code: "OK", name: "Oklahoma"),
        USState(code: "OR", name: "Oregon"),
        USState(code: "PA", name: "Pennsylvania"),
        USState(code: "RI", name: "Rhode Island"),
        USState(code: "SC", name: "South Carolina"),
        USState(code: "SD", name: "South Dakota"),
        USState(code: "TN", name: "Tennessee"),
        USState(code: "TX", name: "Texas"),
        USState(code: "UT", name: "Utah"),
        USState(code: "VT", name: "Vermont"),
        USState(code: "VA", name: "Virginia"),
        USState(code: "WA", name: "Washington"),
        USState(code: "WV", name: "West Virginia"),
        USState(code: "WI", name: "Wisconsin"),
        USState(code: "WY", name: "Wyoming"),
    ]
}

#Preview {
    NavigationStack {
        BrowseView()
    }
}
