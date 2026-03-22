import { NextRequest, NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';

interface RouteContext {
  params: Promise<{ id: string }>;
}

export async function GET(req: NextRequest, context: RouteContext) {
  const { id } = await context.params;

  const { data, error } = await supabase
    .from('garage_sales')
    .select('*, photos:sale_photos(*)')
    .eq('id', id)
    .eq('is_active', true)
    .single();

  if (error || !data) {
    return NextResponse.json({ error: 'Sale not found' }, { status: 404 });
  }

  return NextResponse.json({ sale: data });
}

export async function PUT(req: NextRequest, context: RouteContext) {
  const { id } = await context.params;
  const body = await req.json();
  const { manage_token, ...updates } = body;

  if (!manage_token) {
    return NextResponse.json({ error: 'Manage token is required' }, { status: 401 });
  }

  // Verify the manage token
  const { data: existing, error: fetchError } = await supabase
    .from('garage_sales')
    .select('manage_token')
    .eq('id', id)
    .eq('is_active', true)
    .single();

  if (fetchError || !existing) {
    return NextResponse.json({ error: 'Sale not found' }, { status: 404 });
  }

  if (existing.manage_token !== manage_token) {
    return NextResponse.json({ error: 'Invalid manage token' }, { status: 403 });
  }

  // Only allow updating specific fields
  const allowedFields = [
    'title', 'description', 'categories', 'address', 'city',
    'state', 'zip', 'sale_date', 'start_time', 'end_time',
    'seller_name', 'seller_email',
  ];

  const sanitizedUpdates: Record<string, unknown> = {};
  for (const field of allowedFields) {
    if (updates[field] !== undefined) {
      const value = updates[field];
      if (typeof value === 'string') {
        sanitizedUpdates[field] = field === 'state' ? value.toUpperCase() : value.trim();
      } else {
        sanitizedUpdates[field] = value;
      }
    }
  }

  if (Object.keys(sanitizedUpdates).length === 0) {
    return NextResponse.json({ error: 'No valid fields to update' }, { status: 400 });
  }

  const { data: updated, error: updateError } = await supabase
    .from('garage_sales')
    .update(sanitizedUpdates)
    .eq('id', id)
    .select()
    .single();

  if (updateError) {
    return NextResponse.json({ error: updateError.message }, { status: 500 });
  }

  return NextResponse.json({ sale: updated });
}

export async function DELETE(req: NextRequest, context: RouteContext) {
  const { id } = await context.params;
  const body = await req.json();
  const { manage_token } = body;

  if (!manage_token) {
    return NextResponse.json({ error: 'Manage token is required' }, { status: 401 });
  }

  // Verify the manage token
  const { data: existing, error: fetchError } = await supabase
    .from('garage_sales')
    .select('manage_token')
    .eq('id', id)
    .eq('is_active', true)
    .single();

  if (fetchError || !existing) {
    return NextResponse.json({ error: 'Sale not found' }, { status: 404 });
  }

  if (existing.manage_token !== manage_token) {
    return NextResponse.json({ error: 'Invalid manage token' }, { status: 403 });
  }

  // Soft delete by setting is_active to false
  const { error: deleteError } = await supabase
    .from('garage_sales')
    .update({ is_active: false })
    .eq('id', id);

  if (deleteError) {
    return NextResponse.json({ error: deleteError.message }, { status: 500 });
  }

  return NextResponse.json({ success: true });
}
