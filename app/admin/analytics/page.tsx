'use client';

import { useEffect, useState } from 'react';
import { Loader2, TrendingUp, MessageSquare, Flag, ShoppingBag } from 'lucide-react';
import { createSupabaseBrowser } from '@/lib/supabase';

interface Stats {
  totalSales: number;
  activeSales: number;
  totalMessages: number;
  pendingReports: number;
  topStates: { state: string; count: number }[];
  topCategories: { category: string; count: number }[];
}

export default function AdminAnalyticsPage() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      const supabase = createSupabaseBrowser();

      const [salesRes, activeRes, messagesRes, reportsRes] = await Promise.all([
        supabase.from('garage_sales').select('*', { count: 'exact', head: true }),
        supabase.from('garage_sales').select('*', { count: 'exact', head: true }).eq('is_active', true),
        supabase.from('contact_messages').select('*', { count: 'exact', head: true }),
        supabase.from('sale_reports').select('*', { count: 'exact', head: true }),
      ]);

      // Top states
      const { data: statesData } = await supabase
        .from('garage_sales')
        .select('state')
        .eq('is_active', true);

      const stateMap = new Map<string, number>();
      (statesData ?? []).forEach((s: { state: string }) => {
        stateMap.set(s.state, (stateMap.get(s.state) ?? 0) + 1);
      });
      const topStates = Array.from(stateMap.entries())
        .map(([state, count]) => ({ state, count }))
        .sort((a, b) => b.count - a.count)
        .slice(0, 10);

      // Top categories
      const { data: catsData } = await supabase
        .from('garage_sales')
        .select('categories')
        .eq('is_active', true);

      const catMap = new Map<string, number>();
      (catsData ?? []).forEach((s: { categories: string[] }) => {
        (s.categories ?? []).forEach((c) => {
          catMap.set(c, (catMap.get(c) ?? 0) + 1);
        });
      });
      const topCategories = Array.from(catMap.entries())
        .map(([category, count]) => ({ category, count }))
        .sort((a, b) => b.count - a.count)
        .slice(0, 10);

      setStats({
        totalSales: salesRes.count ?? 0,
        activeSales: activeRes.count ?? 0,
        totalMessages: messagesRes.count ?? 0,
        pendingReports: reportsRes.count ?? 0,
        topStates,
        topCategories,
      });
      setLoading(false);
    };

    fetchStats();
  }, []);

  if (loading || !stats) {
    return (
      <div className="flex items-center justify-center min-h-[200px]">
        <Loader2 size={24} className="animate-spin text-treasure-600" />
      </div>
    );
  }

  const statCards = [
    { label: 'Total Sales', value: stats.totalSales, icon: ShoppingBag, color: 'text-treasure-600 bg-treasure-50' },
    { label: 'Active Sales', value: stats.activeSales, icon: TrendingUp, color: 'text-green-600 bg-green-50' },
    { label: 'Messages', value: stats.totalMessages, icon: MessageSquare, color: 'text-blue-600 bg-blue-50' },
    { label: 'Pending Reports', value: stats.pendingReports, icon: Flag, color: 'text-red-600 bg-red-50' },
  ];

  return (
    <div>
      <h2 className="font-display text-xl font-bold text-gray-900 mb-6">
        Analytics
      </h2>

      {/* Stat cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        {statCards.map(({ label, value, icon: Icon, color }) => (
          <div key={label} className="bg-white rounded-xl border border-gray-200 p-4">
            <div className={`inline-flex items-center justify-center w-10 h-10 rounded-lg ${color} mb-3`}>
              <Icon size={20} />
            </div>
            <div className="text-2xl font-bold text-gray-900">{value.toLocaleString()}</div>
            <div className="text-sm text-gray-500">{label}</div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Top states */}
        <div className="bg-white rounded-xl border border-gray-200 p-5">
          <h3 className="font-semibold text-gray-900 mb-4">Top States</h3>
          {stats.topStates.length === 0 ? (
            <p className="text-sm text-gray-500">No data yet</p>
          ) : (
            <div className="space-y-2">
              {stats.topStates.map(({ state, count }) => (
                <div key={state} className="flex items-center justify-between text-sm">
                  <span className="text-gray-700">{state}</span>
                  <span className="font-medium text-gray-900">{count}</span>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Top categories */}
        <div className="bg-white rounded-xl border border-gray-200 p-5">
          <h3 className="font-semibold text-gray-900 mb-4">Top Categories</h3>
          {stats.topCategories.length === 0 ? (
            <p className="text-sm text-gray-500">No data yet</p>
          ) : (
            <div className="space-y-2">
              {stats.topCategories.map(({ category, count }) => (
                <div key={category} className="flex items-center justify-between text-sm">
                  <span className="text-gray-700">{category}</span>
                  <span className="font-medium text-gray-900">{count}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
