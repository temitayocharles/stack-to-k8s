package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"sync"
	"time"

	"github.com/google/uuid"
)
// LogEntry - Structured log entry
type LogEntry struct {
	Timestamp   time.Time              `json:"timestamp"`
	Level       LogLevel               `json:"level"`
	Component   string                 `json:"component"`
	Message     string                 `json:"message"`
	Details     map[string]interface{} `json:"details,omitempty"`
	Error       string                 `json:"error,omitempty"`
	TraceID     string                 `json:"trace_id,omitempty"`
	UserID      string                 `json:"user_id,omitempty"`
	RequestID   string                 `json:"request_id,omitempty"`
	IPAddress   string                 `json:"ip_address,omitempty"`
	UserAgent   string                 `json:"user_agent,omitempty"`
}

type LogLevel string

const (
	LogLevelDebug   LogLevel = "DEBUG"
	LogLevelInfo    LogLevel = "INFO"
	LogLevelWarn    LogLevel = "WARN"
	LogLevelError   LogLevel = "ERROR"
	LogLevelFatal   LogLevel = "FATAL"
	LogLevelSecurity LogLevel = "SECURITY"
	LogLevelAudit   LogLevel = "AUDIT"
)

// Color codes for terminal output
const (
	ColorReset     = "\033[0m"
	ColorRed       = "\033[31m"
	ColorGreen     = "\033[32m"
	ColorYellow    = "\033[33m"
	ColorBlue      = "\033[34m"
	ColorMagenta   = "\033[35m"
	ColorCyan      = "\033[36m"
	ColorWhite     = "\033[37m"
	ColorBold      = "\033[1m"
	ColorDim       = "\033[2m"
	ColorUnderline = "\033[4m"
)

// Initialize the enhanced logger
func NewEnhancedLogger(logDir string) (*EnhancedLogger, error) {
	// Create log directory if it doesn't exist
	if err := os.MkdirAll(logDir, 0755); err != nil {
		return nil, fmt.Errorf("failed to create log directory: %v", err)
	}

	logger := &EnhancedLogger{
		logDir:             logDir,
		logBuffer:          &bytes.Buffer{},
		colorEnabled:       true,
		scanResults:        &SecurityScanResults{},
		downloadableReports: make(map[string]*DownloadableReport),
	}

	// Create new log file
	if err := logger.rotateLogFile(); err != nil {
		return nil, fmt.Errorf("failed to create log file: %v", err)
	}

	// Start cleanup routine for expired reports
	go logger.cleanupExpiredReports()

	return logger, nil
}

// Log structured entry
func (el *EnhancedLogger) Log(level LogLevel, component string, message string, details map[string]interface{}) {
	entry := LogEntry{
		Timestamp: time.Now(),
		Level:     level,
		Component: component,
		Message:   message,
		Details:   details,
		TraceID:   el.generateTraceID(),
	}

	el.writeLogEntry(entry)
}

// Log with error
func (el *EnhancedLogger) LogError(component string, err error, message string, details map[string]interface{}) {
	entry := LogEntry{
		Timestamp: time.Now(),
		Level:     LogLevelError,
		Component: component,
		Message:   message,
		Error:     err.Error(),
		Details:   details,
		TraceID:   el.generateTraceID(),
	}

	el.writeLogEntry(entry)
}

// Log security event
func (el *EnhancedLogger) LogSecurity(component string, event string, severity VulnerabilitySeverity, details map[string]interface{}) {
	entry := LogEntry{
		Timestamp: time.Now(),
		Level:     LogLevelSecurity,
		Component: component,
		Message:   event,
		Details:   details,
		TraceID:   el.generateTraceID(),
	}

	// Add severity to details
	if entry.Details == nil {
		entry.Details = make(map[string]interface{})
	}
	entry.Details["severity"] = string(severity)

	el.writeLogEntry(entry)
}

// Log audit event
func (el *EnhancedLogger) LogAudit(component string, action string, userID string, details map[string]interface{}) {
	entry := LogEntry{
		Timestamp: time.Now(),
		Level:     LogLevelAudit,
		Component: component,
		Message:   action,
		UserID:    userID,
		Details:   details,
		TraceID:   el.generateTraceID(),
	}

	el.writeLogEntry(entry)
}

// Write log entry to file and buffer
func (el *EnhancedLogger) writeLogEntry(entry LogEntry) {
	el.mutex.Lock()
	defer el.mutex.Unlock()

	// Format log entry
	formattedEntry := el.formatLogEntry(entry)

	// Write to file
	if el.currentLogFile != nil {
		if _, err := el.currentLogFile.WriteString(formattedEntry + "\n"); err != nil {
			log.Printf("Failed to write to log file: %v", err)
		}
	}

	// Write to buffer for downloadable reports
	el.logBuffer.WriteString(formattedEntry + "\n")

	// Also write to stdout with colors
	el.writeToStdout(entry)
}

// Format log entry for file output
func (el *EnhancedLogger) formatLogEntry(entry LogEntry) string {
	timestamp := entry.Timestamp.Format("2006-01-02 15:04:05.000")

	var builder strings.Builder
	builder.WriteString(fmt.Sprintf("[%s] [%s] [%s] %s", timestamp, entry.Level, entry.Component, entry.Message))

	if entry.TraceID != "" {
		builder.WriteString(fmt.Sprintf(" [trace_id=%s]", entry.TraceID))
	}

	if entry.UserID != "" {
		builder.WriteString(fmt.Sprintf(" [user_id=%s]", entry.UserID))
	}

	if entry.RequestID != "" {
		builder.WriteString(fmt.Sprintf(" [request_id=%s]", entry.RequestID))
	}

	if entry.Error != "" {
		builder.WriteString(fmt.Sprintf(" [error=%s]", entry.Error))
	}

	if len(entry.Details) > 0 {
		detailsJSON, _ := json.Marshal(entry.Details)
		builder.WriteString(fmt.Sprintf(" [details=%s]", string(detailsJSON)))
	}

	return builder.String()
}

// Write to stdout with colors
func (el *EnhancedLogger) writeToStdout(entry LogEntry) {
	if !el.colorEnabled {
		fmt.Println(el.formatLogEntry(entry))
		return
	}

	color := el.getColorForLevel(entry.Level)
	reset := ColorReset

	timestamp := entry.Timestamp.Format("2006-01-02 15:04:05.000")

	fmt.Printf("%s[%s]%s %s[%s]%s %s[%s]%s %s%s%s\n",
		ColorDim, timestamp, reset,
		color, entry.Level, reset,
		ColorCyan, entry.Component, reset,
		color, entry.Message, reset)

	if entry.Error != "" {
		fmt.Printf("  %sError: %s%s\n", ColorRed, entry.Error, reset)
	}

	if len(entry.Details) > 0 {
		detailsJSON, _ := json.MarshalIndent(entry.Details, "  ", "  ")
		fmt.Printf("  %sDetails: %s%s\n", ColorYellow, string(detailsJSON), reset)
	}
}

// Get color for log level
func (el *EnhancedLogger) getColorForLevel(level LogLevel) string {
	switch level {
	case LogLevelDebug:
		return ColorDim
	case LogLevelInfo:
		return ColorGreen
	case LogLevelWarn:
		return ColorYellow
	case LogLevelError:
		return ColorRed
	case LogLevelFatal:
		return ColorBold + ColorRed
	case LogLevelSecurity:
		return ColorBold + ColorMagenta
	case LogLevelAudit:
		return ColorBold + ColorBlue
	default:
		return ColorReset
	}
}

// Generate trace ID
func (el *EnhancedLogger) generateTraceID() string {
	return uuid.New().String()[:8]
}

// Rotate log file
func (el *EnhancedLogger) rotateLogFile() error {
	if el.currentLogFile != nil {
		el.currentLogFile.Close()
	}

	timestamp := time.Now().Format("2006-01-02_15-04-05")
	filename := fmt.Sprintf("task-management_%s.log", timestamp)
	filepath := filepath.Join(el.logDir, filename)

	file, err := os.OpenFile(filepath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
	if err != nil {
		return err
	}

	el.currentLogFile = file
	return nil
}

// Record security scan results
func (el *EnhancedLogger) RecordSecurityScan(scanType string, target string, rawOutput string, vulnerabilities []Vulnerability) {
	el.mutex.Lock()
	defer el.mutex.Unlock()

	el.scanResults = &SecurityScanResults{
		ScanID:         uuid.New().String(),
		Timestamp:      time.Now(),
		ScanType:       scanType,
		Target:         target,
		Vulnerabilities: vulnerabilities,
		RawOutput:      rawOutput,
		Status:         "completed",
	}

	// Calculate summary
	el.scanResults.Summary = el.calculateScanSummary(vulnerabilities)

	// Log the scan results
	el.logSecurityScanResults()

	// Create downloadable report
	el.createSecurityScanReport()
}

// Calculate scan summary
func (el *EnhancedLogger) calculateScanSummary(vulnerabilities []Vulnerability) SecurityScanSummary {
	summary := SecurityScanSummary{
		TotalVulnerabilities: len(vulnerabilities),
		Recommendations:      []string{},
	}

	for _, vuln := range vulnerabilities {
		switch vuln.Severity {
		case SeverityCritical:
			summary.CriticalCount++
		case SeverityHigh:
			summary.HighCount++
		case SeverityMedium:
			summary.MediumCount++
		case SeverityLow:
			summary.LowCount++
		case SeverityInfo:
			summary.InfoCount++
		}
	}

	// Generate recommendations
	if summary.CriticalCount > 0 {
		summary.Recommendations = append(summary.Recommendations,
			"CRITICAL: Immediate attention required for critical vulnerabilities")
	}
	if summary.HighCount > 0 {
		summary.Recommendations = append(summary.Recommendations,
			"HIGH: Address high-severity vulnerabilities promptly")
	}
	if summary.MediumCount > 0 {
		summary.Recommendations = append(summary.Recommendations,
			"MEDIUM: Review and fix medium-severity issues")
	}

	return summary
}

// Log security scan results
func (el *EnhancedLogger) logSecurityScanResults() {
	el.Log(LogLevelSecurity, "security-scan", fmt.Sprintf("Security scan completed: %d vulnerabilities found", el.scanResults.Summary.TotalVulnerabilities), map[string]interface{}{
		"scan_id":       el.scanResults.ScanID,
		"scan_type":     el.scanResults.ScanType,
		"target":        el.scanResults.Target,
		"critical":      el.scanResults.Summary.CriticalCount,
		"high":          el.scanResults.Summary.HighCount,
		"medium":        el.scanResults.Summary.MediumCount,
		"low":           el.scanResults.Summary.LowCount,
		"info":          el.scanResults.Summary.InfoCount,
		"recommendations": el.scanResults.Summary.Recommendations,
	})

	// Log individual vulnerabilities
	for _, vuln := range el.scanResults.Vulnerabilities {
		el.Log(LogLevelSecurity, "vulnerability", fmt.Sprintf("Found %s vulnerability: %s", vuln.Severity, vuln.Title), map[string]interface{}{
			"id":          vuln.ID,
			"severity":    string(vuln.Severity),
			"cve":         vuln.CVE,
			"package":     vuln.Package,
			"version":     vuln.Version,
			"fixed_version": vuln.FixedVersion,
			"description": vuln.Description,
			"location":    vuln.Location,
			"line_number": vuln.LineNumber,
		})
	}
}

// Create downloadable security scan report
func (el *EnhancedLogger) createSecurityScanReport() {
	var report strings.Builder

	report.WriteString("TASK MANAGEMENT AI SYSTEM - SECURITY SCAN REPORT\n")
	report.WriteString("================================================\n\n")
	report.WriteString(fmt.Sprintf("Scan ID: %s\n", el.scanResults.ScanID))
	report.WriteString(fmt.Sprintf("Timestamp: %s\n", el.scanResults.Timestamp.Format("2006-01-02 15:04:05")))
	report.WriteString(fmt.Sprintf("Scan Type: %s\n", el.scanResults.ScanType))
	report.WriteString(fmt.Sprintf("Target: %s\n", el.scanResults.Target))
	report.WriteString(fmt.Sprintf("Status: %s\n\n", el.scanResults.Status))

	report.WriteString("SUMMARY\n")
	report.WriteString("-------\n")
	report.WriteString(fmt.Sprintf("Total Vulnerabilities: %d\n", el.scanResults.Summary.TotalVulnerabilities))
	report.WriteString(fmt.Sprintf("Critical: %d\n", el.scanResults.Summary.CriticalCount))
	report.WriteString(fmt.Sprintf("High: %d\n", el.scanResults.Summary.HighCount))
	report.WriteString(fmt.Sprintf("Medium: %d\n", el.scanResults.Summary.MediumCount))
	report.WriteString(fmt.Sprintf("Low: %d\n", el.scanResults.Summary.LowCount))
	report.WriteString(fmt.Sprintf("Info: %d\n\n", el.scanResults.Summary.InfoCount))

	if len(el.scanResults.Summary.Recommendations) > 0 {
		report.WriteString("RECOMMENDATIONS\n")
		report.WriteString("---------------\n")
		for _, rec := range el.scanResults.Summary.Recommendations {
			report.WriteString(fmt.Sprintf("• %s\n", rec))
		}
		report.WriteString("\n")
	}

	report.WriteString("DETAILED VULNERABILITIES\n")
	report.WriteString("========================\n\n")

	// Sort vulnerabilities by severity
	sortedVulns := el.sortVulnerabilitiesBySeverity(el.scanResults.Vulnerabilities)

	for i, vuln := range sortedVulns {
		report.WriteString(fmt.Sprintf("%d. [%s] %s\n", i+1, vuln.Severity, vuln.Title))
		report.WriteString(fmt.Sprintf("   ID: %s\n", vuln.ID))
		if vuln.CVE != "" {
			report.WriteString(fmt.Sprintf("   CVE: %s\n", vuln.CVE))
		}
		if vuln.CVSS > 0 {
			report.WriteString(fmt.Sprintf("   CVSS Score: %.1f\n", vuln.CVSS))
		}
		if vuln.Package != "" {
			report.WriteString(fmt.Sprintf("   Package: %s", vuln.Package))
			if vuln.Version != "" {
				report.WriteString(fmt.Sprintf(" (%s)", vuln.Version))
			}
			report.WriteString("\n")
		}
		if vuln.FixedVersion != "" {
			report.WriteString(fmt.Sprintf("   Fixed Version: %s\n", vuln.FixedVersion))
		}
		if vuln.Location != "" {
			report.WriteString(fmt.Sprintf("   Location: %s", vuln.Location))
			if vuln.LineNumber > 0 {
				report.WriteString(fmt.Sprintf(":%d", vuln.LineNumber))
			}
			report.WriteString("\n")
		}
		report.WriteString(fmt.Sprintf("   Description: %s\n", vuln.Description))
		if len(vuln.References) > 0 {
			report.WriteString("   References:\n")
			for _, ref := range vuln.References {
				report.WriteString(fmt.Sprintf("     • %s\n", ref))
			}
		}
		report.WriteString("\n")
	}

	report.WriteString("RAW SCAN OUTPUT\n")
	report.WriteString("===============\n")
	report.WriteString(el.scanResults.RawOutput)
	report.WriteString("\n")

	// Create downloadable report
	el.createDownloadableReport(
		fmt.Sprintf("security-scan-%s.txt", el.scanResults.ScanID[:8]),
		"Security Scan Report",
		fmt.Sprintf("Comprehensive security scan results for %s", el.scanResults.Target),
		report.String(),
		"text/plain",
		[]string{"security", "scan", "vulnerabilities", el.scanResults.ScanType},
	)
}

// Sort vulnerabilities by severity
func (el *EnhancedLogger) sortVulnerabilitiesBySeverity(vulns []Vulnerability) []Vulnerability {
	severityOrder := map[VulnerabilitySeverity]int{
		SeverityCritical: 5,
		SeverityHigh:     4,
		SeverityMedium:   3,
		SeverityLow:      2,
		SeverityInfo:     1,
		SeverityUnknown:  0,
	}

	sort.Slice(vulns, func(i, j int) bool {
		return severityOrder[vulns[i].Severity] > severityOrder[vulns[j].Severity]
	})

	return vulns
}

// Create downloadable report
func (el *EnhancedLogger) createDownloadableReport(filename, name, description, content, contentType string, tags []string) string {
	el.reportMutex.Lock()
	defer el.reportMutex.Unlock()

	reportID := uuid.New().String()

	report := &DownloadableReport{
		ID:          reportID,
		Name:        name,
		Description: description,
		Content:     content,
		ContentType: contentType,
		Size:        int64(len(content)),
		CreatedAt:   time.Now(),
		ExpiresAt:   time.Now().Add(30 * 24 * time.Hour), // 30 days
		DownloadURL: fmt.Sprintf("/api/logs/download/%s", reportID),
		Tags:        tags,
	}

	el.downloadableReports[reportID] = report

	// Save to file
	filepath := filepath.Join(el.logDir, filename)
	if err := os.WriteFile(filepath, []byte(content), 0644); err != nil {
		el.LogError("logger", err, "Failed to save downloadable report", map[string]interface{}{
			"filename": filename,
			"report_id": reportID,
		})
	}

	el.Log(LogLevelInfo, "logger", "Created downloadable report", map[string]interface{}{
		"report_id": reportID,
		"filename":  filename,
		"size":      report.Size,
		"tags":      tags,
	})

	return reportID
}

// Get downloadable report
func (el *EnhancedLogger) GetDownloadableReport(reportID string) (*DownloadableReport, error) {
	el.reportMutex.RLock()
	defer el.reportMutex.RUnlock()

	report, exists := el.downloadableReports[reportID]
	if !exists {
		return nil, fmt.Errorf("report not found")
	}

	if time.Now().After(report.ExpiresAt) {
		return nil, fmt.Errorf("report expired")
	}

	return report, nil
}

// List downloadable reports
func (el *EnhancedLogger) ListDownloadableReports() []*DownloadableReport {
	el.reportMutex.RLock()
	defer el.reportMutex.RUnlock()

	var reports []*DownloadableReport
	for _, report := range el.downloadableReports {
		if time.Now().Before(report.ExpiresAt) {
			reports = append(reports, report)
		}
	}

	return reports
}

// Create comprehensive log report
func (el *EnhancedLogger) CreateComprehensiveLogReport() string {
	el.mutex.RLock()
	defer el.mutex.RUnlock()

	var report strings.Builder

	report.WriteString("TASK MANAGEMENT AI SYSTEM - COMPREHENSIVE LOG REPORT\n")
	report.WriteString("===================================================\n\n")
	report.WriteString(fmt.Sprintf("Generated: %s\n", time.Now().Format("2006-01-02 15:04:05")))
	report.WriteString(fmt.Sprintf("Log Directory: %s\n\n", el.logDir))

	// Add current buffer contents
	report.WriteString("RECENT LOG ENTRIES\n")
	report.WriteString("==================\n")
	report.WriteString(el.logBuffer.String())
	report.WriteString("\n")

	// Add security scan summary if available
	if el.scanResults.ScanID != "" {
		report.WriteString("SECURITY SCAN SUMMARY\n")
		report.WriteString("=====================\n")
		report.WriteString(fmt.Sprintf("Last Scan ID: %s\n", el.scanResults.ScanID))
		report.WriteString(fmt.Sprintf("Last Scan Time: %s\n", el.scanResults.Timestamp.Format("2006-01-02 15:04:05")))
		report.WriteString(fmt.Sprintf("Total Vulnerabilities: %d\n", el.scanResults.Summary.TotalVulnerabilities))
		report.WriteString(fmt.Sprintf("Critical: %d, High: %d, Medium: %d, Low: %d, Info: %d\n",
			el.scanResults.Summary.CriticalCount,
			el.scanResults.Summary.HighCount,
			el.scanResults.Summary.MediumCount,
			el.scanResults.Summary.LowCount,
			el.scanResults.Summary.InfoCount))
		report.WriteString("\n")
	}

	return el.createDownloadableReport(
		fmt.Sprintf("comprehensive-log-%s.txt", time.Now().Format("2006-01-02_15-04-05")),
		"Comprehensive Log Report",
		"Complete log report with recent entries and security scan summary",
		report.String(),
		"text/plain",
		[]string{"logs", "comprehensive", "report"},
	)
}

// Parse vulnerability from various scanner outputs
func (el *EnhancedLogger) ParseVulnerabilityFromOutput(scannerType string, output string) []Vulnerability {
	var vulnerabilities []Vulnerability

	switch scannerType {
	case "trivy":
		vulnerabilities = el.parseTrivyOutput(output)
	case "gosec":
		vulnerabilities = el.parseGosecOutput(output)
	case "nancy":
		vulnerabilities = el.parseNancyOutput(output)
	case "gitleaks":
		vulnerabilities = el.parseGitleaksOutput(output)
	default:
		el.Log(LogLevelWarn, "logger", "Unknown scanner type for parsing", map[string]interface{}{
			"scanner_type": scannerType,
		})
	}

	return vulnerabilities
}
