package main

// Multi-Application Notification Pipeline System
// Comprehensive notification system supporting Slack, Mattermost, SMTP, and more
// Provides intelligent routing, templating, and delivery optimization across all workspace applications
// Users can remove communication tools that don't apply to their specific application

import (
	"bytes"
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"net/smtp"
	"strings"
	"sync"
	"time"

	"github.com/google/uuid"
)

// NotificationMessage - Universal notification message structure
type NotificationMessage struct {
	ID          string                 `json:"id"`
	Type        NotificationType       `json:"type"`
	Priority    NotificationPriority   `json:"priority"`
	Title       string                 `json:"title"`
	Message     string                 `json:"message"`
	Details     map[string]interface{} `json:"details,omitempty"`
	Recipients  []string               `json:"recipients"`
	Channels    []NotificationChannel  `json:"channels"`
	Template    string                 `json:"template,omitempty"`
	Context     *NotificationContext   `json:"context,omitempty"`
	CreatedAt   time.Time              `json:"created_at"`
	SentAt      *time.Time             `json:"sent_at,omitempty"`
	Status      NotificationStatus     `json:"status"`
	RetryCount  int                    `json:"retry_count"`
	Error       string                 `json:"error,omitempty"`
}

type NotificationType string

const (
	NotificationTypeInfo        NotificationType = "info"
	NotificationTypeWarning     NotificationType = "warning"
	NotificationTypeError       NotificationType = "error"
	NotificationTypeSuccess     NotificationType = "success"
	NotificationTypeAlert       NotificationType = "alert"
	NotificationTypeDeployment  NotificationType = "deployment"
	NotificationTypeSecurity    NotificationType = "security"
	NotificationTypePerformance NotificationType = "performance"
)

type NotificationPriority string

const (
	PriorityLow      NotificationPriority = "low"
	PriorityNormal   NotificationPriority = "normal"
	PriorityHigh     NotificationPriority = "high"
	PriorityCritical NotificationPriority = "critical"
)

type NotificationChannel string

const (
	ChannelSlack      NotificationChannel = "slack"
	ChannelMattermost NotificationChannel = "mattermost"
	ChannelEmail      NotificationChannel = "email"
	ChannelWebhook    NotificationChannel = "webhook"
	ChannelSMS        NotificationChannel = "sms"
)

type NotificationStatus string

const (
	StatusPending   NotificationStatus = "pending"
	StatusSent      NotificationStatus = "sent"
	StatusFailed    NotificationStatus = "failed"
	StatusRetrying  NotificationStatus = "retrying"
)

// NotificationContext - Contextual information for smart routing
type NotificationContext struct {
	UserID      string            `json:"user_id,omitempty"`
	ProjectID   string            `json:"project_id,omitempty"`
	Environment string            `json:"environment,omitempty"`
	Component   string            `json:"component,omitempty"`
	Tags        []string          `json:"tags,omitempty"`
	Metadata    map[string]string `json:"metadata,omitempty"`
}

// SlackNotifier - Slack notification client
type SlackNotifier struct {
	webhookURL string
	client     *http.Client
	timeout    time.Duration
}

type SlackMessage struct {
	Text        string              `json:"text,omitempty"`
	Username    string              `json:"username,omitempty"`
	IconEmoji   string              `json:"icon_emoji,omitempty"`
	IconURL     string              `json:"icon_url,omitempty"`
	Channel     string              `json:"channel,omitempty"`
	Attachments []SlackAttachment   `json:"attachments,omitempty"`
}

type SlackAttachment struct {
	Fallback   string `json:"fallback"`
	Color      string `json:"color"`
	Pretext    string `json:"pretext,omitempty"`
	AuthorName string `json:"author_name,omitempty"`
	AuthorLink string `json:"author_link,omitempty"`
	AuthorIcon string `json:"author_icon,omitempty"`
	Title      string `json:"title"`
	TitleLink  string `json:"title_link,omitempty"`
	Text       string `json:"text"`
	Fields     []SlackField `json:"fields,omitempty"`
	ImageURL   string `json:"image_url,omitempty"`
	ThumbURL   string `json:"thumb_url,omitempty"`
	Footer     string `json:"footer,omitempty"`
	FooterIcon string `json:"footer_icon,omitempty"`
	Ts         int64  `json:"ts,omitempty"`
}

type SlackField struct {
	Title string `json:"title"`
	Value string `json:"value"`
	Short bool   `json:"short,omitempty"`
}

// MattermostNotifier - Mattermost notification client
type MattermostNotifier struct {
	webhookURL string
	client     *http.Client
	timeout    time.Duration
}

type MattermostMessage struct {
	Text        string                    `json:"text,omitempty"`
	Username    string                    `json:"username,omitempty"`
	IconURL     string                    `json:"icon_url,omitempty"`
	Channel     string                    `json:"channel,omitempty"`
	Attachments []MattermostAttachment    `json:"attachments,omitempty"`
}

type MattermostAttachment struct {
	Fallback   string `json:"fallback"`
	Color      string `json:"color"`
	Pretext    string `json:"pretext,omitempty"`
	AuthorName string `json:"author_name,omitempty"`
	AuthorLink string `json:"author_link,omitempty"`
	Title      string `json:"title"`
	TitleLink  string `json:"title_link,omitempty"`
	Text       string `json:"text"`
	Fields     []MattermostField `json:"fields,omitempty"`
	ImageURL   string `json:"image_url,omitempty"`
	ThumbURL   string `json:"thumb_url,omitempty"`
	Footer     string `json:"footer,omitempty"`
}

// SMTPNotifier - Email notification client
type SMTPNotifier struct {
	host     string
	port     int
	username string
	password string
	from     string
	tls      bool
	client   *smtp.Client
}

type EmailMessage struct {
	To          []string
	CC          []string
	BCC         []string
	Subject     string
	Body        string
	HTMLBody    string
	Attachments []EmailAttachment
}

type EmailAttachment struct {
	Filename    string
	ContentType string
	Data        []byte
}

// WebhookNotifier - Generic webhook notification client
type WebhookNotifier struct {
	url     string
	headers map[string]string
	client  *http.Client
	timeout time.Duration
}

// NotificationTemplateEngine - Template engine for notifications
type NotificationTemplateEngine struct {
	templates map[string]*template.Template
	mutex     sync.RWMutex
}

// NotificationRouter - Intelligent routing engine
type NotificationRouter struct {
	rules    []RoutingRule
	escalationRules []EscalationRule
	mutex    sync.RWMutex
}

type RoutingRule struct {
	Condition  func(*NotificationMessage) bool
	Channels   []NotificationChannel
	Priority   NotificationPriority
	Recipients []string
}

type EscalationRule struct {
	Condition     func(*NotificationMessage) bool
	EscalateAfter time.Duration
	EscalateTo    []string
	NewPriority   NotificationPriority
}

// NotificationQueue - Queue for processing notifications
type NotificationQueue struct {
	queue   chan *NotificationMessage
	workers int
	stop    chan bool
}

// NotificationAnalytics - Analytics for notification performance
type NotificationAnalytics struct {
	sentCount     int64
	failedCount   int64
	avgLatency    time.Duration
	channelStats  map[NotificationChannel]*ChannelStats
	mutex         sync.RWMutex
}

type ChannelStats struct {
	SentCount   int64
	FailedCount int64
	AvgLatency  time.Duration
	LastUsed    time.Time
}

// Initialize the notification pipeline
func NewNotificationPipeline() *NotificationPipeline {
	pipeline := &NotificationPipeline{
		slackClient:     NewSlackNotifier(),
		mattermostClient: NewMattermostNotifier(),
		smtpClient:      NewSMTPNotifier(),
		webhookClient:   NewWebhookNotifier(),
		templateEngine:  NewNotificationTemplateEngine(),
		router:          NewNotificationRouter(),
		analytics:       NewNotificationAnalytics(),
		queue:           NewNotificationQueue(10), // 10 workers
	}

	// Start queue processing
	go pipeline.queue.Start(pipeline)

	return pipeline
}

// SendNotification - Main method to send notifications
func (np *NotificationPipeline) SendNotification(ctx context.Context, msg *NotificationMessage) error {
	// Set message ID if not provided
	if msg.ID == "" {
		msg.ID = uuid.New().String()
	}

	// Set creation time
	if msg.CreatedAt.IsZero() {
		msg.CreatedAt = time.Now()
	}

	// Apply intelligent routing
	routedMsg := np.router.RouteNotification(msg)

	// Queue for processing
	select {
	case np.queue.queue <- routedMsg:
		return nil
	case <-ctx.Done():
		return ctx.Err()
	default:
		return fmt.Errorf("notification queue is full")
	}
}

// Process notification from queue
func (np *NotificationPipeline) processNotification(msg *NotificationMessage) {
	start := time.Now()

	// Apply template if specified
	if msg.Template != "" {
		if err := np.templateEngine.ApplyTemplate(msg); err != nil {
			log.Printf("Failed to apply template %s: %v", msg.Template, err)
			np.updateNotificationStatus(msg, StatusFailed, err.Error())
			return
		}
	}

	// Send to all specified channels
	var lastError error
	sentCount := 0

	for _, channel := range msg.Channels {
		if err := np.sendToChannel(msg, channel); err != nil {
			log.Printf("Failed to send to %s: %v", channel, err)
			lastError = err
			msg.RetryCount++
		} else {
			sentCount++
		}
	}

	// Update status
	if sentCount > 0 {
		msg.Status = StatusSent
		msg.SentAt = &start
		np.analytics.RecordSuccess(msg.Channels, time.Since(start))
	} else {
		msg.Status = StatusFailed
		if lastError != nil {
			msg.Error = lastError.Error()
		}
		np.analytics.RecordFailure(msg.Channels)
	}

	// Handle retries for failed messages
	if msg.Status == StatusFailed && msg.RetryCount < 3 {
		msg.Status = StatusRetrying
		time.Sleep(time.Duration(msg.RetryCount) * time.Minute)
		np.queue.queue <- msg
	}
}

// Send to specific channel
func (np *NotificationPipeline) sendToChannel(msg *NotificationMessage, channel NotificationChannel) error {
	switch channel {
	case ChannelSlack:
		return np.slackClient.Send(msg)
	case ChannelMattermost:
		return np.mattermostClient.Send(msg)
	case ChannelEmail:
		return np.smtpClient.Send(msg)
	case ChannelWebhook:
		return np.webhookClient.Send(msg)
	default:
		return fmt.Errorf("unsupported channel: %s", channel)
	}
}

// Update notification status
func (np *NotificationPipeline) updateNotificationStatus(msg *NotificationMessage, status NotificationStatus, errorMsg string) {
	msg.Status = status
	if errorMsg != "" {
		msg.Error = errorMsg
	}
}

// Slack implementation
func (sn *SlackNotifier) Send(msg *NotificationMessage) error {
	if sn.webhookURL == "" {
		return fmt.Errorf("slack webhook URL not configured")
	}

	slackMsg := sn.convertToSlackMessage(msg)

	jsonData, err := json.Marshal(slackMsg)
	if err != nil {
		return fmt.Errorf("failed to marshal slack message: %v", err)
	}

	req, err := http.NewRequest("POST", sn.webhookURL, bytes.NewBuffer(jsonData))
	if err != nil {
		return fmt.Errorf("failed to create request: %v", err)
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: sn.timeout}
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("failed to send slack message: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("slack API returned status %d", resp.StatusCode)
	}

	return nil
}

func (sn *SlackNotifier) convertToSlackMessage(msg *NotificationMessage) *SlackMessage {
	color := sn.getColorForPriority(msg.Priority)

	attachment := SlackAttachment{
		Fallback: msg.Message,
		Color:    color,
		Title:    msg.Title,
		Text:     msg.Message,
		Fields:   sn.convertDetailsToFields(msg.Details),
		Footer:   "Task Management AI System",
		Ts:       msg.CreatedAt.Unix(),
	}

	return &SlackMessage{
		Text:        fmt.Sprintf("*%s*", msg.Title),
		Username:    "Task Management AI",
		IconEmoji:   ":robot_face:",
		Attachments: []SlackAttachment{attachment},
	}
}

func (sn *SlackNotifier) getColorForPriority(priority NotificationPriority) string {
	switch priority {
	case PriorityCritical:
		return "danger"
	case PriorityHigh:
		return "warning"
	case PriorityNormal:
		return "good"
	case PriorityLow:
		return "#808080"
	default:
		return "good"
	}
}

func (sn *SlackNotifier) convertDetailsToFields(details map[string]interface{}) []SlackField {
	var fields []SlackField
	for key, value := range details {
		fields = append(fields, SlackField{
			Title: key,
			Value: fmt.Sprintf("%v", value),
			Short: true,
		})
	}
	return fields
}

// Mattermost implementation
func (mn *MattermostNotifier) Send(msg *NotificationMessage) error {
	if mn.webhookURL == "" {
		return fmt.Errorf("mattermost webhook URL not configured")
	}

	mattermostMsg := mn.convertToMattermostMessage(msg)

	jsonData, err := json.Marshal(mattermostMsg)
	if err != nil {
		return fmt.Errorf("failed to marshal mattermost message: %v", err)
	}

	req, err := http.NewRequest("POST", mn.webhookURL, bytes.NewBuffer(jsonData))
	if err != nil {
		return fmt.Errorf("failed to create request: %v", err)
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: mn.timeout}
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("failed to send mattermost message: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("mattermost API returned status %d", resp.StatusCode)
	}

	return nil
}

func (mn *MattermostNotifier) convertToMattermostMessage(msg *NotificationMessage) *MattermostMessage {
	color := mn.getColorForPriority(msg.Priority)

	attachment := MattermostAttachment{
		Fallback: msg.Message,
		Color:    color,
		Title:    msg.Title,
		Text:     msg.Message,
		Fields:   mn.convertDetailsToFields(msg.Details),
		Footer:   "Task Management AI System",
	}

	return &MattermostMessage{
		Text:        fmt.Sprintf("**%s**", msg.Title),
		Username:    "Task Management AI",
		Attachments: []MattermostAttachment{attachment},
	}
}

func (mn *MattermostNotifier) getColorForPriority(priority NotificationPriority) string {
	switch priority {
	case PriorityCritical:
		return "#FF0000"
	case PriorityHigh:
		return "#FFA500"
	case PriorityNormal:
		return "#00FF00"
	case PriorityLow:
		return "#808080"
	default:
		return "#00FF00"
	}
}

func (mn *MattermostNotifier) convertDetailsToFields(details map[string]interface{}) []MattermostField {
	var fields []MattermostField
	for key, value := range details {
		fields = append(fields, MattermostField{
			Title: key,
			Value: fmt.Sprintf("%v", value),
			Short: true,
		})
	}
	return fields
}

// SMTP implementation
func (sn *SMTPNotifier) Send(msg *NotificationMessage) error {
	if sn.host == "" {
		return fmt.Errorf("SMTP host not configured")
	}

	emailMsg := sn.convertToEmailMessage(msg)

	return sn.sendEmail(emailMsg)
}

func (sn *SMTPNotifier) convertToEmailMessage(msg *NotificationMessage) *EmailMessage {
	subject := fmt.Sprintf("[%s] %s", strings.ToUpper(string(msg.Priority)), msg.Title)

	body := fmt.Sprintf(`
Task Management AI System Notification

%s

Details:
%s

Sent at: %s
`,
		msg.Message,
		sn.formatDetails(msg.Details),
		msg.CreatedAt.Format(time.RFC3339),
	)

	htmlBody := fmt.Sprintf(`
<html>
<body>
<h2>Task Management AI System Notification</h2>
<p><strong>%s</strong></p>
<p>%s</p>

<h3>Details:</h3>
%s

<p><em>Sent at: %s</em></p>
</body>
</html>
`,
		msg.Title,
		msg.Message,
		sn.formatDetailsHTML(msg.Details),
		msg.CreatedAt.Format(time.RFC3339),
	)

	return &EmailMessage{
		To:       msg.Recipients,
		Subject:  subject,
		Body:     body,
		HTMLBody: htmlBody,
	}
}

func (sn *SMTPNotifier) formatDetails(details map[string]interface{}) string {
	if len(details) == 0 {
		return "No additional details"
	}

	var lines []string
	for key, value := range details {
		lines = append(lines, fmt.Sprintf("- %s: %v", key, value))
	}
	return strings.Join(lines, "\n")
}

func (sn *SMTPNotifier) formatDetailsHTML(details map[string]interface{}) string {
	if len(details) == 0 {
		return "<p>No additional details</p>"
	}

	var lines []string
	for key, value := range details {
		lines = append(lines, fmt.Sprintf("<li><strong>%s:</strong> %v</li>", key, value))
	}
	return "<ul>" + strings.Join(lines, "") + "</ul>"
}

func (sn *SMTPNotifier) sendEmail(msg *EmailMessage) error {
	// Set up authentication
	auth := smtp.PlainAuth("", sn.username, sn.password, sn.host)

	// Connect to the server
	addr := fmt.Sprintf("%s:%d", sn.host, sn.port)
	client, err := smtp.Dial(addr)
	if err != nil {
		return fmt.Errorf("failed to connect to SMTP server: %v", err)
	}
	defer client.Close()

	// Start TLS if required
	if sn.tls {
		tlsConfig := &tls.Config{
			InsecureSkipVerify: false,
			ServerName:         sn.host,
		}
		if err = client.StartTLS(tlsConfig); err != nil {
			return fmt.Errorf("failed to start TLS: %v", err)
		}
	}

	// Authenticate
	if err = client.Auth(auth); err != nil {
		return fmt.Errorf("SMTP authentication failed: %v", err)
	}

	// Set the sender and recipient
	if err = client.Mail(sn.from); err != nil {
		return fmt.Errorf("failed to set sender: %v", err)
	}

	for _, recipient := range msg.To {
		if err = client.Rcpt(recipient); err != nil {
			return fmt.Errorf("failed to set recipient %s: %v", recipient, err)
		}
	}

	// Send the email body
	w, err := client.Data()
	if err != nil {
		return fmt.Errorf("failed to create data writer: %v", err)
	}

	// Construct the email message
	message := sn.buildEmailMessage(msg)
	_, err = w.Write([]byte(message))
	if err != nil {
		return fmt.Errorf("failed to write email data: %v", err)
	}

	err = w.Close()
	if err != nil {
		return fmt.Errorf("failed to close email data: %v", err)
	}

	// Send QUIT
	err = client.Quit()
	if err != nil {
		return fmt.Errorf("failed to quit SMTP session: %v", err)
	}

	return nil
}

func (sn *SMTPNotifier) buildEmailMessage(msg *EmailMessage) string {
	var message strings.Builder

	// Headers
	message.WriteString(fmt.Sprintf("From: %s\r\n", sn.from))
	message.WriteString(fmt.Sprintf("To: %s\r\n", strings.Join(msg.To, ",")))
	message.WriteString(fmt.Sprintf("Subject: %s\r\n", msg.Subject))
	message.WriteString("MIME-Version: 1.0\r\n")
	message.WriteString("Content-Type: multipart/alternative; boundary=boundary123\r\n")
	message.WriteString("\r\n")

	// Plain text part
	message.WriteString("--boundary123\r\n")
	message.WriteString("Content-Type: text/plain; charset=utf-8\r\n")
	message.WriteString("\r\n")
	message.WriteString(msg.Body)
	message.WriteString("\r\n")

	// HTML part
	message.WriteString("--boundary123\r\n")
	message.WriteString("Content-Type: text/html; charset=utf-8\r\n")
	message.WriteString("\r\n")
	message.WriteString(msg.HTMLBody)
	message.WriteString("\r\n")

	message.WriteString("--boundary123--\r\n")

	return message.String()
}

// Webhook implementation
func (wn *WebhookNotifier) Send(msg *NotificationMessage) error {
	if wn.url == "" {
		return fmt.Errorf("webhook URL not configured")
	}

	jsonData, err := json.Marshal(msg)
	if err != nil {
		return fmt.Errorf("failed to marshal webhook message: %v", err)
	}

	req, err := http.NewRequest("POST", wn.url, bytes.NewBuffer(jsonData))
	if err != nil {
		return fmt.Errorf("failed to create webhook request: %v", err)
	}

	req.Header.Set("Content-Type", "application/json")
	for key, value := range wn.headers {
		req.Header.Set(key, value)
	}

	client := &http.Client{Timeout: wn.timeout}
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("failed to send webhook: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return fmt.Errorf("webhook returned status %d", resp.StatusCode)
	}

	return nil
}

// Template engine implementation
func (nte *NotificationTemplateEngine) ApplyTemplate(msg *NotificationMessage) error {
	nte.mutex.RLock()
	tmpl, exists := nte.templates[msg.Template]
	nte.mutex.RUnlock()

	if !exists {
		return fmt.Errorf("template %s not found", msg.Template)
	}

	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, msg); err != nil {
		return fmt.Errorf("failed to execute template: %v", err)
	}

	msg.Message = buf.String()
	return nil
}

// Router implementation
func (nr *NotificationRouter) RouteNotification(msg *NotificationMessage) *NotificationMessage {
	routedMsg := *msg // Create a copy

	for _, rule := range nr.rules {
		if rule.Condition(msg) {
			// Add channels if not already present
			for _, channel := range rule.Channels {
				found := false
				for _, existing := range routedMsg.Channels {
					if existing == channel {
						found = true
						break
					}
				}
				if !found {
					routedMsg.Channels = append(routedMsg.Channels, channel)
				}
			}

			// Add recipients if not already present
			for _, recipient := range rule.Recipients {
				found := false
				for _, existing := range routedMsg.Recipients {
					if existing == recipient {
						found = true
						break
					}
				}
				if !found {
					routedMsg.Recipients = append(routedMsg.Recipients, recipient)
				}
			}

			// Update priority if rule has higher priority
			if nr.comparePriority(rule.Priority, routedMsg.Priority) > 0 {
				routedMsg.Priority = rule.Priority
			}
		}
	}

	return &routedMsg
}

func (nr *NotificationRouter) comparePriority(p1, p2 NotificationPriority) int {
	priorityOrder := map[NotificationPriority]int{
		PriorityLow:      0,
		PriorityNormal:   1,
		PriorityHigh:     2,
		PriorityCritical: 3,
	}

	return priorityOrder[p1] - priorityOrder[p2]
}

// Queue implementation
func NewNotificationQueue(workers int) *NotificationQueue {
	return &NotificationQueue{
		queue:   make(chan *NotificationMessage, 1000),
		workers: workers,
		stop:    make(chan bool),
	}
}

func (nq *NotificationQueue) Start(pipeline *NotificationPipeline) {
	for i := 0; i < nq.workers; i++ {
		go func() {
			for {
				select {
				case msg := <-nq.queue:
					pipeline.processNotification(msg)
				case <-nq.stop:
					return
				}
			}
		}()
	}
}

func (nq *NotificationQueue) Stop() {
	close(nq.stop)
}

// Analytics implementation
func NewNotificationAnalytics() *NotificationAnalytics {
	return &NotificationAnalytics{
		channelStats: make(map[NotificationChannel]*ChannelStats),
	}
}

func (na *NotificationAnalytics) RecordSuccess(channels []NotificationChannel, latency time.Duration) {
	na.mutex.Lock()
	defer na.mutex.Unlock()

	na.sentCount++
	for _, channel := range channels {
		if stats, exists := na.channelStats[channel]; exists {
			stats.SentCount++
			stats.LastUsed = time.Now()
			// Update average latency
			if stats.AvgLatency == 0 {
				stats.AvgLatency = latency
			} else {
				stats.AvgLatency = (stats.AvgLatency + latency) / 2
			}
		} else {
			na.channelStats[channel] = &ChannelStats{
				SentCount:  1,
				AvgLatency: latency,
				LastUsed:   time.Now(),
			}
		}
	}
}

func (na *NotificationAnalytics) RecordFailure(channels []NotificationChannel) {
	na.mutex.Lock()
	defer na.mutex.Unlock()

	na.failedCount++
	for _, channel := range channels {
		if stats, exists := na.channelStats[channel]; exists {
			stats.FailedCount++
		} else {
			na.channelStats[channel] = &ChannelStats{
				FailedCount: 1,
				LastUsed:    time.Now(),
			}
		}
	}
}

// Constructor functions
func NewSlackNotifier() *SlackNotifier {
	return &SlackNotifier{
		timeout: 30 * time.Second,
	}
}

func NewMattermostNotifier() *MattermostNotifier {
	return &MattermostNotifier{
		timeout: 30 * time.Second,
	}
}

func NewSMTPNotifier() *SMTPNotifier {
	return &SMTPNotifier{
		port: 587,
		tls:  true,
	}
}

func NewWebhookNotifier() *WebhookNotifier {
	return &WebhookNotifier{
		headers: make(map[string]string),
		timeout: 30 * time.Second,
	}
}

func NewNotificationTemplateEngine() *NotificationTemplateEngine {
	return &NotificationTemplateEngine{
		templates: make(map[string]*template.Template),
	}
}

func NewNotificationRouter() *NotificationRouter {
	return &NotificationRouter{
		rules:          make([]RoutingRule, 0),
		escalationRules: make([]EscalationRule, 0),
	}
}

// Configuration methods
func (sn *SlackNotifier) Configure(webhookURL string) {
	sn.webhookURL = webhookURL
	sn.client = &http.Client{Timeout: sn.timeout}
}

func (mn *MattermostNotifier) Configure(webhookURL string) {
	mn.webhookURL = webhookURL
	mn.client = &http.Client{Timeout: mn.timeout}
}

func (sn *SMTPNotifier) Configure(host string, port int, username, password, from string, tls bool) {
	sn.host = host
	sn.port = port
	sn.username = username
	sn.password = password
	sn.from = from
	sn.tls = tls
}

func (wn *WebhookNotifier) Configure(url string, headers map[string]string) {
	wn.url = url
	wn.headers = headers
	wn.client = &http.Client{Timeout: wn.timeout}
}

// This notification pipeline provides comprehensive multi-channel notification support
// with intelligent routing, templating, and analytics for the AI-powered task management system
