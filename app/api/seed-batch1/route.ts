import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

const newModules = [
  {
    order_index: 11,
    title_hr: 'IT Delivery i Product Ops',
    title_ua: 'IT Delivery та Product Ops',
    description: 'Управління розробкою, міграції, налаштування процесів та Product Operations.',
    vocab: [
      { type: 'word', hr: 'Isporuka', ua: 'Доставка (реліз)' },
      { type: 'word', hr: 'Kapacitet tima', ua: 'Ємність (капасіті) команди' },
      { type: 'word', hr: 'Migracija', ua: 'Міграція' },
      { type: 'phrase', hr: 'Trebamo dokumentirati procese za Product Operations.', ua: 'Нам потрібно задокументувати процеси для Product Operations.' },
      { type: 'phrase', hr: 'Koji su rizici migracije na PHP 8.3?', ua: 'Які ризики міграції на PHP 8.3?' },
      { type: 'phrase', hr: 'Moramo uskladiti očekivanja dionika.', ua: 'Ми повинні узгодити очікування стейкхолдерів.' },
      { type: 'dialogue_line', hr: 'Delivery Manager: Kako napreduje postavljanje Product Ops funkcije?', ua: 'Delivery Manager: Як просувається налаштування функції Product Ops?' },
      { type: 'dialogue_line', hr: 'Team Lead: Radimo na raspodjeli kapaciteta za Warehouse Operations.', ua: 'Team Lead: Працюємо над розподілом капасіті для Warehouse Operations.' },
      { type: 'dialogue_line', hr: 'Delivery Manager: Odlično. Pripremite plan za Q4 radionice.', ua: 'Delivery Manager: Чудово. Підготуйте план для воркшопів на Q4.' }
    ]
  },
  {
    order_index: 12,
    title_hr: 'Specifični auto servis',
    title_ua: 'Специфічний автосервіс',
    description: 'Детальна термінологія для ремонту компактних дизельних авто.',
    vocab: [
      { type: 'word', hr: 'Aktuator', ua: 'Актуатор' },
      { type: 'word', hr: 'Robotizirani mjenjač', ua: 'Роботизована коробка передач' },
      { type: 'word', hr: 'Pogonski remen', ua: 'Привідний ремінь' },
      { type: 'phrase', hr: 'Trebam zamjenu ulja u robotiziranom mjenjaču.', ua: 'Мені потрібна заміна мастила в роботизованій коробці передач.' },
      { type: 'phrase', hr: 'Možete li provjeriti aktuator na Smartu?', ua: 'Можете перевірити актуатор на Смарті?' },
      { type: 'phrase', hr: 'Motor je 1.5 CDI, oznaka OM639.', ua: 'Двигун 1.5 CDI, маркування OM639.' },
      { type: 'dialogue_line', hr: 'Vlasnik: Trebam redovni servis za Smart Forfour iz 2005.', ua: 'Власник: Мені потрібне планове обслуговування для Smart Forfour 2005 року.' },
      { type: 'dialogue_line', hr: 'Mehaničar: Imate li problema s prebacivanjem brzina?', ua: 'Механік: Чи є проблеми з перемиканням передач?' },
      { type: 'dialogue_line', hr: 'Vlasnik: Ponekad trza. Molim vas, podesite aktuator i provjerite dizne.', ua: 'Власник: Іноді смикає. Будь ласка, налаштуйте актуатор і перевірте форсунки.' }
    ]
  },
  {
    order_index: 13,
    title_hr: 'Aktivni psi i njega',
    title_ua: 'Активні собаки та догляд',
    description: 'Лексика для власників енергійних порід та ветеринарні питання.',
    vocab: [
      { type: 'word', hr: 'Australski ovčar', ua: 'Австралійська вівчарка' },
      { type: 'word', hr: 'Istrčavanje', ua: 'Пробіжка / вигул' },
      { type: 'word', hr: 'Dlaka i poddlaka', ua: 'Шерсть та підшерстя' },
      { type: 'phrase', hr: 'Ova pasmina zahtijeva puno mentalne stimulacije.', ua: 'Ця порода вимагає багато розумової стимуляції.' },
      { type: 'phrase', hr: 'Trebam četku za ispadanje dlake.', ua: 'Мені потрібна щітка від випадіння шерсті (фурмінатор).' },
      { type: 'dialogue_line', hr: 'Vlasnik: Trebamo zakazati termin za šišanje i kupanje.', ua: 'Власник: Нам потрібно записатися на стрижку та купання.' },
      { type: 'dialogue_line', hr: 'Groomer: Koja je pasmina u pitanju?', ua: 'Грумер: Яка це порода?' },
      { type: 'dialogue_line', hr: 'Vlasnik: Australski ovčar. Trebamo dobro iščešljati poddlaku.', ua: 'Власник: Австралійська вівчарка. Нам треба добре вичесати підшерстя.' }
    ]
  },
  {
    order_index: 14,
    title_hr: 'Planiranje putovanja i cestarine',
    title_ua: 'Планування подорожей та платні дороги',
    description: 'Організація довгих автоподорожей, розрахунок пального та часу.',
    vocab: [
      { type: 'word', hr: 'Cestarina', ua: 'Плата за проїзд (cestarina)' },
      { type: 'word', hr: 'Trajekt', ua: 'Пором' },
      { type: 'word', hr: 'Zalazak sunca', ua: 'Захід сонця' },
      { type: 'phrase', hr: 'Koliko košta cestarina od Zadra do Italije?', ua: 'Скільки коштує платна дорога від Задара до Італії?' },
      { type: 'phrase', hr: 'Želim stići prije zalaska sunca.', ua: 'Я хочу приїхати до заходу сонця.' },
      { type: 'phrase', hr: 'Koji je najbrži put do Makarske?', ua: 'Який найшвидший шлях до Макарски?' },
      { type: 'dialogue_line', hr: 'Vozač: Planiramo putovanje od Zadra do Siene sljedeći tjedan.', ua: 'Водій: Ми плануємо подорож від Задара до Сієни наступного тижня.' },
      { type: 'dialogue_line', hr: 'Suvozač: Jesi li izračunao troškove goriva i ENC-a?', ua: 'Пасажир: Ти порахував витрати на пальне та ENC (термінал для оплати)?' },
      { type: 'dialogue_line', hr: 'Vozač: Jesam. Krenut ćemo rano da izbjegnemo gužvu na granici.', ua: 'Водій: Так. Ми виїдемо рано, щоб уникнути заторів на кордоні.' }
    ]
  },
  {
    order_index: 15,
    title_hr: 'Investicije i ETF',
    title_ua: 'Інвестиції та ETF',
    description: 'Фінансова лексика, податки на дивіденди та біржові фонди.',
    vocab: [
      { type: 'word', hr: 'Burza', ua: 'Біржа' },
      { type: 'word', hr: 'Dividenda', ua: 'Дивіденди' },
      { type: 'word', hr: 'Porez na kapitalnu dobit', ua: 'Податок на приріст капіталу' },
      { type: 'phrase', hr: 'Ulažem u indeksne fondove.', ua: 'Я інвестую в індексні фонди.' },
      { type: 'phrase', hr: 'Koji je obrazac za prijavu poreza iz inozemstva?', ua: 'Яка форма для декларування податків з-за кордону?' },
      { type: 'dialogue_line', hr: 'Klijent: Koristim Interactive Brokers za kupnju ETF-ova poput VOO i QQQ.', ua: 'Клієнт: Я використовую Interactive Brokers для купівлі ETF, таких як VOO та QQQ.' },
      { type: 'dialogue_line', hr: 'Savjetnik: Prijavljujete li porez na dividende u Hrvatskoj?', ua: 'Консультант: Ви декларуєте податок на дивіденди в Хорватії?' },
      { type: 'dialogue_line', hr: 'Klijent: Da, ispunjavam JOPPD obrazac svake godine.', ua: 'Клієнт: Так, я заповнюю форму JOPPD щороку.' }
    ]
  },
  {
    order_index: 16,
    title_hr: 'Stil i svakodnevica',
    title_ua: 'Стиль та повсякденність',
    description: 'Одяг, взуття та відпочинок без алкоголю.',
    vocab: [
      { type: 'word', hr: 'Brušena koža', ua: 'Замша' },
      { type: 'word', hr: 'Čizme', ua: 'Черевики / чоботи' },
      { type: 'word', hr: 'Bezalkoholno pivo', ua: 'Безалкогольне пиво' },
      { type: 'phrase', hr: 'Tražim smeđe čizme od brušene kože.', ua: 'Я шукаю коричневі замшеві черевики.' },
      { type: 'phrase', hr: 'Ne pijem alkohol. Imate li svježi sok?', ua: 'Я не п\'ю алкоголь. У вас є фреш?' },
      { type: 'dialogue_line', hr: 'Kupac: Imate li ove Chelsea čizme u broju 43?', ua: 'Покупець: У вас є ці черевики Chelsea 43 розміру?' },
      { type: 'dialogue_line', hr: 'Prodavač: Da, imamo ih u tamno smeđoj boji.', ua: 'Продавець: Так, вони є у темно-коричневому кольорі.' },
      { type: 'dialogue_line', hr: 'Kupac: Odlično. Uzimam te. Mogu li platiti karticom?', ua: 'Покупець: Чудово. Я їх беру. Можна оплатити карткою?' }
    ]
  }
];

export async function GET() {
  try {
    for (const topic of newModules) {
      const topicId = '00000000-0000-0000-0000-0000000000' + topic.order_index;
      
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
    return NextResponse.json({ success: true, message: `Завантажено Батч 1 (Модулі ${newModules[0].order_index}-${newModules[newModules.length-1].order_index})!` });
  } catch (error) {
    return NextResponse.json({ success: false, error });
  }
}