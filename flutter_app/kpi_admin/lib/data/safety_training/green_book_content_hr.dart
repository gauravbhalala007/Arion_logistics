// lib/data/safety_training/green_book_content_hr.dart
//
// Sadržaj Green Book obuke — hrvatska verzija.
// Struktura je istovjetna njemačkoj verziji (master): poglavlja gb1–gb6,
// iste folije, isti blokovi i iste vrijednosti.
//
// „Green Book" je knjiga kontrole vožnji: zbirka dnevnih kontrolnih
// listova prema § 1 st. 6 Fahrpersonalverordnung (FPersV — njemačka
// uredba o vozačkom osoblju).

import 'safety_blocks.dart';

const List<SafetyChapterContent> greenBookContentHr = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'gb1',
    title: 'Što je Green Book',
    summary: 'Knjiga kontrole vožnji prema § 1 st. 6 FPersV — i zašto je '
        'za tebe obvezna',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Knjiga vožnji, a ne provjera vozila',
        blocks: [
          ParagraphBlock(
            '„Green Book" je tvoja knjiga kontrole vožnji. U njoj skupljaš '
            'dnevne kontrolne listove: za svaki radni dan jedan list na '
            'kojem piše kada si vozio, kada si imao stanku i kada je '
            'počelo tvoje vrijeme odmora.',
          ),
          ParagraphBlock(
            'To izričito nije provjera vozila. Gume, svjetla i karoserija '
            'dokumentiraju se na drugom mjestu. U Green Booku radi se '
            'isključivo o vremenima — o tvojim vremenima.',
          ),
          BulletsBlock([
            'Jedan list po danu, za svaki dan u kojem voziš vozilo koje '
                'podliježe obvezi evidentiranja',
            'Vodi se rukom, trajnim zapisom i potpisano',
            'Dokazuje da si se držao vremena vožnje, stanki i vremena '
                'odmora',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ukratko',
            text: 'Green Book odgovara na jedno jedino pitanje: kada si bio '
                'za volanom, a kada nisi? Sve ostalo tu ne spada.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tko mora evidentirati',
        blocks: [
          ParagraphBlock(
            'Obveza proizlazi iz § 1 st. 6 Fahrpersonalverordnung (FPersV '
            '— njemačka uredba o vozačkom osoblju). Ne veže se uz tebe '
            'osobno, nego uz vozilo i svrhu vožnje: gospodarski prijevoz '
            'tereta vozilom najveće dopuštene mase iznad 2,8 t do 3,5 t. '
            'To je upravo tipično dostavno vozilo.',
          ),
          FactsBlock([
            FactItem('ispod 2,8 t', 'nema obveze evidentiranja prema § 1 '
                'st. 6 FPersV'),
            FactItem('2,8–3,5 t', 'dnevni kontrolni list — tvoj Green Book'),
            FactItem('od 3,5 t', 'digitalni tahograf umjesto papirnatog '
                'lista'),
          ]),
          ParagraphBlock(
            'Mjerodavna je najveća dopuštena masa iz prometne dozvole '
            '(Fahrzeugschein) — a ne koliko je vozilo danas stvarno '
            'natovareno. Napola prazno vozilo od 3,5 t i dalje podliježe '
            'obvezi evidentiranja.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Pravna osnova',
            text: '§ 1 st. 6 FPersV obvezuje te da evidentiraš vremena '
                'vožnje, prekide vožnje te radna vremena i vremena odmora. '
                'Voziš li bez tog lista, kršiš uredbu — neovisno o tome '
                'jesi li se držao vremena.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Čemu evidencija služi',
        blocks: [
          ParagraphBlock(
            'Propis nije sam sebi svrha. Postoji jer su premoreni vozači '
            'opasni u prometu — za sebe i za sve druge. List čini vidljivim '
            'jesu li tvoji radni dani uopće planirani tako da se mogu '
            'ispoštovati.',
          ),
          BulletsBlock([
            'Zaštita od premorenosti: tko stanku mora dokumentirati, prije '
                'će je i stvarno napraviti',
            'Dokaz za tebe: list potvrđuje da si vozio ispravno — i mjesece '
                'kasnije',
            'Dokaz protiv tvrdnji: bez evidencije tvoje sjećanje stoji '
                'nasuprot pretpostavci kontrole',
            'Podloga za planiranje tura: stalno prekratko planirane ture '
                'vide se na listu',
          ]),
          RevealBlock(
            prompt: 'Primjer iz prakse: danas si se držao vremena — stanka '
                'na vrijeme, kraj smjene na vrijeme. Samo list nisi ispunio '
                'jer je ionako sve bilo u redu. Kontrola poslijepodne. Je '
                'li to problem?',
            answer: 'Da. Obveza evidentiranja znači: sam dokaz je obveza. '
                'Jesi li se stvarno držao vremena, nitko na cestovnoj '
                'kontroli ne može utvrditi — nema se što predočiti. Sa '
                'stajališta kontrole, list koji nedostaje tretira se jednako '
                'kao i prekoračeno vrijeme: postoji prekršaj i on se '
                'sankcionira. Tvoje pridržavanje koristi ti samo ako ga '
                'možeš dokazati.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista: osnovno razumijevanje',
        blocks: [
          ChecklistBlock(
            title: 'Ovo nosim iz 1. poglavlja',
            items: [
              'Znam da Green Book dokumentira vremena, a ne stanje vozila',
              'Znam pravnu osnovu: § 1 st. 6 FPersV',
              'Znam da su obuhvaćena vozila iznad 2,8 t do 3,5 t',
              'Znam da se računa najveća dopuštena masa, a ne trenutna '
                  'težina tereta',
              'Znam da od 3,5 t vrijedi digitalni tahograf',
              'Jasno mi je da je list koji nedostaje već sam po sebi '
                  'prekršaj',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Rečenica za turu',
            text: '„Što nisam zapisao, ne mogu dokazati."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'gb2',
    title: 'Što se točno upisuje',
    summary: 'Svi obvezni podaci — i kako ih uredno ispunjavaš',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Obvezni podaci na listu',
        blocks: [
          ParagraphBlock(
            'Dnevni kontrolni list dokaz je samo ako su na njemu svi '
            'propisani podaci. Nedostaje li jedan od njih, list se smatra '
            'nepotpunim — s istim posljedicama kao i list koji nedostaje.',
          ),
          BulletsBlock([
            'Prezime, ime i adresa vozača',
            'Službena registarska oznaka vozila',
            'Datum dana',
            'Stanje kilometara na početku i na kraju vožnje',
            'Mjesto početka i mjesto završetka vožnje',
            'Vremena vožnje i vremena odmora s navedenim satima',
            'Prekidi vožnje (stanke)',
            'Tvoj potpis',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Potpuno znači potpuno',
            text: '§ 1 st. 6 FPersV navodi podatke taksativno. List bez '
                'registarske oznake, bez adrese ili bez potpisa ne '
                'ispunjava obvezu evidentiranja — čak i ako su vremena '
                'ispravno upisana.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ispunjavanje korak po korak',
        blocks: [
          ParagraphBlock(
            'Redoslijed u nastavku namjerno je odabran tako da ništa ne '
            'zaboraviš: prvo stalni podaci, zatim vremena tijekom dana, na '
            'kraju zaključivanje.',
          ),
          StepsBlock([
            'Prije polaska: upiši datum, prezime, ime, adresu i '
                'registarsku oznaku',
            'Očitaj stanje kilometara s brojila i upiši ga kao početno '
                'stanje — nemoj procjenjivati',
            'Upiši mjesto početka vožnje (depo, lokacija, naziv mjesta)',
            'Upiši početak vremena vožnje s točnim satom, čim krećeš',
            'Svaki prekid vožnje upiši odmah, s početkom i krajem — ne tek '
                'navečer',
            'Na kraju ture: upiši mjesto završetka vožnje i završno stanje '
                'kilometara',
            'Upiši kraj vremena vožnje i početak vremena odmora',
            'Pročitaj list, provjeri ima li praznina i potpiši ga',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Piši trajnim zapisom',
            text: 'Kemijska olovka, ne grafitna. Upis koji se može '
                'izbrisati gumicom nije dokaz. Pogreška u pisanju precrta '
                'se jednom crtom i pored se napiše ispravno — ne prelakira '
                'se i ne prelijepi.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Uredno upisivanje vremena',
        blocks: [
          ParagraphBlock(
            'Najviše se griješi kod vremena. Svaki vremenski blok dana '
            'ide u vlastiti redak, s vremenom od–do. Ovako izgleda normalan '
            'dostavni dan:',
          ),
          TableBlock(
            headers: ['Od–do', 'Vrsta', 'Napomena'],
            rows: [
              ['06:30–07:00', 'Radno vrijeme', 'Utovar u depou, još nije '
                  'vrijeme vožnje'],
              ['07:00–11:30', 'Vrijeme vožnje', '4,5 sata — sada slijedi '
                  'stanka'],
              ['11:30–12:15', 'Prekid vožnje', '45 minuta u komadu'],
              ['12:15–16:45', 'Vrijeme vožnje', 'drugi blok, ukupno 9 sati'],
              ['16:45–17:15', 'Radno vrijeme', 'predaja, povrati, '
                  'zaključivanje'],
              ['od 17:15', 'Vrijeme odmora', 'najmanje 11 sati do sljedećeg '
                  'starta'],
            ],
          ),
          BulletsBlock([
            'Vrijeme vožnje je samo vrijeme za volanom dok vozilo vozi',
            'Utovar i istovar, skeniranje, čekanje na stajalištu radno je '
                'vrijeme, ali nije vrijeme vožnje',
            'Prekid vožnje stanka je samo ako u to vrijeme stvarno ne radiš',
          ]),
          RevealBlock(
            prompt: 'Primjer iz prakse: stojiš 40 minuta na rampi i čekaš '
                'da se istovari. Sjediš u kabini i ne radiš ništa. Smiješ '
                'li to upisati kao prekid vožnje?',
            answer: 'Samo ako tim vremenom stvarno možeš slobodno '
                'raspolagati i ne obavljaš nikakav rad — i ako to znaš '
                'unaprijed. Moraš li biti stalno na raspolaganju jer se '
                'svakog trena može krenuti dalje, to je vrijeme čekanja, a '
                'ne stanka. Uobičajena zabluda: „Nisam ništa radio, dakle '
                'bila je stanka." Presudno nije jesi li se kretao, nego '
                'jesi li mogao raspolagati tim vremenom. U dvojbi upisuješ '
                'radno vrijeme — to je uvijek sigurna strana.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista: je li list potpun?',
        blocks: [
          ChecklistBlock(
            title: 'Prije nego što potpišem',
            items: [
              'Prezime, ime i adresa su upisani',
              'Registarska oznaka odgovara vozilu kojim sam vozio',
              'Datum je upisan',
              'Početno i završno stanje kilometara očitani su s brojila',
              'Mjesto početka i završetka vožnje su upisani',
              'Sva vremena vožnje upisana su s vremenom od–do',
              'Svi prekidi vožnje su upisani',
              'Početak vremena odmora je upisan',
              'Sve kemijskom olovkom, bez brisanja, bez praznina',
              'Potpis je stavljen',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'gb3',
    title: 'Vremena vožnje, stanke, odmori',
    summary: 'Brojke kojih se tvoj radni dan mora držati',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Brojke koje se broje',
        blocks: [
          ParagraphBlock(
            'Green Book dokumentira vremena — ali samo zato da se može '
            'provjeriti jesi li se držao granica. Te granice moraš imati u '
            'glavi, a ne samo na papiru.',
          ),
          FactsBlock([
            FactItem('9 h', 'vrijeme vožnje po danu u pravilu'),
            FactItem('10 h', 'dvaput tjedno dopušteno kao iznimka'),
            FactItem('4,5 h', 'vožnje u komadu, potom slijedi stanka'),
          ]),
          FactsBlock([
            FactItem('45 min', 'prekid vožnje nakon 4,5 sata'),
            FactItem('15 + 30', 'dopuštena podjela — tim redoslijedom'),
            FactItem('11 h', 'dnevno vrijeme odmora, najmanje'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Što propis zahtijeva',
            text: 'Vrijeme vožnje iznosi najviše 9 sati dnevno, dvaput '
                'tjedno smije se produljiti na 10 sati. Nakon najviše 4,5 '
                'sata vožnje treba napraviti prekid vožnje od najmanje 45 '
                'minuta. Dnevno vrijeme odmora iznosi najmanje 11 sati.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kako pravilno postaviti stanku',
        blocks: [
          ParagraphBlock(
            '45 minuta je normalan slučaj. Smiješ ih podijeliti — ali samo '
            'na točno dva dijela i samo određenim redoslijedom: prvo '
            'najmanje 15 minuta, zatim najmanje 30 minuta. Obrnuto se ne '
            'priznaje.',
          ),
          DoDontBlock(
            doTitle: 'Ovako je stanka valjana',
            dos: [
              '45 minuta u komadu nakon najviše 4,5 sata vožnje',
              'Ili prvo 15 minuta, potom 30 minuta',
              'Oba dijela unutar istog bloka od 4,5 sata',
              'Oba dijela upisana u list s vremenom od–do',
            ],
            dontTitle: 'Ovako se ne priznaje',
            donts: [
              'Prvo 30 minuta pa 15 minuta — pogrešan redoslijed',
              'Tri kratke stanke od po 15 minuta',
              'Dvaput po 20 minuta — drugi dio je prekratak',
              'Stanka tek nakon 5 sati vožnje jer je stajalište bolje '
                  'odgovaralo',
            ],
          ),
          BulletsBlock([
            'Tih 4,5 sati čisto je vrijeme vožnje — stajanja s dostavom se '
                'ne broje',
            'Stanka mora biti prije prekoračenja, a ne poslije',
            'Nakon potpunog prekida počinje novi blok od 4,5 sata',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Najčešća pogreška u razmišljanju',
            text: 'Stanka ne slijedi kad si 4,5 sata na poslu, nego kad si '
                '4,5 sata vozio. Tko računa po radnom vremenu, stanku '
                'najčešće napravi prerano — a onda još jednom prekasno.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Računanje u dostavnoj svakodnevici',
        blocks: [
          ParagraphBlock(
            'U svakodnevici ne računaš s jednim blokom, nego s mnogo '
            'kratkih vožnji između stajališta. Zbroji ih — one čine tvoje '
            'vrijeme vožnje.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: krećeš u 07:00. Do 09:30 sjediš 2 '
                'sata za volanom, ostatak si na stajalištima. Do 12:00 '
                'dolaze još 2 sata vožnje, do 13:00 još 30 minuta. Kada '
                'stanka najkasnije slijedi?',
            answer: 'U 13:00. U tom trenutku dosegao si 2 + 2 + 0,5 = 4,5 '
                'sata čistog vremena vožnje — sada ne smiješ prijeći ni '
                'metar prije nego što odradiš prekid vožnje. Uobičajena '
                'zabluda bila bi računati šest sati radnog vremena od 07:00 '
                'i staviti stanku na 11:30. Sat koji se broji radi samo dok '
                'vozilo vozi.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: ovaj tjedan si već dvaput vozio 10 '
                'sati. Danas je petak, na 8,5 sati si vremena vožnje i imaš '
                'još dva stajališta, ukupno oko 40 minuta vožnje. Ide li to '
                'još?',
            answer: 'Ne. Produljenje na 10 sati smiješ koristiti samo '
                'dvaput tjedno, a to je potrošeno. Danas ponovno vrijedi '
                'redovna granica od 9 sati — ostaje ti dakle 30 minuta '
                'vožnje, a ne 40. Voziš do stajališta koje možeš dosegnuti, '
                'ostatak javljaš disponentu i završavaš vrijeme vožnje. '
                'Uobičajena zabluda: „Tih 10 sati pripada mi svaki dan." '
                'Ona su iznimka s tjednim kontingentom.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista: vremena pod kontrolom',
        blocks: [
          ChecklistBlock(
            title: 'Ovo nosim iz 3. poglavlja',
            items: [
              'Znam da je 9 sati vremena vožnje pravilo',
              'Znam da je 10 sati dopušteno samo dvaput tjedno',
              'Tih 4,5 sati brojim kao čisto vrijeme vožnje, a ne kao radno '
                  'vrijeme',
              'Radim najmanje 45 minuta prekida vožnje',
              'Stanku dijelim najviše na 15 + 30 minuta, tim redoslijedom',
              'Držim se najmanje 11 sati dnevnog vremena odmora',
              'Svaku stanku upisujem odmah, a ne navečer',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Zapamti',
            text: '4,5 – 45 – 9 – 11. Četiri brojke koje strukturiraju tvoj '
                'dan. Tko ih zna, ne mora računati, nego samo zapisivati.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'gb4',
    title: 'Tipične pogreške pri ispunjavanju',
    summary: 'Šest pogrešaka koje se primijete na svakoj kontroli',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Šest najčešćih pogrešaka',
        blocks: [
          ParagraphBlock(
            'Gotovo svi osporeni listovi ne padaju zbog vremena, nego zbog '
            'načina na koji su vođeni. Ovih šest pogrešaka čine inače '
            'ispravan list bezvrijednim.',
          ),
          DoDontBlock(
            doTitle: 'Ovako list vodiš ispravno',
            dos: [
              'Svaki upis radiš odmah, kad vremenski blok završi',
              'Koristiš kemijsku olovku, trajni zapis',
              'Stanke upisuješ sa stvarnim vremenom od–do',
              'Stanje kilometara očitavaš s brojila',
              'Na kraju dana potpisuješ',
              'List ostaje u vozilu, kod tebe',
            ],
            dontTitle: 'Ovako će list biti osporen',
            donts: [
              'Cijeli tjedan naknadno upisuješ u petak navečer',
              'Pišeš grafitnom olovkom da bi mogao „kasnije ispraviti"',
              'Stanke procjenjuješ („otprilike tri četvrt sata")',
              'Stanje kilometara pišeš napamet',
              'Zaboraviš potpis',
              'Listove ostavljaš kod kuće ili u depou',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Najskuplja pogreška je ona najudobnija',
            text: 'Naknadno ispunjavanje djeluje bezopasno — to je '
                'pogreška koja najbrže ispliva i najteže se vrednuje.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Zašto se naknadni upisi primijete',
        blocks: [
          ParagraphBlock(
            'List napisan naknadno u jednom komadu izgleda drukčije od '
            'onoga koji je nastajao tijekom dana. Kontrolori svakodnevno '
            'vide oboje i razliku prepoznaju odmah.',
          ),
          BulletsBlock([
            'Isti rukopis, ista olovka, isti pritisak kroz sve retke',
            'Upadljivo okrugla vremena: sve završava na pune i pola sata',
            'Stanja kilometara koja ne odgovaraju upisanoj relaciji',
            'Podaci koji proturječe otpremnicama, skeniranjima ili '
                'računima za gorivo',
            'Stanke koje uvijek traju točno 45 minuta — i u danima u kojima '
                'to nije bilo moguće',
          ]),
          ParagraphBlock(
            'Uz to: pri kontroli u tvrtki listovi leže uz ostalu '
            'dokumentaciju. Proturječja ne primjećuješ ti, nego tijelo '
            'nadzora.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Netočno je gore od praznog',
            text: 'Nepotpun list prekršaj je obveze evidentiranja. Namjerno '
                'netočno ispunjen list više je od toga — tu više nije riječ '
                'samo o prekršaju, nego o pitanju obmane. Radije upiši da '
                'si vozio predugo nego da izmisliš vrijeme.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: u četvrtak primijetiš da u utorak '
                'nije upisana stanka za ručak. Točno se sjećaš: 12:10 do '
                '12:55. Što radiš?',
            answer: 'Upisuješ je naknadno — ali vidljivo kao naknadni upis, '
                's datumom dopune i kratkom napomenom, i obavještavaš svog '
                'disponenta. Poštena, prepoznatljiva ispravka dopuštena je '
                'i znatno bolja od praznine. Uobičajena zabluda bila bi '
                'ubaciti upis tako kao da je nastao u utorak — upravo to je '
                'korak od nemara do krivotvorenja.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista: uredno vođeno',
        blocks: [
          ChecklistBlock(
            title: 'Moj list izdržava kontrolu',
            items: [
              'Svaki vremenski blok upisujem odmah, a ne navečer',
              'Pišem kemijskom olovkom',
              'Vremena i stanja kilometara očitavam umjesto da ih '
                  'procjenjujem',
              'Potpisujem svaki list',
              'Moji listovi uvijek su kod mene u vozilu',
              'Ispravke radim vidljivo i s datumom, nikad nevidljivo',
              'Radije upišem prekršaj nego da izmislim vrijeme',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'gb5',
    title: 'Nošenje, predaja, čuvanje',
    summary: '28 dana kod vozača, godinu dana u tvrtki',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Dva roka',
        blocks: [
          ParagraphBlock(
            'Ispunjen list vrijedi nešto tek kad je u pravom trenutku na '
            'pravom mjestu. Za to postoje dva roka koja moraš razlikovati.',
          ),
          FactsBlock([
            FactItem('28 dana', 'vozač nosi evidencije sa sobom'),
            FactItem('1 godina', 'poduzetnik ih čuva u tvrtki'),
          ]),
          BulletsBlock([
            'Tih 28 dana odnosi se na tebe: moraš imati sa sobom evidencije '
                'tekućeg dana i prethodnih 28 dana',
            'Godišnji rok odnosi se na tvrtku: ona mora listove čuvati '
                'godinu dana i predočiti ih na zahtjev',
            'Oboje vrijedi istodobno — listovi odlaze u arhivu tek nakon '
                'isteka obveze nošenja',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Obveza nošenja',
            text: 'Evidencije posljednjih 28 dana spadaju u vozilo — ne u '
                'ormarić, ne kući i ne u ured. Nedostaju li na kontroli, ne '
                'pomaže to što su uredno vođene.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Cestovna kontrola',
        blocks: [
          ParagraphBlock(
            'Kontrolu provodi BAG — Bundesamt für Logistik und Mobilität, '
            'Savezni ured za logistiku i mobilnost — te policija. Oboje '
            'smiju kontrolirati uz cestu, BAG dodatno i u tvrtki.',
          ),
          StepsBlock([
            'Zaustavi se, ugasi motor, spusti prozor, ruke drži na vidiku',
            'Ostani smiren — kontrola je rutina, a ne sumnja',
            'Predoči vozačku dozvolu, dokumente vozila i evidencije '
                'posljednjih 28 dana',
            'Na pitanja odgovaraj stvarno, ništa ne izmišljaj i ništa ne '
                'ukrašavaj',
            'Kod prigovora: pusti da se slučaj zapisnički evidentira, '
                'nemoj raspravljati',
            'Nakon toga obavijesti disponenta i dokumentiraj slučaj u '
                'tvrtki',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Priprema pobjeđuje objašnjavanje',
            text: 'Kontrola traje nekoliko minuta ako listovi potpuni leže '
                'u vozilu. Sve drugo košta tebe i tvrtku cijelo '
                'poslijepodne.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: uz cestu kontrolor traži '
                'posljednjih 28 dana. Sa sobom imaš samo tekući tjedan — '
                'starije listove uredno si predao u depou. Je li to '
                'dovoljno?',
            answer: 'Ne. Obveza nošenja obuhvaća tekući dan i prethodnih 28 '
                'dana. To što stariji listovi uredno leže u tvrtki '
                'ispunjava obvezu čuvanja, ali ne i obvezu nošenja — to su '
                'dvije odvojene obveze. Ispravno je: preslike ili izvornici '
                'posljednjih 28 dana ostaju kod tebe, tek nakon toga idu u '
                'arhivu. Dogovori s disponentom kako to organizirate u '
                'tvrtki.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Predaja u tvrtki',
        blocks: [
          ParagraphBlock(
            'Poduzetnik svoju obvezu čuvanja može ispuniti samo ako listove '
            'i dobije. Zato predaja nije administrativna sitnica, nego dio '
            'tvoje obveze evidentiranja.',
          ),
          BulletsBlock([
            'Listove predaj u cijelosti nakon isteka roka nošenja, a ne u '
                'hrpi na kraju mjeseca',
            'Ništa ne bacaj, ni listove s pogreškama ili ispravcima',
            'Nedostaje li ti list, reci to odmah — prijavljena praznina '
                'bolja je od otkrivene',
            'Dane godišnjeg, bolovanja i uredske dane nemoj jednostavno '
                'izostaviti, nego ih označi prema uputi tvrtke',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Praznine ostaju praznine',
            text: 'Dan bez lista kasnije se ne može rekonstruirati. Tko '
                'predaju zapušta, proizvodi upravo one praznine koje se '
                'primijete pri kontroli u tvrtki.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista: dokumentacija pod kontrolom',
        blocks: [
          ChecklistBlock(
            title: 'Prije svake smjene i nakon svakog tjedna',
            items: [
              'Evidencije posljednjih 28 dana su u vozilu',
              'Današnji list je započet i nadohvat ruke',
              'Vozačka dozvola i dokumenti vozila su sa mnom',
              'Istekle listove predao sam u tvrtki',
              'Nijedan list nisam bacio, ni one s ispravcima',
              'Znam koga moram obavijestiti pri kontroli',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'gb6',
    title: 'Posljedice kod prekršaja',
    summary: 'Novčana kazna, odgovornost tvrtke, interna eskalacija',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Što prijeti pravno',
        blocks: [
          ParagraphBlock(
            'Dnevni kontrolni list koji nedostaje ili je nepotpun jest '
            'prekršaj. Koliko će novčana kazna iznositi ovisi o tome koliko '
            'je prekršaj težak i koliko se često ponavlja.',
          ),
          FactsBlock([
            FactItem('od 100 €', 'novčana kazna kod listova koji nedostaju '
                'ili su nepotpuni'),
            FactItem('ovisno o težini', 'viši iznosi kod višestrukih ili '
                'ponovljenih prekršaja'),
          ]),
          BulletsBlock([
            'Pogođen nije samo vozač — i tvrtka snosi odgovornost za '
                'evidencije',
            'Kod teških ili ponovljenih prekršaja prijeti postupak o '
                'pouzdanosti tvrtke',
            'Kontrolu provode BAG i policija, uz cestu i u tvrtki',
            'Prigovori iz kontrole u tvrtki pogađaju sve vozače, a ne samo '
                'kontroliranog',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Dva adresata, jedna obveza',
            text: 'FPersV obvezuje vozača i poduzetnika zajedno: ti moraš '
                'evidentirati i nositi dokumente, tvrtka mora čuvati i '
                'nadzirati. Zakaže li jedno od toga, odgovara ona strana '
                'koja je za to zadužena.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Eskalacija u tvrtki',
        blocks: [
          ParagraphBlock(
            'Neovisno o tome utvrdi li neko tijelo nešto, u tvrtki vrijedi '
            'čvrst redoslijed. Jednak je za sve i dokumentira se.',
          ),
          StepsBlock([
            'Prvi stupanj: usmena opomena od strane disponenta',
            'Drugi stupanj: pisana opomena u osobnom dosjeu',
            'Treći stupanj: radnopravne posljedice do otkaza',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Prekršaj je list koji nedostaje',
            text: 'Stupnjevi teku neovisno o tome je li se nešto dogodilo '
                'ili je li bilo kontrole. Već nevođeni list jest prekršaj.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: disponent gura: „Odvezi još ta dva '
                'stajališta, stanku jednostavno upiši, inače nećemo '
                'stići." Što vrijedi?',
            answer: 'Uputa ne mijenja ništa u tvojoj obvezi. Ti si taj koji '
                'evidentira i potpisuje — svojim potpisom potvrđuješ '
                'sadržaj. Usmena uputa ne štiti te ni na kontroli ni '
                'kasnije u tvrtki. Ispravno je: napravi stanku, ispravno je '
                'upiši, javi preostala stajališta i dokumentiraj uputu. '
                'Tvrtka je dužna omogućiti pridržavanje propisa — a ne '
                'zaobilaziti ga.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista: zaključak',
        blocks: [
          ChecklistBlock(
            title: 'Ovo nosim iz obuke',
            items: [
              'Green Book je knjiga kontrole vožnji prema § 1 st. 6 FPersV',
              'Znam sve obvezne podatke i ispunjavam ih u cijelosti',
              'Držim se 9 h vremena vožnje, 4,5 h do stanke, 45 min prekida '
                  'i 11 h odmora',
              'Upisujem odmah, kemijskom olovkom, i potpisujem',
              'Nosim sa sobom evidencije posljednjih 28 dana',
              'Istekle listove predajem u tvrtki',
              'Znam da list koji nedostaje može izazvati novčanu kaznu od '
                  '100 eura naviše',
              'Znam da uputa ne ukida moju obvezu evidentiranja',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Rečenica za turu',
            text: '„List piše zajedno sa mnom dok vozim — a ne kad '
                'završim."',
          ),
        ],
      ),
    ],
  ),
];
