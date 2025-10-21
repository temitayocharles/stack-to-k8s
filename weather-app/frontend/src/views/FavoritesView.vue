<template>
  <div class="favorites-view">
    <!-- Favorites Header -->
    <div class="glass-card favorites-header">
      <div class="header-content">
        <div class="header-main">
          <h1>Favorite Locations</h1>
          <p v-if="favorites.length > 0">
            {{ favorites.length }} saved location{{ favorites.length === 1 ? '' : 's' }}
          </p>
          <p v-else>
            No favorite locations saved yet
          </p>
        </div>
        
        <div class="header-actions">
          <router-link to="/search" class="add-btn">
            <i class="fas fa-plus"></i>
            Add Location
          </router-link>
        </div>
      </div>
    </div>

    <!-- No Favorites State -->
    <div v-if="favorites.length === 0" class="glass-card no-favorites">
      <div class="no-favorites-content">
        <i class="fas fa-heart"></i>
        <h2>No Favorite Locations</h2>
        <p>Save your favorite locations for quick weather updates</p>
        <div class="benefits-list">
          <div class="benefit-item">
            <i class="fas fa-bolt"></i>
            <span>Quick access to weather data</span>
          </div>
          <div class="benefit-item">
            <i class="fas fa-sync-alt"></i>
            <span>Automatic weather updates</span>
          </div>
          <div class="benefit-item">
            <i class="fas fa-chart-line"></i>
            <span>Track weather patterns</span>
          </div>
        </div>
        <div class="action-buttons">
          <router-link to="/search" class="btn btn-primary">
            <i class="fas fa-search"></i>
            Find Locations
          </router-link>
          <button @click="getCurrentLocation" class="btn btn-secondary">
            <i class="fas fa-location-arrow"></i>
            Use Current Location
          </button>
        </div>
      </div>
    </div>

    <!-- Favorites Grid -->
    <div v-else class="favorites-grid">
      <div
        v-for="favorite in favorites"
        :key="`${favorite.coordinates.lat}-${favorite.coordinates.lon}`"
        class="favorite-card glass-card"
        :class="{ 'current': isCurrentLocation(favorite) }"
      >
        <!-- Favorite Header -->
        <div class="favorite-header">
          <div class="location-info">
            <h3>{{ favorite.name }}</h3>
            <p>{{ favorite.country }}</p>
          </div>
          
          <div class="favorite-actions">
            <button
              @click="loadWeather(favorite)"
              :disabled="loadingLocation === getLocationKey(favorite)"
              class="load-btn"
              :class="{ 'loading': loadingLocation === getLocationKey(favorite) }"
              title="Load weather for this location"
            >
              <i class="fas fa-sync-alt"></i>
            </button>
            
            <button
              @click="removeFavorite(favorite)"
              class="remove-btn"
              title="Remove from favorites"
            >
              <i class="fas fa-heart"></i>
            </button>
          </div>
        </div>

        <!-- Weather Data -->
        <div v-if="favoriteWeatherData[getLocationKey(favorite)]" class="weather-data">
          <div class="current-weather">
            <div class="weather-main">
              <div class="temperature">
                {{ Math.round(favoriteWeatherData[getLocationKey(favorite)].current.main.temp) }}°
              </div>
              <div class="weather-info">
                <div class="weather-icon">
                  <i :class="getWeatherIcon(favoriteWeatherData[getLocationKey(favorite)].current.weather.main)"></i>
                </div>
                <div class="weather-desc">
                  {{ favoriteWeatherData[getLocationKey(favorite)].current.weather.description }}
                </div>
              </div>
            </div>
            
            <div class="weather-details">
              <div class="detail-item">
                <i class="fas fa-tint"></i>
                <span>{{ favoriteWeatherData[getLocationKey(favorite)].current.main.humidity }}%</span>
              </div>
              <div class="detail-item">
                <i class="fas fa-wind"></i>
                <span>{{ Math.round(favoriteWeatherData[getLocationKey(favorite)].current.wind.speed) }} m/s</span>
              </div>
            </div>
            
            <div class="last-updated">
              Last updated: {{ formatLastUpdated(favoriteWeatherData[getLocationKey(favorite)].timestamp) }}
            </div>
          </div>
        </div>

        <!-- Loading State -->
        <div v-else-if="loadingLocation === getLocationKey(favorite)" class="weather-loading">
          <div class="loading-spinner"></div>
          <p>Loading weather...</p>
        </div>

        <!-- No Weather Data -->
        <div v-else class="no-weather">
          <div class="no-weather-content">
            <i class="fas fa-cloud"></i>
            <p>No weather data loaded</p>
            <button @click="loadWeather(favorite)" class="load-weather-btn">
              Load Weather
            </button>
          </div>
        </div>

        <!-- Quick Actions -->
        <div class="quick-actions">
          <button
            @click="selectAsCurrent(favorite)"
            class="action-btn"
            :class="{ 'active': isCurrentLocation(favorite) }"
          >
            <i class="fas fa-home"></i>
            {{ isCurrentLocation(favorite) ? 'Current' : 'Set as Current' }}
          </button>
          
          <button
            @click="viewForecast(favorite)"
            class="action-btn"
          >
            <i class="fas fa-calendar-alt"></i>
            View Forecast
          </button>
        </div>
      </div>
    </div>

    <!-- Favorites Management -->
    <div v-if="favorites.length > 0" class="glass-card favorites-management">
      <div class="management-header">
        <h3>Manage Favorites</h3>
        <span class="favorites-count">{{ favorites.length }}/10 locations</span>
      </div>
      
      <div class="management-actions">
        <button
          @click="refreshAllWeather"
          :disabled="loadingAll"
          class="refresh-all-btn"
          :class="{ 'loading': loadingAll }"
        >
          <i class="fas fa-sync-alt"></i>
          {{ loadingAll ? 'Refreshing...' : 'Refresh All Weather' }}
        </button>
        
        <button
          @click="clearAllFavorites"
          class="clear-all-btn"
        >
          <i class="fas fa-trash"></i>
          Clear All Favorites
        </button>
      </div>
      
      <div class="management-info">
        <div class="info-item">
          <i class="fas fa-info-circle"></i>
          <span>Weather data refreshes automatically when you visit each location</span>
        </div>
        <div class="info-item">
          <i class="fas fa-clock"></i>
          <span>You can save up to 10 favorite locations</span>
        </div>
      </div>
    </div>

    <!-- Location Tips -->
    <div v-if="favorites.length > 0 && favorites.length < 5" class="glass-card location-tips">
      <h3>Location Tips</h3>
      <div class="tips-grid">
        <div class="tip-item">
          <i class="fas fa-map-marker-alt"></i>
          <div>
            <strong>Home & Work</strong>
            <p>Add your daily locations for quick access</p>
          </div>
        </div>
        
        <div class="tip-item">
          <i class="fas fa-plane"></i>
          <div>
            <strong>Travel Destinations</strong>
            <p>Monitor weather at places you plan to visit</p>
          </div>
        </div>
        
        <div class="tip-item">
          <i class="fas fa-users"></i>
          <div>
            <strong>Family & Friends</strong>
            <p>Keep track of weather where loved ones live</p>
          </div>
        </div>
        
        <div class="tip-item">
          <i class="fas fa-mountain"></i>
          <div>
            <strong>Activity Spots</strong>
            <p>Save locations for outdoor activities</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useWeatherStore } from '../stores'

const router = useRouter()
const weatherStore = useWeatherStore()

// State
const favoriteWeatherData = ref({})
const loadingLocation = ref(null)
const loadingAll = ref(false)

// Computed
const favorites = computed(() => weatherStore.favorites)
const currentLocation = computed(() => weatherStore.currentLocation)

// Methods
const getCurrentLocation = async () => {
  try {
    await weatherStore.getCurrentLocation()
    router.push('/')
  } catch (error) {
    console.error('Failed to get current location:', error)
  }
}

const getLocationKey = (location) => {
  return `${location.coordinates.lat}-${location.coordinates.lon}`
}

const isCurrentLocation = (favorite) => {
  if (!currentLocation.value) return false
  return (
    currentLocation.value.coordinates.lat === favorite.coordinates.lat &&
    currentLocation.value.coordinates.lon === favorite.coordinates.lon
  )
}

const loadWeather = async (favorite) => {
  const key = getLocationKey(favorite)
  loadingLocation.value = key
  
  try {
    const weatherData = await weatherStore.fetchCurrentWeather(
      favorite.coordinates.lat,
      favorite.coordinates.lon
    )
    
    favoriteWeatherData.value[key] = {
      ...weatherData,
      timestamp: Date.now()
    }
  } catch (error) {
    console.error('Failed to load weather:', error)
  } finally {
    loadingLocation.value = null
  }
}

const removeFavorite = (favorite) => {
  if (confirm(`Remove ${favorite.name} from favorites?`)) {
    weatherStore.removeFromFavorites(favorite)
    
    // Remove weather data
    const key = getLocationKey(favorite)
    delete favoriteWeatherData.value[key]
  }
}

const selectAsCurrent = async (favorite) => {
  await weatherStore.fetchCurrentWeather(
    favorite.coordinates.lat,
    favorite.coordinates.lon
  )
  router.push('/')
}

const viewForecast = async (favorite) => {
  await weatherStore.fetchCurrentWeather(
    favorite.coordinates.lat,
    favorite.coordinates.lon
  )
  router.push('/forecast')
}

const refreshAllWeather = async () => {
  loadingAll.value = true
  
  try {
    const promises = favorites.value.map(async (favorite) => {
      try {
        const weatherData = await weatherStore.fetchCurrentWeather(
          favorite.coordinates.lat,
          favorite.coordinates.lon
        )
        
        const key = getLocationKey(favorite)
        favoriteWeatherData.value[key] = {
          ...weatherData,
          timestamp: Date.now()
        }
      } catch (error) {
        console.error(`Failed to load weather for ${favorite.name}:`, error)
      }
    })
    
    await Promise.all(promises)
  } finally {
    loadingAll.value = false
  }
}

const clearAllFavorites = () => {
  if (confirm('Remove all favorite locations? This cannot be undone.')) {
    favorites.value.forEach(favorite => {
      weatherStore.removeFromFavorites(favorite)
    })
    favoriteWeatherData.value = {}
  }
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

const formatLastUpdated = (timestamp) => {
  const now = Date.now()
  const diff = now - timestamp
  const minutes = Math.floor(diff / 60000)
  
  if (minutes < 1) return 'Just now'
  if (minutes < 60) return `${minutes} min ago`
  
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours} hour${hours === 1 ? '' : 's'} ago`
  
  const days = Math.floor(hours / 24)
  return `${days} day${days === 1 ? '' : 's'} ago`
}

// Load weather for favorites on mount
onMounted(async () => {
  if (favorites.value.length > 0) {
    // Load weather for first few favorites
    const topFavorites = favorites.value.slice(0, 3)
    
    for (const favorite of topFavorites) {
      try {
        await loadWeather(favorite)
      } catch (error) {
        console.error(`Failed to load weather for ${favorite.name}:`, error)
      }
    }
  }
})
</script>

<style scoped>
.favorites-view {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
}

/* Favorites Header */
.favorites-header {
  padding: 2rem;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.header-main h1 {
  font-size: 2rem;
  font-weight: 600;
  margin: 0 0 0.5rem 0;
  color: var(--text-primary);
}

.header-main p {
  font-size: 1rem;
  color: var(--text-secondary);
  margin: 0;
}

.add-btn {
  background: var(--accent-color);
  color: white;
  text-decoration: none;
  padding: 0.75rem 1.5rem;
  border-radius: 20px;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
}

.add-btn:hover {
  background: var(--accent-hover);
  transform: translateY(-1px);
}

/* No Favorites State */
.no-favorites {
  padding: 3rem 2rem;
  text-align: center;
}

.no-favorites-content i {
  font-size: 4rem;
  color: var(--accent-color);
  margin-bottom: 1rem;
}

.no-favorites-content h2 {
  font-size: 1.5rem;
  color: var(--text-primary);
  margin-bottom: 0.5rem;
}

.no-favorites-content p {
  color: var(--text-secondary);
  margin-bottom: 2rem;
}

.benefits-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  max-width: 400px;
  margin: 0 auto 2rem auto;
}

.benefit-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.benefit-item i {
  color: var(--accent-color);
  width: 20px;
  text-align: center;
}

.benefit-item span {
  color: var(--text-primary);
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

/* Favorites Grid */
.favorites-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 1.5rem;
}

.favorite-card {
  padding: 1.5rem;
  transition: all 0.3s ease;
}

.favorite-card:hover {
  transform: translateY(-2px);
}

.favorite-card.current {
  border: 2px solid var(--accent-color);
  background: rgba(var(--accent-color-rgb), 0.1);
}

/* Favorite Header */
.favorite-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.location-info h3 {
  font-size: 1.25rem;
  font-weight: 600;
  margin: 0 0 0.25rem 0;
  color: var(--text-primary);
}

.location-info p {
  font-size: 0.9rem;
  color: var(--text-secondary);
  margin: 0;
}

.favorite-actions {
  display: flex;
  gap: 0.5rem;
}

.load-btn,
.remove-btn {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-secondary);
  cursor: pointer;
  transition: all 0.3s ease;
}

.load-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  color: var(--text-primary);
}

.load-btn.loading {
  animation: spin 1s linear infinite;
}

.remove-btn {
  color: #ef4444;
  border-color: rgba(239, 68, 68, 0.3);
}

.remove-btn:hover {
  background: rgba(239, 68, 68, 0.2);
  color: #ef4444;
}

/* Weather Data */
.weather-data {
  margin-bottom: 1.5rem;
}

.weather-main {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.temperature {
  font-size: 2.5rem;
  font-weight: 300;
  color: var(--text-primary);
}

.weather-info {
  text-align: right;
}

.weather-icon i {
  font-size: 2rem;
  color: var(--accent-color);
  margin-bottom: 0.25rem;
}

.weather-desc {
  font-size: 0.9rem;
  color: var(--text-primary);
  text-transform: capitalize;
}

.weather-details {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}

.detail-item {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 6px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: var(--text-primary);
}

.detail-item i {
  color: var(--accent-color);
}

.last-updated {
  font-size: 0.8rem;
  color: var(--text-secondary);
  text-align: center;
}

/* Loading and No Weather States */
.weather-loading,
.no-weather {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  margin-bottom: 1.5rem;
}

.loading-spinner {
  width: 30px;
  height: 30px;
  border: 2px solid rgba(255, 255, 255, 0.1);
  border-top: 2px solid var(--accent-color);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 0.5rem;
}

.no-weather-content {
  text-align: center;
}

.no-weather-content i {
  font-size: 2rem;
  color: var(--text-secondary);
  margin-bottom: 0.5rem;
}

.load-weather-btn {
  background: var(--accent-color);
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 15px;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-top: 0.5rem;
}

.load-weather-btn:hover {
  background: var(--accent-hover);
}

/* Quick Actions */
.quick-actions {
  display: flex;
  gap: 0.75rem;
}

.action-btn {
  flex: 1;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  padding: 0.75rem;
  color: var(--text-primary);
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  font-size: 0.9rem;
}

.action-btn:hover {
  background: rgba(255, 255, 255, 0.2);
}

.action-btn.active {
  background: rgba(var(--accent-color-rgb), 0.2);
  border-color: var(--accent-color);
  color: var(--accent-color);
}

/* Favorites Management */
.favorites-management {
  padding: 1.5rem;
}

.management-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.management-header h3 {
  font-size: 1.25rem;
  color: var(--text-primary);
  margin: 0;
}

.favorites-count {
  font-size: 0.9rem;
  color: var(--text-secondary);
}

.management-actions {
  display: flex;
  gap: 1rem;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
}

.refresh-all-btn,
.clear-all-btn {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  padding: 0.75rem 1rem;
  color: var(--text-primary);
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.refresh-all-btn:hover,
.clear-all-btn:hover {
  background: rgba(255, 255, 255, 0.2);
}

.refresh-all-btn.loading {
  opacity: 0.7;
  cursor: not-allowed;
}

.refresh-all-btn.loading i {
  animation: spin 1s linear infinite;
}

.clear-all-btn {
  color: #ef4444;
  border-color: rgba(239, 68, 68, 0.3);
}

.clear-all-btn:hover {
  background: rgba(239, 68, 68, 0.2);
}

.management-info {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.info-item i {
  color: var(--accent-color);
  width: 16px;
}

/* Location Tips */
.location-tips {
  padding: 1.5rem;
}

.location-tips h3 {
  font-size: 1.25rem;
  color: var(--text-primary);
  margin: 0 0 1.5rem 0;
}

.tips-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.tip-item {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.tip-item i {
  color: var(--accent-color);
  font-size: 1.25rem;
  margin-top: 0.25rem;
}

.tip-item strong {
  color: var(--text-primary);
  display: block;
  margin-bottom: 0.25rem;
}

.tip-item p {
  color: var(--text-secondary);
  font-size: 0.9rem;
  margin: 0;
}

/* Animations */
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* Responsive Design */
@media (max-width: 768px) {
  .favorites-view {
    padding: 0.5rem;
  }

  .favorites-header {
    padding: 1.5rem;
  }

  .header-content {
    flex-direction: column;
    gap: 1rem;
  }

  .favorites-grid {
    grid-template-columns: 1fr;
  }

  .weather-main {
    flex-direction: column;
    text-align: center;
    gap: 1rem;
  }

  .weather-details {
    flex-direction: column;
    gap: 0.5rem;
  }

  .quick-actions {
    flex-direction: column;
  }

  .management-actions {
    flex-direction: column;
  }

  .tips-grid {
    grid-template-columns: 1fr;
  }

  .action-buttons {
    flex-direction: column;
  }
}
</style>
