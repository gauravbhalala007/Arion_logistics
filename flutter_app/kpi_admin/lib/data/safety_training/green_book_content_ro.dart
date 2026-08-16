// lib/data/safety_training/green_book_content_ro.dart
//
// Conținutul instruirii Green Book — versiunea română.
// Structura este identică cu versiunea germană (master): capitolele
// gb1–gb6, aceleași folii, aceleași blocuri și aceleași valori.
//
// „Green Book" este registrul de control al curselor: colecția fișelor
// zilnice de control conform § 1 alin. 6 Fahrpersonalverordnung (FPersV
// — regulamentul german privind personalul de conducere auto).

import 'safety_blocks.dart';

const List<SafetyChapterContent> greenBookContentRo = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'gb1',
    title: 'Ce este Green Book',
    summary: 'Registrul de control al curselor conform § 1 alin. 6 '
        'FPersV — și de ce este obligatoriu pentru tine',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Registru de curse, nu verificare a vehiculului',
        blocks: [
          ParagraphBlock(
            '„Green Book" este registrul tău de control al curselor. În el '
            'aduni fișele zilnice de control: pentru fiecare zi de lucru o '
            'fișă, pe care scrie când ai condus, când ai făcut pauză și '
            'când a început perioada ta de odihnă.',
          ),
          ParagraphBlock(
            'Nu este nicidecum o verificare a vehiculului. Anvelopele, '
            'luminile și caroseria se documentează în altă parte. În Green '
            'Book este vorba exclusiv despre timpi — timpii tăi.',
          ),
          BulletsBlock([
            'O fișă pe zi, în fiecare zi în care conduci un vehicul supus '
                'obligației de înregistrare',
            'Completată de mână, cu scris indelebil și semnată',
            'Dovedește că ai respectat timpii de conducere, pauzele și '
                'perioadele de odihnă',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Pe scurt',
            text: 'Green Book răspunde la o singură întrebare: când ai fost '
                'la volan și când nu? Orice altceva nu are ce căuta acolo.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Cine trebuie să înregistreze',
        blocks: [
          ParagraphBlock(
            'Obligația vine din § 1 alin. 6 al Fahrpersonalverordnung '
            '(FPersV — regulamentul german privind personalul de conducere '
            'auto). Ea nu ține de tine personal, ci de vehicul și de scopul '
            'cursei: transport comercial de marfă cu un vehicul de peste '
            '2,8 t până la 3,5 t masă totală maximă autorizată. Exact '
            'furgoneta tipică de livrări.',
          ),
          FactsBlock([
            FactItem('sub 2,8 t', 'nicio obligație de înregistrare conform '
                '§ 1 alin. 6 FPersV'),
            FactItem('2,8–3,5 t', 'fișă zilnică de control — Green Book-ul '
                'tău'),
            FactItem('de la 3,5 t', 'tahograf digital în loc de fișă pe '
                'hârtie'),
          ]),
          ParagraphBlock(
            'Determinantă este masa totală maximă autorizată din '
            'certificatul de înmatriculare (Fahrzeugschein) — nu cât de '
            'greu este încărcată furgoneta astăzi. O furgonetă de 3,5 t pe '
            'jumătate goală rămâne supusă obligației de înregistrare.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Temeiul legal',
            text: '§ 1 alin. 6 FPersV te obligă să înregistrezi timpii de '
                'conducere, întreruperile conducerii, precum și timpii de '
                'lucru și de odihnă. Dacă circuli fără această fișă, '
                'încalci regulamentul — indiferent dacă ai respectat sau nu '
                'timpii.',
          ),
        ],
      ),
      SafetySlide(
        title: 'La ce folosește înregistrarea',
        blocks: [
          ParagraphBlock(
            'Norma nu este un scop în sine. Ea există pentru că șoferii '
            'obosiți sunt periculoși în trafic — pentru ei înșiși și '
            'pentru toți ceilalți. Fișa face vizibil dacă zilele tale de '
            'lucru sunt planificate astfel încât să poată fi respectate.',
          ),
          BulletsBlock([
            'Protecție împotriva oboselii: cine trebuie să documenteze '
                'pauza chiar o și face mai degrabă',
            'Dovadă pentru tine: fișa arată că ai condus corect — chiar și '
                'după luni de zile',
            'Dovadă împotriva afirmațiilor: fără înregistrare, amintirea ta '
                'stă împotriva presupunerii controlului',
            'Bază pentru planificarea turelor: turele mereu prea strânse '
                'ies la iveală în fișă',
          ]),
          RevealBlock(
            prompt: 'Exemplu practic: astăzi ai respectat timpii — pauză la '
                'timp, program încheiat la timp. Doar fișa nu ai '
                'completat-o, pentru că oricum totul era în regulă. Control '
                'după-amiaza. Este o problemă?',
            answer: 'Da. Obligația de înregistrare înseamnă: dovada în sine '
                'este obligația. Dacă ai respectat efectiv timpii, nimeni '
                'nu poate constata la un control în trafic — pur și simplu '
                'nu există nimic de prezentat. Din perspectiva controlului, '
                'o fișă lipsă se tratează exact ca un timp depășit: există '
                'o încălcare și ea se sancționează. Respectarea îți '
                'folosește doar dacă o poți dovedi.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare: înțelegerea de bază',
        blocks: [
          ChecklistBlock(
            title: 'Ce rețin din capitolul 1',
            items: [
              'Știu că Green Book documentează timpi, nu starea vehiculului',
              'Cunosc temeiul legal: § 1 alin. 6 FPersV',
              'Știu că sunt vizate vehiculele de peste 2,8 t până la 3,5 t',
              'Știu că numără masa totală maximă autorizată, nu greutatea '
                  'actuală a încărcăturii',
              'Știu că de la 3,5 t intervine tahograful digital',
              'Îmi este clar că o fișă lipsă este în sine o încălcare',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'O frază pentru tură',
            text: '„Ce nu am scris nu pot dovedi."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'gb2',
    title: 'Ce se trece exact în fișă',
    summary: 'Toate câmpurile obligatorii — și cum le completezi corect',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Datele obligatorii de pe fișă',
        blocks: [
          ParagraphBlock(
            'O fișă zilnică de control este o dovadă doar dacă toate datele '
            'prevăzute sunt trecute pe ea. Dacă lipsește una dintre ele, '
            'fișa este considerată incompletă — cu aceleași urmări ca o '
            'fișă lipsă.',
          ),
          BulletsBlock([
            'Numele, prenumele și adresa șoferului',
            'Numărul de înmatriculare al vehiculului',
            'Data zilei',
            'Kilometrajul la începutul și la sfârșitul cursei',
            'Locul începerii cursei și locul încheierii cursei',
            'Timpii de conducere și de odihnă, cu ora',
            'Întreruperile conducerii (pauzele)',
            'Semnătura ta',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Complet înseamnă complet',
            text: '§ 1 alin. 6 FPersV enumeră datele în mod limitativ. O '
                'fișă fără număr de înmatriculare, fără adresă sau fără '
                'semnătură nu îndeplinește obligația de înregistrare — '
                'chiar dacă timpii sunt trecuți corect.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Completarea pas cu pas',
        blocks: [
          ParagraphBlock(
            'Ordinea de mai jos este aleasă intenționat astfel încât să nu '
            'uiți nimic: întâi datele fixe, apoi timpii pe parcursul zilei, '
            'la final încheierea.',
          ),
          StepsBlock([
            'Înainte de plecare: trece data, numele, prenumele, adresa și '
                'numărul de înmatriculare',
            'Citește kilometrajul de pe bord și trece-l ca valoare de '
                'început — nu estima',
            'Trece locul începerii cursei (depozit, locație, localitate)',
            'Trece începutul timpului de conducere cu ora, imediat ce '
                'pleci',
            'Trece fiecare întrerupere a conducerii imediat, cu început și '
                'sfârșit — nu abia seara',
            'La finalul turei: trece locul încheierii cursei și '
                'kilometrajul final',
            'Trece sfârșitul timpului de conducere și începutul perioadei '
                'de odihnă',
            'Recitește fișa, verifică dacă sunt lacune și semnează',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Scrie indelebil',
            text: 'Pix, nu creion. O însemnare care poate fi ștearsă cu '
                'guma nu este o dovadă. O greșeală de scriere se taie o '
                'singură dată cu o linie și se rescrie alături — nu se '
                'acoperă cu pastă corectoare și nu se lipește peste ea.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Trecerea corectă a timpilor',
        blocks: [
          ParagraphBlock(
            'Cel mai des se greșește la timpi. Fiecare bloc de timp al '
            'zilei intră pe un rând separat, cu ora de la–până la. Așa '
            'arată o zi normală de livrări:',
          ),
          TableBlock(
            headers: ['De la–până la', 'Tip', 'Observație'],
            rows: [
              ['06:30–07:00', 'Timp de lucru', 'Încărcare în depozit, încă '
                  'fără timp de conducere'],
              ['07:00–11:30', 'Timp de conducere', '4,5 ore — acum se '
                  'impune pauza'],
              ['11:30–12:15', 'Întrerupere', '45 de minute neîntrerupt'],
              ['12:15–16:45', 'Timp de conducere', 'al doilea bloc, în '
                  'total 9 ore'],
              ['16:45–17:15', 'Timp de lucru', 'predare, retururi, '
                  'încheiere'],
              ['de la 17:15', 'Odihnă', 'minimum 11 ore până la următorul '
                  'start'],
            ],
          ),
          BulletsBlock([
            'Timpul de conducere este doar timpul la volan cu vehiculul în '
                'mers',
            'Încărcarea și descărcarea, scanarea, așteptarea la oprire sunt '
                'timp de lucru, dar nu timp de conducere',
            'O întrerupere a conducerii este pauză doar dacă în acel timp '
                'chiar nu muncești',
          ]),
          RevealBlock(
            prompt: 'Exemplu practic: stai 40 de minute la rampă și aștepți '
                'să se descarce. Stai în cabină și nu faci nimic. Ai voie '
                'să treci asta ca întrerupere a conducerii?',
            answer: 'Doar dacă în acel timp poți dispune liber de el și nu '
                'prestezi nicio activitate — și dacă știi asta dinainte. '
                'Dacă trebuie să fii oricând disponibil, pentru că se poate '
                'porni imediat, este timp de așteptare și nu pauză. '
                'Greșeala la îndemână: „N-am făcut nimic, deci a fost '
                'pauză." Hotărâtor nu este dacă te-ai mișcat, ci dacă ai '
                'putut dispune de acel timp. La îndoială îl treci ca timp '
                'de lucru — asta este întotdeauna partea sigură.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare: fișa este completă?',
        blocks: [
          ChecklistBlock(
            title: 'Înainte să semnez',
            items: [
              'Numele, prenumele și adresa sunt trecute',
              'Numărul de înmatriculare corespunde cu vehiculul condus',
              'Data este trecută',
              'Kilometrajul de început și de sfârșit sunt citite de pe bord',
              'Locul începerii și al încheierii cursei sunt trecute',
              'Toți timpii de conducere sunt trecuți cu ora de la–până la',
              'Toate întreruperile conducerii sunt trecute',
              'Începutul perioadei de odihnă este trecut',
              'Totul cu pixul, fără ștersături, fără lacune',
              'Semnătura este pusă',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'gb3',
    title: 'Timpi de conducere, pauze, odihnă',
    summary: 'Cifrele pe care ziua ta de lucru trebuie să le respecte',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Cifrele care contează',
        blocks: [
          ParagraphBlock(
            'Green Book documentează timpi — dar doar pentru ca să se poată '
            'verifica dacă ai respectat limitele. Aceste limite trebuie să '
            'le ai în cap, nu doar pe hârtie.',
          ),
          FactsBlock([
            FactItem('9 h', 'timp de conducere pe zi, în mod normal'),
            FactItem('10 h', 'permis de două ori pe săptămână, ca excepție'),
            FactItem('4,5 h', 'conducere neîntreruptă, apoi se impune '
                'pauza'),
          ]),
          FactsBlock([
            FactItem('45 min', 'întrerupere a conducerii după 4,5 ore'),
            FactItem('15 + 30', 'împărțire permisă — în această ordine'),
            FactItem('11 h', 'odihnă zilnică, minimum'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Ce cere norma',
            text: 'Timpul de conducere este de cel mult 9 ore pe zi; de '
                'două ori pe săptămână poate fi prelungit la 10 ore. După '
                'cel mult 4,5 ore de conducere trebuie făcută o întrerupere '
                'de minimum 45 de minute. Odihna zilnică este de minimum '
                '11 ore.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Plasarea corectă a pauzei',
        blocks: [
          ParagraphBlock(
            'Cele 45 de minute sunt cazul normal. Ai voie să le împarți — '
            'dar numai în exact două părți și numai într-o anumită ordine: '
            'întâi minimum 15 minute, apoi minimum 30 de minute. Invers nu '
            'se pune.',
          ),
          DoDontBlock(
            doTitle: 'Așa este pauza valabilă',
            dos: [
              '45 de minute neîntrerupt, după cel mult 4,5 ore de conducere',
              'Sau întâi 15 minute, apoi 30 de minute',
              'Ambele părți în interiorul aceluiași bloc de 4,5 ore',
              'Ambele părți trecute în fișă cu ora de la–până la',
            ],
            dontTitle: 'Așa nu se pune la socoteală',
            donts: [
              'Întâi 30 de minute și apoi 15 minute — ordine greșită',
              'Trei pauze scurte de câte 15 minute',
              'De două ori câte 20 de minute — a doua parte este prea '
                  'scurtă',
              'Pauza abia după 5 ore de conducere, pentru că oprirea s-a '
                  'potrivit mai bine',
            ],
          ),
          BulletsBlock([
            'Cele 4,5 ore sunt timp de conducere pur — opririle cu livrare '
                'nu se socotesc',
            'Pauza trebuie să fie înainte de depășire, nu după',
            'După întreruperea completă începe un nou bloc de 4,5 ore',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Cea mai frecventă greșeală de gândire',
            text: 'Pauza nu se impune când ai 4,5 ore de program, ci când '
                'ai condus 4,5 ore. Cine socotește după timpul de serviciu '
                'face pauza de obicei prea devreme — și apoi încă o dată '
                'prea târziu.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Socoteala în activitatea zilnică de livrare',
        blocks: [
          ParagraphBlock(
            'În activitatea zilnică nu socotești un singur bloc, ci multe '
            'curse scurte între opriri. Adună-le — ele formează timpul tău '
            'de conducere.',
          ),
          RevealBlock(
            prompt: 'Exemplu practic: pornești la ora 07:00. Până la 09:30 '
                'stai 2 ore la volan, restul la opriri. Până la 12:00 se '
                'mai adaugă 2 ore de conducere, până la 13:00 încă 30 de '
                'minute. Când se impune pauza, cel mai târziu?',
            answer: 'La ora 13:00. În acel moment ai atins 2 + 2 + 0,5 = '
                '4,5 ore de conducere pură — acum nu mai ai voie să faci '
                'niciun metru înainte de a efectua întreruperea. Greșeala '
                'la îndemână ar fi să socotești șase ore de program de la '
                '07:00 și să pui pauza la 11:30. Ceasul care contează merge '
                'doar când vehiculul este în mers.',
          ),
          RevealBlock(
            prompt: 'Exemplu practic: săptămâna asta ai condus deja de două '
                'ori câte 10 ore. Azi e vineri, ești la 8,5 ore de '
                'conducere și mai ai două opriri, în total circa 40 de '
                'minute de mers. Se mai poate?',
            answer: 'Nu. Prelungirea la 10 ore ai voie să o folosești doar '
                'de două ori pe săptămână, iar acestea sunt consumate. Azi '
                'se aplică din nou limita normală de 9 ore — îți rămân deci '
                '30 de minute de conducere, nu 40. Mergi la oprirea pe care '
                'o poți atinge, raportezi restul dispecerului și închei '
                'timpul de conducere. Greșeala la îndemână: „Cele 10 ore mi '
                'se cuvin în fiecare zi." Ele sunt o excepție cu contingent '
                'săptămânal.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare: timpii sub control',
        blocks: [
          ChecklistBlock(
            title: 'Ce rețin din capitolul 3',
            items: [
              'Știu că 9 ore de conducere sunt regula',
              'Știu că 10 ore sunt permise doar de două ori pe săptămână',
              'Socotesc cele 4,5 ore ca timp de conducere pur, nu ca timp '
                  'de serviciu',
              'Fac minimum 45 de minute de întrerupere a conducerii',
              'Împart pauza cel mult în 15 + 30 de minute, în această '
                  'ordine',
              'Respect minimum 11 ore de odihnă zilnică',
              'Trec fiecare pauză imediat, nu seara',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Formulă de reținut',
            text: '4,5 – 45 – 9 – 11. Patru cifre care îți structurează '
                'ziua. Cine le știe nu mai trebuie să socotească, ci doar '
                'să noteze.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'gb4',
    title: 'Greșeli tipice la completare',
    summary: 'Cele șase greșeli care ies la iveală la orice control',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Cele șase greșeli cele mai frecvente',
        blocks: [
          ParagraphBlock(
            'Aproape toate fișele contestate nu cad din cauza timpilor, ci '
            'din cauza felului în care au fost ținute. Aceste șase greșeli '
            'fac inutilă o fișă altfel corectă.',
          ),
          DoDontBlock(
            doTitle: 'Așa ții fișa corect',
            dos: [
              'Faci fiecare însemnare imediat, când se încheie blocul de '
                  'timp',
              'Folosești pixul, scris indelebil',
              'Treci pauzele cu ora reală de la–până la',
              'Citești kilometrajul de pe bord',
              'Semnezi la finalul zilei',
              'Fișa rămâne în vehicul, la tine',
            ],
            dontTitle: 'Așa este fișa contestată',
            donts: [
              'Completezi toată săptămâna vineri seara',
              'Scrii cu creionul, ca să poți „corecta mai târziu"',
              'Estimezi pauzele („cam trei sferturi de oră")',
              'Scrii kilometrajul din memorie',
              'Uiți semnătura',
              'Lași fișele acasă sau în depozit',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Cea mai scumpă greșeală este cea mai comodă',
            text: 'Completarea ulterioară pare inofensivă — este greșeala '
                'care iese cel mai repede la iveală și cântărește cel mai '
                'greu.',
          ),
        ],
      ),
      SafetySlide(
        title: 'De ce se observă completările ulterioare',
        blocks: [
          ParagraphBlock(
            'O fișă scrisă dintr-o dată, ulterior, arată altfel decât una '
            'apărută pe parcursul zilei. Inspectorii le văd zilnic pe '
            'amândouă și recunosc diferența imediat.',
          ),
          BulletsBlock([
            'Același scris, același pix, aceeași apăsare pe toate rândurile',
            'Timpi suspect de rotunzi: totul se termină la ore fixe și '
                'jumătăți de oră',
            'Valori de kilometraj care nu se potrivesc cu traseul trecut',
            'Date care contrazic avizele de livrare, scanările sau '
                'bonurile de combustibil',
            'Pauze care durează mereu exact 45 de minute — chiar și în zile '
                'în care asta nu era posibil',
          ]),
          ParagraphBlock(
            'La asta se adaugă: la un control în firmă, fișele stau lângă '
            'restul documentelor. Contradicțiile nu îți sar ție în ochi, ci '
            'autorității.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Fals este mai rău decât gol',
            text: 'O fișă incompletă este o încălcare a obligației de '
                'înregistrare. O fișă completată intenționat fals este mai '
                'mult decât atât — acolo nu mai este vorba doar de o '
                'contravenție, ci de chestiunea inducerii în eroare. Mai '
                'bine treci că ai condus prea mult decât să inventezi un '
                'timp.',
          ),
          RevealBlock(
            prompt: 'Exemplu practic: joi observi că marți pauza de prânz '
                'nu este trecută. Îți amintești exact: 12:10 până la 12:55. '
                'Ce faci?',
            answer: 'O treci ulterior — dar vizibil ca o completare '
                'ulterioară, cu data completării și o scurtă observație, și '
                'îți informezi dispecerul. O corectură onestă și '
                'recognoscibilă este permisă și clar mai bună decât o '
                'lacună. Greșeala la îndemână ar fi să introduci însemnarea '
                'ca și cum ar fi apărut marți — exact acesta este pasul de '
                'la neglijență la falsificare.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare: ținută curat',
        blocks: [
          ChecklistBlock(
            title: 'Fișa mea rezistă la un control',
            items: [
              'Trec fiecare bloc de timp imediat, nu seara',
              'Scriu cu pixul',
              'Citesc orele și kilometrajul, în loc să le estimez',
              'Semnez fiecare fișă',
              'Fișele mele sunt mereu la mine, în vehicul',
              'Fac corecturile vizibil și cu dată, niciodată invizibil',
              'Prefer să trec o încălcare decât să inventez un timp',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'gb5',
    title: 'Purtare, predare, păstrare',
    summary: '28 de zile la șofer, un an în firmă',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Cele două termene',
        blocks: [
          ParagraphBlock(
            'Fișa completată valorează ceva abia atunci când se află la '
            'momentul potrivit în locul potrivit. Pentru asta există două '
            'termene, pe care trebuie să le deosebești.',
          ),
          FactsBlock([
            FactItem('28 de zile', 'șoferul poartă înregistrările cu el'),
            FactItem('1 an', 'întreprinzătorul le păstrează în firmă'),
          ]),
          BulletsBlock([
            'Cele 28 de zile te privesc pe tine: trebuie să ai la tine '
                'înregistrările zilei curente și ale celor 28 de zile '
                'anterioare',
            'Termenul de un an privește firma: ea trebuie să păstreze '
                'fișele un an și să le prezinte la cerere',
            'Ambele se aplică în paralel — fișele ajung în arhivă abia '
                'după expirarea obligației de a le purta',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Obligația de a le purta cu tine',
            text: 'Înregistrările ultimelor 28 de zile stau în vehicul — '
                'nu în vestiar, nu acasă și nu în birou. Dacă lipsesc la un '
                'control, nu ajută faptul că au fost ținute corect.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Controlul în trafic',
        blocks: [
          ParagraphBlock(
            'Controlul se face de către BAG — Bundesamt für Logistik und '
            'Mobilität, Oficiul Federal pentru Logistică și Mobilitate — și '
            'de către poliție. Ambele au voie să controleze pe marginea '
            'drumului, BAG în plus și în firmă.',
          ),
          StepsBlock([
            'Tragi pe dreapta, oprești motorul, cobori geamul, ții mâinile '
                'la vedere',
            'Rămâi calm — un control este rutină, nu o suspiciune',
            'Prezinți permisul de conducere, actele vehiculului și '
                'înregistrările ultimelor 28 de zile',
            'Răspunzi la întrebări la obiect, nu inventezi nimic și nu '
                'înflorești nimic',
            'La o contestare: lași să se consemneze cazul, nu discuți în '
                'contradictoriu',
            'Apoi îți informezi dispecerul și documentezi cazul în firmă',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Pregătirea bate explicația',
            text: 'Un control durează câteva minute, dacă fișele sunt '
                'complete în vehicul. Orice altceva te costă pe tine și pe '
                'firmă toată după-amiaza.',
          ),
          RevealBlock(
            prompt: 'Exemplu practic: pe marginea drumului, inspectorul '
                'cere ultimele 28 de zile. Tu ai la tine doar săptămâna '
                'curentă — fișele mai vechi le-ai predat corect la depozit. '
                'Este suficient?',
            answer: 'Nu. Obligația de a purta documentele cuprinde ziua '
                'curentă și cele 28 de zile anterioare. Faptul că fișele '
                'mai vechi stau corect în firmă îndeplinește obligația de '
                'păstrare, dar nu și pe cea de a le purta cu tine — sunt '
                'două obligații separate. Corect este: copii sau originale '
                'ale ultimelor 28 de zile rămân la tine, abia apoi merg în '
                'arhivă. Lămurește cu dispecerul cum organizați asta în '
                'firmă.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Predarea în firmă',
        blocks: [
          ParagraphBlock(
            'Întreprinzătorul își poate îndeplini obligația de păstrare '
            'doar dacă primește și fișele. De aceea predarea nu este '
            'birocrație, ci parte a obligației tale de înregistrare.',
          ),
          BulletsBlock([
            'Predă fișele complet după expirarea termenului de purtare, nu '
                'teancuri la sfârșit de lună',
            'Nu arunca nimic, nici fișele cu greșeli sau cu corecturi',
            'Dacă îți lipsește o fișă, spune imediat — o lacună anunțată '
                'este mai bună decât una descoperită',
            'Zilele de concediu, de boală și de birou nu le lăsa pur și '
                'simplu deoparte, ci marchează-le conform regulii firmei',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Lacunele rămân lacune',
            text: 'O zi fără fișă nu mai poate fi reconstituită ulterior. '
                'Cine neglijează predarea produce exact lacunele care ies '
                'la iveală la un control în firmă.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare: documentele sub control',
        blocks: [
          ChecklistBlock(
            title: 'Înainte de fiecare tură și după fiecare săptămână',
            items: [
              'Înregistrările ultimelor 28 de zile sunt în vehicul',
              'Fișa de azi este începută și stă la îndemână',
              'Permisul de conducere și actele vehiculului sunt la mine',
              'Fișele expirate le-am predat în firmă',
              'Nu am aruncat nicio fișă, nici pe cele cu corecturi',
              'Știu pe cine trebuie să informez la un control',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'gb6',
    title: 'Consecințele în caz de încălcări',
    summary: 'Amendă, răspunderea firmei, escaladare internă',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Ce riști din punct de vedere legal',
        blocks: [
          ParagraphBlock(
            'O fișă zilnică de control lipsă sau incompletă este o '
            'contravenție. Cât de mare este amenda depinde de gravitatea '
            'încălcării și de cât de des s-a întâmplat.',
          ),
          FactsBlock([
            FactItem('de la 100 €', 'amendă pentru fișe lipsă sau '
                'incomplete'),
            FactItem('după gravitate', 'sume mai mari la încălcări multiple '
                'sau repetate'),
          ]),
          BulletsBlock([
            'Vizat nu este doar șoferul — și firma poartă răspunderea '
                'pentru înregistrări',
            'La încălcări grave sau repetate se riscă o procedură privind '
                'buna reputație a firmei',
            'Controlul se face de BAG și de poliție, pe marginea drumului '
                'și în firmă',
            'Contestările dintr-un control în firmă îi privesc pe toți '
                'șoferii, nu doar pe cel controlat',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Doi destinatari, o singură obligație',
            text: 'FPersV îi obligă împreună pe șofer și pe '
                'întreprinzător: tu trebuie să înregistrezi și să porți '
                'documentele cu tine, firma trebuie să le păstreze și să '
                'supravegheze. Dacă una dintre cele două cade, răspunde '
                'partea responsabilă.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Escaladarea în firmă',
        blocks: [
          ParagraphBlock(
            'Indiferent dacă o autoritate constată ceva, în firmă se aplică '
            'o succesiune fixă. Ea este aceeași pentru toți și se '
            'documentează.',
          ),
          StepsBlock([
            'Prima treaptă: avertisment verbal din partea dispecerului',
            'A doua treaptă: avertisment scris la dosarul de personal',
            'A treia treaptă: consecințe de dreptul muncii, până la '
                'concediere',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Încălcarea este fișa lipsă',
            text: 'Treptele se aplică indiferent dacă s-a întâmplat ceva '
                'sau dacă a avut loc un control. Deja fișa neținută este '
                'încălcarea.',
          ),
          RevealBlock(
            prompt: 'Exemplu practic: dispecerul insistă: „Mai fă cele două '
                'opriri, pauza o treci pur și simplu în fișă, altfel nu '
                'terminăm." Ce se aplică?',
            answer: 'Dispoziția nu schimbă nimic din obligația ta. Tu ești '
                'cel care înregistrează și semnează — cu semnătura ta '
                'confirmi conținutul. O dispoziție verbală nu te apără nici '
                'la control, nici mai târziu în firmă. Corect este: faci '
                'pauza, o treci corect, raportezi opririle rămase și '
                'documentezi dispoziția. Firma este obligată să facă '
                'posibilă respectarea normelor — nu să le ocolească.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare: încheiere',
        blocks: [
          ChecklistBlock(
            title: 'Ce rețin din această instruire',
            items: [
              'Green Book este registrul de control al curselor conform '
                  '§ 1 alin. 6 FPersV',
              'Cunosc toate datele obligatorii și le completez integral',
              'Respect 9 h de conducere, 4,5 h până la pauză, 45 min de '
                  'întrerupere și 11 h de odihnă',
              'Trec datele imediat, cu pixul, și semnez',
              'Port cu mine înregistrările ultimelor 28 de zile',
              'Predau fișele expirate în firmă',
              'Știu că o fișă lipsă poate declanșa o amendă de la 100 de '
                  'euro',
              'Știu că o dispoziție nu îmi anulează obligația de '
                  'înregistrare',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'O frază pentru tură',
            text: '„Fișa scrie odată cu mine în timp ce conduc — nu când '
                'am terminat."',
          ),
        ],
      ),
    ],
  ),
];
