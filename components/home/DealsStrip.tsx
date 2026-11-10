import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { Tag, Sparkle } from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { useCartStore } from '@/stores/useCartStore';
import { FoodArtView } from '@/components/common/FoodArtView';
import { formatMoney } from '@/utils/money';

export function DealsStrip() {
  const deals = useCatalogStore((s) => s.deals);
  const { appliedDeal, applyDeal } = useCartStore();

  const handleApply = (deal: typeof deals[0]) => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    applyDeal(deal);
  };

  return (
    <View className="py-2">
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingHorizontal: 16 }}
      >
        {deals.map((deal) => {
          const isApplied = appliedDeal?.id === deal.id;
          return (
            <TouchableOpacity
              key={deal.id}
              activeOpacity={0.88}
              onPress={() => handleApply(deal)}
              className="mr-3 w-64 bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-line-light dark:border-line-dark shadow-xs"
            >
              <View className="flex-row items-center justify-between mb-2">
                <View className="flex-row items-center bg-brand-wash dark:bg-brand-washDark px-2 py-0.5 rounded-full">
                  <Tag size={12} weight="fill" color="#FF5A36" />
                  <Text className="text-xs font-bold text-brand-primary ml-1 uppercase">
                    {deal.code}
                  </Text>
                </View>

                {isApplied && (
                  <View className="flex-row items-center bg-brand-mint/15 px-2 py-0.5 rounded-full">
                    <Sparkle size={12} weight="fill" color="#00C48C" />
                    <Text className="text-xs font-bold text-brand-mint ml-1">
                      Applied
                    </Text>
                  </View>
                )}
              </View>

              <View className="flex-row items-center justify-between my-1">
                <View className="flex-1 pr-2">
                  <Text className="text-base font-extrabold text-ink dark:text-ink-darkDefault">
                    {deal.headline}
                  </Text>
                  <Text className="text-xs text-ink-muted mt-0.5">
                    Orders over {formatMoney(deal.minSpendCents)}
                  </Text>
                </View>
                <FoodArtView art={deal.art} size={48} />
              </View>

              <Text
                numberOfLines={1}
                className="text-xs text-ink-muted/80 mt-2 italic"
              >
                {deal.terms}
              </Text>
            </TouchableOpacity>
          );
        })}
      </ScrollView>
    </View>
  );
}
