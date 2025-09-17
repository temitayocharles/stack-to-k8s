package main

// Multi-Application Notification Pipeline Example
// Demonstrates how to configure and use the notification system across all workspace applications
// Shows how users can customize communication channels and remove unused tools

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/google/uuid"
)

func main() {
	fmt.Println("🚀 Multi-Application Notification Pipeline Demo")
	fmt.Println("==============================================")

	// Initialize the notification pipeline
	pipeline := NewMultiApplicationNotificationPipeline()

	// Demonstrate configuration for each application
	demonstrateApplicationConfigurations(pipeline)

	// Show how to remove unused communication channels
	demonstrateChannelManagement(pipeline)

	// Send sample notifications for different applications
	demonstrateNotificationSending(pipeline)

	// Generate and display configuration guide
	displayConfigurationGuide(pipeline)

	fmt.Println("\n✅ Demo completed successfully!")
}

// Demonstrate configuring each application
func demonstrateApplicationConfigurations(pipeline *MultiApplicationNotificationPipeline) {
	fmt.Println("\n📋 Configuring Applications...")

	// Configure Task Management Application with Slack and Email
	taskConfig := &ApplicationNotificationConfig{
		Name:        "Task Management AI System",
		Description: "Advanced task management with AI and real-time collaboration",
		EnabledChannels: []NotificationChannel{ChannelSlack, ChannelEmail},
		DefaultRecipients: []string{"dev-team@company.com", "product-team@company.com"},
		SlackWebhookURL: "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK",
		SMTPConfig: &SMTPConfig{
			Host:     "smtp.gmail.com",
			Port:     587,
			Username: "your-email@gmail.com",
			Password: "your-app-password",
			From:     "noreply@company.com",
			UseTLS:   true,
		},
	}

	if err := pipeline.ConfigureApplication("task-management", taskConfig); err != nil {
		log.Printf("Failed to configure task-management: %v", err)
	}

	// Configure E-commerce Application with Email only (Slack removed)
	ecommerceConfig := &ApplicationNotificationConfig{
		Name:        "E-commerce Platform",
		Description: "Node.js/Express + React + MongoDB e-commerce application",
		EnabledChannels: []NotificationChannel{ChannelEmail}, // Slack removed as per user preference
		DefaultRecipients: []string{"ecommerce-team@company.com", "sales-team@company.com"},
		SMTPConfig: &SMTPConfig{
			Host:     "smtp.company.com",
			Port:     587,
			Username: "notifications@company.com",
			Password: "secure-password",
			From:     "ecommerce@company.com",
			UseTLS:   true,
		},
	}

	if err := pipeline.ConfigureApplication("ecommerce", ecommerceConfig); err != nil {
		log.Printf("Failed to configure ecommerce: %v", err)
	}

	// Configure Medical Care System with Webhook and Email
	medicalConfig := &ApplicationNotificationConfig{
		Name:        "Medical Care System",
		Description: ".NET Core + Blazor + SQL Server healthcare management system",
		EnabledChannels: []NotificationChannel{ChannelEmail, ChannelWebhook},
		DefaultRecipients: []string{"medical-team@company.com", "compliance-team@company.com"},
		SMTPConfig: &SMTPConfig{
			Host:     "smtp.secure-hospital.com",
			Port:     587,
			Username: "alerts@hospital.com",
			Password: "secure-password",
			From:     "alerts@hospital.com",
			UseTLS:   true,
		},
		WebhookConfig: &WebhookConfig{
			URL: "https://api.hospital-monitoring.com/webhooks/alerts",
			Headers: map[string]string{
				"Authorization": "Bearer hospital-token",
				"Content-Type":  "application/json",
			},
		},
	}

	if err := pipeline.ConfigureApplication("medical", medicalConfig); err != nil {
		log.Printf("Failed to configure medical: %v", err)
	}

	fmt.Println("✅ All applications configured successfully")
}

// Demonstrate removing and adding communication channels
func demonstrateChannelManagement(pipeline *MultiApplicationNotificationPipeline) {
	fmt.Println("\n🔧 Managing Communication Channels...")

	// Remove Mattermost from Educational Platform (user doesn't use it)
	if err := pipeline.RemoveApplicationChannel("educational", ChannelMattermost); err != nil {
		log.Printf("Failed to remove Mattermost from educational: %v", err)
	} else {
		fmt.Println("✅ Removed Mattermost from Educational Platform")
	}

	// Add Webhook to Weather Application for external integrations
	if err := pipeline.AddApplicationChannel("weather", ChannelWebhook); err != nil {
		log.Printf("Failed to add Webhook to weather: %v", err)
	} else {
		fmt.Println("✅ Added Webhook to Weather Application")
	}

	// Remove Email from Social Media Platform (prefers Slack only)
	if err := pipeline.RemoveApplicationChannel("social-media", ChannelEmail); err != nil {
		log.Printf("Failed to remove Email from social-media: %v", err)
	} else {
		fmt.Println("✅ Removed Email from Social Media Platform")
	}

	fmt.Println("✅ Channel management completed")
}

// Demonstrate sending notifications for different applications
func demonstrateNotificationSending(pipeline *MultiApplicationNotificationPipeline) {
	fmt.Println("\n📤 Sending Sample Notifications...")

	ctx := context.Background()

	// Task Management - Deployment Notification
	taskMsg := &NotificationMessage{
		Application: "task-management",
		Type:        NotificationTypeDeployment,
		Priority:    PriorityHigh,
		Title:       "AI Engine Update Deployed",
		Message:     "Task Management AI v2.1.0 deployed with enhanced burnout prevention",
		Template:    "deployment",
		Context: &NotificationContext{
			Environment: "production",
			Component:   "ai-engine",
		},
		Details: map[string]interface{}{
			"version":       "2.1.0",
			"dashboard_url": "https://taskmanager.company.com/dashboard",
			"features":      []string{"burnout-prevention", "smart-routing", "real-time-collab"},
		},
		Channels: []NotificationChannel{ChannelSlack, ChannelEmail},
	}

	if err := pipeline.SendNotification(ctx, taskMsg); err != nil {
		log.Printf("Failed to send task notification: %v", err)
	} else {
		fmt.Println("✅ Task Management deployment notification sent")
	}

	// E-commerce - Order Alert
	ecommerceMsg := &NotificationMessage{
		Application: "ecommerce",
		Type:        NotificationTypeInfo,
		Priority:    PriorityNormal,
		Title:       "High-Value Order Received",
		Message:     "New order worth $5,200 received",
		Template:    "order",
		Context: &NotificationContext{
			Environment: "production",
			Component:   "order-system",
		},
		Details: map[string]interface{}{
			"order_id":        "ORD-2024-00123",
			"amount":          "$5,200.00",
			"customer_email":  "vip-customer@company.com",
			"items_count":     15,
		},
		Channels: []NotificationChannel{ChannelEmail},
	}

	if err := pipeline.SendNotification(ctx, ecommerceMsg); err != nil {
		log.Printf("Failed to send ecommerce notification: %v", err)
	} else {
		fmt.Println("✅ E-commerce order notification sent")
	}

	// Medical Care - Emergency Alert
	medicalMsg := &NotificationMessage{
		Application: "medical",
		Type:        NotificationTypeAlert,
		Priority:    PriorityCritical,
		Title:       "Critical Patient Alert",
		Message:     "Patient in ICU requires immediate attention",
		Template:    "emergency",
		Context: &NotificationContext{
			Environment: "production",
			Component:   "patient-monitoring",
		},
		Details: map[string]interface{}{
			"patient_id": "PAT-789456",
			"priority":   "critical",
			"location":   "ICU Room 204",
			"condition":  "cardiac-arrest",
		},
		Channels: []NotificationChannel{ChannelEmail, ChannelWebhook},
	}

	if err := pipeline.SendNotification(ctx, medicalMsg); err != nil {
		log.Printf("Failed to send medical notification: %v", err)
	} else {
		fmt.Println("✅ Medical emergency notification sent")
	}

	// Weather - Severe Weather Alert
	weatherMsg := &NotificationMessage{
		Application: "weather",
		Type:        NotificationTypeAlert,
		Priority:    PriorityHigh,
		Title:       "Severe Storm Warning",
		Message:     "Category 4 hurricane approaching coastal areas",
		Template:    "alert",
		Context: &NotificationContext{
			Environment: "production",
			Component:   "weather-monitoring",
		},
		Details: map[string]interface{}{
			"alert_type":  "hurricane",
			"severity":    "severe",
			"location":    "East Coast Region",
			"alert_url":   "https://weather.company.com/alerts/HUR-2024-045",
			"wind_speed":  "140 mph",
			"radius":      "200 miles",
		},
		Channels: []NotificationChannel{ChannelWebhook, ChannelEmail},
	}

	if err := pipeline.SendNotification(ctx, weatherMsg); err != nil {
		log.Printf("Failed to send weather notification: %v", err)
	} else {
		fmt.Println("✅ Weather alert notification sent")
	}

	// Wait a moment for notifications to be processed
	time.Sleep(2 * time.Second)
	fmt.Println("✅ All sample notifications sent")
}

// Display the configuration guide
func displayConfigurationGuide(pipeline *MultiApplicationNotificationPipeline) {
	fmt.Println("\n📖 Configuration Guide")
	fmt.Println("======================")

	guide := pipeline.GenerateConfigurationGuide()
	fmt.Println(guide)

	// Show current application configurations
	fmt.Println("\n📋 Current Application Configurations:")
	fmt.Println("=====================================")

	apps := pipeline.ListApplications()
	for appName, config := range apps {
		fmt.Printf("\n🔹 %s (%s)\n", config.Name, appName)
		fmt.Printf("   Description: %s\n", config.Description)
		fmt.Printf("   Enabled Channels: %v\n", config.EnabledChannels)
		fmt.Printf("   Default Recipients: %v\n", config.DefaultRecipients)
		if len(config.Templates) > 0 {
			fmt.Printf("   Available Templates: %v\n", getTemplateNames(config.Templates))
		}
		if len(config.RoutingRules) > 0 {
			fmt.Printf("   Routing Rules: %d configured\n", len(config.RoutingRules))
		}
	}
}

// Helper function to get template names
func getTemplateNames(templates map[string]string) []string {
	names := make([]string, 0, len(templates))
	for name := range templates {
		names = append(names, name)
	}
	return names
}

// Example of how to integrate with your application code
func exampleIntegration() {
	fmt.Println("\n💡 Integration Example")
	fmt.Println("======================")

	codeExample := `
// Initialize pipeline (do this once at application startup)
pipeline := NewMultiApplicationNotificationPipeline()

// Configure your application
config := &ApplicationNotificationConfig{
    Name: "Your Application",
    EnabledChannels: []NotificationChannel{ChannelSlack, ChannelEmail},
    DefaultRecipients: []string{"team@company.com"},
    SlackWebhookURL: "your-slack-webhook-url",
    SMTPConfig: &SMTPConfig{
        Host: "smtp.company.com",
        Port: 587,
        Username: "notifications@company.com",
        Password: "your-password",
        From: "noreply@company.com",
        UseTLS: true,
    },
}

err := pipeline.ConfigureApplication("your-app", config)

// Send notifications anywhere in your code
msg := &NotificationMessage{
    Application: "your-app",
    Type: NotificationTypeInfo,
    Title: "Something happened",
    Message: "Details about the event",
    Channels: []NotificationChannel{ChannelSlack},
}

err = pipeline.SendNotification(ctx, msg)
`

	fmt.Println(codeExample)
}

// Example of removing unused communication tools
func exampleRemovingChannels() {
	fmt.Println("\n🗑️  Removing Unused Communication Tools")
	fmt.Println("======================================")

	examples := `
// Remove Slack if your team doesn't use it
err := pipeline.RemoveApplicationChannel("your-app", ChannelSlack)

// Remove Mattermost if you prefer other tools
err := pipeline.RemoveApplicationChannel("your-app", ChannelMattermost)

// Remove Email if you want to reduce notification volume
err := pipeline.RemoveApplicationChannel("your-app", ChannelEmail)

// Keep only the channels you actually use
err := pipeline.AddApplicationChannel("your-app", ChannelWebhook) // Add if needed
`

	fmt.Println(examples)
}
