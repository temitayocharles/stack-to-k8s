import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Image,
  Dimensions,
  ActivityIndicator
} from 'react-native';

const { width } = Dimensions.get('window');

interface Recommendation {
  id: string;
  user_id: number;
  content: string;
  created_at: string;
  moderated: boolean;
  sentiment: string;
  sentiment_score: number;
  likes: number;
  comments: number;
  shares: number;
  recommendation_score?: number;
  ai_tags?: string[];
}

interface RecommendationEngineProps {
  userId: number;
  onPostPress?: (post: Recommendation) => void;
  onRefresh?: () => void;
}

const RecommendationEngine: React.FC<RecommendationEngineProps> = ({
  userId,
  onPostPress,
  onRefresh
}) => {
  const [recommendations, setRecommendations] = useState<Recommendation[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const fetchRecommendations = async () => {
    try {
      const response = await fetch(`http://localhost:3000/api/posts/recommendations/${userId}`);
      const data = await response.json();

      if (data.recommendations) {
        setRecommendations(data.recommendations);
      }
    } catch (error) {
      console.error('Failed to fetch recommendations:', error);
    }
  };

  const loadRecommendations = async () => {
    setLoading(true);
    await fetchRecommendations();
    setLoading(false);
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await fetchRecommendations();
    setRefreshing(false);
    onRefresh?.();
  };

  const handlePostInteraction = async (postId: string, interactionType: string) => {
    try {
      await fetch('http://localhost:3000/api/interactions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          user_id: userId,
          post_id: postId,
          type: interactionType,
          metadata: {
            source: 'recommendation',
            timestamp: new Date().toISOString()
          }
        })
      });
    } catch (error) {
      console.error('Failed to record interaction:', error);
    }
  };

  useEffect(() => {
    loadRecommendations();
  }, [userId]);

  const renderRecommendationItem = ({ item }: { item: Recommendation }) => (
    <TouchableOpacity
      style={styles.recommendationCard}
      onPress={() => {
        handlePostInteraction(item.id, 'view');
        onPostPress?.(item);
      }}
    >
      <View style={styles.recommendationHeader}>
        <View style={styles.userAvatar}>
          <Text style={styles.avatarText}>
            {item.user_id.toString().charAt(0).toUpperCase()}
          </Text>
        </View>
        <View style={styles.userInfo}>
          <Text style={styles.userName}>User {item.user_id}</Text>
          <Text style={styles.timestamp}>
            {new Date(item.created_at).toLocaleDateString()}
          </Text>
        </View>
        <View style={styles.aiBadge}>
          <Text style={styles.aiBadgeText}>🤖 AI</Text>
        </View>
      </View>

      <Text style={styles.postContent}>{item.content}</Text>

      {item.ai_tags && item.ai_tags.length > 0 && (
        <View style={styles.tagsContainer}>
          {item.ai_tags.slice(0, 3).map((tag, index) => (
            <View key={index} style={styles.tag}>
              <Text style={styles.tagText}>#{tag}</Text>
            </View>
          ))}
        </View>
      )}

      <View style={styles.sentimentIndicator}>
        <Text style={styles.sentimentText}>
          {item.sentiment === 'positive' ? '😊' :
           item.sentiment === 'negative' ? '😔' : '😐'} {item.sentiment}
        </Text>
        <Text style={styles.sentimentScore}>
          {Math.round(item.sentiment_score * 100)}% confidence
        </Text>
      </View>

      <View style={styles.engagementContainer}>
        <TouchableOpacity
          style={styles.engagementButton}
          onPress={() => handlePostInteraction(item.id, 'like')}
        >
          <Text style={styles.engagementText}>👍 {item.likes}</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.engagementButton}
          onPress={() => handlePostInteraction(item.id, 'comment')}
        >
          <Text style={styles.engagementText}>💬 {item.comments}</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.engagementButton}
          onPress={() => handlePostInteraction(item.id, 'share')}
        >
          <Text style={styles.engagementText}>🔗 {item.shares}</Text>
        </TouchableOpacity>
      </View>

      {item.recommendation_score && (
        <View style={styles.recommendationScore}>
          <Text style={styles.scoreText}>
            🎯 Recommended for you • Score: {item.recommendation_score.toFixed(1)}
          </Text>
        </View>
      )}
    </TouchableOpacity>
  );

  const renderEmptyState = () => (
    <View style={styles.emptyContainer}>
      <Text style={styles.emptyEmoji}>🎯</Text>
      <Text style={styles.emptyTitle}>No Recommendations Yet</Text>
      <Text style={styles.emptyText}>
        Start interacting with posts to get personalized recommendations!
      </Text>
    </View>
  );

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#1da1f2" />
        <Text style={styles.loadingText}>Finding perfect recommendations...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>🎯 For You</Text>
        <Text style={styles.subtitle}>
          Personalized recommendations based on your interests
        </Text>
      </View>

      <FlatList
        data={recommendations}
        renderItem={renderRecommendationItem}
        keyExtractor={(item) => item.id}
        showsVerticalScrollIndicator={false}
        refreshing={refreshing}
        onRefresh={handleRefresh}
        ListEmptyComponent={renderEmptyState}
        contentContainerStyle={styles.listContainer}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: '#657786',
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
  listContainer: {
    padding: 10,
  },
  recommendationCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 15,
    marginBottom: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  recommendationHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
  },
  userAvatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#1da1f2',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 10,
  },
  avatarText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  userInfo: {
    flex: 1,
  },
  userName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#14171a',
  },
  timestamp: {
    fontSize: 12,
    color: '#657786',
  },
  aiBadge: {
    backgroundColor: '#e8f5fd',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  aiBadgeText: {
    fontSize: 12,
    color: '#1da1f2',
    fontWeight: 'bold',
  },
  postContent: {
    fontSize: 16,
    color: '#14171a',
    lineHeight: 22,
    marginBottom: 10,
  },
  tagsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginBottom: 10,
  },
  tag: {
    backgroundColor: '#f0f0f0',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
    marginRight: 8,
    marginBottom: 4,
  },
  tagText: {
    fontSize: 12,
    color: '#657786',
  },
  sentimentIndicator: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#f8f9fa',
    padding: 8,
    borderRadius: 6,
    marginBottom: 10,
  },
  sentimentText: {
    fontSize: 14,
    fontWeight: 'bold',
  },
  sentimentScore: {
    fontSize: 12,
    color: '#657786',
  },
  engagementContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingTop: 10,
    borderTopWidth: 1,
    borderTopColor: '#e1e8ed',
  },
  engagementButton: {
    padding: 8,
  },
  engagementText: {
    fontSize: 14,
    color: '#657786',
  },
  recommendationScore: {
    marginTop: 10,
    padding: 8,
    backgroundColor: '#e8f5fd',
    borderRadius: 6,
  },
  scoreText: {
    fontSize: 12,
    color: '#1da1f2',
    textAlign: 'center',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
  },
  emptyEmoji: {
    fontSize: 48,
    marginBottom: 20,
  },
  emptyTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 10,
    textAlign: 'center',
  },
  emptyText: {
    fontSize: 16,
    color: '#657786',
    textAlign: 'center',
    lineHeight: 22,
  },
});

export default RecommendationEngine;