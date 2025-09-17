import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

const CreatePostScreen = () => {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Create Post</Text>
      <Text style={styles.subtitle}>Share your thoughts with the world</Text>
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

export default CreatePostScreen;
