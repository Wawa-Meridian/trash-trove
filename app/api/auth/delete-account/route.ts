import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import { createSupabaseServer } from '@/lib/supabase-server';

/**
 * Deletes the currently authenticated user and all their data.
 *
 * Required by Apple App Store Guideline 5.1.1(v): apps with account
 * creation must offer in-app account deletion. We delete:
 *   - garage_sales rows owned by the user (cascades to sale_photos)
 *   - contact_messages sent to the user's sales
 *   - saved_searches owned by the user
 *   - the profiles row (cascades from auth.users)
 *   - the auth.users row itself (via service role)
 */
export async function POST() {
  const supabase = await createSupabaseServer();
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser();

  if (userError || !user) {
    return NextResponse.json(
      { error: 'Not authenticated' },
      { status: 401 }
    );
  }

  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;

  if (!serviceRoleKey || !supabaseUrl) {
    return NextResponse.json(
      { error: 'Account deletion is not configured on the server' },
      { status: 500 }
    );
  }

  // Service-role client bypasses RLS so we can fully clean up user data.
  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  // 1. Fetch sale ids first so we can cascade delete photos + messages.
  const { data: userSales } = await admin
    .from('garage_sales')
    .select('id')
    .eq('user_id', user.id);

  const saleIds = (userSales ?? []).map((s) => s.id);

  if (saleIds.length > 0) {
    await admin.from('contact_messages').delete().in('sale_id', saleIds);
    await admin.from('sale_photos').delete().in('sale_id', saleIds);
    await admin.from('garage_sales').delete().in('id', saleIds);
  }

  // 2. Remove saved searches (schema may not exist if migration 004 not run).
  await admin.from('saved_searches').delete().eq('user_id', user.id);

  // 3. Delete the auth user. This cascades to `profiles` via ON DELETE CASCADE.
  const { error: deleteError } = await admin.auth.admin.deleteUser(user.id);

  if (deleteError) {
    return NextResponse.json(
      { error: `Failed to delete account: ${deleteError.message}` },
      { status: 500 }
    );
  }

  // 4. Sign the user out on the server so the session cookie is cleared.
  await supabase.auth.signOut();

  return NextResponse.json({ success: true });
}
