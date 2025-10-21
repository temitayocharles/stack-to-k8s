<template>
  <div class="search-view">
    <!-- Search Header -->
    <div class="glass-card search-header">
      <div class="search-container">
        <div class="search-input-wrapper">
          <i class="fas fa-search search-icon"></i>
          <input
            v-model="searchQuery"
            @input="handleSearchInput"
            @keydown.enter="performSearch"
            type="text"
            placeholder="Search for cities, countries, or zip codes..."
            class="search-input"
            :disabled="loading"
          />
          <button
            v-if="searchQuery"
            @click="clearSearch"
            class="clear-btn"
          >
            <i class="fas fa-times"></i>
          </button>
        </div>
        
        <button
          @click="getCurrentLocation"
          :disabled="loading"
          class="location-btn"
          title="Use my current location"
        >
          <i class="fas fa-location-arrow"></i>
        </button>
      </div>

      <!-- Search Suggestions -->
      <div v-if="searchQuery && searchQuery.length >= 2" class="search-suggestions">
        <div class="suggestion-header">
          <span>Search suggestions as you type...</span>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="glass-card loading-card">
      <div class="loading-content">
        <div class="loading-spinner"></div>
        <p>Searching for locations...</p>
      </div>
    </div>

    <!-- Search Results -->
    <div v-if="searchResults.length > 0 && !loading" class="search-results">
      <div class="results-header">
        <h3>Search Results</h3>
        <span class="results-count">{{ searchResults.length }} locations found</span>
      </div>
      
      <div class="results-list">
        <div
          v-for="location in searchResults"
          :key="`${location.lat}-${location.lon}`"
          class="result-item glass-card"
          @click="selectLocation(location)"
        >
          <div class="location-main">
            <div class="location-details">
              <h4>{{ location.name }}</h4>
              <p>{{ formatLocationDetails(location) }}</p>
            </div>
            
            <div class="location-actions">
              <button
                @click.stop="toggleFavorite(location)"
                class="favorite-btn"
                :class="{ 'favorited': isFavorite(location) }"
                :title="isFavorite(location) ? 'Remove from favorites' : 'Add to favorites'"
              >
                <i :class="isFavorite(location) ? 'fas fa-heart' : 'far fa-heart'"></i>
              </button>
            </div>
          </div>
          
          <div class="location-coords">
            <span>{{ location.lat.toFixed(4) }}, {{ location.lon.toFixed(4) }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- No Results -->
    <div v-if="searchQuery && searchResults.length === 0 && !loading && hasSearched" class="glass-card no-results">
      <div class="no-results-content">
        <i class="fas fa-search"></i>
        <h3>No Results Found</h3>
        <p>No locations found for "{{ searchQuery }}"</p>
        <div class="search-tips">
          <h4>Search Tips:</h4>
          <ul>
            <li>Try searching for a city name (e.g., "New York")</li>
            <li>Include the country for better results (e.g., "Paris, France")</li>
            <li>Use zip codes for specific areas (e.g., "10001")</li>
            <li>Check your spelling</li>
          </ul>
        </div>
      </div>
    </div>

    <!-- Recent Searches -->
    <div v-if="recentSearches.length > 0 && !searchQuery" class="glass-card recent-searches">
      <div class="recent-header">
        <h3>Recent Searches</h3>
        <button @click="clearRecentSearches" class="clear-recent-btn">
          Clear All
        </button>
      </div>
      
      <div class="recent-list">
        <div
          v-for="search in recentSearches"
          :key="`recent-${search.lat}-${search.lon}`"
          class="recent-item"
          @click="selectLocation(search)"
        >
          <div class="recent-location">
            <i class="fas fa-history"></i>
            <div class="recent-details">
              <span class="recent-name">{{ search.name }}</span>
              <span class="recent-info">{{ formatLocationDetails(search) }}</span>
            </div>
          </div>
          
          <button
            @click.stop="removeRecentSearch(search)"
            class="remove-recent-btn"
            title="Remove from recent searches"
          >
            <i class="fas fa-times"></i>
          </button>
        </div>
      </div>
    </div>

    <!-- Popular Locations -->
    <div v-if="!searchQuery && !loading" class="glass-card popular-locations">
      <div class="popular-header">
        <h3>Popular Locations</h3>
      </div>
      
      <div class="popular-grid">
        <div
          v-for="location in popularLocations"
          :key="`popular-${location.lat}-${location.lon}`"
          class="popular-item"
          @click="selectLocation(location)"
        >
          <div class="popular-name">{{ location.name }}</div>
          <div class="popular-country">{{ location.country }}</div>
        </div>
      </div>
    </div>

    <!-- Search Tips (when no search query) -->
    <div v-if="!searchQuery && !loading" class="glass-card search-tips-card">
      <div class="tips-content">
        <h3>How to Search</h3>
        <div class="tips-grid">
          <div class="tip-item">
            <i class="fas fa-city"></i>
            <div>
              <strong>City Names</strong>
              <p>Search for any city worldwide</p>
            </div>
          </div>
          
          <div class="tip-item">
            <i class="fas fa-flag"></i>
            <div>
              <strong>Country Names</strong>
              <p>Add country for better accuracy</p>
            </div>
          </div>
          
          <div class="tip-item">
            <i class="fas fa-map-pin"></i>
            <div>
              <strong>Zip Codes</strong>
              <p>Use postal codes for precise locations</p>
            </div>
          </div>
          
          <div class="tip-item">
            <i class="fas fa-location-arrow"></i>
            <div>
              <strong>Current Location</strong>
              <p>Click the location button above</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useWeatherStore } from '../stores'

const router = useRouter()
const weatherStore = useWeatherStore()

// State
const searchQuery = ref('')
const hasSearched = ref(false)
const searchTimeout = ref(null)
const recentSearches = ref([])

// Computed
const searchResults = computed(() => weatherStore.searchResults)
const loading = computed(() => weatherStore.loading)

// Popular locations data
const popularLocations = ref([
  { name: 'New York', country: 'United States', lat: 40.7128, lon: -74.0060 },
  { name: 'London', country: 'United Kingdom', lat: 51.5074, lon: -0.1278 },
  { name: 'Tokyo', country: 'Japan', lat: 35.6762, lon: 139.6503 },
  { name: 'Paris', country: 'France', lat: 48.8566, lon: 2.3522 },
  { name: 'Sydney', country: 'Australia', lat: -33.8688, lon: 151.2093 },
  { name: 'Dubai', country: 'United Arab Emirates', lat: 25.2048, lon: 55.2708 },
  { name: 'Singapore', country: 'Singapore', lat: 1.3521, lon: 103.8198 },
  { name: 'Barcelona', country: 'Spain', lat: 41.3851, lon: 2.1734 }
])

// Methods
const handleSearchInput = () => {
  clearTimeout(searchTimeout.value)
  
  if (searchQuery.value.length >= 2) {
    searchTimeout.value = setTimeout(() => {
      performSearch()
    }, 500) // Debounce search
  }
}

const performSearch = async () => {
  if (!searchQuery.value || searchQuery.value.length < 2) return
  
  hasSearched.value = true
  await weatherStore.searchLocations(searchQuery.value)
}

const clearSearch = () => {
  searchQuery.value = ''
  hasSearched.value = false
  weatherStore.searchResults = []
}

const getCurrentLocation = async () => {
  try {
    await weatherStore.getCurrentLocation()
    router.push('/')
  } catch (error) {
    console.error('Failed to get current location:', error)
  }
}

const selectLocation = async (location) => {
  // Add to recent searches
  addToRecentSearches(location)
  
  // Fetch weather for selected location
  await weatherStore.fetchCurrentWeather(location.lat, location.lon)
  
  // Navigate to home
  router.push('/')
}

const formatLocationDetails = (location) => {
  const parts = []
  if (location.state) parts.push(location.state)
  if (location.country) parts.push(location.country)
  return parts.join(', ')
}

const isFavorite = (location) => {
  return weatherStore.isFavorite({
    name: location.name,
    country: location.country,
    coordinates: { lat: location.lat, lon: location.lon }
  })
}

const toggleFavorite = (location) => {
  const favoriteLocation = {
    name: location.name,
    country: location.country,
    coordinates: { lat: location.lat, lon: location.lon }
  }
  
  if (isFavorite(location)) {
    weatherStore.removeFromFavorites(favoriteLocation)
  } else {
    weatherStore.addToFavorites(favoriteLocation)
  }
}

// Recent searches management
const addToRecentSearches = (location) => {
  const recentItem = {
    name: location.name,
    country: location.country,
    state: location.state,
    lat: location.lat,
    lon: location.lon,
    timestamp: Date.now()
  }
  
  // Remove if already exists
  const existingIndex = recentSearches.value.findIndex(
    item => item.lat === location.lat && item.lon === location.lon
  )
  if (existingIndex > -1) {
    recentSearches.value.splice(existingIndex, 1)
  }
  
  // Add to beginning
  recentSearches.value.unshift(recentItem)
  
  // Keep only last 10
  if (recentSearches.value.length > 10) {
    recentSearches.value = recentSearches.value.slice(0, 10)
  }
  
  // Save to localStorage
  localStorage.setItem('weather-app-recent-searches', JSON.stringify(recentSearches.value))
}

const removeRecentSearch = (search) => {
  const index = recentSearches.value.findIndex(
    item => item.lat === search.lat && item.lon === search.lon
  )
  if (index > -1) {
    recentSearches.value.splice(index, 1)
    localStorage.setItem('weather-app-recent-searches', JSON.stringify(recentSearches.value))
  }
}

const clearRecentSearches = () => {
  recentSearches.value = []
  localStorage.removeItem('weather-app-recent-searches')
}

const loadRecentSearches = () => {
  const saved = localStorage.getItem('weather-app-recent-searches')
  if (saved) {
    recentSearches.value = JSON.parse(saved)
  }
}

// Lifecycle
onMounted(() => {
  loadRecentSearches()
})

// Clear search timeout on unmount
watch(() => searchQuery.value, () => {
  if (searchTimeout.value) {
    clearTimeout(searchTimeout.value)
  }
})
</script>

<style scoped>
.search-view {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  max-width: 800px;
  margin: 0 auto;
  padding: 1rem;
}

/* Search Header */
.search-header {
  padding: 1.5rem;
}

.search-container {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.search-input-wrapper {
  flex: 1;
  position: relative;
  display: flex;
  align-items: center;
}

.search-icon {
  position: absolute;
  left: 1rem;
  color: var(--text-secondary);
  z-index: 1;
}

.search-input {
  width: 100%;
  padding: 1rem 1rem 1rem 3rem;
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 25px;
  background: rgba(255, 255, 255, 0.1);
  color: var(--text-primary);
  font-size: 1rem;
  outline: none;
  transition: all 0.3s ease;
}

.search-input::placeholder {
  color: var(--text-secondary);
}

.search-input:focus {
  border-color: var(--accent-color);
  background: rgba(255, 255, 255, 0.15);
}

.clear-btn {
  position: absolute;
  right: 1rem;
  background: none;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 50%;
  transition: all 0.3s ease;
}

.clear-btn:hover {
  color: var(--text-primary);
  background: rgba(255, 255, 255, 0.1);
}

.location-btn {
  background: var(--accent-color);
  border: none;
  border-radius: 50%;
  width: 50px;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  cursor: pointer;
  transition: all 0.3s ease;
}

.location-btn:hover {
  background: var(--accent-hover);
  transform: scale(1.05);
}

.location-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.search-suggestions {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.suggestion-header {
  color: var(--text-secondary);
  font-size: 0.9rem;
}

/* Loading Card */
.loading-card {
  padding: 2rem;
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

/* Search Results */
.search-results {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.results-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 0.5rem;
}

.results-header h3 {
  font-size: 1.25rem;
  color: var(--text-primary);
  margin: 0;
}

.results-count {
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.results-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.result-item {
  padding: 1.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.result-item:hover {
  transform: translateY(-2px);
  background: rgba(255, 255, 255, 0.1);
}

.location-main {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 0.5rem;
}

.location-details h4 {
  font-size: 1.1rem;
  color: var(--text-primary);
  margin: 0 0 0.25rem 0;
}

.location-details p {
  color: var(--text-secondary);
  margin: 0;
  font-size: 0.9rem;
}

.location-actions {
  display: flex;
  gap: 0.5rem;
}

.favorite-btn {
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

.favorite-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  color: var(--text-primary);
}

.favorite-btn.favorited {
  background: rgba(239, 68, 68, 0.2);
  border-color: rgba(239, 68, 68, 0.3);
  color: #ef4444;
}

.location-coords {
  font-size: 0.8rem;
  color: var(--text-secondary);
  font-family: monospace;
}

/* No Results */
.no-results {
  padding: 3rem 2rem;
  text-align: center;
}

.no-results-content i {
  font-size: 3rem;
  color: var(--text-secondary);
  margin-bottom: 1rem;
}

.no-results-content h3 {
  color: var(--text-primary);
  margin-bottom: 0.5rem;
}

.no-results-content p {
  color: var(--text-secondary);
  margin-bottom: 2rem;
}

.search-tips {
  text-align: left;
  max-width: 400px;
  margin: 0 auto;
}

.search-tips h4 {
  color: var(--text-primary);
  margin-bottom: 1rem;
}

.search-tips ul {
  color: var(--text-secondary);
  padding-left: 1.5rem;
}

.search-tips li {
  margin-bottom: 0.5rem;
}

/* Recent Searches */
.recent-searches {
  padding: 1.5rem;
}

.recent-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.recent-header h3 {
  font-size: 1.25rem;
  color: var(--text-primary);
  margin: 0;
}

.clear-recent-btn {
  background: none;
  border: none;
  color: var(--accent-color);
  cursor: pointer;
  font-size: 0.9rem;
  transition: opacity 0.3s ease;
}

.clear-recent-btn:hover {
  opacity: 0.8;
}

.recent-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.recent-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  cursor: pointer;
  transition: all 0.3s ease;
}

.recent-item:hover {
  background: rgba(255, 255, 255, 0.1);
}

.recent-location {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.recent-location i {
  color: var(--text-secondary);
}

.recent-details {
  display: flex;
  flex-direction: column;
}

.recent-name {
  color: var(--text-primary);
  font-weight: 500;
}

.recent-info {
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.remove-recent-btn {
  background: none;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 50%;
  transition: all 0.3s ease;
}

.remove-recent-btn:hover {
  color: var(--text-primary);
  background: rgba(255, 255, 255, 0.1);
}

/* Popular Locations */
.popular-locations {
  padding: 1.5rem;
}

.popular-header h3 {
  font-size: 1.25rem;
  color: var(--text-primary);
  margin: 0 0 1rem 0;
}

.popular-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 0.75rem;
}

.popular-item {
  padding: 1rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: center;
}

.popular-item:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateY(-2px);
}

.popular-name {
  color: var(--text-primary);
  font-weight: 500;
  margin-bottom: 0.25rem;
}

.popular-country {
  color: var(--text-secondary);
  font-size: 0.9rem;
}

/* Search Tips Card */
.search-tips-card {
  padding: 1.5rem;
}

.tips-content h3 {
  font-size: 1.25rem;
  color: var(--text-primary);
  margin: 0 0 1.5rem 0;
}

.tips-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.tip-item {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
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
  .search-view {
    padding: 0.5rem;
  }

  .search-container {
    flex-direction: column;
    gap: 1rem;
  }

  .location-btn {
    width: 100%;
    border-radius: 25px;
    height: 50px;
  }

  .tips-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .popular-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .results-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
}
</style>
