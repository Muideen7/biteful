import { create } from 'zustand';
import { Platform } from 'react-native';
import { colorScheme } from 'nativewind';
import { UserProfile, Address, AppNotification } from '@/types/account';
import rawProfile from '@/assets/data/profile.json';
import rawAddresses from '@/assets/data/addresses.json';
import rawNotifications from '@/assets/data/notifications.json';

interface SessionState {
  profile: UserProfile;
  addresses: Address[];
  selectedAddressId: string;
  notifications: AppNotification[];
  isDarkMode: boolean;
  hasCompletedOnboarding: boolean;

  setProfile: (profile: Partial<UserProfile>) => void;
  setSelectedAddress: (addressId: string) => void;
  toggleDarkMode: () => void;
  setDarkMode: (enabled: boolean) => void;
  completeOnboarding: () => void;
  markNotificationRead: (id: string) => void;
  markAllNotificationsRead: () => void;
  addAddress: (address: Omit<Address, 'id'>) => void;
  currentAddress: () => Address;
}

export const useSessionStore = create<SessionState>((set, get) => ({
  profile: rawProfile as UserProfile,
  addresses: rawAddresses as Address[],
  selectedAddressId: 'a_home',
  notifications: rawNotifications as AppNotification[],
  isDarkMode: false,
  hasCompletedOnboarding: false,

  setProfile: (update) =>
    set((state) => ({ profile: { ...state.profile, ...update } })),

  setSelectedAddress: (id) => set({ selectedAddressId: id }),

  addAddress: (newAddr) =>
    set((state) => {
      const id = `a_${Date.now()}`;
      return {
        addresses: [...state.addresses, { ...newAddr, id }],
        selectedAddressId: id,
      };
    }),

  toggleDarkMode: () => {
    const next = !get().isDarkMode;
    try {
      colorScheme.set(next ? 'dark' : 'light');
      if (Platform.OS === 'web' && typeof document !== 'undefined') {
        if (next) {
          document.documentElement.classList.add('dark');
        } else {
          document.documentElement.classList.remove('dark');
        }
      }
    } catch (e) {
      // fallback
    }
    set({ isDarkMode: next });
  },

  setDarkMode: (enabled: boolean) => {
    try {
      colorScheme.set(enabled ? 'dark' : 'light');
      if (Platform.OS === 'web' && typeof document !== 'undefined') {
        if (enabled) {
          document.documentElement.classList.add('dark');
        } else {
          document.documentElement.classList.remove('dark');
        }
      }
    } catch (e) {
      // fallback
    }
    set({ isDarkMode: enabled });
  },

  completeOnboarding: () => set({ hasCompletedOnboarding: true }),

  markNotificationRead: (id) =>
    set((state) => ({
      notifications: state.notifications.map((n) =>
        n.id === id ? { ...n, read: true } : n
      ),
    })),

  markAllNotificationsRead: () =>
    set((state) => ({
      notifications: state.notifications.map((n) => ({ ...n, read: true })),
    })),

  currentAddress: () => {
    const { addresses, selectedAddressId } = get();
    return addresses.find((a) => a.id === selectedAddressId) || addresses[0];
  },
}));
