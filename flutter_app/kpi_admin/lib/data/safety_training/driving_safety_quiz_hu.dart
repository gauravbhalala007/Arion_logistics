// lib/data/safety_training/driving_safety_quiz_hu.dart
//
// A DSP vezetesbiztonsagi trening kerdesei — magyar valtozat.
// A felepites azonos a nemet (master) valtozattal: ugyanannyi kerdes,
// ugyanaz a sorrend, ugyanazok a helyes valaszok.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> drivingQuestionsHu = [
  // ══════════════════════════════════ M1 — Biztonsági kultúra
  DrivingQuestion(
    moduleId: 'm1',
    question: '20 megállóval le vagy maradva a tervhez képest. Melyik '
        'reakció felel meg a cég biztonsági kultúrájának?',
    options: [
      'A megállók között gyorsabban hajtani, de magukon a megállókon '
          'gondosnak maradni',
      'Jelenteni a lemaradást, és a túrát a megszokott biztonságos '
          'tempóban folytatni',
      'Lerövidíteni az ellenőrzési időket manőverezéskor, a vezetést '
          'viszont változatlanul hagyni',
    ],
    correctIndex: 1,
    explanation: 'Az időnyomás tervezési probléma, amit jelenteni kell, '
        'nem a volánnál kiegyenlíteni. A másik két válasz kompromisszumnak '
        'hangzik, de csak áthelyezi a kockázatot: a magasabb tempó a '
        'megállók között pont a megállási utat hosszabbítja meg, a '
        'lerövidített manőverezési ellenőrzések pedig azt a tevékenységet '
        'érintik, amelynél az összes kár 70 %-a keletkezik.',
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'A diszpécsered utasít, hogy hibás féklámpával indulj el. '
        'Ki viseli a felelősséget, ha emiatt ráfutásos baleset '
        'történik?',
    options: [
      'A diszpécser, mert ő adta az utasítást',
      'A cég, mert ő biztosítja a járművet',
      'Senki — egyetlen féklámpa nem biztonsági szempontból releváns '
          'hiba',
      'Te mint járművezető',
    ],
    correctIndex: 3,
    explanation: 'Járművezetőként te felelsz annak a járműnek a '
        'közlekedésbiztos állapotáért, amelyet mozgatsz — egy szóbeli '
        'utasítás ezt nem szünteti meg. Az, hogy a cég adja a járművet, '
        'kézenfekvőnek hangzik, de nem mentesít: a bírság és a pontok '
        'téged érintenek személyesen. Helyes a hibát jelenteni és másik '
        'járművet kérni.',
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Manőverezéskor csak néhány centiméter hiányzott egy '
        'oszlopig — nem történt semmi. Mi a helyes?',
    options: [
      'Majdnem-balesetként jelenteni',
      'Nem tenni semmit, hiszen nem keletkezett kár és senki nem került '
          'veszélybe',
      'Csak akkor jelenteni, ha egy kolléga vagy egy kamera észlelte',
    ],
    correctIndex: 0,
    explanation: 'Egy majdnem-baleset megmutat egy veszélyes pontot, '
        'mielőtt bárkit érintene — bejelentve a következő kollégánál már '
        'ártalmatlanítva van. A „nincs kár, nincs téma" gondolat a '
        'leggyakoribb oka annak, hogy ugyanaz a hely hetekkel később '
        'mégis kárhoz vezet.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Melyik tevékenységnél keletkezik az összes furgonkár '
        'nagyjából 70 %-a?',
    options: [
      'Autópályán és országúton nagy sebességnél',
      'Kereszteződésekben kanyarodáskor a városi forgalomban',
      'Manőverezéskor és tolatáskor',
    ],
    correctIndex: 2,
    explanation: 'A károk túlnyomó többsége lépéstempóban, manőverezés '
        'közben keletkezik. A nagy sebesség a legsúlyosabb baleseteket '
        'okozza, de nem a legtöbb kárt — pont ez a felcserélés vezet '
        'oda, hogy manőverezéskor túl kevéssé figyelnek.',
  ),

  // ══════════════════════════════════ M2 — Járműcheck és rakomány
  DrivingQuestion(
    moduleId: 'm2',
    question: 'A rakományt a technika elismert szabályai szerint 0,8 g '
        'ellen kell előre rögzíteni. Ez egy 20 kg-os csomagnál '
        'nagyjából mekkora visszatartó erőnek felel meg?',
    options: [
      'kb. 2 kg',
      'kb. 8 kg',
      'kb. 16 kg',
      'kb. 200 kg',
    ],
    correctIndex: 2,
    explanation: '0,8 × 20 kg nagyjából 16 kg visszatartó erőt ad. A '
        '„kb. 2 kg" drámaian alábecsüli az erőt, és ez az oka annak, hogy '
        'a csomagokat ártalmatlannak tartják; a „200 kg" összekeveri a '
        'rögzítési előírást a valódi ütközésnél fellépő ütőerővel, ami '
        'ténylegesen még ennél is jóval nagyobb.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Hogyan rakodod meg helyesen a rakteret?',
    options: [
      'Nehezet le és előre a válaszfalhoz, a súlyt egyenletesen '
          'elosztva',
      'Nehezet fel, hogy a nehéz csomagok ne kerüljenek a könnyűek alá '
          'nyúláskor',
      'Nehezet hátra az ajtóhoz, hogy a nehéz küldemények jöjjenek ki '
          'először',
    ],
    correctIndex: 0,
    explanation: 'A nehéz + mélyen + elöl alacsonyan tartja a súlypontot '
        'és oda teszi a tömeget, ahol a válaszfal fel tudja fogni. A '
        'másik két változat a munkafolyamat szerint gondolkodik, nem a '
        'fizika szerint: a fenti súly növeli a borulási hajlamot, a hátsó '
        'súly tehermentesíti az első tengelyt és rontja a kormányzást.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'A túra kétharmada után a raktér félig üres. Mi érvényes '
        'most a rakományrögzítésre?',
    options: [
      'Kevésbé fontos, mert lényegesen kevesebb súly van a fedélzeten',
      'Újra kell készíteni — a maradék csomagoknak most több útjuk van, '
          'hogy sebességre tegyenek szert',
      'Változatlanul érvényes, nincs mit tenni',
    ],
    correctIndex: 1,
    explanation: 'Minél üresebb a raktér, annál nagyobb az a szakasz, '
        'amelyen egy csomag gyorsulhat, mielőtt becsapódik. A „kevesebb '
        'súly, kevesebb veszély" logikusan hangzik, de téves: nem az '
        'össztömeg a döntő, hanem az egyes rögzítetlen csomag.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Mit követel tőled a DGUV Vorschrift 70 (Fahrzeuge) a '
        'munkaműszak kezdete előtt?',
    options: [
      'Műszaki vizsgálatot emelővel és fékpadon',
      'A jármű ellenőrzését szemmel látható hibákra',
      'Ellenőrzést csak olyan járműveknél, amelyeket először vezetsz',
    ],
    correctIndex: 1,
    explanation: 'A műszak előtti, szembeötlő hibákra irányuló '
        'ellenőrzést követeli meg — pont azt, amit a körbejárás nyújt. A '
        'műszaki vizsgálat a szerviz dolga, és nem pótolja a '
        'körbejárásodat; a kötelezettség pedig minden járműre és minden '
        'napra vonatkozik, nem csak az ismeretlenekre.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Milyen profilmélységet ír elő legalább a törvény — és mi '
        'ésszerű nedves úton?',
    options: [
      '3 mm törvényileg; nedvesen akkor elég 1,6 mm',
      '1,6 mm törvényileg; ez nedvesen is változatlanul elég',
      '4 mm törvényileg, egész évben minden gumira',
      '1,6 mm törvényileg; nedvesen legalább 3 mm ésszerű',
    ],
    correctIndex: 3,
    explanation: 'A törvényi minimum 1,6 mm, gyakorlatilag nedves úton '
        'legalább 3 mm ésszerű. Az „1,6 mm nedvesen is elég" válasz a '
        'klasszikus tévedés: a minimum a szabálysértés határa, nem a '
        'biztonságé — 1,6 mm-nél a gumi már alig szorít ki vizet.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'A következő megálló csomagja az anyósülésen fekszik, hogy '
        'gyorsan meg tudd fogni. Mi ezzel a fő probléma?',
    options: [
      'A csomag fékezéskor lövedékké válik, és a fékpedál alá kerülhet',
      'Egy közúti ellenőrzésnél rendetlennek látszik',
      'Megengedett, amíg a csomag kevesebb mint 10 kg',
    ],
    correctIndex: 0,
    explanation: 'A vezetőfülkében minden a kiindulási sebességeddel '
        'halad tovább fékezéskor — a legrosszabb esetben a lábtérbe, a '
        'pedál alá. Súlyhatár erre nincs: egy könnyű csomag is blokkol '
        'egy pedált.',
  ),

  // ══════════════════════════════════ M3 — Védekező vezetés
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Lakott területen kívül 80 km/h-val hajtasz száraz úton. '
        'Mekkora követési távolság a helyes legalább?',
    options: [
      'Kb. 20 méter — ez három járműhossznak felel meg',
      'Kb. 45 méter — nagyjából két másodperc, illetve a sebességmérő '
          'értékének fele',
      'Kb. 10 méter, amíg figyelmes vagy és szabad az út',
    ],
    correctIndex: 1,
    explanation: 'Két másodperc 80 km/h-nál nagyjából 45 méter, a '
        'sebességmérő fele 40 méter — a kettő összeillik. A 20 méter az '
        'úton soknak tűnik, de a 24 méteres puszta reakcióút alatt van: '
        'ráfutottál volna, mielőtt a fék egyáltalán fog.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Milyen hosszú a megállási út 50 km/h-nál a '
        'hüvelykujjszabályok szerint (normál fékezés)?',
    options: [
      '15 méter',
      '25 méter',
      '40 méter',
      '65 méter',
    ],
    correctIndex: 2,
    explanation: 'Reakcióút (50 ÷ 10) × 3 = 15 m plusz fékút '
        '(50 ÷ 10)² = 25 m, összesen 40 m. Aki 25 métert mond, csak a '
        'fékutat számolta és elfelejtette a reakcióutat — ez a '
        'leggyakoribb számolási hiba, és pont az a szakasz, amit teljes '
        'sebességgel teszel meg.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Hogyan számolod ki a reakcióutat a hüvelykujjszabály '
        'szerint?',
    options: [
      '(tempó ÷ 10) × 3',
      '(tempó ÷ 10) × (tempó ÷ 10)',
      'tempó ÷ 2',
    ],
    correctIndex: 0,
    explanation: 'A reakcióút (km/h ÷ 10) × 3. A második képlet a fékút, '
        'a harmadik a követési távolság hüvelykujjértéke — hasonlóan '
        'néznek ki, de teljesen mást írnak le.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Megduplázod a tempódat 30-ról 60 km/h-ra. Hogyan '
        'változik a puszta fékút?',
    options: [
      'Megduplázódik',
      'Megnégyszereződik',
      'Megháromszorozódik',
      'Nagyjából ugyanaz marad, mert a fék nagyobb tempónál erősebben '
          'fog',
    ],
    correctIndex: 1,
    explanation: 'A fékút a sebesség négyzetével nő: 9 méterből 36 méter '
        'lesz. A kézenfekvő „megduplázódik" válasz pont ezt becsüli alá — '
        'ez magyarázza, miért érzik ártalmatlannak a 20 km/h többletet '
        'egy lakóutcában.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Miért kell teljesen megrakott furgonnal lényegesen '
        'lassabban menni a kanyarban, mint egy személyautóval?',
    options: [
      'Mert a magas súlypont erősen növeli a borulási hajlamot',
      'Mert a kormányzás terhelés alatt pontatlanabb lesz',
      'Mert a gumik teher alatt puhábbak lesznek és jobban tapadnak',
    ],
    correctIndex: 0,
    explanation: 'Egy magasra rakott dobozos furgon ott borul, ahol egy '
        'személyautó még csúszik — és alig jelzi előre. A '
        'kormánypontosság is változik ugyan, de nem az a valódi '
        'kockázat: a borulás hirtelen történik és az úttesten kívül '
        'végződik.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Egy lámpánál jobbra akarsz kanyarodni, egy kerékpáros '
        'jobbra melletted áll. A lámpa zöldre vált. Mit teszel '
        'először?',
    options: [
      'Gyorsan elindulni és bekanyarodni, mielőtt a kerékpáros '
          'lendületbe jön',
      'A jobb külső tükörbe nézni és aztán bekanyarodni',
      'Vállpillantás jobbra és a kerékpárost átengedni',
    ],
    correctIndex: 2,
    explanation: 'Amint elindulsz és bekanyarodsz, a kerékpáros a '
        'holttérbe kerül — és a jármű hátulja ráadásul belendül a '
        'sávjába. A tükörbe nézés helyesnek hangzik, de pont akkor nem '
        'elég, amikor számít: a tükör nem mutatja teljesen a '
        'vezetőfülke melletti jobb oldali zónát.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Mekkora oldaltávolságot kell tartanod lakott területen '
        'egy kerékpáros előzésekor?',
    options: [
      '1,0 méter',
      '1,5 méter',
      '2,0 méter',
    ],
    correctIndex: 1,
    explanation: 'Lakott területen 1,5 méter, azon kívül 2,0 méter. Aki '
        'a 2,0 métert tartja a lakott területi értéknek, összekeveri a '
        'kettőt — aki pedig 1,0 méterrel előz, alálépi a minimális '
        'távolságot, és felel a kerékpáros esésénél.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Milyen messzire előre irányuljon a tekinteted vezetés '
        'közben?',
    options: [
      'Az előtted haladó lökhárítójára, hogy azonnal lásd a fékezését',
      'A saját motorháztetőre, mert így tartod a legpontosabban a '
          'sávot',
      '12–15 másodperccel előre',
    ],
    correctIndex: 2,
    explanation: 'A távoli tekintet időt ad neked: látod a lámpákat, a '
        'féklámpákat és a gyalogosokat, mielőtt reagálnod kellene. A '
        'lökhárítóra nézés figyelmesnek érződik, de puszta reagálóvá '
        'tesz — csak akkor értesülsz a veszélyről, amikor az előtted '
        'haladó már fékez.',
  ),

  // ══════════════════════════════════ M4 — Tolatás és manőverezés
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Mit jelent a GOAL tolatáskor?',
    options: [
      '„Get Out And Look" — megállni, kiszállni, megnézni a jármű '
          'mögötti területet',
      '„Go Only At Low speed" — kizárólag lépéstempóban tolatni',
      '„Guide On A Line" — egy padlójelöléshez igazodni',
    ],
    correctIndex: 0,
    explanation: 'A GOAL azt jelenti: kiszállni és megnézni — feltárja '
        'az alacsony oszlopokat, a lejtőt és a gyerekeket, akiket az '
        'ülésből sosem látsz. A lépéstempó ugyan szintén kötelező, de '
        'nem pótolja a megnézést: lépésben is olyan zónába hajtasz, '
        'amelyet nem látsz be.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'A járműved tolatókamerával van felszerelve. Mit '
        'változtat ez a GOAL-on?',
    options: [
      'A GOAL elmarad, mert a kamera mutatja a jármű mögötti területet',
      'Semmit',
      'A GOAL ezzel már csak sötétben és rossz látási viszonyoknál '
          'szükséges',
    ],
    correctIndex: 1,
    explanation: 'A kamera csak egy kivágatot mutat, torzítja a '
        'távolságokat és megvakul az esőtől, a hótól és a kosztól — '
        'mindenekelőtt nem látja, mi lép oldalról a pályádba. Kiegészíti '
        'a GOAL-t, de sosem pótolja.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Hol áll helyesen egy irányító?',
    options: [
      'Közvetlenül a jármű mögött, mert onnan tudja legjobban megítélni '
          'a távolságot',
      'A jármű előtt, hogy egyúttal megállítsa a forgalmat',
      'Oldalt, úgy, hogy folyamatosan lásd őt a tükörben',
    ],
    correctIndex: 2,
    explanation: 'Csak az tud biztonságosan irányítani, aki oldalt és '
        'tartósan láthatóan áll. A közvetlenül a jármű mögötti pozíció '
        'ugyan a legközelebb van a történéshez, de pont az a zóna, '
        'amelyben magát az irányítót gázolják el, amint kikerül a '
        'látóteredből.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Hirtelen nem látod többé az irányítót a tükörben. Mit '
        'teszel?',
    options: [
      'Lassabban továbbhaladni, amíg újra felbukkan',
      'Azonnal megállni',
      'Röviden dudálni és továbbhaladni, hogy újra megmutassa magát',
    ],
    correctIndex: 1,
    explanation: 'A szemkontaktus hiánya azt jelenti: nincs érvényes jel '
        '— tehát megállni, nem csak lassítani. A „lassabban '
        'továbbhaladni" óvatosnak hangzik, de azt jelenti, hogy továbbra '
        'is olyan zónába hajtasz, amelyet már senki nem figyel '
        'helyetted.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Mit követel a § 9 Abs. 5 StVO tolatáskor?',
    options: [
      'Az elakadásjelző bekapcsolását',
      'Legfeljebb lépéstempóval haladni',
      'Kizárni mások veszélyeztetését — szükség esetén irányítóval',
    ],
    correctIndex: 2,
    explanation: 'Az előírás minden veszélyeztetés kizárását követeli '
        'meg, szükség esetén irányítóval — a mérce tehát az eredmény, '
        'nem egy meghatározott sebesség. A lépéstempó és az '
        'elakadásjelző jó gyakorlat, de önmagában nem teljesíti a '
        'kötelezettséget.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Az utolsó megálló egy szűk belső udvarban van: előre be '
        'tudsz hajtani, kifelé csak tolatva, egy fal mellett. Mi a '
        'legbiztonságosabb döntés?',
    options: [
      'Megállni az utcán, és az utolsó métereket gyalog, illetve '
          'kézikocsival megtenni',
      'Előre behajtani, mert akkor a bejárót már ismerem a visszaútra',
      'Gyorsan hátramenetben behúzni, amíg szabad az utca',
    ],
    correctIndex: 0,
    explanation: 'A legbiztonságosabb tolatás az, amelyik meg sem '
        'történik. Az, hogy az ember „a behajtás után már ismeri" a '
        'bejárót, tévedés: kifelé a kritikus pontok mögötted vannak, és '
        'a várakozó forgalom ráadásul nyomást szül.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M5 — Időjárás és látás
  DrivingQuestion(
    moduleId: 'm5',
    question: 'A kormány hirtelen könnyűvé válik, a gumik felúsznak egy '
        'vízfilmen. Mit teszel?',
    options: [
      'Erősen fékezni és ellenkormányozni',
      'Levenni a gázt, a kormányt nyugodtan egyenesen tartani, hagyni '
          'kigurulni',
      'Gyorsítani, hogy gyorsan elhagyd a vizes szakaszt',
    ],
    correctIndex: 1,
    explanation: 'Amíg a vízfilm tart, a fék és a kormány nem hat — csak '
        'akkor hatnak hirtelen, amikor a gumi újra fog, és pont ebből '
        'keletkezik a megcsúszás. A fékezés és az ellenkormányzás az '
        'ösztönös, de hibás reakció.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Mitől függ leginkább az aquaplaning veszélye?',
    options: [
      'A rakomány súlyától',
      'A jármű és a fékrendszer korától',
      'A profilmélységtől, a víz magasságától és mindenekelőtt a '
          'sebességtől',
    ],
    correctIndex: 2,
    explanation: 'A veszély aránytalanul nő a sebességgel és csökken a '
        'profilmélységgel — a profilnak kell elvezetnie a vizet a gumi '
        'elől. A rakomány mellékszerepet játszik: a nagyobb súly ugyan '
        'erősebben nyomja a gumit az útra, de nem változtat azon, hogy '
        'egy lapos profil tempónál már nem szorít ki vizet.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Ködben még körülbelül 40 méterre látsz. Milyen gyorsan '
        'hajthatsz legfeljebb?',
    options: [
      'Legfeljebb 40 km/h',
      'A megengedett legnagyobb sebességig, amíg ég a világítás',
      'Legfeljebb 80 km/h, ha a hátsó ködlámpa be van kapcsolva',
    ],
    correctIndex: 0,
    explanation: 'Hüvelykujjszabály: a látótávolság méterben a felső '
        'határod km/h-ban — 40 méter látásnál tehát 40 km/h. A világítás '
        'és a hátsó ködlámpa láthatóbbá tesz, de nem hosszabbítja meg a '
        'látótávolságodat, és így a megengedett tempót sem.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Mikor ír elő a § 2 Abs. 3a StVO télre alkalmas gumit?',
    options: [
      'Mindig októbertől húsvétig, az időjárástól függetlenül',
      'Jégen, hósíkosságon, latyakban, jég- vagy zúzmarasíkosságon',
      'Csak akkor, ha összefüggő hótakaró van az úttesten',
    ],
    correctIndex: 1,
    explanation: 'Németországban helyzetfüggő kötelezettség érvényes: az '
        'út állapotától függ, nem a naptártól. Az „októbertől húsvétig" '
        'csak gyakorlati emlékeztető a gumicseréhez, és nem jogalap — és '
        'már a latyak is elég, nem kell összefüggő hótakaró.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Csontfagy van és időnyomás alatt vagy. A szélvédőnek csak '
        'a vezetőoldalát kaparod le. Mi érvényes?',
    options: [
      'Megengedett, amíg lényegesen lassabban hajtasz',
      'Megengedett, ha a fűtés menet közben szabaddá teszi a többit',
      'Nem megengedett — minden ablaknak, tükörnek, lámpának és a '
          'rendszámnak szabadnak kell lennie',
    ],
    correctIndex: 2,
    explanation: 'A kikapart „kukucskálólyuk" szabálysértés, és baleset '
        'esetén súlyos felróhatóság. Az, hogy a fűtés utólag megoldja, '
        'nem kivétel: az induláskori állapot a mérvadó, nem a három '
        'perccel későbbi.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Miért különösen veszélyeztetett egy ÜRES dobozos furgon '
        'viharban?',
    options: [
      'Mert hiányzik róla a rakomány súlya, ami az úton tartja',
      'Mert a légellenállás rakomány nélkül nagyobb',
      'Mert a guminyomás üres állapotban magasabb',
    ],
    correctIndex: 0,
    explanation: 'A támadási felület üresen és megrakva ugyanakkora, a '
        'tömeg viszont jóval kisebb — ugyanaz a széllökés tehát '
        'erősebben tolja el a járművet. A légellenállás a belső '
        'rakománytól egyáltalán nem változik, ez a gondolati hiba.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M6 — Figyelem és fáradtság
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Kézbe veheted menet közben a telefont, hogy zenét válts?',
    options: [
      'Igen, ha csak egy másodpercig tart és szabad az út',
      'Csak a piros lámpánál',
      'Nem',
    ],
    correctIndex: 2,
    explanation: 'Már az eszköz kézbe vétele vagy tartása maga a '
        'szabálysértés — függetlenül attól, mire. A piros lámpa nem '
        'kivétel, amíg jár a motor. A zenét, a célt és a hangerőt '
        'indulás előtt, álló helyzetben állítod be.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Mikor veheted jogilag kézbe a telefont vagy a '
        'szkennert?',
    options: [
      'Csak akkor, ha a jármű áll ÉS a motor ki van kapcsolva',
      'Amint a jármű áll — a start-stop automatika elég ehhez',
      'Röviden menet közben, ha az útszakasz egyenes és szabad',
    ],
    correctIndex: 0,
    explanation: 'A kivétel csak álló járműnél, kikapcsolt motorral '
        'érvényes. A start-stop automatika kifejezetten nem számít — '
        'pont erre hagyatkoznak sokan a piros lámpánál, és ott kapják '
        'meg a bírságukat.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: '50 km/h-val hajtasz és 2 másodpercig a kijelzőre nézel. '
        'Milyen messzire mész közben anélkül, hogy látnád az utat?',
    options: [
      'kb. 8 méter',
      'kb. 28 méter',
      'kb. 14 méter',
      'kb. 50 méter',
    ],
    correctIndex: 1,
    explanation: 'Az 50 km/h nagyjából 14 méter másodpercenként, 2 '
        'másodperc alatt tehát körülbelül 28 méter. Aki a „14 métert" '
        'választja, csak egy másodpercet számolt — tipikus hiba, amitől '
        'a vak szakasz felére csökkentnek látszik.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: '80-as tempónál 4 másodpercre elbóbiskolsz. Mekkora '
        'szakaszt teszel meg kontroll nélkül?',
    options: [
      'kb. 30 méter',
      'kb. 50 méter',
      'kb. 90 méter',
      'kb. 160 méter',
    ],
    correctIndex: 2,
    explanation: 'A 80 km/h nagyjából 22 méter másodpercenként, szorozva '
        '4-gyel körülbelül 89 méter. A telefonra pillantással ellentétben '
        'ez alatt egyáltalán nem kormányzol — a jármű kisodródik a '
        'sávból. Ezért olyan veszélyes egy „rövid" elbóbiskolás '
        'elképzelése.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Mi segít valóban a volánnál jelentkező akut fáradtság '
        'ellen?',
    options: [
      'Ablakot nyitni és hangos zene',
      'Kávét inni és gyorsabban hajtani, hogy előbb végezz',
      'Megállni, 15–20 perc rövid alvás, utána mozgás',
    ],
    correctIndex: 2,
    explanation: 'Csak az alvás és a mozgás állítja helyre a figyelmet. '
        'A friss levegő és a hangos zene legfeljebb néhány percig hat, és '
        'közben éberséget színlel — pont ebben a fázisban becsüli túl '
        'magát az ember a legjobban.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Egy fülhallgató a kihangosításhoz, a másik fül szabadon — '
        'rendben van ez menet közben?',
    options: [
      'Igen, egy szabad fül elég a forgalomhoz',
      'Igen, amíg a hangerő alacsonyra van állítva',
      'Nem',
    ],
    correctIndex: 2,
    explanation: 'Biztosan be kell tudnod mérni a dudálást, a '
        'kiáltásokat és a megkülönböztetett járműveket — és ehhez mindkét '
        'fülre szükséged van; manőverezéskor a hallás gyakran az egyetlen '
        'figyelmeztetés. Az alacsony hangerő nem változtat azon, hogy az '
        'egyik fül foglalt.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Mi fenyeget, ha kézben tartott telefonnal veszélyeztetsz '
        'egy másik közlekedőt?',
    options: [
      '100 € és 1 pont',
      '150 €, 2 pont és 1 hónap vezetéstől eltiltás',
      'Szóbeli figyelmeztetés bejegyzés nélkül',
    ],
    correctIndex: 1,
    explanation: 'A 100 € és 1 pont az alaptényállás veszélyeztetés '
        'nélkül; ha veszélyeztetés is társul hozzá, 150 €-ra, 2 pontra és '
        'egy hónap vezetéstől eltiltásra emelkedik. Számodra hivatásos '
        'sofőrként nem a pénz a probléma, hanem az eltiltás.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'A mai túraterv biztonságosan nem teljesíthető. Mi a '
        'helyes reakció?',
    options: [
      'Biztonságosan tovább dolgozni és a tervezési problémát korán '
          'jelenteni',
      'A szüneteket elhagyni és a manőverezési ellenőrzéseket '
          'lerövidíteni',
      'A megállók között gyorsabban hajtani és ott behozni az időt',
    ],
    correctIndex: 0,
    explanation: 'A tervet kell igazítani, nem a biztonságot. Ráadásul az '
        'időpont a döntő: egy kora délutáni jelzés még tud hatni, egy '
        'esti már nem. A szünetek elhagyása súlyosbítja a problémát, '
        'mert pont akkor esik le a figyelmed.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M7 — Ki-/beszállás és emelés
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Hogyan szól a BG Verkehr hárompontos szabálya („2+1") be- '
        'és kiszálláskor?',
    options: [
      'Egy kéz és két láb mindig a járművön van',
      'Két kéz és egy láb mindig érintkezik a járművel',
      'Mindkét láb a földön áll, mielőtt elengeded a kapaszkodókat',
    ],
    correctIndex: 1,
    explanation: 'Két kéz plusz egy láb három szilárd pontot ad, így '
        'egyetlen megcsúszás sosem vezet eséshez. A „mindkét láb előbb a '
        'földre" pont azt a pillanatot írja le, amikor egyáltalán nincs '
        'már fogásod — ez az ugrásos változat.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Hogyan szállsz ki helyesen a vezetőfülkéből?',
    options: [
      'Előre, háttal az ajtónak, az utolsó lépést ugorva',
      'Oldalra kifordulni az ülésből és mindkét lábra érkezni',
      'Háttal kifelé, arccal a jármű felé, mint egy létrán',
    ],
    correctIndex: 2,
    explanation: 'Csak arccal a jármű felé tudod használni a '
        'kapaszkodókat és a fellépőt, és tudsz három érintkezési pontot '
        'tartani. Az ülésből való kifordulás gyorsabbnak tűnik, de a '
        'térdet és a bokaízületet egyszerre terheli a teljes '
        'testsúllyal — ez a leggyakoribb kiszállási hiba.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Ezek közül melyik fogás NEM számít biztonságos '
        'érintkezési pontnak?',
    options: [
      'A kapaszkodó az A-oszlopon',
      'Az ajtóperem',
      'A kapaszkodó az ajtókereten',
    ],
    correctIndex: 1,
    explanation: 'Az ajtóperem mozgó alkatrészhez tartozik: az ajtó '
        'engedhet vagy becsapódhat, pont amikor ráhelyezed a súlyodat. '
        'Ugyanez érvényes a kormányra, az ülésre, a gumira és a '
        'kerékagyra — biztonságos pont csak az erre szolgáló '
        'kapaszkodó.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'A kezedben van a szkenner és egy csomag, és ki akarsz '
        'szállni a raktérből. Mi a helyes?',
    options: [
      'Mindkettőt előbb letenni, aztán szabad kézzel leszállni',
      'A csomagot a hónod alá csípni és a szabad kezeddel kapaszkodni',
      'Gyorsan kiszállni, hiszen csak két fok',
    ],
    correctIndex: 0,
    explanation: 'Tele kézzel nincs három érintkezési pontod, és nem '
        'tudsz felfogni egy esést. Az egykezes változat kompromisszumnak '
        'hangzik, de pont az a helyzet, amelyben egy megcsúszás '
        'közvetlenül eséshez vezet: egy pont nem tart meg téged.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Az út szélén állsz meg és ki akarod nyitni a '
        'vezetőajtót. Mi védi legjobban a hátulról érkező '
        'kerékpárost?',
    options: [
      'Az ajtót csak résnyire nyitni és röviden várni',
      'Az ajtót gyorsan és szélesre nyitni, hogy jól látható legyen',
      'Nyitás előtt röviden a külső tükörbe nézni',
      'Vállpillantás és tükör — és az ajtót a távolabbi kézzel nyitni',
    ],
    correctIndex: 3,
    explanation: 'A távolabbi kézzel való fogás automatikusan '
        'hátrafordítja a felsőtestedet és kikényszeríti a pillantást. A '
        'rövid tükörpillantás önmagában nem elég, mert egy kerékpáros a '
        'holttérben pont akkor nem látható; a résnyi nyitás pedig nem '
        'figyelmeztet senkit, aki már melletted van.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Mi a legveszélyesebb kombináció a gerinc számára '
        'emeléskor?',
    options: [
      'Megemelni és közben elcsavarni a felsőtestet',
      'Erősen behajlított térddel, guggolásból megemelni',
      'A terhet szorosan a testhez véve megemelni',
    ],
    correctIndex: 0,
    explanation: 'A teher plusz csavarodás egyoldalúan terheli a '
        'porckorongokat, és ez az akut hátsérülések klasszikus oka — '
        'helyette lépj át a lábaiddal. A guggolás és a testközeli teher '
        'ezzel szemben pont a helyes technika.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Kiszálláskor enyhén kificamodik a bokád, de tudsz tovább '
        'dolgozni. Mi a helyes?',
    options: [
      'Kivárni, és csak akkor jelenteni, ha másnap még fáj',
      'Nem tenni semmit — csak egy kificamodás volt, kiesés nélkül',
      'Azonnal jelenteni és bevezetni a sérülési naplóba',
    ],
    correctIndex: 2,
    explanation: 'Csak a dokumentált eseteket ismerik el később '
        'munkabalesetként, és egy kezeletlen szalagprobléma rosszabbul '
        'gyógyul. A másnapig való várakozás elterjedt, és pont ez az oka '
        'annak, hogy a munkával való összefüggést később gyakran már nem '
        'ismerik el.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M8 — Bejárati ajtó, környezet
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Egy nagy kutya ugat a kertkapunál. Az ügyfél a '
        'szállítási megjegyzésbe azt írta: „A kutya kedves." Mit '
        'teszel?',
    options: [
      'Nyugodtan bemenni — az ügyfél ismeri legjobban a kutyáját',
      'Nem belépni az ingatlanra, kapcsolatot próbálni és a megjegyzést '
          'a kollégáknak berögzíteni',
      'A csomagot a kerítésen áttenni és továbbhajtani',
    ],
    correctIndex: 1,
    explanation: 'Egy szállítási megjegyzés nem biztonsági engedély: az '
        'ügyfél a családdal való bánásmódban ismeri a kutyáját, nem egy '
        'idegen emberrel szemben, aki nagy tárgyat cipel. A csomagot a '
        'kerítésen áttenni ráadásul nem szabályszerű kézbesítés.',
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Egy szabadon futó kutya ugatva feléd jön. Mi a helyes?',
    options: [
      'Nyugodtan állva maradni, elfordítani a tekintetet, feléje '
          'fordítani az oldalad és lassan hátrálni',
      'Gyorsan visszafutni a járműhöz és becsukni az ajtót',
      'Hangoskodni és a csomagot védekezésül felemelni',
    ],
    correctIndex: 0,
    explanation: 'A nyugalom, az elfordított tekintet és a lassú hátrálás '
        'elveszi a kutya indokát. A járműhöz futni ésszerűen hangzik, de '
        'hibás: az elfutás kiváltja a vadászösztönt, és a kutya gyorsabb '
        'nálad.',
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'A legrövidebb út a bejárati ajtóhoz egy nedves gyepen '
        'vezet át. Mit teszel?',
    options: [
      'Átvágni — 120 megállónál a kerülő jelentősen összeadódik',
      'Átvágni, de csak nappal és száraz időben',
      'A burkolt utat választani',
    ],
    correctIndex: 2,
    explanation: 'A botlás, a csúszás és az esés a leggyakoribb sérülési '
        'ok a kézbesítésben, és szinte mindig az utolsó métereken '
        'történik. A számítás nem jön ki: a kerülő másodpercekbe kerül, '
        'egy esés átlagosan 24 kiesett munkanapba.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Mi érvényes, ha egy kézbesítéshez elhagyod a járművet?',
    options: [
      'Motor le, kulcsot magaddal, bezárni, lejtőn a kerekeket '
          'elfordítani',
      'A motor járhat, amíg látótávolságon belül maradsz',
      'Elég a kéziféket erősen behúzni',
    ],
    correctIndex: 0,
    explanation: 'Aki elhagyja a járművét, köteles azt a jogosulatlan '
        'használat ellen biztosítani és a baleseteket elkerülni. A '
        '„látótávolságon belül" nem kivétel — egy járó motorral nyitva '
        'hagyott jármű másodpercek alatt eltűnik, lejtőn pedig a kézifék '
        'önmagában nem tart meg megbízhatóan egy megrakott furgont.',
  ),

  // ══════════════════════════════════ M9 — Vészhelyzet és baleset
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Milyen sorrendben cselekszel egy sérültes baleset '
        'helyszínén?',
    options: [
      'Elsősegélyt nyújtani, aztán biztosítani, aztán leadni a '
          'segélyhívást',
      'Biztosítani, aztán segélyhívás, aztán elsősegély',
      'Segélyhívás, aztán fotók a biztosítónak, aztán elsősegély',
    ],
    correctIndex: 1,
    explanation: 'Előbb biztosítani a helyszínt, különben egy balesetből '
        'kettő lesz — veled mint áldozattal. Azonnal a sérülthöz szaladni '
        'emberileg helyesnek tűnik, de országúton és autópályán '
        'életveszélyes; a fotóknak ebben a fázisban egyáltalán nincs '
        'helyük.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Milyen távolságra állítod ki az elakadásjelző '
        'háromszöget az autópályán?',
    options: [
      'kb. 50 méter',
      'kb. 100 méter',
      'kb. 150–200 méter',
    ],
    correctIndex: 2,
    explanation: 'Lakott területen kb. 50 m, azon kívül kb. 100 m, '
        'autópályán 150–200 m — minél nagyobb a tempó, annál előbb kell '
        'állnia a figyelmeztetésnek. Aki a lakott területen kívüli '
        'értéket veszi, 120 km/h-nál alig ad három másodpercet a mögötte '
        'jövő forgalomnak. Bukkanók és kanyarok elé tartozik a '
        'háromszög, nem mögé.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Egy háromsávos autópályán akadozik a forgalom. Hol '
        'alakítod ki a mentősávot?',
    options: [
      'A bal és a középső sáv között',
      'A középső és a jobb sáv között',
      'A leállósávon',
      'Az úttest közepén, a sávok számától függetlenül',
    ],
    correctIndex: 0,
    explanation: 'A sáv mindig a legszélső bal és a közvetlenül mellette '
        'jobbra lévő forgalmi sáv között van — függetlenül attól, hány '
        'sáv van. A leállósáv nem alternatíva: ott haladnak a mentőerők, '
        'ha a sáv el van torlaszolva.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Mikor kell kialakítani a mentősávot?',
    options: [
      'Csak amikor kék villogó látható vagy hallható',
      'Amint a forgalom akadozni kezd',
      'Csak amikor a kijelzőtábla elrendeli',
    ],
    correctIndex: 1,
    explanation: 'A sáv az akadozással jön létre, nem a kék villogóval. '
        'Ha az ember megvárja a megkülönböztetett járművet, a járművek '
        'már rég túl közel állnak — akkor senkinek nincs helye kitérni.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Manőverezés közben megrongálsz egy parkoló autót, senki '
        'nincs a közelben. Elég egy cédula az ablaktörlő alatt?',
    options: [
      'Igen, ha név és telefonszám van rajta',
      'Igen, a cédula a törvényben előírt út',
      'Nem — csak akkor elég, ha ráadásul fotókat is készítesz',
      'Nem — megfelelő ideig várnod kell, különben értesítened kell a '
          'rendőrséget',
    ],
    correctIndex: 3,
    explanation: 'Egy cédula jogilag nem számít elegendő azonosításnak — '
        'elrepülhet vagy eltávolíthatják; aki erre hagyatkozik, a '
        'cserbenhagyás vádját kockáztatja. A fotók ugyan dokumentálják a '
        'kárt, de nem pótolják sem a várást, sem a bejelentést.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Egy személy a baleset után nem lélegzik normálisan. Mit '
        'teszel?',
    options: [
      'Azonnal elkezdeni a mellkasi nyomkodást, körülbelül percenként '
          '100–120-szor',
      'Stabil oldalfekvésbe helyezni a személyt és betakarni',
      'Megvárni a mentőt — laikusként nem szabad semmit tenned',
    ],
    correctIndex: 0,
    explanation: 'Normális légzés nélkül minden perc számít, és a '
        'nyomkodás az egyetlen intézkedés, ami segít. A stabil '
        'oldalfekvés helyes — de csak meglévő normális légzésnél. A '
        'semmittevés pedig az egyetlen rossz döntés: a segítségnyújtás '
        'elmulasztása büntetendő.',
  ),

  // ══════════════════════════════════ M10 — Összefoglalás
  DrivingQuestion(
    moduleId: 'm10',
    question: 'Mi foglalja össze legjobban ennek a képzésnek a '
        'hozzáállását?',
    options: [
      'A szabályok főleg akkor érvényesek, amikor ellenőriznek',
      'A biztonság a napi döntésem, hogy mindenki épségben hazaérjen',
      'A fő, hogy a túra időben végig legyen csinálva',
    ],
    correctIndex: 1,
    explanation: 'A biztonság hozzáállás, nem kötelező gyakorlat — és '
        'pont akkor mutatkozik meg, amikor senki sem néz oda. Aki a '
        'szabályokat az ellenőrzésekhez köti, nem megértette őket, csak '
        'kibírta.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm10',
    question: 'Hány érintkezési pontot tartasz be- és kiszálláskor — és '
        'hány másodperc követési távolságot legalább száraz úton?',
    options: [
      '2 érintkezési pont és 1 másodperc',
      '3 érintkezési pont és 1 másodperc',
      '3 érintkezési pont (2 kéz + 1 láb) és 2 másodperc',
    ],
    correctIndex: 2,
    explanation: 'Három érintkezési pont („2+1") és két másodperc '
        'távolság — nedves úton három. Egy másodperc távolság 50-es '
        'tempónál pont a puszta reakcióútnak felel meg: minden fékezési '
        'tartalék nélkül futnál rá.',
  ),
];
