'use client';

import { useState, useRef, useEffect } from 'react';
import { Flag, X } from 'lucide-react';

const REPORT_REASONS = [
  { value: 'spam', label: 'Spam or fake listing' },
  { value: 'inappropriate', label: 'Inappropriate content' },
  { value: 'scam', label: 'Suspected scam' },
  { value: 'duplicate', label: 'Duplicate listing' },
  { value: 'other', label: 'Other' },
] as const;

type ReportReason = (typeof REPORT_REASONS)[number]['value'];

interface ReportButtonProps {
  saleId: string;
}

export default function ReportButton({ saleId }: ReportButtonProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedReason, setSelectedReason] = useState<ReportReason | null>(null);
  const [details, setDetails] = useState('');
  const [status, setStatus] = useState<'idle' | 'submitting' | 'success' | 'error'>('idle');
  const [errorMessage, setErrorMessage] = useState('');
  const modalRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (modalRef.current && !modalRef.current.contains(e.target as Node)) {
        handleClose();
      }
    }

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [isOpen]);

  function handleClose() {
    setIsOpen(false);
    setSelectedReason(null);
    setDetails('');
    setStatus('idle');
    setErrorMessage('');
  }

  async function handleSubmit() {
    if (!selectedReason) return;

    setStatus('submitting');
    setErrorMessage('');

    try {
      const body: { reason: string; details?: string } = { reason: selectedReason };
      if (selectedReason === 'other' && details.trim()) {
        body.details = details.trim();
      }

      const res = await fetch(`/api/sales/${saleId}/report`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });

      if (res.status === 429) {
        setStatus('error');
        setErrorMessage('Too many reports. Please try again later.');
        return;
      }

      if (!res.ok) {
        const data = await res.json();
        setStatus('error');
        setErrorMessage(data.error ?? 'Something went wrong.');
        return;
      }

      setStatus('success');
    } catch {
      setStatus('error');
      setErrorMessage('Network error. Please try again.');
    }
  }

  return (
    <>
      <button
        onClick={() => setIsOpen(true)}
        className="flex items-center gap-1.5 text-sm text-gray-400 hover:text-red-500 transition-colors"
      >
        <Flag size={16} />
        Report
      </button>

      {/* Modal overlay */}
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4">
          <div
            ref={modalRef}
            className="bg-white dark:bg-gray-900 rounded-xl shadow-xl w-full max-w-md p-6 relative"
          >
            <button
              onClick={handleClose}
              className="absolute top-4 right-4 text-gray-400 hover:text-gray-600"
              aria-label="Close"
            >
              <X size={20} />
            </button>

            <h3 className="font-display text-lg font-bold text-gray-900 dark:text-gray-100 mb-1">
              Report Listing
            </h3>
            <p className="text-sm text-gray-500 dark:text-gray-400 mb-5">
              Why are you reporting this listing?
            </p>

            {status === 'success' ? (
              <div className="text-center py-6">
                <div className="text-green-600 font-semibold mb-2">
                  Report submitted. Thank you.
                </div>
                <p className="text-sm text-gray-500 mb-4">
                  We will review this listing shortly.
                </p>
                <button onClick={handleClose} className="btn-secondary">
                  Close
                </button>
              </div>
            ) : (
              <>
                <div className="space-y-2 mb-4">
                  {REPORT_REASONS.map((reason) => (
                    <label
                      key={reason.value}
                      className={`flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-colors ${
                        selectedReason === reason.value
                          ? 'border-treasure-500 bg-treasure-50 dark:bg-treasure-900/20'
                          : 'border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800'
                      }`}
                    >
                      <input
                        type="radio"
                        name="report-reason"
                        value={reason.value}
                        checked={selectedReason === reason.value}
                        onChange={() => setSelectedReason(reason.value)}
                        className="accent-treasure-600"
                      />
                      <span className="text-sm text-gray-700 dark:text-gray-300">{reason.label}</span>
                    </label>
                  ))}
                </div>

                {selectedReason === 'other' && (
                  <textarea
                    value={details}
                    onChange={(e) => setDetails(e.target.value)}
                    placeholder="Please provide more details..."
                    className="input-field mb-4 resize-none h-24"
                  />
                )}

                {status === 'error' && (
                  <p className="text-sm text-red-600 mb-3">{errorMessage}</p>
                )}

                <div className="flex gap-3">
                  <button
                    onClick={handleClose}
                    className="btn-secondary flex-1"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={handleSubmit}
                    disabled={!selectedReason || status === 'submitting'}
                    className="btn-primary flex-1 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {status === 'submitting' ? 'Submitting...' : 'Submit Report'}
                  </button>
                </div>
              </>
            )}
          </div>
        </div>
      )}
    </>
  );
}
