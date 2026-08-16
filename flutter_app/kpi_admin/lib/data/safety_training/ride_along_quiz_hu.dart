// lib/data/safety_training/ride_along_quiz_hu.dart
//
// A Ride Along záróteszt kérdései — magyar változat. Tizenöt kérdés az
// öt fejezetre elosztva a ride_along_content_hu.dart fájlból (ra1 …
// ra5), fejezetenként három kérdés. A felépítés azonos a német
// alapváltozattal: ugyanaz a sorrend, ugyanazok a válaszlehetőségek és
// ugyanazok a helyes válaszok.
//
// A kérdések célja: a két kísért nap helyzetei. Több válasz szándékosan
// hangzik hihetően — mindig egy részleten múlik a döntés. Az
// `explanation` mindig mindkettőt megmagyarázza: miért helyes a jó
// válasz, és miért téves a kézenfekvő tévedés.
//
// Több cégnél használható: sehol nem kérdezünk cégspecifikus számokra
// (megállószám, Waiting Area-időpontok, parkolási oldal) — csak arra,
// ami mindenhol érvényes. Jogi alapú kivételek: § 4 ArbZG (szünetek) és
// § 1 Abs. 6 FPersV (Green Book).

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> rideAlongQuestionsHu = [
  // ══════════════════════════ ra1 — Mi az a Ride Along
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'Mi az a Ride Along?',
    options: [
      'Elméleti eligazítás az irodában az első munkanap előtt',
      'Két munkanap kísért fuvar egy tapasztalt sofőrrel trénerként',
      'Hatósági vezetési vizsga, amely nélkül nem állhatsz munkába',
    ],
    correctIndex: 1,
    explanation: 'A Ride Along két valódi munkanap a cégnél, amelyeken '
        'egy tapasztalt sofőr kísér téged, mindent elmagyaráz, majd '
        'téged hagy dolgozni. Ez sem irodai oktatás, sem hatósági vizsga '
        '— ez betanulás éles üzemben, amelyet azonban értékelnek és '
        'dokumentálnak.',
  ),
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'Hány megállót kell levezetned a két nap alatt?',
    options: [
      'Ezt a céged, illetve az állomásod határozza meg — az előírást a '
          'tréner mondja meg',
      'Mindig pontosan 20-at az első és 70-et a második napon, minden '
          'cégnél ugyanúgy',
      'Annyit, amennyit magadtól vállalsz — előírás nincs',
    ],
    correctIndex: 0,
    explanation: 'Elterjedt az első napon kevesebb, a második napon '
        'lényegesen több megálló (gyakran nagyjából 20 és nagyjából 70), '
        'de ezek egyes cégek irányértékei. Kötelező érvényű kizárólag az '
        'állomásod előírása. A kézenfekvő tévedés az, ha egy hallott '
        'számot általános szabálynak veszel — kérdezd meg a trénert, '
        'melyik szám vonatkozik rád.',
  ),
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'Az első napon lényegesen lassabb vagy a tervezettnél, és '
        'több hibát is elkövetsz rendezés közben. Hogyan hat ez az '
        'értékelésre?',
    options: [
      'A Ride Along ezzel nem teljesítettnek számít, és meg kell '
          'ismételni',
      'Nem számít, hiszen az első napon még semmit sem értékelnek',
      'Az a döntő, hogy rákérdezel-e, és utána megszünteted-e a hibát — '
          'nem a tempó',
    ],
    correctIndex: 2,
    explanation: 'Tempót az első napon senki nem vár el; pontosan ezért '
        'van a kevesebb megálló. A tanulási hajlandóságodat értékelik: '
        'rákérdezel-e, elfogadod-e a tanácsokat, harmadszorra is '
        'ugyanazt a hibát követed-e el? A tévedés mindkét irányban '
        'veszélyes — ez sem bukós vizsga, sem értékelés nélküli nap.',
  ),

  // ══════════════════════════ ra2 — Az első nap
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Miért kell a Ride Along megállóinak a saját fiókoddal '
        'futniuk?',
    options: [
      'Mert a tréner ezeken a napokon nem használhatja a saját fiókját',
      'Mert csak így látszik, hogyan kézbesítesz te magad — a te '
          'nevedben számít',
      'Mert a tréner fiókja már nem tud több új megállót fogadni',
    ],
    correctIndex: 1,
    explanation: 'Minden, amit ezeken a napokon kézbesítesz, a te '
        'nevedben fut — pontosan úgy, ahogy később a mindennapokban is. '
        'Csak így látja a tréner és a cég a tényleges munkamódszeredet, '
        'és csak így számítanak a megállók a betanulásodba. Ezért nem '
        'részletkérdés egy reggel nem működő hozzáférés, hanem ok arra, '
        'hogy azonnal szólj.',
  ),
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Mi érvényes a Mentor rögzítési idejére?',
    options: [
      'A Mentor egyhuzamban nagyjából 4 órát rögzít, és utána újra kell '
          'indítani',
      'A Mentor egyszeri indítás után a műszak végéig fut',
      'A Mentor magától elindul, amint a jármű mozogni kezd',
    ],
    correctIndex: 0,
    explanation: 'A rögzítés mindig nagyjából négy órán át tart. Utána '
        'újra kell indítanod, különben a túra többi része rögzítetlen '
        'marad. A leggyakoribb kezdő hiba pontosan ez a tévedés, hogy az '
        'alkalmazás magától végigfut: reggel helyesen elindítva, a '
        'szünet után nem bekapcsolva — és a fél nap hiányzik az '
        'értékelésből.',
  ),
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Ezen a napon 9,5 órát dolgozol. Legalább milyen hosszú '
        'legyen a szüneted?',
    options: [
      '30 perc, mert a 45 perc csak 10 órától érvényes',
      'Elég több rövid, egyenként 5–10 perces szünetet tartani',
      '45 perc, mert a munkaidő 9 óra fölött van',
    ],
    correctIndex: 2,
    explanation: 'A § 4 ArbZG (a német munkaidőtörvény) szerint 6 óránál '
        'több esetén legalább 30 perc, 9 óránál több esetén legalább 45 '
        'perc szünet kötelező — a 9,5 óra a határ fölött van. A szünet '
        'felosztható, de minden résznek legalább 15 percig kell '
        'tartania; az öt perc közbeiktatva nem számít bele.',
  ),

  // ══════════════════════════ ra3 — A második nap
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Egy jelszavas csomagnál a vevőnek nincs kéznél a kódja, de '
        'aláírná az átvételt. Mit teszel?',
    options: [
      'Nem adod át — helyes kód nélkül nincs kivétel',
      'Aláírás ellenében átadod, hiszen az ugyanúgy bizonyíték',
      'A csomagot a szomszédnál hagyod, és értesíted a vevőt',
    ],
    correctIndex: 0,
    explanation: 'A jelszó annak a bizonyítéka, hogy az átvevő valóban az '
        'átvevő — ezért adták ki. Egy aláírás vagy a rábeszélés nem '
        'pótolja, a szomszédnál hagyás pedig végképp nem. Ha a '
        'küldeményt később meg nem érkezettként jelentik, a kód nélküli '
        'átadás a te hibádként szerepel. Helyesen: kerestesd meg a '
        'kódot, különben vidd vissza szabályosan a csomagot és '
        'dokumentáld.',
  ),
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Manőverezés közben nekiérsz egy oszlopnak. Egy karcolás '
        'marad a furgonon, és senki nem látta. Mi a helyes?',
    options: [
      'Nem csinálsz semmit — egy karcolásnál idegen kár nélkül nincs mit '
          'jelenteni',
      'Megvárod, hogy egyáltalán feltűnik-e a következő ellenőrzésnél',
      'Még aznap jelented, és dokumentálod a CoDriverben',
    ],
    correctIndex: 2,
    explanation: 'Egy bejelentett kár olyan eset, amelyet feldolgoznak; '
        'ugyanaz a kár, amelyet másnap reggel valaki más talál meg az '
        'ellenőrzésénél, tisztázatlan kár — és a gyanú a végén mégis az '
        'utolsó használóra terelődik. A „ez úgysem tűnik fel" tévedés '
        'nem tartható: pontosan ezért van ellenőrzés minden túra előtt '
        'és után.',
  ),
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Mi a különbség a teljesítmény és a minőség között a '
        'Scorecardban?',
    options: [
      'A kettő ugyanaz — a Scorecard csak a megállók számát méri',
      'A teljesítmény az adott idő alatti mennyiség, a minőség az, '
          'mennyire tisztán zártál le minden egyes megállót',
      'A minőség csak a járműre vonatkozik, a teljesítmény csak a '
          'kézbesítésre',
    ],
    correctIndex: 1,
    explanation: 'A teljesítmény a mennyiség — hány megálló mennyi idő '
        'alatt. A minőség a gondosság minden egyes megállónál: megfelelő '
        'hely, szabályos dokumentálás, nulla reklamáció. Aki a kettőt '
        'egyenlővé teszi, elöl megspórol egy percet, hátul pedig '
        'utánajárást okoz, amely a cégnek annak sokszorosába kerül.',
  ),

  // ══════════════════════════ ra4 — Lezárás és leadás
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'Hányszor írja alá a tréner a Ride Along ellenőrzőlistát?',
    options: [
      'Egyszer, a második nap végén, mindkét napra együtt',
      'Egyáltalán nem — csak a diszpécser ír alá a leadáskor',
      'Naponta külön, minden alkalommal dátummal',
    ],
    correctIndex: 2,
    explanation: 'Minden napnak megvan a saját pontlistája, ezért zárják '
        'le külön-külön dátummal és aláírással. Ennek gyakorlati oka '
        'van: ha a második nap elmarad vagy áthelyezik, akkor is tisztán '
        'dokumentált, mi készült el az első napon. Egy összevont aláírás '
        'a végén pontosan ezt tenné lehetetlenné.',
  ),
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'Mi történik a kitöltött ellenőrzőlistával a második nap '
        'végén?',
    options: [
      'Fényképként leadják az illetékes diszpécsernél',
      'Hazaviszed, és otthon őrzöd meg',
      'A járműben marad, hogy a következő tréner folytathassa',
    ],
    correctIndex: 0,
    explanation: 'A lapot a második nap végén lefényképezik, és leadják '
        'az illetékes diszpécsernél — ezzel a Ride Along formálisan '
        'lezárul, és a betanulásod dokumentálva van. A járműben vagy '
        'otthon az igazolás a cég számára értéktelen. Ügyelj rá, hogy a '
        'pipák, a dátum, a nevek és az aláírások olvashatók legyenek a '
        'fényképen.',
  ),
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'A visszajelzésben az áll, hogy túl tétova vagy '
        'manőverezésnél. Hogyan reagálsz a leghasznosabban?',
    options: [
      'Elmagyarázod, hogy tudatosan óvatos voltál, és ezzel lezárod a '
          'témát',
      'Kérsz egy konkrét példát az aznapról',
      'Tudomásul veszed a visszajelzést, és legközelebb gyorsabban '
          'manőverezel',
    ],
    correctIndex: 1,
    explanation: 'Az óvatosság manőverezésnél helyes — a „tétova" '
        'rendszerint mást jelent, például a hosszas gondolkodást '
        'ahelyett, hogy röviden kiszállnál és megnéznéd. Egy konkrét '
        'példával lesz olyan pontod, amin dolgozni tudsz. A védekezés '
        'nem visz előre, az egyszerű gyorsítás pedig a három reakció '
        'közül a legveszélyesebb lenne.',
  ),

  // ══════════════════════════ ra5 — Így készülsz fel
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Mikor érdemes ellenőrizned, hogy működnek-e a '
        'hozzáféréseid a munkaidő-nyilvántartáshoz, a Mentorhoz, a '
        'Flexhez és a CoDriverhez?',
    options: [
      'Az első nap reggelén, közösen a trénerrel',
      'Csak akkor, amikor munka közben ténylegesen probléma adódik',
      'Az első nap előtt, legjobb az előző este',
    ],
    correctIndex: 2,
    explanation: 'Egy jelszó visszaállítása előző este percekbe kerül, '
        'reggel a Waiting Areában viszont fél órába — ha egyáltalán '
        'elérhető valaki. A kézenfekvő tévedés az, ha ezt a trénerre '
        'hagyod: egy zárolt hozzáférésnél ő nem tud segíteni, az idő '
        'pedig a saját fiókoddal teljesítendő megállóktól megy el.',
  ),
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Mit jelent a „pontos" a Ride Alongon?',
    options: [
      'Bevethető állapotban lenni az állomáson a műszakkezdésre — a '
          'parkolás és az odaút már bele van számolva',
      'A műszakkezdésre megérkezni az állomás kapujához',
      'Legkésőbb akkor ott lenni, amikor a Waiting Areát szólítják',
    ],
    correctIndex: 0,
    explanation: 'A műszakkezdésre bevethető állapotban vagy, nem úton. '
        'Aki csak a kapuhoz érkezik meg, időt veszít a parkolással és az '
        'udvaron való átjutással, lemarad a Waiting Area-időablakáról — '
        'és ezzel a tréner hullámát is hátratolja. Ezért tudatosan '
        'számold bele a parkolás és a gyaloglás idejét.',
  ),
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Miért érdemes a trénernek szánt kérdéseket már az 1. nap '
        'előtt felírni?',
    options: [
      'Mert a trénernek előre, írásban kell bekérnie a kérdéseket',
      'Mert tíz egymás után elmagyarázott folyamatot senki nem jegyez '
          'meg — felírva célzottan tudsz kérdezni',
      'Mert a fel nem tett kérdéseket egyébként negatívan jegyzik fel az '
          'értékelésben',
    ],
    correctIndex: 1,
    explanation: 'A tréner két nap alatt nagyon sokat magyaráz el '
        'egyszerre; estére ebből jegyzetek nélkül kevés marad. Aki '
        'előkészíti a kérdéseit, és útközben témánként két hívószót '
        'felír, sokszorosát hozza ki a két napból. Formális '
        'kötelezettség nem áll fenn — és a fel nem tett kérdéseket senki '
        'nem jegyzi fel negatívan. Pontosan ezért neked magadnak kell '
        'gondoskodnod róla.',
  ),
];
