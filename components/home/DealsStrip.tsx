import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { Check } from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { useCartStore } from '@/stores/useCartStore';
import { FoodArtView } from '@/components/common/FoodArtView';

export function DealsStrip() {
  const deals = useCatalogStore((s) => s.deals);
  const { appliedDeal, applyDeal } = useCartStore();

  const handleToggleApply = (deal: typeof deals[0]) => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    if (appliedDeal?.id === deal.id) {
      applyDeal(null);
    } else {
      applyDeal(deal);
    }
  };

  return (
    <View className="py-1">
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 4 }}
      >
        {deals.map((deal) => {
          const isApplied = appliedDeal?.id === deal.id;
          return (
            <View
              key={deal.id}
              className="mr-3 w-[260px] bg-[#181512] dark:bg-[#1E1A17] rounded-3xl p-4 border border-[#2E2824] shadow-sm justify-between"
              style={{ minHeight: 140 }}
            >
              {/* Top row: Eyebrow + Headline on left, 3D Art on right */}
              <View className="flex-row items-start justify-between">
                <View className="flex-1 pr-2">
                  <Text className="text-[11px] font-black uppercase tracking-wider text-white/60 mb-1">
                    {deal.eyebrow}
                  </Text>
                  <Text className="text-2xl font-black text-white tracking-tight">
                    {deal.headline}
                  </Text>
                </View>
                <View className="w-14 h-14 items-center justify-center">
                  <FoodArtView art={deal.art} size={50} />
                </View>
              </View>

              {/* Bottom row: Coupon code badge & Interactive Apply pill */}
              <View className="flex-row items-center justify-between mt-3 pt-3 border-t border-white/10">
                <View className="bg-white/10 px-3 py-1.5 rounded-full border border-white/15">
                  <Text className="text-xs font-mono font-bold text-white tracking-widest uppercase">
                    {deal.code}
                  </Text>
                </View>

                <TouchableOpacity
                  activeOpacity={0.8}
                  onPress={() => handleToggleApply(deal)}
                  className={`px-4 py-1.5 rounded-full flex-row items-center shadow-xs ${
                    isApplied
                      ? 'bg-white text-ink'
                      : 'bg-brand-primary'
                  }`}
                >
                  {isApplied && (
                    <View className="mr-1">
                      <Check size={14} weight="bold" color="#181512" />
                    </View>
                  )}
                  <Text
                    className={`text-xs font-black ${
                      isApplied ? 'text-ink' : 'text-white'
                    }`}
                  >
                    {isApplied ? 'Applied' : 'Apply'}
                  </Text>
                </TouchableOpacity>
              </View>
            </View>
          );
        })}
      </ScrollView>
    </View>
  );
}
