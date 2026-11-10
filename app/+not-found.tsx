import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Link, Stack, useRouter } from 'expo-router';
import { House, WarningCircle } from 'phosphor-react-native';
import { Wordmark } from '@/components/common/Wordmark';

export default function NotFoundScreen() {
  const router = useRouter();

  return (
    <>
      <Stack.Screen options={{ title: 'Page Not Found', headerShown: false }} />
      <SafeAreaView
        edges={['top', 'bottom']}
        className="flex-1 bg-paper-light dark:bg-paper-dark justify-center items-center px-6"
      >
        <View className="items-center max-w-sm w-full bg-card-light dark:bg-card-dark p-8 rounded-3xl border border-line-light dark:border-line-dark shadow-sm">
          <View className="w-16 h-16 rounded-full bg-brand-wash dark:bg-brand-washDark items-center justify-center mb-4">
            <WarningCircle size={36} weight="duotone" color="#FF5A36" />
          </View>

          <Wordmark size="md" />

          <Text className="text-xl font-black text-ink dark:text-ink-darkDefault mt-3 text-center">
            Page Not Found
          </Text>

          <Text className="text-sm text-ink-muted text-center mt-2 mb-6">
            This route does not exist. Dishly provides routes for browsing menus, dishes, restaurants, cart, offers, profile, orders, and addresses.
          </Text>

          <TouchableOpacity
            activeOpacity={0.88}
            onPress={() => router.replace('/(tabs)/')}
            className="w-full bg-brand-primary py-3.5 rounded-full flex-row items-center justify-center shadow-sm mb-3"
          >
            <House size={20} weight="bold" color="#FFFFFF" />
            <Text className="text-white font-extrabold text-base ml-2">
              Back to Home
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            activeOpacity={0.7}
            onPress={() => router.replace('/onboarding')}
            className="w-full py-2.5 items-center justify-center"
          >
            <Text className="text-sm font-bold text-ink-muted">
              Explore Onboarding Tour
            </Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    </>
  );
}

