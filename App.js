// 🚍 完整、修正后最终版 App.js 🚚
import React, { useState, useEffect } from 'react';
import {
  View, Text, TextInput, TouchableOpacity, Image, StyleSheet, Alert, ScrollView, LogBox
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { signInWithPhoneNumber } from 'firebase/auth';
import { auth } from './firebaseConfig';
import TRANSLATIONS from './translations';

import Menu from './Menu';
import QuizPage from './QuizPage';
import ResultPage from './ResultPage';

LogBox.ignoreLogs(['AsyncStorage has been extracted from react-native core']);

const PREFIX_OPTIONS = ['A-', 'BP-', 'BPS-'];

export default function App() {
  const [language, setLanguage] = useState('en');
  const [selectedPrefix, setSelectedPrefix] = useState('A-');
  const [phone, setPhone] = useState('');
  const [code, setCode] = useState('');
  const [confirmation, setConfirmation] = useState(null);
  const [screen, setScreen] = useState('home');
  const [subject, setSubject] = useState('');
  const [score, setScore] = useState(null);
  const [percent, setPercent] = useState(null);

  const t = key => TRANSLATIONS[key]?.[language] || TRANSLATIONS[key]?.en;

  useEffect(() => {
    const resetTimer = setTimeout(() => setScreen('home'), 20 * 60 * 1000);
    return () => clearTimeout(resetTimer);
  }, [screen]);

  const sendCode = async () => {
    const sanitizedPhone = phone.replace(/\D/g, '');
    if (sanitizedPhone.length !== 10) {
      Alert.alert(t('error'), t('invalidPhoneNumber'));
      return;
    }
    const fullPhone = '+1' + sanitizedPhone;

    try {
      const confirmationResult = await signInWithPhoneNumber(auth, fullPhone);
      setConfirmation(confirmationResult);
      Alert.alert(t('sendCode'), t('codeSentSuccess'));
    } catch (e) {
      console.log("Error in sendCode:", e);
      Alert.alert(t('error'), e.message || t('firebaseError'));
    }
  };

  const confirmCode = async () => {
    try {
      await confirmation.confirm(code);
      setScreen('menu');
    } catch (e) {
      console.log("Error in confirmCode:", e);
      Alert.alert(t('error'), e.message || t('firebaseError'));
    }
  };

  return (
    <SafeAreaView style={styles.safearea}>
      <View style={styles.container}>

        {screen === 'home' && (
        <ScrollView contentContainerStyle={styles.content}>
            <Text style={styles.title}>🚍 NY CDL Training 🚚</Text>
            <Text style={styles.subtitle}>{t('homeWelcome')}</Text>

            <View style={styles.prefixContainer}>
              {PREFIX_OPTIONS.map(opt => (
                <TouchableOpacity key={opt} onPress={() => setSelectedPrefix(opt)}>
                  <Text style={[styles.prefix, selectedPrefix === opt && styles.selected]}>
                    {opt}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>

            <TextInput
              placeholder={t('enterPhone')}
              value={phone}
              onChangeText={setPhone}
              style={styles.input}
              keyboardType="phone-pad"
            />

            {!confirmation && (
              <TouchableOpacity onPress={sendCode} style={styles.button}>
                <Text style={styles.buttonText}>{t('sendCode')}</Text>
              </TouchableOpacity>
            )}

            {confirmation && (
              <>
                <TextInput
                  placeholder={t('enterCode')}
                  value={code}
                  onChangeText={setCode}
                  style={styles.input}
                  keyboardType="number-pad"
                />
                <TouchableOpacity onPress={confirmCode} style={styles.button}>
                  <Text style={styles.buttonText}>{t('confirm')}</Text>
                </TouchableOpacity>
              </>
            )}

            <TouchableOpacity
              onPress={() => setLanguage(l => l === 'en' ? 'zh' : l === 'zh' ? 'es' : l === 'es' ? 'ru' : 'en')}
              style={styles.languageSwitcher}
            >
              <Image source={require('./assets/lang.png')} style={styles.langIcon} />
            </TouchableOpacity>

            <Text style={styles.contact}>📞 718-205-6789 / 718-899-1166</Text>
            <Text style={styles.contact}>🌐 www.jsdrivingschool.com</Text>
            <Image source={require('./assets/qrcode.png')} style={styles.qrCode} />
          </ScrollView>
        )}

        {screen === 'menu' && (
          <Menu prefix={selectedPrefix} language={language} setStep={setScreen} setSubject={setSubject} />
        )}

        {screen === 'quiz' && (
          <QuizPage prefix={selectedPrefix} language={language} setStep={setScreen} setScore={setScore} setPercent={setPercent} />
        )}

        {screen === 'result' && (
          <ResultPage score={score} percent={percent} setStep={setScreen} language={language} />
        )}

      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safearea: { flex: 1, backgroundColor: '#fff' },
  container: { flex: 1, alignItems: 'center' },
  content: { flexGrow: 1, alignItems: 'center', paddingVertical: 40 },
  title: { fontSize: 28, fontWeight: 'bold', marginBottom: 10 },
  subtitle: { fontSize: 16, marginBottom: 20, textAlign: 'center' },
  prefixContainer: { flexDirection: 'row', marginVertical: 10 },
  prefix: { fontSize: 18, marginHorizontal: 8, color: 'gray' },
  selected: { color: 'blue', fontWeight: 'bold' },
  input: { padding: 12, width: '80%', backgroundColor: '#f3f3f3', marginVertical: 10, borderRadius: 10 },
  button: { padding: 15, backgroundColor: '#2196f3', alignItems: 'center', width: '80%', borderRadius: 10, marginBottom: 6 },
  buttonText: { color: '#fff', fontSize: 16, fontWeight: 'bold' },
  languageSwitcher: { margin: 10 },
  langIcon: { width: 32, height: 32, marginTop: 10 },
  contact: { marginTop: 5, fontSize: 16, color: '#333', textAlign: 'center' },
  qrCode: { width: 80, height: 80, marginTop: 15 },
});