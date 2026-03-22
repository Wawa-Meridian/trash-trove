import type { Metadata } from 'next';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { ChevronRight } from 'lucide-react';
import SaleCard from '@/components/SaleCard';
import SaleMap from '@/components/SaleMap';
import { supabase } from '@/lib/supabase';
import { US_STATES } from '@/lib/types';

const US_STATE_CENTERS: Record<string, [number, number]> = {
  AL: [32.806671, -86.791130], AK: [61.370716, -152.404419], AZ: [33.729759, -111.431221],
  AR: [34.969704, -92.373123], CA: [36.116203, -119.681564], CO: [39.059811, -105.311104],
  CT: [41.597782, -72.755371], DE: [39.318523, -75.507141], FL: [27.766279, -81.686783],
  GA: [33.040619, -83.643074], HI: [21.094318, -157.498337], ID: [44.240459, -114.478773],
  IL: [40.349457, -88.986137], IN: [39.849426, -86.258278], IA: [42.011539, -93.210526],
  KS: [38.526600, -96.726486], KY: [37.668140, -84.670067], LA: [31.169546, -91.867805],
  ME: [44.693947, -69.381927], MD: [39.063946, -76.802101], MA: [42.230171, -71.530106],
  MI: [43.326618, -84.536095], MN: [45.694454, -93.900192], MS: [32.741646, -89.678696],
  MO: [38.456085, -92.288368], MT: [46.921925, -110.454353], NE: [41.125370, -98.268082],
  NV: [38.313515, -117.055374], NH: [43.452492, -71.563896], NJ: [40.298904, -74.521011],
  NM: [34.840515, -106.248482], NY: [42.165726, -74.948051], NC: [35.630066, -79.806419],
  ND: [47.528912, -99.784012], OH: [40.388783, -82.764915], OK: [35.565342, -96.928917],
  OR: [44.572021, -122.070938], PA: [40.590752, -77.209755], RI: [41.680893, -71.511780],
  SC: [33.856892, -80.945007], SD: [44.299782, -99.438828], TN: [35.747845, -86.692345],
  TX: [31.054487, -97.563461], UT: [40.150032, -111.862434], VT: [44.045876, -72.710686],
  VA: [37.769337, -78.169968], WA: [47.400902, -121.490494], WV: [38.491226, -80.954456],
  WI: [44.268543, -89.616508], WY: [42.755966, -107.302490], DC: [38.897438, -77.026817],
};

interface Props {
  params: Promise<{ state: string }>;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { state } = await params;
  const stateCode = state.toUpperCase();
  const stateName = US_STATES[stateCode];

  if (!stateName) return {};

  return {
    title: `Garage Sales in ${stateName}`,
    description: `Find upcoming garage sales in ${stateName}. Browse yard sales, estate sales, and moving sales listed on TrashTrove.`,
  };
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

      {/* Map */}
      {sales.length > 0 && (
        <div className="card overflow-hidden mb-8">
          <SaleMap
            sales={sales}
            center={US_STATE_CENTERS[stateCode]}
            zoom={7}
            className="h-[400px]"
          />
        </div>
      )}

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
