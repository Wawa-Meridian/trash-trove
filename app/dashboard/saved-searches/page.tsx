'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { Loader2, Search, Trash2, Bell, BellOff } from 'lucide-react';
import { createSupabaseBrowser } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';

interface SavedSearch {
  id: string;
  name: string;
  query: string | null;
  state: string | null;
  city: string | null;
  categories: string[];
  date_from: string | null;
  date_to: string | null;
  price_min: number | null;
  price_max: number | null;
  notify_email: boolean;
  created_at: string;
}

export default function SavedSearchesPage() {
  const { user } = useAuth();
  const [searches, setSearches] = useState<SavedSearch[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) return;

    const fetchSearches = async () => {
      const supabase = createSupabaseBrowser();
      const { data } = await supabase
        .from('saved_searches')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false });

      setSearches(data ?? []);
      setLoading(false);
    };

    fetchSearches();
  }, [user]);

  const toggleNotify = async (id: string, currentValue: boolean) => {
    const supabase = createSupabaseBrowser();
    await supabase
      .from('saved_searches')
      .update({ notify_email: !currentValue })
      .eq('id', id);

    setSearches((prev) =>
      prev.map((s) =>
        s.id === id ? { ...s, notify_email: !currentValue } : s
      )
    );
  };

  const deleteSearch = async (id: string) => {
    const supabase = createSupabaseBrowser();
    await supabase.from('saved_searches').delete().eq('id', id);
    setSearches((prev) => prev.filter((s) => s.id !== id));
  };

  const buildSearchUrl = (s: SavedSearch): string => {
    const params = new URLSearchParams();
    if (s.query) params.set('q', s.query);
    if (s.categories?.length > 0) params.set('categories', s.categories.join(','));
    if (s.date_from) params.set('dateFrom', s.date_from);
    if (s.date_to) params.set('dateTo', s.date_to);
    if (s.price_min != null) params.set('priceMin', String(s.price_min));
    if (s.price_max != null) params.set('priceMax', String(s.price_max));

    const qs = params.toString();

    if (s.state && s.city) return `/browse/${s.state}/${encodeURIComponent(s.city)}${qs ? `?${qs}` : ''}`;
    if (s.state) return `/browse/${s.state}${qs ? `?${qs}` : ''}`;
    if (s.query) return `/browse/search?${qs}`;
    return `/browse${qs ? `?${qs}` : ''}`;
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[200px]">
        <Loader2 size={24} className="animate-spin text-treasure-600" />
      </div>
    );
  }

  return (
    <div>
      <h2 className="font-display text-xl font-bold text-gray-900 mb-6">
        Saved Searches
      </h2>

      {searches.length === 0 ? (
        <div className="text-center py-16 bg-white rounded-xl border border-gray-200">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-treasure-50 rounded-full">
            <Search size={28} className="text-treasure-600" />
          </div>
          <h3 className="font-semibold text-gray-700 mt-4">No saved searches</h3>
          <p className="text-gray-500 mt-1 text-sm">
            Save a search from any browse page to quickly run it again later.
          </p>
        </div>
      ) : (
        <div className="space-y-3">
          {searches.map((search) => (
            <div
              key={search.id}
              className="bg-white rounded-xl border border-gray-200 p-4 flex items-center gap-3"
            >
              <div className="flex-1 min-w-0">
                <div className="font-semibold text-gray-900 text-sm">{search.name}</div>
                <div className="flex flex-wrap gap-1.5 mt-1.5">
                  {search.query && (
                    <span className="badge bg-blue-100 text-blue-800">"{search.query}"</span>
                  )}
                  {search.state && (
                    <span className="badge bg-treasure-100 text-treasure-800">{search.state}</span>
                  )}
                  {search.city && (
                    <span className="badge bg-treasure-100 text-treasure-800">{search.city}</span>
                  )}
                  {search.categories?.map((c) => (
                    <span key={c} className="badge bg-gray-100 text-gray-700">{c}</span>
                  ))}
                </div>
              </div>

              <div className="flex items-center gap-2 flex-shrink-0">
                <button
                  onClick={() => toggleNotify(search.id, search.notify_email)}
                  className={`p-2 rounded-lg transition-colors ${
                    search.notify_email
                      ? 'text-treasure-600 bg-treasure-50'
                      : 'text-gray-400 hover:bg-gray-100'
                  }`}
                  title={search.notify_email ? 'Alerts on' : 'Alerts off'}
                >
                  {search.notify_email ? <Bell size={16} /> : <BellOff size={16} />}
                </button>
                <Link
                  href={buildSearchUrl(search)}
                  className="btn-primary text-xs px-3 py-1.5"
                >
                  Run
                </Link>
                <button
                  onClick={() => deleteSearch(search.id)}
                  className="p-2 rounded-lg text-gray-400 hover:bg-red-50 hover:text-red-600"
                >
                  <Trash2 size={16} />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
