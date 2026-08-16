// lib/data/safety_training/safety_content_hu.dart
//
// A biztonsagi oktatas tartalma — magyar valtozat.

import 'safety_blocks.dart';

const String _a = 'assets/academy/safety/';

const List<SafetyChapterContent> safetyContentHu = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ch01',
    title: 'Jogi alapok és a te kötelességeid',
    summary: 'Miért van munkavédelem — és neked mit kell tenned',
    asset: '${_a}ch01_grundlagen.svg',
    slides: [
      SafetySlide(
        title: 'Mire épül a munkavédelem',
        asset: '${_a}ch01_grundlagen.svg',
        blocks: [
          ParagraphBlock(
            'A munkavédelem nem a munkáltatód önkéntes ajánlata, hanem '
            'törvényi előírás. Két pilléren nyugszik: az állami jogon és '
            'a balesetbiztosítók saját szabályain.',
          ),
          BulletsBlock([
            'Arbeitsschutzgesetz (ArbSchG) — a munkáltató kötelességeit '
                'és a munkavállalók jogait és kötelességeit szabályozza',
            'Rendeletek — a törvényt konkretizálják, pl. a munkahelyekre, '
                'az üzembiztonságra és a veszélyes anyagokra vonatkozó '
                'rendelet',
            'DGUV Vorschriften — a szakmai szövetség kötelező érvényű '
                'szabályai, rád mint biztosítottra is kötelezőek',
            'DGUV Regeln és Informationen — végrehajtási segédletek és '
                'ajánlások, nem kötelezőek, de a gyakorlatban beváltak',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A különbség, ami számít',
            text: 'A DGUV Vorschriften kötelező. A DGUV Regeln azt mutatja '
                'meg, hogyan kell alkalmazni. A DGUV Informationen ajánlás.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A hat kötelességed munkavállalóként',
        blocks: [
          ParagraphBlock(
            'A munkáltatónak védenie kell téged — neked pedig együtt kell '
            'működnöd. Ezek a kötelességek minden munkavállalóra '
            'vonatkoznak, beosztástól és szerződéstől függetlenül.',
          ),
          StepsBlock([
            'Gondoskodj a saját és a kollégáid biztonságáról',
            'Kövesd a Betriebsanweisungen előírásait és az oktatásokat',
            'Nyújts elsősegélyt, illetve segítsd a hatékony '
                'elsősegélynyújtást',
            'Jelentsd a baleseteket és a majdnem-baleseteket — a kicsiket is',
            'A hibákat és hiányosságokat azonnal jelentsd (sérült kábel, '
                'rossz eszköz, hibás folyamatok)',
            'A védőfelszerelést rendeltetésszerűen használd — munkavédelmi '
                'cipő, kesztyű, láthatósági mellény, hallásvédő',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Alkohol, drog, gyógyszer',
            text: 'Bódító szerekkel nem veszélyeztetheted magad és másokat. '
                'Ez a teljes munkaidőre érvényes — a szünetre is, mert '
                'utána újra vezetsz. Ide tartoznak az álmosító gyógyszerek '
                'is: ha bizonytalan vagy, kérdezd meg az orvosodat.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ch02',
    title: 'Betriebsanweisungen',
    summary: 'Kötelező érvényű utasítások — és miért védenek téged',
    asset: '${_a}ch02_betriebsanweisungen.svg',
    slides: [
      SafetySlide(
        title: 'Mi az a Betriebsanweisung',
        asset: '${_a}ch02_betriebsanweisungen.svg',
        blocks: [
          ParagraphBlock(
            'A Betriebsanweisung a munkáltatód kötelező érvényű utasítása a '
            'járművek, munkaeszközök és veszélyes anyagok kezelésére. Ez '
            'nem ajánlás.',
          ),
          BulletsBlock([
            'A telephelyen ki van függesztve — ismerned kell',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Ezt tudnod kell',
            text: 'Aki megszegi a Betriebsanweisung előírásait, annak ezt a '
                'baleset kivizsgálásánál a terhére róhatják. A legrosszabb '
                'esetben ez társfelelősséget jelent egy balesetért — '
                'személyesen neked is.',
          ),
          ParagraphBlock(
            'Elhatárolás: a Betriebsanweisung egy munkaeszköz vagy '
            'veszélyes anyag kezelését szabályozza. A munkautasítás egy '
            'munkafolyamat menetét szabályozza.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Felépítés — hat szakasz',
        blocks: [
          ParagraphBlock(
            'Minden Betriebsanweisung ugyanúgy épül fel. Ha ismered a '
            'felépítést, éles helyzetben azonnal megtalálod a megfelelő '
            'részt.',
          ),
          StepsBlock([
            'Hatály — mire és kire vonatkozik',
            'Veszélyek az emberre és a környezetre',
            'Védőintézkedések és magatartási szabályok',
            'Teendők üzemzavar esetén',
            'Teendők baleset esetén és elsősegély',
            'Ártalmatlanítás és karbantartás',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Példa: vezetés a furgonnal',
        blocks: [
          ParagraphBlock(
            'Így néznek ki a konkrét szabályok egy 3,5 t-ig terjedő '
            'járművekre vonatkozó Betriebsanweisung-ban:',
          ),
          BulletsBlock([
            'Tartsd magadnál az érvényes vezetői engedélyt',
            'Semmi alkohol és drog az út előtt és közben',
            'Tolatás veszélyeztetés esetén csak irányító személlyel',
            'A járművet elhagyás után mindig zárd be',
            'Vontatás csak merev vonórúddal',
            'Biztosítsd a baleset helyszínét, minden balesetet '
                'haladéktalanul jelents',
            'A kisebb sérüléseket is azonnal lásd el és vezesd be a '
                'sérülési naplóba',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ha bizonytalan vagy, kérdezz',
            text: 'Ha egy utasítás nem világos, kérdezd meg a '
                'diszpécseredet — mielőtt elindulsz, nem utána.',
          ),
          SubheadBlock('A legfontosabb utasítások'),
          ParagraphBlock(
            'Az összes Betriebsanweisung bármikor elérhető a DA Academy '
            '„Betriebsanweisungen" menüpontjában.',
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
    title: 'A biztonságos munka 10 szabálya',
    summary: 'A munkanapod magja — minden nap érvényes',
    asset: '${_a}ch03_sicheres_arbeiten.svg',
    slides: [
      SafetySlide(
        title: 'Tíz szabály, minden nap',
        asset: '${_a}ch03_sicheres_arbeiten.svg',
        blocks: [
          StepsBlock([
            'Biztonságos és körültekintő munkavégzés',
            'Indulás előtti ellenőrzés minden út előtt',
            'A rakomány rögzítése a járműben',
            'Profi vezetés és a közlekedési szabályok betartása',
            'A biztonsági öv bekapcsolása',
            'A járművek, szerszámok és felszerelések rendben tartása',
            'Munkavégzés csak megfelelő cipőben',
            'Udvarias bánásmód a kollégákkal és az ügyfelekkel',
            'A szünetek betartása',
            'Toleráns és tiszteletteljes viselkedés',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'A három leghatásosabb',
            text: 'Indulás előtti ellenőrzés, rakományrögzítés, biztonsági '
                'öv. Ez a három előzi meg a legtöbb súlyos következményt — '
                'és együtt sem kerül három percbe.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ch04',
    title: 'Egyéni védőfelszerelés (EVE)',
    summary: 'Munkavédelmi cipő és láthatósági mellény — a napi kötelességed',
    asset: '${_a}ch04_psa.svg',
    slides: [
      SafetySlide(
        title: 'A védőfelszerelésed futárként',
        asset: '${_a}ch04_psa.svg',
        blocks: [
          ParagraphBlock(
            'Az egyéni védőfelszerelés mindaz, amit a testeden viselsz, '
            'hogy megvédjen a veszélyektől. A csomagkézbesítésben két '
            'darab kötelező minden nap:',
          ),
          FactsBlock([
            FactItem('1', 'Munkavédelmi cipő'),
            FactItem('2', 'Láthatósági mellény'),
          ]),
          BulletsBlock([
            'Munkavédelmi cipő — az egész munkanapon át, a telephelyen és '
                'az útvonalon is',
            'Láthatósági mellény — kéznél a járműben, és vedd fel, mielőtt '
                'defekt, baleset vagy útszéli megállás esetén kiszállsz',
          ]),
          SubheadBlock('További védőfelszerelés — a tevékenységtől függően'),
          ParagraphBlock(
            'Ez a felszerelés nem naponta kötelező, de bizonyos munkákhoz '
            'szükséges lehet. Hogy rád mi vonatkozik, az a '
            'kockázatértékelésben és a Betriebsanweisung-ban áll.',
          ),
          BulletsBlock([
            'Védőkesztyű — éles szélű küldeményeknél, takarítási és '
                'karbantartási munkáknál, télen',
            'Hallásvédő — zaj esetén, pl. bizonyos csarnokrészekben',
            'Védőszemüveg — fröccsenésveszélyes munkáknál',
            'Fejvédő — építkezéseken és leeső tárgyak veszélye esetén',
            'Időjárás elleni védőruha — tartós szabadtéri munkánál',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Használati kötelezettség',
            text: 'A munkáltató által biztosított védőfelszerelést '
                'rendeltetésszerűen kell használnod '
                '(§ 15 Arbeitsschutzgesetz). A munkáltató ingyenesen '
                'biztosítja, és ellenőriznie kell a betartását.',
          ),
          InstructionRefBlock(['baw_sicherheitsschuhe', 'baw_warnweste']),
        ],
      ),
      SafetySlide(
        title: 'Munkavédelmi cipő: mitől véd',
        blocks: [
          ParagraphBlock(
            'A lábvédelem az a védőfelszerelés, amelyre a leggyakrabban '
            'szükséged van — és amelyet a leggyakrabban alábecsülnek.',
          ),
          SubheadBlock('Mitől véd'),
          BulletsBlock([
            'Mechanikai — beütés, zúzódás, leeső csomagok, hegyes tárgyba '
                'lépés',
            'Kibicsaklás — a bokát fedő cipő megtámasztja a bokaízületet és '
                'megelőzi a szalagszakadást és a bokasérüléseket',
            'Elektromos — antisztatikus levezetés',
            'Vegyi — savak, olajok, üzemanyagok',
            'Hő — meleg és hideg',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Miért bokáig érő',
            text: 'A kézbesítésben a leggyakoribb sérülés a kibicsaklás '
                'kiszálláskor, járdaszegélyen és egyenetlen utakon. A '
                'bokát fedő cipő pontosan ott támasztja meg az ízületet, '
                'ahol az kifordul — egy félcipő ezt nem tudja.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Akkor is, ha kényelmetlen — és nyáron is',
            text: 'A viselési kötelezettség minden munkanapon érvényes, '
                'időjárástól és kényelemtől függetlenül. Éppen nyáron '
                'cserélik le — és pont ilyenkor történnek a sérülések. Ha '
                'a cipő szorít vagy dörzsöl, az egy másik modell melletti '
                'érv, nem a sportcipő melletti.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Ellenőrizd rendszeresen a cipődet',
            text: 'Lekopott mintázat, repedések vagy erős szennyeződés: '
                'cseréltesd ki. Ne alakítsd át magadtól, és soha ne dolgozz '
                'sportcipőben — még „csak egy percre" sem.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A védelmi osztályok áttekintése',
        blocks: [
          TableBlock(
            headers: ['Osztály', 'Tulajdonságok'],
            rows: [
              [
                'S1',
                'Zárt sarokrész, antisztatikus, üzemanyagálló talp',
              ],
              ['S2', 'mint S1 + legalább 60 percig vízhatlan'],
              ['S3', 'mint S2 + átszúrásbiztos és mintázott talp'],
              ['S4', 'mint S2, teljesen gumiból (vulkanizált)'],
              ['S5', 'mint S4 + átszúrásbiztos talp'],
            ],
          ),
          SubheadBlock('Mikor különösen fontosak'),
          BulletsBlock([
            'Létrán, fellépőn és lépcsőn',
            'Görgős konténereknél és kézi raklapemelőnél',
            'Egyenetlen utakon és rámpákon',
          ]),
          ParagraphBlock(
            'Egy jó cipő ismérvei: stabil illeszkedés, zárt kialakítás, '
            'párnázott saroktartás, hajlékony talp, alacsony sarok, '
            'csúszásgátló mintázat.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ch05',
    title: 'Teendők tűz esetén',
    summary: 'A tűzoltó készülék helyes használata és a járműtüzek kezelése',
    asset: '${_a}ch05_brandfall.svg',
    slides: [
      SafetySlide(
        title: 'A tűzoltó készülék kezelése',
        asset: '${_a}ch05_brandfall.svg',
        blocks: [
          ParagraphBlock(
            'Van poroltó, víz- és haboltó, valamint CO₂-oltó. A kezelésük '
            'mindegyiknél ugyanaz:',
          ),
          StepsBlock([
            'Húzd ki a biztosítót',
            'Nyomd meg az ütőgombot',
            'Nyomd meg az oltópisztolyt',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Csak másodperceid vannak',
            text: 'Egy oltó gyorsabban kiürül, mint a legtöbben gondolnák. '
                'Ezért: inkább több oltót egyszerre vess be, mint egymás '
                'után.',
          ),
          FactsBlock([
            FactItem('6–12 s', 'Por 1–2 kg'),
            FactItem('15–23 s', 'Por 6 kg'),
            FactItem('18–33 s', 'Por 12 kg'),
            FactItem('20–30 s', 'Hab 6 l'),
            FactItem('5–10 s', 'CO₂ 2 kg'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Helyes oltás — lépésről lépésre',
        blocks: [
          ParagraphBlock(
            'A sorrenden múlik, hogy a tűz kialszik-e vagy újra fellángol. '
            'Hat lépés, amit érdemes megjegyezned:',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}fire01_pin.svg',
              title: 'Készítsd elő az oltót',
              caption: 'Húzd ki a biztosítót, nyomd meg az ütőgombot, '
                  'tartsd az oltót függőlegesen. Csak ezután menj a tűzhöz.',
            ),
            IllustratedStep(
              asset: '${_a}fire02_wind.svg',
              title: 'Támadj a szél irányából',
              caption: 'A szélnek a hátad mögül kell fújnia, és az '
                  'oltóanyagot a tűzbe vinnie — soha ne olts széllel '
                  'szemben. Így a hő és a füst távol marad tőled.',
            ),
            IllustratedStep(
              asset: '${_a}fire03_surface.svg',
              title: 'Felületi tűz: elölről kezdd',
              caption: 'Célozz a lángok elülső szélére, a parázsba — ne a '
                  'lángnyelvekre. Aztán darabról darabra haladj hátrafelé.',
            ),
            IllustratedStep(
              asset: '${_a}fire04_drip.svg',
              title: 'Csepegő tűz: felülről lefelé',
              caption: 'Ha égő folyadék folyik lefelé, fent, a kifolyásnál '
                  'kezdd, és haladj lefelé — különben fentről mindig újra '
                  'begyullad.',
            ),
            IllustratedStep(
              asset: '${_a}fire05_together.svg',
              title: 'Több oltó egyszerre',
              caption: 'Ha több oltó és segítő is van: közösen és egy '
                  'időben vessétek be. Egymás után a tűznek ideje marad '
                  'összeszedni magát az oltások között.',
            ),
            IllustratedStep(
              asset: '${_a}fire06_watch.svg',
              title: 'Figyeld a tűz helyét',
              caption: 'Oltás után maradj a helyszínen és figyelj. A '
                  'parázsfészkek gyakran percek múlva újra begyulladnak — '
                  'tarts távolságot és legyen bevetésre kész oltó nálad.',
            ),
            IllustratedStep(
              asset: '${_a}fire07_refill.svg',
              title: 'Töltesd újra a használt oltót',
              caption: 'A használt oltó soha nem kerül vissza a falra — még '
                  'egy rövid lövés után sem. Add le azonnal újratöltésre és '
                  'jelentsd a pótlás igényét.',
            ),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Mikor ne olts',
            text: 'Soha ne sodord magad veszélybe. Ha a tűz nagyobb egy '
                'papírkosárnál, erős a füstképződés, vagy kockáztatod a '
                'menekülőutat: kifelé, ajtót be, hívd a 112-t és '
                'figyelmeztess másokat.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Járműtűz',
        blocks: [
          SubheadBlock('A leggyakoribb okok'),
          BulletsBlock([
            'Üzemanyag- vagy olajszivárgás',
            'Szigetelőanyag forró alkatrészeken',
            'Mechanikai sérülések',
            'Elektromos hibák',
            'Égő hulladékgyűjtők',
          ]),
          SubheadBlock('Mit tegyél'),
          StepsBlock([
            'Ne állj meg alagútban vagy hídon — ha lehet, hajts ki',
            'Kapcsold be a vészvillogót, keress alkalmas helyet, állj meg',
            'Hagyd el a járművet, tarts távolságot',
            'Riaszd a tűzoltókat a 112-n — mondd be a helyet a haladási '
                'iránnyal',
            'Saját oltási kísérlet csak akkor, ha biztonságos',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Motorháztető: vigyázz',
            text: 'Csak kesztyűben és csak résnyire nyisd ki. A hirtelen '
                'oxigénbeáramlástól lángcsóva csaphat ki.',
          ),
          SubheadBlock('Mit kell tudnia az ügyeletnek'),
          BulletsBlock([
            'Hol ég?',
            'Mi ég és milyen mértékben?',
            'Hány sérült van, milyen sérülésekkel?',
            'Mi van berakodva?',
            'Ki jelenti?',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ne tedd le',
            text: 'Soha ne fejezd be te a hívást. Várd meg a '
                'visszakérdezéseket — az ügyelet zárja le a beszélgetést.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'ch06',
    title: 'Elsősegély',
    summary: 'A kötelességed, a védettséged és a dokumentáció',
    asset: '${_a}ch06_erste_hilfe.svg',
    slides: [
      SafetySlide(
        title: 'Segíteni kötelesség — és védve vagy',
        asset: '${_a}ch06_erste_hilfe.svg',
        blocks: [
          ParagraphBlock(
            'Mindenki köteles elsősegélyt nyújtani — az elvárható '
            'mértékben, anélkül, hogy magát jelentősen veszélyeztetné. '
            'Laikusként is.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 323c StGB — segítségnyújtás elmulasztása',
            text: 'Aki nem segít, pedig elvárható lenne, büntetendő: '
                'legfeljebb egy év szabadságvesztés vagy pénzbüntetés. Ez '
                'a bámészkodókra is vonatkozik, akik akadályozzák a '
                'segítőket.',
          ),
          SubheadBlock('Aki segít, nem csinál rosszul semmit'),
          BulletsBlock([
            'Elsősegélynyújtóként nem felelsz a hibákért — kivéve '
                'szándékosság vagy súlyos gondatlanság esetén',
            'A segítségnyújtás ideje alatt törvényi baleset-biztosítás '
                'véd téged',
            'A költségeket nem te viseled; a dologi károkat általában '
                'megtérítik',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Az egyetlen igazi hiba',
            text: 'Ha nem teszel semmit. Minden más jobb, mint elfordulni.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Elsősegélynyújtók a telephelyen — és te',
        blocks: [
          ParagraphBlock(
            'A telephelyen vannak kiképzett üzemi elsősegélynyújtók. Erről '
            'a vállalkozó gondoskodik: az elsősegélynyújtás megszervezése '
            'az ő feladata (§ 24 DGUV Vorschrift 1), és biztosítania kell '
            'a kiképzett elsősegélynyújtók minimális számát '
            '(§ 26 DGUV Vorschrift 1).',
          ),
          FactsBlock([
            FactItem('1', 'elsősegélynyújtó 2–20 jelenlévőnél'),
            FactItem('10 %', 'a jelenlévőkből egyéb üzemekben'),
            FactItem('2 év', 'az elsősegélynyújtók továbbképzése'),
          ]),
          ParagraphBlock(
            'Ha több munkáltató dolgozik ugyanazon a területen, '
            'egyeztetniük kell és tájékoztatniuk kell egymást '
            '(§ 8 Arbeitsschutzgesetz). Ennek során megállapodhatnak '
            'abban, hogy a telephely elsősegély-szervezetét közösen '
            'használják. Ez az üzemek együttműködését szabályozza — nem a '
            'te személyes kötelességedet.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Ez téged nem mentesít',
            text: 'A § 323c StGB szerinti segítségnyújtási kötelezettség '
                'mindenkit személyesen terhel. A telephelyen lévő '
                'kiképzett elsősegélynyújtók ezen nem változtatnak.',
          ),
          SubheadBlock('Jogilag így kell kezelni'),
          BulletsBlock([
            'Ha már van ott valaki, és ténylegesen elegendő segítséget '
                'nyújt, neked nem kell magadnak hozzálátnod',
            'A mentők riasztásának és a segítség hívásának kötelezettsége '
                'minden esetben fennmarad',
            'Meg kell győződnöd róla, hogy tényleg segítenek — az '
                'elfordulás azzal a gondolattal, hogy „majd foglalkozik '
                'vele valaki", nem elég',
            'Az elsősegélynyújtó utasítására segíts: biztosíts, irányítsd '
                'oda a mentőket, hozz anyagot, tartsd távol a többieket',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'A túrán egyedül vagy',
            text: 'A munkaidőd nagy részében nem a telephelyen vagy, hanem '
                'úton. Ott nincs telephelyi elsősegélynyújtó — ha az '
                'útvonalon vészhelyzet történik, te vagy az '
                'elsősegélynyújtó.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Segélyhívás leadása',
        blocks: [
          FactsBlock([
            FactItem('112', 'segélyhívó, Európa-szerte'),
          ]),
          SubheadBlock('Az öt kérdés'),
          StepsBlock([
            'Hol történt?',
            'Hány személy sérült meg?',
            'Mi történt?',
            'Ki hív?',
            'Várj a visszakérdezésekre',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Alapszabályok a segítségnyújtásnál',
            text: 'Őrizd meg a nyugalmad · cselekedj gyorsan · ügyelj a '
                'saját biztonságodra · biztosítsd a baleset helyszínét · '
                'segíts legjobb tudásod szerint.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dokumentáció és bejelentés',
        blocks: [
          ParagraphBlock(
            'Minden sérülést dokumentálni kell — a kis vágást is. Ez véd '
            'téged, ha később következményei lennének.',
          ),
          SubheadBlock('A sérülési naplóba tartozik'),
          BulletsBlock([
            'Idő és hely',
            'A történtek menete',
            'A sérülés jellege és mértéke',
            'A sérült személy neve',
            'Tanúk és elsősegélynyújtók',
          ]),
          FactsBlock([
            FactItem('> 3 nap', 'keresőképtelenség → bejelentés kell'),
            FactItem('3 nap', 'a bejelentés határideje'),
            FactItem('5 év', 'megőrzés, bizalmasan'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Azonnal jelentsd',
            text: 'A halálos baleseteket, tömegbaleseteket és súlyos '
                'egészségkárosodásokat a vállalkozó haladéktalanul '
                'jelenti — ezért a munkáltatódat mindig azonnal értesítsd.',
          ),
          ParagraphBlock(
            'Az elsősegélydobozoknak hiánytalannak kell lenniük. '
            'Ellenőrizd a lejárati dátumot és jelentsd a hiányzó anyagot.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 7
  SafetyChapterContent(
    id: 'ch07',
    title: 'Ülés és mozgás',
    summary: 'Kíméld a hátad, tartsd a koncentrációd',
    asset: '${_a}ch07_sitzen_bewegen.svg',
    slides: [
      SafetySlide(
        title: 'Miért lesz kockázat az ülésből',
        asset: '${_a}ch07_sitzen_bewegen.svg',
        blocks: [
          ParagraphBlock(
            'A hosszú, rosszul beállított ülés több mint kényelmetlen — '
            'figyelmet és reakcióidőt vesz el tőled.',
          ),
          BulletsBlock([
            'Fáradtság és csökkenő koncentráció',
            'Izomfeszülés és hátfájás',
            'Panaszok a nyaki és az ágyéki gerincszakaszon',
            'Balesetek a késleltetett reakció miatt',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Állítsd be helyesen az ülést',
        blocks: [
          ParagraphBlock(
            'Szánj rá két percet az első út előtt. Hét beállításon múlik:',
          ),
          StepsBlock([
            'Ülésmagasság és hosszirányú állítás',
            'Az ülőfelület mélysége',
            'Az ülőfelület dőlése',
            'A háttámla dőlése',
            'Ágyéktámasz',
            'Fejtámla',
            'Kormány és az öv vezetése',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Dinamikus ülés',
            text: 'A hátad teljesen a támlához, ülj egyenesen — és '
                'változtass újra meg újra kicsit a testtartásodon. A '
                'legjobb ülőhelyzet mindig a következő.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Gyakorlatok két munka között',
        blocks: [
          SubheadBlock('Ülve'),
          BulletsBlock([
            'Húzd erősen szét a kormányt — tartsd 3–6 másodpercig, '
                '3 ismétlés',
            'Nyomd a térded a kezed ellenállásával szemben — '
                '3–6 másodperc, 5 ismétlés',
            'Támaszkodj meg az ülőfelületen és emeld meg a súlyodat — '
                '3 ismétlés',
          ]),
          SubheadBlock('Állva'),
          BulletsBlock([
            'Nyújtsd a karodat felfelé — kb. 8 másodperc, 3–5 ismétlés',
            'Kezek a tarkóra, könyök hátra — kb. 8 másodperc, '
                '3–5 ismétlés',
            'Sarok egy kb. 30 cm magas emelvényre, nyújtsd a lábad — kb. '
                '8 másodperc, lábanként 2–3 alkalommal',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Az edzett hát többet bír',
            text: 'Használd a szünetidőt — ne külön időt.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 8
  SafetyChapterContent(
    id: 'ch08',
    title: 'Terhelés és koncentráció',
    summary: 'Teljesítőképesen és figyelmesen végig a napon',
    asset: '${_a}ch08_psychische_belastung.svg',
    slides: [
      SafetySlide(
        title: 'Miért tartozik ez a munkavédelemhez',
        asset: '${_a}ch08_psychische_belastung.svg',
        blocks: [
          ParagraphBlock(
            'Aki nyomás alatt van, lassabban reagál, többet néz el és '
            'hibázik. Pont ezért biztonsági kérdés a terhelés — nem csak '
            'akkor, ha valaki már megbetegszik.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Törvényi előírás',
            text: '2013 óta a kockázatértékelésnek kifejezetten figyelembe '
                'kell vennie a munkahelyi pszichés terheléseket is '
                '(§ 5 Abs. 3 Nr. 6 Arbeitsschutzgesetz). A '
                'munkakörülményeket értékelik — nem az egyes személyeket.',
          ),
          SubheadBlock('Mi okoz nyomást a mindennapi vezetésben'),
          BulletsBlock([
            'Szűk időablakok, dugó, útépítés, parkolóhely-keresés',
            'Tisztázatlan felelősségek a be- és kirakodásnál',
            'Hiányzó vagy késői információk a túráról',
            'Műszaki problémák a járművön vagy az eszközön',
            'Nehéz ügyfélhelyzetek',
          ]),
          ParagraphBlock(
            'Ezek olyan körülmények, amelyeken az üzem tud változtatni. '
            'Ezért a legfontosabb szabály: jelezd, amíg még megoldható.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Maradj koncentrált — így megy a gyakorlatban',
        blocks: [
          SubheadBlock('A túra alatt'),
          BulletsBlock([
            'Használd eszközként a szüneteket: szállj ki egy kicsit, nézz '
                'a távolba, sétálj néhány lépést — ez mérhetően '
                'helyreállítja a figyelmet',
            'Igyál eleget és egyél rendszeresen',
            'Ne manőverezz időnyomás alatt — az a két perc olcsóbb, mint '
                'egy karcolás a lemezen',
            'A telefont csak álló helyzetben kezeld, a címet indulás előtt '
                'vidd be',
            'Nehéz ügyfélkontaktus után vegyél egy mély levegőt, mielőtt '
                'továbbindulsz',
          ]),
          SubheadBlock('Szólj időben, ne tűrd némán'),
          ParagraphBlock(
            'Ha valami tartósan nem stimmel, mondd el a diszpécserednek — '
            'korán és konkrétan. Egy túra, amit rendszeresen nem lehet '
            'teljesíteni, egy jármű, ami folyton problémázik, egy útvonal '
            'állandó parkolóhiánnyal: ezt meg lehet tervezni, ha valaki '
            'tud róla.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'A konkrét jelzés többet segít, mint a tűrés',
            text: 'Mondd el, pontosan mi akad és hol — ne csak azt, hogy '
                'stresszes volt. Minél konkrétabb a visszajelzés, annál '
                'nagyobb az esély, hogy változik valami a tervezésben.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Különleges események után',
        blocks: [
          ParagraphBlock(
            'Vannak helyzetek, amelyek utóhatással járnak: egy súlyos '
            'baleset, egy rablás, egy elsősegélynyújtás súlyosan sérült '
            'embereknél. Ez normális reakció egy nem normális eseményre — '
            'és nem a gyengeség jele.',
          ),
          BulletsBlock([
            'Jelentsd az eseményt a felettesednek, akkor is, ha neked '
                'magadnak nem történt bajod',
            'Munkabalesetek után a szakmai szövetségen keresztül elérhetők '
                'támogatási lehetőségek',
            'Sok üzemben van pszichológiai elsősegélynyújtó vagy '
                'trauma-kísérő — kérdezz rá az irodában',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Akut vészhelyzetben',
            text: 'Akut lelki krízis esetén Németországban: '
                'Telefonseelsorge 0800 111 0 111 — ingyenes, névtelen, a '
                'nap 24 órájában elérhető.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 9
  SafetyChapterContent(
    id: 'ch09',
    title: 'Biztonságos vezetés és indulás előtti ellenőrzés',
    summary: 'Két perc ellenőrzés minden túra előtt',
    asset: '${_a}ch09_sicheres_fahren.svg',
    slides: [
      SafetySlide(
        title: 'Körbejárás a jármű körül',
        asset: '${_a}ch09_sicheres_fahren.svg',
        blocks: [
          ParagraphBlock(
            'Minden indulás előtt kötelező az indulás előtti ellenőrzés. '
            'Két percig tart, és pont azokat a hibákat találja meg, '
            'amelyek útközben drágák vagy veszélyesek lesznek.',
          ),
          BulletsBlock([
            'Világítás elöl és hátul',
            'Kilátás — tükrök és üvegek tiszták és sértetlenek',
            'Kerekek — légnyomás, mintázat, rögzítés',
            'Fékek — fékpróba, féknyomás',
            'Motor és hajtás — olaj, hűtő- és fékfolyadék, ablakmosó víz, '
                'nincs szivárgás',
            'Ponyvák és ajtók zárva',
            'Rendszám és figyelmeztető táblák tiszták',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Rakomány és a vezetői munkahely',
        blocks: [
          SubheadBlock('Rakományrögzítés'),
          BulletsBlock([
            'Alkalmas a jármű ehhez a rakományhoz?',
            'Sértetlenek a rögzítőeszközök?',
            'Rögzítve van a rakomány és védve az elcsúszás ellen?',
            'Betartva a tengelyterhelés és a megengedett össztömeg?',
          ]),
          SubheadBlock('A te munkahelyed'),
          BulletsBlock([
            'Az ülés és a kormány helyesen beállítva',
            'A műszerek hibajelzés nélkül',
            'A fékpróba rendben',
            'A vezetéstámogató rendszerek bekapcsolva és üzemkészen',
            'A szellőzés működik',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Télen ezen felül',
            text: 'Megfelelő gumiabroncsok, adott esetben hólánc vagy '
                'indítássegítő, elegendő fagyálló a hűtőfolyadékban és az '
                'ablakmosóban, jégkaparó a fedélzeten.',
          ),
          InstructionRefBlock(['baw_transporter', 'baw_winter']),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 10
  SafetyChapterContent(
    id: 'ch10',
    title: 'Műszaki hiba és baleset',
    summary: 'Biztosítás, segítségnyújtás, helyes dokumentálás',
    asset: '${_a}ch10_pannen_unfaelle.svg',
    slides: [
      SafetySlide(
        title: 'Alapszabály és műszaki hiba',
        asset: '${_a}ch10_pannen_unfaelle.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Az alapszabály',
            text: 'Az önvédelem megelőzi mások védelmét. A személyvédelem '
                'megelőzi a vagyonvédelmet.',
          ),
          SubheadBlock('Ha egy meghibásodás előjelei mutatkoznak'),
          StepsBlock([
            'Keress időben megfelelő megállóhelyet — pl. emelkedő '
                'hűtővíz-hőmérsékletnél',
            'Kapcsold be a vészvillogót már kigurulás közben',
            'Ha lehet, a legközelebbi parkolóba, különben a legszélső '
                'jobb útszélre',
            'Húzd be a rögzítőféket, sötétben kapcsold be a helyzetjelzőt',
            'Vedd fel a láthatósági mellényt — még kiszállás előtt',
            'Helyezd ki az elakadásjelző háromszöget',
          ]),
          FactsBlock([
            FactItem('100 m', 'elakadásjelző háromszög, országúton'),
            FactItem('150–400 m', 'elakadásjelző háromszög, autópályán'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Vészhelyzeti terv baleset esetén',
        blocks: [
          StepsBlock([
            'Állj meg — mindig, akkor is, ha senki nincs ott',
            'Biztosítsd a baleset helyszínét — vészvillogó, rögzítőfék, '
                'sötétben helyzetjelző, láthatósági mellény kiszállás '
                'előtt, elakadásjelző háromszög',
            'Nyújts elsősegélyt — haladéktalanul',
            'Hívd a 112-t — sürgős esetben akár az elsősegély előtt is',
            'Cseréljetek adatokat — név, cím, rendszám, biztosító',
            'Hívj rendőrt — személyi sérülésnél, nagy anyagi kárnál vagy '
                'alkohol- és droggyanú esetén',
            'Rögzítsd a bizonyítékokat — fotók a helyszínről és a '
                'károkról, a tanúk elérhetőségei',
            'Értesítsd a munkáltatót és egyeztesd a teendőket, ellenőrizd '
                'a vezetőképességedet, csomagold vissza a háromszöget',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Parkolási kár és a leggyakoribb sérülés',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Egy cetli nem elég',
            text: 'Ha nekiütközöl egy parkoló autónak és nincs ott senki: '
                'várj legalább 30 percet. Utána hagyd ott a nevedet és a '
                'címedet, ÉS haladéktalanul jelentsd a balesetet a '
                'legközelebbi rendőrőrsön. Különben cserbenhagyás.',
          ),
          SubheadBlock('Hol sérülnek meg valójában a sofőrök'),
          FactsBlock([
            FactItem('51,6 %', 'esések és lezuhanások'),
            FactItem('7,2 %', 'közlekedési balesetek'),
          ]),
          ParagraphBlock(
            'A bejelentésköteles balesetek többsége nem a közúti '
            'forgalomban történik, hanem a vezetőfülkébe vagy a '
            'rakfelületre való fel- és leszállásnál.',
          ),
          DoDontBlock(
            doTitle: 'Helyes',
            dos: [
              'Használd az arra kialakított fellépőket és kapaszkodókat',
              'Három pont érintkezés be- és kiszálláskor',
              'Tartsd tisztán és szabadon a fellépőket',
              'Viselj megfelelő lábbelit',
            ],
            dontTitle: 'Veszélyes',
            donts: [
              'Leugrani a vezetőfülkéből vagy a rakfelületről',
              'Szennyezett, jeges vagy eltorlaszolt fellépőn járni',
              'Nem erre a célra szolgáló járműrészekre vagy a rakományra '
                  'mászni',
              'Sérült létrát használni',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 11
  SafetyChapterContent(
    id: 'ch11',
    title: 'A 3 pont szabálya',
    summary: 'Be- és kiszállás — a legfontosabb egyetlen szabály',
    asset: '${_a}step3p_cover.svg',
    slides: [
      SafetySlide(
        title: 'Mindig 3 a 4 érintkezési pontból',
        asset: '${_a}step3p_cover.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Az alapszabály',
            text: '2 kéz + 1 láb  VAGY  2 láb + 1 kéz. Három pont mindig '
                'szilárdan érintkezik a járművel.',
          ),
          ParagraphBlock(
            'Naponta több tucatszor szállsz be és ki — sietve, esőben, '
            'tele kézzel. Pont ekkor történik a legtöbb baleset. Három '
            'szilárd pont megtart téged, és megelőzi az eséseket és a '
            'boka-, térd- és hátsérüléseket.',
          ),
          FactsBlock([
            FactItem('51,6 %', 'az összes baleset esés'),
            FactItem('7,2 %', 'közlekedési baleset'),
          ]),
          ParagraphBlock(
            'Egyetlen más mozdulat sem előz meg annyi sérülést a '
            'mindennapi munkában, mint ez. Ezért áll ennek az oktatásnak a '
            'végén — mint az, aminek meg kell maradnia benned.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A négy szabály egyenként',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}step3p_01_face.svg',
              title: 'Arccal a jármű felé',
              caption: 'Mindig a jármű felé fordulva szállj ki — soha ne '
                  'hátrafelé vagy oldalra ugorj ki. Az ugrás a '
                  'leggyakoribb baleseti ok. Mindig használd a fellépőt és '
                  'a kapaszkodókat.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_02_hands.svg',
              title: 'Előbb tedd le, aztán fogj meg',
              caption: 'Semmi csomag a kezedben be- és kiszálláskor. Előbb '
                  'tedd le a küldeményt, vagy pakold el az apró darabokat '
                  'a táskába vagy az övre — a kezed maradjon szabadon a '
                  'kapaszkodáshoz.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_03_onepoint.svg',
              title: 'Egyszerre csak egy pontot mozgass',
              caption: 'Mindig csak egy kezet vagy egy lábat mozgass, '
                  'amíg a másik három szilárdan tart. Ne kapkodj — akkor '
                  'sem, ha sürget a túra.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_04_steps.svg',
              title: 'Figyelj a lépcsőkre és a tapadásra',
              caption: 'Tartsd szemmel a nedvességet, a havat, az olajat '
                  'és a szennyeződést. Nyugodtan és kontrolláltan lépj, a '
                  'lépcsőt szükség esetén előbb tisztítsd meg.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Két dolog, ami ehhez tartozik',
        blocks: [
          SubheadBlock('Bokát fedő munkavédelmi cipő'),
          ParagraphBlock(
            'A bokát fedő cipő körbezárja a bokát és sokkal jobban '
            'stabilizálja a bokaízületet — pontosan ott történik a '
            'kibicsaklás leszálláskor.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Bicsaklott már ki a bokád?',
            text: 'Akinek már volt bokaproblémája, kérjen bokát fedő '
                'cipőt — a következő túra előtt, nem utána.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}step3p_05_phone.svg',
              title: 'Semmi privát telefon a kézben',
              caption: 'A telefonálás, a gépelés és a görgetés elvonja a '
                  'figyelmet — pont ebből lesznek az esések és a '
                  'balesetek. A privát hívások és üzenetek megvárják a '
                  'szünetet. Be- és kiszálláskor a telefont el kell tenni.',
            ),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Röviden megjegyezve',
            text: 'Arccal a jármű felé · tarts három pontot · szabad '
                'kezek · bokát fedő munkavédelmi cipő · semmi privát '
                'telefon · lépcsőt használj ugrás helyett.',
          ),
        ],
      ),
    ],
  ),
];
