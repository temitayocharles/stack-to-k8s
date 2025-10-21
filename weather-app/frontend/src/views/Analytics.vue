<template>
  <div class="analytics-page">
    <!-- Page Header -->
    <div class="page-header glass-card">
      <div class="header-content">
        <div class="header-title">
          <i class="fas fa-chart-line header-icon"></i>
          <div>
            <h1>Weather Analytics</h1>
            <p>Historical data analysis, trends, and climate insights</p>
          </div>
        </div>
        
        <div class="header-actions">
          <div class="analytics-controls">
            <select v-model="selectedCity" @change="loadAnalytics" class="control-select">
              <option value="London">London</option>
              <option value="New York">New York</option>
              <option value="Tokyo">Tokyo</option>
              <option value="Paris">Paris</option>
              <option value="Sydney">Sydney</option>
            </select>
            
            <select v-model="selectedMetric" @change="loadAnalytics" class="control-select">
              <option value="temperature">Temperature</option>
              <option value="precipitation">Precipitation</option>
              <option value="humidity">Humidity</option>
            </select>
            
            <select v-model="timeRange" @change="loadAnalytics" class="control-select">
              <option value="1">1 Year</option>
              <option value="3">3 Years</option>
              <option value="5">5 Years</option>
              <option value="10">10 Years</option>
            </select>
            
            <button @click="loadAnalytics" :disabled="loading" class="refresh-btn">
              <i class="fas fa-sync-alt" :class="{ 'spinning': loading }"></i>
              Analyze
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading && !analyticsData" class="loading-container">
      <div class="loading-spinner"></div>
      <p>Analyzing historical weather data...</p>
    </div>

    <!-- Analytics Content -->
    <div v-else-if="analyticsData" class="analytics-content">
      <!-- Key Statistics -->
      <div class="key-stats glass-card">
        <h2><i class="fas fa-calculator"></i> Key Statistics</h2>
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-icon">
              <i class="fas fa-chart-line"></i>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ analyticsData.trend_analysis.overall_average }}</div>
              <div class="stat-unit">{{ analyticsData.unit }}</div>
              <div class="stat-label">Average {{ selectedMetric }}</div>
            </div>
          </div>

          <div class="stat-card trend-card" :class="getTrendClass(analyticsData.trend_analysis.overall_trend)">
            <div class="stat-icon">
              <i :class="getTrendIcon(analyticsData.trend_analysis.overall_trend)"></i>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ analyticsData.trend_analysis.overall_trend.toUpperCase() }}</div>
              <div class="stat-label">Overall Trend</div>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-icon">
              <i class="fas fa-thermometer-full"></i>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ analyticsData.trend_analysis.highest_recorded }}</div>
              <div class="stat-unit">{{ analyticsData.unit }}</div>
              <div class="stat-label">Highest Recorded</div>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-icon">
              <i class="fas fa-thermometer-empty"></i>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ analyticsData.trend_analysis.lowest_recorded }}</div>
              <div class="stat-unit">{{ analyticsData.unit }}</div>
              <div class="stat-label">Lowest Recorded</div>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-icon">
              <i class="fas fa-wave-square"></i>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ analyticsData.trend_analysis.variability }}</div>
              <div class="stat-unit">{{ analyticsData.unit }}</div>
              <div class="stat-label">Variability (σ)</div>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-icon">
              <i class="fas fa-calendar-alt"></i>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ analyticsData.trend_analysis.seasonal_variation }}</div>
              <div class="stat-unit">{{ analyticsData.unit }}</div>
              <div class="stat-label">Seasonal Range</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Historical Chart -->
      <div class="historical-chart glass-card">
        <h2><i class="fas fa-chart-area"></i> Historical Trend ({{ timeRange }} Years)</h2>
        <div class="chart-container">
          <canvas ref="historicalChart" width="800" height="400"></canvas>
        </div>
        <div class="chart-controls">
          <button 
            v-for="chartType in chartTypes"
            :key="chartType.type"
            @click="selectedChartType = chartType.type; updateChart()"
            :class="['chart-type-btn', { 'active': selectedChartType === chartType.type }]"
          >
            <i :class="chartType.icon"></i>
            {{ chartType.name }}
          </button>
        </div>
      </div>

      <!-- Monthly Patterns -->
      <div class="monthly-patterns glass-card">
        <h2><i class="fas fa-calendar"></i> Monthly Patterns</h2>
        <div class="monthly-chart-container">
          <canvas ref="monthlyChart" width="800" height="300"></canvas>
        </div>
        
        <div class="monthly-stats">
          <div class="monthly-highlights">
            <div class="highlight-item warmest">
              <i class="fas fa-sun"></i>
              <div>
                <strong>Warmest Month</strong>
                <span>{{ getExtremeMonth('max') }}</span>
              </div>
            </div>
            <div class="highlight-item coolest">
              <i class="fas fa-snowflake"></i>
              <div>
                <strong>Coolest Month</strong>
                <span>{{ getExtremeMonth('min') }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Climate Insights -->
      <div class="climate-insights glass-card">
        <h2><i class="fas fa-lightbulb"></i> Climate Insights</h2>
        <div class="insights-list">
          <div v-for="(insight, index) in analyticsData.climate_insights" :key="index" class="insight-item">
            <div class="insight-icon">
              <i :class="getInsightIcon(index)"></i>
            </div>
            <div class="insight-content">
              <p>{{ insight }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Data Quality Information -->
      <div class="data-quality glass-card">
        <h2><i class="fas fa-database"></i> Data Quality & Sources</h2>
        <div class="quality-grid">
          <div class="quality-item">
            <div class="quality-header">
              <i class="fas fa-check-circle"></i>
              <h3>Data Completeness</h3>
            </div>
            <div class="quality-value">{{ analyticsData.data_quality.completeness }}</div>
            <div class="quality-description">of data points available</div>
          </div>

          <div class="quality-item">
            <div class="quality-header">
              <i class="fas fa-shield-alt"></i>
              <h3>Reliability Score</h3>
            </div>
            <div class="quality-value">{{ analyticsData.data_quality.reliability_score }}</div>
            <div class="quality-description">confidence level</div>
          </div>

          <div class="quality-item">
            <div class="quality-header">
              <i class="fas fa-satellite"></i>
              <h3>Data Sources</h3>
            </div>
            <div class="sources-list">
              <span v-for="source in analyticsData.data_quality.data_sources" :key="source" class="source-tag">
                {{ source }}
              </span>
            </div>
          </div>

          <div class="quality-item">
            <div class="quality-header">
              <i class="fas fa-clock"></i>
              <h3>Last Updated</h3>
            </div>
            <div class="quality-value">{{ formatTimestamp(analyticsData.data_quality.last_updated) }}</div>
            <div class="quality-description">latest data point</div>
          </div>
        </div>
      </div>

      <!-- Comparative Analysis -->
      <div class="comparative-analysis glass-card">
        <h2><i class="fas fa-balance-scale"></i> Comparative Analysis</h2>
        <div class="comparison-content">
          <div class="comparison-item">
            <h3>vs. Global Average</h3>
            <div class="comparison-bar">
              <div class="bar-fill" :style="{ width: '75%' }"></div>
              <span class="bar-value">+2.3°C above global average</span>
            </div>
          </div>

          <div class="comparison-item">
            <h3>vs. Regional Average</h3>
            <div class="comparison-bar">
              <div class="bar-fill" :style="{ width: '60%' }"></div>
              <span class="bar-value">+1.1°C above regional average</span>
            </div>
          </div>

          <div class="comparison-item">
            <h3>Climate Change Impact</h3>
            <div class="comparison-bar">
              <div class="bar-fill warning" :style="{ width: '85%' }"></div>
              <span class="bar-value">+1.8°C since 1950</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Download and Export -->
      <div class="export-options glass-card">
        <h2><i class="fas fa-download"></i> Export Data</h2>
        <div class="export-buttons">
          <button @click="exportData('csv')" class="export-btn csv">
            <i class="fas fa-file-csv"></i>
            Export CSV
          </button>
          <button @click="exportData('json')" class="export-btn json">
            <i class="fas fa-file-code"></i>
            Export JSON
          </button>
          <button @click="exportData('pdf')" class="export-btn pdf">
            <i class="fas fa-file-pdf"></i>
            Export Report
          </button>
          <button @click="exportChart()" class="export-btn chart">
            <i class="fas fa-image"></i>
            Save Chart
          </button>
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-container glass-card">
      <i class="fas fa-exclamation-circle error-icon"></i>
      <h3>Failed to Load Analytics Data</h3>
      <p>{{ error }}</p>
      <button @click="loadAnalytics" class="retry-btn">
        <i class="fas fa-redo"></i>
        Try Again
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import Chart from 'chart.js/auto'

// Reactive data
const loading = ref(false)
const error = ref('')
const analyticsData = ref(null)
const selectedCity = ref('London')
const selectedMetric = ref('temperature')
const timeRange = ref('5')
const selectedChartType = ref('line')
const historicalChart = ref(null)
const monthlyChart = ref(null)
let historicalChartInstance = null
let monthlyChartInstance = null

// Chart types
const chartTypes = [
  { type: 'line', name: 'Line', icon: 'fas fa-chart-line' },
  { type: 'area', name: 'Area', icon: 'fas fa-chart-area' },
  { type: 'bar', name: 'Bar', icon: 'fas fa-chart-bar' }
]

// Methods
const loadAnalytics = async () => {
  loading.value = true
  error.value = ''
  
  try {
    const response = await fetch(
      `/api/weather/historical-analysis?city=${selectedCity.value}&metric=${selectedMetric.value}&years=${timeRange.value}`
    )
    const data = await response.json()
    
    if (data.success) {
      analyticsData.value = data.data
      await nextTick()
      createCharts()
    } else {
      error.value = data.error || 'Failed to load analytics data'
    }
  } catch (err) {
    error.value = 'Network error occurred'
    console.error('Analytics error:', err)
  } finally {
    loading.value = false
  }
}

const createCharts = () => {
  createHistoricalChart()
  createMonthlyChart()
}

const createHistoricalChart = () => {
  if (!historicalChart.value || !analyticsData.value) return
  
  if (historicalChartInstance) {
    historicalChartInstance.destroy()
  }
  
  const ctx = historicalChart.value.getContext('2d')
  const data = analyticsData.value.historical_data
  
  const chartData = {
    labels: data.map(d => `${d.year}-${String(d.month).padStart(2, '0')}`),
    datasets: [{
      label: `${selectedMetric.value} (${analyticsData.value.unit})`,
      data: data.map(d => d.value),
      borderColor: '#10B981',
      backgroundColor: selectedChartType.value === 'area' ? 'rgba(16, 185, 129, 0.1)' : 'rgba(16, 185, 129, 0.8)',
      borderWidth: 2,
      tension: 0.4,
      fill: selectedChartType.value === 'area'
    }]
  }
  
  historicalChartInstance = new Chart(ctx, {
    type: selectedChartType.value === 'area' ? 'line' : selectedChartType.value,
    data: chartData,
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: true,
          position: 'top'
        },
        tooltip: {
          mode: 'index',
          intersect: false
        }
      },
      scales: {
        x: {
          display: true,
          title: {
            display: true,
            text: 'Date'
          }
        },
        y: {
          display: true,
          title: {
            display: true,
            text: `${selectedMetric.value} (${analyticsData.value.unit})`
          }
        }
      }
    }
  })
}

const createMonthlyChart = () => {
  if (!monthlyChart.value || !analyticsData.value) return
  
  if (monthlyChartInstance) {
    monthlyChartInstance.destroy()
  }
  
  const ctx = monthlyChart.value.getContext('2d')
  const monthlyData = analyticsData.value.monthly_averages
  
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
  
  monthlyChartInstance = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: months,
      datasets: [
        {
          label: 'Average',
          data: monthlyData.map(d => d.average),
          backgroundColor: 'rgba(16, 185, 129, 0.8)',
          borderColor: '#10B981',
          borderWidth: 1
        },
        {
          label: 'Max',
          data: monthlyData.map(d => d.max),
          backgroundColor: 'rgba(239, 68, 68, 0.6)',
          borderColor: '#EF4444',
          borderWidth: 1
        },
        {
          label: 'Min',
          data: monthlyData.map(d => d.min),
          backgroundColor: 'rgba(59, 130, 246, 0.6)',
          borderColor: '#3B82F6',
          borderWidth: 1
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: true,
          position: 'top'
        }
      },
      scales: {
        x: {
          display: true,
          title: {
            display: true,
            text: 'Month'
          }
        },
        y: {
          display: true,
          title: {
            display: true,
            text: `${selectedMetric.value} (${analyticsData.value.unit})`
          }
        }
      }
    }
  })
}

const updateChart = () => {
  createHistoricalChart()
}

const formatTimestamp = (timestamp) => {
  return new Date(timestamp).toLocaleString()
}

const getTrendClass = (trend) => {
  if (trend === 'increasing') return 'trend-up'
  if (trend === 'decreasing') return 'trend-down'
  return 'trend-stable'
}

const getTrendIcon = (trend) => {
  if (trend === 'increasing') return 'fas fa-arrow-up'
  if (trend === 'decreasing') return 'fas fa-arrow-down'
  return 'fas fa-arrows-alt-h'
}

const getExtremeMonth = (type) => {
  if (!analyticsData.value) return ''
  
  const monthlyData = analyticsData.value.monthly_averages
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
  
  let extremeMonth
  if (type === 'max') {
    extremeMonth = monthlyData.reduce((max, current) => current.average > max.average ? current : max)
  } else {
    extremeMonth = monthlyData.reduce((min, current) => current.average < min.average ? current : min)
  }
  
  return `${months[extremeMonth.month - 1]} (${extremeMonth.average}${analyticsData.value.unit})`
}

const getInsightIcon = (index) => {
  const icons = ['fas fa-chart-line', 'fas fa-calendar-alt', 'fas fa-globe']
  return icons[index % icons.length]
}

const exportData = (format) => {
  if (!analyticsData.value) return
  
  let content
  let filename
  
  switch (format) {
    case 'csv':
      content = convertToCSV(analyticsData.value.historical_data)
      filename = `weather-analytics-${selectedCity.value}-${selectedMetric.value}.csv`
      downloadFile(content, filename, 'text/csv')
      break
      
    case 'json':
      content = JSON.stringify(analyticsData.value, null, 2)
      filename = `weather-analytics-${selectedCity.value}-${selectedMetric.value}.json`
      downloadFile(content, filename, 'application/json')
      break
      
    case 'pdf':
      // In a real app, this would generate a PDF report
      alert('PDF export feature would be implemented with a PDF library like jsPDF')
      break
  }
}

const exportChart = () => {
  if (!historicalChartInstance) return
  
  const url = historicalChartInstance.toBase64Image()
  const link = document.createElement('a')
  link.download = `weather-chart-${selectedCity.value}-${selectedMetric.value}.png`
  link.href = url
  link.click()
}

const convertToCSV = (data) => {
  const headers = ['Year', 'Month', 'Value', 'Date']
  const csvContent = [
    headers.join(','),
    ...data.map(row => [row.year, row.month, row.value, row.date].join(','))
  ].join('\n')
  
  return csvContent
}

const downloadFile = (content, filename, mimeType) => {
  const blob = new Blob([content], { type: mimeType })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  link.click()
  URL.revokeObjectURL(url)
}

// Initialize
onMounted(() => {
  loadAnalytics()
})
</script>

<style scoped>
.analytics-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.page-header {
  padding: 2rem;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
}

.header-title {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.header-icon {
  font-size: 2.5rem;
  color: var(--accent-color);
}

.header-title h1 {
  margin: 0;
  font-size: 2rem;
  color: var(--text-primary);
}

.header-title p {
  margin: 0.5rem 0 0 0;
  color: var(--text-secondary);
}

.analytics-controls {
  display: flex;
  gap: 1rem;
  align-items: center;
  flex-wrap: wrap;
}

.control-select {
  padding: 0.75rem 1rem;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  background: rgba(255, 255, 255, 0.1);
  color: var(--text-primary);
  backdrop-filter: blur(10px);
}

.refresh-btn {
  padding: 0.75rem 1.5rem;
  background: var(--accent-color);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
}

.refresh-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(var(--accent-color-rgb), 0.3);
}

.spinning {
  animation: spin 1s linear infinite;
}

.loading-container {
  text-align: center;
  padding: 4rem;
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 4px solid rgba(255, 255, 255, 0.1);
  border-top: 4px solid var(--accent-color);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem;
}

.analytics-content {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.key-stats {
  padding: 2rem;
}

.key-stats h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  color: var(--text-primary);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.stat-card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  transition: transform 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
}

.stat-card.trend-card.trend-up {
  border-color: #10B981;
  background: rgba(16, 185, 129, 0.1);
}

.stat-card.trend-card.trend-down {
  border-color: #EF4444;
  background: rgba(239, 68, 68, 0.1);
}

.stat-card.trend-card.trend-stable {
  border-color: #F59E0B;
  background: rgba(245, 158, 11, 0.1);
}

.stat-icon i {
  font-size: 2rem;
  color: var(--accent-color);
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--text-primary);
  display: flex;
  align-items: baseline;
  gap: 0.25rem;
}

.stat-unit {
  font-size: 0.9rem;
  color: var(--text-secondary);
}

.stat-label {
  color: var(--text-secondary);
  font-size: 0.9rem;
  margin-top: 0.25rem;
}

.historical-chart {
  padding: 2rem;
}

.historical-chart h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  color: var(--text-primary);
}

.chart-container {
  height: 400px;
  margin-bottom: 1rem;
}

.chart-controls {
  display: flex;
  gap: 0.5rem;
  justify-content: center;
  flex-wrap: wrap;
}

.chart-type-btn {
  padding: 0.5rem 1rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 6px;
  color: var(--text-secondary);
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
  font-size: 0.9rem;
}

.chart-type-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  color: var(--text-primary);
}

.chart-type-btn.active {
  background: var(--accent-color);
  color: white;
  border-color: var(--accent-color);
}

.monthly-patterns {
  padding: 2rem;
}

.monthly-patterns h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  color: var(--text-primary);
}

.monthly-chart-container {
  height: 300px;
  margin-bottom: 1.5rem;
}

.monthly-highlights {
  display: flex;
  gap: 2rem;
  justify-content: center;
  flex-wrap: wrap;
}

.highlight-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.highlight-item.warmest {
  background: rgba(245, 158, 11, 0.1);
  border-color: #F59E0B;
}

.highlight-item.coolest {
  background: rgba(59, 130, 246, 0.1);
  border-color: #3B82F6;
}

.highlight-item i {
  font-size: 1.5rem;
  color: var(--accent-color);
}

.highlight-item strong {
  display: block;
  color: var(--text-primary);
  margin-bottom: 0.25rem;
}

.highlight-item span {
  color: var(--text-secondary);
}

.climate-insights {
  padding: 2rem;
}

.climate-insights h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  color: var(--text-primary);
}

.insights-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.insight-item {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  border-left: 4px solid var(--accent-color);
}

.insight-icon i {
  font-size: 1.5rem;
  color: var(--accent-color);
  margin-top: 0.25rem;
}

.insight-content p {
  margin: 0;
  color: var(--text-secondary);
  line-height: 1.6;
}

.data-quality {
  padding: 2rem;
}

.data-quality h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  color: var(--text-primary);
}

.quality-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}

.quality-item {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  padding: 1.5rem;
  text-align: center;
}

.quality-header {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.quality-header i {
  color: var(--accent-color);
}

.quality-header h3 {
  margin: 0;
  color: var(--text-primary);
}

.quality-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--accent-color);
  margin-bottom: 0.5rem;
}

.quality-description {
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.sources-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  justify-content: center;
}

.source-tag {
  background: rgba(255, 255, 255, 0.1);
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  color: var(--text-secondary);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.comparative-analysis {
  padding: 2rem;
}

.comparative-analysis h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  color: var(--text-primary);
}

.comparison-content {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.comparison-item h3 {
  margin: 0 0 0.5rem 0;
  color: var(--text-primary);
}

.comparison-bar {
  background: rgba(255, 255, 255, 0.1);
  height: 40px;
  border-radius: 20px;
  position: relative;
  overflow: hidden;
}

.bar-fill {
  background: linear-gradient(90deg, var(--accent-color), rgba(var(--accent-color-rgb), 0.7));
  height: 100%;
  border-radius: 20px;
  transition: width 0.3s ease;
}

.bar-fill.warning {
  background: linear-gradient(90deg, #F59E0B, #FCD34D);
}

.bar-value {
  position: absolute;
  right: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: white;
  font-weight: 600;
  font-size: 0.9rem;
}

.export-options {
  padding: 2rem;
}

.export-options h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  color: var(--text-primary);
}

.export-buttons {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.export-btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  transition: all 0.3s ease;
}

.export-btn:hover {
  transform: translateY(-2px);
}

.export-btn.csv {
  background: #10B981;
  color: white;
}

.export-btn.json {
  background: #3B82F6;
  color: white;
}

.export-btn.pdf {
  background: #EF4444;
  color: white;
}

.export-btn.chart {
  background: #8B5CF6;
  color: white;
}

.error-container {
  text-align: center;
  padding: 3rem;
}

.error-icon {
  font-size: 3rem;
  color: #EF4444;
  margin-bottom: 1rem;
}

.retry-btn {
  background: var(--accent-color);
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  margin-top: 1rem;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

@media (max-width: 768px) {
  .header-content {
    flex-direction: column;
    align-items: stretch;
  }

  .analytics-controls {
    flex-direction: column;
    gap: 0.5rem;
  }

  .stats-grid {
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  }

  .stat-card {
    flex-direction: column;
    text-align: center;
  }

  .chart-controls {
    flex-direction: column;
    align-items: center;
  }

  .monthly-highlights {
    flex-direction: column;
    align-items: center;
  }

  .quality-grid {
    grid-template-columns: 1fr;
  }

  .export-buttons {
    flex-direction: column;
  }
}
</style>