import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, Dimensions, RefreshControl } from 'react-native';
import { LineChart, BarChart, PieChart, ProgressChart } from 'react-native-chart-kit';

const { width } = Dimensions.get('window');

interface AnalyticsData {
  platform_stats: {
    total_posts: number;
    total_users: number;
    active_users: number;
    trending_posts_count: number;
  };
  trending_posts: Array<{
    id: string;
    engagement_score: number;
    timestamp: number;
  }>;
  engagement_metrics: Array<{
    post_id: string;
    engagement_score: number;
    likes: number;
    comments: number;
    shares: number;
    timestamp: number;
  }>;
  generated_at: string;
}

interface SentimentData {
  positive: number;
  negative: number;
  neutral: number;
}

const AnalyticsDashboard: React.FC = () => {
  const [analyticsData, setAnalyticsData] = useState<AnalyticsData | null>(null);
  const [sentimentData, setSentimentData] = useState<SentimentData>({ positive: 0, negative: 0, neutral: 0 });
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const fetchAnalytics = async () => {
    try {
      const response = await fetch('http://localhost:3000/api/analytics/posts');
      const data = await response.json();
      setAnalyticsData(data);
    } catch (error) {
      console.error('Failed to fetch analytics:', error);
    }
  };

  const fetchSentimentData = async () => {
    // Mock sentiment data - in real app, this would come from the API
    setSentimentData({
      positive: 65,
      negative: 15,
      neutral: 20
    });
  };

  const loadData = async () => {
    setLoading(true);
    await Promise.all([fetchAnalytics(), fetchSentimentData()]);
    setLoading(false);
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  useEffect(() => {
    loadData();
  }, []);

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <Text style={styles.loadingText}>Loading Analytics...</Text>
      </View>
    );
  }

  const chartConfig = {
    backgroundColor: '#ffffff',
    backgroundGradientFrom: '#ffffff',
    backgroundGradientTo: '#ffffff',
    decimalPlaces: 0,
    color: (opacity = 1) => `rgba(29, 161, 242, ${opacity})`,
    labelColor: (opacity = 1) => `rgba(0, 0, 0, ${opacity})`,
    style: {
      borderRadius: 16,
    },
    propsForDots: {
      r: '6',
      strokeWidth: '2',
      stroke: '#1da1f2',
    },
  };

  const engagementData = analyticsData?.engagement_metrics.slice(0, 7).map((metric, index) => ({
    name: `Post ${index + 1}`,
    engagement: metric.engagement_score,
    likes: metric.likes,
    comments: metric.comments,
  })) || [];

  const sentimentChartData = [
    {
      name: 'Positive',
      population: sentimentData.positive,
      color: '#4CAF50',
      legendFontColor: '#7F7F7F',
      legendFontSize: 12,
    },
    {
      name: 'Neutral',
      population: sentimentData.neutral,
      color: '#FFC107',
      legendFontColor: '#7F7F7F',
      legendFontSize: 12,
    },
    {
      name: 'Negative',
      population: sentimentData.negative,
      color: '#F44336',
      legendFontColor: '#7F7F7F',
      legendFontSize: 12,
    },
  ];

  return (
    <ScrollView
      style={styles.container}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
      }
    >
      <View style={styles.header}>
        <Text style={styles.title}>📊 Analytics Dashboard</Text>
        <Text style={styles.subtitle}>
          Last updated: {analyticsData?.generated_at ? new Date(analyticsData.generated_at).toLocaleString() : 'N/A'}
        </Text>
      </View>

      {/* Platform Stats Cards */}
      <View style={styles.statsContainer}>
        <View style={styles.statCard}>
          <Text style={styles.statNumber}>{analyticsData?.platform_stats.total_users.toLocaleString() || 0}</Text>
          <Text style={styles.statLabel}>Total Users</Text>
        </View>
        <View style={styles.statCard}>
          <Text style={styles.statNumber}>{analyticsData?.platform_stats.total_posts.toLocaleString() || 0}</Text>
          <Text style={styles.statLabel}>Total Posts</Text>
        </View>
        <View style={styles.statCard}>
          <Text style={styles.statNumber}>{analyticsData?.platform_stats.active_users || 0}</Text>
          <Text style={styles.statLabel}>Active Users</Text>
        </View>
        <View style={styles.statCard}>
          <Text style={styles.statNumber}>{analyticsData?.platform_stats.trending_posts_count || 0}</Text>
          <Text style={styles.statLabel}>Trending Posts</Text>
        </View>
      </View>

      {/* Sentiment Analysis Chart */}
      <View style={styles.chartContainer}>
        <Text style={styles.chartTitle}>😊 Sentiment Analysis</Text>
        <PieChart
          data={sentimentChartData}
          width={width - 40}
          height={200}
          chartConfig={chartConfig}
          accessor="population"
          backgroundColor="transparent"
          paddingLeft="15"
          absolute
        />
      </View>

      {/* Engagement Metrics Chart */}
      {engagementData.length > 0 && (
        <View style={styles.chartContainer}>
          <Text style={styles.chartTitle}>📈 Post Engagement</Text>
          <BarChart
            data={{
              labels: engagementData.map(d => d.name),
              datasets: [{
                data: engagementData.map(d => d.engagement)
              }]
            }}
            width={width - 40}
            height={220}
            chartConfig={{
              ...chartConfig,
              color: (opacity = 1) => `rgba(255, 99, 132, ${opacity})`,
            }}
            verticalLabelRotation={30}
          />
        </View>
      )}

      {/* AI Insights */}
      <View style={styles.insightsContainer}>
        <Text style={styles.sectionTitle}>🤖 AI Insights</Text>

        <View style={styles.insightCard}>
          <Text style={styles.insightTitle}>Content Moderation</Text>
          <Text style={styles.insightText}>
            AI has processed and moderated {analyticsData?.platform_stats.total_posts || 0} posts,
            ensuring a safe and positive community environment.
          </Text>
        </View>

        <View style={styles.insightCard}>
          <Text style={styles.insightTitle}>Recommendation Engine</Text>
          <Text style={styles.insightText}>
            Personalized recommendations are being generated for users based on their
            interaction patterns and content preferences.
          </Text>
        </View>

        <View style={styles.insightCard}>
          <Text style={styles.insightTitle}>Sentiment Trends</Text>
          <Text style={styles.insightText}>
            {sentimentData.positive}% of content shows positive sentiment,
            indicating a healthy and engaging community atmosphere.
          </Text>
        </View>
      </View>

      {/* Trending Posts */}
      {analyticsData?.trending_posts && analyticsData.trending_posts.length > 0 && (
        <View style={styles.trendingContainer}>
          <Text style={styles.sectionTitle}>🔥 Trending Posts</Text>
          {analyticsData.trending_posts.slice(0, 5).map((post, index) => (
            <View key={post.id} style={styles.trendingItem}>
              <Text style={styles.trendingRank}>#{index + 1}</Text>
              <View style={styles.trendingContent}>
                <Text style={styles.trendingText}>Post ID: {post.id}</Text>
                <Text style={styles.trendingScore}>
                  Engagement: {post.engagement_score.toFixed(1)}
                </Text>
              </View>
            </View>
          ))}
        </View>
      )}
    </ScrollView>
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
    fontSize: 18,
    color: '#666',
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
  statsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    padding: 10,
  },
  statCard: {
    backgroundColor: '#fff',
    borderRadius: 8,
    padding: 15,
    margin: 5,
    width: (width - 40) / 2,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  statNumber: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1da1f2',
    marginBottom: 5,
  },
  statLabel: {
    fontSize: 14,
    color: '#657786',
    textAlign: 'center',
  },
  chartContainer: {
    backgroundColor: '#fff',
    margin: 10,
    borderRadius: 8,
    padding: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  chartTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 15,
    textAlign: 'center',
  },
  insightsContainer: {
    backgroundColor: '#fff',
    margin: 10,
    borderRadius: 8,
    padding: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#14171a',
    marginBottom: 15,
  },
  insightCard: {
    backgroundColor: '#f8f9fa',
    borderRadius: 6,
    padding: 12,
    marginBottom: 10,
  },
  insightTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#1da1f2',
    marginBottom: 5,
  },
  insightText: {
    fontSize: 14,
    color: '#657786',
    lineHeight: 20,
  },
  trendingContainer: {
    backgroundColor: '#fff',
    margin: 10,
    borderRadius: 8,
    padding: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  trendingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#e1e8ed',
  },
  trendingRank: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1da1f2',
    width: 30,
  },
  trendingContent: {
    flex: 1,
  },
  trendingText: {
    fontSize: 14,
    color: '#14171a',
  },
  trendingScore: {
    fontSize: 12,
    color: '#657786',
    marginTop: 2,
  },
});

export default AnalyticsDashboard;