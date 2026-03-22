'use client';

import Link from 'next/link';
import { useState } from 'react';
import { Menu, X, MapPin, Plus, Heart, Locate, LayoutDashboard, LogIn, LogOut, User } from 'lucide-react';
import SearchBar from '@/components/SearchBar';
import ThemeToggle from '@/components/ThemeToggle';
import { useAuth } from '@/components/AuthProvider';

export default function Navbar() {
  const [isOpen, setIsOpen] = useState(false);
  const [showUserMenu, setShowUserMenu] = useState(false);
  const { user, loading, signOut } = useAuth();

  const handleSignOut = async () => {
    setShowUserMenu(false);
    await signOut();
    window.location.href = '/';
  };

  return (
    <nav className="bg-white dark:bg-gray-900 border-b border-gray-100 dark:border-gray-800 sticky top-0 z-50" role="navigation" aria-label="Main navigation">
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
              href="/nearby"
              className="flex items-center gap-1.5 text-gray-600 hover:text-treasure-700 transition-colors"
            >
              <Locate size={18} />
              Near Me
            </Link>
            <Link
              href="/browse"
              className="flex items-center gap-1.5 text-gray-600 hover:text-treasure-700 transition-colors"
            >
              <MapPin size={18} />
              Browse Sales
            </Link>
            <SearchBar className="w-64" />
            <Link
              href="/favorites"
              className="flex items-center gap-1.5 text-gray-600 hover:text-treasure-700 transition-colors"
            >
              <Heart size={18} />
              Favorites
            </Link>
            <Link href="/create" className="btn-primary flex items-center gap-1.5">
              <Plus size={18} />
              List Your Sale
            </Link>

            <ThemeToggle />

            {/* Auth section */}
            {!loading && (
              user ? (
                <div className="relative">
                  <button
                    onClick={() => setShowUserMenu(!showUserMenu)}
                    className="flex items-center gap-2 px-3 py-1.5 rounded-lg text-gray-600 hover:bg-gray-100 transition-colors"
                  >
                    <div className="w-7 h-7 rounded-full bg-treasure-100 flex items-center justify-center">
                      <User size={14} className="text-treasure-700" />
                    </div>
                    <span className="text-sm font-medium max-w-[100px] truncate">
                      {user.user_metadata?.full_name?.split(' ')[0] ?? 'Account'}
                    </span>
                  </button>

                  {showUserMenu && (
                    <>
                      <div
                        className="fixed inset-0 z-40"
                        onClick={() => setShowUserMenu(false)}
                      />
                      <div className="absolute right-0 top-full mt-1 w-48 bg-white rounded-lg shadow-lg border border-gray-200 py-1 z-50">
                        <Link
                          href="/dashboard"
                          className="flex items-center gap-2.5 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50"
                          onClick={() => setShowUserMenu(false)}
                        >
                          <LayoutDashboard size={16} />
                          Dashboard
                        </Link>
                        <button
                          onClick={handleSignOut}
                          className="flex items-center gap-2.5 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 w-full"
                        >
                          <LogOut size={16} />
                          Sign Out
                        </button>
                      </div>
                    </>
                  )}
                </div>
              ) : (
                <Link
                  href="/auth/login"
                  className="flex items-center gap-1.5 text-gray-600 hover:text-treasure-700 transition-colors text-sm font-medium"
                >
                  <LogIn size={18} />
                  Sign In
                </Link>
              )
            )}
          </div>

          {/* Mobile menu button */}
          <button
            className="md:hidden p-2 text-gray-600 dark:text-gray-300"
            onClick={() => setIsOpen(!isOpen)}
            aria-label="Toggle menu"
            aria-expanded={isOpen}
          >
            {isOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>

        {/* Mobile nav */}
        {isOpen && (
          <div className="md:hidden pb-4 space-y-2">
            <Link
              href="/nearby"
              className="flex items-center gap-2 px-3 py-2 rounded-lg text-gray-600 hover:bg-treasure-50"
              onClick={() => setIsOpen(false)}
            >
              <Locate size={18} />
              Near Me
            </Link>
            <Link
              href="/browse"
              className="flex items-center gap-2 px-3 py-2 rounded-lg text-gray-600 hover:bg-treasure-50"
              onClick={() => setIsOpen(false)}
            >
              <MapPin size={18} />
              Browse Sales
            </Link>
            <Link
              href="/favorites"
              className="flex items-center gap-2 px-3 py-2 rounded-lg text-gray-600 hover:bg-treasure-50"
              onClick={() => setIsOpen(false)}
            >
              <Heart size={18} />
              Favorites
            </Link>
            <Link
              href="/create"
              className="flex items-center gap-2 px-3 py-2 rounded-lg bg-treasure-600 text-white"
              onClick={() => setIsOpen(false)}
            >
              <Plus size={18} />
              List Your Sale
            </Link>

            {/* Mobile auth */}
            {!loading && (
              user ? (
                <>
                  <Link
                    href="/dashboard"
                    className="flex items-center gap-2 px-3 py-2 rounded-lg text-gray-600 hover:bg-treasure-50"
                    onClick={() => setIsOpen(false)}
                  >
                    <LayoutDashboard size={18} />
                    Dashboard
                  </Link>
                  <button
                    onClick={() => { setIsOpen(false); handleSignOut(); }}
                    className="flex items-center gap-2 px-3 py-2 rounded-lg text-gray-600 hover:bg-treasure-50 w-full"
                  >
                    <LogOut size={18} />
                    Sign Out
                  </button>
                </>
              ) : (
                <Link
                  href="/auth/login"
                  className="flex items-center gap-2 px-3 py-2 rounded-lg text-gray-600 hover:bg-treasure-50"
                  onClick={() => setIsOpen(false)}
                >
                  <LogIn size={18} />
                  Sign In
                </Link>
              )
            )}

            <SearchBar className="px-3 pt-2" />
          </div>
        )}
      </div>
    </nav>
  );
}
