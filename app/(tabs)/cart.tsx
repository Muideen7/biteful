import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { useRouter } from 'expo-router';
import {
  ShoppingBagOpen,
  Tag,
  Trash,
  Plus,
  Minus,
  Sparkle,
  CaretRight,
} from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useCartStore } from '@/stores/useCartStore';
import { FoodArtView } from '@/components/common/FoodArtView';
import { formatMoney } from '@/utils/money';

export default function CartScreen() {
  const router = useRouter();
  const {
    lines,
    updateQuantity,
    appliedDeal,
    clearCart,
    subtotalCents,
    discountCents,
    deliveryFeeCents,
    totalCents,
  } = useCartStore();

  const subtotal = subtotalCents();
  const discount = discountCents();
  const fee = deliveryFeeCents();
  const total = totalCents();
  const itemCount = lines.reduce((acc, l) => acc + l.quantity, 0);

  const handleCheckout = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    clearCart();
    Alert.alert(
      'Order Placed! 🎉',
      'Your hot meal is being prepared and will be delivered shortly.',
      [
        {
          text: 'Track Order',
          onPress: () => router.push('/orders'),
        },
      ]
    );
  };

  const handleDecrease = (productId: string, currentQty: number) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    updateQuantity(productId, currentQty - 1);
  };

  const handleIncrease = (productId: string, currentQty: number) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    updateQuantity(productId, currentQty + 1);
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
        <Text className="text-2xl font-black text-white">Cart</Text>
        <Text className="text-xs font-bold text-white/85 mt-0.5">
          {itemCount} {itemCount === 1 ? 'item' : 'items'}
        </Text>
      </View>

      {lines.length === 0 ? (
        <View className="flex-1 items-center justify-center p-8">
          <View className="w-20 h-20 rounded-full bg-brand-wash dark:bg-brand-washDark items-center justify-center mb-4">
            <ShoppingBagOpen size={40} weight="duotone" color="#FF5A36" />
          </View>
          <Text className="text-xl font-black text-ink dark:text-ink-darkDefault mb-1 text-center">
            Your cart is hungry
          </Text>
          <Text className="text-sm text-ink-muted text-center mb-6">
            Explore delicious meals and savory dishes to add them here.
          </Text>
          <TouchableOpacity
            activeOpacity={0.88}
            onPress={() => router.push('/(tabs)/')}
            className="px-6 py-3 rounded-full bg-brand-primary shadow-xs"
          >
            <Text className="text-sm font-bold text-white">Browse Menu</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <ScrollView
          showsVerticalScrollIndicator={false}
          contentContainerStyle={{ padding: 16, paddingBottom: 100 }}
        >
          {/* Cart Item Cards */}
          <View className="space-y-3 mb-4">
            {lines.map((line) => (
              <View
                key={line.product.id}
                className="bg-card-light dark:bg-card-dark rounded-2xl p-3.5 border border-line-light dark:border-line-dark shadow-2xs flex-row items-center justify-between"
              >
                {/* Product Art & Info */}
                <View className="flex-row items-center flex-1 mr-3">
                  <View className="w-14 h-14 rounded-xl bg-brand-wash dark:bg-brand-washDark items-center justify-center mr-3">
                    <FoodArtView art={line.product.art} size={42} />
                  </View>
                  <View className="flex-1">
                    <Text
                      numberOfLines={1}
                      className="text-sm font-bold text-ink dark:text-ink-darkDefault"
                    >
                      {line.product.name}
                    </Text>
                    <Text className="text-xs font-black text-brand-primary mt-0.5">
                      {formatMoney(line.product.priceCents * line.quantity)}
                    </Text>
                  </View>
                </View>

                {/* Stepper with Trash for Qty 1 */}
                <View className="flex-row items-center bg-[#F2EDE8] dark:bg-[#231F1C] rounded-full px-2.5 py-1 border border-line-light dark:border-line-dark">
                  <TouchableOpacity
                    onPress={() =>
                      handleDecrease(line.product.id, line.quantity)
                    }
                    className="w-7 h-7 rounded-full items-center justify-center"
                  >
                    {line.quantity === 1 ? (
                      <Trash size={14} color="#FF5A36" />
                    ) : (
                      <Minus size={14} weight="bold" color="#181512" />
                    )}
                  </TouchableOpacity>

                  <Text className="text-sm font-black text-ink dark:text-ink-darkDefault mx-2.5 min-w-[14px] text-center">
                    {line.quantity}
                  </Text>

                  <TouchableOpacity
                    onPress={() =>
                      handleIncrease(line.product.id, line.quantity)
                    }
                    className="w-7 h-7 rounded-full bg-brand-primary items-center justify-center"
                  >
                    <Plus size={14} weight="bold" color="#FFFFFF" />
                  </TouchableOpacity>
                </View>
              </View>
            ))}
          </View>

          {/* Coupon / Deal Card */}
          <TouchableOpacity
            activeOpacity={0.85}
            onPress={() => router.push('/(tabs)/offers')}
            className="bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-line-light dark:border-line-dark shadow-2xs flex-row items-center justify-between mb-4"
          >
            <View className="flex-row items-center flex-1 mr-2">
              <View className="w-8 h-8 rounded-full bg-brand-wash dark:bg-brand-washDark items-center justify-center mr-3">
                <Tag size={16} weight="fill" color="#FF5A36" />
              </View>
              <View className="flex-1">
                <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                  {appliedDeal
                    ? `${appliedDeal.code} applied`
                    : 'Apply Discount Voucher'}
                </Text>
                <Text className="text-xs text-ink-muted mt-0.5">
                  {appliedDeal
                    ? appliedDeal.terms
                    : 'Select a voucher to save on your order'}
                </Text>
              </View>
            </View>
            <CaretRight size={16} color="#8A8179" />
          </TouchableOpacity>

          {/* Bill Summary Breakdown */}
          <View className="bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-line-light dark:border-line-dark shadow-2xs mb-6 space-y-2">
            <View className="flex-row justify-between">
              <Text className="text-sm text-ink-muted">Subtotal</Text>
              <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                {formatMoney(subtotal)}
              </Text>
            </View>

            <View className="flex-row justify-between">
              <Text className="text-sm text-ink-muted">Delivery fee</Text>
              <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                {fee === 0 ? 'FREE' : formatMoney(fee)}
              </Text>
            </View>

            {discount > 0 && (
              <View className="flex-row justify-between">
                <Text className="text-sm font-bold text-brand-primary">
                  Discount ({appliedDeal?.code})
                </Text>
                <Text className="text-sm font-bold text-brand-primary">
                  -{formatMoney(discount)}
                </Text>
              </View>
            )}

            <View className="h-px bg-line-light dark:bg-line-dark my-1" />

            <View className="flex-row justify-between pt-1">
              <Text className="text-base font-black text-ink dark:text-ink-darkDefault">
                Total
              </Text>
              <Text className="text-base font-black text-ink dark:text-ink-darkDefault">
                {formatMoney(total)}
              </Text>
            </View>
          </View>

          {/* Floating Checkout Pill Button */}
          <TouchableOpacity
            activeOpacity={0.88}
            onPress={handleCheckout}
            className="w-full h-14 rounded-full bg-brand-primary items-center justify-center shadow-md"
          >
            <Text className="text-base font-extrabold text-white tracking-wide">
              Checkout · {formatMoney(total)}
            </Text>
          </TouchableOpacity>
        </ScrollView>
      )}
    </View>
  );
}
