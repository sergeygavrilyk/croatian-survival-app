'use client';

import React from 'react';
import { speakCroatian } from '@/utils/speech'; // Додано імпорт функції

export interface DialogueLine {
  id: string;
  speaker: string;
  hr_text: string;
  ua_translation: string;
}

interface LessonViewProps {
  title: string;
  description?: string;
  lines: DialogueLine[];
  onComplete: () => void;
}

export default function LessonView({ title, description, lines, onComplete }: LessonViewProps) {
  return (
    <div className="max-w-md mx-auto p-4 flex flex-col h-full min-h-screen bg-gray-50">
      <div className="mb-6 text-center">
        <h2 className="text-2xl font-bold text-gray-800">{title}</h2>
        {description && <p className="text-gray-500 text-sm mt-1">{description}</p>}
      </div>

      <div className="flex-1 space-y-4 mb-8 overflow-y-auto pb-4">
        {lines.map((line, index) => {
          const isUser = index % 2 === 0; // Чергування сторін діалогу
          return (
            <div key={line.id} className={`flex flex-col ${isUser ? 'items-end' : 'items-start'}`}>
              <span className="text-xs text-gray-400 mb-1 px-2">{line.speaker}</span>
              
              {/* Додано onClick, cursor-pointer та hover-ефекти */}
              <div 
                onClick={() => speakCroatian(line.hr_text)}
                className={`max-w-[85%] rounded-2xl p-4 shadow-sm cursor-pointer hover:opacity-95 active:scale-[0.98] transition-all flex flex-col ${
                  isUser ? 'bg-blue-500 text-white rounded-tr-none' : 'bg-white text-gray-800 border border-gray-100 rounded-tl-none'
                }`}
              >
                <div className="flex items-start justify-between gap-3">
                  <p className="text-lg font-semibold mb-1">{line.hr_text}</p>
                  
                  {/* Іконка динаміка */}
                  <span className={`shrink-0 text-lg opacity-70 ${isUser ? 'text-blue-200' : 'text-gray-400'}`}>
                    🔊
                  </span>
                </div>
                
                <p className={`text-sm ${isUser ? 'text-blue-100' : 'text-gray-500'}`}>
                  {line.ua_translation}
                </p>
              </div>
            </div>
          );
        })}
      </div>

      <button 
        onClick={onComplete}
        className="w-full bg-green-500 hover:bg-green-600 text-white font-bold py-4 rounded-xl shadow-md transition-colors active:scale-95"
      >
        Завершити урок
      </button>
    </div>
  );
}