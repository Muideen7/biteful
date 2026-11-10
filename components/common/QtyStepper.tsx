import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { Minus, Plus } from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';

interface QtyStepperProps {
  quantity: number;
  onIncrement: () => void;
  onDecrement: () => void;
  size?: 'sm' | 'md';
}

export function QtyStepper({
  quantity,
  onIncrement,
  onDecrement,
  size = 'md',
}: QtyStepperProps) {
  const isSm = size === 'sm';

  const handleDec = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    onDecrement();
  };

  const handleInc = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    onIncrement();
  };

  return (
    <View className="flex-row items-center bg-brand-wash dark:bg-brand-washDark rounded-full px-2 py-1">
      <TouchableOpacity
        onPress={handleDec}
        activeOpacity={0.7}
        className={`${isSm ? 'w-6 h-6' : 'w-7 h-7'} rounded-full bg-white dark:bg-card-dark items-center justify-center shadow-xs`}
      >
        <Minus size={isSm ? 12 : 14} weight="bold" color="#FF5A36" />
      </TouchableOpacity>

      <Text
        className={`font-bold text-ink dark:text-ink-darkDefault mx-3 text-center ${
          isSm ? 'text-sm w-4' : 'text-base w-5'
        }`}
      >
        {quantity}
      </Text>

      <TouchableOpacity
        onPress={handleInc}
        activeOpacity={0.7}
        className={`${isSm ? 'w-6 h-6' : 'w-7 h-7'} rounded-full bg-brand-primary items-center justify-center shadow-xs`}
      >
        <Plus size={isSm ? 12 : 14} weight="bold" color="#FFFFFF" />
      </TouchableOpacity>
    </View>
  );
}
