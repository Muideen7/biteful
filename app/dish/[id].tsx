import React, { useState } from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import {
  X,
  Heart,
  Star,
  ClockAfternoon,
  Flame,
  Plus,
  Minus,
} from 'phosphor-react-native';
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
  const restaurant = useCatalogStore((s) =>
    product ? s.getRestaurantById(product.restaurantId) : undefined
  );
  const addItem = useCartStore((s) => s.addItem);
  const { isSaved, toggleSaved } = useSavedStore();

  const [quantity, setQuantity] = useState(1);

  if (!product) {
    return (
      <SafeAreaView className="flex-1 bg-paper-light dark:bg-paper-dark p-4 items-center justify-center">
        <TouchableOpacity
          onPress={() => router.back()}
          className="absolute top-12 left-4 w-10 h-10 rounded-full bg-card-light dark:bg-card-dark items-center justify-center"
        >
          <X size={20} color="#181512" />
        </TouchableOpacity>
        <Text className="text-ink-muted font-bold text-base">Dish not found</Text>
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

  const handleIncrease = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setQuantity((q) => q + 1);
  };

  const handleDecrease = () => {
    if (quantity > 1) {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      setQuantity((q) => q - 1);
    }
  };

  return (
    <SafeAreaView
      edges={['top', 'bottom']}
      className="flex-1 bg-paper-light dark:bg-paper-dark justify-between"
    >
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{
          padding: 20,
          paddingBottom: 24,
          maxWidth: 480,
          width: '100%',
          alignSelf: 'center',
        }}
      >
        {/* Top Hero Card with Food Art, Close button & Favorite button */}
        <View className="w-full bg-brand-wash dark:bg-brand-washDark rounded-[32px] p-6 relative items-center justify-center min-h-[260px] border border-brand-primary/15 shadow-2xs mb-6">
          {/* Close button */}
          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => router.back()}
            className="absolute top-4 left-4 w-10 h-10 rounded-full bg-white dark:bg-[#231F1C] border border-line-light dark:border-line-dark items-center justify-center shadow-xs z-10"
          >
            <X size={18} weight="bold" color="#181512" />
          </TouchableOpacity>

          {/* Favorite Heart button */}
          <TouchableOpacity
            activeOpacity={0.8}
            onPress={handleToggleSaved}
            className="absolute top-4 right-4 w-10 h-10 rounded-full bg-white dark:bg-[#231F1C] border border-line-light dark:border-line-dark items-center justify-center shadow-xs z-10"
          >
            <Heart
              size={18}
              weight={saved ? 'fill' : 'regular'}
              color={saved ? '#FF5A36' : '#8A8179'}
            />
          </TouchableOpacity>

          {/* Hero Food Art */}
          <FoodArtView art={product.art} size={130} />
        </View>

        {/* Title & Price Row */}
        <View className="flex-row items-start justify-between mb-2">
          <View className="flex-1 mr-3">
            <Text className="text-2xl font-black text-ink dark:text-ink-darkDefault">
              {product.name}
            </Text>
            {restaurant && (
              <TouchableOpacity
                activeOpacity={0.7}
                onPress={() => router.push(`/restaurant/${restaurant.id}`)}
                className="mt-1"
              >
                <Text className="text-sm font-bold text-brand-primary">
                  from {restaurant.name}
                </Text>
              </TouchableOpacity>
            )}
          </View>

          <Text className="text-2xl font-black text-brand-primary">
            {formatMoney(product.priceCents)}
          </Text>
        </View>

        {/* Meta Facts Row: Rating, Calories, Time */}
        <View className="flex-row items-center gap-4 my-4 py-3 border-y border-line-light dark:border-line-dark">
          <View className="flex-row items-center">
            <Star size={16} weight="fill" color="#FFAA00" />
            <Text className="text-xs font-bold text-ink dark:text-ink-darkDefault ml-1.5">
              {product.rating.toFixed(1)}
            </Text>
          </View>

          <View className="flex-row items-center">
            <Flame size={16} weight="fill" color="#FF5A36" />
            <Text className="text-xs font-bold text-ink-muted ml-1.5">
              {product.calories} Calories
            </Text>
          </View>

          <View className="flex-row items-center">
            <ClockAfternoon size={16} color="#8A8179" />
            <Text className="text-xs font-bold text-ink-muted ml-1.5">
              {product.minutes} min
            </Text>
          </View>
        </View>

        {/* Description */}
        <Text className="text-sm leading-relaxed text-ink-muted dark:text-ink-darkMuted font-medium mb-6">
          {product.description}
        </Text>
      </ScrollView>

      {/* Floating Bottom Bar: Stepper & Add Button */}
      <View className="p-4 bg-card-light dark:bg-card-dark border-t border-line-light dark:border-line-dark flex-row items-center gap-4 shadow-sm">
        {/* Stepper */}
        <View className="flex-row items-center bg-[#F2EDE8] dark:bg-[#231F1C] rounded-full px-3 py-1.5 border border-line-light dark:border-line-dark">
          <TouchableOpacity
            onPress={handleDecrease}
            disabled={quantity <= 1}
            className="w-8 h-8 rounded-full items-center justify-center"
          >
            <Minus
              size={16}
              weight="bold"
              color={quantity > 1 ? '#181512' : '#B5AFA8'}
            />
          </TouchableOpacity>

          <Text className="text-base font-black text-ink dark:text-ink-darkDefault mx-3 min-w-[16px] text-center">
            {quantity}
          </Text>

          <TouchableOpacity
            onPress={handleIncrease}
            className="w-8 h-8 rounded-full items-center justify-center"
          >
            <Plus size={16} weight="bold" color="#181512" />
          </TouchableOpacity>
        </View>

        {/* Add Pill Button */}
        <TouchableOpacity
          activeOpacity={0.88}
          onPress={handleAddToCart}
          className="flex-1 h-13 rounded-full bg-brand-primary items-center justify-center shadow-xs"
        >
          <Text className="text-base font-extrabold text-white tracking-wide">
            Add · {formatMoney(totalPrice)}
          </Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}
