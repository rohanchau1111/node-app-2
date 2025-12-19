const express = require('express');
const os = require('os'); // Import OS module
const app = express();

// Read environment variables
const NODE_NUMBER = process.env.NODE_NUMBER || "01"; // instance suffix
const VERSION = process.env.APP_VERSION || "1.0";   // version

// Get actual system hostname
const SYSTEM_HOSTNAME = os.hostname();

// Construct display hostname
const HOSTNAME = `${SYSTEM_HOSTNAME}-Node-${NODE_NUMBER}`;

// Serve a simple Web UI
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>Web UI App</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            text-align: center;
            margin-top: 50px;
          }
          h1 { color: #2c3e50; }
          h3 { color: #16a085; }
        </style>
      </head>
      <body>
        <h1>${HOSTNAME}</h1>
        <h3>Version ${VERSION}</h3>
      </body>
    </html>
  `);
});

// Use PORT from environment or default to 3000
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Web UI running on port ${PORT}`);
});

