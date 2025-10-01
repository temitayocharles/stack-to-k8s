#!/bin/bash
# 🎓 COMPREHENSIVE KUBERNETES LEARNING DASHBOARD
# Interactive learning progress tracking with visual feedback

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
readonly PROGRESS_FILE="$WORKSPACE_ROOT/.learning-progress.json"
readonly SESSION_LOG="$WORKSPACE_ROOT/.session-history.log"

# Learning metrics
declare -A USER_STATS=(
    ["total_hours"]=0
    ["sessions_completed"]=0
    ["applications_mastered"]=0
    ["difficulty_level"]="beginner"
    ["achievements_unlocked"]=0
    ["current_streak"]=0
    ["longest_streak"]=0
    ["skills_acquired"]=0
)

# Difficulty levels with detailed progression
declare -A DIFFICULTY_LEVELS=(
    ["beginner"]="🟢 BEGINNER - Maximum guidance and support"
    ["intermediate"]="🟡 INTERMEDIATE - Guided with references"
    ["advanced"]="🔴 ADVANCED - Minimal guidance, self-directed"
    ["expert"]="🟣 EXPERT - Innovation and optimization focus"
)

# Application completion tracking
declare -A APPLICATION_STATUS=(
    ["ecommerce-app"]="completed"
    ["educational-platform"]="in_progress"
    ["medical-care-system"]="pending"
    ["task-management-app"]="pending"
    ["weather-app"]="pending"
    ["social-media-platform"]="pending"
)

# Skills taxonomy
declare -A SKILLS_CATALOG=(
    ["docker_basics"]="Docker Containerization Fundamentals"
    ["kubernetes_basics"]="Kubernetes Core Concepts"
    ["yaml_manifests"]="YAML Manifest Creation"
    ["helm_charts"]="Helm Chart Development"
    ["kustomize"]="Kustomize Configuration Management"
    ["monitoring"]="Prometheus & Grafana Monitoring"
    ["security"]="Kubernetes Security Implementation"
    ["networking"]="Kubernetes Networking & Policies"
    ["storage"]="Persistent Storage Management"
    ["ci_cd"]="CI/CD Pipeline Implementation"
    ["troubleshooting"]="Kubernetes Troubleshooting"
    ["performance"]="Performance Optimization"
)

# Achievement system
declare -A ACHIEVEMENTS=(
    ["first_deployment"]="🚀 First Successful Deployment"
    ["container_master"]="🐳 Container Virtualization Master"
    ["yaml_ninja"]="📋 YAML Configuration Ninja"
    ["monitoring_guru"]="📊 Monitoring Implementation Guru"
    ["security_expert"]="🛡️ Security Hardening Expert"
    ["troubleshoot_hero"]="🔧 Troubleshooting Hero"
    ["automation_master"]="⚙️ CI/CD Automation Master"
    ["performance_optimizer"]="⚡ Performance Optimization Wizard"
    ["networking_specialist"]="🌐 Networking Architecture Specialist"
    ["seven_day_streak"]="🔥 Seven Day Learning Streak"
    ["all_apps_completed"]="🏆 All Applications Mastered"
)

show_banner() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}🎓 KUBERNETES LEARNING DASHBOARD${NC}"
    echo -e "${CYAN}║${NC} ${BLUE}Your comprehensive learning progress and achievements${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

load_progress() {
    if [[ -f "$PROGRESS_FILE" ]]; then
        # Load existing progress
        while IFS='=' read -r key value; do
            if [[ -n "$key" && -n "$value" ]]; then
                USER_STATS["$key"]="$value"
            fi
        done < <(jq -r 'to_entries | .[] | "\(.key)=\(.value)"' "$PROGRESS_FILE" 2>/dev/null || echo "")
    fi
}

save_progress() {
    local json_data="{"
    local first=true
    
    for key in "${!USER_STATS[@]}"; do
        if [[ "$first" == true ]]; then
            first=false
        else
            json_data+=","
        fi
        json_data+="\"$key\":\"${USER_STATS[$key]}\""
    done
    json_data+="}"
    
    echo "$json_data" | jq '.' > "$PROGRESS_FILE" 2>/dev/null || echo "$json_data" > "$PROGRESS_FILE"
}

log_session() {
    local action="$1"
    local details="${2:-}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $action | $details" >> "$SESSION_LOG"
}

show_current_level() {
    local current_level="${USER_STATS[difficulty_level]}"
    echo -e "${BLUE}📊 Current Learning Level${NC}"
    echo "==============================================================================="
    echo ""
    echo -e "   ${DIFFICULTY_LEVELS[$current_level]}"
    echo ""
    
    case "$current_level" in
        "beginner")
            echo -e "${GREEN}🎯 Focus Areas:${NC}"
            echo "   • Docker container basics and Dockerfile creation"
            echo "   • Kubernetes pods, deployments, and services"
            echo "   • Basic YAML manifest writing"
            echo "   • Simple kubectl commands and operations"
            echo ""
            echo -e "${BLUE}📚 Learning Approach:${NC}"
            echo "   • Maximum guidance with step-by-step instructions"
            echo "   • Visual aids and screenshots for every step"
            echo "   • Copy-paste ready commands with explanations"
            echo "   • Extensive error handling and recovery guidance"
            ;;
        "intermediate")
            echo -e "${YELLOW}🎯 Focus Areas:${NC}"
            echo "   • Advanced Kubernetes resources and configurations"
            echo "   • Helm chart development and templating"
            echo "   • Basic monitoring and logging setup"
            echo "   • CI/CD pipeline creation"
            echo ""
            echo -e "${BLUE}📚 Learning Approach:${NC}"
            echo "   • Guided learning with reference materials"
            echo "   • Problem-solving with hints and documentation links"
            echo "   • Increased self-discovery and experimentation"
            echo "   • Performance benchmarking and optimization"
            ;;
        "advanced")
            echo -e "${RED}🎯 Focus Areas:${NC}"
            echo "   • Complex multi-application orchestration"
            echo "   • Security hardening and best practices"
            echo "   • Custom resource definitions (CRDs)"
            echo "   • Production-grade monitoring and alerting"
            echo ""
            echo -e "${BLUE}📚 Learning Approach:${NC}"
            echo "   • Minimal guidance, self-directed learning"
            echo "   • Architecture decision making"
            echo "   • Performance optimization and tuning"
            echo "   • Troubleshooting complex issues"
            ;;
        "expert")
            echo -e "${PURPLE}🎯 Focus Areas:${NC}"
            echo "   • Innovation and cutting-edge Kubernetes features"
            echo "   • Custom operators and controllers"
            echo "   • Multi-cluster management and federation"
            echo "   • Performance engineering and optimization"
            echo ""
            echo -e "${BLUE}📚 Learning Approach:${NC}"
            echo "   • Self-sufficient learning and innovation"
            echo "   • Contributing to open-source projects"
            echo "   • Mentoring and knowledge sharing"
            echo "   • Research and development activities"
            ;;
    esac
}

show_application_progress() {
    echo -e "${BLUE}🚀 Application Mastery Progress${NC}"
    echo "==============================================================================="
    echo ""
    
    local completed=0
    local total=0
    
    for app in "${!APPLICATION_STATUS[@]}"; do
        local status="${APPLICATION_STATUS[$app]}"
        ((total++))
        
        case "$status" in
            "completed")
                echo -e "   ✅ ${GREEN}$app${NC} - Fully mastered"
                ((completed++))
                ;;
            "in_progress")
                echo -e "   🔄 ${YELLOW}$app${NC} - Currently learning"
                ;;
            "pending")
                echo -e "   ⏳ ${CYAN}$app${NC} - Not started"
                ;;
        esac
    done
    
    echo ""
    local progress_percentage=$((completed * 100 / total))
    echo -e "${BLUE}📈 Overall Progress: ${progress_percentage}% (${completed}/${total} applications)${NC}"
    
    if [[ $completed -eq $total ]]; then
        echo -e "${GREEN}🏆 CONGRATULATIONS! All applications mastered!${NC}"
    fi
}

show_skills_matrix() {
    echo -e "${BLUE}🧠 Skills Acquisition Matrix${NC}"
    echo "==============================================================================="
    echo ""
    
    # Skill categories with progress indicators
    local skill_categories=(
        "Core Kubernetes:kubernetes_basics,yaml_manifests,troubleshooting"
        "Containerization:docker_basics,performance"
        "Configuration Management:helm_charts,kustomize"
        "Observability:monitoring"
        "Security:security,networking"
        "Automation:ci_cd"
        "Storage:storage"
    )
    
    for category_data in "${skill_categories[@]}"; do
        IFS=':' read -r category skills <<< "$category_data"
        echo -e "${CYAN}📂 $category${NC}"
        
        IFS=',' read -ra SKILL_LIST <<< "$skills"
        for skill in "${SKILL_LIST[@]}"; do
            if [[ -n "${SKILLS_CATALOG[$skill]:-}" ]]; then
                # Simulate skill completion based on user progress
                local skill_level=$(get_skill_level "$skill")
                case "$skill_level" in
                    "mastered")
                        echo -e "     ✅ ${SKILLS_CATALOG[$skill]}"
                        ;;
                    "learning")
                        echo -e "     🔄 ${SKILLS_CATALOG[$skill]}"
                        ;;
                    *)
                        echo -e "     ⏳ ${SKILLS_CATALOG[$skill]}"
                        ;;
                esac
            fi
        done
        echo ""
    done
}

get_skill_level() {
    local skill="$1"
    local apps_completed="${USER_STATS[applications_mastered]:-0}"
    local difficulty="${USER_STATS[difficulty_level]:-beginner}"
    
    # Logic to determine skill level based on progress
    case "$skill" in
        "docker_basics"|"kubernetes_basics")
            [[ $apps_completed -ge 1 ]] && echo "mastered" || echo "learning"
            ;;
        "yaml_manifests"|"monitoring")
            [[ $apps_completed -ge 2 ]] && echo "mastered" || echo "learning"
            ;;
        "helm_charts"|"security")
            [[ $apps_completed -ge 3 && "$difficulty" != "beginner" ]] && echo "mastered" || echo "learning"
            ;;
        "kustomize"|"ci_cd")
            [[ $apps_completed -ge 4 && "$difficulty" == "advanced" || "$difficulty" == "expert" ]] && echo "mastered" || echo "learning"
            ;;
        *)
            echo "pending"
            ;;
    esac
}

show_achievements() {
    echo -e "${BLUE}🏆 Achievements Unlocked${NC}"
    echo "==============================================================================="
    echo ""
    
    local unlocked_count=0
    
    # Check which achievements are unlocked
    for achievement_key in "${!ACHIEVEMENTS[@]}"; do
        if check_achievement_unlocked "$achievement_key"; then
            echo -e "   ${GREEN}${ACHIEVEMENTS[$achievement_key]}${NC}"
            ((unlocked_count++))
        else
            echo -e "   ${CYAN}🔒 ${ACHIEVEMENTS[$achievement_key]}${NC}"
        fi
    done
    
    echo ""
    echo -e "${BLUE}📊 Achievement Progress: ${unlocked_count}/${#ACHIEVEMENTS[@]} unlocked${NC}"
    
    # Show next achievement target
    show_next_achievement_target
}

check_achievement_unlocked() {
    local achievement="$1"
    local apps_completed="${USER_STATS[applications_mastered]:-0}"
    local streak="${USER_STATS[current_streak]:-0}"
    local total_hours="${USER_STATS[total_hours]:-0}"
    
    case "$achievement" in
        "first_deployment")
            [[ $apps_completed -ge 1 ]]
            ;;
        "container_master")
            [[ $apps_completed -ge 2 ]]
            ;;
        "yaml_ninja")
            [[ $apps_completed -ge 3 ]]
            ;;
        "monitoring_guru")
            [[ $apps_completed -ge 2 ]]
            ;;
        "security_expert")
            [[ $apps_completed -ge 4 ]]
            ;;
        "seven_day_streak")
            [[ $streak -ge 7 ]]
            ;;
        "all_apps_completed")
            [[ $apps_completed -ge 6 ]]
            ;;
        *)
            false
            ;;
    esac
}

show_next_achievement_target() {
    echo -e "${YELLOW}🎯 Next Achievement Target:${NC}"
    
    local apps_completed="${USER_STATS[applications_mastered]:-0}"
    local streak="${USER_STATS[current_streak]:-0}"
    
    if [[ $apps_completed -eq 0 ]]; then
        echo "   Complete your first application to unlock '🚀 First Successful Deployment'"
    elif [[ $apps_completed -eq 1 ]]; then
        echo "   Master one more application to unlock '🐳 Container Virtualization Master'"
    elif [[ $streak -lt 7 ]]; then
        echo "   Learn for $((7 - streak)) more consecutive days to unlock '🔥 Seven Day Learning Streak'"
    elif [[ $apps_completed -lt 6 ]]; then
        echo "   Complete $((6 - apps_completed)) more applications to unlock '🏆 All Applications Mastered'"
    else
        echo "   🎉 All achievements unlocked! You're a Kubernetes master!"
    fi
}

show_learning_analytics() {
    echo -e "${BLUE}📊 Learning Analytics${NC}"
    echo "==============================================================================="
    echo ""
    
    local total_hours="${USER_STATS[total_hours]:-0}"
    local sessions="${USER_STATS[sessions_completed]:-0}"
    local streak="${USER_STATS[current_streak]:-0}"
    local longest_streak="${USER_STATS[longest_streak]:-0}"
    
    echo -e "${CYAN}⏱️  Time Investment${NC}"
    echo "   📈 Total Learning Hours: $total_hours hours"
    echo "   📅 Sessions Completed: $sessions sessions"
    
    if [[ $sessions -gt 0 ]]; then
        local avg_session=$((total_hours * 60 / sessions))
        echo "   ⏱️  Average Session Length: $avg_session minutes"
    fi
    
    echo ""
    echo -e "${CYAN}🔥 Learning Consistency${NC}"
    echo "   📊 Current Streak: $streak days"
    echo "   🏅 Longest Streak: $longest_streak days"
    
    if [[ $streak -gt 0 ]]; then
        echo -e "   ${GREEN}💪 Keep up the great work! Consistency is key to mastery.${NC}"
    else
        echo -e "   ${YELLOW}💡 Start a learning streak today! Even 30 minutes counts.${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}🎯 Learning Efficiency${NC}"
    
    local apps_completed="${USER_STATS[applications_mastered]:-0}"
    if [[ $total_hours -gt 0 && $apps_completed -gt 0 ]]; then
        local hours_per_app=$((total_hours / apps_completed))
        echo "   📈 Average Time per Application: $hours_per_app hours"
        
        if [[ $hours_per_app -lt 10 ]]; then
            echo -e "   ${GREEN}⚡ Excellent! You're learning efficiently.${NC}"
        elif [[ $hours_per_app -lt 20 ]]; then
            echo -e "   ${YELLOW}👍 Good pace! Keep building on your knowledge.${NC}"
        else
            echo -e "   ${BLUE}🎓 Thorough learning approach. Quality over speed!${NC}"
        fi
    fi
}

show_recommended_next_steps() {
    echo -e "${BLUE}🎯 Recommended Next Steps${NC}"
    echo "==============================================================================="
    echo ""
    
    local current_level="${USER_STATS[difficulty_level]:-beginner}"
    local apps_completed="${USER_STATS[applications_mastered]:-0}"
    
    case "$current_level" in
        "beginner")
            if [[ $apps_completed -eq 0 ]]; then
                echo -e "${GREEN}🚀 Start Here:${NC}"
                echo "   1. Complete the E-commerce Application (already in progress)"
                echo "   2. Focus on basic Docker commands and Dockerfile understanding"
                echo "   3. Learn kubectl basics for pod and service management"
                echo "   4. Practice YAML syntax and Kubernetes manifest creation"
            else
                echo -e "${YELLOW}🎓 Level Up:${NC}"
                echo "   1. Move to Educational Platform application"
                echo "   2. Start learning Helm chart basics"
                echo "   3. Implement basic monitoring with Prometheus"
                echo "   4. Consider upgrading to Intermediate level"
            fi
            ;;
        "intermediate")
            echo -e "${YELLOW}🔥 Accelerate Learning:${NC}"
            echo "   1. Master Helm chart templating and packaging"
            echo "   2. Implement comprehensive monitoring and alerting"
            echo "   3. Learn Kustomize for configuration management"
            echo "   4. Build your first CI/CD pipeline"
            echo "   5. Complete 2-3 more applications"
            ;;
        "advanced")
            echo -e "${RED}⚡ Expert Path:${NC}"
            echo "   1. Focus on security hardening and RBAC"
            echo "   2. Implement custom monitoring solutions"
            echo "   3. Master network policies and service mesh"
            echo "   4. Complete all remaining applications"
            echo "   5. Consider contributing to open source"
            ;;
        "expert")
            echo -e "${PURPLE}🌟 Innovation Mode:${NC}"
            echo "   1. Develop custom Kubernetes operators"
            echo "   2. Implement advanced GitOps workflows"
            echo "   3. Optimize for performance and cost"
            echo "   4. Mentor other learners"
            echo "   5. Contribute to Kubernetes ecosystem"
            ;;
    esac
    
    echo ""
    echo -e "${CYAN}📚 Learning Resources:${NC}"
    echo "   • Use the progressive secrets management system"
    echo "   • Deploy monitoring stack for hands-on experience"
    echo "   • Practice with different deployment scenarios"
    echo "   • Join the Kubernetes community for support"
}

update_progress() {
    echo -e "${BLUE}📝 Update Your Learning Progress${NC}"
    echo "==============================================================================="
    echo ""
    
    echo "What would you like to update?"
    echo "1. 🎯 Difficulty Level"
    echo "2. 📚 Learning Session (add hours)"
    echo "3. 🚀 Application Completion"
    echo "4. 🏆 Manual Achievement Unlock"
    echo "5. 🔄 Reset Progress"
    echo ""
    echo -n "Choose an option (1-5): "
    read -r choice
    
    case "$choice" in
        1)
            update_difficulty_level
            ;;
        2)
            update_learning_session
            ;;
        3)
            update_application_status
            ;;
        4)
            manual_achievement_unlock
            ;;
        5)
            reset_progress
            ;;
        *)
            echo "Invalid choice. Returning to main menu."
            ;;
    esac
}

update_difficulty_level() {
    echo ""
    echo "Current level: ${USER_STATS[difficulty_level]}"
    echo ""
    echo "Available levels:"
    echo "1. 🟢 Beginner"
    echo "2. 🟡 Intermediate"  
    echo "3. 🔴 Advanced"
    echo "4. 🟣 Expert"
    echo ""
    echo -n "Choose new level (1-4): "
    read -r level_choice
    
    case "$level_choice" in
        1) USER_STATS[difficulty_level]="beginner" ;;
        2) USER_STATS[difficulty_level]="intermediate" ;;
        3) USER_STATS[difficulty_level]="advanced" ;;
        4) USER_STATS[difficulty_level]="expert" ;;
        *) echo "Invalid choice."; return ;;
    esac
    
    save_progress
    log_session "LEVEL_UPDATE" "Changed to ${USER_STATS[difficulty_level]}"
    echo -e "${GREEN}✅ Difficulty level updated to ${USER_STATS[difficulty_level]}!${NC}"
}

update_learning_session() {
    echo ""
    echo -n "How many hours did you study today? "
    read -r hours
    
    if [[ "$hours" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        USER_STATS[total_hours]=$((${USER_STATS[total_hours]:-0} + hours))
        USER_STATS[sessions_completed]=$((${USER_STATS[sessions_completed]:-0} + 1))
        USER_STATS[current_streak]=$((${USER_STATS[current_streak]:-0} + 1))
        
        if [[ ${USER_STATS[current_streak]} -gt ${USER_STATS[longest_streak]} ]]; then
            USER_STATS[longest_streak]=${USER_STATS[current_streak]}
        fi
        
        save_progress
        log_session "STUDY_SESSION" "$hours hours completed"
        echo -e "${GREEN}✅ Study session logged! Total: ${USER_STATS[total_hours]} hours${NC}"
    else
        echo "Invalid input. Please enter a number."
    fi
}

update_application_status() {
    echo ""
    echo "Which application did you complete?"
    local i=1
    local apps=()
    
    for app in "${!APPLICATION_STATUS[@]}"; do
        echo "$i. $app (${APPLICATION_STATUS[$app]})"
        apps+=("$app")
        ((i++))
    done
    
    echo ""
    echo -n "Choose application (1-${#apps[@]}): "
    read -r app_choice
    
    if [[ "$app_choice" -ge 1 && "$app_choice" -le ${#apps[@]} ]]; then
        local selected_app="${apps[$((app_choice-1))]}"
        APPLICATION_STATUS["$selected_app"]="completed"
        USER_STATS[applications_mastered]=$((${USER_STATS[applications_mastered]:-0} + 1))
        
        save_progress
        log_session "APP_COMPLETED" "$selected_app mastered"
        echo -e "${GREEN}🎉 Congratulations! $selected_app marked as completed!${NC}"
    else
        echo "Invalid choice."
    fi
}

manual_achievement_unlock() {
    echo ""
    echo "Available achievements:"
    local i=1
    local achievement_keys=()
    
    for key in "${!ACHIEVEMENTS[@]}"; do
        echo "$i. ${ACHIEVEMENTS[$key]}"
        achievement_keys+=("$key")
        ((i++))
    done
    
    echo ""
    echo -n "Choose achievement to unlock (1-${#achievement_keys[@]}): "
    read -r achievement_choice
    
    if [[ "$achievement_choice" -ge 1 && "$achievement_choice" -le ${#achievement_keys[@]} ]]; then
        local selected_key="${achievement_keys[$((achievement_choice-1))]}"
        USER_STATS[achievements_unlocked]=$((${USER_STATS[achievements_unlocked]:-0} + 1))
        
        save_progress
        log_session "ACHIEVEMENT_UNLOCKED" "${ACHIEVEMENTS[$selected_key]}"
        echo -e "${GREEN}🏆 Achievement unlocked: ${ACHIEVEMENTS[$selected_key]}!${NC}"
    else
        echo "Invalid choice."
    fi
}

reset_progress() {
    echo ""
    echo -e "${RED}⚠️  WARNING: This will reset ALL progress data!${NC}"
    echo -n "Are you absolutely sure? Type 'RESET' to confirm: "
    read -r confirmation
    
    if [[ "$confirmation" == "RESET" ]]; then
        # Reset all stats
        for key in "${!USER_STATS[@]}"; do
            case "$key" in
                "difficulty_level") USER_STATS["$key"]="beginner" ;;
                *) USER_STATS["$key"]=0 ;;
            esac
        done
        
        # Reset application status
        for app in "${!APPLICATION_STATUS[@]}"; do
            APPLICATION_STATUS["$app"]="pending"
        done
        
        save_progress
        log_session "PROGRESS_RESET" "All progress data reset"
        echo -e "${GREEN}✅ Progress reset successfully!${NC}"
    else
        echo "Reset cancelled."
    fi
}

export_progress_report() {
    local report_file="$WORKSPACE_ROOT/learning-progress-report.md"
    
    cat > "$report_file" << EOF
# 🎓 Kubernetes Learning Progress Report

**Generated:** $(date)
**Current Level:** ${USER_STATS[difficulty_level]}
**Total Learning Hours:** ${USER_STATS[total_hours]}

## Application Mastery Progress

EOF

    for app in "${!APPLICATION_STATUS[@]}"; do
        echo "- **$app**: ${APPLICATION_STATUS[$app]}" >> "$report_file"
    done
    
    cat >> "$report_file" << EOF

## Learning Statistics

- **Sessions Completed:** ${USER_STATS[sessions_completed]}
- **Current Streak:** ${USER_STATS[current_streak]} days
- **Longest Streak:** ${USER_STATS[longest_streak]} days
- **Applications Mastered:** ${USER_STATS[applications_mastered]}
- **Achievements Unlocked:** ${USER_STATS[achievements_unlocked]}

## Recent Activity

EOF
    
    if [[ -f "$SESSION_LOG" ]]; then
        echo "```" >> "$report_file"
        tail -10 "$SESSION_LOG" >> "$report_file"
        echo "```" >> "$report_file"
    fi
    
    echo -e "${GREEN}📄 Progress report exported to: $report_file${NC}"
}

show_main_menu() {
    echo -e "${CYAN}🎓 LEARNING DASHBOARD MENU${NC}"
    echo "==============================================================================="
    echo ""
    echo "1. 📊 View Current Level & Focus Areas"
    echo "2. 🚀 Application Progress Overview"
    echo "3. 🧠 Skills Matrix & Acquisition"
    echo "4. 🏆 Achievements & Unlocks"
    echo "5. 📈 Learning Analytics & Insights"
    echo "6. 🎯 Recommended Next Steps"
    echo "7. 📝 Update Progress"
    echo "8. 📄 Export Progress Report"
    echo "9. 🔄 Refresh Dashboard"
    echo "0. 🚪 Exit"
    echo ""
    echo -n "Choose an option (0-9): "
}

main() {
    # Initialize
    load_progress
    log_session "DASHBOARD_OPENED" "Learning dashboard accessed"
    
    while true; do
        show_banner
        show_main_menu
        read -r choice
        
        case "$choice" in
            1)
                clear
                show_banner
                show_current_level
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            2)
                clear
                show_banner
                show_application_progress
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            3)
                clear
                show_banner
                show_skills_matrix
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            4)
                clear
                show_banner
                show_achievements
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            5)
                clear
                show_banner
                show_learning_analytics
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            6)
                clear
                show_banner
                show_recommended_next_steps
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            7)
                clear
                show_banner
                update_progress
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            8)
                export_progress_report
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            9)
                # Refresh by reloading progress
                load_progress
                log_session "DASHBOARD_REFRESHED" "Data reloaded"
                ;;
            0)
                log_session "DASHBOARD_CLOSED" "Session ended"
                echo -e "${GREEN}Happy learning! Keep up the great work! 🚀${NC}"
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