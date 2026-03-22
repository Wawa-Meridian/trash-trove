'use client';

import { useState } from 'react';
import { ChevronLeft, ChevronRight, ImageIcon } from 'lucide-react';

interface Photo {
  id: string;
  url: string;
  caption: string | null;
}

export default function PhotoGallery({
  photos,
  title,
}: {
  photos: Photo[];
  title: string;
}) {
  const [current, setCurrent] = useState(0);

  if (photos.length === 0) {
    return (
      <div className="aspect-[4/3] bg-gray-100 rounded-xl flex items-center justify-center text-gray-300">
        <div className="text-center">
          <ImageIcon size={64} className="mx-auto mb-2" />
          <p>No photos</p>
        </div>
      </div>
    );
  }

  return (
    <div>
      {/* Main image */}
      <div className="aspect-[4/3] bg-gray-100 rounded-xl overflow-hidden relative group">
        <img
          src={photos[current].url}
          alt={photos[current].caption ?? `${title} photo ${current + 1}`}
          className="w-full h-full object-cover"
        />

        {photos.length > 1 && (
          <>
            <button
              onClick={() =>
                setCurrent((c) => (c - 1 + photos.length) % photos.length)
              }
              className="absolute left-3 top-1/2 -translate-y-1/2 bg-white/80 hover:bg-white rounded-full p-2 shadow-md opacity-0 group-hover:opacity-100 transition-opacity"
              aria-label="Previous photo"
            >
              <ChevronLeft size={20} />
            </button>
            <button
              onClick={() => setCurrent((c) => (c + 1) % photos.length)}
              className="absolute right-3 top-1/2 -translate-y-1/2 bg-white/80 hover:bg-white rounded-full p-2 shadow-md opacity-0 group-hover:opacity-100 transition-opacity"
              aria-label="Next photo"
            >
              <ChevronRight size={20} />
            </button>
            <span className="absolute bottom-3 right-3 bg-black/60 text-white text-sm px-3 py-1 rounded-full">
              {current + 1} / {photos.length}
            </span>
          </>
        )}

        {photos[current].caption && (
          <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent p-4 pt-8">
            <p className="text-white text-sm">{photos[current].caption}</p>
          </div>
        )}
      </div>

      {/* Thumbnails */}
      {photos.length > 1 && (
        <div className="flex gap-2 mt-3 overflow-x-auto pb-2">
          {photos.map((photo, i) => (
            <button
              key={photo.id}
              onClick={() => setCurrent(i)}
              className={`shrink-0 w-16 h-16 rounded-lg overflow-hidden border-2 transition-all ${
                i === current
                  ? 'border-treasure-500 opacity-100'
                  : 'border-transparent opacity-60 hover:opacity-100'
              }`}
            >
              <img
                src={photo.url}
                alt={photo.caption ?? `Thumbnail ${i + 1}`}
                className="w-full h-full object-cover"
              />
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
