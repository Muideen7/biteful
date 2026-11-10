import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { useRouter } from 'expo-router';
import {
  ArrowLeft,
  MagnifyingGlass,
  X,
  Star,
  ClockAfternoon,
  CaretRight,
} from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { FoodCard } from '@/components/common/FoodCard';
import { FoodArtView } from '@/components/common/FoodArtView';

export default function SearchScreen() {
  const router = useRouter();
  const inputRef = useRef<TextInput>(null);
  const [query, setQuery] = useState('');
  const [recentSearches, setRecentSearches] = useState<string[]>([
    'Burger',
    'Sushi',
    'Pizza',
    'Ramen',
    'Chicken',
  ]);

  const { products, restaurants } = useCatalogStore();

  useEffect(() => {
    const timer = setTimeout(() => inputRef.current?.focus(), 150);
    return () => clearTimeout(timer);
  }, []);

  const handleSelectRecent = (term: string) => {
    Haptics.selectionAsync();
    setQuery(term);
  };

  const handleClearQuery = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setQuery('');
  };

  const trimmed = query.trim().toLowerCase();

  const matchedProducts = trimmed
    ? products.filter(
        (p) =>
          p.name.toLowerCase().includes(trimmed) ||
          p.description.toLowerCase().includes(trimmed)
      )
    : [];

  const matchedRestaurants = trimmed
    ? restaurants.filter(
        (r) =>
          r.name.toLowerCase().includes(trimmed) ||
          r.cuisine.toLowerCase().includes(trimmed)
      )
    : [];

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
        <View className="flex-row items-center">
          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => router.back()}
            className="w-10 h-10 rounded-full bg-white/20 border border-white/30 items-center justify-center mr-3"
          >
            <ArrowLeft size={20} weight="bold" color="#FFFFFF" />
          </TouchableOpacity>

          {/* Search Input Pill */}
          <View className="flex-1 h-12 bg-white dark:bg-[#231F1C] rounded-full px-4 flex-row items-center shadow-xs">
            <MagnifyingGlass size={18} weight="bold" color="#8A8179" />
            <TextInput
              ref={inputRef}
              placeholder="Search dishes or restaurants..."
              placeholderTextColor="#8A8179"
              value={query}
              onChangeText={setQuery}
              className="flex-1 ml-2.5 text-sm text-ink dark:text-ink-darkDefault font-medium"
            />
            {query.length > 0 && (
              <TouchableOpacity onPress={handleClearQuery} className="p-1">
                <X size={16} weight="bold" color="#8A8179" />
              </TouchableOpacity>
            )}
          </View>
        </View>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16, paddingBottom: 48 }}
      >
        {!trimmed ? (
          /* Recent Searches */
          <View>
            <Text className="text-sm font-bold uppercase tracking-wider text-ink-muted mb-3 px-1">
              Popular Searches
            </Text>
            <View className="flex-row flex-wrap gap-2">
              {recentSearches.map((term) => (
                <TouchableOpacity
                  key={term}
                  activeOpacity={0.8}
                  onPress={() => handleSelectRecent(term)}
                  className="px-4 py-2 rounded-full bg-card-light dark:bg-card-dark border border-line-light dark:border-line-dark shadow-2xs"
                >
                  <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                    {term}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>
        ) : (
          /* Search Results */
          <View>
            {/* Matched Restaurants */}
            {matchedRestaurants.length > 0 && (
              <View className="mb-6">
                <Text className="text-lg font-black text-ink dark:text-ink-darkDefault mb-3 px-1">
                  Restaurants · {matchedRestaurants.length}
                </Text>
                {matchedRestaurants.map((restaurant) => (
                  <TouchableOpacity
                    key={restaurant.id}
                    activeOpacity={0.85}
                    onPress={() => router.push(`/restaurant/${restaurant.id}`)}
                    className="p-3.5 rounded-2xl bg-card-light dark:bg-card-dark border border-line-light dark:border-line-dark mb-2.5 flex-row items-center justify-between shadow-2xs"
                  >
                    <View className="flex-row items-center flex-1 mr-2">
                      <FoodArtView art={restaurant.art} size={48} />
                      <View className="ml-3 flex-1">
                        <Text className="text-base font-bold text-ink dark:text-ink-darkDefault">
                          {restaurant.name}
                        </Text>
                        <Text className="text-xs text-ink-muted mt-0.5">
                          {restaurant.cuisine}
                        </Text>
                        <View className="flex-row items-center mt-1">
                          <Star size={12} weight="fill" color="#FFAA00" />
                          <Text className="text-xs font-bold text-ink dark:text-ink-darkDefault ml-1">
                            {restaurant.rating.toFixed(1)}
                          </Text>
                          <Text className="text-xs text-ink-muted ml-2">
                            • {restaurant.minMinutes}-{restaurant.maxMinutes} min
                          </Text>
                        </View>
                      </View>
                    </View>
                    <CaretRight size={18} color="#8A8179" />
                  </TouchableOpacity>
                ))}
              </View>
            )}

            {/* Matched Dishes */}
            <Text className="text-lg font-black text-ink dark:text-ink-darkDefault mb-3 px-1">
              Dishes · {matchedProducts.length}
            </Text>
            {matchedProducts.length === 0 && matchedRestaurants.length === 0 ? (
              <View className="items-center py-12">
                <Text className="text-ink-muted text-base font-semibold">
                  No matching results found for "{query}".
                </Text>
              </View>
            ) : (
              <View className="flex-row flex-wrap justify-between">
                {matchedProducts.map((product, idx) => (
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
        )}
      </ScrollView>
    </View>
  );
}
