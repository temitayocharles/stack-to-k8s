#!/bin/bash

# 🐳 CONTAINER CLEANUP SCRIPT
# Removes all unused containers, images, and volumes to free up resources

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 Starting Container Cleanup...${NC}"
echo "================================="

# 1. Stop all running containers from docker-compose
echo -e "\n${YELLOW}🛑 Stopping all docker-compose services...${NC}"
for compose_file in $(find . -name "docker-compose.yml" -o -name "docker-compose.yaml"); do
    compose_dir=$(dirname "$compose_file")
    echo "Stopping services in: $compose_dir"
    (cd "$compose_dir" && docker-compose down 2>/dev/null) || true
done

# 2. Remove stopped containers
echo -e "\n${YELLOW}🗑️  Removing stopped containers...${NC}"
STOPPED_CONTAINERS=$(docker container ls -aq --filter "status=exited" 2>/dev/null || true)
if [ -n "$STOPPED_CONTAINERS" ]; then
    docker container rm $STOPPED_CONTAINERS 2>/dev/null || true
    echo "Removed stopped containers"
else
    echo "No stopped containers to remove"
fi

# 3. Remove unused images
echo -e "\n${YELLOW}🖼️  Removing unused images...${NC}"
UNUSED_IMAGES=$(docker image ls -q --filter "dangling=true" 2>/dev/null || true)
if [ -n "$UNUSED_IMAGES" ]; then
    docker image rm $UNUSED_IMAGES 2>/dev/null || true
    echo "Removed dangling images"
else
    echo "No dangling images to remove"
fi

# 4. Remove unused volumes
echo -e "\n${YELLOW}💾 Removing unused volumes...${NC}"
UNUSED_VOLUMES=$(docker volume ls -q --filter "dangling=true" 2>/dev/null || true)
if [ -n "$UNUSED_VOLUMES" ]; then
    docker volume rm $UNUSED_VOLUMES 2>/dev/null || true
    echo "Removed unused volumes"
else
    echo "No unused volumes to remove"
fi

# 5. Remove unused networks
echo -e "\n${YELLOW}🌐 Removing unused networks...${NC}"
docker network prune -f 2>/dev/null || true

# 6. System-wide cleanup
echo -e "\n${YELLOW}🧹 Running system-wide cleanup...${NC}"
docker system prune -f 2>/dev/null || true

# 7. Display cleanup summary
echo -e "\n${GREEN}✅ Container cleanup completed successfully!${NC}"
echo ""

# 8. Show current Docker usage
echo -e "${BLUE}📊 Current Docker resource usage:${NC}"
echo "=================================="
docker system df 2>/dev/null || echo "Docker system information unavailable"

echo ""
echo -e "${GREEN}🎯 Docker resources are now clean and optimized!${NC}"
echo ""

# 9. Show running containers (should be minimal or none)
RUNNING_CONTAINERS=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
if [ "$RUNNING_CONTAINERS" -eq 0 ]; then
    echo -e "${GREEN}✅ No containers currently running${NC}"
else
    echo -e "${YELLOW}ℹ️  $RUNNING_CONTAINERS containers still running:${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}🚀 Ready for next development work!${NC}"