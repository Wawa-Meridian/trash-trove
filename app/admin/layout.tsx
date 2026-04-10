'use client';

import { useEffect, useState } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import Link from 'next/link';
import { Shield, Flag, ShoppingBag, BarChart3, Loader2 } from 'lucide-react';
import { useAuth } from '@/components/AuthProvider';
import { createSupabaseBrowser } from '@/lib/supabase';

const navItems = [
  { href: '/admin/reports', label: 'Reports', icon: Flag },
  { href: '/admin/sales', label: 'Sales', icon: ShoppingBag },
  { href: '/admin/analytics', label: 'Analytics', icon: BarChart3 },
];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();
  const [isAdmin, setIsAdmin] = useState<boolean | null>(null);

  useEffect(() => {
    if (authLoading) return;

    if (!user) {
      router.push('/auth/login');
      return;
    }

    const checkAdmin = async () => {
      const supabase = createSupabaseBrowser();
      const { data } = await supabase
        .from('profiles')
        .select('is_admin')
        .eq('id', user.id)
        .single();

      if (!data?.is_admin) {
        router.push('/');
        return;
      }

      setIsAdmin(true);
    };

    checkAdmin();
  }, [user, authLoading, router]);

  if (authLoading || isAdmin === null) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <Loader2 size={32} className="animate-spin text-treasure-600" />
      </div>
    );
  }

  if (!isAdmin) return null;

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="flex items-center gap-3 mb-8">
        <Shield size={24} className="text-red-600" />
        <h1 className="font-display text-3xl font-bold text-gray-900">
          Admin
        </h1>
      </div>

      <div className="flex flex-col sm:flex-row gap-8">
        <nav className="sm:w-48 flex sm:flex-col gap-1">
          {navItems.map(({ href, label, icon: Icon }) => {
            const isActive = pathname === href;
            return (
              <Link
                key={href}
                href={href}
                className={`flex items-center gap-2.5 px-4 py-2.5 rounded-lg text-sm font-medium transition-colors ${
                  isActive
                    ? 'bg-red-100 text-red-800'
                    : 'text-gray-600 hover:bg-gray-100'
                }`}
              >
                <Icon size={18} />
                {label}
              </Link>
            );
          })}
        </nav>

        <div className="flex-1 min-w-0">{children}</div>
      </div>
    </div>
  );
}
