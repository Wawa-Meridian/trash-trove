'use client';

import { WifiOff } from 'lucide-react';

export default function OfflinePage() {
  return (
    <div className="max-w-lg mx-auto px-4 py-24 text-center">
      <div className="inline-flex items-center justify-center w-16 h-16 bg-gray-100 dark:bg-gray-800 rounded-full mb-6">
        <WifiOff size={32} className="text-gray-400" />
      </div>
      <h1 className="font-display text-2xl font-bold text-gray-900 dark:text-gray-100 mb-3">
        You&apos;re Offline
      </h1>
      <p className="text-gray-500 dark:text-gray-400 mb-6">
        Check your internet connection and try again. Your favorites are saved locally
        and will be available when you&apos;re back online.
      </p>
      <button
        onClick={() => window.location.reload()}
        className="btn-primary"
      >
        Try Again
      </button>
    </div>
  );
}
