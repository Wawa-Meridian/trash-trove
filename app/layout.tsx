import type { Metadata } from 'next';
import './globals.css';
import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import AuthProvider from '@/components/AuthProvider';
import SkipToContent from '@/components/SkipToContent';
import NativeInit from '@/components/NativeInit';

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
    <html lang="en" suppressHydrationWarning>
      <head>
        <link rel="manifest" href="/manifest.json" />
        <meta name="theme-color" content="#c76b23" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="default" />
        <meta name="apple-mobile-web-app-title" content="TrashTrove" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
        <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
        <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png" />
        {/* Apple splash screens */}
        <link rel="apple-touch-startup-image" href="/splashscreens/iphone-13.png" media="(device-width: 390px) and (device-height: 844px) and (-webkit-device-pixel-ratio: 3)" />
        <link rel="apple-touch-startup-image" href="/splashscreens/iphone-14-pro.png" media="(device-width: 393px) and (device-height: 852px) and (-webkit-device-pixel-ratio: 3)" />
        <link rel="apple-touch-startup-image" href="/splashscreens/iphone-14-pro-max.png" media="(device-width: 430px) and (device-height: 932px) and (-webkit-device-pixel-ratio: 3)" />
        <link rel="apple-touch-startup-image" href="/splashscreens/iphone-x.png" media="(device-width: 375px) and (device-height: 812px) and (-webkit-device-pixel-ratio: 3)" />
        <link rel="apple-touch-startup-image" href="/splashscreens/iphone-xs-max.png" media="(device-width: 414px) and (device-height: 896px) and (-webkit-device-pixel-ratio: 3)" />
        <link rel="apple-touch-startup-image" href="/splashscreens/ipad-pro-12.png" media="(device-width: 1024px) and (device-height: 1366px) and (-webkit-device-pixel-ratio: 2)" />
        <script dangerouslySetInnerHTML={{ __html: `
          try {
            if (localStorage.theme === 'dark' || (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
              document.documentElement.classList.add('dark');
            }
          } catch (_) {}
        `}} />
      </head>
      <body className="min-h-screen flex flex-col bg-[#fdf8f0] dark:bg-gray-950 text-gray-900 dark:text-gray-100">
        <AuthProvider>
          <NativeInit />
          <SkipToContent />
          <Navbar />
          <main id="main-content" className="flex-1">{children}</main>
          <Footer />
        </AuthProvider>
      </body>
    </html>
  );
}
