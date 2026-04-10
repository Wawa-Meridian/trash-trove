import { format, parseISO, isEqual, addDays } from 'date-fns';
import type { SaleDate } from '@/lib/types';

/**
 * Formats sale dates for display.
 * - Single date: "Saturday, March 28"
 * - Consecutive: "Fri-Sun, Mar 27-29"
 * - Non-consecutive: "Mar 27, 29"
 */
export function formatSaleDates(saleDates: SaleDate[] | undefined, fallbackDate?: string): string {
  if (!saleDates || saleDates.length === 0) {
    if (!fallbackDate) return '';
    return format(parseISO(fallbackDate), 'EEEE, MMMM d');
  }

  const sorted = [...saleDates].sort(
    (a, b) => new Date(a.sale_date).getTime() - new Date(b.sale_date).getTime()
  );

  if (sorted.length === 1) {
    return format(parseISO(sorted[0].sale_date), 'EEEE, MMMM d');
  }

  // Check if consecutive
  const isConsecutive = sorted.every((d, i) => {
    if (i === 0) return true;
    const prev = parseISO(sorted[i - 1].sale_date);
    const curr = parseISO(d.sale_date);
    return isEqual(curr, addDays(prev, 1));
  });

  const first = parseISO(sorted[0].sale_date);
  const last = parseISO(sorted[sorted.length - 1].sale_date);

  if (isConsecutive) {
    return `${format(first, 'EEE')}-${format(last, 'EEE')}, ${format(first, 'MMM d')}-${format(last, 'd')}`;
  }

  // Non-consecutive: show each date
  return sorted.map((d) => format(parseISO(d.sale_date), 'MMM d')).join(', ');
}

/**
 * Formats sale date range for card display (shorter format).
 */
export function formatSaleDateShort(saleDates: SaleDate[] | undefined, fallbackDate?: string): string {
  if (!saleDates || saleDates.length === 0) {
    if (!fallbackDate) return '';
    return format(parseISO(fallbackDate), 'EEE, MMM d');
  }

  const sorted = [...saleDates].sort(
    (a, b) => new Date(a.sale_date).getTime() - new Date(b.sale_date).getTime()
  );

  if (sorted.length === 1) {
    return format(parseISO(sorted[0].sale_date), 'EEE, MMM d');
  }

  const first = parseISO(sorted[0].sale_date);
  const last = parseISO(sorted[sorted.length - 1].sale_date);

  return `${format(first, 'EEE')}-${format(last, 'EEE')}, ${format(first, 'MMM d')}-${format(last, 'd')}`;
}
