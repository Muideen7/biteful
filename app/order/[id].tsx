import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import {
  ArrowLeft,
  Motorcycle,
  CheckCircle,
  ClockAfternoon,
  MapPin,
  CookingPot,
  Receipt,
  ArrowRight,
} from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { useCartStore } from '@/stores/useCartStore';
import { useSessionStore } from '@/stores/useSessionStore';
import { FoodArtView } from '@/components/common/FoodArtView';
import { AnimatedRider } from '@/components/common/AnimatedRider';
import { formatMoney } from '@/utils/money';

export default function OrderDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();

  const currentAddress = useSessionStore((s) => s.currentAddress());
  const products = useCatalogStore((s) => s.products);
  const addItem = useCartStore((s) => s.addItem);

  // Mock order data derived from products
  const sampleItems = products.slice(0, 2);
  const subtotal = sampleItems.reduce((acc, p) => acc + p.priceCents, 0);
  const deliveryFee = 249;
  const total = subtotal + deliveryFee;

  const handleReorder = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    sampleItems.forEach((p) => addItem(p));
    router.push('/(tabs)/cart');
  };

  return (
    <SafeAreaView
      edges={['top']}
      className="flex-1 bg-paper-light dark:bg-paper-dark"
    >
      {/* Top Header */}
      <View className="px-4 py-3 flex-row items-center justify-between border-b border-line-light dark:border-line-dark">
        <TouchableOpacity
          activeOpacity={0.7}
          onPress={() => router.back()}
          className="w-10 h-10 rounded-full bg-card-light dark:bg-card-dark border border-line-light dark:border-line-dark items-center justify-center"
        >
          <ArrowLeft size={20} weight="bold" color="#181512" />
        </TouchableOpacity>

        <Text className="text-lg font-bold text-ink dark:text-ink-darkDefault">
          Order #{id || 'DL-48213'}
        </Text>

        <View className="w-10" />
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16, paddingBottom: 100 }}
      >
        {/* Live Status Tracker Hero */}
        <View className="bg-brand-primary rounded-3xl p-5 mb-5 relative overflow-hidden shadow-sm">
          <View className="flex-row items-center justify-between">
            <View className="flex-1 pr-3">
              <Text className="text-white/80 font-bold text-xs uppercase tracking-wider">
                Estimated Delivery
              </Text>
              <Text className="text-white text-3xl font-black mt-1">
                18 - 25 min
              </Text>
              <Text className="text-brand-honey font-semibold text-sm mt-0.5">
                On the way to your door
              </Text>
            </View>

            <View className="items-center justify-center">
              <AnimatedRider size={105} />
            </View>
          </View>

          {/* Timeline steps */}
          <View className="mt-6 pt-5 border-t border-white/20 flex-row items-center justify-between">
            <View className="items-center">
              <CheckCircle size={20} weight="fill" color="#FFAA00" />
              <Text className="text-white text-xs font-bold mt-1">Placed</Text>
            </View>
            <View className="h-0.5 flex-1 bg-white/40 mx-2" />
            <View className="items-center">
              <CookingPot size={20} weight="fill" color="#FFAA00" />
              <Text className="text-white text-xs font-bold mt-1">Cooking</Text>
            </View>
            <View className="h-0.5 flex-1 bg-white/40 mx-2" />
            <View className="items-center">
              <Motorcycle size={20} weight="fill" color="#FFAA00" />
              <Text className="text-white text-xs font-bold mt-1">Riding</Text>
            </View>
            <View className="h-0.5 flex-1 bg-white/20 mx-2" />
            <View className="items-center">
              <ClockAfternoon size={20} weight="regular" color="#FFFFFF" />
              <Text className="text-white/60 text-xs font-medium mt-1">
                Delivered
              </Text>
            </View>
          </View>
        </View>

        {/* Deliver To Card */}
        <View className="bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-line-light dark:border-line-dark mb-4">
          <View className="flex-row items-center">
            <View className="w-8 h-8 rounded-full bg-brand-wash dark:bg-brand-washDark items-center justify-center mr-3">
              <MapPin size={18} weight="fill" color="#FF5A36" />
            </View>
            <View className="flex-1">
              <Text className="text-xs font-bold uppercase tracking-wider text-ink-muted">
                Delivery Location
              </Text>
              <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault mt-0.5">
                {currentAddress.label} • {currentAddress.line}
              </Text>
            </View>
          </View>
        </View>

        {/* Items List */}
        <View className="bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-line-light dark:border-line-dark mb-4">
          <Text className="text-base font-bold text-ink dark:text-ink-darkDefault mb-3">
            Items in Order
          </Text>

          {sampleItems.map((item, idx) => (
            <View
              key={item.id}
              className={`flex-row items-center justify-between py-2.5 ${
                idx !== sampleItems.length - 1
                  ? 'border-b border-line-light dark:border-line-dark'
                  : ''
              }`}
            >
              <FoodArtView art={item.art} size={40} />
              <View className="flex-1 ml-3">
                <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                  {item.name}
                </Text>
                <Text className="text-xs text-ink-muted">Qty: 1</Text>
              </View>
              <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                {formatMoney(item.priceCents)}
              </Text>
            </View>
          ))}
        </View>

        {/* Receipt Totals */}
        <View className="bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-line-light dark:border-line-dark mb-6">
          <View className="flex-row items-center mb-3">
            <Receipt size={18} weight="duotone" color="#FF5A36" />
            <Text className="text-base font-bold text-ink dark:text-ink-darkDefault ml-2">
              Receipt
            </Text>
          </View>

          <View className="flex-row justify-between mb-2">
            <Text className="text-sm text-ink-muted">Subtotal</Text>
            <Text className="text-sm font-semibold text-ink dark:text-ink-darkDefault">
              {formatMoney(subtotal)}
            </Text>
          </View>

          <View className="flex-row justify-between mb-3">
            <Text className="text-sm text-ink-muted">Delivery fee</Text>
            <Text className="text-sm font-semibold text-ink dark:text-ink-darkDefault">
              {formatMoney(deliveryFee)}
            </Text>
          </View>

          <View className="pt-2 border-t border-line-light dark:border-line-dark flex-row justify-between">
            <Text className="text-base font-bold text-ink dark:text-ink-darkDefault">
              Paid Total
            </Text>
            <Text className="text-lg font-extrabold text-brand-primary">
              {formatMoney(total)}
            </Text>
          </View>
        </View>

        {/* Reorder Button */}
        <TouchableOpacity
          activeOpacity={0.88}
          onPress={handleReorder}
          className="bg-brand-primary py-4 rounded-full flex-row items-center justify-center shadow-md"
        >
          <Text className="text-white font-extrabold text-base mr-2">
            Reorder Everything • {formatMoney(subtotal)}
          </Text>
          <ArrowRight size={18} weight="bold" color="#FFFFFF" />
        </TouchableOpacity>
      </ScrollView>
    </SafeAreaView>
  );
}
