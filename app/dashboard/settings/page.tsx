'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { AlertTriangle, Loader2, Trash2 } from 'lucide-react';
import { useAuth } from '@/components/AuthProvider';

export default function SettingsPage() {
  const { user, signOut } = useAuth();
  const router = useRouter();
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [confirmText, setConfirmText] = useState('');
  const [deleting, setDeleting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleDelete = async () => {
    setError(null);
    setDeleting(true);

    try {
      const res = await fetch('/api/auth/delete-account', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      });

      if (!res.ok) {
        const payload = (await res.json().catch(() => null)) as { error?: string } | null;
        throw new Error(payload?.error ?? 'Failed to delete account');
      }

      await signOut();
      router.replace('/?account_deleted=1');
      router.refresh();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to delete account');
      setDeleting(false);
    }
  };

  return (
    <div className="space-y-8">
      <div>
        <h2 className="font-display text-xl font-bold text-gray-900 dark:text-gray-100">
          Settings
        </h2>
        <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
          Manage your account and data.
        </p>
      </div>

      <section className="bg-white dark:bg-gray-900 rounded-xl border border-gray-200 dark:border-gray-700 p-6">
        <h3 className="font-semibold text-gray-900 dark:text-gray-100">Account</h3>
        <dl className="mt-4 space-y-2 text-sm">
          <div className="flex justify-between gap-4">
            <dt className="text-gray-500 dark:text-gray-400">Email</dt>
            <dd className="text-gray-900 dark:text-gray-100 truncate">{user?.email}</dd>
          </div>
          <div className="flex justify-between gap-4">
            <dt className="text-gray-500 dark:text-gray-400">User ID</dt>
            <dd className="text-gray-500 dark:text-gray-400 font-mono text-xs truncate">{user?.id}</dd>
          </div>
        </dl>
      </section>

      <section className="bg-white dark:bg-gray-900 rounded-xl border border-red-200 dark:border-red-900/50 p-6">
        <div className="flex items-start gap-3">
          <div className="p-2 rounded-lg bg-red-50 dark:bg-red-900/20">
            <AlertTriangle size={20} className="text-red-600" />
          </div>
          <div className="flex-1">
            <h3 className="font-semibold text-gray-900 dark:text-gray-100">Delete account</h3>
            <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
              Permanently delete your account and all of your data. This includes every
              garage sale you&apos;ve listed, all contact messages, and your saved searches.
              <strong className="block mt-2 text-red-600">This cannot be undone.</strong>
            </p>

            {!confirmOpen ? (
              <button
                onClick={() => setConfirmOpen(true)}
                className="mt-4 inline-flex items-center gap-2 px-4 py-2 rounded-lg border border-red-300 dark:border-red-800 text-red-700 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors text-sm font-medium"
              >
                <Trash2 size={16} />
                Delete account
              </button>
            ) : (
              <div className="mt-4 space-y-3">
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                  Type <span className="font-mono bg-gray-100 dark:bg-gray-800 px-1 rounded">DELETE</span> to confirm
                </label>
                <input
                  type="text"
                  value={confirmText}
                  onChange={(e) => setConfirmText(e.target.value)}
                  className="input-field"
                  placeholder="DELETE"
                  autoFocus
                />
                {error && (
                  <p className="text-sm text-red-600 flex items-center gap-1">
                    <AlertTriangle size={14} />
                    {error}
                  </p>
                )}
                <div className="flex gap-2">
                  <button
                    onClick={handleDelete}
                    disabled={confirmText !== 'DELETE' || deleting}
                    className="inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-red-600 text-white hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors text-sm font-medium"
                  >
                    {deleting ? (
                      <>
                        <Loader2 size={16} className="animate-spin" />
                        Deleting...
                      </>
                    ) : (
                      <>
                        <Trash2 size={16} />
                        Permanently delete my account
                      </>
                    )}
                  </button>
                  <button
                    onClick={() => {
                      setConfirmOpen(false);
                      setConfirmText('');
                      setError(null);
                    }}
                    disabled={deleting}
                    className="px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors text-sm font-medium"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </section>
    </div>
  );
}
