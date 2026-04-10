import { notFound } from 'next/navigation';
import { format, parseISO } from 'date-fns';
import { createSupabaseServer } from '@/lib/supabase-server';
import { formatSaleDates } from '@/lib/date-utils';
import PrintButton from './PrintButton';

interface Props {
  params: Promise<{ id: string }>;
}

async function getSale(id: string) {
  const supabase = await createSupabaseServer();
  const { data } = await supabase
    .from('garage_sales')
    .select('*, sale_dates(*)')
    .eq('id', id)
    .eq('is_active', true)
    .single();
  return data;
}

export default async function FlyerPage({ params }: Props) {
  const { id } = await params;
  const sale = await getSale(id);

  if (!sale) notFound();

  const saleDates = sale.sale_dates?.sort(
    (a: any, b: any) => new Date(a.sale_date).getTime() - new Date(b.sale_date).getTime()
  ) ?? [];
  const dateDisplay = formatSaleDates(saleDates, sale.sale_date);
  const saleUrl = `${process.env.NEXT_PUBLIC_SITE_URL ?? 'https://trashtrove.app'}/sale/${id}`;

  return (
    <>
      <style>{`
        @media print {
          .no-print { display: none !important; }
          body { background: white !important; }
          @page { margin: 0.5in; }
        }
      `}</style>

      <div className="max-w-2xl mx-auto px-4 py-8">
        {/* Print button */}
        <div className="no-print mb-6">
          <PrintButton />
        </div>

        {/* Flyer content */}
        <div className="bg-white rounded-xl border-4 border-treasure-600 p-8 print:border-2 print:rounded-none">
          {/* Header */}
          <div className="text-center border-b-2 border-treasure-200 pb-6 mb-6">
            <h1 className="text-4xl sm:text-5xl font-bold text-gray-900 leading-tight">
              {sale.title}
            </h1>
            {sale.categories?.length > 0 && (
              <div className="mt-3 flex flex-wrap justify-center gap-2">
                {sale.categories.map((cat: string) => (
                  <span
                    key={cat}
                    className="bg-treasure-100 text-treasure-800 px-3 py-1 rounded-full text-sm font-medium"
                  >
                    {cat}
                  </span>
                ))}
              </div>
            )}
          </div>

          {/* Date & Time */}
          <div className="text-center mb-6">
            <div className="text-2xl font-bold text-treasure-700 mb-1">
              {dateDisplay}
            </div>
            {saleDates.length > 1 ? (
              <div className="space-y-1">
                {saleDates.map((sd: any) => (
                  <div key={sd.id} className="text-lg text-gray-600">
                    {format(parseISO(sd.sale_date), 'EEE, MMM d')}: {sd.start_time} – {sd.end_time}
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-xl text-gray-600">
                {sale.start_time} – {sale.end_time}
              </div>
            )}
          </div>

          {/* Address */}
          <div className="text-center bg-gray-50 rounded-lg p-4 mb-6">
            <div className="text-xl font-semibold text-gray-900">
              {sale.address}
            </div>
            <div className="text-lg text-gray-600">
              {sale.city}, {sale.state} {sale.zip}
            </div>
          </div>

          {/* Description */}
          {sale.description && (
            <div className="mb-6">
              <p className="text-gray-700 whitespace-pre-line leading-relaxed">
                {sale.description.length > 500
                  ? sale.description.slice(0, 497) + '...'
                  : sale.description}
              </p>
            </div>
          )}

          {/* QR-like link */}
          <div className="text-center pt-4 border-t border-gray-200">
            <p className="text-sm text-gray-500 mb-1">Find more details at:</p>
            <p className="text-treasure-600 font-medium break-all">{saleUrl}</p>
            <p className="text-xs text-gray-400 mt-3">
              Listed on TrashTrove — Find garage sales near you
            </p>
          </div>
        </div>
      </div>
    </>
  );
}
