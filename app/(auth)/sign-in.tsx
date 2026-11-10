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
  Modal,
  Image,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import {
  EnvelopeSimple,
  Lock,
  Eye,
  EyeSlash,
  Check,
  X,
  AppleLogo,
} from 'phosphor-react-native';
import Svg, { Path } from 'react-native-svg';
import * as Haptics from 'expo-haptics';
import { useSessionStore } from '@/stores/useSessionStore';

function GoogleIcon({ size = 20 }: { size?: number }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24">
      <Path
        fill="#4285F4"
        d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v4.51h6.6c-.29 1.52-1.14 2.8-2.4 3.66v3.05h3.87c2.26-2.09 3.675-5.17 3.675-9.15z"
      />
      <Path
        fill="#34A853"
        d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.87-3.05c-1.08.72-2.45 1.16-4.06 1.16-3.13 0-5.78-2.11-6.73-4.96H1.25v3.15C3.25 21.37 7.31 24 12 24z"
      />
      <Path
        fill="#FBBC05"
        d="M5.27 14.24c-.25-.72-.38-1.49-.38-2.24s.13-1.52.38-2.24V6.61H1.25C.45 8.22 0 10.05 0 12s.45 3.78 1.25 5.39l4.02-3.15z"
      />
      <Path
        fill="#EA4335"
        d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.31 0 3.25 2.63 1.25 6.61l4.02 3.15c.95-2.85 3.6-4.96 6.73-4.96z"
      />
    </Svg>
  );
}

export default function SignInScreen() {
  const router = useRouter();
  const setProfile = useSessionStore((s) => s.setProfile);

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [keepSignedIn, setKeepSignedIn] = useState(true);
  const [showForgotModal, setShowForgotModal] = useState(false);
  const [forgotEmail, setForgotEmail] = useState('');

  const handleSignIn = () => {
    if (!email || !password) {
      Alert.alert('Missing Fields', 'Please fill in your email or phone and password.');
      return;
    }
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    if (email.trim()) {
      setProfile({
        name: 'FrontendGeek',
        email: email.trim(),
      });
    }
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

  const handleSendResetLink = () => {
    if (!forgotEmail) {
      Alert.alert('Email Required', 'Please enter your registered email address.');
      return;
    }
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    setShowForgotModal(false);
    Alert.alert(
      'Reset Link Dispatched',
      `A password reset link has been dispatched to ${forgotEmail}. Check your inbox!`
    );
    setForgotEmail('');
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
          {/* Welcome Back Heading */}
          <Text className="text-2xl font-black text-ink dark:text-ink-darkDefault mb-6">
            Welcome Back
          </Text>

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

          {/* Keep me signed in & Forgot Password Row */}
          <View className="flex-row items-center justify-between mb-6 px-1">
            <TouchableOpacity
              activeOpacity={0.8}
              onPress={() => setKeepSignedIn(!keepSignedIn)}
              className="flex-row items-center"
            >
              <View
                className={`w-5 h-5 rounded-md items-center justify-center mr-2 border ${
                  keepSignedIn
                    ? 'bg-brand-primary border-brand-primary'
                    : 'bg-white dark:bg-[#231F1C] border-line-light dark:border-line-dark'
                }`}
              >
                {keepSignedIn && <Check size={13} weight="bold" color="#FFFFFF" />}
              </View>
              <Text className="text-sm font-semibold text-ink-muted dark:text-ink-darkMuted">
                Keep me signed in
              </Text>
            </TouchableOpacity>

            <TouchableOpacity
              onPress={() => setShowForgotModal(true)}
              hitSlop={8}
            >
              <Text className="text-sm font-bold text-brand-primary">
                Forgot Password?
              </Text>
            </TouchableOpacity>
          </View>

          {/* Log In Pill Button */}
          <TouchableOpacity
            activeOpacity={0.88}
            onPress={handleSignIn}
            className="w-full h-14 rounded-full bg-brand-primary items-center justify-center shadow-sm mb-6"
          >
            <Text className="text-base font-extrabold text-white tracking-wide">
              Log In
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
              activeOpacity={0.85}
              onPress={handleGoogleAuth}
              className="flex-1 h-13 rounded-full bg-card-light dark:bg-card-dark border border-line-light dark:border-line-dark flex-row items-center justify-center shadow-xs"
            >
              <GoogleIcon size={20} />
              <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault ml-2">
                Google
              </Text>
            </TouchableOpacity>

            <TouchableOpacity
              activeOpacity={0.85}
              onPress={handleAppleAuth}
              className="flex-1 h-13 rounded-full bg-card-light dark:bg-card-dark border border-line-light dark:border-line-dark flex-row items-center justify-center shadow-xs"
            >
              <AppleLogo size={20} weight="fill" color="#181512" />
              <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault ml-2">
                Apple
              </Text>
            </TouchableOpacity>
          </View>

          {/* Bottom Switch Link */}
          <View className="flex-row items-center justify-center">
            <Text className="text-sm font-medium text-ink-muted dark:text-ink-darkMuted">
              Don't have an account?{' '}
            </Text>
            <TouchableOpacity onPress={() => router.push('/(auth)/sign-up')}>
              <Text className="text-sm font-bold text-brand-primary">
                Sign Up
              </Text>
            </TouchableOpacity>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>

      {/* Forgot Password Modal */}
      <Modal
        visible={showForgotModal}
        transparent
        animationType="fade"
        onRequestClose={() => setShowForgotModal(false)}
      >
        <View className="flex-1 bg-black/60 items-center justify-center p-5">
          <View className="bg-card-light dark:bg-card-dark rounded-3xl p-6 w-full max-w-sm border border-line-light dark:border-line-dark shadow-lg">
            <View className="flex-row justify-between items-center mb-3">
              <Text className="text-lg font-black text-ink dark:text-ink-darkDefault">
                Reset Password
              </Text>
              <TouchableOpacity
                onPress={() => setShowForgotModal(false)}
                className="w-8 h-8 rounded-full bg-paper-light dark:bg-paper-dark items-center justify-center"
              >
                <X size={16} color="#8A8179" />
              </TouchableOpacity>
            </View>

            <Text className="text-sm text-ink-muted mb-4">
              Enter your email address and we will dispatch password recovery instructions.
            </Text>

            <View className="w-full h-12 bg-[#F2EDE8] dark:bg-[#231F1C] rounded-full px-4 flex-row items-center border border-line-light dark:border-line-dark mb-4">
              <EnvelopeSimple size={18} color="#8A8179" />
              <TextInput
                placeholder="you@email.com"
                placeholderTextColor="#8A8179"
                value={forgotEmail}
                onChangeText={setForgotEmail}
                keyboardType="email-address"
                autoCapitalize="none"
                className="flex-1 ml-2.5 text-sm text-ink dark:text-ink-darkDefault font-medium"
              />
            </View>

            <TouchableOpacity
              onPress={handleSendResetLink}
              className="w-full h-12 rounded-full bg-brand-primary items-center justify-center shadow-xs"
            >
              <Text className="text-sm font-bold text-white">
                Send Reset Link
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </View>
  );
}
