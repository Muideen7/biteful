import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import {
  ArrowLeft,
  Star,
  ClockAfternoon,
  MapPin,
  Bicycle,
} from 'phosphor-react-native';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { FoodArtView } from '@/components/common/FoodArtView';
import { FoodCard } from '@/components/common/FoodCard';
import { formatMoney } from '@/utils/money';

export default function RestaurantScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();

  const restaurant = useCatalogStore((s) => s.getRestaurantById(id || ''));
  const getProductsByRestaurant = useCatalogStore((s) => s.getProductsByRestaurant);
  const menuDishes = React.useMemo(
    () => getProductsByRestaurant(id || ''),
    [getProductsByRestaurant, id]
  );

  if (!restaurant) {
    return (
      <SafeAreaView className="flex-1 bg-paper-light dark:bg-paper-dark p-4 items-center justify-center">
        <TouchableOpacity
          onPress={() => router.back()}
          className="absolute top-12 left-4 w-10 h-10 rounded-full bg-card-light dark:bg-card-dark items-center justify-center"
        >
          <ArrowLeft size={20} color="#181512" />
        </TouchableOpacity>
        <Text className="text-ink-muted font-bold text-base">
          Restaurant not found
        </Text>
      </SafeAreaView>
    );
  }

  const isFreeDelivery = restaurant.deliveryFeeCents === 0;

  return (
    <View className="flex-1 bg-paper-light dark:bg-paper-dark">
      {/* Curved Tangerine Brand Header */}
      <View
        className="bg-brand-primary pt-12 pb-6 px-4 shadow-sm"
        style={{
          borderBottomLeftRadius: 36,
          borderBottomRightRadius: 36,
        }}
      >
        <View className="flex-row items-center justify-between mb-2">
          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => router.back()}
            className="w-10 h-10 rounded-full bg-white/20 border border-white/30 items-center justify-center"
          >
            <ArrowLeft size={20} weight="bold" color="#FFFFFF" />
          </TouchableOpacity>

          <Text className="text-xl font-black text-white">
            {restaurant.name}
          </Text>

          <View className="w-10" />
        </View>

        {/* Hero Food Art */}
        <View className="items-center justify-center my-2">
          <FoodArtView art={restaurant.art} size={96} />
        </View>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16, paddingBottom: 48 }}
      >
        {/* Cuisine Subtitle */}
        <Text className="text-center text-sm font-semibold text-ink-muted mb-4">
          {restaurant.cuisine}
        </Text>

        {/* Fact Pills Row */}
        <View className="bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-line-light dark:border-line-dark flex-row justify-around mb-3 shadow-2xs">
          {/* Rating */}
          <View className="items-center">
            <View className="flex-row items-center">
              <Star size={15} weight="fill" color="#FFAA00" />
              <Text className="text-base font-extrabold text-ink dark:text-ink-darkDefault ml-1">
                {restaurant.rating.toFixed(1)}
              </Text>
            </View>
            <Text className="text-[11px] text-ink-muted mt-0.5">Rating</Text>
          </View>

          {/* Delivery Time */}
          <View className="items-center">
            <View className="flex-row items-center">
              <ClockAfternoon size={15} color="#8A8179" />
              <Text className="text-base font-extrabold text-ink dark:text-ink-darkDefault ml-1">
                {restaurant.minMinutes}-{restaurant.maxMinutes} min
              </Text>
            </View>
            <Text className="text-[11px] text-ink-muted mt-0.5">Delivery</Text>
          </View>

          {/* Distance */}
          <View className="items-center">
            <View className="flex-row items-center">
              <MapPin size={15} color="#8A8179" />
              <Text className="text-base font-extrabold text-ink dark:text-ink-darkDefault ml-1">
                {restaurant.distanceKm} km
              </Text>
            </View>
            <Text className="text-[11px] text-ink-muted mt-0.5">Away</Text>
          </View>
        </View>

        {/* Delivery Fee Tag */}
        <View className="flex-row items-center justify-center mb-6">
          <View
            className={`flex-row items-center px-3 py-1 rounded-full ${
              isFreeDelivery
                ? 'bg-brand-mint/15'
                : 'bg-card-light dark:bg-card-dark border border-line-light dark:border-line-dark'
            }`}
          >
            <Bicycle
              size={13}
              weight="bold"
              color={isFreeDelivery ? '#00C48C' : '#FF5A36'}
            />
            <Text
              className={`text-xs font-bold ml-1.5 ${
                isFreeDelivery
                  ? 'text-brand-mint'
                  : 'text-ink dark:text-ink-darkDefault'
              }`}
            >
              {isFreeDelivery
                ? 'Free delivery'
                : `${formatMoney(restaurant.deliveryFeeCents)} delivery`}
            </Text>
          </View>
        </View>

        {/* Menu Section Header */}
        <Text className="text-xl font-black text-ink dark:text-ink-darkDefault mb-4 px-1">
          Menu
        </Text>

        {/* 2-Column Food Grid */}
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
