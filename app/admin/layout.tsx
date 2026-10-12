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
    <div className="min-h-screen bg-slate-50 font-sans">
      <nav className="bg-slate-900 text-white p-4 shadow-md flex justify-between items-center">
        <h1 className="font-bold tracking-widest uppercase">🇭🇷 Croatian Survival CMS</h1>
        <a href="/" className="text-slate-400 hover:text-white text-sm">Повернутися в додаток</a>
      </nav>
      {children}
    </div>
  );
}