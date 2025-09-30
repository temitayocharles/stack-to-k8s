# 🌤️ Weather App - Real-Time Weather Dashboard

**Technology**: Vue.js + Python + Redis  
**Difficulty**: ⭐ Beginner  
**Time**: 15 minutes

> **Perfect for**: Learning API integration and caching with modern frameworks

## 🎯 What You'll Build
- ✅ **Real-time weather data** from OpenWeatherMap API
- ✅ **Beautiful Vue.js interface** with responsive design
- ✅ **Smart caching** using Redis for performance
- ✅ **Location search** with autocomplete
- ✅ **Weather forecasts** with 5-day predictions

## 📋 Before You Start
**Required time**: 15 minutes  
**Prerequisites**: [System setup](../getting-started/system-setup.md) completed  
**API Key needed**: OpenWeatherMap (free tier available)

## 🚀 Quick Start

### 1. Navigate to Application
```bash
cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps/weather-app
```

### 2. Set Up API Key
```bash
# Copy environment template
cp .env.example .env

# Edit the API key (get free key from openweathermap.org)
# OPENWEATHER_API_KEY=your_api_key_here
```

### 3. Start Everything
```bash
docker-compose up -d
```

### 4. Open in Browser
- **Frontend**: http://localhost:3003
- **API Health**: http://localhost:8003/health

## 🔍 What's Inside

### Frontend Features (Vue.js)
- **Location search** with intelligent autocomplete
- **Current weather** with detailed conditions
- **5-day forecast** with hourly breakdowns
- **Weather maps** with radar and satellite views
- **Favorite locations** for quick access

### Backend APIs (Python Flask)
- **Weather API** - Current conditions and forecasts
- **Location API** - City search and geolocation
- **Cache API** - Optimized data storage
- **Health checks** - System monitoring

### Caching Layer (Redis)
- **API response caching** - Reduces external API calls
- **Location caching** - Faster search results
- **Session storage** - User preferences
- **Rate limiting** - API usage optimization

## 🧪 Test It Out

### 1. Search for Weather
1. Go to http://localhost:3003
2. Type a city name in the search box
3. Select from autocomplete suggestions
4. View current weather and forecast

### 2. Explore Features
1. Click on different forecast days
2. Toggle between Celsius and Fahrenheit
3. View detailed weather information
4. Add locations to favorites

### 3. Check Performance
1. Search for the same city twice
2. Notice faster loading (Redis caching)
3. Check API rate limiting in action

## 🔧 Technical Details

### Frontend (Vue.js 3)
- **Composition API** with reactive data
- **Vue Router** for navigation
- **Axios** for API communication
- **Chart.js** for weather visualizations
- **Tailwind CSS** for styling

### Backend (Python Flask)
- **Flask-RESTful** for API endpoints
- **Requests** for external API calls
- **Redis-py** for caching
- **APScheduler** for background tasks
- **Marshmallow** for data validation

### External APIs
- **OpenWeatherMap** - Weather data source
- **Geocoding API** - Location resolution
- **UV Index API** - Sun exposure data

## 🚀 Kubernetes Deployment

Ready to deploy to Kubernetes?

### 1. Deploy to Kubernetes
```bash
kubectl apply -f k8s/
```

### 2. Access via Port Forward
```bash
kubectl port-forward service/weather-frontend 3003:80
```

### 3. View in Browser
Go to http://localhost:3003

## 📊 Monitoring

### Check Application Health
```bash
curl http://localhost:8003/health
```

### View Cache Statistics
```bash
docker-compose exec redis redis-cli info stats
```

### Monitor API Usage
```bash
docker-compose logs -f weather-backend | grep "API"
```

## 🔄 Stop Application

```bash
docker-compose down
```

## ➡️ What's Next?

✅ **Master this app?** → [Try the educational platform](educational.md) (more complex backend)  
✅ **Ready for Kubernetes?** → [Kubernetes basics](../getting-started/kubernetes-basics.md)  
✅ **Want production setup?** → [Enterprise deployment](../deployment/production-ready.md)

## 🆘 Need Help?

**Common issues**:
- **API key errors**: Check .env file and OpenWeatherMap account
- **Location not found**: Try major city names first
- **Slow responses**: Wait for Redis cache to warm up

**More help**: [Troubleshooting guide](../troubleshooting/common-issues.md)

---

**Great choice!** The weather app teaches you API integration patterns used in most data-driven applications.