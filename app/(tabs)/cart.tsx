import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import {
  ShoppingBagOpen,
  Tag,
  X,
  ArrowRight,
  Sparkle,
} from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useCartStore } from '@/stores/useCartStore';
import { FoodArtView } from '@/components/common/FoodArtView';
import { QtyStepper } from '@/components/common/QtyStepper';
import { formatMoney } from '@/utils/money';

export default function CartScreen() {
  const router = useRouter();
  const {
    lines,
    updateQuantity,
    appliedDeal,
    applyDeal,
    clearCart,
    subtotalCents,
    discountCents,
    deliveryFeeCents,
    totalCents,
  } = useCartStore();

  const [orderPlaced, setOrderPlaced] = useState(false);

  const subtotal = subtotalCents();
  const discount = discountCents();
  const fee = deliveryFeeCents();
  const total = totalCents();

  const handleCheckout = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    setOrderPlaced(true);
    clearCart();
    Alert.alert(
      'Order Placed! 🎉',
      'Your hot meal is being prepared and will be on its way shortly.',
      [
        {
          text: 'Awesome',
          onPress: () => setOrderPlaced(false),
        },
      ]
    );
  };

  if (lines.length === 0) {
    return (
      <SafeAreaView
        edges={['top']}
        className="flex-1 bg-paper-light dark:bg-paper-dark"
      >
        <View className="px-4 py-3 border-b border-line-light dark:border-line-dark">
          <Text className="text-2xl font-bold tracking-tight text-ink dark:text-ink-darkDefault">
            Your Basket
          </Text>
        </View>

        <View className="flex-1 items-center justify-center p-6">
          <View className="w-20 h-20 rounded-full bg-brand-wash dark:bg-brand-washDark items-center justify-center mb-4">
            <ShoppingBagOpen size={38} weight="duotone" color="#FF5A36" />
          </View>
          <Text className="text-xl font-bold text-ink dark:text-ink-darkDefault">
            Your basket is empty
          </Text>
          <Text className="text-sm text-ink-muted text-center mt-2 px-8 mb-6">
            Explore our delicious best sellers and deals to fill your basket.
          </Text>

          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => router.push('/(tabs)/')}
            className="bg-brand-primary px-6 py-3.5 rounded-full flex-row items-center shadow-sm"
          >
            <Text className="text-white font-bold text-base mr-2">
              Browse Menu
            </Text>
            <ArrowRight size={18} weight="bold" color="#FFFFFF" />
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView
      edges={['top']}
      className="flex-1 bg-paper-light dark:bg-paper-dark"
    >
      <View className="px-4 py-3 border-b border-line-light dark:border-line-dark">
        <Text className="text-2xl font-bold tracking-tight text-ink dark:text-ink-darkDefault">
          Your Basket
        </Text>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16, paddingBottom: 120 }}
      >
        {/* Cart Items List */}
        <View className="bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-line-light dark:border-line-dark mb-4">
          {lines.map((line, idx) => (
            <View
              key={line.product.id}
              className={`flex-row items-center justify-between py-3 ${
                idx !== lines.length - 1
                  ? 'border-b border-line-light dark:border-line-dark'
                  : ''
              }`}
            >
              <FoodArtView art={line.product.art} size={48} />

              <View className="flex-1 ml-3 pr-2">
                <Text
                  numberOfLines={1}
                  className="text-base font-bold text-ink dark:text-ink-darkDefault"
                >
                  {line.product.name}
                </Text>
                <Text className="text-sm font-extrabold text-brand-primary mt-0.5">
                  {formatMoney(line.product.priceCents * line.quantity)}
                </Text>
              </View>

              <QtyStepper
                size="sm"
                quantity={line.quantity}
                onIncrement={() =>
                  updateQuantity(line.product.id, line.quantity + 1)
                }
                onDecrement={() =>
                  updateQuantity(line.product.id, line.quantity - 1)
                }
              />
            </View>
          ))}
        </View>

        {/* Applied Voucher / Deal Strip */}
        {appliedDeal ? (
          <View className="bg-brand-wash dark:bg-brand-washDark rounded-2xl p-3.5 mb-4 border border-brand-primary/20 flex-row items-center justify-between">
            <View className="flex-row items-center flex-1 pr-2">
              <Sparkle size={18} weight="fill" color="#FF5A36" />
              <View className="ml-2.5">
                <Text className="text-sm font-bold text-brand-deep">
                  Code: {appliedDeal.code} applied!
                </Text>
                <Text className="text-xs text-brand-deep/80">
                  {appliedDeal.headline}
                </Text>
              </View>
            </View>
            <TouchableOpacity
              onPress={() => applyDeal(null)}
              className="p-1"
            >
              <X size={16} weight="bold" color="#D93E1B" />
            </TouchableOpacity>
          </View>
        ) : (
          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => router.push('/(tabs)/offers')}
            className="bg-card-light dark:bg-card-dark rounded-2xl p-3.5 mb-4 border border-dashed border-brand-primary flex-row items-center justify-between"
          >
            <View className="flex-row items-center">
              <Tag size={18} weight="bold" color="#FF5A36" />
              <Text className="text-sm font-bold text-brand-primary ml-2">
                Apply a Promo Code
              </Text>
            </View>
            <ArrowRight size={16} weight="bold" color="#FF5A36" />
          </TouchableOpacity>
        )}

        {/* Receipt Totals Card */}
        <View className="bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-line-light dark:border-line-dark">
          <Text className="text-base font-bold text-ink dark:text-ink-darkDefault mb-3">
            Summary
          </Text>

          <View className="flex-row justify-between mb-2">
            <Text className="text-sm text-ink-muted">Subtotal</Text>
            <Text className="text-sm font-semibold text-ink dark:text-ink-darkDefault">
              {formatMoney(subtotal)}
            </Text>
          </View>

          {discount > 0 && (
            <View className="flex-row justify-between mb-2">
              <Text className="text-sm text-brand-primary font-medium">
                Discount
              </Text>
              <Text className="text-sm font-bold text-brand-primary">
                -{formatMoney(discount)}
              </Text>
            </View>
          )}

          <View className="flex-row justify-between mb-3">
            <Text className="text-sm text-ink-muted">Delivery fee</Text>
            <Text className="text-sm font-semibold text-ink dark:text-ink-darkDefault">
              {fee === 0 ? 'FREE' : formatMoney(fee)}
            </Text>
          </View>

          <View className="pt-3 border-t border-line-light dark:border-line-dark flex-row justify-between items-center">
            <Text className="text-base font-bold text-ink dark:text-ink-darkDefault">
              Total Amount
            </Text>
            <Text className="text-xl font-extrabold text-brand-primary">
              {formatMoney(total)}
            </Text>
          </View>
        </View>

        {/* Place Order CTA */}
        <TouchableOpacity
          activeOpacity={0.88}
          onPress={handleCheckout}
          className="mt-6 bg-brand-primary py-4 rounded-full flex-row items-center justify-center shadow-md"
        >
          <Text className="text-white font-extrabold text-lg mr-2">
            Place Order • {formatMoney(total)}
          </Text>
          <ArrowRight size={20} weight="bold" color="#FFFFFF" />
        </TouchableOpacity>
      </ScrollView>
    </SafeAreaView>
  );
}
