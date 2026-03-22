import type { Metadata } from 'next';
import './globals.css';
import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';

export const metadata: Metadata = {
  title: {
    default: 'TrashTrove - Find Garage Sales Near You',
    template: '%s | TrashTrove',
  },
  description:
    'Discover weekend garage sales in your neighborhood. Browse by state and city, find hidden gems, and list your own sale.',
  openGraph: {
    type: 'website',
    siteName: 'TrashTrove',
    title: 'TrashTrove - Find Garage Sales Near You',
    description:
      'Discover weekend garage sales in your neighborhood. Browse by state and city, find hidden gems, and list your own sale.',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'TrashTrove - Find Garage Sales Near You',
    description:
      'Discover weekend garage sales in your neighborhood. Browse by state and city, find hidden gems, and list your own sale.',
  },
};

export const viewport = {
  width: 'device-width',
  initialScale: 1,
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="min-h-screen flex flex-col">
        <Navbar />
        <main className="flex-1">{children}</main>
        <Footer />
      </body>
    </html>
  );
}
