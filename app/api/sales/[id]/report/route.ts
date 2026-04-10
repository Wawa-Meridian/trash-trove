import { NextRequest, NextResponse } from 'next/server';
import { createSupabaseServer } from '@/lib/supabase-server';
import { rateLimit } from '@/lib/rate-limit';

const VALID_REASONS = ['spam', 'inappropriate', 'scam', 'duplicate', 'other'] as const;

interface Props {
  params: Promise<{ id: string }>;
}

export async function POST(req: NextRequest, { params }: Props) {
  const supabase = await createSupabaseServer();
  const { id: saleId } = await params;

  // Get reporter IP
  const ip =
    req.headers.get('x-forwarded-for')?.split(',')[0]?.trim() ??
    req.headers.get('x-real-ip') ??
    'unknown';

  // Rate limit: 5 reports per hour per IP
  const { success: withinLimit } = rateLimit(`report:${ip}`, 5, 60 * 60 * 1000);

  if (!withinLimit) {
    return NextResponse.json(
      { error: 'Too many reports. Please try again later.' },
      { status: 429 }
    );
  }

  // Parse and validate body
  let body: { reason?: string; details?: string };
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: 'Invalid request body' }, { status: 400 });
  }

  const { reason, details } = body;

  if (!reason || !VALID_REASONS.includes(reason as (typeof VALID_REASONS)[number])) {
    return NextResponse.json(
      { error: 'Invalid reason. Must be one of: spam, inappropriate, scam, duplicate, other' },
      { status: 400 }
    );
  }

  // Insert report
  const { error } = await supabase.from('sale_reports').insert({
    sale_id: saleId,
    reason,
    details: details?.trim() || null,
    reporter_ip: ip,
  });

  if (error) {
    return NextResponse.json({ error: 'Failed to submit report' }, { status: 500 });
  }

  return NextResponse.json({ message: 'Report submitted' }, { status: 201 });
}
