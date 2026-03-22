import { ImageResponse } from 'next/og';
import { NextRequest } from 'next/server';
import { createSupabaseServer } from '@/lib/supabase-server';

export const runtime = 'edge';

export async function GET(request: NextRequest) {
  const { searchParams } = request.nextUrl;
  const saleId = searchParams.get('saleId');

  if (!saleId) {
    return new ImageResponse(
      (
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            width: '100%',
            height: '100%',
            background: 'linear-gradient(135deg, #fdf8f0, #fff7ed)',
            fontSize: 48,
            fontWeight: 700,
            color: '#c76b23',
          }}
        >
          🗑️ TrashTrove
        </div>
      ),
      { width: 1200, height: 630 }
    );
  }

  // We can't use createSupabaseServer in edge runtime with cookies,
  // so fetch from the API directly
  const baseUrl = request.nextUrl.origin;
  const res = await fetch(`${baseUrl}/api/sales/${saleId}`);
  const data = await res.json();
  const sale = data?.sale;

  if (!sale) {
    return new ImageResponse(
      (
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            width: '100%',
            height: '100%',
            background: '#fdf8f0',
            fontSize: 32,
            color: '#666',
          }}
        >
          Sale not found
        </div>
      ),
      { width: 1200, height: 630 }
    );
  }

  const categories = (sale.categories ?? []).slice(0, 4);

  return new ImageResponse(
    (
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          width: '100%',
          height: '100%',
          background: 'linear-gradient(135deg, #fdf8f0, #fff7ed)',
          padding: 60,
        }}
      >
        {/* Header */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 12,
            marginBottom: 32,
          }}
        >
          <span style={{ fontSize: 36 }}>🗑️</span>
          <span style={{ fontSize: 24, fontWeight: 700, color: '#c76b23' }}>
            TrashTrove
          </span>
        </div>

        {/* Title */}
        <div
          style={{
            fontSize: 52,
            fontWeight: 700,
            color: '#1a1a1a',
            lineHeight: 1.2,
            marginBottom: 24,
            display: 'flex',
            maxWidth: '90%',
          }}
        >
          {sale.title.length > 60
            ? sale.title.slice(0, 57) + '...'
            : sale.title}
        </div>

        {/* Location & Date */}
        <div
          style={{
            display: 'flex',
            gap: 32,
            fontSize: 24,
            color: '#6b7280',
            marginBottom: 24,
          }}
        >
          <span>📍 {sale.city}, {sale.state}</span>
          <span>📅 {sale.sale_date}</span>
          <span>🕐 {sale.start_time} – {sale.end_time}</span>
        </div>

        {/* Categories */}
        {categories.length > 0 && (
          <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap' }}>
            {categories.map((cat: string) => (
              <div
                key={cat}
                style={{
                  background: '#fef3c7',
                  color: '#92400e',
                  padding: '8px 20px',
                  borderRadius: 24,
                  fontSize: 18,
                  fontWeight: 600,
                }}
              >
                {cat}
              </div>
            ))}
          </div>
        )}

        {/* Footer */}
        <div
          style={{
            display: 'flex',
            marginTop: 'auto',
            fontSize: 18,
            color: '#9ca3af',
          }}
        >
          trashtrove.app
        </div>
      </div>
    ),
    { width: 1200, height: 630 }
  );
}
