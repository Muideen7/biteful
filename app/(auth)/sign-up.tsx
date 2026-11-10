import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  Alert,
  Image,
} from 'react-native';
import { useRouter } from 'expo-router';
import {
  EnvelopeSimple,
  Lock,
  User,
  Eye,
  EyeSlash,
  Check,
  AppleLogo,
} from 'phosphor-react-native';
import Svg, { Path } from 'react-native-svg';
import * as Haptics from 'expo-haptics';
import { useSessionStore } from '@/stores/useSessionStore';

function GoogleIcon({ size = 18 }: { size?: number }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24">
      <Path
        fill="#4285F4"
        d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
      />
      <Path
        fill="#34A853"
        d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
      />
      <Path
        fill="#FBBC05"
        d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
      />
      <Path
        fill="#EA4335"
        d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
      />
    </Svg>
  );
}

export default function SignUpScreen() {
  const router = useRouter();
  const setProfile = useSessionStore((s) => s.setProfile);
  const isDarkMode = useSessionStore((s) => s.isDarkMode);

  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [agreeTerms, setAgreeTerms] = useState(false);

  const handleSignUp = () => {
    if (!name.trim() || !email.trim() || !password) {
      Alert.alert('Missing Fields', 'Please fill in your name, email/phone and password.');
      return;
    }
    if (!agreeTerms) {
      Alert.alert(
        'Terms of Service',
        'Please agree to the Terms and Privacy Policy to continue.'
      );
      return;
    }
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    setProfile({
      name: name.trim(),
      email: email.trim(),
    });
    router.replace('/(tabs)/');
  };

  const handleGoogleAuth = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    setProfile({
      name: 'FrontendGeek',
      email: 'frontendgeek@gmail.com',
    });
    router.replace('/(tabs)/');
  };

  const handleAppleAuth = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    setProfile({
      name: 'FrontendGeek',
      email: 'frontendgeek@icloud.com',
    });
    router.replace('/(tabs)/');
  };

  return (
    <View className="flex-1 bg-paper-light dark:bg-paper-dark">
      {/* Curved Tangerine Brand Header */}
      <View
        className="bg-brand-primary pt-12 pb-6 px-6 relative overflow-hidden"
        style={{
          borderBottomLeftRadius: 36,
          borderBottomRightRadius: 36,
        }}
      >
        {/* Soft radial backdrop ring */}
        <View className="w-48 h-48 rounded-full bg-white/10 absolute -right-8 -bottom-10" />

        {/* Top utility row: App Tour & Skip */}
        <View className="flex-row justify-between items-center mb-4 z-10">
          <TouchableOpacity
            onPress={() => router.push('/onboarding')}
            className="px-3 py-1.5 rounded-full bg-white/20 border border-white/30"
          >
            <Text className="text-xs font-bold text-white tracking-wide">
              App Tour
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={() => router.replace('/(tabs)/')}
            className="px-3 py-1.5 rounded-full bg-white/20 border border-white/30"
          >
            <Text className="text-xs font-bold text-white/90 tracking-wide">
              Skip
            </Text>
          </TouchableOpacity>
        </View>

        {/* Header content: Wordmark + Tagline on Left, Dispatch Rider on Right */}
        <View className="flex-row items-center justify-between z-10 min-h-[110px]">
          <View className="flex-1 pr-3">
            <View className="flex-row items-baseline">
              <Text className="text-3xl font-black text-white tracking-tight">
                Biteful
              </Text>
              <Text className="text-3xl font-black text-brand-honey tracking-tight">
                .
              </Text>
            </View>
            <Text className="text-white/90 text-sm font-semibold mt-1 leading-snug">
              Hot meals,{'\n'}right at your door.
            </Text>
          </View>

          {/* Rider Illustration */}
          <View className="w-32 h-28 items-center justify-center">
            <Image
              source={require('@/assets/brand/rider_onboarding.png')}
              style={{ width: 125, height: 110 }}
              resizeMode="contain"
            />
          </View>
        </View>
      </View>

      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        className="flex-1"
      >
        <ScrollView
          showsVerticalScrollIndicator={false}
          contentContainerStyle={{
            paddingHorizontal: 24,
            paddingTop: 28,
            paddingBottom: 40,
            maxWidth: 480,
            width: '100%',
            alignSelf: 'center',
          }}
        >
          {/* Create account Heading */}
          <Text className="text-2xl font-black text-ink dark:text-ink-darkDefault mb-6">
            Create account
          </Text>

          {/* Name Input Pill */}
          <View className="w-full h-14 bg-[#F2EDE8] dark:bg-[#231F1C] rounded-full px-5 flex-row items-center border border-line-light dark:border-line-dark mb-4 shadow-2xs">
            <User size={20} weight="regular" color="#8A8179" />
            <TextInput
              placeholder="Your name"
              placeholderTextColor="#8A8179"
              value={name}
              onChangeText={setName}
              autoCapitalize="words"
              className="flex-1 ml-3 text-base text-ink dark:text-ink-darkDefault font-medium"
            />
          </View>

          {/* Email or Phone Input Pill */}
          <View className="w-full h-14 bg-[#F2EDE8] dark:bg-[#231F1C] rounded-full px-5 flex-row items-center border border-line-light dark:border-line-dark mb-4 shadow-2xs">
            <EnvelopeSimple size={20} weight="regular" color="#8A8179" />
            <TextInput
              placeholder="Email or phone"
              placeholderTextColor="#8A8179"
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoCapitalize="none"
              className="flex-1 ml-3 text-base text-ink dark:text-ink-darkDefault font-medium"
            />
          </View>

          {/* Password Input Pill */}
          <View className="w-full h-14 bg-[#F2EDE8] dark:bg-[#231F1C] rounded-full px-5 flex-row items-center border border-line-light dark:border-line-dark mb-4 shadow-2xs">
            <Lock size={20} weight="regular" color="#8A8179" />
            <TextInput
              placeholder="Password"
              placeholderTextColor="#8A8179"
              value={password}
              onChangeText={setPassword}
              secureTextEntry={!showPassword}
              className="flex-1 ml-3 text-base text-ink dark:text-ink-darkDefault font-medium"
            />
            <TouchableOpacity
              onPress={() => setShowPassword(!showPassword)}
              className="p-1.5"
            >
              {showPassword ? (
                <Eye size={20} color="#8A8179" />
              ) : (
                <EyeSlash size={20} color="#8A8179" />
              )}
            </TouchableOpacity>
          </View>

          {/* Terms Agreement Checkbox */}
          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => setAgreeTerms(!agreeTerms)}
            className="flex-row items-center mb-6 px-1"
          >
            <View
              className={`w-5 h-5 rounded-md items-center justify-center mr-2.5 border ${
                agreeTerms
                  ? 'bg-brand-primary border-brand-primary'
                  : 'bg-white dark:bg-[#231F1C] border-line-light dark:border-line-dark'
              }`}
            >
              {agreeTerms && <Check size={13} weight="bold" color="#FFFFFF" />}
            </View>
            <Text className="text-sm text-ink-muted dark:text-ink-darkMuted flex-1 leading-snug">
              I agree to the{' '}
              <Text className="text-brand-primary font-bold">Terms</Text> and{' '}
              <Text className="text-brand-primary font-bold">Privacy Policy</Text>
            </Text>
          </TouchableOpacity>

          {/* Sign Up Pill Button */}
          <TouchableOpacity
            activeOpacity={0.88}
            onPress={handleSignUp}
            className="w-full h-14 rounded-full bg-brand-primary items-center justify-center shadow-sm mb-6"
          >
            <Text className="text-base font-extrabold text-white tracking-wide">
              Sign Up
            </Text>
          </TouchableOpacity>

          {/* Divider */}
          <View className="flex-row items-center my-2">
            <View className="flex-1 h-px bg-line-light dark:bg-line-dark" />
            <Text className="mx-4 text-xs font-bold text-ink-muted uppercase tracking-wider">
              Or continue with
            </Text>
            <View className="flex-1 h-px bg-line-light dark:bg-line-dark" />
          </View>

          {/* Side-by-Side Social Buttons */}
          <View className="flex-row items-center gap-3 mt-4 mb-8">
            <TouchableOpacity
              activeOpacity={0.82}
              onPress={handleGoogleAuth}
              className="flex-1 h-14 rounded-full bg-[#F2EDE8] dark:bg-[#231F1C] border border-line-light dark:border-line-dark flex-row items-center justify-center shadow-2xs"
            >
              <View className="w-8 h-8 rounded-full bg-white items-center justify-center mr-2.5 shadow-2xs border border-black/5">
                <GoogleIcon size={18} />
              </View>
              <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                Google
              </Text>
            </TouchableOpacity>

            <TouchableOpacity
              activeOpacity={0.82}
              onPress={handleAppleAuth}
              className="flex-1 h-14 rounded-full bg-[#F2EDE8] dark:bg-[#231F1C] border border-line-light dark:border-line-dark flex-row items-center justify-center shadow-2xs"
            >
              <View className="w-8 h-8 rounded-full bg-white dark:bg-[#2E2824] items-center justify-center mr-2.5 shadow-2xs border border-black/5 dark:border-white/5">
                <AppleLogo
                  size={18}
                  weight="fill"
                  color={isDarkMode ? '#FFFFFF' : '#181512'}
                />
              </View>
              <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault">
                Apple
              </Text>
            </TouchableOpacity>
          </View>

          {/* Bottom Switch Link */}
          <View className="flex-row items-center justify-center">
            <Text className="text-sm font-medium text-ink-muted dark:text-ink-darkMuted">
              Already have an account?{' '}
            </Text>
            <TouchableOpacity onPress={() => router.replace('/(auth)/sign-in')}>
              <Text className="text-sm font-bold text-brand-primary">
                Log In
              </Text>
            </TouchableOpacity>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </View>
  );
}
