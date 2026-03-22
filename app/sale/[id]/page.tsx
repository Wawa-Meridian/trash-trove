import Link from 'next/link';
import { notFound } from 'next/navigation';
import { ChevronRight, MapPin, Clock, Calendar, Mail, User, ChevronLeft, ChevronRight as ChevronRightIcon } from 'lucide-react';
import { format, parseISO } from 'date-fns';
import { supabase } from '@/lib/supabase';
import { US_STATES } from '@/lib/types';
import PhotoGallery from '@/components/PhotoGallery';

interface Props {
  params: Promise<{ id: string }>;
}

async function getSale(id: string) {
  const { data } = await supabase
    .from('garage_sales')
    .select('*, photos:sale_photos(*)')
    .eq('id', id)
    .eq('is_active', true)
    .single();
  return data;
}

export default async function SaleDetailPage({ params }: Props) {
  const { id } = await params;
  const sale = await getSale(id);

  if (!sale) notFound();

  const saleDate = parseISO(sale.sale_date);
  const stateName = US_STATES[sale.state] ?? sale.state;
  const photos = sale.photos?.sort(
    (a: any, b: any) => a.display_order - b.display_order
  ) ?? [];

  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      {/* Breadcrumb */}
      <nav className="flex items-center gap-1.5 text-sm text-gray-500 mb-6 flex-wrap">
        <Link href="/browse" className="hover:text-treasure-600">
          Browse
        </Link>
        <ChevronRight size={14} />
        <Link
          href={`/browse/${sale.state}`}
          className="hover:text-treasure-600"
        >
          {stateName}
        </Link>
        <ChevronRight size={14} />
        <Link
          href={`/browse/${sale.state}/${encodeURIComponent(sale.city)}`}
          className="hover:text-treasure-600"
        >
          {sale.city}
        </Link>
        <ChevronRight size={14} />
        <span className="text-gray-900 font-medium truncate max-w-[200px]">
          {sale.title}
        </span>
      </nav>

      <div className="grid grid-cols-1 lg:grid-cols-5 gap-8">
        {/* Left: Photos */}
        <div className="lg:col-span-3">
          <PhotoGallery photos={photos} title={sale.title} />
        </div>

        {/* Right: Details */}
        <div className="lg:col-span-2 space-y-6">
          <div>
            <h1 className="font-display text-2xl sm:text-3xl font-bold text-gray-900">
              {sale.title}
            </h1>

            {/* Categories */}
            {sale.categories?.length > 0 && (
              <div className="mt-3 flex flex-wrap gap-2">
                {sale.categories.map((cat: string) => (
                  <span key={cat} className="badge-category">
                    {cat}
                  </span>
                ))}
              </div>
            )}
          </div>

          {/* Date & Time */}
          <div className="bg-treasure-50 rounded-xl p-5 space-y-3">
            <div className="flex items-center gap-3">
              <Calendar size={20} className="text-treasure-600" />
              <div>
                <div className="font-semibold text-gray-900">
                  {format(saleDate, 'EEEE, MMMM d, yyyy')}
                </div>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <Clock size={20} className="text-treasure-600" />
              <div className="text-gray-700">
                {sale.start_time} &ndash; {sale.end_time}
              </div>
            </div>
          </div>

          {/* Location */}
          <div className="bg-white rounded-xl border border-gray-200 p-5 space-y-3">
            <div className="flex items-start gap-3">
              <MapPin size={20} className="text-treasure-600 mt-0.5" />
              <div>
                <div className="font-semibold text-gray-900">Address</div>
                <div className="text-gray-600">
                  {sale.address}
                  <br />
                  {sale.city}, {sale.state} {sale.zip}
                </div>
              </div>
            </div>
          </div>

          {/* Seller */}
          <div className="bg-white rounded-xl border border-gray-200 p-5 space-y-3">
            <div className="flex items-center gap-3">
              <User size={20} className="text-treasure-600" />
              <div>
                <div className="font-semibold text-gray-900">
                  {sale.seller_name}
                </div>
              </div>
            </div>
            {sale.seller_email && (
              <div className="flex items-center gap-3">
                <Mail size={20} className="text-treasure-600" />
                <a
                  href={`mailto:${sale.seller_email}`}
                  className="text-treasure-600 hover:underline"
                >
                  {sale.seller_email}
                </a>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Description */}
      <div className="mt-10">
        <h2 className="font-display text-xl font-bold text-gray-900 mb-4">
          About This Sale
        </h2>
        <div className="prose prose-gray max-w-none">
          <p className="whitespace-pre-line text-gray-600">
            {sale.description}
          </p>
        </div>
      </div>
    </div>
  );
}
