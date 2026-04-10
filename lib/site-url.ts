/**
 * Canonical site URL. Prefer the env var so the same code works in dev,
 * preview, and production. Fallback is the production domain so server-side
 * redirects never silently point at localhost.
 */
export const SITE_URL =
  process.env.NEXT_PUBLIC_SITE_URL?.replace(/\/$/, '') ?? 'https://trashtrove.xyz';

/**
 * Build an absolute URL on the canonical origin.
 */
export function absoluteUrl(path: string): string {
  const normalized = path.startsWith('/') ? path : `/${path}`;
  return `${SITE_URL}${normalized}`;
}
