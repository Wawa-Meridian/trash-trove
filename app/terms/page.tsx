import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Terms of Service',
  description: 'TrashTrove terms of service — rules and guidelines for using our platform.',
};

export default function TermsOfServicePage() {
  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <h1 className="font-display text-3xl font-bold text-gray-900 mb-2">
        Terms of Service
      </h1>
      <p className="text-sm text-gray-500 mb-8">Last updated: April 3, 2026</p>

      <div className="prose prose-gray max-w-none space-y-6">
        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            1. Acceptance of Terms
          </h2>
          <p className="text-gray-600 leading-relaxed">
            By accessing or using TrashTrove (&quot;the Service&quot;), you agree to be bound
            by these Terms of Service. If you do not agree to these terms, please do not
            use the Service.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            2. Description of Service
          </h2>
          <p className="text-gray-600 leading-relaxed">
            TrashTrove is a free platform that allows users to list and discover local garage
            sales, yard sales, estate sales, and similar events. We provide a venue for
            connecting sellers and buyers but are not a party to any transactions.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            3. User Responsibilities
          </h2>
          <p className="text-gray-600 leading-relaxed">When using TrashTrove, you agree to:</p>
          <ul className="list-disc pl-6 text-gray-600 space-y-1 mt-2">
            <li>Provide accurate and truthful information in your listings</li>
            <li>Only list sales at addresses where you have permission to hold a sale</li>
            <li>Not use the Service for illegal activities or to sell prohibited items</li>
            <li>Not harass, spam, or send unsolicited messages to other users</li>
            <li>Not attempt to circumvent rate limits or other security measures</li>
            <li>Not scrape, crawl, or extract data from the Service without permission</li>
            <li>Comply with all applicable local, state, and federal laws</li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            4. Listing Guidelines
          </h2>
          <p className="text-gray-600 leading-relaxed">Listings must not contain:</p>
          <ul className="list-disc pl-6 text-gray-600 space-y-1 mt-2">
            <li>Prohibited items (weapons, controlled substances, stolen goods, counterfeit products)</li>
            <li>Offensive, discriminatory, or hateful content</li>
            <li>Misleading or fraudulent information</li>
            <li>Personal information of others without their consent</li>
            <li>Commercial advertising unrelated to a garage/yard sale</li>
          </ul>
          <p className="text-gray-600 leading-relaxed mt-2">
            We reserve the right to remove any listing that violates these guidelines without notice.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            5. Content Ownership
          </h2>
          <p className="text-gray-600 leading-relaxed">
            You retain ownership of all content you post (text, photos, etc.). By posting
            content on TrashTrove, you grant us a non-exclusive, royalty-free license to
            display, distribute, and promote your content in connection with the Service.
            This license ends when your listing is removed.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            6. Listing Management
          </h2>
          <p className="text-gray-600 leading-relaxed">
            When you create a listing, you receive a unique manage link that allows you to
            edit or delete your listing. You are responsible for keeping this link secure.
            Listings are automatically removed one week after the sale date.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            7. Disclaimer of Warranties
          </h2>
          <p className="text-gray-600 leading-relaxed">
            TrashTrove is provided &quot;as is&quot; and &quot;as available&quot; without
            warranties of any kind. We do not guarantee the accuracy of listings, the
            quality of items for sale, or that the Service will be uninterrupted or
            error-free. We are not responsible for any transactions between users.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            8. Limitation of Liability
          </h2>
          <p className="text-gray-600 leading-relaxed">
            To the maximum extent permitted by law, TrashTrove and its operators shall not
            be liable for any indirect, incidental, special, consequential, or punitive
            damages arising from your use of the Service, including but not limited to
            damages from transactions with other users, loss of data, or service interruptions.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            9. Reporting and Enforcement
          </h2>
          <p className="text-gray-600 leading-relaxed">
            Users can report listings that violate these terms. We review reports and may
            remove listings or take other action at our discretion. Repeated violations may
            result in IP-based restrictions.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            10. Changes to Terms
          </h2>
          <p className="text-gray-600 leading-relaxed">
            We may modify these terms at any time. Continued use of the Service after changes
            are posted constitutes acceptance of the modified terms.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-semibold text-gray-900 mt-8 mb-3">
            11. Contact
          </h2>
          <p className="text-gray-600 leading-relaxed">
            For questions about these Terms of Service, please contact us at{' '}
            <a
              href="mailto:legal@trashtrove.app"
              className="text-treasure-600 hover:text-treasure-700"
            >
              legal@trashtrove.app
            </a>.
          </p>
        </section>
      </div>
    </div>
  );
}
