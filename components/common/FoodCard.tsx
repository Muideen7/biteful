import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { Heart, Plus, Flame, ClockAfternoon } from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { Product } from '@/types/catalog';
import { FoodArtView } from './FoodArtView';
import { formatMoney } from '@/utils/money';
import { useCartStore } from '@/stores/useCartStore';
import { useSavedStore } from '@/stores/useSavedStore';

interface FoodCardProps {
  product: Product;
  onPress?: () => void;
}

export function FoodCard({ product, onPress }: FoodCardProps) {
  const addItem = useCartStore((s) => s.addItem);
  const { isSaved, toggleSaved } = useSavedStore();
  const saved = isSaved(product.id);

  const handleAdd = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    addItem(product);
  };

  const handleToggleSaved = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    toggleSaved(product.id);
  };

  return (
    <TouchableOpacity
      activeOpacity={0.88}
      onPress={onPress}
      className="bg-card-light dark:bg-card-dark rounded-3xl p-3.5 mb-3 border border-line-light dark:border-line-dark shadow-2xs flex-1 justify-between"
    >
      {/* Top row: Name & Favorite Heart */}
      <View>
        <View className="flex-row items-start justify-between">
          <Text
            numberOfLines={1}
            className="text-sm font-bold text-ink dark:text-ink-darkDefault flex-1 mr-1"
          >
            {product.name}
          </Text>
          <TouchableOpacity
            hitSlop={8}
            onPress={handleToggleSaved}
            className="p-0.5"
          >
            <Heart
              size={18}
              weight={saved ? 'fill' : 'regular'}
              color={saved ? '#FF5A36' : '#8A8179'}
            />
          </TouchableOpacity>
        </View>

        <Text className="text-xs font-black text-brand-primary mt-0.5">
          {formatMoney(product.priceCents)}
        </Text>
      </View>

      {/* Food art center */}
      <View className="items-center justify-center my-2.5">
        <FoodArtView art={product.art} size={74} />
      </View>

      {/* Bottom metadata & Add Button */}
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
            onPress={handleAdd}
            className="w-8 h-8 rounded-full bg-brand-primary items-center justify-center shadow-2xs"
          >
            <Plus size={16} weight="bold" color="#FFFFFF" />
          </TouchableOpacity>
        </View>
      </View>
    </TouchableOpacity>
  );
}
