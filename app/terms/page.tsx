import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Terms of Service',
};

export default function TermsOfServicePage() {
  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <h1 className="font-display text-3xl font-bold text-gray-900 dark:text-gray-100 mb-8">
        Terms of Service
      </h1>
      <div className="prose prose-gray dark:prose-invert max-w-none space-y-6">
        <p className="text-sm text-gray-500 dark:text-gray-400">Last updated: March 24, 2026</p>

        <section>
          <h2>Agreement to Terms</h2>
          <p>
            By accessing or using TrashTrove (&ldquo;the Service&rdquo;), you agree to be bound by
            these Terms of Service. If you do not agree to these terms, do not use the Service.
          </p>
        </section>

        <section>
          <h2>Description of Service</h2>
          <p>
            TrashTrove is a platform that connects garage sale sellers with buyers. We provide
            tools to list garage sales, browse listings by location, and contact sellers. TrashTrove
            is a listing platform only — we are not a party to any transaction between buyers and sellers.
          </p>
        </section>

        <section>
          <h2>User Accounts</h2>
          <ul>
            <li>You may create listings with or without an account.</li>
            <li>If you create an account, you are responsible for maintaining the security of your credentials.</li>
            <li>You must provide accurate information when creating listings or an account.</li>
            <li>You must be at least 13 years old to use the Service.</li>
          </ul>
        </section>

        <section>
          <h2>Listing Guidelines</h2>
          <p>When creating a listing, you agree to:</p>
          <ul>
            <li>Provide accurate sale information including address, dates, and times</li>
            <li>Only list legitimate garage sales, yard sales, estate sales, or moving sales</li>
            <li>Not list prohibited or illegal items</li>
            <li>Not post spam, fraudulent, or misleading content</li>
            <li>Not use the platform for commercial retail operations</li>
          </ul>
          <p>
            We reserve the right to remove any listing that violates these guidelines or is reported
            by other users.
          </p>
        </section>

        <section>
          <h2>Prohibited Conduct</h2>
          <p>You agree not to:</p>
          <ul>
            <li>Use the Service for any illegal purpose</li>
            <li>Harass, threaten, or abuse other users</li>
            <li>Post false, misleading, or deceptive listings</li>
            <li>Scrape, crawl, or use automated tools to access the Service without permission</li>
            <li>Attempt to circumvent rate limits or security measures</li>
            <li>Impersonate another person or entity</li>
            <li>Upload malicious content, viruses, or harmful code</li>
          </ul>
        </section>

        <section>
          <h2>Content Ownership</h2>
          <p>
            You retain ownership of content you post (descriptions, photos, etc.). By posting
            content to TrashTrove, you grant us a non-exclusive, worldwide, royalty-free license
            to display, distribute, and promote your content in connection with the Service.
          </p>
          <p>
            Listings are automatically removed after the sale date as part of our weekly
            cleanup process. You may also delete your listings at any time.
          </p>
        </section>

        <section>
          <h2>Disclaimer of Warranties</h2>
          <p>
            The Service is provided &ldquo;as is&rdquo; without warranties of any kind. We do not
            guarantee the accuracy of any listing information. We are not responsible for the
            quality, safety, or legality of items sold at garage sales listed on our platform.
          </p>
          <p>
            We do not verify the identity of users or the accuracy of listing information.
            Exercise caution when visiting sale locations or conducting transactions.
          </p>
        </section>

        <section>
          <h2>Limitation of Liability</h2>
          <p>
            To the maximum extent permitted by law, TrashTrove shall not be liable for any
            indirect, incidental, special, consequential, or punitive damages arising from
            your use of the Service, including but not limited to any transactions between
            buyers and sellers.
          </p>
        </section>

        <section>
          <h2>Reporting and Moderation</h2>
          <p>
            Users can report listings that violate our guidelines. We review reports and may
            remove listings or suspend accounts at our discretion. If you believe a listing
            is fraudulent or inappropriate, use the Report button on the listing page.
          </p>
        </section>

        <section>
          <h2>Termination</h2>
          <p>
            We may suspend or terminate your access to the Service at any time, with or without
            cause. You may stop using the Service and delete your account at any time.
          </p>
        </section>

        <section>
          <h2>Changes to Terms</h2>
          <p>
            We may update these Terms from time to time. Continued use of the Service after
            changes constitutes acceptance of the updated Terms.
          </p>
        </section>

        <section>
          <h2>Contact</h2>
          <p>
            Questions about these Terms? Contact us at{' '}
            <a href="mailto:legal@trashtrove.xyz" className="text-treasure-600 hover:text-treasure-700">
              legal@trashtrove.xyz
            </a>
          </p>
        </section>
      </div>
    </div>
  );
}
