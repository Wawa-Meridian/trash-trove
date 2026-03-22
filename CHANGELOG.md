# Changelog

All notable changes to TrashTrove will be documented in this file.

Format follows [Semantic Versioning](https://semver.org/).

## [0.3.0] - 2026-03-22

### Added

- Full-text search bar in navbar and homepage hero
- Search results page with query highlighting
- Edit/delete listings via manage token (no auth required)
- Manage link shown after creating a listing
- Contact seller form (replaces plaintext email exposure)
- Favorites system (localStorage-based) with dedicated /favorites page
- Favorite button on sale cards and detail pages
- Report/flag system with reason categories (spam, scam, inappropriate, duplicate, other)
- Share buttons (Copy Link, Facebook, X/Twitter) on sale detail pages
- SEO meta tags with dynamic OpenGraph for all pages
- Image optimization with Supabase thumbnail transforms
- In-memory rate limiting on sale creation (5/hr) and uploads (30/hr)
- Report rate limiting (5/hr per IP)

### Fixed

- get_state_counts() RPC function now exists in database (was missing, silently failing)

### Changed

- Seller email no longer publicly visible; replaced with contact form
- Sale creation returns manage_token for listing management

## [0.2.0] - 2026-03-22

### Added

- Automated weekly listing wipe via pg_cron
- Timezone-aware cleanup: listings delete at midnight Sunday→Monday per state timezone
- Covers all 6 US timezone groups (Eastern, Central, Mountain, Pacific, Alaska, Hawaii)
- DST handled automatically via PostgreSQL named timezones

## [0.1.0] - 2026-03-22

### Added

- Initial project scaffold with Next.js 15 (App Router)
- Supabase integration (PostgreSQL + Storage)
- Browse garage sales by state and city
- Full-text search across listings
- Photo uploads for sale items
- Create and list your own garage sale
- Mobile-friendly responsive design
- Tailwind CSS styling
- TypeScript throughout
