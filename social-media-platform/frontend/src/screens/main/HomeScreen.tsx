import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  RefreshControl,
  ActivityIndicator,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { AppDispatch, RootState } from '../../store';
import { getFeed, resetFeedPage } from '../../store/slices/postSlice';
import { Post } from '../../store/slices/postSlice';

// Post Card Component (placeholder)
const PostCard = ({ post, onPress }: { post: Post; onPress: () => void }) => {
  return (
    <TouchableOpacity style={styles.postCard} onPress={onPress}>
      <View style={styles.postHeader}>
        <Text style={styles.userName}>{post.user.name}</Text>
        <Text style={styles.userHandle}>@{post.user.username}</Text>
        <Text style={styles.postTime}>{post.formatted_created_at}</Text>
      </View>
      <Text style={styles.postContent}>{post.content}</Text>
      <View style={styles.postActions}>
        <Text style={styles.actionText}>💬 {post.comments_count}</Text>
        <Text style={styles.actionText}>
          {post.current_user_liked ? '❤️' : '🤍'} {post.likes_count}
        </Text>
        <Text style={styles.actionText}>🔄 {post.shares_count}</Text>
      </View>
    </TouchableOpacity>
  );
};

const HomeScreen = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { feed, isLoading, error, hasMoreFeed, refreshing } = useSelector(
    (state: RootState) => state.posts
  );
  const [loadingMore, setLoadingMore] = useState(false);

  useEffect(() => {
    loadFeed();
  }, []);

  const loadFeed = async (refresh = false) => {
    try {
      if (refresh) {
        dispatch(resetFeedPage());
      }
      await dispatch(getFeed({ page: 1, refresh })).unwrap();
    } catch (error: any) {
      Alert.alert('Error', error || 'Failed to load feed');
    }
  };

  const loadMorePosts = async () => {
    if (loadingMore || !hasMoreFeed) return;

    setLoadingMore(true);
    try {
      await dispatch(getFeed({})).unwrap();
    } catch (error: any) {
      Alert.alert('Error', error || 'Failed to load more posts');
    } finally {
      setLoadingMore(false);
    }
  };

  const handleRefresh = () => {
    loadFeed(true);
  };

  const handlePostPress = (post: Post) => {
    // Navigate to post detail
    console.log('Navigate to post:', post.id);
  };

  const renderPost = ({ item }: { item: Post }) => (
    <PostCard post={item} onPress={() => handlePostPress(item)} />
  );

  const renderFooter = () => {
    if (!loadingMore) return null;
    return (
      <View style={styles.loadingFooter}>
        <ActivityIndicator size="small" color="#1da1f2" />
      </View>
    );
  };

  const renderEmpty = () => {
    if (isLoading) return null;
    return (
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyTitle}>No posts yet</Text>
        <Text style={styles.emptySubtitle}>
          Follow some users to see their posts in your feed
        </Text>
      </View>
    );
  };

  if (isLoading && feed.length === 0) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#1da1f2" />
        <Text style={styles.loadingText}>Loading your feed...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Home</Text>
        <TouchableOpacity style={styles.headerButton}>
          <Text style={styles.headerButtonText}>✨</Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={feed}
        renderItem={renderPost}
        keyExtractor={(item) => item.id}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={handleRefresh}
            colors={['#1da1f2']}
            tintColor="#1da1f2"
          />
        }
        onEndReached={loadMorePosts}
        onEndReachedThreshold={0.5}
        ListFooterComponent={renderFooter}
        ListEmptyComponent={renderEmpty}
        showsVerticalScrollIndicator={false}
        style={styles.feedList}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#e1e8ed',
    backgroundColor: '#ffffff',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1a1a1a',
  },
  headerButton: {
    padding: 8,
  },
  headerButtonText: {
    fontSize: 18,
  },
  feedList: {
    flex: 1,
  },
  postCard: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#e1e8ed',
  },
  postHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  userName: {
    fontWeight: 'bold',
    fontSize: 15,
    color: '#1a1a1a',
    marginRight: 4,
  },
  userHandle: {
    fontSize: 15,
    color: '#657786',
    marginRight: 4,
  },
  postTime: {
    fontSize: 15,
    color: '#657786',
    marginLeft: 'auto',
  },
  postContent: {
    fontSize: 16,
    lineHeight: 20,
    color: '#1a1a1a',
    marginBottom: 12,
  },
  postActions: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingTop: 8,
  },
  actionText: {
    fontSize: 14,
    color: '#657786',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ffffff',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#657786',
  },
  loadingFooter: {
    paddingVertical: 20,
    alignItems: 'center',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 32,
    paddingVertical: 64,
  },
  emptyTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1a1a1a',
    marginBottom: 8,
    textAlign: 'center',
  },
  emptySubtitle: {
    fontSize: 16,
    color: '#657786',
    textAlign: 'center',
    lineHeight: 22,
  },
});

export default HomeScreen;
