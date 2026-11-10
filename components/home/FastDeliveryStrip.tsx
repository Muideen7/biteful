import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { Plus, Flame, ClockAfternoon } from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { useCartStore } from '@/stores/useCartStore';
import { FoodArtView } from '@/components/common/FoodArtView';
import { formatMoney } from '@/utils/money';

export function FastDeliveryStrip() {
  const router = useRouter();
  const getFastDelivery = useCatalogStore((s) => s.getFastDelivery);
  const addItem = useCartStore((s) => s.addItem);
  const fastItems = getFastDelivery();

  const handleAdd = (product: typeof fastItems[0]) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    addItem(product);
  };

  if (fastItems.length === 0) return null;

  return (
    <View className="py-1">
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 4 }}
      >
        {fastItems.map((product) => (
          <TouchableOpacity
            key={product.id}
            activeOpacity={0.88}
            onPress={() => router.push(`/dish/${product.id}`)}
            className="mr-3 w-[165px] bg-card-light dark:bg-card-dark rounded-2xl p-3 border border-line-light dark:border-line-dark shadow-2xs justify-between"
          >
            {/* Title & Price */}
            <View>
              <Text
                numberOfLines={1}
                className="text-sm font-bold text-ink dark:text-ink-darkDefault"
              >
                {product.name}
              </Text>
              <Text className="text-xs font-black text-brand-primary mt-0.5">
                {formatMoney(product.priceCents)}
              </Text>
            </View>

            {/* Food Art */}
            <View className="items-center justify-center my-2">
              <FoodArtView art={product.art} size={64} />
            </View>

            {/* Calories & Minutes */}
            <View className="space-y-1">
              <View className="flex-row items-center">
                <Flame size={12} weight="fill" color="#FF5A36" />
                <Text className="text-[11px] text-ink-muted ml-1 font-medium">
                  {product.calories} Calories
                </Text>
              </View>

              <View className="flex-row items-center justify-between pt-1">
                <View className="flex-row items-center">
                  <ClockAfternoon size={12} color="#8A8179" />
                  <Text className="text-[11px] text-ink-muted ml-1 font-medium">
                    {product.minutes} min
                  </Text>
                </View>

                {/* Add button */}
                <TouchableOpacity
                  activeOpacity={0.75}
                  hitSlop={6}
                  onPress={() => handleAdd(product)}
                  className="w-7 h-7 rounded-full bg-brand-primary items-center justify-center shadow-2xs"
                >
                  <Plus size={14} weight="bold" color="#FFFFFF" />
                </TouchableOpacity>
              </View>
            </View>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </View>
  );
}
