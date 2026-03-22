import Link from 'next/link';
import { MapPin, Plus, Calendar, Search } from 'lucide-react';
import SaleCard from '@/components/SaleCard';
import StateGrid from '@/components/StateGrid';
import SearchBar from '@/components/SearchBar';
import { supabase } from '@/lib/supabase';

async function getUpcomingSales() {
  const today = new Date().toISOString().split('T')[0];
  const { data } = await supabase
    .from('garage_sales')
    .select('*, photos:sale_photos(*)')
    .eq('is_active', true)
    .gte('sale_date', today)
    .order('sale_date', { ascending: true })
    .limit(6);
  return data ?? [];
}

async function getStateCounts() {
  const today = new Date().toISOString().split('T')[0];
  const { data } = await supabase
    .rpc('get_state_counts', { min_date: today })
    .select('*');
  // Fallback: if RPC doesn't exist, return empty
  return data ?? [];
}

export default async function HomePage() {
  const [upcomingSales, stateCounts] = await Promise.all([
    getUpcomingSales(),
    getStateCounts().catch(() => []),
  ]);

  return (
    <div>
      {/* Hero */}
      <section className="bg-gradient-to-br from-treasure-50 via-white to-forest-50 py-16 sm:py-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h1 className="font-display text-4xl sm:text-5xl lg:text-6xl font-bold text-treasure-900">
            Find Weekend Garage Sales
            <br />
            <span className="text-treasure-600">Near You</span>
          </h1>
          <p className="mt-4 text-lg text-gray-600 max-w-2xl mx-auto">
            Discover hidden gems at neighborhood garage sales. Browse by
            location or list your own sale for free.
          </p>

          <div className="mt-6 max-w-xl mx-auto">
            <SearchBar />
          </div>

          <div className="mt-8 flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/browse"
              className="btn-primary inline-flex items-center justify-center gap-2 text-lg px-8 py-3"
            >
              <Search size={20} />
              Browse Sales
            </Link>
            <Link
              href="/create"
              className="btn-secondary inline-flex items-center justify-center gap-2 text-lg px-8 py-3"
            >
              <Plus size={20} />
              List Your Sale
            </Link>
          </div>
        </div>
      </section>

      {/* How it works */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="font-display text-2xl font-bold text-center text-gray-900 mb-10">
            How It Works
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {[
              {
                icon: <Plus className="text-treasure-600" size={32} />,
                title: 'List Your Sale',
                desc: 'Add your address, upload photos of your items, pick your date and categories.',
              },
              {
                icon: <MapPin className="text-treasure-600" size={32} />,
                title: 'Shoppers Find You',
                desc: 'Buyers browse by state and city to find sales happening this weekend.',
              },
              {
                icon: <Calendar className="text-treasure-600" size={32} />,
                title: 'Sell Your Stuff',
                desc: 'Shoppers show up, you make some cash, and your clutter finds a new home.',
              },
            ].map((step, i) => (
              <div key={i} className="text-center p-6">
                <div className="inline-flex items-center justify-center w-16 h-16 bg-treasure-50 rounded-full mb-4">
                  {step.icon}
                </div>
                <h3 className="font-semibold text-lg text-gray-900">
                  {step.title}
                </h3>
                <p className="mt-2 text-gray-500">{step.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Upcoming Sales */}
      {upcomingSales.length > 0 && (
        <section className="py-16">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex items-center justify-between mb-8">
              <h2 className="font-display text-2xl font-bold text-gray-900">
                Upcoming Sales
              </h2>
              <Link
                href="/browse"
                className="text-treasure-600 hover:text-treasure-700 font-medium text-sm"
              >
                View all &rarr;
              </Link>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {upcomingSales.map((sale: any) => (
                <SaleCard key={sale.id} sale={sale} />
              ))}
            </div>
          </div>
        </section>
      )}

      {/* Browse by State */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="font-display text-2xl font-bold text-gray-900 mb-8">
            Browse by State
          </h2>
          <StateGrid stateCounts={stateCounts} />
        </div>
      </section>
    </div>
  );
}
