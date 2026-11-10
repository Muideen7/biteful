import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { ArrowLeft, Motorcycle, CaretRight, ArrowRight, ClockAfternoon } from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { useCartStore } from '@/stores/useCartStore';
import { FoodArtView } from '@/components/common/FoodArtView';
import { formatMoney } from '@/utils/money';

export default function OrdersScreen() {
  const router = useRouter();
  const products = useCatalogStore((s) => s.products);
  const addItem = useCartStore((s) => s.addItem);

  // Active simulated order
  const activeOrder = {
    id: 'BF-48213',
    restaurant: 'The Stack Burger Co.',
    status: 'On the way',
    etaMinutes: 20,
    items: [products[0], products[1]].filter(Boolean),
    totalCents: 1498 + 249,
  };

  // Past orders history
  const pastOrders = [
    {
      id: 'BF-39102',
      restaurant: 'Tokyo Ramen Lab',
      date: 'Yesterday, 7:42 PM',
      items: [products[2] || products[0]],
      totalCents: 1299 + 249,
    },
    {
      id: 'BF-28410',
      restaurant: 'Napoli Wood Fired Pizza',
      date: 'Nov 5, 1:15 PM',
      items: [products[3] || products[0]],
      totalCents: 1650 + 249,
    },
  ];

  const handleReorder = (items: typeof products) => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    items.forEach((p) => addItem(p));
    router.push('/(tabs)/cart');
  };

  return (
    <SafeAreaView
      edges={['top']}
      className="flex-1 bg-paper-light dark:bg-paper-dark"
    >
      {/* Header Bar */}
      <View className="px-4 py-3 flex-row items-center justify-between border-b border-line-light dark:border-line-dark">
        <TouchableOpacity
          activeOpacity={0.7}
          onPress={() => router.back()}
          className="w-10 h-10 rounded-full bg-card-light dark:bg-card-dark border border-line-light dark:border-line-dark items-center justify-center"
        >
          <ArrowLeft size={20} weight="bold" color="#181512" />
        </TouchableOpacity>

        <Text className="text-lg font-bold text-ink dark:text-ink-darkDefault">
          My Orders
        </Text>

        <View className="w-10" />
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16, paddingBottom: 40 }}
      >
        {/* Active Order Card */}
        <Text className="text-sm font-bold uppercase tracking-wider text-ink-muted mb-3">
          Active Delivery
        </Text>

        <TouchableOpacity
          activeOpacity={0.9}
          onPress={() => router.push(`/order/${activeOrder.id}`)}
          className="bg-brand-primary rounded-3xl p-5 mb-6 shadow-sm"
        >
          <View className="flex-row items-center justify-between">
            <View className="flex-row items-center">
              <View className="w-10 h-10 rounded-full bg-white/20 items-center justify-center mr-3">
                <Motorcycle size={22} weight="duotone" color="#FFFFFF" />
              </View>
              <View>
                <Text className="text-white font-extrabold text-base">
                  {activeOrder.restaurant}
                </Text>
                <Text className="text-white/80 text-xs font-semibold">
                  Order #{activeOrder.id}
                </Text>
              </View>
            </View>

            <View className="bg-brand-honey px-3 py-1 rounded-full">
              <Text className="text-ink text-xs font-black">
                {activeOrder.status}
              </Text>
            </View>
          </View>

          <View className="flex-row items-center justify-between mt-5 pt-4 border-t border-white/20">
            <View>
              <Text className="text-white/80 text-xs">Arriving in</Text>
              <Text className="text-white font-black text-xl">
                ~{activeOrder.etaMinutes} mins
              </Text>
            </View>

            <View className="flex-row items-center bg-white/20 px-3.5 py-1.5 rounded-full">
              <Text className="text-white text-xs font-bold mr-1">
                Track Live
              </Text>
              <ArrowRight size={14} weight="bold" color="#FFFFFF" />
            </View>
          </View>
        </TouchableOpacity>

        {/* Past Orders History */}
        <Text className="text-sm font-bold uppercase tracking-wider text-ink-muted mb-3">
          Past Orders
        </Text>

        {pastOrders.map((order) => (
          <View
            key={order.id}
            className="bg-card-light dark:bg-card-dark rounded-2xl p-4 mb-3.5 border border-line-light dark:border-line-dark shadow-xs"
          >
            <View className="flex-row items-center justify-between mb-3">
              <View>
                <Text className="text-base font-bold text-ink dark:text-ink-darkDefault">
                  {order.restaurant}
                </Text>
                <Text className="text-xs text-ink-muted mt-0.5">
                  {order.date} • #{order.id}
                </Text>
              </View>

              <Text className="text-sm font-extrabold text-ink dark:text-ink-darkDefault">
                {formatMoney(order.totalCents)}
              </Text>
            </View>

            {/* Thumbnail preview */}
            <View className="flex-row items-center justify-between pt-3 border-t border-line-light dark:border-line-dark">
              <View className="flex-row items-center">
                {order.items.map((item, idx) => (
                  <View key={idx} className="mr-2">
                    <FoodArtView art={item.art} size={32} />
                  </View>
                ))}
                <Text className="text-xs text-ink-soft dark:text-ink-darkSoft font-medium ml-1">
                  {order.items.map((i) => i.name).join(', ')}
                </Text>
              </View>

              <TouchableOpacity
                activeOpacity={0.8}
                onPress={() => handleReorder(order.items)}
                className="bg-brand-wash dark:bg-brand-washDark px-3 py-1.5 rounded-full"
              >
                <Text className="text-xs font-bold text-brand-deep">
                  Reorder
                </Text>
              </TouchableOpacity>
            </View>
          </View>
        ))}
      </ScrollView>
    </SafeAreaView>
  );
}
