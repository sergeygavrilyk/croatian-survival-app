'use client';

import React, { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import { motion, AnimatePresence } from 'framer-motion';

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
      setMessage('❌ Помилка: ' + error.message);
    } else {
      setMessage('✅ Лист для зміни пароля надіслано на вашу пошту!');
    }
    setTimeout(() => setMessage(''), 5000);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-50 flex justify-center items-center">
        <div className="w-10 h-10 border-4 border-indigo-200 border-t-indigo-600 rounded-full animate-spin"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-50 font-sans pb-12 overflow-x-hidden">
      
      {/* Стікі Шапка */}
      <header className="sticky top-0 z-20 backdrop-blur-2xl bg-white/70 border-b border-slate-200/50 px-6 pt-10 pb-4 shadow-sm flex items-center gap-4">
        <button 
          onClick={() => router.back()} 
          className="w-10 h-10 bg-white border border-slate-200 rounded-full flex items-center justify-center text-slate-500 hover:text-indigo-600 shadow-sm active:scale-90 transition-all"
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <h1 className="font-heading text-2xl font-black text-slate-800 tracking-tight">Профіль</h1>
      </header>

      <main className="p-6 flex flex-col gap-6">
        
        {/* Картка користувача */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-white p-6 rounded-[2rem] shadow-lg shadow-slate-200/50 border border-slate-100 flex items-center gap-5"
        >
          <div className="shrink-0 w-16 h-16 rounded-2xl bg-indigo-100 text-indigo-600 flex items-center justify-center font-heading text-3xl font-black shadow-inner">
            {userEmail ? userEmail.charAt(0).toUpperCase() : 'U'}
          </div>
          <div className="min-w-0 flex-1">
            <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-0.5">Ваш акаунт</p>
            <p className="font-bold text-slate-800 text-lg truncate">{userEmail}</p>
          </div>
        </motion.div>

        {/* Налаштування безпеки */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="bg-white rounded-[2rem] shadow-lg shadow-slate-200/50 border border-slate-100 overflow-hidden"
        >
          <div className="p-6 border-b border-slate-50">
            <h2 className="font-heading font-bold text-slate-800 text-lg">Налаштування безпеки</h2>
            <p className="text-slate-500 text-sm font-medium">Керування доступом до вашого акаунту</p>
          </div>
          
          <button 
            onClick={handleResetPassword}
            className="w-full p-6 flex justify-between items-center hover:bg-slate-50 transition-colors active:bg-slate-100"
          >
            <span className="font-bold text-slate-700">Змінити пароль</span>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-slate-400" strokeLinecap="round" strokeLinejoin="round"><path d="m9 18 6-6-6-6"/></svg>
          </button>
        </motion.div>

        {/* Спливаюче повідомлення (Toast) */}
        <AnimatePresence>
          {message && (
            <motion.div 
              initial={{ opacity: 0, height: 0, scale: 0.9 }}
              animate={{ opacity: 1, height: 'auto', scale: 1 }}
              exit={{ opacity: 0, height: 0, scale: 0.9 }}
              className={`p-4 rounded-2xl text-sm font-bold text-center shadow-sm ${
                message.includes('❌') 
                  ? 'bg-rose-50 text-rose-600 border border-rose-100' 
                  : 'bg-emerald-50 text-emerald-600 border border-emerald-100'
              }`}
            >
              {message}
            </motion.div>
          )}
        </AnimatePresence>

        {/* Кнопка виходу */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
        >
          <button 
            onClick={handleLogout}
            className="w-full bg-white p-6 rounded-[2rem] shadow-lg shadow-slate-200/50 border border-slate-100 flex justify-between items-center hover:bg-rose-50 transition-colors active:scale-[0.98] group"
          >
            <span className="font-bold text-rose-600 group-hover:text-rose-700">Вийти з акаунту</span>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-rose-400 group-hover:text-rose-600" strokeLinecap="round" strokeLinejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
          </button>
        </motion.div>
        
      </main>
    </div>
  );
}