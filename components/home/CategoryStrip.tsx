import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import * as Haptics from 'expo-haptics';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { FoodArtView } from '@/components/common/FoodArtView';

export function CategoryStrip() {
  const { categories, selectedCategory, setSelectedCategory } = useCatalogStore();

  const handleSelect = (id: string) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setSelectedCategory(id);
  };

  return (
    <View className="py-2">
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingHorizontal: 16 }}
      >
        {categories.map((cat) => {
          const isSelected = selectedCategory === cat.id;
          return (
            <TouchableOpacity
              key={cat.id}
              activeOpacity={0.75}
              onPress={() => handleSelect(cat.id)}
              className={`mr-3 px-3 py-2 rounded-2xl flex-row items-center border ${
                isSelected
                  ? 'bg-brand-primary border-brand-primary shadow-sm'
                  : 'bg-card-light dark:bg-card-dark border-line-light dark:border-line-dark'
              }`}
            >
              <FoodArtView art={cat.art} size={28} />
              <Text
                className={`ml-2 text-sm font-bold ${
                  isSelected
                    ? 'text-white'
                    : 'text-ink dark:text-ink-darkDefault'
                }`}
              >
                {cat.name}
              </Text>
            </TouchableOpacity>
          );
        })}
      </ScrollView>
    </View>
  );
}
