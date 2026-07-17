const http = require('http');

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/auth/login',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  }
};

const loginData = JSON.stringify({
  username: 'felixpinski_boss',
  password: '123456'
});

const req = http.request(options, (res) => {
  let body = '';
  res.on('data', (chunk) => body += chunk);
  res.on('end', () => {
    if (res.statusCode !== 200) {
      console.error('Login failed during stress test setup:', body);
      process.exit(1);
    }
    const token = JSON.parse(body).token;
    console.log('Authentication successful. Token obtained. Commencing 500 concurrent requests...');
    runStress(token);
  });
});

req.on('error', (e) => {
  console.error('Connection to local API failed:', e);
});
req.write(loginData);
req.end();

function runStress(token) {
  const totalRequests = 500;
  let completed = 0;
  let successCount = 0;
  let failCount = 0;
  const start = Date.now();

  for (let i = 0; i < totalRequests; i++) {
    const getOptions = {
      hostname: 'localhost',
      port: 3000,
      path: '/api/reports/summary',
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    };

    const requestStart = Date.now();
    const req = http.request(getOptions, (res) => {
      let responseBody = '';
      res.on('data', (chunk) => responseBody += chunk);
      res.on('end', () => {
        completed++;
        if (res.statusCode === 200) {
          successCount++;
        } else {
          failCount++;
          if (failCount <= 5) {
            console.log(`Failed request status: ${res.statusCode}. Body: ${responseBody}`);
          }
        }
        checkFinish(completed, totalRequests, successCount, failCount, start);
      });
    });

    req.on('error', (err) => {
      completed++;
      failCount++;
      if (failCount <= 5) {
        console.log(`Request error: ${err.message}`);
      }
      checkFinish(completed, totalRequests, successCount, failCount, start);
    });
    req.end();
  }
}

function checkFinish(completed, total, success, fails, startTime) {
  if (completed === total) {
    const elapsed = Date.now() - startTime;
    console.log('====================================================');
    console.log('             STRESS TEST RESULTS (RC-1)');
    console.log('====================================================');
    console.log(`Total Requests Sent : ${total}`);
    console.log(`Successful Requests : ${success}`);
    console.log(`Failed Requests     : ${fails}`);
    console.log(`Total Time Elapsed  : ${elapsed} ms`);
    console.log(`Average Latency     : ${(elapsed / total).toFixed(2)} ms`);
    console.log(`Requests / Sec      : ${(total / (elapsed / 1000)).toFixed(2)}`);
    console.log('====================================================');
    process.exit(0);
  }
}
