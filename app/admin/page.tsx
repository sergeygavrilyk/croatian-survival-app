'use client';

import React, { useCallback, useEffect, useState } from 'react';
import { Check, CircleAlert, CircleCheck, Plus, X } from 'lucide-react';
import { createClient } from '@/utils/supabase/client';
import { normalizeCroatian } from '@/lib/srs';
import Button from '@/components/ui/Button';
import Card from '@/components/ui/Card';
import Hr from '@/components/ui/Hr';
import IconButton from '@/components/ui/IconButton';
import LevelBadge from '@/components/ui/LevelBadge';
import Skeleton from '@/components/ui/Skeleton';
import { levelStyle, moduleIcon } from '@/lib/levels';
import {
  DEFAULT_LABELS, REGIONS, REGION_LABELS, REGISTERS, REGISTER_LABELS, USAGE_TAGS, USAGE_TAG_LABELS, toggleTag, validateLabels,
  type LexemeLabels, type Region, type Register,
} from '@/lib/lexeme-labels';
import { cn } from '@/lib/ui';

const CEFR_LEVELS = ['A0', 'A1', 'A2', 'B1', 'B2'];
const PARTS_OF_SPEECH: [string, string][] = [
  ['noun', 'Іменник'], ['verb', 'Дієслово'], ['adjective', 'Прикметник'], ['adverb', 'Прислівник'],
  ['pronoun', 'Займенник'], ['preposition', 'Прийменник'], ['conjunction', 'Сполучник'],
  ['particle', 'Частка'], ['numeral', 'Числівник'], ['phrase', 'Вираз / фраза'],
];

interface AdminWord {
  id: string;
  lemma: string;
  ukrainian_translation: string | null;
  part_of_speech: string | null;
  cefr: string | null;
  forms: { inflections?: string[] } | null;
  examples: unknown[] | null;
  status: string | null;
}
interface LevelRow { code: string; title_ua: string | null }
interface ModuleRow { id: string; title_ua: string; title_hr?: string | null; order_index: number }
interface UnitRow { id: string; title_ua: string }
interface LessonRow { id: string; title_ua: string; status: string }

export default function AdminDashboard() {
  // Один клієнт на весь час роботи сторінки (інакше useCallback нижче змінювався б щоразу)
  const [supabase] = useState(() => createClient());
  // Повідомлення замість alert() (не блокує сторінку, видно поруч із формою)
  const [notice, setNotice] = useState<{ ok: boolean; text: string } | null>(null);

  // Стейт для перемикання вкладок
  const [activeTab, setActiveTab] = useState<'vocabulary' | 'curriculum'>('curriculum');

  // ==========================================
  // СТЕЙТИ ТА ЛОГІКА ДЛЯ СЛОВНИКА (Ваш оригінальний код)
  // ==========================================
  const [words, setWords] = useState<AdminWord[]>([]);
  const [loadingWords, setLoadingWords] = useState(false);
  const [newWord, setNewWord] = useState({
    hr_text: '',
    ua_translation: '',
    part_of_speech: 'noun',
    cefr: 'A1',
    details_forms: '',
    details_examples: ''
  });
  // Мітки слова (LEARNING_SPEC §18): з M25 обов'язкові — звичайне слово «стандартне» / «загальне» / без ознак
  const [newLabels, setNewLabels] = useState<LexemeLabels>(DEFAULT_LABELS);

  // Стан змінюємо лише після відповіді бази; «завантаження…» вмикає обробник вкладки (openTab)
  const fetchWords = useCallback(async () => {
    const { data } = await supabase
      .from('lexemes')
      .select('id, lemma, ukrainian_translation, part_of_speech, cefr, forms, examples, status')
      .order('created_at', { ascending: false })
      .limit(50);

    if (data) setWords(data as AdminWord[]);
    setLoadingWords(false);
  }, [supabase]);


  const handleAddWord = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newWord.hr_text || !newWord.ua_translation) return;

    const cleanHrText = newWord.hr_text.trim();
    const labelErrors = validateLabels(newLabels);
    if (labelErrors.length > 0) {
      setNotice({ ok: false, text: labelErrors.join(' ') });
      return;
    }

    // Лема унікальна без урахування регістру (індекс unique_lower_lemma)
    const { data: existingWords } = await supabase
      .from('lexemes')
      .select('id, lemma, ukrainian_translation')
      .ilike('lemma', cleanHrText);

    if (existingWords && existingWords.length > 0) {
      setNotice({ ok: false, text: `Слово «${existingWords[0].lemma}» вже є в базі (переклад: ${existingWords[0].ukrainian_translation}).` });
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
      register: newLabels.register,
      regionality: newLabels.regionality,
      usage_tags: newLabels.usage_tags,
      // Слово вносить адмін вручну (не AI), тому одразу PUBLISHED.
      // AI-батчі отримують AI_GENERATED за замовчуванням і йдуть через перевірку (§64).
      status: 'PUBLISHED',
      source: 'admin_manual',
    }]);

    if (error) {
      setNotice({ ok: false, text: 'Помилка при додаванні: ' + error.message });
    } else {
      setNotice({ ok: true, text: `Слово «${cleanHrText}» додано!` });
      setNewWord({ ...newWord, hr_text: '', ua_translation: '', details_forms: '', details_examples: '' });
      setNewLabels(DEFAULT_LABELS);
      fetchWords();
    }
  };

  // ==========================================
  // СТЕЙТИ ТА ЛОГІКА ДЛЯ CURRICULUM CMS (Новий код)
  // ==========================================
  const [levels, setLevels] = useState<LevelRow[]>([]);
  const [modules, setModules] = useState<ModuleRow[]>([]);
  const [units, setUnits] = useState<UnitRow[]>([]);
  const [lessons, setLessons] = useState<LessonRow[]>([]);

  const [selectedLevel, setSelectedLevel] = useState<string | null>(null);
  const [selectedModule, setSelectedModule] = useState<string | null>(null);
  const [selectedUnit, setSelectedUnit] = useState<string | null>(null);

  const [loadingCurriculum, setLoadingCurriculum] = useState(true);
  const [isAdding, setIsAdding] = useState<'module' | 'unit' | 'lesson' | null>(null);
  const [newItemTitle, setNewItemTitle] = useState('');

  const fetchLevels = useCallback(async () => {
    const { data } = await supabase.from('levels').select('*').order('order_index');
    if (data) setLevels(data as LevelRow[]);
    setLoadingCurriculum(false);
  }, [supabase]);

  // Початкова вкладка — «Структура»: рівні одразу (loadingCurriculum уже true). Стан — лише в колбеці
  // відповіді (react-hooks/set-state-in-effect); перемикання вкладок завантажує в обробнику openTab.
  useEffect(() => {
    let cancelled = false;
    supabase
      .from('levels')
      .select('*')
      .order('order_index')
      .then(({ data }) => {
        if (cancelled) return;
        if (data) setLevels(data as LevelRow[]);
        setLoadingCurriculum(false);
      });
    return () => {
      cancelled = true;
    };
  }, [supabase]);

  const openTab = (tab: 'vocabulary' | 'curriculum') => {
    setActiveTab(tab);
    if (tab === 'vocabulary') {
      setLoadingWords(true);
      void fetchWords();
    } else {
      setLoadingCurriculum(true);
      void fetchLevels();
    }
  };

  const fetchModules = async (levelCode: string) => {
    const { data } = await supabase.from('modules').select('*').eq('level_code', levelCode).order('order_index');
    if (data) setModules(data as ModuleRow[]);
  };

  const fetchUnits = async (moduleId: string) => {
    const { data } = await supabase.from('units').select('*').eq('module_id', moduleId).order('order_index');
    if (data) setUnits(data as UnitRow[]);
  };

  const fetchLessons = async (unitId: string) => {
    const { data } = await supabase.from('lessons').select('*').eq('unit_id', unitId).order('order_index').order('created_at');
    if (data) setLessons(data as LessonRow[]);
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
  // РЕНДЕР ІНТЕРФЕЙСУ (дизайн-система: токени, примітиви, колір рівня й емодзі модуля — DESIGN_SYSTEM §3.4)
  // ==========================================
  const levelCode = selectedLevel ?? '';
  const lv = levelStyle(levelCode);
  const tabClass = (active: boolean) =>
    cn(
      'min-h-11 flex-1 rounded-control px-4 text-label transition-colors duration-150 sm:flex-none',
      active ? 'bg-surface text-ink shadow-sm' : 'text-ink-muted hover:text-ink',
    );
  const fieldClass =
    'min-h-12 w-full rounded-control border border-line bg-surface px-4 text-body focus:border-primary focus:outline-none';
  const labelClass = 'mb-1 block text-label text-ink-muted';

  const addForm = (placeholder: string) => (
    <div className="mt-2 flex items-center gap-1">
      <input
        autoFocus
        value={newItemTitle}
        onChange={(e) => setNewItemTitle(e.target.value)}
        onKeyDown={(e) => {
          if (e.key === 'Enter') void handleCreateCurriculumItem();
          if (e.key === 'Escape') setIsAdding(null);
        }}
        placeholder={placeholder}
        aria-label={placeholder}
        className="min-h-11 min-w-0 flex-1 rounded-control border border-line bg-surface px-3 text-body focus:border-primary focus:outline-none"
      />
      <IconButton label="Зберегти" onClick={() => void handleCreateCurriculumItem()} className="bg-primary text-white hover:bg-primary-hover hover:text-white">
        <Check className="size-5" aria-hidden="true" />
      </IconButton>
      <IconButton label="Скасувати" onClick={() => setIsAdding(null)}>
        <X className="size-5" aria-hidden="true" />
      </IconButton>
    </div>
  );

  const addButton = (kind: 'module' | 'unit' | 'lesson', text: string) => (
    <button
      type="button"
      onClick={() => setIsAdding(kind)}
      className="mt-2 flex min-h-12 w-full items-center justify-center gap-2 rounded-card border-2 border-dashed border-line text-label text-ink-muted transition-colors duration-150 hover:border-primary hover:text-primary-ink"
    >
      <Plus className="size-4" aria-hidden="true" />
      {text}
    </button>
  );

  const column = (title: string, children: React.ReactNode) => (
    <Card className="h-[75vh] overflow-y-auto p-4">
      <h2 className="mb-3 px-1 text-label text-ink-subtle">{title}</h2>
      {children}
    </Card>
  );

  const hint = (text: string) => <p className="mt-10 text-center text-body text-ink-subtle">{text}</p>;

  return (
    <div className="min-h-screen bg-canvas px-4 py-6 sm:px-6">
      <header className="mx-auto mb-6 flex max-w-7xl flex-col gap-4 md:flex-row md:items-center md:justify-between">
        <div>
          <h1 className="font-heading text-h1">
            <span aria-hidden="true">🛠️</span> Адмін-панель
          </h1>
          <p className="mt-1 text-body text-ink-muted">Управління контентом та структурою</p>
        </div>

        {/* Вкладки */}
        <div className="flex w-full rounded-control bg-surface-muted p-1 sm:w-fit" aria-label="Розділ адмінки">
          <button type="button" aria-pressed={activeTab === 'curriculum'} onClick={() => openTab('curriculum')} className={tabClass(activeTab === 'curriculum')}>
            <span aria-hidden="true">🗂️</span> Структура (уроки)
          </button>
          <button type="button" aria-pressed={activeTab === 'vocabulary'} onClick={() => openTab('vocabulary')} className={tabClass(activeTab === 'vocabulary')}>
            <span aria-hidden="true">📚</span> Словник (слова)
          </button>
        </div>
      </header>

      {/* Вкладка 1: структура програми */}
      {activeTab === 'curriculum' && (
        <div className="mx-auto grid max-w-7xl grid-cols-1 gap-4 animate-fade-in-up lg:grid-cols-4">
          {/* 1. Рівні */}
          {column(
            '1. Рівень CEFR',
            loadingCurriculum ? (
              <div className="flex flex-col gap-2">
                {[1, 2, 3].map((i) => (
                  <Skeleton key={i} className="h-16" />
                ))}
              </div>
            ) : (
              <div className="flex flex-col gap-2">
                {levels.map((lvl) => {
                  const active = selectedLevel === lvl.code;
                  const style = levelStyle(lvl.code);
                  return (
                    <button
                      type="button"
                      key={lvl.code}
                      onClick={() => handleLevelSelect(lvl.code)}
                      aria-pressed={active}
                      className={cn(
                        'w-full rounded-card px-4 py-3 text-left transition-colors duration-150',
                        active ? cn(style.solid, 'shadow-sm') : cn('border border-line bg-surface hover:border-primary'),
                      )}
                    >
                      <span className="block font-heading text-h3">{lvl.code}</span>
                      <span className={cn('block text-caption', active ? 'text-white/90' : 'text-ink-muted')}>
                        {lvl.title_ua ?? style.name}
                      </span>
                    </button>
                  );
                })}
              </div>
            ),
          )}

          {/* 2. Модулі */}
          {column(
            '2. Модулі',
            !selectedLevel ? (
              hint('Оберіть рівень')
            ) : (
              <div className="flex flex-col gap-2 pb-4">
                {modules.map((mod) => {
                  const active = selectedModule === mod.id;
                  return (
                    <button
                      type="button"
                      key={mod.id}
                      onClick={() => handleModuleSelect(mod.id)}
                      aria-pressed={active}
                      className={cn(
                        'flex w-full items-center gap-3 rounded-card border px-3 py-2.5 text-left text-body transition-colors duration-150',
                        active ? cn(lv.soft, lv.line, lv.ink, 'font-semibold') : 'border-line bg-surface hover:border-primary',
                      )}
                    >
                      <span aria-hidden="true" className={cn('flex size-9 shrink-0 items-center justify-center rounded-control text-xl leading-none', active ? 'bg-surface' : lv.soft)}>
                        {moduleIcon(levelCode, mod.order_index, mod.title_hr ?? mod.title_ua)}
                      </span>
                      <span className="min-w-0 flex-1 break-words">
                        <span className={cn('text-caption', lv.ink)}>
                          {levelCode}.{mod.order_index}
                        </span>{' '}
                        {mod.title_ua}
                      </span>
                    </button>
                  );
                })}
                {isAdding === 'module' ? addForm('Назва модуля…') : addButton('module', 'Додати модуль')}
              </div>
            ),
          )}

          {/* 3. Юніти */}
          {column(
            '3. Юніти',
            !selectedModule ? (
              hint('Оберіть модуль')
            ) : (
              <div className="flex flex-col gap-2 pb-4">
                {units.map((unit) => {
                  const active = selectedUnit === unit.id;
                  return (
                    <button
                      type="button"
                      key={unit.id}
                      onClick={() => handleUnitSelect(unit.id)}
                      aria-pressed={active}
                      className={cn(
                        'w-full rounded-card border px-4 py-3 text-left text-body transition-colors duration-150',
                        active ? cn(lv.soft, lv.line, lv.ink, 'font-semibold') : 'border-line bg-surface hover:border-primary',
                      )}
                    >
                      {unit.title_ua}
                    </button>
                  );
                })}
                {isAdding === 'unit' ? addForm('Назва юніту…') : addButton('unit', 'Додати юніт')}
              </div>
            ),
          )}

          {/* 4. Уроки */}
          {column(
            '4. Уроки',
            !selectedUnit ? (
              hint('Оберіть юніт')
            ) : (
              <div className="flex flex-col gap-2 pb-4">
                {lessons.map((lesson, i) => (
                  <div key={lesson.id} className="flex w-full items-center gap-3 rounded-card border border-line bg-surface px-3 py-2.5">
                    <span className={cn('flex size-8 shrink-0 items-center justify-center rounded-full font-heading text-label tabular-nums', lv.soft, lv.ink)}>
                      {i + 1}
                    </span>
                    <span className="min-w-0 flex-1 truncate text-body">{lesson.title_ua}</span>
                    <StatusBadge status={lesson.status} />
                  </div>
                ))}
                {isAdding === 'lesson' ? addForm('Назва уроку…') : addButton('lesson', 'Створити урок')}
              </div>
            ),
          )}
        </div>
      )}

      {/* Вкладка 2: словник */}
      {activeTab === 'vocabulary' && (
        <div className="mx-auto mt-2 grid max-w-6xl grid-cols-1 gap-6 animate-fade-in-up md:grid-cols-3">
          <Card className="h-fit p-6">
            <h2 className="mb-5 font-heading text-h3">
              <span aria-hidden="true">✨</span> Додати нове слово
            </h2>
            <form onSubmit={handleAddWord} className="flex flex-col gap-4">
              <div>
                <label htmlFor="admin-lemma" className={labelClass}>Хорватською (lemma)*</label>
                <input id="admin-lemma" lang="hr" required type="text" value={newWord.hr_text} onChange={(e) => setNewWord({ ...newWord, hr_text: e.target.value })} className={fieldClass} placeholder="напр. račun" />
              </div>
              <div>
                <label htmlFor="admin-ua" className={labelClass}>Українською*</label>
                <input id="admin-ua" required type="text" value={newWord.ua_translation} onChange={(e) => setNewWord({ ...newWord, ua_translation: e.target.value })} className={fieldClass} placeholder="напр. рахунок" />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label htmlFor="admin-pos" className={labelClass}>Частина мови</label>
                  <select id="admin-pos" value={newWord.part_of_speech} onChange={(e) => setNewWord({ ...newWord, part_of_speech: e.target.value })} className={fieldClass}>
                    {PARTS_OF_SPEECH.map(([value, label]) => <option key={value} value={value}>{label}</option>)}
                  </select>
                </div>
                <div>
                  <label htmlFor="admin-cefr" className={labelClass}>Рівень</label>
                  <select id="admin-cefr" value={newWord.cefr} onChange={(e) => setNewWord({ ...newWord, cefr: e.target.value })} className={fieldClass}>
                    {CEFR_LEVELS.map((level) => <option key={level} value={level}>{level} · {levelStyle(level).name}</option>)}
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label htmlFor="admin-register" className={labelClass}>Регістр</label>
                  <select id="admin-register" value={newLabels.register} onChange={(e) => setNewLabels({ ...newLabels, register: e.target.value as Register })} className={fieldClass}>
                    {REGISTERS.map((r) => <option key={r} value={r}>{REGISTER_LABELS[r]}</option>)}
                  </select>
                </div>
                <div>
                  <label htmlFor="admin-region" className={labelClass}>Регіон</label>
                  <select id="admin-region" value={newLabels.regionality} onChange={(e) => setNewLabels({ ...newLabels, regionality: e.target.value as Region })} className={fieldClass}>
                    {REGIONS.map((r) => <option key={r} value={r}>{REGION_LABELS[r]}</option>)}
                  </select>
                </div>
              </div>
              <fieldset>
                <legend className={labelClass}>Ознаки (якщо немає — нічого не позначати)</legend>
                <div className="flex flex-wrap gap-2">
                  {USAGE_TAGS.map((t) => (
                    <label key={t} className="inline-flex min-h-11 items-center gap-2 rounded-full border border-line px-3 text-body">
                      <input type="checkbox" checked={newLabels.usage_tags.includes(t)} onChange={() => setNewLabels({ ...newLabels, usage_tags: toggleTag(newLabels.usage_tags, t) })} />
                      {USAGE_TAG_LABELS[t]}
                    </label>
                  ))}
                </div>
              </fieldset>

              <div className="border-t border-line pt-4">
                <label htmlFor="admin-forms" className={labelClass}>Інші форми (через кому)</label>
                <input id="admin-forms" lang="hr" type="text" value={newWord.details_forms} onChange={(e) => setNewWord({ ...newWord, details_forms: e.target.value })} className={fieldClass} placeholder="računi, računa..." />
              </div>
              <div>
                <label htmlFor="admin-examples" className={labelClass}>Приклади (через | )</label>
                <textarea id="admin-examples" lang="hr" value={newWord.details_examples} onChange={(e) => setNewWord({ ...newWord, details_examples: e.target.value })} className={cn(fieldClass, 'min-h-24 py-3')} placeholder="Mogu li dobiti račun? | Račun je 15 eura." />
              </div>

              {notice && (
                <p
                  role={notice.ok ? 'status' : 'alert'}
                  className={cn(
                    'flex items-start gap-2 rounded-card border p-3 text-body',
                    notice.ok ? 'border-success-line bg-success-soft text-success-ink' : 'border-warning-line bg-warning-soft text-warning-ink',
                  )}
                >
                  {notice.ok ? <CircleCheck className="mt-0.5 size-5 shrink-0" aria-hidden="true" /> : <CircleAlert className="mt-0.5 size-5 shrink-0" aria-hidden="true" />}
                  {notice.text}
                </p>
              )}

              <Button type="submit" block className="mt-2">
                Зберегти слово
              </Button>
            </form>
          </Card>

          <div className="md:col-span-2">
            <h2 className="mb-4 font-heading text-h3">
              <span aria-hidden="true">🕒</span> Останні додані слова
            </h2>
            {loadingWords ? (
              <div className="flex flex-col gap-3">
                {[1, 2, 3].map((i) => <Skeleton key={i} className="h-20" />)}
              </div>
            ) : (
              <ul className="flex flex-col gap-3">
                {words.map((word) => (
                  <li key={word.id}>
                    <Card className="flex items-start justify-between gap-3 p-4">
                      <div className="min-w-0">
                        <Hr as="h3" className="font-heading text-h3 break-words">{word.lemma}</Hr>
                        <p className="text-body text-ink-muted">{word.ukrainian_translation}</p>

                        <div className="mt-2 flex flex-wrap gap-2 text-caption">
                          {word.cefr && <LevelBadge level={word.cefr} />}
                          {word.part_of_speech && <span className="rounded-full bg-surface-muted px-2.5 py-0.5 text-ink-muted">{word.part_of_speech}</span>}
                          {(word.forms?.inflections?.length ?? 0) > 0 && <span className="rounded-full bg-surface-muted px-2.5 py-0.5 text-ink-muted">Форми: {word.forms?.inflections?.length}</span>}
                          {(word.examples?.length ?? 0) > 0 && <span className="rounded-full bg-surface-muted px-2.5 py-0.5 text-ink-muted">Приклади: {word.examples?.length}</span>}
                          {word.status && word.status !== 'PUBLISHED' && <StatusBadge status={word.status} />}
                        </div>
                      </div>
                      <span className="max-w-24 shrink-0 truncate text-right font-mono text-caption text-ink-subtle" title={word.id}>
                        ID: {word.id.substring(0, 8)}…
                      </span>
                    </Card>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

/** Статус контенту (§64): опубліковане — зелене, решта — нейтральне / бурштинове. */
function StatusBadge({ status }: { status: string }) {
  const tone =
    status === 'PUBLISHED'
      ? 'bg-success-soft text-success-ink'
      : status === 'DEPRECATED'
        ? 'bg-surface-muted text-ink-subtle'
        : 'bg-warning-soft text-warning-ink';
  return <span className={cn('shrink-0 rounded-full px-2.5 py-0.5 text-caption font-semibold', tone)}>{status}</span>;
}
