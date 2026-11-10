import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { ArrowLeft, Star, ClockAfternoon, MapPin, Tag } from 'phosphor-react-native';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { FoodArtView } from '@/components/common/FoodArtView';
import { FoodCard } from '@/components/common/FoodCard';
import { formatMoney } from '@/utils/money';

export default function RestaurantScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();

  const restaurant = useCatalogStore((s) => s.getRestaurantById(id || ''));
  const getProductsByRestaurant = useCatalogStore((s) => s.getProductsByRestaurant);
  const menuDishes = React.useMemo(() => getProductsByRestaurant(id || ''), [getProductsByRestaurant, id]);

  if (!restaurant) {
    return (
      <SafeAreaView className="flex-1 bg-paper-light dark:bg-paper-dark p-4">
        <TouchableOpacity onPress={() => router.back()} className="p-2">
          <ArrowLeft size={24} color="#181512" />
        </TouchableOpacity>
        <Text className="text-center mt-12 text-ink-muted">Restaurant not found</Text>
      </SafeAreaView>
    );
  }

  return (
    <View className="flex-1 bg-paper-light dark:bg-paper-dark">
      {/* Header Banner */}
      <View className="bg-brand-primary pt-12 pb-6 px-4 rounded-b-[32px] relative overflow-hidden shadow-sm">
        <View className="flex-row items-center justify-between mb-2">
          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => router.back()}
            className="w-10 h-10 rounded-full bg-white/20 items-center justify-center"
          >
            <ArrowLeft size={20} weight="bold" color="#FFFFFF" />
          </TouchableOpacity>
        </View>

        <View className="items-center justify-center my-2">
          <FoodArtView art={restaurant.art} size={110} />
          <Text className="text-2xl font-black text-white mt-3 text-center">
            {restaurant.name}
          </Text>
          <Text className="text-sm font-semibold text-white/80 mt-0.5">
            {restaurant.cuisine}
          </Text>
        </View>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16, paddingBottom: 48 }}
      >
        {/* Facts Card */}
        <View className="bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-line-light dark:border-line-dark flex-row justify-around mb-4 shadow-xs">
          {/* Rating */}
          <View className="items-center">
            <View className="flex-row items-center">
              <Star size={16} weight="fill" color="#FFAA00" />
              <Text className="text-base font-extrabold text-ink dark:text-ink-darkDefault ml-1">
                {restaurant.rating.toFixed(1)}
              </Text>
            </View>
            <Text className="text-xs text-ink-muted mt-0.5">Rating</Text>
          </View>

          <View className="w-px h-8 bg-line-light dark:bg-line-dark self-center" />

          {/* Delivery ETA */}
          <View className="items-center">
            <View className="flex-row items-center">
              <ClockAfternoon size={16} weight="bold" color="#FF5A36" />
              <Text className="text-base font-extrabold text-ink dark:text-ink-darkDefault ml-1">
                {restaurant.minMinutes}-{restaurant.maxMinutes}m
              </Text>
            </View>
            <Text className="text-xs text-ink-muted mt-0.5">Delivery</Text>
          </View>

          <View className="w-px h-8 bg-line-light dark:bg-line-dark self-center" />

          {/* Distance */}
          <View className="items-center">
            <View className="flex-row items-center">
              <MapPin size={16} weight="fill" color="#FF5A36" />
              <Text className="text-base font-extrabold text-ink dark:text-ink-darkDefault ml-1">
                {restaurant.distanceKm.toFixed(1)} km
              </Text>
            </View>
            <Text className="text-xs text-ink-muted mt-0.5">Away</Text>
          </View>
        </View>

        {/* Delivery Fee Chip */}
        <View className="flex-row items-center self-start bg-brand-wash dark:bg-brand-washDark px-3 py-1.5 rounded-full mb-5">
          <Tag size={14} weight="fill" color="#FF5A36" />
          <Text className="text-xs font-bold text-brand-deep ml-1.5">
            {restaurant.deliveryFeeCents === 0
              ? 'Free Delivery'
              : `Delivery: ${formatMoney(restaurant.deliveryFeeCents)}`}
          </Text>
        </View>

        {/* Menu Grid */}
        <Text className="text-xl font-bold tracking-tight text-ink dark:text-ink-darkDefault mb-3">
          Menu ({menuDishes.length} items)
        </Text>

        <View className="flex-row flex-wrap justify-between">
          {menuDishes.map((product, idx) => (
            <View
              key={product.id}
              style={{ width: '48%' }}
              className={idx % 2 === 0 ? 'pr-1.5' : 'pl-1.5'}
            >
              <FoodCard
                product={product}
                onPress={() => router.push(`/dish/${product.id}`)}
              />
            </View>
          ))}
        </View>
      </ScrollView>
    </View>
  );
}
