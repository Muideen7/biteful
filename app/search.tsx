import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import {
  ArrowLeft,
  MagnifyingGlass,
  X,
  ClockCounterClockwise,
  Trash,
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
  ]);

  const { products, restaurants, categories } = useCatalogStore();

  useEffect(() => {
    // Focus search input on mount
    const timer = setTimeout(() => inputRef.current?.focus(), 150);
    return () => clearTimeout(timer);
  }, []);

  const handleSelectRecent = (term: string) => {
    Haptics.selectionAsync();
    setQuery(term);
  };

  const handleRemoveRecent = (term: string) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setRecentSearches((prev) => prev.filter((t) => t !== term));
  };

  const handleClearAllRecent = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setRecentSearches([]);
  };

  const trimmed = query.trim().toLowerCase();

  // Results
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
    <SafeAreaView
      edges={['top']}
      className="flex-1 bg-paper-light dark:bg-paper-dark"
    >
      {/* Search Header Bar */}
      <View className="px-4 py-3 flex-row items-center border-b border-line-light dark:border-line-dark">
        <TouchableOpacity
          activeOpacity={0.7}
          onPress={() => router.back()}
          className="w-10 h-10 rounded-full bg-card-light dark:bg-card-dark border border-line-light dark:border-line-dark items-center justify-center mr-3"
        >
          <ArrowLeft size={20} weight="bold" color="#181512" />
        </TouchableOpacity>

        <View className="flex-1 flex-row items-center bg-card-light dark:bg-card-dark rounded-2xl px-3.5 py-2.5 border border-line-light dark:border-line-dark shadow-xs">
          <MagnifyingGlass size={18} weight="bold" color="#8A8179" />
          <TextInput
            ref={inputRef}
            placeholder="Search dishes or restaurants..."
            placeholderTextColor="#8A8179"
            value={query}
            onChangeText={setQuery}
            className="flex-1 ml-2 text-base text-ink dark:text-ink-darkDefault font-medium"
          />
          {query.length > 0 && (
            <TouchableOpacity
              onPress={() => setQuery('')}
              hitSlop={8}
              className="p-1"
            >
              <X size={16} weight="bold" color="#8A8179" />
            </TouchableOpacity>
          )}
        </View>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16, paddingBottom: 40 }}
      >
        {trimmed.length === 0 ? (
          <>
            {/* Recent Searches */}
            {recentSearches.length > 0 && (
              <View className="mb-6">
                <View className="flex-row items-center justify-between mb-3">
                  <View className="flex-row items-center">
                    <ClockCounterClockwise size={16} color="#8A8179" />
                    <Text className="text-sm font-bold uppercase tracking-wider text-ink-muted ml-2">
                      Recent Searches
                    </Text>
                  </View>
                  <TouchableOpacity onPress={handleClearAllRecent}>
                    <Text className="text-xs font-semibold text-brand-primary">
                      Clear all
                    </Text>
                  </TouchableOpacity>
                </View>

                <View className="flex-row flex-wrap gap-2">
                  {recentSearches.map((term) => (
                    <TouchableOpacity
                      key={term}
                      activeOpacity={0.75}
                      onPress={() => handleSelectRecent(term)}
                      className="flex-row items-center bg-card-light dark:bg-card-dark px-3 py-1.5 rounded-full border border-line-light dark:border-line-dark"
                    >
                      <Text className="text-sm font-medium text-ink dark:text-ink-darkDefault mr-1.5">
                        {term}
                      </Text>
                      <TouchableOpacity
                        hitSlop={6}
                        onPress={() => handleRemoveRecent(term)}
                      >
                        <X size={12} weight="bold" color="#8A8179" />
                      </TouchableOpacity>
                    </TouchableOpacity>
                  ))}
                </View>
              </View>
            )}

            {/* Popular Categories */}
            <Text className="text-sm font-bold uppercase tracking-wider text-ink-muted mb-3">
              Popular Categories
            </Text>
            <View className="flex-row flex-wrap gap-2 mb-6">
              {categories.slice(0, 6).map((cat) => (
                <TouchableOpacity
                  key={cat.id}
                  activeOpacity={0.75}
                  onPress={() => handleSelectRecent(cat.name)}
                  className="flex-row items-center bg-card-light dark:bg-card-dark px-3.5 py-2 rounded-2xl border border-line-light dark:border-line-dark"
                >
                  <FoodArtView art={cat.art} size={22} />
                  <Text className="ml-2 text-sm font-bold text-ink dark:text-ink-darkDefault">
                    {cat.name}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>

            {/* Top Restaurants */}
            <Text className="text-sm font-bold uppercase tracking-wider text-ink-muted mb-3">
              Popular Restaurants
            </Text>
            {restaurants.slice(0, 3).map((r) => (
              <TouchableOpacity
                key={r.id}
                activeOpacity={0.8}
                onPress={() => router.push(`/restaurant/${r.id}`)}
                className="bg-card-light dark:bg-card-dark rounded-2xl p-3.5 mb-3 border border-line-light dark:border-line-dark flex-row items-center"
              >
                <FoodArtView art={r.art} size={48} />
                <View className="ml-3 flex-1">
                  <Text className="text-base font-bold text-ink dark:text-ink-darkDefault">
                    {r.name}
                  </Text>
                  <Text className="text-xs text-ink-muted mt-0.5">
                    {r.cuisine} • {r.minMinutes}-{r.maxMinutes} min • ★{' '}
                    {r.rating.toFixed(1)}
                  </Text>
                </View>
              </TouchableOpacity>
            ))}
          </>
        ) : (
          <>
            {/* Search Results */}
            {matchedRestaurants.length > 0 && (
              <View className="mb-5">
                <Text className="text-base font-bold text-ink dark:text-ink-darkDefault mb-2">
                  Restaurants ({matchedRestaurants.length})
                </Text>
                {matchedRestaurants.map((r) => (
                  <TouchableOpacity
                    key={r.id}
                    activeOpacity={0.8}
                    onPress={() => router.push(`/restaurant/${r.id}`)}
                    className="bg-card-light dark:bg-card-dark rounded-2xl p-3 mb-2 border border-line-light dark:border-line-dark flex-row items-center"
                  >
                    <FoodArtView art={r.art} size={42} />
                    <View className="ml-3 flex-1">
                      <Text className="text-base font-bold text-ink dark:text-ink-darkDefault">
                        {r.name}
                      </Text>
                      <Text className="text-xs text-ink-muted">
                        {r.cuisine} • {r.minMinutes}-{r.maxMinutes} min
                      </Text>
                    </View>
                  </TouchableOpacity>
                ))}
              </View>
            )}

            <Text className="text-base font-bold text-ink dark:text-ink-darkDefault mb-3">
              Dishes ({matchedProducts.length})
            </Text>

            {matchedProducts.length === 0 && matchedRestaurants.length === 0 ? (
              <View className="items-center py-12">
                <Text className="text-base font-medium text-ink-muted">
                  No results found for "{query}"
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
          </>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}
