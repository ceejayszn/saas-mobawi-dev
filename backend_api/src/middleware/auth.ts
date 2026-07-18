import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || '';

export interface AuthenticatedRequest extends Request {
  user?: {
    userId: string;
    businessId: string;
    role: 'admin' | 'manager' | 'cashier' | 'nexus_admin';
  };
}

import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * JWT authentication middleware.
 * Verifies the Bearer token and attaches decoded user info to the request.
 * Rejects with 401 if token is missing, expired, or invalid.
 * Rejects with 403 if the business is suspended.
 */
export async function requireAuth(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({ error: 'Authentication required. Provide a Bearer token.' });
    return;
  }

  const token = authHeader.slice(7);

  if (!JWT_SECRET) {
    console.error('FATAL: JWT_SECRET is not configured. All auth requests will be rejected.');
    res.status(500).json({ error: 'Server configuration error.' });
    return;
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET) as {
      userId: string;
      businessId: string;
      role: string;
    };

    req.user = {
      userId: decoded.userId,
      businessId: decoded.businessId,
      role: decoded.role as 'admin' | 'manager' | 'cashier' | 'nexus_admin',
    };

    if (req.user.role !== 'nexus_admin') {
      const business = await prisma.business.findUnique({
        where: { id: req.user.businessId },
        select: { status: true }
      });
      if (business && business.status === 'SUSPENDED') {
        res.status(403).json({ error: 'Subscription Locked. Contact Mobawi Nexus Administration.' });
        return;
      }
    }

    next();
  } catch (err) {
    if (err instanceof jwt.TokenExpiredError) {
      res.status(401).json({ error: 'Token expired. Please re-authenticate.' });
    } else if (err instanceof jwt.JsonWebTokenError) {
      res.status(401).json({ error: 'Invalid token.' });
    } else {
      res.status(401).json({ error: 'Authentication failed.' });
    }
  }
}

/**
 * Requires the authenticated user to have the 'nexus_admin' role.
 * Must be used AFTER requireAuth.
 */
export function requireNexusAdmin(req: AuthenticatedRequest, res: Response, next: NextFunction): void {
  if (!req.user || req.user.role !== 'nexus_admin') {
    res.status(403).json({ error: 'Forbidden. Nexus admin access required.' });
    return;
  }
  next();
}

/**
 * Extracts businessId from JWT claims for tenant-scoped queries.
 * Prevents URL parameter spoofing by enforcing JWT-based tenant resolution.
 */
export function getBusinessIdFromToken(req: AuthenticatedRequest): string | null {
  return req.user?.businessId || null;
}
