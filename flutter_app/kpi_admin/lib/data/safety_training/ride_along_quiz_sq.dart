// lib/data/safety_training/ride_along_quiz_sq.dart
//
// Pyetjet e testit përfundimtar të Ride Along-ut — versioni shqip.
// Pesëmbëdhjetë pyetje, të shpërndara në pesë kapitujt nga
// ride_along_content_sq.dart (ra1 … ra5), nga tri pyetje për kapitull.
//
// Kërkesa e pyetjeve: skenarë nga dy ditët e udhëtimit shoqërues. Disa
// opsione tingëllojnë me qëllim të besueshme — çdo herë varet nga një
// detaj. `explanation` shpjegon gjithmonë të dyja: pse përgjigjja e
// saktë është e saktë dhe pse gabimi i afërt është i gabuar.
//
// Neutrale ndaj firmës: askund nuk pyetet për shifra specifike të firmës
// (numri i ndalesave, kohët e Waiting Area, ana e parkimit) — vetëm për
// atë që vlen kudo. Përjashtimet me bazë ligjore: § 4 ArbZG (pushimet)
// dhe § 1 Abs. 6 FPersV (Green Book).

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> rideAlongQuestionsSq = [
  // ══════════════════════════ ra1 — Çfarë është Ride Along-u
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'Çfarë është Ride Along-u?',
    options: [
      'Një udhëzim teorik në zyrë para ditës së parë të punës',
      'Dy ditë pune udhëtim shoqërues me një shofer me përvojë si '
          'trajner',
      'Një provim zyrtar ngasjeje, pa të cilin nuk lejohesh të punosh',
    ],
    correctIndex: 1,
    explanation: 'Ride Along-u janë dy ditë të vërteta pune në firmë, gjatë '
        'të cilave një shofer me përvojë të shoqëron, të shpjegon gjithçka '
        'dhe më pas të lë ta bësh vetë. Nuk është as trajnim në zyrë e as '
        'provim shtetëror — është trajnim fillestar në punë të '
        'vazhdueshme, i cili megjithatë vlerësohet dhe dokumentohet.',
  ),
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'Sa ndalesa duhet të ngasësh gjatë dy ditëve?',
    options: [
      'Këtë e cakton firma ose stacioni yt — trajneri ta thotë '
          'përcaktimin',
      'Gjithmonë saktësisht 20 ditën e parë dhe 70 ditën e dytë, njësoj në '
          'çdo firmë',
      'Aq sa e ndien veten të aftë — një përcaktim nuk ekziston',
    ],
    correctIndex: 0,
    explanation: 'Të përhapura janë një numër më i vogël ditën e parë dhe '
        'dukshëm më shumë ditën e dytë (shpesh rreth 20 dhe rreth 70), por '
        'këto janë vlera orientuese të firmave të veçanta. E detyrueshme '
        'është vetëm përcaktimi i stacionit tënd. Gabimi i afërt është ta '
        'marrësh një shifër të dëgjuar për ligj të përgjithshëm — pyete '
        'trajnerin tënd për numrin që vlen për ty.',
  ),
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'Ditën e Parë je dukshëm më i ngadaltë se sa ishte '
        'planifikuar dhe bën disa gabime gjatë renditjes. Si ndikon kjo në '
        'vlerësim?',
    options: [
      'Ride Along-u konsiderohet kështu i pakaluar dhe duhet përsëritur',
      'Nuk luan asnjë rol, sepse ditën e parë nuk vlerësohet ende fare '
          'asgjë',
      'Vendimtare është nëse pyet dhe e ndreq gabimin më pas — jo ritmi',
    ],
    correctIndex: 2,
    explanation: 'Ritëm ditën e parë nuk pret askush; pikërisht për këtë '
        'është numri më i vogël i ndalesave. Vlerësohet gatishmëria jote '
        'për të mësuar: A pyet, a i pranon udhëzimet, a e bën të njëjtin '
        'gabim edhe herën e tretë? Gabimi në të dyja drejtimet është i '
        'rrezikshëm — nuk është as provim me gijotinë e as ditë pa '
        'vlerësim.',
  ),

  // ══════════════════════════ ra2 — Dita e Parë
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Pse duhet të zhvillohen ndalesat e Ride Along-ut përmes '
        'llogarisë sate?',
    options: [
      'Sepse trajneri nuk lejohet ta përdorë llogarinë e vet ato ditë',
      'Sepse vetëm kështu duket si është shpërndarja jote — ajo numërohet '
          'nën emrin tënd',
      'Sepse llogaria e trajnerit nuk mund të marrë më ndalesa të reja',
    ],
    correctIndex: 1,
    explanation: 'Gjithçka që shpërndan ato ditë shkon nën emrin tënd — '
        'pikërisht si më vonë në përditshmëri. Vetëm kështu shohin trajneri '
        'dhe firma mënyrën tënde reale të punës, dhe vetëm kështu '
        'numërohen ndalesat për trajnimin tënd. Prandaj një qasje që nuk '
        'funksionon në mëngjes nuk është detaj, por arsye për të njoftuar '
        'menjëherë.',
  ),
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Çfarë vlen për kohëzgjatjen e regjistrimit të Mentor-it?',
    options: [
      'Mentor regjistron rreth 4 orë njëherësh dhe pas kësaj duhet nisur '
          'nga e para',
      'Mentor, sapo niset një herë, punon deri në fund të turnit',
      'Mentor niset vetvetiu sapo mjeti fillon të lëvizë',
    ],
    correctIndex: 0,
    explanation: 'Regjistrimi zgjat çdo herë rreth katër orë. Pas kësaj '
        'duhet ta nisësh nga e para, përndryshe pjesa tjetër e turit '
        'mbetet e paregjistruar. Gabimi më i shpeshtë i fillestarëve është '
        'pikërisht ai iluzion se aplikacioni punon vetë deri në fund: i '
        'nisur saktë në mëngjes, i paaktivizuar sërish pas pushimit — dhe '
        'gjysma e ditës mungon në vlerësim.',
  ),
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Atë ditë punon 9,5 orë. Sa i gjatë duhet të jetë pushimi yt '
        'të paktën?',
    options: [
      '30 minuta, sepse 45 minuta vlejnë vetëm nga 10 orë e tutje',
      'Mjafton të bësh disa pushime të shkurtra nga 5 deri në 10 minuta',
      '45 minuta, sepse koha e punës është mbi 9 orë',
    ],
    correctIndex: 2,
    explanation: 'Sipas § 4 ArbZG janë të detyrueshme të paktën 30 minuta '
        'pushim për më shumë se 6 orë dhe të paktën 45 minuta për më shumë '
        'se 9 orë — 9,5 orë janë mbi kufi. Pushimi mund të ndahet, por çdo '
        'pjesë duhet të zgjasë të paktën 15 minuta; pesë minuta ndërmjet '
        'nuk numërohen.',
  ),

  // ══════════════════════════ ra3 — Dita e Dytë
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Një klient me një pako me fjalëkalim nuk e ka kodin në '
        'dorë, por do të nënshkruajë. Çfarë bën?',
    options: [
      'Nuk e dorëzon — pa kodin e saktë nuk ka asnjë përjashtim',
      'E dorëzon kundrejt nënshkrimit, sepse edhe ai është po aq dëshmi',
      'E lë pakon te fqinji dhe e njofton klientin',
    ],
    correctIndex: 0,
    explanation: 'Fjalëkalimi është dëshmia se marrësi është vërtet marrësi '
        '— për këtë u dha. Një nënshkrim ose bindja me fjalë të mira nuk e '
        'zëvendësojnë atë, e aq më pak lënia te fqinji. Nëse dërgesa '
        'raportohet më vonë si e pamarrë, dorëzimi pa kod mbetet si gabimi '
        'yt. E drejta është: lëre ta kërkojë kodin, përndryshe ktheje '
        'pakon si duhet dhe dokumentoje.',
  ),
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Gjatë manovrimit prek një shtyllë. Mbetet një gërvishtje në '
        'furgon, askush nuk e ka parë. Çfarë është e drejtë?',
    options: [
      'Mos bëj asgjë — te një gërvishtje pa dëm të huaj nuk ka çfarë të '
          'raportosh',
      'Prit fillimisht nëse bie fare në sy te inspektimi i radhës',
      'Raportoje po atë ditë dhe dokumentoje në CoDriver',
    ],
    correctIndex: 2,
    explanation: 'Një dëm i raportuar është një ngjarje që trajtohet; i '
        'njëjti dëm, që të nesërmen në mëngjes e gjen dikush tjetër gjatë '
        'inspektimit të vet, është një dëm i pasqaruar — dhe dyshimi në '
        'fund prapë drejtohet nga përdoruesi i fundit. Gabimi „nuk bie në '
        'sy" nuk qëndron: pikërisht për këtë ka inspektim para dhe pas çdo '
        'turi.',
  ),
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Cili është dallimi mes performancës dhe cilësisë në '
        'Scorecard?',
    options: [
      'Të dyja nënkuptojnë të njëjtën gjë — Scorecard-i mat vetëm numrin e '
          'ndalesave',
      'Performanca është sasia në kohë, cilësia është se sa pastër u mbyll '
          'çdo ndalesë e vetme',
      'Cilësia ka të bëjë vetëm me mjetin, performanca vetëm me '
          'shpërndarjen',
    ],
    correctIndex: 1,
    explanation: 'Performanca është sasia — sa ndalesa në sa kohë. Cilësia '
        'është kujdesi te çdo ndalesë e vetme: vendi i duhur, dokumentimi '
        'i saktë, asnjë reklamim. Kush i barazon të dyja, kursen përpara '
        'një minutë dhe krijon prapa një hetim që i kushton firmës '
        'shumëfishin.',
  ),

  // ══════════════════════════ ra4 — Përfundimi dhe dorëzimi
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'Sa herë e nënshkruan trajneri listën e kontrollit të Ride '
        'Along-ut?',
    options: [
      'Një herë në fund të Ditës së Dytë për të dyja ditët bashkë',
      'Fare — nënshkruan vetëm dispeçeri në dorëzim',
      'Veçmas për çdo ditë, çdo herë me datë',
    ],
    correctIndex: 2,
    explanation: 'Çdo ditë ka listën e vet të pikave dhe prandaj mbyllet '
        'veçmas me datë dhe nënshkrim. Kjo ka një arsye praktike: nëse dita '
        'e dytë bie ose shtyhet, mbetet prapë e dokumentuar pastër çfarë u '
        'krye ditën e parë. Një nënshkrim i përbashkët në fund do ta bënte '
        'pikërisht këtë të pamundur.',
  ),
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'Çfarë ndodh me listën e kontrollit të plotësuar në fund të '
        'Ditës së Dytë?',
    options: [
      'Ajo dorëzohet si foto te dispeçeri përgjegjës',
      'E merr me vete në shtëpi dhe e ruan privatisht',
      'Ajo mbetet në mjet, që trajneri tjetër ta vazhdojë',
    ],
    correctIndex: 0,
    explanation: 'Fleta fotografohet në fund të Ditës së Dytë dhe dorëzohet '
        'te dispeçeri përgjegjës — me këtë Ride Along-u është formalisht i '
        'mbyllur dhe trajnimi yt i dokumentuar. Në mjet ose privatisht në '
        'shtëpi dëshmia është e pavlerë për firmën. Kujdes që shenjat, '
        'data, emrat dhe nënshkrimet të jenë të lexueshme në foto.',
  ),
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'Në vlerësim thuhet se je shumë hezitues gjatë manovrimit. '
        'Si reagon më me vend?',
    options: [
      'Shpjego se ishe me qëllim i kujdesshëm dhe mbylle kështu temën',
      'Pyet për një shembull konkret nga ajo ditë',
      'Merre vlerësimin për dijeni dhe herën tjetër manovro më shpejt',
    ],
    correctIndex: 1,
    explanation: 'Kujdesi gjatë manovrimit është i drejtë — „hezitues" '
        'zakonisht nënkupton diçka tjetër, për shembull të menduarit gjatë '
        'në vend që të zbresësh shkurt e të shikosh. Me një shembull '
        'konkret ke një pikë në të cilën mund të punosh. Të justifikohesh '
        'nuk sjell asgjë, dhe thjesht të manovrosh më shpejt do të ishte '
        'reagimi më i rrezikshëm nga të treja.',
  ),

  // ══════════════════════════ ra5 — Kështu përgatitesh
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Kur duhet të kontrollosh nëse qasjet e tua te regjistrimi i '
        'kohës, Mentor, Flex dhe CoDriver funksionojnë?',
    options: [
      'Në mëngjesin e Ditës së Parë bashkë me trajnerin',
      'Vetëm atëherë kur gjatë punës shfaqet vërtet një problem',
      'Para Ditës së Parë, më së miri një mbrëmje më parë',
    ],
    correctIndex: 2,
    explanation: 'Rivendosja e një fjalëkalimi zgjat një mbrëmje më parë '
        'disa minuta dhe në mëngjes në Waiting Area gjysmë ore — nëse '
        'gjendet fare dikush. Gabimi i afërt është t\'ia lësh këtë '
        'trajnerit: ai nuk mund të të ndihmojë te një qasje e bllokuar, '
        'dhe koha pastaj mungon te ndalesat përmes llogarisë sate.',
  ),
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Çfarë do të thotë „në kohë" në Ride Along?',
    options: [
      'Gati për punë në stacion në fillimin e turnit — parkimi dhe rruga '
          'janë llogaritur tashmë',
      'Të mbërrish te porta e stacionit në fillimin e turnit',
      'Të jesh aty më së voni kur thirret Waiting Area',
    ],
    correctIndex: 0,
    explanation: 'Në fillimin e turnit je gati për punë, jo në rrugë. Kush '
        'mbërrin vetëm te porta, humbet kohë me parkimin dhe me rrugën '
        'nëpër oborr dhe e humbet dritaren e vet të Waiting Area — dhe '
        'kështu e shtyn edhe valën e trajnerit. Prandaj llogarite me '
        'vetëdije kohën për parkim dhe për të ecur.',
  ),
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Pse ia vlen t\'i shkruash pyetjet për trajnerin që para '
        'Ditës së Parë?',
    options: [
      'Sepse trajneri duhet t\'i marrë pyetjet paraprakisht me shkrim',
      'Sepse dhjetë ecuri të shpjeguara njëra pas tjetrës nuk i mban mend '
          'askush — të shkruara pyet me qëllim',
      'Sepse pyetjet e pabëra shënohen ndryshe negativisht në vlerësim',
    ],
    correctIndex: 1,
    explanation: 'Trajneri shpjegon gjatë dy ditëve shumë gjëra njëherësh; '
        'në mbrëmje pa shënime mbetet pak nga to. Kush i përgatit pyetjet e '
        'veta dhe shkruan rrugës dy fjalë kyçe për çdo temë, nxjerr nga dy '
        'ditët shumëfish më tepër. Detyrim formal nuk është — dhe askush '
        'nuk i shënon negativisht pyetjet e pabëra. Pikërisht prandaj duhet '
        'të kujdesesh vetë për këtë.',
  ),
];
