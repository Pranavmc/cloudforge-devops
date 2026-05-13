const request = require('supertest');
const express = require('express');

// We test the running instance or require the app if exported
// For this standalone task, supertest will reach out to the specified URL or app object.

describe('API Endpoints', () => {
  const baseUrl = 'http://localhost:8080';

  test('GET /health returns 200 with status ok', async () => {
    const response = await request(baseUrl).get('/health');
    expect(response.statusCode).toBe(200);
    expect(response.body.status).toBe('ok');
  });

  test('GET /api/items returns 200 with array of length 5', async () => {
    const response = await request(baseUrl).get('/api/items');
    expect(response.statusCode).toBe(200);
    expect(Array.isArray(response.body)).toBe(true);
    expect(response.body.length).toBe(5);
  });

  test('POST /api/items with valid body returns 201 with id field', async () => {
    const response = await request(baseUrl)
      .post('/api/items')
      .send({ name: "Pro Server", price: 199.99 });
    expect(response.statusCode).toBe(201);
    expect(response.body).toHaveProperty('id');
  });

  test('POST /api/items missing name returns 400 with error field', async () => {
    const response = await request(baseUrl)
      .post('/api/items')
      .send({ price: 199.99 });
    expect(response.statusCode).toBe(400);
    expect(response.body.error).toBe("name is required");
  });

  test('GET /nonexistent returns 404', async () => {
    const response = await request(baseUrl).get('/nonexistent');
    expect(response.statusCode).toBe(404);
  });
});
