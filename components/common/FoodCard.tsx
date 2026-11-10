import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { Heart, Plus, Star, ClockAfternoon } from 'phosphor-react-native';
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
      className="bg-card-light dark:bg-card-dark rounded-2xl p-3.5 mb-3.5 border border-line-light dark:border-line-dark shadow-sm flex-1"
    >
      {/* Top row: Star rating + Heart */}
      <View className="flex-row items-center justify-between mb-2">
        <View className="flex-row items-center bg-brand-wash dark:bg-brand-washDark px-2 py-0.5 rounded-full">
          <Star size={13} weight="fill" color="#FFAA00" />
          <Text className="text-xs font-semibold text-brand-deep ml-1">
            {product.rating.toFixed(1)}
          </Text>
        </View>

        <TouchableOpacity
          hitSlop={8}
          onPress={handleToggleSaved}
          className="p-1"
        >
          <Heart
            size={20}
            weight={saved ? 'fill' : 'regular'}
            color={saved ? '#FF5A36' : '#8A8179'}
          />
        </TouchableOpacity>
      </View>

      {/* Food art render */}
      <View className="items-center justify-center my-2">
        <FoodArtView art={product.art} size={88} />
      </View>

      {/* Name and time */}
      <Text
        numberOfLines={1}
        className="text-base font-bold text-ink dark:text-ink-darkDefault mt-1"
      >
        {product.name}
      </Text>

      <View className="flex-row items-center mt-1 space-x-2">
        <View className="flex-row items-center">
          <ClockAfternoon size={13} color="#8A8179" />
          <Text className="text-xs text-ink-muted ml-1">
            {product.minutes} min
          </Text>
        </View>
        <Text className="text-xs text-ink-muted ml-2">
          • {product.calories} kcal
        </Text>
      </View>

      {/* Bottom row: Price and Add Button */}
      <View className="flex-row items-center justify-between mt-3 pt-2 border-t border-line-light dark:border-line-dark">
        <Text className="text-base font-extrabold text-ink dark:text-ink-darkDefault">
          {formatMoney(product.priceCents)}
        </Text>

        <TouchableOpacity
          activeOpacity={0.8}
          onPress={handleAdd}
          className="bg-brand-primary w-8 h-8 rounded-full items-center justify-center shadow-sm"
        >
          <Plus size={18} weight="bold" color="#FFFFFF" />
        </TouchableOpacity>
      </View>
    </TouchableOpacity>
  );
}
