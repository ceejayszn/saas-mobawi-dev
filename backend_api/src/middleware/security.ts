import { Request, Response, NextFunction } from 'express';
import helmet from 'helmet';
import cors from 'cors';

// --- CORS Configuration ---
// Only allow requests from known frontend origins.
const ALLOWED_ORIGINS = (process.env.ALLOWED_ORIGINS || 'http://localhost:3000')
  .split(',')
  .map((o) => o.trim());

export const corsMiddleware = cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (server-to-server, mobile apps)
    if (!origin) return callback(null, true);
    if (ALLOWED_ORIGINS.includes(origin)) {
      return callback(null, true);
    }
    callback(new Error('Not allowed by CORS'));
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-business-id'],
  credentials: true,
  maxAge: 86400, // 24 hours
});

// --- Security Headers (via Helmet) ---
export const securityHeaders = helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", 'data:', 'https:'],
    },
  },
  hsts: {
    maxAge: 31536000, // 1 year
    includeSubDomains: true,
    preload: true,
  },
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
});

// --- Request Body Size Limiter ---
// Prevents DoS via large payloads.
// Applied in index.ts via express.json({ limit: '1mb' })

// --- Request Timeout ---
export function requestTimeout(timeoutMs: number = 30000) {
  return (req: Request, res: Response, next: NextFunction) => {
    res.setTimeout(timeoutMs, () => {
      if (!res.headersSent) {
        res.status(408).json({ error: 'Request timeout.' });
      }
    });
    next();
  };
}

// --- Error Sanitizer ---
// Prevents raw error objects from leaking to clients.
export function sanitizeError(error: unknown): string {
  if (process.env.NODE_ENV === 'development') {
    return String(error);
  }
  // In production, never expose internal error details
  return 'An unexpected error occurred. Please try again later.';
}
