import { NextRequest, NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';

interface RouteContext {
  params: Promise<{ id: string }>;
}

export async function POST(req: NextRequest, context: RouteContext) {
  const { id } = await context.params;
  const body = await req.json();
  const { name, email, message } = body;

  // Validate required fields
  if (!name || !email || !message) {
    return NextResponse.json(
      { error: 'Name, email, and message are required' },
      { status: 400 },
    );
  }

  // Validate email format
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return NextResponse.json({ error: 'Invalid email address' }, { status: 400 });
  }

  // Look up the sale to get seller info
  const { data: sale, error } = await supabase
    .from('garage_sales')
    .select('id, title, seller_email, seller_name')
    .eq('id', id)
    .eq('is_active', true)
    .single();

  if (error || !sale) {
    return NextResponse.json({ error: 'Sale not found' }, { status: 404 });
  }

  // Log the contact message (email sending can be added later)
  console.log('Contact message received:', {
    sale_id: sale.id,
    sale_title: sale.title,
    seller_email: sale.seller_email,
    from_name: name,
    from_email: email,
    message,
  });

  return NextResponse.json({ success: true });
}
