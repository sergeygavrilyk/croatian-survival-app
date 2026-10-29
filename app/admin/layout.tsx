import Link from 'next/link';
import { redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  // Адмін — за таблицею app_admins (міграція M3, §124), а не за email.
  // Ту саму перевірку робить база (RLS), тож обійти її з браузера не вийде.
  const { data: isAdmin, error } = await supabase.rpc('is_admin');
  if (error || isAdmin !== true) {
    redirect('/');
  }

  return (
    <div className="min-h-screen bg-canvas font-sans">
      <nav className="flex items-center justify-between gap-3 border-b border-line bg-surface px-4 py-3 shadow-sm sm:px-6">
        <p className="font-heading text-h3">
          <span aria-hidden="true">🛠️</span> Croatian Survival CMS
        </p>
        <Link href="/" className="flex min-h-11 items-center rounded-control px-3 text-label text-primary-ink hover:bg-primary-soft">
          Повернутися в додаток
        </Link>
      </nav>
      {children}
    </div>
  );
}
