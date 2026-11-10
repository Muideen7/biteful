import React from 'react';
import { View, Image } from 'react-native';
import { FoodArt } from '@/types/catalog';
import { getFoodImage } from '@/utils/foodArt';

interface FoodArtViewProps {
  art: FoodArt;
  size?: number;
}

export function FoodArtView({ art, size = 64 }: FoodArtViewProps) {
  const sideSize = Math.round(size * 0.44);

  return (
    <View
      style={{ width: size, height: size }}
      className="relative items-center justify-center"
    >
      <Image
        source={getFoodImage(art.main)}
        style={{ width: size, height: size }}
        resizeMode="contain"
      />
      {art.side && (
        <View
          style={{
            position: 'absolute',
            bottom: -2,
            right: -2,
            width: sideSize,
            height: sideSize,
          }}
        >
          <Image
            source={getFoodImage(art.side)}
            style={{ width: sideSize, height: sideSize }}
            resizeMode="contain"
          />
        </View>
      )}
    </View>
  );
}
