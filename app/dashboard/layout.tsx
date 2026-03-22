'use client';

import { useEffect, useState } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import Link from 'next/link';
import { LayoutDashboard, ShoppingBag, MessageSquare, Search, Loader2 } from 'lucide-react';
import { useAuth } from '@/components/AuthProvider';

const navItems = [
  { href: '/dashboard', label: 'My Sales', icon: ShoppingBag },
  { href: '/dashboard/messages', label: 'Messages', icon: MessageSquare },
  { href: '/dashboard/saved-searches', label: 'Saved Searches', icon: Search },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();
  const [redirecting, setRedirecting] = useState(false);

  useEffect(() => {
    if (!loading && !user) {
      setRedirecting(true);
      router.push('/auth/login');
    }
  }, [user, loading, router]);

  if (loading || redirecting) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <Loader2 size={32} className="animate-spin text-treasure-600" />
      </div>
    );
  }

  if (!user) return null;

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="flex items-center gap-3 mb-8">
        <LayoutDashboard size={24} className="text-treasure-600" />
        <h1 className="font-display text-3xl font-bold text-gray-900">
          Dashboard
        </h1>
      </div>

      <div className="flex flex-col sm:flex-row gap-8">
        {/* Sidebar */}
        <nav className="sm:w-48 flex sm:flex-col gap-1">
          {navItems.map(({ href, label, icon: Icon }) => {
            const isActive = pathname === href;
            return (
              <Link
                key={href}
                href={href}
                className={`flex items-center gap-2.5 px-4 py-2.5 rounded-lg text-sm font-medium transition-colors ${
                  isActive
                    ? 'bg-treasure-100 text-treasure-800'
                    : 'text-gray-600 hover:bg-gray-100'
                }`}
              >
                <Icon size={18} />
                {label}
              </Link>
            );
          })}
        </nav>

        {/* Content */}
        <div className="flex-1 min-w-0">{children}</div>
      </div>
    </div>
  );
}
