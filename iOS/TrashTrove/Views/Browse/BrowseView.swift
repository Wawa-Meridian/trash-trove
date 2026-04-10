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
        .navigationDestination(for: StateDestination.self) { destination in
            StateSalesView(stateCode: destination.code, stateName: destination.name)
        }
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
                StateGridView(saleCounts: stateCounts)
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

#Preview {
    NavigationStack {
        BrowseView()
    }
}

