import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Privacy Policy',
};

export default function PrivacyPolicyPage() {
  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <h1 className="font-display text-3xl font-bold text-gray-900 dark:text-gray-100 mb-8">
        Privacy Policy
      </h1>
      <div className="prose prose-gray dark:prose-invert max-w-none space-y-6">
        <p className="text-sm text-gray-500 dark:text-gray-400">Last updated: March 24, 2026</p>

        <section>
          <h2>Overview</h2>
          <p>
            TrashTrove (&ldquo;we&rdquo;, &ldquo;us&rdquo;, or &ldquo;our&rdquo;) operates the website
            trashtrove.xyz and the TrashTrove mobile application. This Privacy Policy explains how we
            collect, use, and protect your information when you use our services.
          </p>
        </section>

        <section>
          <h2>Information We Collect</h2>
          <h3>Information you provide</h3>
          <ul>
            <li><strong>Account information:</strong> When you create an account, we collect your name, email address, and password. If you sign in with Google, we receive your name and email from Google.</li>
            <li><strong>Listing information:</strong> When you create a garage sale listing, we collect the sale title, description, address, dates, times, categories, photos, and your contact information.</li>
            <li><strong>Contact messages:</strong> When you contact a seller, we collect your name, email, and message content.</li>
          </ul>

          <h3>Information collected automatically</h3>
          <ul>
            <li><strong>Location data:</strong> If you use the &ldquo;Near Me&rdquo; feature, we request your device&apos;s location to find nearby sales. This is only used in real-time and is not stored on our servers.</li>
            <li><strong>Usage data:</strong> We collect standard web server logs including IP addresses, browser type, and pages visited.</li>
          </ul>
        </section>

        <section>
          <h2>How We Use Your Information</h2>
          <ul>
            <li>Display your garage sale listings to other users</li>
            <li>Deliver contact messages between buyers and sellers</li>
            <li>Send email notifications when someone contacts you about your sale (if configured)</li>
            <li>Geocode your sale address to display it on maps</li>
            <li>Enforce rate limits and prevent abuse</li>
            <li>Improve and maintain our services</li>
          </ul>
        </section>

        <section>
          <h2>Information Sharing</h2>
          <p>We do not sell your personal information. We share information only in these cases:</p>
          <ul>
            <li><strong>Public listings:</strong> Your sale title, description, address, photos, categories, dates, and seller name are publicly visible to all users.</li>
            <li><strong>Contact messages:</strong> When you contact a seller, your name and email are shared with that seller so they can respond.</li>
            <li><strong>Service providers:</strong> We use Supabase for data storage, Google Maps for geocoding, and Resend for email delivery. These services process data on our behalf.</li>
            <li><strong>Legal requirements:</strong> We may disclose information if required by law or to protect our rights.</li>
          </ul>
        </section>

        <section>
          <h2>Data Storage and Security</h2>
          <p>
            Your data is stored securely on Supabase servers in the United States. We use
            row-level security policies to protect your data and HTTPS encryption for all
            communications. Photos are stored in Supabase Storage with public read access.
          </p>
        </section>

        <section>
          <h2>Data Retention</h2>
          <p>
            Garage sale listings are automatically removed after the sale date passes as part of our
            weekly cleanup process. Account data is retained until you delete your account. You can
            delete your listings at any time through the manage page or your dashboard.
          </p>
        </section>

        <section>
          <h2>Your Rights</h2>
          <p>You have the right to:</p>
          <ul>
            <li>Access your personal data through your dashboard</li>
            <li>Edit or delete your listings at any time</li>
            <li>
              <strong>Delete your account and all of your data</strong> at any time from{' '}
              <em>Dashboard → Settings → Delete account</em>. This permanently removes your
              listings, messages, saved searches, profile, and authentication record.
            </li>
            <li>Opt out of email notifications</li>
          </ul>
        </section>

        <section>
          <h2>Third-Party Services</h2>
          <p>
            We rely on the following processors to deliver TrashTrove. Each has its own
            privacy policy that governs how they handle your data:
          </p>
          <ul>
            <li>
              <strong>Supabase</strong> — database, authentication, and file storage.{' '}
              <a href="https://supabase.com/privacy" target="_blank" rel="noopener noreferrer">
                supabase.com/privacy
              </a>
            </li>
            <li>
              <strong>Google Maps Platform</strong> — geocoding and map tiles.{' '}
              <a href="https://policies.google.com/privacy" target="_blank" rel="noopener noreferrer">
                policies.google.com/privacy
              </a>
            </li>
            <li>
              <strong>Resend</strong> — transactional email delivery.{' '}
              <a href="https://resend.com/legal/privacy-policy" target="_blank" rel="noopener noreferrer">
                resend.com/legal/privacy-policy
              </a>
            </li>
            <li>
              <strong>Cloudflare</strong> — TLS termination, content delivery, and DDoS
              protection. <a href="https://www.cloudflare.com/privacypolicy/" target="_blank" rel="noopener noreferrer">
                cloudflare.com/privacypolicy
              </a>
            </li>
          </ul>
        </section>

        <section>
          <h2>California Residents (CCPA/CPRA)</h2>
          <p>
            If you live in California, you have the right to know what personal information
            we collect, to request deletion of that information, to correct inaccurate data,
            and to opt out of any sale or sharing of personal information. TrashTrove does
            not sell or share personal information. You can exercise your access and
            deletion rights from the Settings page inside the app, or by emailing{' '}
            <a href="mailto:privacy@trashtrove.xyz">privacy@trashtrove.xyz</a>.
          </p>
        </section>

        <section>
          <h2>European Residents (GDPR)</h2>
          <p>
            If you live in the European Economic Area, United Kingdom, or Switzerland, you
            have the right to access, rectify, erase, restrict processing of, and port your
            personal data. Our lawful basis for processing is the performance of the contract
            you agree to when creating an account (Article 6(1)(b) GDPR) and your consent
            for optional features such as location and email notifications (Article 6(1)(a)
            GDPR). You can withdraw consent and delete your data at any time from the
            Settings page or by contacting{' '}
            <a href="mailto:privacy@trashtrove.xyz">privacy@trashtrove.xyz</a>.
          </p>
        </section>

        <section>
          <h2>Cookies</h2>
          <p>
            We use essential cookies for authentication session management. We do not use
            advertising or tracking cookies. Your theme preference (light/dark mode) is stored
            in your browser&apos;s local storage.
          </p>
        </section>

        <section>
          <h2>Children&apos;s Privacy</h2>
          <p>
            TrashTrove is not intended for children under 13. We do not knowingly collect
            information from children under 13. If you believe a child has provided us with
            personal information, please contact us.
          </p>
        </section>

        <section>
          <h2>Changes to This Policy</h2>
          <p>
            We may update this Privacy Policy from time to time. We will notify users of
            significant changes by posting a notice on our website.
          </p>
        </section>

        <section>
          <h2>Contact Us</h2>
          <p>
            If you have questions about this Privacy Policy, contact us at{' '}
            <a href="mailto:privacy@trashtrove.xyz" className="text-treasure-600 hover:text-treasure-700">
              privacy@trashtrove.xyz
            </a>
          </p>
        </section>
      </div>
    </div>
  );
}
