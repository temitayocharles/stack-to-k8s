from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_caching import Cache
import redis
import requests
import os
from datetime import datetime, timedelta
import json
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)

# Redis cache configuration
cache_config = {
    'CACHE_TYPE': 'redis',
    'CACHE_REDIS_HOST': os.getenv('REDIS_HOST', 'localhost'),
    'CACHE_REDIS_PORT': int(os.getenv('REDIS_PORT', 6379)),
    'CACHE_REDIS_DB': int(os.getenv('REDIS_DB', 0)),
    'CACHE_DEFAULT_TIMEOUT': 300  # 5 minutes
}
cache = Cache(app, config=cache_config)

# Weather API configuration
WEATHER_API_KEY = os.getenv('OPENWEATHER_API_KEY')
WEATHER_BASE_URL = 'https://api.openweathermap.org/data/2.5'
GEO_BASE_URL = 'http://api.openweathermap.org/geo/1.0'

class WeatherService:
    def __init__(self):
        self.api_key = WEATHER_API_KEY
        
    def get_current_weather(self, lat, lon):
        """Get current weather data for given coordinates"""
        cache_key = f"current_weather_{lat}_{lon}"
        cached_data = cache.get(cache_key)
        
        if cached_data:
            return cached_data
            
        url = f"{WEATHER_BASE_URL}/weather"
        params = {
            'lat': lat,
            'lon': lon,
            'appid': self.api_key,
            'units': 'metric'
        }
        
        try:
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            # Format the response
            weather_data = {
                'location': {
                    'name': data['name'],
                    'country': data['sys']['country'],
                    'coordinates': {'lat': lat, 'lon': lon}
                },
                'current': {
                    'temperature': round(data['main']['temp']),
                    'feels_like': round(data['main']['feels_like']),
                    'humidity': data['main']['humidity'],
                    'pressure': data['main']['pressure'],
                    'visibility': data.get('visibility', 0) / 1000,  # Convert to km
                    'uv_index': 0,  # Would need separate API call
                    'wind': {
                        'speed': data['wind']['speed'],
                        'direction': data['wind'].get('deg', 0)
                    },
                    'weather': {
                        'main': data['weather'][0]['main'],
                        'description': data['weather'][0]['description'].title(),
                        'icon': data['weather'][0]['icon']
                    }
                },
                'sun': {
                    'sunrise': datetime.fromtimestamp(data['sys']['sunrise']).strftime('%H:%M'),
                    'sunset': datetime.fromtimestamp(data['sys']['sunset']).strftime('%H:%M')
                },
                'timestamp': datetime.now().isoformat()
            }
            
            # Cache for 5 minutes
            cache.set(cache_key, weather_data, timeout=300)
            return weather_data
            
        except requests.RequestException as e:
            raise Exception(f"Failed to fetch weather data: {str(e)}")
    
    def get_forecast(self, lat, lon, days=5):
        """Get weather forecast for given coordinates"""
        cache_key = f"forecast_{lat}_{lon}_{days}"
        cached_data = cache.get(cache_key)
        
        if cached_data:
            return cached_data
            
        url = f"{WEATHER_BASE_URL}/forecast"
        params = {
            'lat': lat,
            'lon': lon,
            'appid': self.api_key,
            'units': 'metric'
        }
        
        try:
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            # Process forecast data
            forecast_data = []
            daily_data = {}
            
            for item in data['list']:
                date = datetime.fromtimestamp(item['dt']).date()
                
                if date not in daily_data:
                    daily_data[date] = {
                        'date': date.isoformat(),
                        'temperatures': [],
                        'weather_conditions': [],
                        'humidity': [],
                        'wind_speed': [],
                        'descriptions': []
                    }
                
                daily_data[date]['temperatures'].append(item['main']['temp'])
                daily_data[date]['weather_conditions'].append(item['weather'][0]['main'])
                daily_data[date]['humidity'].append(item['main']['humidity'])
                daily_data[date]['wind_speed'].append(item['wind']['speed'])
                daily_data[date]['descriptions'].append(item['weather'][0]['description'])
            
            # Calculate daily averages and most common conditions
            for date, day_data in list(daily_data.items())[:days]:
                temps = day_data['temperatures']
                forecast_data.append({
                    'date': day_data['date'],
                    'temperature': {
                        'max': round(max(temps)),
                        'min': round(min(temps)),
                        'avg': round(sum(temps) / len(temps))
                    },
                    'weather': {
                        'main': max(set(day_data['weather_conditions']), 
                                  key=day_data['weather_conditions'].count),
                        'description': max(set(day_data['descriptions']), 
                                         key=day_data['descriptions'].count).title()
                    },
                    'humidity': round(sum(day_data['humidity']) / len(day_data['humidity'])),
                    'wind_speed': round(sum(day_data['wind_speed']) / len(day_data['wind_speed']), 1)
                })
            
            # Cache for 1 hour
            cache.set(cache_key, forecast_data, timeout=3600)
            return forecast_data
            
        except requests.RequestException as e:
            raise Exception(f"Failed to fetch forecast data: {str(e)}")
    
    def search_locations(self, query, limit=5):
        """Search for locations by name"""
        cache_key = f"location_search_{query}_{limit}"
        cached_data = cache.get(cache_key)
        
        if cached_data:
            return cached_data
            
        url = f"{GEO_BASE_URL}/direct"
        params = {
            'q': query,
            'limit': limit,
            'appid': self.api_key
        }
        
        try:
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            locations = []
            for item in data:
                locations.append({
                    'name': item['name'],
                    'country': item['country'],
                    'state': item.get('state', ''),
                    'coordinates': {
                        'lat': item['lat'],
                        'lon': item['lon']
                    }
                })
            
            # Cache for 1 hour
            cache.set(cache_key, locations, timeout=3600)
            return locations
            
        except requests.RequestException as e:
            raise Exception(f"Failed to search locations: {str(e)}")

# Initialize weather service
weather_service = WeatherService()

@app.route('/')
def home():
    return jsonify({
        'message': 'Weather API Service',
        'version': '1.0.0',
        'endpoints': {
            'current_weather': '/api/weather/current?lat={lat}&lon={lon}',
            'forecast': '/api/weather/forecast?lat={lat}&lon={lon}&days={days}',
            'search_locations': '/api/locations/search?q={query}&limit={limit}',
            'health': '/api/health'
        }
    })

@app.route('/api/health')
def health_check():
    """Health check endpoint"""
    try:
        # Test Redis connection
        cache.get('health_check')
        redis_status = 'connected'
    except:
        redis_status = 'disconnected'
    
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'services': {
            'redis': redis_status,
            'weather_api': 'configured' if WEATHER_API_KEY else 'not_configured'
        }
    })

@app.route('/api/weather/current')
def get_current_weather():
    """Get current weather for specified coordinates"""
    lat = request.args.get('lat', type=float)
    lon = request.args.get('lon', type=float)
    
    if lat is None or lon is None:
        return jsonify({'error': 'Latitude and longitude are required'}), 400
    
    if not (-90 <= lat <= 90) or not (-180 <= lon <= 180):
        return jsonify({'error': 'Invalid coordinates'}), 400
    
    try:
        weather_data = weather_service.get_current_weather(lat, lon)
        return jsonify(weather_data)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/weather/forecast')
def get_forecast():
    """Get weather forecast for specified coordinates"""
    lat = request.args.get('lat', type=float)
    lon = request.args.get('lon', type=float)
    days = request.args.get('days', default=5, type=int)
    
    if lat is None or lon is None:
        return jsonify({'error': 'Latitude and longitude are required'}), 400
    
    if not (-90 <= lat <= 90) or not (-180 <= lon <= 180):
        return jsonify({'error': 'Invalid coordinates'}), 400
    
    if not (1 <= days <= 7):
        return jsonify({'error': 'Days must be between 1 and 7'}), 400
    
    try:
        forecast_data = weather_service.get_forecast(lat, lon, days)
        return jsonify({'forecast': forecast_data})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/locations/search')
def search_locations():
    """Search for locations by name"""
    query = request.args.get('q', '').strip()
    limit = request.args.get('limit', default=5, type=int)
    
    if not query:
        return jsonify({'error': 'Search query is required'}), 400
    
    if len(query) < 2:
        return jsonify({'error': 'Search query must be at least 2 characters'}), 400
    
    if not (1 <= limit <= 20):
        return jsonify({'error': 'Limit must be between 1 and 20'}), 400
    
    try:
        locations = weather_service.search_locations(query, limit)
        return jsonify({'locations': locations})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/weather/historical')
def get_historical_weather():
    """Get historical weather data (placeholder for premium API)"""
    return jsonify({
        'message': 'Historical weather data requires premium API access',
        'available_endpoints': [
            '/api/weather/current',
            '/api/weather/forecast'
        ]
    }), 501

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5001))
    debug = os.getenv('FLASK_ENV') == 'development'
    app.run(host='0.0.0.0', port=port, debug=debug)
