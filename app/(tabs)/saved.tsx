import React from 'react';
import { View, Text, ScrollView } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Heart } from 'phosphor-react-native';
import { FoodCard } from '@/components/common/FoodCard';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { useSavedStore } from '@/stores/useSavedStore';

export default function SavedScreen() {
  const router = useRouter();
  const savedIds = useSavedStore((s) => s.savedProductIds);
  const products = useCatalogStore((s) => s.products);

  const savedDishes = products.filter((p) => savedIds.includes(p.id));

  return (
    <SafeAreaView
      edges={['top']}
      className="flex-1 bg-paper-light dark:bg-paper-dark"
    >
      <View className="px-4 py-3 border-b border-line-light dark:border-line-dark">
        <Text className="text-2xl font-bold tracking-tight text-ink dark:text-ink-darkDefault">
          Saved Dishes
        </Text>
        <Text className="text-sm text-ink-muted">
          Your favorite meals ready to re-order
        </Text>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16 }}
      >
        {savedDishes.length === 0 ? (
          <View className="items-center justify-center py-24">
            <View className="w-16 h-16 rounded-full bg-brand-wash dark:bg-brand-washDark items-center justify-center mb-3">
              <Heart size={32} weight="duotone" color="#FF5A36" />
            </View>
            <Text className="text-lg font-bold text-ink dark:text-ink-darkDefault">
              No saved dishes yet
            </Text>
            <Text className="text-sm text-ink-muted text-center mt-1 px-8">
              Tap the heart icon on any dish to save it here for later.
            </Text>
          </View>
        ) : (
          <View className="flex-row flex-wrap justify-between">
            {savedDishes.map((product, idx) => (
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
      </ScrollView>
    </SafeAreaView>
  );
}
