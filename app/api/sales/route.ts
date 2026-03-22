import { NextRequest, NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';
import { rateLimit } from '@/lib/rate-limit';
import { geocodeAddress } from '@/lib/geocode';

export async function GET(req: NextRequest) {
  const { searchParams } = req.nextUrl;
  const ids = searchParams.getAll('ids');
  const state = searchParams.get('state');
  const city = searchParams.get('city');
  const search = searchParams.get('q');
  const limit = Math.min(parseInt(searchParams.get('limit') ?? '20'), 50);
  const offset = parseInt(searchParams.get('offset') ?? '0');

  // Batch fetch by IDs (used by favorites page)
  if (ids.length > 0) {
    const safeIds = ids.slice(0, 50);
    const { data, error } = await supabase
      .from('garage_sales')
      .select('*, photos:sale_photos(*)')
      .in('id', safeIds)
      .eq('is_active', true);

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    return NextResponse.json({ sales: data, total: data?.length ?? 0 });
  }

  const today = new Date().toISOString().split('T')[0];

  let query = supabase
    .from('garage_sales')
    .select('*, photos:sale_photos(*)', { count: 'exact' })
    .eq('is_active', true)
    .gte('sale_date', today)
    .order('sale_date', { ascending: true })
    .range(offset, offset + limit - 1);

  if (state) query = query.eq('state', state.toUpperCase());
  if (city) query = query.ilike('city', city);
  if (search) query = query.textSearch('fts', search);

  const { data, error, count } = await query;

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json({ sales: data, total: count });
}

export async function POST(req: NextRequest) {
  const ip =
    req.headers.get('x-forwarded-for')?.split(',')[0]?.trim() ??
    req.headers.get('x-real-ip') ??
    'unknown';
  const { success, remaining } = rateLimit(`sales:${ip}`, 5, 60 * 60 * 1000);

  if (!success) {
    return NextResponse.json(
      { error: 'Too many sales created. Please try again later.' },
      { status: 429, headers: { 'Retry-After': '3600' } }
    );
  }

  const body = await req.json();
  const {
    title,
    description,
    categories,
    address,
    city,
    state,
    zip,
    sale_date,
    start_time,
    end_time,
    seller_name,
    seller_email,
    photoUrls,
  } = body;

  // Basic validation
  if (!title || !description || !address || !city || !state || !zip || !sale_date) {
    return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
  }

  // Generate a manage token for anonymous edit/delete
  const manage_token = crypto.randomUUID();

  // Insert the sale
  const { data: sale, error: saleError } = await supabase
    .from('garage_sales')
    .insert({
      title: title.trim(),
      description: description.trim(),
      categories: categories ?? [],
      address: address.trim(),
      city: city.trim(),
      state: state.toUpperCase(),
      zip: zip.trim(),
      sale_date,
      start_time: start_time ?? '08:00',
      end_time: end_time ?? '14:00',
      seller_name: seller_name?.trim() ?? 'Anonymous',
      seller_email: seller_email?.trim() ?? '',
      manage_token,
    })
    .select()
    .single();

  if (saleError) {
    return NextResponse.json({ error: saleError.message }, { status: 500 });
  }

  // Geocode the address and update coordinates
  const coords = await geocodeAddress(
    sale.address,
    sale.city,
    sale.state,
    sale.zip
  );

  if (coords) {
    const { error: geoError } = await supabase
      .from('garage_sales')
      .update({ latitude: coords.latitude, longitude: coords.longitude })
      .eq('id', sale.id);

    if (geoError) {
      console.error('Failed to update coordinates:', geoError);
    }
  }

  // Insert photos
  if (photoUrls?.length > 0) {
    const photoRows = photoUrls.map((url: string, i: number) => ({
      sale_id: sale.id,
      url,
      display_order: i,
    }));

    const { error: photoError } = await supabase
      .from('sale_photos')
      .insert(photoRows);

    if (photoError) {
      console.error('Failed to insert photos:', photoError);
    }
  }

  return NextResponse.json({ id: sale.id, manage_token }, { status: 201 });
}
