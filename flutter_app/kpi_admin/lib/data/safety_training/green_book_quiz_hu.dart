// lib/data/safety_training/green_book_quiz_hu.dart
//
// A Green Book záróteszt kérdései (menetellenőrző könyv a § 1 Abs. 6
// FPersV szerint) — magyar változat. A felépítés megegyezik a német
// mesterváltozattal: ugyanannyi kérdés, ugyanaz a sorrend, ugyanazok a
// helyes válaszok.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> greenBookQuestionsHu = [
  // ══════════════════════════ gb1 — Mi az a Green Book
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Mit dokumentálsz a Green Bookban?',
    options: [
      'A jármű állapotát az indulás előtt',
      'A kézbesített csomagok és a visszáru darabszámát',
      'A vezetési időt, a vezetési szüneteket, valamint a munka- és '
          'pihenőidőt',
    ],
    correctIndex: 2,
    explanation: 'A Green Book a menetellenőrző könyv — a napi ellenőrző '
        'lapok gyűjteménye a § 1 Abs. 6 FPersV szerint. Kizárólag időket '
        'igazol. A jármű állapotát máshol dokumentálják, és kifejezetten '
        'nem ide tartozik.',
  ),
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Mely járművekre vonatkozik a nyilvántartási kötelezettség a '
        '§ 1 Abs. 6 FPersV szerint?',
    options: [
      '2,8 t feletti, 3,5 t-ig terjedő megengedett legnagyobb össztömeg '
          'üzletszerű árufuvarozásban',
      'Minden járműre, amellyel üzletszerűen csomagot szállítanak',
      'Csak 3,5 t megengedett legnagyobb össztömegtől',
    ],
    correctIndex: 0,
    explanation: 'A kötelezettség a 2,8 t feletti, 3,5 t-ig terjedő sávban '
        'áll fenn — pontosan a tipikus kézbesítő furgon. 2,8 t alatt nem '
        'áll fenn, 3,5 t-tól a digitális tachográf veszi át a '
        'nyilvántartást.',
  ),
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'A furgonod a forgalmi engedély szerint 3,5 t megengedett '
        'legnagyobb össztömegű, ma azonban csak 900 kg van rajta. Mi '
        'érvényes?',
    options: [
      'Nincs nyilvántartási kötelezettség — a tényleges tömeg 2,8 t alatt '
          'van',
      'A nyilvántartási kötelezettség fennmarad',
      'A kötelezettség csak 100 kilométeres napi távolságtól áll fenn',
    ],
    correctIndex: 1,
    explanation: 'A forgalmi engedélyben szereplő megengedett legnagyobb '
        'össztömeg a mérvadó, nem a mai rakomány. A kézenfekvő tévedés, '
        'hogy minden nap újraszámolod a rakomány szerint — a jármű '
        'besorolása ettől nem változik.',
  ),

  // ══════════════════════════ gb2 — Mit kell bejegyezni
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Melyik adat NEM tartozik a napi ellenőrző lap kötelező '
        'adatai közé?',
    options: [
      'Kilométeróra-állás az út elején és az út végén',
      'A kézbesített küldemények darabszáma',
      'Az indulás és az érkezés helye',
    ],
    correctIndex: 1,
    explanation: 'Előírás többek között a sofőr vezeték- és keresztneve, '
        'lakcíme, a rendszám, a dátum, a kilométeróra-állások, a helyek, '
        'az idők és az aláírás. A darabszám céges mutató, és nem szerepel '
        'a lapon.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Mivel töltöd ki a napi ellenőrző lapot?',
    options: [
      'Golyóstollal, letörölhetetlenül',
      'Ceruzával, hogy a hibákat tisztán lehessen javítani',
      'Az íróeszköz mindegy, amíg olvasható',
    ],
    correctIndex: 0,
    explanation: 'Egy kiradírozható bejegyzés nem bizonyíték. Pontosan '
        'ezért nem megengedett a ceruza — akkor sem, ha a javítás jó '
        'szándékú. A hibát egyszer áthúzod, és mellé újraírod.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Minden idő és kilométeróra-állás be van írva, csak az '
        'aláírás hiányzik. Mi érvényes erre a lapra?',
    options: [
      'Érvényes — az aláírás puszta formaság',
      'Hiányosnak számít, és nem teljesíti a nyilvántartási '
          'kötelezettséget',
      'A diszpécser utólag ellenjegyezheti a cégnél',
    ],
    correctIndex: 1,
    explanation: 'Az aláírás az előírt adatok egyike — ezzel igazolod a '
        'tartalmat. Nélküle a lap hiányos, ugyanolyan következményekkel, '
        'mint egy hiányzó lap. Idegen aláírás nem pótolja a tiédet.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: '40 percet vársz a rakodórámpánál. Nem csinálsz semmit, de '
        'bármelyik pillanatban készen kell állnod, mert azonnal '
        'folytatódhat. Hogyan írod be ezt az időt?',
    options: [
      'Vezetési szünetként — hiszen nem dolgoztál',
      'A napi pihenőidő kezdeteként',
      'Munkaidőként',
    ],
    correctIndex: 2,
    explanation: 'Egy vezetési szünet csak akkor pihenő, ha szabadon '
        'rendelkezel az idővel, és ezt előre tudod. A készenlét várakozási '
        'idő, és így munkaidő. A kézenfekvő tévedés: „nem csináltam '
        'semmit, tehát szünet volt" — nem a tevékenység a döntő, hanem a '
        'rendelkezésre állás.',
  ),

  // ══════════════════════════ gb3 — Vezetési idő, szünet, pihenő
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Mennyit vezethetsz legfeljebb egy szokásos napon?',
    options: [
      '9 órát',
      '10 órát',
      '8 órát, azon túl csak a diszpécser hozzájárulásával',
    ],
    correctIndex: 0,
    explanation: 'A napi vezetési idő legfeljebb 9 óra. A 10 óra nem egy '
        'második alapkorlát, hanem szűkre szabott kivétel — a céges '
        'hozzájárulás pedig a korlát szempontjából egyáltalán nem játszik '
        'szerepet.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Milyen gyakran hosszabbíthatod meg a vezetési időt 10 '
        'órára?',
    options: [
      'Hetente egyszer',
      'Hetente kétszer',
      'Minden nap, amikor a túra megkívánja',
    ],
    correctIndex: 1,
    explanation: 'Hetente kétszer hosszabbítható meg a napi vezetési idő '
        '10 órára. Ez heti keret, nem napi jogosultság — és a túra '
        'nagysága nem hosszabbítja meg.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Fel akarod osztani a 45 perces vezetési szünetet. Melyik '
        'felosztás megengedett?',
    options: [
      'Először 30 perc, utána 15 perc',
      'Háromszor 15 perc a nap folyamán elosztva',
      'Először 15 perc, utána 30 perc',
    ],
    correctIndex: 2,
    explanation: 'A felosztás csak két részben és csak ebben a sorrendben '
        'megengedett: először legalább 15, utána legalább 30 perc. A '
        'fordított sorrend nem számít, három rövid rész sem — akkor sem, '
        'ha az összeg stimmel.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: '07:00-kor indulsz. 09:30-ig 2 órát ülsz a volánnál, '
        '12:00-ig további 2 óra vezetési idő jön hozzá, 13:00-ig még 30 '
        'perc. Mikor esedékes legkésőbb a vezetési szünet?',
    options: [
      '11:30-kor, vagyis 4,5 órával a szolgálat kezdete után',
      '12:00-kor, mert az ebédidő erre szolgál',
      '13:00-kor',
    ],
    correctIndex: 2,
    explanation: 'A 2 + 2 + 0,5 óra 13:00-ra pontosan 4,5 óra tiszta '
        'vezetési időt ad ki — most egyetlen métert sem vezethetsz, amíg a '
        'szünetet le nem tudtad. A kézenfekvő tévedés a szolgálat '
        'kezdetétől számolni: az óra csak akkor jár, amikor a jármű halad.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: '17:15-kor fejezed be a vezetési időt. Mikor indulhatsz '
        'legkorábban újra?',
    options: [
      '02:15-kor — 9 óra pihenőidő elegendő',
      '04:15-kor',
      'Amint kipihentnek érzed magad, nincs rögzített határ',
    ],
    correctIndex: 1,
    explanation: 'A napi pihenőidő legalább 11 óra, tehát legkorábban '
        '04:15. A 9 óra a vezetési idő korlátja, nem a pihenőidőé — ezt a '
        'két számot rendszeresen összekeverik.',
  ),

  // ══════════════════════════ gb4 — Tipikus hibák
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Egy kolléga péntek este tölti ki az egész hét lapjait. Az '
        'idők tartalmilag stimmelnek. Hogyan értékelendő ez?',
    options: [
      'Szabálysértés, és egy ellenőrzésen feltűnik',
      'Nem probléma, amíg a beírt idők megfelelnek a valóságnak',
      'Csak rendtartási kérdés, jogi jelentőség nélkül',
    ],
    correctIndex: 0,
    explanation: 'A nyilvántartás azt jelenti: időben nyilvántartani. Az '
        'utólag megírt lapok felismerhetők az azonos íróképről, a '
        'feltűnően kerek időkről és a kilométeróra-állásokról, amelyek nem '
        'illenek az útvonalhoz. Az, hogy az idők stimmelnek, nem orvosolja '
        'a nyilvántartási kötelezettség megsértését.',
  ),
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Csütörtökön veszed észre, hogy kedden nincs beírva az '
        'ebédszünet. Biztosan emlékszel az időpontra. Mit teszel?',
    options: [
      'Utólagos bejegyzésként beírod a kiegészítés dátumával, és '
          'tájékoztatod a diszpécsert',
      'Úgy illeszted be a bejegyzést, hogy keddinek látsszon',
      'Meghagyod a hiányt — az utólagos bejegyzés csak ront a helyzeten',
    ],
    correctIndex: 0,
    explanation: 'Az őszinte, felismerhetően dátumozott javítás '
        'megengedett, és jobb, mint egy hiány. A bejegyzést úgy alakítani, '
        'mintha kedden keletkezett volna, a hanyagságtól a megtévesztésig '
        'tartó lépés — és lényegesen többet nyom a latban.',
  ),
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Ma 9,5 órát vezettél, pedig a 10 órára szóló heti kereted '
        'már elfogyott. Mit írsz be?',
    options: [
      'Pontosan 9,0 órát — hogy a lap szabályosnak nézzen ki',
      'A ténylegesen vezetett 9,5 órát',
      'Erre a napra semmit, akkor nem tűnik fel',
    ],
    correctIndex: 1,
    explanation: 'Mindig a tényleges időket írod be. Egy megszépített '
        'bejegyzés a túllépést valótlan adattá változtatja, és rontja a '
        'helyzetet. A hiányzó lap szintén önálló szabálysértés — a '
        'kihagyás nem segít.',
  ),

  // ══════════════════════════ gb5 — Magánál tartás, leadás, megőrzés
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Mely nyilvántartásokat kell magaddal vinned a járműben?',
    options: [
      'Csak az aktuális nap lapját',
      'Az aktuális naptári hét lapjait',
      'Az aktuális napot és az azt megelőző 28 napot',
    ],
    correctIndex: 2,
    explanation: 'Az utolsó 28 nap nyilvántartását kell magadnál tartanod, '
        'az aktuális nappal együtt. Az, hogy a régebbi lapok rendben a '
        'cégnél vannak, a megőrzési kötelezettséget teljesíti, de a '
        'magánál tartásit nem — ez két külön kötelezettség.',
  ),
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Meddig kell a vállalkozónak megőriznie a napi ellenőrző '
        'lapokat a cégnél?',
    options: [
      'Egy évig',
      '28 napig, utána megsemmisíthetők',
      'Három hónapig a negyedév végétől',
    ],
    correctIndex: 0,
    explanation: 'A vállalkozó egy évig megőrzi a nyilvántartást, és '
        'kérésre bemutatja. A 28 nap a sofőr magánál tartási határideje — '
        'ezt gyakran összekeverik a megőrzési határidővel.',
  ),
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Ki ellenőrzi a nyilvántartási kötelezettség betartását?',
    options: [
      'Kizárólag a rendőrség, és csak közúti ellenőrzéseknél',
      'A BAG és a rendőrség — közúti ellenőrzéseknél és a cégnél',
      'A TÜV a jármű időszakos műszaki vizsgája keretében',
    ],
    correctIndex: 1,
    explanation: 'Az ellenőrzést a BAG (Bundesamt für Logistik und '
        'Mobilität, a német szövetségi logisztikai és mobilitási hivatal) '
        'és a rendőrség végzi, az út szélén és a cégnél egyaránt. A '
        'műszaki vizsga a jármű műszaki állapotát érinti, és semmi köze a '
        'nyilvántartáshoz.',
  ),

  // ══════════════════════════ gb6 — Következmények
  DrivingQuestion(
    moduleId: 'gb6',
    question: 'Mire kell számítani, ha lapok hiányoznak vagy hiányosak?',
    options: [
      '100 eurótól induló bírságra, a súlyosságtól függően magasabbra is',
      'Semmilyen következményre — ez pusztán belső céges előírás',
      'Ingyenes figyelmeztetésre, további következmények nélkül',
    ],
    correctIndex: 0,
    explanation: 'A hiányzó vagy hiányos nyilvántartás szabálysértés; a '
        'bírság körülbelül 100 eurónál kezdődik, és a súlyossággal nő. '
        'Súlyos vagy ismételt szabálysértéseknél ezenfelül eljárás '
        'indulhat a vállalkozás megbízhatóságáról.',
  ),
  DrivingQuestion(
    moduleId: 'gb6',
    question: 'A diszpécser azt mondja: „Vidd még el a két megállót, a '
        'szünetet meg egyszerűen írd bele." Hogyan reagálsz?',
    options: [
      'Követed az utasítást — a felelősséget akkor a diszpécser viseli',
      'Kihagyod a szünetet, de legalább őszintén beírod, hogy hiányzik',
      'Megtartod a szünetet, helyesen beírod, és jelented a nyitva maradt '
          'megállókat',
    ],
    correctIndex: 2,
    explanation: 'Egy szóbeli utasítás nem szünteti meg a nyilvántartási '
        'kötelezettségedet — te írod alá a lapot, és ezzel igazolod a '
        'tartalmát. A szünet tudatos elhagyása ezenfelül a vezetési időre '
        'vonatkozó előírások megsértése lenne. A cégnek lehetővé kell '
        'tennie a szabálykövetést, nem megkerülnie.',
  ),
];
