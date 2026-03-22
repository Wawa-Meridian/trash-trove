'use client';

import Link from 'next/link';
import { useState } from 'react';
import { Menu, X, MapPin, Plus } from 'lucide-react';

export default function Navbar() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <nav className="bg-white border-b border-gray-100 sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <Link href="/" className="flex items-center gap-2">
            <span className="text-2xl">🗑️</span>
            <span className="font-display text-xl font-bold text-treasure-800">
              TrashTrove
            </span>
          </Link>

          {/* Desktop nav */}
          <div className="hidden md:flex items-center gap-6">
            <Link
              href="/browse"
              className="flex items-center gap-1.5 text-gray-600 hover:text-treasure-700 transition-colors"
            >
              <MapPin size={18} />
              Browse Sales
            </Link>
            <Link href="/create" className="btn-primary flex items-center gap-1.5">
              <Plus size={18} />
              List Your Sale
            </Link>
          </div>

          {/* Mobile menu button */}
          <button
            className="md:hidden p-2 text-gray-600"
            onClick={() => setIsOpen(!isOpen)}
            aria-label="Toggle menu"
          >
            {isOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>

        {/* Mobile nav */}
        {isOpen && (
          <div className="md:hidden pb-4 space-y-2">
            <Link
              href="/browse"
              className="flex items-center gap-2 px-3 py-2 rounded-lg text-gray-600 hover:bg-treasure-50"
              onClick={() => setIsOpen(false)}
            >
              <MapPin size={18} />
              Browse Sales
            </Link>
            <Link
              href="/create"
              className="flex items-center gap-2 px-3 py-2 rounded-lg bg-treasure-600 text-white"
              onClick={() => setIsOpen(false)}
            >
              <Plus size={18} />
              List Your Sale
            </Link>
          </div>
        )}
      </div>
    </nav>
  );
}
