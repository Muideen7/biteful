import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { ArrowLeft, Bell, Check } from 'phosphor-react-native';
import { useSessionStore } from '@/stores/useSessionStore';

export default function NotificationsScreen() {
  const router = useRouter();
  const { notifications, markNotificationRead } = useSessionStore();

  return (
    <SafeAreaView
      edges={['top']}
      className="flex-1 bg-paper-light dark:bg-paper-dark"
    >
      <View className="px-4 py-3 flex-row items-center justify-between border-b border-line-light dark:border-line-dark">
        <TouchableOpacity
          activeOpacity={0.7}
          onPress={() => router.back()}
          className="w-10 h-10 rounded-full bg-card-light dark:bg-card-dark border border-line-light dark:border-line-dark items-center justify-center"
        >
          <ArrowLeft size={20} weight="bold" color="#181512" />
        </TouchableOpacity>

        <Text className="text-lg font-bold text-ink dark:text-ink-darkDefault">
          Notifications
        </Text>

        <View className="w-10" />
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16 }}
      >
        {notifications.map((item) => (
          <TouchableOpacity
            key={item.id}
            activeOpacity={0.8}
            onPress={() => markNotificationRead(item.id)}
            className={`p-4 rounded-2xl mb-3 border ${
              item.read
                ? 'bg-card-light dark:bg-card-dark border-line-light dark:border-line-dark opacity-75'
                : 'bg-brand-wash dark:bg-brand-washDark border-brand-primary/20'
            }`}
          >
            <View className="flex-row items-start justify-between">
              <View className="flex-row items-center flex-1 pr-2">
                <View className="w-8 h-8 rounded-full bg-brand-primary/20 items-center justify-center mr-3">
                  <Bell size={18} weight={item.read ? 'regular' : 'fill'} color="#FF5A36" />
                </View>
                <View className="flex-1">
                  <Text className="text-base font-bold text-ink dark:text-ink-darkDefault">
                    {item.title}
                  </Text>
                  <Text className="text-xs text-ink-muted mt-0.5">
                    {item.minutesAgo} min ago
                  </Text>
                </View>
              </View>

              {!item.read && (
                <View className="w-2.5 h-2.5 rounded-full bg-brand-primary mt-1" />
              )}
            </View>

            <Text className="text-sm text-ink-soft dark:text-ink-darkSoft mt-2.5 leading-relaxed">
              {item.body}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </SafeAreaView>
  );
}
