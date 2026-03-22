import StateGrid from '@/components/StateGrid';
import { supabase } from '@/lib/supabase';

async function getStateCounts() {
  const today = new Date().toISOString().split('T')[0];
  const { data } = await supabase
    .rpc('get_state_counts', { min_date: today })
    .select('*');
  return data ?? [];
}

export default async function BrowsePage() {
  const stateCounts = await getStateCounts().catch(() => []);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <h1 className="font-display text-3xl font-bold text-gray-900 mb-2">
        Browse Garage Sales
      </h1>
      <p className="text-gray-500 mb-8">
        Select a state to find garage sales near you.
      </p>
      <StateGrid stateCounts={stateCounts} />
    </div>
  );
}
