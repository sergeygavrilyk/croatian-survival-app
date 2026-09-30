export function speakCroatian(audioUrlOrText: string) {
  if (typeof window === 'undefined') return;
  if (!audioUrlOrText) return;

  // 1. Якщо передано посилання на хмарний файл (або шлях до локального)
  if (audioUrlOrText.startsWith('http') || audioUrlOrText.startsWith('/')) {
    const audio = new Audio(audioUrlOrText);
    
    audio.play().catch((error) => {
      console.warn('Не вдалося відтворити хмарне аудіо, перемикаємось на синтез мови...', error);
      fallbackToSpeechSynthesis(audioUrlOrText);
    });
    return;
  }

  // 2. Якщо це звичайний текст або репліка діалогу
  fallbackToSpeechSynthesis(audioUrlOrText);
}

function fallbackToSpeechSynthesis(text: string) {
  // Очищуємо від ролей (наприклад, "A: ", "Stanar: ")
  const cleanText = text.replace(/^[A-Za-zА-Яа-яЄ-юІ-іҐ-ґ\s]+:\s*/, '').trim();

  if (!('speechSynthesis' in window)) {
    console.warn('Синтез мови не підтримується браузером.');
    return;
  }

  window.speechSynthesis.cancel();

  const utterance = new SpeechSynthesisUtterance(cleanText);
  utterance.lang = 'hr-HR';
  utterance.rate = 0.9;

  const voices = window.speechSynthesis.getVoices();
  const voice = voices.find((v) => {
    const lang = v.lang.toLowerCase();
    return lang.includes('hr') || lang.includes('bs') || lang.includes('sr');
  });

  if (voice) {
    utterance.voice = voice;
  }

  window.speechSynthesis.speak(utterance);
}

if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
  window.speechSynthesis.onvoiceschanged = () => {
    window.speechSynthesis.getVoices();
  };
}