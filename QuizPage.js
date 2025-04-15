// ✅ 最终优化版 — QuizPage.js

import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ScrollView, Alert } from 'react-native';
import { collection, getDocs } from 'firebase/firestore';
import { db } from './firebaseConfig';
import { TRANSLATIONS } from './translations';

const parseQuestionText = (rawText) => {
  const output = {
    question: '',
    options: {},
    answer: '',
    explanation: '',
    reference: ''
  };

  const cleaned = rawText.replace(/^\d+\.\s*/, '');
  const [mainPart, explanationPart] = cleaned.split(/\s*🔍\s*Explanation[:：]?/);
  const [explanationText, refText] = explanationPart?.split(/\s*📘\s*Ref[:：]?/) || ['', ''];
  output.explanation = explanationText.trim();
  output.reference = refText.trim();

  const match = mainPart.match(/^(.*?)\s*A[.:]\s*(.*?)\s*B[.:]\s*(.*?)\s*C[.:]\s*(.*?)(?:\s*D[.:]\s*(.*))?$/);
  if (match) {
    output.question = match[1].trim();
    output.options = {
      A: match[2].replace(/[✅❌]/g, '').trim(),
      B: match[3].replace(/[✅❌]/g, '').trim(),
      C: match[4].replace(/[✅❌]/g, '').trim()
    };
    if (match[5]) {
      output.options.D = match[5].replace(/[✅❌]/g, '').trim();
    }
    output.answer = ['A', 'B', 'C', 'D'].find(l => match[['A', 'B', 'C', 'D'].indexOf(l) + 2]?.includes('✅') );
  } else {
    output.question = cleaned.trim();
  }
  return output;
};

export default function QuizPage({ prefix, language, setStep, setScore, setPercent }) {
  const [questions, setQuestions] = useState([]);
  const [index, setIndex] = useState(0);
  const [selectedAnswers, setSelectedAnswers] = useState([]);
  const [correctCount, setCorrectCount] = useState(0);

  const t = key => TRANSLATIONS[key]?.[language] || TRANSLATIONS[key]?.en;
  const fsLang = lang => ['zh', 'zh-Hant', 'zh-CN'].includes(lang) ? 'zh' : ['es', 'ru'].includes(lang) ? 'en' : lang;

  useEffect(() => {
    const loadQuestions = async () => {
      const subjectCollection = `core_${fsLang(language)}`;
      const snap = await getDocs(collection(db, subjectCollection));
      const raw = snap.docs.map(doc => doc.data()?.question || doc.data()?.options?.question);
      const parsed = raw.map(parseQuestionText);
      setQuestions(parsed.sort(() => Math.random() - 0.5).slice(0, 20));
      setSelectedAnswers(Array(20).fill(null)); // 初始化答案状态
    };
    loadQuestions();
  }, []);

  const selectAnswer = ans => {
    if (selectedAnswers[index]) return;
    const updated = [...selectedAnswers];
    updated[index] = ans;
    setSelectedAnswers(updated);
    if (ans === questions[index].answer) {
      setCorrectCount(prev => prev + 1);
    }
  };

  const nextQuestion = () => {
    if (index < questions.length - 1) {
      setIndex(prev => prev + 1);
    } else {
      if (selectedAnswers.includes(null)) {
        Alert.alert(
          t('error'),
          t('unanswered'),
          [
            { text: t('yes'), onPress: () => setIndex(selectedAnswers.indexOf(null)) },
            { text: t('no'), onPress: showResults }
          ]
        );
      } else {
        showResults();
      }
    }
  };

  const showResults = () => {
    const percent = Math.round((correctCount / questions.length) * 100);
    setScore(correctCount);
    setPercent(percent);
    setStep('result');
  };

  if (!questions.length) return <Text style={styles.loading}>🚛 Loading...</Text>;

  const current = questions[index];
  const alreadySelected = selectedAnswers[index];

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <TouchableOpacity style={styles.exit} onPress={() => setStep('home')}>
        <Text style={styles.exitText}>⎋ {t('exit')}</Text>
      </TouchableOpacity>

      <Text style={styles.qtitle}>{t('question')} {index + 1}/{questions.length}</Text>
      <Text style={styles.qtext}>{current.question}</Text>

      {current.options && Object.entries(current.options).map(([key, val]) => (
        <TouchableOpacity
          key={key}
          onPress={() => selectAnswer(key)}
          disabled={!!alreadySelected}
          style={[
            styles.option,
            alreadySelected && (key === current.answer ? styles.correct : (key === alreadySelected ? styles.incorrect : null))
          ]}
        >
          <Text style={styles.optionText}>{key}. {val}</Text>
        </TouchableOpacity>
      ))}

      {alreadySelected && current.explanation ? (
        <View style={styles.explainBox}>
          <Text style={styles.explainText}>🔍 {current.explanation}</Text>
          {current.reference ? <Text style={styles.explainText}>📘 {current.reference}</Text> : null}
        </View>
      ) : null}

      {alreadySelected ? (
        <TouchableOpacity style={styles.nextBtn} onPress={nextQuestion}>
          <Text style={styles.nextText}>{index === questions.length - 1 ? t('finish') : t('next')}</Text>
        </TouchableOpacity>
      ) : null}

      <Text style={styles.copy}>
        ⚠️ This App is for J&S/PDA educational use only. Unauthorized distribution is prohibited. ⚠️
      </Text>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { padding: 20, paddingTop: 50 },
  qtitle: { fontSize: 18, textAlign: 'center', marginBottom: 8 },
  qtext: { fontSize: 20, fontWeight: 'bold', marginBottom: 12, textAlign: 'left' },
  option: { padding: 10, backgroundColor: '#eee', borderRadius: 6, marginBottom: 10 },
  correct: { backgroundColor: '#c8f7c5' },
  incorrect: { backgroundColor: '#f8d7da' },
  optionText: { fontSize: 17 },
  explainBox: { padding: 10, backgroundColor: '#fff7d1', borderRadius: 6, marginTop: 12 },
  explainText: { fontSize:16, fontStyle: 'italic' },
  nextBtn: { padding:10, backgroundColor:'#007AFF',borderRadius:6,marginTop:12, alignItems:'center' },
  nextText: { color:'#fff',fontWeight:'bold' },
  exit: { position:'absolute',top:10,left:10 },
  exitText: { color:'#555', fontSize:16 },
  loading:{ fontSize:18,textAlign:'center',marginTop:100 },
  copy:{ fontSize:12,color:'#888',textAlign:'center',marginTop:40 }
});