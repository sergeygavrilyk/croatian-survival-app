import SongsView from '@/components/SongsView';
import { SONGS } from '@/lib/songs';

export const metadata = { title: 'Пісні · Ситуації · Croatian Survival App' };

/**
 * «Ситуації» → «Пісні»: хорватські пісні для свят і фешт (lib/songs.ts — статичний каталог, працює й офлайн).
 * Сторінка бере дані, SongsView — малює.
 */
export default function SongsPage() {
  return <SongsView songs={SONGS} />;
}
