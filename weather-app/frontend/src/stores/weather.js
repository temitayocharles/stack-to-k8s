import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { useToast } from 'vue-toastification'
import { 
  weatherService, 
  geolocationService, 
  storageService 
} from '../services'

export const useWeatherStore = defineStore('weather', () => {
  // State
  const currentWeather = ref(null)
  const forecast = ref([])
  const currentLocation = ref(null)
  const searchResults = ref([])
  const favorites = ref([])
  const preferences = ref({})
  const loading = ref(false)
  const error = ref(null)

  // Toast instance
  const toast = useToast()

  // Computed
  const hasCurrentWeather = computed(() => !!currentWeather.value)
  const hasForecast = computed(() => forecast.value.length > 0)
  const weatherCondition = computed(() => {
    if (!currentWeather.value) return 'default'
    const main = currentWeather.value.current.weather.main.toLowerCase()
    
    switch (main) {
      case 'clear':
        return 'sunny'
      case 'clouds':
        return 'cloudy'
      case 'rain':
      case 'drizzle':
        return 'rainy'
      case 'snow':
        return 'snowy'
      case 'thunderstorm':
        return 'stormy'
      default:
        return 'default'
    }
  })

  // Actions
  const setLoading = (value) => {
    loading.value = value
  }

  const setError = (message) => {
    error.value = message
    if (message) {
      toast.error(message)
    }
  }

  const clearError = () => {
    error.value = null
  }

  // Fetch current weather
  const fetchCurrentWeather = async (lat, lon) => {
    try {
      setLoading(true)
      clearError()
      
      const data = await weatherService.getCurrentWeather(lat, lon)
      currentWeather.value = data
      
      // Save as last location
      const locationData = {
        name: data.location.name,
        country: data.location.country,
        coordinates: { lat, lon }
      }
      currentLocation.value = locationData
      storageService.saveLastLocation(locationData)
      
      toast.success(`Weather updated for ${data.location.name}`)
      return data
    } catch (error) {
      setError(error.message)
      throw error
    } finally {
      setLoading(false)
    }
  }

  // Fetch forecast
  const fetchForecast = async (lat, lon, days = 5) => {
    try {
      setLoading(true)
      clearError()
      
      const data = await weatherService.getForecast(lat, lon, days)
      forecast.value = data.forecast
      
      return data.forecast
    } catch (error) {
      setError(error.message)
      throw error
    } finally {
      setLoading(false)
    }
  }

  // Search locations
  const searchLocations = async (query) => {
    if (!query || query.length < 2) {
      searchResults.value = []
      return []
    }

    try {
      setLoading(true)
      clearError()
      
      const data = await weatherService.searchLocations(query)
      searchResults.value = data.locations
      
      return data.locations
    } catch (error) {
      setError(error.message)
      searchResults.value = []
      return []
    } finally {
      setLoading(false)
    }
  }

  // Get user's current location
  const getCurrentLocation = async () => {
    try {
      setLoading(true)
      clearError()
      
      const position = await geolocationService.getCurrentPosition()
      await fetchCurrentWeather(position.lat, position.lon)
      
      toast.success('Location detected successfully')
      return position
    } catch (error) {
      setError(error.message)
      throw error
    } finally {
      setLoading(false)
    }
  }

  // Add to favorites
  const addToFavorites = (location) => {
    const exists = favorites.value.some(
      fav => fav.coordinates.lat === location.coordinates.lat && 
             fav.coordinates.lon === location.coordinates.lon
    )
    
    if (!exists) {
      favorites.value.push(location)
      storageService.saveFavoriteLocations(favorites.value)
      toast.success(`${location.name} added to favorites`)
    } else {
      toast.info(`${location.name} is already in favorites`)
    }
  }

  // Remove from favorites
  const removeFromFavorites = (location) => {
    const index = favorites.value.findIndex(
      fav => fav.coordinates.lat === location.coordinates.lat && 
             fav.coordinates.lon === location.coordinates.lon
    )
    
    if (index > -1) {
      favorites.value.splice(index, 1)
      storageService.saveFavoriteLocations(favorites.value)
      toast.success(`${location.name} removed from favorites`)
    }
  }

  // Check if location is in favorites
  const isFavorite = (location) => {
    return favorites.value.some(
      fav => fav.coordinates.lat === location.coordinates.lat && 
             fav.coordinates.lon === location.coordinates.lon
    )
  }

  // Update preferences
  const updatePreferences = (newPreferences) => {
    preferences.value = { ...preferences.value, ...newPreferences }
    storageService.savePreferences(preferences.value)
    toast.success('Preferences updated')
  }

  // Load saved data
  const loadSavedData = () => {
    favorites.value = storageService.getFavoriteLocations()
    preferences.value = storageService.getPreferences()
    
    const lastLocation = storageService.getLastLocation()
    if (lastLocation) {
      currentLocation.value = lastLocation
    }
  }

  // Initialize app
  const initializeApp = async () => {
    loadSavedData()
    
    // Try to load last location or get current location
    if (currentLocation.value) {
      try {
        await fetchCurrentWeather(
          currentLocation.value.coordinates.lat,
          currentLocation.value.coordinates.lon
        )
      } catch (error) {
        console.warn('Failed to load last location weather:', error)
      }
    } else {
      try {
        await getCurrentLocation()
      } catch (error) {
        console.warn('Failed to get current location:', error)
        toast.info('Please search for a location or allow location access')
      }
    }
  }

  // Refresh current weather
  const refreshWeather = async () => {
    if (currentLocation.value) {
      await fetchCurrentWeather(
        currentLocation.value.coordinates.lat,
        currentLocation.value.coordinates.lon
      )
    }
  }

  return {
    // State
    currentWeather,
    forecast,
    currentLocation,
    searchResults,
    favorites,
    preferences,
    loading,
    error,
    
    // Computed
    hasCurrentWeather,
    hasForecast,
    weatherCondition,
    
    // Actions
    fetchCurrentWeather,
    fetchForecast,
    searchLocations,
    getCurrentLocation,
    addToFavorites,
    removeFromFavorites,
    isFavorite,
    updatePreferences,
    initializeApp,
    refreshWeather,
    setLoading,
    setError,
    clearError
  }
})
