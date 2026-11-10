import React from 'react';
import { View, Text, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import {
  MapPin,
  PencilSimple,
  CaretRight,
  Receipt,
  User,
  ArrowClockwise,
  SignOut,
  Bicycle,
} from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useSessionStore } from '@/stores/useSessionStore';
import { useSavedStore } from '@/stores/useSavedStore';
import { useCartStore } from '@/stores/useCartStore';

export default function ProfileScreen() {
  const router = useRouter();
  const { profile, isDarkMode, toggleDarkMode, addresses } = useSessionStore();
  const savedProductIds = useSavedStore((s) => s.savedProductIds);
  const clearCart = useCartStore((s) => s.clearCart);

  const initial = profile.name?.charAt(0)?.toUpperCase() || 'F';
  const currentAddress = addresses[0]?.line || '12 Admiralty Way, Lekki Phase 1, Lagos';

  const handleResetDemo = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
    Alert.alert(
      'Reset Demo Data',
      'This will reset your basket, applied deals, and session back to defaults.',
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
    <View className="flex-1 bg-paper-light dark:bg-paper-dark">
      {/* Curved Tangerine Brand Header */}
      <View
        className="bg-brand-primary pt-12 pb-5 px-4 shadow-sm"
        style={{
          borderBottomLeftRadius: 32,
          borderBottomRightRadius: 32,
        }}
      >
        <Text className="text-2xl font-black text-white">Profile</Text>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16, paddingBottom: 60 }}
      >
        {/* User Profile Card */}
        <View className="bg-card-light dark:bg-card-dark rounded-3xl p-4 border border-line-light dark:border-line-dark flex-row items-center justify-between mb-4 shadow-2xs">
          <View className="flex-row items-center flex-1 mr-2">
            <View className="w-14 h-14 rounded-full bg-brand-primary items-center justify-center shadow-xs">
              <Text className="text-white text-2xl font-black">{initial}</Text>
            </View>
            <View className="ml-3.5 flex-1">
              <Text className="text-lg font-black text-ink dark:text-ink-darkDefault">
                {profile.name || 'FrontendGeek'}
              </Text>
              <Text className="text-xs text-ink-muted mt-0.5">
                {profile.email || 'frontendgeek@biteful.com'}
              </Text>
            </View>
          </View>

          <TouchableOpacity
            activeOpacity={0.7}
            className="w-9 h-9 rounded-full bg-paper-light dark:bg-paper-dark border border-line-light dark:border-line-dark items-center justify-center"
          >
            <PencilSimple size={16} color="#8A8179" />
          </TouchableOpacity>
        </View>

        {/* Quick Stat Cards */}
        <View className="flex-row gap-3 mb-6">
          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => router.push('/orders')}
            className="flex-1 bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-line-light dark:border-line-dark shadow-2xs"
          >
            <Text className="text-2xl font-black text-brand-primary">5</Text>
            <Text className="text-xs font-bold text-ink-muted mt-0.5">Orders</Text>
          </TouchableOpacity>

          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => router.push('/(tabs)/saved')}
            className="flex-1 bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-line-light dark:border-line-dark shadow-2xs"
          >
            <Text className="text-2xl font-black text-brand-primary">
              {savedProductIds.length || 4}
            </Text>
            <Text className="text-xs font-bold text-ink-muted mt-0.5">Saved</Text>
          </TouchableOpacity>
        </View>

        {/* Account Links */}
        <Text className="text-xs font-black uppercase tracking-wider text-ink-muted mb-2 px-1">
          Account
        </Text>
        <View className="bg-card-light dark:bg-card-dark rounded-2xl border border-line-light dark:border-line-dark mb-6 overflow-hidden shadow-2xs">
          {/* My Orders */}
          <TouchableOpacity
            activeOpacity={0.7}
            onPress={() => router.push('/orders')}
            className="p-4 flex-row items-center justify-between border-b border-line-light dark:border-line-dark"
          >
            <View className="flex-row items-center flex-1 mr-2">
              <View className="w-8 h-8 rounded-full bg-brand-wash dark:bg-brand-washDark items-center justify-center mr-3">
                <Receipt size={16} weight="bold" color="#FF5A36" />
              </View>
              <View className="flex-1">
                <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                  My orders
                </Text>
                <Text className="text-xs text-brand-primary font-semibold mt-0.5">
                  1 on the way
                </Text>
              </View>
            </View>
            <CaretRight size={16} color="#8A8179" />
          </TouchableOpacity>

          {/* Addresses */}
          <TouchableOpacity
            activeOpacity={0.7}
            onPress={() => router.push('/addresses')}
            className="p-4 flex-row items-center justify-between border-b border-line-light dark:border-line-dark"
          >
            <View className="flex-row items-center flex-1 mr-2">
              <View className="w-8 h-8 rounded-full bg-brand-wash dark:bg-brand-washDark items-center justify-center mr-3">
                <MapPin size={16} weight="bold" color="#FF5A36" />
              </View>
              <View className="flex-1">
                <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                  Addresses
                </Text>
                <Text numberOfLines={1} className="text-xs text-ink-muted mt-0.5">
                  Delivering to Home, {currentAddress}
                </Text>
              </View>
            </View>
            <CaretRight size={16} color="#8A8179" />
          </TouchableOpacity>

          {/* Personal Details */}
          <View className="p-4 flex-row items-center justify-between">
            <View className="flex-row items-center flex-1 mr-2">
              <View className="w-8 h-8 rounded-full bg-brand-wash dark:bg-brand-washDark items-center justify-center mr-3">
                <User size={16} weight="bold" color="#FF5A36" />
              </View>
              <View className="flex-1">
                <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                  Personal details
                </Text>
                <Text className="text-xs text-ink-muted mt-0.5">
                  {profile.name || 'FrontendGeek'} · {profile.phone || '+1 810 123 4567'}
                </Text>
              </View>
            </View>
            <CaretRight size={16} color="#8A8179" />
          </View>
        </View>

        {/* Appearance Control */}
        <Text className="text-xs font-black uppercase tracking-wider text-ink-muted mb-2 px-1">
          Appearance
        </Text>
        <View className="bg-card-light dark:bg-card-dark rounded-2xl p-2 border border-line-light dark:border-line-dark mb-6 flex-row shadow-2xs">
          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => isDarkMode && toggleDarkMode()}
            className={`flex-1 py-2.5 rounded-xl items-center justify-center ${
              !isDarkMode ? 'bg-brand-primary shadow-xs' : 'bg-transparent'
            }`}
          >
            <Text
              className={`text-xs font-bold ${
                !isDarkMode ? 'text-white' : 'text-ink-muted'
              }`}
            >
              Light
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => !isDarkMode && toggleDarkMode()}
            className={`flex-1 py-2.5 rounded-xl items-center justify-center ${
              isDarkMode ? 'bg-brand-primary shadow-xs' : 'bg-transparent'
            }`}
          >
            <Text
              className={`text-xs font-bold ${
                isDarkMode ? 'text-white' : 'text-ink-muted'
              }`}
            >
              Dark
            </Text>
          </TouchableOpacity>
        </View>

        {/* Demo Settings */}
        <Text className="text-xs font-black uppercase tracking-wider text-ink-muted mb-2 px-1">
          Demo Settings
        </Text>
        <View className="bg-card-light dark:bg-card-dark rounded-2xl border border-line-light dark:border-line-dark mb-6 overflow-hidden shadow-2xs">
          <TouchableOpacity
            activeOpacity={0.7}
            onPress={handleResetDemo}
            className="p-4 flex-row items-center justify-between border-b border-line-light dark:border-line-dark"
          >
            <View className="flex-row items-center flex-1 mr-2">
              <View className="w-8 h-8 rounded-full bg-brand-wash dark:bg-brand-washDark items-center justify-center mr-3">
                <ArrowClockwise size={16} weight="bold" color="#FF5A36" />
              </View>
              <View className="flex-1">
                <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                  Reset demo data
                </Text>
                <Text className="text-xs text-ink-muted mt-0.5">
                  Clears cart, saved items, orders and edits
                </Text>
              </View>
            </View>
            <CaretRight size={16} color="#8A8179" />
          </TouchableOpacity>

          <TouchableOpacity
            activeOpacity={0.7}
            onPress={handleSignOut}
            className="p-4 flex-row items-center justify-between"
          >
            <View className="flex-row items-center flex-1 mr-2">
              <View className="w-8 h-8 rounded-full bg-red-500/10 items-center justify-center mr-3">
                <SignOut size={16} weight="bold" color="#EF4444" />
              </View>
              <Text className="text-sm font-bold text-red-500">Sign out</Text>
            </View>
            <CaretRight size={16} color="#8A8179" />
          </TouchableOpacity>
        </View>
      </ScrollView>
    </View>
  );
}
