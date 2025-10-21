<template>
  <div class="home-view">
    <!-- Current Weather Card -->
    <div v-if="hasCurrentWeather" class="glass-card current-weather">
      <div class="current-weather-header">
        <div class="location-info">
          <h1>{{ currentWeather.location.name }}</h1>
          <p>{{ currentWeather.location.country }}</p>
        </div>
        <button 
          @click="refreshWeather" 
          :disabled="loading"
          class="refresh-btn"
          :class="{ 'loading': loading }"
        >
          <i class="fas fa-sync-alt"></i>
        </button>
      </div>

      <div class="current-weather-main">
        <div class="temperature-section">
          <div class="temperature">
            {{ Math.round(currentWeather.current.temperature) }}°
          </div>
          <div class="feels-like">
            Feels like {{ Math.round(currentWeather.current.feels_like) }}°
          </div>
        </div>

        <div class="weather-info">
          <div class="weather-icon">
            <i :class="getWeatherIcon(currentWeather.current.weather.main)"></i>
          </div>
          <div class="weather-description">
            {{ currentWeather.current.weather.description }}
          </div>
        </div>
      </div>

      <div class="weather-details">
        <div class="detail-item">
          <i class="fas fa-eye"></i>
          <span>{{ currentWeather.current.visibility }}km</span>
        </div>
        <div class="detail-item">
          <i class="fas fa-tint"></i>
          <span>{{ currentWeather.current.humidity }}%</span>
        </div>
        <div class="detail-item">
          <i class="fas fa-wind"></i>
          <span>{{ Math.round(currentWeather.current.wind.speed) }} m/s</span>
        </div>
        <div class="detail-item">
          <i class="fas fa-thermometer-half"></i>
          <span>{{ Math.round(currentWeather.current.pressure) }} hPa</span>
        </div>
      </div>

      <div class="favorite-action">
        <button 
          @click="toggleFavorite" 
          class="favorite-btn"
          :class="{ 'favorited': isFavoriteLocation }"
        >
          <i :class="isFavoriteLocation ? 'fas fa-heart' : 'far fa-heart'"></i>
          {{ isFavoriteLocation ? 'Remove from Favorites' : 'Add to Favorites' }}
        </button>
      </div>
    </div>

    <!-- No Weather Data -->
    <div v-else-if="!loading" class="glass-card no-weather">
      <div class="no-weather-content">
        <i class="fas fa-cloud-sun"></i>
        <h2>No Weather Data</h2>
        <p>Get started by searching for a location or allowing location access</p>
        <div class="action-buttons">
          <button @click="getCurrentLocation" class="btn btn-primary">
            <i class="fas fa-location-arrow"></i>
            Use My Location
          </button>
          <router-link to="/search" class="btn btn-secondary">
            <i class="fas fa-search"></i>
            Search Location
          </router-link>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="glass-card loading-card">
      <div class="loading-content">
        <div class="loading-spinner"></div>
        <p>Loading weather data...</p>
      </div>
    </div>

    <!-- Quick Forecast -->
    <div v-if="hasForecast" class="glass-card quick-forecast">
      <div class="quick-forecast-header">
        <h3>5-Day Forecast</h3>
        <router-link to="/forecast" class="view-all-btn">
          View Details
        </router-link>
      </div>
      
      <div class="forecast-list">
        <div 
          v-for="day in forecast.slice(0, 5)" 
          :key="day.date"
          class="forecast-item"
        >
          <div class="forecast-day">
            {{ formatDate(day.date) }}
          </div>
          <div class="forecast-icon">
            <i :class="getWeatherIcon(day.weather.main)"></i>
          </div>
          <div class="forecast-temps">
            <span class="temp-high">{{ Math.round(day.temperature.max) }}°</span>
            <span class="temp-low">{{ Math.round(day.temperature.min) }}°</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Favorites Quick Access -->
    <div v-if="favorites.length > 0" class="glass-card favorites-quick">
      <div class="favorites-header">
        <h3>Favorite Locations</h3>
        <router-link to="/favorites" class="view-all-btn">
          View All
        </router-link>
      </div>
      
      <div class="favorites-list">
        <div 
          v-for="favorite in favorites.slice(0, 3)" 
          :key="`${favorite.coordinates.lat}-${favorite.coordinates.lon}`"
          class="favorite-item"
          @click="loadFavoriteWeather(favorite)"
        >
          <div class="favorite-name">
            {{ favorite.name }}
          </div>
          <div class="favorite-country">
            {{ favorite.country }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, watch } from 'vue'
import { useWeatherStore } from '../stores'

const weatherStore = useWeatherStore()

// Computed properties
const currentWeather = computed(() => weatherStore.currentWeather)
const forecast = computed(() => weatherStore.forecast)
const favorites = computed(() => weatherStore.favorites)
const loading = computed(() => weatherStore.loading)
const hasCurrentWeather = computed(() => weatherStore.hasCurrentWeather)
const hasForecast = computed(() => weatherStore.hasForecast)
const currentLocation = computed(() => weatherStore.currentLocation)

const isFavoriteLocation = computed(() => {
  if (!currentLocation.value) return false
  return weatherStore.isFavorite(currentLocation.value)
})

// Methods
const refreshWeather = async () => {
  await weatherStore.refreshWeather()
}

const getCurrentLocation = async () => {
  await weatherStore.getCurrentLocation()
}

const toggleFavorite = () => {
  if (!currentLocation.value) return
  
  if (isFavoriteLocation.value) {
    weatherStore.removeFromFavorites(currentLocation.value)
  } else {
    weatherStore.addToFavorites(currentLocation.value)
  }
}

const loadFavoriteWeather = async (favorite) => {
  await weatherStore.fetchCurrentWeather(
    favorite.coordinates.lat,
    favorite.coordinates.lon
  )
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

const formatDate = (dateString) => {
  const date = new Date(dateString)
  const today = new Date()
  const tomorrow = new Date(today)
  tomorrow.setDate(today.getDate() + 1)
  
  if (date.toDateString() === today.toDateString()) {
    return 'Today'
  } else if (date.toDateString() === tomorrow.toDateString()) {
    return 'Tomorrow'
  } else {
    return date.toLocaleDateString('en-US', { weekday: 'short' })
  }
}

// Watch for current weather changes to fetch forecast
watch(currentWeather, async (newWeather) => {
  if (newWeather && currentLocation.value) {
    await weatherStore.fetchForecast(
      currentLocation.value.coordinates.lat,
      currentLocation.value.coordinates.lon
    )
  }
})

// Initialize on mount
onMounted(async () => {
  await weatherStore.initializeApp()
})
</script>

<style scoped>
.home-view {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  max-width: 800px;
  margin: 0 auto;
  padding: 1rem;
}

/* Current Weather Card */
.current-weather {
  padding: 2rem;
}

.current-weather-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 2rem;
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

.refresh-btn {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-primary);
  cursor: pointer;
  transition: all 0.3s ease;
}

.refresh-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: scale(1.05);
}

.refresh-btn.loading {
  animation: spin 1s linear infinite;
}

.current-weather-main {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.temperature {
  font-size: 4rem;
  font-weight: 300;
  line-height: 1;
  color: var(--text-primary);
}

.feels-like {
  font-size: 0.9rem;
  color: var(--text-secondary);
  margin-top: 0.5rem;
}

.weather-info {
  text-align: right;
}

.weather-icon i {
  font-size: 3rem;
  color: var(--accent-color);
  margin-bottom: 0.5rem;
}

.weather-description {
  font-size: 1.1rem;
  color: var(--text-primary);
  text-transform: capitalize;
}

.weather-details {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
  padding: 1.5rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--text-primary);
}

.detail-item i {
  color: var(--accent-color);
  width: 16px;
}

.favorite-action {
  text-align: center;
}

.favorite-btn {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 20px;
  padding: 0.75rem 1.5rem;
  color: var(--text-primary);
  cursor: pointer;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.favorite-btn:hover {
  background: rgba(255, 255, 255, 0.2);
}

.favorite-btn.favorited {
  background: rgba(239, 68, 68, 0.2);
  border-color: rgba(239, 68, 68, 0.3);
  color: #ef4444;
}

/* No Weather State */
.no-weather {
  padding: 3rem 2rem;
  text-align: center;
}

.no-weather-content i {
  font-size: 4rem;
  color: var(--accent-color);
  margin-bottom: 1rem;
}

.no-weather-content h2 {
  font-size: 1.5rem;
  color: var(--text-primary);
  margin-bottom: 0.5rem;
}

.no-weather-content p {
  color: var(--text-secondary);
  margin-bottom: 2rem;
}

.action-buttons {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
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

/* Loading Card */
.loading-card {
  padding: 3rem 2rem;
  text-align: center;
}

.loading-content {
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

/* Quick Forecast */
.quick-forecast {
  padding: 1.5rem;
}

.quick-forecast-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.quick-forecast-header h3 {
  font-size: 1.25rem;
  color: var(--text-primary);
  margin: 0;
}

.view-all-btn {
  color: var(--accent-color);
  text-decoration: none;
  font-size: 0.9rem;
  transition: opacity 0.3s ease;
}

.view-all-btn:hover {
  opacity: 0.8;
}

.forecast-list {
  display: flex;
  gap: 1rem;
  overflow-x: auto;
  padding-bottom: 0.5rem;
}

.forecast-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  min-width: 80px;
  padding: 1rem 0.5rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.forecast-day {
  font-size: 0.8rem;
  color: var(--text-secondary);
  text-align: center;
}

.forecast-icon i {
  font-size: 1.5rem;
  color: var(--accent-color);
}

.forecast-temps {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
}

.temp-high {
  font-weight: 600;
  color: var(--text-primary);
}

.temp-low {
  font-size: 0.9rem;
  color: var(--text-secondary);
}

/* Favorites Quick Access */
.favorites-quick {
  padding: 1.5rem;
}

.favorites-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.favorites-header h3 {
  font-size: 1.25rem;
  color: var(--text-primary);
  margin: 0;
}

.favorites-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.favorite-item {
  padding: 1rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  cursor: pointer;
  transition: all 0.3s ease;
}

.favorite-item:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateY(-1px);
}

.favorite-name {
  font-weight: 500;
  color: var(--text-primary);
}

.favorite-country {
  font-size: 0.9rem;
  color: var(--text-secondary);
}

/* Animations */
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* Responsive Design */
@media (max-width: 768px) {
  .home-view {
    padding: 0.5rem;
  }

  .current-weather {
    padding: 1.5rem;
  }

  .current-weather-main {
    flex-direction: column;
    text-align: center;
    gap: 1rem;
  }

  .temperature {
    font-size: 3rem;
  }

  .weather-details {
    grid-template-columns: repeat(2, 1fr);
  }

  .action-buttons {
    flex-direction: column;
  }

  .forecast-list {
    justify-content: space-between;
  }

  .forecast-item {
    min-width: 70px;
  }
}
</style>
