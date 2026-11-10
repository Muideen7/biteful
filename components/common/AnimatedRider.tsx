import React, { useEffect } from 'react';
import { View } from 'react-native';
import Svg, {
  G,
  Path,
  Circle,
  Rect,
  Ellipse,
  Line,
  Defs,
  LinearGradient,
  Stop,
} from 'react-native-svg';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withRepeat,
  withTiming,
  withSequence,
  Easing,
} from 'react-native-reanimated';

interface AnimatedRiderProps {
  size?: number;
  speed?: number; // 0 to 1
  animated?: boolean;
}

export function AnimatedRider({
  size = 200,
  animated = true,
}: AnimatedRiderProps) {
  const rotation = useSharedValue(0);
  const bob = useSharedValue(0);
  const puff = useSharedValue(0);

  useEffect(() => {
    if (animated) {
      // Continuous wheel rotation
      rotation.value = withRepeat(
        withTiming(360, { duration: 900, easing: Easing.linear }),
        -1
      );

      // Chassis and rider bob
      bob.value = withRepeat(
        withSequence(
          withTiming(-2.5, { duration: 250, easing: Easing.inOut(Easing.quad) }),
          withTiming(0, { duration: 250, easing: Easing.inOut(Easing.quad) })
        ),
        -1,
        true
      );

      // Exhaust puff animation
      puff.value = withRepeat(
        withTiming(1, { duration: 750, easing: Easing.out(Easing.ease) }),
        -1
      );
    }
  }, [animated]);

  const animatedChassisStyle = useAnimatedStyle(() => ({
    transform: [{ translateY: bob.value }],
  }));

  const scale = size / 240;

  return (
    <View style={{ width: size, height: size * (200 / 240) }} className="items-center justify-center">
      <Animated.View style={[{ width: size, height: size * (200 / 240) }, animatedChassisStyle]}>
        <Svg width={size} height={size * (200 / 240)} viewBox="0 0 240 200">
          <Defs>
            <LinearGradient id="scooterGrad" x1="0" y1="0" x2="1" y2="1">
              <Stop offset="0%" stopColor="#FF5A36" />
              <Stop offset="100%" stopColor="#D93E1B" />
            </LinearGradient>
            <LinearGradient id="boxGrad" x1="0" y1="0" x2="1" y2="1">
              <Stop offset="0%" stopColor="#FFAA00" />
              <Stop offset="100%" stopColor="#E69500" />
            </LinearGradient>
          </Defs>

          {/* Soft Ground Shadow */}
          <Ellipse cx="126" cy="184" rx="90" ry="5" fill="#181512" fillOpacity="0.14" />

          {/* Delivery Box (Biteful Amber) */}
          <Rect x="16" y="68" width="60" height="46" rx="8" fill="url(#boxGrad)" />
          <Rect x="16" y="68" width="60" height="12" rx="8" fill="#D98200" />
          <Rect x="20" y="82" width="5" height="28" rx="2" fill="#FFFFFF" fillOpacity="0.4" />
          {/* Box Logo Word */}
          <Circle cx="46" cy="94" r="10" fill="#FFFFFF" fillOpacity="0.25" />

          {/* Rear Scooter Cowl */}
          <Path
            d="M 28 150 C 26 128 46 112 76 110 L 118 112 C 126 126 122 142 110 152 L 34 152 Z"
            fill="url(#scooterGrad)"
          />
          {/* Scooter Floorboard */}
          <Rect x="110" y="146" width="46" height="8" rx="4" fill="#3B3531" />

          {/* Front Steering Column & Apron */}
          <Path
            d="M 148 148 L 176 96 C 180 88 190 88 194 94 L 192 148 C 184 152 168 152 148 148 Z"
            fill="url(#scooterGrad)"
          />

          {/* Headlight */}
          <Circle cx="193" cy="98" r="7" fill="#FFF275" />
          <Circle cx="193" cy="98" r="4" fill="#FFFFFF" />

          {/* Handlebars */}
          <Rect x="165" y="86" width="26" height="5" rx="2.5" fill="#181512" />

          {/* Rear Wheel */}
          <Circle cx="64" cy="160" r="22" fill="#25211E" />
          <Circle cx="64" cy="160" r="13" fill="#EAE5DF" />
          <Circle cx="64" cy="160" r="4.5" fill="#25211E" />

          {/* Front Wheel */}
          <Circle cx="186" cy="160" r="22" fill="#25211E" />
          <Circle cx="186" cy="160" r="13" fill="#EAE5DF" />
          <Circle cx="186" cy="160" r="4.5" fill="#25211E" />

          {/* Rider Body & Jacket */}
          {/* Torso */}
          <Path
            d="M 88 94 C 88 78 102 70 120 74 L 138 104 C 132 124 116 128 98 126 Z"
            fill="#181512"
          />

          {/* Rider Arms leaning forward */}
          <Path
            d="M 112 88 L 168 92"
            stroke="#181512"
            strokeWidth="10"
            strokeLinecap="round"
          />

          {/* Helmet & Head */}
          <Circle cx="130" cy="52" r="18" fill="url(#scooterGrad)" />
          {/* Visor */}
          <Path
            d="M 136 46 C 146 48 148 56 144 62 L 132 62 Z"
            fill="#181512"
          />

          {/* Speed Lines Behind */}
          <Line x1="12" y1="122" x2="34" y2="122" stroke="#FF5A36" strokeWidth="2.5" strokeLinecap="round" opacity="0.6" />
          <Line x1="4" y1="138" x2="22" y2="138" stroke="#FFAA00" strokeWidth="2.5" strokeLinecap="round" opacity="0.7" />
          <Line x1="16" y1="154" x2="38" y2="154" stroke="#FF5A36" strokeWidth="2" strokeLinecap="round" opacity="0.5" />
        </Svg>
      </Animated.View>
    </View>
  );
}
