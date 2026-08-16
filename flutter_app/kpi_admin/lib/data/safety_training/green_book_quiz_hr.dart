// lib/data/safety_training/green_book_quiz_hr.dart
//
// Pitanja završnog testa Green Book (knjiga kontrole vožnji prema
// § 1 st. 6 FPersV) — hrvatska verzija.
// Struktura je istovjetna njemačkoj verziji (master): isti broj pitanja,
// isti redoslijed, isti točni odgovori.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> greenBookQuestionsHr = [
  // ══════════════════════════ gb1 — Što je Green Book
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Što dokumentiraš u Green Booku?',
    options: [
      'Stanje vozila prije početka vožnje',
      'Broj dostavljenih paketa i povrata',
      'Vremena vožnje, prekide vožnje te radna vremena i vremena odmora',
    ],
    correctIndex: 2,
    explanation: 'Green Book je knjiga kontrole vožnji — zbirka dnevnih '
        'kontrolnih listova prema § 1 st. 6 FPersV. Dokazuje isključivo '
        'vremena. Stanje vozila dokumentira se na drugom mjestu i izričito '
        'tu ne spada.',
  ),
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Za koja vozila vrijedi obveza evidentiranja prema § 1 st. 6 '
        'FPersV?',
    options: [
      'Iznad 2,8 t do 3,5 t najveće dopuštene mase u gospodarskom '
          'prijevozu tereta',
      'Za svako vozilo kojim se gospodarski prevoze paketi',
      'Tek od 3,5 t najveće dopuštene mase',
    ],
    correctIndex: 0,
    explanation: 'Obveza vrijedi u rasponu iznad 2,8 t do 3,5 t — upravo za '
        'tipično dostavno vozilo. Ispod 2,8 t je nema, a od 3,5 t '
        'evidentiranje preuzima digitalni tahograf.',
  ),
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Tvoje dostavno vozilo ima prema prometnoj dozvoli 3,5 t '
        'najveće dopuštene mase, ali danas je natovareno sa samo 900 kg. '
        'Što vrijedi?',
    options: [
      'Nema obveze evidentiranja — stvarna težina je ispod 2,8 t',
      'Obveza evidentiranja i dalje postoji',
      'Obveza vrijedi tek od dnevne relacije od 100 kilometara',
    ],
    correctIndex: 1,
    explanation: 'Mjerodavna je najveća dopuštena masa iz prometne dozvole, '
        'a ne današnja težina tereta. Uobičajena zabluda jest svaki dan '
        'iznova računati prema utovaru — razvrstavanje vozila time se ne '
        'mijenja.',
  ),

  // ══════════════════════════ gb2 — Što se točno upisuje
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Koji podatak NE spada u obvezne podatke dnevnog kontrolnog '
        'lista?',
    options: [
      'Stanje kilometara na početku i na kraju vožnje',
      'Broj dostavljenih pošiljaka',
      'Mjesto početka i završetka vožnje',
    ],
    correctIndex: 1,
    explanation: 'Propisani su, među ostalim, prezime, ime i adresa vozača, '
        'registarska oznaka, datum, stanja kilometara, mjesta, vremena i '
        'potpis. Broj komada interni je pokazatelj tvrtke i ne stoji na '
        'listu.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Čime ispunjavaš dnevni kontrolni list?',
    options: [
      'Kemijskom olovkom, trajnim zapisom',
      'Grafitnom olovkom, da se pogreške mogu uredno ispraviti',
      'Sredstvo za pisanje nije važno, dok god je čitljivo',
    ],
    correctIndex: 0,
    explanation: 'Upis koji se može izbrisati gumicom nije dokaz. Upravo '
        'zato grafitna olovka nije dopuštena — čak i kad je ispravka dobro '
        'zamišljena. Pogreška se precrta jednom crtom i pored se napiše '
        'ispravno.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Sva vremena i stanja kilometara su upisana, nedostaje samo '
        'potpis. Što vrijedi za taj list?',
    options: [
      'Valjan je — potpis je čista formalnost',
      'Smatra se nepotpunim i ne ispunjava obvezu evidentiranja',
      'Disponent ga može naknadno supotpisati u tvrtki',
    ],
    correctIndex: 1,
    explanation: 'Potpis je jedan od propisanih podataka — njime potvrđuješ '
        'sadržaj. Bez njega list je nepotpun, s istim posljedicama kao i '
        'list koji nedostaje. Tuđi potpis ne zamjenjuje tvoj.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Čekaš 40 minuta na rampi. Ne radiš ništa, ali moraš biti '
        'stalno na raspolaganju jer se svakog trena može krenuti dalje. '
        'Kako upisuješ to vrijeme?',
    options: [
      'Kao prekid vožnje — ipak nisi radio',
      'Kao početak dnevnog vremena odmora',
      'Kao radno vrijeme',
    ],
    correctIndex: 2,
    explanation: 'Prekid vožnje stanka je samo ako tim vremenom možeš '
        'slobodno raspolagati i to znaš unaprijed. Biti na raspolaganju '
        'vrijeme je čekanja, a time i radno vrijeme. Uobičajena zabluda '
        'glasi „nisam ništa radio, dakle bila je stanka" — presudna nije '
        'aktivnost, nego raspoloživost.',
  ),

  // ══════════════════════════ gb3 — Vremena vožnje, stanke, odmori
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Koliko dugo smiješ najviše voziti u normalnom danu?',
    options: [
      '9 sati',
      '10 sati',
      '8 sati, nakon toga samo uz suglasnost disponenta',
    ],
    correctIndex: 0,
    explanation: 'Dnevno vrijeme vožnje iznosi najviše 9 sati. Tih 10 sati '
        'nije druga redovna granica, nego usko ograničena iznimka — a '
        'suglasnost tvrtke za tu granicu uopće nije bitna.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Koliko često smiješ produljiti vrijeme vožnje na 10 sati?',
    options: [
      'Jednom tjedno',
      'Dvaput tjedno',
      'Svaki dan kad tura to zahtijeva',
    ],
    correctIndex: 1,
    explanation: 'Dvaput tjedno dnevno vrijeme vožnje smije se produljiti '
        'na 10 sati. To je tjedni kontingent, a ne dnevno pravo — i opseg '
        'ture ga ne produljuje.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Želiš podijeliti prekid vožnje od 45 minuta. Koja je podjela '
        'dopuštena?',
    options: [
      'Prvo 30 minuta, potom 15 minuta',
      'Triput po 15 minuta raspoređeno kroz dan',
      'Prvo 15 minuta, potom 30 minuta',
    ],
    correctIndex: 2,
    explanation: 'Podjela je dopuštena samo na dva dijela i samo tim '
        'redoslijedom: prvo najmanje 15, potom najmanje 30 minuta. Obrnut '
        'redoslijed se ne priznaje, kao ni tri kratka dijela — čak i kad je '
        'zbroj točan.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Krećeš u 07:00. Do 09:30 sjediš 2 sata za volanom, do 12:00 '
        'dolaze još 2 sata vremena vožnje, do 13:00 još 30 minuta. Kada '
        'prekid vožnje najkasnije slijedi?',
    options: [
      'U 11:30, dakle 4,5 sata nakon početka rada',
      'U 12:00, jer je vrijeme ručka za to predviđeno',
      'U 13:00',
    ],
    correctIndex: 2,
    explanation: '2 + 2 + 0,5 sata daju u 13:00 točno 4,5 sata čistog '
        'vremena vožnje — sada ne smiješ prijeći ni metar prije nego što '
        'odradiš stanku. Uobičajena zabluda jest računati od početka rada: '
        'sat radi samo dok vozilo vozi.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Vrijeme vožnje završavaš u 17:15. Kada najranije smiješ '
        'ponovno krenuti?',
    options: [
      'U 02:15 — 9 sati odmora je dovoljno',
      'U 04:15',
      'Čim se osjećaš odmorno, čvrste granice nema',
    ],
    correctIndex: 1,
    explanation: 'Dnevno vrijeme odmora iznosi najmanje 11 sati, dakle '
        'najranije u 04:15. Tih 9 sati granica je za vrijeme vožnje, a ne '
        'za odmor — te dvije brojke redovito se zamjenjuju.',
  ),

  // ══════════════════════════ gb4 — Tipične pogreške
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Kolega ispunjava listove za cijeli tjedan u petak navečer. '
        'Vremena su sadržajno točna. Kako to ocijeniti?',
    options: [
      'To je prekršaj i primijeti se pri kontroli',
      'Bez problema, dok god upisana vremena odgovaraju istini',
      'Samo pitanje urednosti, ali bez pravnog značenja',
    ],
    correctIndex: 0,
    explanation: 'Evidentirati znači evidentirati pravodobno. Naknadno '
        'napisani listovi prepoznaju se po istom rukopisu, upadljivo '
        'okruglim vremenima i stanjima kilometara koja ne odgovaraju '
        'relaciji. To što su vremena točna ne otklanja prekršaj obveze '
        'evidentiranja.',
  ),
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'U četvrtak primijetiš da u utorak nije upisana stanka za '
        'ručak. Sigurno se sjećaš vremena. Što radiš?',
    options: [
      'Upisujem kao naknadni upis s datumom dopune i obavještavam '
          'disponenta',
      'Ubacujem upis tako da izgleda kao da je napisan u utorak',
      'Ostavljam prazninu — naknadni upis samo pogoršava stvar',
    ],
    correctIndex: 0,
    explanation: 'Poštena, prepoznatljivo datirana ispravka dopuštena je i '
        'bolja od praznine. Oblikovati upis tako kao da je nastao u utorak '
        'korak je od nemara do obmane — i vrednuje se znatno teže.',
  ),
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Danas si vozio 9,5 sati, iako je tvoj tjedni kontingent za '
        '10 sati već bio potrošen. Što upisuješ?',
    options: [
      'Točno 9,0 sati — da list izgleda u skladu s propisima',
      'Stvarno odvožena 9,5 sata',
      'Za taj dan ništa, tako se neće primijetiti',
    ],
    correctIndex: 1,
    explanation: 'Uvijek upisuješ stvarna vremena. Uljepšan upis pretvara '
        'prekoračenje u lažni podatak i pogoršava stvar. List koji '
        'nedostaje također je zaseban prekršaj — izostavljanje ne pomaže.',
  ),

  // ══════════════════════════ gb5 — Nošenje, predaja, čuvanje
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Koje evidencije moraš nositi sa sobom u vozilu?',
    options: [
      'Samo list tekućeg dana',
      'Listove tekućeg kalendarskog tjedna',
      'Tekući dan i prethodnih 28 dana',
    ],
    correctIndex: 2,
    explanation: 'Nositi treba evidencije posljednjih 28 dana uključujući '
        'tekući dan. To što stariji listovi uredno leže u tvrtki ispunjava '
        'obvezu čuvanja, ali ne i obvezu nošenja — to su dvije odvojene '
        'obveze.',
  ),
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Koliko dugo poduzetnik mora čuvati dnevne kontrolne listove '
        'u tvrtki?',
    options: [
      'Godinu dana',
      '28 dana, nakon toga se smiju uništiti',
      'Tri mjeseca od kraja kvartala',
    ],
    correctIndex: 0,
    explanation: 'Poduzetnik čuva evidencije godinu dana i predočuje ih na '
        'zahtjev. Tih 28 dana rok je za nošenje kod vozača — često se '
        'zamjenjuje s rokom čuvanja.',
  ),
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Tko kontrolira pridržavanje obveze evidentiranja?',
    options: [
      'Isključivo policija, i to samo pri cestovnim kontrolama',
      'BAG i policija — pri cestovnim kontrolama i u tvrtki',
      'TÜV u okviru tehničkog pregleda vozila',
    ],
    correctIndex: 1,
    explanation: 'Kontrolu provode BAG (Bundesamt für Logistik und '
        'Mobilität, Savezni ured za logistiku i mobilnost) i policija, i uz '
        'cestu i u tvrtki. Tehnički pregled odnosi se na tehničko stanje '
        'vozila i s evidencijama nema veze.',
  ),

  // ══════════════════════════ gb6 — Posljedice
  DrivingQuestion(
    moduleId: 'gb6',
    question: 'S čime treba računati ako listovi nedostaju ili su '
        'nepotpuni?',
    options: [
      'S novčanom kaznom od 100 eura, ovisno o težini i višom',
      'Ni s kakvom posljedicom — to je čisto interni propis tvrtke',
      'S besplatnom opomenom bez daljnjih posljedica',
    ],
    correctIndex: 0,
    explanation: 'Evidencije koje nedostaju ili su nepotpune jesu prekršaj; '
        'novčana kazna počinje od oko 100 eura i raste s težinom. Kod '
        'teških ili ponovljenih prekršaja može se dodatno pokrenuti '
        'postupak o pouzdanosti tvrtke.',
  ),
  DrivingQuestion(
    moduleId: 'gb6',
    question: 'Disponent kaže: „Odvezi još ta dva stajališta, stanku '
        'jednostavno upiši." Kako reagiraš?',
    options: [
      'Slijedim uputu — odgovornost tada snosi disponent',
      'Izostavljam stanku, ali barem pošteno upisujem da je nema',
      'Napravim stanku, ispravno je upišem i javim otvorena stajališta',
    ],
    correctIndex: 2,
    explanation: 'Usmena uputa ne ukida tvoju obvezu evidentiranja — ti '
        'potpisuješ list i time potvrđuješ sadržaj. Svjesno izostaviti '
        'stanku bio bi uz to i prekršaj propisa o vremenima vožnje. Tvrtka '
        'mora omogućiti pridržavanje propisa, a ne zaobilaziti ga.',
  ),
];

// Odabir jezika i filtriranje po poglavljima nalaze se u podatkovnom
// sloju obuke — vidi green_book_quiz_de.dart.
