# TrashTrove

Find weekend garage sales near you. Browse by state and city, discover hidden gems, or list your own sale for free.

## Tech Stack

- **Framework:** Next.js 15 (App Router)
- **Styling:** Tailwind CSS
- **Database:** Supabase (PostgreSQL + Storage)
- **Language:** TypeScript

## Getting Started

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up Supabase:**
   - Create a project at [supabase.com](https://supabase.com)
   - Run `lib/schema.sql` in the SQL Editor
   - Copy `.env.example` to `.env.local` and fill in your keys

3. **Run the dev server:**
   ```bash
   npm run dev
   ```

4. Open [http://localhost:3000](http://localhost:3000)

## Features

- Browse garage sales by state and city
- Full-text search across listings
- Photo uploads for sale items
- Create and list your own garage sale
- Mobile-friendly responsive design
