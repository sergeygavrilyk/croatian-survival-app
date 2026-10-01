import type { Metadata, Viewport } from "next";
import { Inter, Plus_Jakarta_Sans } from "next/font/google";
import "./globals.css";

// Підключаємо два шрифти (виправлено сабсет для Plus Jakarta Sans на cyrillic-ext)
const inter = Inter({ subsets: ["latin", "cyrillic"], variable: "--font-inter" });
const jakarta = Plus_Jakarta_Sans({ subsets: ["latin", "cyrillic-ext"], variable: "--font-jakarta" });

export const viewport: Viewport = {
  themeColor: "#3b82f6",
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false, 
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
    <html lang="uk">
      <body 
        className={`${inter.variable} ${jakarta.variable} font-sans bg-slate-50 text-slate-900 antialiased`} 
        suppressHydrationWarning
      >
        {children}
      </body>
    </html>
  );
}