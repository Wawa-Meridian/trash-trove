import { NextRequest, NextResponse } from 'next/server';
import { createSupabaseServer } from '@/lib/supabase-server';
import { sendContactNotification } from '@/lib/email';

interface RouteContext {
  params: Promise<{ id: string }>;
}

export async function POST(req: NextRequest, context: RouteContext) {
  const supabase = await createSupabaseServer();
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

  // Store the contact message so the seller can view it
  const { error: insertError } = await supabase
    .from('contact_messages')
    .insert({
      sale_id: sale.id,
      sender_name: name,
      sender_email: email,
      message,
    });

  if (insertError) {
    console.error('Failed to store contact message:', insertError);
    return NextResponse.json(
      { error: 'Failed to send message. Please try again later.' },
      { status: 500 },
    );
  }

  // Send email notification (fire-and-forget)
  try {
    await sendContactNotification({
      sellerEmail: sale.seller_email,
      sellerName: sale.seller_name,
      saleTitle: sale.title,
      saleId: sale.id,
      senderName: name,
      senderEmail: email,
      message,
    });
  } catch (err) {
    console.error('Email notification failed:', err);
  }

  return NextResponse.json({
    success: true,
    message: 'Your message has been sent to the seller',
  });
}
