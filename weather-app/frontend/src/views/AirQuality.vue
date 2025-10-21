<template>
  <div class="air-quality-page">
    <!-- Page Header -->
    <div class="page-header glass-card">
      <div class="header-content">
        <div class="header-title">
          <i class="fas fa-lungs header-icon"></i>
          <div>
            <h1>Air Quality Monitor</h1>
            <p>Real-time air quality data with health recommendations</p>
          </div>
        </div>
        
        <div class="header-actions">
          <div class="quality-controls">
            <select v-model="selectedCity" @change="loadAirQuality" class="control-select">
              <option value="London">London</option>
              <option value="New York">New York</option>
              <option value="Tokyo">Tokyo</option>
              <option value="Paris">Paris</option>
              <option value="Sydney">Sydney</option>
              <option value="Beijing">Beijing</option>
              <option value="Mumbai">Mumbai</option>
            </select>
            
            <button @click="loadAirQuality" :disabled="loading" class="refresh-btn">
              <i class="fas fa-sync-alt" :class="{ 'spinning': loading }"></i>
              Refresh
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading && !airQuality" class="loading-container">
      <div class="loading-spinner"></div>
      <p>Analyzing air quality...</p>
    </div>

    <!-- Air Quality Content -->
    <div v-else-if="airQuality" class="air-quality-content">
      <!-- AQI Overview -->
      <div class="aqi-overview glass-card">
        <div class="aqi-main">
          <div class="aqi-circle" :style="{ borderColor: airQuality.color_code }">
            <div class="aqi-value" :style="{ color: airQuality.color_code }">
              {{ airQuality.air_quality_index }}
            </div>
            <div class="aqi-label">AQI</div>
          </div>
          
          <div class="aqi-info">
            <h2>{{ airQuality.quality_level }}</h2>
            <p class="health-advice">{{ airQuality.health_advice }}</p>
            <div class="update-time">
              <i class="fas fa-clock"></i>
              Last updated: {{ formatTimestamp(airQuality.timestamp) }}
            </div>
          </div>
        </div>

        <!-- Quick Health Recommendations -->
        <div class="quick-recommendations">
          <div class="recommendation-item" :class="getRecommendationClass(airQuality.health_recommendations.outdoor_exercise)">
            <i class="fas fa-running"></i>
            <div>
              <strong>Outdoor Exercise</strong>
              <span>{{ airQuality.health_recommendations.outdoor_exercise }}</span>
            </div>
          </div>
          
          <div class="recommendation-item" :class="getRecommendationClass(airQuality.health_recommendations.window_opening)">
            <i class="fas fa-window-maximize"></i>
            <div>
              <strong>Open Windows</strong>
              <span>{{ airQuality.health_recommendations.window_opening }}</span>
            </div>
          </div>
          
          <div class="recommendation-item" :class="getRecommendationClass(airQuality.health_recommendations.mask_recommendation)">
            <i class="fas fa-head-side-mask"></i>
            <div>
              <strong>Face Mask</strong>
              <span>{{ airQuality.health_recommendations.mask_recommendation }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Pollutant Details -->
      <div class="pollutants-section glass-card">
        <h2><i class="fas fa-atom"></i> Pollutant Breakdown</h2>
        <div class="pollutants-grid">
          <div v-for="(value, pollutant) in airQuality.pollutants" :key="pollutant" class="pollutant-card">
            <div class="pollutant-header">
              <i :class="getPollutantIcon(pollutant)"></i>
              <h3>{{ getPollutantName(pollutant) }}</h3>
            </div>
            
            <div class="pollutant-value">
              <span class="value">{{ value.toFixed(1) }}</span>
              <span class="unit">{{ getPollutantUnit(pollutant) }}</span>
            </div>
            
            <div class="pollutant-bar">
              <div 
                class="pollutant-fill" 
                :style="{ 
                  width: Math.min((value / getPollutantMax(pollutant)) * 100, 100) + '%',
                  backgroundColor: getPollutantColor(value, pollutant)
                }"
              ></div>
            </div>
            
            <div class="pollutant-status" :style="{ color: getPollutantColor(value, pollutant) }">
              {{ getPollutantStatus(value, pollutant) }}
            </div>
          </div>
        </div>
      </div>

      <!-- Environmental Details -->
      <div class="environmental-details glass-card">
        <h2><i class="fas fa-leaf"></i> Environmental Conditions</h2>
        <div class="environmental-grid">
          <div class="env-card">
            <div class="env-icon">
              <i class="fas fa-eye"></i>
            </div>
            <div class="env-content">
              <h3>Visibility</h3>
              <div class="env-value">{{ airQuality.detailed_analysis.visibility_km.toFixed(1) }} km</div>
              <div class="env-status" :class="getVisibilityClass(airQuality.detailed_analysis.visibility_km)">
                {{ getVisibilityStatus(airQuality.detailed_analysis.visibility_km) }}
              </div>
            </div>
          </div>

          <div class="env-card">
            <div class="env-icon">
              <i class="fas fa-sun"></i>
            </div>
            <div class="env-content">
              <h3>UV Index</h3>
              <div class="env-value">{{ airQuality.detailed_analysis.uv_index }}</div>
              <div class="env-status" :class="getUVClass(airQuality.detailed_analysis.uv_index)">
                {{ getUVStatus(airQuality.detailed_analysis.uv_index) }}
              </div>
            </div>
          </div>

          <div class="env-card">
            <div class="env-icon">
              <i class="fas fa-seedling"></i>
            </div>
            <div class="env-content">
              <h3>Pollen Count</h3>
              <div class="env-value">{{ airQuality.detailed_analysis.pollen_count }}</div>
              <div class="env-status" :class="getPollenClass(airQuality.detailed_analysis.pollen_count)">
                {{ airQuality.detailed_analysis.pollen_count }} Level
              </div>
            </div>
          </div>

          <div class="env-card">
            <div class="env-icon">
              <i class="fas fa-exclamation-triangle"></i>
            </div>
            <div class="env-content">
              <h3>Primary Pollutant</h3>
              <div class="env-value">{{ getPollutantName(airQuality.detailed_analysis.primary_pollutant) }}</div>
              <div class="env-status warning">Highest Contributor</div>
            </div>
          </div>
        </div>
      </div>

      <!-- AQI Scale Reference -->
      <div class="aqi-scale glass-card">
        <h2><i class="fas fa-chart-bar"></i> AQI Scale Reference</h2>
        <div class="scale-items">
          <div class="scale-item good">
            <div class="scale-range">0-50</div>
            <div class="scale-label">Good</div>
            <div class="scale-description">Air quality is satisfactory</div>
          </div>
          
          <div class="scale-item moderate">
            <div class="scale-range">51-100</div>
            <div class="scale-label">Moderate</div>
            <div class="scale-description">Acceptable for most people</div>
          </div>
          
          <div class="scale-item unhealthy-sensitive">
            <div class="scale-range">101-150</div>
            <div class="scale-label">Unhealthy for Sensitive Groups</div>
            <div class="scale-description">Sensitive individuals should limit outdoor activities</div>
          </div>
          
          <div class="scale-item unhealthy">
            <div class="scale-range">151-200</div>
            <div class="scale-label">Unhealthy</div>
            <div class="scale-description">Everyone should limit outdoor activities</div>
          </div>
          
          <div class="scale-item very-unhealthy">
            <div class="scale-range">201-300</div>
            <div class="scale-label">Very Unhealthy</div>
            <div class="scale-description">Health alert: everyone may experience serious health effects</div>
          </div>
        </div>
      </div>

      <!-- Health Tips -->
      <div class="health-tips glass-card">
        <h2><i class="fas fa-heart"></i> Health Protection Tips</h2>
        <div class="tips-grid">
          <div class="tip-category">
            <h3><i class="fas fa-child"></i> For Sensitive Groups</h3>
            <ul>
              <li>Children, elderly, and people with heart/lung conditions</li>
              <li>Limit outdoor activities when AQI > 100</li>
              <li>Use air purifiers indoors</li>
              <li>Consider wearing N95 masks outdoors</li>
            </ul>
          </div>

          <div class="tip-category">
            <h3><i class="fas fa-home"></i> Indoor Air Quality</h3>
            <ul>
              <li>Keep windows closed during high pollution</li>
              <li>Use HEPA air filters</li>
              <li>Avoid smoking indoors</li>
              <li>Regularly clean and vacuum</li>
            </ul>
          </div>

          <div class="tip-category">
            <h3><i class="fas fa-running"></i> Exercise Guidelines</h3>
            <ul>
              <li>Exercise indoors when AQI > 150</li>
              <li>Reduce intensity when AQI 100-150</li>
              <li>Choose early morning or evening hours</li>
              <li>Stay hydrated and listen to your body</li>
            </ul>
          </div>
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-container glass-card">
      <i class="fas fa-exclamation-circle error-icon"></i>
      <h3>Failed to Load Air Quality Data</h3>
      <p>{{ error }}</p>
      <button @click="loadAirQuality" class="retry-btn">
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
const airQuality = ref(null)
const selectedCity = ref('London')

// Methods
const loadAirQuality = async () => {
  loading.value = true
  error.value = ''
  
  try {
    const response = await fetch(`/api/air-quality?city=${selectedCity.value}`)
    const data = await response.json()
    
    if (data.success) {
      airQuality.value = data.data
    } else {
      error.value = data.error || 'Failed to load air quality data'
    }
  } catch (err) {
    error.value = 'Network error occurred'
    console.error('Air quality error:', err)
  } finally {
    loading.value = false
  }
}

const formatTimestamp = (timestamp) => {
  return new Date(timestamp).toLocaleString()
}

const getRecommendationClass = (status) => {
  if (status.includes('Safe') || status.includes('Recommended') || status.includes('Not Needed')) {
    return 'safe'
  } else if (status.includes('Caution') || status.includes('Limited') || status.includes('N95 Recommended')) {
    return 'caution'
  } else {
    return 'danger'
  }
}

const getPollutantName = (pollutant) => {
  const names = {
    'pm2_5': 'PM2.5',
    'pm10': 'PM10',
    'no2': 'NO₂',
    'so2': 'SO₂',
    'co': 'CO',
    'o3': 'O₃'
  }
  return names[pollutant] || pollutant.toUpperCase()
}

const getPollutantIcon = (pollutant) => {
  const icons = {
    'pm2_5': 'fas fa-smog',
    'pm10': 'fas fa-cloud',
    'no2': 'fas fa-car',
    'so2': 'fas fa-industry',
    'co': 'fas fa-fire',
    'o3': 'fas fa-sun'
  }
  return icons[pollutant] || 'fas fa-atom'
}

const getPollutantUnit = (pollutant) => {
  const units = {
    'pm2_5': 'μg/m³',
    'pm10': 'μg/m³',
    'no2': 'μg/m³',
    'so2': 'μg/m³',
    'co': 'mg/m³',
    'o3': 'μg/m³'
  }
  return units[pollutant] || 'μg/m³'
}

const getPollutantMax = (pollutant) => {
  const maxValues = {
    'pm2_5': 50,
    'pm10': 100,
    'no2': 100,
    'so2': 50,
    'co': 10,
    'o3': 150
  }
  return maxValues[pollutant] || 100
}

const getPollutantColor = (value, pollutant) => {
  const thresholds = {
    'pm2_5': [12, 35, 55],
    'pm10': [50, 100, 150],
    'no2': [40, 80, 120],
    'so2': [20, 40, 60],
    'co': [2, 5, 8],
    'o3': [60, 120, 180]
  }
  
  const levels = thresholds[pollutant] || [25, 50, 75]
  
  if (value <= levels[0]) return '#10B981' // Green
  if (value <= levels[1]) return '#F59E0B' // Yellow
  if (value <= levels[2]) return '#F97316' // Orange
  return '#EF4444' // Red
}

const getPollutantStatus = (value, pollutant) => {
  const color = getPollutantColor(value, pollutant)
  
  if (color === '#10B981') return 'Good'
  if (color === '#F59E0B') return 'Moderate'
  if (color === '#F97316') return 'Poor'
  return 'Very Poor'
}

const getVisibilityClass = (visibility) => {
  if (visibility >= 20) return 'good'
  if (visibility >= 10) return 'moderate'
  return 'poor'
}

const getVisibilityStatus = (visibility) => {
  if (visibility >= 20) return 'Excellent'
  if (visibility >= 10) return 'Good'
  if (visibility >= 5) return 'Moderate'
  return 'Poor'
}

const getUVClass = (uv) => {
  if (uv <= 2) return 'low'
  if (uv <= 5) return 'moderate'
  if (uv <= 7) return 'high'
  if (uv <= 10) return 'very-high'
  return 'extreme'
}

const getUVStatus = (uv) => {
  if (uv <= 2) return 'Low'
  if (uv <= 5) return 'Moderate'
  if (uv <= 7) return 'High'
  if (uv <= 10) return 'Very High'
  return 'Extreme'
}

const getPollenClass = (pollen) => {
  const level = pollen.toLowerCase()
  if (level === 'low') return 'good'
  if (level === 'moderate') return 'moderate'
  if (level === 'high') return 'poor'
  return 'very-poor'
}

// Initialize
onMounted(() => {
  loadAirQuality()
})
</script>

<style scoped>
.air-quality-page {
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
  color: var(--accent-color);
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

.quality-controls {
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

.air-quality-content {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.aqi-overview {
  padding: 2rem;
}

.aqi-main {
  display: flex;
  align-items: center;
  gap: 2rem;
  margin-bottom: 2rem;
}

.aqi-circle {
  width: 120px;
  height: 120px;
  border: 8px solid;
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
}

.aqi-value {
  font-size: 2.5rem;
  font-weight: 700;
}

.aqi-label {
  font-size: 0.9rem;
  color: var(--text-secondary);
}

.aqi-info h2 {
  margin: 0 0 0.5rem 0;
  color: var(--text-primary);
}

.health-advice {
  color: var(--text-secondary);
  margin-bottom: 1rem;
}

.update-time {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.quick-recommendations {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}

.recommendation-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border-radius: 8px;
  border-left: 4px solid;
}

.recommendation-item.safe {
  background: rgba(16, 185, 129, 0.1);
  border-color: #10B981;
}

.recommendation-item.caution {
  background: rgba(245, 158, 11, 0.1);
  border-color: #F59E0B;
}

.recommendation-item.danger {
  background: rgba(239, 68, 68, 0.1);
  border-color: #EF4444;
}

.recommendation-item i {
  font-size: 1.5rem;
  opacity: 0.8;
}

.recommendation-item strong {
  display: block;
  color: var(--text-primary);
  margin-bottom: 0.25rem;
}

.recommendation-item span {
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.pollutants-section {
  padding: 2rem;
}

.pollutants-section h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  color: var(--text-primary);
}

.pollutants-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}

.pollutant-card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  padding: 1.5rem;
  text-align: center;
}

.pollutant-header {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.pollutant-header i {
  font-size: 1.5rem;
  color: var(--accent-color);
}

.pollutant-header h3 {
  margin: 0;
  color: var(--text-primary);
}

.pollutant-value {
  margin-bottom: 1rem;
}

.pollutant-value .value {
  font-size: 2rem;
  font-weight: 700;
  color: var(--text-primary);
}

.pollutant-value .unit {
  font-size: 0.9rem;
  color: var(--text-secondary);
  margin-left: 0.25rem;
}

.pollutant-bar {
  background: rgba(255, 255, 255, 0.1);
  height: 8px;
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 0.5rem;
}

.pollutant-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 0.3s ease;
}

.pollutant-status {
  font-size: 0.9rem;
  font-weight: 600;
}

.environmental-details {
  padding: 2rem;
}

.environmental-details h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  color: var(--text-primary);
}

.environmental-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.env-card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  padding: 1.5rem;
  text-align: center;
}

.env-icon i {
  font-size: 2rem;
  color: var(--accent-color);
  margin-bottom: 1rem;
}

.env-content h3 {
  margin: 0 0 0.5rem 0;
  color: var(--text-primary);
}

.env-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: 0.5rem;
}

.env-status {
  font-size: 0.9rem;
  font-weight: 600;
}

.env-status.good { color: #10B981; }
.env-status.moderate { color: #F59E0B; }
.env-status.poor { color: #F97316; }
.env-status.very-poor { color: #EF4444; }
.env-status.warning { color: #F59E0B; }

.aqi-scale {
  padding: 2rem;
}

.aqi-scale h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  color: var(--text-primary);
}

.scale-items {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.scale-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border-radius: 8px;
  border-left: 4px solid;
}

.scale-item.good {
  background: rgba(16, 185, 129, 0.1);
  border-color: #10B981;
}

.scale-item.moderate {
  background: rgba(245, 158, 11, 0.1);
  border-color: #F59E0B;
}

.scale-item.unhealthy-sensitive {
  background: rgba(249, 115, 22, 0.1);
  border-color: #F97316;
}

.scale-item.unhealthy {
  background: rgba(239, 68, 68, 0.1);
  border-color: #EF4444;
}

.scale-item.very-unhealthy {
  background: rgba(147, 51, 234, 0.1);
  border-color: #9333EA;
}

.scale-range {
  font-weight: 700;
  color: var(--text-primary);
  min-width: 60px;
}

.scale-label {
  font-weight: 600;
  color: var(--text-primary);
  min-width: 200px;
}

.scale-description {
  color: var(--text-secondary);
  flex: 1;
}

.health-tips {
  padding: 2rem;
}

.health-tips h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  color: var(--text-primary);
}

.tips-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
}

.tip-category h3 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--text-primary);
  margin-bottom: 1rem;
}

.tip-category ul {
  list-style: none;
  padding: 0;
}

.tip-category li {
  color: var(--text-secondary);
  padding: 0.5rem 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.tip-category li:before {
  content: "✓";
  color: var(--accent-color);
  font-weight: bold;
  margin-right: 0.5rem;
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

  .quality-controls {
    flex-direction: column;
    gap: 0.5rem;
  }

  .aqi-main {
    flex-direction: column;
    text-align: center;
  }

  .quick-recommendations {
    grid-template-columns: 1fr;
  }

  .pollutants-grid {
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  }

  .environmental-grid {
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  }

  .scale-items {
    gap: 0.5rem;
  }

  .scale-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }

  .tips-grid {
    grid-template-columns: 1fr;
  }
}
</style>