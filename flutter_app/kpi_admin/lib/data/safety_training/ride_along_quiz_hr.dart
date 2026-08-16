// lib/data/safety_training/ride_along_quiz_hr.dart
//
// Pitanja završnog testa Ride Along — hrvatska verzija.
// Struktura je istovjetna njemačkoj verziji (master): petnaest pitanja,
// raspoređenih na pet poglavlja iz ride_along_content_hr.dart
// (ra1 … ra5), po tri pitanja po poglavlju, isti redoslijed odgovora i
// isti točni odgovori.
//
// Prilagođeno za više tvrtki: nigdje se ne pita za brojke pojedine
// tvrtke (broj stajališta, vremena u Waiting Areji, strana za
// parkiranje) — samo za ono što vrijedi svugdje. Iznimke s pravnim
// uporištem: § 4 ArbZG (stanke) i § 1 st. 6 FPersV (Green Book).

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> rideAlongQuestionsHr = [
  // ══════════════════════════ ra1 — Što je Ride Along
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'Što je Ride Along?',
    options: [
      'Teorijska uputa u uredu prije prvog radnog dana',
      'Dva radna dana vožnje u pratnji s iskusnim vozačem kao trenerom',
      'Službeni vozački ispit bez kojeg te se ne smije rasporediti na '
          'posao',
    ],
    correctIndex: 1,
    explanation: 'Ride Along su dva prava radna dana u tvrtki, u kojima te '
        'iskusan vozač prati, sve objašnjava i zatim te pušta da sam '
        'radiš. Nije to ni uredska obuka ni ispit neke službe — to je '
        'uvođenje u posao u punom pogonu, koje se ipak ocjenjuje i '
        'dokumentira.',
  ),
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'Koliko stajališta moraš odvoziti u ta dva dana?',
    options: [
      'To određuje tvoja tvrtka odnosno tvoja stanica — trener ti navodi '
          'zadatak',
      'Uvijek točno 20 prvog i 70 drugog dana, jednako u svakoj tvrtki',
      'Onoliko koliko sam sebi vjeruješ — zadatka nema',
    ],
    correctIndex: 0,
    explanation: 'Rašireno je manji broj prvog i znatno više drugog dana '
        '(često oko 20 i oko 70), ali to su okvirne vrijednosti pojedinih '
        'tvrtki. Obvezujući je samo zadatak tvoje stanice. Zabluda koja se '
        'nameće jest čuvenu brojku držati općim zakonom — pitaj svojeg '
        'trenera za broj koji vrijedi za tebe.',
  ),
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'Prvog si dana znatno sporiji nego što je planirano i radiš '
        'više pogrešaka pri sortiranju. Kako to utječe na ocjenu?',
    options: [
      'Ride Along time vrijedi kao nepoložen i mora se ponoviti',
      'Nije važno, jer se prvog dana još uopće ništa ne ocjenjuje',
      'Presudno je pitaš li i otkloniš li pogrešku nakon toga — a ne tempo',
    ],
    correctIndex: 2,
    explanation: 'Tempo prvog dana nitko ne očekuje; upravo zbog toga '
        'postoji manji broj stajališta. Ocjenjuje se tvoja spremnost na '
        'učenje: pitaš li, prihvaćaš li upute, radiš li istu pogrešku i '
        'treći put? Zabluda je opasna u oba smjera — to nije ni ispit s '
        'giljotinom ni dan bez ocjene.',
  ),

  // ══════════════════════════ ra2 — Prvi dan
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Zašto stajališta na Ride Alongu moraju teći preko tvojeg '
        'vlastitog računa?',
    options: [
      'Jer trener tih dana ne smije koristiti svoj račun',
      'Jer samo tako postaje vidljivo kako izgleda tvoja vlastita dostava '
          '— ona se broji pod tvojim imenom',
      'Jer trenerov račun više ne može primiti nova stajališta',
    ],
    correctIndex: 1,
    explanation: 'Sve što tih dana dostaviš ide pod tvojim imenom — točno '
        'kao poslije u svakodnevici. Samo tako trener i tvrtka vide tvoj '
        'stvarni način rada, i samo se tako stajališta broje za tvoje '
        'uvođenje u posao. Zato pristup koji ujutro ne radi nije '
        'sitnica, nego razlog da odmah javiš.',
  ),
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Što vrijedi za trajanje bilježenja aplikacije Mentor?',
    options: [
      'Mentor bilježi oko 4 sata u komadu i nakon toga se mora ponovno '
          'pokrenuti',
      'Mentor jednom pokrenut radi do kraja smjene',
      'Mentor se pokreće automatski čim se vozilo pomakne',
    ],
    correctIndex: 0,
    explanation: 'Bilježenje traje svaki put oko četiri sata. Nakon toga ga '
        'moraš ponovno pokrenuti, inače ostatak ture ostaje nezabilježen. '
        'Najčešća početnička pogreška upravo je zabluda da aplikacija radi '
        'sama od sebe: ujutro ispravno pokrenuta, nakon stanke nije '
        'ponovno aktivirana — i pola dana nedostaje u ocjeni.',
  ),
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Tog dana radiš 9,5 sati. Koliko najmanje mora trajati tvoja '
        'stanka?',
    options: [
      '30 minuta, jer 45 minuta vrijedi tek od 10 sati',
      'Dovoljno je napraviti više kratkih stanki od po 5 do 10 minuta',
      '45 minuta, jer je radno vrijeme dulje od 9 sati',
    ],
    correctIndex: 2,
    explanation: 'Prema § 4 ArbZG (njemački zakon o radnom vremenu) kod više '
        'od 6 sati propisano je najmanje 30 minuta, a kod više od 9 sati '
        'najmanje 45 minuta stanke — 9,5 sati je iznad granice. Stanka se '
        'smije podijeliti, ali svaki dio mora trajati najmanje 15 minuta; '
        'pet minuta usput se ne broji.',
  ),

  // ══════════════════════════ ra3 — Drugi dan
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Kupac s paketom sa zaporkom nema kod pri ruci, ali želi '
        'potpisati. Što činiš?',
    options: [
      'Ne predaješ — bez ispravnog koda nema iznimke',
      'Predaješ uz potpis, jer je i on jednako dokaz',
      'Paket ostavljaš kod susjeda i obavještavaš kupca',
    ],
    correctIndex: 0,
    explanation: 'Zaporka je dokaz da je primatelj stvarno primatelj — zbog '
        'toga je i dodijeljena. Potpis ili lijepo nagovaranje ne '
        'zamjenjuju je, a predaja susjedu pogotovo ne. Bude li pošiljka '
        'poslije prijavljena kao neprimljena, predaja bez koda stoji kao '
        'tvoja pogreška. Ispravno je: pusti ga da potraži kod, inače paket '
        'ispravno vrati i dokumentiraj.',
  ),
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Pri manevriranju okrzneš stupić. Na kombiju ostaje '
        'ogrebotina, nitko nije vidio. Što je ispravno?',
    options: [
      'Ne poduzimati ništa — kod ogrebotine bez tuđe štete nema se što '
          'prijaviti',
      'Prvo pričekati hoće li se pri sljedećem pregledu uopće primijetiti',
      'Prijaviti još istog dana i dokumentirati u CoDriveru',
    ],
    correctIndex: 2,
    explanation: 'Prijavljena je šteta događaj koji se obrađuje; ista šteta, '
        'koju sljedećeg jutra netko drugi nađe pri svojem pregledu, '
        'nerazjašnjena je šteta — a sumnja se na kraju ipak usmjerava na '
        'posljednjeg korisnika. Zabluda „to se neće primijetiti" ne '
        'drži: upravo zbog toga postoji pregled prije i nakon svake ture.',
  ),
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Koja je razlika između učinka i kvalitete u Scorecardu?',
    options: [
      'Oboje znači isto — Scorecard mjeri samo broj stajališta',
      'Učinak je količina u vremenu, kvaliteta je koliko je uredno '
          'zaključeno svako pojedino stajalište',
      'Kvaliteta se tiče samo vozila, učinak samo dostave',
    ],
    correctIndex: 1,
    explanation: 'Učinak je količina — koliko stajališta u kojem vremenu. '
        'Kvaliteta je pažljivost na svakom pojedinom stajalištu: pravo '
        'mjesto, ispravno dokumentiranje, nikakva reklamacija. Tko oboje '
        'izjednači, sprijeda uštedi minutu, a straga stvori izvid koji '
        'tvrtku košta višestruko.',
  ),

  // ══════════════════════════ ra4 — Završetak i predaja
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'Koliko puta trener potpisuje kontrolnu listu Ride Alonga?',
    options: [
      'Jednom na kraju drugog dana, za oba dana zajedno',
      'Nikako — potpisuje samo disponent pri predaji',
      'Odvojeno po danu, svaki put s datumom',
    ],
    correctIndex: 2,
    explanation: 'Svaki dan ima svoj popis točaka i zato se zaključuje '
        'pojedinačno, s datumom i potpisom. To ima praktičan razlog: '
        'otkaže li drugi dan ili se pomakne, ipak je uredno dokumentirano '
        'što je prvog dana obavljeno. Skupni bi potpis na kraju upravo to '
        'onemogućio.',
  ),
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'Što se događa s ispunjenom kontrolnom listom na kraju drugog '
        'dana?',
    options: [
      'Predaje se kao fotografija nadležnom disponentu',
      'Nosiš je kući i čuvaš privatno',
      'Ostaje u vozilu, kako bi je sljedeći trener nastavio voditi',
    ],
    correctIndex: 0,
    explanation: 'List se na kraju drugog dana fotografira i predaje '
        'nadležnom disponentu — time je Ride Along formalno zaključen, a '
        'tvoje uvođenje u posao dokumentirano. U vozilu ili privatno kod '
        'kuće dokaz je za tvrtku bezvrijedan. Pripazi da su kvačice, '
        'datum, imena i potpisi na fotografiji čitljivi.',
  ),
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'U povratnoj informaciji stoji da si pri manevriranju '
        'prekolebljiv. Kako najsmislenije reagiraš?',
    options: [
      'Objasniš da si bio svjesno oprezan i time završiš temu',
      'Zatražiš konkretan primjer iz tog dana',
      'Primiš povratnu informaciju na znanje i sljedeći put manevriraš '
          'brže',
    ],
    correctIndex: 1,
    explanation: 'Oprez pri manevriranju je ispravan — „kolebljiv" u pravilu '
        'znači nešto drugo, primjerice dugo razmišljanje umjesto da kratko '
        'izađeš i pogledaš. S konkretnim primjerom imaš točku na kojoj '
        'možeš raditi. Opravdavanje ne donosi ništa, a jednostavno brže '
        'manevrirati bila bi najopasnija od triju reakcija.',
  ),

  // ══════════════════════════ ra5 — Ovako se pripremaš
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Kada bi trebao provjeriti rade li tvoji pristupi evidenciji '
        'radnog vremena, Mentoru, Flexu i CoDriveru?',
    options: [
      'Ujutro prvog dana zajedno s trenerom',
      'Tek onda kada se pri radu stvarno pojavi problem',
      'Prije prvog dana, najbolje prethodnu večer',
    ],
    correctIndex: 2,
    explanation: 'Poništavanje zaporke traje prethodnu večer nekoliko '
        'minuta, a ujutro u Waiting Areji pola sata — ako je uopće netko '
        'dostupan. '
        'Zabluda koja se nameće jest to prepustiti treneru: on ti kod '
        'blokiranog pristupa ne može pomoći, a vrijeme onda nedostaje kod '
        'stajališta preko tvojeg vlastitog računa.',
  ),
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Što znači „na vrijeme" na Ride Alongu?',
    options: [
      'Spreman za rad u stanici na početku smjene — parkiranje i put su '
          'već uračunati',
      'Doći na ulaz stanice na početku smjene',
      'Biti ondje najkasnije kada se prozove Waiting Area',
    ],
    correctIndex: 0,
    explanation: 'Na početku smjene si spreman za rad, a ne na putu. Tko '
        'stigne tek na ulaz, gubi vrijeme na parkiranje i na put preko '
        'dvorišta i propušta svoj termin u Waiting Areji — i time pomiče i '
        'trenerov val. Zato svjesno uračunaj vrijeme za parkiranje i '
        'hodanje.',
  ),
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Zašto se isplati pitanja za trenera zapisati već prije 1. '
        'dana?',
    options: [
      'Jer trener mora dati da se pitanja unaprijed predaju u pisanom '
          'obliku',
      'Jer deset postupaka objašnjenih jedan za drugim nitko ne zapamti — '
          'zapisano pitaš ciljano',
      'Jer se nepostavljena pitanja inače negativno bilježe u ocjeni',
    ],
    correctIndex: 1,
    explanation: 'Trener u dva dana objašnjava vrlo mnogo odjednom; navečer '
        'od toga bez bilježaka ostaje malo. Tko svoja pitanja pripremi i '
        'usput zapiše dvije natuknice po temi, iz ta dva dana izvuče '
        'višestruko više. Formalna obveza to nije — i nitko negativno ne '
        'bilježi nepostavljena pitanja. Upravo se zato sam moraš za to '
        'pobrinuti.',
  ),
];
