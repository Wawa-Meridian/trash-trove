'use client';

import { useState, useCallback } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Filter, X, ChevronDown, ChevronUp } from 'lucide-react';
import { SALE_CATEGORIES } from '@/lib/types';

interface Props {
  basePath: string;
  className?: string;
}

export default function SaleFilters({ basePath, className }: Props) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [expanded, setExpanded] = useState(false);

  const selectedCategories = searchParams.get('categories')?.split(',').filter(Boolean) ?? [];
  const dateFrom = searchParams.get('dateFrom') ?? '';
  const dateTo = searchParams.get('dateTo') ?? '';
  const priceMin = searchParams.get('priceMin') ?? '';
  const priceMax = searchParams.get('priceMax') ?? '';
  const freeItems = searchParams.get('freeItems') === 'true';

  const hasActiveFilters =
    selectedCategories.length > 0 || dateFrom || dateTo || priceMin || priceMax || freeItems;

  const updateFilters = useCallback(
    (updates: Record<string, string | null>) => {
      const params = new URLSearchParams(searchParams.toString());
      for (const [key, value] of Object.entries(updates)) {
        if (value === null || value === '') {
          params.delete(key);
        } else {
          params.set(key, value);
        }
      }
      const qs = params.toString();
      router.push(`${basePath}${qs ? `?${qs}` : ''}`);
    },
    [router, searchParams, basePath]
  );

  const toggleCategory = (cat: string) => {
    const current = new Set(selectedCategories);
    if (current.has(cat)) {
      current.delete(cat);
    } else {
      current.add(cat);
    }
    const value = Array.from(current).join(',');
    updateFilters({ categories: value || null });
  };

  const clearAll = () => {
    updateFilters({
      categories: null,
      dateFrom: null,
      dateTo: null,
      priceMin: null,
      priceMax: null,
      freeItems: null,
    });
  };

  return (
    <div className={`bg-white rounded-xl border border-gray-200 ${className ?? ''}`}>
      {/* Toggle bar */}
      <button
        onClick={() => setExpanded(!expanded)}
        className="w-full flex items-center justify-between px-4 py-3"
      >
        <span className="flex items-center gap-2 text-sm font-medium text-gray-700">
          <Filter size={16} />
          Filters
          {hasActiveFilters && (
            <span className="bg-treasure-600 text-white text-xs px-2 py-0.5 rounded-full">
              Active
            </span>
          )}
        </span>
        {expanded ? <ChevronUp size={16} className="text-gray-400" /> : <ChevronDown size={16} className="text-gray-400" />}
      </button>

      {expanded && (
        <div className="px-4 pb-4 space-y-5 border-t border-gray-100 pt-4">
          {/* Categories */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Categories
            </label>
            <div className="flex flex-wrap gap-2">
              {SALE_CATEGORIES.map((cat) => (
                <button
                  key={cat}
                  onClick={() => toggleCategory(cat)}
                  className={`px-3 py-1 rounded-full text-xs font-medium border transition-all ${
                    selectedCategories.includes(cat)
                      ? 'bg-treasure-600 text-white border-treasure-600'
                      : 'bg-white text-gray-600 border-gray-300 hover:border-treasure-400'
                  }`}
                >
                  {cat}
                </button>
              ))}
            </div>
          </div>

          {/* Date range */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Date Range
            </label>
            <div className="flex items-center gap-2">
              <input
                type="date"
                value={dateFrom}
                onChange={(e) => updateFilters({ dateFrom: e.target.value || null })}
                className="input-field text-sm flex-1"
                placeholder="From"
              />
              <span className="text-gray-400 text-sm">to</span>
              <input
                type="date"
                value={dateTo}
                onChange={(e) => updateFilters({ dateTo: e.target.value || null })}
                className="input-field text-sm flex-1"
                placeholder="To"
              />
            </div>
          </div>

          {/* Price range */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Price Range
            </label>
            <div className="flex items-center gap-2">
              <div className="relative flex-1">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">$</span>
                <input
                  type="number"
                  min="0"
                  value={priceMin}
                  onChange={(e) => updateFilters({ priceMin: e.target.value || null })}
                  className="input-field text-sm pl-7"
                  placeholder="Min"
                />
              </div>
              <span className="text-gray-400 text-sm">to</span>
              <div className="relative flex-1">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">$</span>
                <input
                  type="number"
                  min="0"
                  value={priceMax}
                  onChange={(e) => updateFilters({ priceMax: e.target.value || null })}
                  className="input-field text-sm pl-7"
                  placeholder="Max"
                />
              </div>
            </div>
            <label className="flex items-center gap-2 mt-2 cursor-pointer">
              <input
                type="checkbox"
                checked={freeItems}
                onChange={(e) => updateFilters({ freeItems: e.target.checked ? 'true' : null })}
                className="rounded border-gray-300 text-treasure-600 focus:ring-treasure-500"
              />
              <span className="text-sm text-gray-600">Has free items</span>
            </label>
          </div>

          {/* Clear all */}
          {hasActiveFilters && (
            <button
              onClick={clearAll}
              className="flex items-center gap-1.5 text-sm text-red-600 hover:text-red-700"
            >
              <X size={14} />
              Clear all filters
            </button>
          )}
        </div>
      )}
    </div>
  );
}
