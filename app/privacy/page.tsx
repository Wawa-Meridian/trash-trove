import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Privacy Policy',
  description: 'TrashTrove privacy policy — how we collect, use, and protect your data.',
};

export default function PrivacyPolicyPage() {
  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <h1 className="font-display text-3xl font-bold text-gray-900 mb-2">
        Privacy Policy
      </h1>
      <p className="text-sm text-gray-500 mb-8">Last updated: April 3, 2026</p>

      <div className="prose prose-gray max-w-none space-y-6">
        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            1. Information We Collect
          </h2>
          <p className="text-gray-600 leading-relaxed">
            When you use TrashTrove, we may collect the following information:
          </p>
          <ul className="list-disc pl-6 text-gray-600 space-y-1 mt-2">
            <li><strong>Listing Information:</strong> Name, email address, street address, city, state, ZIP code, sale descriptions, and photos you upload when creating a listing.</li>
            <li><strong>Contact Messages:</strong> Name, email address, and message content when you contact a seller through our platform.</li>
            <li><strong>Location Data:</strong> With your permission, we collect your geographic coordinates to show nearby garage sales. This data is not stored on our servers.</li>
            <li><strong>Usage Data:</strong> IP address (for rate limiting and abuse prevention), pages visited, search queries, and general interaction patterns.</li>
            <li><strong>Device Information:</strong> Browser type, operating system, and device type for optimizing your experience.</li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            2. How We Use Your Information
          </h2>
          <ul className="list-disc pl-6 text-gray-600 space-y-1">
            <li>Display your garage sale listings to potential buyers</li>
            <li>Facilitate communication between buyers and sellers</li>
            <li>Geocode your address to show your sale on maps</li>
            <li>Prevent abuse, spam, and fraudulent listings</li>
            <li>Improve our services and user experience</li>
            <li>Respond to reports of policy violations</li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            3. Third-Party Services
          </h2>
          <p className="text-gray-600 leading-relaxed">
            We use the following third-party services to operate TrashTrove:
          </p>
          <ul className="list-disc pl-6 text-gray-600 space-y-1 mt-2">
            <li><strong>Supabase:</strong> Database hosting and file storage for listings and photos.</li>
            <li><strong>Google Maps API:</strong> Address geocoding to place sales on maps.</li>
            <li><strong>OpenStreetMap / Nominatim:</strong> Fallback geocoding and map tile rendering.</li>
          </ul>
          <p className="text-gray-600 leading-relaxed mt-2">
            Each service has its own privacy policy. We encourage you to review them.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            4. Data Retention
          </h2>
          <p className="text-gray-600 leading-relaxed">
            Garage sale listings are automatically removed one week after the sale date.
            Contact messages and reports are retained for up to 90 days for moderation
            purposes. Photos are deleted when the associated listing is removed.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            5. Your Rights
          </h2>
          <p className="text-gray-600 leading-relaxed">You have the right to:</p>
          <ul className="list-disc pl-6 text-gray-600 space-y-1 mt-2">
            <li><strong>Access:</strong> Request a copy of the data we hold about you.</li>
            <li><strong>Delete:</strong> Remove your listing at any time using your manage link. Contact us to request deletion of other personal data.</li>
            <li><strong>Correct:</strong> Update your listing information using your manage link.</li>
            <li><strong>Opt out:</strong> You can use TrashTrove to browse without providing any personal information. Location access is optional.</li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            6. Data Security
          </h2>
          <p className="text-gray-600 leading-relaxed">
            We implement industry-standard security measures including encrypted connections
            (TLS/SSL), rate limiting, input validation, and Row-Level Security policies on
            our database. However, no method of transmission over the Internet is 100% secure.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            7. Cookies and Local Storage
          </h2>
          <p className="text-gray-600 leading-relaxed">
            TrashTrove uses browser local storage to save your favorites and manage tokens
            for your listings. We do not use tracking cookies. No third-party advertising
            cookies are used.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            8. Children&apos;s Privacy
          </h2>
          <p className="text-gray-600 leading-relaxed">
            TrashTrove is not intended for children under 13 years of age. We do not
            knowingly collect personal information from children under 13.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            9. Changes to This Policy
          </h2>
          <p className="text-gray-600 leading-relaxed">
            We may update this privacy policy from time to time. We will notify you of any
            changes by posting the new privacy policy on this page and updating the
            &quot;Last updated&quot; date.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            10. Contact Us
          </h2>
          <p className="text-gray-600 leading-relaxed">
            If you have questions about this privacy policy or wish to exercise your data
            rights, please contact us at{' '}
            <a
              href="mailto:privacy@trashtrove.app"
              className="text-treasure-600 hover:text-treasure-700"
            >
              privacy@trashtrove.app
            </a>.
          </p>
        </section>
      </div>
    </div>
  );
}
