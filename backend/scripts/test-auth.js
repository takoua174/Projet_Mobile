#!/usr/bin/env node

/**
 * Script to test authentication endpoints
 * Usage: node scripts/test-auth.js
 */

const API_URL = 'http://localhost:3000';

const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
};

async function makeRequest(method, endpoint, data = null, token = null) {
  const url = `${API_URL}${endpoint}`;
  const headers = {
    'Content-Type': 'application/json',
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const options = {
    method,
    headers,
  };

  if (data) {
    options.body = JSON.stringify(data);
  }

  try {
    const response = await fetch(url, options);
    const json = await response.json();
    return { status: response.status, data: json };
  } catch (error) {
    return { status: 0, error: error.message };
  }
}

async function testRegister() {
  console.log(`\n${colors.blue}Testing Registration...${colors.reset}`);
  
  const testUser = {
    email: `test${Date.now()}@example.com`,
    username: `testuser${Date.now()}`,
    password: 'Test123!@#',
  };

  const result = await makeRequest('POST', '/auth/register', testUser);
  
  if (result.status === 201) {
    console.log(`${colors.green}✓ Registration successful${colors.reset}`);
    console.log(`  Token: ${result.data.data.access_token.substring(0, 20)}...`);
    return { token: result.data.data.access_token, email: testUser.email, password: testUser.password };
  } else {
    console.log(`${colors.red}✗ Registration failed${colors.reset}`);
    console.log(`  Status: ${result.status}`);
    console.log(`  Message: ${JSON.stringify(result.data)}`);
    return null;
  }
}

async function testLogin(email, password) {
  console.log(`\n${colors.blue}Testing Login...${colors.reset}`);
  
  const result = await makeRequest('POST', '/auth/login', { email, password });
  
  if (result.status === 200) {
    console.log(`${colors.green}✓ Login successful${colors.reset}`);
    console.log(`  Token: ${result.data.data.access_token.substring(0, 20)}...`);
    return result.data.data.access_token;
  } else {
    console.log(`${colors.red}✗ Login failed${colors.reset}`);
    console.log(`  Status: ${result.status}`);
    console.log(`  Message: ${JSON.stringify(result.data)}`);
    return null;
  }
}

async function testGetProfile(token) {
  console.log(`\n${colors.blue}Testing Get Profile...${colors.reset}`);
  
  const result = await makeRequest('GET', '/auth/me', null, token);
  
  if (result.status === 200) {
    console.log(`${colors.green}✓ Get profile successful${colors.reset}`);
    console.log(`  User: ${JSON.stringify(result.data.data)}`);
    return true;
  } else {
    console.log(`${colors.red}✗ Get profile failed${colors.reset}`);
    console.log(`  Status: ${result.status}`);
    console.log(`  Message: ${JSON.stringify(result.data)}`);
    return false;
  }
}

async function testVerifyToken(token) {
  console.log(`\n${colors.blue}Testing Token Verification...${colors.reset}`);
  
  const result = await makeRequest('GET', '/auth/verify', null, token);
  
  if (result.status === 200) {
    console.log(`${colors.green}✓ Token verification successful${colors.reset}`);
    console.log(`  Valid: ${result.data.data.valid}`);
    return true;
  } else {
    console.log(`${colors.red}✗ Token verification failed${colors.reset}`);
    console.log(`  Status: ${result.status}`);
    return false;
  }
}

async function testInvalidLogin() {
  console.log(`\n${colors.blue}Testing Invalid Login...${colors.reset}`);
  
  const result = await makeRequest('POST', '/auth/login', {
    email: 'invalid@example.com',
    password: 'WrongPassword123!',
  });
  
  if (result.status === 401) {
    console.log(`${colors.green}✓ Invalid login correctly rejected${colors.reset}`);
    return true;
  } else {
    console.log(`${colors.red}✗ Invalid login test failed${colors.reset}`);
    console.log(`  Expected status 401, got ${result.status}`);
    return false;
  }
}

async function runTests() {
  console.log(`${colors.yellow}==================================${colors.reset}`);
  console.log(`${colors.yellow}Authentication API Test Suite${colors.reset}`);
  console.log(`${colors.yellow}==================================${colors.reset}`);
  console.log(`\nAPI URL: ${API_URL}`);

  let passed = 0;
  let failed = 0;

  // Test 1: Register
  const registerResult = await testRegister();
  if (registerResult) {
    passed++;

    // Test 2: Login
    const loginToken = await testLogin(registerResult.email, registerResult.password);
    if (loginToken) {
      passed++;

      // Test 3: Get Profile
      if (await testGetProfile(loginToken)) passed++;
      else failed++;

      // Test 4: Verify Token
      if (await testVerifyToken(loginToken)) passed++;
      else failed++;
    } else {
      failed++;
    }
  } else {
    failed++;
  }

  // Test 5: Invalid Login
  if (await testInvalidLogin()) passed++;
  else failed++;

  // Summary
  console.log(`\n${colors.yellow}==================================${colors.reset}`);
  console.log(`${colors.yellow}Test Results${colors.reset}`);
  console.log(`${colors.yellow}==================================${colors.reset}`);
  console.log(`${colors.green}Passed: ${passed}${colors.reset}`);
  console.log(`${colors.red}Failed: ${failed}${colors.reset}`);
  console.log(`Total: ${passed + failed}`);
  
  if (failed === 0) {
    console.log(`\n${colors.green}✓ All tests passed!${colors.reset}\n`);
  } else {
    console.log(`\n${colors.red}✗ Some tests failed${colors.reset}\n`);
  }
}

// Check if server is running
fetch(`${API_URL}/auth/verify`)
  .then(() => runTests())
  .catch(() => {
    console.log(`${colors.red}Error: Cannot connect to server at ${API_URL}${colors.reset}`);
    console.log(`${colors.yellow}Make sure the server is running: npm run start:dev${colors.reset}`);
  });
