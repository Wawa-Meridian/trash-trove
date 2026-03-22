import Link from 'next/link';
import { SearchX } from 'lucide-react';
import SaleCard from '@/components/SaleCard';
import { supabase } from '@/lib/supabase';
import type { GarageSale } from '@/lib/types';

interface SearchPageProps {
  searchParams: Promise<{ q?: string }>;
}

async function searchSales(query: string): Promise<GarageSale[]> {
  const { data } = await supabase
    .from('garage_sales')
    .select('*, photos:sale_photos(*)')
    .eq('is_active', true)
    .textSearch('fts', query, { type: 'websearch' })
    .order('sale_date', { ascending: true })
    .limit(24);

  return data ?? [];
}

export default async function SearchPage({ searchParams }: SearchPageProps) {
  const { q } = await searchParams;
  const query = q?.trim() ?? '';
  const results = query.length > 0 ? await searchSales(query) : [];

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <h1 className="font-display text-3xl font-bold text-gray-900 mb-2">
        {query.length > 0
          ? `Results for "${query}"`
          : 'Search Garage Sales'}
      </h1>

      {query.length > 0 && results.length > 0 && (
        <p className="text-gray-500 mb-8">
          {results.length} {results.length === 1 ? 'sale' : 'sales'} found
        </p>
      )}

      {query.length > 0 && results.length === 0 && (
        <div className="text-center py-16">
          <SearchX size={48} className="mx-auto text-gray-300 mb-4" />
          <h2 className="text-xl font-semibold text-gray-700 mb-2">
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
