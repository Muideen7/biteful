import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import {
  ArrowLeft,
  Bicycle,
  Bell,
  Tag,
  Check,
  CheckCircle,
} from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useSessionStore } from '@/stores/useSessionStore';

export default function NotificationsScreen() {
  const router = useRouter();
  const { notifications, markNotificationRead, markAllNotificationsRead } =
    useSessionStore();

  const handleMarkAll = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    markAllNotificationsRead();
  };

  const handlePressItem = (id: string) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    markNotificationRead(id);
  };

  return (
    <View className="flex-1 bg-paper-light dark:bg-paper-dark">
      {/* Curved Tangerine Brand Header */}
      <View
        className="bg-brand-primary pt-12 pb-5 px-4 shadow-sm"
        style={{
          borderBottomLeftRadius: 32,
          borderBottomRightRadius: 32,
        }}
      >
        <View className="flex-row items-center justify-between">
          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => router.back()}
            className="w-10 h-10 rounded-full bg-white/20 border border-white/30 items-center justify-center"
          >
            <ArrowLeft size={20} weight="bold" color="#FFFFFF" />
          </TouchableOpacity>

          <Text className="text-xl font-black text-white">
            Notifications
          </Text>

          <TouchableOpacity
            activeOpacity={0.8}
            onPress={handleMarkAll}
            className="px-3 py-1.5 rounded-full bg-white/20 border border-white/30"
          >
            <Text className="text-xs font-bold text-white">
              Mark all read
            </Text>
          </TouchableOpacity>
        </View>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16, paddingBottom: 48 }}
      >
        {notifications.map((item) => {
          const isUnread = !item.read;
          return (
            <TouchableOpacity
              key={item.id}
              activeOpacity={0.85}
              onPress={() => handlePressItem(item.id)}
              className={`p-4 rounded-2xl mb-3 border flex-row items-start justify-between shadow-2xs ${
                isUnread
                  ? 'bg-card-light dark:bg-card-dark border-brand-primary/30'
                  : 'bg-card-light/60 dark:bg-card-dark/60 border-line-light dark:border-line-dark opacity-80'
              }`}
            >
              <View className="flex-row items-start flex-1 mr-3">
                {/* Notification Icon */}
                <View
                  className={`w-10 h-10 rounded-full items-center justify-center mr-3 ${
                    isUnread
                      ? 'bg-brand-wash dark:bg-brand-washDark'
                      : 'bg-[#F2EDE8] dark:bg-[#231F1C]'
                  }`}
                >
                  {item.title.toLowerCase().includes('rider') ||
                  item.title.toLowerCase().includes('order') ? (
                    <Bicycle
                      size={20}
                      weight="bold"
                      color={isUnread ? '#FF5A36' : '#8A8179'}
                    />
                  ) : item.title.toLowerCase().includes('treat') ||
                    item.title.toLowerCase().includes('off') ? (
                    <Tag
                      size={20}
                      weight="fill"
                      color={isUnread ? '#FFAA00' : '#8A8179'}
                    />
                  ) : (
                    <Bell
                      size={20}
                      weight="fill"
                      color={isUnread ? '#FF5A36' : '#8A8179'}
                    />
                  )}
                </View>

                {/* Content */}
                <View className="flex-1">
                  <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                    {item.title}
                  </Text>
                  <Text className="text-xs leading-relaxed text-ink-muted mt-1">
                    {item.body}
                  </Text>
                  <Text className="text-[11px] text-ink-muted/80 mt-1.5 font-medium">
                    {item.minutesAgo < 60
                      ? `${item.minutesAgo} min ago`
                      : item.minutesAgo < 1440
                      ? `${Math.round(item.minutesAgo / 60)} h ago`
                      : `${Math.round(item.minutesAgo / 1440)} days ago`}
                  </Text>
                </View>
              </View>

              {/* Unread Indicator Dot */}
              {isUnread && (
                <View className="w-2.5 h-2.5 rounded-full bg-brand-primary mt-1" />
              )}
            </TouchableOpacity>
          );
        })}
      </ScrollView>
    </View>
  );
}
