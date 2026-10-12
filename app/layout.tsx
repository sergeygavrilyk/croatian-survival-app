import type { Metadata, Viewport } from "next";
import { Inter, Plus_Jakarta_Sans } from "next/font/google";
import "./globals.css";
import AnalyticsSession from "@/components/AnalyticsSession";
import MotionProvider from "@/components/MotionProvider";
import BottomNav from "@/components/ui/BottomNav";

// Inter — основний текст, Plus Jakarta Sans — заголовки (docs/DESIGN_SYSTEM.md §4)
const inter = Inter({ subsets: ["latin", "latin-ext", "cyrillic"], variable: "--font-inter" });
const jakarta = Plus_Jakarta_Sans({ subsets: ["latin", "latin-ext", "cyrillic-ext"], variable: "--font-jakarta" });

// Масштабування не блокуємо (§98, WCAG 1.4.4). viewportFit — для safe-area на iPhone.
export const viewport: Viewport = {
  themeColor: "#2563eb",
  width: "device-width",
  initialScale: 1,
  viewportFit: "cover",
};

export const metadata: Metadata = {
  title: "Croatian Survival App",
  description: "Вивчай хорватську мову швидко та ефективно",
  manifest: "/manifest.json",
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: "Learn HR",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="uk" className={`${inter.variable} ${jakarta.variable}`}>
      <body className="font-sans bg-canvas text-ink antialiased" suppressHydrationWarning>
        <AnalyticsSession />
        <MotionProvider>
          {children}
          <BottomNav />
        </MotionProvider>
      </body>
    </html>
  );
}
