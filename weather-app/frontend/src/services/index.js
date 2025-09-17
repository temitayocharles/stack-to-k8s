import axios from 'axios'

const API_BASE_URL = process.env.VUE_APP_API_URL || 'http://localhost:5001/api'

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// Request interceptor
api.interceptors.request.use(
  config => {
    console.log(`Making ${config.method.toUpperCase()} request to ${config.url}`)
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// Response interceptor
api.interceptors.response.use(
  response => response,
  error => {
    console.error('API Error:', error.response?.data || error.message)
    return Promise.reject(error)
  }
)

export class WeatherService {
  // Get current weather for coordinates
  async getCurrentWeather(lat, lon) {
    try {
      const response = await api.get('/weather/current', {
        params: { lat, lon }
      })
      return response.data
    } catch (error) {
      throw new Error(error.response?.data?.error || 'Failed to fetch current weather')
    }
  }

  // Get weather forecast
  async getForecast(lat, lon, days = 5) {
    try {
      const response = await api.get('/weather/forecast', {
        params: { lat, lon, days }
      })
      return response.data
    } catch (error) {
      throw new Error(error.response?.data?.error || 'Failed to fetch forecast')
    }
  }

  // Search for locations
  async searchLocations(query, limit = 5) {
    try {
      const response = await api.get('/locations/search', {
        params: { q: query, limit }
      })
      return response.data
    } catch (error) {
      throw new Error(error.response?.data?.error || 'Failed to search locations')
    }
  }

  // Get health status
  async getHealthStatus() {
    try {
      const response = await api.get('/health')
      return response.data
    } catch (error) {
      throw new Error('Weather service is unavailable')
    }
  }
}

export class GeolocationService {
  // Get user's current position
  getCurrentPosition() {
    return new Promise((resolve, reject) => {
      if (!navigator.geolocation) {
        reject(new Error('Geolocation is not supported by this browser'))
        return
      }

      navigator.geolocation.getCurrentPosition(
        position => {
          resolve({
            lat: position.coords.latitude,
            lon: position.coords.longitude,
            accuracy: position.coords.accuracy
          })
        },
        error => {
          let message = 'Unable to get location'
          switch (error.code) {
            case error.PERMISSION_DENIED:
              message = 'Location access denied by user'
              break
            case error.POSITION_UNAVAILABLE:
              message = 'Location information unavailable'
              break
            case error.TIMEOUT:
              message = 'Location request timed out'
              break
          }
          reject(new Error(message))
        },
        {
          enableHighAccuracy: true,
          timeout: 10000,
          maximumAge: 300000 // 5 minutes
        }
      )
    })
  }

  // Watch position changes
  watchPosition(callback, errorCallback) {
    if (!navigator.geolocation) {
      errorCallback(new Error('Geolocation is not supported'))
      return null
    }

    return navigator.geolocation.watchPosition(
      position => {
        callback({
          lat: position.coords.latitude,
          lon: position.coords.longitude,
          accuracy: position.coords.accuracy
        })
      },
      error => {
        errorCallback(new Error('Failed to watch position'))
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 300000
      }
    )
  }
}

export class StorageService {
  // Save favorite locations
  saveFavoriteLocations(locations) {
    try {
      localStorage.setItem('weather_favorites', JSON.stringify(locations))
    } catch (error) {
      console.error('Failed to save favorites:', error)
    }
  }

  // Get favorite locations
  getFavoriteLocations() {
    try {
      const data = localStorage.getItem('weather_favorites')
      return data ? JSON.parse(data) : []
    } catch (error) {
      console.error('Failed to load favorites:', error)
      return []
    }
  }

  // Save last searched location
  saveLastLocation(location) {
    try {
      localStorage.setItem('weather_last_location', JSON.stringify(location))
    } catch (error) {
      console.error('Failed to save last location:', error)
    }
  }

  // Get last searched location
  getLastLocation() {
    try {
      const data = localStorage.getItem('weather_last_location')
      return data ? JSON.parse(data) : null
    } catch (error) {
      console.error('Failed to load last location:', error)
      return null
    }
  }

  // Save user preferences
  savePreferences(preferences) {
    try {
      localStorage.setItem('weather_preferences', JSON.stringify(preferences))
    } catch (error) {
      console.error('Failed to save preferences:', error)
    }
  }

  // Get user preferences
  getPreferences() {
    try {
      const data = localStorage.getItem('weather_preferences')
      return data ? JSON.parse(data) : {
        temperatureUnit: 'celsius',
        windUnit: 'kmh',
        timeFormat: '24h',
        theme: 'auto'
      }
    } catch (error) {
      console.error('Failed to load preferences:', error)
      return {
        temperatureUnit: 'celsius',
        windUnit: 'kmh',
        timeFormat: '24h',
        theme: 'auto'
      }
    }
  }
}

// Export service instances
export const weatherService = new WeatherService()
export const geolocationService = new GeolocationService()
export const storageService = new StorageService()
