// lib/data/safety_training/privacy_quiz_hu.dart
//
// Az adatvédelmi oktatás zárótesztjének kérdései — magyar változat.
// Tizennyolc kérdés, egyenletesen elosztva a privacy_content_hu.dart hat
// fejezetére (fejezetenként három kérdés, ds1 … ds6). A felépítés, a
// sorrend és a helyes válaszok indexei azonosak a német alapváltozattal
// (privacy_quiz_de.dart) — a kettőnek szinkronban kell maradnia.
//
// A kérdések igénye: jelenetek a kézbesítés mindennapjaiból és
// jogkövetkezmény-kérdések. Több opció szándékosan hangzik hihetően — a
// döntés mindig egy részleten múlik. Az `explanation` mindig mindkettőt
// elmagyarázza: miért helyes a helyes válasz, és miért téves a
// kézenfekvő tévedés.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> privacyQuestionsHu = [
  // ══════════════════════════ ds1 — Miért érint téged az adatvédelem
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Az alábbi adatok közül melyik NEM személyes adat a DSGVO '
        '(GDPR) értelmében?',
    options: [
      'A ma a túrán kézbesített csomagok összdarabszáma',
      'A „csomagot kérem a kuka mögé" megjegyzés a hozzá tartozó '
          'címmel',
      'A kézbesítési fotó egy címzett bejárati ajtaja előtt',
    ],
    correctIndex: 0,
    explanation: 'Egy puszta darabszám személyhez kötődés nélkül nem '
        'személyes adat. A lerakási megjegyzés viszont egy konkrét ember '
        'lakhatási helyzetéről mond el valamit, a kézbesítési fotó pedig '
        'egy címhez van hozzárendelve. A kézenfekvő tévedés az, hogy '
        'csak a neveket tartjuk személyes adatnak — személyes adat '
        'minden információ, amely alapján egy személy azonosítható.',
  ),
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Este a baráti körben elmeséled, melyik utcában lakik egy '
        'ismert sportoló, akinek a csomagját kézbesítetted. Hogyan kell '
        'ezt megítélni?',
    options: [
      'Nem probléma, amíg a nevet nem teszed fel az internetre',
      'A célhoz kötöttség és a bizalmasság megsértése az Art. 5 DSGVO '
          'szerint',
      'Nem probléma, mert egy cím amúgy is nyilvánosan ismert',
    ],
    correctIndex: 1,
    explanation: 'A címet kizárólag a munkádból ismered. Harmadik félnek '
        'továbbadni céltól eltérő felfedés, és sérti az Art. 5 Abs. 1 '
        'lit. b és lit. f DSGVO-t. A kézenfekvő tévedés az, hogy egy kis '
        'privát kör nem számít — a DSGVO nem a közönség méretét kérdezi.',
  ),
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Mely előírásokból következik, hogy a cégnek adatvédelmi '
        'oktatásban kell részesítenie téged?',
    options: [
      'A német munkavédelmi törvény § 12 Abs. 1-éből — az adatvédelem '
          'az éves biztonsági oktatás része',
      'Az Art. 30 DSGVO-ban rögzített kifejezett oktatási '
          'kötelezettségből',
      'Közvetve az Art. 32, az Art. 39 Abs. 1 lit. b és az Art. 5 '
          'Abs. 2 DSGVO-ból',
    ],
    correctIndex: 2,
    explanation: 'A DSGVO nem ismer kifejezett oktatási kötelezettséget. '
        'Az közvetve adódik: az Art. 32 szervezési intézkedéseket '
        'követel, az Art. 39 Abs. 1 lit. b a tudatosítást és az oktatást '
        'az adatvédelmi tisztviselő feladataként nevezi meg, az Art. 5 '
        'Abs. 2 pedig a betartás igazolását követeli meg. Az Art. 30 '
        'ezzel szemben az adatkezelési tevékenységek nyilvántartását '
        'érinti, a munkavédelmi törvény (ArbSchG) pedig a munkavédelmet '
        'szabályozza, nem az adatvédelmet.',
  ),

  // ══════════════════════════ ds2 — Fotók és kézbesítési igazolások
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'Mi látszódhat egy kézbesítési fotón?',
    options: [
      'A címzett, ha szóban hozzájárult a felvételhez',
      'A csomag a lerakóhelyen, mellette ajtó vagy házszám '
          'helymegjelölésként',
      'A csomag és az előtte parkoló jármű rendszáma a jobb azonosítás '
          'érdekében',
    ],
    correctIndex: 1,
    explanation: 'A fotó pontosan egy kérdésre válaszol: hol van a '
        'csomag? Minden ezen túlmenő sérti az Art. 5 Abs. 1 lit. c DSGVO '
        'szerinti adattakarékosságot. Személyek szóbeli beleegyezéssel '
        'sem valók az igazolásra, a rendszám pedig személyes adat, amely '
        'a célhoz nem szükséges.',
  ),
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'A szkenner sztrájkol. A lerakást a normál telefonkameráddal '
        'fotózod le, majd a képet utána feltöltöd a munkahelyi appba. Mi '
        'ezzel a baj?',
    options: [
      'Semmi — csak az számít, hogy a kép a végén az appban legyen',
      'Csak a képminőség, jogilag aggálytalan',
      'A kép utána tartósan a privát galériában marad, gyakran ráadásul '
          'egy privát felhőben is',
    ],
    correctIndex: 2,
    explanation: 'A feltöltés nem szünteti meg a másolatot: az eredeti a '
        'privát galériában marad, és gyakran automatikusan felhőbe is '
        'mentődik. Így személyes adatok kerülnek a cég ellenőrzésén '
        'kívülre. A kézenfekvő tévedés az, hogy csak a végállapot számít '
        '— valójában minden útközben keletkező másolat számít.',
  ),
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'A megálló lezárása után veszed észre, hogy a feltöltött '
        'fotón felismerhető egy szomszéd. Mit teszel?',
    options: [
      'Szólok a diszpécsernek vagy az üzemvezetésnek, hogy a képet a '
          'rendszerben töröljék',
      'Semmit — a megálló le van zárva, a képen úgysem lehet már '
          'változtatni',
      'Másnap becsengetek a szomszédhoz, és engedélyt kérek',
    ],
    correctIndex: 0,
    explanation: 'A cég csak akkor tudja törölni a képet és dokumentálni '
        'az esetet, ha tud róla. A kézenfekvő tévedés az, hogy a megálló '
        'lezárása után már nem éri meg jelenteni. Az utólagos '
        'hozzájárulás nem orvosolja a jogsértést, és a foglalkoztatási '
        'kontextusban amúgy sem megbízható jogalap.',
  ),

  // ══════════════════════════ ds3 — A címzettadatok kezelése
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Képernyőképet készítesz a címlistáról, hogy jobban '
        'megjegyezd a sorrendet. Rajtad kívül senki nem látja. '
        'Megengedett ez?',
    options: [
      'Igen, amíg a képernyőképet a túra végén újra törlöd',
      'Igen, mert az adatokat munkádhoz amúgy is kezelheted',
      'Nem — a képernyőkép a rendszeren kívüli másolat, és ezzel '
          'megengedhetetlen',
    ],
    correctIndex: 2,
    explanation: 'A képernyőképpel személyes adatok olyan másolata jön '
        'létre, amelyet a cég már nem tud ellenőrizni. Az, hogy az '
        'adatokat a munkádhoz láthatod, nem jogosít fel arra, hogy a '
        'rendszeren kívül tárold őket. A későbbi törlés szándéka sem '
        'változtat a megengedhetetlen adatkezelésen.',
  ),
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Egy szomszéd átvesz egy csomagot, és megkérdezi, mi van '
        'benne, és hogy a címzett egyáltalán ott lakik-e még. Mit '
        'mondasz?',
    options: [
      'Csak a címzett nevét és a házszámot — a tartalomról és további '
          'adatokról semmi felvilágosítás',
      'Mindent, ami a címkén áll, hiszen ő veszi át a csomagot',
      'Semmit, még a címzett nevét sem',
    ],
    correctIndex: 0,
    explanation: 'A szomszédnál történő leadáshoz a név és a házszám '
        'szükséges — nélkülük a szomszéd nem tudja továbbadni a '
        'csomagot. Minden ezen túlmenő, különösen a tartalom vagy a '
        'lakáskörülmények megerősítése, az Art. 6 DSGVO szerinti jogalap '
        'nélküli felfedés. Semmit sem mondani viszont életszerűtlen '
        'lenne, és a leadás így nem lenne kivitelezhető.',
  ),
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'A túra véget ért, a papír túralistára már nincs szükség. '
        'Hogyan semmisíted meg helyesen?',
    options: [
      'A saját lakóházad papírgyűjtőjében, amint hazaérsz',
      'A cégnél kijelölt úton — adatvédelmi gyűjtő vagy '
          'iratmegsemmisítő',
      'Széttépve a benzinkúti vegyes hulladékba, hogy senki ne tudja '
          'többé elolvasni',
    ],
    correctIndex: 1,
    explanation: 'A listán nevek és címek szerepelnek; úgy kell '
        'megsemmisíteni, hogy ne legyen helyreállítható — a cégnél, '
        'adatvédelmi gyűjtőn vagy iratmegsemmisítőn keresztül. A '
        'kézenfekvő tévedés az, hogy egy elintézett lista értéktelen. A '
        'nyilvánosan hozzáférhető kukák kizártak, és a listát eleve nem '
        'is lett volna szabad hazavinned.',
  ),

  // ══════════════════════════ ds4 — Saját adatok és kollégaadatok
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Egy kolléga képernyőképet kér tőled egy belső '
        'kimutatásról, amelyen minden sofőr névvel és értékekkel '
        'szerepel. Csak a saját sorát akarja látni. Hogyan reagálsz?',
    options: [
      'Elutasítom, és az üzemvezetéshez irányítom — csak a saját '
          'adataira jogosult',
      'Elküldöm, mert ő maga is rajta van a listán, ezért hozzáférésre '
          'jogosult',
      'Elküldöm, de előbb kitakarom a többiek nevét, utána pedig törlöm '
          'a képernyőképet',
    ],
    correctIndex: 0,
    explanation: 'A képernyőképpel az összes kolléga teljesítményadatát '
        'megkapná — ez munkavállalói adatok jogalap nélküli továbbadása. '
        'Az Art. 15 DSGVO szerinti hozzáférési joga kizárólag a saját '
        'adataira vonatkozik. A házilag barkácsolt kitakarás sem '
        'változtat azon, hogy megengedhetetlen másolatot készítettél.',
  ),
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Miért élveznek különös védelmet a kollégák '
        'betegjelentései?',
    options: [
      'Mert a munkaszerződés kifejezetten bizalmasnak nevezi őket',
      'Mert a GeschGehG szerinti üzleti titkok',
      'Mert az egészségügyi adatok az Art. 9 DSGVO szerinti különleges '
          'kategóriájú személyes adatok',
    ],
    correctIndex: 2,
    explanation: 'Az egészségügyi adatok az Art. 9 DSGVO alá esnek, és '
        'szigorúbb védelem alatt állnak, mint a közönséges adatok. Már '
        'maga a megbetegedés ténye is ilyen adat, az oka pláne. Az '
        'üzleti titkok ezzel szemben céges tudást érintenek, nem a '
        'munkavállalók egészségügyi adatait.',
  ),
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Szeretnéd tudni, milyen adatokat tárol rólad a '
        'munkáltatód. Melyik jogodat használod ehhez?',
    options: [
      'Az adathordozhatósághoz való jogot az Art. 20 DSGVO szerint',
      'A hozzáférési jogot az Art. 15 DSGVO szerint',
      'A tiltakozási jogot az Art. 21 DSGVO szerint',
    ],
    correctIndex: 1,
    explanation: 'Az Art. 15 DSGVO jogot ad arra, hogy áttekintést kapj '
        'a rólad tárolt adatokról és a célokról. Az Art. 20 az adatok '
        'hordozható formátumban való kiadását, az Art. 21 az adatkezelés '
        'elleni tiltakozást érinti — egyik sem válaszolja meg, hogy '
        'egyáltalán mit tárolnak. A kérelemre főszabály szerint egy '
        'hónapon belül válaszolni kell.',
  ),

  // ══════════════════════════ ds5 — Adatvédelmi incidens
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Az alábbi esetek közül melyik NEM adatvédelmi incidens?',
    options: [
      'Egy csomagot rossz címzettnél adtál le, aki ki is nyitotta',
      'Elszámoltad a visszáruk darabszámát a napi jelentésben',
      'A túralistát nyitva hagytad a lezáratlan járműben',
    ],
    correctIndex: 1,
    explanation: 'Egy számolási hiba a visszáruknál nem érint személyes '
        'adatokat, és senki számára nem teszi hozzáférhetővé őket. A '
        'másik két esetben illetéktelenek ismerhettek meg neveket, '
        'címeket vagy küldeménytartalmakat — ez a személyes adatok '
        'védelmének megsértése.',
  ),
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Mit mond ki az Art. 33 DSGVO szerinti 72 órás határidő?',
    options: [
      'A cégnek az adatvédelmi incidenst lehetőleg a tudomásszerzéstől '
          'számított 72 órán belül jelentenie kell a felügyeleti '
          'hatóságnak',
      'A sofőrnek 72 órája van az esetet a cégnél jelenteni',
      'Az érintetteknek 72 órán belül panaszt kell tenniük a cégnél, '
          'különben elvész az igényük',
    ],
    correctIndex: 0,
    explanation: 'A határidő a céget köti a felügyeleti hatóság felé, és '
        'a tudomásszerzéstől fut. Pontosan ezért kell azonnal '
        'jelentened — minden óra, amit kivársz, a cégnek hiányzik. A '
        'kézenfekvő tévedés az, hogy a 72 órát a sofőr saját '
        'időablakaként olvassuk.',
  ),
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Este vetted észre, hogy egy csomag rossz címzettnél '
        'landolt, és ott ki is nyitották. Mi a helyes?',
    options: [
      'Holnap reggel feltűnés nélkül elhozni és jól kézbesíteni — így a '
          'hiba el van hárítva',
      'Csak a következő munkamegbeszélésen megemlíteni, mert úgysem '
          'lehet már változtatni rajta',
      'Még aznap szólni a diszpécsernek vagy az üzemvezetésnek, és '
          'semmit nem tenni saját szakállra',
    ],
    correctIndex: 2,
    explanation: 'Már bekövetkezett egy adatvédelmi incidens: egy idegen '
        'személy megismerte a nevet, a címet és a küldemény tartalmát. A '
        'cégnek értékelnie, dokumentálnia és adott esetben az Art. 33 '
        'DSGVO szerint jelentenie kell — ehhez azonnal kell neki az '
        'információ. A csendes korrekció ártalmatlannak tűnik, de '
        'pontosan ezeket a lépéseket akadályozza meg. Aki azonnal '
        'jelent, helyesen cselekszik.',
  ),

  // ══════════════════════════ ds6 — Titoktartás és lojalitás
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'Melyik megnyilvánulást NEM fedi a véleménynyilvánítás '
        'szabadsága?',
    options: [
      'Az az állítás, hogy egy túra rendszeresen nem teljesíthető a '
          'tervezett idő alatt',
      'A jelzés, hogy egy járművet többszöri bejelentés ellenére sem '
          'javítottak meg',
      'A tudatosan valótlan állítás, hogy a cég szisztematikusan csalja '
          'a sofőrjeit az óráknál',
    ],
    correctIndex: 2,
    explanation: 'A véleménynyilvánítást és az igazságnak megfelelő '
        'kritikát az Art. 5 Abs. 1 GG védi, akkor is, ha kényelmetlen. A '
        'tudatosan valótlan tényállításokat nem: azok a § 626 BGB '
        'szerinti azonnali felmondást indokolhatják, és rossz hírbe '
        'hozás esetén ráadásul a § 186 StGB szerint büntethetők.',
  ),
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'Legjobb tudásod szerint jelentesz egy visszásságot a '
        'cégnél. A végén kiderül, hogy a gyanúd nem igazolódott be. Mi '
        'érvényes?',
    options: [
      'A védelem visszamenőleg elesik, mert a bejelentés téves volt',
      'A bejelentővédelmi törvény (HinSchG) továbbra is véd a '
          'megtorlástól',
      'A védelem csak akkor érvényes, ha a bejelentést külső helyre is '
          'benyújtottad',
    ],
    correctIndex: 1,
    explanation: 'A HinSchG (2023. július 2. óta) megvédi a '
        'szabálysértéseket jelentő munkavállalókat a megtorlástól, mint '
        'a felmondás, a figyelmeztetés vagy a hátrányba hozás. A védelem '
        'csak tudatosan vagy súlyosan gondatlanul valótlan '
        'bejelentéseknél esik el — nem egy komoly gyanúnál, amely a '
        'végén nem igazolódik be. Külső bejelentés ehhez nem szükséges.',
  ),
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'A sofőr-chatcsoportban állítólagos bércsökkentésekről '
        'folyik a vita. Te magad is elégedetlen vagy. Mi a helyes út?',
    options: [
      'A saját, konkrét esetemet megnevezni, és a diszpécsernek, az '
          'üzemvezetésnek vagy a belső bejelentőhelynek átadni',
      'Megerősíteni az állítást a csoportban, hogy a kollégák '
          'figyelmeztetve legyenek',
      'A vádat nyilvánosan kiposztolni egy értékelőportálra, hogy '
          'történjen valami',
    ],
    correctIndex: 0,
    explanation: 'A saját, ellenőrizhető eset igaz, tárgyilagos és a '
        'HinSchG által védett — és belül oldható meg a leggyorsabban. '
        'Egy olyan állítást megerősíteni, amelyet magad nem éltél át, '
        'valótlan tényállítás; a zárt chatcsoport pedig nem védett tér, '
        'amint egy képernyőkép körbejár. A kifelé fordulás csak akkor '
        'jön szóba, ha belül semmi nem történik.',
  ),
];
