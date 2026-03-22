'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { Plus, Calendar, MapPin, Edit, Trash2, Loader2, AlertTriangle } from 'lucide-react';
import { format, parseISO, isPast } from 'date-fns';
import { createSupabaseBrowser } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';

interface Sale {
  id: string;
  title: string;
  city: string;
  state: string;
  sale_date: string;
  is_active: boolean;
  photos: { url: string }[];
}

export default function DashboardPage() {
  const { user } = useAuth();
  const [sales, setSales] = useState<Sale[]>([]);
  const [loading, setLoading] = useState(true);
  const [deletingSaleId, setDeletingSaleId] = useState<string | null>(null);

  useEffect(() => {
    if (!user) return;

    const fetchSales = async () => {
      const supabase = createSupabaseBrowser();
      const { data } = await supabase
        .from('garage_sales')
        .select('id, title, city, state, sale_date, is_active, photos:sale_photos(url)')
        .eq('user_id', user.id)
        .order('sale_date', { ascending: false });

      setSales(data ?? []);
      setLoading(false);
    };

    fetchSales();
  }, [user]);

  const handleDelete = async (saleId: string) => {
    if (!confirm('Are you sure you want to delete this listing?')) return;

    setDeletingSaleId(saleId);
    const res = await fetch(`/api/sales/${saleId}`, { method: 'DELETE' });

    if (res.ok) {
      setSales((prev) => prev.filter((s) => s.id !== saleId));
    }
    setDeletingSaleId(null);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[200px]">
        <Loader2 size={24} className="animate-spin text-treasure-600" />
      </div>
    );
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 className="font-display text-xl font-bold text-gray-900">
          My Sales
        </h2>
        <Link href="/create" className="btn-primary flex items-center gap-2 text-sm">
          <Plus size={16} />
          New Sale
        </Link>
      </div>

      {sales.length === 0 ? (
        <div className="text-center py-16 bg-white rounded-xl border border-gray-200">
          <ShoppingBagEmpty />
          <h3 className="font-semibold text-gray-700 mt-4">No sales yet</h3>
          <p className="text-gray-500 mt-1 text-sm">
            Create your first garage sale listing to get started.
          </p>
          <Link href="/create" className="btn-primary inline-flex items-center gap-2 mt-4">
            <Plus size={16} />
            List Your Sale
          </Link>
        </div>
      ) : (
        <div className="space-y-3">
          {sales.map((sale) => {
            const saleDate = parseISO(sale.sale_date);
            const expired = isPast(saleDate);

            return (
              <div
                key={sale.id}
                className={`bg-white rounded-xl border p-4 flex items-center gap-4 ${
                  !sale.is_active || expired
                    ? 'border-gray-200 opacity-60'
                    : 'border-gray-200 hover:border-treasure-300'
                } transition-colors`}
              >
                {/* Thumbnail */}
                <div className="w-16 h-16 rounded-lg bg-gray-100 overflow-hidden flex-shrink-0">
                  {sale.photos?.[0] ? (
                    <img
                      src={sale.photos[0].url}
                      alt=""
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center text-2xl">
                      🏷️
                    </div>
                  )}
                </div>

                {/* Info */}
                <div className="flex-1 min-w-0">
                  <Link
                    href={`/sale/${sale.id}`}
                    className="font-semibold text-gray-900 hover:text-treasure-600 truncate block"
                  >
                    {sale.title}
                  </Link>
                  <div className="flex items-center gap-3 text-sm text-gray-500 mt-1">
                    <span className="flex items-center gap-1">
                      <MapPin size={14} />
                      {sale.city}, {sale.state}
                    </span>
                    <span className="flex items-center gap-1">
                      <Calendar size={14} />
                      {format(saleDate, 'MMM d, yyyy')}
                    </span>
                  </div>
                  {!sale.is_active && (
                    <span className="inline-flex items-center gap-1 text-xs text-red-600 mt-1">
                      <AlertTriangle size={12} />
                      Deleted
                    </span>
                  )}
                  {sale.is_active && expired && (
                    <span className="text-xs text-gray-400 mt-1 block">Expired</span>
                  )}
                </div>

                {/* Actions */}
                {sale.is_active && (
                  <div className="flex items-center gap-2">
                    <Link
                      href={`/sale/${sale.id}/manage`}
                      className="p-2 rounded-lg text-gray-500 hover:bg-gray-100 hover:text-treasure-600 transition-colors"
                      title="Edit"
                    >
                      <Edit size={18} />
                    </Link>
                    <button
                      onClick={() => handleDelete(sale.id)}
                      disabled={deletingSaleId === sale.id}
                      className="p-2 rounded-lg text-gray-500 hover:bg-red-50 hover:text-red-600 transition-colors disabled:opacity-50"
                      title="Delete"
                    >
                      {deletingSaleId === sale.id ? (
                        <Loader2 size={18} className="animate-spin" />
                      ) : (
                        <Trash2 size={18} />
                      )}
                    </button>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

function ShoppingBagEmpty() {
  return (
    <div className="inline-flex items-center justify-center w-16 h-16 bg-treasure-50 rounded-full">
      <span className="text-3xl">🏷️</span>
    </div>
  );
}
