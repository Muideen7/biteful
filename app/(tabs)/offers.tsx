import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Tag, Sparkle, Check } from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { useCartStore } from '@/stores/useCartStore';
import { FoodArtView } from '@/components/common/FoodArtView';
import { formatMoney } from '@/utils/money';

export default function OffersScreen() {
  const router = useRouter();
  const deals = useCatalogStore((s) => s.deals);
  const { appliedDeal, applyDeal } = useCartStore();

  const handleApply = (deal: typeof deals[0]) => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    applyDeal(deal);
    router.push('/(tabs)/cart');
  };

  return (
    <SafeAreaView
      edges={['top']}
      className="flex-1 bg-paper-light dark:bg-paper-dark"
    >
      <View className="px-4 py-3 border-b border-line-light dark:border-line-dark">
        <Text className="text-2xl font-bold tracking-tight text-ink dark:text-ink-darkDefault">
          Deals & Offers
        </Text>
        <Text className="text-sm text-ink-muted">
          Active vouchers to save on your orders
        </Text>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16 }}
      >
        {deals.map((deal) => {
          const isApplied = appliedDeal?.id === deal.id;
          return (
            <View
              key={deal.id}
              className="bg-card-light dark:bg-card-dark rounded-2xl p-4 mb-4 border border-line-light dark:border-line-dark shadow-xs"
            >
              <View className="flex-row items-center justify-between">
                <View className="flex-row items-center bg-brand-wash dark:bg-brand-washDark px-2.5 py-1 rounded-full">
                  <Tag size={14} weight="fill" color="#FF5A36" />
                  <Text className="text-xs font-bold text-brand-primary ml-1.5 uppercase">
                    {deal.code}
                  </Text>
                </View>

                {isApplied && (
                  <View className="flex-row items-center bg-brand-mint/15 px-2.5 py-1 rounded-full">
                    <Check size={14} weight="bold" color="#00C48C" />
                    <Text className="text-xs font-bold text-brand-mint ml-1">
                      Active Voucher
                    </Text>
                  </View>
                )}
              </View>

              <View className="flex-row items-center justify-between my-3">
                <View className="flex-1 pr-3">
                  <Text className="text-lg font-bold text-ink dark:text-ink-darkDefault">
                    {deal.headline}
                  </Text>
                  <Text className="text-sm text-ink-muted mt-1">
                    Minimum spend: {formatMoney(deal.minSpendCents)}
                  </Text>
                  <Text className="text-xs text-ink-muted/80 mt-1 italic">
                    {deal.terms}
                  </Text>
                </View>
                <FoodArtView art={deal.art} size={64} />
              </View>

              <TouchableOpacity
                activeOpacity={0.8}
                onPress={() => handleApply(deal)}
                className={`py-2.5 rounded-xl items-center justify-center ${
                  isApplied
                    ? 'bg-brand-wash dark:bg-brand-washDark border border-brand-primary/30'
                    : 'bg-brand-primary'
                }`}
              >
                <Text
                  className={`font-bold text-sm ${
                    isApplied ? 'text-brand-deep' : 'text-white'
                  }`}
                >
                  {isApplied ? 'Applied to Basket' : 'Apply Offer'}
                </Text>
              </TouchableOpacity>
            </View>
          );
        })}
      </ScrollView>
    </SafeAreaView>
  );
}
