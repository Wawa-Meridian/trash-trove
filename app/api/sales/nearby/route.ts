import { NextRequest, NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';

export async function GET(req: NextRequest) {
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

  if (saleIds.length > 0) {
    const { data: photos } = await supabase
      .from('sale_photos')
      .select('*')
      .in('sale_id', saleIds)
      .order('display_order', { ascending: true });

    if (photos) {
      photosMap = photos.reduce(
        (acc: Record<string, Array<{ id: string; url: string; display_order: number }>>, photo: { sale_id: string; id: string; url: string; display_order: number }) => {
          const existing = acc[photo.sale_id] ?? [];
          return { ...acc, [photo.sale_id]: [...existing, photo] };
        },
        {} as Record<string, Array<{ id: string; url: string; display_order: number }>>
      );
    }
  }

  const salesWithPhotos = (data ?? []).map((sale: { id: string; distance_miles: number }) => ({
    ...sale,
    photos: photosMap[sale.id] ?? [],
  }));

  return NextResponse.json({
    sales: salesWithPhotos,
    total: salesWithPhotos.length,
    radius_miles,
  });
}
