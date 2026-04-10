import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Terms of Service")
                        .font(.custom("Georgia", size: 32))
                        .fontWeight(.bold)
                        .accessibilityAddTraits(.isHeader)

                    Text("Last updated: April 1, 2026")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text("Welcome to TrashTrove. By using our mobile application and website (trashtrove.app), you agree to be bound by these Terms of Service (\"Terms\"). If you do not agree to these Terms, please do not use the service.")

                // Acceptance of Terms
                termsSection(title: "1. Acceptance of Terms") {
                    Text("By accessing or using TrashTrove, you acknowledge that you have read, understood, and agree to be bound by these Terms and our Privacy Policy. These Terms apply to all users of the platform, including sellers who create listings and buyers who browse and contact sellers.")
                }

                // Description of Service
                termsSection(title: "2. Description of Service") {
                    Text("TrashTrove is a free platform that connects garage sale sellers with potential buyers. The service allows users to:")

                    bulletPoint("Create and publish garage sale, yard sale, and estate sale listings with photos, descriptions, dates, and locations.")
                    bulletPoint("Browse, search, and discover garage sale listings by location, state, category, and proximity.")
                    bulletPoint("Contact sellers through the platform's messaging system.")
                    bulletPoint("Save favorite listings for future reference.")

                    Text("TrashTrove does not facilitate transactions, process payments, or act as an intermediary in any sale of goods. All transactions occur directly between buyers and sellers at the physical sale location.")
                        .padding(.top, 4)
                }

                // User Responsibilities
                termsSection(title: "3. User Responsibilities") {
                    Text("As a user of TrashTrove, you agree to:")

                    bulletPoint("Provide accurate and truthful information in all listings and communications.")
                    bulletPoint("Only create listings for legitimate garage sales, yard sales, or estate sales that you are authorized to post.")
                    bulletPoint("Keep your listing information current, including updating or removing listings if a sale is cancelled.")
                    bulletPoint("Treat other users with respect in all communications through the platform.")
                    bulletPoint("Comply with all applicable local, state, and federal laws regarding the sale of goods.")
                    bulletPoint("Safeguard your manage token, which provides the ability to edit or delete your listing.")
                }

                // Listing Guidelines
                termsSection(title: "4. Listing Guidelines") {
                    Text("All listings must comply with the following guidelines:")

                    bulletPoint("Listings must be for actual garage sales, yard sales, estate sales, or similar events at a physical location.")
                    bulletPoint("Sale addresses must be accurate and correspond to the actual sale location.")
                    bulletPoint("Photos must depict items actually available at the sale or the sale location itself.")
                    bulletPoint("Descriptions must accurately represent the items and conditions of the sale.")
                    bulletPoint("Sale dates and times must be accurate and reflect when the sale is actually occurring.")
                }

                // Prohibited Content
                termsSection(title: "5. Prohibited Content") {
                    Text("The following content is strictly prohibited on TrashTrove:")

                    bulletPoint("Listings for items that are illegal to sell under federal or state law, including but not limited to controlled substances, stolen property, and weapons prohibited by law.")
                    bulletPoint("Fraudulent or misleading listings that do not correspond to an actual sale.")
                    bulletPoint("Spam, duplicate listings, or commercial advertising disguised as garage sale listings.")
                    bulletPoint("Content that is defamatory, obscene, threatening, or harassing.")
                    bulletPoint("Content that infringes on the intellectual property rights of others.")
                    bulletPoint("Listings that discriminate on the basis of race, color, religion, gender, sexual orientation, national origin, disability, or any other protected class.")
                    bulletPoint("Phishing attempts, malware distribution, or any content designed to compromise user security.")
                }

                // Content Ownership
                termsSection(title: "6. Content Ownership") {
                    Text("You retain ownership of all content you submit to TrashTrove, including listing descriptions and photos. By submitting content, you grant TrashTrove a non-exclusive, royalty-free, worldwide license to use, display, reproduce, and distribute your content in connection with operating and promoting the service.")

                    Text("You represent and warrant that you own or have the necessary rights to all content you submit, and that your content does not violate any third party's rights.")
                        .padding(.top, 4)
                }

                // Account Termination and Listing Removal
                termsSection(title: "7. Listing Removal") {
                    Text("TrashTrove reserves the right to remove any listing at any time, for any reason, including but not limited to:")

                    bulletPoint("Violation of these Terms of Service or our Listing Guidelines.")
                    bulletPoint("Reports from other users that are substantiated upon review.")
                    bulletPoint("Listings that appear to be fraudulent or misleading.")
                    bulletPoint("Listings that have expired (past the sale date) and the retention period has elapsed.")
                    bulletPoint("As required by law or in response to a valid legal request.")

                    Text("Sellers may remove their own listings at any time using their manage token. If you have lost your manage token, contact us for assistance.")
                        .padding(.top, 4)
                }

                // Limitation of Liability
                termsSection(title: "8. Limitation of Liability") {
                    Text("TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW:")
                        .font(.subheadline.weight(.semibold))
                        .padding(.bottom, 4)

                    bulletPoint("TrashTrove is provided on an \"AS IS\" and \"AS AVAILABLE\" basis without warranties of any kind, either express or implied.")
                    bulletPoint("We do not warrant that the service will be uninterrupted, timely, secure, or error-free.")
                    bulletPoint("We are not responsible for the accuracy, completeness, or reliability of any listing content posted by users.")
                    bulletPoint("We are not liable for any transactions, disputes, injuries, or damages that occur between buyers and sellers, whether at the sale location or otherwise.")
                    bulletPoint("We are not responsible for the quality, safety, legality, or availability of items listed on the platform.")
                    bulletPoint("In no event shall TrashTrove, its officers, directors, employees, or agents be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the service.")
                    bulletPoint("Our total liability for any claim arising from these Terms or your use of the service shall not exceed the amount you paid to use the service (which is zero, as TrashTrove is a free service).")
                }

                // Indemnification
                termsSection(title: "9. Indemnification") {
                    Text("You agree to indemnify and hold harmless TrashTrove and its affiliates, officers, agents, and employees from any claim, demand, loss, or damage, including reasonable attorney's fees, arising from your use of the service, your violation of these Terms, or your violation of any rights of another party.")
                }

                // Dispute Resolution
                termsSection(title: "10. Dispute Resolution") {
                    Text("Any disputes arising from or related to these Terms or your use of TrashTrove shall be resolved as follows:")

                    subsection(title: "Informal Resolution") {
                        Text("Before filing any formal proceeding, you agree to first contact us at legal@trashtrove.app and attempt to resolve the dispute informally for at least 30 days.")
                    }

                    subsection(title: "Governing Law") {
                        Text("These Terms are governed by and construed in accordance with the laws of the State of Delaware, without regard to its conflict of law provisions.")
                    }

                    subsection(title: "Arbitration") {
                        Text("If informal resolution is unsuccessful, any dispute shall be resolved by binding arbitration in accordance with the rules of the American Arbitration Association. The arbitration shall take place in the State of Delaware, and the arbitrator's decision shall be final and binding.")
                    }

                    subsection(title: "Class Action Waiver") {
                        Text("You agree that any dispute resolution proceedings will be conducted only on an individual basis and not in a class, consolidated, or representative action.")
                    }
                }

                // Modifications
                termsSection(title: "11. Modifications to Terms") {
                    Text("We reserve the right to modify these Terms at any time. We will provide notice of material changes by updating the \"Last updated\" date. Your continued use of TrashTrove after changes are posted constitutes acceptance of the modified Terms. If you do not agree with the modified Terms, you must stop using the service.")
                }

                // Severability
                termsSection(title: "12. Severability") {
                    Text("If any provision of these Terms is found to be invalid or unenforceable by a court of competent jurisdiction, the remaining provisions shall remain in full force and effect. The invalid or unenforceable provision shall be modified to the minimum extent necessary to make it valid and enforceable.")
                }

                // Contact
                termsSection(title: "13. Contact Information") {
                    Text("If you have questions about these Terms of Service, please contact us at:")

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email: legal@trashtrove.app")
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
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsService.shared.trackScreen("TermsOfService")
        }
    }

    // MARK: - Helpers

    private func termsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.custom("Georgia", size: 20))
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
        TermsOfServiceView()
    }
}
