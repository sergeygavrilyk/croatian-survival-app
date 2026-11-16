import type { NextConfig } from "next";
import withPWAInit from "@ducanh2912/next-pwa";

const withPWA = withPWAInit({
  dest: "public",
  cacheOnFrontEndNav: true,
  aggressiveFrontEndNavCaching: true,
  // Не перезавантажувати сторінку, коли мережа повертається (§76): на телефоні мережа «моргає», і перезавантаження
  // губило відповіді уроку, ще не збережені, та скасовувало перехід, який людина вже почала (причина нестабільного
  // E2E-тесту офлайну, 2026-11-16). Свіжі дані й так приходять з мережею при наступному переході.
  reloadOnOnline: false,
  disable: process.env.NODE_ENV === "development",
  workboxOptions: {
    disableDevLogs: true,
  },
});

const nextConfig: NextConfig = {
  reactStrictMode: true,
};

export default withPWA(nextConfig);