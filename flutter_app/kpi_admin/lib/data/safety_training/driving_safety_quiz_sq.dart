// lib/data/safety_training/driving_safety_quiz_sq.dart
//
// Pyetjet e trajnimit DSP për sigurinë në ngasje — versioni shqip.
// Struktura është identike me versionin gjerman (master): i njëjti
// numër pyetjesh, i njëjti rend, të njëjtat përgjigje të sakta.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> drivingQuestionsSq = [
  // ══════════════════════════════════ M1 — Kultura e sigurisë
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Je 20 ndalesa pas planit. Cili reagim i përgjigjet kulturës '
        'së sigurisë në firmë?',
    options: [
      'Mes ndalesave të ngasësh më shpejt, por te vetë ndalesat të '
          'mbetesh i kujdesshëm',
      'Të njoftosh vonesën dhe ta vazhdosh turin me ritmin e zakonshëm të '
          'sigurt',
      'Të shkurtosh kohët e kontrollit gjatë manovrimit, por ta lësh '
          'sjelljen në ngasje të pandryshuar',
    ],
    correctIndex: 1,
    explanation: 'Presioni i kohës është problem planifikimi dhe njoftohet, '
        'nuk kompensohet në timon. Dy përgjigjet e tjera tingëllojnë si '
        'kompromis, por vetëm e zhvendosin rrezikun: shpejtësia më e '
        'lartë mes ndalesave e zgjat pikërisht rrugën e ndalimit, dhe '
        'kontrollet e shkurtuara të manovrimit prekin veprimtarinë te e '
        'cila lindin 70 % e të gjitha dëmeve.',
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Dispeçeri të urdhëron të nisesh me një dritë frenimi të '
        'prishur. Kush e mban përgjegjësinë, nëse për këtë arsye ndodh një '
        'përplasje nga pas?',
    options: [
      'Dispeçeri, sepse ai e dha urdhrin',
      'Firma, sepse ajo e vë në dispozicion mjetin',
      'Askush — një dritë e vetme frenimi nuk është defekt me rëndësi për '
          'sigurinë',
      'Ti si drejtues mjeti',
    ],
    correctIndex: 3,
    explanation: 'Si drejtues mjeti përgjigjesh për gjendjen e sigurt në '
        'trafik të mjetit që ngas — një urdhër gojor nuk e heq këtë. Që '
        'firma e siguron mjetin tingëllon bindëse, por nuk të liron: gjoba '
        'dhe pikët të prekin ty personalisht. E saktë është ta njoftosh '
        'defektin dhe të kërkosh një mjet tjetër.',
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Gjatë manovrimit munguan vetëm pak centimetra deri te një '
        'shtyllë — nuk ndodhi asgjë. Çfarë është e saktë?',
    options: [
      'Ta njoftosh si situatë për pak aksident',
      'Të mos bësh asgjë, meqë nuk lindi dëm dhe askush nuk u rrezikua',
      'Ta njoftosh vetëm nëse e ka parë një koleg ose një kamerë',
    ],
    correctIndex: 0,
    explanation: 'Një situatë për pak aksident tregon një pikë rreziku para '
        'se ajo të godasë dikë — e njoftuar, ajo është zbutur për kolegun '
        'e radhës. Mendimi „pa dëm, pa temë" është arsyeja më e shpeshtë '
        'pse i njëjti vend javë më vonë prapëseprapë çon në dëm.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Gjatë cilës veprimtari lindin rreth 70 % e të gjitha dëmeve '
        'të furgonëve?',
    options: [
      'Në autostradë dhe rrugë ndërqytetëse me shpejtësi të lartë',
      'Gjatë kthimit në kryqëzime në trafikun e qytetit',
      'Gjatë manovrimit dhe lëvizjes prapa',
    ],
    correctIndex: 2,
    explanation: 'Shumica dërrmuese e dëmeve lind me shpejtësi këmbësori '
        'gjatë manovrimit. Shpejtësia e lartë shkakton aksidentet më të '
        'rënda, por jo dëmet më të shumta — pikërisht ky ngatërrim bën që '
        'gjatë manovrimit të tregohet shumë pak kujdes.',
  ),

  // ══════════════════════════════════ M2 — Kontrolli dhe ngarkesa
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Ngarkesa duhet siguruar sipas rregullave të njohura të '
        'teknikës kundër 0,8 g përpara. Cilës forcë mbajtëse i përgjigjet '
        'kjo përafërsisht te një pako 20 kg?',
    options: [
      'rreth 2 kg',
      'rreth 8 kg',
      'rreth 16 kg',
      'rreth 200 kg',
    ],
    correctIndex: 2,
    explanation: '0,8 × 20 kg jep rreth 16 kg forcë mbajtëse. „Rreth 2 kg" '
        'e nënvlerëson forcën në mënyrë dramatike dhe është arsyeja pse '
        'pakot mbahen për të padëmshme; „200 kg" e ngatërron kërkesën e '
        'sigurimit me forcën e goditjes në një përplasje të vërtetë, e '
        'cila në fakt qëndron edhe shumë më lart.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Si e ngarkon drejt hapësirën e ngarkesës?',
    options: [
      'E rënda poshtë dhe përpara te muri ndarës, pesha e shpërndarë '
          'njësoj',
      'E rënda sipër, që pakot e rënda gjatë kapjes të mos rrinë nën të '
          'lehtat',
      'E rënda prapa te dera, që dërgesat e rënda të dalin të parat',
    ],
    correctIndex: 0,
    explanation: 'E rëndë + poshtë + përpara e mban qendrën e rëndesës '
        'ulët dhe masën aty ku muri ndarës mund ta ndalë. Dy variantet e '
        'tjera janë menduar sipas rrjedhës së punës, jo sipas fizikës: '
        'pesha lart e rrit prirjen për përmbysje, pesha prapa e lehtëson '
        'boshtin e përparmë dhe e keqëson drejtimin.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Pas dy të tretave të turit hapësira e ngarkesës është gjysmë '
        'e zbrazët. Çfarë vlen tani për sigurimin e ngarkesës?',
    options: [
      'Është më pak e rëndësishme, sepse në bord ka dukshëm më pak peshë',
      'Duhet bërë sërish — pakot e mbetura kanë tani më shumë rrugë për të '
          'marrë shpejtësi',
      'Vlen e pandryshuar më tej, nuk ka çfarë të bëhet',
    ],
    correctIndex: 1,
    explanation: 'Sa më e zbrazët hapësira e ngarkesës, aq më e madhe '
        'distanca në të cilën një pako mund të përshpejtojë para se të '
        'godasë. „Më pak peshë, më pak rrezik" tingëllon logjike, por '
        'është e gabuar: vendimtare nuk është masa e përgjithshme, por '
        'pakoja e vetme e pasiguruar.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Çfarë kërkon DGUV Vorschrift 70 (rregullorja gjermane për '
        'mjetet) prej teje para fillimit të ndërrimit të punës?',
    options: [
      'Një kontroll teknik me platformë ngritëse dhe stend frenash',
      'Një kontroll të mjetit për defekte të dukshme',
      'Një kontroll vetëm te mjetet që i ngas për herë të parë',
    ],
    correctIndex: 1,
    explanation: 'Kërkohet kontrolli i defekteve që bien në sy para '
        'ndërrimit — pikërisht ajo që bën rrotullimi rreth mjetit. '
        'Kontrolli teknik është punë e ofiçinës dhe nuk e zëvendëson '
        'rrotullimin tënd; dhe detyrimi vlen për çdo mjet në çdo ditë, jo '
        'vetëm për ato të panjohurat.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Cilën thellësi profili e përcakton ligji si minimum — dhe '
        'çfarë ka kuptim në rrugë të lagur?',
    options: [
      '3 mm ligjërisht; në lagështi mjaftojnë atëherë 1,6 mm',
      '1,6 mm ligjërisht; kjo mjafton e pandryshuar edhe në lagështi',
      '4 mm ligjërisht, gjatë gjithë vitit për të gjitha gomat',
      '1,6 mm ligjërisht; në lagështi kanë kuptim së paku 3 mm',
    ],
    correctIndex: 3,
    explanation: 'Minimumi ligjor është 1,6 mm, praktikisht i arsyeshëm në '
        'lagështi së paku 3 mm. Përgjigjja „1,6 mm mjaftojnë edhe në '
        'lagështi" është gabimi klasik: minimumi është kufiri drejt '
        'kundërvajtjes, jo kufiri drejt sigurisë — me 1,6 mm goma '
        'pothuajse nuk zhvendos më ujë.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Ndalesa e radhës rri në sedilen e pasagjerit, që ta kapësh '
        'shpejt. Cili është problemi kryesor këtu?',
    options: [
      'Pakoja bëhet predhë gjatë një frenimi dhe mund të futet nën pedalin '
          'e frenave',
      'Duket e parregullt gjatë një kontrolli trafiku',
      'Lejohet, për sa kohë që pakoja peshon më pak se 10 kg',
    ],
    correctIndex: 0,
    explanation: 'Gjithçka në kabinë lëviz gjatë një frenimi më tej me '
        'shpejtësinë tënde fillestare — në rastin më të keq në hapësirën e '
        'këmbëve nën pedal. Kufi peshe për këtë nuk ka: edhe një pako e '
        'lehtë e bllokon një pedal.',
  ),

  // ══════════════════════════════════ M3 — Ngasje mbrojtëse
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Ngas jashtë qytetit 80 km/h në rrugë të thatë. Cila '
        'distancë ndaj mjetit përpara është e paktën e saktë?',
    options: [
      'Rreth 20 metra — kjo i përgjigjet tri gjatësive mjeti',
      'Rreth 45 metra — afërsisht dy sekonda përkatësisht gjysma e vlerës '
          'së shpejtësimatësit',
      'Rreth 10 metra, për sa kohë je i vëmendshëm dhe rruga është e lirë',
    ],
    correctIndex: 1,
    explanation: 'Dy sekonda i përgjigjen me 80 km/h rreth 45 metrave, '
        'gjysma e vlerës së shpejtësimatësit 40 metrave — të dyja '
        'përputhen. 20 metra duken shumë në rrugë, por qëndrojnë nën '
        'rrugën e pastër të reagimit prej 24 metrash: do të ishe përplasur '
        'para se frenat të kapin fare.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Sa e gjatë është rruga e ndalimit me 50 km/h sipas '
        'formulave praktike (frenim normal)?',
    options: [
      '15 metra',
      '25 metra',
      '40 metra',
      '65 metra',
    ],
    correctIndex: 2,
    explanation: 'Rruga e reagimit (50 ÷ 10) × 3 = 15 m plus rruga e '
        'frenimit (50 ÷ 10)² = 25 m jep 40 m. Kush thotë 25 metra, ka '
        'llogaritur vetëm rrugën e frenimit dhe e ka harruar rrugën e '
        'reagimit — ky është gabimi më i shpeshtë i llogaritjes dhe '
        'pikërisht ajo pjesë e distancës që e bën me shpejtësi të plotë.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Si e llogarit rrugën e reagimit sipas formulës praktike?',
    options: [
      '(Shpejtësia ÷ 10) × 3',
      '(Shpejtësia ÷ 10) × (Shpejtësia ÷ 10)',
      'Shpejtësia ÷ 2',
    ],
    correctIndex: 0,
    explanation: 'Rruga e reagimit është (km/h ÷ 10) × 3. Formula e dytë '
        'është rruga e frenimit, e treta vlera praktike për distancën e '
        'sigurisë — të dyja duken të ngjashme, por përshkruajnë diçka '
        'krejt tjetër.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'E dyfishon shpejtësinë nga 30 në 60 km/h. Si ndryshon rruga '
        'e pastër e frenimit?',
    options: [
      'Dyfishohet',
      'Katërfishohet',
      'Trefishohet',
      'Mbetet pothuajse e njëjtë, sepse frenat me shpejtësi më të lartë '
          'kapin më fort',
    ],
    correctIndex: 1,
    explanation: 'Rruga e frenimit rritet me katrorin e shpejtësisë: nga 9 '
        'metra bëhen 36 metra. Përgjigjja e afërt „dyfishohet" e '
        'nënvlerëson pikërisht këtë — ajo shpjegon pse 20 km/h më shumë në '
        'një rrugë banimi ndihen si të padëmshme.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Pse duhet të ngasësh dukshëm më ngadalë në kthesa me një '
        'furgon plot të ngarkuar sesa me një veturë?',
    options: [
      'Sepse qendra e lartë e rëndesës e rrit fort prirjen për përmbysje',
      'Sepse drejtimi bëhet më i pasaktë me ngarkesë',
      'Sepse gomat nën ngarkesë bëhen më të buta dhe kanë më shumë kapje',
    ],
    correctIndex: 0,
    explanation: 'Një furgon i ngarkuar lart përmbyset aty ku një veturë '
        'ende rrëshqet — dhe pothuajse nuk e paralajmëron. Saktësia e '
        'drejtimit ndryshon vërtet edhe ajo, por nuk është rreziku i '
        'vërtetë: përmbysja ndodh papritur dhe përfundon jashtë '
        'karrexhatës.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Do të kthehesh djathtas te një semafor, një çiklist rri '
        'djathtas pranë teje. Semafori bëhet i gjelbër. Çfarë bën së '
        'pari?',
    options: [
      'Nisesh shpejt dhe kthehesh, para se çiklisti të marrë vrull',
      'Shikon në pasqyrën e jashtme të djathtë dhe pastaj kthen timonin',
      'Bën vështrim mbi sup djathtas dhe e lë çiklistin të kalojë',
    ],
    correctIndex: 2,
    explanation: 'Sapo nisesh dhe kthen timonin, çiklisti kalon në këndin e '
        'vdekur — dhe pjesa jote e prapme hyn përveç kësaj në shiritin e '
        'tij. Vështrimi në pasqyrë tingëllon i saktë, por nuk mjafton '
        'pikërisht atëherë kur ka rëndësi: pasqyra nuk e tregon plotësisht '
        'zonën djathtas pranë kabinës.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Cilën distancë minimale anësore duhet të mbash brenda '
        'qytetit gjatë tejkalimit të një çiklisti?',
    options: [
      '1,0 metër',
      '1,5 metra',
      '2,0 metra',
    ],
    correctIndex: 1,
    explanation: 'Brenda qytetit janë 1,5 metra, jashtë qytetit 2,0 metra. '
        'Kush e mban 2,0 metra për vlerën brenda qytetit, i ngatërron të '
        'dyja — dhe kush tejkalon me 1,0 metër, e shkel distancën minimale '
        'dhe përgjigjet nëse çiklisti rrëzohet.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Sa larg përpara duhet të jetë drejtuar shikimi yt gjatë '
        'ngasjes?',
    options: [
      'Te parakolpi i mjetit përpara, që ta shohësh menjëherë frenimin e '
          'tij',
      'Te kapaku i motorit tënd, sepse kështu e mban shiritin më saktë',
      '12–15 sekonda përpara',
    ],
    correctIndex: 2,
    explanation: 'Shikimi i largët të siguron kohë: i sheh semaforët, '
        'dritat e frenimit dhe këmbësorët para se të duhet të reagosh. '
        'Shikimi te parakolpi ndihet i vëmendshëm, por të bën vetëm '
        'reagues — për rrezikun mëson vetëm kur mjeti përpara ka filluar '
        'të frenojë.',
  ),

  // ══════════════════════════════════ M4 — Prapa dhe manovrim
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Për çfarë qëndron GOAL gjatë lëvizjes prapa?',
    options: [
      '„Get Out And Look" — ndalo, zbrit, shiko pas mjetit',
      '„Go Only At Low speed" — lëviz prapa vetëm me shpejtësi këmbësori',
      '„Guide On A Line" — orientohu sipas një shenje në tokë',
    ],
    correctIndex: 0,
    explanation: 'GOAL do të thotë të zbresësh dhe të shikosh — ai zbulon '
        'shtylla të ulëta, pjerrësi dhe fëmijë që nga sedilja nuk i sheh '
        'kurrë. Shpejtësia e këmbësorit është gjithashtu detyrim, por nuk '
        'e zëvendëson shikimin: edhe me shpejtësi këmbësori futesh në një '
        'zonë që nuk e sheh dot.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Mjeti yt ka kamerë të lëvizjes prapa. Çfarë ndryshon kjo te '
        'GOAL?',
    options: [
      'GOAL bie, sepse kamera e tregon zonën pas mjetit',
      'Asgjë',
      'GOAL është me këtë i nevojshëm vetëm në errësirë dhe pamje të keqe',
    ],
    correctIndex: 1,
    explanation: 'Kamera tregon vetëm një prerje, i shtrembëron distancat '
        'dhe verbohet nga shiu, bora dhe balta — mbi të gjitha nuk sheh '
        'çfarë hyn anash në rrugën tënde. Ajo e plotëson GOAL, kurrë nuk e '
        'zëvendëson.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Ku qëndron drejt një udhëzues?',
    options: [
      'Drejtpërdrejt pas mjetit, sepse që andej e vlerëson më mirë '
          'distancën',
      'Para mjetit, për ta ndalur njëkohësisht trafikun',
      'Anash, ashtu që ta shohësh vazhdimisht në pasqyrë',
    ],
    correctIndex: 2,
    explanation: 'Vetëm ai që rri anash dhe mbetet i dukshëm vazhdimisht '
        'mund të udhëzojë me siguri. Pozicioni drejtpërdrejt pas mjetit '
        'duket më afër ngjarjes, por është pikërisht zona në të cilën '
        'udhëzuesi shtypet vetë, sapo ta humbësh nga sytë.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Papritur nuk e sheh më udhëzuesin tënd në pasqyrë. Çfarë '
        'bën?',
    options: [
      'Vazhdon më ngadalë, derisa ai të shfaqet sërish',
      'Ndalon menjëherë',
      'I bie shkurt borisë dhe vazhdon, që ai të tregohet sërish',
    ],
    correctIndex: 1,
    explanation: 'Pa kontakt me sy nuk ka shenjë të vlefshme — pra ndalo, '
        'jo vetëm ngadalëso. „Të vazhdosh më ngadalë" tingëllon i '
        'kujdesshëm, por do të thotë se vazhdon të futesh në një zonë që '
        'askush nuk e mbikëqyr më për ty.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Çfarë kërkon § 9 par. 5 StVO gjatë lëvizjes prapa?',
    options: [
      'Të ndizen dritat e rrezikut',
      'Të ngasësh së shumti me shpejtësi këmbësori',
      'Të përjashtohet rrezikimi i të tjerëve — nëse është e nevojshme me '
          'udhëzues',
    ],
    correctIndex: 2,
    explanation: 'Dispozita kërkon përjashtimin e çdo rrezikimi, nëse '
        'duhet përmes një udhëzuesi — kriteri është pra rezultati, jo një '
        'shpejtësi e caktuar. Shpejtësia e këmbësorit dhe dritat e '
        'rrezikut janë praktikë e mirë, por vetëm ato nuk e përmbushin '
        'detyrimin.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Ndalesa e fundit ndodhet në një oborr të ngushtë të '
        'brendshëm: përpara futesh, dil vetëm prapa pranë një muri. Cili '
        'është vendimi më i sigurt?',
    options: [
      'Të ndalosh në rrugë dhe metrat e fundit t\'i bësh në këmbë '
          'përkatësisht me karrocë',
      'Të futesh përpara, sepse pastaj hyrjen e njeh tashmë për rrugën e '
          'kthimit',
      'Të futesh shpejt prapa, për sa kohë rruga është ende e lirë',
    ],
    correctIndex: 0,
    explanation: 'Lëvizja prapa më e sigurt është ajo që nuk ndodh fare. Se '
        'hyrjen „e njeh pasi ke hyrë" është një mashtrim: gjatë daljes '
        'pikat kritike janë pas teje, dhe trafiku në pritje krijon përveç '
        'kësaj presion.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M5 — Moti dhe pamja
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Timoni bëhet papritur i lehtë, gomat notojnë mbi një cipë '
        'uji. Çfarë bën?',
    options: [
      'Frenon fort dhe kundërkthen timonin',
      'Heq gazin, e mban timonin qetë drejt, e lë makinën të ecë',
      'Përshpejton, për ta lënë shpejt vendin me ujë',
    ],
    correctIndex: 1,
    explanation: 'Për sa kohë cipa e ujit mban, frenat dhe timoni nuk '
        'veprojnë — ato veprojnë papritur vetëm kur goma kap sërish, dhe '
        'pikërisht nga kjo lind rrëshqitja. Frenimi dhe kundërkthimi është '
        'reagimi intuitiv, por i gabuar.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Nga çfarë varet më së shumti rreziku i akuaplanimit?',
    options: [
      'Nga pesha e ngarkesës',
      'Nga mosha e mjetit dhe e sistemit të frenave',
      'Nga thellësia e profilit, lartësia e ujit dhe mbi të gjitha '
          'shpejtësia',
    ],
    correctIndex: 2,
    explanation: 'Rreziku rritet në mënyrë joproporcionale me shpejtësinë '
        'dhe bie me thellësinë e profilit — profili duhet ta largojë ujin '
        'para gomës. Ngarkesa luan rol dytësor: më shumë peshë e shtyp '
        'gomën më fort mbi rrugë, por nuk ndryshon asgjë nga fakti se një '
        'profil i hollë me shpejtësi nuk zhvendos më ujë.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Në mjegull sheh edhe rreth 40 metra larg. Sa shpejt lejohet '
        'të ngasësh së shumti?',
    options: [
      'Së shumti 40 km/h',
      'Deri te shpejtësia maksimale e lejuar, për sa kohë dritat janë '
          'ndezur',
      'Së shumti 80 km/h, nëse drita e prapme e mjegullës është ndezur',
    ],
    correctIndex: 0,
    explanation: 'Rregull praktik: distanca e dukshme në metra është kufiri '
        'yt i sipërm në km/h — me 40 metra pamje pra 40 km/h. Dritat dhe '
        'drita e prapme e mjegullës të bëjnë më të dukshëm, por nuk e '
        'zgjatin distancën tënde të pamjes dhe rrjedhimisht as shpejtësinë '
        'e lejuar.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Kur i përcakton § 2 par. 3a StVO gomat e përshtatshme për '
        'dimër?',
    options: [
      'Gjithmonë në periudhën tetor deri në Pashkë, pavarësisht nga moti',
      'Në akull, ngricë bore, llucë bore, akull ose brymë',
      'Vetëm nëse në rrugë ka shtresë të mbyllur bore',
    ],
    correctIndex: 1,
    explanation: 'Në Gjermani vlen një detyrim situativ: ai varet nga '
        'gjendja e rrugës, jo nga kalendari. „Tetor deri në Pashkë" është '
        'vetëm një rregull praktik për ndërrimin e gomave dhe jo bazë '
        'ligjore — dhe llucë bore mjafton tashmë, nuk duhet të ketë '
        'shtresë të mbyllur.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Është shumë ftohtë dhe je nën presion kohe. Pastron vetëm '
        'anën e shoferit të xhamit të përparmë. Çfarë vlen?',
    options: [
      'E lejuar, për sa kohë ngas dukshëm më ngadalë',
      'E lejuar, nëse ngrohja e pastron pjesën tjetër gjatë udhëtimit',
      'Jo e lejuar — të gjitha xhamat, pasqyrat, dritat dhe targa duhet '
          'të jenë të lira',
    ],
    correctIndex: 2,
    explanation: '„Vrima e shikimit" e kruar është kundërvajtje dhe në një '
        'aksident një akuzë e rëndë faji. Që ngrohja e plotëson më pas nuk '
        'është përjashtim: përcaktuese është gjendja në çastin e nisjes, '
        'jo tri minuta më vonë.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Pse është një furgon i ZBRAZËT veçanërisht i rrezikuar në '
        'stuhi?',
    options: [
      'Sepse i mungon pesha e ngarkesës, e cila e mban në rrugë',
      'Sepse rezistenca e ajrit pa ngarkesë është më e madhe',
      'Sepse presioni i gomave në gjendje bosh është më i lartë',
    ],
    correctIndex: 0,
    explanation: 'Sipërfaqja që i ekspozohet erës është njësoj e madhe bosh '
        'si e ngarkuar, por masa dukshëm më e vogël — i njëjti shkulm e '
        'zhvendos pra mjetin më fort. Rezistenca e ajrit nuk ndryshon fare '
        'nga ngarkesa brenda, ky është gabimi i të menduarit.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M6 — Shpërqendrimi dhe lodhja
  DrivingQuestion(
    moduleId: 'm6',
    question: 'A lejohet ta marrësh telefonin në dorë gjatë udhëtimit, për '
        'të ndërruar muzikën?',
    options: [
      'Po, nëse zgjat vetëm një sekondë dhe rruga është e lirë',
      'Vetëm te semafori i kuq',
      'Jo',
    ],
    correctIndex: 2,
    explanation: 'Vetëm marrja ose mbajtja e pajisjes është shkelja — '
        'pavarësisht se për çfarë. Semafori i kuq nuk është përjashtim, '
        'për sa kohë motori punon. Muzika, destinacioni dhe zëri '
        'rregullohen para udhëtimit, në vend.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Kur lejohet ligjërisht ta marrësh telefonin ose skanerin në '
        'dorë?',
    options: [
      'Vetëm kur mjeti është i ndalur DHE motori është i fikur',
      'Sapo mjeti të ndalet — sistemi automatik start-stop mjafton për '
          'këtë',
      'Shkurt gjatë udhëtimit, kur rruga është e drejtë dhe e lirë',
    ],
    correctIndex: 0,
    explanation: 'Përjashtimi vlen vetëm me mjet të ndalur dhe motor të '
        'fikur. Sistemi automatik start-stop shprehimisht nuk numërohet — '
        'pikërisht te ai mbështeten shumë veta te semafori i kuq dhe atje '
        'marrin gjobën e tyre.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Ngas 50 km/h dhe shikon 2 sekonda te ekrani. Sa larg ngas '
        'gjatë kësaj pa pamje mbi rrugë?',
    options: [
      'rreth 8 metra',
      'rreth 28 metra',
      'rreth 14 metra',
      'rreth 50 metra',
    ],
    correctIndex: 1,
    explanation: '50 km/h janë rreth 14 metra për sekondë, në 2 sekonda pra '
        'afërsisht 28 metra. Kush zgjedh „14 metra", ka llogaritur vetëm '
        'një sekondë — një gabim tipik që e bën distancën e verbër të '
        'duket sa gjysma.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Të zë gjumi me shpejtësi 80 për 4 sekonda. Cilën distancë e '
        'bën pa kontroll?',
    options: [
      'rreth 30 metra',
      'rreth 50 metra',
      'rreth 90 metra',
      'rreth 160 metra',
    ],
    correctIndex: 2,
    explanation: '80 km/h janë rreth 22 metra për sekondë, herë 4 jep '
        'afërsisht 89 metra. Ndryshe nga vështrimi te telefoni, në këtë '
        'kohë nuk e drejton fare timonin — mjeti del nga shiriti. Prandaj '
        'përfytyrimi i një gjumi „të shkurtër" është kaq i rrezikshëm.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Çfarë ndihmon vërtet kundër lodhjes akute në timon?',
    options: [
      'Të hapësh xhamin dhe muzikë e lartë',
      'Të pish kafe dhe të ngasësh më shpejt, për të mbaruar më herët',
      'Të ndalosh, 15–20 minuta gjumë i shkurtër, pastaj lëvizje',
    ],
    correctIndex: 2,
    explanation: 'Vetëm gjumi dhe lëvizja e rikthejnë vëmendjen. Ajri i '
        'freskët dhe muzika e lartë veprojnë së shumti pak minuta dhe '
        'gjatë kësaj simulojnë zgjuarsi — pikërisht në këtë fazë njeriu e '
        'mbivlerëson veten më së shumti.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Një dëgjuese për funksionin pa duar, veshi tjetër i lirë — a '
        'është kjo në rregull gjatë udhëtimit?',
    options: [
      'Po, një vesh i lirë mjafton për trafikun',
      'Po, për sa kohë zëri është vendosur i ulët',
      'Jo',
    ],
    correctIndex: 2,
    explanation: 'Duhet të mund të lokalizosh me siguri boritë, thirrjet '
        'dhe mjetet e urgjencës — dhe për këtë të duhen të dy veshët; '
        'gjatë manovrimit dëgjimi është shpesh paralajmërimi i vetëm. Një '
        'zë i ulët nuk ndryshon asgjë nga fakti se një vesh është i zënë.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Çfarë të kërcënon, nëse me telefonin në dorë rrezikon një '
        'pjesëmarrës tjetër në trafik?',
    options: [
      '100 € dhe 1 pikë',
      '150 €, 2 pikë dhe 1 muaj ndalim drejtimi',
      'Një paralajmërim gojor pa shënim',
    ],
    correctIndex: 1,
    explanation: '100 € dhe 1 pikë janë rasti bazë pa rrezikim; nëse shtohet '
        'një rrezikim, ngjitet në 150 €, 2 pikë dhe një muaj ndalim '
        'drejtimi. Për ty si shofer profesionist problemi nuk janë paratë, '
        'por ndalimi i drejtimit.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Plani i turit sot nuk realizohet dot në mënyrë të sigurt. '
        'Cili është reagimi i drejtë?',
    options: [
      'Të vazhdosh punën me siguri dhe ta njoftosh herët problemin e '
          'planifikimit',
      'Të heqësh pushimet dhe të shkurtosh kontrollet gjatë manovrimit',
      'Të ngasësh më shpejt mes ndalesave dhe kohën ta nxjerrësh atje',
    ],
    correctIndex: 0,
    explanation: 'Plani përshtatet, jo siguria. Vendimtar është përveç '
        'kësaj çasti: një njoftim herët pasdite mund të bëjë ende diçka, '
        'një në mbrëmje jo më. Heqja e pushimeve e ashpërson problemin, '
        'sepse vëmendja jote bie pikërisht atëherë.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M7 — Zbritja dhe ngritja
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Si thotë rregulli i 3 pikave („2+1") i BG Verkehr gjatë '
        'hipjes dhe zbritjes?',
    options: [
      'Një dorë dhe dy këmbë janë gjithmonë te mjeti',
      'Dy duar dhe një këmbë janë gjithmonë në kontakt me mjetin',
      'Të dyja këmbët qëndrojnë në tokë para se t\'i lëshosh dorezat',
    ],
    correctIndex: 1,
    explanation: 'Dy duar plus një këmbë japin tri pika të forta, ashtu që '
        'një rrëshqitje e vetme kurrë nuk çon në rrëzim. „Të dyja këmbët '
        'së pari në tokë" përshkruan pikërisht çastin kur nuk ke më asnjë '
        'mbështetje — kjo është varianti i kërcimit.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Si zbret drejt nga kabina?',
    options: [
      'Përpara, me shpinë nga dera, hapin e fundit me kërcim',
      'Duke u kthyer anash nga sedilja dhe duke u ulur mbi të dyja këmbët',
      'Me shpinë nga jashtë, me fytyrë nga mjeti, si në një shkallë',
    ],
    correctIndex: 2,
    explanation: 'Vetëm me fytyrë nga mjeti mund t\'i përdorësh dorezat dhe '
        'shkallën dhe të mbash tri pika kontakti. Kthimi jashtë nga '
        'sedilja duket më i shpejtë, por i ngarkon gjurin dhe kyçin e '
        'këmbës me tërë peshën e trupit njëherësh — ky është gabimi më i '
        'shpeshtë i zbritjes.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Cila prej këtyre kapjeve NUK numërohet si pikë e sigurt '
        'kontakti?',
    options: [
      'Doreza te shtylla A',
      'Buza e derës',
      'Doreza te korniza e derës',
    ],
    correctIndex: 1,
    explanation: 'Buza e derës i takon një pjese të lëvizshme: dera mund të '
        'lëshojë ose të mbyllet, pikërisht kur ti vendos peshën mbi të. E '
        'njëjta gjë vlen për timonin, sedilen, gomën dhe qendrën e rrotës '
        '— pika të sigurta janë vetëm dorezat e parashikuara për këtë.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Ke skanerin dhe një pako në duar dhe do të zbresësh nga '
        'hapësira e ngarkesës. Çfarë është e saktë?',
    options: [
      'Së pari lëri të dyja mënjanë, pastaj zbrit me duar të lira',
      'Ta shtrëngosh pakon nën krah dhe të mbahesh me dorën e lirë',
      'Të zbresësh shpejt, meqë janë vetëm dy shkallë',
    ],
    correctIndex: 0,
    explanation: 'Me duar plot nuk ke tri pika kontakti dhe nuk e ndal dot '
        'një rrëzim. Varianti me një dorë tingëllon si kompromis, por '
        'është pikërisht situata në të cilën një rrëshqitje çon '
        'drejtpërdrejt në rrëzim: një pikë nuk të mban.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Ndalon në anë të rrugës dhe do të hapësh derën e shoferit. '
        'Çfarë e mbron më mirë një çiklist që vjen nga pas?',
    options: [
      'Ta hapësh derën vetëm një çarë dhe të presësh pak',
      'Ta hapësh derën shpejt dhe gjerë, që të duket mirë',
      'Para hapjes të shikosh shkurt në pasqyrën e jashtme',
      'Vështrim mbi sup dhe pasqyrë — dhe ta hapësh derën me dorën më të '
          'largët',
    ],
    correctIndex: 3,
    explanation: 'Kapja me dorën më të largët ta kthen trupin automatikisht '
        'prapa dhe e detyron vështrimin. Vetëm vështrimi i shkurtër në '
        'pasqyrë nuk mjafton, sepse një çiklist në këndin e vdekur '
        'pikërisht atëherë nuk duket; dhe një hapje sa një çarë nuk '
        'paralajmëron askënd që është tashmë pranë teje.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Cili është gjatë ngritjes kombinimi më i rrezikshëm për '
        'shtyllën kurrizore?',
    options: [
      'Të ngresh dhe gjatë kësaj të përdredhësh trupin',
      'Të ngresh me gjunjë fort të përkulur nga pozicioni i ulur',
      'Të ngresh me ngarkesën ngushtë pranë trupit',
    ],
    correctIndex: 0,
    explanation: 'Ngarkesa plus përdredhja i ngarkon disqet në mënyrë të '
        'njëanshme dhe është shkaku klasik i dëmtimeve akute të shpinës — '
        'në vend të kësaj lëviz këmbët. Pozicioni i ulur dhe ngarkesa afër '
        'trupit janë përkundrazi pikërisht teknika e drejtë.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Gjatë zbritjes përdredh lehtë këmbën, por mund të vazhdosh '
        'punën. Çfarë është e saktë?',
    options: [
      'Të presësh dhe të njoftosh vetëm nëse të dhemb ende ditën tjetër',
      'Të mos bësh asgjë — ishte vetëm një përdredhje pa mungesë',
      'Të njoftosh menjëherë dhe ta shënosh në librin e ndihmës së parë',
    ],
    correctIndex: 2,
    explanation: 'Vetëm rastet e dokumentuara vlejnë më vonë si aksident në '
        'punë, dhe një problem i patrajtuar i ligamenteve shërohet më keq. '
        'Pritja deri ditën tjetër është e përhapur dhe pikërisht arsyeja '
        'pse lidhja me punën më vonë shpesh nuk njihet më.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M8 — Dera dhe mjedisi
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Një qen i madh leh te porta e kopshtit. Klienti ka shënuar '
        'te udhëzimi i dorëzimit: „Qeni është i mirë." Çfarë bën?',
    options: [
      'Hyn i qetë — klienti e njeh qenin e vet më së miri',
      'Nuk hyn në pronë, provon kontaktin dhe e lë udhëzimin për kolegët',
      'E lë pakon përtej gardhit dhe vazhdon rrugën',
    ],
    correctIndex: 1,
    explanation: 'Një udhëzim dorëzimi nuk është leje sigurie: klienti e '
        'njeh qenin e vet në kontakt me familjen, jo me një njeri të huaj '
        'që mban një objekt të madh. Ta lësh pakon përtej gardhit nuk '
        'është përveç kësaj dorëzim i rregullt.',
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Një qen i lirë vjen drejt teje duke lehur. Çfarë është e '
        'saktë?',
    options: [
      'Të qëndrosh i qetë, ta largosh shikimin, t\'i kthesh anën dhe të '
          'tërhiqesh ngadalë',
      'Të kthehesh shpejt me vrap te mjeti dhe ta mbyllësh derën',
      'Të bërtasësh dhe ta ngresh pakon për mbrojtje',
    ],
    correctIndex: 0,
    explanation: 'Qetësia, shikimi i larguar dhe tërheqja e ngadaltë ia '
        'heqin qenit shkakun. Të vraposh te mjeti tingëllon e arsyeshme, '
        'por është e gabuar: ikja me vrap e nxit refleksin e gjuetisë, dhe '
        'qeni është më i shpejtë se ti.',
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Rruga më e shkurtër deri te dera kalon mbi një bar të '
        'lagësht. Çfarë bën?',
    options: [
      'Shkurton — me 120 ndalesa rruga shtesë mblidhet ndjeshëm',
      'Shkurton, por vetëm në dritë dite dhe në mot të thatë',
      'Merr rrugën e shtruar',
    ],
    correctIndex: 2,
    explanation: 'Pengimi, rrëshqitja dhe rrëzimi është shkaku më i '
        'shpeshtë i lëndimeve në shpërndarje, dhe pothuajse gjithmonë '
        'ndodh në metrat e fundit. Llogaria e kohës nuk del: rruga shtesë '
        'kushton sekonda, një rrëzim mesatarisht 24 ditë mungese.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Çfarë vlen, kur e lë mjetin për një dorëzim?',
    options: [
      'Motori fikur, çelësi merret, mbyllet, në pjerrësi rrotat kthehen',
      'Motori mund të punojë, për sa kohë mbetesh brenda pamjes',
      'Mjafton ta tërheqësh fort frenin e dorës',
    ],
    correctIndex: 0,
    explanation: 'Kush e lë mjetin e vet, duhet ta sigurojë kundër '
        'përdorimit të paautorizuar dhe të shmangë aksidentet. „Brenda '
        'pamjes" nuk është përjashtim — një mjet i ndezur dhe i hapur '
        'zhduket brenda sekondave, dhe në pjerrësi vetëm freni i dorës nuk '
        'e mban me siguri një furgon të ngarkuar.',
  ),

  // ══════════════════════════════════ M9 — Urgjenca dhe aksidenti
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Në cilën radhë vepron te një vend aksidenti me të lënduar?',
    options: [
      'Të japësh ndihmën e parë, pastaj të sigurosh vendin, pastaj të bësh '
          'thirrjen e urgjencës',
      'Të sigurosh vendin, pastaj thirrja e urgjencës, pastaj ndihma e '
          'parë',
      'Thirrja e urgjencës, pastaj foto për sigurimin, pastaj ndihma e '
          'parë',
    ],
    correctIndex: 1,
    explanation: 'Së pari siguro vendin, përndryshe nga një aksident bëhet '
        'një i dytë — me ty si viktimë. Të vraposh menjëherë te i lënduari '
        'duket njerëzisht e drejtë, por në rrugë ndërqytetëse dhe '
        'autostradë është rrezik për jetën; fotot nuk kanë fare vend në '
        'këtë fazë.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Në cilën distancë e vendos trekëndëshin në autostradë?',
    options: [
      'rreth 50 metra',
      'rreth 100 metra',
      'rreth 150–200 metra',
    ],
    correctIndex: 2,
    explanation: 'Brenda qytetit rreth 50 m, jashtë qytetit rreth 100 m, në '
        'autostradë 150–200 m — sa më e lartë shpejtësia, aq më herët '
        'duhet të qëndrojë paralajmërimi. Kush merr vlerën e jashtë '
        'qytetit, i jep trafikut që vjen pas me 120 km/h mezi tri sekonda. '
        'Para kodrinave dhe kthesave trekëndëshi shkon para tyre, jo pas '
        'tyre.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Në një autostradë me tri korsi trafiku ngadalësohet. Ku e '
        'formon korridorin e shpëtimit?',
    options: [
      'Mes korsisë së majtë dhe asaj të mesme',
      'Mes korsisë së mesme dhe asaj të djathtë',
      'Në korsinë e emergjencës',
      'Në mes të karrexhatës, pavarësisht nga numri i korsive',
    ],
    correctIndex: 0,
    explanation: 'Korridori qëndron gjithmonë mes korsisë krejt të majtë '
        'dhe asaj menjëherë djathtas saj — pavarësisht se sa korsi ka. '
        'Korsia e emergjencës nuk është alternativë: atje lëvizin forcat e '
        'urgjencës, kur korridori është i bllokuar.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Kur duhet formuar korridori i shpëtimit?',
    options: [
      'Vetëm kur shihet ose dëgjohet drita blu',
      'Sapo trafiku ngadalësohet',
      'Vetëm kur urdhërohet përmes tabelës elektronike',
    ],
    correctIndex: 1,
    explanation: 'Korridori lind me ngadalësimin, jo me dritën blu. Nëse '
        'pritet mjeti i urgjencës, mjetet qëndrojnë prej kohësh shumë '
        'afër — atëherë askush nuk ka më vend për t\'u shmangur.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Gjatë manovrimit dëmton një makinë të parkuar, askush nuk '
        'është afër. A mjafton një letër nën fshirësin e xhamit?',
    options: [
      'Po, nëse mbi të janë emri dhe numri i telefonit',
      'Po, një letër është rruga e parashikuar me ligj',
      'Jo — mjafton vetëm nëse bën edhe foto',
      'Jo — duhet të presësh një kohë të arsyeshme dhe përndryshe të '
          'informosh policinë',
    ],
    correctIndex: 3,
    explanation: 'Një letër ligjërisht nuk vlen si identifikim i '
        'mjaftueshëm — ajo mund të fluturojë ose të hiqet; kush '
        'mbështetet te ajo, rrezikon akuzën e largimit të palejuar nga '
        'vendi i aksidentit. Fotot e dokumentojnë vërtet dëmin, por nuk e '
        'zëvendësojnë as pritjen as njoftimin.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Një person pas aksidentit nuk merr frymë normalisht. Çfarë '
        'bën?',
    options: [
      'Fillon menjëherë masazhin e zemrës, rreth 100–120 herë për minutë',
      'E vendos personin në pozicion të qëndrueshëm anash dhe e mbulon',
      'Pret shërbimin e shpëtimit — si laik nuk lejohet të bësh asgjë',
    ],
    correctIndex: 0,
    explanation: 'Pa frymëmarrje normale çdo minutë numëron, dhe shtypja '
        'është masa e vetme që ndihmon. Pozicioni i qëndrueshëm anash '
        'është i saktë — por vetëm kur ka frymëmarrje normale. Dhe të mos '
        'bësh asgjë është vendimi i vetëm i gabuar: mosdhënia e ndihmës '
        'është e dënueshme.',
  ),

  // ══════════════════════════════════ M10 — Përmbledhje
  DrivingQuestion(
    moduleId: 'm10',
    question: 'Çfarë e përmbledh më mirë qëndrimin e këtij trajnimi?',
    options: [
      'Rregullat vlejnë sidomos atëherë kur ka kontroll',
      'Siguria është vendimi im i përditshëm, që të gjithë të kthehen të '
          'sigurt në shtëpi',
      'Kryesorja është që turi të kryhet në kohë',
    ],
    correctIndex: 1,
    explanation: 'Siguria është një qëndrim, jo një ushtrim i detyruar — '
        'dhe ajo tregohet pikërisht atëherë kur askush nuk shikon. Kush i '
        'lidh rregullat me kontrollet, nuk i ka kuptuar, por vetëm i ka '
        'duruar.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm10',
    question: 'Sa pika kontakti mban gjatë hipjes dhe zbritjes — dhe sa '
        'sekonda distancë së paku në rrugë të thatë?',
    options: [
      '2 pika kontakti dhe 1 sekondë',
      '3 pika kontakti dhe 1 sekondë',
      '3 pika kontakti (2 duar + 1 këmbë) dhe 2 sekonda',
    ],
    correctIndex: 2,
    explanation: 'Tri pika kontakti („2+1") dhe dy sekonda distancë — në '
        'lagështi tri. Një sekondë distancë i përgjigjet me shpejtësi 50 '
        'pikërisht rrugës së pastër të reagimit: do të përplaseshe pa '
        'asnjë rezervë frenimi.',
  ),
];

// Zgjidhja e gjuhës, `drivingQuestionsForModule()` dhe `buildDrivingExam()`
// ndodhen në driving_safety_data.dart.
