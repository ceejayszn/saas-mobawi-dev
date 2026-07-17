import crypto from 'crypto';

/**
 * Generates a random 16-byte salt represented as a hex string.
 */
export function generateSalt(): string {
  return crypto.randomBytes(16).toString('hex');
}

/**
 * Hashes a password using SHA-256 HMAC with a salt.
 */
export function hashPassword(password: string, salt: string): string {
  const hmac = crypto.createHmac('sha256', salt);
  hmac.update(password);
  return hmac.digest('hex');
}

/**
 * Constant-time comparison to prevent timing attacks.
 */
export function constantTimeEquals(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let result = 0;
  for (let i = 0; i < a.length; i++) {
    result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return result === 0;
}
