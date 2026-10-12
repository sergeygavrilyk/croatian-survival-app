// components/features/simulator/RoleplaySimulator.tsx
'use client';

import React, { useState, useEffect, useRef } from 'react';
import { speakCroatian } from '@/utils/speech';
import { startConversation, saveChatMessage } from '@/app/actions/chat';

export interface DialogueLine {
  id: string;
  speaker_name: string;
  hr_text: string;
  ua_translation: string;
}

interface RoleplaySimulatorProps {
  lines: DialogueLine[];
  uniqueSpeakers: string[];
  onExit: () => void;
}

export default function RoleplaySimulator({ lines, uniqueSpeakers, onExit }: RoleplaySimulatorProps) {
  const [mode, setMode] = useState<'setup' | 'active'>('setup');
  const [selectedRole, setSelectedRole] = useState<string | null>(null);
  const [currentStep, setCurrentStep] = useState(0);
  const [conversationId, setConversationId] = useState<string | null>(null);
  const chatEndRef = useRef<HTMLDivElement>(null);

  // Стейти для мікрофона
  const [isListening, setIsListening] = useState(false);
  const [transcript, setTranscript] = useState('');
  const [speechFeedback, setSpeechFeedback] = useState<'idle' | 'success' | 'error'>('idle');
  const recognitionRef = useRef<any>(null);

  const startRoleplay = async (role: string) => {
    setSelectedRole(role);
    setCurrentStep(0);
    setMode('active');

    let currentConvId: string | null = null;
    try {
      currentConvId = await startConversation('roleplay');
      setConversationId(currentConvId);
    } catch (e) {
      console.error("Не вдалося створити сесію чату:", e);
    }

    if (lines[0].speaker_name !== role) {
      speakCroatian(lines[0].hr_text);
      if (currentConvId) {
        await saveChatMessage(currentConvId, 'assistant', lines[0].hr_text);
      }
    }
  };

  const nextRoleplayStep = async () => {
    const next = currentStep + 1;
    setCurrentStep(next);

    if (next < lines.length && lines[next].speaker_name !== selectedRole) {
      speakCroatian(lines[next].hr_text);
      if (conversationId) {
        await saveChatMessage(conversationId, 'assistant', lines[next].hr_text);
      }
    }
  };

  const normalizeText = (text: string) => text.toLowerCase().replace(/[.,!?;:"'«»]/g, '').trim();

  const startListening = (expectedText: string) => {
    const SpeechRecognition = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;
    if (!SpeechRecognition) {
      alert("На жаль, ваш браузер не підтримує розпізнавання голосу. Використовуйте Chrome або Safari.");
      return;
    }

    setTranscript('');
    setSpeechFeedback('idle');
    setIsListening(true);

    const recognition = new SpeechRecognition();
    recognition.lang = 'hr-HR';
    recognition.interimResults = true;
    recognition.maxAlternatives = 1;
    recognitionRef.current = recognition;

    recognition.onresult = (event: any) => {
      const current = event.resultIndex;
      setTranscript(event.results[current][0].transcript);
    };

    recognition.onend = async () => {
      setIsListening(false);
      const finalTranscript = document.getElementById('speech-transcript')?.innerText || '';
      if (!finalTranscript) return;

      if (conversationId) {
        await saveChatMessage(conversationId, 'user', finalTranscript);
      }

      const spokenWords = normalizeText(finalTranscript).split(' ');
      const expectedWords = normalizeText(expectedText).split(' ');

      let matchCount = 0;
      expectedWords.forEach(w => {
        if (spokenWords.includes(w)) matchCount++;
      });

      if ((matchCount / expectedWords.length) >= 0.5) {
        setSpeechFeedback('success');
        speakCroatian("Odlično!");

        if (conversationId) {
          await saveChatMessage(conversationId, 'system', 'Feedback: Success (Odlično!)');
        }

        setTimeout(() => {
          nextRoleplayStep();
          setTranscript('');
          setSpeechFeedback('idle');
        }, 1500);
      } else {
        setSpeechFeedback('error');
        if (conversationId) {
          await saveChatMessage(conversationId, 'system', 'Feedback: Error (Не розпізнано)');
        }
      }
    };

    recognition.start();
  };

  const stopListening = () => {
    if (recognitionRef.current) {
      recognitionRef.current.stop();
      setIsListening(false);
    }
  };

  useEffect(() => {
    if (mode === 'active') chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [currentStep, mode]);

  if (mode === 'setup') {
    return (
      <div className="max-w-md mx-auto p-6 flex flex-col h-full min-h-screen bg-gray-50 text-center justify-center">
        <button onClick={onExit} className="absolute top-6 left-6 text-gray-400 hover:text-gray-600 text-2xl font-bold">✕</button>
        <h2 className="text-2xl font-bold text-gray-800 mb-2">Оберіть вашу роль</h2>
        <p className="text-gray-500 mb-8">Симулятор розмови буде автоматично відповідати вам від імені іншого персонажа.</p>
        <div className="flex flex-col gap-4">
          {uniqueSpeakers.map(speaker => (
            <button key={speaker} onClick={() => startRoleplay(speaker)} className="bg-white border-2 border-purple-200 hover:border-purple-500 text-purple-700 font-bold py-5 rounded-2xl shadow-sm transition-all active:scale-[0.98] text-lg">
              Я буду грати за: <span className="text-xl">«{speaker}»</span>
            </button>
          ))}
        </div>
      </div>
    );
  }

  const visibleLines = lines.slice(0, currentStep + 1);
  const isFinished = currentStep >= lines.length;
  const currentLine = lines[currentStep];
  const isUserTurn = currentLine?.speaker_name === selectedRole;

  return (
    <div className="max-w-md mx-auto flex flex-col h-screen bg-gray-50 relative">
      <div className="bg-white px-4 py-4 shadow-sm z-10 flex items-center justify-between">
        <button onClick={onExit} className="text-gray-400 hover:text-gray-600 text-xl font-bold">✕</button>
        <div className="text-center flex-1">
          <h3 className="text-sm font-bold text-gray-800">Симулятор розмови</h3>
          <p className="text-xs text-purple-600 font-medium">Ваша роль: {selectedRole}</p>
        </div>
        <div className="w-6"></div>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4 pb-24">
        {visibleLines.map((line) => {
          const isUser = line.speaker_name === selectedRole;
          return (
            <div key={line.id} className={`flex flex-col ${isUser ? 'items-end' : 'items-start'} animate-fade-in-up`}>
              <span className="text-[10px] text-gray-400 mb-1 px-2 uppercase tracking-wider">{line.speaker_name}</span>
              <div onClick={() => speakCroatian(line.hr_text)} className={`max-w-[85%] rounded-2xl p-4 shadow-sm cursor-pointer transition-all ${isUser ? 'bg-purple-600 text-white rounded-tr-none' : 'bg-white text-gray-800 border border-gray-100 rounded-tl-none'}`}>
                <p className="text-lg font-semibold mb-1">{line.hr_text}</p>
                <p className={`text-sm ${isUser ? 'text-purple-200' : 'text-gray-500'}`}>{line.ua_translation}</p>
              </div>
            </div>
          );
        })}
        <div ref={chatEndRef} />
      </div>

      <div className="absolute bottom-0 w-full bg-white border-t border-gray-100 p-4 shadow-[0_-10px_20px_-5px_rgba(0,0,0,0.05)]">
        {isFinished ? (
          <button onClick={onExit} className="w-full bg-purple-600 hover:bg-purple-700 text-white font-bold py-4 rounded-xl shadow-md transition-all active:scale-[0.98]">Завершити симуляцію 🎉</button>
        ) : isUserTurn ? (
          <div className="flex flex-col gap-3 animate-fade-in-up">
            <div className="text-center mb-1">
              <p className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-1">Ваша репліка:</p>
              <p className="text-lg font-bold text-purple-700 leading-tight">{currentLine.hr_text}</p>
              <p className="text-sm text-gray-500 mt-1">{currentLine.ua_translation}</p>
            </div>

            {(transcript || speechFeedback !== 'idle') && (
              <div className={`p-3 rounded-xl text-center border-2 transition-colors ${
                speechFeedback === 'success' ? 'bg-emerald-50 border-emerald-200' : 
                speechFeedback === 'error' ? 'bg-rose-50 border-rose-200' : 
                'bg-gray-50 border-gray-200'
              }`}>
                <span className="text-[10px] text-gray-400 uppercase font-bold">Мікрофон чує:</span>
                <p id="speech-transcript" className={`font-medium ${speechFeedback === 'error' ? 'text-rose-600' : 'text-gray-800'}`}>
                  {transcript || (speechFeedback === 'error' ? 'Не розпізнано, спробуйте ще раз' : '...')}
                </p>
              </div>
            )}

            <div className="flex gap-2 mt-2">
              <button 
                onClick={() => isListening ? stopListening() : startListening(currentLine.hr_text)} 
                className={`flex-[3] font-bold py-4 rounded-xl shadow-md transition-all active:scale-[0.98] flex items-center justify-center gap-2 ${
                  isListening ? 'bg-rose-500 hover:bg-rose-600 text-white animate-pulse' : 'bg-purple-600 hover:bg-purple-700 text-white'
                }`}
              >
                {isListening ? '🛑 Зупинити запис' : '🎙 Натисніть та говоріть'}
              </button>
              
              <button 
                onClick={() => { stopListening(); nextRoleplayStep(); setTranscript(''); setSpeechFeedback('idle'); }} 
                className="flex-[1] bg-gray-100 hover:bg-gray-200 text-gray-500 font-bold py-4 rounded-xl transition-all active:scale-[0.98] text-sm"
              >
                Пропустити
              </button>
            </div>
          </div>
        ) : (
          <div className="flex flex-col gap-3">
            <div className="flex items-center gap-2 text-gray-400 font-medium justify-center text-sm"><span className="animate-pulse">🎧</span> Співрозмовник говорить...</div>
            <button onClick={nextRoleplayStep} className="w-full bg-gray-100 hover:bg-gray-200 text-gray-700 font-bold py-3.5 rounded-xl transition-all active:scale-[0.98]">Далі ➔</button>
          </div>
        )}
      </div>
    </div>
  );
}