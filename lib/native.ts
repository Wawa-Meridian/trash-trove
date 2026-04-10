/**
 * Native bridge utilities — uses Capacitor plugins when running in a native app,
 * falls back to web APIs in the browser.
 */

import { Capacitor } from '@capacitor/core';

export function isNativeApp(): boolean {
  return Capacitor.isNativePlatform();
}

export function getPlatform(): 'ios' | 'android' | 'web' {
  return Capacitor.getPlatform() as 'ios' | 'android' | 'web';
}

/**
 * Share content using native share sheet or Web Share API.
 */
export async function shareContent(data: { title: string; text?: string; url: string }) {
  if (isNativeApp()) {
    const { Share } = await import('@capacitor/share');
    await Share.share(data);
  } else if (navigator.share) {
    await navigator.share(data);
  } else {
    await navigator.clipboard.writeText(data.url);
  }
}

/**
 * Open a URL in the native browser (Safari/Chrome) or in a new tab.
 */
export async function openExternal(url: string) {
  if (isNativeApp()) {
    const { Browser } = await import('@capacitor/browser');
    await Browser.open({ url });
  } else {
    window.open(url, '_blank', 'noopener');
  }
}

/**
 * Trigger a haptic feedback tap (native only, no-op on web).
 */
export async function hapticTap() {
  if (isNativeApp()) {
    const { Haptics, ImpactStyle } = await import('@capacitor/haptics');
    await Haptics.impact({ style: ImpactStyle.Light });
  }
}
