#!/bin/bash
# Access monitoring services locally

echo "🚀 Starting monitoring service access..."
echo "======================================="

# Port forward Grafana
echo "📈 Grafana will be available at: http://localhost:3001"
echo "   Username: admin"
echo "   Password: admin123"
kubectl port-forward -n monitoring svc/grafana 3001:3000 &

# Port forward Prometheus
echo "📊 Prometheus will be available at: http://localhost:9090"
kubectl port-forward -n monitoring svc/prometheus 9090:9090 &

# Port forward AlertManager
echo "🚨 AlertManager will be available at: http://localhost:9093"
kubectl port-forward -n monitoring svc/alertmanager 9093:9093 &

echo ""
echo "✅ All monitoring services are now accessible!"
echo "   Press Ctrl+C to stop all port-forwards"

# Wait for user interrupt
wait
