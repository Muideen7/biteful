import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { HomeHeader } from '@/components/home/HomeHeader';
import { PromoCarousel } from '@/components/home/PromoCarousel';
import { CategoryStrip } from '@/components/home/CategoryStrip';
import { OrderAgainStrip } from '@/components/home/OrderAgainStrip';
import { DealsStrip } from '@/components/home/DealsStrip';
import { PopularRestaurantsStrip } from '@/components/home/PopularRestaurantsStrip';
import { FastDeliveryStrip } from '@/components/home/FastDeliveryStrip';
import { SectionHeader } from '@/components/common/SectionHeader';
import { FoodCard } from '@/components/common/FoodCard';
import { useCatalogStore } from '@/stores/useCatalogStore';

export default function HomeScreen() {
  const router = useRouter();
  const [searchQuery, setSearchQuery] = useState('');
  const { getBestSellers, selectedCategory, products } = useCatalogStore();

  const searchResults = searchQuery
    ? products.filter((p) =>
        p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        p.description?.toLowerCase().includes(searchQuery.toLowerCase())
      )
    : [];

  const bestSellers = getBestSellers();

  return (
    <SafeAreaView
      edges={['top']}
      className="flex-1 bg-paper-light dark:bg-paper-dark"
    >
      {/* Curved Tangerine Brand Header with Avatar, Address, Notifications & Search Pill */}
      <HomeHeader
        searchQuery={searchQuery}
        setSearchQuery={setSearchQuery}
        onPressAddress={() => router.push('/addresses')}
        onPressNotifications={() => router.push('/notifications')}
      />

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingBottom: 40 }}
      >
        {searchQuery ? (
          /* Live Search Results View */
          <View className="px-4 pt-4">
            <SectionHeader
              title={`Results for "${searchQuery}"`}
              actionText="Clear"
              onAction={() => setSearchQuery('')}
            />
            {searchResults.length === 0 ? (
              <View className="items-center py-12">
                <Text className="text-ink-muted text-base font-semibold">
                  No matching dishes found.
                </Text>
              </View>
            ) : (
              <View className="flex-row flex-wrap justify-between mt-2">
                {searchResults.map((product, idx) => (
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
            )}
          </View>
        ) : (
          /* Home Feed Matching Dishly & App Designer Blueprint */
          <>
            {/* 1. Fast & Free Delivery Promo Carousel */}
            <View className="pt-3">
              <PromoCarousel />
            </View>

            {/* 2. Categories Horizontal Strip */}
            <SectionHeader
              title="Categories"
              actionText="See All"
              onAction={() => router.push('/search')}
            />
            <CategoryStrip />

            {/* 3. Order Again Strip */}
            <SectionHeader
              title="Order again"
              actionText="My orders"
              onAction={() => router.push('/orders')}
            />
            <OrderAgainStrip />

            {/* 4. Deals For You High-Contrast Cards */}
            <SectionHeader
              title="Deals for you"
              actionText="See All"
              onAction={() => router.push('/(tabs)/offers')}
            />
            <DealsStrip />

            {/* 5. Popular Restaurants Near You */}
            <SectionHeader
              title="Popular restaurants near you"
              actionText="See All"
              onAction={() => router.push('/search')}
            />
            <PopularRestaurantsStrip />

            {/* 6. Fast Delivery (15 min or less) */}
            <SectionHeader
              title="Fast delivery · 15 min or less"
              actionText="See All"
              onAction={() => router.push('/search')}
            />
            <FastDeliveryStrip />

            {/* 7. Best Sellers 2-Column Food Grid */}
            <SectionHeader
              title={selectedCategory ? 'Filtered Dishes' : 'Best Sellers'}
            />
            <View className="px-4">
              {bestSellers.length === 0 ? (
                <View className="items-center py-8">
                  <Text className="text-ink-muted text-base font-medium">
                    No dishes found in this category
                  </Text>
                </View>
              ) : (
                <View className="flex-row flex-wrap justify-between">
                  {bestSellers.map((product, idx) => (
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
              )}
            </View>
          </>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}
