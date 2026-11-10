import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  Image,
  Animated,
  Easing,
  Platform,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { ArrowRight, Sparkle } from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { Wordmark } from '@/components/common/Wordmark';
import { useSessionStore } from '@/stores/useSessionStore';

interface OnboardingSlide {
  id: string;
  badge: string;
  title: string;
  description: string;
  image: any;
}

const SLIDES: OnboardingSlide[] = [
  {
    id: 'slide-1',
    badge: 'Dispatch Courier',
    title: 'ORDER GREAT FOOD NEAR YOU WITH BITEFUL !',
    description:
      'Fast, reliable dispatch courier delivery from the finest restaurants and cozy kitchens in your neighborhood.',
    image: require('@/assets/brand/rider_onboarding.png'),
  },
  {
    id: 'slide-2',
    badge: 'Comfort Foods',
    title: 'HOT MEALS & SAVORY DISHES CRAVED DAILY !',
    description:
      'From juicy stacked burgers and cheesy wood-fired pizza to steaming pasta, satisfy every craving.',
    image: require('@/assets/brand/onboarding_comfort.jpg'),
  },
  {
    id: 'slide-3',
    badge: 'Chef Masterpieces',
    title: 'EXPLORE HANDPICKED MENUS FROM TOP CHEFS !',
    description:
      'Discover artisanal ramen, fresh sushi, verified customer ratings, and app-exclusive dining discounts.',
    image: require('@/assets/brand/onboarding_chef.jpg'),
  },
  {
    id: 'slide-4',
    badge: 'Doorstep Milestone',
    title: 'REAL-TIME DISPATCH TRACKER TO YOUR DOOR !',
    description:
      'Follow your order live on the map every turn of the way until piping hot meals land directly in your hands.',
    image: require('@/assets/brand/onboarding_doorstep.jpg'),
  },
];

export default function OnboardingScreen() {
  const router = useRouter();
  const [currentIndex, setCurrentIndex] = useState(0);
  const completeOnboarding = useSessionStore((s) => s.completeOnboarding);

  // Spring animation values for illustration
  const imageFadeAnim = useRef(new Animated.Value(1)).current;
  const imageSlideAnim = useRef(new Animated.Value(0)).current;
  const imageScaleAnim = useRef(new Animated.Value(1)).current;

  // Spring animation values for bottom card text
  const textFadeAnim = useRef(new Animated.Value(1)).current;
  const textSlideAnim = useRef(new Animated.Value(0)).current;

  // Button press spring scale
  const buttonScale = useRef(new Animated.Value(1)).current;

  // Animated dot widths
  const dotWidths = useRef(
    SLIDES.map((_, i) => new Animated.Value(i === 0 ? 28 : 8))
  ).current;

  const animateToSlide = (newIndex: number) => {
    // 1. Animate out quickly
    Animated.parallel([
      Animated.timing(imageFadeAnim, {
        toValue: 0.1,
        duration: 120,
        easing: Easing.out(Easing.ease),
        useNativeDriver: true,
      }),
      Animated.timing(imageSlideAnim, {
        toValue: -20,
        duration: 120,
        easing: Easing.out(Easing.ease),
        useNativeDriver: true,
      }),
      Animated.timing(textFadeAnim, {
        toValue: 0.2,
        duration: 120,
        useNativeDriver: true,
      }),
      Animated.timing(textSlideAnim, {
        toValue: 8,
        duration: 120,
        useNativeDriver: true,
      }),
    ]).start(() => {
      // 2. Change state
      setCurrentIndex(newIndex);
      imageSlideAnim.setValue(32);
      imageScaleAnim.setValue(0.92);
      textSlideAnim.setValue(10);

      // 3. Spring into view
      Animated.parallel([
        Animated.spring(imageSlideAnim, {
          toValue: 0,
          friction: 8,
          tension: 65,
          useNativeDriver: true,
        }),
        Animated.spring(imageScaleAnim, {
          toValue: 1,
          friction: 7,
          tension: 70,
          useNativeDriver: true,
        }),
        Animated.timing(imageFadeAnim, {
          toValue: 1,
          duration: 260,
          easing: Easing.out(Easing.cubic),
          useNativeDriver: true,
        }),
        Animated.timing(textFadeAnim, {
          toValue: 1,
          duration: 240,
          useNativeDriver: true,
        }),
        Animated.spring(textSlideAnim, {
          toValue: 0,
          friction: 8,
          tension: 70,
          useNativeDriver: true,
        }),
        ...dotWidths.map((anim, i) =>
          Animated.spring(anim, {
            toValue: i === newIndex ? 28 : 8,
            friction: 7,
            tension: 80,
            useNativeDriver: false,
          })
        ),
      ]).start();
    });
  };

  const handleFinish = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    completeOnboarding();
    router.replace('/(auth)/sign-in');
  };

  const handleNext = () => {
    if (currentIndex < SLIDES.length - 1) {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      animateToSlide(currentIndex + 1);
    } else {
      handleFinish();
    }
  };

  const handleDotPress = (index: number) => {
    if (index === currentIndex) return;
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    animateToSlide(index);
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

      {/* Center Image Area: Spring-animated & Centered from top to bottom */}
      <View className="flex-1 items-center justify-center px-4 py-2">
        <Animated.View
          style={{
            opacity: imageFadeAnim,
            transform: [
              { translateX: imageSlideAnim },
              { scale: imageScaleAnim },
            ],
            width: 320,
            height: 300,
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <Image
            source={currentSlide.image}
            style={{
              width: 300,
              height: 280,
              borderRadius: currentIndex > 0 ? 28 : 0,
              maxWidth: '100%',
              maxHeight: '100%',
            }}
            resizeMode="contain"
          />
        </Animated.View>
      </View>

      {/* Bottom Orange Card (Matching Image 2 Style with Spring Polish) */}
      <View className="px-4 pb-4">
        <View className="bg-brand-primary rounded-3xl p-6 shadow-md relative overflow-hidden">
          {/* Subtle Decorative Accent Circle */}
          <View className="absolute -right-8 -bottom-8 w-32 h-32 rounded-full bg-white/10 pointer-events-none" />

          {/* Dots Pagination with Spring Width */}
          <View className="flex-row items-center mb-4">
            {SLIDES.map((_, idx) => (
              <TouchableOpacity
                key={idx}
                onPress={() => handleDotPress(idx)}
                hitSlop={8}
                className="mr-2"
              >
                <Animated.View
                  style={{
                    width: dotWidths[idx],
                    height: 8,
                    backgroundColor:
                      idx === currentIndex ? '#FFFFFF' : 'rgba(255,255,255,0.4)',
                    borderRadius: 4,
                  }}
                />
              </TouchableOpacity>
            ))}
          </View>

          {/* Animated Title & Description */}
          <Animated.View
            style={{
              opacity: textFadeAnim,
              transform: [{ translateY: textSlideAnim }],
            }}
          >
            <Text
              numberOfLines={2}
              className="text-white font-black text-2xl tracking-tight leading-7 mb-2"
            >
              {currentSlide.title}
            </Text>

            <Text className="text-white/85 text-sm font-medium leading-5 mb-6">
              {currentSlide.description}
            </Text>
          </Animated.View>

          {/* Tactile Spring Action Button */}
          <Animated.View style={{ transform: [{ scale: buttonScale }] }}>
            <TouchableOpacity
              activeOpacity={0.9}
              onPressIn={() => {
                Animated.spring(buttonScale, {
                  toValue: 0.96,
                  useNativeDriver: true,
                }).start();
              }}
              onPressOut={() => {
                Animated.spring(buttonScale, {
                  toValue: 1,
                  friction: 4,
                  tension: 60,
                  useNativeDriver: true,
                }).start();
              }}
              onPress={handleNext}
              className="w-full bg-[#181512] dark:bg-card-dark py-4 rounded-2xl flex-row items-center justify-center shadow-sm"
            >
              <Text className="text-white font-extrabold text-base mr-2">
                {isLast ? 'Start ordering' : 'Continue'}
              </Text>
              {isLast ? (
                <Sparkle size={18} weight="fill" color="#FFAA00" />
              ) : (
                <ArrowRight size={18} weight="bold" color="#FFFFFF" />
              )}
            </TouchableOpacity>
          </Animated.View>
        </View>
      </View>
    </SafeAreaView>
  );
}
