#!/bin/bash
# 📊 PROGRESS TRACKING SYSTEM
# Comprehensive learning progress monitoring and milestone tracking

set -euo pipefail

# Colors and styling
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Configuration
readonly PROGRESS_FILE=".learning-progress.json"
readonly BACKUP_DIR=".progress-backups"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Initialize progress file if not exists
init_progress_file() {
    if [[ ! -f "$PROGRESS_FILE" ]]; then
        cat > "$PROGRESS_FILE" << 'EOF'
{
  "learner": {
    "name": "",
    "start_date": "",
    "current_level": "beginner",
    "goal": "",
    "estimated_completion": ""
  },
  "applications": {
    "ecommerce-app": {
      "status": "not_started",
      "difficulty": "beginner",
      "progress": 0,
      "milestones": {},
      "time_spent": 0,
      "last_activity": ""
    },
    "educational-platform": {
      "status": "not_started",
      "difficulty": "intermediate",
      "progress": 0,
      "milestones": {},
      "time_spent": 0,
      "last_activity": ""
    },
    "medical-care-system": {
      "status": "not_started",
      "difficulty": "advanced",
      "progress": 0,
      "milestones": {},
      "time_spent": 0,
      "last_activity": ""
    },
    "task-management-app": {
      "status": "not_started",
      "difficulty": "intermediate",
      "progress": 0,
      "milestones": {},
      "time_spent": 0,
      "last_activity": ""
    },
    "weather-app": {
      "status": "not_started",
      "difficulty": "beginner",
      "progress": 0,
      "milestones": {},
      "time_spent": 0,
      "last_activity": ""
    },
    "social-media-platform": {
      "status": "not_started",
      "difficulty": "expert",
      "progress": 0,
      "milestones": {},
      "time_spent": 0,
      "last_activity": ""
    }
  },
  "skills": {
    "docker": {"level": 0, "milestones": []},
    "kubernetes": {"level": 0, "milestones": []},
    "ci_cd": {"level": 0, "milestones": []},
    "monitoring": {"level": 0, "milestones": []},
    "security": {"level": 0, "milestones": []},
    "cloud": {"level": 0, "milestones": []},
    "chaos_engineering": {"level": 0, "milestones": []}
  },
  "achievements": [],
  "total_time_spent": 0,
  "last_updated": ""
}
EOF
    fi
}

# Backup progress file
backup_progress() {
    if [[ -f "$PROGRESS_FILE" ]]; then
        cp "$PROGRESS_FILE" "$BACKUP_DIR/progress-$(date +%Y%m%d_%H%M%S).json"
        
        # Keep only last 10 backups
        ls -t "$BACKUP_DIR"/progress-*.json | tail -n +11 | xargs rm -f 2>/dev/null || true
    fi
}

# Display current progress
show_progress() {
    init_progress_file
    
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}📊 YOUR LEARNING PROGRESS DASHBOARD${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Extract learner info
    local learner_name=$(jq -r '.learner.name // "Not Set"' "$PROGRESS_FILE")
    local start_date=$(jq -r '.learner.start_date // "Not Set"' "$PROGRESS_FILE")
    local current_level=$(jq -r '.learner.current_level // "beginner"' "$PROGRESS_FILE")
    local goal=$(jq -r '.learner.goal // "Not Set"' "$PROGRESS_FILE")
    local total_time=$(jq -r '.total_time_spent // 0' "$PROGRESS_FILE")
    
    echo -e "${PURPLE}👤 Learner Profile${NC}"
    echo "   Name: $learner_name"
    echo "   Started: $start_date"
    echo "   Current Level: $(echo "$current_level" | tr '[:lower:]' '[:upper:]')"
    echo "   Goal: $goal"
    echo "   Total Time: ${total_time} hours"
    echo ""
    
    # Show application progress
    echo -e "${BLUE}🏗️  APPLICATION PROGRESS${NC}"
    echo "────────────────────────────────────────────────────────────────────────────"
    
    for app in ecommerce-app educational-platform medical-care-system task-management-app weather-app social-media-platform; do
        local status=$(jq -r ".applications[\"$app\"].status // \"not_started\"" "$PROGRESS_FILE")
        local progress=$(jq -r ".applications[\"$app\"].progress // 0" "$PROGRESS_FILE")
        local difficulty=$(jq -r ".applications[\"$app\"].difficulty // \"beginner\"" "$PROGRESS_FILE")
        
        # Status emoji
        local status_emoji="⚪"
        case "$status" in
            "completed") status_emoji="✅" ;;
            "in_progress") status_emoji="🔄" ;;
            "started") status_emoji="🟡" ;;
            "not_started") status_emoji="⚪" ;;
        esac
        
        # Difficulty color
        local diff_color="$GREEN"
        case "$difficulty" in
            "intermediate") diff_color="$YELLOW" ;;
            "advanced") diff_color="$BLUE" ;;
            "expert") diff_color="$RED" ;;
        esac
        
        # Progress bar
        local bar_length=20
        local filled=$(( progress * bar_length / 100 ))
        local bar=""
        for ((i=0; i<filled; i++)); do bar+="█"; done
        for ((i=filled; i<bar_length; i++)); do bar+="░"; done
        
        printf "%s %-25s [%s] %3d%% %s%s%s\n" \
            "$status_emoji" \
            "$(echo "$app" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')" \
            "$bar" \
            "$progress" \
            "$diff_color" \
            "$(echo "$difficulty" | tr '[:lower:]' '[:upper:]')" \
            "$NC"
    done
    
    echo ""
    
    # Show skill levels
    echo -e "${BLUE}🎯 SKILL DEVELOPMENT${NC}"
    echo "────────────────────────────────────────────────────────────────────────────"
    
    for skill in docker kubernetes ci_cd monitoring security cloud chaos_engineering; do
        local level=$(jq -r ".skills[\"$skill\"].level // 0" "$PROGRESS_FILE")
        local skill_name=$(echo "$skill" | sed 's/_/ /g' | sed 's/\b\w/\U&/g')
        
        # Skill level representation
        local stars=""
        for ((i=1; i<=5; i++)); do
            if [[ $i -le $level ]]; then
                stars+="⭐"
            else
                stars+="☆"
            fi
        done
        
        printf "%-20s %s (%d/5)\n" "$skill_name" "$stars" "$level"
    done
    
    echo ""
    
    # Show recent achievements
    local achievements_count=$(jq '.achievements | length' "$PROGRESS_FILE")
    if [[ $achievements_count -gt 0 ]]; then
        echo -e "${YELLOW}🏆 RECENT ACHIEVEMENTS${NC}"
        echo "────────────────────────────────────────────────────────────────────────────"
        jq -r '.achievements[-3:] | .[] | "🎉 " + .title + " (" + .date + ")"' "$PROGRESS_FILE" 2>/dev/null || echo "No achievements yet"
        echo ""
    fi
    
    # Show next recommendations
    echo -e "${GREEN}💡 RECOMMENDED NEXT STEPS${NC}"
    echo "────────────────────────────────────────────────────────────────────────────"
    
    local not_started_apps=$(jq -r '.applications | to_entries[] | select(.value.status == "not_started") | .key' "$PROGRESS_FILE" | head -3)
    local in_progress_apps=$(jq -r '.applications | to_entries[] | select(.value.status == "in_progress" or .value.status == "started") | .key' "$PROGRESS_FILE" | head -1)
    
    if [[ -n "$in_progress_apps" ]]; then
        echo "🔄 Continue with: $(echo "$in_progress_apps" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')"
    fi
    
    if [[ -n "$not_started_apps" ]]; then
        echo "🆕 Try next: $(echo "$not_started_apps" | head -1 | sed 's/-/ /g' | sed 's/\b\w/\U&/g')"
    fi
    
    # Calculate overall completion
    local overall_progress=$(jq '[.applications[] | .progress] | add / length' "$PROGRESS_FILE")
    echo ""
    echo -e "${CYAN}📈 Overall Progress: ${overall_progress}%${NC}"
}

# Update progress for an application
update_progress() {
    local app="$1"
    local milestone="$2"
    local progress_value="${3:-}"
    
    init_progress_file
    backup_progress
    
    local current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Update application progress
    if [[ -n "$progress_value" ]]; then
        jq --arg app "$app" --arg milestone "$milestone" --argjson progress "$progress_value" --arg date "$current_date" '
            .applications[$app].milestones[$milestone] = $date |
            .applications[$app].progress = $progress |
            .applications[$app].last_activity = $date |
            .applications[$app].status = (if $progress == 100 then "completed" elif $progress > 0 then "in_progress" else "not_started" end) |
            .last_updated = $date
        ' "$PROGRESS_FILE" > "${PROGRESS_FILE}.tmp" && mv "${PROGRESS_FILE}.tmp" "$PROGRESS_FILE"
    else
        jq --arg app "$app" --arg milestone "$milestone" --arg date "$current_date" '
            .applications[$app].milestones[$milestone] = $date |
            .applications[$app].last_activity = $date |
            .last_updated = $date
        ' "$PROGRESS_FILE" > "${PROGRESS_FILE}.tmp" && mv "${PROGRESS_FILE}.tmp" "$PROGRESS_FILE"
    fi
    
    echo -e "${GREEN}✅ Progress updated: $milestone completed for $app${NC}"
}

# Add achievement
add_achievement() {
    local title="$1"
    local description="${2:-}"
    
    init_progress_file
    backup_progress
    
    local current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    jq --arg title "$title" --arg desc "$description" --arg date "$current_date" '
        .achievements += [{
            "title": $title,
            "description": $desc,
            "date": $date
        }] |
        .last_updated = $date
    ' "$PROGRESS_FILE" > "${PROGRESS_FILE}.tmp" && mv "${PROGRESS_FILE}.tmp" "$PROGRESS_FILE"
    
    echo -e "${YELLOW}🏆 Achievement unlocked: $title${NC}"
}

# Set learner profile
set_profile() {
    init_progress_file
    backup_progress
    
    echo -e "${CYAN}👤 Setting up your learner profile${NC}"
    echo ""
    
    read -p "Your name: " learner_name
    read -p "Your learning goal (e.g., 'Master Kubernetes for production use'): " goal
    
    echo ""
    echo "Select your current experience level:"
    echo "1) Beginner - New to containers and Kubernetes"
    echo "2) Intermediate - Some container experience"
    echo "3) Advanced - Experienced with Kubernetes"
    echo "4) Expert - Production Kubernetes experience"
    echo ""
    read -p "Your choice (1-4): " level_choice
    
    local level="beginner"
    case "$level_choice" in
        2) level="intermediate" ;;
        3) level="advanced" ;;
        4) level="expert" ;;
    esac
    
    local current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    jq --arg name "$learner_name" --arg goal "$goal" --arg level "$level" --arg date "$current_date" '
        .learner.name = $name |
        .learner.goal = $goal |
        .learner.current_level = $level |
        .learner.start_date = $date |
        .last_updated = $date
    ' "$PROGRESS_FILE" > "${PROGRESS_FILE}.tmp" && mv "${PROGRESS_FILE}.tmp" "$PROGRESS_FILE"
    
    echo -e "${GREEN}✅ Profile updated successfully!${NC}"
    echo ""
    add_achievement "Learning Journey Started" "Set up learner profile and goals"
}

# Reset progress
reset_progress() {
    echo -e "${YELLOW}⚠️  Are you sure you want to reset all progress? (y/N)${NC}"
    read -r confirmation
    
    if [[ "$confirmation" =~ ^[Yy]$ ]]; then
        backup_progress
        rm -f "$PROGRESS_FILE"
        init_progress_file
        echo -e "${GREEN}✅ Progress reset successfully${NC}"
    else
        echo "Reset cancelled"
    fi
}

# Show help
show_help() {
    echo -e "${CYAN}📚 Progress Tracker Help${NC}"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  show                 Show current progress dashboard"
    echo "  update <app> <milestone> [progress%]"
    echo "                      Update application progress"
    echo "  achieve <title> [description]"
    echo "                      Add an achievement"
    echo "  profile             Set up learner profile"
    echo "  reset               Reset all progress"
    echo "  help                Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 show"
    echo "  $0 update ecommerce-app 'Docker Setup' 25"
    echo "  $0 achieve 'First Container' 'Successfully ran first Docker container'"
    echo "  $0 profile"
}

# Main function
main() {
    local command="${1:-show}"
    
    case "$command" in
        "show"|"")
            show_progress
            ;;
        "update")
            if [[ $# -lt 3 ]]; then
                echo -e "${RED}❌ Usage: $0 update <app> <milestone> [progress%]${NC}"
                exit 1
            fi
            update_progress "$2" "$3" "${4:-}"
            ;;
        "achieve")
            if [[ $# -lt 2 ]]; then
                echo -e "${RED}❌ Usage: $0 achieve <title> [description]${NC}"
                exit 1
            fi
            add_achievement "$2" "${3:-}"
            ;;
        "profile")
            set_profile
            ;;
        "reset")
            reset_progress
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $command${NC}"
            show_help
            exit 1
            ;;
    esac
}

# Check for jq dependency
if ! command -v jq &> /dev/null; then
    echo -e "${RED}❌ Error: jq is required but not installed${NC}"
    echo "Install with:"
    echo "  macOS: brew install jq"
    echo "  Linux: sudo apt-get install jq"
    exit 1
fi

main "$@"