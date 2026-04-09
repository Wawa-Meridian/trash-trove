import Link from 'next/link';
import Logo from '@/components/Logo';

export default function Footer() {
  return (
    <footer className="bg-treasure-950 dark:bg-gray-900 text-treasure-300 dark:text-gray-300 mt-auto dark:border-t dark:border-gray-800">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div>
            <div className="flex items-center gap-2 mb-3">
              <Logo size={28} />
              <span className="font-display text-lg font-bold text-white dark:text-gray-100">
                TrashTrove
              </span>
            </div>
            <p className="text-sm text-treasure-300 dark:text-gray-400">
              Your weekend destination for neighborhood garage sales. Find
              hidden gems or list your own sale for free.
            </p>
          </div>

          <div>
            <h3 className="font-semibold text-white mb-3">Quick Links</h3>
            <ul className="space-y-2 text-sm">
              <li>
                <Link href="/nearby" className="hover:text-white transition-colors">
                  Near Me
                </Link>
              </li>
              <li>
                <Link href="/browse" className="hover:text-white transition-colors">
                  Browse Sales
                </Link>
              </li>
              <li>
                <Link href="/favorites" className="hover:text-white transition-colors">
                  Favorites
                </Link>
              </li>
              <li>
                <Link href="/create" className="hover:text-white transition-colors">
                  List Your Sale
                </Link>
              </li>
            </ul>
          </div>

          <div>
            <h3 className="font-semibold text-white mb-3">Popular States</h3>
            <ul className="space-y-2 text-sm">
              <li>
                <Link href="/browse/CA" className="hover:text-white transition-colors">
                  California
                </Link>
              </li>
              <li>
                <Link href="/browse/TX" className="hover:text-white transition-colors">
                  Texas
                </Link>
              </li>
              <li>
                <Link href="/browse/FL" className="hover:text-white transition-colors">
                  Florida
                </Link>
              </li>
              <li>
                <Link href="/browse/NY" className="hover:text-white transition-colors">
                  New York
                </Link>
              </li>
            </ul>
          </div>
        </div>

        <div className="border-t border-treasure-800 dark:border-gray-700 mt-8 pt-8 text-center text-sm text-treasure-400 dark:text-gray-400">
          <div className="flex items-center justify-center gap-4 mb-3">
            <Link href="/privacy" className="hover:text-white transition-colors">Privacy Policy</Link>
            <span>·</span>
            <Link href="/terms" className="hover:text-white transition-colors">Terms of Service</Link>
          </div>
          &copy; {new Date().getFullYear()} TrashTrove. All rights reserved.
        </div>
      </div>
    </footer>
  );
}
