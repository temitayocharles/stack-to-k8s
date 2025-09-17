#!/bin/sh

# Docker entrypoint script for Angular frontend
# This script allows for runtime environment variable configuration

echo "Starting Educational Platform Frontend..."

# Replace environment variables in nginx config if needed
if [ ! -z "$API_URL" ]; then
    echo "Configuring API URL: $API_URL"
    # Replace placeholder in nginx config if any
    sed -i "s|http://backend:8080|$API_URL|g" /etc/nginx/nginx.conf
fi

if [ ! -z "$WS_URL" ]; then
    echo "Configuring WebSocket URL: $WS_URL"
    # Replace placeholder in nginx config if any
    sed -i "s|ws://backend:8080|$WS_URL|g" /etc/nginx/nginx.conf
fi

# Create environment configuration for Angular at runtime
cat > /usr/share/nginx/html/assets/env.js << EOF
window['env'] = {
  production: ${PRODUCTION:-true},
  apiUrl: '${API_URL:-http://localhost:8080/api}',
  wsUrl: '${WS_URL:-ws://localhost:8080/ws}',
  features: {
    enableNotifications: ${ENABLE_NOTIFICATIONS:-true},
    enableChat: ${ENABLE_CHAT:-true},
    enableVideoCall: ${ENABLE_VIDEO_CALL:-true},
    enableAnalytics: ${ENABLE_ANALYTICS:-true},
    enableDarkMode: ${ENABLE_DARK_MODE:-true}
  }
};
EOF

echo "Environment configuration created"
echo "API URL: ${API_URL:-http://localhost:8080/api}"
echo "WebSocket URL: ${WS_URL:-ws://localhost:8080/ws}"

# Test nginx configuration
echo "Testing nginx configuration..."
nginx -t

if [ $? -eq 0 ]; then
    echo "Nginx configuration is valid"
else
    echo "Nginx configuration is invalid"
    exit 1
fi

echo "Starting nginx..."
exec "$@"
