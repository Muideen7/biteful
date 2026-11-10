import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { HeartBreak, Heart } from 'phosphor-react-native';
import { useSavedStore } from '@/stores/useSavedStore';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { FoodCard } from '@/components/common/FoodCard';

export default function SavedScreen() {
  const router = useRouter();
  const savedProductIds = useSavedStore((s) => s.savedProductIds);
  const products = useCatalogStore((s) => s.products);

  const savedProducts = products.filter((p) => savedProductIds.includes(p.id));

  return (
    <View className="flex-1 bg-paper-light dark:bg-paper-dark">
      {/* Curved Tangerine Brand Header */}
      <View
        className="bg-brand-primary pt-12 pb-5 px-4 shadow-sm"
        style={{
          borderBottomLeftRadius: 32,
          borderBottomRightRadius: 32,
        }}
      >
        <Text className="text-2xl font-black text-white">Saved</Text>
        <Text className="text-xs font-semibold text-white/85 mt-0.5">
          {savedProducts.length} {savedProducts.length === 1 ? 'dish' : 'dishes'}
        </Text>
      </View>

      {savedProducts.length === 0 ? (
        <View className="flex-1 items-center justify-center p-8">
          <View className="w-20 h-20 rounded-full bg-brand-wash dark:bg-brand-washDark items-center justify-center mb-4">
            <Heart size={40} weight="duotone" color="#FF5A36" />
          </View>
          <Text className="text-xl font-black text-ink dark:text-ink-darkDefault mb-1 text-center">
            No saved dishes yet
          </Text>
          <Text className="text-sm text-ink-muted text-center mb-6">
            Tap the heart icon on any dish to bookmark your favorites here.
          </Text>
          <TouchableOpacity
            activeOpacity={0.88}
            onPress={() => router.push('/(tabs)/')}
            className="px-6 py-3 rounded-full bg-brand-primary shadow-xs"
          >
            <Text className="text-sm font-bold text-white">Explore Menu</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <ScrollView
          showsVerticalScrollIndicator={false}
          contentContainerStyle={{ padding: 16, paddingBottom: 48 }}
        >
          <View className="flex-row flex-wrap justify-between">
            {savedProducts.map((product, idx) => (
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
      )}
    </View>
  );
}
