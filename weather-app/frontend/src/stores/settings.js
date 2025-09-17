import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useSettingsStore = defineStore('settings', () => {
  // State
  const isSettingsOpen = ref(false)
  const theme = ref('light')
  const units = ref('metric') // metric, imperial
  const language = ref('en')
  const notifications = ref(true)
  const autoRefresh = ref(true)
  const refreshInterval = ref(10) // minutes

  // Actions
  const openSettings = () => {
    isSettingsOpen.value = true
  }

  const closeSettings = () => {
    isSettingsOpen.value = false
  }

  const toggleTheme = () => {
    theme.value = theme.value === 'light' ? 'dark' : 'light'
    document.documentElement.classList.toggle('dark', theme.value === 'dark')
  }

  const setUnits = (unit) => {
    units.value = unit
  }

  const setLanguage = (lang) => {
    language.value = lang
  }

  const toggleNotifications = () => {
    notifications.value = !notifications.value
  }

  const toggleAutoRefresh = () => {
    autoRefresh.value = !autoRefresh.value
  }

  const setRefreshInterval = (interval) => {
    refreshInterval.value = interval
  }

  // Initialize settings from localStorage
  const initializeSettings = () => {
    const savedTheme = localStorage.getItem('weather-app-theme')
    if (savedTheme) {
      theme.value = savedTheme
      document.documentElement.classList.toggle('dark', theme.value === 'dark')
    }

    const savedUnits = localStorage.getItem('weather-app-units')
    if (savedUnits) {
      units.value = savedUnits
    }

    const savedLanguage = localStorage.getItem('weather-app-language')
    if (savedLanguage) {
      language.value = savedLanguage
    }

    const savedNotifications = localStorage.getItem('weather-app-notifications')
    if (savedNotifications !== null) {
      notifications.value = JSON.parse(savedNotifications)
    }

    const savedAutoRefresh = localStorage.getItem('weather-app-auto-refresh')
    if (savedAutoRefresh !== null) {
      autoRefresh.value = JSON.parse(savedAutoRefresh)
    }

    const savedRefreshInterval = localStorage.getItem('weather-app-refresh-interval')
    if (savedRefreshInterval) {
      refreshInterval.value = parseInt(savedRefreshInterval)
    }
  }

  // Save settings to localStorage
  const saveSettings = () => {
    localStorage.setItem('weather-app-theme', theme.value)
    localStorage.setItem('weather-app-units', units.value)
    localStorage.setItem('weather-app-language', language.value)
    localStorage.setItem('weather-app-notifications', JSON.stringify(notifications.value))
    localStorage.setItem('weather-app-auto-refresh', JSON.stringify(autoRefresh.value))
    localStorage.setItem('weather-app-refresh-interval', refreshInterval.value.toString())
  }

  return {
    // State
    isSettingsOpen,
    theme,
    units,
    language,
    notifications,
    autoRefresh,
    refreshInterval,

    // Actions
    openSettings,
    closeSettings,
    toggleTheme,
    setUnits,
    setLanguage,
    toggleNotifications,
    toggleAutoRefresh,
    setRefreshInterval,
    initializeSettings,
    saveSettings
  }
})
