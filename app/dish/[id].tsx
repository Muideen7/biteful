import React, { useState } from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { X, Heart, Star, ClockAfternoon, Fire, Plus, Minus, ArrowRight } from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { useCartStore } from '@/stores/useCartStore';
import { useSavedStore } from '@/stores/useSavedStore';
import { FoodArtView } from '@/components/common/FoodArtView';
import { formatMoney } from '@/utils/money';

export default function DishModalScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();

  const product = useCatalogStore((s) => s.getProductById(id || ''));
  const addItem = useCartStore((s) => s.addItem);
  const { isSaved, toggleSaved } = useSavedStore();

  const [quantity, setQuantity] = useState(1);

  if (!product) {
    return (
      <SafeAreaView className="flex-1 bg-paper-light dark:bg-paper-dark p-4">
        <TouchableOpacity onPress={() => router.back()} className="p-2">
          <X size={24} color="#181512" />
        </TouchableOpacity>
        <Text className="text-center mt-12 text-ink-muted">Dish not found</Text>
      </SafeAreaView>
    );
  }

  const saved = isSaved(product.id);
  const totalPrice = product.priceCents * quantity;

  const handleAddToCart = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    for (let i = 0; i < quantity; i++) {
      addItem(product);
    }
    router.back();
  };

  const handleToggleSaved = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    toggleSaved(product.id);
  };

  return (
    <SafeAreaView
      edges={['top', 'bottom']}
      className="flex-1 bg-card-light dark:bg-card-dark"
    >
      {/* Header bar: Close button & Heart toggle */}
      <View className="flex-row items-center justify-between px-4 py-3">
        <TouchableOpacity
          activeOpacity={0.7}
          onPress={() => router.back()}
          className="w-10 h-10 rounded-full bg-paper-light dark:bg-paper-dark border border-line-light dark:border-line-dark items-center justify-center"
        >
          <X size={20} weight="bold" color="#181512" />
        </TouchableOpacity>

        <TouchableOpacity
          activeOpacity={0.7}
          onPress={handleToggleSaved}
          className="w-10 h-10 rounded-full bg-paper-light dark:bg-paper-dark border border-line-light dark:border-line-dark items-center justify-center"
        >
          <Heart
            size={22}
            weight={saved ? 'fill' : 'regular'}
            color={saved ? '#FF5A36' : '#8A8179'}
          />
        </TouchableOpacity>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingHorizontal: 20, paddingBottom: 32 }}
      >
        {/* Large 3D Food Art Presentation */}
        <View className="items-center justify-center py-6">
          <FoodArtView art={product.art} size={160} />
        </View>

        {/* Name and Price */}
        <View className="flex-row items-start justify-between mt-2">
          <View className="flex-1 pr-3">
            <Text className="text-2xl font-extrabold text-ink dark:text-ink-darkDefault">
              {product.name}
            </Text>
            <View className="flex-row items-center mt-1.5 space-x-3">
              <View className="flex-row items-center bg-brand-wash dark:bg-brand-washDark px-2 py-0.5 rounded-full mr-2">
                <Star size={13} weight="fill" color="#FFAA00" />
                <Text className="text-xs font-bold text-brand-deep ml-1">
                  {product.rating.toFixed(1)}
                </Text>
              </View>
              <View className="flex-row items-center mr-3">
                <ClockAfternoon size={14} color="#8A8179" />
                <Text className="text-xs text-ink-muted ml-1">
                  {product.minutes} min
                </Text>
              </View>
              <View className="flex-row items-center">
                <Fire size={14} color="#8A8179" />
                <Text className="text-xs text-ink-muted ml-1">
                  {product.calories} kcal
                </Text>
              </View>
            </View>
          </View>

          <Text className="text-2xl font-black text-brand-primary">
            {formatMoney(product.priceCents)}
          </Text>
        </View>

        {/* Description */}
        <Text className="text-sm text-ink-soft dark:text-ink-darkSoft leading-relaxed mt-4">
          {product.description}
        </Text>

        {/* Quantity Selection */}
        <View className="flex-row items-center justify-between mt-8 p-4 bg-paper-light dark:bg-paper-dark rounded-2xl border border-line-light dark:border-line-dark">
          <Text className="text-base font-bold text-ink dark:text-ink-darkDefault">
            Select Quantity
          </Text>

          <View className="flex-row items-center bg-card-light dark:bg-card-dark rounded-full px-2 py-1 border border-line-light dark:border-line-dark">
            <TouchableOpacity
              onPress={() => {
                Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                setQuantity(Math.max(1, quantity - 1));
              }}
              className="w-8 h-8 rounded-full bg-brand-wash dark:bg-brand-washDark items-center justify-center"
            >
              <Minus size={14} weight="bold" color="#FF5A36" />
            </TouchableOpacity>

            <Text className="font-extrabold text-base text-ink dark:text-ink-darkDefault mx-4 text-center w-6">
              {quantity}
            </Text>

            <TouchableOpacity
              onPress={() => {
                Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                setQuantity(quantity + 1);
              }}
              className="w-8 h-8 rounded-full bg-brand-primary items-center justify-center"
            >
              <Plus size={14} weight="bold" color="#FFFFFF" />
            </TouchableOpacity>
          </View>
        </View>

        {/* Add to Basket CTA */}
        <TouchableOpacity
          activeOpacity={0.88}
          onPress={handleAddToCart}
          className="mt-6 bg-brand-primary py-4 rounded-full flex-row items-center justify-center shadow-md"
        >
          <Text className="text-white font-extrabold text-lg mr-2">
            Add to Basket • {formatMoney(totalPrice)}
          </Text>
          <ArrowRight size={20} weight="bold" color="#FFFFFF" />
        </TouchableOpacity>
      </ScrollView>
    </SafeAreaView>
  );
}
