import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  FlatList,
  TouchableOpacity,
  Dimensions,
  ActivityIndicator
} from 'react-native';

const { width } = Dimensions.get('window');

interface SearchResult {
  type: string;
  id: string | number;
  content?: string;
  user_id?: number;
  score: number;
  title?: string;
  tags?: string[];
}

interface SmartSearchProps {
  userId?: number;
  placeholder?: string;
  onResultPress?: (result: SearchResult) => void;
}

const SmartSearch: React.FC<SmartSearchProps> = ({
  userId,
  placeholder = "Search posts, topics, or users...",
  onResultPress
}) => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState(false);
  const [searchHistory, setSearchHistory] = useState<string[]>([]);

  const performSearch = async (searchQuery: string) => {
    if (!searchQuery.trim()) {
      setResults([]);
      return;
    }

    setLoading(true);
    try {
      const response = await fetch(
        `http://localhost:3000/api/search?q=${encodeURIComponent(searchQuery)}${userId ? `&user_id=${userId}` : ''}`
      );
      const data = await response.json();

      if (data.results) {
        setResults(data.results);
        // Add to search history
        if (!searchHistory.includes(searchQuery)) {
          setSearchHistory(prev => [searchQuery, ...prev.slice(0, 9)]);
        }
      }
    } catch (error) {
      console.error('Search failed:', error);
      setResults([]);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (text: string) => {
    setQuery(text);
    if (text.length > 2) {
      performSearch(text);
    } else {
      setResults([]);
    }
  };

  const clearSearch = () => {
    setQuery('');
    setResults([]);
  };

  const renderSearchResult = ({ item }: { item: SearchResult }) => (
    <TouchableOpacity
      style={styles.resultItem}
      onPress={() => onResultPress?.(item)}
    >
      <View style={styles.resultHeader}>
        <Text style={styles.resultType}>
          {item.type === 'post' ? '📝' : item.type === 'user' ? '👤' : '🏷️'}
        </Text>
        <View style={styles.resultContent}>
          <Text style={styles.resultTitle}>
            {item.type === 'post' ? `Post by User ${item.user_id}` :
             item.type === 'user' ? `User ${item.id}` :
             item.title || item.content?.substring(0, 50)}
          </Text>
          {item.content && (
            <Text style={styles.resultSnippet} numberOfLines={2}>
              {item.content}
            </Text>
          )}
        </View>
        <View style={styles.scoreBadge}>
          <Text style={styles.scoreText}>{item.score.toFixed(1)}</Text>
        </View>
      </View>

      {item.tags && item.tags.length > 0 && (
        <View style={styles.tagsContainer}>
          {item.tags.slice(0, 3).map((tag, index) => (
            <Text key={index} style={styles.tag}>#{tag}</Text>
          ))}
        </View>
      )}
    </TouchableOpacity>
  );

  const renderSearchHistory = () => (
    <View style={styles.historyContainer}>
      <Text style={styles.historyTitle}>Recent Searches</Text>
      {searchHistory.map((item, index) => (
        <TouchableOpacity
          key={index}
          style={styles.historyItem}
          onPress={() => handleSearch(item)}
        >
          <Text style={styles.historyText}>🔍 {item}</Text>
        </TouchableOpacity>
      ))}
    </View>
  );

  const renderTrendingTopics = () => (
    <View style={styles.trendingContainer}>
      <Text style={styles.trendingTitle}>🔥 Trending Topics</Text>
      <View style={styles.trendingTopics}>
        {['AI', 'Machine Learning', 'Web Development', 'Docker', 'Kubernetes', 'React'].map((topic, index) => (
          <TouchableOpacity
            key={index}
            style={styles.trendingTopic}
            onPress={() => handleSearch(topic)}
          >
            <Text style={styles.trendingTopicText}>#{topic}</Text>
          </TouchableOpacity>
        ))}
      </View>
    </View>
  );

  return (
    <View style={styles.container}>
      {/* Search Input */}
      <View style={styles.searchContainer}>
        <TextInput
          style={styles.searchInput}
          placeholder={placeholder}
          value={query}
          onChangeText={handleSearch}
          placeholderTextColor="#657786"
        />
        {query.length > 0 && (
          <TouchableOpacity style={styles.clearButton} onPress={clearSearch}>
            <Text style={styles.clearButtonText}>✕</Text>
          </TouchableOpacity>
        )}
        {loading && (
          <View style={styles.loadingIndicator}>
            <ActivityIndicator size="small" color="#1da1f2" />
          </View>
        )}
      </View>

      {/* Search Results */}
      {query.length > 0 && (
        <FlatList
          data={results}
          renderItem={renderSearchResult}
          keyExtractor={(item, index) => `${item.type}-${item.id}-${index}`}
          style={styles.resultsList}
          ListEmptyComponent={
            !loading ? (
              <View style={styles.noResults}>
                <Text style={styles.noResultsEmoji}>🔍</Text>
                <Text style={styles.noResultsText}>No results found</Text>
                <Text style={styles.noResultsSubtext}>Try different keywords or check spelling</Text>
              </View>
            ) : null
          }
        />
      )}

      {/* Default State */}
      {query.length === 0 && (
        <View style={styles.defaultState}>
          {renderSearchHistory()}
          {renderTrendingTopics()}
        </View>
      )}

      {/* AI-Powered Search Info */}
      <View style={styles.aiInfo}>
        <Text style={styles.aiInfoText}>
          🤖 Powered by AI • Smart search with personalized results
        </Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    margin: 10,
    borderRadius: 25,
    paddingHorizontal: 15,
    paddingVertical: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  searchInput: {
    flex: 1,
    fontSize: 16,
    color: '#14171a',
    paddingVertical: 5,
  },
  clearButton: {
    padding: 5,
  },
  clearButtonText: {
    fontSize: 18,
    color: '#657786',
  },
  loadingIndicator: {
    padding: 5,
  },
  resultsList: {
    flex: 1,
    paddingHorizontal: 10,
  },
  resultItem: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 15,
    marginBottom: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  resultHeader: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  resultType: {
    fontSize: 20,
    marginRight: 10,
    marginTop: 2,
  },
  resultContent: {
    flex: 1,
  },
  resultTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 4,
  },
  resultSnippet: {
    fontSize: 14,
    color: '#657786',
    lineHeight: 20,
  },
  scoreBadge: {
    backgroundColor: '#e8f5fd',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  scoreText: {
    fontSize: 12,
    color: '#1da1f2',
    fontWeight: 'bold',
  },
  tagsContainer: {
    flexDirection: 'row',
    marginTop: 8,
  },
  tag: {
    fontSize: 12,
    color: '#1da1f2',
    marginRight: 8,
  },
  defaultState: {
    flex: 1,
    padding: 10,
  },
  historyContainer: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 15,
    marginBottom: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  historyTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 10,
  },
  historyItem: {
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#e1e8ed',
  },
  historyText: {
    fontSize: 16,
    color: '#657786',
  },
  trendingContainer: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  trendingTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 15,
  },
  trendingTopics: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  trendingTopic: {
    backgroundColor: '#e8f5fd',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
    marginRight: 8,
    marginBottom: 8,
  },
  trendingTopicText: {
    fontSize: 14,
    color: '#1da1f2',
    fontWeight: 'bold',
  },
  noResults: {
    alignItems: 'center',
    padding: 40,
  },
  noResultsEmoji: {
    fontSize: 48,
    marginBottom: 20,
  },
  noResultsText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 5,
  },
  noResultsSubtext: {
    fontSize: 14,
    color: '#657786',
    textAlign: 'center',
  },
  aiInfo: {
    padding: 10,
    alignItems: 'center',
  },
  aiInfoText: {
    fontSize: 12,
    color: '#657786',
  },
});

export default SmartSearch;