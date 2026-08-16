// lib/data/safety_training/privacy_quiz_sq.dart
//
// Pyetjet e testit përfundimtar të trajnimit për mbrojtjen e të dhënave
// — versioni shqip. Tetëmbëdhjetë pyetje, të shpërndara njësoj në
// gjashtë kapitujt nga privacy_content_sq.dart (nga tri pyetje për
// kapitull ds1 … ds6). Struktura identike me privacy_quiz_de.dart
// (master) — të njëjtat pyetje, i njëjti renditje, i njëjti
// `correctIndex`.
//
// Kërkesa e pyetjeve: skenarë nga përditshmëria e dorëzimit dhe pyetje
// mbi pasojat ligjore. Disa opsione tingëllojnë me qëllim të besueshme
// — çdo herë varet nga një detaj. `explanation` shpjegon gjithmonë të
// dyja: pse përgjigjja e saktë është e saktë dhe pse gabimi i afërt
// është i gabuar.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> privacyQuestionsSq = [
  // ══════════════════════════ ds1 — Pse mbrojtja e të dhënave të prek
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Cila nga këto të dhëna NUK është e dhënë personale në '
        'kuptimin e DSGVO-së (GDPR)?',
    options: [
      'Numri i përgjithshëm i pakove të dorëzuara sot në tur',
      'Udhëzimi „Pakon lëre pas koshit të plehrave" me adresën përkatëse',
      'Fotoja e dorëzimit para derës së një marrësi',
    ],
    correctIndex: 0,
    explanation: 'Një numër i thjeshtë copësh pa lidhje me një person nuk '
        'është personal. Udhëzimi i lënies, përkundrazi, tregon diçka për '
        'mënyrën e banimit të një njeriu të caktuar, dhe fotoja e '
        'dorëzimit i është caktuar një adrese. Gabimi i afërt është të '
        'mendosh se personale janë vetëm emrat — personale është çdo e '
        'dhënë me të cilën mund të identifikohet një person.',
  ),
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Në mbrëmje u tregon miqve në cilën rrugë banon një '
        'sportist i njohur, pakon e të cilit e ke dorëzuar. Si '
        'vlerësohet kjo?',
    options: [
      'Pa problem, për sa kohë nuk e vendos emrin në internet',
      'Një shkelje e kufizimit të qëllimit dhe konfidencialitetit sipas '
          'Art. 5 DSGVO',
      'Pa problem, sepse një adresë është gjithsesi publikisht e njohur',
    ],
    correctIndex: 1,
    explanation: 'Adresën e njeh vetëm nga puna jote. T\'ua japësh të '
        'tjerëve është një zbulim jashtë qëllimit dhe shkel Art. 5 '
        'Abs. 1 lit. b dhe lit. f DSGVO. Gabimi i afërt është të mendosh '
        'se një rreth i vogël privat nuk llogaritet — DSGVO-ja nuk pyet '
        'për madhësinë e publikut.',
  ),
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Nga cilat dispozita rrjedh që firma duhet të të trajnojë '
        'për mbrojtjen e të dhënave?',
    options: [
      'Nga § 12 Abs. 1 i ligjit për mbrojtjen në punë — mbrojtja e të '
          'dhënave është pjesë e udhëzimit vjetor të sigurisë',
      'Nga një detyrim i shprehur trajnimi në Art. 30 DSGVO',
      'Në mënyrë të tërthortë nga Art. 32, Art. 39 Abs. 1 lit. b dhe '
          'Art. 5 Abs. 2 DSGVO',
    ],
    correctIndex: 2,
    explanation: 'DSGVO-ja nuk njeh një detyrim të shprehur trajnimi. Ai '
        'rrjedh tërthorazi: Art. 32 kërkon masa organizative, Art. 39 '
        'Abs. 1 lit. b e përmend sensibilizimin dhe trajnimin si detyrë '
        'të përgjegjësit për mbrojtjen e të dhënave, dhe Art. 5 Abs. 2 '
        'kërkon provën e respektimit. Art. 30, përkundrazi, ka të bëjë '
        'me regjistrin e aktiviteteve të përpunimit, dhe ligji i '
        'mbrojtjes në punë (ArbSchG) rregullon sigurinë në punë, jo '
        'mbrojtjen e të dhënave.',
  ),

  // ══════════════════════════ ds2 — Fotot dhe provat e dorëzimit
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'Çfarë mund të duket në një foto dorëzimi?',
    options: [
      'Marrësi, nëse ka dhënë gojarisht pëlqimin për fotografimin',
      'Pakoja në vendin e lënies, plus dera ose numri i shtëpisë si '
          'referencë vendi',
      'Pakoja dhe targa e automjetit të parkuar përpara, për identifikim '
          'më të mirë',
    ],
    correctIndex: 1,
    explanation: 'Fotoja i përgjigjet saktësisht një pyetjeje: Ku ndodhet '
        'pakoja? Gjithçka përtej kësaj shkel minimizimin e të dhënave '
        'sipas Art. 5 Abs. 1 lit. c DSGVO. Personat nuk kanë vend në '
        'provë as me pëlqim gojor, dhe një targë është një e dhënë '
        'personale që nuk nevojitet për qëllimin.',
  ),
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'Skaneri nuk punon. Fotografon vendin e lënies me kamerën '
        'normale të telefonit dhe e ngarkon foton pastaj në aplikacionin '
        'e punës. Çfarë është gabim këtu?',
    options: [
      'Asgjë — e rëndësishme është vetëm që fotoja të përfundojë në '
          'aplikacion',
      'Vetëm cilësia e fotos, ligjërisht është pa problem',
      'Fotoja mbetet pastaj përgjithmonë në galerinë private, shpesh '
          'edhe në një cloud privat',
    ],
    correctIndex: 2,
    explanation: 'Ngarkimi nuk e heq kopjen: Origjinali mbetet në '
        'galerinë private dhe shpesh ruhet automatikisht në një cloud. '
        'Kështu të dhënat personale ndodhen jashtë kontrollit të firmës. '
        'Gabimi i afërt është të mendosh se llogaritet vetëm gjendja '
        'përfundimtare — vendimtare është çdo kopje që krijohet gjatë '
        'rrugës.',
  ),
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'Pas mbylljes së ndalesës vë re se në foton e ngarkuar '
        'njihet një fqinjë. Çfarë bën?',
    options: [
      'Njoftoj dispeçerin ose drejtorinë e firmës, që fotoja të fshihet '
          'në sistem',
      'Asgjë — ndalesa është mbyllur, fotoja gjithsesi nuk ndryshohet më',
      'Të nesërmen i bie ziles së fqinjës dhe i kërkoj leje',
    ],
    correctIndex: 0,
    explanation: 'Vetëm nëse firma e di, mund ta fshijë foton dhe ta '
        'dokumentojë rastin. Gabimi i afërt është të mendosh se një '
        'raportim pas mbylljes së ndalesës s\'ia vlen më. Një pëlqim i '
        'mëvonshëm nuk e shëron shkeljen dhe veç kësaj nuk është bazë '
        'ligjore e qëndrueshme në kontekstin e punës.',
  ),

  // ══════════════════════════ ds3 — Puna me të dhënat e marrësve
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Bën një screenshot të listës së adresave për ta mbajtur '
        'mend më mirë radhën. Askush tjetër nuk e sheh. A lejohet kjo?',
    options: [
      'Po, për sa kohë e fshin screenshot-in në fund të turit',
      'Po, sepse të dhënat gjithsesi mund t\'i përpunosh për punë',
      'Jo — një screenshot është një kopje jashtë sistemit dhe me këtë '
          'i palejueshëm',
    ],
    correctIndex: 2,
    explanation: 'Me screenshot-in krijohet një kopje e të dhënave '
        'personale, të cilën firma nuk mund ta kontrollojë më. Që të '
        'dhënat mund t\'i shohësh për punë, nuk të lejon t\'i ruash '
        'jashtë sistemit. Edhe qëllimi për t\'i fshirë më vonë nuk '
        'ndryshon asgjë te përpunimi i palejueshëm.',
  ),
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Një fqinj merr një pako dhe pyet çfarë ka brenda dhe nëse '
        'marrësi banon ende aty. Çfarë i thua?',
    options: [
      'Vetëm emrin e marrësit dhe numrin e shtëpisë — për përmbajtjen '
          'dhe të dhëna të tjera asnjë informacion',
      'Gjithçka që shkruhet në etiketë, sepse ai po e merr pakon',
      'Asgjë, as emrin e marrësit',
    ],
    correctIndex: 0,
    explanation: 'Për dorëzimin te fqinji nevojiten emri dhe numri i '
        'shtëpisë — pa to fqinji nuk mund ta japë pakon më tej. Gjithçka '
        'përtej kësaj, sidomos përmbajtja ose konfirmimi i vendbanimit, '
        'është një zbulim pa bazë ligjore sipas Art. 6 DSGVO. Të mos '
        'thuash fare asgjë do të ishte, përkundrazi, jopraktike dhe do '
        'ta bënte dorëzimin të pamundur.',
  ),
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Turi ka mbaruar, lista e letrës e turit nuk nevojitet më. '
        'Si e asgjëson drejt?',
    options: [
      'Në kazanin e letrës te banesa jote, sapo të arrish në shtëpi',
      'Përmes rrugës së parashikuar në firmë — koshi për mbrojtjen e të '
          'dhënave ose grirësja e letrës',
      'E grisur në mbeturinat e karburantit, që të mos e lexojë më '
          'askush',
    ],
    correctIndex: 1,
    explanation: 'Në listë ka emra dhe adresa; ajo duhet asgjësuar ashtu '
        'që të mos rikuperohet — në firmë përmes koshit për mbrojtjen e '
        'të dhënave ose grirëses së letrës. Gabimi i afërt është të '
        'mendosh se një listë e kryer është pa vlerë. Kazanët publikisht '
        'të aksesueshëm përjashtohen, dhe në shtëpi listën gjithsesi nuk '
        'do të duhej ta kishe marrë.',
  ),

  // ══════════════════════════ ds4 — Të dhënat e tua dhe të kolegëve
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Një koleg të lutet për një screenshot të një analize të '
        'brendshme, ku janë të gjithë shoferët me emra dhe vlera. Ai do '
        'të shohë vetëm rreshtin e vet. Si reagon?',
    options: [
      'Refuzoj dhe e drejtoj te drejtoria e firmës — ai ka të drejtë '
          'vetëm për të dhënat e veta',
      'Ia dërgoj, sepse ai vetë është në listë dhe prandaj ka të drejtë '
          'aksesi',
      'Ia dërgoj, por më parë i fsheh emrat e të tjerëve dhe pastaj e '
          'fshij screenshot-in',
    ],
    correctIndex: 0,
    explanation: 'Me screenshot-in ai do të merrte të dhënat e '
        'performancës së të gjithë kolegëve — një dhënie e të dhënave të '
        'punonjësve pa bazë ligjore. E drejta e tij e informimit sipas '
        'Art. 15 DSGVO ka të bëjë vetëm me të dhënat e veta. Edhe një '
        'fshehje e improvizuar nuk ndryshon faktin që ke krijuar një '
        'kopje të palejueshme.',
  ),
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Pse raportimet si i sëmurë të kolegëve mbrohen '
        'veçanërisht?',
    options: [
      'Sepse në kontratën e punës cilësohen shprehimisht si '
          'konfidenciale',
      'Sepse janë sekrete biznesi sipas GeschGehG',
      'Sepse të dhënat shëndetësore janë kategori të veçanta të dhënash '
          'personale sipas Art. 9 DSGVO',
    ],
    correctIndex: 2,
    explanation: 'Të dhënat shëndetësore bien nën Art. 9 DSGVO dhe u '
        'nënshtrohen një mbrojtjeje më të rreptë se të dhënat e '
        'zakonshme. Vetë fakti i sëmundjes është një e dhënë e tillë, '
        'arsyeja aq më tepër. Sekretet e biznesit, përkundrazi, kanë të '
        'bëjnë me dijen e firmës, jo me të dhënat shëndetësore të '
        'punonjësve.',
  ),
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Do të dish cilat të dhëna ka ruajtur punëdhënësi yt për '
        'ty. Cilën të drejtë përdor për këtë?',
    options: [
      'Të drejtën e bartjes së të dhënave sipas Art. 20 DSGVO',
      'Të drejtën e informimit sipas Art. 15 DSGVO',
      'Të drejtën e kundërshtimit sipas Art. 21 DSGVO',
    ],
    correctIndex: 1,
    explanation: 'Art. 15 DSGVO të jep të drejtën për një pasqyrë të të '
        'dhënave të ruajtura për ty dhe të qëllimeve. Art. 20 ka të bëjë '
        'me dorëzimin në një format të bartshëm, Art. 21 me '
        'kundërshtimin e një përpunimi — asnjëra nuk i përgjigjet '
        'pyetjes se çfarë është ruajtur fare. Kërkesës duhet t\'i '
        'përgjigjet në parim brenda një muaji.',
  ),

  // ══════════════════════════ ds5 — Incidenti i të dhënave
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Cili nga këta raste NUK është incident i të dhënave?',
    options: [
      'Ke dorëzuar një pako te marrësi i gabuar, që e ka hapur',
      'Ke gabuar në numërimin e kthimeve në raportin ditor',
      'Ke lënë listën e turit hapur në automjetin e pambyllur',
    ],
    correctIndex: 1,
    explanation: 'Një gabim numërimi te kthimet nuk prek të dhëna '
        'personale dhe nuk ia bën ato të aksesueshme askujt. Në dy '
        'rastet e tjera, persona të paautorizuar mund të shihnin emra, '
        'adresa ose përmbajtje dërgesash — kjo është një shkelje e '
        'mbrojtjes së të dhënave personale.',
  ),
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Çfarë thotë afati 72-orësh i Art. 33 DSGVO?',
    options: [
      'Firma duhet ta raportojë një incident të të dhënave mundësisht '
          'brenda 72 orësh pas marrjes dijeni te autoriteti mbikëqyrës',
      'Shoferi ka 72 orë kohë ta raportojë rastin në firmë',
      'Të prekurit duhet të ankohen brenda 72 orësh te firma, përndryshe '
          'humbin të drejtën',
    ],
    correctIndex: 0,
    explanation: 'Afati e detyron firmën ndaj autoritetit mbikëqyrës dhe '
        'ecën nga marrja dijeni. Pikërisht prandaj ti duhet të raportosh '
        'menjëherë — çdo orë që pret, i mungon firmës. Gabimi i afërt '
        'është t\'i lexosh 72 orët si dritare kohore të vetën e '
        'shoferit.',
  ),
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Në mbrëmje ke vënë re se një pako ka përfunduar te marrësi '
        'i gabuar dhe aty është hapur. Çfarë është e drejtë?',
    options: [
      'Ta marr nesër në mëngjes pa u vënë re dhe ta dorëzoj drejt — '
          'kështu gabimi është rregulluar',
      'Ta përmend vetëm në bisedën e ardhshme të punës, sepse gjithsesi '
          'asgjë nuk ndryshohet më',
      'Të njoftoj po atë ditë dispeçerin ose drejtorinë e firmës dhe të '
          'mos ndërmarr asgjë me kokën time',
    ],
    correctIndex: 2,
    explanation: 'Tashmë ekziston një incident i të dhënave: Një person '
        'i huaj ka mësuar emrin, adresën dhe përmbajtjen e dërgesës. '
        'Firma duhet të vlerësojë, të dokumentojë dhe sipas rastit të '
        'raportojë sipas Art. 33 DSGVO — për këtë i duhet informacioni '
        'menjëherë. Korrigjimi i heshtur duket i padëmshëm, por pengon '
        'pikërisht këto hapa. Kush raporton menjëherë, vepron drejt.',
  ),

  // ══════════════════════════ ds6 — Diskrecioni dhe besnikëria
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'Cila shprehje NUK mbulohet nga liria e shprehjes?',
    options: [
      'Thënia se një tur rregullisht nuk arrihet në kohën e planifikuar',
      'Vërejtja se një automjet nuk është riparuar megjithë raportimet e '
          'shumta',
      'Pohimi i pavërtetë me vetëdije se firma i mashtron shoferët e '
          'saj sistematikisht me orët',
    ],
    correctIndex: 2,
    explanation: 'Shprehjet e mendimit dhe kritika e vërtetë mbrohen nga '
        'Art. 5 Abs. 1 GG, edhe kur janë të pakëndshme. Pohimet e '
        'fakteve të pavërteta me vetëdije nuk mbrohen: Ato mund të '
        'justifikojnë një pushim të menjëhershëm nga puna sipas § 626 '
        'BGB dhe, në rast përgojimi, të jenë veç kësaj të ndëshkueshme '
        'sipas § 186 StGB.',
  ),
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'Raporton sipas dijes më të mirë një parregullsi në firmë. '
        'Në fund del se dyshimi yt nuk qëndronte. Çfarë vlen?',
    options: [
      'Mbrojtja bie prapaveprueshëm, sepse raportimi ishte i gabuar',
      'Mbetesh i mbrojtur nga hakmarrjet përmes ligjit për mbrojtjen e '
          'sinjalizuesve',
      'Mbrojtja vlen vetëm nëse raportimin e ke dorëzuar edhe jashtë '
          'firmës',
    ],
    correctIndex: 1,
    explanation: 'HinSchG (që nga 2 korriku 2023) i mbron punonjësit që '
        'raportojnë shkelje nga hakmarrjet si pushimi nga puna, vërejtja '
        'ose disfavorizimi. Mbrojtja bie vetëm në raportime të pasakta '
        'me vetëdije ose nga pakujdesia e rëndë — jo në një dyshim '
        'serioz që në fund nuk konfirmohet. Një raportim i jashtëm nuk '
        'nevojitet për këtë.',
  ),
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'Në grupin e chatit të shoferëve diskutohet për shkurtime '
        'të supozuara pagash. Edhe ti vetë je i pakënaqur. Cila është '
        'rruga e drejtë?',
    options: [
      'Të përmend rastin tim konkret dhe t\'ia jap dispeçerit, '
          'drejtorisë së firmës ose zyrës së brendshme të raportimit',
      'Ta konfirmoj pohimin në grup, që kolegët të jenë të paralajmëruar',
      'Ta postoj akuzën publikisht në një portal vlerësimi, që të lëvizë '
          'diçka',
    ],
    correctIndex: 0,
    explanation: 'Rasti yt i verifikueshëm është i vërtetë, objektiv dhe '
        'i mbrojtur nga HinSchG — dhe brenda firmës zgjidhet më shpejt. '
        'Të konfirmosh një pohim që vetë nuk e ke përjetuar, është një '
        'pohim fakti i pavërtetë; një grup chati i mbyllur nuk është '
        'hapësirë e mbrojtur sapo qarkullon një screenshot. Dalja jashtë '
        'vjen në konsideratë vetëm kur brenda nuk ndodh asgjë.',
  ),
];
