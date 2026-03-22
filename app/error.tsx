'use client';

import { AlertTriangle, RotateCcw } from 'lucide-react';

export default function ErrorPage({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="max-w-lg mx-auto px-4 py-24 text-center">
      <div className="inline-flex items-center justify-center w-16 h-16 bg-red-50 dark:bg-red-900/20 rounded-full mb-6">
        <AlertTriangle size={32} className="text-red-500" />
      </div>
      <h1 className="font-display text-2xl font-bold text-gray-900 dark:text-gray-100 mb-3">
        Something went wrong
      </h1>
      <p className="text-gray-500 dark:text-gray-400 mb-6">
        An unexpected error occurred. Please try again.
      </p>
      <button
        onClick={reset}
        className="btn-primary inline-flex items-center gap-2"
      >
        <RotateCcw size={16} />
        Try Again
      </button>
    </div>
  );
}
