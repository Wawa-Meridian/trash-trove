import Link from 'next/link';
import { MapPin, Clock, Calendar, ImageIcon } from 'lucide-react';
import { format, parseISO } from 'date-fns';
import type { GarageSale } from '@/lib/types';

export default function SaleCard({ sale }: { sale: GarageSale }) {
  const saleDate = parseISO(sale.sale_date);
  const coverPhoto = sale.photos?.[0]?.url;

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
        {sale.photos?.length > 1 && (
          <span className="absolute bottom-2 right-2 bg-black/60 text-white text-xs px-2 py-1 rounded-full">
            {sale.photos.length} photos
          </span>
        )}
      </div>

      {/* Details */}
      <div className="p-4">
        <h3 className="font-semibold text-gray-900 group-hover:text-treasure-700 transition-colors line-clamp-1">
          {sale.title}
        </h3>

        <div className="mt-2 space-y-1.5 text-sm text-gray-500">
          <div className="flex items-center gap-1.5">
            <MapPin size={14} className="text-treasure-500 shrink-0" />
            <span className="truncate">
              {sale.city}, {sale.state}
            </span>
          </div>
          <div className="flex items-center gap-1.5">
            <Calendar size={14} className="text-treasure-500 shrink-0" />
            <span>{format(saleDate, 'EEEE, MMMM d')}</span>
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
      </div>
    </Link>
  );
}
