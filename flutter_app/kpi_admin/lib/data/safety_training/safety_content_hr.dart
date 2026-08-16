// lib/data/safety_training/safety_content_hr.dart
//
// Sadrzaj sigurnosne obuke — hrvatska verzija.

import 'safety_blocks.dart';

const String _a = 'assets/academy/safety/';

const List<SafetyChapterContent> safetyContentHr = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ch01',
    title: 'Pravne osnove i tvoje obveze',
    summary: 'Zašto postoji zaštita na radu — i što ti moraš doprinijeti',
    asset: '${_a}ch01_grundlagen.svg',
    slides: [
      SafetySlide(
        title: 'Na čemu se temelji zaštita na radu',
        asset: '${_a}ch01_grundlagen.svg',
        blocks: [
          ParagraphBlock(
            'Zaštita na radu nije dobrovoljna ponuda tvojeg poslodavca, '
            'nego je propisana zakonom. Počiva na dva stupa: na državnom '
            'pravu i na pravu nositelja osiguranja od nezgoda.',
          ),
          BulletsBlock([
            'Arbeitsschutzgesetz (ArbSchG) — uređuje obveze poslodavca te '
                'prava i obveze zaposlenika',
            'Uredbe — konkretiziraju zakon, npr. uredbe o radnim '
                'mjestima, o sigurnosti pogona i o opasnim tvarima',
            'DGUV Vorschriften — obvezujuća pravila strukovne udruge, za '
                'tebe kao osiguranika obvezujuća',
            'DGUV Regeln und Informationen — pomoć pri primjeni i '
                'preporuke, nisu obvezujuće, ali su provjerene u praksi',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Razlika koja je važna',
            text: 'DGUV Vorschriften su obvezujuće. DGUV Regeln pokazuju '
                'kako ih primijeniti. DGUV Informationen su preporuke.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tvojih šest obveza kao zaposlenika',
        blocks: [
          ParagraphBlock(
            'Poslodavac te mora štititi — ti moraš sudjelovati. Ove '
            'obveze vrijede za svakog zaposlenika, bez obzira na položaj '
            'i ugovor.',
          ),
          StepsBlock([
            'Brinuti se za vlastitu sigurnost i sigurnost kolega',
            'Slijediti Betriebsanweisungen i upute s poduke',
            'Pružiti prvu pomoć odnosno podržati učinkovitu prvu pomoć',
            'Prijaviti nezgode i skoro-nezgode — i one male',
            'Odmah prijaviti kvarove i nedostatke (oštećeni kabeli, '
                'pokvareni uređaji, pogrešni postupci)',
            'Zaštitnu opremu koristiti namjenski — zaštitne cipele, '
                'rukavice, sigurnosni prsluk, zaštita sluha',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Alkohol, droge, lijekovi',
            text: 'Ne smiješ ugroziti sebe ni druge opojnim sredstvima. '
                'To vrijedi za cijelo radno vrijeme — i za pauzu, jer '
                'nakon nje opet voziš. Tu spadaju i lijekovi koji '
                'izazivaju pospanost: ako nisi siguran, pitaj liječnika.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ch02',
    title: 'Betriebsanweisungen',
    summary: 'Obvezujuće upute — i zašto te štite',
    asset: '${_a}ch02_betriebsanweisungen.svg',
    slides: [
      SafetySlide(
        title: 'Što je Betriebsanweisung',
        asset: '${_a}ch02_betriebsanweisungen.svg',
        blocks: [
          ParagraphBlock(
            'Betriebsanweisung je obvezujuća uputa tvojeg poslodavca za '
            'rukovanje vozilima, radnim sredstvima i opasnim tvarima. To '
            'nije preporuka.',
          ),
          BulletsBlock([
            'Dostupna je u tvrtki — moraš je poznavati',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'To bi trebao znati',
            text: 'Tko prekrši Betriebsanweisung, to mu se pri istrazi '
                'nezgode može pripisati. U najgorem slučaju to znači '
                'suodgovornost za nezgodu — i to osobno za tebe.',
          ),
          ParagraphBlock(
            'Razlika: Betriebsanweisung uređuje rukovanje radnim '
            'sredstvom ili opasnom tvari. Radna uputa uređuje tijek '
            'radnog procesa.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Struktura — šest odjeljaka',
        blocks: [
          ParagraphBlock(
            'Svaka Betriebsanweisung ima istu strukturu. Ako je '
            'poznaješ, u ozbiljnoj situaciji odmah nađeš pravo mjesto.',
          ),
          StepsBlock([
            'Područje primjene — za što i za koga vrijedi',
            'Opasnosti za čovjeka i okoliš',
            'Zaštitne mjere i pravila ponašanja',
            'Ponašanje kod smetnji',
            'Ponašanje kod nezgoda i prva pomoć',
            'Zbrinjavanje i održavanje',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Primjer: vožnja kombijem',
        blocks: [
          ParagraphBlock(
            'Ovako izgledaju konkretna pravila iz jedne '
            'Betriebsanweisung za vozila do 3,5 t:',
          ),
          BulletsBlock([
            'Nositi važeću vozačku dozvolu',
            'Bez alkohola i droga prije i tijekom vožnje',
            'Vožnja unatrag kod opasnosti samo uz navodioca',
            'Vozilo nakon napuštanja uvijek zaključati',
            'Vuča samo krutom rudom',
            'Osigurati mjesto nezgode, svaku nezgodu odmah prijaviti',
            'I manje ozljede odmah zbrinuti i upisati u knjigu '
                'evidencije ozljeda',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ako nisi siguran, pitaj',
            text: 'Ako ti neka uputa nije jasna, pitaj svojeg dispečera — '
                'prije nego što kreneš, a ne poslije.',
          ),
          SubheadBlock('Najvažnije upute'),
          ParagraphBlock(
            'Sve Betriebsanweisungen možeš u svakom trenutku pronaći u DA '
            'Academy pod „Betriebsanweisungen”.',
          ),
          InstructionRefBlock([
            'baw_transporter',
            'baw_heben_tragen',
            'baw_winter',
          ]),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ch03',
    title: '10 pravila za siguran rad',
    summary: 'Srž tvojeg radnog dana — vrijedi svaki dan',
    asset: '${_a}ch03_sicheres_arbeiten.svg',
    slides: [
      SafetySlide(
        title: 'Deset pravila, svaki dan',
        asset: '${_a}ch03_sicheres_arbeiten.svg',
        blocks: [
          StepsBlock([
            'Siguran i promišljen rad',
            'Kontrola vozila prije polaska',
            'Osiguravanje tereta u vozilu',
            'Profesionalna vožnja i poštivanje prometnih propisa',
            'Vezanje sigurnosnog pojasa',
            'Održavanje vozila, alata i opreme u ispravnom stanju',
            'Rad samo u prikladnoj obući',
            'Pristojno ophođenje s kolegama i kupcima',
            'Poštivanje pravila o pauzama',
            'Tolerantno ophođenje puno poštovanja',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Tri s najvećim učinkom',
            text: 'Kontrola prije polaska, osiguranje tereta, sigurnosni '
                'pojas. Ta tri sprječavaju većinu teških posljedica — a '
                'zajedno ne traju ni tri minute.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ch04',
    title: 'Osobna zaštitna oprema (OZO)',
    summary: 'Zaštitne cipele i sigurnosni prsluk — tvoja dnevna obveza',
    asset: '${_a}ch04_psa.svg',
    slides: [
      SafetySlide(
        title: 'Tvoja OZO kao dostavljača',
        asset: '${_a}ch04_psa.svg',
        blocks: [
          ParagraphBlock(
            'Osobna zaštitna oprema je sve što nosiš na tijelu da se '
            'zaštitiš od opasnosti. U dostavi su dva dijela obvezna '
            'svaki dan:',
          ),
          FactsBlock([
            FactItem('1', 'Zaštitne cipele'),
            FactItem('2', 'Sigurnosni prsluk'),
          ]),
          BulletsBlock([
            'Zaštitne cipele — cijeli radni dan, u stanici kao i na ruti',
            'Sigurnosni prsluk — nadohvat ruke u vozilu i obučen prije '
                'nego što izađeš kod kvara, nezgode ili stajanja uz cestu',
          ]),
          SubheadBlock('Ostala OZO — ovisno o poslu'),
          ParagraphBlock(
            'Ova oprema nije propisana svaki dan, ali može biti potrebna '
            'za određene radove. Što vrijedi za tebe, piše u procjeni '
            'rizika i u Betriebsanweisung.',
          ),
          BulletsBlock([
            'Zaštitne rukavice — kod pošiljaka s oštrim rubovima, kod '
                'čišćenja i održavanja, zimi',
            'Zaštita sluha — kod buke, npr. u pojedinim dijelovima hale',
            'Zaštitne naočale — kod radova s opasnošću od prskanja',
            'Zaštita glave — na gradilištima i kod opasnosti od '
                'padajućih predmeta',
            'Odjeća za zaštitu od vremena — kod trajnog rada na otvorenom',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Obveza korištenja',
            text: 'OZO koju osigurava poslodavac moraš koristiti '
                'namjenski (§ 15 Arbeitsschutzgesetz). Poslodavac je daje '
                'besplatno i mora nadzirati pridržavanje.',
          ),
          InstructionRefBlock(['baw_sicherheitsschuhe', 'baw_warnweste']),
        ],
      ),
      SafetySlide(
        title: 'Zaštitne cipele: zaštitno djelovanje',
        blocks: [
          ParagraphBlock(
            'Zaštita stopala je OZO koju najčešće trebaš — i koja se '
            'najčešće podcjenjuje.',
          ),
          SubheadBlock('Od čega štite'),
          BulletsBlock([
            'Mehanički — udarci, prignječenja, padajući paketi, gaženje '
                'po oštrim predmetima',
            'Uganuće — cipele do gležnja podupiru skočni zglob i '
                'sprječavaju puknuća ligamenata i ozljede gležnja',
            'Električno — antistatičko odvođenje',
            'Kemijski — kiseline, ulja, goriva',
            'Toplinski — vrućina i hladnoća',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Zašto do gležnja',
            text: 'Najčešća ozljeda u dostavi je uganuće pri izlasku iz '
                'vozila, na rubnjacima i neravnim putovima. Cipela do '
                'gležnja podupire zglob točno ondje gdje popušta — plitka '
                'cipela to ne može.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'I kad su neudobne — i ljeti',
            text: 'Obveza nošenja vrijedi svakog radnog dana, bez obzira '
                'na vrijeme i udobnost. Baš se ljeti ljudi presvuku — i '
                'upravo se tada događaju ozljede. Ako cipele žuljaju ili '
                'tište, to je razlog za drugi model, a ne za tenisice.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Redovito provjeravaj svoje cipele',
            text: 'Istrošen profil, pukotine ili jaka zaprljanost: daj ih '
                'zamijeniti. Nemoj ih sam preinačivati i nikad ne radi u '
                'tenisicama — ni „samo nakratko”.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pregled zaštitnih razreda',
        blocks: [
          TableBlock(
            headers: ['Razred', 'Svojstva'],
            rows: [
              [
                'S1',
                'Zatvoren dio pete, antistatične, potplat otporan na '
                    'gorivo',
              ],
              ['S2', 'kao S1 + najmanje 60 minuta vodonepropusne'],
              ['S3', 'kao S2 + potplat otporan na probijanje i profiliran'],
              ['S4', 'kao S2, u cijelosti od gume (vulkanizirane)'],
              ['S5', 'kao S4 + potplat otporan na probijanje'],
            ],
          ),
          SubheadBlock('Kada su posebno važne'),
          BulletsBlock([
            'Na ljestvama, gazištima i stubama',
            'Kod rolo-kontejnera i ručnih paletnih kolica',
            'Na neravnim putovima i rampama',
          ]),
          ParagraphBlock(
            'Obilježja dobre cipele: čvrsto naliježe, zatvorena je, drži '
            'petu uz amortizaciju, savitljiv potplat, niska peta, '
            'protuklizni profil.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ch05',
    title: 'Ponašanje u slučaju požara',
    summary: 'Pravilno koristiti aparat i svladati požar vozila',
    asset: '${_a}ch05_brandfall.svg',
    slides: [
      SafetySlide(
        title: 'Rukovanje vatrogasnim aparatom',
        asset: '${_a}ch05_brandfall.svg',
        blocks: [
          ParagraphBlock(
            'Postoje aparati s prahom, s vodom/pjenom i s CO₂. Rukovanje '
            'je kod svih jednako:',
          ),
          StepsBlock([
            'Ukloniti osigurač',
            'Pritisnuti udarno dugme',
            'Pritisnuti mlaznicu',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Imaš samo nekoliko sekundi',
            text: 'Aparat je prazan brže nego što većina misli. Zato: '
                'radije koristi više aparata istodobno nego jedan za '
                'drugim.',
          ),
          FactsBlock([
            FactItem('6–12 s', 'Prah 1–2 kg'),
            FactItem('15–23 s', 'Prah 6 kg'),
            FactItem('18–33 s', 'Prah 12 kg'),
            FactItem('20–30 s', 'Pjena 6 l'),
            FactItem('5–10 s', 'CO₂ 2 kg'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Pravilno gašenje — korak po korak',
        blocks: [
          ParagraphBlock(
            'Redoslijed odlučuje hoće li se vatra ugasiti ili opet '
            'buknuti. Šest koraka koje bi trebao zapamtiti:',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}fire01_pin.svg',
              title: 'Pripremi aparat',
              caption: 'Izvuci osigurač, pritisni udarno dugme, drži '
                  'aparat uspravno. Tek onda idi prema požaru.',
            ),
            IllustratedStep(
              asset: '${_a}fire02_wind.svg',
              title: 'Napadaj u smjeru vjetra',
              caption: 'Vjetar ti mora biti u leđima i nositi sredstvo za '
                  'gašenje u vatru — nikad ne gasi protiv vjetra. Tako '
                  'toplina i dim ostaju dalje od tebe.',
            ),
            IllustratedStep(
              asset: '${_a}fire03_surface.svg',
              title: 'Površinski požar: počni sprijeda',
              caption: 'Ciljaj na prednji rub plamena, u žar — a ne u '
                  'vrhove plamena. Zatim komad po komad radi prema '
                  'natrag.',
            ),
            IllustratedStep(
              asset: '${_a}fire04_drip.svg',
              title: 'Kapajući požar: odozgo prema dolje',
              caption: 'Ako zapaljena tekućina curi prema dolje, počni '
                  'gore na mjestu izlaza i radi prema dolje — inače se '
                  'odozgo stalno iznova zapali.',
            ),
            IllustratedStep(
              asset: '${_a}fire05_together.svg',
              title: 'Više aparata istodobno',
              caption: 'Ako ima više aparata i pomagača: koristite ih '
                  'zajedno i u isto vrijeme. Jedan za drugim daje vatri '
                  'vremena da se između aparata oporavi.',
            ),
            IllustratedStep(
              asset: '${_a}fire06_watch.svg',
              title: 'Promatraj mjesto požara',
              caption: 'Nakon gašenja ostani na mjestu i promatraj. '
                  'Žarišta se često nakon nekoliko minuta ponovno '
                  'zapale — drži razmak i aparat spreman.',
            ),
            IllustratedStep(
              asset: '${_a}fire07_refill.svg',
              title: 'Iskorišteni aparat daj napuniti',
              caption: 'Iskorišteni aparat nikad ne ide natrag na zid — '
                  'ni nakon kratkog mlaza. Odmah ga daj na ponovno '
                  'punjenje i prijavi zamjenu.',
            ),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Kada ne gasiš',
            text: 'Nikad se ne dovodi u opasnost. Ako je požar veći od '
                'koša za smeće, ako se jako razvija dim ili riskiraš put '
                'za bijeg: van, zatvori vrata, nazovi 112 i upozori '
                'druge.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Požar vozila',
        blocks: [
          SubheadBlock('Najčešći uzroci'),
          BulletsBlock([
            'Propuštanje goriva ili ulja',
            'Izolacijski materijal na vrućim dijelovima',
            'Mehanička oštećenja',
            'Električni kvarovi',
            'Zapaljeni spremnici za otpad',
          ]),
          SubheadBlock('Što ti činiš'),
          StepsBlock([
            'Ne zaustavljaj se u tunelima ni na mostovima — ako je '
                'moguće, izađi iz njih',
            'Uključi sva četiri pokazivača smjera, potraži prikladno '
                'mjesto, zaustavi se',
            'Napusti vozilo, drži razmak',
            'Pozovi vatrogasce na 112 — navedi lokaciju i smjer vožnje',
            'Tek onda vlastiti pokušaji gašenja, ako je sigurno',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Poklopac motora: oprez',
            text: 'Otvaraj samo s rukavicama i samo na malu pukotinu. '
                'Zbog naglog dotoka kisika može doći do naglog buktanja '
                'plamena.',
          ),
          SubheadBlock('Što centrala mora znati'),
          BulletsBlock([
            'Gdje gori?',
            'Što gori i u kojem opsegu?',
            'Koliko je ozlijeđenih i kakve su ozljede?',
            'Što je natovareno?',
            'Tko prijavljuje?',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ne prekidaj vezu',
            text: 'Nikad sam ne prekidaj poziv. Čekaj dodatna pitanja — '
                'centrala završava razgovor.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'ch06',
    title: 'Prva pomoć',
    summary: 'Tvoja obveza, tvoja zaštita i dokumentacija',
    asset: '${_a}ch06_erste_hilfe.svg',
    slides: [
      SafetySlide(
        title: 'Pomagati je obveza — i zaštićeno je',
        asset: '${_a}ch06_erste_hilfe.svg',
        blocks: [
          ParagraphBlock(
            'Svatko je dužan pružiti prvu pomoć — u okviru razumnog i '
            'bez znatnog ugrožavanja sebe. I kao laik.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 323c StGB — nepružanje pomoći',
            text: 'Tko ne pomogne iako bi se to od njega moglo očekivati, '
                'čini kazneno djelo: do godine dana zatvora ili novčana '
                'kazna. To vrijedi i za znatiželjnike koji ometaju '
                'pomagače.',
          ),
          SubheadBlock('Tko pomaže, ne griješi'),
          BulletsBlock([
            'Kao pružatelj prve pomoći ne odgovaraš za pogreške — osim '
                'kod namjere ili grube nepažnje',
            'Tijekom pružanja pomoći zakonski si osiguran od nezgode',
            'Troškove ne snosiš ti; materijalna šteta se u pravilu '
                'nadoknađuje',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Jedina prava pogreška',
            text: 'Ne učiniti ništa. Sve drugo je bolje od okretanja '
                'glave.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pružatelji prve pomoći u stanici — i ti',
        blocks: [
          ParagraphBlock(
            'U stanici postoje obučeni pružatelji prve pomoći. Za to se '
            'brine poduzetnik: organizacija prve pomoći je njegova '
            'zadaća (§ 24 DGUV Vorschrift 1), i mora osigurati najmanji '
            'broj obučenih pružatelja prve pomoći '
            '(§ 26 DGUV Vorschrift 1).',
          ),
          FactsBlock([
            FactItem('1', 'pružatelj na 2–20 prisutnih'),
            FactItem('10 %', 'prisutnih u ostalim pogonima'),
            FactItem('2 godine', 'usavršavanje pružatelja prve pomoći'),
          ]),
          ParagraphBlock(
            'Ako više poslodavaca radi na istom terenu, moraju se '
            'uskladiti i međusobno informirati '
            '(§ 8 Arbeitsschutzgesetz). Pritom se može dogovoriti da se '
            'zajednički koristi organizacija prve pomoći stanice. To '
            'uređuje suradnju poduzeća — a ne tvoju osobnu obvezu.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'To te ne oslobađa',
            text: 'Obveza pružanja pomoći prema § 323c StGB pogađa '
                'svakoga osobno. Obučeni pružatelji prve pomoći u '
                'stanici to ne mijenjaju.',
          ),
          SubheadBlock('Kako je to pravno riješeno'),
          BulletsBlock([
            'Ako je netko već ondje i stvarno dovoljno pomaže, ne moraš '
                'sam prihvatiti posao',
            'Obveza da pozoveš hitnu pomoć i dovedeš pomoć ostaje u '
                'svakom slučaju',
            'Moraš se uvjeriti da se doista pomaže — okretanje glave uz '
                'misao „netko će se već pobrinuti” nije dovoljno',
            'Po uputi pružatelja prve pomoći pomozi: osiguraj mjesto, '
                'dočekaj hitnu pomoć, donesi materijal, drži druge '
                'podalje',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Na turi si sam',
            text: 'Najveći dio radnog vremena nisi u stanici, nego na '
                'putu. Ondje nema pružatelja prve pomoći iz stanice — '
                'kod hitnog slučaja na ruti ti pružaš prvu pomoć.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pozivanje hitne službe',
        blocks: [
          FactsBlock([
            FactItem('112', 'Hitni broj, u cijeloj Europi'),
          ]),
          SubheadBlock('Pet ključnih pitanja'),
          StepsBlock([
            'Gdje se dogodilo?',
            'Koliko je osoba ozlijeđeno?',
            'Što se dogodilo?',
            'Tko zove?',
            'Čekaj dodatna pitanja',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Osnovna pravila pri pomaganju',
            text: 'Ostani miran · djeluj brzo · pazi na vlastitu '
                'sigurnost · osiguraj mjesto nezgode · pomozi najbolje '
                'što znaš.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dokumentacija i prijava',
        blocks: [
          ParagraphBlock(
            'Svaka ozljeda se dokumentira — i mala posjekotina. To te '
            'štiti ako se kasnije pojave posljedice.',
          ),
          SubheadBlock('U knjigu evidencije ozljeda spada'),
          BulletsBlock([
            'Vrijeme i mjesto',
            'Tijek događaja',
            'Vrsta i opseg ozljede',
            'Ime ozlijeđene osobe',
            'Svjedoci i pružatelji prve pomoći',
          ]),
          FactsBlock([
            FactItem('> 3 dana', 'bolovanje → potrebna prijava nezgode'),
            FactItem('3 dana', 'rok za prijavu'),
            FactItem('5 godina', 'čuvanje, povjerljivo'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Odmah prijavi',
            text: 'Smrtne nezgode, masovne nezgode i teška oštećenja '
                'zdravlja poduzetnik prijavljuje bez odgode — zato uvijek '
                'odmah obavijesti svojeg poslodavca.',
          ),
          ParagraphBlock(
            'Kutije prve pomoći moraju biti potpune. Provjeri rok '
            'trajanja i prijavi materijal koji nedostaje.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 7
  SafetyChapterContent(
    id: 'ch07',
    title: 'Sjedenje i kretanje',
    summary: 'Čuvaj leđa, zadrži koncentraciju',
    asset: '${_a}ch07_sitzen_bewegen.svg',
    slides: [
      SafetySlide(
        title: 'Zašto sjedenje postaje rizik',
        asset: '${_a}ch07_sitzen_bewegen.svg',
        blocks: [
          ParagraphBlock(
            'Dugo i loše namješteno sjedenje više je od neudobnosti — '
            'košta te pažnje i vremena reakcije.',
          ),
          BulletsBlock([
            'Umor i pad koncentracije',
            'Napetost i bolovi u leđima',
            'Tegobe u vratnoj i slabinskoj kralježnici',
            'Nezgode zbog usporene reakcije',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Pravilno namjesti sjedalo',
        blocks: [
          ParagraphBlock(
            'Uzmi si dvije minute prije prve vožnje. Odlučuje sedam '
            'postavki:',
          ),
          StepsBlock([
            'Visina sjedala i uzdužni pomak',
            'Dubina sjedišta',
            'Nagib sjedišta',
            'Nagib naslona',
            'Potpora za slabinsku kralježnicu',
            'Naslon za glavu',
            'Volan i položaj pojasa',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Dinamično sjedenje',
            text: 'Leđa potpuno uz naslon, sjedi uspravno — i stalno malo '
                'mijenjaj držanje. Najbolji položaj sjedenja je sljedeći.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Vježbe za između',
        blocks: [
          SubheadBlock('U sjedećem položaju'),
          BulletsBlock([
            'Snažno razvlači volan u stranu — drži 3–6 sekundi, '
                '3 ponavljanja',
            'Pritisni koljena protiv pritiska ruku — 3–6 sekundi, '
                '5 ponavljanja',
            'Osloni se na sjedište i podigni težinu — 3 ponavljanja',
          ]),
          SubheadBlock('U stojećem položaju'),
          BulletsBlock([
            'Ispruži ruke prema gore — oko 8 sekundi, 3–5 ponavljanja',
            'Ruke na zatiljak, laktovi prema natrag — oko 8 sekundi, '
                '3–5 ponavljanja',
            'Petu na povišenje visoko oko 30 cm, istegni nogu — oko '
                '8 sekundi, 2–3 puta po nozi',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Uvježbana leđa izdrže više',
            text: 'Iskoristi vrijeme pauze — a ne dodatno vrijeme.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 8
  SafetyChapterContent(
    id: 'ch08',
    title: 'Opterećenje i koncentracija',
    summary: 'Sposoban i pažljiv kroz cijeli dan',
    asset: '${_a}ch08_psychische_belastung.svg',
    slides: [
      SafetySlide(
        title: 'Zašto to spada u zaštitu na radu',
        asset: '${_a}ch08_psychische_belastung.svg',
        blocks: [
          ParagraphBlock(
            'Tko je pod pritiskom, sporije reagira, više previdi i '
            'griješi. Upravo je zato opterećenje sigurnosna tema — a ne '
            'tek onda kad netko oboli.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Propisano zakonom',
            text: 'Od 2013. procjena rizika mora izričito uzeti u obzir i '
                'psihička opterećenja na radu '
                '(§ 5 Abs. 3 Nr. 6 Arbeitsschutzgesetz). Procjenjuju se '
                'radni uvjeti — a ne pojedine osobe.',
          ),
          SubheadBlock('Što u svakodnevnoj vožnji stvara pritisak'),
          BulletsBlock([
            'Uski vremenski okviri, gužve, gradilišta, traženje parkinga',
            'Nejasne nadležnosti pri utovaru i istovaru',
            'Nedostatne ili zakašnjele informacije o turi',
            'Tehnički problemi na vozilu ili uređaju',
            'Teške situacije s kupcima',
          ]),
          ParagraphBlock(
            'To su uvjeti koje pogon može promijeniti. Zato je najvažnije '
            'pravilo: prijavi dok se još može riješiti.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ostati koncentriran — kako to ide u praksi',
        blocks: [
          SubheadBlock('Tijekom ture'),
          BulletsBlock([
            'Koristi pauze kao alat: kratko izađi, pogledaj u daljinu, '
                'prohodaj nekoliko koraka — to mjerljivo vraća pažnju',
            'Pij dovoljno i jedi redovito',
            'Ne manevriraj pod vremenskim pritiskom — te dvije minute '
                'jeftinije su od udubljenja na limu',
            'Mobitel koristi tek u mjestu, adresu upiši prije polaska',
            'Nakon teških kontakata s kupcima kratko udahni prije nego '
                'kreneš dalje',
          ]),
          SubheadBlock('Reci rano umjesto da trpiš'),
          ParagraphBlock(
            'Ako nešto trajno ne štima, reci to svojem dispečeru — rano i '
            'konkretno. Tura koja se redovito ne može odraditi, vozilo '
            'koje pravi probleme, ruta sa stalnim nedostatkom parkinga: '
            'to se da isplanirati ako netko za to zna.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Konkretna prijava pomaže više od trpljenja',
            text: 'Reci što točno ne funkcionira i gdje — ne samo da je '
                'bilo stresno. Što je povratna informacija konkretnija, '
                'to se prije nešto promijeni u planiranju.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Nakon posebnih događaja',
        blocks: [
          ParagraphBlock(
            'Neke situacije ostavljaju trag: teška nezgoda, pljačka, '
            'pružanje prve pomoći teško ozlijeđenim osobama. To je '
            'normalna reakcija na nenormalan događaj — a ne znak '
            'slabosti.',
          ),
          BulletsBlock([
            'Prijavi događaj svojem nadređenom, i ako tebi samome ništa '
                'nije bilo',
            'Nakon nezgoda na radu postoje ponude podrške preko strukovne '
                'udruge',
            'Mnoge tvrtke imaju psihološke prve pomagače ili '
                'trauma-savjetnike — pitaj u uredu',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'U akutnom hitnom slučaju',
            text: 'Kod akutne duševne krize u Njemačkoj: Telefonseelsorge '
                '0800 111 0 111 — besplatno, anonimno, dostupno '
                'danonoćno.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 9
  SafetyChapterContent(
    id: 'ch09',
    title: 'Sigurna vožnja i kontrola prije polaska',
    summary: 'Dvije minute kontrole prije svake ture',
    asset: '${_a}ch09_sicheres_fahren.svg',
    slides: [
      SafetySlide(
        title: 'Obilazak oko vozila',
        asset: '${_a}ch09_sicheres_fahren.svg',
        blocks: [
          ParagraphBlock(
            'Prije svakog polaska obvezna je kontrola vozila. Traje dvije '
            'minute i pronalazi upravo one nedostatke koji na putu '
            'postaju skupi ili opasni.',
          ),
          BulletsBlock([
            'Rasvjeta sprijeda i straga',
            'Vidljivost — ogledala i stakla čisti i neoštećeni',
            'Kotači — tlak, profil, pričvršćenost',
            'Kočnice — proba kočenja, tlak u kočnicama',
            'Motor i pogon — ulje, rashladna i kočiona tekućina, '
                'tekućina za pranje stakla, bez curenja',
            'Cerade i vrata zatvoreni',
            'Registarske pločice i ploče upozorenja čiste',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Teret i vozačevo radno mjesto',
        blocks: [
          SubheadBlock('Osiguranje tereta'),
          BulletsBlock([
            'Je li vozilo prikladno za ovaj teret?',
            'Jesu li sredstva za vezivanje neoštećena?',
            'Je li teret osiguran i zaštićen od klizanja?',
            'Jesu li osovinska opterećenja i najveća dopuštena masa '
                'poštovani?',
          ]),
          SubheadBlock('Tvoje radno mjesto'),
          BulletsBlock([
            'Sjedalo i volan pravilno namješteni',
            'Kontrolni uređaji bez dojave smetnje',
            'Proba kočenja bez primjedbi',
            'Sustavi za pomoć vozaču uključeni i spremni',
            'Ventilacija ispravna',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Zimi dodatno',
            text: 'Prikladne gume, po potrebi lanci za snijeg ili pomoć '
                'pri kretanju, dovoljno sredstva protiv smrzavanja u '
                'rashladnoj tekućini i tekućini za pranje stakla, '
                'strugalica za led u vozilu.',
          ),
          InstructionRefBlock(['baw_transporter', 'baw_winter']),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 10
  SafetyChapterContent(
    id: 'ch10',
    title: 'Kvarovi i nezgode',
    summary: 'Osigurati, pomoći, ispravno dokumentirati',
    asset: '${_a}ch10_pannen_unfaelle.svg',
    slides: [
      SafetySlide(
        title: 'Osnovno pravilo i kvar',
        asset: '${_a}ch10_pannen_unfaelle.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Osnovno pravilo',
            text: 'Vlastita zaštita ide ispred zaštite drugih. Zaštita '
                'osoba ide ispred zaštite stvari.',
          ),
          SubheadBlock('Kad se kvar najavi'),
          StepsBlock([
            'Pravodobno potraži prikladno mjesto za zaustavljanje — npr. '
                'kod rasta temperature rashladne tekućine',
            'Uključi sva četiri pokazivača smjera već dok se zaustavljaš',
            'Ako je moguće do sljedećeg parkirališta, inače krajnji '
                'desni rub kolnika',
            'Zategni ručnu kočnicu, u mraku uključi poziciona svjetla',
            'Obuci sigurnosni prsluk — prije izlaska',
            'Postavi sigurnosni trokut',
          ]),
          FactsBlock([
            FactItem('100 m', 'Sigurnosni trokut, cesta'),
            FactItem('150–400 m', 'Sigurnosni trokut, autocesta'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Plan za hitni slučaj kod nezgode',
        blocks: [
          StepsBlock([
            'Zaustavi se — uvijek, i ako nikoga nema',
            'Osiguraj mjesto nezgode — sva četiri pokazivača smjera, '
                'ručna kočnica, u mraku poziciona svjetla, sigurnosni '
                'prsluk prije izlaska, sigurnosni trokut',
            'Pruži prvu pomoć — bez odgode',
            'Nazovi 112 — kod hitnosti i prije prve pomoći',
            'Razmijeni osobne podatke — ime, adresa, registarska oznaka, '
                'osiguranje',
            'Pozovi policiju — kod ozljeda osoba, velike materijalne '
                'štete ili sumnje na alkohol/droge',
            'Osiguraj dokaze — fotografije mjesta nezgode i šteta, '
                'kontakti svjedoka',
            'Obavijesti poslodavca i dogovori postupak, provjeri jesi li '
                'sposoban voziti, spremi sigurnosni trokut natrag',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Šteta na parkiralištu i najčešća ozljeda',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Papirić nije dovoljan',
            text: 'Ako okrzneš parkirani auto i nikoga nema: pričekaj '
                'najmanje 30 minuta. Nakon toga ostavi ime i adresu I '
                'bez odgode prijavi nezgodu najbližoj policijskoj '
                'postaji. Inače je to bijeg s mjesta nezgode.',
          ),
          SubheadBlock('Gdje se vozači stvarno ozljeđuju'),
          FactsBlock([
            FactItem('51,6 %', 'Padovi i propadanja'),
            FactItem('7,2 %', 'Prometne nezgode'),
          ]),
          ParagraphBlock(
            'Većina nezgoda koje se moraju prijaviti ne događa se u '
            'cestovnom prometu, nego pri penjanju i silaženju iz kabine '
            'ili s tovarnog prostora.',
          ),
          DoDontBlock(
            doTitle: 'Ispravno',
            dos: [
              'Koristiti predviđene stepenice i rukohvate',
              'Tri točke oslonca pri ulasku i izlasku',
              'Držati stepenice čistima i slobodnima',
              'Nositi prikladnu obuću',
            ],
            dontTitle: 'Opasno',
            donts: [
              'Skakati iz kabine ili s tovarnog prostora',
              'Hodati po zaprljanim, zaleđenim ili zakrčenim stepenicama',
              'Penjati se na dijelove vozila koji za to nisu predviđeni '
                  'ili na teret',
              'Koristiti oštećene ljestve',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 11
  SafetyChapterContent(
    id: 'ch11',
    title: 'Pravilo triju točaka',
    summary: 'Ulazak i izlazak — najvažnije pojedinačno pravilo',
    asset: '${_a}step3p_cover.svg',
    slides: [
      SafetySlide(
        title: 'Uvijek 3 od 4 dodirne točke',
        asset: '${_a}step3p_cover.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Osnovno pravilo',
            text: '2 ruke + 1 noga  ILI  2 noge + 1 ruka. Tri točke '
                'uvijek imaju čvrst kontakt s vozilom.',
          ),
          ParagraphBlock(
            'Svaki dan ulaziš i izlaziš desetke puta — u žurbi, po kiši, '
            'punih ruku. Upravo se pritom događa najviše nezgoda. Tri '
            'čvrste točke daju ti oslonac i sprječavaju padove i ozljede '
            'gležnja, koljena i leđa.',
          ),
          FactsBlock([
            FactItem('51,6 %', 'svih nezgoda su padovi'),
            FactItem('7,2 %', 'su prometne nezgode'),
          ]),
          ParagraphBlock(
            'Nijedan drugi pokret u radnoj svakodnevici ne sprječava '
            'toliko ozljeda kao ovaj. Zato stoji na kraju ove poduke — '
            'kao ono što ti treba ostati u glavi.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Četiri pravila pojedinačno',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}step3p_01_face.svg',
              title: 'Licem prema vozilu',
              caption: 'Izlazi uvijek okrenut prema vozilu — nikad '
                  'unatrag ni bočno iskačući. Skakanje je najčešći uzrok '
                  'nezgoda. Uvijek koristi stepenicu i rukohvate.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_02_hands.svg',
              title: 'Prvo odloži, pa se uhvati',
              caption: 'Nikakvi paketi u ruci pri ulasku i izlasku. Prvo '
                  'odloži pošiljku ili spremi sitne dijelove u torbu ili '
                  'pojas — ruke ostaju slobodne za držanje.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_03_onepoint.svg',
              title: 'Pomiči samo jednu točku',
              caption: 'Pomiči uvijek samo jednu ruku ili jednu nogu, dok '
                  'ostale tri imaju čvrst oslonac. Nemoj žuriti — ni kad '
                  'tura pritišće.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_04_steps.svg',
              title: 'Pazi na stepenice i oslonac',
              caption: 'Imaj na oku mokrinu, snijeg, ulje i prljavštinu. '
                  'Stani mirno i kontrolirano, po potrebi prije toga '
                  'očisti stepenice.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Dvije stvari koje idu uz to',
        blocks: [
          SubheadBlock('Poluvisoke zaštitne cipele'),
          ParagraphBlock(
            'Poluvisoke cipele obuhvaćaju gležanj i znatno bolje '
            'stabiliziraju skočni zglob — upravo se ondje događa uganuće '
            'pri silasku.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Već si uganuo gležanj?',
            text: 'Tko je već imao problema s gležnjem, treba zatražiti '
                'poluvisoke cipele — prije sljedeće ture, a ne poslije.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}step3p_05_phone.svg',
              title: 'Bez privatnog mobitela u ruci',
              caption: 'Telefoniranje, tipkanje i skrolanje odvlače '
                  'pažnju — upravo iz toga nastaju padovi i nezgode. '
                  'Privatni pozivi i poruke čekaju do pauze. Pri ulasku i '
                  'izlasku mobitel ide u džep.',
            ),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Ukratko zapamti',
            text: 'Licem prema vozilu · drži tri točke · ruke slobodne · '
                'poluvisoke zaštitne cipele · bez privatnog mobitela · '
                'koristi stepenice umjesto skakanja.',
          ),
        ],
      ),
    ],
  ),
];
