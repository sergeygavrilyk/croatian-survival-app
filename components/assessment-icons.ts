import { Ear, Languages, MessagesSquare, Mic, type LucideIcon } from 'lucide-react';
import type { Area } from '@/lib/assessment';

/** Іконки чотирьох навичок §60 (тест і результат). */
export const AREA_ICONS: Record<Area, LucideIcon> = {
  understand: Ear,
  interact: MessagesSquare,
  mediate: Languages,
  produce: Mic,
};
