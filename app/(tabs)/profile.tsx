import React from 'react';
import { View, Text, ScrollView, TouchableOpacity, Switch, Alert } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import {
  MapPin,
  Moon,
  ClockCounterClockwise,
  SignOut,
  CaretRight,
  Receipt,
  Compass,
} from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useSessionStore } from '@/stores/useSessionStore';
import { useCartStore } from '@/stores/useCartStore';
import { Wordmark } from '@/components/common/Wordmark';

export default function ProfileScreen() {
  const router = useRouter();
  const { profile, addresses, isDarkMode, toggleDarkMode } = useSessionStore();
  const clearCart = useCartStore((s) => s.clearCart);

  const handleResetDemo = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
    Alert.alert(
      'Reset Demo Data',
      'This will reset your basket, addresses, and sample session back to fresh default state.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Reset',
          style: 'destructive',
          onPress: () => {
            clearCart();
            Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
          },
        },
      ]
    );
  };

  const handleSignOut = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    Alert.alert('Sign Out', 'Are you sure you want to sign out?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Sign Out',
        style: 'destructive',
        onPress: () => {
          router.replace('/(auth)/sign-in');
        },
      },
    ]);
  };

  return (
    <SafeAreaView
      edges={['top']}
      className="flex-1 bg-paper-light dark:bg-paper-dark"
    >
      <View className="px-4 py-3 border-b border-line-light dark:border-line-dark">
        <Text className="text-2xl font-bold tracking-tight text-ink dark:text-ink-darkDefault">
          My Account
        </Text>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16 }}
      >
        {/* User Card - Initial Letter Avatar */}
        <View className="bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-line-light dark:border-line-dark flex-row items-center mb-5 shadow-xs">
          <View
            style={{ width: 56, height: 56, minWidth: 56, minHeight: 56 }}
            className="rounded-full bg-brand-primary items-center justify-center shadow-xs"
          >
            <Text className="text-white text-2xl font-black">
              {profile.name?.charAt(0)?.toUpperCase() || 'F'}
            </Text>
          </View>
          <View className="ml-3.5 flex-1">
            <Text className="text-lg font-bold text-ink dark:text-ink-darkDefault">
              {profile.name || 'FrontendGeek'}
            </Text>
            <Text className="text-sm text-ink-muted">{profile.email || 'frontendgeek@biteful.com'}</Text>
            <Text className="text-xs text-ink-muted/80 mt-0.5">
              {profile.phone}
            </Text>
          </View>
        </View>

        {/* Orders Section */}
        <Text className="text-sm font-bold uppercase tracking-wider text-ink-muted mb-2 px-1">
          Orders & Activity
        </Text>
        <View className="bg-card-light dark:bg-card-dark rounded-2xl border border-line-light dark:border-line-dark mb-5 overflow-hidden">
          <TouchableOpacity
            activeOpacity={0.7}
            onPress={() => router.push('/orders')}
            className="p-3.5 flex-row items-center justify-between"
          >
            <View className="flex-row items-center">
              <Receipt size={18} weight="bold" color="#FF5A36" />
              <View className="ml-2.5">
                <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                  My Orders
                </Text>
                <Text className="text-xs text-ink-muted mt-0.5">
                  Track live orders & view history
                </Text>
              </View>
            </View>
            <CaretRight size={16} color="#8A8179" />
          </TouchableOpacity>
        </View>

        {/* Addresses Section */}
        <View className="flex-row items-center justify-between mb-2 px-1">
          <Text className="text-sm font-bold uppercase tracking-wider text-ink-muted">
            Saved Addresses
          </Text>
          <TouchableOpacity onPress={() => router.push('/addresses')}>
            <Text className="text-xs font-bold text-brand-primary">Manage</Text>
          </TouchableOpacity>
        </View>
        <View className="bg-card-light dark:bg-card-dark rounded-2xl border border-line-light dark:border-line-dark mb-5 overflow-hidden">
          {addresses.map((addr, idx) => (
            <TouchableOpacity
              key={addr.id}
              activeOpacity={0.7}
              onPress={() => router.push('/addresses')}
              className={`p-3.5 flex-row items-center justify-between ${
                idx !== addresses.length - 1
                  ? 'border-b border-line-light dark:border-line-dark'
                  : ''
              }`}
            >
              <View className="flex-row items-center flex-1 pr-2">
                <MapPin size={18} weight="fill" color="#FF5A36" />
                <View className="ml-2.5">
                  <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                    {addr.label}
                  </Text>
                  <Text
                    numberOfLines={1}
                    className="text-xs text-ink-muted mt-0.5"
                  >
                    {addr.line}
                  </Text>
                </View>
              </View>
              <CaretRight size={16} color="#8A8179" />
            </TouchableOpacity>
          ))}
        </View>

        {/* Settings & Preferences */}
        <Text className="text-sm font-bold uppercase tracking-wider text-ink-muted mb-2 px-1">
          Preferences & Account
        </Text>
        <View className="bg-card-light dark:bg-card-dark rounded-2xl border border-line-light dark:border-line-dark mb-6 overflow-hidden">
          {/* Dark Mode Switch */}
          <View className="p-3.5 flex-row items-center justify-between border-b border-line-light dark:border-line-dark">
            <View className="flex-row items-center">
              <Moon size={18} weight="bold" color="#FF5A36" />
              <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault ml-2.5">
                Dark Mode
              </Text>
            </View>
            <Switch
              value={isDarkMode}
              onValueChange={toggleDarkMode}
              trackColor={{ false: '#EFECE6', true: '#FF5A36' }}
              thumbColor="#FFFFFF"
            />
          </View>

          {/* App Tour & Onboarding */}
          <TouchableOpacity
            activeOpacity={0.7}
            onPress={() => router.push('/onboarding')}
            className="p-3.5 flex-row items-center justify-between border-b border-line-light dark:border-line-dark"
          >
            <View className="flex-row items-center">
              <Compass size={18} weight="bold" color="#FF5A36" />
              <View className="ml-2.5">
                <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                  App Tour & Onboarding
                </Text>
                <Text className="text-xs text-ink-muted mt-0.5">
                  Explore features & welcome guide
                </Text>
              </View>
            </View>
            <CaretRight size={16} color="#8A8179" />
          </TouchableOpacity>

          {/* Reset Demo Data */}
          <TouchableOpacity
            activeOpacity={0.7}
            onPress={handleResetDemo}
            className="p-3.5 flex-row items-center justify-between border-b border-line-light dark:border-line-dark"
          >
            <View className="flex-row items-center">
              <ClockCounterClockwise size={18} weight="bold" color="#FF5A36" />
              <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault ml-2.5">
                Reset Demo Data
              </Text>
            </View>
            <CaretRight size={16} color="#8A8179" />
          </TouchableOpacity>

          {/* Sign Out */}
          <TouchableOpacity
            activeOpacity={0.7}
            onPress={handleSignOut}
            className="p-3.5 flex-row items-center justify-between"
          >
            <View className="flex-row items-center">
              <SignOut size={18} weight="bold" color="#DC2626" />
              <Text className="text-sm font-bold text-red-600 ml-2.5">
                Sign Out
              </Text>
            </View>
            <CaretRight size={16} color="#8A8179" />
          </TouchableOpacity>
        </View>

        {/* Branding Footer */}
        <View className="items-center py-6">
          <Wordmark size="md" />
          <Text className="text-xs text-ink-muted mt-1">
            Good food, craved and delivered fast.
          </Text>
          <Text className="text-xs text-ink-muted/60 mt-0.5">
            Version 1.0.0 (NativeWind & Expo)
          </Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
