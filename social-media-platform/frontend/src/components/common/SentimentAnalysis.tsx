import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  ScrollView,
  Alert,
  ActivityIndicator,
  Dimensions
} from 'react-native';

const { width } = Dimensions.get('window');

interface SentimentResult {
  sentiment: string;
  score: number;
  confidence: number;
  error?: string;
}

const SentimentAnalysis: React.FC = () => {
  const [text, setText] = useState('');
  const [result, setResult] = useState<SentimentResult | null>(null);
  const [loading, setLoading] = useState(false);

  const analyzeSentiment = async () => {
    if (!text.trim()) {
      Alert.alert('Error', 'Please enter some text to analyze');
      return;
    }

    setLoading(true);
    try {
      const response = await fetch('http://localhost:3000/api/sentiment/analyze', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ text }),
      });

      const data = await response.json();
      setResult(data);
    } catch (error) {
      console.error('Sentiment analysis failed:', error);
      Alert.alert('Error', 'Failed to analyze sentiment. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const getSentimentColor = (sentiment: string) => {
    switch (sentiment) {
      case 'positive': return '#4CAF50';
      case 'negative': return '#F44336';
      case 'neutral': return '#FFC107';
      default: return '#9E9E9E';
    }
  };

  const getSentimentEmoji = (sentiment: string) => {
    switch (sentiment) {
      case 'positive': return '😊';
      case 'negative': return '😔';
      case 'neutral': return '😐';
      default: return '🤔';
    }
  };

  const getSentimentDescription = (sentiment: string) => {
    switch (sentiment) {
      case 'positive': return 'This text expresses positive emotions and satisfaction';
      case 'negative': return 'This text expresses negative emotions or dissatisfaction';
      case 'neutral': return 'This text is neutral and doesn\'t show strong emotions';
      default: return 'Unable to determine sentiment';
    }
  };

  const renderSentimentMeter = (score: number) => {
    const percentage = Math.round(score * 100);
    return (
      <View style={styles.meterContainer}>
        <View style={styles.meterBackground}>
          <View
            style={[
              styles.meterFill,
              {
                width: `${percentage}%`,
                backgroundColor: percentage > 50 ? '#4CAF50' : percentage > 25 ? '#FFC107' : '#F44336'
              }
            ]}
          />
        </View>
        <Text style={styles.meterText}>{percentage}%</Text>
      </View>
    );
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>😊 Sentiment Analysis</Text>
        <Text style={styles.subtitle}>
          Understand the emotional tone of your content
        </Text>
      </View>

      <View style={styles.inputContainer}>
        <Text style={styles.label}>Text to Analyze</Text>
        <TextInput
          style={styles.textInput}
          multiline
          numberOfLines={6}
          placeholder="Enter the text you want to analyze for sentiment..."
          value={text}
          onChangeText={setText}
          placeholderTextColor="#657786"
        />

        <TouchableOpacity
          style={[styles.button, loading && styles.buttonDisabled]}
          onPress={analyzeSentiment}
          disabled={loading}
        >
          {loading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.buttonText}>🔍 Analyze Sentiment</Text>
          )}
        </TouchableOpacity>
      </View>

      {result && (
        <View style={styles.resultContainer}>
          <View style={styles.resultHeader}>
            <Text style={styles.resultTitle}>Analysis Result</Text>
            <View style={[styles.sentimentBadge, { backgroundColor: getSentimentColor(result.sentiment) }]}>
              <Text style={styles.sentimentEmoji}>{getSentimentEmoji(result.sentiment)}</Text>
              <Text style={styles.sentimentBadgeText}>{result.sentiment.toUpperCase()}</Text>
            </View>
          </View>

          <Text style={styles.description}>
            {getSentimentDescription(result.sentiment)}
          </Text>

          <View style={styles.scoreContainer}>
            <Text style={styles.scoreLabel}>Sentiment Score:</Text>
            <Text style={styles.scoreValue}>
              {(result.score * 100).toFixed(1)}%
            </Text>
          </View>

          <View style={styles.confidenceContainer}>
            <Text style={styles.confidenceLabel}>Confidence:</Text>
            <Text style={styles.confidenceValue}>
              {(result.confidence * 100).toFixed(1)}%
            </Text>
          </View>

          <View style={styles.meterSection}>
            <Text style={styles.meterLabel}>Sentiment Intensity:</Text>
            {renderSentimentMeter(result.score)}
          </View>

          {result.error && (
            <View style={styles.errorContainer}>
              <Text style={styles.errorText}>⚠️ {result.error}</Text>
            </View>
          )}
        </View>
      )}

      <View style={styles.examplesContainer}>
        <Text style={styles.examplesTitle}>📝 Try These Examples</Text>

        <TouchableOpacity
          style={styles.exampleButton}
          onPress={() => setText("I absolutely love this new feature! It's amazing and works perfectly.")}
        >
          <Text style={styles.exampleButtonText}>😊 Positive Example</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.exampleButton}
          onPress={() => setText("This is really disappointing. I expected much better quality.")}
        >
          <Text style={styles.exampleButtonText}>😔 Negative Example</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.exampleButton}
          onPress={() => setText("The weather is okay today, nothing special.")}
        >
          <Text style={styles.exampleButtonText}>😐 Neutral Example</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.infoContainer}>
        <Text style={styles.infoTitle}>🤖 How Sentiment Analysis Works</Text>
        <Text style={styles.infoText}>
          Our AI analyzes text to determine emotional tone and intensity. The system considers:
        </Text>

        <View style={styles.bulletPoints}>
          <Text style={styles.bulletPoint}>• Word choice and emotional language</Text>
          <Text style={styles.bulletPoint}>• Context and situational factors</Text>
          <Text style={styles.bulletPoint}>• Intensity modifiers (very, extremely, etc.)</Text>
          <Text style={styles.bulletPoint}>• Cultural and linguistic nuances</Text>
        </View>

        <Text style={styles.infoText}>
          The sentiment score ranges from 0-100%, where higher scores indicate stronger positive sentiment.
          Confidence indicates how certain the AI is about its analysis.
        </Text>
      </View>

      <View style={styles.useCasesContainer}>
        <Text style={styles.useCasesTitle}>💡 Common Use Cases</Text>

        <View style={styles.useCase}>
          <Text style={styles.useCaseTitle}>📊 Social Media Monitoring</Text>
          <Text style={styles.useCaseText}>
            Track public sentiment about your brand or products
          </Text>
        </View>

        <View style={styles.useCase}>
          <Text style={styles.useCaseTitle}>💬 Customer Feedback</Text>
          <Text style={styles.useCaseText}>
            Analyze customer reviews and support tickets
          </Text>
        </View>

        <View style={styles.useCase}>
          <Text style={styles.useCaseTitle}>📰 Content Analysis</Text>
          <Text style={styles.useCaseText}>
            Understand audience reactions to your content
          </Text>
        </View>

        <View style={styles.useCase}>
          <Text style={styles.useCaseTitle}>🎯 Market Research</Text>
          <Text style={styles.useCaseText}>
            Gauge public opinion on current events or trends
          </Text>
        </View>
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
  sentimentBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 20,
  },
  sentimentEmoji: {
    fontSize: 16,
    marginRight: 5,
  },
  sentimentBadgeText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
  },
  description: {
    fontSize: 16,
    color: '#657786',
    lineHeight: 22,
    marginBottom: 15,
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
    color: '#1da1f2',
  },
  confidenceContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 15,
  },
  confidenceLabel: {
    fontSize: 16,
    color: '#657786',
    marginRight: 10,
  },
  confidenceValue: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#4CAF50',
  },
  meterSection: {
    marginBottom: 15,
  },
  meterLabel: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 10,
  },
  meterContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  meterBackground: {
    flex: 1,
    height: 20,
    backgroundColor: '#e1e8ed',
    borderRadius: 10,
    marginRight: 10,
    overflow: 'hidden',
  },
  meterFill: {
    height: '100%',
    borderRadius: 10,
  },
  meterText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#14171a',
    minWidth: 40,
    textAlign: 'center',
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
  bulletPoints: {
    marginLeft: 10,
    marginBottom: 10,
  },
  bulletPoint: {
    fontSize: 14,
    color: '#657786',
    lineHeight: 20,
  },
  useCasesContainer: {
    backgroundColor: '#fff',
    margin: 10,
    borderRadius: 12,
    padding: 15,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  useCasesTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 15,
  },
  useCase: {
    marginBottom: 15,
  },
  useCaseTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#1da1f2',
    marginBottom: 5,
  },
  useCaseText: {
    fontSize: 14,
    color: '#657786',
    lineHeight: 20,
  },
});

export default SentimentAnalysis;