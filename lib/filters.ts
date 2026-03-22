import type { SupabaseClient } from '@supabase/supabase-js';

export interface FilterParams {
  categories?: string;
  dateFrom?: string;
  dateTo?: string;
  priceMin?: string;
  priceMax?: string;
  freeItems?: string;
}

/**
 * Applies filter search params to a Supabase query on garage_sales.
 * Returns the modified query builder.
 */
export function applyFilters<T>(
  query: any,
  filters: FilterParams,
): any {
  if (filters.categories) {
    const catArray = filters.categories.split(',').map((c) => c.trim()).filter(Boolean);
    if (catArray.length > 0) {
      query = query.overlaps('categories', catArray);
    }
  }

  if (filters.dateFrom) {
    query = query.gte('sale_date', filters.dateFrom);
  }

  if (filters.dateTo) {
    query = query.lte('sale_date', filters.dateTo);
  }

  if (filters.priceMin) {
    query = query.gte('price_min', parseInt(filters.priceMin));
  }

  if (filters.priceMax) {
    query = query.lte('price_max', parseInt(filters.priceMax));
  }

  if (filters.freeItems === 'true') {
    query = query.eq('has_free_items', true);
  }

  return query;
}
