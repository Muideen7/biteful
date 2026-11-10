import React from 'react';
import { View, Text, TouchableOpacity, TextInput } from 'react-native';
import { useRouter } from 'expo-router';
import { MapPin, Bell, CaretDown, MagnifyingGlass, SlidersHorizontal } from 'phosphor-react-native';
import { useSessionStore } from '@/stores/useSessionStore';

interface HomeHeaderProps {
  searchQuery: string;
  setSearchQuery: (q: string) => void;
  onPressAddress?: () => void;
  onPressNotifications?: () => void;
}

export function HomeHeader({
  searchQuery,
  setSearchQuery,
  onPressAddress,
  onPressNotifications,
}: HomeHeaderProps) {
  const router = useRouter();
  const currentAddress = useSessionStore((s) => s.currentAddress());
  const profile = useSessionStore((s) => s.profile);
  const unreadCount = useSessionStore(
    (s) => s.notifications.filter((n) => !n.read).length
  );

  const initial = profile.name?.charAt(0)?.toUpperCase() || 'F';

  return (
    <View
      className="bg-brand-primary pt-3 pb-5 px-4 shadow-sm"
      style={{
        borderBottomLeftRadius: 32,
        borderBottomRightRadius: 32,
      }}
    >
      {/* Top row: Avatar + Deliver To + Notification Bell */}
      <View className="flex-row items-center justify-between mb-4">
        {/* Left: Avatar with Initial */}
        <TouchableOpacity
          activeOpacity={0.8}
          onPress={() => router.push('/(tabs)/profile')}
          className="w-10 h-10 rounded-full bg-white/25 border-2 border-white items-center justify-center shadow-xs"
        >
          <Text className="text-white text-base font-black">
            {initial}
          </Text>
        </TouchableOpacity>

        {/* Center: Deliver to Address */}
        <TouchableOpacity
          activeOpacity={0.8}
          onPress={onPressAddress}
          className="flex-1 mx-3 items-center justify-center"
        >
          <View className="flex-row items-center">
            <MapPin size={13} weight="fill" color="#FFAA00" />
            <Text className="text-xs font-bold text-white/85 ml-1 tracking-wide">
              Deliver to
            </Text>
            <View className="ml-1">
              <CaretDown size={11} weight="bold" color="#FFFFFF" />
            </View>
          </View>
          <Text
            numberOfLines={1}
            className="text-xs font-black text-white text-center mt-0.5"
          >
            {currentAddress.label} • {currentAddress.line}
          </Text>
        </TouchableOpacity>

        {/* Right: Notification Bell */}
        <TouchableOpacity
          activeOpacity={0.8}
          onPress={onPressNotifications}
          className="w-10 h-10 rounded-full bg-white/20 border border-white/30 items-center justify-center relative shadow-xs"
        >
          <Bell size={20} weight="regular" color="#FFFFFF" />
          {unreadCount > 0 && (
            <View className="absolute top-2 right-2 w-2.5 h-2.5 rounded-full bg-brand-honey border border-brand-primary" />
          )}
        </TouchableOpacity>
      </View>

      {/* Integrated Search Bar Pill */}
      <View className="flex-row items-center bg-white dark:bg-[#231F1C] rounded-full px-4 py-2.5 shadow-sm">
        <MagnifyingGlass size={18} weight="bold" color="#8A8179" />
        <TextInput
          placeholder="Search dishes or restaurants..."
          placeholderTextColor="#8A8179"
          value={searchQuery}
          onChangeText={setSearchQuery}
          className="flex-1 ml-2.5 text-sm text-ink dark:text-ink-darkDefault font-medium"
        />
        <TouchableOpacity
          activeOpacity={0.7}
          onPress={() => router.push('/search')}
          className="p-1 ml-1"
        >
          <SlidersHorizontal size={18} weight="bold" color="#FF5A36" />
        </TouchableOpacity>
      </View>
    </View>
  );
}
