// lib/data/safety_training/green_book_quiz_ro.dart
//
// Întrebările testului final Green Book (registrul de control al curselor
// conform § 1 alin. 6 FPersV) — versiunea română.
// Structura este identică cu versiunea germană (master): același număr de
// întrebări, aceeași ordine, aceleași răspunsuri corecte.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> greenBookQuestionsRo = [
  // ══════════════════════════ gb1 — Ce este Green Book
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Ce documentezi în Green Book?',
    options: [
      'Starea vehiculului înainte de plecarea în cursă',
      'Numărul de colete livrate și de retururi',
      'Timpii de conducere, întreruperile conducerii, precum și timpii de '
          'lucru și de odihnă',
    ],
    correctIndex: 2,
    explanation: 'Green Book este registrul de control al curselor — '
        'colecția fișelor zilnice de control conform § 1 alin. 6 FPersV. El '
        'dovedește exclusiv timpi. Starea vehiculului se documentează în '
        'altă parte și nu are ce căuta aici.',
  ),
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Pentru ce vehicule se aplică obligația de înregistrare '
        'conform § 1 alin. 6 FPersV?',
    options: [
      'Peste 2,8 t până la 3,5 t masă totală maximă autorizată, în '
          'transportul comercial de marfă',
      'Pentru orice vehicul cu care se transportă comercial colete',
      'Abia de la 3,5 t masă totală maximă autorizată',
    ],
    correctIndex: 0,
    explanation: 'Obligația se aplică în intervalul de peste 2,8 t până la '
        '3,5 t — exact furgoneta tipică de livrări. Sub 2,8 t ea nu există, '
        'iar de la 3,5 t tahograful digital preia înregistrarea.',
  ),
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Furgoneta ta are, conform certificatului de înmatriculare, '
        '3,5 t masă totală maximă autorizată, dar astăzi este încărcată cu '
        'doar 900 kg. Ce se aplică?',
    options: [
      'Nicio obligație de înregistrare — greutatea reală este sub 2,8 t',
      'Obligația de înregistrare rămâne valabilă',
      'Obligația se aplică abia de la o distanță zilnică de 100 de '
          'kilometri',
    ],
    correctIndex: 1,
    explanation: 'Determinantă este masa totală maximă autorizată din '
        'certificatul de înmatriculare, nu greutatea încărcăturii de azi. '
        'Greșeala la îndemână este să socotești zilnic după încărcătură — '
        'încadrarea vehiculului nu se schimbă din cauza asta.',
  ),

  // ══════════════════════════ gb2 — Ce se trece exact în fișă
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Care dintre date NU face parte din datele obligatorii ale '
        'fișei zilnice de control?',
    options: [
      'Kilometrajul la începutul și la sfârșitul cursei',
      'Numărul de expedieri livrate',
      'Locul începerii și al încheierii cursei',
    ],
    correctIndex: 1,
    explanation: 'Sunt prevăzute, printre altele, numele, prenumele și '
        'adresa șoferului, numărul de înmatriculare, data, valorile de '
        'kilometraj, locurile, timpii și semnătura. Numărul de bucăți este '
        'un indicator intern al firmei și nu apare pe fișă.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Cu ce completezi fișa zilnică de control?',
    options: [
      'Cu pixul, cu scris indelebil',
      'Cu creionul, ca să se poată corecta curat greșelile',
      'Instrumentul de scris nu contează, atâta timp cât se poate citi',
    ],
    correctIndex: 0,
    explanation: 'O însemnare care poate fi ștearsă cu guma nu este o '
        'dovadă. Exact de aceea creionul este inadmisibil — chiar dacă '
        'corectura este bine intenționată. O greșeală se taie o singură '
        'dată cu o linie și se rescrie alături.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Toți timpii și valorile de kilometraj sunt trecute, lipsește '
        'doar semnătura. Ce se aplică pentru această fișă?',
    options: [
      'Este valabilă — semnătura este o simplă formalitate',
      'Este considerată incompletă și nu îndeplinește obligația de '
          'înregistrare',
      'Dispecerul o poate contrasemna ulterior în firmă',
    ],
    correctIndex: 1,
    explanation: 'Semnătura este una dintre datele prevăzute — cu ea '
        'confirmi conținutul. Fără ea, fișa este incompletă, cu aceleași '
        'urmări ca o fișă lipsă. O semnătură străină nu o înlocuiește pe a '
        'ta.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Aștepți 40 de minute la rampă. Nu faci nimic, dar trebuie să '
        'fii oricând disponibil, pentru că se poate porni imediat. Cum treci '
        'acest timp?',
    options: [
      'Ca întrerupere a conducerii — doar n-ai muncit',
      'Ca început al perioadei zilnice de odihnă',
      'Ca timp de lucru',
    ],
    correctIndex: 2,
    explanation: 'O întrerupere a conducerii este pauză doar dacă poți '
        'dispune liber de acel timp și dacă știi asta dinainte. A sta la '
        'dispoziție este timp de așteptare și deci timp de lucru. Greșeala '
        'la îndemână sună „n-am făcut nimic, deci a fost pauză" — hotărâtor '
        'nu este ce ai făcut, ci disponibilitatea.',
  ),

  // ══════════════════════════ gb3 — Timpi de conducere, pauze, odihnă
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Cât ai voie să conduci cel mult într-o zi normală?',
    options: [
      '9 ore',
      '10 ore',
      '8 ore, apoi doar cu acordul dispecerului',
    ],
    correctIndex: 0,
    explanation: 'Timpul zilnic de conducere este de cel mult 9 ore. Cele '
        '10 ore nu sunt o a doua limită normală, ci o excepție strict '
        'limitată — iar un acord intern al firmei nu joacă niciun rol '
        'pentru limită.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'De câte ori ai voie să prelungești timpul de conducere la '
        '10 ore?',
    options: [
      'O dată pe săptămână',
      'De două ori pe săptămână',
      'În fiecare zi în care tura o cere',
    ],
    correctIndex: 1,
    explanation: 'De două ori pe săptămână timpul zilnic de conducere poate '
        'fi prelungit la 10 ore. Este un contingent săptămânal, nu un drept '
        'zilnic — iar volumul turei nu îl prelungește.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Vrei să împarți întreruperea de 45 de minute. Care împărțire '
        'este admisă?',
    options: [
      'Întâi 30 de minute, apoi 15 minute',
      'De trei ori câte 15 minute, repartizate peste zi',
      'Întâi 15 minute, apoi 30 de minute',
    ],
    correctIndex: 2,
    explanation: 'Împărțirea este admisă doar în două părți și doar în '
        'această ordine: întâi minimum 15, apoi minimum 30 de minute. '
        'Ordinea inversă nu se pune la socoteală, la fel nici trei părți '
        'scurte — chiar dacă suma este corectă.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Pornești la ora 07:00. Până la 09:30 stai 2 ore la volan, '
        'până la 12:00 se mai adaugă 2 ore de conducere, până la 13:00 încă '
        '30 de minute. Când se impune întreruperea, cel mai târziu?',
    options: [
      'La ora 11:30, adică la 4,5 ore după începerea programului',
      'La ora 12:00, pentru că pauza de prânz este prevăzută pentru asta',
      'La ora 13:00',
    ],
    correctIndex: 2,
    explanation: '2 + 2 + 0,5 ore dau la ora 13:00 exact 4,5 ore de '
        'conducere pură — acum nu mai ai voie să faci niciun metru înainte '
        'de a efectua pauza. Greșeala la îndemână este să socotești de la '
        'începerea programului: ceasul merge doar când vehiculul este în '
        'mers.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Încheii timpul de conducere la ora 17:15. Când ai voie să '
        'pornești cel mai devreme din nou?',
    options: [
      'La ora 02:15 — 9 ore de odihnă sunt suficiente',
      'La ora 04:15',
      'Imediat ce te simți odihnit, nu există o limită fixă',
    ],
    correctIndex: 1,
    explanation: 'Odihna zilnică este de minimum 11 ore, deci cel mai '
        'devreme la 04:15. Cele 9 ore sunt limita pentru timpul de '
        'conducere, nu pentru odihnă — cele două cifre se confundă des.',
  ),

  // ══════════════════════════ gb4 — Greșeli tipice
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Un coleg completează fișele întregii săptămâni vineri seara. '
        'Timpii sunt corecți ca fond. Cum se apreciază asta?',
    options: [
      'Este o încălcare și iese la iveală la un control',
      'Fără probleme, atâta timp cât timpii trecuți corespund adevărului',
      'Doar o chestiune de ordine, dar fără semnificație juridică',
    ],
    correctIndex: 0,
    explanation: 'A înregistra înseamnă a înregistra la timp. Fișele scrise '
        'ulterior se recunosc după același scris, timpi suspect de rotunzi '
        'și valori de kilometraj care nu se potrivesc cu traseul. Faptul că '
        'timpii sunt corecți nu vindecă încălcarea obligației de '
        'înregistrare.',
  ),
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Joi observi că marți pauza de prânz nu este trecută. Îți '
        'amintești sigur ora. Ce faci?',
    options: [
      'O treci ca o completare ulterioară, cu data completării, și îți '
          'informezi dispecerul',
      'Introduci însemnarea astfel încât să pară scrisă marți',
      'Lași lacuna — o completare ulterioară nu face decât să înrăutățească '
          'lucrurile',
    ],
    correctIndex: 0,
    explanation: 'O corectură onestă, datată vizibil, este permisă și mai '
        'bună decât o lacună. A face însemnarea să pară că a apărut marți '
        'este pasul de la neglijență la inducere în eroare — și cântărește '
        'clar mai greu.',
  ),
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Astăzi ai condus 9,5 ore, deși contingentul tău săptămânal '
        'pentru 10 ore era deja consumat. Ce treci în fișă?',
    options: [
      'Exact 9,0 ore — ca fișa să arate conform regulilor',
      'Cele 9,5 ore conduse efectiv',
      'Pentru ziua asta nimic, atunci nu se observă',
    ],
    correctIndex: 1,
    explanation: 'Treci întotdeauna timpii reali. O însemnare cosmetizată '
        'transformă o depășire într-o declarație falsă și înrăutățește '
        'situația. O fișă lipsă este de asemenea o încălcare de sine '
        'stătătoare — omiterea nu ajută.',
  ),

  // ══════════════════════════ gb5 — Purtare, predare, păstrare
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Ce înregistrări trebuie să porți cu tine în vehicul?',
    options: [
      'Doar fișa zilei curente',
      'Fișele săptămânii calendaristice curente',
      'Ziua curentă și cele 28 de zile anterioare',
    ],
    correctIndex: 2,
    explanation: 'Trebuie purtate înregistrările ultimelor 28 de zile, '
        'inclusiv ziua curentă. Faptul că fișele mai vechi stau corect în '
        'firmă îndeplinește obligația de păstrare, dar nu și pe cea de a le '
        'purta cu tine — sunt două obligații separate.',
  ),
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Cât timp trebuie să păstreze întreprinzătorul fișele zilnice '
        'de control în firmă?',
    options: [
      'Un an',
      '28 de zile, apoi pot fi distruse',
      'Trei luni de la sfârșitul trimestrului',
    ],
    correctIndex: 0,
    explanation: 'Întreprinzătorul păstrează înregistrările timp de un an '
        'și le prezintă la cerere. Cele 28 de zile sunt termenul pentru '
        'purtarea lor de către șofer — ele se confundă des cu termenul de '
        'păstrare.',
  ),
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Cine controlează respectarea obligației de înregistrare?',
    options: [
      'Exclusiv poliția, și doar la controale în trafic',
      'BAG și poliția — la controale în trafic și în firmă',
      'TÜV, în cadrul inspecției tehnice a vehiculului',
    ],
    correctIndex: 1,
    explanation: 'Controlul se face de către BAG (Bundesamt für Logistik '
        'und Mobilität, Oficiul Federal pentru Logistică și Mobilitate) și '
        'de către poliție, atât pe marginea drumului, cât și în firmă. '
        'Inspecția tehnică privește starea tehnică a vehiculului și nu are '
        'nicio legătură cu înregistrările.',
  ),

  // ══════════════════════════ gb6 — Consecințe
  DrivingQuestion(
    moduleId: 'gb6',
    question: 'La ce te poți aștepta dacă lipsesc fișe sau dacă acestea '
        'sunt incomplete?',
    options: [
      'La o amendă de la 100 de euro, în funcție de gravitate și mai mare',
      'La nicio urmare — este o simplă normă internă a firmei',
      'La un avertisment gratuit, fără alte consecințe',
    ],
    correctIndex: 0,
    explanation: 'Înregistrările lipsă sau incomplete sunt o contravenție; '
        'amenda începe de la circa 100 de euro și crește odată cu '
        'gravitatea. La încălcări grave sau repetate se poate deschide în '
        'plus o procedură privind buna reputație a firmei.',
  ),
  DrivingQuestion(
    moduleId: 'gb6',
    question: 'Dispecerul spune: „Mai fă cele două opriri, pauza o scrii '
        'pur și simplu în fișă." Cum reacționezi?',
    options: [
      'Urmezi dispoziția — răspunderea o poartă atunci dispecerul',
      'Renunți la pauză, dar treci măcar cinstit că lipsește',
      'Faci pauza, o treci corect și raportezi opririle rămase',
    ],
    correctIndex: 2,
    explanation: 'O dispoziție verbală nu îți anulează obligația de '
        'înregistrare — tu semnezi fișa și confirmi astfel conținutul. A '
        'renunța conștient la pauză ar fi în plus o încălcare a normelor '
        'privind timpii de conducere. Firma trebuie să facă posibilă '
        'respectarea normelor, nu să le ocolească.',
  ),
];

// Alegerea limbii și filtrarea pe capitole se fac în stratul de date al
// instruirii — vezi green_book_quiz_de.dart.
