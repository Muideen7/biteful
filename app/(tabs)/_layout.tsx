import React from 'react';
import { View, Text } from 'react-native';
import { Tabs } from 'expo-router';
import {
  House,
  Heart,
  ShoppingBagOpen,
  Ticket,
  User,
} from 'phosphor-react-native';
import { useCartStore } from '@/stores/useCartStore';
import { useSessionStore } from '@/stores/useSessionStore';

export default function TabLayout() {
  const isDarkMode = useSessionStore((s) => s.isDarkMode);
  const itemCount = useCartStore((s) => s.itemCount());

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: '#FF5A36',
        tabBarInactiveTintColor: isDarkMode ? '#78716C' : '#8A8179',
        tabBarStyle: {
          backgroundColor: isDarkMode ? '#1C1917' : '#FFFFFF',
          borderTopColor: isDarkMode ? '#292524' : '#EFECE6',
          borderTopWidth: 1,
          height: 60,
          paddingBottom: 8,
          paddingTop: 6,
        },
        tabBarLabelStyle: {
          fontSize: 11,
          fontWeight: '600',
        },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ color, focused }) => (
            <House
              size={24}
              color={color}
              weight={focused ? 'fill' : 'regular'}
            />
          ),
        }}
      />
      <Tabs.Screen
        name="saved"
        options={{
          title: 'Saved',
          tabBarIcon: ({ color, focused }) => (
            <Heart
              size={24}
              color={color}
              weight={focused ? 'fill' : 'regular'}
            />
          ),
        }}
      />
      <Tabs.Screen
        name="cart"
        options={{
          title: 'Cart',
          tabBarIcon: ({ color, focused }) => (
            <View className="relative">
              <ShoppingBagOpen
                size={24}
                color={color}
                weight={focused ? 'fill' : 'regular'}
              />
              {itemCount > 0 && (
                <View className="absolute -top-1.5 -right-2.5 bg-brand-primary rounded-full min-w-4 h-4 px-1 items-center justify-center">
                  <Text className="text-white text-[10px] font-bold">
                    {itemCount}
                  </Text>
                </View>
              )}
            </View>
          ),
        }}
      />
      <Tabs.Screen
        name="offers"
        options={{
          title: 'Offers',
          tabBarIcon: ({ color, focused }) => (
            <Ticket
              size={24}
              color={color}
              weight={focused ? 'fill' : 'regular'}
            />
          ),
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ color, focused }) => (
            <User
              size={24}
              color={color}
              weight={focused ? 'fill' : 'regular'}
            />
          ),
        }}
      />
    </Tabs>
  );
}
