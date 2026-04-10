import type { Metadata } from 'next';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { ChevronRight } from 'lucide-react';
import SaleCard from '@/components/SaleCard';
import SaleMap from '@/components/SaleMap';
import { createSupabaseServer } from '@/lib/supabase-server';
import { US_STATES } from '@/lib/types';
import { applyFilters, type FilterParams } from '@/lib/filters';
import SaleFilters from '@/components/SaleFilters';

interface Props {
  params: Promise<{ state: string; city: string }>;
  searchParams: Promise<Record<string, string | undefined>>;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { state, city: rawCity } = await params;
  const stateCode = state.toUpperCase();
  const city = decodeURIComponent(rawCity);
  const stateName = US_STATES[stateCode];

  if (!stateName) return {};

  return {
    title: `Garage Sales in ${city}, ${stateName}`,
    description: `Find upcoming garage sales in ${city}, ${stateName}. Browse yard sales, estate sales, and moving sales listed on TrashTrove.`,
  };
}

async function getSalesInCity(state: string, city: string, filters: FilterParams = {}) {
  const supabase = await createSupabaseServer();
  const today = new Date().toISOString().split('T')[0];
  let query = supabase
    .from('garage_sales')
    .select('*, photos:sale_photos(*), sale_dates(*)')
    .eq('state', state)
    .ilike('city', city)
    .eq('is_active', true)
    .gte('sale_date', filters.dateFrom ?? today)
    .order('sale_date', { ascending: true });

  query = applyFilters(query, filters);

  const { data } = await query;
  return data ?? [];
}

export default async function CityPage({ params, searchParams }: Props) {
  const { state, city: rawCity } = await params;
  const sp = await searchParams;
  const stateCode = state.toUpperCase();
  const city = decodeURIComponent(rawCity);
  const stateName = US_STATES[stateCode];

  if (!stateName) notFound();

  const filters: FilterParams = {
    categories: sp.categories,
    dateFrom: sp.dateFrom,
    dateTo: sp.dateTo,
    priceMin: sp.priceMin,
    priceMax: sp.priceMax,
    freeItems: sp.freeItems,
  };

  const sales = await getSalesInCity(stateCode, city, filters);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      {/* Breadcrumb */}
      <nav className="flex items-center gap-1.5 text-sm text-gray-500 mb-6">
        <Link href="/browse" className="hover:text-treasure-600">
          Browse
        </Link>
        <ChevronRight size={14} />
        <Link href={`/browse/${stateCode}`} className="hover:text-treasure-600">
          {stateName}
        </Link>
        <ChevronRight size={14} />
        <span className="text-gray-900 font-medium">{city}</span>
      </nav>

      <h1 className="font-display text-3xl font-bold text-gray-900 dark:text-gray-100 mb-2">
        Garage Sales in {city}, {stateCode}
      </h1>
      <p className="text-gray-500 mb-8">
        {sales.length} upcoming sale{sales.length !== 1 ? 's' : ''}
      </p>

      <SaleFilters basePath={`/browse/${stateCode}/${encodeURIComponent(city)}`} className="mb-6" />

      {/* Map */}
      {sales.length > 0 && (
        <div className="card overflow-hidden mb-8">
          <SaleMap sales={sales} zoom={12} className="h-[400px]" />
        </div>
      )}

      {sales.length > 0 ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {sales.map((sale: any) => (
            <SaleCard key={sale.id} sale={sale} />
          ))}
        </div>
      ) : (
        <div className="text-center py-16">
          <p className="text-gray-400 text-lg">
            No upcoming sales in {city}, {stateCode} yet.
          </p>
          <Link href="/create" className="btn-primary inline-block mt-4">
            Be the first to list a sale!
          </Link>
        </div>
      )}
    </div>
  );
}
