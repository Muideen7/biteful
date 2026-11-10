import React from 'react';
import { View, Text } from 'react-native';

interface WordmarkProps {
  size?: 'sm' | 'md' | 'lg' | 'xl';
}

export function Wordmark({ size = 'md' }: WordmarkProps) {
  const textSizes = {
    sm: 'text-lg',
    md: 'text-2xl',
    lg: 'text-3xl',
    xl: 'text-4xl',
  };

  return (
    <View className="flex-row items-baseline">
      <Text className={`${textSizes[size]} font-bold tracking-tight text-ink dark:text-ink-darkDefault`}>
        Bite
      </Text>
      <Text className={`${textSizes[size]} font-bold tracking-tight text-brand-primary`}>
        ful
      </Text>
      <Text className={`${textSizes[size]} font-extrabold text-brand-honey`}>
        .
      </Text>
    </View>
  );
}
