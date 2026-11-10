import '../global.css';
import React, { useEffect } from 'react';
import { Platform } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useFonts } from 'expo-font';
import * as SplashScreen from 'expo-splash-screen';
import { colorScheme } from 'nativewind';
import { useSessionStore } from '@/stores/useSessionStore';

SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const isDarkMode = useSessionStore((s) => s.isDarkMode);

  const [loaded, error] = useFonts({
    'Bricolage-Regular': require('@/assets/fonts/Bricolage-Regular.ttf'),
    'Bricolage-Medium': require('@/assets/fonts/Bricolage-Medium.ttf'),
    'Bricolage-SemiBold': require('@/assets/fonts/Bricolage-SemiBold.ttf'),
    'Bricolage-Bold': require('@/assets/fonts/Bricolage-Bold.ttf'),
    'Bricolage-ExtraBold': require('@/assets/fonts/Bricolage-ExtraBold.ttf'),
  });

  useEffect(() => {
    if (loaded || error) {
      SplashScreen.hideAsync();
    }
  }, [loaded, error]);

  useEffect(() => {
    try {
      colorScheme.set(isDarkMode ? 'dark' : 'light');
      if (Platform.OS === 'web' && typeof document !== 'undefined') {
        if (isDarkMode) {
          document.documentElement.classList.add('dark');
        } else {
          document.documentElement.classList.remove('dark');
        }
      }
    } catch (e) {}
  }, [isDarkMode]);

  if (!loaded && !error) {
    return null;
  }

  return (
    <>
      <StatusBar style={isDarkMode ? 'light' : 'dark'} />
      <Stack
        screenOptions={{
          headerShown: false,
          contentStyle: {
            backgroundColor: isDarkMode ? '#12100E' : '#FBF9F6',
          },
        }}
      >
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen
          name="onboarding"
          options={{
            presentation: 'card',
            headerShown: false,
          }}
        />
        <Stack.Screen
          name="learn"
          options={{
            presentation: 'card',
            headerShown: false,
          }}
        />
        <Stack.Screen
          name="dish/[id]"
          options={{
            presentation: 'modal',
            headerShown: false,
          }}
        />
        <Stack.Screen
          name="notifications"
          options={{
            presentation: 'modal',
            headerShown: false,
          }}
        />
        <Stack.Screen
          name="search"
          options={{
            presentation: 'card',
            headerShown: false,
          }}
        />
        <Stack.Screen
          name="restaurant/[id]"
          options={{
            presentation: 'card',
            headerShown: false,
          }}
        />
        <Stack.Screen
          name="order/[id]"
          options={{
            presentation: 'card',
            headerShown: false,
          }}
        />
        <Stack.Screen
          name="orders"
          options={{
            presentation: 'card',
            headerShown: false,
          }}
        />
        <Stack.Screen
          name="addresses"
          options={{
            presentation: 'card',
            headerShown: false,
          }}
        />
        <Stack.Screen
          name="(auth)/sign-in"
          options={{
            presentation: 'card',
            headerShown: false,
          }}
        />
        <Stack.Screen
          name="(auth)/sign-up"
          options={{
            presentation: 'card',
            headerShown: false,
          }}
        />
        <Stack.Screen
          name="+not-found"
          options={{
            presentation: 'card',
            headerShown: false,
          }}
        />
      </Stack>
    </>
  );
}
