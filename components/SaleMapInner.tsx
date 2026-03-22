'use client';

import { useRef } from 'react';
import L from 'leaflet';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import { Crosshair } from 'lucide-react';
import 'leaflet/dist/leaflet.css';

// Fix default marker icon issue with webpack/Next.js
L.Icon.Default.mergeOptions({
  iconRetinaUrl:
    'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl:
    'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl:
    'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
});

interface Sale {
  id: string;
  title: string;
  city: string;
  state: string;
  latitude: number | null;
  longitude: number | null;
  sale_date: string;
}

interface SaleMapInnerProps {
  sales?: Sale[];
  center?: [number, number];
  zoom?: number;
  singleMarker?: { lat: number; lng: number; title: string };
  className?: string;
  showLocateButton?: boolean;
  onLocationFound?: (lat: number, lng: number) => void;
}

function LocateButton({
  onLocationFound,
}: {
  onLocationFound?: (lat: number, lng: number) => void;
}) {
  const map = useMap();

  const handleLocate = () => {
    if (!navigator.geolocation) return;

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords;
        map.flyTo([latitude, longitude], 11);
        onLocationFound?.(latitude, longitude);
      },
      (error) => {
        console.error('Geolocation error:', error.message);
      }
    );
  };

  return (
    <button
      onClick={handleLocate}
      className="absolute bottom-4 right-4 z-[1000] rounded-lg bg-white p-2 shadow-md transition-colors hover:bg-gray-100"
      aria-label="Find my location"
      type="button"
    >
      <Crosshair className="h-5 w-5 text-gray-700" />
    </button>
  );
}

const DEFAULT_CENTER: [number, number] = [39.8283, -98.5795];
const DEFAULT_ZOOM = 4;

export default function SaleMapInner({
  sales,
  center,
  zoom,
  singleMarker,
  className,
  showLocateButton,
  onLocationFound,
}: SaleMapInnerProps) {
  const mapRef = useRef<L.Map | null>(null);

  const mapCenter = singleMarker
    ? ([singleMarker.lat, singleMarker.lng] as [number, number])
    : center ?? DEFAULT_CENTER;

  const mapZoom = singleMarker ? 15 : zoom ?? DEFAULT_ZOOM;

  const salesWithCoords = (sales ?? []).filter(
    (s): s is Sale & { latitude: number; longitude: number } =>
      s.latitude !== null && s.longitude !== null
  );

  return (
    <div className={`relative min-h-[400px] ${className ?? ''}`}>
      <MapContainer
        center={mapCenter}
        zoom={mapZoom}
        className="h-full w-full min-h-[400px] rounded-lg"
        ref={mapRef}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />

        {singleMarker && (
          <Marker position={[singleMarker.lat, singleMarker.lng]}>
            <Popup>{singleMarker.title}</Popup>
          </Marker>
        )}

        {!singleMarker &&
          salesWithCoords.map((sale) => (
            <Marker
              key={sale.id}
              position={[sale.latitude, sale.longitude]}
            >
              <Popup>
                <div className="text-sm">
                  <a
                    href={`/sale/${sale.id}`}
                    className="font-semibold text-blue-600 hover:underline"
                  >
                    {sale.title}
                  </a>
                  <p className="text-gray-600">
                    {sale.city}, {sale.state}
                  </p>
                  <p className="text-gray-500">{sale.sale_date}</p>
                </div>
              </Popup>
            </Marker>
          ))}

        {showLocateButton && (
          <LocateButton onLocationFound={onLocationFound} />
        )}
      </MapContainer>
    </div>
  );
}
