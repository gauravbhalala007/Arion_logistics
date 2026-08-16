// lib/data/safety_training/ride_along_content_hr.dart
//
// Sadržaj Ride Along obuke — hrvatska verzija.
// Struktura je istovjetna njemačkoj verziji (master): poglavlja ra1–ra5,
// iste folije, isti blokovi i iste vrijednosti.
//
// „Ride Along" je dvodnevna vožnja u pratnji za nove vozače: 1. dan s
// manjim brojem stajališta, 2. dan sa znatno više njih. Trener pritom
// prolazi kontrolnu listu, potvrđuje svaku točku i na kraju daje povratnu
// informaciju; list se kao fotografija predaje nadležnom disponentu.
//
// Svrha ove obuke: PRIPREMA. Tko je prije prođe, ne čuje teme tih dvaju
// dana prvi put, nego može ciljano pitati i svjesno iskoristiti vožnju u
// pratnji.
//
// Prilagođeno za više tvrtki: bez imena osoba, bez naziva stanica, bez
// brojki pojedine tvrtke kao pravila. Broj stajališta, vremena u Waiting
// Areji, početak rada i strana za parkiranje izričito su zadaci pojedine
// stanice — njih navodi trener. Alati tvrtke, poput evidencije radnog
// vremena, stoje samo kao primjer („npr. Kenjo"). Konkretni smiju
// ostati: Amazonovi alati (Flex, Mentor, ATLAS, Scorecard), aplikacija
// CoDriver, pravila o stankama prema § 4 ArbZG i Green Book prema
// § 1 st. 6 FPersV — sve troje vrijedi u svakoj tvrtki. Za ovu temu nema
// ilustracija, stoga `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> rideAlongContentHr = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ra1',
    title: 'Što je Ride Along',
    summary: 'Dva dana vožnje u pratnji: cilj, tijek, tko sudjeluje i '
        'kako se ocjenjuje',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Dva dana uz iskusnog vozača',
        blocks: [
          ParagraphBlock(
            'Ride Along je tvoja vožnja u pratnji za početak: dva radna '
            'dana u kojima je s tobom na putu iskusan vozač kao trener. '
            'Turu ne upoznaješ iz prezentacije, nego točno ondje gdje se '
            'odvija — u stanici, u Loading Areji i na cesti.',
          ),
          FactsBlock([
            FactItem('2 dana', 'vožnja u pratnji s trenerom'),
            FactItem('1. dan', 'manji broj stajališta — u mnogim tvrtkama '
                'oko 20'),
            FactItem('2. dan', 'znatno više stajališta — u mnogim tvrtkama '
                'oko 70'),
          ]),
          ParagraphBlock(
            'Ta se dva dana nadovezuju jedan na drugi. Prvog je dana '
            'težište na postupcima: kako se dolazi u stanicu, koje '
            'aplikacije pokrećeš i kada, kako se utovaruje, kada je '
            'stanka. Drugog dana količina znatno raste, a ti sam voziš i '
            'dostavljaš — trener te prati, ali ne preuzima.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Brojevi stajališta su okvirne vrijednosti',
            text: 'Koliko je stajališta stvarno predviđeno 1. i 2. dana '
                'određuje tvoja tvrtka, odnosno tvoja stanica. Raširena su '
                'oko 20 prvog i oko 70 drugog dana — obvezujući je ipak '
                'samo zadatak koji ti navede tvoj trener ili tvoj nadležni '
                'disponent.',
          ),
          BulletsBlock([
            'Oba dana teku preko tvojeg vlastitog računa, a ne preko '
                'trenerovog',
            'Stajališta se broje kao pravi rad, a ne kao suha vježba',
            'Trener objašnjava, pokazuje i zatim te pušta da sam radiš',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ukratko',
            text: 'Ride Along je tvoje uvođenje u pravi rad. Na kraju bi '
                'trebao moći sam odvoziti turu — to je mjerilo prema kojem '
                'se sve ravna.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tko sudjeluje i tko što radi',
        blocks: [
          ParagraphBlock(
            'U Ride Alongu sudjeluju tri uloge. Ako znaš tko je za što '
            'zadužen, ne pitaš pogrešnu osobu i ne gubiš vrijeme.',
          ),
          TableBlock(
            headers: ['Uloga', 'Zadatak'],
            rows: [
              [
                'Ti',
                'Voziš, dostavljaš, pitaš, sudjeluješ — oba dana preko '
                    'svojeg vlastitog računa',
              ],
              [
                'Trener',
                'Iskusan vozač: objašnjava svaku točku, pokazuje kako se '
                    'radi, promatra te, ispunjava kontrolnu listu i '
                    'potpisuje',
              ],
              [
                'Disponent',
                'Planira ta dva dana, kontakt je kod problema i na kraju '
                    'preuzima fotografiju kontrolne liste',
              ],
            ],
          ),
          ParagraphBlock(
            'Trener nije tvoj nadređeni ni tvoj ispitivač u smislu neke '
            'službe. On je kolega koji stanicu najbolje poznaje. Upravo je '
            'zato prava adresa za svako pitanje koje ti padne na pamet '
            'tijekom ta dva dana — i za ono koje ti se čini banalnim.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Pitanja ne koštaju ništa',
            text: 'Pitanje na Ride Alongu je jeftino. Isto pitanje u '
                'trećem tjednu, sam na turi, s punom rutom pred sobom, '
                'skupo je.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista i povratna informacija',
        blocks: [
          ParagraphBlock(
            'Trener prolazi zadani list — kontrolnu listu Ride Alonga. Na '
            'njoj za svaki od dvaju dana piše što mora biti objašnjeno i '
            'pokazano: od pregleda vozila preko pravila o stankama do '
            'paketa sa zaporkom. Svaka se točka potvrđuje, svaki se dan '
            'zaključuje datumom i potpisom.',
          ),
          BulletsBlock([
            'Kontrolna lista je dokaz da si bio uveden u posao',
            'Ona štiti i tebe: ono što je označeno tebi je objašnjeno',
            'Nakon drugog dana trener daje povratnu informaciju o učinku i '
                'vozačkim sposobnostima',
          ]),
          ParagraphBlock(
            'Nije to ispit s giljotinom. Nitko ne očekuje da prvog dana '
            'voziš turu kao vozač s tri godine iskustva. Ali se ocjenjuje: '
            'trener zapisuje kako radiš, a list ide tvrtki. Tko vidljivo '
            'razmišlja, dolazi na vrijeme i prihvaća upute, dobiva dobru '
            'povratnu informaciju — i ako je spor.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Razlika o kojoj je riječ',
            text: 'Ne ocjenjuje se znaš li sve, nego jesi li spreman učiti '
                'i shvaćaš li pravila ozbiljno. Pogreške su normalne. Da ti '
                'se pogreška objasni dvaput i da je svejedno ignoriraš — '
                'to nije.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: prvog dana dvaput zamijeniš '
                'redoslijed paketa na rolo-kontejneru i za svoja '
                'stajališta trebaš znatno dulje nego što je planirano. '
                'Siguran si da je Ride Along time propao. Je li to točno?',
            answer: 'Nije. Upravo zato postoji prvi dan. Trener tempo '
                'očekuje tek drugog dana, i to tek donekle, a zaista tek u '
                'tjednima nakon toga. Ono što on prvog dana ocjenjuje '
                'nešto je drugo: pitaš li kada nisi siguran? Radiš li istu '
                'pogrešku i treći put? Sortiraš li nakon toga sam od sebe '
                'urednije? Tko pogrešku spomene i kod sljedećeg '
                'rolo-kontejnera svjesno postupi drukčije, ostavlja bolji '
                'dojam nego netko tko je brz i ništa ne preispituje.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista: poglavlje 1',
        blocks: [
          ChecklistBlock(
            title: 'Ovo nosim iz poglavlja 1',
            items: [
              'Ride Along su dva radna dana s trenerom',
              '1. dan manje stajališta, 2. dan znatno više — točan broj '
                  'zadaje moja tvrtka (rašireno oko 20 i oko 70)',
              'Oba dana teku preko mojeg vlastitog računa',
              'Trener objašnjava, pokazuje i pušta me da sam radim',
              'On ispunjava kontrolnu listu i potpisuje za svaki dan',
              'Nakon 2. dana slijedi povratna informacija o učinku i '
                  'vozačkim sposobnostima',
              'To je uvođenje u posao, ali se ocjenjuje — spremnost na '
                  'učenje vrijedi više od tempa',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Jedna rečenica za ta dva dana',
            text: '„Radije pitam jednom previše nego jednom premalo — '
                'zbog toga i postoje ta dva dana."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ra2',
    title: 'Prvi dan',
    summary: 'Prva stajališta, pokretanje aplikacija, pregled, Loading '
        'Area, stanke i ključ vozila',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Prva stajališta preko tvojeg vlastitog računa',
        blocks: [
          ParagraphBlock(
            'Prvi dan ima najmanji broj stajališta koja bi trebao odvoziti '
            'i dostaviti — preko svojeg vlastitog računa. Namjerno je '
            'držan malim (u mnogim tvrtkama oko 20); obvezujući broj za '
            'tvoju stanicu navodi ti trener. Prvog dana nije riječ o '
            'količini, nego o tome da svaki zahvat jednom sjedne kako '
            'treba.',
          ),
          ParagraphBlock(
            'Važan je vlastiti račun. Ne trenerov, ne neki zajednički '
            'pristup. Sve što tog dana dostaviš ide pod tvojim imenom — '
            'točno onako kako će se poslije i brojiti. Samo tako trener i '
            'tvrtka vide kako tvoja dostava stvarno izgleda.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Bez pristupa nema Ride Alonga',
            text: 'Ako ti račun ujutro ne radi, reci to odmah — prije '
                'polaska, a ne na prvom stajalištu. Nerazjašnjen pristup '
                'košta cijeli dan.',
          ),
          SubheadBlock('Aplikacija CoDriver'),
          ParagraphBlock(
            'CoDriver je aplikacija tvrtke — aplikacija u kojoj upravo '
            'čitaš. Odvojena je od Amazonovih alata: Amazon vodi turu, '
            'CoDriver sve oko tvojeg rada u tvrtki. Trener je prvog dana '
            'prolazi s tobom.',
          ),
          BulletsBlock([
            'Raspored smjena i Wave-Plan: kada radiš i u kojem valu '
                'krećeš',
            'Prijava izostanaka i bolovanja',
            'DA Academy: obuke poput ove, uz to i radne upute',
            'Poruke i obavijesti tvrtke',
            'Prijave nezgoda i šteta',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Zapamti',
            text: 'Amazonove aplikacije vode turu. CoDriver vodi tvoj radni '
                'odnos. Oboje trebaš svaki dan i oboje se prvog dana mora '
                'jednom pogledati u cijelosti.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dolazak: radno vrijeme, strana za parkiranje, Waiting Area',
        blocks: [
          ParagraphBlock(
            'Dan ne počinje prvim stajalištem, nego dolaskom u stanicu. '
            'Tri stvari ti trener prvog dana stavlja posebno na srce, jer '
            'se ponavljaju svakog pojedinog radnog dana.',
          ),
          SubheadBlock('1 — Radno vrijeme'),
          ParagraphBlock(
            'Tvoja smjena ima čvrst početak. Piše u rasporedu smjena u '
            'CoDriveru, a „početak" znači: u to si vrijeme spreman za rad '
            'u stanici — a ne na putu prema njoj. Konkretna vremena tvoje '
            'stanice navodi ti trener, razlikuju se ovisno o lokaciji i '
            'valu.',
          ),
          SubheadBlock('2 — Strana za parkiranje'),
          ParagraphBlock(
            'Svaka stanica ima pravilo gdje smiju stajati privatna vozila '
            'i s koje se strane postrojavaju kombiji. To nije šikaniranje: '
            'u dvorištu istodobno manevrira mnogo vozila, često unatrag i '
            'sa slabom preglednošću. Tko krivo parkira, blokira prolaz ili '
            'stoji u mrtvom kutu nekoga tko manevrira. Trener ti pokazuje '
            'stranu koja vrijedi za tebe.',
          ),
          SubheadBlock('3 — Vremena u Waiting Areji'),
          ParagraphBlock(
            'Waiting Area je područje u kojem čekaš dok se ne prozove tvoj '
            'rolo-kontejner ili tvoja pozicija za utovar. Za to postoje '
            'čvrsti vremenski okviri po valu. Tko ondje stoji prerano, '
            'zakrčuje područje; tko dođe prekasno, propušta svoj poziv i '
            'gura cijeli val unatrag. Točna vremena za tvoju stanicu '
            'navodi ti trener prvog dana — zapiši ih.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Tri podatka koja bi si trebao zapisati',
            text: 'Početak smjene, strana za parkiranje i tvoj termin u '
                'Waiting Areji. Ta tri podatka trebaš od sljedećeg dana '
                'svako jutro — i onda te više nitko ne pita.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: na vrijeme si na ulazu za početak '
                'smjene, ali ti onda treba deset minuta za parkirno '
                'mjesto, jer si tražio na pogrešnoj strani. U Waiting Areju '
                'time dolaziš prekasno. Koliko je to loše?',
            answer: 'Gore nego što izgleda. Poziv u Waiting Areji ide u '
                'taktu: ako propustiš svoj termin, kliznuo si iza ostalih '
                'vozača svojeg vala. Tvoj rolo-kontejner čeka, tvoje vozilo '
                'pritom možda blokira neku poziciju, a tvoj se start '
                'pomiče za više od tih deset minuta koje si izgubio. Zato '
                'strana za parkiranje i vrijeme u Waiting Areji idu '
                'zajedno: „na vrijeme na ulazu" nije isto što i „na '
                'vrijeme u Waiting Areji". Uračunaj vrijeme za parkiranje '
                'i hodanje.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Start: evidencija radnog vremena, Mentor i Flex',
        blocks: [
          ParagraphBlock(
            'Tri sustava moraju raditi na početku smjene — i to na vrijeme '
            'i tim redoslijedom. Svaki ima drugu svrhu i svaki izaziva '
            'nevolje ako se pokrene prekasno.',
          ),
          StepsBlock([
            'Evidencija radnog vremena tvoje tvrtke (npr. Kenjo) — prijava '
                'na početku smjene. Što ovdje ne pokreneš, nije plaćeno '
                'radno vrijeme i poslije nedostaje u tvojem obračunu. Koji '
                'sustav tvoja tvrtka koristi, pokazuje ti trener.',
            'Mentor — Amazonova aplikacija za način vožnje: mora raditi '
                'prije nego što kreneš. Ona bilježi tvoj način vožnje i '
                'daje podatke za tvoj rezultat.',
            'Flex — Amazonova aplikacija za dostavu: ovdje dobivaš svoju '
                'rutu, skeniraš pakete i dokumentiraš svaku dostavu.',
          ]),
          SubheadBlock('Četiri sata aplikacije Mentor'),
          ParagraphBlock(
            'Mentor ne radi neograničeno: aplikacija svaki put bilježi oko '
            'četiri sata u komadu. Nakon toga je moraš ponovno pokrenuti, '
            'inače ostatak tvoje ture ostaje nezabilježen. Upravo je to '
            'najčešća početnička pogreška — aplikacija je ujutro ispravno '
            'pokrenuta, ali nakon podnevne stanke nije ponovno aktivirana. '
            'Trener ti prvog dana pokazuje po čemu prepoznaješ da Mentor '
            'još radi.',
          ),
          FactsBlock([
            FactItem('4 h', 'trajanje bilježenja aplikacije Mentor u '
                'komadu'),
            FactItem('prije polaska', 'pokreni Mentor — a ne tek usput'),
            FactItem('nakon stanke', 'provjeri Mentor i ponovno ga '
                'pokreni'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Najčešća pogreška prvog dana',
            text: 'Flex radi, Mentor ne. Onda doduše voziš svoju rutu, ali '
                'se tvoj način vožnje ne bilježi — a nedostajuće vrijeme u '
                'Mentoru u tvrtki pada u oči jednako kao i loša vrijednost.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: u 14 sati primijetiš da Mentor od '
                'stanke više ne radi. Što činiš — voziš dalje do kraja '
                'radnog dana pa sutra bolje, ili reagiraš odmah?',
            answer: 'Reagiraš odmah: staneš na sljedećem sigurnom mjestu, '
                'ponovno pokreneš Mentor, voziš dalje. Zabluda koja se '
                'nameće jest misliti da je pola dana bez bilježenja '
                'svejedno, jer si ionako vozio uredno. Nije: za tvrtku '
                'rupa izgleda kao rupa — a ne kao dobra vožnja. A voziti '
                'dalje znači svakim satom činiti rupu većom. Javi to '
                'dodatno svojem treneru ili svojem nadležnom disponentu, '
                'kako bi rupa bila objašnjiva.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pregled vozila i Loading Area',
        blocks: [
          SubheadBlock('Pregled vozila'),
          ParagraphBlock(
            'Prije nego što kreneš, vozilo se provjerava — i nakon ture '
            'još jednom. Pregled je vizualna provjera s dokumentiranjem: '
            'jednom obiđeš kombi, pogledaš svaku stranu, provjeriš funkcije '
            'i zabilježiš što vidiš.',
          ),
          BulletsBlock([
            'Vanjski obilazak: karoserija, branici, zrcala, stakla — svaka '
                'udubina i svaka ogrebotina',
            'Gume: profil, vidljiva oštećenja, dojam o tlaku',
            'Svjetla: kratka svjetla, kočna svjetla, pokazivači smjera, '
                'svjetlo za vožnju unatrag',
            'Kabina i teretni prostor: čistoća, slobodni dijelovi, '
                'pregradna stijenka',
            'Oprema: sigurnosni trokut, sigurnosni prsluk, kutija prve '
                'pomoći',
            'Stanje brojača kilometara i razina goriva odnosno napunjenosti',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Zašto se pregled PRIJE vožnje računa',
            text: 'Šteta koju prije dokumentiraš je ranija šteta. Ista '
                'šteta koju ne dokumentiraš navečer je tvoja šteta. Te dvije '
                'minute obilaska najjeftinije su osiguranje tvojeg radnog '
                'dana.',
          ),
          SubheadBlock('Utovar rolo-kontejnera u Loading Areji'),
          ParagraphBlock(
            'U Loading Areji stoji tvoj rolo-kontejner s paketima tvoje '
            'rute. Kako ga posložiš u kombi, odlučuje o cijelom tvojem '
            'danu: tko utovari nesortirano, traži na svakom stajalištu — a '
            'to se tijekom pune ture zbroji u sate.',
          ),
          BulletsBlock([
            'Utovaruj redoslijedom rute: što prvo mora van, ulazi zadnje '
                'i leži sprijeda',
            'Teški paketi dolje, lagani gore — a ne obrnuto',
            'Osiguraj teret: ništa ne smije pri kočenju kliznuti naprijed',
            'Ništa ne slaži u prolaz ni pred klizna vrata',
            'Posebne pakete (zaporka, ATLAS, glomazno) položi odvojeno i '
                'nadohvat ruke',
            'Prazan rolo-kontejner vrati onamo gdje pripada — a ne bilo '
                'gdje',
          ]),
          DoDontBlock(
            doTitle: 'Ovako radiš ispravno',
            dos: [
              'Već pri utovaru misli na to koje je stajalište prvo',
              'Pri podizanju idi u koljena, teret drži blizu tijela',
              'Pitaj kada ne znaš kamo neki paket ide',
            ],
            dontTitle: 'Ovo te poslije košta vremena',
            donts: [
              'Sve nabacati unutra i „sortirati usput"',
              'Stavljati pakete na pregradnu stijenku ili u vozačev '
                  'prostor',
              'Ostaviti rolo-kontejner nasred prolaza',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Stanke, ključ i automatsko zaključavanje',
        blocks: [
          SubheadBlock('Stanke: 30 i 45 minuta'),
          ParagraphBlock(
            'Postoje dvije duljine stanke, a koja vrijedi za tebe ovisi '
            'isključivo o tvojem radnom vremenu tog dana. Za razliku od '
            'vremena u Waiting Areji ili broja stajališta, to nije zadatak '
            'tvoje stanice, nego zakon: § 4 Arbeitszeitgesetz (ArbZG — '
            'njemački zakon o radnom vremenu). Pravilo time vrijedi jednako '
            'u svakoj tvrtki i o njemu se ne pregovara.',
          ),
          FactsBlock([
            FactItem('30 min', 'kod više od 6 do 9 sati radnog vremena'),
            FactItem('45 min', 'kod više od 9 sati radnog vremena'),
            FactItem('15 min', 'najmanji dio stanke koji se priznaje'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 4 ArbZG — pravna osnova',
            text: 'Njemački zakon o radnom vremenu propisuje kod više od 6 '
                'sati radnog vremena najmanje 30 minuta odmora, a kod više '
                'od 9 sati najmanje 45 minuta. Raditi dulje od 6 sati bez '
                'stanke izričito je zabranjeno.',
          ),
          ParagraphBlock(
            'Stanka se smije podijeliti, ali svaki dio mora trajati '
            'najmanje 15 minuta — dvaput po 15 minuta daje dakle stanku od '
            '30, triput po 15 minuta onu od 45. Pet minuta usput se ne '
            'broji. Osim toga je važno: stanka mora započeti prije isteka '
            'šest sati rada, a ne tek na kraju smjene.',
          ),
          ParagraphBlock(
            'Zašto se mora evidentirati: tvoja stanka nije plaćeno radno '
            'vrijeme, a tvrtka mora moći dokazati da si je stvarno '
            'iskoristio. Zato se upisuje u evidenciju radnog vremena — ne '
            'iz nepovjerenja, nego zato što se nedokumentirana stanka pri '
            'nadzoru smatra neiskorištenom stankom. To je prekršaj za koji '
            'odgovara tvrtka. Trener ti pokazuje gdje je točno upisuješ.',
          ),
          SubheadBlock('Automatsko zaključavanje i ključ'),
          ParagraphBlock(
            'Mnogi se Sprinteri zaključavaju automatski: zalupe li se '
            'vrata ili vozilo krene, centralna se brava zatvara sama. To je '
            'zaštita tvojeg tereta od krađe — i upravo je to razlog zašto '
            'ključ uvijek ostaje uza te.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Ključ ide na tvoje tijelo',
            text: 'Ne na sjedalo, ne u pretinac, ne u džep jakne koja leži '
                'u vozilu. Ključ u džep hlača ili na traku na tvojem pojasu '
                '— svaki put kada izlaziš.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: nakratko staneš, ostaviš ključ u '
                'bravi, uzmeš dva paketa i nogom zatvoriš klizna vrata. '
                'Centralna se brava zaključava. Što se sada događa?',
            answer: 'Stojiš s dva paketa pred zaključanim kombijem u kojem '
                'su tvoj ključ, tvoj mobitel, ostatak tereta i najčešće i '
                'tvoji dokumenti. Dan je time propao: trebaš pomoć iz '
                'stanice ili bravara, cijela ti ruta stoji, a paketi u '
                'vozilu danas više ne stižu svojim kupcima. Zabluda koja se '
                'nameće jest „pa nema me samo deset sekundi" — automatsko '
                'zaključavanje ne razlikuje deset sekundi od deset minuta. '
                'Zato bez iznimke vrijedi: ključ van, ključ na tijelo, tek '
                'onda izlaziš.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kraj ture: zatvaranje Flexa i pregled',
        blocks: [
          ParagraphBlock(
            'Dan ne završava na zadnjem stajalištu, nego u stanici. Dvije '
            'stvari ondje stoje na trenerovoj kontrolnoj listi — i obje se '
            'rado zaboravljaju, jer si umoran i želiš kući.',
          ),
          StepsBlock([
            'Uredno zatvori aplikaciju Flex: zaključi rutu, predaj povrate '
                'i izađi iz aplikacije — a ne samo spremi mobitel.',
            'Pregled vozila nakon vožnje: isti obilazak kao ujutro, sada s '
                'pogledom na nova oštećenja, stanje brojača kilometara i '
                'razinu goriva odnosno napunjenosti.',
            'Predaj vozilo čisto i prazno, provjeri teretni prostor — '
                'nijedan paket ne ostaje unutra.',
            'Odjavi se u evidenciji radnog vremena tvoje tvrtke (npr. '
                'Kenjo) i predaj ključ ondje gdje pripada.',
          ]),
          ParagraphBlock(
            'Završni je pregled protuteža pregledu ujutro. Tek je kroz oba '
            'zajedno jasno što se tog dana na vozilu dogodilo — a što nije. '
            'Nedostaje li onaj navečer, šteta se sljedećeg jutra više '
            'nikome ne može pripisati, a sljedeći vozač preuzima tvoj '
            'problem ili ti njegov.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Pravilo za kraj radnog dana',
            text: 'Flex zatvoren, krug oko vozila, teretni prostor prazan, '
                'odjavljen, ključ predan. Tek je onda kraj radnog dana.',
          ),
          ChecklistBlock(
            title: 'Ovo nosim iz 1. dana',
            items: [
              'Broj stajališta koji zadaje moja tvrtka, preko mojeg '
                  'vlastitog računa',
              'Poznajem aplikaciju CoDriver i znam što u njoj nalazim',
              'Znam početak svoje smjene, pravilo parkiranja svoje stanice '
                  'i svoj termin u Waiting Areji',
              'Pokrećem evidenciju radnog vremena (npr. Kenjo), Mentor i '
                  'Flex na vrijeme i tim redoslijedom',
              'Znam da Mentor bilježi oko 4 sata i da se nakon toga mora '
                  'ponovno pokrenuti',
              'Pregled vozila radim prije i nakon ture',
              'Rolo-kontejner utovarujem redoslijedom rute, teško dolje, '
                  'teret osiguran',
              'Poznajem pravilo o stanci prema § 4 ArbZG: 30 minuta od '
                  'više od 6 sati, 45 minuta od više od 9 sati — i '
                  'upisujem je',
              'Ključ uvijek ostaje na tijelu, jer se Sprinter zaključava '
                  'automatski',
              'Na kraju zatvaram Flex, radim pregled i odjavljujem se',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ra3',
    title: 'Drugi dan',
    summary: 'Znatno više stajališta samostalno, Scorecard, zaštita '
        'vozila, Green Book, posebni paketi, gorivo i punjenje',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Znatno više stajališta — ti voziš, ti dostavljaš',
        blocks: [
          ParagraphBlock(
            'Drugog se dana odnos okreće. Broj stajališta znatno raste — u '
            'mnogim tvrtkama na oko 70, obvezujući je zadatak tvoje '
            'stanice — a ti stajališta obavljaš samostalno: ti voziš, ti '
            'navigiraš, ti skeniraš, ti dostavljaš, ti dokumentiraš. Trener '
            'sjedi pokraj tebe i uskače samo ako je potrebno.',
          ),
          FactsBlock([
            FactItem('više', 'stajališta nego 1. dana — broj prema '
                'zadatku tvrtke'),
            FactItem('sam', 'vožnja i dostava — trener samo prati'),
            FactItem('1 dan', 'do prve vlastite ture'),
          ]),
          ParagraphBlock(
            'To je pravi smisao drugog dana: trebao bi jednom doživjeti '
            'kako se puna tura osjeća — s tempom, sa sortiranjem usput, s '
            'kupcima koji ne otvaraju i s osjećajem da sat teče. Ako si to '
            'jednom prošao s nekim uz sebe, prvi je samostalni izlazak '
            'upola manji.',
          ),
          BulletsBlock([
            'Ne daj da ti netko preuzme ono što možeš sam — i ako ide '
                'sporije',
            'Pitaj odmah nakon svakog stajališta koje ti se učinilo čudnim',
            'Zapamti što si moraš zapisati: kodove, postupke, kontakte',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Mjerilo 2. dana',
            text: 'Ne „hoće li turu odraditi u rekordnom vremenu", nego '
                '„bi li ga se sutra moglo poslati samog". Upravo to trener '
                'procjenjuje.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Scorecard, kvaliteta i učinak',
        blocks: [
          ParagraphBlock(
            'Tvoj se rad mjeri. Amazonov Scorecard tjedan za tjednom '
            'sažima kako ste vozili ti i tvoja tvrtka. Drugog ti dana '
            'trener objašnjava koje vrijednosti u njemu stoje i kako na '
            'njih utječeš — jer gotovo svaka vrijednost nastaje iz nečega '
            'što ti sam držiš u rukama.',
          ),
          BulletsBlock([
            'Kvaliteta dostave: je li paket predan ili odložen na pravom '
                'mjestu i uredno dokumentiran?',
            'Način vožnje iz Mentora: kočenje, ubrzavanje, zavoji, '
                'korištenje mobitela, vezanje pojasa',
            'Pouzdanost: točan start, u cijelosti odvožena ruta, ispravan '
                'povrat',
            'Povratne informacije kupaca: pritužbe i pohvale također '
                'završavaju u ocjeni',
          ]),
          ParagraphBlock(
            'Kvaliteta i učinak pritom su dvije različite stvari koje se '
            'često zamjenjuju. Učinak je količina: koliko stajališta u '
            'kojem vremenu. Kvaliteta je koliko je uredno zaključeno svako '
            'pojedino stajalište. Vozač s visokim učinkom i lošom '
            'kvalitetom uzrokuje više posla nego što ga uštedi — svaka '
            'reklamacija tvrtku košta višestruko više od minute koja je '
            'sprijeda ušteđena.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Najskuplja je pogreška brza pogreška',
            text: 'Paket ostavljen na krivom mjestu i brza vožnja dalje '
                'štede ti minutu, a tvrtku koštaju reklamacije, izvida i u '
                'krajnjem slučaju vrijednosti robe.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: kupac ne otvara, pred tobom je još '
                '30 stajališta. Paket odložiš iza kante za smeće i brzo '
                'fotografiraš ulazna vrata. Zašto je to problem?',
            answer: 'Dvostruko. Prvo, mjesto odlaganja ne odgovara onome '
                'što si dokumentirao — ne nađe li kupac paket, tvoja '
                'dostava stoji kao nepotkrijepljena. Drugo, odlaganje iza '
                'kante za smeće nije prikladno mjesto: vidljivo je s ceste, '
                'a kanta se prazni. Ispravno je poći predviđenim putem — '
                'susjed, sigurno mjesto odlaganja uz suglasnost kupca ili '
                'povrat — i dokumentirati točno ono što si stvarno učinio. '
                'Ta jedna ušteđena minuta stoji nasuprot reklamaciji koja '
                'tebe, kupca i tvrtku košta znatno više.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Zaštita vozila, nezgode, čišćenje i održavanje',
        blocks: [
          ParagraphBlock(
            'Kombi je tvoje radno mjesto i najskuplji alat koji ti tvrtka '
            'povjerava. Kako s njim postupaš, drugog je dana zasebna točka '
            'na kontrolnoj listi — u tri dijela.',
          ),
          SubheadBlock('1 — Izbjegavanje šteta'),
          BulletsBlock([
            'Vožnja unatrag samo kada drukčije ne ide — i tada polako, uz '
                'pogled kroz oba zrcala',
            'Kod nejasne situacije izađi i pogledaj, umjesto da nagađaš',
            'Uski ulazi, niske grane, podzemne garaže i stupići najčešći '
                'su izvori šteta',
            'Drži razmak i koči predviđajući — to istodobno čuva vozilo i '
                'Scorecard',
          ]),
          SubheadBlock('2 — Ako se ipak nešto dogodi'),
          StepsBlock([
            'Stani, osiguraj mjesto: sva četiri žmigavca, sigurnosni '
                'prsluk, sigurnosni trokut.',
            'Zbrini ozlijeđene, kod ozljeda osoba uvijek zovi 112.',
            'Ništa ne mijenjaj, fotografiraj: cjelokupnu situaciju, '
                'štete, registarske oznake, okolinu.',
            'Kod tuđeg vozila ili nejasne krivnje pozovi policiju — i kod '
                'malih šteta.',
            'Odmah obavijesti svojeg nadležnog disponenta i prijavi '
                'događaj u CoDriveru.',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Nikada ne vozi dalje',
            text: 'I mala ogrebotina na tuđem vozilu bez prijave je '
                'bijeg s mjesta nesreće — kazneno djelo. Ceduljica ispod '
                'brisača pravno nije dovoljna.',
          ),
          SubheadBlock('3 — Čišćenje i održavanje'),
          BulletsBlock([
            'Kabinu svakodnevno isprazni: bez smeća, bez boca, bez papira',
            'Teretni prostor pometi i provjeri ima li zaboravljenih paketa',
            'Stakla i zrcala drži čistima — loša je preglednost sigurnosni '
                'problem, a ne estetska sitnica',
            'Pogonske tekućine i neobične zvukove prijavi, nemoj ih '
                'ignorirati',
          ]),
          RevealBlock(
            prompt: 'Primjer iz prakse: pri manevriranju okrzneš stupić. Na '
                'vozilu je ogrebotina, inače ništa, nitko nije vidio. '
                'Prijavljuješ li to?',
            answer: 'Da, uvijek i još istog dana. Nije riječ o krivnji, '
                'nego o pripisivanju: prijavljena je ogrebotina događaj '
                'koji se obrađuje. Ista ogrebotina, koju sljedećeg jutra '
                'drugi vozač nađe pri svojem pregledu, nerazjašnjena je '
                'šteta — a to postaje neugodno za sve uključene, pa i za '
                'tebe, jer se sumnja na kraju ipak usmjerava na posljednjeg '
                'korisnika. Zabluda koja se nameće jest „to se neće '
                'primijetiti". Primijetit će se pri sljedećem pregledu, '
                'zbog toga on i postoji.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Green Book / knjiga kontrole',
        blocks: [
          ParagraphBlock(
            'Green Book je tvoja knjiga kontrole vožnji: dnevni kontrolni '
            'listovi prema § 1 st. 6 Fahrpersonalverordnung (FPersV — '
            'njemačka uredba o vozačkom osoblju), kojima dokazuješ svoja '
            'vremena vožnje, prekide vožnje i vremena odmora. Ni to nije '
            'pravilo tvoje stanice, nego važeće pravo o vozačkom osoblju — '
            'vrijedi jednako u svakoj tvrtki. Izričito nije provjera '
            'vozila: u Green Booku radi se isključivo o vremenima, o '
            'tvojim vremenima.',
          ),
          BulletsBlock([
            'Jedan list po radnom danu, vođen rukom i potpisan',
            'Upisuju se početak i kraj vožnje, stanja brojača kilometara, '
                'vremena vožnje, prekidi i vremena odmora',
            'Ispunjava se odmah, a ne rekonstruira navečer po sjećanju',
            'Zapisi posljednjih dana nose se sa sobom i moraju se pri '
                'nadzoru predočiti',
          ]),
          ParagraphBlock(
            'Trener ti drugog dana pokazuje gdje list stoji, kako se '
            'ispunjava i gdje se gotovi listovi predaju. Sve ostalo ne '
            'stoji ovdje: u DA Academy za to postoji zasebna obuka „Green '
            'Book" — s obveznim podacima, vremenima vožnje i odmora, '
            'obvezom nošenja i posljedicama kod prekršaja. Prođi je, '
            'umjesto da si detalje želiš zapamtiti drugog dana u vozilu.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Sam je zapis obveza',
            text: 'Jesi li se držao vremena, pri nadzoru nitko ne može '
                'utvrditi ako ništa ne postoji. List koji nedostaje zato je '
                'jednako prekršaj kao i prekoračeno vrijeme vožnje.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Posebni slučajevi: paketi sa zaporkom i ATLAS paketi',
        blocks: [
          SubheadBlock('Paketi sa zaporkom'),
          ParagraphBlock(
            'Neke se pošiljke smiju predati samo uz zaporku ili kod koji je '
            'kupac prethodno dobio. Tipična je vrijedna roba i sve što je '
            'posebno izloženo krađi. Flex te na stajalištu na to upozorava.',
          ),
          BulletsBlock([
            'Kupac ti kod izgovara ili pokazuje — ti ga ne čitaš naglas i '
                'ne izgovaraš prvi',
            'Bez ispravnog koda nema predaje: nema iznimke, ni kod susjeda',
            'Nema odlaganja pred vratima ni ostavljanja u hodniku zgrade',
            'Ne odgovara li kod, pošiljka se predviđenim putem vraća i '
                'dokumentira',
          ]),
          SubheadBlock('ATLAS paketi'),
          ParagraphBlock(
            'ATLAS pošiljke također su posebno tretirani paketi: slijede '
            'vlastiti postupak s dodatnim koracima pri skeniranju i '
            'predaji. Za tebe je važno da ih prepoznaš, da ih odvojeno i '
            'nadohvat ruke odložiš i da zadani postupak ne skraćuješ. Kako '
            'postupak u tvojoj stanici konkretno izgleda i koje ti korake '
            'Flex pritom zadaje, pokazuje ti trener drugog dana na pravom '
            'paketu.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Posebne pakete posloži prve',
            text: 'Nijednu od tih dviju vrsta paketa ne želiš tražiti na '
                'stajalištu ispod 90 drugih pošiljaka. Pri utovaru ih '
                'svjesno položi odvojeno i zapamti njihov položaj.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: kupac je tu, ali nema zaporku pri '
                'ruci — „pa to je samo formalnost, potpisat ću vam sve '
                'što treba". Što činiš?',
            answer: 'Ne predaješ. Zaporka je dokaz da je primatelj stvarno '
                'primatelj — upravo je zato dodijeljena. Potpis, osobna '
                'iskaznica koju ne smiješ provjeravati ili lijepo '
                'nagovaranje ne zamjenjuju je. Zabluda koja se nameće jest '
                'staviti ljubaznost iznad postupka: bude li pošiljka '
                'poslije prijavljena kao neprimljena, predaja bez koda '
                'ostaje kao pogreška na tvoje ime. Zamoli kupca da kod '
                'potraži u potvrdi narudžbe. Ne nađe li ga, paket nosiš '
                'natrag sa sobom i to ispravno dokumentiraš.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Gorivo, punjenje i kraj ture',
        blocks: [
          SubheadBlock('Točenje goriva'),
          ParagraphBlock(
            'Kombi se toči prema pravilima tvrtke: na predviđenim '
            'postajama, karticom za gorivo tog vozila i ispravnim gorivom. '
            'Račun pripada vozilu ili se predaje ondje gdje ti trener '
            'pokaže. Kada točiš, ovisi o jednostavnom pravilu: ne tek kada '
            'se upali lampica rezerve, nego tako da sljedeći vozač ne mora '
            'krenuti s gotovo praznim spremnikom.',
          ),
          BulletsBlock([
            'Ispravna vrsta goriva — pogrešno točenje obustavlja vozilo '
                'danima',
            'Kartica za gorivo pripada vozilu, a ne tvojoj privatnoj torbi',
            'Račun sačuvaj i predaj kako je zadano',
            'Motor ugašen, ne puši, mobitel na stranu kod točionika',
          ]),
          SubheadBlock('Električno punjenje'),
          ParagraphBlock(
            'Kod električnog vozila punjenje stupa na mjesto točenja '
            'goriva — uz jednu važnu razliku: punjenje traje dulje i zato '
            'se mora planirati. Trener ti pokazuje gdje se puni, koji kabel '
            'pripada vozilu i koju razinu napunjenosti vozilo mora imati na '
            'kraju smjene.',
          ),
          BulletsBlock([
            'Drži razinu napunjenosti na oku i planiraj na vrijeme, a ne '
                'da reagiraš tek kod preostalog dosega',
            'Nakon priključivanja provjeri je li punjenje stvarno '
                'započelo',
            'Kabel uredno namotaj i ne ostavljaj mjesta za spoticanje',
            'Na kraju smjene predaj vozilo onako kako tvrtka zadaje — '
                'sljedeći vozač s njim kreće',
          ]),
          SubheadBlock('Kraj ture — kao 1. dana'),
          StepsBlock([
            'Uredno zatvori aplikaciju Flex, zaključi rutu, predaj '
                'povrate.',
            'Pregled vozila nakon vožnje: obilazak, nova oštećenja, stanje '
                'brojača kilometara, razina goriva odnosno napunjenosti.',
            'Teretni prostor prazan i čist, kabina pospremljena.',
            'Odjava, predaja ključa, dovršavanje Green Booka.',
          ]),
          ChecklistBlock(
            title: 'Ovo nosim iz 2. dana',
            items: [
              'Znatno veći broj stajališta koji zadaje moja tvrtka — koja '
                  'sam vozim i dostavljam',
              'Znam što stoji u Scorecardu i kako na njega utječem',
              'Kvaliteta nije isto što i učinak — vrijedi oboje',
              'Aktivno izbjegavam štete i svaki događaj odmah prijavljujem',
              'Vozilo držim čistim iznutra i izvana',
              'Poznajem Green Book prema § 1 st. 6 FPersV i za njega radim '
                  'zasebnu obuku u DA Academy',
              'Pakete sa zaporkom izdajem samo uz ispravan kod',
              'ATLAS pakete prepoznajem i slijedim zadani postupak',
              'Poznajem pravila za točenje goriva i za električno punjenje',
              'Na kraju: zatvoriti Flex, pregled, odjava',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ra4',
    title: 'Završetak i predaja',
    summary: 'Trenerova povratna informacija, potpisi po danu i predaja '
        'lista kao fotografije',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Trenerova povratna informacija',
        blocks: [
          ParagraphBlock(
            'Nakon drugog dana trener sjeda s tobom i daje povratnu '
            'informaciju o tvojem učinku i tvojim vozačkim sposobnostima. '
            'To nije presuda u dvije riječi, nego procjena: što već ide '
            'glatko, na čemu moraš raditi, na što u sljedećim tjednima '
            'trebaš posebno paziti.',
          ),
          BulletsBlock([
            'Način vožnje: smirenost, predviđanje, vožnja unatrag, '
                'snalaženje na uskim mjestima',
            'Dostava: pažljivost, dokumentiranje, ophođenje s kupcima',
            'Organizacija: sortiranje, osjećaj za vrijeme, rad s '
                'aplikacijama',
            'Radni stav: točnost, postavljanje pitanja, prihvaćanje uputa',
          ]),
          ParagraphBlock(
            'Shvati povratnu informaciju ozbiljno, ali ne osobno. To je '
            'jedina prilika u kojoj te netko puna dva dana gledao. Pitaj '
            'kada ti je neka točka nejasna, i pitaj konkretno: „Što točno '
            'da radim drukčije pri vožnji unatrag?" donosi ti više nego '
            'kimanje glavom.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Jedno pitanje na kraju',
            text: 'Pitaj svojeg trenera na kraju: „Koja je ta jedna stvar '
                'na koju u svojem prvom tjednu sam trebam posebno '
                'paziti?" Odgovor je ono najvrjednije iz ta dva dana.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: u povratnoj informaciji stoji da si '
                'prekolebljiv pri manevriranju i da time gubiš vrijeme. Ti '
                'smatraš da si jednostavno bio oprezan. Kako s time '
                'postupaš?',
            answer: 'Pitaj umjesto da se opravdavaš. Oprez pri '
                'manevriranju je ispravan — trener pod „kolebljiv" u '
                'pravilu misli nešto drugo: da dugo razmišljaš umjesto da '
                'izađeš i kratko pogledaš, ili da više puta zauzimaš '
                'položaj ondje gdje bi bilo dovoljno jednom se vratiti uz '
                'pogled kroz oba zrcala. Zamoli za konkretan primjer iz tog '
                'dana. Onda imaš točku na kojoj stvarno možeš raditi, '
                'umjesto ocjene koju samo prokimaš ili odbiješ.',
          ),
        ],
      ),
      SafetySlide(
        title: 'List: datum, imena, potpisi',
        blocks: [
          ParagraphBlock(
            'Kontrolna lista Ride Alonga potpuna je tek kada su podaci u '
            'zaglavlju točni. Bez njih je list papir s kvačicama i ne može '
            'se pripisati nikakvom dokazu.',
          ),
          TableBlock(
            headers: ['Podatak', 'Što se pod time misli'],
            rows: [
              ['Datum', 'Upisan odvojeno za svaki od dvaju dana'],
              ['Ime polaznika', 'Tvoje ime — novi vozač'],
              ['Ime instruktora', 'Ime tvojeg trenera'],
              [
                'Potpis',
                'Od trenera, odvojeno po danu — a ne jednom za oba dana',
              ],
            ],
          ),
          ParagraphBlock(
            'To što se potpisuje po danu ima razlog: svaki dan ima svoj '
            'popis točaka. Otkaže li drugi dan ili se pomakne, ipak je '
            'uredno dokumentirano što je prvog dana obavljeno. Zato na '
            'kraju svakog dana sam provjeri jesu li datum i potpis '
            'upisani.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Pogledaj i sam',
            text: 'List je dokaz tvojeg uvođenja u posao. Nedostaje li '
                'potpis, nedostaje dokaz — a naknadno je takvo što uvijek '
                'mukotrpno. Dovoljan je jedan pogled prije kraja radnog '
                'dana.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Predaja: fotografija disponentu',
        blocks: [
          ParagraphBlock(
            'Na kraju drugog dana ispunjeni se list kao fotografija predaje '
            'tvojem nadležnom disponentu. Time je Ride Along formalno '
            'zaključen i tvoje je uvođenje u posao dokumentirano.',
          ),
          StepsBlock([
            'Položi list na ravnu podlogu, potraži dobro svjetlo.',
            'Fotografiraj odozgo, cijeli list u kadru, bez sjena i bez '
                'odrezanih rubova.',
            'Provjeri jesu li kvačice, datum, imena i potpisi čitljivi.',
            'Predaj fotografiju nadležnom disponentu — putem koji vam '
                'navede trener.',
            'S papirnatim listom postupaj kako tvoja tvrtka zadaje: može '
                'se zatražiti.',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Nečitljivo je kao nepredano',
            text: 'Mutna ili napola odrezana fotografija mora se ponoviti — '
                'a tada ste možda obojica već kod kuće. Pogledaj je jednom '
                'prije nego što je pošalješ.',
          ),
          ChecklistBlock(
            title: 'Ovo nosim iz završetka',
            items: [
              'Nakon 2. dana trener daje povratnu informaciju o učinku i '
                  'vozačkim sposobnostima',
              'Kod nejasnih točaka pitam konkretno',
              'Na listu stoje datum, ime polaznika i ime instruktora',
              'Trener potpisuje odvojeno po danu',
              'Na kraju svakog dana sam provjeravam je li sve upisano',
              'List se na kraju 2. dana kao čitljiva fotografija predaje '
                  'nadležnom disponentu',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ra5',
    title: 'Ovako se pripremaš',
    summary: 'Što bi trebao razjasniti PRIJE 1. dana — pristupi, oprema, '
        'planiranje vremena i tvoja pitanja',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Razjasni unaprijed: pristupi i tehnika',
        blocks: [
          ParagraphBlock(
            'Najčešći razlog zašto prvi dan loše krene nije nedostatak '
            'znanja, nego pristup koji ne radi. Razjasni to unaprijed — '
            'onda tvoj Ride Along počinje onime o čemu je zaista riječ.',
          ),
          BulletsBlock([
            'Tvoj vlastiti račun za dostavu: pristupni podaci postoje i '
                'jednom si se uspješno prijavio',
            'Evidencija radnog vremena tvoje tvrtke (npr. Kenjo): pristup '
                'postavljen, znaš kako se prijavljuješ i odjavljuješ',
            'Mentor i Flex: aplikacije instalirane, prijava testirana, '
                'dopuštenja za lokaciju i kretanje dana',
            'CoDriver: prijavljen, obavijesti dopuštene',
            'Mobitel: napunjen, dovoljno memorije, kabel za punjenje ili '
                'prijenosna baterija za kombi sa sobom',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Provjeri prethodnu večer, a ne ujutro',
            text: 'Poništavanje zaporke traje u 20 sati pet minuta, a u 6 '
                'sati u Waiting Areji pola sata — ako je uopće netko '
                'dostupan.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: ujutro prvog dana tvoja se '
                'aplikacija za dostavu ne može prijaviti. Trener čeka, val '
                'kreće. Koja je najbolja reakcija?',
            answer: 'Odmah reci da pristup ne radi — i to treneru, kako bi '
                'on mogao uključiti tvojeg nadležnog disponenta. Zabluda '
                'koja se nameće jest tiho pokušavati dalje, da ne bi '
                'ispao nesposoban. To košta upravo one minute u kojima bi '
                'problem još bio rješiv, a na kraju cijeli dan voziš preko '
                'trenerovog računa — čime najmanji broj stajališta preko '
                'tvojeg vlastitog računa nije ispunjen, a dan se u '
                'najgorem slučaju mora ponoviti. Zato: javi rano, jasno '
                'reci što si već pokušao.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Odjeća, oprema i točnost',
        blocks: [
          SubheadBlock('Što oblačiš'),
          BulletsBlock([
            'Zaštitne cipele: čvrsta, zatvorena radna cipela — bez '
                'tenisica, bez sandala',
            'Odjeća otporna na vremenske uvjete: cijeli si dan vani, i '
                'kada ujutro izgleda još suho',
            'Sloboda kretanja: ulaziš i izlaziš stotine puta',
            'Sigurnosni prsluk nadohvat ruke — leži u vozilu, ali mora '
                'biti u tvojoj glavi',
          ]),
          SubheadBlock('Što nosiš sa sobom'),
          BulletsBlock([
            'Vozačku dozvolu — bez nje ne voziš, ni prvog dana',
            'Osobnu iskaznicu ili boravišni dokument, ako tvrtka to traži',
            'Piće i nešto za jelo za stanku',
            'Olovku i mali blok ili aplikaciju za bilješke',
          ]),
          SubheadBlock('Točnost'),
          ParagraphBlock(
            'Točno znači: spreman za rad u stanici na početku smjene, a ne '
            'da tek dolaziš na ulaz. Uračunaj vrijeme za parkiranje, put '
            'preko dvorišta i Waiting Areju. Tko prvog dana zakasni, '
            'pomiče i trenerov val — a to ostane zapamćeno.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Pravilo za prve dane',
            text: 'Isplaniraj put tako da radije budeš prerano ondje. '
                'Dobivenih četvrt sata iskoristi da se osvrneš — toaleti, '
                'Waiting Area, mjesta postrojavanja.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tvoja pitanja — i kontrolna lista unaprijed',
        blocks: [
          ParagraphBlock(
            'Dva dana imaš pokraj sebe nekoga tko zna sve što ti moraš '
            'znati. To je situacija koja se tako više ne ponavlja. '
            'Pogreška koju rade gotovo svi: ne zapamte svoja pitanja, a '
            'sjete ih se tek u drugom tjednu, sami u kombiju.',
          ),
          BulletsBlock([
            'Već prije 1. dana zapiši što želiš znati — i sitnice',
            'Odgovore bilježi tijekom ture, ne oslanjaj se na pamćenje',
            'Ne fotografiraj ništa od podataka kupaca, ali bilježi '
                'postupke i kontakte',
            'Pitaj na kraju svakog dana: „Što danas još nisam vidio?"',
          ]),
          ParagraphBlock(
            'Dobra pitanja za Ride Along su primjerice: kada je točno moj '
            'termin u Waiting Areji? Gdje parkiram privatno? Kako '
            'prepoznajem radi li Mentor još? Gdje upisujem svoju stanku? '
            'Kome prvo prijavljujem štetu? Gdje predajem Green Book? Što '
            'radim ako kupac kod paketa sa zaporkom nema kod?',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Zašto si prošao ovu obuku',
            text: 'Ne zato da na Ride Alongu već sve znaš, nego zato da '
                'poznaješ pojmove. Tko zna o čemu je riječ, može slušati — '
                'tko sve čuje prvi put, može samo kimati.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: trener ti prijepodne objasni deset '
                'stvari jednu za drugom. Navečer se sjećaš triju. Do čega '
                'je bilo — do tebe?',
            answer: 'Do metode, a ne do tebe. Da ti se objasni deset novih '
                'postupaka jedan za drugim i da ih zapamtiš, ne uspijeva '
                'nikome. Ono što uspijeva: da si pojmove jednom prije '
                'pročitao — upravo zbog toga postoji ova obuka — i da '
                'usput bilježiš. Dvije natuknice po temi dovoljne su da '
                'navečer prizoveš cijeli postupak. A ono što drugog dana '
                'još nedostaje, pitaš ciljano, umjesto da se nadaš da će ti '
                'samo od sebe doći.',
          ),
          ChecklistBlock(
            title: 'Prije 1. dana — za samostalno označavanje',
            items: [
              'Pristupni podaci za moj vlastiti račun za dostavu testirani',
              'Evidencija radnog vremena (npr. Kenjo), Mentor, Flex i '
                  'CoDriver instalirani i prijavljeni',
              'Mobitel napunjen, kabel za punjenje ili prijenosna baterija '
                  'spakirani',
              'Zaštitne cipele i odjeća otporna na vremenske uvjete '
                  'pripremljene',
              'Vozačka dozvola i potrebni dokumenti u džepu',
              'Piće i hrana za stanku pripremljeni',
              'Olovka i mogućnost bilježenja sa sobom',
              'Dolazak isplaniran — uključujući parkiranje i put do '
                  'Waiting Areje',
              'Moja pitanja za trenera zapisana',
              'Ova obuka prođena, kako bih poznavao pojmove',
            ],
          ),
        ],
      ),
    ],
  ),
];
