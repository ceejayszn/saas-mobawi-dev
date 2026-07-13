import rateLimit from 'express-rate-limit';

/**
 * General API rate limiter.
 * 100 requests per minute per IP.
 */
export const generalLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests. Please slow down.' },
});

/**
 * Authentication rate limiter.
 * 5 requests per minute per IP — protects login/token endpoints.
 */
export const authLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many authentication attempts. Try again later.' },
});

/**
 * Admin action limiter (deploy, restart).
 * 3 requests per minute per IP.
 */
export const adminActionLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 3,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many admin actions. Please wait.' },
});
