'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { Heart, MapPin } from 'lucide-react';
import SaleCard from '@/components/SaleCard';
import type { GarageSale } from '@/lib/types';

const STORAGE_KEY = 'trashtrove_favorites';

function getFavorites(): string[] {
  if (typeof window === 'undefined') return [];
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    return stored ? JSON.parse(stored) : [];
  } catch {
    return [];
  }
}

export default function FavoritesPage() {
  const [sales, setSales] = useState<GarageSale[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchFavorites() {
      const favoriteIds = getFavorites();

      if (favoriteIds.length === 0) {
        setLoading(false);
        return;
      }

      try {
        // Batch fetch by requesting all IDs via query params
        const params = new URLSearchParams();
        favoriteIds.forEach((id) => params.append('ids', id));

        const res = await fetch(`/api/sales?${params.toString()}`);
        const data = await res.json();

        setSales(data.sales ?? []);
      } catch {
        setSales([]);
      } finally {
        setLoading(false);
      }
    }

    fetchFavorites();
  }, []);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="flex items-center gap-3 mb-8">
        <Heart size={28} className="text-red-500 fill-red-500" />
        <h1 className="font-display text-3xl font-bold text-gray-900">
          Your Favorites
        </h1>
      </div>

      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {[1, 2, 3].map((i) => (
            <div key={i} className="card animate-pulse">
              <div className="aspect-[4/3] bg-gray-200" />
              <div className="p-4 space-y-3">
                <div className="h-5 bg-gray-200 rounded w-3/4" />
                <div className="h-4 bg-gray-200 rounded w-1/2" />
                <div className="h-4 bg-gray-200 rounded w-2/3" />
              </div>
            </div>
          ))}
        </div>
      ) : sales.length > 0 ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {sales.map((sale) => (
            <SaleCard key={sale.id} sale={sale} />
          ))}
        </div>
      ) : (
        <div className="text-center py-20">
          <Heart size={48} className="mx-auto text-gray-300 mb-4" />
          <h2 className="font-display text-xl font-semibold text-gray-700 mb-2">
            No favorites yet
          </h2>
          <p className="text-gray-500 mb-6">
            Browse sales and tap the heart to save them.
          </p>
          <Link href="/browse" className="btn-primary inline-flex items-center gap-2">
            <MapPin size={18} />
            Browse Sales
          </Link>
        </div>
      )}
    </div>
  );
}
