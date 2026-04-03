import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Privacy Policy")
                        .font(.custom("Georgia", size: 32))
                        .fontWeight(.bold)
                        .accessibilityAddTraits(.isHeader)

                    Text("Last updated: April 1, 2026")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text("TrashTrove (\"we\", \"our\", or \"us\") operates the TrashTrove mobile application and website (trashtrove.app). This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our service.")

                // Information We Collect
                policySection(title: "Information We Collect") {
                    Text("We collect information that you provide directly and information collected automatically when you use TrashTrove.")

                    subsection(title: "Information You Provide") {
                        bulletPoint("Email addresses when creating a garage sale listing or contacting a seller.")
                        bulletPoint("Names provided when creating listings or sending contact messages.")
                        bulletPoint("Listing content including sale titles, descriptions, addresses, dates, times, and categories.")
                        bulletPoint("Photos uploaded for garage sale listings.")
                        bulletPoint("Contact messages sent through the platform to sellers.")
                    }

                    subsection(title: "Information Collected Automatically") {
                        bulletPoint("Location data (latitude and longitude) when you use the \"Nearby Sales\" feature. Location access requires your explicit permission and can be revoked at any time through your device settings.")
                        bulletPoint("IP addresses for rate limiting and abuse prevention.")
                        bulletPoint("Device information including device type, operating system version, and app version.")
                        bulletPoint("Usage analytics including screens viewed, features used, and search queries to improve the service.")
                    }
                }

                // How We Use Your Information
                policySection(title: "How We Use Your Information") {
                    bulletPoint("To display garage sale listings to other users of the platform.")
                    bulletPoint("To facilitate communication between buyers and sellers via contact messages.")
                    bulletPoint("To provide location-based search and discovery of nearby garage sales.")
                    bulletPoint("To geocode listing addresses for map display using third-party mapping services.")
                    bulletPoint("To prevent abuse, enforce rate limits, and maintain platform integrity.")
                    bulletPoint("To analyze usage patterns and improve the service.")
                    bulletPoint("To send transactional notifications related to your listings (if notifications are enabled).")
                }

                // Third-Party Services
                policySection(title: "Third-Party Services") {
                    Text("TrashTrove uses the following third-party services that may collect and process your data:")

                    subsection(title: "Supabase") {
                        Text("Our backend infrastructure provider. Stores listing data, photos, and contact messages. Visit supabase.com/privacy for their privacy policy.")
                    }

                    subsection(title: "OpenStreetMap (Nominatim)") {
                        Text("Used for geocoding listing addresses to coordinates for map display. Requests include the listing address. Visit wiki.osmfoundation.org/wiki/Privacy_Policy for their privacy policy.")
                    }

                    subsection(title: "Apple MapKit") {
                        Text("Used to display maps and sale locations within the iOS app. Subject to Apple's privacy policy at apple.com/legal/privacy.")
                    }

                    subsection(title: "Google Maps") {
                        Text("Used on the web version for directions and map links. Subject to Google's privacy policy at policies.google.com/privacy.")
                    }
                }

                // Data Retention
                policySection(title: "Data Retention") {
                    bulletPoint("Active garage sale listings are retained for as long as the sale date has not passed and the listing has not been removed by the seller.")
                    bulletPoint("Expired listings (past sale date) may be retained for up to 90 days for archival purposes before automatic deletion.")
                    bulletPoint("Contact messages are retained for 90 days after the associated sale date.")
                    bulletPoint("Photos associated with listings are deleted when the listing is removed.")
                    bulletPoint("Analytics data is retained in aggregate form and is not linked to individual users after 12 months.")
                    bulletPoint("Favorites and search history are stored locally on your device and are never transmitted to our servers.")
                }

                // Data Security
                policySection(title: "Data Security") {
                    Text("We implement appropriate technical and organizational measures to protect your personal information, including:")

                    bulletPoint("All data in transit is encrypted using TLS/SSL.")
                    bulletPoint("Database access is controlled through Row Level Security (RLS) policies.")
                    bulletPoint("API endpoints are rate-limited to prevent abuse.")
                    bulletPoint("Manage tokens for listings are generated using cryptographically secure methods.")
                    bulletPoint("We do not store passwords as the platform does not require user accounts.")
                }

                // Your Rights
                policySection(title: "Your Rights") {
                    Text("You have the following rights regarding your personal data:")

                    subsection(title: "Data Access") {
                        Text("You may request a copy of all data associated with your email address by contacting us.")
                    }

                    subsection(title: "Data Deletion") {
                        Text("You may delete your garage sale listing at any time using the manage token provided when the listing was created. You may also request deletion of all data associated with your email address by contacting us.")
                    }

                    subsection(title: "Location Data") {
                        Text("You may revoke location access at any time through your device settings. The app will continue to function with browse and search features without location access.")
                    }

                    subsection(title: "Local Data") {
                        Text("Favorites and search history stored on your device can be cleared at any time from the Settings screen within the app.")
                    }
                }

                // Children's Privacy
                policySection(title: "Children's Privacy") {
                    Text("TrashTrove is not directed at children under 13 years of age. We do not knowingly collect personal information from children under 13. If we become aware that a child under 13 has provided us with personal information, we will take steps to delete that information.")
                }

                // Changes to This Policy
                policySection(title: "Changes to This Policy") {
                    Text("We may update this Privacy Policy from time to time. We will notify you of any material changes by updating the \"Last updated\" date at the top of this policy. Your continued use of TrashTrove after changes are posted constitutes your acceptance of the revised policy.")
                }

                // Contact Information
                policySection(title: "Contact Us") {
                    Text("If you have questions or concerns about this Privacy Policy or our data practices, please contact us at:")

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email: privacy@trashtrove.app")
                            .font(.subheadline)
                        Text("Website: trashtrove.app/contact")
                            .font(.subheadline)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.treasure50)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(24)
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsService.shared.trackScreen("PrivacyPolicy")
        }
    }

    // MARK: - Helpers

    private func policySection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.custom("Georgia", size: 22))
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)

            content()
        }
    }

    private func subsection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .padding(.top, 4)

            content()
        }
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\u{2022}")
                .foregroundStyle(Color.treasureGold600)
                .accessibilityHidden(true)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
