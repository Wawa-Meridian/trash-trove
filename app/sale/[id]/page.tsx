import type { Metadata } from 'next';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { ChevronRight, MapPin, Clock, Calendar, User, ChevronLeft, ChevronRight as ChevronRightIcon } from 'lucide-react';
import { format, parseISO } from 'date-fns';
import { createSupabaseServer } from '@/lib/supabase-server';
import { US_STATES } from '@/lib/types';
import { formatSaleDates } from '@/lib/date-utils';
import PhotoGallery from '@/components/PhotoGallery';
import ShareButtons from '@/components/ShareButtons';
import ContactForm from '@/components/ContactForm';
import FavoriteButton from '@/components/FavoriteButton';
import ReportButton from '@/components/ReportButton';
import SaleMap from '@/components/SaleMap';
import GetDirectionsButton from '@/components/GetDirectionsButton';

interface Props {
  params: Promise<{ id: string }>;
}

async function getSale(id: string) {
  const supabase = await createSupabaseServer();
  const { data } = await supabase
    .from('garage_sales')
    .select('*, photos:sale_photos(*), sale_dates(*)')
    .eq('id', id)
    .eq('is_active', true)
    .single();
  return data;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id } = await params;
  const sale = await getSale(id);

  if (!sale) return {};

  const description = sale.description
    ? sale.description.slice(0, 160)
    : `Garage sale in ${sale.city}, ${sale.state}`;

  const photos = sale.photos?.sort(
    (a: any, b: any) => a.display_order - b.display_order
  ) ?? [];

  const metadata: Metadata = {
    title: sale.title,
    description,
    openGraph: {
      title: sale.title,
      description,
    },
    twitter: {
      card: photos.length > 0 ? 'summary_large_image' : 'summary',
      title: sale.title,
      description,
    },
  };

  const ogImage = { url: `/api/og?saleId=${id}`, width: 1200, height: 630 };

  if (photos.length > 0) {
    metadata.openGraph!.images = [{ url: photos[0].url }, ogImage];
    metadata.twitter!.images = [photos[0].url];
  } else {
    metadata.openGraph!.images = [ogImage];
    metadata.twitter = {
      card: 'summary_large_image',
      title: sale.title,
      description,
      images: [ogImage.url],
    };
  }

  return metadata;
}

export default async function SaleDetailPage({ params }: Props) {
  const { id } = await params;
  const sale = await getSale(id);

  if (!sale) notFound();

  const saleDates = sale.sale_dates?.sort(
    (a: any, b: any) => new Date(a.sale_date).getTime() - new Date(b.sale_date).getTime()
  ) ?? [];
  const dateDisplay = formatSaleDates(saleDates, sale.sale_date);
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
        <span className="text-gray-900 dark:text-gray-100 font-medium truncate max-w-[200px]">
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
            <div className="flex items-start justify-between gap-3">
              <h1 className="font-display text-2xl sm:text-3xl font-bold text-gray-900 dark:text-gray-100">
                {sale.title}
              </h1>
              <FavoriteButton
                saleId={sale.id}
                variant="default"
                className="mt-1 p-2 rounded-full hover:bg-gray-100 transition-colors"
              />
            </div>

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

            <ShareButtons title={sale.title} />
          </div>

          {/* Date & Time */}
          <div className="bg-treasure-50 dark:bg-treasure-900/20 rounded-xl p-5 space-y-3">
            {saleDates.length > 1 ? (
              <>
                <div className="flex items-center gap-3 mb-1">
                  <Calendar size={20} className="text-treasure-600" />
                  <div className="font-semibold text-gray-900">{dateDisplay}</div>
                </div>
                {saleDates.map((sd: any) => (
                  <div key={sd.id} className="flex items-center gap-3 pl-8 text-sm text-gray-700">
                    <span className="font-medium">{format(parseISO(sd.sale_date), 'EEE, MMM d')}</span>
                    <span>{sd.start_time} &ndash; {sd.end_time}</span>
                  </div>
                ))}
              </>
            ) : (
              <>
                <div className="flex items-center gap-3">
                  <Calendar size={20} className="text-treasure-600" />
                  <div className="font-semibold text-gray-900">{dateDisplay}</div>
                </div>
                <div className="flex items-center gap-3">
                  <Clock size={20} className="text-treasure-600" />
                  <div className="text-gray-700">
                    {sale.start_time} &ndash; {sale.end_time}
                  </div>
                </div>
              </>
            )}
          </div>

          {/* Location */}
          <div className="bg-white dark:bg-gray-900 rounded-xl border border-gray-200 dark:border-gray-700 p-5 space-y-3">
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
            {sale.latitude && sale.longitude && (
              <div className="mt-3 rounded-lg overflow-hidden">
                <SaleMap
                  singleMarker={{ lat: sale.latitude, lng: sale.longitude, title: sale.title }}
                  className="h-[200px]"
                />
              </div>
            )}
            <GetDirectionsButton
              address={sale.address}
              city={sale.city}
              state={sale.state}
              zip={sale.zip}
              className="mt-3"
            />
          </div>

          {/* Seller */}
          <div className="bg-white dark:bg-gray-900 rounded-xl border border-gray-200 dark:border-gray-700 p-5 space-y-3">
            <div className="flex items-center gap-3">
              <User size={20} className="text-treasure-600" />
              <div>
                <div className="font-semibold text-gray-900 dark:text-gray-100">
                  {sale.seller_name}
                </div>
              </div>
            </div>
          </div>

          {/* Contact Form */}
          <ContactForm saleId={sale.id} sellerName={sale.seller_name} />
        </div>
      </div>

      {/* Description */}
      <div className="mt-10">
        <h2 className="font-display text-xl font-bold text-gray-900 dark:text-gray-100 mb-4">
          About This Sale
        </h2>
        <div className="prose prose-gray dark:prose-invert max-w-none">
          <p className="whitespace-pre-line text-gray-600 dark:text-gray-400">
            {sale.description}
          </p>
        </div>
      </div>

      {/* Actions */}
      <div className="mt-8 pt-6 border-t border-gray-200 dark:border-gray-700 flex items-center justify-between">
        <Link
          href={`/sale/${sale.id}/flyer`}
          className="text-sm text-gray-500 hover:text-treasure-600 flex items-center gap-1.5"
        >
          🖨️ Print Flyer
        </Link>
        <ReportButton saleId={sale.id} />
      </div>
    </div>
  );
}
