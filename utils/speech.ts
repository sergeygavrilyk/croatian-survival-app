export function speakCroatian(text: string) {
  if (typeof window === 'undefined' || !text) return;

  // Очищаємо текст від маркерів ролей у діалогах
  const cleanText = text.replace(/^[A-Za-zА-Яа-яЄ-юІ-іҐ-ґ\s]+:\s*/, '').trim();

  // Звертаємося до нашого безпечного Next.js API
  const audio = new Audio(`/api/tts?text=${encodeURIComponent(cleanText)}`);
  
  audio.play().catch((error) => {
    console.error('Не вдалося відтворити аудіо:', error);
  });
}