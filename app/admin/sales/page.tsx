'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { Loader2, Search, ExternalLink, Ban, RotateCcw } from 'lucide-react';
import { format, parseISO } from 'date-fns';
import { createSupabaseBrowser } from '@/lib/supabase';

interface AdminSale {
  id: string;
  title: string;
  city: string;
  state: string;
  sale_date: string;
  is_active: boolean;
  created_at: string;
}

export default function AdminSalesPage() {
  const [sales, setSales] = useState<AdminSale[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'inactive'>('all');
  const [actionLoading, setActionLoading] = useState<string | null>(null);

  useEffect(() => {
    const fetchSales = async () => {
      const supabase = createSupabaseBrowser();
      let query = supabase
        .from('garage_sales')
        .select('id, title, city, state, sale_date, is_active, created_at')
        .order('created_at', { ascending: false })
        .limit(100);

      const { data } = await query;
      setSales(data ?? []);
      setLoading(false);
    };

    fetchSales();
  }, []);

  const toggleActive = async (saleId: string, currentlyActive: boolean) => {
    setActionLoading(saleId);
    await fetch(`/api/admin/sales/${saleId}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ is_active: !currentlyActive }),
    });

    setSales((prev) =>
      prev.map((s) =>
        s.id === saleId ? { ...s, is_active: !currentlyActive } : s
      )
    );
    setActionLoading(null);
  };

  const filtered = sales.filter((s) => {
    const matchesSearch =
      !searchQuery ||
      s.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      s.city.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus =
      statusFilter === 'all' ||
      (statusFilter === 'active' && s.is_active) ||
      (statusFilter === 'inactive' && !s.is_active);
    return matchesSearch && matchesStatus;
  });

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[200px]">
        <Loader2 size={24} className="animate-spin text-treasure-600" />
      </div>
    );
  }

  return (
    <div>
      <h2 className="font-display text-xl font-bold text-gray-900 mb-6">
        All Sales ({sales.length})
      </h2>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-3 mb-6">
        <div className="relative flex-1">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Search by title or city..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="input-field pl-9 text-sm"
          />
        </div>
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value as 'all' | 'active' | 'inactive')}
          className="input-field text-sm w-auto"
        >
          <option value="all">All Status</option>
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
        </select>
      </div>

      <div className="space-y-2">
        {filtered.map((sale) => (
          <div
            key={sale.id}
            className={`bg-white rounded-lg border p-3 flex items-center gap-3 ${
              sale.is_active ? 'border-gray-200' : 'border-red-200 bg-red-50/50'
            }`}
          >
            <div className="flex-1 min-w-0">
              <Link
                href={`/sale/${sale.id}`}
                className="font-medium text-sm text-gray-900 hover:text-treasure-600 flex items-center gap-1"
              >
                <span className="truncate">{sale.title}</span>
                <ExternalLink size={12} className="flex-shrink-0" />
              </Link>
              <div className="text-xs text-gray-500 mt-0.5">
                {sale.city}, {sale.state} · {format(parseISO(sale.sale_date), 'MMM d, yyyy')}
              </div>
            </div>

            <span
              className={`text-xs px-2 py-0.5 rounded-full font-medium ${
                sale.is_active ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
              }`}
            >
              {sale.is_active ? 'Active' : 'Inactive'}
            </span>

            <button
              onClick={() => toggleActive(sale.id, sale.is_active)}
              disabled={actionLoading === sale.id}
              className="p-1.5 rounded-lg hover:bg-gray-100 text-gray-500 disabled:opacity-50"
              title={sale.is_active ? 'Deactivate' : 'Reactivate'}
            >
              {actionLoading === sale.id ? (
                <Loader2 size={16} className="animate-spin" />
              ) : sale.is_active ? (
                <Ban size={16} />
              ) : (
                <RotateCcw size={16} />
              )}
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}
