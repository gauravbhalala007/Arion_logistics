// lib/data/safety_training/operating_instructions_hr.dart
//
// Betriebsanweisungen — kroatische Fassung (Übersetzung des DE-Masters).
// Struktur, IDs und Listenlängen identisch zu
// operating_instructions_de.dart.

import 'operating_instructions.dart';

const List<OperatingInstruction> operatingInstructionsHr = [
  // ─────────────────────────────────────────── Vozilo
  OperatingInstruction(
    id: 'baw_transporter',
    title: 'Vožnja dostavnim vozilom do 3,5 t',
    subtitle: 'Upravljanje dostavnim vozilom, manevriranje, parkiranje',
    category: InstructionCategory.vehicle,
    scope: 'Vrijedi za sve zaposlenike koji upravljaju dostavnim vozilima '
        'do 3,5 t najveće dopuštene mase.',
    hazards: [
      'Prometne nesreće zbog nepažnje, vremenskog pritiska i umora',
      'Nalijetanje na osobe pri vožnji unatrag — mrtvi kut',
      'Klizanje tereta pri kočenju i u zavojima',
      'Padovi pri ulasku u vozilo i izlasku iz njega',
      'Prekoračenje najveće dopuštene mase',
    ],
    protection: [
      'Uvijek nosi sa sobom važeću vozačku dozvolu',
      'Kontrola prije polaska: rasvjeta, gume, kočnice, vidljivost, '
          'osiguranje tereta',
      'Sjedalo, retrovizore i naslon za glavu namjesti prije prve vožnje',
      'Veži sigurnosni pojas — i na kratkim dionicama između dva '
          'stajališta',
      'Bez alkohola, droga i lijekova koji utječu na sposobnost vožnje, '
          'prije i tijekom vožnje',
      'Mobitel samo uz handsfree, unos adrese samo dok vozilo stoji',
      'Vožnja unatrag uz opasnost samo s pomagačem; u dvojbi izađi i '
          'provjeri okolinu',
      'Osiguraj teret od klizanja, teške pošiljke dolje i uz prednju '
          'stijenku',
      'Vozilo nakon napuštanja uvijek zaključaj, ključ nikada ne '
          'ostavljaj u bravi',
      'Poštuj propise o odmorima i vremenu vožnje',
    ],
    onFailure: [
      'Kod signalnih lampica ili neobičnih zvukova: pronađi sigurno '
          'mjesto i zaustavi se',
      'Uključi sva četiri pokazivača smjera, obuci sigurnosni prsluk, '
          'postavi sigurnosni trokut (oko 100 m, na autocesti 150–400 m)',
      'Obavijesti dispečera, pomoć na cesti zatraži predviđenim putem',
      'Ne popravljaj sam — vuča samo krutom rudom',
      'Vozilo s uočljivim nedostatkom nemoj dalje pomicati',
    ],
    onAccident: [
      'Zaustavi se, osiguraj mjesto nesreće, prsluk prije izlaska',
      'Pruži prvu pomoć, hitni poziv 112',
      'Policija kod ozljeda osoba, velike materijalne štete ili sumnje '
          'na alkohol/droge',
      'Razmijeni osobne podatke i podatke o osiguranju, osiguraj '
          'fotografije i svjedoke',
      'Odmah obavijesti poslodavca; i male ozljede upiši u knjigu '
          'evidencije ozljeda',
    ],
    maintenance: [
      'Nedostatke odmah prijavi i dokumentiraj',
      'Vozilo drži čistim, staklene površine i stepenice bez snijega, '
          'leda i prljavštine',
      'Provjeri potpunost i rok trajanja kutije prve pomoći, sigurnosnog '
          'trokuta i prsluka',
      'Poštuj termine servisa i tehničkih pregleda',
    ],
  ),

  // ─────────────────────────────────────────── OZO
  OperatingInstruction(
    id: 'baw_sicherheitsschuhe',
    title: 'Zaštitne cipele',
    subtitle: 'Zaštita stopala u dostavnoj djelatnosti',
    category: InstructionCategory.ppe,
    scope: 'Vrijedi za sve zaposlenike u dostavi, skladištu i na voznom '
        'dvorištu.',
    hazards: [
      'Pošiljke i dijelovi tereta koji padaju',
      'Nagazivanje na šiljate ili oštrobridne predmete',
      'Uvrtanje i ozljede ligamenata skočnog zgloba pri izlasku iz '
          'vozila, na rubnjacima i neravnim putovima',
      'Proklizavanje na mokrim i zaleđenim površinama',
      'Prignječenja rolo-kontejnerima i ručnim paletnim viličarima',
    ],
    protection: [
      'Zaštitne cipele nosi tijekom cijelog radnog vremena — u stanici '
          'kao i na ruti, tijekom cijele godine i neovisno o udobnosti '
          'nošenja',
      'Prednost daj izvedbi preko gležnja — ona podupire skočni zglob i '
          'sprječava uvrtanje',
      'Najmanje zaštitna klasa S1; kod vlage S2, kod opasnosti od '
          'proboda S3',
      'Cipele potpuno zaveži, nosi ih zatvorene',
      'Prije početka rada provjeri nedostatke: profil, pukotine, '
          'prianjanje potplata',
      'Ne izvodi vlastite preinake na cipelama',
      'Nikada ne radi u tenisicama ili otvorenim cipelama',
    ],
    onFailure: [
      'Istrošen profil, pukotine ili neispravan potplat: cipele više ne '
          'koristi',
      'Prijavi cipele koje žuljaju ili tište — postoje drugi modeli i '
          'veličine; prelazak na privatne tenisice nije '
          'rješenje',
      'Zamjenu zatraži od nadređenog — poslodavac besplatno osigurava '
          'osobnu zaštitnu opremu (PSA/PPE)',
    ],
    onAccident: [
      'Ozljede stopala odmah daj zbrinuti, i one naizgled lagane',
      'Upis u knjigu evidencije ozljeda',
      'Kod ubodnih ozljeda liječnička obrada — daj provjeriti zaštitu '
          'od tetanusa',
    ],
    maintenance: [
      'Cipele redovito čisti i ostavi da se osuše',
      'Jako zaprljane ili promočene cipele zamijeni',
      'Interval zamjene prema podacima proizvođača i istrošenosti',
    ],
  ),

  OperatingInstruction(
    id: 'baw_warnweste',
    title: 'Sigurnosni prsluk',
    subtitle: 'Biti viđen u prometnom prostoru',
    category: InstructionCategory.ppe,
    scope: 'Vrijedi za sve zaposlenike koji se zadržavaju u prometnom '
        'prostoru, na dvorištu ili na utovarnim površinama.',
    hazards: [
      'Da te previde drugi sudionici u prometu',
      'Loša vidljivost u sumrak, u mraku, po kiši i magli',
      'Manevarski promet na području stanice',
    ],
    protection: [
      'Sigurnosni prsluk drži nadohvat ruke u kabini — ne u tovarnom '
          'prostoru',
      'Obuci ga prije izlaska kod kvara, nesreće i svakog zaustavljanja '
          'u prometnom prostoru',
      'Nosi ga na području stanice i na utovarnim površinama ako se '
          'ondje odvija promet vozila',
      'Koristi prsluk klase 2 ili 3, potpuno ga zatvori',
      'U mraku dodatno pazi na rasvjetu i pozicijska svjetla',
    ],
    onFailure: [
      'Zaprljani, izblijedjeli ili oštećeni prsluk zamijeni — '
          'reflektirajuće trake moraju biti djelotvorne',
      'Nedostatak prsluka prijavi prije polaska i daj ga zamijeniti',
    ],
    onAccident: [
      'Nakon nesreće u prometnom prostoru zadrži prsluk na sebi dok se '
          'mjesto nesreće ne raščisti',
      'Ozljede prijavi i dokumentiraj',
    ],
    maintenance: [
      'Prsluk drži čistim, peri ga prema uputama proizvođača',
      'Provjeri je li u vozilu — dio kontrole prije '
          'polaska',
    ],
  ),

  // ─────────────────────────────────────────── Rukovanje
  OperatingInstruction(
    id: 'baw_heben_tragen',
    title: 'Podizanje i nošenje',
    subtitle: 'Pomicanje pošiljaka bez oštećivanja leđa',
    category: InstructionCategory.handling,
    scope: 'Vrijedi za ručno podizanje, nošenje i odlaganje pošiljaka i '
        'nosača tereta.',
    hazards: [
      'Oštećenja kralježnice i međukralježničnih diskova zbog pogrešne '
          'tehnike podizanja',
      'Ozljede mišića i tetiva zbog naglih pokreta',
      'Prignječenja šaka i stopala pri odlaganju',
      'Spoticanje zbog ograničene vidljivosti kod velikih pošiljaka',
    ],
    protection: [
      'Prije podizanja procijeni težinu i oslobodi put',
      'Priđi teretu blizu, stopala u širini ramena',
      'Podiži iz nogu: spusti se u koljena, leđa drži ravno',
      'Teret nosi uz tijelo, ne na ispruženim rukama',
      'Ne podiži i istodobno se ne okreći — premjesti se stopalima',
      'Teške ili glomazne pošiljke pomiči udvoje ili pomoćnim sredstvima '
          '(rolo-kontejner, kolica za vreće, ručni paletni viličar)',
      'Pri nošenju drži vidik slobodnim; u dvojbi idi dvaput',
      'Kod pošiljaka s oštrim bridovima nosi rukavice',
    ],
    onFailure: [
      'Teret koji je pretežak ili nezgrapan ne pomiči sam — zatraži '
          'pomoć',
      'Neispravna pomoćna sredstva (zaglavljeni kotačići, oštećena '
          'kolica za vreće) ne koristi i prijavi ih',
    ],
    onAccident: [
      'Kod iznenadne boli u leđima odmah prekini rad',
      'Obavijesti nadređenog, upis u knjigu evidencije ozljeda',
      'Kod trajnih tegoba potraži ovlaštenog liječnika '
          '(Durchgangsarzt)',
    ],
    maintenance: [
      'Transportna pomoćna sredstva redovito provjeravaj na ispravnost',
      'Prometne putove i utovarne površine drži slobodnima i '
          'neklizavima',
    ],
  ),

  OperatingInstruction(
    id: 'baw_winter',
    title: 'Zimski uvjeti na cestama',
    subtitle: 'Vožnja i dostava po snijegu, ledu i vlazi',
    category: InstructionCategory.vehicle,
    scope: 'Vrijedi za dostavu i vožnju u zimskim uvjetima.',
    hazards: [
      'Produljen zaustavni put, proklizavanje, aquaplaning',
      'Padovi na zaleđenim nogostupima, rampama i stepenicama',
      'Pothlađivanje pri duljem boravku na otvorenom',
      'Ograničena vidljivost zbog zaleđenih stakala i retrovizora',
    ],
    protection: [
      'Vozilo prije polaska potpuno očisti od snijega i leda — i krov, '
          'farove i registarske pločice',
      'Zimske gume; lance za snijeg i pomagala za polazak nosi sa sobom '
          'po potrebi',
      'Provjeri zaštitu od smrzavanja u rashladnoj tekućini i tekućini '
          'za pranje stakala, strugač za led u vozilu',
      'Znatno smanji brzinu, razmak najmanje '
          'udvostruči',
      'Kočenje, upravljanje i ubrzavanje izvodi blago',
      'Stepenice i prilaze prije korištenja očisti od snijega',
      'Nosi toplu odjeću otpornu na vremenske uvjete i obuću koja ne '
          'kliže',
      'Izbjegavaj vremenski pritisak — bolje stići kasnije nego uopće ne '
          'stići',
    ],
    onFailure: [
      'Kod neprohodnih cesta prekini turu i obavijesti '
          'dispečera',
      'Zaglavljeno vozilo ne pokušavaj izvući silom — zatraži '
          'pomoć',
    ],
    onAccident: [
      'Mjesto nesreće osiguraj osobito pažljivo — sigurnosni trokut '
          'postavi dalje od vozila',
      'Ozljede od pada prijavi i dokumentiraj i kod blagih '
          'simptoma',
    ],
    maintenance: [
      'Redovito kontroliraj metlice brisača i rasvjetu',
      'Njeguj brtve na vratima, brave odledi',
    ],
  ),

  // ─────────────────────────────────────────── Opasne tvari
  OperatingInstruction(
    id: 'baw_adblue',
    title: 'AdBlue (otopina uree)',
    subtitle: 'Dopunjavanje AdBlue na dostavnom vozilu',
    category: InstructionCategory.hazardous,
    scope: 'Vrijedi za dopunjavanje i rukovanje AdBlue na vozilima sa '
        'SCR pročišćavanjem ispušnih plinova.',
    hazards: [
      'Nadraživanje očiju, kože i dišnih putova pri kontaktu',
      'Opasnost od proklizavanja zbog prolivene tekućine',
      'Kristalizacija i korozija na dijelovima vozila',
      'Onečišćenje okoliša pri dospijeću u tlo ili kanalizaciju',
    ],
    protection: [
      'Koristi samo predviđeni plavi nastavak za punjenje — nikada ne '
          'toči u spremnik za dizel',
      'Nosi zaštitne rukavice, izbjegavaj kontakt s kožom',
      'Dopunjavaj samo na otvorenom ili uz dobru ventilaciju, ugasi '
          'motor',
      'Spremnik čisto zatvori, ne skladišti ga na suncu',
      'Nakon rukovanja temeljito operi ruke',
    ],
    onFailure: [
      'Prolivenu tekućinu odmah razrijedi vodom i '
          'pokupi',
      'Koristi upijajuće sredstvo, ne ispiraj u kanalizaciju',
      'Kod pogrešnog punjenja ne pokreći vozilo i odmah prijavi',
    ],
    onAccident: [
      'Kontakt s očima: ispiraj vodom najmanje 15 minuta, potraži '
          'liječnika',
      'Kontakt s kožom: isperi s puno vode, presvuci natopljenu '
          'odjeću',
      'Gutanje: isperi usta, popij vodu, potraži liječnika',
      'Prijavi događaj i upiši ga u knjigu evidencije ozljeda',
    ],
    maintenance: [
      'Spremnik i područje punjenja drži čistima',
      'Praznu ambalažu zbrini prema propisu',
    ],
  ),

  // ─────────────────────────────────────────── Higijena
  OperatingInstruction(
    id: 'baw_hautschutz',
    title: 'Zaštita kože i higijena ruku',
    subtitle: 'Zaštita ruku pri kontaktu s kupcima i utovaru',
    category: InstructionCategory.hygiene,
    scope: 'Vrijedi za sve zaposlenike s čestim dodirom ruku s '
        'pošiljkama, vozilima i kupcima.',
    hazards: [
      'Isušivanje i pukotine zbog čestog pranja i dezinficiranja',
      'Nadraživanje kože zbog prljavštine, hladnoće i sredstava za '
          'čišćenje',
      'Prijenos infekcija pri kontaktu s kupcima',
      'Posjekotine i ogrebotine na rubovima kartona',
    ],
    protection: [
      'Sredstvo za zaštitu kože nanesi prije početka rada',
      'Ruke operi nakon odlaska na WC, prije pauza i nakon utovara',
      'Dezinfekcijsko sredstvo potpuno utrljaj i pusti da se osuši — '
          'nemoj ga brisati',
      'Nakon pranja koristi sredstvo za njegu kože',
      'Zaštitne rukavice kod oštrobridnih ili zaprljanih pošiljaka',
      'Prstenje i ručne satove skini pri utovaru',
    ],
    onFailure: [
      'Kod trajnog crvenila, svrbeža ili pukotina prijavi tu djelatnost',
      'Sredstvo koje ne podnosiš više ne koristi — zatraži '
          'alternativu',
    ],
    onAccident: [
      'Posjekotine i ogrebotine odmah očisti i previj',
      'Upis u knjigu evidencije ozljeda, i kod malih ozljeda',
      'Kod znakova upale liječnička obrada',
    ],
    maintenance: [
      'Provjeri razinu punjenja dozatora za sapun, dezinfekcijsko '
          'sredstvo i sredstvo za njegu',
      'Prazne ili neispravne dozatore prijavi',
    ],
  ),

  // ─────────────────────────────────────────── Radno mjesto
  OperatingInstruction(
    id: 'baw_bildschirm',
    title: 'Radno mjesto sa zaslonom',
    subtitle: 'Dispozicija i uredski rad',
    category: InstructionCategory.workplace,
    scope: 'Vrijedi za zaposlenike koji pretežno rade za zaslonom — '
        'osobito za dispečere i upravu.',
    hazards: [
      'Tegobe s očima zbog blještanja i dugotrajnog fokusiranja',
      'Napetost u vratu, ramenima i leđima',
      'Nadraživanje tetivnih ovojnica zbog nepovoljnog položaja šake i '
          'ruke',
      'Spoticanje o kabele',
    ],
    protection: [
      'Gornji rub zaslona otprilike u visini očiju, udaljenost gledanja '
          '50–70 cm',
      'Zaslon postavi bočno u odnosu na prozor — ne ispred njega ni '
          'nasuprot njemu',
      'Visinu sjedala odaberi tako da podlaktice i nadlaktice tvore '
          'približno pravi kut',
      'Stopala ravno na podu ili na osloncu za noge',
      'Redovito mijenjaj držanje, kratke stanke s pogledom u daljinu',
      'Kabele provedi i osiguraj',
    ],
    onFailure: [
      'Treperave ili neispravne zaslone i svjetiljke prijavi',
      'Neispravne stolice više ne koristi',
    ],
    onAccident: [
      'Kod trajnih tegoba obavijesti nadređenog',
      'Daj provjeriti pravo na zdravstvenu zaštitu na radu i naočale '
          'za rad sa zaslonom',
    ],
    maintenance: [
      'Zaslon i ulazne uređaje drži čistima',
      'Redovito provjeravaj rasvjetu radnog mjesta',
    ],
  ),
];
