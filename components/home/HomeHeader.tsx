import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { MapPin, Bell, CaretDown } from 'phosphor-react-native';
import { Wordmark } from '@/components/common/Wordmark';
import { useSessionStore } from '@/stores/useSessionStore';

interface HomeHeaderProps {
  onPressAddress?: () => void;
  onPressNotifications?: () => void;
}

export function HomeHeader({
  onPressAddress,
  onPressNotifications,
}: HomeHeaderProps) {
  const currentAddress = useSessionStore((s) => s.currentAddress());
  const unreadCount = useSessionStore(
    (s) => s.notifications.filter((n) => !n.read).length
  );

  return (
    <View className="px-4 pt-3 pb-3 bg-paper-light dark:bg-paper-dark border-b border-line-light dark:border-line-dark">
      {/* Top row: Wordmark + Notification Icon */}
      <View className="flex-row items-center justify-between">
        <Wordmark size="md" />

        <TouchableOpacity
          activeOpacity={0.7}
          onPress={onPressNotifications}
          className="w-10 h-10 rounded-full bg-card-light dark:bg-card-dark border border-line-light dark:border-line-dark items-center justify-center relative"
        >
          <Bell size={20} weight="regular" color="#181512" />
          {unreadCount > 0 && (
            <View className="absolute top-2 right-2 w-2.5 h-2.5 rounded-full bg-brand-primary" />
          )}
        </TouchableOpacity>
      </View>

      {/* Deliver To Row */}
      <TouchableOpacity
        activeOpacity={0.7}
        onPress={onPressAddress}
        className="flex-row items-center mt-2.5"
      >
        <View className="w-7 h-7 rounded-full bg-brand-wash dark:bg-brand-washDark items-center justify-center mr-2">
          <MapPin size={16} weight="fill" color="#FF5A36" />
        </View>
        <View className="flex-1">
          <View className="flex-row items-center">
            <Text className="text-xs font-semibold text-ink-muted uppercase tracking-wider">
              Deliver to
            </Text>
            <View className="ml-1">
              <CaretDown size={12} weight="bold" color="#8A8179" />
            </View>
          </View>
          <Text
            numberOfLines={1}
            className="text-sm font-bold text-ink dark:text-ink-darkDefault"
          >
            {currentAddress.label} • {currentAddress.line}
          </Text>
        </View>
      </TouchableOpacity>
    </View>
  );
}
