import Link from 'next/link';
import { SearchX } from 'lucide-react';
import SaleCard from '@/components/SaleCard';
import { createSupabaseServer } from '@/lib/supabase-server';
import type { GarageSale } from '@/lib/types';
import { applyFilters, type FilterParams } from '@/lib/filters';
import SaleFilters from '@/components/SaleFilters';

interface SearchPageProps {
  searchParams: Promise<Record<string, string | undefined>>;
}

async function searchSales(query: string, filters: FilterParams = {}): Promise<GarageSale[]> {
  const supabase = await createSupabaseServer();
  const today = new Date().toISOString().split('T')[0];
  let dbQuery = supabase
    .from('garage_sales')
    .select('*, photos:sale_photos(*), sale_dates(*)')
    .eq('is_active', true)
    .gte('sale_date', filters.dateFrom ?? today)
    .textSearch('fts', query, { type: 'websearch' })
    .order('sale_date', { ascending: true })
    .limit(24);

  dbQuery = applyFilters(dbQuery, filters);

  const { data } = await dbQuery;
  return data ?? [];
}

export default async function SearchPage({ searchParams }: SearchPageProps) {
  const sp = await searchParams;
  const query = sp.q?.trim() ?? '';

  const filters: FilterParams = {
    categories: sp.categories,
    dateFrom: sp.dateFrom,
    dateTo: sp.dateTo,
    priceMin: sp.priceMin,
    priceMax: sp.priceMax,
    freeItems: sp.freeItems,
  };

  const results = query.length > 0 ? await searchSales(query, filters) : [];

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <h1 className="font-display text-3xl font-bold text-gray-900 dark:text-gray-100 mb-2">
        {query.length > 0
          ? `Results for "${query}"`
          : 'Search Garage Sales'}
      </h1>

      <SaleFilters basePath={`/browse/search${query ? `?q=${encodeURIComponent(query)}` : ''}`} className="mb-6" />

      {query.length > 0 && results.length > 0 && (
        <p className="text-gray-500 mb-8">
          {results.length} {results.length === 1 ? 'sale' : 'sales'} found
        </p>
      )}

      {query.length > 0 && results.length === 0 && (
        <div className="text-center py-16">
          <SearchX size={48} className="mx-auto text-gray-300 mb-4" />
          <h2 className="text-xl font-semibold text-gray-700 dark:text-gray-300 mb-2">
            No results found
          </h2>
          <p className="text-gray-500 mb-6">
            We couldn&apos;t find any garage sales matching &ldquo;{query}&rdquo;.
            Try a different search or browse all sales.
          </p>
          <Link
            href="/browse"
            className="btn-primary inline-flex items-center gap-2"
          >
            Browse All Sales
          </Link>
        </div>
      )}

      {query.length === 0 && (
        <p className="text-gray-500 mb-8">
          Enter a search term to find garage sales.
        </p>
      )}

      {results.length > 0 && (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {results.map((sale) => (
            <SaleCard key={sale.id} sale={sale} />
          ))}
        </div>
      )}
    </div>
  );
}
