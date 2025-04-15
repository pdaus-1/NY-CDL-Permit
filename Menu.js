import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, StyleSheet } from 'react-native';
import { TRANSLATIONS } from './translations';

const Menu = ({ prefix, language, setStep, setSubject }) => {
  // 选择不同Prefix对应的考试科目
  const subjects = {
    'A-': ['core', 'airbrake', 'combination'],
    'BP-': ['core', 'airbrake', 'passenger'],
    'BPS-': ['core', 'airbrake', 'passenger', 'schoolbus']
  }[prefix] || [];

  // 翻译辅助函数
  const t = key => TRANSLATIONS[key]?.[language] || TRANSLATIONS[key]?.en;

  // 更好地命名显示考试科目
  const subjectTitle = (subjectKey) => t(subjectKey);

  return (
    <ScrollView 
      contentContainerStyle={styles.container}
      showsVerticalScrollIndicator={false}
    >
      <Text style={styles.title}>{t('selectSubject')}</Text>

      {subjects.map(subject => (
        <TouchableOpacity
          key={subject}
          onPress={() => {
            setSubject(subject);
            setStep('quiz');
          }}
          style={styles.button}
        >
          <Text style={styles.buttonText}>
            {subjectTitle(subject)}
          </Text>
        </TouchableOpacity>
      ))}

      <TouchableOpacity onPress={() => setStep('home')} style={styles.exitButton}>
        <Text style={styles.exitButtonText}>⏏️ {t('exit')}</Text>
      </TouchableOpacity>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 40,
    backgroundColor: '#fff',
  },
  title: {
    fontSize: 24,
    marginBottom: 25,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center'
  },
  button: {
    backgroundColor: '#007AFF',
    paddingVertical: 14,
    paddingHorizontal: 30,
    borderRadius: 10,
    marginVertical: 10,
    alignItems: 'center',
    width: '80%',
    elevation: 2,
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '600'
  },
  exitButton: {
    marginTop: 40,
    paddingVertical: 8,
    paddingHorizontal: 20,
    borderRadius: 8,
    alignItems: 'center',
  },
  exitButtonText: {
    color: '#888',
    fontSize: 16,
  }
});

export default Menu;