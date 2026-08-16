// lib/data/privacy_notice/privacy_notice_hr.dart
//
// Informacija o zaštiti podataka za vozače prema Art. 13 DSGVO —
// hrvatska verzija. Prijevod 1:1 njemačke master verzije
// (`privacy_notice_de.dart`): isti odjeljci, isti redoslijed, isti
// blokovi.
//
// VAŽNO: ovo je INFORMACIJA s potvrdom primitka na znanje, a ne izjava
// vozača kojom se dopušta obrada. Zato u cijelom tekstu:
// „informiran sam" / „pročitao sam i razumio" — nikada formulacija koja
// zvuči kao davanje dopuštenja.
//
// Pravne odredbe ostaju u izvornom njemačkom obliku (Art. 6 Abs. 1
// lit. b DSGVO, § 26 BDSG, § 16 Abs. 2 ArbZG, § 147 AO …), uz kratko
// objašnjenje u zagradi.

import '../safety_training/safety_blocks.dart';
import 'privacy_notice_content.dart';

const List<PrivacyNoticeSection> privacyNoticeSectionsHr = [
  // ══════════════════════════════════════════════════════════════ 1
  PrivacyNoticeSection(
    id: 'verantwortlich',
    title: 'Tko obrađuje tvoje podatke',
    summary: 'Voditelj obrade, izvršitelj obrade i gdje se podaci nalaze',
    blocks: [
      ParagraphBlock(
        'Kako bi mogao raditi u aplikaciji CoDriver, obrađuju se podaci '
        'o tebi. Prema Art. 13 DSGVO (Opća uredba o zaštiti podataka) '
        'imaš pravo od samog početka znati koji su to podaci, u koju se '
        'svrhu obrađuju, na čemu se to temelji i koliko dugo ostaju '
        'pohranjeni. Upravo to piše na sljedećim stranicama.',
      ),
      SubheadBlock('Voditelj obrade'),
      ParagraphBlock(
        'Voditelj obrade tvojih podataka je tvoj poslodavac — Delivery '
        'Service Partner (DSP) kod kojeg si zaposlen. Njegovo ime piše '
        'na vrhu ove stranice. Njemu se obraćaš sa svim pitanjima o '
        'svojim podacima; ako je imenovao službenicu ili službenika za '
        'zaštitu podataka, možeš se obratiti izravno njima.',
      ),
      SubheadBlock('Tko upravlja softverom'),
      ParagraphBlock(
        'Aplikaciju CoDriver stavlja na raspolaganje ARION Logistics '
        'GmbH. Ona obrađuje tvoje podatke isključivo po nalogu i prema '
        'uputama tvojeg poslodavca — kao izvršitelj obrade prema '
        'Art. 28 DSGVO, na temelju ugovora o obradi. Vlastite svrhe s '
        'tvojim podacima ne provodi.',
      ),
      SubheadBlock('Gdje su podaci pohranjeni'),
      ParagraphBlock(
        'Podaci se nalaze kod usluge Google Firebase u Europskoj uniji '
        '(Firestore regija eur3, podatkovni centri Frankfurt i Belgija; '
        'Cloud Functions u regiji europe-west3, Frankfurt). Šifrirani su '
        'na putu prijenosa i u pohrani. Prijenos u treću zemlju izvan '
        'EU-a ne događa se.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Ovo je informacija — ne dopuštenje koje ti daješ',
        text: 'Ovdje si informiran. Tvoj potpis na kraju potvrđuje '
            'isključivo to da si ovu informaciju pročitao i razumio. '
            'Smiju li se tvoji podaci obrađivati ne ovisi o tvojem '
            'potpisu, nego o pravnim osnovama koje su navedene uz svaki '
            'odjeljak. Zašto je to tako, piše u posljednjem odjeljku.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 2
  PrivacyNoticeSection(
    id: 'stammdaten',
    title: 'Tvoji osnovni podaci',
    summary: 'Ime, matični broj, Transporter-ID i kontaktni podaci',
    blocks: [
      ParagraphBlock(
        'Bez vozačkog profila nitko te ne može uvrstiti u plan, '
        'dodijeliti ti smjenu ni doći do tebe. Tvoj profil je temelj za '
        'sve daljnje u aplikaciji.',
      ),
      SubheadBlock('Koji podaci'),
      BulletsBlock([
        'Ime i prezime',
        'Transporter-ID — tvoja oznaka u Amazonovu sustavu i istodobno '
            'tvoj ključ u aplikaciji CoDriver',
        'Matični broj radnika, ako ti ga je poslodavac dodijelio',
        'Poslovna e-mail adresa — ona je ujedno i tvoja prijava',
        'Broj telefona za dostupnost tijekom rada',
        'Datum rođenja i državljanstvo, ako su preuzeti pri onboardingu '
            'ili iz tvoje prijave za posao',
        'Profilna fotografija, ako je postaviš',
        'Odabrani jezik aplikacije',
        'Status tvojeg radnog odnosa (aktivan, neaktivan, otišao)',
      ]),
      SubheadBlock('U koju svrhu'),
      ParagraphBlock(
        'Za jednoznačno povezivanje tvoje osobe sa smjenama, vozilima, '
        'vremenima i dokazima, za komunikaciju između tebe i dispečerske '
        'službe te za upravljanje tvojim pristupom aplikaciji.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Pravna osnova',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (izvršavanje tvojeg ugovora o '
            'radu) u vezi s § 26 Abs. 1 BDSG (obrada podataka u svrhe '
            'radnog odnosa).',
      ),
      SubheadBlock('Koliko dugo'),
      ParagraphBlock(
        'Za vrijeme trajanja radnog odnosa i zakonskih rokova čuvanja. '
        'Nakon toga tvoj se profil briše ili blokira.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 3
  PrivacyNoticeSection(
    id: 'zeiterfassung',
    title: 'Evidencija radnog vremena i provjera lokacije',
    summary: 'Evidentiranje uz geofence provjeru — i što se pritom '
        'izričito ne pohranjuje',
    blocks: [
      ParagraphBlock(
        'Tvoj je poslodavac zakonski obvezan tvoje radno vrijeme '
        'bilježiti objektivno, pouzdano i dostupno — tako piše u '
        '§ 16 ArbZG (njemački Zakon o radnom vremenu) i u presudi Suda '
        'Europske unije C-55/18. Kada u aplikaciji CoDriver evidentiraš '
        'vrijeme („Počni smjenu", „Pauza", „Završi smjenu"), aplikacija '
        'provjerava nalazi li se tvoj uređaj na dogovorenom mjestu rada.',
      ),
      SubheadBlock('Koji podaci pri svakom evidentiranju'),
      BulletsBlock([
        'Vrijeme kao vremenska oznaka poslužitelja',
        'Tvoj Transporter-ID',
        'Je li na tvojem uređaju uključeno dopuštenje za lokaciju',
        'Rezultat geofence provjere: unutar ili izvan područja huba',
        'Oznaka područja huba, npr. „DBY5_main"',
        'Točnost određivanja lokacije u metrima',
        'Hub-ID i broj verzije skeniranog QR koda',
        'Platforma uređaja i verzija aplikacije',
        'Tvoja IP adresa, pohranjena samo kao SHA-256 hash vrijednost, '
            'nikada u čitljivom obliku',
      ]),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Što se izričito NE pohranjuje',
        text: 'Tvoje točne GPS koordinate ne pohranjuju se. One se u '
            'trenutku evidentiranja jednokratno prenose na poslužitelj, '
            'ondje se obrađuju za geofence provjeru i zatim se '
            'odbacuju. Ostaje samo odgovor „bio u području huba / nije '
            'bio u području huba". Nema praćenja lokacije u pozadini ni '
            'profila kretanja između dva evidentiranja.',
      ),
      SubheadBlock('U koju svrhu'),
      BulletsBlock([
        'Pravno sigurna dokumentacija tvojeg radnog vremena prema '
            '§ 16 ArbZG',
        'Ispravan obračun plaće i socijalnog osiguranja',
        'Zaštita od manipulacije pri evidentiranju',
      ]),
      SubheadBlock('Dopuštenje za lokaciju je dobrovoljno'),
      ParagraphBlock(
        'Hoćeš li svojem uređaju dati dopuštenje za lokaciju, odlučuješ '
        'sam i to možeš u svakom trenutku promijeniti u postavkama '
        'uređaja. Bez dopuštenja za lokaciju svejedno možeš evidentirati '
        'vrijeme — postupak se tada označava kao „lokacija nije '
        'potvrđena" i dispečerska ga služba provjerava ručno. '
        'Radnopravne posljedice iz toga za tebe ne nastaju.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Pravna osnova',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (izvršavanje ugovora o radu), '
            'Art. 6 Abs. 1 lit. c DSGVO (pravna obveza iz § 16 ArbZG), '
            'Art. 6 Abs. 1 lit. f DSGVO (legitiman interes za '
            'sprječavanje manipulacije) i § 26 BDSG.',
      ),
      SubheadBlock('Koliko dugo'),
      TableBlock(
        headers: ['Podaci', 'Čuvanje', 'Osnova'],
        rows: [
          ['Pojedinačna evidentiranja', '2 godine', '§ 16 Abs. 2 ArbZG'],
          [
            'Mjesečne vrijednosti (plan/stvarno/saldo)',
            '6 godina',
            '§ 147 AO',
          ],
          ['Zapisnik izmjena', '2 godine', 'Sljedivost'],
          ['Zahtjevi za ispravak', '2 godine', 'Sljedivost'],
        ],
      ),
      SubheadBlock('Nema automatske odluke o tebi'),
      ParagraphBlock(
        'Automatizirana odluka s pravnim učinkom prema Art. 22 DSGVO ne '
        'provodi se. Napomene aplikacije, primjerice o prekoračenoj '
        'pauzi, isključivo su informativne; o posljedicama uvijek '
        'odlučuje čovjek. Prije uvođenja evidencije radnog vremena '
        'provedena je procjena učinka na zaštitu podataka prema '
        'Art. 35 DSGVO; preostali je rizik ocijenjen niskim jer se ne '
        'pohranjuju ni sirove koordinate ni profili kretanja.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 4
  PrivacyNoticeSection(
    id: 'academy',
    title: 'DA Academy — edukacije i dokazi',
    summary: 'Rezultati testova, potvrde i tvoj potpis na njima',
    blocks: [
      ParagraphBlock(
        'U programu DA Academy prolaziš upute i edukacije — primjerice '
        'sigurnosnu uputu, Green Book, edukaciju o zaštiti podataka ili '
        'radne upute. Tvoj poslodavac mora moći dokazati da si bio '
        'educiran.',
      ),
      SubheadBlock('Koji podaci'),
      BulletsBlock([
        'Koju si edukaciju kada započeo i završio',
        'Rezultat završnog testa: postignuti broj bodova, postotak, '
            'položeno ili nije položeno, broj pokušaja',
        'Datum polaganja i istek valjanosti',
        'Jezik na kojem si edukaciju prošao',
        'Tvoj vlastoručni potpis kao slikovna datoteka',
        'PDF dokaz koji iz toga nastaje, s imenom, matičnim brojem, '
            'oznakom Transporter-ID, datumom i potpisom',
        'Potvrde pojedinih radnih uputa i pravila',
      ]),
      SubheadBlock('U koju svrhu'),
      ParagraphBlock(
        'Za dokazivanje provedene edukacije pred tijelima vlasti, '
        'strukovnim osiguravateljem i naručiteljem, za upravljanje '
        'dospjelim ponavljajućim edukacijama i za ispunjavanje obveze '
        'dokazivanja usklađenosti tvojeg poslodavca.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Pravna osnova',
        text: 'Art. 6 Abs. 1 lit. c DSGVO (pravna obveza iz propisa o '
            'zaštiti na radu i zaštiti podataka, među ostalim '
            '§ 12 ArbSchG, § 4 DGUV Vorschrift 1, Art. 5 Abs. 2 i '
            'Art. 32 DSGVO), Art. 6 Abs. 1 lit. b DSGVO (izvršavanje '
            'ugovora o radu) i § 26 BDSG.',
      ),
      SubheadBlock('Koliko dugo'),
      ParagraphBlock(
        'Za vrijeme trajanja radnog odnosa i zakonskih rokova čuvanja. '
        'Dokazi o provedenim edukacijama čuvaju se barem onoliko dugo '
        'koliko su potrebni za dokazivanje pred tijelima vlasti.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 5
  PrivacyNoticeSection(
    id: 'dokumente',
    title: 'Tvoji dokumenti',
    summary: 'Vozačka dozvola, osobna iskaznica, boravišna dozvola i '
        'ostali dokazi',
    blocks: [
      ParagraphBlock(
        'Za rad kao vozač određeni dokazi moraju postojati i moraju biti '
        'valjani. Ti ili dispečerska služba pohranjujete ih u tvoj '
        'vozački profil.',
      ),
      SubheadBlock('Koji podaci'),
      BulletsBlock([
        'Vozačka dozvola — prednja i stražnja strana',
        'Osobna iskaznica ili putovnica',
        'Boravišna i radna dozvola, ako su potrebne',
        'Porezni identifikacijski broj',
        'Dokaz o socijalnom osiguranju',
        'Ugovor o radu',
        'Datumi isteka i valjanosti tih dokumenata',
      ]),
      SubheadBlock('U koju svrhu'),
      ParagraphBlock(
        'Za provjeru smiješ li uopće biti raspoređen na rad — prije '
        'svega kontrola vozačke dozvole kao obveza poslodavca u ulozi '
        'vlasnika vozila —, za ispunjavanje prijavnih, poreznih i '
        'socijalnoosiguravajućih obveza te za pravodobni podsjetnik '
        'prije nego što neki dokument istekne.',
      ),
      CalloutBlock(
        tone: CalloutTone.warning,
        title: 'Posebna pažnja',
        text: 'Identifikacijski dokumenti sadrže osjetljive podatke. '
            'Vidljivi su samo tebi i dispečerskoj službi tvojeg pogona, '
            'pohranjeni su šifrirano u EU-u i ne prosljeđuju se '
            'trećima, osim ako to neko tijelo vlasti zatraži na '
            'zakonskoj osnovi.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Pravna osnova',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (izvršavanje ugovora o radu), '
            'Art. 6 Abs. 1 lit. c DSGVO (pravne obveze, među ostalim '
            '§ 21 StVG odgovornost vlasnika vozila, propisi o boravku, '
            'porezni propisi i propisi o socijalnom osiguranju), '
            'Art. 6 Abs. 1 lit. f DSGVO (legitiman interes za '
            'sposobnost rasporeda na rad) i § 26 BDSG.',
      ),
      SubheadBlock('Koliko dugo'),
      ParagraphBlock(
        'Za vrijeme trajanja radnog odnosa i zakonskih rokova čuvanja.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 6
  PrivacyNoticeSection(
    id: 'abwesenheiten',
    title: 'Izostanci, godišnji odmor i bolovanja',
    summary: 'Zahtjevi, odobrenja i potvrde o nesposobnosti za rad',
    blocks: [
      ParagraphBlock(
        'Godišnji odmor, bolovanje i druge izostanke prijavljuješ u '
        'aplikaciji; dispečerska služba o tome odlučuje i u skladu s tim '
        'planira.',
      ),
      SubheadBlock('Koji podaci'),
      BulletsBlock([
        'Vrsta izostanka — godišnji odmor, bolest, neplaćeni dopust i '
            'drugi razlozi',
        'Razdoblje od … do i broj dana',
        'Status: zatraženo, odobreno, odbijeno',
        'Tvoj komentar uz zahtjev i odgovor dispečerske službe',
        'Tvoje pravo na godišnji odmor i već iskorišteni dio',
        'Učitana potvrda o nesposobnosti za rad, ako je predaš',
      ]),
      CalloutBlock(
        tone: CalloutTone.warning,
        title: 'Bolovanja su posebno zaštićena',
        text: 'Bilježi se samo TO DA si nesposoban za rad i za koje '
            'razdoblje. Dijagnozu ne moraš navesti niti je potvrda za '
            'poslodavca sadrži. Podaci o zdravlju posebna su kategorija '
            'podataka prema Art. 9 DSGVO i u njih uvid imaju samo osobe '
            'kojima su doista potrebni za nastavak isplate plaće i za '
            'planiranje.',
      ),
      SubheadBlock('U koju svrhu'),
      ParagraphBlock(
        'Za planiranje rada, za izračun prava na godišnji odmor i '
        'nastavka isplate plaće te za dokazivanje pred nositeljima '
        'socijalnog osiguranja.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Pravna osnova',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (izvršavanje ugovora o radu), '
            'Art. 6 Abs. 1 lit. c DSGVO (među ostalim BUrlG i EntgFG), '
            'a za podatke o nesposobnosti za rad Art. 9 Abs. 2 lit. b '
            'DSGVO u vezi s § 26 Abs. 3 BDSG (ostvarivanje prava i '
            'obveza iz radnog prava i prava socijalne sigurnosti).',
      ),
      SubheadBlock('Koliko dugo'),
      ParagraphBlock(
        'Za vrijeme trajanja radnog odnosa i zakonskih rokova čuvanja. '
        'Potvrde o nesposobnosti za rad brišu se čim više nisu potrebne '
        'za nastavak isplate plaće i kao dokaz.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 7
  PrivacyNoticeSection(
    id: 'planung',
    title: 'Planiranje smjena i valova',
    summary: 'Tko kada, u kojem valu, na kojoj ruti i u kojem vozilu '
        'vozi',
    blocks: [
      ParagraphBlock(
        'Dispečerska služba svakodnevno planira tko radi, u kojem valu '
        'krećeš i kojim si vozilom na putu. Taj je plan vidljiv tebi i '
        'dispečerskoj službi.',
      ),
      SubheadBlock('Koji podaci'),
      BulletsBlock([
        'Tvoj raspored po danima — u planu, slobodno, izostanak',
        'Vrijeme vala i vrijeme početka',
        'Dodijeljena ruta odnosno tura',
        'Dodijeljeno vozilo s registarskom oznakom',
        'Potvrda da si svoj plan primio na znanje',
        'Izmjene plana i tko ih je napravio',
        'Zadaci i poruke koji su ti dodijeljeni, zajedno s potvrdom '
            'čitanja',
      ]),
      SubheadBlock('U koju svrhu'),
      ParagraphBlock(
        'Za organizaciju svakodnevnog poslovanja, za dodjelu vozila i '
        'rute te za sljedivost tko je kada koju turu vozio.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Pravna osnova',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (izvršavanje ugovora o radu) '
            'i Art. 6 Abs. 1 lit. f DSGVO (legitiman interes za '
            'nesmetano odvijanje poslovanja), svaki u vezi s '
            '§ 26 BDSG.',
      ),
      SubheadBlock('Koliko dugo'),
      ParagraphBlock(
        'Za vrijeme trajanja radnog odnosa i zakonskih rokova čuvanja.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 8
  PrivacyNoticeSection(
    id: 'scorecard',
    title: 'Podaci o učinku iz izvještaja Scorecard',
    summary: 'Pokazatelji o sigurnosti, kvaliteti i dostavi',
    blocks: [
      ParagraphBlock(
        'Naručitelj tjedno stavlja na raspolaganje pokazatelje o tvojoj '
        'dostavnoj djelatnosti. Aplikacija CoDriver učitava taj '
        'Scorecard i prikazuje ga tebi i dispečerskoj službi.',
      ),
      SubheadBlock('Koji podaci'),
      BulletsBlock([
        'Sigurnosni pokazatelji poput FICO vozačkog rezultata, '
            'brzinskih događaja na 100 tura i korištenja alata Mentor',
        'Pokazatelji usklađenosti poput kontrole vozila i poštivanja '
            'radnog vremena',
        'Pokazatelji kvalitete poput stope dostave, neisporučenih '
            'pošiljaka i stope gubitka',
        'Pokazatelji kvalitete dostave poput fotografije kao dokaza o '
            'isporuci i usklađenosti pri kontaktiranju',
        'Povratne informacije kupaca i eskalacije',
        'Ukupna ocjena po tjednu i njezino kretanje',
      ]),
      SubheadBlock('U koju svrhu'),
      ParagraphBlock(
        'Za ispunjavanje ugovora između tvojeg poslodavca i naručitelja, '
        'za prepoznavanje sigurnosnih rizika, za ciljanu edukaciju i za '
        'povratnu informaciju tebi.',
      ),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Nema automatizma preko tvoje glave',
        text: 'Iz jednog pokazatelja ne slijedi automatska mjera. Ocjene '
            'i razgovore uvijek vodi čovjek, a ti pritom možeš iznijeti '
            'svoje viđenje. Automatizirana odluka prema Art. 22 DSGVO '
            'ne provodi se.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Pravna osnova',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (izvršavanje ugovora o radu) '
            'i Art. 6 Abs. 1 lit. f DSGVO (legitiman interes za '
            'sigurnost prometa, osiguranje kvalitete i ispunjavanje '
            'ugovornih obveza prema naručitelju), u vezi s § 26 BDSG.',
      ),
      SubheadBlock('Koliko dugo'),
      ParagraphBlock(
        'Za vrijeme trajanja radnog odnosa i zakonskih rokova čuvanja.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 9
  PrivacyNoticeSection(
    id: 'empfaenger',
    title: 'Tko vidi tvoje podatke',
    summary: 'Primatelji unutar i izvan pogona',
    blocks: [
      SubheadBlock('U pogonu'),
      BulletsBlock([
        'Uprava tvojeg poslodavca',
        'Dispečerska služba i dispečeri koje je ona ovlastila — svaki '
            'samo za vlastiti pogon',
        'Ti sam: vlastite podatke vidiš u aplikaciji u svakom trenutku',
      ]),
      SubheadBlock('Izvan pogona'),
      BulletsBlock([
        'Google Ireland/Google LLC kao pružatelj usluge hostinga '
            '(izvršitelj obrade, poslužitelji u EU-u)',
        'ARION Logistics GmbH kao operator aplikacije CoDriver '
            '(izvršitelj obrade)',
        'Porezno savjetovanje i obračun plaća, ako ih tvoj poslodavac '
            'koristi — svaki na temelju ugovora o obradi',
        'Naručitelj, u mjeri u kojoj pokazatelji iz izvještaja Scorecard '
            'ionako potječu odande',
        'Tijela vlasti, nositelji socijalnog osiguranja i strukovni '
            'osiguravatelj — samo ako ih na to ovlašćuje zakonska '
            'osnova',
      ]),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Ne prodaju se, ne koriste se za oglašavanje',
        text: 'Tvoji se podaci ne prodaju, ne koriste se za oglašavanje '
            'i ne prosljeđuju se trećima koji bi ih htjeli koristiti u '
            'vlastite svrhe.',
      ),
      SubheadBlock('Odakle podaci dolaze'),
      ParagraphBlock(
        'Većina podataka dolazi od tebe samoga — iz tvoje prijave za '
        'posao, iz onboardinga i iz tvoje svakodnevne uporabe '
        'aplikacije. Pokazatelji iz izvještaja Scorecard dolaze od '
        'naručitelja, a podaci o planu i smjenama od dispečerske službe.',
      ),
      SubheadBlock('Moraš li navesti podatke?'),
      ParagraphBlock(
        'Neki su podaci nužni da bi se radni odnos uopće mogao provoditi '
        '— primjerice ime, vozačka dozvola i radno vrijeme. Bez njih ne '
        'možeš biti raspoređen na rad. Drugi podaci, primjerice '
        'profilna fotografija, dobrovoljni su; iz toga ti ne nastaje '
        'nikakva šteta.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 10
  PrivacyNoticeSection(
    id: 'rechte',
    title: 'Tvoja prava',
    summary: 'Pristup, ispravak, brisanje, prigovor i pritužba',
    blocks: [
      ParagraphBlock(
        'Prema svojem poslodavcu kao voditelju obrade imaš sljedeća '
        'prava. Njihovo je ostvarivanje besplatno i iz toga ti ne '
        'nastaje nikakva šteta.',
      ),
      BulletsBlock([
        'Pristup (Art. 15 DSGVO): Možeš saznati obrađuju li se podaci o '
            'tebi i koji, te zatražiti njihovu kopiju.',
        'Ispravak (Art. 16 DSGVO): Netočne podatke moraš moći dati '
            'ispraviti, a nepotpune dopuniti — za evidentirana vremena '
            'za to u aplikaciji postoji zahtjev za ispravak.',
        'Brisanje (Art. 17 DSGVO): Podaci koji više nisu potrebni i ne '
            'podliježu obvezi čuvanja brišu se na zahtjev.',
        'Ograničenje obrade (Art. 18 DSGVO): Ako je sporno jesu li '
            'podaci točni ili smiju li se obrađivati, možeš zatražiti da '
            'se do razjašnjenja samo pohranjuju.',
        'Prenosivost podataka (Art. 20 DSGVO): Podatke koje si stavio na '
            'raspolaganje dobivaš u uobičajenom, strojno čitljivom '
            'formatu.',
        'Prigovor (Art. 21 DSGVO): Protiv obrada koje se temelje na '
            'legitimnom interesu — primjerice protiv automatske '
            'geofence provjere — možeš uložiti prigovor iz razloga koji '
            'proizlaze iz tvoje posebne situacije.',
        'Pritužba (Art. 77 DSGVO): U svakom se trenutku možeš pritužiti '
            'nadzornom tijelu za zaštitu podataka.',
      ]),
      SubheadBlock('Kome se obraćaš'),
      ParagraphBlock(
        'Najprije svojem poslodavcu — DSP-u čije ime piše na vrhu ove '
        'stranice. Ako je imenovao službenicu ili službenika za zaštitu '
        'podataka, možeš se obratiti izravno njima; kontaktne podatke '
        'daje ti uprava. Za pritužbu je nadležno nadzorno tijelo za '
        'zaštitu podataka one savezne pokrajine u kojoj tvoj pogon ima '
        'sjedište; možeš se obratiti i tijelu u mjestu svojeg '
        'prebivališta ili u mjestu navodne povrede.',
      ),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Ovako brzo dobivaš odgovor',
        text: 'Na zahtjev ti voditelj obrade u pravilu mora odgovoriti u '
            'roku od mjesec dana. Samo u složenim slučajevima smije taj '
            'rok produljiti i o tome te mora obavijestiti.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 11
  PrivacyNoticeSection(
    id: 'bedeutung',
    title: 'Što znači tvoja potvrda',
    summary: 'Zašto si ovdje informiran, a ne nešto dopuštaš',
    blocks: [
      ParagraphBlock(
        'Odmah ćeš potpisati. Da bude jasno što potpisuješ: potvrđuješ '
        'isključivo to da si ovu informaciju pročitao i razumio. Time ne '
        'dopuštaš nikakvu obradu i ništa ne odobravaš.',
      ),
      SubheadBlock('Zašto je to važno'),
      ParagraphBlock(
        'U radnom se odnosu nalaziš u odnosu ovisnosti prema svojem '
        'poslodavcu. Izjava kojom bi dopustio obradu zato gotovo nikada '
        'ne bi bila uistinu dobrovoljna — a mogao bi je u svakom '
        'trenutku povući, što bi evidenciju radnog vremena ili obračun '
        'plaća učinilo nemogućima. Zato se tvoj rad u aplikaciji '
        'CoDriver ne temelji na takvoj izjavi, nego na onome što ionako '
        'vrijedi: na izvršavanju tvojeg ugovora o radu '
        '(Art. 6 Abs. 1 lit. b DSGVO), zakonskim obvezama tvojeg '
        'poslodavca (Art. 6 Abs. 1 lit. c DSGVO) i legitimnim '
        'interesima pogona (Art. 6 Abs. 1 lit. f DSGVO), svakome u vezi '
        's § 26 BDSG.',
      ),
      DoDontBlock(
        doTitle: 'To potvrđuješ',
        dos: [
          'Informiran sam prema Art. 13 DSGVO o obradi svojih podataka.',
          'Ovu sam informaciju o zaštiti podataka pročitao i razumio.',
          'Znam kome se obraćam s pitanjima i zahtjevima.',
        ],
        dontTitle: 'To ne potvrđuješ',
        donts: [
          'Nikakvo dopuštenje za obradu — pravne su osnove navedene uz '
              'svaki odjeljak.',
          'Nikakvo odricanje od tvojih prava iz Art. 15 do Art. 21 '
              'DSGVO.',
          'Nikakvo odricanje od tvojeg prava na pritužbu prema '
              'Art. 77 DSGVO.',
        ],
      ),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'A ako se nešto promijeni?',
        text: 'Ako se ova informacija sadržajno promijeni, povećava se '
            'broj njezine verzije i pri sljedećoj ti se prijavi ponovno '
            'predočuje. Tako uvijek znaš o čemu si bio informiran — i '
            'kada.',
      ),
      ParagraphBlock(
        'I sama se potvrda dokumentira: pohranjuju se tvoj '
        'Transporter-ID, broj verzije, datum i vrijeme, jezik ovog '
        'prikaza te PDF dokaz s tvojim potpisom. Osnova za to je obveza '
        'dokazivanja usklađenosti prema Art. 5 Abs. 2 DSGVO.',
      ),
    ],
  ),
];
