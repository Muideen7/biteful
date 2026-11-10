import { create } from 'zustand';

interface SavedState {
  savedProductIds: string[];
  toggleSaved: (productId: string) => void;
  isSaved: (productId: string) => boolean;
}

export const useSavedStore = create<SavedState>((set, get) => ({
  savedProductIds: ['p_cheeseburger', 'p_ramen_tonkotsu'],

  toggleSaved: (productId) =>
    set((state) => {
      const exists = state.savedProductIds.includes(productId);
      return {
        savedProductIds: exists
          ? state.savedProductIds.filter((id) => id !== productId)
          : [...state.savedProductIds, productId],
      };
    }),

  isSaved: (productId) => get().savedProductIds.includes(productId),
}));
