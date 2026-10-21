import Skeleton from '@/components/ui/Skeleton';

/** Поки сервер готує список уроків (або перевірки рівня) — скелет, як і раніше в client-сторінці. */
export default function Loading() {
  return (
    <div className="min-h-screen pb-28">
      <div className="mx-auto flex max-w-2xl flex-col gap-4 px-5 pt-[calc(2.5rem+env(safe-area-inset-top))] pb-4">
        <Skeleton className="h-10 w-40" />
        <Skeleton className="h-12" />
      </div>
      <div className="mx-auto flex max-w-2xl flex-col gap-4 px-5" role="status" aria-busy="true" aria-label="Завантаження уроків">
        <Skeleton className="h-20" />
        <Skeleton className="h-24" />
        <Skeleton className="h-24" />
        <Skeleton className="h-24" />
      </div>
    </div>
  );
}
