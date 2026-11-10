import React from 'react';
import { View, Text, ScrollView, TouchableOpacity, Image } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import {
  ArrowLeft,
  Bicycle,
  CheckCircle,
  ClockAfternoon,
  MapPin,
  CookingPot,
  ArrowsClockwise,
  PhoneCall,
  House,
} from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useCatalogStore } from '@/stores/useCatalogStore';
import { useCartStore } from '@/stores/useCartStore';
import { useSessionStore } from '@/stores/useSessionStore';
import { FoodArtView } from '@/components/common/FoodArtView';
import { formatMoney } from '@/utils/money';

export default function OrderDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();

  const currentAddress = useSessionStore((s) => s.currentAddress());
  const getProductById = useCatalogStore((s) => s.getProductById);
  const addItem = useCartStore((s) => s.addItem);

  const orderItems = [
    { product: getProductById('p_ramen'), quantity: 1 },
    { product: getProductById('p_dumplings'), quantity: 1 },
  ].filter((item) => Boolean(item.product)) as {
    product: NonNullable<ReturnType<typeof getProductById>>;
    quantity: number;
  }[];

  const subtotal = orderItems.reduce(
    (acc, it) => acc + it.product.priceCents * it.quantity,
    0
  );

  const handleReorder = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    orderItems.forEach((it) => {
      for (let i = 0; i < it.quantity; i++) {
        addItem(it.product);
      }
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
            <View className="flex-row items-center">
              <Text className="text-lg font-black text-white mr-2">
                {id || 'BF-48213'}
              </Text>
              <View className="flex-row items-center bg-white/25 px-2 py-0.5 rounded-full">
                <Bicycle size={12} weight="bold" color="#FFFFFF" />
                <Text className="text-[11px] font-bold text-white ml-1">
                  On the way
                </Text>
              </View>
            </View>
            <Text className="text-xs font-bold text-white/90 mt-1">
              Arriving in 7 min
            </Text>
          </View>

          <View className="w-10" />
        </View>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16, paddingBottom: 60 }}
      >
        {/* Rider On The Way Card with Moving Tracker */}
        <View className="bg-card-light dark:bg-card-dark rounded-3xl p-5 border border-line-light dark:border-line-dark shadow-2xs mb-4">
          <Text className="text-base font-black text-ink dark:text-ink-darkDefault mb-4">
            Your rider is on the way
          </Text>

          {/* Track progress graphic */}
          <View className="py-2">
            {/* Scooter image moving over line */}
            <View className="flex-row items-center justify-between mb-1">
              <View className="w-9 h-9 rounded-full bg-brand-wash dark:bg-brand-washDark items-center justify-center">
                <CookingPot size={18} weight="fill" color="#FF5A36" />
              </View>

              <View className="items-center justify-center px-4">
                <Image
                  source={require('@/assets/brand/rider_onboarding.png')}
                  style={{ width: 68, height: 50 }}
                  resizeMode="contain"
                />
              </View>

              <View className="w-9 h-9 rounded-full bg-brand-primary items-center justify-center shadow-xs">
                <House size={18} weight="fill" color="#FFFFFF" />
              </View>
            </View>

            {/* Progress line track */}
            <View className="h-2 w-full bg-line-light dark:bg-line-dark rounded-full overflow-hidden mt-2">
              <View className="h-full bg-brand-primary rounded-full w-[68%]" />
            </View>
          </View>
        </View>

        {/* Milestone Timeline Tracker */}
        <View className="bg-card-light dark:bg-card-dark rounded-3xl p-5 border border-line-light dark:border-line-dark shadow-2xs mb-4">
          <Text className="text-xs font-black uppercase tracking-wider text-ink-muted mb-4">
            Delivery Milestones
          </Text>

          <View className="space-y-4">
            {/* Step 1: Order placed */}
            <View className="flex-row items-center justify-between">
              <View className="flex-row items-center flex-1 mr-2">
                <View className="w-6 h-6 rounded-full bg-brand-mint items-center justify-center mr-3">
                  <CheckCircle size={14} weight="bold" color="#FFFFFF" />
                </View>
                <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                  Order placed
                </Text>
              </View>
              <Text className="text-xs text-ink-muted">8:08 PM</Text>
            </View>

            {/* Step 2: Being prepared */}
            <View className="flex-row items-center justify-between">
              <View className="flex-row items-center flex-1 mr-2">
                <View className="w-6 h-6 rounded-full bg-brand-mint items-center justify-center mr-3">
                  <CheckCircle size={14} weight="bold" color="#FFFFFF" />
                </View>
                <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                  Being prepared
                </Text>
              </View>
              <Text className="text-xs text-ink-muted">8:09 PM</Text>
            </View>

            {/* Step 3: Picked up by your rider (Active) */}
            <View className="flex-row items-center justify-between">
              <View className="flex-row items-center flex-1 mr-2">
                <View className="w-6 h-6 rounded-full bg-brand-primary items-center justify-center mr-3 shadow-xs">
                  <Bicycle size={13} weight="bold" color="#FFFFFF" />
                </View>
                <Text className="text-sm font-black text-brand-primary">
                  Picked up by your rider
                </Text>
              </View>
              <Text className="text-xs font-bold text-brand-primary">
                8:14 PM
              </Text>
            </View>

            {/* Step 4: Delivered (Pending) */}
            <View className="flex-row items-center justify-between opacity-50">
              <View className="flex-row items-center flex-1 mr-2">
                <View className="w-6 h-6 rounded-full border-2 border-line-light dark:border-line-dark items-center justify-center mr-3" />
                <Text className="text-sm font-medium text-ink-muted">
                  Delivered
                </Text>
              </View>
              <Text className="text-xs text-ink-muted">About 8:28 PM</Text>
            </View>
          </View>
        </View>

        {/* Deliver to Home Card */}
        <View className="bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-line-light dark:border-line-dark shadow-2xs mb-4 flex-row items-center">
          <View className="w-9 h-9 rounded-full bg-brand-wash dark:bg-brand-washDark items-center justify-center mr-3">
            <MapPin size={18} weight="fill" color="#FF5A36" />
          </View>
          <View className="flex-1">
            <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
              Deliver to {currentAddress.label}
            </Text>
            <Text numberOfLines={1} className="text-xs text-ink-muted mt-0.5">
              {currentAddress.line}
            </Text>
          </View>
        </View>

        {/* Your Order Summary */}
        <View className="bg-card-light dark:bg-card-dark rounded-3xl p-5 border border-line-light dark:border-line-dark shadow-2xs mb-6">
          <Text className="text-sm font-black text-ink dark:text-ink-darkDefault mb-3">
            Your order
          </Text>

          {orderItems.map(({ product, quantity }) => (
            <View
              key={product.id}
              className="flex-row items-center justify-between py-2 border-b border-line-light dark:border-line-dark"
            >
              <View className="flex-row items-center flex-1 mr-2">
                <FoodArtView art={product.art} size={36} />
                <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault ml-2.5">
                  {quantity}x {product.name}
                </Text>
              </View>
              <Text className="text-sm font-black text-ink dark:text-ink-darkDefault">
                {formatMoney(product.priceCents * quantity)}
              </Text>
            </View>
          ))}
        </View>

        {/* Reorder Pill Button */}
        <TouchableOpacity
          activeOpacity={0.88}
          onPress={handleReorder}
          className="w-full h-14 rounded-full bg-brand-primary items-center justify-center shadow-md flex-row"
        >
          <ArrowsClockwise size={18} weight="bold" color="#FFFFFF" />
          <Text className="text-base font-extrabold text-white ml-2 tracking-wide">
            Reorder · {formatMoney(subtotal)}
          </Text>
        </TouchableOpacity>
      </ScrollView>
    </View>
  );
}
