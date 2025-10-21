import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

const FollowingScreen = () => {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Following</Text>
      <Text style={styles.subtitle}>Screen to be implemented</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ffffff',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
  },
});

export default FollowingScreen;
