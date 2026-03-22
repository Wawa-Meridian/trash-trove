// Nominatim geocoding (free, no API key needed)
// Rate limit: 1 request per second, must include User-Agent

interface GeocodeResult {
  latitude: number;
  longitude: number;
}

export async function geocodeAddress(
  address: string,
  city: string,
  state: string,
  zip: string
): Promise<GeocodeResult | null> {
  const query = `${address}, ${city}, ${state} ${zip}, USA`;
  const params = new URLSearchParams({
    q: query,
    format: 'json',
    limit: '1',
    countrycodes: 'us',
  });

  try {
    const res = await fetch(
      `https://nominatim.openstreetmap.org/search?${params}`,
      {
        headers: { 'User-Agent': 'TrashTrove/0.3.0 (garage-sale-finder)' },
      }
    );

    if (!res.ok) return null;

    const data = await res.json();
    if (data.length === 0) return null;

    return {
      latitude: parseFloat(data[0].lat),
      longitude: parseFloat(data[0].lon),
    };
  } catch {
    return null;
  }
}
