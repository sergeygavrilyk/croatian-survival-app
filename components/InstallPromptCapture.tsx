'use client';

import { useEffect } from 'react';
import { captureInstallPrompt } from '@/lib/install-prompt-client';

/** Кореневий layout: ловить пропозицію браузера встановити застосунок (§76, lib/install-prompt-client.ts). */
export default function InstallPromptCapture() {
  useEffect(() => captureInstallPrompt(), []);
  return null;
}
