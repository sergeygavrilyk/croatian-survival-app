'use client';

import { MotionConfig } from 'framer-motion';

/** framer-motion поважає системне «Зменшити рух» (docs/DESIGN_SYSTEM.md §6). */
export default function MotionProvider({ children }: { children: React.ReactNode }) {
  return <MotionConfig reducedMotion="user">{children}</MotionConfig>;
}
