import { NextRequest, NextResponse } from 'next/server';
import { createSupabaseServer } from '@/lib/supabase-server';

interface RouteContext {
  params: Promise<{ id: string }>;
}

export async function DELETE(req: NextRequest, context: RouteContext) {
  const supabase = await createSupabaseServer();
  const { id } = await context.params;

  // Verify admin
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { data: profile } = await supabase
    .from('profiles')
    .select('is_admin')
    .eq('id', user.id)
    .single();

  if (!profile?.is_admin) {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
  }

  const { error } = await supabase
    .from('sale_reports')
    .delete()
    .eq('id', id);

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  // Log admin action
  await supabase.from('admin_actions').insert({
    admin_id: user.id,
    action_type: 'dismiss_report',
    target_report_id: id,
  });

  return NextResponse.json({ success: true });
}
