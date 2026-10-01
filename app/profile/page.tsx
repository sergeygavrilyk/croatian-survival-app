'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import Link from 'next/link';

export default function ProfilePage() {
  const router = useRouter();
  const supabase = createClient();
  const [userEmail, setUserEmail] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState('');

  useEffect(() => {
    async function getUser() {
      const { data: { user } } = await supabase.auth.getUser();
      if (user) {
        setUserEmail(user.email ?? null);
      } else {
        router.push('/login');
      }
      setLoading(false);
    }
    getUser();
  }, [router, supabase]);

  const handleLogout = async () => {
    await supabase.auth.signOut();
    router.push('/login');
    router.refresh();
  };

  const handleResetPassword = async () => {
    if (!userEmail) return;
    const { error } = await supabase.auth.resetPasswordForEmail(userEmail, {
      redirectTo: `${window.location.origin}/reset-password`,
    });
    if (error) {
      setMessage('Помилка: ' + error.message);
    } else {
      setMessage('Лист для зміни пароля надіслано на вашу пошту!');
    }
    setTimeout(() => setMessage(''), 5000);
  };

  if (loading) {
    return <div className="min-h-screen bg-gray-50 flex justify-center items-center text-gray-400">Завантаження...</div>;
  }

  return (
    <div className="max-w-md mx-auto p-4 min-h-screen bg-gray-50">
      {/* Шапка */}
      <header className="mb-8 mt-4 flex items-center justify-between">
        <Link href="/" className="text-gray-400 hover:text-blue-500 font-medium active:scale-95 transition-transform flex items-center gap-1">
          ← Назад
        </Link>
        <h1 className="text-xl font-bold text-gray-800">Профіль</h1>
        <div className="w-16"></div> {/* Для балансу флекс-контейнера */}
      </header>

      {/* Картка користувача */}
      <div className="bg-white rounded-3xl p-6 shadow-sm border border-gray-100 mb-6 flex items-center gap-4">
        <div className="w-16 h-16 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center text-2xl font-bold">
          {userEmail ? userEmail.charAt(0).toUpperCase() : '👤'}
        </div>
        <div className="overflow-hidden">
          <p className="text-sm text-gray-500 font-medium mb-0.5">Ваш акаунт</p>
          <p className="text-gray-800 font-bold truncate">{userEmail}</p>
        </div>
      </div>

      {/* Налаштування */}
      <div className="bg-white rounded-3xl p-2 shadow-sm border border-gray-100 mb-6">
        <div className="p-4 border-b border-gray-50">
          <h3 className="text-sm font-bold text-gray-800 mb-1">Налаштування безпеки</h3>
          <p className="text-xs text-gray-500">Керування доступом до вашого акаунту</p>
        </div>
        
        <button 
          onClick={handleResetPassword}
          className="w-full text-left px-4 py-4 text-sm font-semibold text-gray-700 hover:bg-gray-50 transition-colors flex justify-between items-center"
        >
          Змінити пароль
          <span className="text-gray-400">➔</span>
        </button>
      </div>

      {message && (
        <div className="bg-green-100 text-green-700 p-4 rounded-xl text-sm mb-6 text-center animate-fade-in font-medium">
          {message}
        </div>
      )}

      {/* Небезпечна зона */}
      <div className="bg-white rounded-3xl p-2 shadow-sm border border-gray-100">
        <button 
          onClick={handleLogout}
          className="w-full px-4 py-4 text-sm font-bold text-red-500 hover:bg-red-50 rounded-2xl transition-colors flex justify-between items-center"
        >
          Вийти з акаунту
          <span>🚪</span>
        </button>
      </div>
    </div>
  );
}