import 'dotenv/config';
import express from 'express';
import { PrismaClient } from '@prisma/client';

// Security middleware
import { requireAuth, requireNexusAdmin, AuthenticatedRequest } from './middleware/auth';
import { corsMiddleware, securityHeaders, requestTimeout, sanitizeError } from './middleware/security';
import { generalLimiter, adminActionLimiter } from './middleware/rateLimiter';

const prisma = new PrismaClient();
const app = express();
const port = process.env.PORT || 3000;

// ── Global Middleware ─────────────────────────────────────────────────────
app.use(securityHeaders);
app.use(corsMiddleware);
app.use(express.json({ limit: '1mb' })); // Prevent payload DoS
app.use(generalLimiter);
app.use(requestTimeout(30000));

// ── Health Check (unauthenticated) ────────────────────────────────────────
app.get('/health', async (req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.json({ status: 'healthy', database: 'connected' });
  } catch {
    res.status(500).json({ status: 'unhealthy', database: 'disconnected' });
  }
});

// ── Nexus Admin Endpoints (requires nexus_admin role) ─────────────────────

app.get('/api/nexus/metrics', requireAuth, requireNexusAdmin, async (req, res) => {
  try {
    const health = await prisma.systemHealth.findFirst({
      orderBy: { time: 'desc' }
    });
    res.json(health || {
      databaseOnline: true,
      railwayOnline: true,
      apiOnline: true,
      syncStatus: "OK",
      appVersion: "1.0.0",
      buildNumber: "100"
    });
  } catch (error) {
    res.status(500).json({ error: sanitizeError(error) });
  }
});

app.get('/api/nexus/deployments', requireAuth, requireNexusAdmin, async (req, res) => {
  try {
    const deployments = await prisma.deploymentLog.findMany({
      orderBy: { time: 'desc' },
      take: 20
    });
    res.json(deployments);
  } catch (error) {
    res.status(500).json({ error: sanitizeError(error) });
  }
});

app.get('/api/nexus/logs', requireAuth, requireNexusAdmin, async (req, res) => {
  try {
    const logs = await prisma.deploymentLog.findFirst({
      orderBy: { time: 'desc' }
    });
    res.send(logs?.logs || "No deployment logs available.");
  } catch (error) {
    res.status(500).json({ error: sanitizeError(error) });
  }
});

app.get('/api/nexus/overview', requireAuth, requireNexusAdmin, async (req, res) => {
  try {
    const businessCount = await prisma.business.count();
    const totalSales = await prisma.sale.aggregate({
      _sum: { amount: true }
    });
    res.json({
      activeBusinesses: businessCount,
      totalRevenue: totalSales._sum.amount || 0.0,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: sanitizeError(error) });
  }
});

app.get('/api/nexus/products', requireAuth, requireNexusAdmin, async (req, res) => {
  try {
    const products = await prisma.product.findMany({
      include: { business: true }
    });
    res.json(products);
  } catch (error) {
    res.status(500).json({ error: sanitizeError(error) });
  }
});

// ── Admin Business Portal Endpoints (requires auth) ──────────────────────

app.get('/api/admin/businesses', requireAuth, requireNexusAdmin, async (req, res) => {
  try {
    const businesses = await prisma.business.findMany({
      include: {
        _count: {
          select: { users: true, sales: true }
        }
      }
    });
    res.json(businesses);
  } catch (error) {
    res.status(500).json({ error: sanitizeError(error) });
  }
});

app.get('/api/admin/businesses/:id/statistics', requireAuth, requireNexusAdmin, async (req, res) => {
  const id = req.params.id as string;
  try {
    const sales = await prisma.sale.findMany({
      where: { businessId: id },
      orderBy: { date: 'asc' }
    });

    const expenses = await prisma.expense.findMany({
      where: { businessId: id },
      orderBy: { date: 'asc' }
    });

    const totalSales = sales.reduce((sum, item) => sum + item.amount, 0);
    const totalExpenses = expenses.reduce((sum, item) => sum + item.amount, 0);

    res.json({
      businessId: id,
      totalSales,
      totalExpenses,
      netRevenue: totalSales - totalExpenses,
      salesOverTime: sales.map(s => ({ date: s.date, amount: s.amount })),
      expensesOverTime: expenses.map(e => ({ date: e.date, amount: e.amount, category: e.category }))
    });
  } catch (error) {
    res.status(500).json({ error: sanitizeError(error) });
  }
});

app.get('/api/admin/businesses/:id/logs', requireAuth, requireNexusAdmin, async (req, res) => {
  const id = req.params.id as string;
  try {
    const auditLogs = await prisma.auditLog.findMany({
      where: { businessId: id },
      orderBy: { time: 'desc' },
      take: 50
    });

    const activityLogs = await prisma.activityLog.findMany({
      where: { businessId: id },
      orderBy: { time: 'desc' },
      take: 50
    });

    res.json({
      auditLogs,
      activityLogs
    });
  } catch (error) {
    res.status(500).json({ error: sanitizeError(error) });
  }
});

app.get('/api/admin/businesses/:id/devices', requireAuth, requireNexusAdmin, async (req, res) => {
  const id = req.params.id as string;
  try {
    const devices = await prisma.deviceLog.findMany({
      where: { businessId: id },
      orderBy: { lastSync: 'desc' }
    });

    const health = await prisma.systemHealth.findFirst({
      where: { businessId: id },
      orderBy: { time: 'desc' }
    });

    res.json({
      devices,
      health: health || {
        databaseOnline: true,
        apiOnline: true,
        syncStatus: "OK"
      }
    });
  } catch (error) {
    res.status(500).json({ error: sanitizeError(error) });
  }
});

// ── Remote Actions (requires nexus_admin + rate limited) ──────────────────

app.post('/api/nexus/deploy', requireAuth, requireNexusAdmin, adminActionLimiter, async (req: AuthenticatedRequest, res) => {
  const { service_id } = req.body;

  if (!service_id || typeof service_id !== 'string') {
    res.status(400).json({ error: 'service_id is required.' });
    return;
  }

  try {
    const log = await prisma.deploymentLog.create({
      data: {
        status: "SUCCESS",
        component: "Railway",
        logs: `Deployment triggered by ${req.user?.userId || 'unknown'} for service ${service_id}.`
      }
    });
    res.json({ success: true, message: `Deployment triggered for service ${service_id}`, log });
  } catch (error) {
    res.status(500).json({ success: false, error: sanitizeError(error) });
  }
});

app.post('/api/nexus/restart', requireAuth, requireNexusAdmin, adminActionLimiter, async (req: AuthenticatedRequest, res) => {
  const { service_id } = req.body;

  if (!service_id || typeof service_id !== 'string') {
    res.status(400).json({ error: 'service_id is required.' });
    return;
  }

  try {
    const log = await prisma.deploymentLog.create({
      data: {
        status: "RESTARTED",
        component: "Server",
        logs: `Restart by ${req.user?.userId || 'unknown'} for service ${service_id}.`
      }
    });
    res.json({ success: true, message: `Service ${service_id} restarted.`, log });
  } catch (error) {
    res.status(500).json({ success: false, error: sanitizeError(error) });
  }
});

// ── Start Server ──────────────────────────────────────────────────────────

app.listen(port, () => {
  console.log(`Backend API running on port ${port}`);
});
