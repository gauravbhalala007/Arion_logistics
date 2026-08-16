// lib/data/safety_training/green_book_quiz_sq.dart
//
// Pyetjet e testit përfundimtar Green Book (libri i kontrollit të
// udhëtimeve sipas § 1 Abs. 6 FPersV) — versioni shqip. Struktura është
// identike me versionin gjerman (master): i njëjti numër pyetjesh, i
// njëjti rend, të njëjtat përgjigje të sakta.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> greenBookQuestionsSq = [
  // ══════════════════════════ gb1 — Çfarë është Green Book-u
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Çfarë dokumenton në Green Book?',
    options: [
      'Gjendjen e mjetit para nisjes',
      'Numrin e pakove të dorëzuara dhe të kthimeve',
      'Kohët e ngasjes, ndërprerjet e udhëtimit si dhe kohët e punës e të '
          'pushimit',
    ],
    correctIndex: 2,
    explanation: 'Green Book-u është libri i kontrollit të udhëtimeve — '
        'mbledhja e fletëve ditore të kontrollit sipas § 1 Abs. 6 FPersV. '
        'Ai dëshmon vetëm kohët. Gjendja e mjetit dokumentohet diku tjetër '
        'dhe shprehimisht nuk hyn këtu.',
  ),
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Për cilat mjete vlen detyrimi i regjistrimit sipas § 1 '
        'Abs. 6 FPersV?',
    options: [
      'Mbi 2,8 t deri në 3,5 t masë maksimale e lejuar në transportin '
          'tregtar të mallrave',
      'Për çdo mjet me të cilin transportohen pako në mënyrë tregtare',
      'Vetëm nga 3,5 t masë maksimale e lejuar',
    ],
    correctIndex: 0,
    explanation: 'Detyrimi vlen në brezin mbi 2,8 t deri në 3,5 t — '
        'pikërisht furgoni tipik i shpërndarjes. Nën 2,8 t ai nuk '
        'ekziston, nga 3,5 t regjistrimin e merr përsipër tahografi '
        'digjital.',
  ),
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Furgoni yt ka sipas lejes së qarkullimit 3,5 t masë '
        'maksimale të lejuar, por sot është i ngarkuar vetëm me 900 kg. '
        'Çfarë vlen?',
    options: [
      'Pa detyrim regjistrimi — pesha e vërtetë është nën 2,8 t',
      'Detyrimi i regjistrimit mbetet',
      'Detyrimi vlen vetëm nga një distancë ditore prej 100 kilometrash',
    ],
    correctIndex: 1,
    explanation: 'Vendimtare është masa maksimale e lejuar nga leja e '
        'qarkullimit, jo pesha e sotme e ngarkesës. Gabimi i afërt është '
        'të llogaritet çdo ditë nga e para sipas ngarkesës — klasifikimi i '
        'mjetit nuk ndryshon nga kjo.',
  ),

  // ══════════════════════════ gb2 — Çfarë shënohet saktësisht
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Cila e dhënë NUK bën pjesë te të dhënat e detyrueshme të '
        'fletës ditore të kontrollit?',
    options: [
      'Gjendja e kilometrazhit në fillim dhe në fund të udhëtimit',
      'Numri i dërgesave të dorëzuara',
      'Vendi i nisjes dhe i mbarimit të udhëtimit',
    ],
    correctIndex: 1,
    explanation: 'Të parashikuara janë ndër të tjera mbiemri, emri dhe '
        'adresa e shoferit, targa, data, kilometrazhet, vendet, kohët dhe '
        'nënshkrimi. Numrat e copëve janë tregues i brendshëm i firmës dhe '
        'nuk qëndrojnë në fletë.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Me çfarë e plotëson fletën ditore të kontrollit?',
    options: [
      'Me stilolaps, me shkrim të pafshirshëm',
      'Me laps, që gabimet të korrigjohen pastër',
      'Mjeti i shkrimit nuk ka rëndësi, mjafton të lexohet',
    ],
    correctIndex: 0,
    explanation: 'Një shënim që mund të fshihet nuk është dëshmi. '
        'Pikërisht prandaj lapsi nuk lejohet — edhe nëse korrigjimi është '
        'me qëllim të mirë. Një gabim vijëzohet një herë dhe rishkruhet '
        'pranë.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Të gjitha kohët dhe kilometrazhet janë shënuar, mungon '
        'vetëm nënshkrimi. Çfarë vlen për këtë fletë?',
    options: [
      'Është e vlefshme — nënshkrimi është formalitet i pastër',
      'Quhet e paplotë dhe nuk e përmbush detyrimin e regjistrimit',
      'Dispeçeri mund ta bashkënënshkruajë më vonë në firmë',
    ],
    correctIndex: 1,
    explanation: 'Nënshkrimi është një nga të dhënat e parashikuara — me '
        'të vërteton përmbajtjen. Pa të fleta është e paplotë, me të '
        'njëjtat pasoja si një fletë që mungon. Një nënshkrim i huaj nuk e '
        'zëvendëson tëndin.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Pret 40 minuta te rampa. Nuk bën asgjë, por duhet të jesh '
        'gati në çdo moment, sepse mund të vazhdohet menjëherë. Si e '
        'shënon këtë kohë?',
    options: [
      'Si ndërprerje udhëtimi — në fund të fundit nuk ke punuar',
      'Si fillim të kohës ditore të pushimit',
      'Si kohë pune',
    ],
    correctIndex: 2,
    explanation: 'Një ndërprerje udhëtimi është pushim vetëm nëse mund të '
        'disponosh lirisht kohën dhe e di këtë paraprakisht. Të qenët gati '
        'është kohë pritjeje dhe kështu kohë pune. Gabimi i afërt është '
        '„nuk bëra asgjë, pra ishte pushim" — vendimtare nuk është '
        'veprimtaria, por disponueshmëria.',
  ),

  // ══════════════════════════ gb3 — Kohët e ngasjes dhe të pushimit
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Sa gjatë guxon të ngasësh më së shumti në një ditë normale?',
    options: [
      '9 orë',
      '10 orë',
      '8 orë, pastaj vetëm me miratimin e dispeçerit',
    ],
    correctIndex: 0,
    explanation: 'Koha ditore e ngasjes është më së shumti 9 orë. 10 orët '
        'nuk janë kufi i dytë i rregullt, por një përjashtim i kufizuar '
        'ngushtë — dhe një miratim i firmës nuk luan fare rol për kufirin.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Sa shpesh guxon ta zgjatësh kohën e ngasjes në 10 orë?',
    options: [
      'Një herë në javë',
      'Dy herë në javë',
      'Çdo ditë kur tura e kërkon',
    ],
    correctIndex: 1,
    explanation: 'Dy herë në javë koha ditore e ngasjes mund të zgjatet në '
        '10 orë. Është kuotë javore, jo e drejtë ditore — dhe madhësia e '
        'turës nuk e zgjat atë.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Do ta ndash ndërprerjen e udhëtimit prej 45 minutash. Cila '
        'ndarje lejohet?',
    options: [
      'Fillimisht 30 minuta, pastaj 15 minuta',
      'Tri herë nga 15 minuta të shpërndara gjatë ditës',
      'Fillimisht 15 minuta, pastaj 30 minuta',
    ],
    correctIndex: 2,
    explanation: 'Ndarja lejohet vetëm në dy pjesë dhe vetëm në këtë rend: '
        'fillimisht të paktën 15, pastaj të paktën 30 minuta. Rendi i '
        'kundërt nuk vlen, as tri pjesë të shkurtra — edhe nëse shuma del.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Nisesh në orën 07:00. Deri në 09:30 rri 2 orë në timon, '
        'deri në 12:00 shtohen 2 orë të tjera kohë ngasjeje, deri në 13:00 '
        'edhe 30 minuta. Kur duhet më së voni ndërprerja e udhëtimit?',
    options: [
      'Në orën 11:30, pra 4,5 orë pas fillimit të shërbimit',
      'Në orën 12:00, sepse koha e drekës është parashikuar për këtë',
      'Në orën 13:00',
    ],
    correctIndex: 2,
    explanation: '2 + 2 + 0,5 orë japin në orën 13:00 saktësisht 4,5 orë '
        'kohë të pastër ngasjeje — tani nuk guxon të ngasësh asnjë metër '
        'para se të kryhet pushimi. Gabimi i afërt është të llogaritet nga '
        'fillimi i shërbimit: ora ecën vetëm kur mjeti lëviz.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'E mbyll kohën e ngasjes në orën 17:15. Kur guxon të nisesh '
        'sërish më së hershmi?',
    options: [
      'Në orën 02:15 — 9 orë pushim mjaftojnë',
      'Në orën 04:15',
      'Sapo të ndihesh i pushuar, nuk ka kufi të fiksuar',
    ],
    correctIndex: 1,
    explanation: 'Pushimi ditor është të paktën 11 orë, pra më së hershmi '
        'ora 04:15. 9 orët janë kufiri për kohën e ngasjes, jo për '
        'pushimin — të dy numrat ngatërrohen rregullisht.',
  ),

  // ══════════════════════════ gb4 — Gabimet tipike
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Një koleg i plotëson fletët e gjithë javës të premten në '
        'mbrëmje. Kohët përmbajtësisht janë të sakta. Si vlerësohet kjo?',
    options: [
      'Është shkelje dhe bie në sy në një kontroll',
      'Pa problem, për sa kohë kohët e shënuara i përgjigjen të vërtetës',
      'Vetëm çështje rregulli, por pa rëndësi juridike',
    ],
    correctIndex: 0,
    explanation: 'Të regjistrosh do të thotë të regjistrosh në kohë. '
        'Fletët e shkruara më vonë njihen nga i njëjti shkrim, nga kohët '
        'çuditërisht të rrumbullakëta dhe nga kilometrazhet që nuk '
        'përputhen me rrugën. Që kohët janë të sakta nuk e shëron shkeljen '
        'e detyrimit të regjistrimit.',
  ),
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Të enjten vëren se të martën pushimi i drekës nuk është '
        'shënuar. E mban mend me siguri orën. Çfarë bën?',
    options: [
      'E shënon si shtesë me datën e plotësimit dhe njofton dispeçerin',
      'E fut shënimin ashtu që të duket sikur është shkruar të martën',
      'E lë boshllëkun — një shtesë e bën vetëm më keq',
    ],
    correctIndex: 0,
    explanation: 'Një korrigjim i ndershëm dhe dukshëm i datuar është i '
        'lejuar dhe më i mirë se një boshllëk. Ta formosh shënimin sikur '
        'të kishte lindur të martën është hapi nga pakujdesia te mashtrimi '
        '— dhe peshon dukshëm më rëndë.',
  ),
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Sot ke ngarë 9,5 orë, edhe pse kuota jote javore për 10 orë '
        'ishte tashmë e shpenzuar. Çfarë shënon?',
    options: [
      'Saktësisht 9,0 orë — që fleta të duket sipas rregullit',
      '9,5 orët e ngara në të vërtetë',
      'Për këtë ditë asgjë, atëherë nuk bie në sy',
    ],
    correctIndex: 1,
    explanation: 'Gjithmonë shënon kohët e vërteta. Një shënim i zbukuruar '
        'e kthen një tejkalim në një të dhënë të rreme dhe e përkeqëson '
        'çështjen. Edhe një fletë që mungon është shkelje më vete — lënia '
        'jashtë nuk ndihmon.',
  ),

  // ══════════════════════════ gb5 — Mbajtja, dorëzimi, ruajtja
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Cilat regjistrime duhet të mbash me vete në mjet?',
    options: [
      'Vetëm fletën e ditës në vazhdim',
      'Fletët e javës kalendarike në vazhdim',
      'Ditën në vazhdim dhe 28 ditët e mëparshme',
    ],
    correctIndex: 2,
    explanation: 'Me vete mbahen regjistrimet e 28 ditëve të fundit, '
        'përfshirë ditën në vazhdim. Që fletët më të vjetra qëndrojnë me '
        'rregull në firmë e përmbush detyrimin e ruajtjes, por jo atë të '
        'mbajtjes me vete — janë dy detyrime të ndara.',
  ),
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Sa gjatë duhet t’i ruajë sipërmarrësi fletët ditore të '
        'kontrollit në firmë?',
    options: [
      'Një vit',
      '28 ditë, pastaj mund të asgjësohen',
      'Tre muaj nga fundi i tremujorit',
    ],
    correctIndex: 0,
    explanation: 'Sipërmarrësi i ruan regjistrimet një vit dhe i paraqet '
        'me kërkesë. 28 ditët janë afati për mbajtjen me vete nga shoferi '
        '— ato ngatërrohen shpesh me afatin e ruajtjes.',
  ),
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Kush e kontrollon respektimin e detyrimit të regjistrimit?',
    options: [
      'Vetëm policia, dhe vetëm në kontrollet rrugore',
      'BAG-u dhe policia — në kontrollet rrugore dhe në firmë',
      'TÜV-i në kuadër të kontrollit teknik të mjetit',
    ],
    correctIndex: 1,
    explanation: 'Kontrollohet nga BAG-u (Bundesamt für Logistik und '
        'Mobilität, zyra federale gjermane për logjistikë dhe mobilitet) '
        'dhe nga policia, si në rrugë ashtu edhe në firmë. Kontrolli '
        'teknik ka të bëjë me gjendjen teknike të mjetit dhe nuk lidhet me '
        'regjistrimet.',
  ),

  // ══════════════════════════ gb6 — Pasojat
  DrivingQuestion(
    moduleId: 'gb6',
    question: 'Me çfarë duhet llogaritur, nëse fletët mungojnë ose janë të '
        'paplota?',
    options: [
      'Me një gjobë nga 100 euro, sipas rëndësisë edhe më të lartë',
      'Me asnjë pasojë — është rregull thjesht i brendshëm i firmës',
      'Me një vërejtje pa pagesë dhe pa pasoja të tjera',
    ],
    correctIndex: 0,
    explanation: 'Regjistrimet që mungojnë ose janë të paplota janë '
        'kundërvajtje administrative; gjoba fillon rreth 100 euro dhe '
        'rritet me rëndësinë e shkeljes. Në shkelje të rënda ose të '
        'përsëritura mund të hapet gjithashtu një procedurë për '
        'besueshmërinë e firmës.',
  ),
  DrivingQuestion(
    moduleId: 'gb6',
    question: 'Dispeçeri thotë: „Ngaji edhe dy ndalesat, pushimin thjesht '
        'shkruaje brenda." Si reagon?',
    options: [
      'Ndjek urdhrin — përgjegjësinë e mban atëherë dispeçeri',
      'E lë pushimin jashtë, por të paktën shëno ndershmërisht se mungon',
      'Bën pushimin, e shënon saktë dhe raporton ndalesat e hapura',
    ],
    correctIndex: 2,
    explanation: 'Një urdhër gojor nuk e heq detyrimin tënd të '
        'regjistrimit — ti e nënshkruan fletën dhe me këtë vërteton '
        'përmbajtjen. Ta lësh me vetëdije pushimin jashtë do të ishte '
        'përveç kësaj shkelje e rregullave të kohës së ngasjes. Firma '
        'duhet ta mundësojë respektimin, jo ta anashkalojë.',
  ),
];
