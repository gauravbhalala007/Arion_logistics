// lib/data/safety_training/driving_safety_quiz_hr.dart
//
// Pitanja DSP treninga sigurne voznje — hrvatska verzija.
// Struktura i redoslijed identicni njemackom izvorniku: isti broj
// pitanja, isti redoslijed, isti tocni odgovori.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> drivingQuestionsHr = [
  // ══════════════════════════════════ M1 — Kultura sigurnosti
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Zaostaješ 20 stajanja za planom. Koja reakcija odgovara '
        'kulturi sigurnosti u tvrtki?',
    options: [
      'Između stajanja voziti brže, ali na samim stajanjima ostati '
          'pažljiv',
      'Prijaviti zaostatak i turu nastaviti uobičajenim sigurnim '
          'tempom',
      'Skratiti vrijeme kontrole pri manevriranju, ali ponašanje u '
          'vožnji ostaviti nepromijenjeno',
    ],
    correctIndex: 1,
    explanation: 'Vremenski pritisak je problem planiranja i prijavljuje '
        'se, a ne nadoknađuje za volanom. Druga dva odgovora zvuče kao '
        'kompromis, ali rizik samo premještaju: veća brzina između '
        'stajanja produljuje upravo zaustavni put, a skraćene kontrole '
        'pri manevriranju pogađaju djelatnost kod koje nastaje 70 % svih '
        'šteta.',
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Tvoj disponent ti naloži da kreneš s neispravnim '
        'stop-svjetlom. Tko nosi odgovornost ako zbog toga dođe do '
        'nalijetanja straga?',
    options: [
      'Disponent, jer je dao nalog',
      'Tvrtka, jer ona daje vozilo',
      'Nitko — jedno stop-svjetlo nije nedostatak bitan za sigurnost',
      'Ti kao vozač vozila',
    ],
    correctIndex: 3,
    explanation: 'Kao vozač odgovaraš za prometno sigurno stanje vozila '
        'koje pokrećeš — usmeni nalog to ne ukida. To što tvrtka daje '
        'vozilo zvuči logično, ali te ne oslobađa: kazna i bodovi pogađaju '
        'tebe osobno. Ispravno je prijaviti nedostatak i zatražiti drugo '
        'vozilo.',
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Pri manevriranju nedostajalo je samo nekoliko centimetara '
        'do stupića — nije se ništa dogodilo. Što je ispravno?',
    options: [
      'Prijaviti kao izbjegnutu nesreću',
      'Ne činiti ništa, ionako nije nastala šteta i nitko nije ugrožen',
      'Prijaviti samo ako je to vidio kolega ili kamera',
    ],
    correctIndex: 0,
    explanation: 'Izbjegnuta nesreća pokazuje opasno mjesto prije nego '
        'nekoga pogodi — prijavljena, ona je za sljedećeg kolegu '
        'obezopašena. Misao „nema štete, nema teme" najčešći je razlog '
        'zašto isto mjesto tjednima poslije ipak dovede do štete.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Pri kojoj djelatnosti nastaje oko 70 % svih šteta na '
        'kombijima?',
    options: [
      'Na autocesti i regionalnoj cesti pri velikoj brzini',
      'Pri skretanju na raskrižjima u gradskom prometu',
      'Pri manevriranju i vožnji unatrag',
    ],
    correctIndex: 2,
    explanation: 'Velika većina šteta nastaje brzinom pješaka pri '
        'manevriranju. Velika brzina uzrokuje najteže nesreće, ali ne i '
        'najviše šteta — upravo ta zamjena dovodi do toga da se pri '
        'manevriranju premalo pazi.',
  ),

  // ══════════════════════════════════ M2 — Provjera vozila i teret
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Teret se prema priznatim pravilima tehnike mora osigurati '
        'protiv 0,8 g prema naprijed. Kojoj sili držanja to otprilike '
        'odgovara kod paketa od 20 kg?',
    options: [
      'oko 2 kg',
      'oko 8 kg',
      'oko 16 kg',
      'oko 200 kg',
    ],
    correctIndex: 2,
    explanation: '0,8 × 20 kg daje oko 16 kg sile držanja. „Oko 2 kg" '
        'dramatično podcjenjuje silu i razlog je zašto se paketi smatraju '
        'bezopasnima; „200 kg" brka propis o osiguranju s udarnom silom '
        'kod pravog sudara, koja je zapravo još daleko iznad toga.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Kako pravilno tovariš teretni prostor?',
    options: [
      'Teško dolje i naprijed uz pregradnu stijenu, težina ravnomjerno '
          'raspoređena',
      'Teško gore, kako teški paketi pri hvatanju ne bi ležali ispod '
          'lakih',
      'Teško straga uz vrata, kako bi teške pošiljke prve izašle',
    ],
    correctIndex: 0,
    explanation: 'Teško + nisko + naprijed drži težište nisko, a masu '
        'ondje gdje je pregradna stijena može zaustaviti. Druge dvije '
        'varijante mišljene su prema tijeku posla, a ne prema fizici: '
        'težina gore povećava sklonost prevrtanju, težina straga rasterećuje '
        'prednju osovinu i pogoršava upravljanje.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Nakon dvije trećine ture teretni prostor je poluprazan. Što '
        'sada vrijedi za osiguranje tereta?',
    options: [
      'Manje je važno jer je znatno manje težine u vozilu',
      'Mora se iznova uspostaviti — preostali paketi sada imaju više puta '
          'da uhvate brzinu',
      'Vrijedi nepromijenjeno dalje, ništa se ne treba činiti',
    ],
    correctIndex: 1,
    explanation: 'Što je teretni prostor prazniji, to je veća dionica na '
        'kojoj paket može ubrzati prije nego udari. „Manje težine, manje '
        'opasnosti" zvuči logično, ali je pogrešno: presudna nije ukupna '
        'masa, nego pojedinačni neosigurani paket.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Što od tebe traži DGUV Vorschrift 70 (njemački propis o '
        'vozilima) prije početka radne smjene?',
    options: [
      'Tehnički pregled s dizalicom i uređajem za ispitivanje kočnica',
      'Provjeru vozila na očite nedostatke',
      'Provjeru samo kod vozila koja voziš prvi put',
    ],
    correctIndex: 1,
    explanation: 'Traži se provjera uočljivih nedostataka prije smjene — '
        'točno ono što obilazak i daje. Tehnički pregled je stvar servisa '
        'i ne zamjenjuje tvoj obilazak; a obveza vrijedi za svako vozilo '
        'svakog dana, ne samo za nepoznata.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Koju najmanju dubinu šare propisuje zakon — i što ima '
        'smisla na mokrom kolniku?',
    options: [
      '3 mm zakonski; po mokrom su onda dovoljna 1,6 mm',
      '1,6 mm zakonski; to je i po mokrom nepromijenjeno dovoljno',
      '4 mm zakonski, cijele godine za sve gume',
      '1,6 mm zakonski; po mokrom ima smisla najmanje 3 mm',
    ],
    correctIndex: 3,
    explanation: 'Zakonski minimum je 1,6 mm, praktično smisleno po '
        'mokrom najmanje 3 mm. Odgovor „1,6 mm dovoljno je i po mokrom" '
        'klasična je zabluda: minimum je granica prema prekršaju, a ne '
        'granica prema sigurnosti — kod 1,6 mm guma gotovo više ne '
        'istiskuje vodu.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Sljedeće stajanje leži na suvozačevom sjedalu da ga brzo '
        'dohvatiš. Što je tu glavni problem?',
    options: [
      'Paket pri kočenju postane projektil i može dospjeti pod papučicu '
          'kočnice',
      'Kod prometne kontrole izgleda neuredno',
      'Dopušteno je dok god paket teži manje od 10 kg',
    ],
    correctIndex: 0,
    explanation: 'Sve u kabini pri kočenju nastavlja se kretati tvojom '
        'početnom brzinom — u najgorem slučaju u prostor za noge pod '
        'papučicu. Granice težine za to nema: i lagan paket blokira '
        'papučicu.',
  ),

  // ══════════════════════════════════ M3 — Defenzivna vožnja
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Voziš izvan naselja 80 km/h po suhoj cesti. Koji je razmak '
        'do vozila ispred najmanje ispravan?',
    options: [
      'Oko 20 metara — to odgovara trima duljinama vozila',
      'Oko 45 metara — otprilike dvije sekunde odnosno pola vrijednosti '
          'brzinomjera',
      'Oko 10 metara, dok si pažljiv i cesta je slobodna',
    ],
    correctIndex: 1,
    explanation: 'Dvije sekunde pri 80 km/h odgovaraju oko 45 metara, pola '
        'vrijednosti brzinomjera 40 metara — oboje se poklapa. 20 metara '
        'na cesti djeluje mnogo, ali je ispod čistog puta reakcije od 24 '
        'metra: naletio bi prije nego kočnica uopće uhvati.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Koliko je dug zaustavni put pri 50 km/h prema praktičnim '
        'formulama (normalno kočenje)?',
    options: [
      '15 metara',
      '25 metara',
      '40 metara',
      '65 metara',
    ],
    correctIndex: 2,
    explanation: 'Put reakcije (50 ÷ 10) × 3 = 15 m plus put kočenja '
        '(50 ÷ 10)² = 25 m daje 40 m. Tko kaže 25 metara, računao je samo '
        'put kočenja i zaboravio put reakcije — to je najčešća računska '
        'pogreška i upravo onaj dio dionice koji prelaziš punom brzinom.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Kako računaš put reakcije prema praktičnoj formuli?',
    options: [
      '(Brzina ÷ 10) × 3',
      '(Brzina ÷ 10) × (Brzina ÷ 10)',
      'Brzina ÷ 2',
    ],
    correctIndex: 0,
    explanation: 'Put reakcije je (km/h ÷ 10) × 3. Druga formula je put '
        'kočenja, treća praktična vrijednost za sigurnosni razmak — obje '
        'izgledaju slično, ali opisuju nešto posve drugo.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Udvostručuješ brzinu s 30 na 60 km/h. Kako se mijenja čisti '
        'put kočenja?',
    options: [
      'Udvostručuje se',
      'Učetverostručuje se',
      'Utrostručuje se',
      'Ostaje gotovo isti jer kočnica pri većoj brzini jače hvata',
    ],
    correctIndex: 1,
    explanation: 'Put kočenja raste s kvadratom brzine: od 9 metara '
        'postane 36 metara. Nametljiv odgovor „udvostručuje" podcjenjuje '
        'upravo to — on objašnjava zašto se 20 km/h više u stambenoj ulici '
        'doživljava kao bezopasno.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Zašto s punim natovarenim kombijem moraš voziti znatno '
        'sporije u zavojima nego s osobnim autom?',
    options: [
      'Jer visoko težište snažno povećava sklonost prevrtanju',
      'Jer upravljanje pri teretu postaje nepreciznije',
      'Jer gume pod teretom postaju mekše i imaju više prianjanja',
    ],
    correctIndex: 0,
    explanation: 'Visoko natovaren kombi prevrne se ondje gdje osobni auto '
        'još kliže — i to jedva najavljuje. Preciznost upravljanja se '
        'doduše također mijenja, ali nije pravi rizik: prevrtanje se '
        'dogodi naglo i završi izvan kolnika.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Želiš na semaforu skrenuti udesno, biciklist stoji desno '
        'pokraj tebe. Semafor se pali zeleno. Što činiš prvo?',
    options: [
      'Brzo kreneš i skreneš prije nego biciklist krene',
      'Pogledaš u desno vanjsko ogledalo i onda zakreneš',
      'Pogled preko desnog ramena i propustiš biciklista',
    ],
    correctIndex: 2,
    explanation: 'Čim kreneš i zakreneš, biciklist ulazi u mrtvi kut — a '
        'tvoj stražnji dio dodatno zalazi u njegovu traku. Pogled u '
        'ogledalo zvuči ispravno, ali baš tada više nije dovoljan kad je '
        'najvažnije: ogledalo ne pokazuje u cijelosti područje desno uz '
        'kabinu.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Koji najmanji bočni razmak moraš držati u naselju pri '
        'pretjecanju biciklista?',
    options: [
      '1,0 metar',
      '1,5 metra',
      '2,0 metra',
    ],
    correctIndex: 1,
    explanation: 'U naselju je to 1,5 metra, izvan naselja 2,0 metra. Tko '
        '2,0 metra smatra vrijednošću za naselje, brka oboje — a tko '
        'pretječe s 1,0 metrom, krši najmanji razmak i odgovara ako '
        'biciklist padne.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Koliko daleko unaprijed treba biti usmjeren tvoj pogled '
        'pri vožnji?',
    options: [
      'Na branik vozila ispred, kako bi odmah vidio njegovo kočenje',
      'Na vlastiti poklopac motora, jer tako najtočnije držiš traku',
      '12–15 sekundi unaprijed',
    ],
    correctIndex: 2,
    explanation: 'Dalek pogled ti pribavlja vrijeme: vidiš semafore, '
        'stop-svjetla i pješake prije nego moraš reagirati. Pogled na '
        'branik djeluje pažljivo, ali te pretvara u čistog reagenta — za '
        'opasnost saznaješ tek kad vozilo ispred već koči.',
  ),

  // ══════════════════════════════════ M4 — Unatrag i manevriranje
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Što znači GOAL pri vožnji unatrag?',
    options: [
      '„Get Out And Look" — stani, izađi, pogledaj iza vozila',
      '„Go Only At Low speed" — voziti unatrag isključivo brzinom '
          'pješaka',
      '„Guide On A Line" — orijentirati se prema oznaci na tlu',
    ],
    correctIndex: 0,
    explanation: 'GOAL znači izaći i pogledati — to otkriva niske stupiće, '
        'pad terena i djecu koje sa sjedala nikad ne vidiš. Brzina pješaka '
        'je doduše također obveza, ali ne zamjenjuje gledanje: i brzinom '
        'pješaka voziš u područje koje ne možeš vidjeti.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Tvoje vozilo ima kameru za vožnju unatrag. Što to mijenja u '
        'vezi s GOAL?',
    options: [
      'GOAL otpada jer kamera pokazuje područje iza vozila',
      'Ništa',
      'GOAL je time potreban samo u mraku i pri lošoj vidljivosti',
    ],
    correctIndex: 1,
    explanation: 'Kamera pokazuje samo isječak, iskrivljuje razmake i '
        'oslijepi od kiše, snijega i prljavštine — prije svega ne vidi što '
        'sa strane ulazi u tvoj put. Ona dopunjuje GOAL, nikad ga ne '
        'zamjenjuje.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Gdje navodilac stoji ispravno?',
    options: [
      'Neposredno iza vozila, jer odande najbolje može procijeniti '
          'razmak',
      'Ispred vozila, kako bi istodobno zaustavljao promet',
      'Sa strane, tako da ga stalno vidiš u ogledalu',
    ],
    correctIndex: 2,
    explanation: 'Samo onaj tko stoji sa strane i trajno vidljivo može '
        'sigurno navoditi. Položaj neposredno iza vozila djeluje doduše '
        'najbliže događaju, ali je upravo područje u kojem navodilac sam '
        'bude pregažen čim ga izgubiš iz vida.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Odjednom više ne vidiš svog navodioca u ogledalu. Što '
        'činiš?',
    options: [
      'Voziš dalje sporije dok se ponovno ne pojavi',
      'Odmah staješ',
      'Kratko zatrubiš i voziš dalje kako bi se opet pokazao',
    ],
    correctIndex: 1,
    explanation: 'Nema kontakta pogledom znači nema važećeg znaka — dakle '
        'stati, ne samo usporiti. „Voziti dalje sporije" zvuči oprezno, '
        'ali znači da i dalje voziš u područje koje za tebe više nitko ne '
        'nadzire.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Što traži § 9 st. 5 StVO pri vožnji unatrag?',
    options: [
      'Uključiti sva četiri žmigavca',
      'Voziti najviše brzinom pješaka',
      'Isključiti ugrožavanje drugih — po potrebi uz navodioca',
    ],
    correctIndex: 2,
    explanation: 'Propis zahtijeva isključenje svakog ugrožavanja, po '
        'potrebi uz navodioca — mjerilo je dakle rezultat, a ne određena '
        'brzina. Brzina pješaka i sva četiri dobra su praksa, ali sami po '
        'sebi ne ispunjavaju obvezu.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Zadnje stajanje je u uskom unutarnjem dvorištu: naprijed '
        'ulaziš, van samo unatrag pokraj zida. Koja je najsigurnija '
        'odluka?',
    options: [
      'Stati na ulici i zadnje metre prijeći pješice odnosno s kolicima',
      'Ući naprijed jer se ulaz onda već poznaje za povratak',
      'Brzo ući unatrag dok je ulica još slobodna',
    ],
    correctIndex: 0,
    explanation: 'Najsigurnija vožnja unatrag je ona koja se uopće ne '
        'dogodi. To da se ulaz „nakon ulaska poznaje" je zabluda: pri '
        'izlasku su kritične točke iza tebe, a promet koji čeka dodatno '
        'stvara pritisak.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M5 — Vrijeme i vidljivost
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Volan odjednom postane lagan, gume plivaju na vodenom '
        'filmu. Što činiš?',
    options: [
      'Snažno kočiš i kontriraš volanom',
      'Skineš gas, volan držiš mirno ravno, pustiš vozilo da se izveze',
      'Ubrzavaš kako bi brzo napustio mjesto s vodom',
    ],
    correctIndex: 1,
    explanation: 'Dok god vodeni film nosi, kočnica i upravljanje ne '
        'djeluju — oni djeluju naglo tek kad guma opet uhvati, i upravo '
        'iz toga nastaje proklizavanje. Kočenje i kontriranje intuitivna '
        'je, ali pogrešna reakcija.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'O čemu najviše ovisi opasnost od akvaplaninga?',
    options: [
      'O težini tereta',
      'O starosti vozila i kočionog sustava',
      'O dubini šare, visini vode i prije svega o brzini',
    ],
    correctIndex: 2,
    explanation: 'Opasnost raste neproporcionalno s brzinom i pada s '
        'dubinom šare — šara mora odvesti vodu ispred gume. Teret igra '
        'sporednu ulogu: veća težina doduše jače pritišće gumu na cestu, '
        'ali ne mijenja to da plitka šara pri brzini više ne istiskuje '
        'vodu.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'U magli vidiš još oko 40 metara daleko. Koliko brzo smiješ '
        'najviše voziti?',
    options: [
      'Najviše 40 km/h',
      'Do dopuštene najveće brzine, dok su svjetla upaljena',
      'Najviše 80 km/h ako je stražnje svjetlo za maglu uključeno',
    ],
    correctIndex: 0,
    explanation: 'Pravilo: vidljivost u metrima tvoja je gornja granica u '
        'km/h — kod 40 metara vidljivosti dakle 40 km/h. Svjetla i '
        'stražnje svjetlo za maglu čine te vidljivijim, ali ne produljuju '
        'tvoju vidljivost pa time ni dopuštenu brzinu.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Kada § 2 st. 3a StVO propisuje zimske gume?',
    options: [
      'Uvijek u razdoblju od listopada do Uskrsa, neovisno o vremenu',
      'Kod poledice, snježne poledice, snježne bljuzge, ledene ili inja',
      'Samo ako na kolniku leži zatvoreni snježni pokrivač',
    ],
    correctIndex: 1,
    explanation: 'U Njemačkoj vrijedi situacijska obveza: ona ovisi o '
        'stanju ceste, a ne o kalendaru. „Od listopada do Uskrsa" samo je '
        'praktično pravilo za zamjenu guma, a ne pravna osnova — i '
        'snježna bljuzga je već dovoljna, ne mora ležati zatvoreni '
        'pokrivač.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Ledeno je hladno i pod vremenskim si pritiskom. Ostružeš '
        'samo vozačevu stranu vjetrobrana. Što vrijedi?',
    options: [
      'Dopušteno, dok god voziš znatno sporije',
      'Dopušteno ako grijanje ostatak oslobodi tijekom vožnje',
      'Nije dopušteno — sva stakla, ogledala, svjetla i registarska '
          'pločica moraju biti slobodni',
    ],
    correctIndex: 2,
    explanation: 'Ostrugana „rupica za gledanje" je prekršaj, a kod '
        'nesreće težak prigovor krivnje. To što grijanje naknadno '
        'oslobodi staklo nije iznimka: mjerodavno je stanje pri polasku, '
        'a ne tri minute poslije.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Zašto je PRAZAN kombi za oluje posebno ugrožen?',
    options: [
      'Jer mu nedostaje težina tereta koja ga drži na cesti',
      'Jer je otpor zraka bez tereta veći',
      'Jer je tlak u gumama u praznom stanju viši',
    ],
    correctIndex: 0,
    explanation: 'Površina izložena vjetru jednako je velika prazna kao i '
        'natovarena, ali je masa znatno manja — isti udar dakle vozilo '
        'jače pomakne. Otpor zraka se teretom u unutrašnjosti uopće ne '
        'mijenja, to je pogreška u razmišljanju.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M6 — Ometanje i umor
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Smiješ li tijekom vožnje uzeti mobitel u ruku da promijeniš '
        'glazbu?',
    options: [
      'Da, ako traje samo sekundu i cesta je slobodna',
      'Samo na crvenom semaforu',
      'Ne',
    ],
    correctIndex: 2,
    explanation: 'Već je uzimanje ili držanje uređaja prekršaj — neovisno '
        'o tome za što. Crveni semafor nije iznimka dok motor radi. '
        'Glazba, odredište i glasnoća namještaju se prije vožnje, u '
        'mjestu.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Kada pravno smiješ uzeti mobitel ili skener u ruku?',
    options: [
      'Samo kad vozilo stoji I kad je motor ugašen',
      'Čim vozilo stoji — start-stop automatika je za to dovoljna',
      'Nakratko tijekom vožnje, kad je dionica ravna i slobodna',
    ],
    correctIndex: 0,
    explanation: 'Iznimka vrijedi samo kod vozila koje stoji s ugašenim '
        'motorom. Start-stop automatika izričito se ne broji — upravo se '
        'na to mnogi oslanjaju na crvenom semaforu i ondje dobiju svoju '
        'kaznu.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Voziš 50 km/h i gledaš 2 sekunde u zaslon. Koliko daleko '
        'pritom voziš bez pogleda na cestu?',
    options: [
      'oko 8 metara',
      'oko 28 metara',
      'oko 14 metara',
      'oko 50 metara',
    ],
    correctIndex: 1,
    explanation: '50 km/h je oko 14 metara u sekundi, u 2 sekunde dakle '
        'otprilike 28 metara. Tko odabere „14 metara", računao je samo '
        'jednu sekundu — tipična pogreška zbog koje slijepa dionica '
        'izgleda upola manja.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Zaspiš pri brzini 80 na 4 sekunde. Koju dionicu prijeđeš '
        'bez kontrole?',
    options: [
      'oko 30 metara',
      'oko 50 metara',
      'oko 90 metara',
      'oko 160 metara',
    ],
    correctIndex: 2,
    explanation: '80 km/h je oko 22 metra u sekundi, puta 4 daje otprilike '
        '89 metara. Za razliku od pogleda na mobitel, u tom vremenu uopće '
        'ne upravljaš — vozilo izlazi iz trake. Zato je predodžba o '
        '„kratkom" zaspavanju tako opasna.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Što stvarno pomaže protiv akutnog umora za volanom?',
    options: [
      'Otvoriti prozor i glasna glazba',
      'Popiti kavu i voziti brže da se prije završi',
      'Stati, 15–20 minuta kratkog sna, nakon toga kretanje',
    ],
    correctIndex: 2,
    explanation: 'Samo san i kretanje ponovno uspostavljaju pažnju. Svjež '
        'zrak i glasna glazba djeluju najviše nekoliko minuta i pritom '
        'lažno stvaraju dojam budnosti — upravo se u toj fazi čovjek '
        'najjače precjenjuje.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Jedna bubica za handsfree funkciju, drugo uho slobodno — je '
        'li to tijekom vožnje u redu?',
    options: [
      'Da, jedno slobodno uho dovoljno je za promet',
      'Da, dok god je glasnoća postavljena nisko',
      'Ne',
    ],
    correctIndex: 2,
    explanation: 'Moraš moći pouzdano odrediti odakle dolaze trube, '
        'dozivanje i vozila hitnih službi — a za to trebaš oba uha; pri '
        'manevriranju je sluh često jedino upozorenje. Niska glasnoća ne '
        'mijenja to da je jedno uho zauzeto.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Što ti prijeti ako s mobitelom u ruci ugroziš drugog '
        'sudionika u prometu?',
    options: [
      '100 € i 1 bod',
      '150 €, 2 boda i 1 mjesec zabrane vožnje',
      'Usmeno upozorenje bez upisa',
    ],
    correctIndex: 1,
    explanation: '100 € i 1 bod osnovni su prekršaj bez ugrožavanja; '
        'pridođe li ugrožavanje, raste na 150 €, 2 boda i mjesec dana '
        'zabrane vožnje. Za tebe kao profesionalnog vozača problem nije '
        'novac, nego zabrana vožnje.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Plan ture danas se ne može sigurno odraditi. Koja je '
        'ispravna reakcija?',
    options: [
      'Sigurno nastaviti raditi i rano prijaviti problem planiranja',
      'Ukinuti pauze i skratiti kontrole pri manevriranju',
      'Voziti brže između stajanja i vrijeme nadoknaditi ondje',
    ],
    correctIndex: 0,
    explanation: 'Plan se prilagođava, a ne sigurnost. Presudan je uz to '
        'trenutak: prijava u rano poslijepodne još može nešto promijeniti, '
        'ona navečer više ne. Ukidanje pauza pogoršava problem jer ti '
        'pažnja upravo tada pada.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M7 — Izlazak i dizanje
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Kako glasi pravilo triju točaka („2+1") BG Verkehr pri '
        'ulasku i izlasku?',
    options: [
      'Jedna ruka i dva stopala uvijek su na vozilu',
      'Dvije ruke i jedno stopalo uvijek su u dodiru s vozilom',
      'Oba stopala stoje na tlu prije nego pustiš rukohvate',
    ],
    correctIndex: 1,
    explanation: 'Dvije ruke plus jedno stopalo daju tri čvrste točke, '
        'tako da pojedinačno klizanje nikad ne dovede do pada. „Oba '
        'stopala prvo na tlo" opisuje upravo trenutak u kojem uopće nemaš '
        'oslonca — to je varijanta sa skokom.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Kako pravilno izlaziš iz kabine?',
    options: [
      'Naprijed, leđima prema vratima, zadnji korak skokom',
      'Bočno se izviti iz sjedala i doskočiti na oba stopala',
      'Unatrag, licem prema vozilu, kao na ljestvama',
    ],
    correctIndex: 2,
    explanation: 'Samo licem prema vozilu možeš koristiti rukohvate i '
        'stepenicu te držati tri dodirne točke. Izvijanje iz sjedala '
        'djeluje brže, ali opterećuje koljeno i skočni zglob punom '
        'tjelesnom težinom odjednom — to je najčešća pogreška pri '
        'izlasku.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Koji se od ovih hvatova NE broji kao sigurna dodirna '
        'točka?',
    options: [
      'Rukohvat na A-stupu',
      'Rub vrata',
      'Rukohvat na okviru vrata',
    ],
    correctIndex: 1,
    explanation: 'Rub vrata pripada pokretnom dijelu: vrata mogu popustiti '
        'ili se zaljuljati, upravo kad na njih prebaciš svoju težinu. Isto '
        'vrijedi za volan, sjedalo, gumu i glavčinu kotača — sigurne točke '
        'su samo za to predviđeni rukohvati.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Imaš skener i paket u rukama i želiš izaći iz teretnog '
        'prostora. Što je ispravno?',
    options: [
      'Oboje prvo odložiti, pa sići slobodnih ruku',
      'Paket stisnuti pod ruku i držati se slobodnom rukom',
      'Brzo izaći, ionako su samo dvije stepenice',
    ],
    correctIndex: 0,
    explanation: 'S punim rukama nemaš tri dodirne točke i ne možeš '
        'zaustaviti pad. Varijanta s jednom rukom zvuči kao kompromis, ali '
        'je upravo situacija u kojoj klizanje izravno vodi u pad: jedna te '
        'točka ne drži.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Stojiš uz rub kolnika i želiš otvoriti vozačeva vrata. Što '
        'najbolje štiti biciklista koji dolazi straga?',
    options: [
      'Vrata otvoriti samo odškrinuto i kratko pričekati',
      'Vrata otvoriti brzo i široko kako bi bila dobro vidljiva',
      'Prije otvaranja kratko pogledati u vanjsko ogledalo',
      'Pogled preko ramena i ogledalo — i vrata otvoriti udaljenijom '
          'rukom',
    ],
    correctIndex: 3,
    explanation: 'Hvat udaljenijom rukom automatski ti okreće gornji dio '
        'tijela unatrag i prisiljava na pogled. Sam kratak pogled u '
        'ogledalo nije dovoljan jer biciklist u mrtvom kutu baš tada nije '
        'vidljiv; a otvaranje na prst ne upozorava nikoga tko je već '
        'pokraj tebe.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Koja je pri dizanju najopasnija kombinacija za '
        'kralježnicu?',
    options: [
      'Podizati i pritom uvrtati gornji dio tijela',
      'Podizati s jako savijenim koljenima iz čučnja',
      'Podizati s teretom tijesno uz tijelo',
    ],
    correctIndex: 0,
    explanation: 'Teret plus okretanje jednostrano opterećuje diskove i '
        'klasičan je uzrok akutnih ozljeda leđa — umjesto toga prekorači '
        'stopalima. Čučanj i teret uz tijelo upravo su suprotno ispravna '
        'tehnika.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Pri izlasku lagano uganeš nogu, ali možeš nastaviti raditi. '
        'Što je ispravno?',
    options: [
      'Pričekati i prijaviti samo ako sljedeći dan još boli',
      'Ne činiti ništa — bilo je to samo uganuće bez izostanka',
      'Odmah prijaviti i upisati u knjigu prve pomoći',
    ],
    correctIndex: 2,
    explanation: 'Samo dokumentirani događaji kasnije vrijede kao nesreća '
        'na radu, a neliječen problem s ligamentima lošije zacjeljuje. '
        'Čekanje do sljedećeg dana rašireno je i upravo je razlog zašto se '
        'povezanost s poslom kasnije često više ne priznaje.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M8 — Kućna vrata i okolina
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Velik pas laje na vrtnim vratima. Kupac je u napomeni za '
        'dostavu zabilježio: „Pas je dobar." Što činiš?',
    options: [
      'Mirno ući — kupac najbolje poznaje svog psa',
      'Ne stupiti na posjed, pokušati kontakt i ostaviti napomenu za '
          'kolege',
      'Paket prebaciti preko ograde i odvesti se dalje',
    ],
    correctIndex: 1,
    explanation: 'Napomena za dostavu nije sigurnosna dozvola: kupac '
        'poznaje svog psa u odnosu s obitelji, a ne sa stranim čovjekom '
        'koji nosi velik predmet. Prebaciti paket preko ograde uz to nije '
        'uredna dostava.',
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Slobodan pas dolazi lajući prema tebi. Što je ispravno?',
    options: [
      'Mirno ostati stajati, odvratiti pogled, okrenuti mu bok i polako '
          'se povlačiti',
      'Brzo otrčati natrag do vozila i zatvoriti vrata',
      'Postati glasan i podignuti paket za obranu',
    ],
    correctIndex: 0,
    explanation: 'Mir, odvraćen pogled i polagano uzmicanje oduzimaju psu '
        'povod. Otrčati do vozila zvuči razumno, ali je pogrešno: bijeg '
        'pokreće lovni refleks, a pas je brži od tebe.',
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Najkraći put do ulaznih vrata vodi preko mokrog travnjaka. '
        'Što činiš?',
    options: [
      'Kratiš — kod 120 stajanja zaobilazak se znatno zbraja',
      'Kratiš, ali samo po danjem svjetlu i suhom vremenu',
      'Ideš izgrađenim putem',
    ],
    correctIndex: 2,
    explanation: 'Spoticanje, klizanje i padanje najčešći je uzrok ozljeda '
        'u dostavi, i gotovo se uvijek događa na zadnjim metrima. Računica '
        'vremena ne izlazi: zaobilazak košta sekunde, a pad u prosjeku 24 '
        'dana izostanka.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Što vrijedi kad napuštaš vozilo radi dostave?',
    options: [
      'Motor ugašen, ključ ponijeti, zaključati, na nagibu okrenuti '
          'kotače',
      'Motor smije raditi dok god ostaješ u vidokrugu',
      'Dovoljno je čvrsto zategnuti ručnu kočnicu',
    ],
    correctIndex: 0,
    explanation: 'Tko napusti svoje vozilo, mora ga osigurati od '
        'neovlaštene uporabe i izbjeći nesreće. „U vidokrugu" nije iznimka '
        '— upaljeno, otvoreno vozilo nestane u nekoliko sekundi, a na '
        'nagibu sama ručna kočnica ne drži pouzdano natovaren kombi.',
  ),

  // ══════════════════════════════════ M9 — Hitni slučaj i nesreća
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Kojim redoslijedom postupaš na mjestu nesreće s '
        'ozlijeđenima?',
    options: [
      'Pružiti prvu pomoć, zatim osigurati, zatim uputiti hitni poziv',
      'Osigurati, zatim hitni poziv, zatim prva pomoć',
      'Hitni poziv, zatim fotografije za osiguranje, zatim prva pomoć',
    ],
    correctIndex: 1,
    explanation: 'Prvo osiguraj mjesto, inače iz jedne nesreće nastane '
        'druga — s tobom kao žrtvom. Odmah otrčati do ozlijeđenog djeluje '
        'ljudski ispravno, ali je na regionalnoj cesti i autocesti opasno '
        'po život; fotografije u toj fazi nemaju nikakvo mjesto.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Na kojoj udaljenosti postavljaš sigurnosni trokut na '
        'autocesti?',
    options: [
      'oko 50 metara',
      'oko 100 metara',
      'oko 150–200 metara',
    ],
    correctIndex: 2,
    explanation: 'U naselju oko 50 m, izvan naselja oko 100 m, na '
        'autocesti 150–200 m — što je brzina veća, to ranije upozorenje '
        'mora stajati. Tko uzme vrijednost za izvan naselja, daje prometu '
        'koji nailazi pri 120 km/h jedva tri sekunde. Prije uzvišenja i '
        'zavoja trokut ide ispred njih, a ne iza.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Na autocesti s tri traka promet je zastao. Gdje stvaraš '
        'koridor za hitne službe?',
    options: [
      'Između lijevog i srednjeg traka',
      'Između srednjeg i desnog traka',
      'Na zaustavnom traku',
      'U sredini kolnika, neovisno o broju traka',
    ],
    correctIndex: 0,
    explanation: 'Koridor je uvijek između krajnje lijevog i neposredno '
        'desno uz njega položenog traka — neovisno o tome koliko traka '
        'ima. Zaustavni trak nije alternativa: ondje voze hitne službe kad '
        'je koridor blokiran.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Kada se koridor za hitne službe mora stvoriti?',
    options: [
      'Tek kad se vidi ili čuje rotirajuće svjetlo',
      'Čim promet zastane',
      'Tek kad se to naredi preko prometne ploče',
    ],
    correctIndex: 1,
    explanation: 'Koridor nastaje sa zastojem, a ne s rotirajućim '
        'svjetlom. Čeka li se vozilo hitne službe, vozila odavno stoje '
        'preblizu — tada nitko više nema mjesta za izmicanje.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Pri manevriranju oštetiš parkirani auto, nikoga nema u '
        'blizini. Je li dovoljna poruka iza brisača?',
    options: [
      'Da, ako na njoj piše ime i broj telefona',
      'Da, poruka je zakonom predviđen put',
      'Ne — dovoljno je samo ako uz to napraviš fotografije',
      'Ne — moraš primjereno vrijeme pričekati i inače obavijestiti '
          'policiju',
    ],
    correctIndex: 3,
    explanation: 'Poruka pravno ne vrijedi kao dostatno utvrđivanje — može '
        'odletjeti ili biti uklonjena; tko se na nju osloni, riskira '
        'optužbu za nedopušteno udaljavanje s mjesta nesreće. Fotografije '
        'doduše dokumentiraju štetu, ali ne zamjenjuju ni čekanje ni '
        'prijavu.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Osoba nakon nesreće ne diše normalno. Što činiš?',
    options: [
      'Odmah započeti masažu srca, otprilike 100–120 puta u minuti',
      'Osobu staviti u bočni položaj i pokriti',
      'Čekati hitnu pomoć — kao laik ne smiješ ništa raditi',
    ],
    correctIndex: 0,
    explanation: 'Bez normalnog disanja svaka minuta se broji, a pritisak '
        'je jedina mjera koja pomaže. Bočni položaj je ispravan — ali samo '
        'kod postojećeg normalnog disanja. A nečinjenje je jedina pogrešna '
        'odluka: nepružanje pomoći je kažnjivo.',
  ),

  // ══════════════════════════════════ M10 — Sažetak
  DrivingQuestion(
    moduleId: 'm10',
    question: 'Što najbolje sažima stav ove obuke?',
    options: [
      'Pravila vrijede prije svega onda kad se kontrolira',
      'Sigurnost je moja svakodnevna odluka, kako bi svi sigurno došli '
          'kući',
      'Glavno je da je tura odrađena na vrijeme',
    ],
    correctIndex: 1,
    explanation: 'Sigurnost je stav, a ne obvezna vježba — i pokazuje se '
        'upravo onda kad nitko ne gleda. Tko pravila veže uz kontrole, '
        'nije ih shvatio, nego samo izdržao.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm10',
    question: 'Koliko dodirnih točaka držiš pri ulasku i izlasku — i '
        'koliko sekundi razmaka najmanje na suhoj cesti?',
    options: [
      '2 dodirne točke i 1 sekunda',
      '3 dodirne točke i 1 sekunda',
      '3 dodirne točke (2 ruke + 1 stopalo) i 2 sekunde',
    ],
    correctIndex: 2,
    explanation: 'Tri dodirne točke („2+1") i dvije sekunde razmaka — po '
        'mokrom tri. Jedna sekunda razmaka pri brzini 50 odgovara točno '
        'čistom putu reakcije: naletio bi bez ikakve rezerve za kočenje.',
  ),
];

// Odabir jezika, `drivingQuestionsForModule()` i `buildDrivingExam()`
// nalaze se u driving_safety_data.dart.
