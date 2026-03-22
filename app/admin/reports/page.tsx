'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { Loader2, Flag, Ban, Check, ExternalLink } from 'lucide-react';
import { formatDistanceToNow, parseISO } from 'date-fns';
import { createSupabaseBrowser } from '@/lib/supabase';

interface Report {
  id: string;
  reason: string;
  details: string | null;
  reporter_ip: string;
  created_at: string;
  sale: {
    id: string;
    title: string;
    is_active: boolean;
  };
}

export default function AdminReportsPage() {
  const [reports, setReports] = useState<Report[]>([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState<string | null>(null);

  useEffect(() => {
    const fetchReports = async () => {
      const supabase = createSupabaseBrowser();
      const { data } = await supabase
        .from('sale_reports')
        .select('*, sale:garage_sales!inner(id, title, is_active)')
        .order('created_at', { ascending: false })
        .limit(100);

      const formatted = (data ?? []).map((r: any) => ({
        ...r,
        sale: Array.isArray(r.sale) ? r.sale[0] : r.sale,
      }));

      setReports(formatted);
      setLoading(false);
    };

    fetchReports();
  }, []);

  const handleDeactivate = async (saleId: string) => {
    setActionLoading(saleId);
    await fetch(`/api/admin/sales/${saleId}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ is_active: false }),
    });

    setReports((prev) =>
      prev.map((r) =>
        r.sale.id === saleId
          ? { ...r, sale: { ...r.sale, is_active: false } }
          : r
      )
    );
    setActionLoading(null);
  };

  const handleDismiss = async (reportId: string) => {
    setActionLoading(reportId);
    await fetch(`/api/admin/reports/${reportId}`, { method: 'DELETE' });
    setReports((prev) => prev.filter((r) => r.id !== reportId));
    setActionLoading(null);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[200px]">
        <Loader2 size={24} className="animate-spin text-treasure-600" />
      </div>
    );
  }

  const reasonColors: Record<string, string> = {
    spam: 'bg-yellow-100 text-yellow-800',
    scam: 'bg-red-100 text-red-800',
    inappropriate: 'bg-orange-100 text-orange-800',
    duplicate: 'bg-blue-100 text-blue-800',
    other: 'bg-gray-100 text-gray-800',
  };

  return (
    <div>
      <h2 className="font-display text-xl font-bold text-gray-900 mb-6">
        Reports ({reports.length})
      </h2>

      {reports.length === 0 ? (
        <div className="text-center py-16 bg-white rounded-xl border border-gray-200">
          <Flag size={32} className="mx-auto text-gray-300 mb-3" />
          <p className="text-gray-500">No reports to review</p>
        </div>
      ) : (
        <div className="space-y-3">
          {reports.map((report) => (
            <div
              key={report.id}
              className="bg-white rounded-xl border border-gray-200 p-4"
            >
              <div className="flex items-start justify-between gap-3">
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${reasonColors[report.reason] ?? reasonColors.other}`}>
                      {report.reason}
                    </span>
                    <span className="text-xs text-gray-400">
                      {formatDistanceToNow(parseISO(report.created_at), { addSuffix: true })}
                    </span>
                  </div>
                  <Link
                    href={`/sale/${report.sale.id}`}
                    className="font-semibold text-gray-900 hover:text-treasure-600 flex items-center gap-1"
                  >
                    {report.sale.title}
                    <ExternalLink size={14} />
                  </Link>
                  {report.details && (
                    <p className="text-sm text-gray-600 mt-1">{report.details}</p>
                  )}
                  {!report.sale.is_active && (
                    <span className="text-xs text-red-500 mt-1 block">Sale already deactivated</span>
                  )}
                </div>

                <div className="flex items-center gap-2 flex-shrink-0">
                  {report.sale.is_active && (
                    <button
                      onClick={() => handleDeactivate(report.sale.id)}
                      disabled={actionLoading === report.sale.id}
                      className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-red-700 bg-red-50 rounded-lg hover:bg-red-100 disabled:opacity-50"
                    >
                      {actionLoading === report.sale.id ? (
                        <Loader2 size={14} className="animate-spin" />
                      ) : (
                        <Ban size={14} />
                      )}
                      Deactivate
                    </button>
                  )}
                  <button
                    onClick={() => handleDismiss(report.id)}
                    disabled={actionLoading === report.id}
                    className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 disabled:opacity-50"
                  >
                    {actionLoading === report.id ? (
                      <Loader2 size={14} className="animate-spin" />
                    ) : (
                      <Check size={14} />
                    )}
                    Dismiss
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
