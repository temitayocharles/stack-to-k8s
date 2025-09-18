import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const taskCreationTrend = new Trend('task_creation_duration');
const taskRetrievalTrend = new Trend('task_retrieval_duration');
const userCreationTrend = new Trend('user_creation_duration');

// Test configuration
export const options = {
  scenarios: {
    // Smoke test - basic functionality
    smoke_test: {
      executor: 'constant-vus',
      vus: 1,
      duration: '30s',
      tags: { test_type: 'smoke' },
    },

    // Load test - increasing load
    load_test: {
      executor: 'ramping-vus',
      stages: [
        { duration: '1m', target: 10 },   // Ramp up to 10 users
        { duration: '3m', target: 50 },   // Ramp up to 50 users
        { duration: '2m', target: 100 },  // Ramp up to 100 users
        { duration: '1m', target: 100 },  // Stay at 100 users
        { duration: '1m', target: 0 },    // Ramp down to 0
      ],
      tags: { test_type: 'load' },
    },

    // Stress test - maximum capacity
    stress_test: {
      executor: 'ramping-vus',
      stages: [
        { duration: '2m', target: 200 },  // Ramp up to 200 users
        { duration: '5m', target: 200 },  // Stay at 200 users
        { duration: '2m', target: 0 },    // Ramp down
      ],
      tags: { test_type: 'stress' },
    },

    // Spike test - sudden traffic spikes
    spike_test: {
      executor: 'ramping-vus',
      stages: [
        { duration: '10s', target: 10 },   // Normal load
        { duration: '10s', target: 200 },  // Spike to 200 users
        { duration: '10s', target: 10 },   // Back to normal
        { duration: '10s', target: 200 },  // Another spike
        { duration: '10s', target: 10 },   // Back to normal
      ],
      tags: { test_type: 'spike' },
    },

    // Endurance test - sustained load
    endurance_test: {
      executor: 'constant-vus',
      vus: 50,
      duration: '10m',
      tags: { test_type: 'endurance' },
    },
  },

  thresholds: {
    // HTTP request duration should be < 500ms for 95% of requests
    http_req_duration: ['p(95)<500'],

    // Error rate should be < 1%
    http_req_failed: ['rate<0.01'],

    // Custom error rate
    errors: ['rate<0.05'],
  },
};

// Base URL configuration
const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
const API_BASE = `${BASE_URL}/api/v1`;

// Test data
const testUsers = [];
const testTasks = [];

// Setup function - runs before the test starts
export function setup() {
  console.log('🚀 Starting Task Management Load Test');
  console.log(`📍 Target URL: ${BASE_URL}`);

  // Create test users for the test
  for (let i = 0; i < 10; i++) {
    const user = {
      username: `testuser_${i}_${Date.now()}`,
      email: `testuser_${i}_${Date.now()}@example.com`,
      role: 'user'
    };

    const response = http.post(`${API_BASE}/users`, JSON.stringify(user), {
      headers: { 'Content-Type': 'application/json' },
    });

    if (response.status === 201) {
      testUsers.push(JSON.parse(response.body));
    }
  }

  console.log(`✅ Created ${testUsers.length} test users`);

  return { users: testUsers };
}

// Teardown function - runs after the test completes
export function teardown(data) {
  console.log('🧹 Cleaning up test data...');

  // Clean up test tasks
  testTasks.forEach(task => {
    http.del(`${API_BASE}/tasks/${task.id}`);
  });

  // Clean up test users
  data.users.forEach(user => {
    // Note: In a real scenario, you might want to clean up users too
    // But for now, we'll leave them for debugging purposes
  });

  console.log('✅ Test cleanup completed');
}

// Main test function
export default function (data) {
  const user = data.users[Math.floor(Math.random() * data.users.length)];

  // Health check
  const healthResponse = http.get(`${API_BASE}/health`);
  check(healthResponse, {
    'health check status is 200': (r) => r.status === 200,
    'health check response time < 200ms': (r) => r.timings.duration < 200,
  }) || errorRate.add(1);

  // Test task creation
  const taskData = {
    title: `Load Test Task ${Date.now()}`,
    description: `Description for load test task created at ${new Date().toISOString()}`,
    status: 'todo',
    priority: 'medium',
    assignee_id: user.id
  };

  const createStart = new Date().getTime();
  const createResponse = http.post(`${API_BASE}/tasks`, JSON.stringify(taskData), {
    headers: { 'Content-Type': 'application/json' },
  });
  const createDuration = new Date().getTime() - createStart;

  taskCreationTrend.add(createDuration);

  const createSuccess = check(createResponse, {
    'task creation status is 201': (r) => r.status === 201,
    'task creation response time < 1000ms': (r) => r.timings.duration < 1000,
    'task has id': (r) => {
      try {
        const task = JSON.parse(r.body);
        if (task.id) {
          testTasks.push(task);
          return true;
        }
      } catch (e) {
        return false;
      }
      return false;
    },
  });

  if (!createSuccess) {
    errorRate.add(1);
  }

  sleep(Math.random() * 2 + 0.5); // Random sleep between 0.5-2.5s

  // Test task retrieval
  if (testTasks.length > 0) {
    const randomTask = testTasks[Math.floor(Math.random() * testTasks.length)];

    const retrieveStart = new Date().getTime();
    const retrieveResponse = http.get(`${API_BASE}/tasks/${randomTask.id}`);
    const retrieveDuration = new Date().getTime() - retrieveStart;

    taskRetrievalTrend.add(retrieveDuration);

    check(retrieveResponse, {
      'task retrieval status is 200': (r) => r.status === 200,
      'task retrieval response time < 500ms': (r) => r.timings.duration < 500,
    }) || errorRate.add(1);
  }

  sleep(Math.random() * 1 + 0.5); // Random sleep between 0.5-1.5s

  // Test user creation (less frequent)
  if (Math.random() < 0.1) { // 10% chance
    const newUser = {
      username: `loaduser_${Date.now()}_${Math.random()}`,
      email: `loaduser_${Date.now()}_${Math.random()}@example.com`,
      role: 'user'
    };

    const userCreateStart = new Date().getTime();
    const userResponse = http.post(`${API_BASE}/users`, JSON.stringify(newUser), {
      headers: { 'Content-Type': 'application/json' },
    });
    const userCreateDuration = new Date().getTime() - userCreateStart;

    userCreationTrend.add(userCreateDuration);

    check(userResponse, {
      'user creation status is 201': (r) => r.status === 201,
      'user creation response time < 1000ms': (r) => r.timings.duration < 1000,
    }) || errorRate.add(1);
  }

  sleep(Math.random() * 3 + 1); // Random sleep between 1-4s
}

// Handle summary - custom summary output
export function handleSummary(data) {
  const summary = {
    'stdout': textSummary(data, { indent: ' ', enableColors: true }),
    'summary.json': JSON.stringify(data, null, 2),
    'metrics.json': JSON.stringify({
      metrics: data.metrics,
      thresholds: data.thresholds,
    }, null, 2),
  };

  // Generate HTML report
  summary['report.html'] = generateHTMLReport(data);

  return summary;
}

function generateHTMLReport(data) {
  return `
<!DOCTYPE html>
<html>
<head>
    <title>Task Management Load Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .metric { background: #f5f5f5; padding: 10px; margin: 10px 0; border-radius: 5px; }
        .success { color: green; }
        .warning { color: orange; }
        .error { color: red; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>🚀 Task Management Load Test Report</h1>
    <p><strong>Generated:</strong> ${new Date().toISOString()}</p>
    <p><strong>Target URL:</strong> ${BASE_URL}</p>

    <h2>📊 Test Results Summary</h2>
    <div class="metric">
        <h3>HTTP Request Duration</h3>
        <p>Average: ${Math.round(data.metrics.http_req_duration.values.avg)}ms</p>
        <p>95th percentile: ${Math.round(data.metrics.http_req_duration.values['p(95)'])}ms</p>
        <p>99th percentile: ${Math.round(data.metrics.http_req_duration.values['p(99)'])}ms</p>
    </div>

    <div class="metric">
        <h3>Request Rate</h3>
        <p>Total requests: ${data.metrics.http_reqs.values.count}</p>
        <p>Failed requests: ${Math.round(data.metrics.http_req_failed.values.rate * 100)}%</p>
    </div>

    <div class="metric">
        <h3>Custom Metrics</h3>
        <p>Task creation avg: ${Math.round(data.metrics.task_creation_duration.values.avg)}ms</p>
        <p>Task retrieval avg: ${Math.round(data.metrics.task_retrieval_duration.values.avg)}ms</p>
        <p>Error rate: ${Math.round(data.metrics.errors.values.rate * 100)}%</p>
    </div>

    <h2>📈 Detailed Metrics</h2>
    <table>
        <tr><th>Metric</th><th>Value</th><th>Threshold</th><th>Status</th></tr>
        ${Object.entries(data.thresholds).map(([key, threshold]) => `
            <tr>
                <td>${key}</td>
                <td>${threshold.ok ? '✅' : '❌'}</td>
                <td>${JSON.stringify(threshold)}</td>
                <td class="${threshold.ok ? 'success' : 'error'}">${threshold.ok ? 'PASS' : 'FAIL'}</td>
            </tr>
        `).join('')}
    </table>

    <h2>🔍 Recommendations</h2>
    <ul>
        ${data.metrics.http_req_duration.values['p(95)'] > 500 ? '<li class="warning">⚠️ Consider optimizing response times (95th percentile > 500ms)</li>' : ''}
        ${data.metrics.http_req_failed.values.rate > 0.01 ? '<li class="error">❌ High error rate detected - investigate failures</li>' : ''}
        ${data.metrics.errors.values.rate > 0.05 ? '<li class="warning">⚠️ Custom error rate is high - check application logs</li>' : ''}
        <li class="success">✅ Load test completed successfully</li>
    </ul>
</body>
</html>`;
}

function textSummary(data, options) {
  return `
🚀 Task Management Load Test Results
=====================================

📊 Summary:
- Total Requests: ${data.metrics.http_reqs.values.count}
- Failed Requests: ${Math.round(data.metrics.http_req_failed.values.rate * 100)}%
- Average Response Time: ${Math.round(data.metrics.http_req_duration.values.avg)}ms
- 95th Percentile: ${Math.round(data.metrics.http_req_duration.values['p(95)'])}ms

🎯 Custom Metrics:
- Task Creation Avg: ${Math.round(data.metrics.task_creation_duration.values.avg)}ms
- Task Retrieval Avg: ${Math.round(data.metrics.task_retrieval_duration.values.avg)}ms
- Error Rate: ${Math.round(data.metrics.errors.values.rate * 100)}%

📈 Threshold Results:
${Object.entries(data.thresholds).map(([key, threshold]) =>
  `- ${key}: ${threshold.ok ? '✅ PASS' : '❌ FAIL'}`
).join('\n')}

🔍 Recommendations:
${data.metrics.http_req_duration.values['p(95)'] > 500 ? '⚠️ Consider optimizing response times\n' : ''}
${data.metrics.http_req_failed.values.rate > 0.01 ? '❌ Investigate failed requests\n' : ''}
${data.metrics.errors.values.rate > 0.05 ? '⚠️ Check application logs for errors\n' : ''}
✅ Load test completed
`;
}