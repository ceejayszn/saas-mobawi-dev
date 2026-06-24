import express from 'express';
import cors from 'cors';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Health Check
app.get('/health', async (req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.json({ status: 'healthy', database: 'connected' });
  } catch (error) {
    res.status(500).json({ status: 'unhealthy', database: 'disconnected', error });
  }
});

// Example route to get dashboard stats
app.get('/api/dashboard', async (req, res) => {
  // Mock logic for dashboard
  res.json({
    salesToday: 1500,
    expensesToday: 300,
    netPosition: 1200
  });
});

app.listen(port, () => {
  console.log(`Backend API running on port ${port}`);
});
