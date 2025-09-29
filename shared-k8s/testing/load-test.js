// k6 Load Testing Suite for Enterprise Applications
// Comprehensive performance testing with multiple scenarios

import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter, Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('error_rate');
const customResponseTime = new Trend('custom_response_time');
const successfulRequests = new Counter('successful_requests');

// Test scenarios configuration
export let options = {
  scenarios: {
    // Smoke Test - Basic functionality
    smoke_test: {
      executor: 'constant-vus',
      vus: 1,
      duration: '30s',
      tags: { test_type: 'smoke' },
    },
    
    // Load Test - Normal capacity
    load_test: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '2m', target: 20 },
        { duration: '5m', target: 20 },
        { duration: '2m', target: 0 },
      ],
      tags: { test_type: 'load' },
    },
    
    // Stress Test - Beyond normal capacity
    stress_test: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '2m', target: 50 },
        { duration: '5m', target: 50 },
        { duration: '3m', target: 100 },
        { duration: '2m', target: 100 },
        { duration: '2m', target: 0 },
      ],
      tags: { test_type: 'stress' },
    },
    
    // Spike Test - Sudden traffic increase
    spike_test: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '10s', target: 5 },
        { duration: '1m', target: 5 },
        { duration: '10s', target: 50 },
        { duration: '3m', target: 50 },
        { duration: '10s', target: 5 },
        { duration: '3m', target: 5 },
        { duration: '10s', target: 0 },
      ],
      tags: { test_type: 'spike' },
    },
    
    // Endurance Test - Extended duration
    endurance_test: {
      executor: 'constant-vus',
      vus: 10,
      duration: '30m',
      tags: { test_type: 'endurance' },
    },
  },
  
  thresholds: {
    // Performance targets
    'http_req_duration': ['p(95)<500'], // 95th percentile under 500ms
    'http_req_failed': ['rate<0.01'],   // Error rate under 1%
    'http_reqs': ['rate>100'],          // Throughput over 100 RPS
    'error_rate': ['rate<0.05'],        // Custom error rate under 5%
    'custom_response_time': ['p(90)<300'], // 90th percentile under 300ms
  },
};

// Application endpoints configuration
const endpoints = {
  educational: {
    base: 'http://localhost:8080',
    health: '/actuator/health',
    api: '/api/courses',
    login: '/api/auth/login',
  },
  medical: {
    base: 'http://localhost:5170',
    health: '/api/health',
    api: '/api/patients',
    login: '/api/auth/login',
  },
  weather: {
    base: 'http://localhost:5002',
    health: '/api/health',
    api: '/api/weather/current',
    forecast: '/api/weather/forecast',
  },
  task: {
    base: 'http://localhost:8082',
    health: '/api/v1/health',
    api: '/api/v1/tasks',
    login: '/api/v1/auth/login',
  },
};

// Test data
const testUsers = [
  { email: 'test1@example.com', password: 'password123' },
  { email: 'test2@example.com', password: 'password123' },
  { email: 'test3@example.com', password: 'password123' },
];

// Main test function
export default function() {
  const testType = __ENV.TEST_TYPE || 'load';
  
  // Test Educational Platform
  testEducationalPlatform();
  
  // Test Medical Care System
  testMedicalCareSystem();
  
  // Test Weather Application
  testWeatherApplication();
  
  // Test Task Management
  testTaskManagement();
  
  sleep(1);
}

function testEducationalPlatform() {
  const baseUrl = endpoints.educational.base;
  
  // Health check
  let response = http.get(`${baseUrl}${endpoints.educational.health}`);
  check(response, {
    'Educational health check status is 200': (r) => r.status === 200,
    'Educational health response time < 100ms': (r) => r.timings.duration < 100,
  });
  errorRate.add(response.status !== 200);
  customResponseTime.add(response.timings.duration);
  
  // API endpoint test
  response = http.get(`${baseUrl}${endpoints.educational.api}`, {
    headers: { 'Content-Type': 'application/json' },
  });
  check(response, {
    'Educational API accessible': (r) => r.status === 200 || r.status === 401,
    'Educational API response time < 200ms': (r) => r.timings.duration < 200,
  });
  
  if (response.status === 200 || response.status === 401) {
    successfulRequests.add(1);
  }
  errorRate.add(response.status >= 500);
}

function testMedicalCareSystem() {
  const baseUrl = endpoints.medical.base;
  
  // Health check
  let response = http.get(`${baseUrl}${endpoints.medical.health}`);
  check(response, {
    'Medical health check status is 200': (r) => r.status === 200,
    'Medical health response time < 100ms': (r) => r.timings.duration < 100,
  });
  errorRate.add(response.status !== 200);
  customResponseTime.add(response.timings.duration);
  
  // API endpoint test
  response = http.get(`${baseUrl}${endpoints.medical.api}`, {
    headers: { 'Content-Type': 'application/json' },
  });
  check(response, {
    'Medical API accessible': (r) => r.status === 200 || r.status === 401,
    'Medical API response time < 200ms': (r) => r.timings.duration < 200,
  });
  
  if (response.status === 200 || response.status === 401) {
    successfulRequests.add(1);
  }
  errorRate.add(response.status >= 500);
}

function testWeatherApplication() {
  const baseUrl = endpoints.weather.base;
  
  // Health check
  let response = http.get(`${baseUrl}${endpoints.weather.health}`);
  check(response, {
    'Weather health check status is 200': (r) => r.status === 200,
    'Weather health response time < 100ms': (r) => r.timings.duration < 100,
  });
  errorRate.add(response.status !== 200);
  customResponseTime.add(response.timings.duration);
  
  // Weather API test
  response = http.get(`${baseUrl}${endpoints.weather.api}?city=London`, {
    headers: { 'Content-Type': 'application/json' },
  });
  check(response, {
    'Weather API accessible': (r) => r.status === 200,
    'Weather API response time < 300ms': (r) => r.timings.duration < 300,
    'Weather API returns valid JSON': (r) => {
      try {
        JSON.parse(r.body);
        return true;
      } catch (e) {
        return false;
      }
    },
  });
  
  if (response.status === 200) {
    successfulRequests.add(1);
  }
  errorRate.add(response.status >= 400);
}

function testTaskManagement() {
  const baseUrl = endpoints.task.base;
  
  // Health check
  let response = http.get(`${baseUrl}${endpoints.task.health}`);
  check(response, {
    'Task health check status is 200': (r) => r.status === 200,
    'Task health response time < 100ms': (r) => r.timings.duration < 100,
  });
  errorRate.add(response.status !== 200);
  customResponseTime.add(response.timings.duration);
  
  // Tasks API test
  response = http.get(`${baseUrl}${endpoints.task.api}`, {
    headers: { 'Content-Type': 'application/json' },
  });
  check(response, {
    'Task API accessible': (r) => r.status === 200,
    'Task API response time < 200ms': (r) => r.timings.duration < 200,
    'Task API returns valid JSON': (r) => {
      try {
        JSON.parse(r.body);
        return true;
      } catch (e) {
        return false;
      }
    },
  });
  
  if (response.status === 200) {
    successfulRequests.add(1);
  }
  errorRate.add(response.status >= 400);
}

// Teardown function
export function teardown(data) {
  console.log('Test completed successfully!');
  console.log('Custom metrics summary:');
  console.log(`- Error rate: ${errorRate.value * 100}%`);
  console.log(`- Successful requests: ${successfulRequests.value}`);
  console.log(`- Average response time: ${customResponseTime.value}ms`);
}

// Setup function for test preparation
export function setup() {
  console.log('Starting enterprise load testing suite...');
  console.log('Testing endpoints:');
  Object.keys(endpoints).forEach(app => {
    console.log(`- ${app}: ${endpoints[app].base}`);
  });
  
  return { timestamp: Date.now() };
}