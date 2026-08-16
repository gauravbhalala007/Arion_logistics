// lib/data/safety_training/privacy_quiz_ro.dart
//
// Întrebările testului final al instruirii de protecție a datelor —
// versiunea română. Structura este identică cu versiunea germană
// (master, privacy_quiz_de.dart): optsprezece întrebări, repartizate
// uniform pe cele șase capitole din privacy_content_ro.dart (câte trei
// întrebări per capitol ds1 … ds6), aceeași ordine a opțiunilor și
// aceleași răspunsuri corecte. Orice modificare de structură se face
// mai întâi în fișierul german și se preia apoi aici.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> privacyQuestionsRo = [
  // ══════════════════════════ ds1 — De ce te privește protecția datelor
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Care dintre următoarele informații NU este o informație '
        'cu caracter personal în sensul DSGVO (GDPR)?',
    options: [
      'Numărul total al coletelor livrate azi pe tură',
      'Indicația „Coletul, te rog, în spatele tomberonului" împreună '
          'cu adresa aferentă',
      'Fotografia de livrare din fața ușii unui destinatar',
    ],
    correctIndex: 0,
    explanation: 'Un simplu număr de bucăți, fără legătură cu o '
        'persoană, nu are caracter personal. Indicația de amplasare, în '
        'schimb, spune ceva despre situația locativă a unui anumit om, '
        'iar fotografia de livrare este asociată unei adrese. Greșeala '
        'la îndemână este să consideri personale doar numele — cu '
        'caracter personal este orice informație prin care o persoană '
        'poate fi identificată.',
  ),
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Povestești seara între prieteni pe ce stradă locuiește '
        'un sportiv cunoscut, al cărui colet l-ai livrat. Cum se '
        'evaluează asta?',
    options: [
      'Neproblematic, atâta timp cât nu pui numele pe internet',
      'O încălcare a limitării scopului și a confidențialității '
          'conform Art. 5 DSGVO',
      'Neproblematic, pentru că o adresă este oricum cunoscută public',
    ],
    correctIndex: 1,
    explanation: 'Cunoști adresa exclusiv din munca ta. Să o dai mai '
        'departe unor terți este o divulgare contrară scopului și '
        'încalcă Art. 5 alin. 1 lit. b și lit. f DSGVO. Greșeala la '
        'îndemână este să crezi că un cerc privat mic nu contează — '
        'DSGVO nu întreabă de mărimea publicului.',
  ),
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Din ce prevederi rezultă că firma trebuie să te '
        'instruiască în protecția datelor?',
    options: [
      'Din § 12 alin. 1 ArbSchG (legea protecției muncii) — protecția '
          'datelor este parte a instructajului anual de siguranță',
      'Dintr-o obligație de instruire explicită în Art. 30 DSGVO',
      'Indirect, din Art. 32, Art. 39 alin. 1 lit. b și Art. 5 alin. 2 '
          'DSGVO',
    ],
    correctIndex: 2,
    explanation: 'DSGVO nu cunoaște o obligație de instruire explicită. '
        'Ea rezultă indirect: Art. 32 cere măsuri organizatorice, '
        'Art. 39 alin. 1 lit. b numește sensibilizarea și instruirea '
        'drept sarcină a responsabilului cu protecția datelor, iar '
        'Art. 5 alin. 2 cere dovada respectării regulilor. Art. 30 '
        'privește, în schimb, registrul activităților de prelucrare, '
        'iar ArbSchG reglementează protecția muncii, nu protecția '
        'datelor.',
  ),

  // ══════════════════════════ ds2 — Fotografiile și dovezile de livrare
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'Ce are voie să se vadă pe o fotografie de livrare?',
    options: [
      'Destinatarul, dacă și-a dat verbal acordul pentru fotografie',
      'Coletul la locul de amplasare, plus ușa sau numărul casei ca '
          'reper',
      'Coletul și numărul de înmatriculare al vehiculului parcat în '
          'față, pentru o identificare mai bună',
    ],
    correctIndex: 1,
    explanation: 'Fotografia răspunde la exact o întrebare: unde se '
        'află coletul? Tot ce este în plus încalcă reducerea datelor la '
        'minimum conform Art. 5 alin. 1 lit. c DSGVO. Persoanele nu au '
        'ce căuta pe dovadă nici cu acord verbal, iar un număr de '
        'înmatriculare este o informație cu caracter personal care nu '
        'este necesară scopului.',
  ),
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'Scannerul nu funcționează. Fotografiezi locul de '
        'amplasare cu camera normală a telefonului și încarci apoi '
        'imaginea în aplicația de serviciu. Ce este greșit aici?',
    options: [
      'Nimic — decisiv este doar ca imaginea să ajungă la final în '
          'aplicație',
      'Doar calitatea imaginii, juridic este în regulă',
      'Imaginea rămâne apoi permanent în galeria privată, adesea și '
          'într-un cloud privat',
    ],
    correctIndex: 2,
    explanation: 'Încărcarea nu elimină copia: originalul rămâne în '
        'galeria privată și este adesea salvat automat într-un cloud. '
        'Astfel, date cu caracter personal ajung în afara controlului '
        'firmei. Greșeala la îndemână este să crezi că doar starea '
        'finală contează — decisivă este fiecare copie care apare pe '
        'drum.',
  ),
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'După închiderea opririi observi că pe fotografia '
        'încărcată se recunoaște o vecină. Ce faci?',
    options: [
      'Informezi dispecerul sau conducerea firmei, ca imaginea să fie '
          'ștearsă din sistem',
      'Nimic — oprirea este închisă, imaginea oricum nu mai poate fi '
          'schimbată',
      'Suni a doua zi la ușa vecinei și îi ceri permisiunea',
    ],
    correctIndex: 0,
    explanation: 'Doar dacă firma știe, poate șterge imaginea și '
        'documenta cazul. Greșeala la îndemână este să crezi că o '
        'raportare după închiderea opririi nu mai merită. Un '
        'consimțământ ulterior nu vindecă încălcarea și, în plus, nu '
        'este un temei legal solid în contextul raportului de muncă.',
  ),

  // ══════════════════════════ ds3 — Lucrul cu datele destinatarilor
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Faci o captură de ecran a listei de adrese, ca să reții '
        'mai ușor ordinea. Nimeni altcineva nu o vede. Este permis?',
    options: [
      'Da, atâta timp cât ștergi captura la sfârșitul turei',
      'Da, pentru că oricum ai voie să prelucrezi datele în scop de '
          'serviciu',
      'Nu — o captură de ecran este o copie în afara sistemului și '
          'deci nepermisă',
    ],
    correctIndex: 2,
    explanation: 'Prin captura de ecran apare o copie a datelor cu '
        'caracter personal, pe care firma nu o mai poate controla. '
        'Faptul că ai voie să vezi datele în scop de serviciu nu îți '
        'permite să le stochezi în afara sistemului. Nici intenția de '
        'a șterge mai târziu nu schimbă nimic la prelucrarea nepermisă.',
  ),
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Un vecin preia un colet și întreabă ce este înăuntru și '
        'dacă destinatarul mai locuiește acolo. Ce spui?',
    options: [
      'Doar numele destinatarului și numărul casei — despre conținut '
          'și alte informații, nimic',
      'Tot ce scrie pe etichetă, pentru că el preia coletul',
      'Nimic, nici măcar numele destinatarului',
    ],
    correctIndex: 0,
    explanation: 'Pentru predarea la vecin sunt necesare numele și '
        'numărul casei — fără ele vecinul nu poate da coletul mai '
        'departe. Tot ce este în plus, în special conținutul sau '
        'confirmarea situației locative, este o divulgare fără temei '
        'legal conform Art. 6 DSGVO. Să nu spui nimic ar fi, în '
        'schimb, rupt de practică și ar face predarea imposibilă.',
  ),
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Tura s-a încheiat, lista de tură pe hârtie nu mai este '
        'necesară. Cum o elimini corect?',
    options: [
      'În tomberonul de hârtie de la propriul bloc, imediat ce ajungi '
          'acasă',
      'Pe calea prevăzută în firmă — container de protecție a datelor '
          'sau distrugător de documente',
      'Ruptă, la gunoiul menajer de la benzinărie, ca să nu o mai '
          'poată citi nimeni',
    ],
    correctIndex: 1,
    explanation: 'Pe listă se află nume și adrese; ea trebuie eliminată '
        'astfel încât să nu poată fi reconstituită — în firmă, prin '
        'container de protecție a datelor sau distrugător de documente. '
        'Greșeala la îndemână este să crezi că o listă rezolvată nu mai '
        'valorează nimic. Tomberoanele accesibile publicului sunt '
        'excluse, iar acasă oricum nu ai fi avut voie să iei lista.',
  ),

  // ══════════════════════════ ds4 — Datele proprii și ale colegilor
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Un coleg te roagă să îi trimiți o captură de ecran a '
        'unei evaluări interne, pe care apar toți șoferii cu nume și '
        'valori. Vrea să își vadă doar propriul rând. Cum reacționezi?',
    options: [
      'Refuzi și îl trimiți la conducerea firmei — are dreptul doar la '
          'propriile lui date',
      'I-o trimiți, pentru că apare el însuși pe listă și deci are '
          'drept de acces',
      'I-o trimiți, dar întâi faci ilizibile numele celorlalți și apoi '
          'ștergi captura',
    ],
    correctIndex: 0,
    explanation: 'Cu captura de ecran ar primi datele de performanță '
        'ale tuturor colegilor — o transmitere de date ale angajaților '
        'fără temei legal. Dreptul lui de acces conform Art. 15 DSGVO '
        'se referă exclusiv la propriile lui date. Nici o anonimizare '
        'improvizată nu schimbă faptul că ai creat o copie nepermisă.',
  ),
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'De ce sunt concediile medicale ale colegilor protejate '
        'în mod special?',
    options: [
      'Pentru că sunt desemnate explicit drept confidențiale în '
          'contractul de muncă',
      'Pentru că sunt secrete de afaceri conform GeschGehG',
      'Pentru că datele de sănătate sunt categorii speciale de date cu '
          'caracter personal conform Art. 9 DSGVO',
    ],
    correctIndex: 2,
    explanation: 'Datele de sănătate intră sub Art. 9 DSGVO și '
        'beneficiază de o protecție mai strictă decât datele obișnuite. '
        'Deja simplul fapt al îmbolnăvirii este o astfel de informație, '
        'motivul cu atât mai mult. Secretele de afaceri privesc, în '
        'schimb, cunoștințele interne ale firmei, nu datele de sănătate '
        'ale angajaților.',
  ),
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Vrei să știi ce date a stocat angajatorul tău despre '
        'tine. Ce drept folosești pentru asta?',
    options: [
      'Dreptul la portabilitatea datelor conform Art. 20 DSGVO',
      'Dreptul de acces conform Art. 15 DSGVO',
      'Dreptul la opoziție conform Art. 21 DSGVO',
    ],
    correctIndex: 1,
    explanation: 'Art. 15 DSGVO îți dă dreptul la o privire de '
        'ansamblu asupra datelor stocate despre tine și a scopurilor '
        'lor. Art. 20 privește predarea într-un format portabil, '
        'Art. 21 opoziția față de o prelucrare — niciunul nu răspunde '
        'la întrebarea ce anume este stocat. Cererea trebuie, în '
        'principiu, să primească răspuns în termen de o lună.',
  ),

  // ══════════════════════════ ds5 — Incidentul de date
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Care dintre aceste incidente NU este un incident de '
        'date?',
    options: [
      'Ai predat un colet destinatarului greșit, care l-a deschis',
      'Te-ai încurcat la numărul retururilor din raportul zilnic',
      'Ai lăsat lista de tură la vedere în vehiculul neîncuiat',
    ],
    correctIndex: 1,
    explanation: 'O greșeală de numărare la retururi nu privește date '
        'cu caracter personal și nu le face accesibile nimănui. În '
        'celelalte două cazuri, persoane neautorizate au putut lua la '
        'cunoștință nume, adrese sau conținutul trimiterilor — aceasta '
        'este o încălcare a securității datelor cu caracter personal.',
  ),
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Ce spune termenul de 72 de ore din Art. 33 DSGVO?',
    options: [
      'Firma trebuie să notifice un incident de date autorității de '
          'supraveghere, pe cât posibil în 72 de ore de la aflare',
      'Șoferul are la dispoziție 72 de ore ca să raporteze incidentul '
          'în firmă',
      'Persoanele vizate trebuie să reclame la firmă în 72 de ore, '
          'altfel își pierd dreptul',
    ],
    correctIndex: 0,
    explanation: 'Termenul obligă firma față de autoritatea de '
        'supraveghere și curge de la aflare. Exact de aceea trebuie să '
        'raportezi imediat — fiecare oră în care aștepți îi lipsește '
        'firmei. Greșeala la îndemână este să citești cele 72 de ore '
        'ca pe o fereastră de timp proprie a șoferului.',
  ),
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Ai observat seara că un colet a ajuns la destinatarul '
        'greșit și a fost deschis acolo. Ce este corect?',
    options: [
      'Îl iei mâine dimineață discret și îl livrezi corect — astfel '
          'greșeala este reparată',
      'Îl menționezi abia la următoarea discuție de serviciu, pentru '
          'că oricum nu se mai poate schimba nimic',
      'Informezi încă din aceeași zi dispecerul sau conducerea firmei '
          'și nu întreprinzi nimic pe cont propriu',
    ],
    correctIndex: 2,
    explanation: 'Incidentul de date s-a produs deja: o persoană '
        'străină a aflat numele, adresa și conținutul trimiterii. '
        'Firma trebuie să evalueze, să documenteze și, dacă este '
        'cazul, să notifice conform Art. 33 DSGVO — pentru asta are '
        'nevoie de informație imediat. Corectura tăcută pare '
        'inofensivă, dar împiedică exact acești pași. Cine raportează '
        'imediat procedează corect.',
  ),

  // ══════════════════════════ ds6 — Confidențialitate și loialitate
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'Care afirmație NU este acoperită de libertatea de '
        'exprimare?',
    options: [
      'Afirmația că o tură nu poate fi terminată, în mod repetat, în '
          'timpul planificat',
      'Semnalarea că un vehicul nu a fost reparat în ciuda '
          'raportărilor repetate',
      'Afirmația conștient neadevărată că firma își înșală sistematic '
          'șoferii la ore',
    ],
    correctIndex: 2,
    explanation: 'Exprimarea opiniilor și critica adevărată sunt '
        'protejate de Art. 5 alin. 1 GG (Constituția Germaniei), chiar '
        'dacă sunt incomode. Afirmațiile factuale conștient neadevărate '
        'nu sunt: ele pot justifica o concediere fără preaviz conform '
        '§ 626 BGB, iar la defăimare pot fi în plus pedepsite conform '
        '§ 186 StGB.',
  ),
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'Raportezi după cea mai bună știință o neregulă din '
        'firmă. La final se dovedește că suspiciunea ta nu s-a '
        'confirmat. Ce este valabil?',
    options: [
      'Protecția dispare retroactiv, pentru că raportarea a fost falsă',
      'Rămâi protejat de represalii prin legea protecției avertizorilor '
          '(HinSchG)',
      'Protecția este valabilă doar dacă ai depus raportarea și extern',
    ],
    correctIndex: 1,
    explanation: 'HinSchG (în vigoare din 2 iulie 2023) protejează '
        'angajații care raportează încălcări de represalii precum '
        'concediere, avertisment sau dezavantajare. Protecția dispare '
        'doar la raportări neadevărate făcute cu bună știință sau din '
        'neglijență gravă — nu la o suspiciune serioasă care la final '
        'nu se confirmă. O raportare externă nu este necesară pentru '
        'asta.',
  ),
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'În grupul de chat al șoferilor se discută despre '
        'presupuse tăieri de salariu. Ești tu însuți nemulțumit. Care '
        'este calea corectă?',
    options: [
      'Îți numești propriul caz concret și îl duci la dispecer, la '
          'conducerea firmei sau la canalul intern de raportare',
      'Confirmi afirmația în grup, ca să fie avertizați colegii',
      'Postezi acuzația public pe un portal de recenzii, ca să se '
          'miște ceva',
    ],
    correctIndex: 0,
    explanation: 'Propriul caz, verificabil, este adevărat, obiectiv '
        'și protejat prin HinSchG — și intern se rezolvă cel mai '
        'repede. Să confirmi o afirmație pe care nu ai trăit-o tu '
        'însuți este o afirmație factuală neadevărată; un grup de chat '
        'închis nu este un spațiu protejat, de îndată ce circulă o '
        'captură de ecran. Ieșirea în afară intră în discuție abia '
        'când intern nu se întâmplă nimic.',
  ),
];
