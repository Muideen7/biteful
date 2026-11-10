import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { Check } from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { useCartStore } from '@/stores/useCartStore';
import { FoodArtView } from '@/components/common/FoodArtView';

export default function OffersScreen() {
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
    <View className="flex-1 bg-paper-light dark:bg-paper-dark">
      {/* Curved Tangerine Brand Header */}
      <View
        className="bg-brand-primary pt-12 pb-5 px-4 shadow-sm"
        style={{
          borderBottomLeftRadius: 32,
          borderBottomRightRadius: 32,
        }}
      >
        <Text className="text-2xl font-black text-white">Offers</Text>
        <Text className="text-xs font-semibold text-white/85 mt-1 leading-snug">
          One code per order. Apply it here or at checkout.
        </Text>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16, paddingBottom: 48 }}
      >
        {deals.map((deal) => {
          const isApplied = appliedDeal?.id === deal.id;
          return (
            <View
              key={deal.id}
              className="bg-[#181512] dark:bg-[#1E1A17] rounded-3xl p-5 mb-4 border border-[#2E2824] shadow-sm justify-between"
              style={{ minHeight: 144 }}
            >
              {/* Top row: Eyebrow + Headline on left, 3D Art on right */}
              <View className="flex-row items-start justify-between">
                <View className="flex-1 pr-3">
                  <Text className="text-xs font-black uppercase tracking-wider text-white/60 mb-1">
                    {deal.eyebrow}
                  </Text>
                  <Text className="text-2xl font-black text-white tracking-tight">
                    {deal.headline}
                  </Text>
                  <Text className="text-xs text-white/60 mt-1 leading-relaxed">
                    {deal.terms}
                  </Text>
                </View>

                <View className="w-16 h-16 items-center justify-center">
                  <FoodArtView art={deal.art} size={54} />
                </View>
              </View>

              {/* Bottom row: Coupon code badge & Interactive Apply pill */}
              <View className="flex-row items-center justify-between mt-4 pt-3 border-t border-white/10">
                <View className="bg-white/10 px-3.5 py-1.5 rounded-full border border-white/15">
                  <Text className="text-xs font-mono font-bold text-white tracking-widest uppercase">
                    {deal.code}
                  </Text>
                </View>

                <TouchableOpacity
                  activeOpacity={0.8}
                  onPress={() => handleToggleApply(deal)}
                  className={`px-5 py-2 rounded-full flex-row items-center shadow-xs ${
                    isApplied ? 'bg-white' : 'bg-brand-primary'
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
