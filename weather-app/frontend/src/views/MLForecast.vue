<template>
  <div class="ml-forecast-page">
    <!-- Page Header -->
    <div class="page-header glass-card">
      <div class="header-content">
        <div class="header-title">
          <i class="fas fa-brain header-icon"></i>
          <div>
            <h1>ML Weather Forecast</h1>
            <p>Advanced machine learning weather predictions with confidence intervals</p>
          </div>
        </div>
        
        <div class="header-actions">
          <div class="forecast-controls">
            <select v-model="selectedCity" @change="loadMLForecast" class="control-select">
              <option value="London">London</option>
              <option value="New York">New York</option>
              <option value="Tokyo">Tokyo</option>
              <option value="Paris">Paris</option>
              <option value="Sydney">Sydney</option>
            </select>
            
            <select v-model="forecastDays" @change="loadMLForecast" class="control-select">
              <option value="3">3 Days</option>
              <option value="7">7 Days</option>
              <option value="14">14 Days</option>
              <option value="30">30 Days</option>
            </select>
            
            <button @click="loadMLForecast" :disabled="loading" class="refresh-btn">
              <i class="fas fa-sync-alt" :class="{ 'spinning': loading }"></i>
              Refresh
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading && !mlForecast" class="loading-container">
      <div class="loading-spinner"></div>
      <p>Generating ML forecasts...</p>
    </div>

    <!-- ML Forecast Content -->
    <div v-else-if="mlForecast" class="forecast-content">
      <!-- Model Performance Overview -->
      <div class="model-overview glass-card">
        <h2><i class="fas fa-cogs"></i> Model Performance</h2>
        <div class="model-metrics">
          <div class="metric-card">
            <div class="metric-value">{{ mlForecast.model_info.accuracy_metrics.r2_score }}</div>
            <div class="metric-label">R² Score</div>
          </div>
          <div class="metric-card">
            <div class="metric-value">{{ mlForecast.model_info.accuracy_metrics.mae }}°</div>
            <div class="metric-label">Mean Absolute Error</div>
          </div>
          <div class="metric-card">
            <div class="metric-value">{{ mlForecast.model_info.training_data_period }}</div>
            <div class="metric-label">Training Period</div>
          </div>
          <div class="metric-card">
            <div class="metric-value">{{ mlForecast.model_info.algorithms_used.length }}</div>
            <div class="metric-label">ML Models</div>
          </div>
        </div>
      </div>

      <!-- Algorithm Comparison -->
      <div class="algorithm-comparison glass-card">
        <h2><i class="fas fa-chart-bar"></i> Algorithm Performance Comparison</h2>
        <div class="algorithm-tabs">
          <button 
            v-for="algorithm in algorithms"
            :key="algorithm.key"
            @click="selectedAlgorithm = algorithm.key"
            :class="['algorithm-tab', { 'active': selectedAlgorithm === algorithm.key }]"
          >
            <i :class="algorithm.icon"></i>
            {{ algorithm.name }}
          </button>
        </div>
        
        <div class="forecast-chart">
          <canvas ref="forecastChart" width="800" height="300"></canvas>
        </div>
      </div>

      <!-- Detailed Forecast Cards -->
      <div class="forecast-cards">
        <div 
          v-for="(day, index) in mlForecast.ml_forecast" 
          :key="day.date"
          class="forecast-card glass-card"
          :class="{ 'featured': index === 0 }"
        >
          <div class="forecast-header">
            <div class="forecast-date">
              <div class="day">{{ formatDate(day.date).day }}</div>
              <div class="date">{{ formatDate(day.date).date }}</div>
            </div>
            <div class="weather-icon">
              <i :class="getWeatherIcon(day.predictions.ensemble.temperature)"></i>
            </div>
          </div>

          <div class="forecast-details">
            <!-- Ensemble Prediction (Recommended) -->
            <div class="prediction-section recommended">
              <div class="prediction-header">
                <h4><i class="fas fa-star"></i> Ensemble Model</h4>
                <div class="confidence-bar">
                  <div 
                    class="confidence-fill" 
                    :style="{ width: (day.predictions.ensemble.confidence * 100) + '%' }"
                  ></div>
                  <span class="confidence-text">{{ Math.round(day.predictions.ensemble.confidence * 100) }}%</span>
                </div>
              </div>
              <div class="prediction-values">
                <div class="temp-value">{{ day.predictions.ensemble.temperature }}°C</div>
                <div class="humidity-value">{{ day.predictions.ensemble.humidity }}% humidity</div>
              </div>
            </div>

            <!-- Individual Model Predictions -->
            <div class="individual-predictions">
              <div class="prediction-item">
                <span class="model-name">Linear Regression</span>
                <span class="temp">{{ day.predictions.linear_regression.temperature }}°C</span>
                <span class="confidence">{{ Math.round(day.predictions.linear_regression.confidence * 100) }}%</span>
              </div>
              <div class="prediction-item">
                <span class="model-name">Neural Network</span>
                <span class="temp">{{ day.predictions.neural_network.temperature }}°C</span>
                <span class="confidence">{{ Math.round(day.predictions.neural_network.confidence * 100) }}%</span>
              </div>
            </div>

            <!-- Weather Patterns -->
            <div class="weather-patterns">
              <div class="pattern-item">
                <i class="fas fa-tachometer-alt"></i>
                <span>Pressure: {{ day.weather_patterns.pressure_trend }}</span>
              </div>
              <div class="pattern-item">
                <i class="fas fa-wind"></i>
                <span>Wind: {{ day.weather_patterns.wind_pattern }}</span>
              </div>
              <div class="pattern-item">
                <i class="fas fa-cloud-rain"></i>
                <span>Rain: {{ Math.round(day.weather_patterns.precipitation_probability * 100) }}%</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Technical Details -->
      <div class="technical-details glass-card">
        <h2><i class="fas fa-microchip"></i> Technical Information</h2>
        <div class="tech-grid">
          <div class="tech-item">
            <h4>Algorithms Used</h4>
            <ul>
              <li v-for="algorithm in mlForecast.model_info.algorithms_used" :key="algorithm">
                {{ algorithm }}
              </li>
            </ul>
          </div>
          <div class="tech-item">
            <h4>Performance Metrics</h4>
            <div class="metrics-list">
              <div class="metric-row">
                <span>Mean Squared Error:</span>
                <span>{{ mlForecast.model_info.accuracy_metrics.mse }}</span>
              </div>
              <div class="metric-row">
                <span>R² Score:</span>
                <span>{{ mlForecast.model_info.accuracy_metrics.r2_score }}</span>
              </div>
              <div class="metric-row">
                <span>Mean Absolute Error:</span>
                <span>{{ mlForecast.model_info.accuracy_metrics.mae }}°C</span>
              </div>
            </div>
          </div>
          <div class="tech-item">
            <h4>Data Sources</h4>
            <p>Training data span: {{ mlForecast.model_info.training_data_period }}</p>
            <p>Last model update: {{ formatTimestamp(mlForecast.model_info.last_updated) }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-container glass-card">
      <i class="fas fa-exclamation-circle error-icon"></i>
      <h3>Failed to Load ML Forecast</h3>
      <p>{{ error }}</p>
      <button @click="loadMLForecast" class="retry-btn">
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
const mlForecast = ref(null)
const selectedCity = ref('London')
const forecastDays = ref(7)
const selectedAlgorithm = ref('ensemble')
const forecastChart = ref(null)
let chartInstance = null

// Algorithm configuration
const algorithms = [
  { key: 'ensemble', name: 'Ensemble', icon: 'fas fa-star' },
  { key: 'linear_regression', name: 'Linear Regression', icon: 'fas fa-chart-line' },
  { key: 'neural_network', name: 'Neural Network', icon: 'fas fa-brain' }
]

// Methods
const loadMLForecast = async () => {
  loading.value = true
  error.value = ''
  
  try {
    const response = await fetch(`/api/weather/ml-forecast?city=${selectedCity.value}&days=${forecastDays.value}`)
    const data = await response.json()
    
    if (data.success) {
      mlForecast.value = data.data
      await nextTick()
      createForecastChart()
    } else {
      error.value = data.error || 'Failed to load ML forecast'
    }
  } catch (err) {
    error.value = 'Network error occurred'
    console.error('ML Forecast error:', err)
  } finally {
    loading.value = false
  }
}

const createForecastChart = () => {
  if (!forecastChart.value || !mlForecast.value) return
  
  if (chartInstance) {
    chartInstance.destroy()
  }
  
  const ctx = forecastChart.value.getContext('2d')
  const dates = mlForecast.value.ml_forecast.map(d => formatDate(d.date).short)
  
  const datasets = []
  
  // Add datasets based on selected algorithm
  if (selectedAlgorithm.value === 'ensemble' || selectedAlgorithm.value === 'all') {
    datasets.push({
      label: 'Ensemble Model',
      data: mlForecast.value.ml_forecast.map(d => d.predictions.ensemble.temperature),
      borderColor: '#10B981',
      backgroundColor: 'rgba(16, 185, 129, 0.1)',
      borderWidth: 3,
      tension: 0.4,
      fill: true
    })
  }
  
  if (selectedAlgorithm.value === 'linear_regression' || selectedAlgorithm.value === 'all') {
    datasets.push({
      label: 'Linear Regression',
      data: mlForecast.value.ml_forecast.map(d => d.predictions.linear_regression.temperature),
      borderColor: '#3B82F6',
      backgroundColor: 'rgba(59, 130, 246, 0.1)',
      borderWidth: 2,
      tension: 0.4
    })
  }
  
  if (selectedAlgorithm.value === 'neural_network' || selectedAlgorithm.value === 'all') {
    datasets.push({
      label: 'Neural Network',
      data: mlForecast.value.ml_forecast.map(d => d.predictions.neural_network.temperature),
      borderColor: '#8B5CF6',
      backgroundColor: 'rgba(139, 92, 246, 0.1)',
      borderWidth: 2,
      tension: 0.4
    })
  }
  
  chartInstance = new Chart(ctx, {
    type: 'line',
    data: {
      labels: dates,
      datasets: datasets
    },
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
            text: 'Temperature (°C)'
          }
        }
      }
    }
  })
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
  
  return {
    day: days[date.getDay()],
    date: `${months[date.getMonth()]} ${date.getDate()}`,
    short: `${date.getMonth() + 1}/${date.getDate()}`
  }
}

const formatTimestamp = (timestamp) => {
  return new Date(timestamp).toLocaleString()
}

const getWeatherIcon = (temperature) => {
  if (temperature > 25) return 'fas fa-sun'
  if (temperature > 15) return 'fas fa-cloud-sun'
  if (temperature > 5) return 'fas fa-cloud'
  return 'fas fa-snowflake'
}

// Initialize
onMounted(() => {
  loadMLForecast()
})
</script>

<style scoped>
.ml-forecast-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
  space-y: 2rem;
}

.page-header {
  padding: 2rem;
  margin-bottom: 2rem;
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

.forecast-controls {
  display: flex;
  gap: 1rem;
  align-items: center;
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

.refresh-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
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

.forecast-content {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.model-overview {
  padding: 2rem;
}

.model-overview h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  color: var(--text-primary);
}

.model-metrics {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.metric-card {
  background: rgba(255, 255, 255, 0.05);
  padding: 1.5rem;
  border-radius: 12px;
  text-align: center;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.metric-value {
  font-size: 2rem;
  font-weight: 700;
  color: var(--accent-color);
  margin-bottom: 0.5rem;
}

.metric-label {
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.algorithm-comparison {
  padding: 2rem;
}

.algorithm-comparison h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  color: var(--text-primary);
}

.algorithm-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.algorithm-tab {
  padding: 0.75rem 1.5rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  color: var(--text-secondary);
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
}

.algorithm-tab:hover {
  background: rgba(255, 255, 255, 0.1);
  color: var(--text-primary);
}

.algorithm-tab.active {
  background: var(--accent-color);
  color: white;
  border-color: var(--accent-color);
}

.forecast-chart {
  height: 300px;
  margin-top: 1rem;
}

.forecast-cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 1.5rem;
}

.forecast-card {
  padding: 1.5rem;
  transition: transform 0.3s ease;
}

.forecast-card:hover {
  transform: translateY(-2px);
}

.forecast-card.featured {
  border: 2px solid var(--accent-color);
  box-shadow: 0 4px 20px rgba(var(--accent-color-rgb), 0.2);
}

.forecast-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.forecast-date .day {
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--text-primary);
}

.forecast-date .date {
  font-size: 0.9rem;
  color: var(--text-secondary);
}

.weather-icon i {
  font-size: 2rem;
  color: var(--accent-color);
}

.prediction-section.recommended {
  background: rgba(16, 185, 129, 0.1);
  border: 1px solid rgba(16, 185, 129, 0.3);
  border-radius: 8px;
  padding: 1rem;
  margin-bottom: 1rem;
}

.prediction-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.prediction-header h4 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin: 0;
  color: var(--text-primary);
}

.confidence-bar {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  height: 8px;
  width: 80px;
  position: relative;
  overflow: hidden;
}

.confidence-fill {
  background: var(--accent-color);
  height: 100%;
  border-radius: 10px;
  transition: width 0.3s ease;
}

.confidence-text {
  position: absolute;
  right: -35px;
  top: -12px;
  font-size: 0.8rem;
  color: var(--text-secondary);
}

.prediction-values {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.temp-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--accent-color);
}

.humidity-value {
  color: var(--text-secondary);
}

.individual-predictions {
  margin-bottom: 1rem;
}

.prediction-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.model-name {
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.temp {
  color: var(--text-primary);
  font-weight: 600;
}

.confidence {
  color: var(--accent-color);
  font-size: 0.8rem;
}

.weather-patterns {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.pattern-item {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.8rem;
  color: var(--text-secondary);
}

.technical-details {
  padding: 2rem;
}

.technical-details h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  color: var(--text-primary);
}

.tech-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
}

.tech-item h4 {
  color: var(--text-primary);
  margin-bottom: 1rem;
}

.tech-item ul {
  list-style: none;
  padding: 0;
}

.tech-item li {
  color: var(--text-secondary);
  padding: 0.25rem 0;
}

.metrics-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.metric-row {
  display: flex;
  justify-content: space-between;
  color: var(--text-secondary);
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

  .forecast-controls {
    flex-direction: column;
    gap: 0.5rem;
  }

  .algorithm-tabs {
    justify-content: center;
  }

  .forecast-cards {
    grid-template-columns: 1fr;
  }

  .tech-grid {
    grid-template-columns: 1fr;
  }
}
</style>