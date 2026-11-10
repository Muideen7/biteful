import { create } from 'zustand';
import { Product, Deal, MoneyCents } from '@/types/catalog';

export interface CartLine {
  product: Product;
  quantity: number;
}

interface CartState {
  lines: CartLine[];
  appliedDeal: Deal | null;

  addItem: (product: Product) => void;
  removeItem: (productId: string) => void;
  updateQuantity: (productId: string, quantity: number) => void;
  applyDeal: (deal: Deal | null) => void;
  clearCart: () => void;

  itemCount: () => number;
  subtotalCents: () => MoneyCents;
  discountCents: () => MoneyCents;
  deliveryFeeCents: () => MoneyCents;
  totalCents: () => MoneyCents;
}

export const useCartStore = create<CartState>((set, get) => ({
  lines: [],
  appliedDeal: null,

  addItem: (product) =>
    set((state) => {
      const existing = state.lines.find((l) => l.product.id === product.id);
      if (existing) {
        return {
          lines: state.lines.map((l) =>
            l.product.id === product.id ? { ...l, quantity: l.quantity + 1 } : l
          ),
        };
      }
      return { lines: [...state.lines, { product, quantity: 1 }] };
    }),

  removeItem: (productId) =>
    set((state) => ({
      lines: state.lines.filter((l) => l.product.id !== productId),
    })),

  updateQuantity: (productId, quantity) =>
    set((state) => {
      if (quantity <= 0) {
        return { lines: state.lines.filter((l) => l.product.id !== productId) };
      }
      return {
        lines: state.lines.map((l) =>
          l.product.id === productId ? { ...l, quantity } : l
        ),
      };
    }),

  applyDeal: (deal) => set({ appliedDeal: deal }),
  clearCart: () => set({ lines: [], appliedDeal: null }),

  itemCount: () => get().lines.reduce((acc, line) => acc + line.quantity, 0),

  subtotalCents: () =>
    get().lines.reduce((acc, line) => acc + line.product.priceCents * line.quantity, 0),

  discountCents: () => {
    const { appliedDeal, subtotalCents } = get();
    if (!appliedDeal) return 0;
    const subtotal = subtotalCents();
    if (subtotal < appliedDeal.minSpendCents) return 0;

    if (appliedDeal.kind === 'percent') {
      return Math.round((subtotal * appliedDeal.value) / 100);
    }
    if (appliedDeal.kind === 'flat') {
      return appliedDeal.value;
    }
    return 0;
  },

  deliveryFeeCents: () => {
    const { lines, appliedDeal } = get();
    if (lines.length === 0) return 0;
    if (appliedDeal?.kind === 'freeDelivery') return 0;
    // Standard flat delivery fee of $2.49 (249 cents)
    return 249;
  },

  totalCents: () => {
    const subtotal = get().subtotalCents();
    if (subtotal === 0) return 0;
    const discount = get().discountCents();
    const fee = get().deliveryFeeCents();
    return Math.max(0, subtotal - discount + fee);
  },
}));
