export type MoneyCents = number; // e.g. 1250 = $12.50

export interface FoodArt {
  main: string;
  side?: string | null;
}

export interface FoodCategory {
  id: string;
  name: string;
  art: FoodArt;
}

export interface Restaurant {
  id: string;
  name: string;
  cuisine: string;
  rating: number;
  minMinutes: number;
  maxMinutes: number;
  distanceKm: number;
  deliveryFeeCents: MoneyCents;
  art: FoodArt;
}

export interface Product {
  id: string;
  name: string;
  priceCents: MoneyCents;
  calories: number;
  minutes: number;
  categoryId: string;
  restaurantId: string;
  rating: number;
  bestSeller: boolean;
  fastDelivery: boolean;
  description: string;
  art: FoodArt;
}

export interface PromoBanner {
  id: string;
  style: 'rider' | 'art' | string;
  lineOne: string;
  lineTwo: string;
  subtitle: string;
  cta: string;
  dealId?: string | null;
  restaurantId?: string | null;
  art?: FoodArt | null;
}

export type DealKind = 'percent' | 'flat' | 'freeDelivery';

export interface Deal {
  id: string;
  code: string;
  eyebrow: string;
  headline: string;
  kind: DealKind;
  value: number; // Percent for 'percent', cents for 'flat'
  minSpendCents: MoneyCents;
  art: FoodArt;
  terms: string;
}
