import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { Star, ClockAfternoon, MapPin, Bicycle } from 'phosphor-react-native';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { FoodArtView } from '@/components/common/FoodArtView';
import { formatMoney } from '@/utils/money';

export function PopularRestaurantsStrip() {
  const router = useRouter();
  const restaurants = useCatalogStore((s) => s.restaurants);

  if (restaurants.length === 0) return null;

  return (
    <View className="py-1">
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 4 }}
      >
        {restaurants.map((restaurant) => {
          const isFree = restaurant.deliveryFeeCents === 0;
          return (
            <TouchableOpacity
              key={restaurant.id}
              activeOpacity={0.85}
              onPress={() => router.push(`/restaurant/${restaurant.id}`)}
              className="mr-3 w-[220px] bg-card-light dark:bg-card-dark rounded-2xl p-3.5 border border-line-light dark:border-line-dark shadow-2xs justify-between"
            >
              {/* Delivery fee badge */}
              <View className="flex-row items-center mb-2">
                <View
                  className={`flex-row items-center px-2 py-0.5 rounded-full ${
                    isFree
                      ? 'bg-brand-mint/15'
                      : 'bg-paper-light dark:bg-paper-dark border border-line-light dark:border-line-dark'
                  }`}
                >
                  <Bicycle
                    size={12}
                    weight="bold"
                    color={isFree ? '#00C48C' : '#FF5A36'}
                  />
                  <Text
                    className={`text-[11px] font-bold ml-1 ${
                      isFree ? 'text-brand-mint' : 'text-ink dark:text-ink-darkDefault'
                    }`}
                  >
                    {isFree
                      ? 'Free delivery'
                      : `${formatMoney(restaurant.deliveryFeeCents)} delivery`}
                  </Text>
                </View>
              </View>

              {/* Centered Food Art */}
              <View className="items-center justify-center my-2">
                <FoodArtView art={restaurant.art} size={64} />
              </View>

              {/* Name and Rating */}
              <View className="flex-row items-center justify-between mt-1">
                <Text
                  numberOfLines={1}
                  className="text-base font-bold text-ink dark:text-ink-darkDefault flex-1 mr-1"
                >
                  {restaurant.name}
                </Text>
                <View className="flex-row items-center bg-brand-wash dark:bg-brand-washDark px-1.5 py-0.5 rounded-md">
                  <Star size={12} weight="fill" color="#FFAA00" />
                  <Text className="text-xs font-bold text-brand-deep ml-0.5">
                    {restaurant.rating.toFixed(1)}
                  </Text>
                </View>
              </View>

              {/* Cuisine */}
              <Text
                numberOfLines={1}
                className="text-xs text-ink-muted mt-0.5"
              >
                {restaurant.cuisine}
              </Text>

              {/* Time & Distance */}
              <View className="flex-row items-center mt-2 pt-2 border-t border-line-light dark:border-line-dark">
                <View className="flex-row items-center mr-3">
                  <ClockAfternoon size={12} color="#8A8179" />
                  <Text className="text-[11px] text-ink-muted ml-1 font-medium">
                    {restaurant.minMinutes}-{restaurant.maxMinutes} min
                  </Text>
                </View>
                <View className="flex-row items-center">
                  <MapPin size={12} color="#8A8179" />
                  <Text className="text-[11px] text-ink-muted ml-1 font-medium">
                    {restaurant.distanceKm} km
                  </Text>
                </View>
              </View>
            </TouchableOpacity>
          );
        })}
      </ScrollView>
    </View>
  );
}

