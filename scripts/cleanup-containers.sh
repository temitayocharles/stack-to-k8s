#!/bin/bash
# 🐳 MANDATORY CONTAINER CLEANUP SCRIPT
# Implements container resource management from anchor document

# Colors for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "${BLUE}🐳 STARTING CONTAINER CLEANUP...${NC}"

# Check if Docker is available
if ! command -v docker >/dev/null 2>&1; then
    echo "${YELLOW}⚠️  Docker not available - skipping container cleanup${NC}"
    exit 0
fi

# Record initial state
INITIAL_CONTAINERS=$(docker ps -a -q 2>/dev/null | wc -l)
INITIAL_IMAGES=$(docker images -q 2>/dev/null | wc -l)
INITIAL_VOLUMES=$(docker volume ls -q 2>/dev/null | wc -l)
INITIAL_NETWORKS=$(docker network ls -q 2>/dev/null | wc -l)

echo "${BLUE}📊 Initial state:${NC}"
echo "   Containers: $INITIAL_CONTAINERS"
echo "   Images: $INITIAL_IMAGES"
echo "   Volumes: $INITIAL_VOLUMES"
echo "   Networks: $INITIAL_NETWORKS"

# 1. Stop all running containers from docker-compose
echo "${YELLOW}  Stopping docker-compose services...${NC}"
for compose_file in docker-compose.yml docker-compose.*.yml; do
    if [ -f "$compose_file" ]; then
        echo "${BLUE}    Stopping services from $compose_file${NC}"
        docker-compose -f "$compose_file" down 2>/dev/null || true
    fi
done

# Also check in subdirectories for compose files
find . -name "docker-compose*.yml" -not -path "./global-configs/*" | while read -r compose_file; do
    if [ -f "$compose_file" ]; then
        echo "${BLUE}    Stopping services from $compose_file${NC}"
        (cd "$(dirname "$compose_file")" && docker-compose down 2>/dev/null || true)
    fi
done

# 2. Remove stopped containers
echo "${YELLOW}  Removing stopped containers...${NC}"
STOPPED_CONTAINERS=$(docker container prune -f 2>/dev/null | grep "Total reclaimed space" || echo "0 containers")
echo "${GREEN}    $STOPPED_CONTAINERS${NC}"

# 3. Remove unused images (not currently used by any container)
echo "${YELLOW}  Removing unused images...${NC}"
UNUSED_IMAGES=$(docker image prune -f 2>/dev/null | grep "Total reclaimed space" || echo "0 images")
echo "${GREEN}    $UNUSED_IMAGES${NC}"

# 4. Remove unused volumes
echo "${YELLOW}  Removing unused volumes...${NC}"
UNUSED_VOLUMES=$(docker volume prune -f 2>/dev/null | grep "Total reclaimed space" || echo "0 volumes")
echo "${GREEN}    $UNUSED_VOLUMES${NC}"

# 5. Remove unused networks
echo "${YELLOW}  Removing unused networks...${NC}"
UNUSED_NETWORKS=$(docker network prune -f 2>/dev/null | grep "Deleted Networks" || echo "0 networks")
echo "${GREEN}    $UNUSED_NETWORKS${NC}"

# 6. System-wide cleanup (removes all unused Docker objects)
echo "${YELLOW}  Running system-wide cleanup...${NC}"
SYSTEM_CLEANUP=$(docker system prune -f 2>/dev/null | grep "Total reclaimed space" || echo "No additional cleanup needed")
echo "${GREEN}    $SYSTEM_CLEANUP${NC}"

# 7. Check for running containers that might need attention
RUNNING_CONTAINERS=$(docker ps -q 2>/dev/null | wc -l)
if [ "$RUNNING_CONTAINERS" -gt 0 ]; then
    echo "${YELLOW}⚠️  Warning: $RUNNING_CONTAINERS containers still running${NC}"
    echo "${BLUE}    Running containers:${NC}"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" 2>/dev/null || true
    echo "${YELLOW}    These may be intentionally running services${NC}"
fi

# 8. Record final state
FINAL_CONTAINERS=$(docker ps -a -q 2>/dev/null | wc -l)
FINAL_IMAGES=$(docker images -q 2>/dev/null | wc -l)
FINAL_VOLUMES=$(docker volume ls -q 2>/dev/null | wc -l)
FINAL_NETWORKS=$(docker network ls -q 2>/dev/null | wc -l)

# 9. Generate cleanup report
echo ""
echo "${BLUE}📋 CONTAINER CLEANUP REPORT${NC}"
echo "=========================="
echo "Containers: $INITIAL_CONTAINERS → $FINAL_CONTAINERS (removed: $((INITIAL_CONTAINERS - FINAL_CONTAINERS)))"
echo "Images: $INITIAL_IMAGES → $FINAL_IMAGES (removed: $((INITIAL_IMAGES - FINAL_IMAGES)))"
echo "Volumes: $INITIAL_VOLUMES → $FINAL_VOLUMES (removed: $((INITIAL_VOLUMES - FINAL_VOLUMES)))"
echo "Networks: $INITIAL_NETWORKS → $FINAL_NETWORKS (removed: $((INITIAL_NETWORKS - FINAL_NETWORKS)))"

# 10. Check Docker disk usage
echo ""
echo "${BLUE}📊 DOCKER DISK USAGE:${NC}"
docker system df 2>/dev/null || echo "Unable to get Docker disk usage"

# 11. Validate cleanup success
if [ "$RUNNING_CONTAINERS" -eq 0 ]; then
    echo "${GREEN}✅ CONTAINER CLEANUP SUCCESSFUL - All test containers removed${NC}"
    echo "${GREEN}✅ RESOURCES LIBERATED - Ready for next development cycle${NC}"
    exit 0
else
    echo "${YELLOW}⚠️  PARTIAL CLEANUP - Some containers still running${NC}"
    echo "${YELLOW}   This may be intentional for ongoing development${NC}"
    exit 0
fi