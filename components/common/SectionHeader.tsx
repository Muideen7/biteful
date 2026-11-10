import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';

interface SectionHeaderProps {
  title: string;
  actionText?: string;
  onAction?: () => void;
}

export function SectionHeader({
  title,
  actionText = 'See all',
  onAction,
}: SectionHeaderProps) {
  return (
    <View className="flex-row items-center justify-between px-4 pt-5 pb-2.5">
      <Text className="text-xl font-bold tracking-tight text-ink dark:text-ink-darkDefault">
        {title}
      </Text>
      {onAction && (
        <TouchableOpacity activeOpacity={0.7} onPress={onAction}>
          <Text className="text-sm font-semibold text-brand-primary">
            {actionText}
          </Text>
        </TouchableOpacity>
      )}
    </View>
  );
}
