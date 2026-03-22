'use client';

import { Navigation } from 'lucide-react';
import { openExternal, getPlatform, hapticTap } from '@/lib/native';

interface Props {
  address: string;
  city: string;
  state: string;
  zip: string;
  className?: string;
}

export default function GetDirectionsButton({ address, city, state, zip, className }: Props) {
  const fullAddress = `${address}, ${city}, ${state} ${zip}`;
  const encoded = encodeURIComponent(fullAddress);

  const handleClick = async () => {
    await hapticTap();
    const platform = getPlatform();
    const url = platform === 'ios'
      ? `maps://maps.apple.com/?daddr=${encoded}`
      : `https://www.google.com/maps/dir/?api=1&destination=${encoded}`;

    await openExternal(url);
  };

  return (
    <button
      onClick={handleClick}
      className={`flex items-center justify-center gap-2 text-sm font-medium text-treasure-700 dark:text-treasure-400 bg-treasure-50 dark:bg-treasure-900/20 hover:bg-treasure-100 dark:hover:bg-treasure-900/30 py-2.5 px-4 rounded-lg transition-colors w-full ${className ?? ''}`}
    >
      <Navigation size={16} />
      Get Directions
    </button>
  );
}
