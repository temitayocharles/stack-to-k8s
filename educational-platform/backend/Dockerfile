# Educational Platform Backend - Spring Boot Application
# Multi-stage build for production

# Stage 1: Build stage
FROM maven:3.9.5-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy POM file first for better layer caching
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests=true -B

# Stage 2: Production stage
FROM eclipse-temurin:17-jre AS production

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r springboot && useradd -r -g springboot springboot

# Set working directory
WORKDIR /app

# Create directories for uploads and logs
RUN mkdir -p /app/uploads /app/logs && \
    chown -R springboot:springboot /app

# Copy JAR from builder stage
COPY --from=builder --chown=springboot:springboot /app/target/*.jar app.jar

# Switch to non-root user
USER springboot

# Expose port
EXPOSE 8080

# Environment variables
ENV SPRING_PROFILES_ACTIVE=docker
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Start application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]