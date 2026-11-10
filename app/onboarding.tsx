import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  Image,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { ArrowRight } from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { Wordmark } from '@/components/common/Wordmark';
import { useSessionStore } from '@/stores/useSessionStore';

interface OnboardingSlide {
  id: string;
  title: string;
  description: string;
  image: any;
}

const SLIDES: OnboardingSlide[] = [
  {
    id: 'slide-1',
    title: 'ORDER GREAT FOOD NEAR YOU WITH BITEFUL !',
    description:
      'Fast, reliable dispatch delivery from the finest restaurants and cozy kitchens in your neighborhood.',
    image: require('@/assets/brand/rider_onboarding.png'),
  },
  {
    id: 'slide-2',
    title: 'HOT MEALS & SAVORY DISHES CRAVED DAILY !',
    description:
      'From juicy stacked burgers and cheesy wood-fired pizza to steaming noodles, satisfy every craving.',
    image: require('@/assets/brand/onboarding_comfort.png'),
  },
  {
    id: 'slide-3',
    title: 'EXPLORE HANDPICKED MENUS FROM TOP CHEFS !',
    description:
      'Discover artisanal cuisine, authentic recipes, verified customer reviews, and app-exclusive deals.',
    image: require('@/assets/brand/onboarding_ramen.png'),
  },
  {
    id: 'slide-4',
    title: 'REAL-TIME DISPATCH TRACKER TO YOUR DOOR !',
    description:
      'Follow your rider live on the map every turn of the way until piping hot meals land directly at your door.',
    image: require('@/assets/brand/rider_onboarding.png'),
  },
];

export default function OnboardingScreen() {
  const router = useRouter();
  const [currentIndex, setCurrentIndex] = useState(0);
  const completeOnboarding = useSessionStore((s) => s.completeOnboarding);

  const handleFinish = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    completeOnboarding();
    router.replace('/(auth)/sign-in');
  };

  const handleNext = () => {
    if (currentIndex < SLIDES.length - 1) {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      setCurrentIndex(currentIndex + 1);
    } else {
      handleFinish();
    }
  };

  const isLast = currentIndex === SLIDES.length - 1;
  const currentSlide = SLIDES[currentIndex];

  return (
    <SafeAreaView
      edges={['top', 'bottom']}
      className="flex-1 bg-paper-light dark:bg-paper-dark max-w-md w-full self-center justify-between"
    >
      {/* Top Header Bar */}
      <View className="px-5 py-3 flex-row items-center justify-between">
        <Wordmark size="md" />

        <TouchableOpacity
          activeOpacity={0.7}
          onPress={handleFinish}
          className="px-3.5 py-1.5 rounded-full bg-card-light dark:bg-card-dark border border-line-light dark:border-line-dark shadow-xs"
        >
          <Text className="text-xs font-bold text-ink-muted">Skip</Text>
        </TouchableOpacity>
      </View>

      {/* Center Dispatch Rider Area - Cleanly centered from top to bottom */}
      <View className="flex-1 items-center justify-center px-4 py-2">
        <Image
          key={currentSlide.id}
          source={currentSlide.image}
          style={{
            width: 310,
            height: 290,
            maxWidth: '100%',
          }}
          resizeMode="contain"
        />
      </View>

      {/* Bottom Orange Card (Matching Image 2 Style) */}
      <View className="px-4 pb-4">
        <View className="bg-brand-primary rounded-3xl p-6 shadow-md relative overflow-hidden">
          {/* Subtle Decorative Accent Circle */}
          <View className="absolute -right-8 -bottom-8 w-32 h-32 rounded-full bg-white/10" />

          {/* Dots Pagination */}
          <View className="flex-row items-center mb-4">
            {SLIDES.map((_, idx) => (
              <TouchableOpacity
                key={idx}
                onPress={() => {
                  Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                  setCurrentIndex(idx);
                }}
                hitSlop={8}
                className="mr-2"
              >
                <View
                  style={{
                    width: idx === currentIndex ? 26 : 8,
                    height: 8,
                    backgroundColor:
                      idx === currentIndex ? '#FFFFFF' : 'rgba(255,255,255,0.4)',
                    borderRadius: 4,
                  }}
                />
              </TouchableOpacity>
            ))}
          </View>

          {/* Title */}
          <Text
            numberOfLines={2}
            className="text-white font-black text-2xl tracking-tight leading-7 mb-2"
          >
            {currentSlide.title}
          </Text>

          {/* Description */}
          <Text className="text-white/85 text-sm font-medium leading-5 mb-6">
            {currentSlide.description}
          </Text>

          {/* Action Button */}
          <TouchableOpacity
            activeOpacity={0.88}
            onPress={handleNext}
            className="w-full bg-[#181512] dark:bg-card-dark py-4 rounded-2xl flex-row items-center justify-center shadow-sm"
          >
            <Text className="text-white font-extrabold text-base mr-2">
              {isLast ? 'Start ordering' : 'Continue'}
            </Text>
            <ArrowRight size={18} weight="bold" color="#FFFFFF" />
          </TouchableOpacity>
        </View>
      </View>
    </SafeAreaView>
  );
}
