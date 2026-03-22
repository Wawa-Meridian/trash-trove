'use client';

import { useState } from 'react';
import { useSearchParams } from 'next/navigation';
import { Bookmark, Loader2, Check } from 'lucide-react';
import { createSupabaseBrowser } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';

interface Props {
  state?: string;
  city?: string;
  className?: string;
}

export default function SaveSearchButton({ state, city, className }: Props) {
  const { user } = useAuth();
  const searchParams = useSearchParams();
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [showInput, setShowInput] = useState(false);
  const [name, setName] = useState('');

  if (!user) return null;

  const handleSave = async () => {
    if (!name.trim()) return;

    setSaving(true);
    const supabase = createSupabaseBrowser();

    const categories = searchParams.get('categories')?.split(',').filter(Boolean) ?? [];

    await supabase.from('saved_searches').insert({
      user_id: user.id,
      name: name.trim(),
      query: searchParams.get('q') || null,
      state: state || null,
      city: city || null,
      categories,
      date_from: searchParams.get('dateFrom') || null,
      date_to: searchParams.get('dateTo') || null,
      price_min: searchParams.get('priceMin') ? parseInt(searchParams.get('priceMin')!) : null,
      price_max: searchParams.get('priceMax') ? parseInt(searchParams.get('priceMax')!) : null,
    });

    setSaving(false);
    setSaved(true);
    setShowInput(false);
    setTimeout(() => setSaved(false), 3000);
  };

  if (saved) {
    return (
      <span className={`flex items-center gap-1.5 text-sm text-green-600 font-medium ${className ?? ''}`}>
        <Check size={16} />
        Saved!
      </span>
    );
  }

  if (showInput) {
    return (
      <div className={`flex items-center gap-2 ${className ?? ''}`}>
        <input
          type="text"
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="Name this search..."
          className="input-field text-sm py-1.5 w-48"
          autoFocus
          onKeyDown={(e) => e.key === 'Enter' && handleSave()}
        />
        <button
          onClick={handleSave}
          disabled={saving || !name.trim()}
          className="btn-primary text-xs px-3 py-1.5 disabled:opacity-50"
        >
          {saving ? <Loader2 size={14} className="animate-spin" /> : 'Save'}
        </button>
        <button
          onClick={() => setShowInput(false)}
          className="text-xs text-gray-500 hover:text-gray-700"
        >
          Cancel
        </button>
      </div>
    );
  }

  return (
    <button
      onClick={() => setShowInput(true)}
      className={`flex items-center gap-1.5 text-sm text-gray-500 hover:text-treasure-600 font-medium ${className ?? ''}`}
    >
      <Bookmark size={16} />
      Save Search
    </button>
  );
}
