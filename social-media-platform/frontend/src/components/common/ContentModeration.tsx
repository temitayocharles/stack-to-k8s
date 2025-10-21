import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  ScrollView,
  Alert,
  ActivityIndicator
} from 'react-native';

interface ModerationResult {
  safe: boolean;
  score: number;
  categories: string[];
  flagged_categories: string[];
  error?: string;
}

const ContentModeration: React.FC = () => {
  const [content, setContent] = useState('');
  const [result, setResult] = useState<ModerationResult | null>(null);
  const [loading, setLoading] = useState(false);

  const moderateContent = async () => {
    if (!content.trim()) {
      Alert.alert('Error', 'Please enter some content to moderate');
      return;
    }

    setLoading(true);
    try {
      const response = await fetch('http://localhost:3000/api/moderate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ content }),
      });

      const data = await response.json();
      setResult(data);
    } catch (error) {
      console.error('Moderation failed:', error);
      Alert.alert('Error', 'Failed to moderate content. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const getRiskColor = (score: number) => {
    if (score < 0.3) return '#4CAF50'; // Green - Low risk
    if (score < 0.7) return '#FFC107'; // Yellow - Medium risk
    return '#F44336'; // Red - High risk
  };

  const getRiskLevel = (score: number) => {
    if (score < 0.3) return 'Low Risk';
    if (score < 0.7) return 'Medium Risk';
    return 'High Risk';
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>🛡️ Content Moderation</Text>
        <Text style={styles.subtitle}>
          AI-powered content analysis and safety checking
        </Text>
      </View>

      <View style={styles.inputContainer}>
        <Text style={styles.label}>Content to Moderate</Text>
        <TextInput
          style={styles.textInput}
          multiline
          numberOfLines={6}
          placeholder="Enter the content you want to check..."
          value={content}
          onChangeText={setContent}
          placeholderTextColor="#657786"
        />

        <TouchableOpacity
          style={[styles.button, loading && styles.buttonDisabled]}
          onPress={moderateContent}
          disabled={loading}
        >
          {loading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.buttonText}>🔍 Analyze Content</Text>
          )}
        </TouchableOpacity>
      </View>

      {result && (
        <View style={styles.resultContainer}>
          <View style={styles.resultHeader}>
            <Text style={styles.resultTitle}>Analysis Result</Text>
            <View style={[styles.riskBadge, { backgroundColor: getRiskColor(result.score) }]}>
              <Text style={styles.riskBadgeText}>{getRiskLevel(result.score)}</Text>
            </View>
          </View>

          <View style={styles.scoreContainer}>
            <Text style={styles.scoreLabel}>Risk Score:</Text>
            <Text style={[styles.scoreValue, { color: getRiskColor(result.score) }]}>
              {(result.score * 100).toFixed(1)}%
            </Text>
          </View>

          <View style={styles.statusContainer}>
            <Text style={styles.statusLabel}>Status:</Text>
            <View style={[styles.statusBadge, result.safe ? styles.safeBadge : styles.unsafeBadge]}>
              <Text style={styles.statusBadgeText}>
                {result.safe ? '✅ Safe' : '🚫 Flagged'}
              </Text>
            </View>
          </View>

          {result.categories && result.categories.length > 0 && (
            <View style={styles.categoriesContainer}>
              <Text style={styles.categoriesTitle}>Detected Categories:</Text>
              <View style={styles.categoriesList}>
                {result.categories.map((category, index) => (
                  <View key={index} style={styles.categoryItem}>
                    <Text style={styles.categoryText}>{category}</Text>
                  </View>
                ))}
              </View>
            </View>
          )}

          {result.flagged_categories && result.flagged_categories.length > 0 && (
            <View style={styles.flaggedContainer}>
              <Text style={styles.flaggedTitle}>🚨 Flagged Content:</Text>
              <View style={styles.flaggedList}>
                {result.flagged_categories.map((category, index) => (
                  <View key={index} style={styles.flaggedItem}>
                    <Text style={styles.flaggedText}>{category}</Text>
                  </View>
                ))}
              </View>
            </View>
          )}

          {result.error && (
            <View style={styles.errorContainer}>
              <Text style={styles.errorText}>⚠️ {result.error}</Text>
            </View>
          )}
        </View>
      )}

      <View style={styles.infoContainer}>
        <Text style={styles.infoTitle}>🤖 How It Works</Text>
        <Text style={styles.infoText}>
          Our AI moderation system analyzes content for potentially harmful or inappropriate material
          using advanced machine learning models. It checks for various categories including hate speech,
          violence, adult content, and other potentially harmful material.
        </Text>

        <Text style={styles.infoText}>
          The system provides a risk score from 0-100%, where higher scores indicate higher risk.
          Content with scores above 70% may be flagged for review.
        </Text>
      </View>

      <View style={styles.examplesContainer}>
        <Text style={styles.examplesTitle}>📝 Example Content</Text>

        <TouchableOpacity
          style={styles.exampleButton}
          onPress={() => setContent("This is a wonderful day to learn about technology and innovation!")}
        >
          <Text style={styles.exampleButtonText}>✅ Safe Example</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.exampleButton}
          onPress={() => setContent("This content contains inappropriate language and harmful content.")}
        >
          <Text style={styles.exampleButtonText}>🚫 Risky Example</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    padding: 20,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e1e8ed',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 5,
  },
  subtitle: {
    fontSize: 14,
    color: '#657786',
  },
  inputContainer: {
    backgroundColor: '#fff',
    margin: 10,
    borderRadius: 12,
    padding: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  label: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 10,
  },
  textInput: {
    borderWidth: 1,
    borderColor: '#e1e8ed',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    color: '#14171a',
    textAlignVertical: 'top',
    marginBottom: 15,
    minHeight: 120,
  },
  button: {
    backgroundColor: '#1da1f2',
    borderRadius: 25,
    padding: 15,
    alignItems: 'center',
  },
  buttonDisabled: {
    backgroundColor: '#ccc',
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  resultContainer: {
    backgroundColor: '#fff',
    margin: 10,
    borderRadius: 12,
    padding: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  resultHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 15,
  },
  resultTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#14171a',
  },
  riskBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  riskBadgeText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
  },
  scoreContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
  },
  scoreLabel: {
    fontSize: 16,
    color: '#657786',
    marginRight: 10,
  },
  scoreValue: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  statusContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 15,
  },
  statusLabel: {
    fontSize: 16,
    color: '#657786',
    marginRight: 10,
  },
  statusBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  safeBadge: {
    backgroundColor: '#4CAF50',
  },
  unsafeBadge: {
    backgroundColor: '#F44336',
  },
  statusBadgeText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
  },
  categoriesContainer: {
    marginBottom: 15,
  },
  categoriesTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 10,
  },
  categoriesList: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  categoryItem: {
    backgroundColor: '#e8f5fd',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 15,
    marginRight: 8,
    marginBottom: 5,
  },
  categoryText: {
    fontSize: 12,
    color: '#1da1f2',
  },
  flaggedContainer: {
    marginBottom: 15,
  },
  flaggedTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#F44336',
    marginBottom: 10,
  },
  flaggedList: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  flaggedItem: {
    backgroundColor: '#ffebee',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 15,
    marginRight: 8,
    marginBottom: 5,
  },
  flaggedText: {
    fontSize: 12,
    color: '#F44336',
  },
  errorContainer: {
    backgroundColor: '#fff3e0',
    padding: 10,
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#FF9800',
  },
  errorText: {
    fontSize: 14,
    color: '#E65100',
  },
  infoContainer: {
    backgroundColor: '#fff',
    margin: 10,
    borderRadius: 12,
    padding: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  infoTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 10,
  },
  infoText: {
    fontSize: 14,
    color: '#657786',
    lineHeight: 20,
    marginBottom: 10,
  },
  examplesContainer: {
    backgroundColor: '#fff',
    margin: 10,
    borderRadius: 12,
    padding: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  examplesTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 15,
  },
  exampleButton: {
    backgroundColor: '#f0f0f0',
    borderRadius: 8,
    padding: 12,
    marginBottom: 10,
    alignItems: 'center',
  },
  exampleButtonText: {
    fontSize: 14,
    color: '#14171a',
  },
});

export default ContentModeration;