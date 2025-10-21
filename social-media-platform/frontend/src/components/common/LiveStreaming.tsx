import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  TextInput,
  Alert,
  ActivityIndicator,
  Dimensions,
  Image,
  FlatList
} from 'react-native';

const { width, height } = Dimensions.get('window');

interface StreamData {
  id: string;
  title: string;
  streamer: string;
  viewers: number;
  isLive: boolean;
  thumbnail: string;
  category: string;
  startedAt: string;
}

interface ChatMessage {
  id: string;
  user: string;
  message: string;
  timestamp: string;
}

const LiveStreaming: React.FC = () => {
  const [isStreaming, setIsStreaming] = useState(false);
  const [streamTitle, setStreamTitle] = useState('');
  const [streamCategory, setStreamCategory] = useState('');
  const [liveStreams, setLiveStreams] = useState<StreamData[]>([]);
  const [selectedStream, setSelectedStream] = useState<StreamData | null>(null);
  const [chatMessages, setChatMessages] = useState<ChatMessage[]>([]);
  const [newMessage, setNewMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const [viewingStream, setViewingStream] = useState(false);

  const chatScrollRef = useRef<ScrollView>(null);

  useEffect(() => {
    fetchLiveStreams();
    const interval = setInterval(fetchLiveStreams, 30000); // Refresh every 30 seconds
    return () => clearInterval(interval);
  }, []);

  const fetchLiveStreams = async () => {
    try {
      const response = await fetch('http://localhost:3000/api/streams/live');
      const data = await response.json();
      setLiveStreams(data.streams || []);
    } catch (error) {
      console.error('Failed to fetch live streams:', error);
    }
  };

  const startStream = async () => {
    if (!streamTitle.trim() || !streamCategory.trim()) {
      Alert.alert('Error', 'Please enter both title and category for your stream');
      return;
    }

    setLoading(true);
    try {
      const response = await fetch('http://localhost:3000/api/streams/start', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          title: streamTitle,
          category: streamCategory,
          streamer: 'current_user' // In real app, get from auth
        }),
      });

      const data = await response.json();
      if (data.success) {
        setIsStreaming(true);
        Alert.alert('Success', 'Your stream is now live!');
        fetchLiveStreams();
      } else {
        Alert.alert('Error', data.message || 'Failed to start stream');
      }
    } catch (error) {
      console.error('Failed to start stream:', error);
      Alert.alert('Error', 'Failed to start stream. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const stopStream = async () => {
    setLoading(true);
    try {
      const response = await fetch('http://localhost:3000/api/streams/stop', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      });

      const data = await response.json();
      if (data.success) {
        setIsStreaming(false);
        setStreamTitle('');
        setStreamCategory('');
        Alert.alert('Success', 'Stream ended successfully');
        fetchLiveStreams();
      }
    } catch (error) {
      console.error('Failed to stop stream:', error);
      Alert.alert('Error', 'Failed to stop stream');
    } finally {
      setLoading(false);
    }
  };

  const joinStream = (stream: StreamData) => {
    setSelectedStream(stream);
    setViewingStream(true);
    // In a real app, this would connect to the streaming service
    fetchChatMessages(stream.id);
  };

  const fetchChatMessages = async (streamId: string) => {
    try {
      const response = await fetch(`http://localhost:3000/api/streams/${streamId}/chat`);
      const data = await response.json();
      setChatMessages(data.messages || []);
    } catch (error) {
      console.error('Failed to fetch chat messages:', error);
    }
  };

  const sendChatMessage = async () => {
    if (!newMessage.trim() || !selectedStream) return;

    try {
      const response = await fetch(`http://localhost:3000/api/streams/${selectedStream.id}/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: newMessage,
          user: 'current_user' // In real app, get from auth
        }),
      });

      if (response.ok) {
        setNewMessage('');
        fetchChatMessages(selectedStream.id);
      }
    } catch (error) {
      console.error('Failed to send message:', error);
    }
  };

  const leaveStream = () => {
    setSelectedStream(null);
    setViewingStream(false);
    setChatMessages([]);
  };

  const renderStreamCard = ({ item }: { item: StreamData }) => (
    <TouchableOpacity
      style={styles.streamCard}
      onPress={() => joinStream(item)}
    >
      <Image
        source={{ uri: item.thumbnail || 'https://via.placeholder.com/300x200?text=Live+Stream' }}
        style={styles.streamThumbnail}
      />
      <View style={styles.streamInfo}>
        <Text style={styles.streamTitle} numberOfLines={2}>
          {item.title}
        </Text>
        <Text style={styles.streamerName}>{item.streamer}</Text>
        <View style={styles.streamStats}>
          <View style={styles.liveIndicator}>
            <Text style={styles.liveText}>🔴 LIVE</Text>
          </View>
          <Text style={styles.viewersText}>{item.viewers} viewers</Text>
        </View>
        <Text style={styles.categoryText}>{item.category}</Text>
      </View>
    </TouchableOpacity>
  );

  const renderChatMessage = ({ item }: { item: ChatMessage }) => (
    <View style={styles.chatMessage}>
      <Text style={styles.chatUser}>{item.user}:</Text>
      <Text style={styles.chatText}>{item.message}</Text>
    </View>
  );

  if (viewingStream && selectedStream) {
    return (
      <View style={styles.streamViewContainer}>
        {/* Stream Video Area */}
        <View style={styles.videoContainer}>
          <View style={styles.videoPlaceholder}>
            <Text style={styles.videoPlaceholderText}>🎥 Live Stream</Text>
            <Text style={styles.streamTitleText}>{selectedStream.title}</Text>
            <Text style={styles.streamerText}>by {selectedStream.streamer}</Text>
          </View>
        </View>

        {/* Stream Info */}
        <View style={styles.streamHeader}>
          <View style={styles.streamDetails}>
            <Text style={styles.streamTitleText}>{selectedStream.title}</Text>
            <Text style={styles.streamerText}>{selectedStream.streamer}</Text>
            <View style={styles.streamStatsRow}>
              <View style={styles.liveBadge}>
                <Text style={styles.liveBadgeText}>🔴 LIVE</Text>
              </View>
              <Text style={styles.viewersCount}>{selectedStream.viewers} watching</Text>
            </View>
          </View>
          <TouchableOpacity style={styles.leaveButton} onPress={leaveStream}>
            <Text style={styles.leaveButtonText}>Leave Stream</Text>
          </TouchableOpacity>
        </View>

        {/* Chat */}
        <View style={styles.chatContainer}>
          <Text style={styles.chatTitle}>💬 Live Chat</Text>

          <ScrollView
            ref={chatScrollRef}
            style={styles.chatMessages}
            onContentSizeChange={() => chatScrollRef.current?.scrollToEnd()}
          >
            {chatMessages.map((message) => (
              <View key={message.id} style={styles.chatMessage}>
                <Text style={styles.chatUser}>{message.user}:</Text>
                <Text style={styles.chatText}>{message.message}</Text>
              </View>
            ))}
          </ScrollView>

          <View style={styles.chatInputContainer}>
            <TextInput
              style={styles.chatInput}
              placeholder="Type a message..."
              value={newMessage}
              onChangeText={setNewMessage}
              onSubmitEditing={sendChatMessage}
            />
            <TouchableOpacity style={styles.sendButton} onPress={sendChatMessage}>
              <Text style={styles.sendButtonText}>📤</Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>📺 Live Streaming</Text>
        <Text style={styles.subtitle}>
          Go live and connect with your audience in real-time
        </Text>
      </View>

      {/* Stream Controls */}
      <View style={styles.streamControls}>
        <Text style={styles.sectionTitle}>
          {isStreaming ? '🔴 You\'re Live!' : '🎬 Start Streaming'}
        </Text>

        {!isStreaming ? (
          <>
            <TextInput
              style={styles.input}
              placeholder="Stream Title"
              value={streamTitle}
              onChangeText={setStreamTitle}
              placeholderTextColor="#657786"
            />

            <TextInput
              style={styles.input}
              placeholder="Category (Gaming, Music, Talk, etc.)"
              value={streamCategory}
              onChangeText={setStreamCategory}
              placeholderTextColor="#657786"
            />

            <TouchableOpacity
              style={[styles.streamButton, loading && styles.buttonDisabled]}
              onPress={startStream}
              disabled={loading}
            >
              {loading ? (
                <ActivityIndicator color="#fff" />
              ) : (
                <Text style={styles.streamButtonText}>🚀 Go Live</Text>
              )}
            </TouchableOpacity>
          </>
        ) : (
          <TouchableOpacity
            style={[styles.stopButton, loading && styles.buttonDisabled]}
            onPress={stopStream}
            disabled={loading}
          >
            {loading ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.stopButtonText}>⏹️ Stop Stream</Text>
            )}
          </TouchableOpacity>
        )}
      </View>

      {/* Live Streams */}
      <View style={styles.liveStreamsSection}>
        <Text style={styles.sectionTitle}>🔥 Live Now</Text>

        {liveStreams.length > 0 ? (
          <FlatList
            data={liveStreams}
            renderItem={renderStreamCard}
            keyExtractor={(item) => item.id}
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={styles.streamsList}
          />
        ) : (
          <View style={styles.noStreamsContainer}>
            <Text style={styles.noStreamsText}>📺 No live streams right now</Text>
            <Text style={styles.noStreamsSubtext}>Be the first to go live!</Text>
          </View>
        )}
      </View>

      {/* Streaming Tips */}
      <View style={styles.tipsContainer}>
        <Text style={styles.tipsTitle}>💡 Streaming Tips</Text>

        <View style={styles.tip}>
          <Text style={styles.tipTitle}>🎯 Choose a Great Title</Text>
          <Text style={styles.tipText}>
            Make it descriptive and engaging to attract viewers
          </Text>
        </View>

        <View style={styles.tip}>
          <Text style={styles.tipTitle}>🎭 Interact with Chat</Text>
          <Text style={styles.tipText}>
            Respond to messages and build a community
          </Text>
        </View>

        <View style={styles.tip}>
          <Text style={styles.tipTitle}>⚡ Go Live at Peak Times</Text>
          <Text style={styles.tipText}>
            Stream when your audience is most active
          </Text>
        </View>

        <View style={styles.tip}>
          <Text style={styles.tipTitle}>🎨 Use Good Lighting</Text>
          <Text style={styles.tipText}>
            Ensure viewers can see you clearly
          </Text>
        </View>
      </View>

      {/* Categories */}
      <View style={styles.categoriesContainer}>
        <Text style={styles.categoriesTitle}>🏷️ Popular Categories</Text>
        <View style={styles.categoryButtons}>
          {['Gaming', 'Music', 'Talk Show', 'Cooking', 'Fitness', 'Art', 'Tech', 'Education'].map((category) => (
            <TouchableOpacity
              key={category}
              style={styles.categoryButton}
              onPress={() => setStreamCategory(category)}
            >
              <Text style={styles.categoryButtonText}>{category}</Text>
            </TouchableOpacity>
          ))}
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
  streamControls: {
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
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 15,
  },
  input: {
    borderWidth: 1,
    borderColor: '#e1e8ed',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    color: '#14171a',
    marginBottom: 10,
  },
  streamButton: {
    backgroundColor: '#e0245e',
    borderRadius: 25,
    padding: 15,
    alignItems: 'center',
  },
  streamButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  stopButton: {
    backgroundColor: '#657786',
    borderRadius: 25,
    padding: 15,
    alignItems: 'center',
  },
  stopButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  buttonDisabled: {
    backgroundColor: '#ccc',
  },
  liveStreamsSection: {
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
  streamsList: {
    paddingVertical: 10,
  },
  streamCard: {
    width: width * 0.7,
    marginRight: 15,
    backgroundColor: '#f8f9fa',
    borderRadius: 12,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  streamThumbnail: {
    width: '100%',
    height: 120,
    backgroundColor: '#e1e8ed',
  },
  streamInfo: {
    padding: 12,
  },
  streamTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 4,
  },
  streamerName: {
    fontSize: 12,
    color: '#657786',
    marginBottom: 8,
  },
  streamStats: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 4,
  },
  liveIndicator: {
    backgroundColor: '#e0245e',
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 4,
    marginRight: 8,
  },
  liveText: {
    color: '#fff',
    fontSize: 10,
    fontWeight: 'bold',
  },
  viewersText: {
    fontSize: 12,
    color: '#657786',
  },
  categoryText: {
    fontSize: 12,
    color: '#1da1f2',
    fontWeight: 'bold',
  },
  noStreamsContainer: {
    alignItems: 'center',
    padding: 20,
  },
  noStreamsText: {
    fontSize: 16,
    color: '#657786',
    marginBottom: 5,
  },
  noStreamsSubtext: {
    fontSize: 14,
    color: '#aab8c2',
  },
  tipsContainer: {
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
  tipsTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 15,
  },
  tip: {
    marginBottom: 15,
  },
  tipTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#1da1f2',
    marginBottom: 5,
  },
  tipText: {
    fontSize: 14,
    color: '#657786',
    lineHeight: 20,
  },
  categoriesContainer: {
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
  categoriesTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 15,
  },
  categoryButtons: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  categoryButton: {
    backgroundColor: '#f0f0f0',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 20,
    margin: 4,
  },
  categoryButtonText: {
    fontSize: 12,
    color: '#14171a',
  },
  streamViewContainer: {
    flex: 1,
    backgroundColor: '#000',
  },
  videoContainer: {
    flex: 1,
    backgroundColor: '#000',
  },
  videoPlaceholder: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#1a1a1a',
  },
  videoPlaceholderText: {
    fontSize: 24,
    color: '#fff',
    marginBottom: 10,
  },
  streamTitleText: {
    fontSize: 18,
    color: '#fff',
    fontWeight: 'bold',
    textAlign: 'center',
  },
  streamerText: {
    fontSize: 14,
    color: '#ccc',
    textAlign: 'center',
    marginTop: 5,
  },
  streamHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 15,
    backgroundColor: '#1a1a1a',
  },
  streamDetails: {
    flex: 1,
  },
  streamStatsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 5,
  },
  liveBadge: {
    backgroundColor: '#e0245e',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
    marginRight: 10,
  },
  liveBadgeText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
  },
  viewersCount: {
    color: '#ccc',
    fontSize: 14,
  },
  leaveButton: {
    backgroundColor: '#657786',
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 20,
  },
  leaveButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  chatContainer: {
    height: height * 0.4,
    backgroundColor: '#1a1a1a',
  },
  chatTitle: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#333',
  },
  chatMessages: {
    flex: 1,
    padding: 15,
  },
  chatMessage: {
    flexDirection: 'row',
    marginBottom: 8,
  },
  chatUser: {
    color: '#1da1f2',
    fontSize: 14,
    fontWeight: 'bold',
    marginRight: 8,
  },
  chatText: {
    color: '#fff',
    fontSize: 14,
    flex: 1,
  },
  chatInputContainer: {
    flexDirection: 'row',
    padding: 15,
    borderTopWidth: 1,
    borderTopColor: '#333',
  },
  chatInput: {
    flex: 1,
    backgroundColor: '#333',
    borderRadius: 20,
    paddingHorizontal: 15,
    paddingVertical: 10,
    color: '#fff',
    fontSize: 14,
    marginRight: 10,
  },
  sendButton: {
    width: 40,
    height: 40,
    backgroundColor: '#1da1f2',
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  sendButtonText: {
    fontSize: 16,
  },
});

export default LiveStreaming;