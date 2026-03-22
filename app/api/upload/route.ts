import { NextRequest, NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';

export async function POST(req: NextRequest) {
  const formData = await req.formData();
  const file = formData.get('file') as File | null;

  if (!file) {
    return NextResponse.json({ error: 'No file provided' }, { status: 400 });
  }

  // Validate file type
  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
  if (!allowedTypes.includes(file.type)) {
    return NextResponse.json(
      { error: 'Invalid file type. Only JPG, PNG, and WebP are allowed.' },
      { status: 400 }
    );
  }

  // Validate file size (5MB)
  if (file.size > 5 * 1024 * 1024) {
    return NextResponse.json(
      { error: 'File too large. Maximum size is 5MB.' },
      { status: 400 }
    );
  }

  // Generate unique filename
  const ext = file.name.split('.').pop() ?? 'jpg';
  const filename = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}.${ext}`;
  const path = `sales/${filename}`;

  const arrayBuffer = await file.arrayBuffer();
  const buffer = new Uint8Array(arrayBuffer);

  const { error } = await supabase.storage
    .from('sale-photos')
    .upload(path, buffer, {
      contentType: file.type,
      cacheControl: '3600',
    });

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  const { data: urlData } = supabase.storage
    .from('sale-photos')
    .getPublicUrl(path);

  return NextResponse.json({ url: urlData.publicUrl });
}
