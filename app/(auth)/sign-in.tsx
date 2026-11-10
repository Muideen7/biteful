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
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import {
  ArrowRight,
  EnvelopeSimple,
  Lock,
  User,
  Eye,
  EyeSlash,
  Motorcycle,
  AppleLogo,
  Check,
  X,
} from 'phosphor-react-native';
import Svg, { Path } from 'react-native-svg';
import * as Haptics from 'expo-haptics';
import { Wordmark } from '@/components/common/Wordmark';
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
  const isDarkMode = useSessionStore((s) => s.isDarkMode);

  const [isSignUp, setIsSignUp] = useState(false);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [keepSignedIn, setKeepSignedIn] = useState(true);
  const [agreeTerms, setAgreeTerms] = useState(false);
  const [showForgotModal, setShowForgotModal] = useState(false);
  const [forgotEmail, setForgotEmail] = useState('');

  const handleEmailAuth = () => {
    if (!email || !password) {
      Alert.alert('Missing Fields', 'Please fill in your email and password.');
      return;
    }
    if (isSignUp && !agreeTerms) {
      Alert.alert(
        'Terms of Service',
        'Please agree to the Terms of Service to create an account.'
      );
      return;
    }
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    if (isSignUp && name.trim()) {
      setProfile({
        name: name.trim(),
        email: email.trim(),
      });
    } else if (email.trim()) {
      setProfile({
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
      'Reset Link Sent',
      `A password reset link has been dispatched to ${forgotEmail}. Check your inbox!`
    );
    setForgotEmail('');
  };

  return (
    <SafeAreaView
      edges={['top', 'bottom']}
      className="flex-1 bg-paper-light dark:bg-paper-dark"
    >
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        className="flex-1"
      >
        <ScrollView
          showsVerticalScrollIndicator={false}
          contentContainerStyle={{
            padding: 20,
            flexGrow: 1,
            maxWidth: 480,
            width: '100%',
            alignSelf: 'center',
          }}
        >
          {/* Top Actions: Tour & Skip */}
          <View className="flex-row justify-between items-center mb-4">
            <TouchableOpacity
              onPress={() => router.push('/onboarding')}
              className="px-3.5 py-1.5 rounded-full bg-card-light dark:bg-card-dark border border-line-light dark:border-line-dark shadow-xs"
            >
              <Text className="text-xs font-bold text-brand-primary">
                App Tour
              </Text>
            </TouchableOpacity>

            <TouchableOpacity
              onPress={() => router.replace('/(tabs)/')}
              className="px-3.5 py-1.5 rounded-full bg-card-light dark:bg-card-dark border border-line-light dark:border-line-dark shadow-xs"
            >
              <Text className="text-xs font-bold text-ink-muted">Skip</Text>
            </TouchableOpacity>
          </View>

          {/* Hero Header Card */}
          <View className="bg-brand-primary rounded-3xl p-6 mb-5 relative overflow-hidden shadow-sm items-center">
            <View className="w-16 h-16 rounded-full bg-white/20 items-center justify-center mb-3">
              <Motorcycle size={38} weight="duotone" color="#FFFFFF" />
            </View>
            <Wordmark size="lg" />
            <Text className="text-white/85 text-sm font-semibold mt-1">
              Hot meals, craved and delivered fast.
            </Text>
          </View>

          {/* Auth Card */}
          <View className="bg-card-light dark:bg-card-dark rounded-3xl p-6 border border-line-light dark:border-line-dark shadow-xs mb-6">
            {/* Mode Switch Tabs */}
            <View className="flex-row bg-paper-light dark:bg-paper-dark p-1 rounded-2xl mb-5 border border-line-light dark:border-line-dark">
              <TouchableOpacity
                activeOpacity={0.8}
                onPress={() => setIsSignUp(false)}
                className={`flex-1 py-2.5 rounded-xl items-center justify-center ${
                  !isSignUp
                    ? 'bg-card-light dark:bg-card-dark shadow-xs'
                    : 'bg-transparent'
                }`}
              >
                <Text
                  className={`text-sm font-bold ${
                    !isSignUp
                      ? 'text-brand-primary'
                      : 'text-ink-muted dark:text-ink-darkMuted'
                  }`}
                >
                  Sign In
                </Text>
              </TouchableOpacity>

              <TouchableOpacity
                activeOpacity={0.8}
                onPress={() => setIsSignUp(true)}
                className={`flex-1 py-2.5 rounded-xl items-center justify-center ${
                  isSignUp
                    ? 'bg-card-light dark:bg-card-dark shadow-xs'
                    : 'bg-transparent'
                }`}
              >
                <Text
                  className={`text-sm font-bold ${
                    isSignUp
                      ? 'text-brand-primary'
                      : 'text-ink-muted dark:text-ink-darkMuted'
                  }`}
                >
                  Sign Up
                </Text>
              </TouchableOpacity>
            </View>

            <Text className="text-2xl font-black text-ink dark:text-ink-darkDefault mb-1">
              {isSignUp ? 'Create an Account' : 'Welcome Back'}
            </Text>
            <Text className="text-sm text-ink-muted mb-5">
              {isSignUp
                ? 'Sign up to track live orders and save favorite dishes'
                : 'Enter your credentials to continue ordering'}
            </Text>

            {/* Social Auth Buttons (Gmail & Apple) */}
            <View className="mb-5">
              {/* Google Button */}
              <TouchableOpacity
                activeOpacity={0.85}
                onPress={handleGoogleAuth}
                className="w-full bg-paper-light dark:bg-paper-dark border border-line-light dark:border-line-dark py-3.5 px-4 rounded-2xl flex-row items-center justify-center mb-3 shadow-xs"
              >
                <GoogleIcon size={20} />
                <Text className="text-sm font-bold text-ink dark:text-ink-darkDefault ml-2.5">
                  Continue with Google
                </Text>
              </TouchableOpacity>

              {/* Apple Button */}
              <TouchableOpacity
                activeOpacity={0.85}
                onPress={handleAppleAuth}
                className="w-full bg-[#181512] dark:bg-white py-3.5 px-4 rounded-2xl flex-row items-center justify-center shadow-xs"
              >
                <AppleLogo
                  size={20}
                  weight="fill"
                  color={isDarkMode ? '#181512' : '#FFFFFF'}
                />
                <Text
                  className={`text-sm font-bold ml-2.5 ${
                    isDarkMode ? 'text-[#181512]' : 'text-white'
                  }`}
                >
                  Continue with Apple
                </Text>
              </TouchableOpacity>
            </View>

            {/* Or Divider */}
            <View className="flex-row items-center mb-5">
              <View className="flex-1 h-px bg-line-light dark:bg-line-dark" />
              <Text className="text-xs font-bold text-ink-muted uppercase tracking-wider px-3">
                or with email
              </Text>
              <View className="flex-1 h-px bg-line-light dark:bg-line-dark" />
            </View>

            {/* Full Name Field (Sign Up Only) */}
            {isSignUp && (
              <View className="mb-4">
                <Text className="text-xs font-bold uppercase tracking-wider text-ink-muted mb-1.5">
                  Full Name
                </Text>
                <View className="flex-row items-center bg-paper-light dark:bg-paper-dark rounded-xl px-3.5 py-3 border border-line-light dark:border-line-dark">
                  <User size={18} color="#8A8179" />
                  <TextInput
                    placeholder="Frontend Geek"
                    placeholderTextColor="#8A8179"
                    value={name}
                    onChangeText={setName}
                    className="flex-1 ml-2.5 text-base text-ink dark:text-ink-darkDefault font-medium"
                  />
                </View>
              </View>
            )}

            {/* Email Field */}
            <Text className="text-xs font-bold uppercase tracking-wider text-ink-muted mb-1.5">
              Email Address
            </Text>
            <View className="flex-row items-center bg-paper-light dark:bg-paper-dark rounded-xl px-3.5 py-3 border border-line-light dark:border-line-dark mb-4">
              <EnvelopeSimple size={18} color="#8A8179" />
              <TextInput
                placeholder="name@example.com"
                placeholderTextColor="#8A8179"
                keyboardType="email-address"
                autoCapitalize="none"
                value={email}
                onChangeText={setEmail}
                className="flex-1 ml-2.5 text-base text-ink dark:text-ink-darkDefault font-medium"
              />
            </View>

            {/* Password Field */}
            <Text className="text-xs font-bold uppercase tracking-wider text-ink-muted mb-1.5">
              Password
            </Text>
            <View className="flex-row items-center bg-paper-light dark:bg-paper-dark rounded-xl px-3.5 py-3 border border-line-light dark:border-line-dark mb-4">
              <Lock size={18} color="#8A8179" />
              <TextInput
                placeholder="••••••••"
                placeholderTextColor="#8A8179"
                secureTextEntry={!showPassword}
                value={password}
                onChangeText={setPassword}
                className="flex-1 ml-2.5 text-base text-ink dark:text-ink-darkDefault font-medium"
              />
              <TouchableOpacity
                onPress={() => setShowPassword(!showPassword)}
                hitSlop={8}
                className="p-1"
              >
                {showPassword ? (
                  <EyeSlash size={18} color="#8A8179" />
                ) : (
                  <Eye size={18} color="#8A8179" />
                )}
              </TouchableOpacity>
            </View>

            {/* Options Row */}
            {!isSignUp ? (
              <View className="flex-row items-center justify-between mb-5">
                <TouchableOpacity
                  activeOpacity={0.7}
                  onPress={() => setKeepSignedIn(!keepSignedIn)}
                  className="flex-row items-center"
                >
                  <View
                    className={`w-5 h-5 rounded-md border items-center justify-center mr-2 ${
                      keepSignedIn
                        ? 'bg-brand-primary border-brand-primary'
                        : 'border-line-light dark:border-line-dark bg-paper-light dark:bg-paper-dark'
                    }`}
                  >
                    {keepSignedIn && (
                      <Check size={12} weight="bold" color="#FFFFFF" />
                    )}
                  </View>
                  <Text className="text-xs font-semibold text-ink-muted">
                    Keep me signed in
                  </Text>
                </TouchableOpacity>

                <TouchableOpacity
                  activeOpacity={0.7}
                  onPress={() => setShowForgotModal(true)}
                >
                  <Text className="text-xs font-bold text-brand-primary">
                    Forgot Password?
                  </Text>
                </TouchableOpacity>
              </View>
            ) : (
              <TouchableOpacity
                activeOpacity={0.7}
                onPress={() => setAgreeTerms(!agreeTerms)}
                className="flex-row items-center mb-5"
              >
                <View
                  className={`w-5 h-5 rounded-md border items-center justify-center mr-2.5 ${
                    agreeTerms
                      ? 'bg-brand-primary border-brand-primary'
                      : 'border-line-light dark:border-line-dark bg-paper-light dark:bg-paper-dark'
                  }`}
                >
                  {agreeTerms && (
                    <Check size={12} weight="bold" color="#FFFFFF" />
                  )}
                </View>
                <Text className="text-xs font-medium text-ink-muted flex-1">
                  I agree to the{' '}
                  <Text className="text-brand-primary font-bold">Terms of Service</Text>{' '}
                  and Privacy Policy.
                </Text>
              </TouchableOpacity>
            )}

            {/* Submit Button */}
            <TouchableOpacity
              activeOpacity={0.88}
              onPress={handleEmailAuth}
              className="bg-brand-primary py-4 rounded-full flex-row items-center justify-center shadow-md mb-4"
            >
              <Text className="text-white font-extrabold text-base mr-2">
                {isSignUp ? 'Create Account' : 'Sign In'}
              </Text>
              <ArrowRight size={18} weight="bold" color="#FFFFFF" />
            </TouchableOpacity>

            {/* Mode Switch Toggle Footer */}
            <TouchableOpacity
              onPress={() => setIsSignUp(!isSignUp)}
              className="items-center py-2"
            >
              <Text className="text-sm font-semibold text-ink-muted">
                {isSignUp
                  ? 'Already have an account? '
                  : "Don't have an account? "}
                <Text className="text-brand-primary font-bold">
                  {isSignUp ? 'Sign In' : 'Sign Up'}
                </Text>
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
        <View className="flex-1 bg-black/50 justify-center items-center px-5">
          <View className="bg-card-light dark:bg-card-dark w-full max-w-sm rounded-3xl p-6 border border-line-light dark:border-line-dark shadow-lg">
            <View className="flex-row items-center justify-between mb-3">
              <Text className="text-xl font-black text-ink dark:text-ink-darkDefault">
                Reset Password
              </Text>
              <TouchableOpacity
                onPress={() => setShowForgotModal(false)}
                className="p-1 rounded-full bg-paper-light dark:bg-paper-dark"
              >
                <X size={18} color="#8A8179" />
              </TouchableOpacity>
            </View>

            <Text className="text-xs text-ink-muted mb-4 leading-4">
              Enter your registered email address and we will dispatch a reset link to your inbox.
            </Text>

            <View className="flex-row items-center bg-paper-light dark:bg-paper-dark rounded-xl px-3.5 py-3 border border-line-light dark:border-line-dark mb-4">
              <EnvelopeSimple size={18} color="#8A8179" />
              <TextInput
                placeholder="name@example.com"
                placeholderTextColor="#8A8179"
                keyboardType="email-address"
                autoCapitalize="none"
                value={forgotEmail}
                onChangeText={setForgotEmail}
                className="flex-1 ml-2.5 text-base text-ink dark:text-ink-darkDefault font-medium"
              />
            </View>

            <TouchableOpacity
              activeOpacity={0.88}
              onPress={handleSendResetLink}
              className="w-full bg-brand-primary py-3.5 rounded-full items-center justify-center shadow-xs"
            >
              <Text className="text-white font-bold text-sm">
                Send Reset Link
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}
