import { defineConfig, globalIgnores } from "eslint/config";
import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";

const eslintConfig = defineConfig([
  ...nextVitals,
  ...nextTs,
  // Override default ignores of eslint-config-next.
  globalIgnores([
    // Default ignores of eslint-config-next:
    ".next/**",
    "out/**",
    "build/**",
    "next-env.d.ts",
    // Згенеровані файли PWA (@ducanh2912/next-pwa пише їх у public/ під час збірки)
    "public/sw.js",
    "public/workbox-*.js",
    "public/swe-worker-*.js",
    "public/fallback-*.js",
    // Edge Functions — Deno, не Next.js
    "supabase/functions/**",
    // Заглушки типів для хмарних сесій (scripts/dev/tscheck.sh)
    "scripts/dev/tscheck/**",
    // Звіти Playwright
    "playwright-report/**",
    "test-results/**",
  ]),
]);

export default eslintConfig;
