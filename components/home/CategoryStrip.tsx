import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import * as Haptics from 'expo-haptics';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { FoodArtView } from '@/components/common/FoodArtView';

export function CategoryStrip() {
  const { categories, selectedCategory, setSelectedCategory } = useCatalogStore();

  const handleSelect = (id: string | null) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setSelectedCategory(id);
  };

  const isAllSelected = selectedCategory === null;

  return (
    <View className="py-1">
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 4 }}
      >
        {/* "All" Category Card */}
        <TouchableOpacity
          activeOpacity={0.8}
          onPress={() => handleSelect(null)}
          className={`mr-3 w-[72px] h-[82px] rounded-2xl items-center justify-center border shadow-2xs ${
            isAllSelected
              ? 'bg-brand-primary border-brand-primary'
              : 'bg-card-light dark:bg-card-dark border-line-light dark:border-line-dark'
          }`}
        >
          <View className="mb-1">
            <FoodArtView
              art={{ main: 'fries', side: 'burger' }}
              size={34}
            />
          </View>
          <Text
            className={`text-xs font-black ${
              isAllSelected
                ? 'text-white'
                : 'text-ink dark:text-ink-darkDefault'
            }`}
          >
            All
          </Text>
        </TouchableOpacity>

        {/* Individual Categories */}
        {categories.map((cat) => {
          const isSelected = selectedCategory === cat.id;
          return (
            <TouchableOpacity
              key={cat.id}
              activeOpacity={0.8}
              onPress={() => handleSelect(cat.id)}
              className={`mr-3 w-[72px] h-[82px] rounded-2xl items-center justify-center border shadow-2xs ${
                isSelected
                  ? 'bg-brand-primary border-brand-primary'
                  : 'bg-card-light dark:bg-card-dark border-line-light dark:border-line-dark'
              }`}
            >
              <View className="mb-1">
                <FoodArtView art={cat.art} size={34} />
              </View>
              <Text
                numberOfLines={1}
                className={`text-xs font-black ${
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
