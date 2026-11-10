import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import {
  ArrowLeft,
  Bicycle,
  CheckCircle,
  ClockAfternoon,
  ArrowsClockwise,
  NavigationArrow,
} from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { useCartStore } from '@/stores/useCartStore';
import { FoodArtView } from '@/components/common/FoodArtView';
import { formatMoney } from '@/utils/money';

export default function OrdersScreen() {
  const router = useRouter();
  const getProductById = useCatalogStore((s) => s.getProductById);
  const addItem = useCartStore((s) => s.addItem);

  // Active simulated order
  const activeOrder = {
    id: 'BF-48213',
    status: 'On the way',
    etaMinutes: 7,
    itemsText: 'Tonkotsu Ramen, Pork Dumplings',
    count: 2,
    totalCents: 2250,
    art: { main: 'ramen', side: 'dumpling' },
  };

  // Past orders
  const pastOrders = [
    {
      id: 'BF-47760',
      status: 'Delivered',
      date: 'Yesterday, 7:51 PM',
      itemsText: '2 x Cheese Burger, 2 x Classic Cola',
      count: 4,
      totalCents: 1378,
      art: { main: 'burger', side: 'cola' },
      reorderIds: ['p_cheeseburger'],
    },
    {
      id: 'BF-46902',
      status: 'Delivered',
      date: '3 days ago',
      itemsText: 'Sushi Bento Box, Salmon Avocado Maki',
      count: 2,
      totalCents: 2647,
      art: { main: 'sushi', side: 'avocado' },
      reorderIds: ['p_bento', 'p_maki'],
    },
    {
      id: 'BF-45518',
      status: 'Delivered',
      date: '6 days ago',
      itemsText: 'Iced Caramel Latte',
      count: 1,
      totalCents: 490,
      art: { main: 'coffee' },
      reorderIds: ['p_cheeseburger'],
    },
  ];

  const handleReorder = (ids: string[]) => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    ids.forEach((id) => {
      const p = getProductById(id);
      if (p) addItem(p);
    });
    router.push('/(tabs)/cart');
  };

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
        <View className="flex-row items-center justify-between">
          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => router.back()}
            className="w-10 h-10 rounded-full bg-white/20 border border-white/30 items-center justify-center"
          >
            <ArrowLeft size={20} weight="bold" color="#FFFFFF" />
          </TouchableOpacity>

          <View className="items-center">
            <Text className="text-xl font-black text-white">My orders</Text>
            <Text className="text-xs font-semibold text-white/80 mt-0.5">
              1 on the way · 4 in total
            </Text>
          </View>

          <View className="w-10" />
        </View>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16, paddingBottom: 48 }}
      >
        {/* On the Way Section */}
        <Text className="text-xs font-black uppercase tracking-wider text-ink-muted mb-3 px-1">
          On the way
        </Text>

        <View className="bg-card-light dark:bg-card-dark rounded-3xl p-4 border border-line-light dark:border-line-dark shadow-2xs mb-6">
          <View className="flex-row items-center justify-between mb-3">
            <Text className="text-sm font-black text-ink dark:text-ink-darkDefault">
              {activeOrder.id}
            </Text>
            <View className="flex-row items-center bg-brand-mint/15 px-2.5 py-1 rounded-full">
              <Bicycle size={13} weight="bold" color="#00C48C" />
              <Text className="text-xs font-bold text-brand-mint ml-1">
                On the way
              </Text>
            </View>
          </View>

          <View className="flex-row items-center my-1">
            <View className="w-14 h-14 rounded-2xl bg-brand-wash dark:bg-brand-washDark items-center justify-center mr-3">
              <FoodArtView art={activeOrder.art} size={42} />
            </View>
            <View className="flex-1">
              <Text
                numberOfLines={1}
                className="text-sm font-bold text-ink dark:text-ink-darkDefault"
              >
                {activeOrder.itemsText}
              </Text>
              <Text className="text-xs font-bold text-brand-primary mt-1">
                Arriving in {activeOrder.etaMinutes} min
              </Text>
            </View>
          </View>

          <View className="flex-row items-center justify-between mt-3 pt-3 border-t border-line-light dark:border-line-dark">
            <Text className="text-xs font-bold text-ink-muted">
              {activeOrder.count} items · {formatMoney(activeOrder.totalCents)}
            </Text>

            <TouchableOpacity
              activeOpacity={0.88}
              onPress={() => router.push(`/order/${activeOrder.id}`)}
              className="px-4 py-2 rounded-full bg-brand-primary flex-row items-center shadow-xs"
            >
              <NavigationArrow size={13} weight="fill" color="#FFFFFF" />
              <Text className="text-xs font-black text-white ml-1.5">
                Track
              </Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Past Orders Section */}
        <Text className="text-xs font-black uppercase tracking-wider text-ink-muted mb-3 px-1">
          Past orders
        </Text>

        <View className="space-y-3">
          {pastOrders.map((order) => (
            <View
              key={order.id}
              className="bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-line-light dark:border-line-dark shadow-2xs mb-3"
            >
              <View className="flex-row items-center justify-between mb-2">
                <Text className="text-sm font-black text-ink dark:text-ink-darkDefault">
                  {order.id}
                </Text>
                <View className="flex-row items-center bg-[#F2EDE8] dark:bg-[#231F1C] px-2.5 py-0.5 rounded-full">
                  <CheckCircle size={13} weight="fill" color="#8A8179" />
                  <Text className="text-[11px] font-bold text-ink-muted ml-1">
                    Delivered
                  </Text>
                </View>
              </View>

              <View className="flex-row items-center my-1">
                <View className="w-12 h-12 rounded-xl bg-paper-light dark:bg-paper-dark items-center justify-center mr-3 border border-line-light dark:border-line-dark">
                  <FoodArtView art={order.art} size={36} />
                </View>
                <View className="flex-1">
                  <Text
                    numberOfLines={1}
                    className="text-xs font-bold text-ink dark:text-ink-darkDefault"
                  >
                    {order.itemsText}
                  </Text>
                  <Text className="text-[11px] text-ink-muted mt-0.5">
                    {order.date}
                  </Text>
                </View>
              </View>

              <View className="flex-row items-center justify-between mt-2.5 pt-2.5 border-t border-line-light dark:border-line-dark">
                <Text className="text-xs text-ink-muted font-medium">
                  {order.count} items · {formatMoney(order.totalCents)}
                </Text>

                <TouchableOpacity
                  activeOpacity={0.8}
                  onPress={() => handleReorder(order.reorderIds)}
                  className="px-3 py-1.5 rounded-full bg-paper-light dark:bg-paper-dark border border-line-light dark:border-line-dark flex-row items-center shadow-2xs"
                >
                  <ArrowsClockwise size={13} weight="bold" color="#FF5A36" />
                  <Text className="text-xs font-bold text-brand-primary ml-1">
                    Reorder
                  </Text>
                </TouchableOpacity>
              </View>
            </View>
          ))}
        </View>
      </ScrollView>
    </View>
  );
}
