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

const nextConfig: NextConfig = {
  reactStrictMode: true,
};

export default withPWA(nextConfig);