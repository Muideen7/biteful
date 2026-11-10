import { FoodArt, MoneyCents } from './catalog';

export type OrderStatus = 'preparing' | 'onTheWay' | 'delivered';

export interface OrderItem {
  id: string;
  name: string;
  priceCents: MoneyCents;
  quantity: number;
  art: FoodArt;
}

export interface Order {
  id: string;
  restaurantId: string;
  restaurantName: string;
  status: OrderStatus;
  placedMinutesAgo: number;
  etaMinutes: number;
  addressLine: string;
  items: OrderItem[];
  subtotalCents: MoneyCents;
  deliveryFeeCents: MoneyCents;
  discountCents: MoneyCents;
  totalCents: MoneyCents;
}
