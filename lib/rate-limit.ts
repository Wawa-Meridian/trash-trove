interface RateLimitEntry {
  count: number;
  expiresAt: number;
}

const store = new Map<string, RateLimitEntry>();

// Periodically clean up expired entries to prevent memory leaks
let cleanupScheduled = false;

function scheduleCleanup() {
  if (cleanupScheduled) return;
  cleanupScheduled = true;

  setTimeout(() => {
    const now = Date.now();
    for (const [key, entry] of store) {
      if (entry.expiresAt <= now) {
        store.delete(key);
      }
    }
    cleanupScheduled = false;
  }, 60_000); // Clean up every 60 seconds
}

export function rateLimit(
  key: string,
  limit: number,
  windowMs: number
): { success: boolean; remaining: number } {
  const now = Date.now();
  const entry = store.get(key);

  // If no entry or entry has expired, create a new window
  if (!entry || entry.expiresAt <= now) {
    store.set(key, { count: 1, expiresAt: now + windowMs });
    scheduleCleanup();
    return { success: true, remaining: limit - 1 };
  }

  // Increment count within the existing window
  const updatedCount = entry.count + 1;

  if (updatedCount > limit) {
    return { success: false, remaining: 0 };
  }

  store.set(key, { count: updatedCount, expiresAt: entry.expiresAt });
  return { success: true, remaining: limit - updatedCount };
}
