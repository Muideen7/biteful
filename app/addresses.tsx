import React, { useState } from 'react';
import { View, Text, ScrollView, TouchableOpacity, TextInput } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { ArrowLeft, MapPin, Check, Plus } from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useSessionStore } from '@/stores/useSessionStore';

export default function AddressesScreen() {
  const router = useRouter();
  const { addresses, selectedAddressId, setSelectedAddress } = useSessionStore();
  const [isAdding, setIsAdding] = useState(false);
  const [newLabel, setNewLabel] = useState('');
  const [newLine, setNewLine] = useState('');

  const handleSelect = (id: string) => {
    Haptics.selectionAsync();
    setSelectedAddress(id);
    router.back();
  };

  return (
    <SafeAreaView
      edges={['top']}
      className="flex-1 bg-paper-light dark:bg-paper-dark"
    >
      <View className="px-4 py-3 flex-row items-center justify-between border-b border-line-light dark:border-line-dark">
        <TouchableOpacity
          activeOpacity={0.7}
          onPress={() => router.back()}
          className="w-10 h-10 rounded-full bg-card-light dark:bg-card-dark border border-line-light dark:border-line-dark items-center justify-center"
        >
          <ArrowLeft size={20} weight="bold" color="#181512" />
        </TouchableOpacity>

        <Text className="text-lg font-bold text-ink dark:text-ink-darkDefault">
          Delivery Address
        </Text>

        <View className="w-10" />
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16 }}
      >
        <Text className="text-sm font-bold uppercase tracking-wider text-ink-muted mb-3">
          Select Saved Location
        </Text>

        <View className="bg-card-light dark:bg-card-dark rounded-2xl border border-line-light dark:border-line-dark overflow-hidden mb-6">
          {addresses.map((addr, idx) => {
            const isSelected = selectedAddressId === addr.id;
            return (
              <TouchableOpacity
                key={addr.id}
                activeOpacity={0.7}
                onPress={() => handleSelect(addr.id)}
                className={`p-4 flex-row items-center justify-between ${
                  idx !== addresses.length - 1
                    ? 'border-b border-line-light dark:border-line-dark'
                    : ''
                }`}
              >
                <View className="flex-row items-center flex-1 pr-3">
                  <View
                    className={`w-9 h-9 rounded-full items-center justify-center mr-3 ${
                      isSelected
                        ? 'bg-brand-primary'
                        : 'bg-brand-wash dark:bg-brand-washDark'
                    }`}
                  >
                    <MapPin
                      size={18}
                      weight="fill"
                      color={isSelected ? '#FFFFFF' : '#FF5A36'}
                    />
                  </View>
                  <View className="flex-1">
                    <Text className="text-base font-bold text-ink dark:text-ink-darkDefault">
                      {addr.label}
                    </Text>
                    <Text
                      numberOfLines={1}
                      className="text-xs text-ink-muted mt-0.5"
                    >
                      {addr.line}
                    </Text>
                  </View>
                </View>

                {isSelected && (
                  <View className="w-6 h-6 rounded-full bg-brand-primary items-center justify-center">
                    <Check size={14} weight="bold" color="#FFFFFF" />
                  </View>
                )}
              </TouchableOpacity>
            );
          })}
        </View>

        {/* Add Address Form Toggle */}
        {!isAdding ? (
          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => setIsAdding(true)}
            className="flex-row items-center justify-center bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-dashed border-brand-primary"
          >
            <Plus size={18} weight="bold" color="#FF5A36" />
            <Text className="text-sm font-bold text-brand-primary ml-2">
              Add New Address
            </Text>
          </TouchableOpacity>
        ) : (
          <View className="bg-card-light dark:bg-card-dark rounded-2xl p-4 border border-line-light dark:border-line-dark">
            <Text className="text-base font-bold text-ink dark:text-ink-darkDefault mb-3">
              New Address Details
            </Text>
            <TextInput
              placeholder="Label (e.g. Vacation Home, Studio)"
              placeholderTextColor="#8A8179"
              value={newLabel}
              onChangeText={setNewLabel}
              className="bg-paper-light dark:bg-paper-dark px-3.5 py-2.5 rounded-xl text-ink dark:text-ink-darkDefault mb-3 font-medium border border-line-light dark:border-line-dark"
            />
            <TextInput
              placeholder="Street, City, Postal Code"
              placeholderTextColor="#8A8179"
              value={newLine}
              onChangeText={setNewLine}
              className="bg-paper-light dark:bg-paper-dark px-3.5 py-2.5 rounded-xl text-ink dark:text-ink-darkDefault mb-4 font-medium border border-line-light dark:border-line-dark"
            />
            <View className="flex-row justify-end space-x-2">
              <TouchableOpacity
                onPress={() => setIsAdding(false)}
                className="px-4 py-2 rounded-xl bg-paper-light dark:bg-paper-dark mr-2"
              >
                <Text className="text-sm font-semibold text-ink-muted">
                  Cancel
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                onPress={() => {
                  if (newLabel && newLine) {
                    Haptics.notificationAsync(
                      Haptics.NotificationFeedbackType.Success
                    );
                    setIsAdding(false);
                    setNewLabel('');
                    setNewLine('');
                  }
                }}
                className="px-5 py-2 rounded-xl bg-brand-primary"
              >
                <Text className="text-sm font-bold text-white">Save</Text>
              </TouchableOpacity>
            </View>
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}
