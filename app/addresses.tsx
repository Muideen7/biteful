import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  TextInput,
  Modal,
} from 'react-native';
import { useRouter } from 'expo-router';
import {
  ArrowLeft,
  Plus,
  House,
  Briefcase,
  MapPin,
  PencilSimple,
  Check,
  X,
} from 'phosphor-react-native';
import * as Haptics from 'expo-haptics';
import { useSessionStore } from '@/stores/useSessionStore';

export default function AddressesScreen() {
  const router = useRouter();
  const { addresses, selectedAddressId, setSelectedAddress, addAddress } =
    useSessionStore();

  const [showAddModal, setShowAddModal] = useState(false);
  const [newLabel, setNewLabel] = useState('');
  const [newLine, setNewLine] = useState('');

  const handleSelect = (id: string) => {
    Haptics.selectionAsync();
    setSelectedAddress(id);
    router.back();
  };

  const handleSaveNewAddress = () => {
    if (!newLabel.trim() || !newLine.trim()) return;
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    addAddress({
      label: newLabel.trim(),
      line: newLine.trim(),
    });
    setNewLabel('');
    setNewLine('');
    setShowAddModal(false);
  };

  const getAddressIcon = (label: string) => {
    const l = label.toLowerCase();
    if (l.includes('home')) return House;
    if (l.includes('work') || l.includes('office')) return Briefcase;
    return MapPin;
  };

  return (
    <View className="flex-1 bg-paper-light dark:bg-paper-dark">
      {/* Curved Tangerine Brand Header */}
      <View
        className="bg-brand-primary pt-12 pb-5 px-4 shadow-sm"
        style={{
          borderBottomLeftRadius: 32,
          borderBottomRightRadius: 32,
        }}
      >
        <View className="flex-row items-center justify-between mb-1">
          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => router.back()}
            className="w-10 h-10 rounded-full bg-white/20 border border-white/30 items-center justify-center"
          >
            <ArrowLeft size={20} weight="bold" color="#FFFFFF" />
          </TouchableOpacity>

          <Text className="text-xl font-black text-white">Addresses</Text>

          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => setShowAddModal(true)}
            className="w-10 h-10 rounded-full bg-white/20 border border-white/30 items-center justify-center"
          >
            <Plus size={20} weight="bold" color="#FFFFFF" />
          </TouchableOpacity>
        </View>

        <Text className="text-xs font-semibold text-white/85 text-center mt-1">
          Tap one to deliver there
        </Text>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ padding: 16, paddingBottom: 48 }}
      >
        <View className="space-y-3">
          {addresses.map((addr) => {
            const isSelected = selectedAddressId === addr.id;
            const Icon = getAddressIcon(addr.label);

            return (
              <TouchableOpacity
                key={addr.id}
                activeOpacity={0.85}
                onPress={() => handleSelect(addr.id)}
                className={`p-4 rounded-3xl border mb-3 flex-row items-center justify-between shadow-2xs ${
                  isSelected
                    ? 'bg-brand-wash dark:bg-brand-washDark border-brand-primary/30'
                    : 'bg-card-light dark:bg-card-dark border-line-light dark:border-line-dark'
                }`}
              >
                <View className="flex-row items-center flex-1 mr-3">
                  <View
                    className={`w-11 h-11 rounded-2xl items-center justify-center mr-3.5 ${
                      isSelected
                        ? 'bg-brand-primary shadow-xs'
                        : 'bg-paper-light dark:bg-paper-dark border border-line-light dark:border-line-dark'
                    }`}
                  >
                    <Icon
                      size={20}
                      weight={isSelected ? 'fill' : 'regular'}
                      color={isSelected ? '#FFFFFF' : '#FF5A36'}
                    />
                  </View>

                  <View className="flex-1">
                    <View className="flex-row items-center">
                      <Text className="text-sm font-black text-ink dark:text-ink-darkDefault">
                        {addr.label}
                      </Text>
                      {isSelected && (
                        <Text className="text-xs font-bold text-brand-primary ml-2">
                          Delivering here
                        </Text>
                      )}
                    </View>
                    <Text
                      numberOfLines={1}
                      className="text-xs text-ink-muted mt-0.5"
                    >
                      {addr.line}
                    </Text>
                  </View>
                </View>

                <TouchableOpacity
                  activeOpacity={0.7}
                  className="w-8 h-8 rounded-full items-center justify-center"
                >
                  <PencilSimple size={16} color="#8A8179" />
                </TouchableOpacity>
              </TouchableOpacity>
            );
          })}
        </View>
      </ScrollView>

      {/* Add Address Modal */}
      <Modal
        visible={showAddModal}
        transparent
        animationType="fade"
        onRequestClose={() => setShowAddModal(false)}
      >
        <View className="flex-1 bg-black/60 items-center justify-center p-5">
          <View className="bg-card-light dark:bg-card-dark rounded-3xl p-6 w-full max-w-sm border border-line-light dark:border-line-dark shadow-lg">
            <View className="flex-row justify-between items-center mb-4">
              <Text className="text-lg font-black text-ink dark:text-ink-darkDefault">
                Add New Address
              </Text>
              <TouchableOpacity
                onPress={() => setShowAddModal(false)}
                className="w-8 h-8 rounded-full bg-paper-light dark:bg-paper-dark items-center justify-center"
              >
                <X size={16} color="#8A8179" />
              </TouchableOpacity>
            </View>

            <View className="mb-3">
              <Text className="text-xs font-bold text-ink-muted mb-1 px-1">
                Label (e.g. Home, Office, Studio)
              </Text>
              <TextInput
                placeholder="Home"
                placeholderTextColor="#8A8179"
                value={newLabel}
                onChangeText={setNewLabel}
                className="w-full h-12 bg-[#F2EDE8] dark:bg-[#231F1C] rounded-2xl px-4 text-sm text-ink dark:text-ink-darkDefault font-medium border border-line-light dark:border-line-dark"
              />
            </View>

            <View className="mb-5">
              <Text className="text-xs font-bold text-ink-muted mb-1 px-1">
                Full Address Line
              </Text>
              <TextInput
                placeholder="12 Admiralty Way, Lekki Phase 1"
                placeholderTextColor="#8A8179"
                value={newLine}
                onChangeText={setNewLine}
                className="w-full h-12 bg-[#F2EDE8] dark:bg-[#231F1C] rounded-2xl px-4 text-sm text-ink dark:text-ink-darkDefault font-medium border border-line-light dark:border-line-dark"
              />
            </View>

            <TouchableOpacity
              activeOpacity={0.88}
              onPress={handleSaveNewAddress}
              className="w-full h-12 rounded-full bg-brand-primary items-center justify-center shadow-xs"
            >
              <Text className="text-sm font-bold text-white">Save Address</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </View>
  );
}
