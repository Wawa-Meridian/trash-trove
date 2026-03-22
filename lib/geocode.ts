interface GeocodeResult {
  latitude: number;
  longitude: number;
}

// Google Maps Geocoding API (primary)
async function geocodeWithGoogle(
  address: string,
  city: string,
  state: string,
  zip: string
): Promise<GeocodeResult | null> {
  const apiKey = process.env.GOOGLE_MAPS_API_KEY;
  if (!apiKey) return null;

  const query = `${address}, ${city}, ${state} ${zip}, USA`;
  const params = new URLSearchParams({
    address: query,
    key: apiKey,
  });

  try {
    const res = await fetch(
      `https://maps.googleapis.com/maps/api/geocode/json?${params}`
    );

    if (!res.ok) return null;

    const data = await res.json();
    if (data.status !== 'OK' || data.results.length === 0) return null;

    const { lat, lng } = data.results[0].geometry.location;
    return { latitude: lat, longitude: lng };
  } catch {
    return null;
  }
}

// Nominatim / OpenStreetMap (fallback)
async function geocodeWithNominatim(
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
        headers: { 'User-Agent': 'TrashTrove/0.4.0 (garage-sale-finder)' },
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

// Try Google first, fall back to Nominatim
export async function geocodeAddress(
  address: string,
  city: string,
  state: string,
  zip: string
): Promise<GeocodeResult | null> {
  const result = await geocodeWithGoogle(address, city, state, zip);
  if (result) return result;
  return geocodeWithNominatim(address, city, state, zip);
}
