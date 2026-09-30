import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

const newModules = [
  {
    order_index: 7,
    title_hr: 'IT komunikacija i Scrum',
    title_ua: 'ІТ-комунікація та Scrum',
    description: 'Лексика для Delivery Management, стендапів та роботи з командою.',
    vocab: [
      { type: 'word', hr: 'Zastoj', ua: 'Блокер (перешкода)' },
      { type: 'word', hr: 'Isporuka', ua: 'Доставка (Delivery)' },
      { type: 'word', hr: 'Procjena', ua: 'Оцінка (естімація)' },
      { type: 'word', hr: 'Dnevni sastanak', ua: 'Дейлі (стендап)' },
      { type: 'phrase', hr: 'Imamo li blokada za ovaj sprint?', ua: 'Чи є у нас блокери на цей спринт?' },
      { type: 'phrase', hr: 'Koji je status ovog zadatka?', ua: 'Який статус цієї задачі?' },
      { type: 'dialogue_line', hr: 'Scrum Master: Dobro jutro svima. Krenimo s dnevnim sastankom.', ua: 'Скрам-майстер: Доброго ранку всім. Почнемо дейлі.' },
      { type: 'dialogue_line', hr: 'Developer: Završio sam backend dio. Danas radim na testiranju.', ua: 'Розробник: Я закінчив бекенд частину. Сьогодні працюю над тестуванням.' },
      { type: 'dialogue_line', hr: 'Scrum Master: Imaš li kakvih zastoja?', ua: 'Скрам-майстер: Чи є в тебе якісь блокери?' }
    ]
  },
  {
    order_index: 8,
    title_hr: 'Auto servis i popravci',
    title_ua: 'Автосервіс та ремонт',
    description: 'Обслуговування авто: двигун, коробка передач, діагностика.',
    vocab: [
      { type: 'word', hr: 'Ulje u mjenjaču', ua: 'Мастило в коробці передач' },
      { type: 'word', hr: 'Dizne', ua: 'Форсунки' },
      { type: 'word', hr: 'Motor', ua: 'Двигун' },
      { type: 'word', hr: 'Kvačilo', ua: 'Зчеплення' },
      { type: 'phrase', hr: 'Trebam zamjenu ulja u mjenjaču.', ua: 'Мені потрібна заміна мастила в коробці передач.' },
      { type: 'phrase', hr: 'Možete li provjeriti motor OM639?', ua: 'Можете перевірити двигун OM639?' },
      { type: 'dialogue_line', hr: 'Vlasnik: Dobar dan. Želim dogovoriti servis za Smart Forfour.', ua: 'Власник: Доброго дня. Хочу записатися на сервіс для Smart Forfour.' },
      { type: 'dialogue_line', hr: 'Mehaničar: Koji je problem?', ua: 'Механік: У чому проблема?' },
      { type: 'dialogue_line', hr: 'Vlasnik: Treba mi provjera dizni i zamjena ulja u mjenjaču.', ua: 'Власник: Мені потрібна перевірка форсунок та заміна мастила в коробці.' }
    ]
  },
  {
    order_index: 9,
    title_hr: 'Veterinar i kućni ljubimci',
    title_ua: 'Ветеринар та домашні улюбленці',
    description: 'Візит до ветеринара, купівля корму, базовий догляд за собакою.',
    vocab: [
      { type: 'word', hr: 'Australski ovčar', ua: 'Австралійська вівчарка' },
      { type: 'word', hr: 'Cjepivo', ua: 'Щеплення (вакцина)' },
      { type: 'word', hr: 'Hrana za pse', ua: 'Корм для собак' },
      { type: 'word', hr: 'Povodac', ua: 'Повідець' },
      { type: 'phrase', hr: 'Moj pas treba godišnje cjepivo.', ua: 'Моєму собаці потрібне щорічне щеплення.' },
      { type: 'phrase', hr: 'Imate li hranu bez žitarica?', ua: 'У вас є беззерновий корм?' },
      { type: 'dialogue_line', hr: 'Vlasnik: Dobar dan, naručeni smo za pregled.', ua: 'Власник: Доброго дня, ми записані на огляд.' },
      { type: 'dialogue_line', hr: 'Veterinar: Kako se zove pas? Je li to australski ovčar?', ua: 'Ветеринар: Як звати собаку? Це австралійська вівчарка?' },
      { type: 'dialogue_line', hr: 'Vlasnik: Da, tako je. Došli smo na redovno cijepljenje.', ua: 'Власник: Так, все вірно. Ми прийшли на планове щеплення.' }
    ]
  },
  {
    order_index: 10,
    title_hr: 'MUP i birokracija',
    title_ua: 'MUP та бюрократія',
    description: 'Оформлення документів, посвідка на проживання, комунікація в поліції.',
    vocab: [
      { type: 'word', hr: 'Dozvola za boravak', ua: 'Посвідка на проживання' },
      { type: 'word', hr: 'OIB', ua: 'Ідентифікаційний номер (OIB)' },
      { type: 'word', hr: 'Šalter', ua: 'Віконце (каса/прийомне)' },
      { type: 'word', hr: 'Zahtjev', ua: 'Заява (запит)' },
      { type: 'phrase', hr: 'Predao sam zahtjev online.', ua: 'Я подав заяву онлайн.' },
      { type: 'phrase', hr: 'Koji broj trebam uzeti za MUP?', ua: 'Який номер мені потрібно взяти для MUP?' },
      { type: 'dialogue_line', hr: 'Osoba: Dobar dan. Došao sam po novu dozvolu za boravak.', ua: 'Особа: Добрий день. Я прийшов за новою посвідкою на проживання.' },
      { type: 'dialogue_line', hr: 'Službenik: Vaša putovnica i potvrdnica, molim.', ua: 'Службовець: Ваш паспорт і квитанцію, будь ласка.' },
      { type: 'dialogue_line', hr: 'Osoba: Izvolite. Trebam li potpisati ovdje?', ua: 'Особа: Прошу. Мені потрібно підписати тут?' }
    ]
  }
];

export async function GET() {
  try {
    for (const topic of newModules) {
      // Використовуємо прості фіксовані UUID для зручності
      const topicId = '00000000-0000-0000-0000-0000000000' + (topic.order_index < 10 ? '0' + topic.order_index : topic.order_index);
      
      const { error: topicError } = await supabase
        .from('topics')
        .upsert({
          id: topicId,
          title_hr: topic.title_hr,
          title_ua: topic.title_ua,
          description: topic.description,
          order_index: topic.order_index,
        });

      if (topicError) throw topicError;

      const vocabData = topic.vocab.map((item) => ({
        topic_id: topicId,
        item_type: item.type,
        hr_text: item.hr,
        ua_translation: item.ua,
      }));

      const { error: vocabError } = await supabase.from('vocabulary').insert(vocabData);
      if (vocabError) throw vocabError;
    }

    return NextResponse.json({ success: true, message: 'Розширені модулі завантажено!' });
  } catch (error) {
    return NextResponse.json({ success: false, error });
  }
}