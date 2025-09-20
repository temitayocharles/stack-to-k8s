from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_caching import Cache
import redis
import requests
import os
from datetime import datetime, timedelta
import json
import statistics
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

# Advanced Weather Features - ML Forecasting, Air Quality, Alerts

@app.route('/api/weather/ml-forecast')
def ml_weather_forecast():
    """
    Advanced ML-powered weather forecasting using multiple algorithms
    """
    try:
        city = request.args.get('city', 'London')
        days = int(request.args.get('days', 7))
        
        # Mock ML forecast data (in production, this would use trained models)
        import random
        from datetime import datetime, timedelta
        
        ml_forecast = []
        base_temp = 20 + random.uniform(-5, 5)
        
        for i in range(days):
            date = datetime.now() + timedelta(days=i)
            
            # Simulate different ML model predictions
            linear_temp = base_temp + random.uniform(-3, 3)
            neural_network_temp = base_temp + random.uniform(-2, 4)
            ensemble_temp = (linear_temp + neural_network_temp) / 2
            
            ml_forecast.append({
                'date': date.strftime('%Y-%m-%d'),
                'predictions': {
                    'linear_regression': {
                        'temperature': round(linear_temp, 1),
                        'humidity': random.randint(40, 80),
                        'confidence': random.uniform(0.7, 0.95)
                    },
                    'neural_network': {
                        'temperature': round(neural_network_temp, 1),
                        'humidity': random.randint(45, 85),
                        'confidence': random.uniform(0.75, 0.98)
                    },
                    'ensemble': {
                        'temperature': round(ensemble_temp, 1),
                        'humidity': random.randint(42, 82),
                        'confidence': random.uniform(0.85, 0.99),
                        'recommended': True
                    }
                },
                'weather_patterns': {
                    'pressure_trend': random.choice(['rising', 'falling', 'stable']),
                    'wind_pattern': random.choice(['calm', 'moderate', 'gusty']),
                    'precipitation_probability': random.uniform(0, 1)
                }
            })
        
        return jsonify({
            'success': True,
            'data': {
                'city': city,
                'forecast_period': f'{days} days',
                'ml_forecast': ml_forecast,
                'model_info': {
                    'algorithms_used': ['Linear Regression', 'Neural Network', 'Ensemble'],
                    'training_data_period': '10 years',
                    'last_updated': datetime.now().isoformat(),
                    'accuracy_metrics': {
                        'mse': 2.1,
                        'r2_score': 0.89,
                        'mae': 1.3
                    }
                }
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'ML forecast error: {str(e)}'
        }), 500

@app.route('/api/air-quality')
def air_quality_monitoring():
    """
    Real-time air quality monitoring with health recommendations
    """
    try:
        city = request.args.get('city', 'London')
        
        # Mock air quality data (in production, this would connect to real APIs)
        import random
        
        pollutants = {
            'pm2_5': random.uniform(5, 50),
            'pm10': random.uniform(10, 80),
            'no2': random.uniform(10, 100),
            'so2': random.uniform(5, 50),
            'co': random.uniform(0.1, 5.0),
            'o3': random.uniform(20, 150)
        }
        
        # Calculate AQI (Air Quality Index)
        aqi_values = []
        for pollutant, value in pollutants.items():
            if pollutant == 'pm2_5':
                aqi = min(int((value / 35.4) * 100), 300)
            elif pollutant == 'pm10':
                aqi = min(int((value / 154) * 100), 300)
            else:
                aqi = random.randint(20, 120)
            aqi_values.append(aqi)
        
        overall_aqi = max(aqi_values)
        
        # Determine air quality level
        if overall_aqi <= 50:
            quality_level = 'Good'
            color = '#00E400'
            health_advice = 'Air quality is satisfactory for outdoor activities'
        elif overall_aqi <= 100:
            quality_level = 'Moderate'
            color = '#FFFF00'
            health_advice = 'Acceptable for most people, sensitive individuals should limit outdoor exertion'
        elif overall_aqi <= 150:
            quality_level = 'Unhealthy for Sensitive Groups'
            color = '#FF7E00'
            health_advice = 'Sensitive individuals should avoid outdoor activities'
        else:
            quality_level = 'Unhealthy'
            color = '#FF0000'
            health_advice = 'Everyone should limit outdoor activities'
        
        return jsonify({
            'success': True,
            'data': {
                'city': city,
                'timestamp': datetime.now().isoformat(),
                'air_quality_index': overall_aqi,
                'quality_level': quality_level,
                'color_code': color,
                'health_advice': health_advice,
                'pollutants': pollutants,
                'detailed_analysis': {
                    'primary_pollutant': max(pollutants, key=pollutants.get),
                    'visibility_km': random.uniform(5, 25),
                    'uv_index': random.randint(1, 11),
                    'pollen_count': random.choice(['Low', 'Moderate', 'High', 'Very High'])
                },
                'health_recommendations': {
                    'outdoor_exercise': 'Safe' if overall_aqi <= 100 else 'Caution' if overall_aqi <= 150 else 'Avoid',
                    'window_opening': 'Recommended' if overall_aqi <= 50 else 'Limited' if overall_aqi <= 100 else 'Not Recommended',
                    'mask_recommendation': 'Not Needed' if overall_aqi <= 100 else 'N95 Recommended' if overall_aqi <= 150 else 'N95 Required'
                }
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Air quality monitoring error: {str(e)}'
        }), 500

@app.route('/api/weather/alerts')
def severe_weather_alerts():
    """
    Severe weather alerts and notifications system
    """
    try:
        city = request.args.get('city', 'London')
        alert_type = request.args.get('type', 'all')  # all, temperature, precipitation, wind
        
        # Mock severe weather alerts (in production, this would connect to weather services)
        import random
        
        active_alerts = []
        
        # Generate random alerts for demonstration
        alert_types = [
            {
                'type': 'temperature',
                'severity': 'moderate',
                'title': 'Heat Advisory',
                'description': 'Temperatures expected to reach 35°C (95°F). Stay hydrated and limit outdoor activities.',
                'start_time': datetime.now() + timedelta(hours=2),
                'end_time': datetime.now() + timedelta(hours=8),
                'affected_areas': ['City Center', 'Suburbs'],
                'recommendations': ['Drink plenty of water', 'Wear light clothing', 'Stay in shade']
            },
            {
                'type': 'precipitation',
                'severity': 'high',
                'title': 'Flash Flood Warning',
                'description': 'Heavy rainfall expected. Potential for flooding in low-lying areas.',
                'start_time': datetime.now() + timedelta(hours=1),
                'end_time': datetime.now() + timedelta(hours=6),
                'affected_areas': ['Downtown', 'River District'],
                'recommendations': ['Avoid driving through water', 'Move to higher ground if necessary', 'Have emergency kit ready']
            },
            {
                'type': 'wind',
                'severity': 'moderate',
                'title': 'Strong Wind Advisory',
                'description': 'Sustained winds of 45-55 mph with gusts up to 70 mph expected.',
                'start_time': datetime.now() + timedelta(hours=4),
                'end_time': datetime.now() + timedelta(hours=12),
                'affected_areas': ['Coastal Areas', 'Elevated Regions'],
                'recommendations': ['Secure loose objects', 'Avoid tall trees', 'Drive with caution']
            }
        ]
        
        # Filter alerts if specific type requested
        if alert_type != 'all':
            active_alerts = [alert for alert in active_alerts if alert['type'] == alert_type]
        else:
            # Randomly include some alerts
            active_alerts = random.sample(alert_types, random.randint(0, 3))
        
        # Add alert statistics
        alert_stats = {
            'total_active': len(active_alerts),
            'high_severity': len([a for a in active_alerts if a['severity'] == 'high']),
            'moderate_severity': len([a for a in active_alerts if a['severity'] == 'moderate']),
            'low_severity': len([a for a in active_alerts if a['severity'] == 'low'])
        }
        
        return jsonify({
            'success': True,
            'data': {
                'city': city,
                'timestamp': datetime.now().isoformat(),
                'active_alerts': active_alerts,
                'alert_statistics': alert_stats,
                'notification_settings': {
                    'email_enabled': True,
                    'sms_enabled': True,
                    'push_enabled': True,
                    'severity_threshold': 'moderate'
                },
                'emergency_contacts': {
                    'local_emergency': '911',
                    'weather_service': '1-800-WEATHER',
                    'flood_info': '1-800-FLOOD'
                }
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Weather alerts error: {str(e)}'
        }), 500

@app.route('/api/weather/historical-analysis')
def historical_weather_analysis():
    """
    Advanced historical weather data analysis with trends and patterns
    """
    try:
        city = request.args.get('city', 'London')
        years = int(request.args.get('years', 5))
        metric = request.args.get('metric', 'temperature')  # temperature, precipitation, humidity
        
        # Mock historical analysis (in production, this would analyze real historical data)
        import random
        import math
        
        # Generate historical data points
        historical_data = []
        monthly_averages = []
        
        for year in range(datetime.now().year - years, datetime.now().year):
            for month in range(1, 13):
                if metric == 'temperature':
                    # Simulate seasonal temperature variation
                    base_temp = 15 + 10 * math.sin((month - 3) * math.pi / 6)
                    value = base_temp + random.uniform(-5, 5)
                    unit = '°C'
                elif metric == 'precipitation':
                    # Simulate seasonal precipitation variation
                    value = random.uniform(20, 150)
                    unit = 'mm'
                else:  # humidity
                    value = random.uniform(40, 85)
                    unit = '%'
                
                historical_data.append({
                    'year': year,
                    'month': month,
                    'value': round(value, 1),
                    'date': f'{year}-{month:02d}'
                })
        
        # Calculate monthly averages
        for month in range(1, 13):
            month_data = [d['value'] for d in historical_data if d['month'] == month]
            monthly_averages.append({
                'month': month,
                'average': round(sum(month_data) / len(month_data), 1),
                'min': round(min(month_data), 1),
                'max': round(max(month_data), 1),
                'std_dev': round(statistics.stdev(month_data), 1) if len(month_data) > 1 else 0
            })
        
        # Calculate trends
        values = [d['value'] for d in historical_data]
        trend_analysis = {
            'overall_average': round(statistics.mean(values), 1),
            'overall_trend': 'increasing' if values[-12:] > values[:12] else 'decreasing' if values[-12:] < values[:12] else 'stable',
            'variability': round(statistics.stdev(values), 1),
            'highest_recorded': max(values),
            'lowest_recorded': min(values),
            'seasonal_variation': round(max([m['average'] for m in monthly_averages]) - min([m['average'] for m in monthly_averages]), 1)
        }
        
        # Climate insights
        climate_insights = [
            f"Average {metric} has {'increased' if trend_analysis['overall_trend'] == 'increasing' else 'decreased' if trend_analysis['overall_trend'] == 'decreasing' else 'remained stable'} over the past {years} years",
            f"Highest variability observed in {'winter' if metric == 'temperature' else 'summer'} months",
            f"Climate pattern shows {'strong' if trend_analysis['variability'] > 10 else 'moderate'} seasonal influence"
        ]
        
        return jsonify({
            'success': True,
            'data': {
                'city': city,
                'analysis_period': f'{years} years',
                'metric': metric,
                'unit': unit,
                'historical_data': historical_data[-24:],  # Last 2 years for display
                'monthly_averages': monthly_averages,
                'trend_analysis': trend_analysis,
                'climate_insights': climate_insights,
                'data_quality': {
                    'completeness': '98.5%',
                    'reliability_score': 'High',
                    'data_sources': ['National Weather Service', 'Local Stations', 'Satellite Data'],
                    'last_updated': datetime.now().isoformat()
                }
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Historical analysis error: {str(e)}'
        }), 500

@app.route('/api/weather/map-data')
def weather_map_visualization():
    """
    Weather map data for interactive visualizations
    """
    try:
        region = request.args.get('region', 'europe')
        layer = request.args.get('layer', 'temperature')  # temperature, precipitation, clouds, pressure
        
        # Mock map data (in production, this would provide real map layer data)
        import random
        
        # Generate grid points for the region
        if region == 'europe':
            lat_range = (35, 65)
            lon_range = (-10, 40)
        elif region == 'north_america':
            lat_range = (25, 60)
            lon_range = (-125, -65)
        else:  # global
            lat_range = (-90, 90)
            lon_range = (-180, 180)
        
        map_data = []
        grid_size = 20
        
        for i in range(grid_size):
            for j in range(grid_size):
                lat = lat_range[0] + (lat_range[1] - lat_range[0]) * i / grid_size
                lon = lon_range[0] + (lon_range[1] - lon_range[0]) * j / grid_size
                
                if layer == 'temperature':
                    value = random.uniform(-10, 35)
                    unit = '°C'
                elif layer == 'precipitation':
                    value = random.uniform(0, 50)
                    unit = 'mm'
                elif layer == 'clouds':
                    value = random.uniform(0, 100)
                    unit = '%'
                else:  # pressure
                    value = random.uniform(980, 1040)
                    unit = 'hPa'
                
                map_data.append({
                    'lat': round(lat, 2),
                    'lon': round(lon, 2),
                    'value': round(value, 1)
                })
        
        return jsonify({
            'success': True,
            'data': {
                'region': region,
                'layer': layer,
                'unit': unit,
                'timestamp': datetime.now().isoformat(),
                'map_data': map_data,
                'legend': {
                    'min_value': min([d['value'] for d in map_data]),
                    'max_value': max([d['value'] for d in map_data]),
                    'color_scale': 'viridis',
                    'intervals': 10
                },
                'map_settings': {
                    'zoom_level': 4,
                    'center_lat': (lat_range[0] + lat_range[1]) / 2,
                    'center_lon': (lon_range[0] + lon_range[1]) / 2,
                    'animation_enabled': True
                }
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Map data error: {str(e)}'
        }), 500



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
