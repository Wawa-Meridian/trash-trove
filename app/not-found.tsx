import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24 text-center">
      <h1 className="font-display text-4xl font-bold text-gray-900 mb-4">
        Page Not Found
      </h1>
      <p className="text-gray-500 mb-8">
        The page you&apos;re looking for doesn&apos;t exist or has been removed.
      </p>
      <div className="flex gap-4 justify-center">
        <Link href="/" className="btn-primary">
          Go Home
        </Link>
        <Link href="/browse" className="btn-secondary">
          Browse Sales
        </Link>
      </div>
    </div>
  );
}
