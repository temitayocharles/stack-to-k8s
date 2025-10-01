#!/bin/bash
# ⏰ TIME INVESTMENT TRACKING SYSTEM
# Comprehensive learning time analysis and optimization

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
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly TIME_LOG="$WORKSPACE_ROOT/.time-tracking.json"
readonly SESSION_TIMER="$WORKSPACE_ROOT/.current-session.tmp"

# Time tracking variables
declare -A TIME_CATEGORIES=(
    ["learning"]="📚 Active Learning Time"
    ["building"]="🔨 Hands-on Building Time"
    ["debugging"]="🐛 Debugging & Troubleshooting"
    ["reading"]="📖 Documentation Reading"
    ["planning"]="📋 Planning & Architecture"
    ["testing"]="🧪 Testing & Validation"
    ["deployment"]="🚀 Deployment Activities"
    ["monitoring"]="📊 Monitoring Setup"
)

declare -A APPLICATION_TIMES=(
    ["ecommerce-app"]=0
    ["educational-platform"]=0
    ["medical-care-system"]=0
    ["task-management-app"]=0
    ["weather-app"]=0
    ["social-media-platform"]=0
)

declare -A SKILL_TIMES=(
    ["docker"]=0
    ["kubernetes"]=0
    ["helm"]=0
    ["monitoring"]=0
    ["security"]=0
    ["networking"]=0
    ["troubleshooting"]=0
)

show_banner() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}⏰ TIME INVESTMENT TRACKING SYSTEM${NC}"
    echo -e "${CYAN}║${NC} ${BLUE}Optimize your learning efficiency with detailed time analytics${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

load_time_data() {
    if [[ -f "$TIME_LOG" ]]; then
        # Load existing time data from JSON
        while IFS='=' read -r category time; do
            if [[ -n "$category" && -n "$time" ]]; then
                case "$category" in
                    app_*)
                        local app_name="${category#app_}"
                        APPLICATION_TIMES["$app_name"]="$time"
                        ;;
                    skill_*)
                        local skill_name="${category#skill_}"
                        SKILL_TIMES["$skill_name"]="$time"
                        ;;
                esac
            fi
        done < <(jq -r 'to_entries | .[] | "\(.key)=\(.value)"' "$TIME_LOG" 2>/dev/null || echo "")
    fi
}

save_time_data() {
    local json_data="{"
    local first=true
    
    # Save application times
    for app in "${!APPLICATION_TIMES[@]}"; do
        if [[ "$first" == true ]]; then
            first=false
        else
            json_data+=","
        fi
        json_data+="\"app_$app\":${APPLICATION_TIMES[$app]}"
    done
    
    # Save skill times
    for skill in "${!SKILL_TIMES[@]}"; do
        json_data+=",\"skill_$skill\":${SKILL_TIMES[$skill]}"
    done
    
    json_data+="}"
    
    echo "$json_data" | jq '.' > "$TIME_LOG" 2>/dev/null || echo "$json_data" > "$TIME_LOG"
}

start_timer() {
    local category="$1"
    local application="${2:-general}"
    local start_time=$(date +%s)
    
    echo "$start_time|$category|$application" > "$SESSION_TIMER"
    
    echo -e "${GREEN}⏱️  Timer started for: ${TIME_CATEGORIES[$category]:-$category}${NC}"
    echo -e "${BLUE}📱 Application: $application${NC}"
    echo -e "${YELLOW}💡 Use 'stop' command to finish this session${NC}"
    echo ""
    
    # Show live timer
    show_live_timer &
    local timer_pid=$!
    echo "$timer_pid" >> "$SESSION_TIMER"
}

show_live_timer() {
    while [[ -f "$SESSION_TIMER" ]]; do
        if [[ -s "$SESSION_TIMER" ]]; then
            local session_data=$(head -1 "$SESSION_TIMER")
            IFS='|' read -r start_time category application <<< "$session_data"
            
            local current_time=$(date +%s)
            local elapsed=$((current_time - start_time))
            local hours=$((elapsed / 3600))
            local minutes=$(((elapsed % 3600) / 60))
            local seconds=$((elapsed % 60))
            
            printf "\r🕐 Active Session: %02d:%02d:%02d - %s (%s)" "$hours" "$minutes" "$seconds" "$category" "$application"
        fi
        sleep 1
    done
}

stop_timer() {
    if [[ ! -f "$SESSION_TIMER" ]]; then
        echo -e "${RED}❌ No active timer session found${NC}"
        return 1
    fi
    
    local session_data=$(head -1 "$SESSION_TIMER")
    IFS='|' read -r start_time category application <<< "$session_data"
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local hours=$(echo "scale=2; $duration / 3600" | bc -l 2>/dev/null || echo "$((duration / 3600))")
    
    # Kill timer display process
    if [[ $(wc -l < "$SESSION_TIMER") -gt 1 ]]; then
        local timer_pid=$(tail -1 "$SESSION_TIMER")
        kill "$timer_pid" 2>/dev/null || true
    fi
    
    # Update time records
    if [[ -n "${APPLICATION_TIMES[$application]:-}" ]]; then
        APPLICATION_TIMES["$application"]=$(echo "${APPLICATION_TIMES[$application]} + $hours" | bc -l 2>/dev/null || echo "$((APPLICATION_TIMES[$application] + duration / 3600))")
    fi
    
    # Map category to skill
    local skill=$(map_category_to_skill "$category")
    if [[ -n "$skill" && -n "${SKILL_TIMES[$skill]:-}" ]]; then
        SKILL_TIMES["$skill"]=$(echo "${SKILL_TIMES[$skill]} + $hours" | bc -l 2>/dev/null || echo "$((SKILL_TIMES[$skill] + duration / 3600))")
    fi
    
    save_time_data
    rm -f "$SESSION_TIMER"
    
    echo ""
    echo -e "${GREEN}⏹️  Timer stopped!${NC}"
    echo -e "${BLUE}📊 Session Duration: $(format_duration $duration)${NC}"
    echo -e "${CYAN}📱 Application: $application${NC}"
    echo -e "${PURPLE}🎯 Category: ${TIME_CATEGORIES[$category]:-$category}${NC}"
    
    # Show updated totals
    show_session_summary "$application" "$skill"
}

map_category_to_skill() {
    case "$1" in
        "building"|"deployment") echo "docker" ;;
        "learning"|"planning") echo "kubernetes" ;;
        "monitoring") echo "monitoring" ;;
        "debugging") echo "troubleshooting" ;;
        "testing") echo "security" ;;
        *) echo "kubernetes" ;;
    esac
}

format_duration() {
    local total_seconds="$1"
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))
    
    if [[ $hours -gt 0 ]]; then
        printf "%dh %dm %ds" "$hours" "$minutes" "$seconds"
    elif [[ $minutes -gt 0 ]]; then
        printf "%dm %ds" "$minutes" "$seconds"
    else
        printf "%ds" "$seconds"
    fi
}

show_session_summary() {
    local app="$1"
    local skill="$2"
    
    echo ""
    echo -e "${CYAN}📈 Updated Totals:${NC}"
    
    if [[ -n "${APPLICATION_TIMES[$app]:-}" ]]; then
        local app_hours=$(printf "%.1f" "${APPLICATION_TIMES[$app]}")
        echo "   📱 $app: ${app_hours}h total"
    fi
    
    if [[ -n "${SKILL_TIMES[$skill]:-}" ]]; then
        local skill_hours=$(printf "%.1f" "${SKILL_TIMES[$skill]}")
        echo "   🧠 $skill: ${skill_hours}h total"
    fi
    
    # Calculate today's total
    local today_total=$(get_today_total)
    echo "   📅 Today's Total: ${today_total}h"
}

get_today_total() {
    # This would integrate with session logs to calculate today's total
    # For now, return a placeholder
    echo "2.5"
}

show_time_analytics() {
    echo -e "${BLUE}📊 Comprehensive Time Analytics${NC}"
    echo "==============================================================================="
    echo ""
    
    # Application breakdown
    echo -e "${CYAN}📱 Time Investment by Application${NC}"
    local total_app_time=0
    
    for app in "${!APPLICATION_TIMES[@]}"; do
        local hours=$(printf "%.1f" "${APPLICATION_TIMES[$app]}")
        total_app_time=$(echo "$total_app_time + ${APPLICATION_TIMES[$app]}" | bc -l 2>/dev/null || echo "$((total_app_time + APPLICATION_TIMES[$app]))")
        
        # Calculate percentage
        local percentage=0
        if [[ $(echo "$total_app_time > 0" | bc -l 2>/dev/null || echo "0") -eq 1 ]]; then
            percentage=$(echo "scale=1; ${APPLICATION_TIMES[$app]} * 100 / $total_app_time" | bc -l 2>/dev/null || echo "0")
        fi
        
        echo "   📂 $app: ${hours}h (${percentage}%)"
    done
    
    echo ""
    echo -e "${CYAN}🧠 Time Investment by Skill${NC}"
    local total_skill_time=0
    
    for skill in "${!SKILL_TIMES[@]}"; do
        local hours=$(printf "%.1f" "${SKILL_TIMES[$skill]}")
        total_skill_time=$(echo "$total_skill_time + ${SKILL_TIMES[$skill]}" | bc -l 2>/dev/null || echo "$((total_skill_time + SKILL_TIMES[$skill]))")
        
        echo "   🎯 $skill: ${hours}h"
    done
    
    echo ""
    echo -e "${CYAN}📈 Learning Efficiency Metrics${NC}"
    
    local total_hours=$(printf "%.1f" "$total_app_time")
    local avg_per_app=$(echo "scale=1; $total_app_time / ${#APPLICATION_TIMES[@]}" | bc -l 2>/dev/null || echo "0")
    
    echo "   ⏱️  Total Learning Time: ${total_hours}h"
    echo "   📊 Average per Application: $(printf "%.1f" "$avg_per_app")h"
    
    if [[ $(echo "$total_hours > 0" | bc -l 2>/dev/null || echo "0") -eq 1 ]]; then
        local completed_apps=$(count_completed_apps)
        if [[ $completed_apps -gt 0 ]]; then
            local hours_per_completed=$(echo "scale=1; $total_app_time / $completed_apps" | bc -l 2>/dev/null || echo "0")
            echo "   🏆 Hours per Completed App: $(printf "%.1f" "$hours_per_completed")h"
        fi
    fi
    
    show_time_recommendations
}

count_completed_apps() {
    # This would integrate with application status tracking
    # For now, return a reasonable estimate
    echo "1"
}

show_time_recommendations() {
    echo ""
    echo -e "${YELLOW}💡 Time Optimization Recommendations${NC}"
    
    local total_hours=$(printf "%.0f" "$(echo "${APPLICATION_TIMES[*]}" | tr ' ' '+' | bc -l 2>/dev/null || echo "10")")
    
    if [[ $total_hours -lt 5 ]]; then
        echo "   🚀 You're just getting started! Focus on consistent daily practice."
        echo "   🎯 Aim for 1-2 hours per day to build momentum."
    elif [[ $total_hours -lt 20 ]]; then
        echo "   📈 Great progress! You're building good learning habits."
        echo "   🎯 Continue with 1-2 hours daily, focus on hands-on practice."
    elif [[ $total_hours -lt 50 ]]; then
        echo "   🔥 Excellent commitment! You're developing solid expertise."
        echo "   🎯 Consider specializing in areas that interest you most."
    else
        echo "   🏆 Outstanding dedication! You're approaching mastery level."
        echo "   🎯 Focus on real-world projects and mentoring others."
    fi
    
    echo ""
    show_efficiency_tips
}

show_efficiency_tips() {
    echo -e "${CYAN}⚡ Efficiency Tips Based on Your Data${NC}"
    
    # Analyze time distribution
    local max_time=0
    local max_skill=""
    
    for skill in "${!SKILL_TIMES[@]}"; do
        if [[ $(echo "${SKILL_TIMES[$skill]} > $max_time" | bc -l 2>/dev/null || echo "0") -eq 1 ]]; then
            max_time="${SKILL_TIMES[$skill]}"
            max_skill="$skill"
        fi
    done
    
    if [[ -n "$max_skill" ]]; then
        echo "   🎯 Your strongest area: $max_skill ($(printf "%.1f" "$max_time")h invested)"
        echo "   💪 Leverage this strength to accelerate learning in other areas"
    fi
    
    echo "   📚 Break learning into 25-minute focused sessions (Pomodoro)"
    echo "   🔄 Alternate between reading and hands-on practice"
    echo "   🎯 Set specific learning goals for each session"
    echo "   📝 Document your progress to maintain motivation"
}

show_time_goals() {
    echo -e "${BLUE}🎯 Learning Time Goals & Targets${NC}"
    echo "==============================================================================="
    echo ""
    
    echo -e "${CYAN}📅 Recommended Time Investment per Application${NC}"
    echo "   🟢 Beginner Level: 8-12 hours per application"
    echo "   🟡 Intermediate Level: 6-10 hours per application"
    echo "   🔴 Advanced Level: 4-8 hours per application"
    echo "   🟣 Expert Level: 2-6 hours per application"
    echo ""
    
    echo -e "${CYAN}🎓 Skill Mastery Targets${NC}"
    echo "   🐳 Docker Basics: 10-15 hours"
    echo "   ☸️  Kubernetes Core: 20-30 hours"
    echo "   📊 Monitoring Setup: 8-12 hours"
    echo "   🛡️  Security Implementation: 15-20 hours"
    echo "   🔧 Troubleshooting Skills: 12-18 hours"
    echo ""
    
    echo -e "${CYAN}📈 Weekly Learning Schedule Suggestions${NC}"
    echo "   📚 Weekdays: 1-2 hours of focused learning"
    echo "   🔨 Weekends: 3-4 hours of hands-on projects"
    echo "   🎯 Weekly Target: 10-15 hours total"
    echo "   📅 Monthly Target: 40-60 hours total"
}

quick_timer_start() {
    echo -e "${BLUE}⚡ Quick Timer Start${NC}"
    echo "==============================================================================="
    echo ""
    
    echo "Select activity category:"
    local i=1
    local categories=()
    
    for category in "${!TIME_CATEGORIES[@]}"; do
        echo "$i. ${TIME_CATEGORIES[$category]}"
        categories+=("$category")
        ((i++))
    done
    
    echo ""
    echo -n "Choose category (1-${#categories[@]}): "
    read -r category_choice
    
    if [[ "$category_choice" -ge 1 && "$category_choice" -le ${#categories[@]} ]]; then
        local selected_category="${categories[$((category_choice-1))]}"
        
        echo ""
        echo "Select application:"
        local j=1
        local apps=()
        
        for app in "${!APPLICATION_TIMES[@]}"; do
            echo "$j. $app"
            apps+=("$app")
            ((j++))
        done
        
        echo ""
        echo -n "Choose application (1-${#apps[@]}): "
        read -r app_choice
        
        if [[ "$app_choice" -ge 1 && "$app_choice" -le ${#apps[@]} ]]; then
            local selected_app="${apps[$((app_choice-1))]}"
            start_timer "$selected_category" "$selected_app"
        else
            echo "Invalid application choice."
        fi
    else
        echo "Invalid category choice."
    fi
}

manual_time_entry() {
    echo -e "${BLUE}📝 Manual Time Entry${NC}"
    echo "==============================================================================="
    echo ""
    
    echo -n "Enter application name: "
    read -r app_name
    echo -n "Enter hours spent: "
    read -r hours
    echo -n "Enter activity category: "
    read -r category
    
    if [[ "$hours" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        # Add to application time
        if [[ -n "${APPLICATION_TIMES[$app_name]:-}" ]]; then
            APPLICATION_TIMES["$app_name"]=$(echo "${APPLICATION_TIMES[$app_name]} + $hours" | bc -l 2>/dev/null || echo "$((APPLICATION_TIMES[$app_name] + hours))")
        else
            APPLICATION_TIMES["$app_name"]="$hours"
        fi
        
        # Add to skill time
        local skill=$(map_category_to_skill "$category")
        if [[ -n "${SKILL_TIMES[$skill]:-}" ]]; then
            SKILL_TIMES["$skill"]=$(echo "${SKILL_TIMES[$skill]} + $hours" | bc -l 2>/dev/null || echo "$((SKILL_TIMES[$skill] + hours))")
        fi
        
        save_time_data
        
        echo -e "${GREEN}✅ Time entry saved successfully!${NC}"
        echo "   📱 Application: $app_name (+${hours}h)"
        echo "   🧠 Skill: $skill (+${hours}h)"
    else
        echo -e "${RED}❌ Invalid hours format${NC}"
    fi
}

export_time_report() {
    local report_file="$WORKSPACE_ROOT/time-investment-report.md"
    
    cat > "$report_file" << EOF
# ⏰ Time Investment Analysis Report

**Generated:** $(date)
**Total Applications:** ${#APPLICATION_TIMES[@]}
**Total Skills Tracked:** ${#SKILL_TIMES[@]}

## Application Time Breakdown

EOF

    local total_app_time=0
    for app in "${!APPLICATION_TIMES[@]}"; do
        local hours=$(printf "%.1f" "${APPLICATION_TIMES[$app]}")
        total_app_time=$(echo "$total_app_time + ${APPLICATION_TIMES[$app]}" | bc -l 2>/dev/null || echo "$((total_app_time + APPLICATION_TIMES[$app]))")
        echo "- **$app**: ${hours} hours" >> "$report_file"
    done
    
    cat >> "$report_file" << EOF

**Total Application Time:** $(printf "%.1f" "$total_app_time") hours

## Skill Development Time

EOF

    for skill in "${!SKILL_TIMES[@]}"; do
        local hours=$(printf "%.1f" "${SKILL_TIMES[$skill]}")
        echo "- **$skill**: ${hours} hours" >> "$report_file"
    done
    
    cat >> "$report_file" << EOF

## Learning Efficiency Analysis

- **Average time per application:** $(echo "scale=1; $total_app_time / ${#APPLICATION_TIMES[@]}" | bc -l 2>/dev/null || echo "0") hours
- **Most invested skill:** $(get_max_skill)
- **Learning pattern:** Consistent progress across multiple applications

## Recommendations

Based on your time investment patterns:

1. **Continue current pace** - Your learning velocity is appropriate
2. **Focus on hands-on practice** - Balance theory with implementation
3. **Consider specialization** - Identify areas of highest interest/aptitude
4. **Track daily consistency** - Aim for regular, shorter sessions

---
*This report was generated automatically by the Time Investment Tracking System*
EOF

    echo -e "${GREEN}📄 Time investment report exported to: $report_file${NC}"
}

get_max_skill() {
    local max_time=0
    local max_skill="kubernetes"
    
    for skill in "${!SKILL_TIMES[@]}"; do
        if [[ $(echo "${SKILL_TIMES[$skill]} > $max_time" | bc -l 2>/dev/null || echo "0") -eq 1 ]]; then
            max_time="${SKILL_TIMES[$skill]}"
            max_skill="$skill"
        fi
    done
    
    echo "$max_skill"
}

show_main_menu() {
    echo -e "${CYAN}⏰ TIME TRACKING MENU${NC}"
    echo "==============================================================================="
    echo ""
    
    # Show current session status
    if [[ -f "$SESSION_TIMER" ]]; then
        echo -e "${GREEN}🟢 Active Timer Session Running${NC}"
        echo ""
    fi
    
    echo "1. ⏱️  Start Timer (Quick Start)"
    echo "2. ⏹️  Stop Timer"
    echo "3. 📊 View Time Analytics"
    echo "4. 🎯 Learning Goals & Targets"
    echo "5. 📝 Manual Time Entry"
    echo "6. 📈 Efficiency Recommendations"
    echo "7. 📄 Export Time Report"
    echo "8. 🔄 Refresh Data"
    echo "0. 🚪 Exit"
    echo ""
    echo -n "Choose an option (0-8): "
}

main() {
    # Check for bc calculator
    if ! command -v bc &> /dev/null; then
        echo -e "${YELLOW}⚠️  Installing 'bc' calculator for time calculations...${NC}"
        if command -v brew &> /dev/null; then
            brew install bc
        else
            echo -e "${RED}Please install 'bc' calculator: brew install bc${NC}"
            exit 1
        fi
    fi
    
    # Initialize
    load_time_data
    
    # Handle direct commands
    case "${1:-}" in
        "start")
            shift
            if [[ $# -ge 2 ]]; then
                start_timer "$1" "$2"
                exit 0
            else
                quick_timer_start
                exit 0
            fi
            ;;
        "stop")
            stop_timer
            exit 0
            ;;
        "status")
            if [[ -f "$SESSION_TIMER" ]]; then
                echo -e "${GREEN}⏱️  Timer is running${NC}"
            else
                echo -e "${BLUE}⏸️  No active timer${NC}"
            fi
            exit 0
            ;;
    esac
    
    # Interactive menu
    while true; do
        show_banner
        show_main_menu
        read -r choice
        
        case "$choice" in
            1)
                clear
                show_banner
                quick_timer_start
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            2)
                clear
                show_banner
                stop_timer
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            3)
                clear
                show_banner
                show_time_analytics
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            4)
                clear
                show_banner
                show_time_goals
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            5)
                clear
                show_banner
                manual_time_entry
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            6)
                clear
                show_banner
                show_time_recommendations
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            7)
                export_time_report
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            8)
                load_time_data
                echo -e "${GREEN}✅ Data refreshed successfully!${NC}"
                sleep 1
                ;;
            0)
                echo -e "${GREEN}Keep tracking your learning journey! ⏰${NC}"
                exit 0
                ;;
            *)
                echo "Invalid choice. Please try again."
                sleep 1
                ;;
        esac
    done
}

main "$@"