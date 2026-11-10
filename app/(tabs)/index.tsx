import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TextInput,
  TouchableOpacity,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { MagnifyingGlass, SlidersHorizontal } from 'phosphor-react-native';
import { HomeHeader } from '@/components/home/HomeHeader';
import { PromoCarousel } from '@/components/home/PromoCarousel';
import { CategoryStrip } from '@/components/home/CategoryStrip';
import { DealsStrip } from '@/components/home/DealsStrip';
import { SectionHeader } from '@/components/common/SectionHeader';
import { FoodCard } from '@/components/common/FoodCard';
import { useCatalogStore } from '@/stores/useCatalogStore';

export default function HomeScreen() {
  const router = useRouter();
  const [searchQuery, setSearchQuery] = useState('');
  const { getBestSellers, selectedCategory } = useCatalogStore();

  const bestSellers = getBestSellers().filter((p) =>
    searchQuery ? p.name.toLowerCase().includes(searchQuery.toLowerCase()) : true
  );

  return (
    <SafeAreaView
      edges={['top']}
      className="flex-1 bg-paper-light dark:bg-paper-dark"
    >
      <HomeHeader
        onPressAddress={() => router.push('/addresses')}
        onPressNotifications={() => router.push('/notifications')}
      />

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingBottom: 32 }}
      >
        {/* Search Bar */}
        <View className="px-4 py-3">
          <View className="flex-row items-center bg-card-light dark:bg-card-dark rounded-2xl px-3.5 py-2.5 border border-line-light dark:border-line-dark shadow-xs">
            <MagnifyingGlass size={20} weight="bold" color="#8A8179" />
            <TextInput
              placeholder="Search dishes or restaurants..."
              placeholderTextColor="#8A8179"
              value={searchQuery}
              onChangeText={setSearchQuery}
              className="flex-1 ml-2.5 text-base text-ink dark:text-ink-darkDefault font-medium"
            />
            <TouchableOpacity
              activeOpacity={0.7}
              onPress={() => router.push('/search')}
              className="p-1"
            >
              <SlidersHorizontal size={18} weight="bold" color="#FF5A36" />
            </TouchableOpacity>
          </View>
        </View>

        {/* Promo Banner Carousel */}
        {!searchQuery && <PromoCarousel />}

        {/* Categories Strip */}
        {!searchQuery && (
          <>
            <SectionHeader title="Categories" />
            <CategoryStrip />
          </>
        )}

        {/* Deals Strip */}
        {!searchQuery && (
          <>
            <SectionHeader title="Deals for you" actionText="All offers" onAction={() => router.push('/(tabs)/offers')} />
            <DealsStrip />
          </>
        )}

        {/* Best Sellers Grid */}
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
      </ScrollView>
    </SafeAreaView>
  );
}
