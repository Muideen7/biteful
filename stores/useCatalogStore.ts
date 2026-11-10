import { create } from 'zustand';
import { FoodCategory, Product, Restaurant, PromoBanner, Deal } from '@/types/catalog';

import rawCategories from '@/assets/data/categories.json';
import rawProducts from '@/assets/data/products.json';
import rawRestaurants from '@/assets/data/restaurants.json';
import rawBanners from '@/assets/data/banners.json';
import rawDeals from '@/assets/data/deals.json';

const APP_NAME = 'Biteful';

// Replace {app} in banners
const banners: PromoBanner[] = (rawBanners as any[]).map((b) => ({
  ...b,
  lineOne: b.lineOne.replace('{app}', APP_NAME),
  lineTwo: b.lineTwo.replace('{app}', APP_NAME),
  subtitle: b.subtitle.replace('{app}', APP_NAME),
}));

interface CatalogState {
  categories: FoodCategory[];
  products: Product[];
  restaurants: Restaurant[];
  banners: PromoBanner[];
  deals: Deal[];
  selectedCategory: string | null;
  setSelectedCategory: (categoryId: string | null) => void;
  getProductById: (id: string) => Product | undefined;
  getRestaurantById: (id: string) => Restaurant | undefined;
  getProductsByRestaurant: (restaurantId: string) => Product[];
  getBestSellers: () => Product[];
  getFastDelivery: () => Product[];
}

export const useCatalogStore = create<CatalogState>((set, get) => ({
  categories: rawCategories as FoodCategory[],
  products: rawProducts as Product[],
  restaurants: rawRestaurants as Restaurant[],
  banners,
  deals: rawDeals as Deal[],
  selectedCategory: null,

  setSelectedCategory: (categoryId) =>
    set((state) => ({
      selectedCategory: state.selectedCategory === categoryId ? null : categoryId,
    })),

  getProductById: (id) => get().products.find((p) => p.id === id),
  getRestaurantById: (id) => get().restaurants.find((r) => r.id === id),
  getProductsByRestaurant: (restaurantId) =>
    get().products.filter((p) => p.restaurantId === restaurantId),
  getBestSellers: () => {
    const { products, selectedCategory } = get();
    let filtered = products.filter((p) => p.bestSeller);
    if (selectedCategory) {
      filtered = filtered.filter((p) => p.categoryId === selectedCategory);
    }
    return filtered;
  },
  getFastDelivery: () => get().products.filter((p) => p.fastDelivery),
}));
