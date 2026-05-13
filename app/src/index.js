require('express-async-errors');
const express = require('express');
const morgan = require('morgan');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const port = process.env.PORT || 8080;

// Metrics tracking
const requestCounts = {};

// Middleware
app.use(morgan('combined'));
app.use(express.json());

// Metrics middleware
app.use((req, res, next) => {
  const route = req.path;
  const method = req.method;
  const status = res.statusCode;
  const key = `${method}:${route}:${status}`;
  requestCounts[key] = (requestCounts[key] || 0) + 1;
  next();
});

// Routes
app.get('/health', (req, res) => {
  res.status(200).json({
    status: "ok",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: "1.0.0",
    environment: process.env.NODE_ENV || "development"
  });
});

app.get('/api/items', (req, res) => {
  const items = [
    { id: 1, name: "Cloud Server", price: 29.99, category: "Compute", inStock: true },
    { id: 2, name: "Managed Database", price: 49.99, category: "Storage", inStock: true },
    { id: 3, name: "Load Balancer", price: 15.00, category: "Networking", inStock: false },
    { id: 4, name: "CDN Bucket", price: 9.99, category: "Storage", inStock: true },
    { id: 5, name: "Auto Scaler", price: 12.50, category: "Compute", inStock: true }
  ];
  res.status(200).json(items);
});

app.post('/api/items', (req, res) => {
  const { name, price } = req.body;

  if (!name || typeof name !== 'string') {
    return res.status(400).json({ error: "name is required" });
  }

  if (!price || typeof price !== 'number' || price <= 0) {
    return res.status(400).json({ error: "price must be a positive number" });
  }

  const newItem = {
    ...req.body,
    id: Date.now(),
    createdAt: new Date().toISOString()
  };

  res.status(201).json(newItem);
});

app.get('/metrics', (req, res) => {
  let output = "# HELP http_requests_total Total HTTP requests\n# TYPE http_requests_total counter\n";
  for (const [key, count] of Object.entries(requestCounts)) {
    const [method, route, status] = key.split(':');
    output += `http_requests_total{method="${method}",route="${route}",status="${status}"} ${count}\n`;
  }
  output += "\n# HELP process_uptime_seconds Process uptime\n# TYPE process_uptime_seconds gauge\n";
  output += `process_uptime_seconds ${process.uptime()}\n`;

  res.set('Content-Type', 'text/plain');
  res.status(200).send(output);
});

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ error: "Route not found", path: req.path });
});

// Global Error Handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: "Internal server error" });
});

const server = app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

module.exports = { app, server };