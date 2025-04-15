// firebaseConfig.js (标准推荐版)
import { initializeApp, getApps, getApp } from 'firebase/app';
import {
  getAuth,
  initializeAuth,
  getReactNativePersistence,
} from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import AsyncStorage from '@react-native-async-storage/async-storage';

const firebaseConfig = {
  apiKey: "AIzaSyA2ID42Hf8G_Y77gzJ-vHjLZAItBcARMHg",
  authDomain: "ny-cdl-app.firebaseapp.com",
  projectId: "ny-cdl-app",
  storageBucket: "ny-cdl-app.appspot.com",
  messagingSenderId: "973770233665",
  appId: "1:973770233665:web:6b1542a353ffb9d7d8b3c0"
};

// 防止 Firebase 被重复初始化
const app = getApps().length ? getApp() : initializeApp(firebaseConfig);

// 初始化 Firebase Auth 并使用本地存储(AsyncStorage)
let auth;
try {
  auth = initializeAuth(app, {
    persistence: getReactNativePersistence(AsyncStorage),
  });
} catch (e) {
  auth = getAuth(app);
}

//  初始化 Firestore 数据库
const db = getFirestore(app);

export { app, auth, db, firebaseConfig };