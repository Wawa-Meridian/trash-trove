'use client';

import { useEffect } from 'react';
import { isNativeApp } from '@/lib/native';

export default function NativeInit() {
  useEffect(() => {
    if (!isNativeApp()) return;

    async function initNative() {
      // Hide splash screen after app loads
      const { SplashScreen } = await import('@capacitor/splash-screen');
      await SplashScreen.hide();

      // Set status bar style
      const { StatusBar, Style } = await import('@capacitor/status-bar');
      await StatusBar.setStyle({ style: Style.Dark });
      await StatusBar.setBackgroundColor({ color: '#c76b23' });

      // Handle Android back button
      const { App } = await import('@capacitor/app');
      App.addListener('backButton', ({ canGoBack }) => {
        if (canGoBack) {
          window.history.back();
        } else {
          App.exitApp();
        }
      });

      // Handle deep links
      App.addListener('appUrlOpen', ({ url }) => {
        const path = new URL(url).pathname;
        if (path) {
          window.location.href = path;
        }
      });
    }

    initNative().catch(console.error);
  }, []);

  return null;
}
