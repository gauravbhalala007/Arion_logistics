// lib/data/safety_training/operating_instructions_hu.dart
//
// Betriebsanweisungen — ungarische Fassung.
// Übersetzung der deutschen Master-Fassung
// (operating_instructions_de.dart). IDs, Kategorien und Listenlängen
// bleiben identisch.

import 'operating_instructions.dart';

const List<OperatingInstruction> operatingInstructionsHu = [
  // ─────────────────────────────────────────── Jármű
  OperatingInstruction(
    id: 'baw_transporter',
    title: 'Vezetés 3,5 t-ig terjedő kisteherautóval',
    subtitle: 'Kézbesítő jármű vezetése, tolatás, leállítás',
    category: InstructionCategory.vehicle,
    scope: 'Minden munkatársra vonatkozik, aki 3,5 t megengedett '
        'össztömegig terjedő kézbesítő járművet vezet.',
    hazards: [
      'Közlekedési balesetek figyelemelterelés, időnyomás és fáradtság '
          'miatt',
      'Személyek elütése tolatás közben — holttér',
      'Elcsúszó rakomány fékezéskor és kanyarban',
      'Elesés be- és kiszálláskor',
      'A megengedett össztömeg túllépése',
    ],
    protection: [
      'Tartsd magadnál az érvényes vezetői engedélyt',
      'Indulás előtti ellenőrzés az út megkezdése előtt: világítás, '
          'gumiabroncsok, fékek, kilátás, rakományrögzítés',
      'Az első út előtt állítsd be az ülést, a tükröket és a fejtámlát',
      'Csatold be a biztonsági övet — a két megálló közötti rövid '
          'szakaszon is',
      'Semmi alkohol, semmi kábítószer, semmi vezetési képességet '
          'befolyásoló gyógyszer az út előtt és közben',
      'Mobiltelefon csak kihangosítóval, címbevitel csak álló '
          'helyzetben',
      'Veszélyeztetés esetén csak irányító személlyel tolass; kétség '
          'esetén szállj ki és nézd meg a környezetet',
      'Rögzítsd a rakományt elcsúszás ellen, a nehéz küldemények '
          'alulra és a homlokfalhoz kerüljenek',
      'A járművet elhagyás után mindig zárd be, a kulcsot soha ne '
          'hagyd benne',
      'Tartsd be a szünet- és vezetésiidő-szabályokat',
    ],
    onFailure: [
      'Figyelmeztető lámpa vagy szokatlan zaj esetén: hajts biztonságos '
          'helyre és állj meg',
      'Kapcsold be a vészvillogót, vedd fel a láthatósági mellényt, '
          'helyezd ki az elakadásjelző háromszöget (kb. 100 m, '
          'autópályán 150–400 m)',
      'Értesítsd a diszpécsert, és az előírt úton kérj műszaki '
          'segítséget',
      'Ne javítsd magad — vontatás csak vonórúddal',
      'Felismerhetően hibás járművet ne mozgass tovább',
    ],
    onAccident: [
      'Állj meg, biztosítsd a baleset helyszínét, a mellényt még '
          'kiszállás előtt vedd fel',
      'Nyújts elsősegélyt, hívd a 112-t',
      'Rendőrség személyi sérülés, magas anyagi kár vagy alkohol- '
          'illetve kábítószergyanú esetén',
      'Cseréljetek személyi és biztosítási adatokat, készíts fotókat '
          'és biztosíts tanúkat',
      'Haladéktalanul értesítsd a munkáltatót; a kisebb sérüléseket is '
          'vezesd be a sérülési naplóba',
    ],
    maintenance: [
      'A hibákat azonnal jelentsd és dokumentáld',
      'Tartsd tisztán a járművet, a látó- és fellépőfelületek legyenek '
          'hó-, jég- és szennyeződésmentesek',
      'Ellenőrizd az elsősegélydoboz, az elakadásjelző háromszög és a '
          'láthatósági mellény hiánytalanságát és lejárati idejét',
      'Tartsd be a karbantartási és vizsgálati időpontokat',
    ],
  ),

  // ─────────────────────────────────────────── Egyéni védőeszköz (PPE)
  OperatingInstruction(
    id: 'baw_sicherheitsschuhe',
    title: 'Munkavédelmi cipő',
    subtitle: 'Lábvédelem a kézbesítésben',
    category: InstructionCategory.ppe,
    scope: 'Minden munkatársra vonatkozik a kézbesítésben, a raktárban '
        'és a járműudvaron.',
    hazards: [
      'Leeső küldemények és rakományrészek',
      'Hegyes vagy éles tárgyakba lépés',
      'Bokaficam és szalagsérülés kiszálláskor, járdaszegélyen és '
          'egyenetlen utakon',
      'Elcsúszás nedves és jeges felületeken',
      'Zúzódások görgős konténerek és kézi raklapemelők miatt',
    ],
    protection: [
      'Viseld a munkavédelmi cipőt a teljes munkaidő alatt — a '
          'telephelyen és az útvonalon is, egész évben és a viseleti '
          'kényelemtől függetlenül',
      'Válaszd inkább a bokáig érő kivitelt — az megtámasztja a bokát '
          'a kifordulás ellen',
      'Legalább S1 védelmi osztály; nedvesség esetén S2, '
          'átszúrásveszély esetén S3',
      'Fűzd be teljesen a cipőt, zárt állapotban viseld',
      'Munkakezdés előtt ellenőrizd a hibákat: futófelület, repedések, '
          'talptapadás',
      'Ne végezz saját átalakítást a cipőn',
      'Soha ne dolgozz edzőcipőben vagy nyitott cipőben',
    ],
    onFailure: [
      'Lekopott futófelület, repedések vagy hibás talp esetén: ne '
          'használd tovább a cipőt',
      'Jelentsd, ha a cipő szorít vagy feltöri a lábad — vannak más '
          'modellek és méretek; a saját edzőcipőre váltás nem megoldás',
      'Kérj cserét a felettesedtől — a munkáltató ingyen biztosítja az '
          'egyéni védőeszközöket (PSA/PPE)',
    ],
    onAccident: [
      'A lábsérüléseket azonnal láttasd el, a látszólag enyhéket is',
      'Bejegyzés a sérülési naplóba',
      'Szúrt sérülés esetén orvosi ellátás — ellenőriztesd a '
          'tetanuszvédettséget',
    ],
    maintenance: [
      'Tisztítsd rendszeresen a cipőt és hagyd megszáradni',
      'Az erősen szennyezett vagy átázott cipőt cseréld ki',
      'A csereciklus a gyártó előírása és a kopás szerint',
    ],
  ),

  OperatingInstruction(
    id: 'baw_warnweste',
    title: 'Láthatósági mellény',
    subtitle: 'Hogy lássanak a közúti térben',
    category: InstructionCategory.ppe,
    scope: 'Minden munkatársra vonatkozik, aki a közúti térben, az '
        'udvaron vagy a rakodófelületeken tartózkodik.',
    hazards: [
      'A többi közlekedő nem vesz észre',
      'Rossz látási viszonyok szürkületben, sötétben, esőben és ködben',
      'Manőverező forgalom a telephely területén',
    ],
    protection: [
      'A láthatósági mellényt kéznél tartsd a vezetőfülkében — ne a '
          'raktérben',
      'Kiszállás előtt vedd fel műszaki hiba, baleset és minden közúti '
          'térben történő megállás esetén',
      'Viseld a telephely területén és a rakodófelületeken, ha ott '
          'járműforgalom van',
      '2-es vagy 3-as osztályú láthatósági mellényt használj, és zárd '
          'be teljesen',
      'Sötétben ügyelj emellett a világításra és a helyzetjelzőre',
    ],
    onFailure: [
      'A szennyezett, kifakult vagy sérült mellényt cseréld le — a '
          'fényvisszaverő csíkoknak hatásosnak kell lenniük',
      'A hiányzó mellényt az út megkezdése előtt jelentsd és pótoltasd',
    ],
    onAccident: [
      'Közúti baleset után tartsd magadon a mellényt, amíg a helyszínt '
          'fel nem számolták',
      'A sérüléseket jelentsd és dokumentáld',
    ],
    maintenance: [
      'Tartsd tisztán a mellényt, a gyártó előírása szerint mosd',
      'Ellenőrizd a meglétét a járműben — része az indulás előtti '
          'ellenőrzésnek',
    ],
  ),

  // ─────────────────────────────────────────── Anyagmozgatás
  OperatingInstruction(
    id: 'baw_heben_tragen',
    title: 'Emelés és teherhordás',
    subtitle: 'Küldemények mozgatása a hát károsítása nélkül',
    category: InstructionCategory.handling,
    scope: 'A küldemények és rakományhordozók kézi emelésére, '
        'hordására és letételére vonatkozik.',
    hazards: [
      'Gerinc- és porckorongsérülések helytelen emelési technika miatt',
      'Izom- és ínsérülések rántásszerű mozdulatok miatt',
      'Kéz- és lábzúzódások letételkor',
      'Megbotlás a nagy küldemények miatti korlátozott kilátás mellett',
    ],
    protection: [
      'Emelés előtt becsüld meg a súlyt és tedd szabaddá az utat',
      'Lépj közel a teherhez, a lábak vállszélességben',
      'A lábadból emelj: menj guggolásba, a hátad tartsd egyenesen',
      'A terhet testközelben vidd, ne karnyújtásnyira',
      'Ne emelj és csavarodj egyszerre — a lábaddal fordulj',
      'A nehéz vagy terjedelmes küldeményeket ketten vagy '
          'segédeszközzel mozgasd (görgős konténer, kézikocsi, kézi '
          'raklapemelő)',
      'Hordás közben tartsd szabadon a kilátást; kétség esetén menj '
          'kétszer',
      'Éles peremű küldeményeknél viselj kesztyűt',
    ],
    onFailure: [
      'A túl nehéz vagy nehezen kezelhető terhet ne mozgasd egyedül — '
          'kérj segítséget',
      'A hibás segédeszközt (szoruló görgők, sérült kézikocsi) ne '
          'használd, és jelentsd',
    ],
    onAccident: [
      'Hirtelen hátfájás esetén azonnal hagyd abba a tevékenységet',
      'Értesítsd a felettesedet, bejegyzés a sérülési naplóba',
      'Tartós panasz esetén keresd fel a baleseti szakorvost '
          '(Durchgangsarzt)',
    ],
    maintenance: [
      'Rendszeresen ellenőrizd a szállítási segédeszközök működését',
      'Tartsd szabadon és csúszásmentesen a közlekedési utakat és a '
          'rakfelületeket',
    ],
  ),

  OperatingInstruction(
    id: 'baw_winter',
    title: 'Téli útviszonyok',
    subtitle: 'Vezetés és kézbesítés hóban, jégen és nedves úton',
    category: InstructionCategory.vehicle,
    scope: 'A kézbesítésre és a járműüzemre vonatkozik téli viszonyok '
        'között.',
    hazards: [
      'Megnövekedett fékút, megcsúszás, aquaplaning',
      'Elesés jeges járdákon, rámpákon és fellépőkön',
      'Kihűlés hosszabb szabadban tartózkodás esetén',
      'Korlátozott kilátás a jeges szélvédő és tükrök miatt',
    ],
    protection: [
      'Az út megkezdése előtt teljesen tisztítsd meg a járművet hótól '
          'és jégtől — a tetőt, a fényszórókat és a rendszámot is',
      'Téli üzemre alkalmas gumiabroncs; szükség esetén vigyél '
          'magaddal hóláncot és indítássegítőt',
      'Ellenőrizd a fagyállót a hűtő- és az ablakmosó folyadékban, '
          'legyen jégkaparó a fedélzeten',
      'Csökkentsd jelentősen a sebességet, a követési távolságot '
          'legalább duplázd meg',
      'Finoman fékezz, kormányozz és gyorsíts',
      'A fellépőket és feljárókat használat előtt tisztítsd meg a '
          'hótól',
      'Viselj meleg, időjárásálló ruházatot és csúszásgátló lábbelit',
      'Kerüld az időnyomást — jobb később megérkezni, mint egyáltalán '
          'nem',
    ],
    onFailure: [
      'Járhatatlan utak esetén szakítsd meg a túrát és értesítsd a '
          'diszpécsert',
      'Elakadás esetén ne próbáld erővel kiszabadítani a járművet — '
          'kérj segítséget',
    ],
    onAccident: [
      'A baleset helyszínét különösen gondosan biztosítsd — az '
          'elakadásjelző háromszöget távolabb helyezd ki',
      'Az esésből származó sérüléseket enyhe tünetek esetén is '
          'jelentsd és dokumentáld',
    ],
    maintenance: [
      'Rendszeresen ellenőrizd az ablaktörlő lapátokat és a világítást',
      'Ápold az ajtótömítéseket, jégtelenítsd a zárakat',
    ],
  ),

  // ─────────────────────────────────────────── Veszélyes anyagok
  OperatingInstruction(
    id: 'baw_adblue',
    title: 'AdBlue (karbamidoldat)',
    subtitle: 'AdBlue utántöltése a kézbesítő járművön',
    category: InstructionCategory.hazardous,
    scope: 'Az AdBlue utántöltésére és kezelésére vonatkozik '
        'SCR-kipufogógáz-tisztítással szerelt járműveknél.',
    hazards: [
      'A szem, a bőr és a légutak irritációja érintkezéskor',
      'Csúszásveszély a kiömlött folyadék miatt',
      'Kristályosodás és korrózió a jármű alkatrészein',
      'Környezetterhelés, ha talajba vagy csatornába kerül',
    ],
    protection: [
      'Csak az erre szolgáló kék betöltőcsonkot használd — soha ne '
          'töltsd a dízeltankba',
      'Viselj védőkesztyűt, kerüld a bőrrel való érintkezést',
      'Csak szabadban vagy jól szellőző helyen tölts utána, a motort '
          'állítsd le',
      'A tartályt zárd le tisztán, ne tárold napon',
      'A munka után alaposan moss kezet',
    ],
    onFailure: [
      'A kiömlött folyadékot azonnal hígítsd vízzel és itasd fel',
      'Használj felitató anyagot, ne öblítsd a csatornába',
      'Téves tankolás esetén ne indítsd el a járművet, és azonnal '
          'jelentsd',
    ],
    onAccident: [
      'Szembe kerülés: legalább 15 percig öblítsd vízzel, keress fel '
          'orvost',
      'Bőrrel érintkezés: bő vízzel mosd le, cseréld le az átitatott '
          'ruhát',
      'Lenyelés: öblítsd ki a szádat, igyál vizet, keress fel orvost',
      'Jelentsd az esetet és vezesd be a sérülési naplóba',
    ],
    maintenance: [
      'Tartsd tisztán a tartályt és a betöltési területet',
      'Az üres göngyöleget az előírás szerint ártalmatlanítsd',
    ],
  ),

  // ─────────────────────────────────────────── Higiénia
  OperatingInstruction(
    id: 'baw_hautschutz',
    title: 'Bőrvédelem és kézhigiénia',
    subtitle: 'A kezed védelme ügyfélkontaktus és rakodás közben',
    category: InstructionCategory.hygiene,
    scope: 'Minden munkatársra vonatkozik, akinek a keze gyakran '
        'érintkezik küldeményekkel, járművekkel és ügyfelekkel.',
    hazards: [
      'Kiszáradás és berepedezés a gyakori mosás és fertőtlenítés '
          'miatt',
      'Bőrirritáció szennyeződés, hideg és tisztítószerek miatt',
      'Fertőzés átvitele ügyfélkontaktus során',
      'Vágott és horzsolt sebek a kartondobozok élein',
    ],
    protection: [
      'Munkakezdés előtt vidd fel a bőrvédő készítményt',
      'Moss kezet WC-használat után, szünetek előtt és rakodás után',
      'A fertőtlenítőszert teljesen dörzsöld be és hagyd megszáradni — '
          'ne töröld le',
      'Mosás után használj bőrápoló készítményt',
      'Éles peremű vagy szennyezett küldeményeknél viselj '
          'védőkesztyűt',
      'Rakodáskor vedd le a gyűrűket és a karórát',
    ],
    onFailure: [
      'Tartós bőrpír, viszketés vagy repedések esetén jelentsd a '
          'tevékenységet',
      'A nem tolerált szert ne használd tovább — kérj alternatívát',
    ],
    onAccident: [
      'A vágott és horzsolt sebeket azonnal tisztítsd meg és kösd be',
      'Bejegyzés a sérülési naplóba, a kisebb sérüléseknél is',
      'Gyulladásra utaló jelek esetén orvosi ellátás',
    ],
    maintenance: [
      'Ellenőrizd a szappan-, fertőtlenítő- és ápolószer-adagolók '
          'töltöttségét',
      'Az üres vagy hibás adagolókat jelentsd',
    ],
  ),

  // ─────────────────────────────────────────── Munkahely
  OperatingInstruction(
    id: 'baw_bildschirm',
    title: 'Képernyős munkahely',
    subtitle: 'Diszpozíció és irodai munka',
    category: InstructionCategory.workplace,
    scope: 'Azokra a munkatársakra vonatkozik, akik túlnyomórészt '
        'képernyő előtt dolgoznak — különösen a diszpécserekre és az '
        'adminisztrációra.',
    hazards: [
      'Szempanaszok a káprázás és a hosszú fókuszálás miatt',
      'Izomfeszülés a nyakban, a vállban és a hátban',
      'Ínhüvelygyulladás kedvezőtlen kéz- és kartartás miatt',
      'Megbotlás a kábelekben',
    ],
    protection: [
      'A képernyő felső széle nagyjából szemmagasságban, nézési '
          'távolság 50–70 cm',
      'A képernyőt az ablakhoz képest oldalt állítsd — ne elé és ne '
          'szembe',
      'Az ülésmagasságot úgy válaszd meg, hogy az alkar és a felkar '
          'nagyjából derékszöget zárjon be',
      'A lábad laposan a padlón vagy lábtartón',
      'Rendszeresen válts testtartást, tarts rövid szüneteket a '
          'távolba nézve',
      'Vezesd és rögzítsd a kábeleket',
    ],
    onFailure: [
      'Jelentsd a villódzó vagy hibás képernyőket és lámpákat',
      'A hibás székeket ne használd tovább',
    ],
    onAccident: [
      'Tartós panasz esetén értesítsd a felettesedet',
      'Ellenőriztesd, hogy jogosult vagy-e munkaegészségügyi '
          'vizsgálatra és képernyős munkahelyi szemüvegre',
    ],
    maintenance: [
      'Tartsd tisztán a képernyőt és a beviteli eszközöket',
      'Rendszeresen ellenőrizd a munkahelyi világítást',
    ],
  ),
];
