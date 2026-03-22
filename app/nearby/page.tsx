'use client';

import { useState, useEffect, useCallback } from 'react';
import Link from 'next/link';
import { Loader2, MapPinOff, MapPin, Navigation } from 'lucide-react';
import SaleCard from '@/components/SaleCard';
import SaleMap from '@/components/SaleMap';
import type { GarageSale } from '@/lib/types';

type NearbyGarageSale = GarageSale & { distance_miles: number };

const RADIUS_OPTIONS = [10, 25, 50, 100] as const;

export default function NearbyPage() {
  const [status, setStatus] = useState<'loading' | 'denied' | 'ready'>('loading');
  const [userLocation, setUserLocation] = useState<{ lat: number; lng: number } | null>(null);
  const [radius, setRadius] = useState<number>(25);
  const [sales, setSales] = useState<NearbyGarageSale[]>([]);
  const [fetching, setFetching] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Request geolocation on mount
  useEffect(() => {
    if (!navigator.geolocation) {
      setStatus('denied');
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        setUserLocation({
          lat: position.coords.latitude,
          lng: position.coords.longitude,
        });
        setStatus('ready');
      },
      () => {
        setStatus('denied');
      },
      { enableHighAccuracy: false, timeout: 10000, maximumAge: 300000 }
    );
  }, []);

  // Fetch nearby sales when location or radius changes
  const fetchSales = useCallback(async (lat: number, lng: number, r: number) => {
    setFetching(true);
    setError(null);
    try {
      const res = await fetch(`/api/sales/nearby?lat=${lat}&lng=${lng}&radius=${r}`);
      if (!res.ok) {
        const body = await res.json();
        throw new Error(body.error ?? 'Failed to fetch nearby sales');
      }
      const data = await res.json();
      setSales(data.sales ?? []);
    } catch (err: any) {
      setError(err.message ?? 'Something went wrong');
      setSales([]);
    } finally {
      setFetching(false);
    }
  }, []);

  useEffect(() => {
    if (userLocation) {
      fetchSales(userLocation.lat, userLocation.lng, radius);
    }
  }, [userLocation, radius, fetchSales]);

  // Loading state
  if (status === 'loading') {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 text-center">
        <Loader2 size={40} className="animate-spin text-treasure-600 mx-auto mb-4" />
        <h1 className="font-display text-2xl font-bold text-gray-900 mb-2">
          Finding Sales Near You
        </h1>
        <p className="text-gray-500">Requesting your location...</p>
      </div>
    );
  }

  // Denied state
  if (status === 'denied') {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 text-center">
        <MapPinOff size={48} className="text-gray-400 mx-auto mb-4" />
        <h1 className="font-display text-2xl font-bold text-gray-900 mb-2">
          Location Access Required
        </h1>
        <p className="text-gray-500 max-w-md mx-auto mb-6">
          Location access is needed to find sales near you. Please enable location
          in your browser settings.
        </p>
        <Link href="/browse" className="btn-primary inline-flex items-center gap-2">
          <MapPin size={18} />
          Browse Sales Instead
        </Link>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <h1 className="font-display text-3xl font-bold text-gray-900 mb-2">
        Garage Sales Near You
      </h1>
      <p className="text-gray-500 mb-6">
        {fetching
          ? 'Searching for nearby sales...'
          : `${sales.length} sale${sales.length !== 1 ? 's' : ''} within ${radius} miles`}
      </p>

      {/* Map */}
      {userLocation && (
        <div className="card overflow-hidden mb-6">
          <SaleMap
            sales={sales}
            center={[userLocation.lat, userLocation.lng]}
            zoom={10}
            showLocateButton={true}
            onLocationFound={(lat, lng) => setUserLocation({ lat, lng })}
            className="h-[400px]"
          />
        </div>
      )}

      {/* Radius selector */}
      <div className="flex items-center gap-2 mb-8">
        <span className="text-sm font-medium text-gray-700 mr-1">Radius:</span>
        {RADIUS_OPTIONS.map((r) => (
          <button
            key={r}
            onClick={() => setRadius(r)}
            className={`px-4 py-1.5 rounded-full text-sm font-medium transition-colors ${
              radius === r
                ? 'bg-treasure-600 text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {r} mi
          </button>
        ))}
      </div>

      {/* Error state */}
      {error && (
        <div className="text-center py-10">
          <p className="text-red-500">{error}</p>
        </div>
      )}

      {/* Loading spinner for fetch */}
      {fetching && (
        <div className="flex justify-center py-10">
          <Loader2 size={32} className="animate-spin text-treasure-600" />
        </div>
      )}

      {/* Sales grid */}
      {!fetching && !error && sales.length > 0 && (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {sales.map((sale) => (
            <div key={sale.id} className="relative">
              <SaleCard sale={sale} />
              <span className="absolute top-2 left-2 bg-treasure-600 text-white text-xs font-medium px-2 py-1 rounded-full flex items-center gap-1 shadow-sm">
                <Navigation size={12} />
                {sale.distance_miles} mi away
              </span>
            </div>
          ))}
        </div>
      )}

      {/* Empty state */}
      {!fetching && !error && sales.length === 0 && (
        <div className="text-center py-16">
          <MapPinOff size={48} className="text-gray-300 mx-auto mb-4" />
          <p className="text-gray-400 text-lg mb-2">
            No garage sales found within {radius} miles
          </p>
          <p className="text-gray-400 text-sm mb-6">
            Try expanding your search radius or browse sales by location.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
            {radius < 100 && (
              <button
                onClick={() => setRadius(Math.min(radius * 2, 100))}
                className="btn-primary inline-flex items-center gap-2"
              >
                Expand to {Math.min(radius * 2, 100)} miles
              </button>
            )}
            <Link
              href="/browse"
              className="text-treasure-600 hover:text-treasure-700 font-medium text-sm"
            >
              Browse all sales
            </Link>
          </div>
        </div>
      )}
    </div>
  );
}
