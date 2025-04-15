// BackgroundLayer.js — 用于背景图淡化展示，适配 Web 与 Mobile

import React from 'react';
import { ImageBackground, StyleSheet, Platform } from 'react-native';

const BackgroundLayer = ({ children }) => {
  return (
    <ImageBackground
      source={require('./assets/sm.png')}
      style={styles.background}
      imageStyle={styles.imageStyle}
      resizeMode="cover"
    >
      {children}
    </ImageBackground>
  );
};

const styles = StyleSheet.create({
  background: {
    flex: 1,
    width: '100%',
    height: '100%',
    justifyContent: 'center'
  },
  imageStyle: {
    opacity: 0.3,
    resizeMode: Platform.OS === 'web' ? 'contain' : 'cover'
  }
});

export default BackgroundLayer;


