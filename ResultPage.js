
// ResultPage.js — 结果显示界面
import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { TRANSLATIONS } from './translations';
import BackgroundLayer from './BackgroundLayer';

const ResultPage = ({ score, percent, setStep, language }) => {
  const t = key => TRANSLATIONS[key]?.[language] || TRANSLATIONS[key]?.en;
  const passed = percent >= 80;

  return (
    <View style={{ flex: 1 }}>
      <BackgroundLayer />
      <View style={styles.container}>
        <Text style={styles.result}>{t('resultTitle')}</Text>
        <Text style={styles.score}>{t('yourScore')}: {score}/20</Text>
        <Text style={[styles.percent, { color: passed ? 'green' : 'red' }]}> 
          {percent}% - {passed ? t('pass') : t('fail')}
        </Text>

        <TouchableOpacity style={styles.button} onPress={() => setStep('menu')}>
          <Text style={styles.buttonText}>🔁 {t('tryAgain')}</Text>
        </TouchableOpacity>

        <TouchableOpacity style={[styles.button, { marginTop: 12 }]} onPress={() => setStep('home')}>
          <Text style={styles.buttonText}>⏏ {t('exit')}</Text>
        </TouchableOpacity>

        <Text style={styles.copyright}>
          {language === 'zh-Hant' || language === 'zh'
            ? '⚠️ 本 App 為 J&S/PDA 教學用途，嚴禁未經授權轉傳 ⚠️'
            : language === 'es'
            ? '⚠️ Esta App es solo para uso educativo de J&S/PDA. Prohibida su distribución ⚠️'
            : language === 'ru'
            ? '⚠️ Это приложение только для обучения от J&S/PDA. Распространение запрещено ⚠️'
            : '⚠️ This App is for educational use only by J&S/PDA. Unauthorized distribution is strictly prohibited ⚠️'}
        </Text>
      </View>
    </View>
  );
};

export default ResultPage;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20
  },
  result: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 10,
    color: '#000'
  },
  score: {
    fontSize: 22,
    marginBottom: 5,
    color: '#000'
  },
  percent: {
    fontSize: 20,
    marginBottom: 30
  },
  button: {
    backgroundColor: '#007AFF',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 10
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold'
  },
  copyright: {
    marginTop: 40,
    fontSize: 12,
    color: '#666',
    textAlign: 'center'
  }
});