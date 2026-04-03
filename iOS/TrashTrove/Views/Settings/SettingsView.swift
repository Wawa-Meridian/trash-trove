import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("defaultRadius") private var defaultRadius = 25
    @AppStorage("defaultState") private var defaultState = ""

    @State private var showClearFavoritesAlert = false
    @State private var showClearHistoryAlert = false

    private let appVersion: String = {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }()

    private let radiusOptions = [10, 25, 50, 100]

    var body: some View {
        NavigationStack {
            List {
                notificationsSection
                searchSection
                dataSection
                legalSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                AnalyticsService.shared.trackScreen("Settings")
            }
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        Section {
            Toggle(isOn: $notificationsEnabled) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sale Reminders")
                        Text("Get notified about upcoming sales nearby")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "bell.badge")
                        .foregroundStyle(.treasureGold600)
                }
            }
            .tint(.treasureGold600)
            .accessibilityLabel("Sale reminders")
            .accessibilityHint("Toggle notifications for nearby garage sales")
        } header: {
            Text("Notifications")
        }
    }

    // MARK: - Search Section

    private var searchSection: some View {
        Section {
            Picker(selection: $defaultRadius) {
                ForEach(radiusOptions, id: \.self) { miles in
                    Text("\(miles) miles").tag(miles)
                }
            } label: {
                Label {
                    Text("Default Radius")
                } icon: {
                    Image(systemName: "circle.dashed")
                        .foregroundStyle(.treasureGold600)
                }
            }
            .accessibilityLabel("Default search radius")

            Picker(selection: $defaultState) {
                Text("All States").tag("")
                ForEach(USState.allStates) { state in
                    Text(state.name).tag(state.code)
                }
            } label: {
                Label {
                    Text("Default State")
                } icon: {
                    Image(systemName: "map")
                        .foregroundStyle(.treasureGold600)
                }
            }
            .accessibilityLabel("Default state filter")
        } header: {
            Text("Search")
        }
    }

    // MARK: - Data Section

    private var dataSection: some View {
        Section {
            Button(role: .destructive) {
                showClearFavoritesAlert = true
            } label: {
                Label {
                    Text("Clear Favorites")
                        .foregroundStyle(.primary)
                } icon: {
                    Image(systemName: "heart.slash")
                        .foregroundStyle(.red)
                }
            }
            .alert("Clear Favorites", isPresented: $showClearFavoritesAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    FavoritesService.shared.clear()
                    AnalyticsService.shared.track(.screenView, properties: ["action": "favoritesCleared"])
                }
            } message: {
                Text("This will remove all saved favorites. This action cannot be undone.")
            }
            .accessibilityLabel("Clear all favorites")

            Button(role: .destructive) {
                showClearHistoryAlert = true
            } label: {
                Label {
                    Text("Clear Search History")
                        .foregroundStyle(.primary)
                } icon: {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(.red)
                }
            }
            .alert("Clear Search History", isPresented: $showClearHistoryAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear History", role: .destructive) {
                    UserDefaults.standard.removeObject(forKey: "searchHistory")
                    AnalyticsService.shared.track(.screenView, properties: ["action": "searchHistoryCleared"])
                }
            } message: {
                Text("This will remove your recent search history. This action cannot be undone.")
            }
            .accessibilityLabel("Clear search history")
        } header: {
            Text("Data")
        }
    }

    // MARK: - Legal Section

    private var legalSection: some View {
        Section {
            NavigationLink {
                PrivacyPolicyView()
            } label: {
                Label {
                    Text("Privacy Policy")
                } icon: {
                    Image(systemName: "hand.raised")
                        .foregroundStyle(.treasureGold600)
                }
            }
            .accessibilityLabel("View privacy policy")

            NavigationLink {
                TermsOfServiceView()
            } label: {
                Label {
                    Text("Terms of Service")
                } icon: {
                    Image(systemName: "doc.text")
                        .foregroundStyle(.treasureGold600)
                }
            }
            .accessibilityLabel("View terms of service")
        } header: {
            Text("Legal")
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            HStack {
                Label {
                    Text("Version")
                } icon: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.treasureGold600)
                }
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("App version \(appVersion)")

            if let rateURL = URL(string: "https://apps.apple.com/app/trashtrove/id0000000000") {
                Link(destination: rateURL) {
                    Label {
                        Text("Rate on App Store")
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: "star")
                            .foregroundStyle(.treasureGold600)
                    }
                }
                .accessibilityLabel("Rate TrashTrove on the App Store")
            }

            if let feedbackURL = URL(string: "mailto:support@trashtrove.app?subject=TrashTrove%20iOS%20Feedback") {
                Link(destination: feedbackURL) {
                    Label {
                        Text("Send Feedback")
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: "envelope")
                            .foregroundStyle(.treasureGold600)
                    }
                }
                .accessibilityLabel("Send feedback via email")
            }
        } header: {
            Text("About")
        } footer: {
            Text("TrashTrove - Discover local garage sales")
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
        }
    }
}

#Preview {
    SettingsView()
}
