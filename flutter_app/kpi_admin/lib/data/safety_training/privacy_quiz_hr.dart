// lib/data/safety_training/privacy_quiz_hr.dart
//
// Pitanja završnog testa obuke o zaštiti podataka — hrvatska verzija.
// Struktura je istovjetna njemačkoj verziji (master
// privacy_quiz_de.dart): osamnaest pitanja, ravnomjerno raspoređenih na
// šest poglavlja iz privacy_content_hr.dart (po tri pitanja po poglavlju
// ds1 … ds6), isti redoslijed odgovora i isti točni odgovori — kod
// izmjena držati usklađeno s masterom.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> privacyQuestionsHr = [
  // ══════════════════════════ ds1 — Zašto se zaštita podataka tiče tebe
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Koji od sljedećih podataka NIJE osobni podatak u smislu '
        'DSGVO-a (GDPR)?',
    options: [
      'Ukupan broj paketa dostavljenih danas na turi',
      'Napomena „paket molim staviti iza kante za smeće" s pripadajućom '
          'adresom',
      'Fotografija dostave ispred ulaznih vrata primatelja',
    ],
    correctIndex: 0,
    explanation: 'Sam broj komada bez veze s nekom osobom nije osobni '
        'podatak. Napomena o odlaganju, naprotiv, govori nešto o '
        'stambenoj situaciji određenog čovjeka, a fotografija dostave '
        'pridružena je adresi. Bliska je zabluda smatrati osobnima samo '
        'imena — osobni je podatak svaki podatak po kojem se neka osoba '
        'može odrediti.',
  ),
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Navečer u društvu prijatelja ispričaš u kojoj ulici '
        'stanuje poznati sportaš čiji si paket dostavio. Kako to '
        'ocijeniti?',
    options: [
      'Nije problem dok god ime ne staviš na internet',
      'Povreda ograničenja svrhe i povjerljivosti prema Art. 5 '
          'DSGVO',
      'Nije problem jer je adresa ionako javno poznata',
    ],
    correctIndex: 1,
    explanation: 'Adresu znaš isključivo sa svog posla. Proslijediti je '
        'trećim osobama otkrivanje je protivno svrsi i krši Art. 5 '
        'Abs. 1 lit. b i lit. f DSGVO. Bliska je zabluda da se mali '
        'privatni krug ne računa — DSGVO ne pita za veličinu publike.',
  ),
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Iz kojih propisa proizlazi da te tvrtka mora obučiti o '
        'zaštiti podataka?',
    options: [
      'Iz § 12 Abs. 1 njemačkog Zakona o zaštiti na radu — zaštita '
          'podataka dio je godišnje sigurnosne pouke',
      'Iz izričite obveze obuke u Art. 30 DSGVO',
      'Posredno iz Art. 32, Art. 39 Abs. 1 lit. b i Art. 5 Abs. 2 '
          'DSGVO',
    ],
    correctIndex: 2,
    explanation: 'DSGVO ne poznaje izričitu obvezu obuke. Ona proizlazi '
        'posredno: Art. 32 zahtijeva organizacijske mjere, Art. 39 '
        'Abs. 1 lit. b navodi podizanje svijesti i obuku kao zadaću '
        'službenika za zaštitu podataka, a Art. 5 Abs. 2 zahtijeva '
        'dokaz usklađenosti. Art. 30 se, naprotiv, odnosi na evidenciju '
        'aktivnosti obrade, a ArbSchG uređuje zaštitu na radu, ne '
        'zaštitu podataka.',
  ),

  // ══════════════════════════ ds2 — Fotografije i dokazi o dostavi
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'Što smije biti vidljivo na fotografiji dostave?',
    options: [
      'Primatelj, ako je usmeno pristao na snimanje',
      'Paket na mjestu odlaganja, uz vrata ili kućni broj kao prostornu '
          'referencu',
      'Paket i registarska oznaka vozila parkiranog ispred, radi lakše '
          'identifikacije',
    ],
    correctIndex: 1,
    explanation: 'Fotografija odgovara na točno jedno pitanje: gdje leži '
        'paket? Sve preko toga krši minimizaciju podataka prema Art. 5 '
        'Abs. 1 lit. c DSGVO. Osobe ne idu na dokaz ni uz usmeni '
        'pristanak, a registarska oznaka osobni je podatak koji za tu '
        'svrhu nije potreban.',
  ),
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'Skener štrajka. Mjesto odlaganja fotografiraš svojom '
        'običnom kamerom na mobitelu i sliku zatim učitaš u službenu '
        'aplikaciju. Što je u tome pogrešno?',
    options: [
      'Ništa — bitno je samo da slika na kraju bude u aplikaciji',
      'Samo kvaliteta slike, pravno je bezopasno',
      'Slika nakon toga trajno leži u privatnoj galeriji, često dodatno '
          'i u privatnom cloudu',
    ],
    correctIndex: 2,
    explanation: 'Učitavanje ne uklanja kopiju: original ostaje u '
        'privatnoj galeriji i često se automatski sprema u cloud. Time '
        'osobni podaci leže izvan kontrole tvrtke. Bliska je zabluda da '
        'se računa samo konačno stanje — bitna je svaka kopija koja '
        'usput nastane.',
  ),
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'Nakon zaključivanja stajališta primijetiš da je na '
        'učitanoj fotografiji prepoznatljiva susjeda. Što ćeš '
        'učiniti?',
    options: [
      'Obavijestiti disponenta ili upravu kako bi se slika izbrisala iz '
          'sustava',
      'Ništa — stajalište je zaključeno, slika se ionako više ne može '
          'mijenjati',
      'Sutradan pozvoniti susjedi i zamoliti je za dopuštenje',
    ],
    correctIndex: 0,
    explanation: 'Samo ako tvrtka za to zna, može izbrisati sliku i '
        'dokumentirati postupak. Bliska je zabluda da se prijava nakon '
        'zaključenog stajališta više ne isplati. Naknadna privola ne '
        'otklanja povredu, a uz to u radnom kontekstu nije održiva '
        'pravna osnova.',
  ),

  // ══════════════════════════ ds3 — Postupanje s podacima primatelja
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Napraviš screenshot adresne liste kako bi lakše zapamtio '
        'redoslijed. Nitko ga drugi ne dobije vidjeti. Je li to '
        'dopušteno?',
    options: [
      'Da, dok god screenshot na kraju ture opet izbrišeš',
      'Da, jer te podatke ionako smiješ službeno obrađivati',
      'Ne — screenshot je kopija izvan sustava i time je nedopušten',
    ],
    correctIndex: 2,
    explanation: 'Screenshotom nastaje kopija osobnih podataka koju '
        'tvrtka više ne može kontrolirati. To što podatke smiješ '
        'službeno vidjeti ne dopušta ti da ih spremaš izvan sustava. Ni '
        'namjera da ih kasnije izbrišeš ne mijenja ništa na '
        'nedopuštenoj obradi.',
  ),
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Susjed preuzima paket i pita što je unutra i stanuje li '
        'primatelj uopće još tamo. Što kažeš?',
    options: [
      'Samo ime primatelja i kućni broj — o sadržaju i drugim podacima '
          'bez informacija',
      'Sve što piše na etiketi, jer on paket ipak preuzima',
      'Ništa, čak ni ime primatelja',
    ],
    correctIndex: 0,
    explanation: 'Za predaju susjedu potrebni su ime i kućni broj — bez '
        'njih susjed paket ne može predati dalje. Sve preko toga, '
        'posebno sadržaj ili potvrđivanje toga tko gdje stanuje, '
        'otkrivanje je bez pravne osnove prema Art. 6 DSGVO. Ne reći '
        'baš ništa bilo bi pak nepraktično i predaja ne bi bila '
        'izvediva.',
  ),
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Tura je gotova, papirnata lista ture više nije potrebna. '
        'Kako je ispravno zbrinuti?',
    options: [
      'U kantu za papir kod vlastite zgrade čim dođeš kući',
      'Predviđenim putem u tvrtki — spremnik za zaštitu podataka ili '
          'uništavač dokumenata',
      'Poderanu u ostali otpad na benzinskoj postaji kako je nitko više '
          'ne bi mogao pročitati',
    ],
    correctIndex: 1,
    explanation: 'Na listi su imena i adrese; mora se zbrinuti tako da '
        'se ne može obnoviti — u tvrtki preko spremnika za zaštitu '
        'podataka ili uništavača dokumenata. Bliska je zabluda da je '
        'odrađena lista bezvrijedna. Javno dostupne kante otpadaju, a '
        'listu kući ionako nisi smio ponijeti.',
  ),

  // ══════════════════════════ ds4 — Vlastiti podaci i podaci kolega
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Kolega te moli za screenshot interne analize na kojoj su '
        'svi vozači s imenima i vrijednostima. Želi vidjeti samo svoj '
        'redak. Kako reagiraš?',
    options: [
      'Odbiti i uputiti ga na upravu — ima pravo samo na svoje vlastite '
          'podatke',
      'Poslati, jer je i sam na listi pa zato ima pravo pristupa',
      'Poslati, ali prije toga zacrniti imena ostalih i zatim izbrisati '
          'screenshot',
    ],
    correctIndex: 0,
    explanation: 'Sa screenshotom bi dobio podatke o učinku svih kolega '
        '— prosljeđivanje podataka zaposlenika bez pravne osnove. '
        'Njegovo pravo na pristup prema Art. 15 DSGVO odnosi se '
        'isključivo na njegove vlastite podatke. Ni vlastoručno '
        'zacrnjivanje ne mijenja to da si izradio nedopuštenu kopiju.',
  ),
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Zašto su bolovanja kolega posebno zaštićena?',
    options: [
      'Jer su u ugovoru o radu izričito označena kao povjerljiva',
      'Jer su poslovne tajne prema GeschGehG-u',
      'Jer su zdravstveni podaci posebne kategorije osobnih podataka '
          'prema Art. 9 DSGVO',
    ],
    correctIndex: 2,
    explanation: 'Zdravstveni podaci potpadaju pod Art. 9 DSGVO i '
        'podliježu strožoj zaštiti od običnih podataka. Već je sama '
        'činjenica bolesti takav podatak, razlog pogotovo. Poslovne se '
        'tajne, naprotiv, odnose na znanje tvrtke, a ne na zdravstvene '
        'podatke zaposlenika.',
  ),
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Želiš znati koje je podatke tvoj poslodavac o tebi '
        'pohranio. Koje pravo za to koristiš?',
    options: [
      'Pravo na prenosivost podataka prema Art. 20 DSGVO',
      'Pravo na pristup prema Art. 15 DSGVO',
      'Pravo na prigovor prema Art. 21 DSGVO',
    ],
    correctIndex: 1,
    explanation: 'Art. 15 DSGVO daje ti pravo na pregled podataka '
        'pohranjenih o tebi i njihovih svrha. Art. 20 odnosi se na '
        'izdavanje u prenosivom formatu, Art. 21 na prigovor protiv '
        'obrade — ni jedno ni drugo ne odgovara na pitanje što je '
        'uopće pohranjeno. Na zahtjev se u pravilu mora odgovoriti u '
        'roku od mjesec dana.',
  ),

  // ══════════════════════════ ds5 — Povreda podataka
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Koji od ovih događaja NIJE povreda podataka?',
    options: [
      'Paket si predao pogrešnom primatelju, koji ga je otvorio',
      'Krivo si se izbrojio kod broja povrata u dnevnom izvještaju',
      'Listu ture ostavio si otvorenu u nezaključanom vozilu',
    ],
    correctIndex: 1,
    explanation: 'Pogreška u brojanju povrata ne tiče se osobnih '
        'podataka i nikome ih ne čini dostupnima. U druga dva slučaja '
        'neovlaštene su osobe mogle saznati imena, adrese ili sadržaj '
        'pošiljaka — to je povreda zaštite osobnih podataka.',
  ),
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Što kaže rok od 72 sata iz Art. 33 DSGVO?',
    options: [
      'Tvrtka mora povredu podataka po mogućnosti u roku od 72 sata od '
          'saznanja prijaviti nadzornom tijelu',
      'Vozač ima 72 sata vremena prijaviti incident u tvrtki',
      'Pogođeni se moraju u roku od 72 sata žaliti tvrtki, inače im '
          'pravo propada',
    ],
    correctIndex: 0,
    explanation: 'Rok obvezuje tvrtku prema nadzornom tijelu i teče od '
        'trenutka saznanja. Upravo zato moraš prijaviti odmah — svaki '
        'sat koji čekaš nedostaje tvrtki. Bliska je zabluda čitati ta '
        '72 sata kao vlastiti vremenski okvir za vozača.',
  ),
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Navečer si primijetio da je paket završio kod pogrešnog '
        'primatelja i da je tamo otvoren. Što je ispravno?',
    options: [
      'Sutra ujutro neupadljivo ga pokupiti i ispravno dostaviti — time '
          'je pogreška otklonjena',
      'Spomenuti tek na sljedećem službenom razgovoru jer se ionako '
          'ništa više ne može promijeniti',
      'Još isti dan obavijestiti disponenta ili upravu i ništa ne '
          'poduzimati na svoju ruku',
    ],
    correctIndex: 2,
    explanation: 'Povreda podataka već postoji: strana je osoba saznala '
        'ime, adresu i sadržaj pošiljke. Tvrtka mora procijeniti, '
        'dokumentirati i po potrebi prijaviti prema Art. 33 DSGVO — za '
        'to joj informacija treba odmah. Tiha korekcija djeluje '
        'bezazleno, ali sprječava upravo te korake. Tko odmah prijavi, '
        'postupa ispravno.',
  ),

  // ══════════════════════════ ds6 — Povjerljivost i lojalnost
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'Koja izjava NIJE pokrivena slobodom mišljenja?',
    options: [
      'Izjava da se tura redovito ne može stići u planiranom vremenu',
      'Napomena da vozilo unatoč višekratnim prijavama nije '
          'popravljeno',
      'Svjesno neistinita tvrdnja da tvrtka sustavno vara svoje vozače '
          'kod sati',
    ],
    correctIndex: 2,
    explanation: 'Iznošenje mišljenja i istinita kritika zaštićeni su '
        'prema Art. 5 Abs. 1 GG, čak i kad su neugodni. Svjesno '
        'neistinite činjenične tvrdnje nisu: mogu opravdati izvanredni '
        'otkaz prema § 626 BGB, a kod klevete dodatno biti kažnjive '
        'prema § 186 StGB.',
  ),
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'Po najboljem znanju prijaviš nepravilnost u tvrtki. Na '
        'kraju se pokaže da tvoja sumnja nije bila točna. Što '
        'vrijedi?',
    options: [
      'Zaštita otpada retroaktivno jer je prijava bila pogrešna',
      'Ostaješ zaštićen od odmazde zakonom o zaštiti zviždača '
          '(HinSchG)',
      'Zaštita vrijedi samo ako si prijavu dodatno podnio i vanjskim '
          'putem',
    ],
    correctIndex: 1,
    explanation: 'HinSchG (od 2. srpnja 2023.) štiti zaposlenike koji '
        'prijave prekršaje od odmazde poput otkaza, opomene ili '
        'stavljanja u nepovoljniji položaj. Zaštita otpada samo kod '
        'svjesno ili krajnje nepažljivo netočnih prijava — ne kod '
        'ozbiljne sumnje koja se na kraju ne potvrdi. Vanjska prijava '
        'za to nije potrebna.',
  ),
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'U vozačkoj chat-grupi raspravlja se o navodnim '
        'smanjenjima plaće. I sam si nezadovoljan. Koji je ispravan '
        'put?',
    options: [
      'Navesti vlastiti, konkretan slučaj i predati ga disponentu, '
          'upravi ili internom mjestu za prijave',
      'Potvrditi tvrdnju u grupi kako bi kolege bili upozoreni',
      'Optužbu javno objaviti na portalu za recenzije kako bi se nešto '
          'pokrenulo',
    ],
    correctIndex: 0,
    explanation: 'Vlastiti, provjerljiv slučaj istinit je, objektivan i '
        'zaštićen HinSchG-om — a interno se i najbrže rješava. '
        'Potvrditi tvrdnju koju sam nisi doživio neistinita je '
        'činjenična tvrdnja; zatvorena chat-grupa pritom nije zaštićen '
        'prostor čim screenshot krene dalje. Izlazak van dolazi u '
        'obzir tek kad se interno ništa ne dogodi.',
  ),
];
