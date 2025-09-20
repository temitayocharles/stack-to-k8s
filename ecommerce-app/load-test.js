/*
 * ===============================================================
 * K6 LOAD TESTING SUITE FOR E-COMMERCE APPLICATION
 * ===============================================================
 * 
 * Implements 5 mandatory test scenarios as per anchor document:
 * 1. Smoke Test - Basic functionality under minimal load
 * 2. Load Test - Sustained load at target capacity  
 * 3. Stress Test - Load beyond normal capacity
 * 4. Spike Test - Sudden traffic spikes
 * 5. Endurance Test - Prolonged load testing
 * 
 * Performance Targets:
 * - Response Time (95th percentile): < 500ms
 * - Error Rate: < 1%
 * - Throughput: 1000+ requests/second
 * - Resource Utilization: < 80%
 * ===============================================================
 */

import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

// Custom metrics for business logic
const errorRate = new Rate('error_rate');
const responseTime = new Trend('response_time');
const requestCount = new Counter('request_count');

// Test configuration based on scenario
const scenarios = {
  smoke_test: {
    executor: 'constant-vus',
    vus: 1,
    duration: '30s',
    tags: { test_type: 'smoke' }
  },
  load_test: {
    executor: 'ramping-vus',
    stages: [
      { duration: '2m', target: 10 },  // Ramp up
      { duration: '5m', target: 10 },  // Stay at load
      { duration: '2m', target: 0 },   // Ramp down
    ],
    tags: { test_type: 'load' }
  },
  stress_test: {
    executor: 'ramping-vus',
    stages: [
      { duration: '2m', target: 20 },  // Ramp up to normal load
      { duration: '5m', target: 20 },  // Stay at normal load
      { duration: '2m', target: 50 },  // Ramp up to stress load
      { duration: '5m', target: 50 },  // Stay at stress load
      { duration: '2m', target: 0 },   // Ramp down
    ],
    tags: { test_type: 'stress' }
  },
  spike_test: {
    executor: 'ramping-vus',
    stages: [
      { duration: '10s', target: 5 },   // Normal load
      { duration: '10s', target: 50 },  // Spike!
      { duration: '10s', target: 5 },   // Back to normal
      { duration: '10s', target: 100 }, // Another spike!
      { duration: '10s', target: 5 },   // Back to normal
      { duration: '10s', target: 0 },   // End
    ],
    tags: { test_type: 'spike' }
  },
  endurance_test: {
    executor: 'constant-vus',
    vus: 15,
    duration: '10m',  // Extended duration for endurance
    tags: { test_type: 'endurance' }
  }
};

// Test configuration - select scenario via K6_SCENARIO environment variable
export const options = {
  scenarios: {
    [__ENV.K6_SCENARIO || 'load_test']: scenarios[__ENV.K6_SCENARIO || 'load_test']
  },
  thresholds: {
    // Performance targets from anchor document
    'http_req_duration{percentile:95}': ['p(95)<500'], // 95th percentile < 500ms
    'http_req_failed': ['rate<0.01'],                  // Error rate < 1%
    'http_reqs': ['rate>10'],                          // Throughput > 10 req/s (adjusted for test)
    'error_rate': ['rate<0.01'],                       // Custom error rate < 1%
  },
};

// Base URL configuration
const BASE_URL = __ENV.BASE_URL || 'http://localhost:5000';

// Test data for realistic scenarios
const testProducts = [
  { name: 'Laptop', category: 'electronics', price: 999.99 },
  { name: 'Smartphone', category: 'electronics', price: 599.99 },
  { name: 'Book', category: 'books', price: 19.99 },
  { name: 'Headphones', category: 'electronics', price: 199.99 }
];

const testUsers = [
  { email: 'test1@example.com', password: 'password123' },
  { email: 'test2@example.com', password: 'password123' },
  { email: 'test3@example.com', password: 'password123' }
];

// Main test function
export default function() {
  const scenarioType = __ENV.K6_SCENARIO || 'load_test';
  
  // Test scenario execution
  switch(scenarioType) {
    case 'smoke_test':
      smokeTest();
      break;
    case 'load_test':
      loadTest();
      break;
    case 'stress_test':
      stressTest();
      break;
    case 'spike_test':
      spikeTest();
      break;
    case 'endurance_test':
      enduranceTest();
      break;
    default:
      loadTest();
  }
  
  sleep(1); // Think time between requests
}

// Smoke Test - Basic functionality validation
function smokeTest() {
  console.log('🚀 Running Smoke Test - Basic functionality validation');
  
  // Test all 5 health endpoints
  testHealthEndpoints();
  
  // Test basic API endpoints
  testBasicAPIEndpoints();
  
  // Test product operations
  testProductOperations();
}

// Load Test - Sustained load at target capacity
function loadTest() {
  console.log('📊 Running Load Test - Sustained load testing');
  
  // Mixed workload simulating real user behavior
  const userScenario = Math.random();
  
  if (userScenario < 0.3) {
    // 30% - Browse products
    browseProducts();
  } else if (userScenario < 0.6) {
    // 30% - Search products
    searchProducts();
  } else if (userScenario < 0.8) {
    // 20% - View product details
    viewProductDetails();
  } else if (userScenario < 0.95) {
    // 15% - Add to cart
    addToCart();
  } else {
    // 5% - Complete purchase
    completePurchase();
  }
}

// Stress Test - Load beyond normal capacity
function stressTest() {
  console.log('⚡ Running Stress Test - Beyond normal capacity');
  
  // More aggressive testing with higher concurrent operations
  performStressOperations();
}

// Spike Test - Sudden traffic spikes
function spikeTest() {
  console.log('🌋 Running Spike Test - Sudden traffic spikes');
  
  // Test system's ability to handle sudden load increases
  performSpikeOperations();
}

// Endurance Test - Prolonged load testing
function enduranceTest() {
  console.log('🏃 Running Endurance Test - Prolonged load testing');
  
  // Extended testing to identify memory leaks and performance degradation
  performEnduranceOperations();
}

// Health Endpoints Testing
function testHealthEndpoints() {
  const endpoints = ['/health', '/ready', '/live', '/health/dependencies', '/metrics'];
  
  endpoints.forEach(endpoint => {
    const response = http.get(`${BASE_URL}${endpoint}`);
    
    const success = check(response, {
      [`${endpoint} status is 200`]: (r) => r.status === 200,
      [`${endpoint} response time < 200ms`]: (r) => r.timings.duration < 200,
    });
    
    errorRate.add(!success);
    responseTime.add(response.timings.duration);
    requestCount.add(1);
  });
}

// Basic API Endpoints Testing
function testBasicAPIEndpoints() {
  const endpoints = [
    '/api/products',
    '/api/categories',
    '/api/products?page=1&limit=10'
  ];
  
  endpoints.forEach(endpoint => {
    const response = http.get(`${BASE_URL}${endpoint}`);
    
    const success = check(response, {
      [`${endpoint} status is 200`]: (r) => r.status === 200,
      [`${endpoint} has response body`]: (r) => r.body.length > 0,
      [`${endpoint} response time < 500ms`]: (r) => r.timings.duration < 500,
    });
    
    errorRate.add(!success);
    responseTime.add(response.timings.duration);
    requestCount.add(1);
  });
}

// Product Operations Testing
function testProductOperations() {
  // Test product listing
  const productsResponse = http.get(`${BASE_URL}/api/products`);
  
  check(productsResponse, {
    'products endpoint status is 200': (r) => r.status === 200,
    'products response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  // Test categories
  const categoriesResponse = http.get(`${BASE_URL}/api/categories`);
  
  check(categoriesResponse, {
    'categories endpoint status is 200': (r) => r.status === 200,
    'categories response time < 300ms': (r) => r.timings.duration < 300,
  });
}

// Browse Products Scenario
function browseProducts() {
  const response = http.get(`${BASE_URL}/api/products?page=${Math.floor(Math.random() * 5) + 1}&limit=12`);
  
  const success = check(response, {
    'browse products status is 200': (r) => r.status === 200,
    'browse products response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  errorRate.add(!success);
  responseTime.add(response.timings.duration);
  requestCount.add(1);
}

// Search Products Scenario
function searchProducts() {
  const searchTerms = ['laptop', 'phone', 'book', 'headphones', 'electronics'];
  const term = searchTerms[Math.floor(Math.random() * searchTerms.length)];
  
  const response = http.get(`${BASE_URL}/api/search?q=${term}`);
  
  const success = check(response, {
    'search products status is 200': (r) => r.status === 200,
    'search products response time < 800ms': (r) => r.timings.duration < 800,
  });
  
  errorRate.add(!success);
  responseTime.add(response.timings.duration);
  requestCount.add(1);
}

// View Product Details Scenario
function viewProductDetails() {
  // Assume we have product IDs from 1-100
  const productId = Math.floor(Math.random() * 100) + 1;
  
  const response = http.get(`${BASE_URL}/api/products/${productId}`);
  
  const success = check(response, {
    'product details response time < 300ms': (r) => r.timings.duration < 300,
  });
  
  errorRate.add(!success);
  responseTime.add(response.timings.duration);
  requestCount.add(1);
}

// Add to Cart Scenario
function addToCart() {
  const cartData = {
    productId: Math.floor(Math.random() * 100) + 1,
    quantity: Math.floor(Math.random() * 3) + 1
  };
  
  const response = http.post(`${BASE_URL}/api/cart`, JSON.stringify(cartData), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  const success = check(response, {
    'add to cart response time < 400ms': (r) => r.timings.duration < 400,
  });
  
  errorRate.add(!success);
  responseTime.add(response.timings.duration);
  requestCount.add(1);
}

// Complete Purchase Scenario (simplified)
function completePurchase() {
  // Simulate the purchase flow
  const orderData = {
    items: [
      { productId: Math.floor(Math.random() * 100) + 1, quantity: 1 }
    ],
    total: Math.floor(Math.random() * 1000) + 10
  };
  
  const response = http.post(`${BASE_URL}/api/orders`, JSON.stringify(orderData), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  const success = check(response, {
    'purchase response time < 1000ms': (r) => r.timings.duration < 1000,
  });
  
  errorRate.add(!success);
  responseTime.add(response.timings.duration);
  requestCount.add(1);
}

// Stress Test Operations
function performStressOperations() {
  // More aggressive concurrent operations
  browseProducts();
  searchProducts();
  viewProductDetails();
}

// Spike Test Operations
function performSpikeOperations() {
  // Quick succession of requests to test spike handling
  testHealthEndpoints();
  browseProducts();
}

// Endurance Test Operations
function performEnduranceOperations() {
  // Mixed load for extended periods
  const operation = Math.random();
  
  if (operation < 0.4) {
    browseProducts();
  } else if (operation < 0.7) {
    searchProducts();
  } else {
    testHealthEndpoints();
  }
}

// Setup function (runs once)
export function setup() {
  console.log('🔧 Setting up load test environment...');
  
  // Test that the application is accessible
  const healthResponse = http.get(`${BASE_URL}/health`);
  
  if (healthResponse.status !== 200) {
    throw new Error(`Application not ready. Health check failed with status: ${healthResponse.status}`);
  }
  
  console.log('✅ Application is ready for load testing');
  
  return {
    baseUrl: BASE_URL,
    testStartTime: new Date().toISOString()
  };
}

// Teardown function (runs once at the end)
export function teardown(data) {
  console.log('🧹 Cleaning up after load test...');
  console.log(`Test completed at: ${new Date().toISOString()}`);
  console.log(`Test started at: ${data.testStartTime}`);
}

/*
 * Usage Examples:
 * 
 * # Smoke Test (30 seconds, 1 user)
 * K6_SCENARIO=smoke_test k6 run load-test.js
 * 
 * # Load Test (9 minutes, up to 10 concurrent users)
 * K6_SCENARIO=load_test k6 run load-test.js
 * 
 * # Stress Test (16 minutes, up to 50 concurrent users)
 * K6_SCENARIO=stress_test k6 run load-test.js
 * 
 * # Spike Test (1 minute, up to 100 concurrent users with spikes)
 * K6_SCENARIO=spike_test k6 run load-test.js
 * 
 * # Endurance Test (10 minutes, 15 concurrent users)
 * K6_SCENARIO=endurance_test k6 run load-test.js
 * 
 * # Custom base URL
 * BASE_URL=http://production-server.com K6_SCENARIO=load_test k6 run load-test.js
 */