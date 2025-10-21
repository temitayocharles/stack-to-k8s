<template>
  <div id="app" :class="['min-h-screen transition-colors duration-300', weatherBg]">
    <!-- Navigation -->
    <nav class="glass-card nav-bar">
      <div class="nav-content">
        <div class="nav-brand">
          <i class="fas fa-cloud-sun nav-icon"></i>
          <h1 class="nav-title">WeatherVue</h1>
        </div>
        
        <div class="nav-menu">
          <router-link to="/" class="nav-link" exact-active-class="active">
            <i class="fas fa-home"></i>
            <span>Home</span>
          </router-link>
          
          <router-link to="/search" class="nav-link" active-class="active">
            <i class="fas fa-search"></i>
            <span>Search</span>
          </router-link>
          
          <router-link to="/forecast" class="nav-link" active-class="active">
            <i class="fas fa-calendar-alt"></i>
            <span>Forecast</span>
          </router-link>

          <!-- New ML Features -->
          <router-link to="/ml-forecast" class="nav-link" active-class="active">
            <i class="fas fa-brain"></i>
            <span>ML Forecast</span>
          </router-link>

          <router-link to="/air-quality" class="nav-link" active-class="active">
            <i class="fas fa-lungs"></i>
            <span>Air Quality</span>
          </router-link>

          <router-link to="/alerts" class="nav-link" active-class="active">
            <i class="fas fa-exclamation-triangle"></i>
            <span>Alerts</span>
          </router-link>

          <router-link to="/analytics" class="nav-link" active-class="active">
            <i class="fas fa-chart-line"></i>
            <span>Analytics</span>
          </router-link>
          
          <router-link to="/favorites" class="nav-link" active-class="active">
            <i class="fas fa-heart"></i>
            <span>Favorites</span>
            <span v-if="favorites.length > 0" class="favorites-count">{{ favorites.length }}</span>
          </router-link>
        </div>
        
        <div class="nav-actions">
          <button
            @click="refreshWeather"
            :disabled="loading"
            class="nav-btn"
            :class="{ 'loading': loading }"
            title="Refresh weather data"
          >
            <i class="fas fa-sync-alt"></i>
          </button>
          
          <button
            @click="openSettings"
            class="nav-btn"
            title="Settings"
          >
            <i class="fas fa-cog"></i>
          </button>
        </div>
      </div>
    </nav>

    <!-- Main Content -->
    <main class="main-content">
      <router-view />
    </main>

    <!-- Settings Modal -->
    <SettingsModal />

    <!-- Loading Overlay -->
    <div 
      v-if="loading && !hasWeatherData" 
      class="loading-overlay"
    >
      <div class="loading-content glass-card">
        <div class="loading-spinner"></div>
        <p>Loading weather data...</p>
      </div>
    </div>

    <!-- Error Toast Container -->
    <div id="toast-container"></div>
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useWeatherStore, useSettingsStore } from './stores'
import SettingsModal from './components/SettingsModal.vue'

const weatherStore = useWeatherStore()
const settingsStore = useSettingsStore()

// Computed properties
const loading = computed(() => weatherStore.loading)
const favorites = computed(() => weatherStore.favorites)
const currentWeather = computed(() => weatherStore.currentWeather)
const weatherCondition = computed(() => weatherStore.weatherCondition)

const hasWeatherData = computed(() => !!currentWeather.value)

const weatherBg = computed(() => {
  const condition = weatherCondition.value
  const theme = settingsStore.theme
  
  if (theme === 'dark') {
    switch (condition) {
      case 'sunny':
        return 'bg-gradient-to-br from-yellow-900 via-orange-900 to-red-900'
      case 'cloudy':
        return 'bg-gradient-to-br from-gray-800 via-gray-900 to-black'
      case 'rainy':
        return 'bg-gradient-to-br from-slate-800 via-slate-900 to-black'
      case 'snowy':
        return 'bg-gradient-to-br from-slate-700 via-slate-800 to-slate-900'
      case 'stormy':
        return 'bg-gradient-to-br from-purple-900 via-gray-900 to-black'
      default:
        return 'bg-gradient-to-br from-blue-900 via-blue-800 to-indigo-900'
    }
  } else {
    switch (condition) {
      case 'sunny':
        return 'bg-gradient-to-br from-yellow-400 via-orange-400 to-red-400'
      case 'cloudy':
        return 'bg-gradient-to-br from-gray-400 via-gray-500 to-gray-600'
      case 'rainy':
        return 'bg-gradient-to-br from-slate-400 via-slate-500 to-slate-600'
      case 'snowy':
        return 'bg-gradient-to-br from-blue-200 via-blue-300 to-blue-400'
      case 'stormy':
        return 'bg-gradient-to-br from-purple-500 via-gray-600 to-gray-700'
      default:
        return 'bg-gradient-to-br from-blue-400 via-blue-500 to-blue-600'
    }
  }
})

// Methods
const refreshWeather = async () => {
  await weatherStore.refreshWeather()
}

const openSettings = () => {
  settingsStore.openSettings()
}

// Initialize app on mount
onMounted(async () => {
  settingsStore.initializeSettings()
  await weatherStore.initializeApp()
})
</script>

<style scoped>
/* Navigation Styles */
.nav-bar {
  margin: 1rem;
  padding: 1rem 1.5rem;
  position: sticky;
  top: 1rem;
  z-index: 100;
}

.nav-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  max-width: 1200px;
  margin: 0 auto;
}

.nav-brand {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.nav-icon {
  font-size: 2rem;
  color: var(--accent-color);
}

.nav-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--text-primary);
  margin: 0;
}

.nav-menu {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.nav-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  border-radius: 12px;
  color: var(--text-secondary);
  text-decoration: none;
  transition: all 0.3s ease;
  position: relative;
  font-size: 0.9rem;
  font-weight: 500;
}

.nav-link:hover {
  background: rgba(255, 255, 255, 0.1);
  color: var(--text-primary);
  transform: translateY(-1px);
}

.nav-link.active {
  background: rgba(var(--accent-color-rgb), 0.2);
  color: var(--accent-color);
  border: 1px solid rgba(var(--accent-color-rgb), 0.3);
}

.nav-link i {
  font-size: 1rem;
}

.favorites-count {
  background: var(--accent-color);
  color: white;
  border-radius: 50%;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.7rem;
  font-weight: 600;
  margin-left: 0.25rem;
}

.nav-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.nav-btn {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-secondary);
  cursor: pointer;
  transition: all 0.3s ease;
}

.nav-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  color: var(--text-primary);
  transform: translateY(-1px);
}

.nav-btn.loading {
  animation: spin 1s linear infinite;
}

/* Main Content */
.main-content {
  padding: 0 1rem 2rem 1rem;
}

/* Loading Overlay */
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.3);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.loading-content {
  padding: 2rem;
  text-align: center;
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

.loading-content p {
  color: var(--text-primary);
  margin: 0;
}

/* Animations */
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* Responsive Design */
@media (max-width: 768px) {
  .nav-bar {
    margin: 0.5rem;
    padding: 1rem;
  }

  .nav-content {
    flex-direction: column;
    gap: 1rem;
  }

  .nav-menu {
    order: 3;
    width: 100%;
    justify-content: space-around;
    background: rgba(255, 255, 255, 0.05);
    border-radius: 12px;
    padding: 0.5rem;
  }

  .nav-link {
    flex-direction: column;
    gap: 0.25rem;
    padding: 0.5rem;
    font-size: 0.8rem;
    flex: 1;
    text-align: center;
  }

  .nav-link span {
    display: block;
  }

  .nav-actions {
    order: 2;
  }

  .main-content {
    padding: 0 0.5rem 1rem 0.5rem;
  }
}

@media (max-width: 480px) {
  .nav-link span {
    display: none;
  }

  .nav-link {
    flex-direction: row;
    justify-content: center;
  }
}
</style>
