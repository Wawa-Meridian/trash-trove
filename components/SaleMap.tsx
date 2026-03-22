'use client';

import dynamic from 'next/dynamic';

const SaleMapInner = dynamic(() => import('./SaleMapInner'), {
  ssr: false,
  loading: () => (
    <div className="flex min-h-[400px] items-center justify-center rounded-lg bg-gray-100">
      <p className="text-gray-500">Loading map...</p>
    </div>
  ),
});

interface SaleMapProps {
  sales?: Array<{
    id: string;
    title: string;
    city: string;
    state: string;
    latitude: number | null;
    longitude: number | null;
    sale_date: string;
  }>;
  center?: [number, number];
  zoom?: number;
  singleMarker?: { lat: number; lng: number; title: string };
  className?: string;
  showLocateButton?: boolean;
  onLocationFound?: (lat: number, lng: number) => void;
}

export default function SaleMap(props: SaleMapProps) {
  return <SaleMapInner {...props} />;
}
