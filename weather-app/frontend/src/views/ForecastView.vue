<template>
  <div class="forecast-view">
    <!-- Forecast Header -->
    <div class="glass-card forecast-header">
      <div class="header-content">
        <div class="location-info">
          <h1 v-if="currentLocation">
            {{ currentLocation.name }}
          </h1>
          <p v-if="currentLocation">
            {{ currentLocation.country }}
          </p>
        </div>
        
        <div class="header-actions">
          <button 
            @click="refreshForecast" 
            :disabled="loading"
            class="refresh-btn"
            :class="{ 'loading': loading }"
            title="Refresh forecast"
          >
            <i class="fas fa-sync-alt"></i>
          </button>
          
          <button 
            @click="toggleForecastDays"
            class="days-toggle-btn"
            :title="`Switch to ${forecastDays === 5 ? '7' : '5'} day forecast`"
          >
            {{ forecastDays }}d
          </button>
        </div>
      </div>
      
      <div v-if="currentWeather" class="current-summary">
        <div class="current-temp">
          {{ Math.round(currentWeather.current.main.temp) }}°
        </div>
        <div class="current-condition">
          <i :class="getWeatherIcon(currentWeather.current.weather.main)"></i>
          <span>{{ currentWeather.current.weather.description }}</span>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="glass-card loading-card">
      <div class="loading-content">
        <div class="loading-spinner"></div>
        <p>Loading {{ forecastDays }}-day forecast...</p>
      </div>
    </div>

    <!-- No Forecast Data -->
    <div v-else-if="!hasForecast" class="glass-card no-forecast">
      <div class="no-forecast-content">
        <i class="fas fa-calendar-alt"></i>
        <h2>No Forecast Available</h2>
        <p>Please select a location to view the weather forecast</p>
        <div class="action-buttons">
          <router-link to="/search" class="btn btn-primary">
            <i class="fas fa-search"></i>
            Search Location
          </router-link>
          <router-link to="/" class="btn btn-secondary">
            <i class="fas fa-home"></i>
            Go Home
          </router-link>
        </div>
      </div>
    </div>

    <!-- Forecast Cards -->
    <div v-else class="forecast-grid">
      <div
        v-for="(day, index) in forecast"
        :key="day.date"
        class="forecast-card glass-card"
        :class="{ 'today': index === 0, 'tomorrow': index === 1 }"
      >
        <!-- Day Header -->
        <div class="day-header">
          <div class="day-name">
            {{ formatDayName(day.date, index) }}
          </div>
          <div class="day-date">
            {{ formatDate(day.date) }}
          </div>
        </div>

        <!-- Weather Icon and Description -->
        <div class="weather-main">
          <div class="weather-icon">
            <i :class="getWeatherIcon(day.weather.main)"></i>
          </div>
          <div class="weather-desc">
            {{ day.weather.description }}
          </div>
        </div>

        <!-- Temperature Range -->
        <div class="temperature-range">
          <div class="temp-high">
            <span class="temp-label">High</span>
            <span class="temp-value">{{ Math.round(day.temperature.max) }}°</span>
          </div>
          <div class="temp-low">
            <span class="temp-label">Low</span>
            <span class="temp-value">{{ Math.round(day.temperature.min) }}°</span>
          </div>
        </div>

        <!-- Weather Details -->
        <div class="weather-details">
          <div class="detail-row">
            <div class="detail-item">
              <i class="fas fa-tint"></i>
              <span class="detail-label">Humidity</span>
              <span class="detail-value">{{ day.humidity }}%</span>
            </div>
            <div class="detail-item">
              <i class="fas fa-wind"></i>
              <span class="detail-label">Wind</span>
              <span class="detail-value">{{ Math.round(day.wind.speed) }} m/s</span>
            </div>
          </div>
          
          <div class="detail-row">
            <div class="detail-item">
              <i class="fas fa-cloud-rain"></i>
              <span class="detail-label">Rain</span>
              <span class="detail-value">{{ Math.round(day.precipitation.probability) }}%</span>
            </div>
            <div class="detail-item">
              <i class="fas fa-thermometer-half"></i>
              <span class="detail-label">Pressure</span>
              <span class="detail-value">{{ Math.round(day.pressure) }} hPa</span>
            </div>
          </div>
        </div>

        <!-- Hourly Preview (for today and tomorrow) -->
        <div v-if="index <= 1 && day.hourly" class="hourly-preview">
          <div class="hourly-label">
            {{ index === 0 ? 'Today' : 'Tomorrow' }}
          </div>
          <div class="hourly-list">
            <div
              v-for="hour in day.hourly.slice(0, 6)"
              :key="hour.time"
              class="hourly-item"
            >
              <div class="hour-time">{{ formatHour(hour.time) }}</div>
              <div class="hour-icon">
                <i :class="getWeatherIcon(hour.weather.main)"></i>
              </div>
              <div class="hour-temp">{{ Math.round(hour.temperature) }}°</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Forecast Summary -->
    <div v-if="hasForecast" class="glass-card forecast-summary">
      <h3>{{ forecastDays }}-Day Summary</h3>
      
      <div class="summary-stats">
        <div class="stat-item">
          <div class="stat-label">Average High</div>
          <div class="stat-value">{{ averageHigh }}°</div>
        </div>
        
        <div class="stat-item">
          <div class="stat-label">Average Low</div>
          <div class="stat-value">{{ averageLow }}°</div>
        </div>
        
        <div class="stat-item">
          <div class="stat-label">Rainy Days</div>
          <div class="stat-value">{{ rainyDays }}</div>
        </div>
        
        <div class="stat-item">
          <div class="stat-label">Most Common</div>
          <div class="stat-value">{{ mostCommonWeather }}</div>
        </div>
      </div>
      
      <div class="summary-insights">
        <h4>Insights</h4>
        <ul>
          <li v-for="insight in weatherInsights" :key="insight">
            {{ insight }}
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, watch, ref } from 'vue'
import { useWeatherStore } from '../stores'

const weatherStore = useWeatherStore()

// State
const forecastDays = ref(5)

// Computed
const currentWeather = computed(() => weatherStore.currentWeather)
const currentLocation = computed(() => weatherStore.currentLocation)
const forecast = computed(() => weatherStore.forecast)
const loading = computed(() => weatherStore.loading)
const hasForecast = computed(() => weatherStore.hasForecast)

// Forecast analytics
const averageHigh = computed(() => {
  if (!forecast.value.length) return 0
  const sum = forecast.value.reduce((acc, day) => acc + day.temperature.max, 0)
  return Math.round(sum / forecast.value.length)
})

const averageLow = computed(() => {
  if (!forecast.value.length) return 0
  const sum = forecast.value.reduce((acc, day) => acc + day.temperature.min, 0)
  return Math.round(sum / forecast.value.length)
})

const rainyDays = computed(() => {
  if (!forecast.value.length) return 0
  return forecast.value.filter(day => day.precipitation.probability > 30).length
})

const mostCommonWeather = computed(() => {
  if (!forecast.value.length) return 'N/A'
  
  const weatherCounts = {}
  forecast.value.forEach(day => {
    const weather = day.weather.main
    weatherCounts[weather] = (weatherCounts[weather] || 0) + 1
  })
  
  const mostCommon = Object.entries(weatherCounts)
    .sort(([,a], [,b]) => b - a)[0]
  
  return mostCommon ? mostCommon[0] : 'N/A'
})

const weatherInsights = computed(() => {
  if (!forecast.value.length) return []
  
  const insights = []
  
  // Temperature trend
  const tempTrend = forecast.value.slice(0, 3).map(day => day.temperature.max)
  if (tempTrend.every((temp, i) => i === 0 || temp > tempTrend[i - 1])) {
    insights.push('Temperatures are rising over the next few days')
  } else if (tempTrend.every((temp, i) => i === 0 || temp < tempTrend[i - 1])) {
    insights.push('Temperatures are cooling down')
  }
  
  // Rain forecast
  const rainyDaysCount = rainyDays.value
  if (rainyDaysCount >= 3) {
    insights.push('Expect frequent rain this week')
  } else if (rainyDaysCount === 0) {
    insights.push('No rain expected in the forecast period')
  }
  
  // Wind conditions
  const windyDays = forecast.value.filter(day => day.wind.speed > 10).length
  if (windyDays >= 2) {
    insights.push('Windy conditions expected')
  }
  
  // Extreme temperatures
  const hotDays = forecast.value.filter(day => day.temperature.max > 30).length
  const coldDays = forecast.value.filter(day => day.temperature.min < 0).length
  
  if (hotDays >= 2) {
    insights.push('Hot weather ahead')
  }
  if (coldDays >= 2) {
    insights.push('Cold temperatures expected')
  }
  
  return insights.length > 0 ? insights : ['Weather conditions look typical for this time of year']
})

// Methods
const refreshForecast = async () => {
  if (currentLocation.value) {
    await weatherStore.fetchForecast(
      currentLocation.value.coordinates.lat,
      currentLocation.value.coordinates.lon,
      forecastDays.value
    )
  }
}

const toggleForecastDays = async () => {
  forecastDays.value = forecastDays.value === 5 ? 7 : 5
  await refreshForecast()
}

const getWeatherIcon = (weatherMain) => {
  const iconMap = {
    'Clear': 'fas fa-sun',
    'Clouds': 'fas fa-cloud',
    'Rain': 'fas fa-cloud-rain',
    'Drizzle': 'fas fa-cloud-drizzle',
    'Thunderstorm': 'fas fa-bolt',
    'Snow': 'fas fa-snowflake',
    'Mist': 'fas fa-smog',
    'Fog': 'fas fa-smog',
    'Haze': 'fas fa-smog'
  }
  return iconMap[weatherMain] || 'fas fa-cloud'
}

const formatDayName = (dateString, index) => {
  if (index === 0) return 'Today'
  if (index === 1) return 'Tomorrow'
  
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { weekday: 'long' })
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    month: 'short', 
    day: 'numeric' 
  })
}

const formatHour = (timeString) => {
  const date = new Date(timeString)
  return date.toLocaleTimeString('en-US', { 
    hour: 'numeric',
    hour12: true 
  })
}

// Watch for location changes
watch(currentLocation, async (newLocation) => {
  if (newLocation) {
    await weatherStore.fetchForecast(
      newLocation.coordinates.lat,
      newLocation.coordinates.lon,
      forecastDays.value
    )
  }
})

// Initialize
onMounted(async () => {
  if (currentLocation.value && !hasForecast.value) {
    await weatherStore.fetchForecast(
      currentLocation.value.coordinates.lat,
      currentLocation.value.coordinates.lon,
      forecastDays.value
    )
  }
})
</script>

<style scoped>
.forecast-view {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
}

/* Forecast Header */
.forecast-header {
  padding: 2rem;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1.5rem;
}

.location-info h1 {
  font-size: 2rem;
  font-weight: 600;
  margin: 0 0 0.25rem 0;
  color: var(--text-primary);
}

.location-info p {
  font-size: 1rem;
  color: var(--text-secondary);
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 0.75rem;
}

.refresh-btn,
.days-toggle-btn {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  padding: 0.75rem;
  color: var(--text-primary);
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 45px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.refresh-btn:hover,
.days-toggle-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: translateY(-1px);
}

.refresh-btn.loading {
  animation: spin 1s linear infinite;
}

.current-summary {
  display: flex;
  align-items: center;
  gap: 2rem;
}

.current-temp {
  font-size: 3rem;
  font-weight: 300;
  color: var(--text-primary);
}

.current-condition {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.current-condition i {
  font-size: 2rem;
  color: var(--accent-color);
}

.current-condition span {
  font-size: 1.1rem;
  color: var(--text-primary);
  text-transform: capitalize;
}

/* Loading and No Data States */
.loading-card,
.no-forecast {
  padding: 3rem 2rem;
  text-align: center;
}

.loading-content,
.no-forecast-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid rgba(255, 255, 255, 0.1);
  border-top: 3px solid var(--accent-color);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.no-forecast-content i {
  font-size: 4rem;
  color: var(--accent-color);
  margin-bottom: 1rem;
}

.no-forecast-content h2 {
  font-size: 1.5rem;
  color: var(--text-primary);
  margin-bottom: 0.5rem;
}

.no-forecast-content p {
  color: var(--text-secondary);
  margin-bottom: 2rem;
}

.action-buttons {
  display: flex;
  gap: 1rem;
  justify-content: center;
}

.btn {
  padding: 0.75rem 1.5rem;
  border-radius: 20px;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
  border: none;
  cursor: pointer;
}

.btn-primary {
  background: var(--accent-color);
  color: white;
}

.btn-primary:hover {
  background: var(--accent-hover);
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.1);
  color: var(--text-primary);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.btn-secondary:hover {
  background: rgba(255, 255, 255, 0.2);
}

/* Forecast Grid */
.forecast-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 1.5rem;
}

.forecast-card {
  padding: 1.5rem;
  transition: all 0.3s ease;
}

.forecast-card:hover {
  transform: translateY(-2px);
}

.forecast-card.today {
  border: 2px solid var(--accent-color);
  background: rgba(var(--accent-color-rgb), 0.1);
}

.forecast-card.tomorrow {
  border: 2px solid rgba(255, 255, 255, 0.3);
}

/* Day Header */
.day-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.day-name {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--text-primary);
}

.day-date {
  font-size: 0.9rem;
  color: var(--text-secondary);
}

/* Weather Main */
.weather-main {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.weather-icon i {
  font-size: 2.5rem;
  color: var(--accent-color);
}

.weather-desc {
  font-size: 1.1rem;
  color: var(--text-primary);
  text-transform: capitalize;
}

/* Temperature Range */
.temperature-range {
  display: flex;
  justify-content: space-between;
  margin-bottom: 1.5rem;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.temp-high,
.temp-low {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
}

.temp-label {
  font-size: 0.8rem;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.temp-value {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--text-primary);
}

.temp-high .temp-value {
  color: #ff6b6b;
}

.temp-low .temp-value {
  color: #4dabf7;
}

/* Weather Details */
.weather-details {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
}

.detail-row {
  display: flex;
  gap: 1rem;
}

.detail-item {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 6px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.detail-item i {
  color: var(--accent-color);
  width: 16px;
  text-align: center;
}

.detail-label {
  font-size: 0.8rem;
  color: var(--text-secondary);
  flex: 1;
}

.detail-value {
  font-size: 0.9rem;
  color: var(--text-primary);
  font-weight: 500;
}

/* Hourly Preview */
.hourly-preview {
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  padding-top: 1rem;
}

.hourly-label {
  font-size: 0.9rem;
  color: var(--text-secondary);
  margin-bottom: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.hourly-list {
  display: flex;
  justify-content: space-between;
  gap: 0.5rem;
}

.hourly-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
  flex: 1;
  padding: 0.5rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 6px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.hour-time {
  font-size: 0.7rem;
  color: var(--text-secondary);
}

.hour-icon i {
  font-size: 1rem;
  color: var(--accent-color);
}

.hour-temp {
  font-size: 0.8rem;
  color: var(--text-primary);
  font-weight: 500;
}

/* Forecast Summary */
.forecast-summary {
  padding: 2rem;
}

.forecast-summary h3 {
  font-size: 1.5rem;
  color: var(--text-primary);
  margin: 0 0 1.5rem 0;
}

.summary-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.stat-label {
  font-size: 0.9rem;
  color: var(--text-secondary);
  text-align: center;
}

.stat-value {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--text-primary);
}

.summary-insights h4 {
  font-size: 1.1rem;
  color: var(--text-primary);
  margin: 0 0 1rem 0;
}

.summary-insights ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.summary-insights li {
  padding: 0.5rem 0;
  color: var(--text-secondary);
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.summary-insights li:last-child {
  border-bottom: none;
}

.summary-insights li::before {
  content: '→';
  color: var(--accent-color);
  margin-right: 0.5rem;
}

/* Animations */
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* Responsive Design */
@media (max-width: 768px) {
  .forecast-view {
    padding: 0.5rem;
  }

  .forecast-header {
    padding: 1.5rem;
  }

  .header-content {
    flex-direction: column;
    gap: 1rem;
  }

  .current-summary {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }

  .forecast-grid {
    grid-template-columns: 1fr;
  }

  .detail-row {
    flex-direction: column;
    gap: 0.5rem;
  }

  .hourly-list {
    overflow-x: auto;
    padding-bottom: 0.5rem;
  }

  .hourly-item {
    min-width: 60px;
  }

  .summary-stats {
    grid-template-columns: repeat(2, 1fr);
  }

  .action-buttons {
    flex-direction: column;
  }
}
</style>
