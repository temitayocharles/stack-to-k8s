#!/bin/bash

# Database Cleanup Script for macOS
# Removes locally installed databases since we're now using containers

echo "🧹 Database Cleanup Script - Removing Local Database Installations"
echo "=================================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${RED}[WARNING]${NC} $1"
}

# Stop running database services first
print_status "Stopping local database services..."

echo "Stopping Homebrew database services:"
brew services stop postgresql@15 2>/dev/null || true
brew services stop postgresql@14 2>/dev/null || true
brew services stop postgresql 2>/dev/null || true
brew services stop redis 2>/dev/null || true
brew services stop mongodb-community 2>/dev/null || true
brew services stop mongodb/brew/mongodb-community 2>/dev/null || true
brew services stop mysql 2>/dev/null || true

# Check and remove PostgreSQL
print_status "Checking for PostgreSQL installations..."
if command -v psql &> /dev/null; then
    print_warning "PostgreSQL found. Removing..."
    
    # Stop services
    brew services stop postgresql 2>/dev/null || true
    
    # Remove Homebrew PostgreSQL
    brew uninstall --ignore-dependencies postgresql@15 2>/dev/null || true
    brew uninstall --ignore-dependencies postgresql@14 2>/dev/null || true  
    brew uninstall --ignore-dependencies postgresql 2>/dev/null || true
    brew uninstall --ignore-dependencies libpq 2>/dev/null || true
    
    # Remove data directories
    rm -rf /usr/local/var/postgres* 2>/dev/null || true
    rm -rf /opt/homebrew/var/postgres* 2>/dev/null || true
    rm -rf ~/Library/Application\ Support/Postgres* 2>/dev/null || true
    
    # Remove PostgreSQL.app if installed
    rm -rf /Applications/PostgreSQL*.app 2>/dev/null || true
    
    print_success "PostgreSQL removed"
else
    print_success "PostgreSQL not found locally"
fi

# Check and remove Redis
print_status "Checking for Redis installations..."
if command -v redis-server &> /dev/null; then
    print_warning "Redis found. Removing..."
    
    # Stop services
    brew services stop redis 2>/dev/null || true
    
    # Remove Homebrew Redis
    brew uninstall --ignore-dependencies redis 2>/dev/null || true
    
    # Remove data directories
    rm -rf /usr/local/var/db/redis* 2>/dev/null || true
    rm -rf /opt/homebrew/var/db/redis* 2>/dev/null || true
    
    print_success "Redis removed"
else
    print_success "Redis not found locally"
fi

# Check and remove MongoDB
print_status "Checking for MongoDB installations..."
if command -v mongod &> /dev/null; then
    print_warning "MongoDB found. Removing..."
    
    # Stop services
    brew services stop mongodb-community 2>/dev/null || true
    brew services stop mongodb/brew/mongodb-community 2>/dev/null || true
    
    # Remove Homebrew MongoDB
    brew uninstall --ignore-dependencies mongodb-community 2>/dev/null || true
    brew uninstall --ignore-dependencies mongodb-database-tools 2>/dev/null || true
    brew uninstall --ignore-dependencies mongosh 2>/dev/null || true
    
    # Remove MongoDB tap
    brew untap mongodb/brew 2>/dev/null || true
    
    # Remove data directories
    rm -rf /usr/local/var/mongodb* 2>/dev/null || true
    rm -rf /opt/homebrew/var/mongodb* 2>/dev/null || true
    rm -rf /usr/local/var/log/mongodb* 2>/dev/null || true
    rm -rf /opt/homebrew/var/log/mongodb* 2>/dev/null || true
    
    print_success "MongoDB removed"
else
    print_success "MongoDB not found locally"
fi

# Check and remove MySQL
print_status "Checking for MySQL installations..."
if command -v mysql &> /dev/null; then
    print_warning "MySQL found. Removing..."
    
    # Stop services
    brew services stop mysql 2>/dev/null || true
    
    # Remove Homebrew MySQL
    brew uninstall --ignore-dependencies mysql 2>/dev/null || true
    
    # Remove data directories
    rm -rf /usr/local/var/mysql* 2>/dev/null || true
    rm -rf /opt/homebrew/var/mysql* 2>/dev/null || true
    
    print_success "MySQL removed"
else
    print_success "MySQL not found locally"
fi

# Check and remove SQL Server tools
print_status "Checking for SQL Server tools..."
if command -v sqlcmd &> /dev/null; then
    print_warning "SQL Server tools found. Removing..."
    
    # Remove Microsoft SQL Server tools
    brew uninstall --ignore-dependencies mssql-tools 2>/dev/null || true
    brew uninstall --ignore-dependencies msodbcsql17 2>/dev/null || true
    
    print_success "SQL Server tools removed"
else
    print_success "SQL Server tools not found locally"
fi

# Clean up remaining database-related packages
print_status "Cleaning up database-related packages..."
brew uninstall --ignore-dependencies pgcli 2>/dev/null || true
brew uninstall --ignore-dependencies redis-cli 2>/dev/null || true
brew uninstall --ignore-dependencies sqlite 2>/dev/null || true

# Clean up Homebrew
print_status "Cleaning up Homebrew..."
brew cleanup
brew autoremove

# Remove any remaining configuration files
print_status "Removing configuration files..."
rm -rf ~/.pgpass 2>/dev/null || true
rm -rf ~/.redis* 2>/dev/null || true
rm -rf ~/.mongorc.js 2>/dev/null || true
rm -rf ~/.my.cnf 2>/dev/null || true

# Check for remaining processes
print_status "Checking for remaining database processes..."
remaining_processes=$(ps aux | grep -E "(postgres|redis|mongo|mysql)" | grep -v grep | grep -v docker || true)
if [[ -n "$remaining_processes" ]]; then
    print_warning "Some database processes are still running:"
    echo "$remaining_processes"
    echo "You may need to manually stop these processes."
else
    print_success "No remaining database processes found"
fi

echo ""
print_success "Database cleanup completed!"
echo ""
echo "📦 All applications now use containerized databases:"
echo "   🏥 Medical Care System  → SQL Server 2022 container"
echo "   🛒 E-commerce App       → MongoDB + Redis containers"  
echo "   🎓 Educational Platform → PostgreSQL + Redis containers"
echo "   📋 Task Management App  → PostgreSQL container"
echo "   🌤️ Weather App          → Redis container"
echo "   📱 Social Media Platform → PostgreSQL + Redis containers"
echo ""
echo "✅ Your system is now clean and all databases run in containers!"
