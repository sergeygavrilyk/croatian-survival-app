import { LessonLoading } from '@/components/lesson/LessonScreen';

/** Поки сервер готує урок — той самий індикатор, що й раніше в client-сторінці. */
export default function Loading() {
  return <LessonLoading />;
}
