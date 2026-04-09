'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Loader2 } from 'lucide-react';
import { createSupabaseBrowser } from '@/lib/supabase';

export default function AuthCallbackPage() {
  const router = useRouter();

  useEffect(() => {
    let cancelled = false;

    async function handleCallback() {
      const supabase = createSupabaseBrowser();
      const params = new URLSearchParams(window.location.search);

      // Surface Supabase/OAuth provider errors early.
      const providerError = params.get('error') ?? params.get('error_description');
      if (providerError) {
        router.replace(`/auth/login?error=${encodeURIComponent(providerError)}`);
        return;
      }

      // PKCE flow — Supabase returns ?code=... which must be exchanged
      // client-side (the code verifier lives in this browser/webview).
      const code = params.get('code');
      if (code) {
        const { error } = await supabase.auth.exchangeCodeForSession(code);
        if (cancelled) return;
        if (error) {
          router.replace(`/auth/login?error=${encodeURIComponent(error.message)}`);
          return;
        }
        router.replace('/dashboard');
        router.refresh();
        return;
      }

      // Implicit flow (legacy) — tokens arrive in the URL hash. The
      // browser client's detectSessionInUrl:true will already have
      // persisted the session by the time this effect runs.
      const hashParams = new URLSearchParams(window.location.hash.replace(/^#/, ''));
      if (hashParams.get('access_token')) {
        router.replace('/dashboard');
        router.refresh();
        return;
      }

      router.replace('/auth/login?error=no_code');
    }

    handleCallback();
    return () => {
      cancelled = true;
    };
  }, [router]);

  return (
    <div className="flex items-center justify-center min-h-[400px]">
      <div className="text-center">
        <Loader2 size={32} className="animate-spin text-treasure-600 mx-auto mb-4" />
        <p className="text-gray-500">Signing you in...</p>
      </div>
    </div>
  );
}
