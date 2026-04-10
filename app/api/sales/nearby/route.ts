import { NextRequest, NextResponse } from 'next/server';
import { createSupabaseServer } from '@/lib/supabase-server';

export async function GET(req: NextRequest) {
  const supabase = await createSupabaseServer();
  const { searchParams } = req.nextUrl;
  const latParam = searchParams.get('lat');
  const lngParam = searchParams.get('lng');
  const radiusParam = searchParams.get('radius');

  if (!latParam || !lngParam) {
    return NextResponse.json(
      { error: 'Missing required parameters: lat, lng' },
      { status: 400 }
    );
  }

  const user_lat = parseFloat(latParam);
  const user_lng = parseFloat(lngParam);

  if (isNaN(user_lat) || isNaN(user_lng)) {
    return NextResponse.json(
      { error: 'Invalid lat/lng values' },
      { status: 400 }
    );
  }

  if (user_lat < -90 || user_lat > 90 || user_lng < -180 || user_lng > 180) {
    return NextResponse.json(
      { error: 'lat must be between -90 and 90, lng between -180 and 180' },
      { status: 400 }
    );
  }

  const radius_miles = Math.min(
    Math.max(parseFloat(radiusParam ?? '25') || 25, 1),
    100
  );

  const { data, error } = await supabase.rpc('nearby_sales', {
    user_lat,
    user_lng,
    radius_miles,
  });

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  // Fetch photos for the returned sales
  const saleIds = (data ?? []).map((s: { id: string }) => s.id);

  let photosMap: Record<string, Array<{ id: string; url: string; display_order: number }>> = {};
  let datesMap: Record<string, Array<{ id: string; sale_date: string; start_time: string; end_time: string }>> = {};

  if (saleIds.length > 0) {
    const [{ data: photos }, { data: saleDates }] = await Promise.all([
      supabase
        .from('sale_photos')
        .select('*')
        .in('sale_id', saleIds)
        .order('display_order', { ascending: true }),
      supabase
        .from('sale_dates')
        .select('*')
        .in('sale_id', saleIds)
        .order('sale_date', { ascending: true }),
    ]);

    if (photos) {
      photosMap = photos.reduce(
        (acc: typeof photosMap, photo: { sale_id: string; id: string; url: string; display_order: number }) => {
          const existing = acc[photo.sale_id] ?? [];
          return { ...acc, [photo.sale_id]: [...existing, photo] };
        },
        {} as typeof photosMap
      );
    }

    if (saleDates) {
      datesMap = saleDates.reduce(
        (acc: typeof datesMap, d: { sale_id: string; id: string; sale_date: string; start_time: string; end_time: string }) => {
          const existing = acc[d.sale_id] ?? [];
          return { ...acc, [d.sale_id]: [...existing, d] };
        },
        {} as typeof datesMap
      );
    }
  }

  const salesWithPhotos = (data ?? []).map((sale: { id: string; distance_miles: number }) => ({
    ...sale,
    photos: photosMap[sale.id] ?? [],
    sale_dates: datesMap[sale.id] ?? [],
  }));

  return NextResponse.json({
    sales: salesWithPhotos,
    total: salesWithPhotos.length,
    radius_miles,
  });
}
