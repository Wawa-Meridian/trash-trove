'use client';

import { useState, useEffect, useCallback } from 'react';
import { useParams, useSearchParams, useRouter } from 'next/navigation';
import { Edit, Trash2, Loader2, CheckCircle, AlertTriangle, ArrowLeft } from 'lucide-react';
import Link from 'next/link';
import { SALE_CATEGORIES, US_STATES } from '@/lib/types';

interface SaleData {
  id: string;
  title: string;
  description: string;
  categories: string[];
  address: string;
  city: string;
  state: string;
  zip: string;
  sale_date: string;
  start_time: string;
  end_time: string;
  seller_name: string;
  seller_email: string;
}

export default function ManageSalePage() {
  const params = useParams();
  const searchParams = useSearchParams();
  const router = useRouter();
  const id = params.id as string;
  const token = searchParams.get('token');

  const [sale, setSale] = useState<SaleData | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  const [formData, setFormData] = useState<Partial<SaleData>>({});

  const fetchSale = useCallback(async () => {
    try {
      const res = await fetch(`/api/sales/${id}`);
      if (!res.ok) {
        setError('Sale not found');
        return;
      }
      const { sale: saleData } = await res.json();
      setSale(saleData);
      setFormData({
        title: saleData.title,
        description: saleData.description,
        categories: saleData.categories ?? [],
        address: saleData.address,
        city: saleData.city,
        state: saleData.state,
        zip: saleData.zip,
        sale_date: saleData.sale_date,
        start_time: saleData.start_time,
        end_time: saleData.end_time,
        seller_name: saleData.seller_name,
        seller_email: saleData.seller_email,
      });
    } catch {
      setError('Failed to load sale');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    if (!token) {
      setError('No manage token provided');
      setLoading(false);
      return;
    }
    fetchSale();
  }, [token, fetchSale]);

  const updateField = (field: string, value: unknown) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  const toggleCategory = (cat: string) => {
    const current = formData.categories ?? [];
    const updated = current.includes(cat)
      ? current.filter((c) => c !== cat)
      : [...current, cat];
    updateField('categories', updated);
  };

  const handleSave = async () => {
    setSaving(true);
    setError(null);
    setSuccess(null);

    try {
      const res = await fetch(`/api/sales/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...formData, manage_token: token }),
      });

      if (!res.ok) {
        const data = await res.json();
        throw new Error(data.error ?? 'Failed to update sale');
      }

      setSuccess('Your listing has been updated successfully.');
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Failed to update sale';
      setError(message);
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    setDeleting(true);
    setError(null);

    try {
      const res = await fetch(`/api/sales/${id}`, {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ manage_token: token }),
      });

      if (!res.ok) {
        const data = await res.json();
        throw new Error(data.error ?? 'Failed to delete sale');
      }

      router.push('/');
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Failed to delete sale';
      setError(message);
      setShowDeleteConfirm(false);
    } finally {
      setDeleting(false);
    }
  };

  if (loading) {
    return (
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-10 flex items-center justify-center min-h-[400px]">
        <Loader2 size={32} className="animate-spin text-treasure-600" />
      </div>
    );
  }

  if (!sale || !token) {
    return (
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        <div className="bg-red-50 text-red-700 px-6 py-4 rounded-lg flex items-center gap-3">
          <AlertTriangle size={20} />
          <span>{error ?? 'Unable to load this sale. Check your manage link.'}</span>
        </div>
        <Link href="/" className="btn-secondary inline-flex items-center gap-2 mt-6">
          <ArrowLeft size={16} />
          Back to Home
        </Link>
      </div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="flex items-center gap-3 mb-2">
        <Edit size={24} className="text-treasure-600" />
        <h1 className="font-display text-3xl font-bold text-gray-900">
          Manage Your Listing
        </h1>
      </div>
      <p className="text-gray-500 mb-8">
        Edit your sale details or remove the listing.
      </p>

      {error && (
        <div className="bg-red-50 text-red-700 px-4 py-3 rounded-lg text-sm mb-6 flex items-center gap-2">
          <AlertTriangle size={16} />
          {error}
        </div>
      )}

      {success && (
        <div className="bg-green-50 text-green-700 px-4 py-3 rounded-lg text-sm mb-6 flex items-center gap-2">
          <CheckCircle size={16} />
          {success}
        </div>
      )}

      <div className="space-y-8">
        {/* Basic Info */}
        <section className="space-y-4">
          <h2 className="font-semibold text-lg text-gray-900">Basic Info</h2>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Sale Title
            </label>
            <input
              className="input-field"
              value={formData.title ?? ''}
              onChange={(e) => updateField('title', e.target.value)}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <textarea
              rows={4}
              className="input-field"
              value={formData.description ?? ''}
              onChange={(e) => updateField('description', e.target.value)}
            />
          </div>
        </section>

        {/* Categories */}
        <section>
          <h2 className="font-semibold text-lg text-gray-900 mb-3">
            What Are You Selling?
          </h2>
          <div className="flex flex-wrap gap-2">
            {SALE_CATEGORIES.map((cat) => (
              <button
                key={cat}
                type="button"
                onClick={() => toggleCategory(cat)}
                className={`px-3 py-1.5 rounded-full text-sm font-medium border transition-all ${
                  formData.categories?.includes(cat)
                    ? 'bg-treasure-600 text-white border-treasure-600'
                    : 'bg-white text-gray-600 border-gray-300 hover:border-treasure-400'
                }`}
              >
                {cat}
              </button>
            ))}
          </div>
        </section>

        {/* Location */}
        <section className="space-y-4">
          <h2 className="font-semibold text-lg text-gray-900">Location</h2>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Street Address
            </label>
            <input
              className="input-field"
              value={formData.address ?? ''}
              onChange={(e) => updateField('address', e.target.value)}
            />
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                City
              </label>
              <input
                className="input-field"
                value={formData.city ?? ''}
                onChange={(e) => updateField('city', e.target.value)}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                State
              </label>
              <select
                className="input-field"
                value={formData.state ?? ''}
                onChange={(e) => updateField('state', e.target.value)}
              >
                <option value="">Select...</option>
                {Object.entries(US_STATES)
                  .sort(([, a], [, b]) => a.localeCompare(b))
                  .map(([code, name]) => (
                    <option key={code} value={code}>
                      {name}
                    </option>
                  ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                ZIP Code
              </label>
              <input
                className="input-field"
                value={formData.zip ?? ''}
                onChange={(e) => updateField('zip', e.target.value)}
              />
            </div>
          </div>
        </section>

        {/* Date & Time */}
        <section className="space-y-4">
          <h2 className="font-semibold text-lg text-gray-900">Date &amp; Time</h2>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Sale Date
              </label>
              <input
                type="date"
                className="input-field"
                value={formData.sale_date ?? ''}
                onChange={(e) => updateField('sale_date', e.target.value)}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Start Time
              </label>
              <input
                type="time"
                className="input-field"
                value={formData.start_time ?? ''}
                onChange={(e) => updateField('start_time', e.target.value)}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                End Time
              </label>
              <input
                type="time"
                className="input-field"
                value={formData.end_time ?? ''}
                onChange={(e) => updateField('end_time', e.target.value)}
              />
            </div>
          </div>
        </section>

        {/* Contact Info */}
        <section className="space-y-4">
          <h2 className="font-semibold text-lg text-gray-900">Your Info</h2>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Your Name
              </label>
              <input
                className="input-field"
                value={formData.seller_name ?? ''}
                onChange={(e) => updateField('seller_name', e.target.value)}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Email
              </label>
              <input
                type="email"
                className="input-field"
                value={formData.seller_email ?? ''}
                onChange={(e) => updateField('seller_email', e.target.value)}
              />
            </div>
          </div>
        </section>

        {/* Actions */}
        <div className="flex flex-col sm:flex-row gap-4 pt-4 border-t border-gray-200">
          <button
            onClick={handleSave}
            disabled={saving}
            className="btn-primary flex items-center justify-center gap-2 flex-1 disabled:opacity-50"
          >
            {saving ? (
              <>
                <Loader2 size={18} className="animate-spin" />
                Saving...
              </>
            ) : (
              <>
                <CheckCircle size={18} />
                Save Changes
              </>
            )}
          </button>

          <button
            onClick={() => setShowDeleteConfirm(true)}
            disabled={deleting}
            className="bg-red-600 hover:bg-red-700 text-white font-medium py-2.5 px-5 rounded-lg transition-colors duration-200 flex items-center justify-center gap-2 disabled:opacity-50"
          >
            <Trash2 size={18} />
            Delete Listing
          </button>
        </div>
      </div>

      {/* Delete confirmation dialog */}
      {showDeleteConfirm && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl p-6 max-w-md w-full space-y-4 shadow-xl">
            <div className="flex items-center gap-3 text-red-600">
              <AlertTriangle size={24} />
              <h3 className="font-display text-xl font-bold">Delete Listing?</h3>
            </div>
            <p className="text-gray-600">
              This action cannot be undone. Your listing for &ldquo;{sale.title}&rdquo; will
              be permanently removed.
            </p>
            <div className="flex gap-3 pt-2">
              <button
                onClick={() => setShowDeleteConfirm(false)}
                disabled={deleting}
                className="btn-secondary flex-1"
              >
                Cancel
              </button>
              <button
                onClick={handleDelete}
                disabled={deleting}
                className="bg-red-600 hover:bg-red-700 text-white font-medium py-2.5 px-5 rounded-lg transition-colors duration-200 flex items-center justify-center gap-2 flex-1 disabled:opacity-50"
              >
                {deleting ? (
                  <>
                    <Loader2 size={16} className="animate-spin" />
                    Deleting...
                  </>
                ) : (
                  <>
                    <Trash2 size={16} />
                    Yes, Delete
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
