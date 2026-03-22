'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useDropzone } from 'react-dropzone';
import { Upload, X, Loader2, CheckCircle, Link as LinkIcon, Plus, Trash2 } from 'lucide-react';
import { SALE_CATEGORIES, US_STATES } from '@/lib/types';
import { useAuth } from '@/components/AuthProvider';

const saleSchema = z.object({
  title: z.string().min(3, 'Title must be at least 3 characters'),
  description: z.string().min(10, 'Description must be at least 10 characters'),
  categories: z.array(z.string()).min(1, 'Select at least one category'),
  address: z.string().min(5, 'Enter a valid address'),
  city: z.string().min(2, 'Enter a city'),
  state: z.string().length(2, 'Select a state'),
  zip: z.string().regex(/^\d{5}(-\d{4})?$/, 'Enter a valid ZIP code'),
  seller_name: z.string().min(2, 'Enter your name'),
  seller_email: z.string().email('Enter a valid email'),
});

type SaleFormData = z.infer<typeof saleSchema>;

interface SaleDateRow {
  date: string;
  start_time: string;
  end_time: string;
}

// Get next Saturday as default date
function getNextWeekendDate() {
  const d = new Date();
  const day = d.getDay();
  const daysUntilSat = (6 - day + 7) % 7 || 7;
  d.setDate(d.getDate() + daysUntilSat);
  return d.toISOString().split('T')[0];
}

export default function CreateSalePage() {
  const router = useRouter();
  const { user } = useAuth();
  const [photos, setPhotos] = useState<File[]>([]);
  const [previews, setPreviews] = useState<string[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [manageUrl, setManageUrl] = useState<string | null>(null);
  const [createdId, setCreatedId] = useState<string | null>(null);

  // Multi-day dates
  const [saleDates, setSaleDates] = useState<SaleDateRow[]>([
    { date: getNextWeekendDate(), start_time: '08:00', end_time: '14:00' },
  ]);

  // Price range
  const [priceMin, setPriceMin] = useState('');
  const [priceMax, setPriceMax] = useState('');
  const [hasFreeItems, setHasFreeItems] = useState(false);

  const {
    register,
    handleSubmit,
    setValue,
    watch,
    formState: { errors },
  } = useForm<SaleFormData>({
    resolver: zodResolver(saleSchema),
    defaultValues: {
      categories: [],
      seller_name: user?.user_metadata?.full_name ?? '',
      seller_email: user?.email ?? '',
    },
  });

  const selectedCategories = watch('categories');

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    accept: { 'image/*': ['.jpg', '.jpeg', '.png', '.webp'] },
    maxFiles: 10,
    maxSize: 5 * 1024 * 1024,
    onDrop: (accepted) => {
      const newPhotos = [...photos, ...accepted].slice(0, 10);
      setPhotos(newPhotos);
      setPreviews(newPhotos.map((f) => URL.createObjectURL(f)));
    },
  });

  const removePhoto = (index: number) => {
    URL.revokeObjectURL(previews[index]);
    setPhotos((p) => p.filter((_, i) => i !== index));
    setPreviews((p) => p.filter((_, i) => i !== index));
  };

  const toggleCategory = (cat: string) => {
    const current = selectedCategories ?? [];
    const updated = current.includes(cat)
      ? current.filter((c) => c !== cat)
      : [...current, cat];
    setValue('categories', updated, { shouldValidate: true });
  };

  // Multi-day date handlers
  const addDateRow = () => {
    if (saleDates.length >= 7) return;
    const lastDate = saleDates[saleDates.length - 1];
    const nextDay = new Date(lastDate.date);
    nextDay.setDate(nextDay.getDate() + 1);
    setSaleDates([
      ...saleDates,
      {
        date: nextDay.toISOString().split('T')[0],
        start_time: lastDate.start_time,
        end_time: lastDate.end_time,
      },
    ]);
  };

  const removeDateRow = (index: number) => {
    if (saleDates.length <= 1) return;
    setSaleDates(saleDates.filter((_, i) => i !== index));
  };

  const updateDateRow = (index: number, field: keyof SaleDateRow, value: string) => {
    setSaleDates(
      saleDates.map((row, i) => (i === index ? { ...row, [field]: value } : row))
    );
  };

  const onSubmit = async (data: SaleFormData) => {
    // Validate dates
    if (saleDates.some((d) => !d.date)) {
      setError('All sale dates must be filled in');
      return;
    }

    setIsSubmitting(true);
    setError(null);

    try {
      // Upload photos
      const photoUrls: string[] = [];
      for (const photo of photos) {
        const formData = new FormData();
        formData.append('file', photo);
        const res = await fetch('/api/upload', { method: 'POST', body: formData });
        if (!res.ok) throw new Error('Failed to upload photo');
        const { url } = await res.json();
        photoUrls.push(url);
      }

      // Create the sale
      const res = await fetch('/api/sales', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ...data,
          sale_dates: saleDates,
          photoUrls,
          ...(priceMin ? { price_min: parseFloat(priceMin) } : {}),
          ...(priceMax ? { price_max: parseFloat(priceMax) } : {}),
          has_free_items: hasFreeItems,
        }),
      });

      if (!res.ok) {
        const err = await res.json();
        throw new Error(err.error ?? 'Failed to create sale');
      }

      const { id, manage_token } = await res.json();

      if (user) {
        // Authenticated user — go straight to dashboard
        router.push(`/sale/${id}`);
      } else if (manage_token) {
        localStorage.setItem(`trashtrove_manage_${id}`, manage_token);
        setManageUrl(`${window.location.origin}/sale/${id}/manage?token=${manage_token}`);
        setCreatedId(id);
      } else {
        router.push(`/sale/${id}`);
      }
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Failed to create sale';
      setError(message);
    } finally {
      setIsSubmitting(false);
    }
  };

  const today = new Date().toISOString().split('T')[0];

  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <h1 className="font-display text-3xl font-bold text-gray-900 dark:text-gray-100 mb-2">
        List Your Garage Sale
      </h1>
      <p className="text-gray-500 dark:text-gray-400 mb-8">
        Share your sale details and let shoppers know what treasures you have.
      </p>

      {manageUrl && createdId && (
        <div className="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-xl p-6 mb-8 space-y-4">
          <div className="flex items-center gap-2 text-green-800 dark:text-green-300 font-semibold text-lg">
            <CheckCircle size={22} />
            Your sale has been listed!
          </div>
          <p className="text-green-700 dark:text-green-400 text-sm">
            Save this link to manage your listing. You can use it to edit or delete your sale later.
            This is the only way to manage your listing, so keep it safe.
          </p>
          <div className="flex items-center gap-2">
            <div className="flex-1 bg-white dark:bg-gray-800 border border-green-300 dark:border-green-700 rounded-lg px-3 py-2 text-sm text-gray-700 dark:text-gray-300 truncate">
              <LinkIcon size={14} className="inline mr-2 text-green-600" />
              {manageUrl}
            </div>
            <button
              type="button"
              onClick={() => navigator.clipboard.writeText(manageUrl)}
              className="btn-secondary text-sm whitespace-nowrap"
            >
              Copy Link
            </button>
          </div>
          <a
            href={`/sale/${createdId}`}
            className="btn-primary inline-flex items-center gap-2 text-sm"
          >
            View Your Listing
          </a>
        </div>
      )}

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-8">
        {/* Basic Info */}
        <section className="space-y-4">
          <h2 className="font-semibold text-lg text-gray-900 dark:text-gray-100">Basic Info</h2>

          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Sale Title
            </label>
            <input
              {...register('title')}
              className="input-field"
              placeholder="e.g. Big Moving Sale - Everything Must Go!"
            />
            {errors.title && (
              <p className="text-red-500 text-sm mt-1">{errors.title.message}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Description
            </label>
            <textarea
              {...register('description')}
              rows={4}
              className="input-field"
              placeholder="Describe what kinds of items you're selling, any highlights, pricing info, etc."
            />
            {errors.description && (
              <p className="text-red-500 text-sm mt-1">
                {errors.description.message}
              </p>
            )}
          </div>
        </section>

        {/* Categories */}
        <section>
          <h2 className="font-semibold text-lg text-gray-900 dark:text-gray-100 mb-3">
            What Are You Selling?
          </h2>
          <div className="flex flex-wrap gap-2">
            {SALE_CATEGORIES.map((cat) => (
              <button
                key={cat}
                type="button"
                onClick={() => toggleCategory(cat)}
                className={`px-3 py-1.5 rounded-full text-sm font-medium border transition-all ${
                  selectedCategories?.includes(cat)
                    ? 'bg-treasure-600 text-white border-treasure-600'
                    : 'bg-white dark:bg-gray-800 text-gray-600 dark:text-gray-300 border-gray-300 dark:border-gray-600 hover:border-treasure-400'
                }`}
              >
                {cat}
              </button>
            ))}
          </div>
          {errors.categories && (
            <p className="text-red-500 text-sm mt-2">
              {errors.categories.message}
            </p>
          )}
        </section>

        {/* Photos */}
        <section>
          <h2 className="font-semibold text-lg text-gray-900 dark:text-gray-100 mb-3">
            Photos <span className="text-gray-400 font-normal">(up to 10)</span>
          </h2>

          <div
            {...getRootProps()}
            className={`border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition-colors ${
              isDragActive
                ? 'border-treasure-500 bg-treasure-50 dark:bg-treasure-900/20'
                : 'border-gray-300 dark:border-gray-600 hover:border-treasure-400'
            }`}
          >
            <input {...getInputProps()} />
            <Upload size={32} className="mx-auto text-gray-400 mb-2" />
            <p className="text-gray-500 dark:text-gray-400">
              Drag &amp; drop photos here, or click to select
            </p>
            <p className="text-gray-400 text-sm mt-1">
              JPG, PNG, or WebP up to 5MB each
            </p>
          </div>

          {previews.length > 0 && (
            <div className="grid grid-cols-3 sm:grid-cols-5 gap-3 mt-4">
              {previews.map((src, i) => (
                <div key={i} className="relative aspect-square rounded-lg overflow-hidden group">
                  <img
                    src={src}
                    alt={`Preview ${i + 1}`}
                    className="w-full h-full object-cover"
                  />
                  <button
                    type="button"
                    onClick={() => removePhoto(i)}
                    className="absolute top-1 right-1 bg-red-500 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
                    aria-label="Remove photo"
                  >
                    <X size={14} />
                  </button>
                </div>
              ))}
            </div>
          )}
        </section>

        {/* Location */}
        <section className="space-y-4">
          <h2 className="font-semibold text-lg text-gray-900 dark:text-gray-100">Location</h2>

          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Street Address
            </label>
            <input
              {...register('address')}
              className="input-field"
              placeholder="123 Main St"
            />
            {errors.address && (
              <p className="text-red-500 text-sm mt-1">{errors.address.message}</p>
            )}
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                City
              </label>
              <input
                {...register('city')}
                className="input-field"
                placeholder="Springfield"
              />
              {errors.city && (
                <p className="text-red-500 text-sm mt-1">{errors.city.message}</p>
              )}
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                State
              </label>
              <select {...register('state')} className="input-field">
                <option value="">Select...</option>
                {Object.entries(US_STATES)
                  .sort(([, a], [, b]) => a.localeCompare(b))
                  .map(([code, name]) => (
                    <option key={code} value={code}>
                      {name}
                    </option>
                  ))}
              </select>
              {errors.state && (
                <p className="text-red-500 text-sm mt-1">{errors.state.message}</p>
              )}
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                ZIP Code
              </label>
              <input
                {...register('zip')}
                className="input-field"
                placeholder="12345"
              />
              {errors.zip && (
                <p className="text-red-500 text-sm mt-1">{errors.zip.message}</p>
              )}
            </div>
          </div>
        </section>

        {/* Date & Time — Multi-day */}
        <section className="space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="font-semibold text-lg text-gray-900 dark:text-gray-100">
              Date &amp; Time
            </h2>
            {saleDates.length < 7 && (
              <button
                type="button"
                onClick={addDateRow}
                className="text-sm text-treasure-600 hover:text-treasure-700 font-medium flex items-center gap-1"
              >
                <Plus size={14} />
                Add another day
              </button>
            )}
          </div>

          <div className="space-y-3">
            {saleDates.map((row, i) => (
              <div key={i} className="flex items-end gap-3">
                <div className="flex-1">
                  {i === 0 && (
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                      Date
                    </label>
                  )}
                  <input
                    type="date"
                    value={row.date}
                    min={today}
                    onChange={(e) => updateDateRow(i, 'date', e.target.value)}
                    className="input-field"
                    required
                  />
                </div>
                <div className="w-28">
                  {i === 0 && (
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                      Start
                    </label>
                  )}
                  <input
                    type="time"
                    value={row.start_time}
                    onChange={(e) => updateDateRow(i, 'start_time', e.target.value)}
                    className="input-field"
                    required
                  />
                </div>
                <div className="w-28">
                  {i === 0 && (
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                      End
                    </label>
                  )}
                  <input
                    type="time"
                    value={row.end_time}
                    onChange={(e) => updateDateRow(i, 'end_time', e.target.value)}
                    className="input-field"
                    required
                  />
                </div>
                {saleDates.length > 1 && (
                  <button
                    type="button"
                    onClick={() => removeDateRow(i)}
                    className="p-2.5 text-gray-400 hover:text-red-500 transition-colors"
                    aria-label="Remove this date"
                  >
                    <Trash2 size={16} />
                  </button>
                )}
              </div>
            ))}
          </div>

          {saleDates.length > 1 && (
            <p className="text-xs text-gray-500 dark:text-gray-400">
              Multi-day sale! Each day can have different hours.
            </p>
          )}
        </section>

        {/* Price Range (optional) */}
        <section className="space-y-4">
          <h2 className="font-semibold text-lg text-gray-900 dark:text-gray-100">
            Price Range <span className="text-gray-400 font-normal">(optional)</span>
          </h2>

          <div className="flex items-center gap-3">
            <div className="relative flex-1">
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">$</span>
              <input
                type="number"
                min="0"
                step="1"
                value={priceMin}
                onChange={(e) => setPriceMin(e.target.value)}
                className="input-field pl-7"
                placeholder="Min price"
              />
            </div>
            <span className="text-gray-400">to</span>
            <div className="relative flex-1">
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">$</span>
              <input
                type="number"
                min="0"
                step="1"
                value={priceMax}
                onChange={(e) => setPriceMax(e.target.value)}
                className="input-field pl-7"
                placeholder="Max price"
              />
            </div>
          </div>

          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="checkbox"
              checked={hasFreeItems}
              onChange={(e) => setHasFreeItems(e.target.checked)}
              className="rounded border-gray-300 text-treasure-600 focus:ring-treasure-500"
            />
            <span className="text-sm text-gray-600 dark:text-gray-400">
              Some items are free
            </span>
          </label>
        </section>

        {/* Contact Info */}
        <section className="space-y-4">
          <h2 className="font-semibold text-lg text-gray-900 dark:text-gray-100">Your Info</h2>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Your Name
              </label>
              <input
                {...register('seller_name')}
                className="input-field"
                placeholder="Jane Smith"
              />
              {errors.seller_name && (
                <p className="text-red-500 text-sm mt-1">
                  {errors.seller_name.message}
                </p>
              )}
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Email
              </label>
              <input
                type="email"
                {...register('seller_email')}
                className="input-field"
                placeholder="jane@example.com"
              />
              {errors.seller_email && (
                <p className="text-red-500 text-sm mt-1">
                  {errors.seller_email.message}
                </p>
              )}
            </div>
          </div>
        </section>

        {/* Submit */}
        {error && (
          <div className="bg-red-50 dark:bg-red-900/20 text-red-700 dark:text-red-400 px-4 py-3 rounded-lg text-sm">
            {error}
          </div>
        )}

        <button
          type="submit"
          disabled={isSubmitting}
          className="btn-primary w-full flex items-center justify-center gap-2 text-lg py-3 disabled:opacity-50"
        >
          {isSubmitting ? (
            <>
              <Loader2 size={20} className="animate-spin" />
              Creating Your Sale...
            </>
          ) : (
            <>
              <CheckCircle size={20} />
              List My Garage Sale
            </>
          )}
        </button>
      </form>
    </div>
  );
}
