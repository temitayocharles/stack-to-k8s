<template>
  <div class="alerts-page">
    <!-- Page Header -->
    <div class="page-header glass-card">
      <div class="header-content">
        <div class="header-title">
          <i class="fas fa-exclamation-triangle header-icon"></i>
          <div>
            <h1>Weather Alerts</h1>
            <p>Real-time severe weather monitoring and emergency notifications</p>
          </div>
        </div>
        
        <div class="header-actions">
          <div class="alert-controls">
            <select v-model="selectedCity" @change="loadAlerts" class="control-select">
              <option value="London">London</option>
              <option value="New York">New York</option>
              <option value="Tokyo">Tokyo</option>
              <option value="Miami">Miami</option>
              <option value="Sydney">Sydney</option>
            </select>
            
            <select v-model="alertType" @change="loadAlerts" class="control-select">
              <option value="all">All Types</option>
              <option value="temperature">Temperature</option>
              <option value="precipitation">Precipitation</option>
              <option value="wind">Wind</option>
            </select>
            
            <button @click="loadAlerts" :disabled="loading" class="refresh-btn">
              <i class="fas fa-sync-alt" :class="{ 'spinning': loading }"></i>
              Refresh
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Alert Status Summary -->
    <div v-if="alertData" class="alert-summary glass-card">
      <div class="summary-stats">
        <div class="stat-item" :class="{ 'has-alerts': alertData.alert_statistics.total_active > 0 }">
          <div class="stat-value">{{ alertData.alert_statistics.total_active }}</div>
          <div class="stat-label">Active Alerts</div>
        </div>
        
        <div class="stat-item severity-high">
          <div class="stat-value">{{ alertData.alert_statistics.high_severity }}</div>
          <div class="stat-label">High Severity</div>
        </div>
        
        <div class="stat-item severity-moderate">
          <div class="stat-value">{{ alertData.alert_statistics.moderate_severity }}</div>
          <div class="stat-label">Moderate</div>
        </div>
        
        <div class="stat-item severity-low">
          <div class="stat-value">{{ alertData.alert_statistics.low_severity }}</div>
          <div class="stat-label">Low Severity</div>
        </div>
      </div>
      
      <div class="notification-status">
        <h3><i class="fas fa-bell"></i> Notification Settings</h3>
        <div class="notification-toggles">
          <div class="toggle-item">
            <label class="toggle-switch">
              <input type="checkbox" v-model="alertData.notification_settings.email_enabled">
              <span class="slider"></span>
            </label>
            <span><i class="fas fa-envelope"></i> Email Alerts</span>
          </div>
          
          <div class="toggle-item">
            <label class="toggle-switch">
              <input type="checkbox" v-model="alertData.notification_settings.sms_enabled">
              <span class="slider"></span>
            </label>
            <span><i class="fas fa-sms"></i> SMS Alerts</span>
          </div>
          
          <div class="toggle-item">
            <label class="toggle-switch">
              <input type="checkbox" v-model="alertData.notification_settings.push_enabled">
              <span class="slider"></span>
            </label>
            <span><i class="fas fa-mobile-alt"></i> Push Notifications</span>
          </div>
        </div>
        
        <div class="threshold-setting">
          <label>Alert Threshold: </label>
          <select v-model="alertData.notification_settings.severity_threshold" class="threshold-select">
            <option value="low">Low and above</option>
            <option value="moderate">Moderate and above</option>
            <option value="high">High only</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading && !alertData" class="loading-container">
      <div class="loading-spinner"></div>
      <p>Loading weather alerts...</p>
    </div>

    <!-- Active Alerts -->
    <div v-else-if="alertData" class="alerts-content">
      <!-- No Alerts State -->
      <div v-if="alertData.active_alerts.length === 0" class="no-alerts glass-card">
        <div class="no-alerts-content">
          <i class="fas fa-check-circle no-alerts-icon"></i>
          <h2>No Active Weather Alerts</h2>
          <p>Weather conditions are currently normal for {{ selectedCity }}.</p>
          <p class="last-update">Last checked: {{ formatTimestamp(alertData.timestamp) }}</p>
        </div>
      </div>

      <!-- Alert Cards -->
      <div v-else class="alerts-grid">
        <div 
          v-for="alert in alertData.active_alerts" 
          :key="alert.title"
          class="alert-card glass-card"
          :class="[`severity-${alert.severity}`, `type-${alert.type}`]"
        >
          <div class="alert-header">
            <div class="alert-icon">
              <i :class="getAlertIcon(alert.type)"></i>
            </div>
            <div class="alert-title-section">
              <h3>{{ alert.title }}</h3>
              <div class="alert-meta">
                <span class="severity-badge" :class="`severity-${alert.severity}`">
                  {{ alert.severity.toUpperCase() }}
                </span>
                <span class="alert-type">{{ alert.type.toUpperCase() }}</span>
              </div>
            </div>
          </div>

          <div class="alert-description">
            <p>{{ alert.description }}</p>
          </div>

          <div class="alert-timing">
            <div class="timing-item">
              <i class="fas fa-play-circle"></i>
              <span>Starts: {{ formatAlertTime(alert.start_time) }}</span>
            </div>
            <div class="timing-item">
              <i class="fas fa-stop-circle"></i>
              <span>Ends: {{ formatAlertTime(alert.end_time) }}</span>
            </div>
            <div class="timing-item duration">
              <i class="fas fa-clock"></i>
              <span>Duration: {{ calculateDuration(alert.start_time, alert.end_time) }}</span>
            </div>
          </div>

          <div class="affected-areas">
            <h4><i class="fas fa-map-marker-alt"></i> Affected Areas</h4>
            <div class="areas-list">
              <span v-for="area in alert.affected_areas" :key="area" class="area-tag">
                {{ area }}
              </span>
            </div>
          </div>

          <div class="recommendations">
            <h4><i class="fas fa-lightbulb"></i> Recommendations</h4>
            <ul class="recommendations-list">
              <li v-for="recommendation in alert.recommendations" :key="recommendation">
                {{ recommendation }}
              </li>
            </ul>
          </div>

          <div class="alert-actions">
            <button @click="dismissAlert(alert)" class="dismiss-btn">
              <i class="fas fa-times"></i>
              Dismiss
            </button>
            <button @click="shareAlert(alert)" class="share-btn">
              <i class="fas fa-share"></i>
              Share
            </button>
            <button @click="getMoreInfo(alert)" class="info-btn">
              <i class="fas fa-info-circle"></i>
              More Info
            </button>
          </div>
        </div>
      </div>

      <!-- Emergency Contacts -->
      <div class="emergency-contacts glass-card">
        <h2><i class="fas fa-phone"></i> Emergency Contacts</h2>
        <div class="contacts-grid">
          <div class="contact-item">
            <div class="contact-icon">
              <i class="fas fa-exclamation-triangle"></i>
            </div>
            <div class="contact-info">
              <h4>Emergency Services</h4>
              <p class="contact-number">{{ alertData.emergency_contacts.local_emergency }}</p>
              <p class="contact-description">Life-threatening emergencies</p>
            </div>
          </div>

          <div class="contact-item">
            <div class="contact-icon">
              <i class="fas fa-cloud-rain"></i>
            </div>
            <div class="contact-info">
              <h4>Weather Service</h4>
              <p class="contact-number">{{ alertData.emergency_contacts.weather_service }}</p>
              <p class="contact-description">Weather updates and warnings</p>
            </div>
          </div>

          <div class="contact-item">
            <div class="contact-icon">
              <i class="fas fa-water"></i>
            </div>
            <div class="contact-info">
              <h4>Flood Information</h4>
              <p class="contact-number">{{ alertData.emergency_contacts.flood_info }}</p>
              <p class="contact-description">Flood warnings and evacuation</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Alert History -->
      <div class="alert-history glass-card">
        <h2><i class="fas fa-history"></i> Recent Alert History</h2>
        <div class="history-timeline">
          <div v-for="(item, index) in alertHistory" :key="index" class="timeline-item">
            <div class="timeline-dot" :class="`severity-${item.severity}`"></div>
            <div class="timeline-content">
              <div class="timeline-header">
                <h4>{{ item.title }}</h4>
                <span class="timeline-time">{{ item.time }}</span>
              </div>
              <p>{{ item.description }}</p>
              <span class="timeline-status" :class="item.status">{{ item.status }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-container glass-card">
      <i class="fas fa-exclamation-circle error-icon"></i>
      <h3>Failed to Load Weather Alerts</h3>
      <p>{{ error }}</p>
      <button @click="loadAlerts" class="retry-btn">
        <i class="fas fa-redo"></i>
        Try Again
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

// Reactive data
const loading = ref(false)
const error = ref('')
const alertData = ref(null)
const selectedCity = ref('London')
const alertType = ref('all')

// Mock alert history for demonstration
const alertHistory = ref([
  {
    title: 'Heat Wave Warning',
    description: 'Temperatures exceeded 40°C for 3 consecutive days',
    time: '2 days ago',
    severity: 'high',
    status: 'resolved'
  },
  {
    title: 'Thunderstorm Watch',
    description: 'Severe thunderstorms with heavy rain and lightning',
    time: '1 week ago',
    severity: 'moderate',
    status: 'expired'
  },
  {
    title: 'Wind Advisory',
    description: 'Strong winds up to 65 mph in coastal areas',
    time: '2 weeks ago',
    severity: 'moderate',
    status: 'resolved'
  }
])

// Methods
const loadAlerts = async () => {
  loading.value = true
  error.value = ''
  
  try {
    const response = await fetch(`/api/weather/alerts?city=${selectedCity.value}&type=${alertType.value}`)
    const data = await response.json()
    
    if (data.success) {
      alertData.value = data.data
    } else {
      error.value = data.error || 'Failed to load weather alerts'
    }
  } catch (err) {
    error.value = 'Network error occurred'
    console.error('Weather alerts error:', err)
  } finally {
    loading.value = false
  }
}

const formatTimestamp = (timestamp) => {
  return new Date(timestamp).toLocaleString()
}

const formatAlertTime = (timestamp) => {
  const date = new Date(timestamp)
  return date.toLocaleString('en-US', {
    weekday: 'short',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const calculateDuration = (start, end) => {
  const startTime = new Date(start)
  const endTime = new Date(end)
  const diffHours = Math.round((endTime - startTime) / (1000 * 60 * 60))
  
  if (diffHours < 24) {
    return `${diffHours} hours`
  } else {
    const days = Math.floor(diffHours / 24)
    const hours = diffHours % 24
    return `${days} day${days > 1 ? 's' : ''}${hours > 0 ? ` ${hours}h` : ''}`
  }
}

const getAlertIcon = (type) => {
  const icons = {
    'temperature': 'fas fa-thermometer-full',
    'precipitation': 'fas fa-cloud-rain',
    'wind': 'fas fa-wind',
    'storm': 'fas fa-bolt',
    'snow': 'fas fa-snowflake',
    'fog': 'fas fa-smog'
  }
  return icons[type] || 'fas fa-exclamation-triangle'
}

const dismissAlert = (alert) => {
  // In a real app, this would make an API call to dismiss the alert
  const index = alertData.value.active_alerts.findIndex(a => a.title === alert.title)
  if (index !== -1) {
    alertData.value.active_alerts.splice(index, 1)
    alertData.value.alert_statistics.total_active--
    
    // Add to history
    alertHistory.value.unshift({
      title: alert.title,
      description: alert.description,
      time: 'Just now',
      severity: alert.severity,
      status: 'dismissed'
    })
  }
}

const shareAlert = (alert) => {
  const text = `Weather Alert: ${alert.title}\n\n${alert.description}\n\nStarts: ${formatAlertTime(alert.start_time)}\nEnds: ${formatAlertTime(alert.end_time)}`
  
  if (navigator.share) {
    navigator.share({
      title: alert.title,
      text: text
    })
  } else {
    // Fallback to copy to clipboard
    navigator.clipboard.writeText(text).then(() => {
      alert('Alert details copied to clipboard!')
    }).catch(() => {
      alert('Unable to share alert. Please copy manually.')
    })
  }
}

const getMoreInfo = (alert) => {
  // In a real app, this would navigate to a detailed alert page or open a modal
  alert(`More information about ${alert.title}:\n\nType: ${alert.type}\nSeverity: ${alert.severity}\nAffected Areas: ${alert.affected_areas.join(', ')}\n\nFor the latest updates, monitor local weather services and emergency broadcasts.`)
}

// Initialize
onMounted(() => {
  loadAlerts()
})
</script>

<style scoped>
.alerts-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.page-header {
  padding: 2rem;
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
  color: #F59E0B;
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

.alert-controls {
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

.spinning {
  animation: spin 1s linear infinite;
}

.alert-summary {
  padding: 2rem;
  display: flex;
  justify-content: space-between;
  gap: 2rem;
  flex-wrap: wrap;
}

.summary-stats {
  display: flex;
  gap: 2rem;
  flex-wrap: wrap;
}

.stat-item {
  text-align: center;
  padding: 1rem;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  min-width: 120px;
}

.stat-item.has-alerts {
  border-color: #F59E0B;
  background: rgba(245, 158, 11, 0.1);
}

.stat-item.severity-high {
  border-color: #EF4444;
  background: rgba(239, 68, 68, 0.1);
}

.stat-item.severity-moderate {
  border-color: #F59E0B;
  background: rgba(245, 158, 11, 0.1);
}

.stat-item.severity-low {
  border-color: #10B981;
  background: rgba(16, 185, 129, 0.1);
}

.stat-value {
  font-size: 2rem;
  font-weight: 700;
  color: var(--text-primary);
}

.stat-label {
  color: var(--text-secondary);
  font-size: 0.9rem;
  margin-top: 0.5rem;
}

.notification-status h3 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
  color: var(--text-primary);
}

.notification-toggles {
  display: flex;
  gap: 1.5rem;
  margin-bottom: 1rem;
  flex-wrap: wrap;
}

.toggle-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.toggle-switch {
  position: relative;
  display: inline-block;
  width: 50px;
  height: 24px;
}

.toggle-switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(255, 255, 255, 0.2);
  transition: 0.3s;
  border-radius: 24px;
}

.slider:before {
  position: absolute;
  content: "";
  height: 18px;
  width: 18px;
  left: 3px;
  bottom: 3px;
  background-color: white;
  transition: 0.3s;
  border-radius: 50%;
}

input:checked + .slider {
  background-color: var(--accent-color);
}

input:checked + .slider:before {
  transform: translateX(26px);
}

.threshold-setting {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--text-secondary);
}

.threshold-select {
  padding: 0.5rem;
  border-radius: 4px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  background: rgba(255, 255, 255, 0.1);
  color: var(--text-primary);
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

.no-alerts {
  padding: 4rem;
  text-align: center;
}

.no-alerts-icon {
  font-size: 4rem;
  color: #10B981;
  margin-bottom: 1rem;
}

.no-alerts-content h2 {
  color: var(--text-primary);
  margin-bottom: 1rem;
}

.no-alerts-content p {
  color: var(--text-secondary);
  margin-bottom: 0.5rem;
}

.last-update {
  font-size: 0.9rem;
  font-style: italic;
}

.alerts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 2rem;
}

.alert-card {
  padding: 2rem;
  border-left: 4px solid;
  transition: transform 0.3s ease;
}

.alert-card:hover {
  transform: translateY(-2px);
}

.alert-card.severity-high {
  border-color: #EF4444;
  background: rgba(239, 68, 68, 0.05);
}

.alert-card.severity-moderate {
  border-color: #F59E0B;
  background: rgba(245, 158, 11, 0.05);
}

.alert-card.severity-low {
  border-color: #10B981;
  background: rgba(16, 185, 129, 0.05);
}

.alert-header {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.alert-icon i {
  font-size: 2rem;
  color: var(--accent-color);
}

.alert-title-section h3 {
  margin: 0 0 0.5rem 0;
  color: var(--text-primary);
}

.alert-meta {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.severity-badge {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.7rem;
  font-weight: 600;
  color: white;
}

.severity-badge.severity-high {
  background: #EF4444;
}

.severity-badge.severity-moderate {
  background: #F59E0B;
}

.severity-badge.severity-low {
  background: #10B981;
}

.alert-type {
  font-size: 0.8rem;
  color: var(--text-secondary);
  font-weight: 500;
}

.alert-description {
  margin-bottom: 1.5rem;
}

.alert-description p {
  color: var(--text-secondary);
  line-height: 1.6;
}

.alert-timing {
  margin-bottom: 1.5rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  padding: 1rem;
}

.timing-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.timing-item:last-child {
  margin-bottom: 0;
}

.timing-item.duration {
  color: var(--text-primary);
  font-weight: 600;
}

.affected-areas {
  margin-bottom: 1.5rem;
}

.affected-areas h4 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
  color: var(--text-primary);
}

.areas-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.area-tag {
  background: rgba(255, 255, 255, 0.1);
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  color: var(--text-secondary);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.recommendations {
  margin-bottom: 1.5rem;
}

.recommendations h4 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
  color: var(--text-primary);
}

.recommendations-list {
  list-style: none;
  padding: 0;
}

.recommendations-list li {
  color: var(--text-secondary);
  padding: 0.25rem 0;
  position: relative;
  padding-left: 1rem;
}

.recommendations-list li:before {
  content: "•";
  color: var(--accent-color);
  font-weight: bold;
  position: absolute;
  left: 0;
}

.alert-actions {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.alert-actions button {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.8rem;
  transition: all 0.3s ease;
}

.dismiss-btn {
  background: rgba(239, 68, 68, 0.2);
  color: #EF4444;
  border: 1px solid rgba(239, 68, 68, 0.3);
}

.share-btn {
  background: rgba(59, 130, 246, 0.2);
  color: #3B82F6;
  border: 1px solid rgba(59, 130, 246, 0.3);
}

.info-btn {
  background: rgba(16, 185, 129, 0.2);
  color: #10B981;
  border: 1px solid rgba(16, 185, 129, 0.3);
}

.alert-actions button:hover {
  transform: translateY(-1px);
  opacity: 0.8;
}

.emergency-contacts {
  padding: 2rem;
}

.emergency-contacts h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  color: var(--text-primary);
}

.contacts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.5rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.contact-icon i {
  font-size: 1.5rem;
  color: var(--accent-color);
}

.contact-info h4 {
  margin: 0 0 0.25rem 0;
  color: var(--text-primary);
}

.contact-number {
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--accent-color);
  margin: 0.25rem 0;
}

.contact-description {
  font-size: 0.9rem;
  color: var(--text-secondary);
  margin: 0;
}

.alert-history {
  padding: 2rem;
}

.alert-history h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  color: var(--text-primary);
}

.history-timeline {
  position: relative;
  padding-left: 2rem;
}

.history-timeline:before {
  content: '';
  position: absolute;
  left: 8px;
  top: 0;
  bottom: 0;
  width: 2px;
  background: rgba(255, 255, 255, 0.2);
}

.timeline-item {
  position: relative;
  margin-bottom: 2rem;
}

.timeline-dot {
  position: absolute;
  left: -10px;
  top: 0;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  border: 2px solid;
}

.timeline-dot.severity-high {
  background: #EF4444;
  border-color: #EF4444;
}

.timeline-dot.severity-moderate {
  background: #F59E0B;
  border-color: #F59E0B;
}

.timeline-dot.severity-low {
  background: #10B981;
  border-color: #10B981;
}

.timeline-content {
  background: rgba(255, 255, 255, 0.05);
  padding: 1rem;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.timeline-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.timeline-header h4 {
  margin: 0;
  color: var(--text-primary);
}

.timeline-time {
  color: var(--text-secondary);
  font-size: 0.8rem;
}

.timeline-content p {
  color: var(--text-secondary);
  margin: 0 0 0.5rem 0;
}

.timeline-status {
  font-size: 0.8rem;
  font-weight: 600;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
}

.timeline-status.resolved {
  background: rgba(16, 185, 129, 0.2);
  color: #10B981;
}

.timeline-status.expired {
  background: rgba(156, 163, 175, 0.2);
  color: #9CA3AF;
}

.timeline-status.dismissed {
  background: rgba(59, 130, 246, 0.2);
  color: #3B82F6;
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

  .alert-controls {
    flex-direction: column;
    gap: 0.5rem;
  }

  .alert-summary {
    flex-direction: column;
    gap: 1rem;
  }

  .summary-stats {
    justify-content: center;
  }

  .notification-toggles {
    flex-direction: column;
    gap: 1rem;
  }

  .alerts-grid {
    grid-template-columns: 1fr;
  }

  .contacts-grid {
    grid-template-columns: 1fr;
  }

  .alert-actions {
    justify-content: space-between;
  }

  .timeline-content {
    margin-left: 1rem;
  }
}
</style>