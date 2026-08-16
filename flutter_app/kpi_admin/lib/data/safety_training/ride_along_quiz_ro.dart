// lib/data/safety_training/ride_along_quiz_ro.dart
//
// Întrebările testului final Ride Along — versiunea română.
// Structura este identică cu versiunea germană (master): cincisprezece
// întrebări, repartizate pe cele cinci capitole din
// ride_along_content_ro.dart (ra1 … ra5), câte trei întrebări per
// capitol, aceeași ordine a opțiunilor și aceleași răspunsuri corecte.
//
// Compatibil cu mai mulți operatori: nicăieri nu se întreabă despre
// cifre specifice unei firme (număr de opriri, ore din Waiting Area,
// partea de parcare) — doar despre ce este valabil peste tot. Excepțiile
// cu temei legal: § 4 ArbZG (pauzele) și § 1 alin. 6 FPersV (Green
// Book).

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> rideAlongQuestionsRo = [
  // ══════════════════════════ ra1 — Ce este Ride Along
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'Ce este Ride Along?',
    options: [
      'O instruire teoretică la birou, înainte de prima zi de lucru',
      'Două zile de lucru cu cursă însoțită, alături de un șofer cu '
          'experiență ca antrenor',
      'Un examen oficial de conducere, fără de care nu ai voie să fii '
          'folosit',
    ],
    correctIndex: 1,
    explanation: 'Ride Along înseamnă două zile de lucru reale în firmă, în '
        'care un șofer cu experiență te însoțește, îți explică totul și '
        'apoi te lasă să faci singur. Nu este nici o instruire de birou, '
        'nici un examen al unei autorități — este integrare în activitatea '
        'curentă, care însă se evaluează și se documentează.',
  ),
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'Câte opriri trebuie să faci în cele două zile?',
    options: [
      'Asta stabilește firma ta, respectiv stația ta — antrenorul îți '
          'spune cerința',
      'Întotdeauna exact 20 în prima zi și 70 în a doua, la fel în orice '
          'firmă',
      'Câte îți dai singur seama că poți — o cerință nu există',
    ],
    correctIndex: 0,
    explanation: 'Frecvent este un număr mai mic în prima zi și semnificativ '
        'mai mult în a doua (adesea în jur de 20 și în jur de 70), dar '
        'acestea sunt valori orientative ale unor firme. Obligatorie este '
        'doar cerința stației tale. Greșeala la îndemână este să iei o '
        'cifră auzită drept lege generală — întreabă-ți antrenorul care '
        'este numărul valabil pentru tine.',
  ),
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'În prima zi ești semnificativ mai lent decât era planificat '
        'și faci mai multe greșeli la sortare. Cum se răsfrânge asta '
        'asupra evaluării?',
    options: [
      'Ride Along este astfel considerat nepromovat și trebuie repetat',
      'Nu are nicio importanță, pentru că în prima zi încă nu se evaluează '
          'nimic',
      'Decisiv este dacă întrebi și dacă înlături greșeala după aceea — nu '
          'ritmul',
    ],
    correctIndex: 2,
    explanation: 'Ritm în prima zi nu așteaptă nimeni; exact pentru asta '
        'există numărul mai mic de opriri. Se evaluează disponibilitatea ta '
        'de a învăța: întrebi, accepți indicațiile, faci aceeași greșeală și '
        'a treia oară? Greșeala este periculoasă în ambele direcții — nu '
        'este nici un examen cu ghilotină, nici o zi fără evaluare.',
  ),

  // ══════════════════════════ ra2 — Prima zi
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'De ce trebuie ca opririle de la Ride Along să se '
        'desfășoare pe contul tău propriu?',
    options: [
      'Pentru că antrenorul nu are voie să-și folosească contul în aceste '
          'zile',
      'Pentru că numai așa devine vizibil cum arată livrarea ta proprie — '
          'ea contează pe numele tău',
      'Pentru că în contul antrenorului nu mai încap opriri noi',
    ],
    correctIndex: 1,
    explanation: 'Tot ce livrezi în aceste zile merge pe numele tău — exact '
        'ca mai târziu în activitatea zilnică. Numai așa văd antrenorul și '
        'firma felul tău real de a lucra, și numai așa contează opririle '
        'pentru integrarea ta. De aceea un acces care nu funcționează '
        'dimineața nu este un detaliu, ci un motiv să anunți imediat.',
  ),
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Ce este valabil pentru durata de înregistrare a aplicației '
        'Mentor?',
    options: [
      'Mentor înregistrează în jur de 4 ore la rând și trebuie repornit '
          'după aceea',
      'Mentor merge, o dată pornit, până la finalul turei',
      'Mentor pornește automat de îndată ce vehiculul se mișcă',
    ],
    correctIndex: 0,
    explanation: 'Înregistrarea merge de fiecare dată în jur de patru ore. '
        'După aceea trebuie să o repornești, altfel restul turei rămâne '
        'neînregistrat. Cea mai frecventă greșeală de începător este exact '
        'ideea că aplicația merge singură mai departe: pornită corect '
        'dimineața, nereactivată după pauză — și jumătate de zi lipsește '
        'din evaluare.',
  ),
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'În ziua respectivă lucrezi 9,5 ore. Cât trebuie să dureze '
        'pauza ta cel puțin?',
    options: [
      '30 de minute, pentru că 45 de minute sunt valabile abia de la 10 '
          'ore',
      'Este de ajuns să faci mai multe pauze scurte de câte 5 până la 10 '
          'minute',
      '45 de minute, pentru că timpul de lucru depășește 9 ore',
    ],
    correctIndex: 2,
    explanation: 'Conform § 4 ArbZG (legea germană a timpului de lucru) sunt '
        'prevăzute la peste 6 ore cel puțin 30 de minute și la peste 9 ore '
        'cel puțin 45 de minute de pauză — 9,5 ore sunt peste limită. Pauza '
        'poate fi împărțită, dar fiecare parte trebuie să dureze cel puțin '
        '15 minute; cinci minute printre picături nu se pun la socoteală.',
  ),

  // ══════════════════════════ ra3 — A doua zi
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Un client cu un colet cu parolă nu are codul la îndemână, '
        'dar vrea să semneze. Ce faci?',
    options: [
      'Nu predai — fără cod corect nu există excepție',
      'Predai contra semnătură, pentru că și ea este tot o dovadă',
      'Lași coletul la vecin și îl informezi pe client',
    ],
    correctIndex: 0,
    explanation: 'Parola este dovada că destinatarul este într-adevăr '
        'destinatarul — pentru asta a fost atribuită. O semnătură sau '
        'vorbele bune nu o înlocuiesc, iar predarea la vecin cu atât mai '
        'puțin. Dacă trimiterea este anunțată mai târziu ca neprimită, '
        'predarea fără cod rămâne ca greșeala ta. Corect este: pune-l să '
        'caute codul, altfel returnează coletul corect și documentează.',
  ),
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'La manevrare atingi un stâlpișor. Rămâne o zgârietură pe '
        'furgonetă, nimeni nu a văzut. Ce este corect?',
    options: [
      'Să nu întreprinzi nimic — la o zgârietură fără daună la terți nu '
          'este nimic de anunțat',
      'Să aștepți mai întâi să vezi dacă se observă la următoarea '
          'inspecție',
      'Să anunți chiar în aceeași zi și să documentezi în CoDriver',
    ],
    correctIndex: 2,
    explanation: 'O daună anunțată este un incident care se prelucrează; '
        'aceeași daună, găsită a doua zi dimineață de altcineva la '
        'inspecția lui, este o daună nelămurită — iar bănuiala se îndreaptă '
        'la final tot spre ultimul utilizator. Greșeala „nu se observă" nu '
        'ține: exact pentru asta există inspecția înainte și după fiecare '
        'tură.',
  ),
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Care este diferența dintre prestație și calitate în '
        'Scorecard?',
    options: [
      'Amândouă înseamnă același lucru — Scorecard-ul măsoară doar numărul '
          'de opriri',
      'Prestația este cantitatea în timp, calitatea este cât de curat a '
          'fost încheiată fiecare oprire în parte',
      'Calitatea privește doar vehiculul, prestația doar livrarea',
    ],
    correctIndex: 1,
    explanation: 'Prestația este cantitatea — câte opriri în cât timp. '
        'Calitatea este grija la fiecare oprire în parte: locul corect, '
        'documentare corectă, nicio reclamație. Cine le pune semnul egal '
        'economisește în față un minut și produce în spate o cercetare care '
        'costă firma de câteva ori mai mult.',
  ),

  // ══════════════════════════ ra4 — Încheierea și predarea
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'De câte ori semnează antrenorul lista de verificare Ride '
        'Along?',
    options: [
      'O dată, la finalul celei de-a doua zile, pentru ambele zile '
          'împreună',
      'Deloc — semnează doar dispecerul la predare',
      'Separat pentru fiecare zi, de fiecare dată cu dată',
    ],
    correctIndex: 2,
    explanation: 'Fiecare zi are propria listă de puncte și de aceea se '
        'încheie separat, cu dată și semnătură. Asta are un motiv practic: '
        'dacă a doua zi cade sau se amână, rămâne totuși documentat curat '
        'ce s-a rezolvat în prima zi. O semnătură colectivă la final ar '
        'face exact acest lucru imposibil.',
  ),
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'Ce se întâmplă cu lista de verificare completată la finalul '
        'celei de-a doua zile?',
    options: [
      'Se predă ca fotografie dispecerului responsabil',
      'O iei acasă și o păstrezi la tine, în particular',
      'Rămâne în vehicul, ca următorul antrenor să o continue',
    ],
    correctIndex: 0,
    explanation: 'Fișa se fotografiază la finalul celei de-a doua zile și se '
        'predă dispecerului responsabil — cu asta Ride Along este încheiat '
        'formal și integrarea ta este documentată. În vehicul sau acasă, în '
        'particular, dovada este fără valoare pentru firmă. Ai grijă ca '
        'bifele, data, numele și semnăturile să fie lizibile pe fotografie.',
  ),
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'În feedback se spune că ești prea ezitant la manevrare. Cum '
        'reacționezi cel mai bine?',
    options: [
      'Explici că ai fost conștient de precaut și închei astfel subiectul',
      'Ceri un exemplu concret din ziua respectivă',
      'Iei feedbackul la cunoștință și data viitoare manevrezi mai repede',
    ],
    correctIndex: 1,
    explanation: 'Prudența la manevrare este corectă — „ezitant" înseamnă de '
        'regulă altceva, de exemplu gândit îndelung în loc să cobori scurt '
        'și să te uiți. Cu un exemplu concret ai un punct la care poți '
        'lucra. Justificarea nu aduce nimic, iar pur și simplu să manevrezi '
        'mai repede ar fi cea mai periculoasă dintre cele trei reacții.',
  ),

  // ══════════════════════════ ra5 — Așa te pregătești
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Când ar trebui să verifici dacă accesurile tale la pontaj, '
        'Mentor, Flex și CoDriver funcționează?',
    options: [
      'În dimineața primei zile, împreună cu antrenorul',
      'Abia atunci când apare cu adevărat o problemă în timpul lucrului',
      'Înainte de prima zi, cel mai bine în seara dinainte',
    ],
    correctIndex: 2,
    explanation: 'Resetarea unei parole durează seara dinainte câteva '
        'minute, iar dimineața în Waiting Area o jumătate de oră — dacă este '
        'cineva de găsit. Greșeala la îndemână este să lași asta pe seama '
        'antrenorului: el nu te poate ajuta la un acces blocat, iar timpul '
        'lipsește apoi de la opririle pe contul tău propriu.',
  ),
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Ce înseamnă „punctual" la Ride Along?',
    options: [
      'Gata de lucru la stație la începutul turei — parcarea și drumul '
          'sunt deja incluse în calcul',
      'Să ajungi la poarta stației la începutul turei',
      'Să fii acolo cel târziu atunci când se face apelul în Waiting Area',
    ],
    correctIndex: 0,
    explanation: 'La începutul turei ești gata de lucru, nu pe drum. Cine '
        'ajunge abia la poartă pierde timp cu parcarea și cu drumul prin '
        'curte și își ratează fereastra din Waiting Area — și decalează '
        'astfel și valul antrenorului. Planifică de aceea conștient timpul '
        'pentru parcare și pentru mersul pe jos.',
  ),
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'De ce merită să-ți scrii întrebările pentru antrenor încă '
        'dinainte de ziua 1?',
    options: [
      'Pentru că antrenorul trebuie să primească întrebările în scris, în '
          'prealabil',
      'Pentru că zece procese explicate unul după altul nu le reține '
          'nimeni — scrise, întrebi țintit',
      'Pentru că întrebările nepuse sunt altfel notate negativ în evaluare',
    ],
    correctIndex: 1,
    explanation: 'Antrenorul explică în două zile foarte multe deodată; '
        'seara rămâne din asta puțin, fără notițe. Cine își pregătește '
        'întrebările și își notează pe parcurs două cuvinte cheie pe temă '
        'scoate din cele două zile de câteva ori mai mult. O obligație '
        'formală nu este — și nimeni nu notează negativ întrebările nepuse. '
        'Tocmai de aceea trebuie să ai tu însuți grijă de asta.',
  ),
];
