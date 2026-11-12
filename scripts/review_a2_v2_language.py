#!/usr/bin/env python3
"""
Мовна перевірка рівня A2 v2 з даних генератора (skill croatian-content-review, 2026-11-12).

  python3 -B scripts/review_a2_v2_language.py --auto      →  автоматичні перевірки по всіх 14 модулях (сербізми / екавізми,
                                                             da li, treba da, biti ću, кирилиця / латиниця не там, російські літери,
                                                             знаки питання й числа в парах, однакові приклади)
  python3 -B scripts/review_a2_v2_language.py --export 3  →  усі пари «хорватське ↔ українське» модуля A2.3 для читання
                                                             (W — слово [частина мови, рід/вид] :: приклад; D — діалог; F — вставте слово;
                                                              B — складіть; S — скажіть; LD / LQ — «на слух»; WR — письмо; MD — переказ)
Автоматичні знахідки — підказки: частина спрацювань хибна (neko mjesto, kafić, e-mail); остаточно вирішує людина.
"""
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_curriculum_a2_v2 as V  # noqa: E402
import curriculum_a2_v2_data as D  # noqa: E402
def items(m):
    """(where, hr, ua) пари для всього модуля"""
    out=[]
    for (mm,o),L in V.lessons_of(m).items():
        n=V.PLACE[(mm,o)]; p=f'{n}'
        out.append((p+' T', L['title'][1], L['title'][0]))
        for lem,ua,pos,fc,ex in L['vocab']:
            out.append((p+' W', f'{lem} [{pos} {fc}] :: {ex}', ua))
        for si,(sua,shr,turns) in enumerate(L['scenes'],1):
            out.append((p+f' D{si}', shr, sua))
            for sp,hr,ua in turns: out.append((p+f' D{si}', f'{sp}: {hr}', ua))
        f=L['fill']; out.append((p+' F', f[0]+' → '+f[1], 'opts: '+', '.join(f[2])))
        for ua,hr in L['build']: out.append((p+' B', hr, ua))
        for ua,hr in L['speak']: out.append((p+' S', hr, ua))
        out.append((p+' L', L['listen'], ''))
        ls=L['listening']; out.append((p+' LD', ls['kind'], ls['situation']))
        for t in ls['script']:
            hr,ua=(t[-2],t[-1]); sp=t[0]+': ' if len(t)==3 else ''
            out.append((p+' LD', sp+hr, ua))
        for q in ls['questions']: out.append((p+' LQ', json.dumps(q,ensure_ascii=False)[:300], ''))
        w=L['write']; out.append((p+' WR', ' | '.join(w['models']), w['situation']))
        md=L['mediation']; out.append((p+' MD', ' | '.join(md['models']), md['friend']))
    return out
SERB = r"\b(hiljad\w*|hleb\w*|uopšte|tačn\w*|vazduh\w*|sedmic\w*|voz|vozom|pozorišt\w*|opštin\w*|apotek\w*|kompjuter\w*|bezbed\w*|uslov\w*|porodic\w*|fudbal\w*|kafa|kafu|kafe|kafić\w*|lekar\w*|mleko|dete|deca|decu|lep\w*|reka|reku|cvet\w*|beo|belo|bela|hteo|htela|negde|gde|ovde|šta|ko|neko|niko|nekog|nikog|jun|jul|avgust\w*|septemb\w*|oktob\w*|novemb\w*|decemb\w*|januar\w*|februar\w*|mart|april\w*|milion\w*|pasoš\w*|kašik\w*|obavezn\w*|tačka|spisak|ručak?|dobiti|treba da|da li|biti ću|nedelj\w*|sutra?dan|lično|lična|stanica|aerodrom\w*|ćebe|sveska|ćao|izvini(te)?)\b"
SERB_OK = {'neko', 'kafić', 'kafići', 'kafiću', 'kafića', 'leptirići', 'ručak','ruča','sutradan','dobiti','stanica','izvini','izvinite','aerodrom','aerodromu','aerodroma','lično','lična','tačka'}  # провірити вручну окремо
RUS = r"(приймати участь|прийняти участь|на протязі|являється|являються|слідуюч|получ|любий|міроприєм|відміт|вибачаюсь|співпада|кушат|всьо|нажат|прийом їжі|згідно|самий кращ|більш кращ)"
CYR=re.compile('[А-Яа-яЇїІіЄєҐґ]'); LAT=re.compile('[a-zčćšžđ]{3,}', re.I)
def auto():
    find = defaultdict(list)
    exs = defaultdict(list)
    for m in range(1, 15):
        for w, hr, ua in items(m):
            kind = w.split()[1]
            h = hr.split(' :: ', 1)[-1] if kind == 'W' else hr
            if kind != 'LQ' and CYR.search(hr):
                find['кирилиця в хорватському'].append((m, w, hr))
            for mt in re.finditer(SERB, h, re.I):
                t = mt.group(0).lower()
                if t not in SERB_OK:
                    find[f'сербізм / екавізм? «{t}»'].append((m, w, h))
            if re.search(r"\b\w+ti (ću|ćeš|će|ćemo|ćete)\b", h):
                find['інфінітив на -ti перед ću (bit ću, а не biti ću)'].append((m, w, h))
            if re.search(RUS, ua, re.I):
                find['русизм в українському?'].append((m, w, ua))
            if re.search('[ыэъёЫЭЪЁ]', ua + hr):
                find['російські літери (ы, э, ъ, ё)'].append((m, w, ua))
            if re.search(r'[а-яіїєґ][a-z]|[a-z][а-яіїєґ]', ua) and 'e-mail' not in ua:
                find['латиниця всередині українського слова'].append((m, w, ua))
            if kind in ('B', 'S', 'D1', 'D2', 'LD'):
                if (kind in ('D1', 'D2') and ': ' not in hr) or (kind == 'LD' and ' ' not in hr):
                    continue  # назва сцени / вид запису
                hh = hr.split(': ', 1)[-1] if kind in ('D1', 'D2', 'LD') else hr
                uu = re.sub(r'^Складіть: «(.*)»$', r'\1', ua)
                if uu and LAT.search(re.sub(r'\([^)]*\)', '', uu)) and not re.search(r'\b(Daša|Darja)\b', uu):
                    find['латиниця в перекладі'].append((m, w, uu))
                if uu and hh.rstrip().endswith('?') != uu.rstrip().endswith('?'):
                    find['питання ↔ не питання'].append((m, w, hh + ' || ' + uu))
                if uu and sorted(re.findall(r'\d+', hh)) != sorted(re.findall(r'\d+', uu)):
                    find['числа не збігаються'].append((m, w, hh + ' || ' + uu))
                if hh and not re.search(r'[.!?…"»)]$', hh.strip()):
                    find['без розділового знака в кінці'].append((m, w, hh))
            if kind == 'W':
                exs[hr.split(' :: ', 1)[1]].append((m, w))
    for ex, lst in exs.items():
        if len(lst) > 1:
            find['однаковий приклад у різних слів'].append((lst, ex, ''))
    for k, v in find.items():
        print(f'### {k} ({len(v)})')
        for x in v[:40]:
            print('  ', x)

if __name__ == '__main__':
    if '--auto' in sys.argv:
        auto()
    elif '--export' in sys.argv:
        m = int(sys.argv[sys.argv.index('--export') + 1])
        for w, hr, ua in items(m):
            print(f'{w}\t{hr}\t{ua}')
    else:
        print(__doc__)
