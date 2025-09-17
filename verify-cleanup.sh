#!/bin/bash

# Database Cleanup Verification Script

echo "🔍 Verifying Database Cleanup"
echo "============================="

# Check for database binaries
echo "Checking for database binaries:"
for cmd in psql redis-server redis-cli mongod mongo mysql; do
    if command -v $cmd &> /dev/null; then
        echo "  ❌ $cmd still found at: $(which $cmd)"
    else
        echo "  ✅ $cmd not found (good)"
    fi
done

# Check for running database processes
echo ""
echo "Checking for running database processes:"
db_processes=$(ps aux | grep -E "(postgres|redis|mongo|mysql)" | grep -v grep | grep -v docker | grep -v cleanup)
if [[ -n "$db_processes" ]]; then
    echo "  ❌ Found running database processes:"
    echo "$db_processes"
else
    echo "  ✅ No local database processes running"
fi

# Check for Homebrew database packages
echo ""
echo "Checking Homebrew packages:"
db_packages=$(brew list 2>/dev/null | grep -E "(postgresql|mysql|redis|mongodb)")
if [[ -n "$db_packages" ]]; then
    echo "  ❌ Found database packages:"
    echo "$db_packages"
else
    echo "  ✅ No database packages found in Homebrew"
fi

# Check for database services
echo ""
echo "Checking Homebrew services:"
db_services=$(brew services list 2>/dev/null | grep -E "(postgresql|mysql|redis|mongodb)")
if [[ -n "$db_services" ]]; then
    echo "  ❌ Found database services:"
    echo "$db_services"
else
    echo "  ✅ No database services found"
fi

# Check for data directories
echo ""
echo "Checking for database data directories:"
data_dirs_found=false
for dir in /usr/local/var/postgres* /opt/homebrew/var/postgres* /usr/local/var/mysql* /opt/homebrew/var/mysql* /usr/local/var/mongodb* /opt/homebrew/var/mongodb* /usr/local/var/db/redis* /opt/homebrew/var/db/redis*; do
    if [[ -d "$dir" ]]; then
        echo "  ❌ Found data directory: $dir"
        data_dirs_found=true
    fi
done

if [[ "$data_dirs_found" = false ]]; then
    echo "  ✅ No database data directories found"
fi

echo ""
echo "📦 Container Status Check:"
echo "========================="

# Check our containerized databases
for app in medical-care-system ecommerce-app educational-platform task-management-app weather-app social-media-platform; do
    if [[ -f "/Users/charlie/Documents/PERSONAL/$app/docker-compose.yml" ]]; then
        echo "  ✅ $app has docker-compose.yml"
    else
        echo "  ❌ $app missing docker-compose.yml"
    fi
done

echo ""
echo "🎉 Cleanup verification complete!"
echo ""
echo "If you see any ❌ items above, you may need to manually remove them."
echo "All ✅ items indicate successful cleanup."
