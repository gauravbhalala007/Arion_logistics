// lib/data/safety_training/privacy_content_hr.dart
//
// Sadržaj obuke o zaštiti podataka — hrvatska verzija.
// Prijevod datoteke privacy_content_de.dart (master). Struktura je
// istovjetna njemačkoj verziji: poglavlja ds1–ds6, iste folije, isti
// blokovi i iste vrijednosti — kod izmjena držati usklađeno s masterom.
// Pravni pojmovi ostaju u izvornom obliku (npr. „Art. 5 DSGVO",
// § 26 BDSG, GeschGehG), uz kratko hrvatsko objašnjenje gdje ga daje i
// njemački original. Za ovu temu nema ilustracija, stoga `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> privacyContentHr = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ds1',
    title: 'Zašto se zaštita podataka tiče tebe',
    summary: 'Osobni podaci u svakodnevnoj dostavi i načela iz '
        'Art. 5 DSGVO (GDPR)',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Cijeli dan radiš s tuđim podacima',
        blocks: [
          ParagraphBlock(
            'Zaštita podataka zvuči kao ured, ormar s dokumentima i '
            'odvjetnik. U stvarnosti gotovo nitko nije tako blizu osobnim '
            'podacima kao ti. Od prvog skeniranja ujutro do zadnjeg '
            'stajališta navečer u rukama imaš tuđa imena, adrese i brojeve '
            'telefona — a uz to i fotografije tuđih ulaznih vrata.',
          ),
          ParagraphBlock(
            'Osobni je podatak svaki podatak po kojem se neka osoba može '
            'odrediti. Ne samo ime: i kombinacija adrese, vremena i '
            'sadržaja paketa govori nešto o nekom čovjeku. Upravo zato za '
            'to vrijede pravila.',
          ),
          BulletsBlock([
            'Imena primatelja i adrese na etiketi, skeneru i listi',
            'Brojevi telefona za kontakt prije dostave',
            'Potpisi na skeneru kao potvrda primitka',
            'Fotografije kao dokaz o dostavi ispred vrata',
            'Podaci o lokaciji skenera i vozila',
            'Podaci o susjedima kod kojih si ostavio paket',
            'Napomene poput „paket molim iza kante za smeće" — i to je '
                'informacija o stambenoj situaciji nekog čovjeka',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ukratko',
            text: 'Sve što saznaš o primatelju, saznao si samo zato što mu '
                'dostavljaš paket. Ni za što drugo tu informaciju nisi '
                'dobio.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tri načela koja se broje u svakodnevici',
        blocks: [
          ParagraphBlock(
            'Art. 5 DSGVO postavlja šest načela. Tri od njih praktički '
            'svaki dan odlučuju o tome postupaš li ispravno ili pogrešno. '
            'Jednostavnim jezikom:',
          ),
          TableBlock(
            headers: ['Načelo', 'Što to znači za tebe'],
            rows: [
              [
                'Ograničenje svrhe',
                'Podatke koristi samo za svrhu za koju si ih dobio: '
                    'dostavu. Ne za privatne stvari.',
              ],
              [
                'Minimizacija podataka',
                'Prikupljaj i pokazuj samo onoliko koliko je nužno. Ni '
                    'fotografija više nego što treba, ni lista dulja nego '
                    'što treba.',
              ],
              [
                'Povjerljivost',
                'Ono što vidiš ostaje kod tebe i u tvrtki. Ne u '
                    'chat-grupi, ne za kuhinjskim stolom, ne na internetu.',
              ],
            ],
          ),
          ParagraphBlock(
            'Uz to dolaze točnost (pogrešne podatke ispraviti umjesto '
            'vući ih dalje), ograničenje pohrane (ništa ne čuvati dulje '
            'nego što je potrebno) i pouzdanost — obveza dokazivanja '
            'usklađenosti; ta se posljednja točka tiče tvrtke i razlog je '
            'za ovu obuku.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Pravna osnova',
            text: 'Art. 5 Abs. 1 DSGVO zahtijeva, među ostalim, '
                'ograničenje svrhe (lit. b), minimizaciju podataka '
                '(lit. c) te cjelovitost i povjerljivost (lit. f). Ta '
                'načela vrijede za svakoga tko u ime tvrtke radi s '
                'osobnim podacima — dakle i za tebe na turi.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Zašto postoji ova obuka',
        blocks: [
          ParagraphBlock(
            'U DSGVO-u (GDPR) nigdje doslovno ne piše „zaposlenici moraju '
            'biti obučeni". On to ipak zahtijeva — samo preko tri druga '
            'puta. Zato sjediš ovdje i zato se završetak dokumentira.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Odakle proizlazi obveza obuke',
            text: 'Art. 32 DSGVO obvezuje tvrtku na tehničke i '
                'organizacijske mjere za sigurnost obrade — obučeni '
                'zaposlenici jedna su takva mjera. Art. 39 Abs. 1 lit. b '
                'DSGVO izričito navodi podizanje svijesti i obuku kao '
                'zadaću službenika za zaštitu podataka. A Art. 5 Abs. 2 '
                'DSGVO zahtijeva da tvrtka može dokazati usklađenost — '
                'pouzdanost.',
          ),
          ParagraphBlock(
            'Nadzorna tijela kod provjere na to pomno gledaju. Nedostatak '
            'obuke zaposlenika redovito ocjenjuju kao znak da mjere nisu '
            'bile dovoljne — pogotovo onda kad se već nešto dogodilo. '
            'Nakon povrede podataka prvo je pitanje gotovo uvijek: jesu '
            'li ljudi bili obučeni i možete li to dokazati?',
          ),
          BulletsBlock([
            'Godišnja osnovna obuka za sve — tvoj završetak vrijedi '
                'dvanaest mjeseci',
            'Izvanredna obuka kad se nešto promijeni ili kad se nešto '
                'dogodilo',
            'Uvođenje novih zaposlenika prije prvog samostalnog dana',
            'Dokumentiranje testa i potpisa kao dokaz prema '
                'Art. 5 Abs. 2 DSGVO',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Gdje u svakodnevici prolazi granica',
        blocks: [
          RevealBlock(
            prompt: 'Primjer: Na tvojoj se turi nalazi paket za poznatog '
                'nogometaša iz regije. Navečer u društvu prijatelja '
                'ispričaš u kojoj ulici stanuje — ništa više, bez imena na '
                'društvenim mrežama, samo među prijateljima. Je li to '
                'povreda zaštite podataka?',
            answer: 'Da. Adresa je osobni podatak, a znaš je isključivo '
                'sa svog posla. Proslijediti je trećima krši ograničenje '
                'svrhe (Art. 5 Abs. 1 lit. b DSGVO) i povjerljivost '
                '(lit. f). Bliska je zabluda da se privatni krug „ne '
                'računa" — DSGVO ne pita koliko je velika tvoja publika, '
                'nego jesi li podatke otkrio protivno svrsi. Ako netko od '
                'tvojih prijatelja to ispriča dalje, uz to više nemaš '
                'nikakvu kontrolu.',
          ),
          DoDontBlock(
            doTitle: 'Ispravno',
            dos: [
              'Podatke primatelja koristiti samo za dostavu i nakon toga '
                  'ih ostaviti u sustavu',
              'Kod upita o pošiljci uputiti na disponenta ili upravu',
              'Skener i papirnatu listu držati tako da treće osobe ne '
                  'mogu čitati',
              'Nejasne situacije iznijeti umjesto da sam odlučuješ',
            ],
            dontTitle: 'Pogrešno',
            donts: [
              'Adrese ili imena prepričavati u privatnom okruženju — ni '
                  '„samo među prijateljima"',
              'Slavne osobe ili upadljive pošiljke pretvarati u temu '
                  'razgovora',
              'Podatke primatelja pretraživati iz znatiželje, bez radnog '
                  'naloga za to',
              'Oslanjati se na to da „to ionako nitko neće saznati"',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista — 1. poglavlje',
        blocks: [
          ParagraphBlock(
            'Prođi kratko kroz točke. Ako kod neke zastaneš, prolistaj '
            'još jednom natrag — u testu dolaze upravo te situacije.',
          ),
          ChecklistBlock(
            title: 'Ovo nosim iz 1. poglavlja',
            items: [
              'Znam koji su podaci na mojoj turi osobni podaci',
              'Poznajem ograničenje svrhe, minimizaciju podataka i '
                  'povjerljivost',
              'Znam da podaci primatelja ne idu u privatni život',
              'Znam zašto se ova obuka dokumentira '
                  '(Art. 5 Abs. 2 DSGVO)',
              'Jasno mi je da se obuka ponavlja svake godine',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ds2',
    title: 'Fotografije i dokazi o dostavi',
    summary: 'Što smije na sliku, što ne — i kamo fotografija pripada',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Fotografija ima točno jednu svrhu',
        blocks: [
          ParagraphBlock(
            'Fotografija dostave treba odgovoriti na jedno jedino '
            'pitanje: gdje leži paket? Ništa drugo. Sve što ide preko '
            'toga više je informacija nego što je potrebno — a time i '
            'povreda minimizacije podataka.',
          ),
          ParagraphBlock(
            'U praksi to znači: kameru dolje na paket, dovoljno blizu da '
            'se prepozna mjesto odlaganja i dovoljno daleko od svega što '
            'prikazuje ljude ili ih čini prepoznatljivima.',
          ),
          DoDontBlock(
            doTitle: 'Smije na sliku',
            dos: [
              'Sam paket na mjestu odlaganja',
              'Dio zida kuće, vrata ili stube kao prostorna referenca',
              'Kućni broj, ako je potreban za identifikaciju',
              'Kod dozvole za odlaganje: dogovoreno mjesto odlaganja',
            ],
            dontTitle: 'Ne smije na sliku',
            donts: [
              'Osobe — ni primatelj, ni netko snimljen s leđa',
              'Registarske oznake parkiranih vozila',
              'Prozori, balkoni i pogledi u unutarnje prostore',
              'Djeca, kućni ljubimci, posjetitelji, susjedi u pozadini',
              'Natpisi s imenima trećih osoba, ako ne pripadaju pošiljci',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Pravna osnova',
            text: 'Art. 5 Abs. 1 lit. c DSGVO zahtijeva minimizaciju '
                'podataka: podaci moraju biti primjereni svrsi i '
                'ograničeni na nužnu mjeru. Fotografija koja prikazuje '
                'osobe, registarske oznake ili unutrašnjost stana prelazi '
                'svrhu „dokaz o dostavi". Kod prikazanih osoba dodatno '
                'vrijedi pravo na vlastitu sliku.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kamo fotografija pripada — a kamo ne',
        blocks: [
          ParagraphBlock(
            'Jednako je važno kao sadržaj slike i mjesto pohrane. '
            'Fotografija nastaje u službenoj aplikaciji i tamo ostaje. U '
            'tvojoj privatnoj galeriji nema što tražiti, a u messengeru '
            'pogotovo ne.',
          ),
          BulletsBlock([
            'Fotografiraj isključivo u službenoj aplikaciji — ne najprije '
                'aplikacijom kamere pa onda učitavati',
            'Bez kopije u privatnoj galeriji, bez cloud-sigurnosne kopije '
                'privatnog mobitela',
            'Bez slanja preko WhatsAppa, Telegrama, Signala ili vozačke '
                'chat-grupe',
            'Ne čuvaj fotografiju „za svaki slučaj" za sebe — dokaz je u '
                'sustavu',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Najčešća pogreška',
            text: 'Najprije fotografirati običnom kamerom pa sliku zatim '
                'učitati u aplikaciju. Time fotografija trajno leži u '
                'tvojoj privatnoj galeriji — često dodatno i u cloudu u '
                'inozemstvu. To je nedopuštena obrada, čak i ako je nikad '
                'nikome ne pokažeš.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ako je ipak netko na slici',
        blocks: [
          ParagraphBlock(
            'Događa se: susjeda izađe kroz vrata točno u trenutku '
            'okidanja ili dijete protrči kroz kadar. To nije drama — dok '
            'god odmah reagiraš.',
          ),
          StepsBlock([
            'Fotografiju odmah izbriši prije nego što zaključiš '
                'stajalište',
            'Fotografiraj ponovno, ovaj put bez osobe na slici',
            'Ako je slika već učitana: obavijesti disponenta ili upravu '
                'da se može izbrisati iz sustava',
            'Ako nisi siguran je li netko prepoznatljiv: radije prijavi '
                'nego se nadaj',
          ]),
          RevealBlock(
            prompt: 'Primjer: Odlažeš paket u stražnjem dvorištu. Na '
                'fotografiji se vidi paket — a u pozadini, kroz prozor do '
                'poda, dnevni boravak s dvije osobe na kauču. Stajalište '
                'si već zaključio i stojiš u sljedećem dvorištu. Što ćeš '
                'učiniti?',
            answer: 'Prijavit ćeš to. Slika prikazuje unutarnji prostor i '
                'prepoznatljive osobe — time daleko prelazi svrhu „dokaz '
                'o dostavi" i mora se ukloniti iz sustava. Bliska je '
                'zabluda da se pogrešku više ne isplati prijaviti jer je '
                'stajalište već zaključeno. Upravo obrnuto: samo ako '
                'tvrtka za to zna, može izbrisati sliku i dokumentirati '
                'postupak. Tko prijavi, čini sve ispravno — tko šuti, '
                'ostavlja povredu da traje.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista — 2. poglavlje',
        blocks: [
          ChecklistBlock(
            title: 'Prije svake fotografije dostave',
            items: [
              'Fotografiram samo u službenoj aplikaciji',
              'Na slici se ne vidi nijedna osoba',
              'Bez registarske oznake, bez prozora, bez unutarnjeg '
                  'prostora na slici',
              'Paket i mjesto odlaganja jasno su prepoznatljivi',
              'Nijedna slika ne završava u mojoj privatnoj galeriji ili '
                  'u chatu',
              'Ako je slučajno netko na slici: izbrisati, ponoviti, '
                  'prijaviti',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ds3',
    title: 'Postupanje s podacima primatelja',
    summary: 'Skener, telefon i papirnate liste — službena sredstva, ne '
        'privatna stvar',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Skener i službeni mobitel nisu privatni uređaji',
        blocks: [
          ParagraphBlock(
            'Na skeneru i službenom telefonu nalaze se podaci stotina '
            'ljudi dnevno. Oba uređaja pripadaju tvrtki i služe '
            'isključivo poslu — i u pauzi, i onda kad ih nosiš kući.',
          ),
          BulletsBlock([
            'Bez privatnih aplikacija, privatnih prijava i privatnog '
                'clouda na službenom uređaju',
            'Uređaj ne davati dalje — ni nakratko kolegama, članovima '
                'obitelji ili poznanicima',
            'Zaključavanje zaslona držati aktivnim i uređaj nikad ne '
                'ostavljati bez nadzora',
            'Pri izlasku iz vozila: skener ponijeti ili sigurno '
                'spremiti, ne vidljivo na sjedalu',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Apsolutna zabrana',
            text: 'Bez screenshotova adresnih lista, pregleda tura ili '
                'podataka primatelja. Ni da ih pošalješ samom sebi, ni '
                '„kao podsjetnik". Screenshot je kopija izvan sustava — '
                'upravo ono što tvrtka više ne može kontrolirati.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Informacije susjedima i strancima',
        blocks: [
          ParagraphBlock(
            'Na vratima će te pitati. To je normalno i najčešće '
            'dobronamjerno. Ipak vrijedi: otkrivaš samo onoliko koliko je '
            'potrebno za dostavu — ne više.',
          ),
          TableBlock(
            headers: ['Situacija', 'Dokle smiješ ići'],
            rows: [
              [
                'Susjed preuzima paket',
                'Reci ime primatelja i kućni broj — više mu ne treba.',
              ],
              [
                'Susjed pita što je unutra',
                'Bez informacija. Sadržaj se tiče samo primatelja.',
              ],
              [
                'Netko pita stanuje li osoba X ovdje',
                'Bez informacija. Ne potvrđuješ adrese stanovanja.',
              ],
              [
                'Netko pita kad opet dolaziš',
                'Odgovori općenito, bez podataka o drugim pošiljkama ili '
                    'primateljima.',
              ],
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Pravna osnova',
            text: 'Prosljeđivanje podataka primatelja trećim osobama '
                'otkrivanje je u smislu Art. 4 Nr. 2 DSGVO i treba pravnu '
                'osnovu prema Art. 6 DSGVO. Za predaju paketa susjedu '
                'navođenje imena i adrese nužno je za ispunjenje ugovora '
                '— za sadržaj paketa, brojeve telefona ili informacije o '
                'drugim primateljima pravne osnove nema.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Papir je podcijenjena opasnost',
        blocks: [
          ParagraphBlock(
            'Digitalni su podaci barem zaštićeni zaključavanjem zaslona. '
            'Papir u vozilu nije. Lista ture iza vjetrobranskog stakla '
            'čitljiva je izvana — s imenima i adresama dvjesto '
            'kućanstava.',
          ),
          BulletsBlock([
            'Papirnate liste nikad ne ostavljati otvorene u vozilu, '
                'pogotovo ne vidljive kroz staklo',
            'Pri izlasku iz vozila liste ponijeti ili zaključano '
                'spremiti',
            'Na kraju ture: liste predati u tvrtki, ne nositi kući',
            'Zbrinjavanje samo predviđenim putem u tvrtki — ne u kućni '
                'otpad, ne u koš za papir na benzinskoj postaji',
            'Etikete povrata i pogrešno usmjerenih paketa tretirati '
                'jednako kao liste',
          ]),
          RevealBlock(
            prompt: 'Primjer: Gotov si s turom, lista ture samo je još '
                'stari papir. Na putu kući baciš je u kantu za papir kod '
                'svoje zgrade. Je li to u redu?',
            answer: 'Ne. Na listi su imena i adrese — osobni podaci. '
                'Moraju se zbrinuti tako da ih nitko ne može obnoviti, u '
                'pravilu preko spremnika za zaštitu podataka ili '
                'uništavača dokumenata u tvrtki. Bliska je zabluda da '
                'odrađena lista „više ništa ne vrijedi". Za zaštitu '
                'podataka to što je odrađena ne mijenja ništa: podaci su '
                'isti, a otvorena kanta za papir javno je dostupno '
                'mjesto. Uz to, listu uopće nisi smio ponijeti kući.',
          ),
          DoDontBlock(
            doTitle: 'Ispravno',
            dos: [
              'Liste predati u tvrtki i tamo ih propisno zbrinuti',
              'Zaključati skener prije nego što izađeš iz vozila',
              'Kod upita o tuđim pošiljkama uputiti na upravu',
            ],
            dontTitle: 'Pogrešno',
            donts: [
              'Izrađivati ili slati screenshotove adresnih lista',
              'Nositi liste tura kući ili ih privatno zbrinjavati',
              'Prosljeđivati podatke primatelja susjedima, poznanicima '
                  'ili trećim osobama',
              'Predavati službeni uređaj nekom drugom',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista — 3. poglavlje',
        blocks: [
          ChecklistBlock(
            title: 'Na kraju svake ture',
            items: [
              'Na mom uređaju nema screenshota adresnih podataka',
              'Skener i službeni mobitel zaključani su i sigurno '
                  'spremljeni',
              'Nijedna papirnata lista ne leži otvorena u vozilu',
              'Sve liste i etikete predane su u tvrtki',
              'Nisam proslijedio podatke primatelja trećim osobama',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ds4',
    title: 'Tvoji vlastiti podaci i podaci kolega',
    summary: 'Bolovanje, evidencija radnog vremena, personalni dosje — i '
        'tvoja prava kao ispitanika',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Zaštita podataka štiti i tebe',
        blocks: [
          ParagraphBlock(
            'Podatke u sustavu nemaju samo primatelji — imaš ih i ti. A '
            'oni su dijelom znatno osjetljiviji od adrese za dostavu.',
          ),
          BulletsBlock([
            'Pokazatelji učinka iz tvoje dostave',
            'Bolovanja i izostanci',
            'Evidencija radnog vremena, rasporedi smjena, vremena stanki',
            'Podaci o vozačkoj dozvoli i osobnoj iskaznici iz '
                'personalnog dosjea',
            'Fotografije na kojima se vidiš ti ili kolege',
          ]),
          ParagraphBlock(
            'Te podatke tvrtka smije obrađivati koliko je potrebno za '
            'radni odnos. Ne smije ih, međutim, proizvoljno prosljeđivati '
            '— a jednako tako ni ti, kad je riječ o kolegama.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Pravna osnova',
            text: 'Podaci zaposlenika obrađuju se na temelju Art. 6 '
                'Abs. 1 lit. b i f DSGVO u vezi s § 26 BDSG — dopušteno '
                'samo koliko je potrebno za radni odnos. Zdravstveni '
                'podaci poput bolovanja posebne su kategorije prema '
                'Art. 9 DSGVO i posebno su strogo zaštićeni.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Podaci kolega ne pripadaju tebi',
        blocks: [
          ParagraphBlock(
            'U depou se čuje svašta: tko je bolestan, tko je imao '
            'problema s turom, tko je dobio opomenu. Čuti je jedno — '
            'prepričavati drugo.',
          ),
          DoDontBlock(
            doTitle: 'Ispravno',
            dos: [
              'O vlastitim vrijednostima pričaj koliko god želiš',
              'Probleme s kolegom riješi izravno s njim ili s upravom',
              'Fotografiju s kolegama snimi i podijeli samo ako su svi '
                  'prikazani suglasni',
              'Uočene prekršaje prijavi interno umjesto da ih '
                  'prepričavaš po depou',
            ],
            dontTitle: 'Pogrešno',
            donts: [
              'Prosljeđivati podatke o učinku ili analize kolega',
              'Govoriti o razlogu bolovanja kolege — čak i ako ga znaš',
              'Objavljivati fotografije ili videozapise kolega u '
                  'chat-grupama bez njihova pristanka',
              'Dijeliti screenshotove internih lista ili analiza',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Posebno osjetljivo',
            text: 'Bolovanja. To da je netko bolestan zdravstveni je '
                'podatak prema Art. 9 DSGVO. Razlog pogotovo. '
                'Prosljeđivanje drugim vozačima nije dopušteno ni onda '
                'kad je dotični o tome već sam pričao.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tvoja prava kao ispitanika',
        blocks: [
          ParagraphBlock(
            'DSGVO ti daje prava prema tvom poslodavcu. Ne moraš ih '
            'obrazlagati, a njihovo korištenje ne smije ti biti na '
            'štetu.',
          ),
          TableBlock(
            headers: ['Pravo', 'Što možeš zahtijevati'],
            rows: [
              [
                'Pristup (Art. 15)',
                'Pregled toga koji su podaci o tebi pohranjeni i za '
                    'što.',
              ],
              [
                'Ispravak (Art. 16)',
                'Ispravak pogrešnih podataka, npr. pogrešnog personalnog '
                    'broja ili adrese.',
              ],
              [
                'Brisanje (Art. 17)',
                'Brisanje podataka koji više nisu potrebni i ne '
                    'podliježu roku čuvanja.',
              ],
            ],
          ),
          ParagraphBlock(
            'Za to se obraćaš upravi ili službeniku za zaštitu podataka '
            'tvrtke. Na zahtjev se u pravilu mora odgovoriti u roku od '
            'mjesec dana.',
          ),
          RevealBlock(
            prompt: 'Primjer: Kolega te moli da mu pošalješ screenshot '
                'interne analize — na kojoj su svi vozači s imenima i '
                'vrijednostima. Želi samo vidjeti gdje je on sam. Hoćeš '
                'li to učiniti?',
            answer: 'Ne. Na screenshotu su podaci o učinku svih kolega; '
                'to je prosljeđivanje podataka zaposlenika bez pravne '
                'osnove. To što kolega želi vidjeti samo svoj redak ne '
                'mijenja ništa — svejedno dobiva i sve ostale. Ispravno '
                'je: neka svoje vrijednosti zatraži od uprave. Njegovo '
                'pravo na pristup prema Art. 15 DSGVO odnosi se '
                'isključivo na njegove vlastite podatke.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista — 4. poglavlje',
        blocks: [
          ChecklistBlock(
            title: 'U postupanju s podacima kolega',
            items: [
              'Ne prosljeđujem podatke o učinku kolega',
              'Ne pričam o bolovanjima drugih',
              'Ne objavljujem fotografije kolega bez njihova pristanka',
              'Ne radim screenshotove internih analiza',
              'Znam kome se obratiti kad želim pristup vlastitim '
                  'podacima',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ds5',
    title: 'Kad nešto pođe po zlu — povreda podataka',
    summary: 'Rok za prijavu od 72 sata: zašto moraš prijaviti odmah',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Što je povreda podataka',
        blocks: [
          ParagraphBlock(
            'Povreda podataka nije samo veliki hakerski napad. U dostavi '
            'su to gotovo uvijek male, svakodnevne nezgode — i upravo se '
            'one također računaju.',
          ),
          BulletsBlock([
            'Izgubljen ili ukraden službeni telefon ili skener',
            'Paket predan pogrešnom primatelju, koji ga je otvorio',
            'Paket s čitljivom adresnom etiketom ostavljen otvoreno u '
                'haustoru ili na ulici',
            'Fotografija ili adresna lista greškom poslana pogrešnoj '
                'osobi',
            'Lista ture izgubljena ili ostavljena otvorena u vozilu',
            'Skener bio bez nadzora i dostupan otključan',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Osnovno pravilo',
            text: 'Čim su osobni podaci postali dostupni nekome kome nisu '
                'smjeli biti dostupni, riječ je o povredi podataka. Je li '
                'na kraju stvarno nastala šteta, ne odlučuješ ti — to '
                'provjerava tvrtka.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Rok od 72 sata',
        blocks: [
          ParagraphBlock(
            'Ključna stvar za tebe jest sat. Čim tvrtka sazna za povredu '
            'podataka, teče vrlo kratak rok — i teče neovisno o tome je '
            'li kraj radnog dana, vikend ili blagdan.',
          ),
          FactsBlock([
            FactItem('72 h', 'rok tvrtke za prijavu nadzornom tijelu '
                'prema Art. 33 DSGVO'),
            FactItem('odmah', 'tvoja prijava disponentu ili upravi — još '
                'isti dan'),
            FactItem('0', 'posljedica za tebe ako vlastitu pogrešku '
                'odmah prijaviš'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Pravna osnova',
            text: 'Art. 33 Abs. 1 DSGVO obvezuje tvrtku da povredu '
                'zaštite osobnih podataka bez odgode, a po mogućnosti u '
                'roku od 72 sata od saznanja, prijavi nadzornom tijelu. '
                'Kod visokog rizika prema Art. 34 DSGVO dodatno se moraju '
                'obavijestiti pogođene osobe. Tvrtka taj rok može održati '
                'samo ako ti prijaviš odmah.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ovako prijavljuješ ispravno',
        blocks: [
          StepsBlock([
            'Odmah nazovi disponenta ili upravu — ne čekaj kraj radnog '
                'vremena',
            'Reci što se dogodilo, kada se dogodilo i koji su podaci '
                'pogođeni',
            'Reci tko je podatke možda vidio',
            'Ništa ne popravljaj na svoju ruku: bez brisanja zapisa, bez '
                'vraćanja bez dogovora',
            'Ako je moguće, očuvaj zatečeno stanje — npr. pogrešno '
                'dostavljeni paket ne premještati dok se ne dogovori '
                'kako postupiti',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Najvažnije u ovom poglavlju',
            text: 'Tko pogrešku odmah prijavi, postupa ispravno. '
                'Prijavljivanje je izričito poželjno i nije priznanje '
                'nesposobnosti. Prešućivanje, naprotiv, od male nezgode '
                'radi pravi problem — za pogođene, za tvrtku i na kraju '
                'i za tebe.',
          ),
          DoDontBlock(
            doTitle: 'Ispravno',
            dos: [
              'Prijaviti odmah, čak i ako je neugodno',
              'Opisati sve u cijelosti, i vlastite pogreške',
              'Pitati trebaš li još nešto učiniti',
            ],
            dontTitle: 'Pogrešno',
            donts: [
              'Čekati hoće li itko uopće primijetiti',
              'Javiti tek sljedeći radni dan',
              'Umanjivati incident ili izostavljati dijelove',
              'Na svoju ruku pokušavati vratiti paket ili fotografiju',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Primjer i kontrolna lista',
        blocks: [
          RevealBlock(
            prompt: 'Primjer: Navečer primijetiš da si paket predao u '
                'kuću broj 14 umjesto 41. Tamošnji primatelj već ga je '
                'otvorio. Želiš ga sutra ujutro jednostavno pokupiti i '
                'ispravno dostaviti — pa nitko neće primijetiti. Što je u '
                'tome pogrešno?',
            answer: 'Dvije stvari. Prvo, povreda podataka već je nastala: '
                'strana je osoba saznala ime, adresu i sadržaj pošiljke. '
                'To se mora provjeriti radi obveze prijave, a rok od 72 '
                'sata iz Art. 33 DSGVO teče od trenutka kad tvrtka za to '
                'sazna. Drugo, čekanjem sprječavaš upravo ono što bi '
                'tvrtka morala učiniti — procijeniti, dokumentirati i po '
                'potrebi obavijestiti pogođenog primatelja. Bliska je '
                'zabluda da tiha korekcija nikome ne šteti. Zapravo '
                'šteti: ako incident kasnije izađe na vidjelo, tvrtka '
                'stoji bez pravodobne prijave — a ti si pogrešku prešutio '
                'umjesto da si je prijavio.',
          ),
          ChecklistBlock(
            title: 'Kod svake sumnje na povredu podataka',
            items: [
              'Prijavljujem još isti dan, ne tek sutra',
              'Kažem što se dogodilo, kada i koji su podaci pogođeni',
              'Ništa ne uljepšavam i ništa ne izostavljam',
              'Ništa ne poduzimam na svoju ruku',
              'Jasno mi je: prijaviti je ispravno, prešutjeti pogoršava '
                  'stvar',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'ds6',
    title: 'Povjerljivost i lojalnost',
    summary: 'Što smije van, što ne — i zašto je objektivna kritika '
        'izričito dopuštena',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Poslovne tajne ostaju u tvrtki',
        blocks: [
          ParagraphBlock(
            'Uz osobne podatke postoji i druga skupina informacija koje '
            'ne idu van: interne brojke te poslovne tajne. Tu spada '
            'mnogo toga o čemu se u depou posve normalno razgovara.',
          ),
          BulletsBlock([
            'Cijene, uvjeti i ugovori s naručiteljima',
            'Interni pokazatelji i analize',
            'Planovi tura, logika ruta i brojke o kapacitetima',
            'Interne upute, materijali za obuku i procesna pravila',
            'Fotografije iz depoa na kojima se prepoznaju liste, ekrani '
                'ili pošiljke',
          ]),
          ParagraphBlock(
            'To vrijedi jednako u svakom kanalu: u osobnom razgovoru, na '
            'društvenim mrežama i u vozačkim chat-grupama. '
            'WhatsApp-grupa sa šezdeset vozača nije privatni razgovor.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Pravna osnova',
            text: 'Poslovne tajne zaštićene su njemačkim zakonom o '
                'zaštiti poslovnih tajni (GeschGehG). Neovisno o tome, iz '
                'ugovora o radu proizlazi obveza povjerljivosti kao '
                'sporedna ugovorna obveza prema § 241 Abs. 2 BGB. Za '
                'osobne podatke dodatno vrijedi povjerljivost prema '
                'Art. 5 Abs. 1 lit. f DSGVO.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Neistinite tvrdnje o tvrtki',
        blocks: [
          ParagraphBlock(
            'Ovdje se često miješa što je dopušteno, a što nije. Granica '
            'ne prolazi između „pozitivnog" i „negativnog", nego između '
            'istinitog i svjesno neistinitog, između kritike i '
            'omalovažavanja.',
          ),
          ParagraphBlock(
            'Svjesno neistinite činjenične tvrdnje o tvrtki, nadređenima '
            'ili kolegama nisu pokrivene slobodom mišljenja. Isto vrijedi '
            'za uvrede i uvredljivo omalovažavanje — dakle izjave kod '
            'kojih više nije riječ o stvari, nego samo o tome da se '
            'nekoga ponizi.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Pravna osnova',
            text: 'Art. 5 Abs. 1 GG štiti iznošenje mišljenja, ali ne i '
                'svjesno neistinite činjenične tvrdnje ni uvredljivo '
                'omalovažavanje. Takve izjave mogu opravdati izvanredni '
                'otkaz prema § 626 BGB. Kod klevete dolazi i kažnjivost '
                'prema § 186 StGB; kod svjesno lažnih tvrdnji vrijedi '
                '§ 187 StGB (Verleumdung — svjesna kleveta).',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Tipični nesporazumi',
            text: 'Privatni profil nije privatan čim drugi mogu čitati. '
                'Zatvorena chat-grupa nije zaštićena čim screenshot iz '
                'nje krene dalje. A „pa to je bilo samo moje mišljenje" '
                'ne pomaže ako je izjava bila činjenična tvrdnja koja '
                'dokazivo nije točna.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Objektivna kritika izričito je dopuštena',
        blocks: [
          ParagraphBlock(
            'Jednako je važno kao granica i ono što leži s ove strane '
            'nje — a toga je mnogo. Smiješ iznositi kritiku, i jasnu, i '
            'neugodnu. Smiješ reći da je tura preusko planirana, da je '
            'vozilo u lošem stanju ili da je najava u depou bila '
            'pogrešna.',
          ),
          ParagraphBlock(
            'A tko prijavi stvarne nepravilnosti, nije nezaštićen: od '
            '2. srpnja 2023. vrijedi njemački zakon o zaštiti zviždača '
            '(HinSchG). On zabranjuje odmazdu prema zaposlenicima koji '
            'prijave prekršaje — dakle otkaz, opomenu, premještaj ili '
            'stavljanje u nepovoljniji položaj zbog prijave.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Zaštita zviždača',
            text: 'HinSchG štiti osobe koje u profesionalnom kontekstu '
                'prijave prekršaje od odmazde. Zaštita otpada samo kod '
                'svjesno ili krajnje nepažljivo netočnih prijava. Tko '
                'dakle ozbiljno i po najboljem znanju prijavi '
                'nepravilnost, zaštićen je — i onda kad se sumnja na '
                'kraju ne potvrdi.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Razlika u jednoj rečenici',
            text: 'Reci što si doživio — a ne ono što sam sklapaš u '
                'glavi. Istinita kritika zaštićena je, izmišljene optužbe '
                'nisu.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Konstruktivan put',
        blocks: [
          ParagraphBlock(
            'Gotovo sve što vozači iznose van moglo bi se interno brže '
            'riješiti. Put prema unutra zato nije samo sigurniji, nego '
            'najčešće i djelotvorniji.',
          ),
          StepsBlock([
            'Najprije se obrati disponentu — većina problema problemi su '
                'planiranja i tamo su rješivi',
            'Ako nema odgovora: obrati se upravi, po mogućnosti pisano, '
                's datumom i konkretnim događajem',
            'Kod ozbiljnijih prekršaja: iskoristi interno mjesto za '
                'prijave prema HinSchG-u',
            'Tek ako se interno ništa ne dogodi, dolaze u obzir vanjske '
                'instance — ali tada objektivno i s dokazivim '
                'činjenicama',
          ]),
          DoDontBlock(
            doTitle: 'Dopušteno i poželjno',
            dos: [
              'Reći da se tura redovito ne može stići',
              'Upozoriti na tehnički nedostatak na vozilu — i '
                  'ponovljeno',
              'Opisati konkretan događaj koji si sam doživio',
              'Prijaviti prekršaj preko internog mjesta za prijave',
              'Pitati dalje kad se na prijavu ništa ne dogodi',
            ],
            dontTitle: 'Nije pokriveno',
            donts: [
              'Iznositi tvrdnje za koje znaš da nisu istinite',
              'Vrijeđati ili ponižavati nadređene ili kolege',
              'Javno objavljivati interne brojke, ugovore ili analize',
              'Širiti glasine po chat-grupama, a da ih ne poznaješ',
              'Iznositi sukobe preko portala za recenzije ili društvenih '
                  'mreža prije nego što je interno itko uopće pitan',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Primjer i kontrolna lista',
        blocks: [
          RevealBlock(
            prompt: 'Primjer: U vozačkoj chat-grupi netko napiše da '
                'tvrtka namjerno ne isplaćuje sate. Ti to sam nikad nisi '
                'doživio, ali se upravo ljutiš zbog svog rasporeda i '
                'napišeš: „Točno, sve nas sustavno varaju." Sljedeći dan '
                'kruži screenshot grupe. Kako to ocijeniti?',
            answer: 'Kritično — ne zbog kritike, nego zbog forme. Iznio '
                'si činjeničnu tvrdnju („sustavno nas varaju") koju sam '
                'ne možeš dokazati i nisi doživio. Svjesno neistinite '
                'činjenične tvrdnje nisu pokrivene slobodom mišljenja i '
                'mogu imati radnopravne posljedice sve do izvanrednog '
                'otkaza prema § 626 BGB; kod klevete dolazi i § 186 '
                'StGB. Screenshot uz to pokazuje da zatvorena grupa nije '
                'zaštićen prostor. Ispravno bi bilo: navesti vlastiti '
                'slučaj — „Meni u srpnju nedostaju dva sata, prijavio '
                'sam to i dosad nemam odgovora" — i predati ga '
                'disponentu, upravi ili internom mjestu za prijave. Ta '
                'je izjava istinita, provjerljiva i zaštićena '
                'HinSchG-om. Rezultat: isto nezadovoljstvo, ali ispravno '
                'izrečeno, ne može ti naštetiti.',
          ),
          ChecklistBlock(
            title: 'Prije nego što nešto iznesem van',
            items: [
              'Iz vlastitog iskustva znam da je istina',
              'Događaj opisujem objektivno, bez vrijeđanja',
              'Ne otkrivam interne brojke, ugovore ni analize',
              'Najprije sam to iznio interno — disponentu, upravi ili '
                  'mjestu za prijave',
              'Jasno mi je: prijaviti stvarne nepravilnosti zaštićeno '
                  'je, tvrditi izmišljeno nije',
            ],
          ),
        ],
      ),
    ],
  ),
];
