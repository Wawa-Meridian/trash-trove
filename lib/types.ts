export interface SaleDate {
  id: string;
  sale_id: string;
  sale_date: string;
  start_time: string;
  end_time: string;
}

export interface GarageSale {
  id: string;
  title: string;
  description: string;
  categories: string[];
  address: string;
  city: string;
  state: string;
  zip: string;
  latitude: number | null;
  longitude: number | null;
  sale_date: string;
  start_time: string;
  end_time: string;
  sale_dates?: SaleDate[];
  photos: SalePhoto[];
  seller_name: string;
  seller_email: string;
  user_id?: string | null;
  price_min?: number | null;
  price_max?: number | null;
  has_free_items?: boolean;
  created_at: string;
  is_active: boolean;
}

export interface SalePhoto {
  id: string;
  sale_id: string;
  url: string;
  caption: string | null;
  display_order: number;
}

export interface CreateSaleInput {
  title: string;
  description: string;
  categories: string[];
  address: string;
  city: string;
  state: string;
  zip: string;
  sale_date: string;
  start_time: string;
  end_time: string;
  seller_name: string;
  seller_email: string;
}

export const SALE_CATEGORIES = [
  'Furniture',
  'Clothing',
  'Electronics',
  'Books',
  'Toys & Games',
  'Kitchen & Dining',
  'Tools & Hardware',
  'Sports & Outdoors',
  'Collectibles & Antiques',
  'Baby & Kids',
  'Home Decor',
  'Garden & Patio',
  'Vehicles & Parts',
  'Musical Instruments',
  'Art & Crafts',
  'Jewelry & Accessories',
  'Everything Must Go',
  'Other',
] as const;

export const US_STATES: Record<string, string> = {
  AL: 'Alabama', AK: 'Alaska', AZ: 'Arizona', AR: 'Arkansas',
  CA: 'California', CO: 'Colorado', CT: 'Connecticut', DE: 'Delaware',
  FL: 'Florida', GA: 'Georgia', HI: 'Hawaii', ID: 'Idaho',
  IL: 'Illinois', IN: 'Indiana', IA: 'Iowa', KS: 'Kansas',
  KY: 'Kentucky', LA: 'Louisiana', ME: 'Maine', MD: 'Maryland',
  MA: 'Massachusetts', MI: 'Michigan', MN: 'Minnesota', MS: 'Mississippi',
  MO: 'Missouri', MT: 'Montana', NE: 'Nebraska', NV: 'Nevada',
  NH: 'New Hampshire', NJ: 'New Jersey', NM: 'New Mexico', NY: 'New York',
  NC: 'North Carolina', ND: 'North Dakota', OH: 'Ohio', OK: 'Oklahoma',
  OR: 'Oregon', PA: 'Pennsylvania', RI: 'Rhode Island', SC: 'South Carolina',
  SD: 'South Dakota', TN: 'Tennessee', TX: 'Texas', UT: 'Utah',
  VT: 'Vermont', VA: 'Virginia', WA: 'Washington', WV: 'West Virginia',
  WI: 'Wisconsin', WY: 'Wyoming', DC: 'District of Columbia',
};
