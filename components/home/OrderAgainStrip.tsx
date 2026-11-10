import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { ArrowsClockwise } from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { useCartStore } from '@/stores/useCartStore';
import { FoodArtView } from '@/components/common/FoodArtView';
import { formatMoney } from '@/utils/money';

export function OrderAgainStrip() {
  const router = useRouter();
  const getProductById = useCatalogStore((s) => s.getProductById);
  const addItem = useCartStore((s) => s.addItem);

  // Past favorite orders (Tonkotsu Ramen and Pork Dumplings as in reference)
  const pastOrderIds = ['p_ramen', 'p_dumplings', 'p_cheeseburger'];
  const items = pastOrderIds
    .map((id) => getProductById(id))
    .filter(Boolean) as NonNullable<ReturnType<typeof getProductById>>[];

  const handleReorder = (product: typeof items[0]) => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    addItem(product);
  };

  if (items.length === 0) return null;

  return (
    <View className="py-2">
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingHorizontal: 16 }}
      >
        {items.map((product) => (
          <TouchableOpacity
            key={product.id}
            activeOpacity={0.85}
            onPress={() => router.push(`/dish/${product.id}`)}
            className="mr-3 w-[230px] bg-card-light dark:bg-card-dark rounded-2xl p-3 border border-line-light dark:border-line-dark shadow-2xs flex-row items-center justify-between"
          >
            <View className="flex-row items-center flex-1 mr-2">
              <FoodArtView art={product.art} size={42} />
              <View className="ml-2.5 flex-1">
                <Text
                  numberOfLines={1}
                  className="text-sm font-bold text-ink dark:text-ink-darkDefault"
                >
                  {product.name}
                </Text>
                <Text className="text-xs text-ink-muted mt-0.5">
                  Today • {formatMoney(product.priceCents)}
                </Text>
              </View>
            </View>

            {/* Reorder Button */}
            <TouchableOpacity
              activeOpacity={0.7}
              hitSlop={8}
              onPress={() => handleReorder(product)}
              className="w-8 h-8 rounded-full bg-brand-wash dark:bg-brand-washDark border border-brand-primary/20 items-center justify-center"
            >
              <ArrowsClockwise size={16} weight="bold" color="#FF5A36" />
            </TouchableOpacity>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </View>
  );
}

