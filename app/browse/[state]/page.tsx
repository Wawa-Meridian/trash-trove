import Link from 'next/link';
import { notFound } from 'next/navigation';
import { ChevronRight } from 'lucide-react';
import SaleCard from '@/components/SaleCard';
import { supabase } from '@/lib/supabase';
import { US_STATES } from '@/lib/types';

interface Props {
  params: Promise<{ state: string }>;
}

async function getCitiesInState(state: string) {
  const today = new Date().toISOString().split('T')[0];
  const { data } = await supabase
    .from('garage_sales')
    .select('city')
    .eq('state', state)
    .eq('is_active', true)
    .gte('sale_date', today);

  if (!data) return [];
  // Count sales per city
  const cityMap = new Map<string, number>();
  for (const row of data) {
    cityMap.set(row.city, (cityMap.get(row.city) ?? 0) + 1);
  }
  return Array.from(cityMap.entries())
    .map(([city, count]) => ({ city, count }))
    .sort((a, b) => a.city.localeCompare(b.city));
}

async function getSalesInState(state: string) {
  const today = new Date().toISOString().split('T')[0];
  const { data } = await supabase
    .from('garage_sales')
    .select('*, photos:sale_photos(*)')
    .eq('state', state)
    .eq('is_active', true)
    .gte('sale_date', today)
    .order('sale_date', { ascending: true })
    .limit(12);
  return data ?? [];
}

export default async function StatePage({ params }: Props) {
  const { state } = await params;
  const stateCode = state.toUpperCase();
  const stateName = US_STATES[stateCode];

  if (!stateName) notFound();

  const [cities, sales] = await Promise.all([
    getCitiesInState(stateCode),
    getSalesInState(stateCode),
  ]);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      {/* Breadcrumb */}
      <nav className="flex items-center gap-1.5 text-sm text-gray-500 mb-6">
        <Link href="/browse" className="hover:text-treasure-600">
          Browse
        </Link>
        <ChevronRight size={14} />
        <span className="text-gray-900 font-medium">{stateName}</span>
      </nav>

      <h1 className="font-display text-3xl font-bold text-gray-900 mb-2">
        Garage Sales in {stateName}
      </h1>
      <p className="text-gray-500 mb-8">
        {sales.length} upcoming sale{sales.length !== 1 ? 's' : ''} across{' '}
        {cities.length} cit{cities.length !== 1 ? 'ies' : 'y'}
      </p>

      {/* Cities */}
      {cities.length > 0 && (
        <div className="mb-10">
          <h2 className="font-semibold text-lg text-gray-900 mb-4">Cities</h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-3">
            {cities.map(({ city, count }) => (
              <Link
                key={city}
                href={`/browse/${stateCode}/${encodeURIComponent(city)}`}
                className="flex items-center justify-between p-3 rounded-lg border border-gray-200 hover:border-treasure-400 hover:bg-treasure-50 transition-all group"
              >
                <span className="font-medium text-gray-700 group-hover:text-treasure-800 text-sm">
                  {city}
                </span>
                <span className="text-xs bg-treasure-100 text-treasure-700 px-2 py-0.5 rounded-full">
                  {count}
                </span>
              </Link>
            ))}
          </div>
        </div>
      )}

      {/* Sales Grid */}
      {sales.length > 0 ? (
        <div>
          <h2 className="font-semibold text-lg text-gray-900 mb-4">
            All Upcoming Sales
          </h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {sales.map((sale: any) => (
              <SaleCard key={sale.id} sale={sale} />
            ))}
          </div>
        </div>
      ) : (
        <div className="text-center py-16">
          <p className="text-gray-400 text-lg">
            No upcoming sales in {stateName} yet.
          </p>
          <Link href="/create" className="btn-primary inline-block mt-4">
            Be the first to list a sale!
          </Link>
        </div>
      )}
    </div>
  );
}
