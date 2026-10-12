'use client';

import React, { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { useRouter } from 'next/navigation';
import { normalizeCroatian } from '@/lib/srs';

const CEFR_LEVELS = ['A0', 'A1', 'A2', 'B1', 'B2'];
const PARTS_OF_SPEECH: [string, string][] = [
  ['noun', 'Іменник'], ['verb', 'Дієслово'], ['adjective', 'Прикметник'], ['adverb', 'Прислівник'],
  ['pronoun', 'Займенник'], ['preposition', 'Прийменник'], ['conjunction', 'Сполучник'],
  ['particle', 'Частка'], ['numeral', 'Числівник'], ['phrase', 'Вираз / фраза'],
];

export default function AdminDashboard() {
  const supabase = createClient();
  const router = useRouter();

  // Стейт для перемикання вкладок
  const [activeTab, setActiveTab] = useState<'vocabulary' | 'curriculum'>('curriculum');

  // ==========================================
  // СТЕЙТИ ТА ЛОГІКА ДЛЯ СЛОВНИКА (Ваш оригінальний код)
  // ==========================================
  const [words, setWords] = useState<any[]>([]);
  const [loadingWords, setLoadingWords] = useState(false);
  const [newWord, setNewWord] = useState({
    hr_text: '',
    ua_translation: '',
    part_of_speech: 'noun',
    cefr: 'A1',
    details_forms: '',
    details_examples: ''
  });

  useEffect(() => {
    if (activeTab === 'vocabulary') fetchWords();
  }, [activeTab]);

  const fetchWords = async () => {
    setLoadingWords(true);
    const { data } = await supabase
      .from('lexemes')
      .select('id, lemma, ukrainian_translation, part_of_speech, cefr, forms, examples, status')
      .order('created_at', { ascending: false })
      .limit(50);
      
    if (data) setWords(data);
    setLoadingWords(false);
  };

  const handleAddWord = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newWord.hr_text || !newWord.ua_translation) return;

    const cleanHrText = newWord.hr_text.trim();

    // Лема унікальна без урахування регістру (індекс unique_lower_lemma)
    const { data: existingWords } = await supabase
      .from('lexemes')
      .select('id, lemma, ukrainian_translation')
      .ilike('lemma', cleanHrText);

    if (existingWords && existingWords.length > 0) {
      alert(`⚠️ Слово "${existingWords[0].lemma}" вже є в базі (переклад: ${existingWords[0].ukrainian_translation}).`);
      return;
    }

    const inflections = newWord.details_forms ? newWord.details_forms.split(',').map(s => s.trim()).filter(Boolean) : [];
    const examples = newWord.details_examples ? newWord.details_examples.split('|').map(s => s.trim()).filter(Boolean) : [];

    const { error } = await supabase.from('lexemes').insert([{
      lemma: cleanHrText,
      normalized: normalizeCroatian(cleanHrText),
      ukrainian_translation: newWord.ua_translation.trim(),
      part_of_speech: newWord.part_of_speech,
      cefr: newWord.cefr,
      vocabulary_type: newWord.part_of_speech === 'phrase' ? 'chunk' : 'core',
      forms: inflections.length > 0 ? { inflections } : {},
      examples,
      // Слово вносить адмін вручну (не AI), тому одразу PUBLISHED.
      // AI-батчі отримують AI_GENERATED за замовчуванням і йдуть через перевірку (§64).
      status: 'PUBLISHED',
      source: 'admin_manual',
    }]);

    if (error) {
      alert('Помилка при додаванні: ' + error.message);
    } else {
      alert('Слово успішно додано!');
      setNewWord({ ...newWord, hr_text: '', ua_translation: '', details_forms: '', details_examples: '' });
      fetchWords();
    }
  };

  // ==========================================
  // СТЕЙТИ ТА ЛОГІКА ДЛЯ CURRICULUM CMS (Новий код)
  // ==========================================
  const [levels, setLevels] = useState<any[]>([]);
  const [modules, setModules] = useState<any[]>([]);
  const [units, setUnits] = useState<any[]>([]);
  const [lessons, setLessons] = useState<any[]>([]);

  const [selectedLevel, setSelectedLevel] = useState<string | null>(null);
  const [selectedModule, setSelectedModule] = useState<string | null>(null);
  const [selectedUnit, setSelectedUnit] = useState<string | null>(null);

  const [loadingCurriculum, setLoadingCurriculum] = useState(true);
  const [isAdding, setIsAdding] = useState<'module' | 'unit' | 'lesson' | null>(null);
  const [newItemTitle, setNewItemTitle] = useState('');

  useEffect(() => {
    if (activeTab === 'curriculum') fetchLevels();
  }, [activeTab]);

  const fetchLevels = async () => {
    setLoadingCurriculum(true);
    const { data } = await supabase.from('levels').select('*').order('order_index');
    if (data) setLevels(data);
    setLoadingCurriculum(false);
  };

  const fetchModules = async (levelCode: string) => {
    const { data } = await supabase.from('modules').select('*').eq('level_code', levelCode).order('order_index');
    if (data) setModules(data);
  };

  const fetchUnits = async (moduleId: string) => {
    const { data } = await supabase.from('units').select('*').eq('module_id', moduleId).order('order_index');
    if (data) setUnits(data);
  };

  const fetchLessons = async (unitId: string) => {
    const { data } = await supabase.from('lessons').select('*').eq('unit_id', unitId).order('order_index').order('created_at');
    if (data) setLessons(data);
  };

  const handleLevelSelect = (code: string) => {
    setSelectedLevel(code);
    setSelectedModule(null);
    setSelectedUnit(null);
    setUnits([]);
    setLessons([]);
    fetchModules(code);
  };

  const handleModuleSelect = (id: string) => {
    setSelectedModule(id);
    setSelectedUnit(null);
    setLessons([]);
    fetchUnits(id);
  };

  const handleUnitSelect = (id: string) => {
    setSelectedUnit(id);
    fetchLessons(id);
  };

  const handleCreateCurriculumItem = async () => {
    if (!newItemTitle.trim()) return;

    try {
      if (isAdding === 'module' && selectedLevel) {
        await supabase.from('modules').insert({
          level_code: selectedLevel,
          title_ua: newItemTitle,
          order_index: modules.length + 1
        });
        fetchModules(selectedLevel);
      } 
      else if (isAdding === 'unit' && selectedModule) {
        await supabase.from('units').insert({
          module_id: selectedModule,
          title_ua: newItemTitle,
          order_index: units.length + 1
        });
        fetchUnits(selectedModule);
      } 
      else if (isAdding === 'lesson' && selectedUnit && selectedLevel) {
        await supabase.from('lessons').insert({
          unit_id: selectedUnit,
          level_code: selectedLevel,
          title_ua: newItemTitle,
          status: 'DRAFT'
        });
        fetchLessons(selectedUnit);
      }
    } catch (error) {
      console.error('Помилка створення:', error);
    } finally {
      setIsAdding(null);
      setNewItemTitle('');
    }
  };

  // ==========================================
  // РЕНДЕР ІНТЕРФЕЙСУ
  // ==========================================
  return (
    <div className="min-h-screen bg-slate-50 p-6">
      <header className="mb-6 flex flex-col md:flex-row md:justify-between md:items-center max-w-7xl mx-auto gap-4">
        <div>
          <h1 className="text-3xl font-bold text-slate-900">Адмін-панель</h1>
          <p className="text-slate-500 mt-1">Управління контентом та структурою</p>
        </div>
        
        {/* Навігація вкладок */}
        <div className="flex bg-white p-1 rounded-xl shadow-sm border border-slate-200 w-fit">
          <button 
            onClick={() => setActiveTab('curriculum')} 
            className={`px-6 py-2 rounded-lg font-medium text-sm transition-all ${activeTab === 'curriculum' ? 'bg-blue-600 text-white shadow' : 'text-slate-600 hover:bg-slate-50'}`}
          >
            Структура (Уроки)
          </button>
          <button 
            onClick={() => setActiveTab('vocabulary')} 
            className={`px-6 py-2 rounded-lg font-medium text-sm transition-all ${activeTab === 'vocabulary' ? 'bg-blue-600 text-white shadow' : 'text-slate-600 hover:bg-slate-50'}`}
          >
            Словник (Слова)
          </button>
        </div>

        <button onClick={() => router.push('/')} className="text-sm font-medium text-blue-600 hover:text-blue-800 bg-blue-50 px-4 py-2 rounded-xl transition-colors">
          На дашборд
        </button>
      </header>

      {/* Вкладка 1: CURRICULUM CMS */}
      {activeTab === 'curriculum' && (
        <div className="max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-4 gap-6 animate-fade-in-up">
          {/* КОЛОНКА 1: РІВНІ */}
          <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-4 h-[75vh] overflow-y-auto">
            <h2 className="text-sm font-bold text-slate-400 uppercase tracking-wider mb-4 px-2">1. Рівень CEFR</h2>
            {loadingCurriculum ? <div className="p-4 text-slate-400">Завантаження...</div> : (
              <div className="space-y-2">
                {levels.map(lvl => (
                  <button
                    key={lvl.code}
                    onClick={() => handleLevelSelect(lvl.code)}
                    className={`w-full text-left px-4 py-3 rounded-xl transition-all font-medium ${
                      selectedLevel === lvl.code ? 'bg-blue-600 text-white shadow-md' : 'hover:bg-slate-50 text-slate-700'
                    }`}
                  >
                    <div className="text-lg">{lvl.code}</div>
                    <div className={`text-xs ${selectedLevel === lvl.code ? 'text-blue-200' : 'text-slate-500'}`}>{lvl.title_ua}</div>
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* КОЛОНКА 2: МОДУЛІ */}
          <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-4 h-[75vh] overflow-y-auto relative">
            <h2 className="text-sm font-bold text-slate-400 uppercase tracking-wider mb-4 px-2">2. Модулі</h2>
            {!selectedLevel ? (
              <p className="text-sm text-slate-400 text-center mt-10">Оберіть рівень</p>
            ) : (
              <div className="space-y-2 pb-16">
                {modules.map(mod => (
                  <button
                    key={mod.id}
                    onClick={() => handleModuleSelect(mod.id)}
                    className={`w-full text-left px-4 py-3 rounded-xl transition-all text-sm font-medium border ${
                      selectedModule === mod.id ? 'bg-indigo-50 border-indigo-200 text-indigo-700' : 'bg-white border-slate-100 hover:border-slate-300 text-slate-700'
                    }`}
                  >
                    {mod.order_index}. {mod.title_ua}
                  </button>
                ))}
                {isAdding === 'module' ? (
                  <div className="mt-2 flex gap-2">
                    <input autoFocus value={newItemTitle} onChange={e => setNewItemTitle(e.target.value)} placeholder="Назва модуля..." className="w-full text-sm px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500" />
                    <button onClick={handleCreateCurriculumItem} className="bg-blue-600 text-white px-3 rounded-lg text-sm font-bold">✓</button>
                    <button onClick={() => setIsAdding(null)} className="bg-slate-100 text-slate-500 px-3 rounded-lg text-sm font-bold">✕</button>
                  </div>
                ) : (
                  <button onClick={() => setIsAdding('module')} className="w-full mt-2 py-3 border-2 border-dashed border-slate-200 text-slate-500 rounded-xl text-sm font-medium hover:border-blue-400 hover:text-blue-600 transition-colors">
                    + Додати модуль
                  </button>
                )}
              </div>
            )}
          </div>

          {/* КОЛОНКА 3: ЮНІТИ */}
          <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-4 h-[75vh] overflow-y-auto relative">
            <h2 className="text-sm font-bold text-slate-400 uppercase tracking-wider mb-4 px-2">3. Юніти</h2>
            {!selectedModule ? (
              <p className="text-sm text-slate-400 text-center mt-10">Оберіть модуль</p>
            ) : (
              <div className="space-y-2 pb-16">
                {units.map(unit => (
                  <button
                    key={unit.id}
                    onClick={() => handleUnitSelect(unit.id)}
                    className={`w-full text-left px-4 py-3 rounded-xl transition-all text-sm font-medium border ${
                      selectedUnit === unit.id ? 'bg-amber-50 border-amber-200 text-amber-700' : 'bg-white border-slate-100 hover:border-slate-300 text-slate-700'
                    }`}
                  >
                    {unit.title_ua}
                  </button>
                ))}
                {isAdding === 'unit' ? (
                  <div className="mt-2 flex gap-2">
                    <input autoFocus value={newItemTitle} onChange={e => setNewItemTitle(e.target.value)} placeholder="Назва юніту..." className="w-full text-sm px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500" />
                    <button onClick={handleCreateCurriculumItem} className="bg-blue-600 text-white px-3 rounded-lg text-sm font-bold">✓</button>
                    <button onClick={() => setIsAdding(null)} className="bg-slate-100 text-slate-500 px-3 rounded-lg text-sm font-bold">✕</button>
                  </div>
                ) : (
                  <button onClick={() => setIsAdding('unit')} className="w-full mt-2 py-3 border-2 border-dashed border-slate-200 text-slate-500 rounded-xl text-sm font-medium hover:border-blue-400 hover:text-blue-600 transition-colors">
                    + Додати юніт
                  </button>
                )}
              </div>
            )}
          </div>

          {/* КОЛОНКА 4: УРОКИ */}
          <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-4 h-[75vh] overflow-y-auto relative">
            <h2 className="text-sm font-bold text-slate-400 uppercase tracking-wider mb-4 px-2">4. Уроки</h2>
            {!selectedUnit ? (
              <p className="text-sm text-slate-400 text-center mt-10">Оберіть юніт</p>
            ) : (
              <div className="space-y-2 pb-16">
                {lessons.map(lesson => (
                  <div key={lesson.id} className="w-full text-left px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 text-slate-700 flex justify-between items-center">
                    <span className="text-sm font-medium truncate pr-2">{lesson.title_ua}</span>
                    <span className={`text-[10px] px-2 py-1 rounded-full font-bold ${lesson.status === 'PUBLISHED' ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-200 text-slate-500'}`}>
                      {lesson.status}
                    </span>
                  </div>
                ))}
                {isAdding === 'lesson' ? (
                  <div className="mt-2 flex gap-2">
                    <input autoFocus value={newItemTitle} onChange={e => setNewItemTitle(e.target.value)} placeholder="Назва уроку..." className="w-full text-sm px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500" />
                    <button onClick={handleCreateCurriculumItem} className="bg-blue-600 text-white px-3 rounded-lg text-sm font-bold">✓</button>
                    <button onClick={() => setIsAdding(null)} className="bg-slate-100 text-slate-500 px-3 rounded-lg text-sm font-bold">✕</button>
                  </div>
                ) : (
                  <button onClick={() => setIsAdding('lesson')} className="w-full mt-2 py-3 border-2 border-dashed border-slate-200 text-slate-500 rounded-xl text-sm font-medium hover:border-blue-400 hover:text-blue-600 transition-colors">
                    + Створити урок
                  </button>
                )}
              </div>
            )}
          </div>
        </div>
      )}

      {/* Вкладка 2: VOCABULARY (Ваш оригінальний код) */}
      {activeTab === 'vocabulary' && (
        <div className="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-3 gap-8 mt-2 animate-fade-in-up">
          <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-200 h-fit">
            <h2 className="text-xl font-bold text-slate-800 mb-6">Додати нове слово</h2>
            <form onSubmit={handleAddWord} className="flex flex-col gap-4">
              <div>
                <label className="block text-xs font-bold text-slate-500 uppercase mb-1">Хорватською (lemma)*</label>
                <input required type="text" value={newWord.hr_text} onChange={e => setNewWord({...newWord, hr_text: e.target.value})} className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3" placeholder="напр. račun" />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-500 uppercase mb-1">Українською*</label>
                <input required type="text" value={newWord.ua_translation} onChange={e => setNewWord({...newWord, ua_translation: e.target.value})} className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3" placeholder="напр. рахунок" />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-500 uppercase mb-1">Частина мови</label>
                  <select value={newWord.part_of_speech} onChange={e => setNewWord({...newWord, part_of_speech: e.target.value})} className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3 text-sm">
                    {PARTS_OF_SPEECH.map(([value, label]) => <option key={value} value={value}>{label}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-500 uppercase mb-1">Рівень</label>
                  <select value={newWord.cefr} onChange={e => setNewWord({...newWord, cefr: e.target.value})} className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3 text-sm">
                    {CEFR_LEVELS.map(level => <option key={level} value={level}>{level}</option>)}
                  </select>
                </div>
              </div>
              
              <div className="pt-4 border-t border-slate-100">
                <label className="block text-xs font-bold text-slate-500 uppercase mb-1">Інші форми (через кому)</label>
                <input type="text" value={newWord.details_forms} onChange={e => setNewWord({...newWord, details_forms: e.target.value})} className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3" placeholder="računi, računa..." />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-500 uppercase mb-1">Приклади (через | )</label>
                <textarea value={newWord.details_examples} onChange={e => setNewWord({...newWord, details_examples: e.target.value})} className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3 min-h-[100px]" placeholder="Mogu li dobiti račun? | Račun je 15 eura." />
              </div>
              
              <button type="submit" className="mt-4 bg-slate-900 hover:bg-slate-800 text-white font-bold py-4 rounded-xl shadow-md transition-all active:scale-95">
                Зберегти слово
              </button>
            </form>
          </div>

          <div className="md:col-span-2">
            <h2 className="text-xl font-bold text-slate-800 mb-6">Останні додані слова</h2>
            {loadingWords ? (
              <div className="animate-pulse flex flex-col gap-3">
                {[1,2,3].map(i => <div key={i} className="h-16 bg-slate-200 rounded-xl"></div>)}
              </div>
            ) : (
              <div className="flex flex-col gap-3">
                {words.map((word) => (
                  <div key={word.id} className="bg-white p-4 rounded-xl shadow-sm border border-slate-200 flex justify-between items-start">
                    <div>
                      <h3 className="font-bold text-lg text-slate-900">{word.lemma}</h3>
                      <p className="text-sm text-blue-600 font-medium">{word.ukrainian_translation}</p>
                      
                      <div className="mt-2 text-xs flex flex-wrap gap-2">
                        {word.cefr && <span className="bg-blue-50 text-blue-700 px-2 py-1 rounded">{word.cefr}</span>}
                        {word.part_of_speech && <span className="bg-slate-100 text-slate-600 px-2 py-1 rounded">{word.part_of_speech}</span>}
                        {word.forms?.inflections?.length > 0 && <span className="bg-slate-100 text-slate-600 px-2 py-1 rounded">Форми: {word.forms.inflections.length}</span>}
                        {word.examples?.length > 0 && <span className="bg-slate-100 text-slate-600 px-2 py-1 rounded">Приклади: {word.examples.length}</span>}
                        {word.status && word.status !== 'PUBLISHED' && <span className="bg-amber-50 text-amber-700 px-2 py-1 rounded">{word.status}</span>}
                      </div>
                    </div>
                    <div className="text-[10px] text-slate-400 font-mono text-right max-w-[100px] truncate" title={word.id}>
                      ID: {word.id.substring(0,8)}...
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}