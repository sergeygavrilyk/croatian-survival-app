'use client';

import { useEffect } from 'react';
import { usePathname } from 'next/navigation';
import { track } from '@/lib/analytics-client';

const OPENED_KEY = 'cs_app_open_tracked';

/** Подія app_open — один раз на сесію (вкладку). Потрібна для метрик утримання D1/D7/D30 (§73). */
export default function AnalyticsSession() {
  const pathname = usePathname();

  useEffect(() => {
    try {
      if (sessionStorage.getItem(OPENED_KEY)) return;
      sessionStorage.setItem(OPENED_KEY, '1');
    } catch {
      // без sessionStorage подія може задублюватись — це прийнятно
    }
    track('app_open', { path: pathname ?? '/' });
    // лише при першому відкритті
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return null;
}
