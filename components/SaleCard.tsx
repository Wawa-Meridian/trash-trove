import Link from 'next/link';
import { MapPin, Clock, Calendar, ImageIcon } from 'lucide-react';
import type { GarageSale } from '@/lib/types';
import { formatSaleDateShort } from '@/lib/date-utils';
import FavoriteButton from '@/components/FavoriteButton';

export default function SaleCard({ sale }: { sale: GarageSale }) {
  const coverPhoto = sale.photos?.[0]?.url;
  const dateDisplay = formatSaleDateShort(sale.sale_dates, sale.sale_date);
  const isMultiDay = (sale.sale_dates?.length ?? 0) > 1;

  return (
    <Link href={`/sale/${sale.id}`} className="card group">
      {/* Photo */}
      <div className="aspect-[4/3] bg-gray-100 relative overflow-hidden">
        {coverPhoto ? (
          <img
            src={coverPhoto}
            alt={sale.title}
            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-gray-300">
            <ImageIcon size={48} />
          </div>
        )}
        <FavoriteButton
          saleId={sale.id}
          className="absolute top-2 right-2 bg-black/40 hover:bg-black/60 rounded-full p-1.5"
        />
        {sale.photos?.length > 1 && (
          <span className="absolute bottom-2 right-2 bg-black/60 text-white text-xs px-2 py-1 rounded-full">
            {sale.photos.length} photos
          </span>
        )}
        {isMultiDay && (
          <span className="absolute top-2 left-2 bg-forest-600 text-white text-xs px-2 py-1 rounded-full font-medium">
            Multi-day
          </span>
        )}
      </div>

      {/* Details */}
      <div className="p-4">
        <h3 className="font-semibold text-gray-900 dark:text-gray-100 group-hover:text-treasure-700 transition-colors line-clamp-1">
          {sale.title}
        </h3>

        <div className="mt-2 space-y-1.5 text-sm text-gray-500 dark:text-gray-400">
          <div className="flex items-center gap-1.5">
            <MapPin size={14} className="text-treasure-500 shrink-0" />
            <span className="truncate">
              {sale.city}, {sale.state}
            </span>
          </div>
          <div className="flex items-center gap-1.5">
            <Calendar size={14} className="text-treasure-500 shrink-0" />
            <span>{dateDisplay}</span>
          </div>
          <div className="flex items-center gap-1.5">
            <Clock size={14} className="text-treasure-500 shrink-0" />
            <span>
              {sale.start_time} &ndash; {sale.end_time}
            </span>
          </div>
        </div>

        {/* Categories */}
        {sale.categories?.length > 0 && (
          <div className="mt-3 flex flex-wrap gap-1.5">
            {sale.categories.slice(0, 3).map((cat) => (
              <span key={cat} className="badge-category">
                {cat}
              </span>
            ))}
            {sale.categories.length > 3 && (
              <span className="badge-category">+{sale.categories.length - 3}</span>
            )}
          </div>
        )}

        {/* Price indicator */}
        {(sale.price_min != null || sale.price_max != null || sale.has_free_items) && (
          <div className="mt-2 flex items-center gap-2 text-xs text-gray-500">
            {sale.price_min != null && sale.price_max != null && (
              <span>${(sale.price_min / 100).toFixed(0)} - ${(sale.price_max / 100).toFixed(0)}</span>
            )}
            {sale.has_free_items && (
              <span className="bg-green-100 text-green-700 px-1.5 py-0.5 rounded-full">Free items!</span>
            )}
          </div>
        )}
      </div>
    </Link>
  );
}
