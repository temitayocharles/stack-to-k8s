#!/bin/bash

# 📋 CHECKPOINT LOGGER - AUTOMATED SESSION TRACKING
# Usage: ./checkpoint-logger.sh "Session Description" [milestone_name]

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SESSION_LOG="SESSION_LOG.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
SESSION_DATE=$(date '+%Y-%m-%d %H:%M')

# Function to log session start
log_session_start() {
    local description="$1"
    
    echo -e "${CYAN}📋 LOGGING SESSION START: $description${NC}"
    
    # Add session header
    echo "" >> "$SESSION_LOG"
    echo "## SESSION: $SESSION_DATE - $description" >> "$SESSION_LOG"
    echo "" >> "$SESSION_LOG"
    
    # Add starting context
    echo "### STARTING CONTEXT" >> "$SESSION_LOG"
    echo "- Session started: $TIMESTAMP" >> "$SESSION_LOG"
    echo "- Last commit: $(git log -1 --oneline 2>/dev/null || echo 'No commits')" >> "$SESSION_LOG"
    echo "- Branch: $(git branch --show-current 2>/dev/null || echo 'No git repo')" >> "$SESSION_LOG"
    echo "- Workspace size: $(du -sh . | awk '{print $1}')" >> "$SESSION_LOG"
    echo "- Running containers: $(docker ps -q | wc -l)" >> "$SESSION_LOG"
    echo "- Working directory: $(pwd)" >> "$SESSION_LOG"
    echo "" >> "$SESSION_LOG"
    
    echo "### WORK COMPLETED THIS SESSION" >> "$SESSION_LOG"
    echo "" >> "$SESSION_LOG"
}

# Function to log milestone
log_milestone() {
    local milestone="$1"
    local action="$2"
    local result="$3"
    local verification="$4"
    
    echo -e "${YELLOW}📊 LOGGING MILESTONE: $milestone${NC}"
    
    echo "#### $TIMESTAMP - $milestone" >> "$SESSION_LOG"
    echo "- **Action**: $action" >> "$SESSION_LOG"
    echo "- **Result**: $result" >> "$SESSION_LOG"
    if [ -n "$verification" ]; then
        echo "- **Verified**: $verification" >> "$SESSION_LOG"
    fi
    
    # Auto-detect git commit if available
    local latest_commit=$(git log -1 --oneline 2>/dev/null || echo "No commit")
    if [ "$latest_commit" != "No commit" ]; then
        echo "- **Committed**: $latest_commit" >> "$SESSION_LOG"
    fi
    echo "" >> "$SESSION_LOG"
}

# Function to update current status
update_status() {
    echo -e "${BLUE}📈 UPDATING CURRENT STATUS${NC}"
    
    # Look for existing CURRENT STATUS section and update it
    if grep -q "### CURRENT STATUS" "$SESSION_LOG"; then
        # Create temp file with updated status
        awk '
        /^### CURRENT STATUS$/ { 
            print "### CURRENT STATUS"
            print ""
            print "#### Session Status:"
            print "- Last updated: '"$TIMESTAMP"'"
            print "- Workspace size: " system("du -sh . | awk '\''{print $1}'\''")
            print "- Running containers: " system("docker ps -q | wc -l")
            print "- Git status: " system("git status --porcelain | wc -l") " files modified"
            print ""
            
            # Skip until next major section
            while(getline && !/^### [A-Z]/) continue
            if(/^### [A-Z]/) print
        }
        !/^### CURRENT STATUS$/ { print }
        ' "$SESSION_LOG" > "${SESSION_LOG}.tmp" && mv "${SESSION_LOG}.tmp" "$SESSION_LOG"
    else
        echo "### CURRENT STATUS" >> "$SESSION_LOG"
        echo "" >> "$SESSION_LOG"
        echo "#### Session Status:" >> "$SESSION_LOG"
        echo "- Last updated: $TIMESTAMP" >> "$SESSION_LOG"
        echo "- Workspace size: $(du -sh . | awk '{print $1}')" >> "$SESSION_LOG"
        echo "- Running containers: $(docker ps -q | wc -l)" >> "$SESSION_LOG"
        echo "- Git status: $(git status --porcelain | wc -l) files modified" >> "$SESSION_LOG"
        echo "" >> "$SESSION_LOG"
    fi
}

# Function to show current session context
show_context() {
    echo -e "${GREEN}📖 CURRENT SESSION CONTEXT${NC}"
    
    if [ -f "$SESSION_LOG" ]; then
        echo "Last session information:"
        tail -20 "$SESSION_LOG"
    else
        echo "No previous session log found"
    fi
}

# Main logic
case "$1" in
    "start")
        log_session_start "$2"
        echo -e "${GREEN}✅ Session started and logged${NC}"
        ;;
    "milestone")
        log_milestone "$2" "$3" "$4" "$5"
        echo -e "${GREEN}✅ Milestone logged${NC}"
        ;;
    "status")
        update_status
        echo -e "${GREEN}✅ Status updated${NC}"
        ;;
    "context"|"show")
        show_context
        ;;
    *)
        echo -e "${CYAN}📋 CHECKPOINT LOGGER USAGE${NC}"
        echo ""
        echo "Usage: ./checkpoint-logger.sh <command> [args...]"
        echo ""
        echo "Commands:"
        echo "  start <description>     - Start new session with description"
        echo "  milestone <name> <action> <result> [verification] - Log milestone"
        echo "  status                  - Update current status"
        echo "  context                 - Show current session context"
        echo ""
        echo "Examples:"
        echo "  ./checkpoint-logger.sh start \"Educational Platform Testing\""
        echo "  ./checkpoint-logger.sh milestone \"Security Testing\" \"Applied Trivy scan\" \"0 vulnerabilities found\" \"All tests passing\""
        echo "  ./checkpoint-logger.sh status"
        echo "  ./checkpoint-logger.sh context"
        ;;
esac