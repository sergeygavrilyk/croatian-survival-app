import type { NextConfig } from "next";
import withPWAInit from "@ducanh2912/next-pwa";
import { pageCacheRules } from "./lib/pwa-cache.ts";

const withPWA = withPWAInit({
  dest: "public",
  cacheOnFrontEndNav: true,
  aggressiveFrontEndNavCaching: true,
  // Не перезавантажувати сторінку, коли мережа повертається (§76): на телефоні мережа «моргає», і перезавантаження
  // губило відповіді уроку, ще не збережені, та скасовувало перехід, який людина вже почала (причина нестабільного
  // E2E-тесту офлайну, 2026-11-16). Свіжі дані й так приходять з мережею при наступному переході.
  reloadOnOnline: false,
  disable: process.env.NODE_ENV === "development",
  // Сторінки — 30 днів і до 200 штук замість стандартних 24 годин і 32 (§76, рішення власника 2026-11-16): lib/pwa-cache.ts
  extendDefaultRuntimeCaching: true,
  workboxOptions: {
    disableDevLogs: true,
    runtimeCaching: pageCacheRules,
  },
});

// Номер збірки для браузера: інший, ніж минулого разу, — застосунок оновився, і збережені для офлайну сторінки
// треба оновити (components/OfflineRefresh.tsx, §76). Vercel — id розгортання; інакше — час збірки.
const buildId = process.env.VERCEL_DEPLOYMENT_ID || process.env.VERCEL_GIT_COMMIT_SHA || String(Date.now());

const nextConfig: NextConfig = {
  reactStrictMode: true,
  env: { NEXT_PUBLIC_BUILD_ID: buildId },
};

export default withPWA(nextConfig);