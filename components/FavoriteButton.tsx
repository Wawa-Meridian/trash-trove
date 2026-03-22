'use client';

import { useState, useEffect } from 'react';
import { Heart } from 'lucide-react';

const STORAGE_KEY = 'trashtrove_favorites';

function getFavorites(): string[] {
  if (typeof window === 'undefined') return [];
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    return stored ? JSON.parse(stored) : [];
  } catch {
    return [];
  }
}

function setFavorites(favorites: string[]): void {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(favorites));
}

interface FavoriteButtonProps {
  saleId: string;
  className?: string;
  variant?: 'overlay' | 'default';
}

export default function FavoriteButton({ saleId, className = '', variant = 'overlay' }: FavoriteButtonProps) {
  const [isFavorited, setIsFavorited] = useState(false);
  const [isAnimating, setIsAnimating] = useState(false);

  useEffect(() => {
    const favorites = getFavorites();
    setIsFavorited(favorites.includes(saleId));
  }, [saleId]);

  function handleToggle(e: React.MouseEvent) {
    e.preventDefault();
    e.stopPropagation();

    setIsAnimating(true);
    setTimeout(() => setIsAnimating(false), 200);

    const favorites = getFavorites();
    const updated = isFavorited
      ? favorites.filter((id) => id !== saleId)
      : [...favorites, saleId];

    setFavorites(updated);
    setIsFavorited(!isFavorited);
  }

  return (
    <button
      onClick={handleToggle}
      className={`transition-transform duration-200 ${isAnimating ? 'scale-125' : 'scale-100'} ${className}`}
      aria-label={isFavorited ? 'Remove from favorites' : 'Add to favorites'}
    >
      <Heart
        size={20}
        className={
          isFavorited
            ? 'fill-red-500 text-red-500'
            : variant === 'overlay'
              ? 'text-white drop-shadow-md'
              : 'text-gray-400'
        }
      />
    </button>
  );
}
