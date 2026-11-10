import React, { useState } from 'react';
import { View, Text, ScrollView, TouchableOpacity, useWindowDimensions } from 'react-native';
import { ArrowRight } from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { useCartStore } from '@/stores/useCartStore';
import { FoodArtView } from '@/components/common/FoodArtView';
import { AnimatedRider } from '@/components/common/AnimatedRider';

export function PromoCarousel() {
  const [containerWidth, setContainerWidth] = useState(0);
  const { width: windowWidth } = useWindowDimensions();
  const banners = useCatalogStore((s) => s.banners);
  const deals = useCatalogStore((s) => s.deals);
  const applyDeal = useCartStore((s) => s.applyDeal);

  const effectiveWidth = containerWidth > 0 ? containerWidth : windowWidth;
  const bannerWidth = Math.max(280, Math.min(effectiveWidth - 32, 380));

  const handleBannerPress = (dealId?: string | null) => {
    if (!dealId) return;
    const deal = deals.find((d) => d.id === dealId);
    if (deal) {
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      applyDeal(deal);
    }
  };

  return (
    <View
      onLayout={(e) => setContainerWidth(e.nativeEvent.layout.width)}
      className="py-3"
    >
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        snapToInterval={bannerWidth + 12}
        decelerationRate="fast"
        contentContainerStyle={{ paddingHorizontal: 16 }}
      >
        {banners.map((b) => (
          <TouchableOpacity
            key={b.id}
            activeOpacity={0.9}
            onPress={() => handleBannerPress(b.dealId)}
            style={{ width: bannerWidth }}
            className="mr-3 bg-brand-primary rounded-3xl p-5 overflow-hidden relative shadow-sm"
          >
            {/* Background design circle accent */}
            <View className="absolute -right-6 -bottom-6 w-44 h-44 rounded-full bg-brand-deep/30" />

            <View className="flex-row justify-between items-center z-10">
              <View className="flex-1 pr-3">
                <Text className="text-white/80 font-bold text-xs uppercase tracking-wider">
                  {b.subtitle}
                </Text>
                <Text className="text-white text-2xl font-extrabold tracking-tight mt-1">
                  {b.lineOne}
                </Text>
                <Text className="text-brand-honey text-2xl font-extrabold tracking-tight">
                  {b.lineTwo}
                </Text>

                <View className="flex-row items-center bg-white/20 self-start px-3 py-1.5 rounded-full mt-3">
                  <Text className="text-white text-xs font-bold mr-1">
                    {b.cta}
                  </Text>
                  <ArrowRight size={12} weight="bold" color="#FFFFFF" />
                </View>
              </View>

              {/* Graphic element */}
              <View className="items-center justify-center">
                {b.style === 'rider' ? (
                  <AnimatedRider size={100} />
                ) : b.art ? (
                  <FoodArtView art={b.art} size={80} />
                ) : null}
              </View>
            </View>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </View>
  );
}
