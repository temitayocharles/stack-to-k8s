<template>
  <teleport to="body">
    <transition name="modal">
      <div v-if="isOpen" class="modal-overlay" @click="closeModal">
        <div class="modal-container" @click.stop>
          <div class="modal-header">
            <h2>Settings</h2>
            <button @click="closeModal" class="close-btn">
              <i class="fas fa-times"></i>
            </button>
          </div>

          <div class="modal-content">
            <!-- Theme Settings -->
            <div class="settings-section">
              <h3>
                <i class="fas fa-palette"></i>
                Appearance
              </h3>
              
              <div class="setting-item">
                <div class="setting-info">
                  <label>Theme</label>
                  <p>Choose between light and dark mode</p>
                </div>
                <div class="setting-control">
                  <div class="theme-toggle">
                    <button
                      @click="setTheme('light')"
                      class="theme-btn"
                      :class="{ 'active': theme === 'light' }"
                    >
                      <i class="fas fa-sun"></i>
                      Light
                    </button>
                    <button
                      @click="setTheme('dark')"
                      class="theme-btn"
                      :class="{ 'active': theme === 'dark' }"
                    >
                      <i class="fas fa-moon"></i>
                      Dark
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Units Settings -->
            <div class="settings-section">
              <h3>
                <i class="fas fa-thermometer-half"></i>
                Units
              </h3>
              
              <div class="setting-item">
                <div class="setting-info">
                  <label>Temperature & Wind</label>
                  <p>Choose your preferred unit system</p>
                </div>
                <div class="setting-control">
                  <div class="units-toggle">
                    <button
                      @click="setUnits('metric')"
                      class="units-btn"
                      :class="{ 'active': units === 'metric' }"
                    >
                      <div class="units-main">Metric</div>
                      <div class="units-sub">°C, m/s, km</div>
                    </button>
                    <button
                      @click="setUnits('imperial')"
                      class="units-btn"
                      :class="{ 'active': units === 'imperial' }"
                    >
                      <div class="units-main">Imperial</div>
                      <div class="units-sub">°F, mph, mi</div>
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Language Settings -->
            <div class="settings-section">
              <h3>
                <i class="fas fa-language"></i>
                Language
              </h3>
              
              <div class="setting-item">
                <div class="setting-info">
                  <label>Interface Language</label>
                  <p>Change the app language</p>
                </div>
                <div class="setting-control">
                  <select v-model="language" @change="updateLanguage" class="language-select">
                    <option value="en">English</option>
                    <option value="es">Español</option>
                    <option value="fr">Français</option>
                    <option value="de">Deutsch</option>
                    <option value="it">Italiano</option>
                    <option value="pt">Português</option>
                    <option value="ru">Русский</option>
                    <option value="zh">中文</option>
                    <option value="ja">日本語</option>
                    <option value="ko">한국어</option>
                  </select>
                </div>
              </div>
            </div>

            <!-- Notifications Settings -->
            <div class="settings-section">
              <h3>
                <i class="fas fa-bell"></i>
                Notifications
              </h3>
              
              <div class="setting-item">
                <div class="setting-info">
                  <label>Weather Alerts</label>
                  <p>Get notified about weather updates</p>
                </div>
                <div class="setting-control">
                  <button
                    @click="toggleNotifications"
                    class="toggle-btn"
                    :class="{ 'active': notifications }"
                  >
                    <div class="toggle-slider">
                      <div class="toggle-thumb"></div>
                    </div>
                    <span>{{ notifications ? 'Enabled' : 'Disabled' }}</span>
                  </button>
                </div>
              </div>
            </div>

            <!-- Auto Refresh Settings -->
            <div class="settings-section">
              <h3>
                <i class="fas fa-sync-alt"></i>
                Auto Refresh
              </h3>
              
              <div class="setting-item">
                <div class="setting-info">
                  <label>Automatic Updates</label>
                  <p>Automatically refresh weather data</p>
                </div>
                <div class="setting-control">
                  <button
                    @click="toggleAutoRefresh"
                    class="toggle-btn"
                    :class="{ 'active': autoRefresh }"
                  >
                    <div class="toggle-slider">
                      <div class="toggle-thumb"></div>
                    </div>
                    <span>{{ autoRefresh ? 'Enabled' : 'Disabled' }}</span>
                  </button>
                </div>
              </div>

              <div v-if="autoRefresh" class="setting-item">
                <div class="setting-info">
                  <label>Refresh Interval</label>
                  <p>How often to update weather data</p>
                </div>
                <div class="setting-control">
                  <select v-model="refreshInterval" @change="updateRefreshInterval" class="interval-select">
                    <option :value="5">Every 5 minutes</option>
                    <option :value="10">Every 10 minutes</option>
                    <option :value="15">Every 15 minutes</option>
                    <option :value="30">Every 30 minutes</option>
                    <option :value="60">Every hour</option>
                  </select>
                </div>
              </div>
            </div>

            <!-- Data & Privacy -->
            <div class="settings-section">
              <h3>
                <i class="fas fa-shield-alt"></i>
                Data & Privacy
              </h3>
              
              <div class="setting-item">
                <div class="setting-info">
                  <label>Location Data</label>
                  <p>How your location data is used</p>
                </div>
                <div class="setting-control">
                  <div class="privacy-info">
                    <i class="fas fa-info-circle"></i>
                    <span>Location data is only used to fetch weather information and is not stored permanently</span>
                  </div>
                </div>
              </div>

              <div class="setting-item">
                <div class="setting-info">
                  <label>Clear Data</label>
                  <p>Remove all saved preferences and favorites</p>
                </div>
                <div class="setting-control">
                  <button @click="clearAllData" class="danger-btn">
                    <i class="fas fa-trash"></i>
                    Clear All Data
                  </button>
                </div>
              </div>
            </div>

            <!-- About -->
            <div class="settings-section">
              <h3>
                <i class="fas fa-info-circle"></i>
                About
              </h3>
              
              <div class="about-info">
                <div class="about-item">
                  <strong>Weather App</strong>
                  <span>Version 1.0.0</span>
                </div>
                <div class="about-item">
                  <strong>Weather Data</strong>
                  <span>Powered by OpenWeather API</span>
                </div>
                <div class="about-item">
                  <strong>Built with</strong>
                  <span>Vue 3, Python Flask, Redis</span>
                </div>
              </div>
            </div>
          </div>

          <div class="modal-footer">
            <button @click="resetToDefaults" class="reset-btn">
              <i class="fas fa-undo"></i>
              Reset to Defaults
            </button>
            <button @click="saveAndClose" class="save-btn">
              <i class="fas fa-check"></i>
              Save Changes
            </button>
          </div>
        </div>
      </div>
    </transition>
  </teleport>
</template>

<script setup>
import { computed, watch } from 'vue'
import { useSettingsStore } from '../stores'
import { useToast } from 'vue-toastification'

const settingsStore = useSettingsStore()
const toast = useToast()

// Computed properties
const isOpen = computed(() => settingsStore.isSettingsOpen)
const theme = computed({
  get: () => settingsStore.theme,
  set: (value) => settingsStore.theme = value
})
const units = computed({
  get: () => settingsStore.units,
  set: (value) => settingsStore.units = value
})
const language = computed({
  get: () => settingsStore.language,
  set: (value) => settingsStore.language = value
})
const notifications = computed(() => settingsStore.notifications)
const autoRefresh = computed(() => settingsStore.autoRefresh)
const refreshInterval = computed({
  get: () => settingsStore.refreshInterval,
  set: (value) => settingsStore.refreshInterval = value
})

// Methods
const closeModal = () => {
  settingsStore.closeSettings()
}

const setTheme = (newTheme) => {
  theme.value = newTheme
  settingsStore.toggleTheme()
}

const setUnits = (newUnits) => {
  units.value = newUnits
  settingsStore.setUnits(newUnits)
}

const updateLanguage = () => {
  settingsStore.setLanguage(language.value)
  toast.info('Language updated')
}

const toggleNotifications = () => {
  settingsStore.toggleNotifications()
  const message = notifications.value ? 'Notifications enabled' : 'Notifications disabled'
  toast.info(message)
}

const toggleAutoRefresh = () => {
  settingsStore.toggleAutoRefresh()
  const message = autoRefresh.value ? 'Auto refresh enabled' : 'Auto refresh disabled'
  toast.info(message)
}

const updateRefreshInterval = () => {
  settingsStore.setRefreshInterval(refreshInterval.value)
  toast.info(`Refresh interval set to ${refreshInterval.value} minutes`)
}

const clearAllData = () => {
  if (confirm('This will remove all your saved preferences, favorites, and data. This action cannot be undone. Continue?')) {
    // Clear all localStorage data
    localStorage.clear()
    
    // Reset settings to defaults
    resetToDefaults()
    
    toast.success('All data cleared successfully')
  }
}

const resetToDefaults = () => {
  if (confirm('Reset all settings to default values?')) {
    // Reset to default values
    settingsStore.theme = 'light'
    settingsStore.units = 'metric'
    settingsStore.language = 'en'
    settingsStore.notifications = true
    settingsStore.autoRefresh = true
    settingsStore.refreshInterval = 10
    
    // Apply theme change
    document.documentElement.classList.remove('dark')
    
    toast.success('Settings reset to defaults')
  }
}

const saveAndClose = () => {
  settingsStore.saveSettings()
  toast.success('Settings saved successfully')
  closeModal()
}

// Watch for settings changes and auto-save
watch([theme, units, language, notifications, autoRefresh, refreshInterval], () => {
  settingsStore.saveSettings()
}, { deep: true })

// Close modal on Escape key
const handleKeydown = (event) => {
  if (event.key === 'Escape' && isOpen.value) {
    closeModal()
  }
}

// Add event listener
if (typeof window !== 'undefined') {
  window.addEventListener('keydown', handleKeydown)
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 1rem;
}

.modal-container {
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  border: 1px solid var(--glass-border);
  border-radius: 16px;
  width: 100%;
  max-width: 600px;
  max-height: 90vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.modal-header h2 {
  font-size: 1.5rem;
  color: var(--text-primary);
  margin: 0;
}

.close-btn {
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

.close-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  color: var(--text-primary);
}

.modal-content {
  flex: 1;
  overflow-y: auto;
  padding: 1.5rem;
}

.settings-section {
  margin-bottom: 2rem;
}

.settings-section:last-child {
  margin-bottom: 0;
}

.settings-section h3 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.1rem;
  color: var(--text-primary);
  margin: 0 0 1rem 0;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.settings-section h3 i {
  color: var(--accent-color);
}

.setting-item {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1.5rem;
  gap: 1rem;
}

.setting-item:last-child {
  margin-bottom: 0;
}

.setting-info {
  flex: 1;
}

.setting-info label {
  display: block;
  font-weight: 500;
  color: var(--text-primary);
  margin-bottom: 0.25rem;
}

.setting-info p {
  font-size: 0.9rem;
  color: var(--text-secondary);
  margin: 0;
}

.setting-control {
  display: flex;
  align-items: center;
}

/* Theme Toggle */
.theme-toggle {
  display: flex;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  overflow: hidden;
}

.theme-btn {
  background: none;
  border: none;
  padding: 0.75rem 1rem;
  color: var(--text-secondary);
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
}

.theme-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  color: var(--text-primary);
}

.theme-btn.active {
  background: var(--accent-color);
  color: white;
}

/* Units Toggle */
.units-toggle {
  display: flex;
  gap: 0.5rem;
}

.units-btn {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  padding: 0.75rem;
  color: var(--text-primary);
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 80px;
  text-align: center;
}

.units-btn:hover {
  background: rgba(255, 255, 255, 0.1);
}

.units-btn.active {
  background: rgba(var(--accent-color-rgb), 0.2);
  border-color: var(--accent-color);
  color: var(--accent-color);
}

.units-main {
  font-weight: 500;
  margin-bottom: 0.25rem;
}

.units-sub {
  font-size: 0.8rem;
  opacity: 0.8;
}

/* Select Inputs */
.language-select,
.interval-select {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  padding: 0.5rem 0.75rem;
  color: var(--text-primary);
  font-size: 0.9rem;
  cursor: pointer;
  min-width: 150px;
}

.language-select:focus,
.interval-select:focus {
  outline: none;
  border-color: var(--accent-color);
  background: rgba(255, 255, 255, 0.1);
}

/* Toggle Button */
.toggle-btn {
  background: none;
  border: none;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 20px;
  transition: all 0.3s ease;
}

.toggle-slider {
  width: 44px;
  height: 24px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  position: relative;
  transition: all 0.3s ease;
}

.toggle-thumb {
  width: 20px;
  height: 20px;
  background: white;
  border-radius: 50%;
  position: absolute;
  top: 2px;
  left: 2px;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.toggle-btn.active .toggle-slider {
  background: var(--accent-color);
}

.toggle-btn.active .toggle-thumb {
  transform: translateX(20px);
}

.toggle-btn span {
  color: var(--text-primary);
  font-size: 0.9rem;
}

/* Privacy Info */
.privacy-info {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
  padding: 0.75rem;
  background: rgba(var(--accent-color-rgb), 0.1);
  border-radius: 8px;
  border: 1px solid rgba(var(--accent-color-rgb), 0.2);
  max-width: 250px;
}

.privacy-info i {
  color: var(--accent-color);
  margin-top: 0.125rem;
}

.privacy-info span {
  font-size: 0.8rem;
  color: var(--text-secondary);
  line-height: 1.4;
}

/* Danger Button */
.danger-btn {
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.3);
  border-radius: 8px;
  padding: 0.5rem 0.75rem;
  color: #ef4444;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
}

.danger-btn:hover {
  background: rgba(239, 68, 68, 0.2);
}

/* About Section */
.about-info {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.about-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.about-item strong {
  color: var(--text-primary);
}

.about-item span {
  color: var(--text-secondary);
  font-size: 0.9rem;
}

/* Modal Footer */
.modal-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  gap: 1rem;
}

.reset-btn,
.save-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
  font-size: 0.9rem;
}

.reset-btn {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: var(--text-primary);
}

.reset-btn:hover {
  background: rgba(255, 255, 255, 0.2);
}

.save-btn {
  background: var(--accent-color);
  color: white;
}

.save-btn:hover {
  background: var(--accent-hover);
}

/* Modal Transitions */
.modal-enter-active,
.modal-leave-active {
  transition: all 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
  transform: scale(0.9);
}

/* Scrollbar Styling */
.modal-content::-webkit-scrollbar {
  width: 6px;
}

.modal-content::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.05);
  border-radius: 3px;
}

.modal-content::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 3px;
}

.modal-content::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.3);
}

/* Responsive Design */
@media (max-width: 768px) {
  .modal-overlay {
    padding: 0.5rem;
  }

  .modal-container {
    max-height: 95vh;
  }

  .modal-header,
  .modal-content,
  .modal-footer {
    padding: 1rem;
  }

  .setting-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.75rem;
  }

  .units-toggle {
    width: 100%;
  }

  .units-btn {
    flex: 1;
  }

  .modal-footer {
    flex-direction: column;
  }

  .reset-btn,
  .save-btn {
    width: 100%;
    justify-content: center;
  }

  .privacy-info {
    max-width: none;
  }
}
</style>
