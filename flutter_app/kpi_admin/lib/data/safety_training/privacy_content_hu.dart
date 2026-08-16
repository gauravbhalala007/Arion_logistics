// lib/data/safety_training/privacy_content_hu.dart
//
// Az adatvédelmi oktatás tartalma — magyar változat.
// A felépítés azonos a német alapváltozattal (privacy_content_de.dart):
// ds1–ds6 fejezetek, ugyanazok a diák, ugyanazok a blokkok és ugyanazok
// az értékek. Tartalmi változtatás mindig előbb a német fájlban történik,
// utána itt — a kettőnek szinkronban kell maradnia.
//
// A hivatkozott jogszabályok németek (DSGVO = GDPR, BDSG, GeschGehG,
// HinSchG); a cikk- és paragrafushivatkozások a német eredetivel
// azonosan maradnak. Ehhez a témához nincsenek illusztrációk, ezért
// `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> privacyContentHu = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ds1',
    title: 'Miért érint téged az adatvédelem',
    summary: 'Személyes adatok a kézbesítés mindennapjaiban és az '
        'Art. 5 DSGVO alapelvei',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Egész nap mások adataival dolgozol',
        blocks: [
          ParagraphBlock(
            'Az adatvédelem irodát, iratszekrényt és jogászt idéz. '
            'Valójában alig van bárki, aki olyan közel lenne a személyes '
            'adatokhoz, mint te. A reggeli első szkenneléstől az esti '
            'utolsó megállóig idegen nevek, címek és telefonszámok vannak '
            'a kezedben — és hozzá fotók idegen bejárati ajtókról.',
          ),
          ParagraphBlock(
            'Személyes adat minden olyan információ, amely alapján egy '
            'személy azonosítható. Nem csak a név: a cím, az időpont és a '
            'csomagtartalom kombinációja is elárul valamit egy emberről. '
            'Pontosan ezért vonatkoznak rá szabályok.',
          ),
          BulletsBlock([
            'Címzettek nevei és címei a címkén, a szkenneren és a listán',
            'Telefonszámok a kézbesítés előtti kapcsolatfelvételhez',
            'Aláírások a szkenneren átvételi igazolásként',
            'Fotók kézbesítési igazolásként az ajtó előtt',
            'A szkenner és a jármű helyadatai',
            'Adatok a szomszédokról, akiknél csomagot adtál le',
            'Megjegyzések, mint „a csomagot kérem a kuka mögé" — ez is '
                'információ egy ember lakhatási helyzetéről',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Röviden',
            text: 'Mindent, amit egy címzettről megtudsz, csak azért '
                'tudod, mert te viszed a csomagot. Semmi másra nem kaptad '
                'ezt az információt.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Három alapelv, ami a mindennapokban számít',
        blocks: [
          ParagraphBlock(
            'Az Art. 5 DSGVO (GDPR) hat alapelvet rögzít. Közülük három '
            'gyakorlatilag minden nap eldönti, hogy helyesen vagy '
            'helytelenül cselekszel-e. Egyszerű nyelven:',
          ),
          TableBlock(
            headers: ['Alapelv', 'Mit jelent ez neked'],
            rows: [
              [
                'Célhoz kötöttség',
                'Az adatokat csak arra a célra használd, amire kaptad: a '
                    'kézbesítésre. Privát célra nem.',
              ],
              [
                'Adattakarékosság',
                'Csak annyit gyűjts és mutass, amennyi szükséges. Nincs a '
                    'kelleténél több fotó, se hosszabb lista.',
              ],
              [
                'Bizalmasság',
                'Amit látsz, nálad és a cégen belül marad. Nem a '
                    'chatcsoportban, nem a konyhaasztalnál, nem a neten.',
              ],
            ],
          ),
          ParagraphBlock(
            'Ehhez jön a pontosság (a hibás adatot javítani kell, nem '
            'továbbcipelni), a tárolás korlátozása (semmit sem tartunk '
            'meg tovább a szükségesnél) és az elszámoltathatóság — ez '
            'utóbbi a céget érinti, és ez az oka ennek az oktatásnak.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A jogi háttér',
            text: 'Az Art. 5 Abs. 1 DSGVO többek között célhoz '
                'kötöttséget (lit. b), adattakarékosságot (lit. c), '
                'valamint integritást és bizalmasságot (lit. f) követel '
                'meg. Ezek az alapelvek mindenkire érvényesek, aki a cég '
                'megbízásából személyes adatokkal dolgozik — tehát rád is '
                'a túrán.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Miért létezik ez az oktatás',
        blocks: [
          ParagraphBlock(
            'A DSGVO sehol nem írja le szó szerint, hogy „a munkatársakat '
            'oktatni kell". Mégis megköveteli — csak három másik úton. '
            'Ezért ülsz most itt, és ezért dokumentáljuk az elvégzését.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Miből következik az oktatási kötelezettség',
            text: 'Az Art. 32 DSGVO technikai és szervezési '
                'intézkedésekre kötelezi a céget az adatkezelés '
                'biztonsága érdekében — a képzett munkatárs ilyen '
                'intézkedés. Az Art. 39 Abs. 1 lit. b DSGVO a '
                'tudatosítást és az oktatást kifejezetten az adatvédelmi '
                'tisztviselő feladataként nevezi meg. Az Art. 5 Abs. 2 '
                'DSGVO pedig megköveteli, hogy a cég igazolni tudja a '
                'szabályok betartását — ez az elszámoltathatóság.',
          ),
          ParagraphBlock(
            'A felügyeleti hatóságok egy ellenőrzésnél pontosan ezt '
            'nézik. A hiányzó munkatársi oktatást rendszeresen annak '
            'jeleként értékelik, hogy az intézkedések elégtelenek voltak '
            '— különösen akkor, ha már történt valami. Egy adatvédelmi '
            'incidens után szinte mindig az az első kérdés: képzettek '
            'voltak-e az emberek, és tudjátok-e ezt bizonyítani?',
          ),
          BulletsBlock([
            'Éves alapoktatás mindenkinek — az elvégzés tizenkét hónapig '
                'érvényes',
            'Rendkívüli oktatás, ha valami változik vagy történt valami',
            'Új munkatársak betanítása az első önálló nap előtt',
            'A teszt és az aláírás dokumentálása igazolásként az '
                'Art. 5 Abs. 2 DSGVO szerint',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Hol húzódik a határ a mindennapokban',
        blocks: [
          RevealBlock(
            prompt: 'Példaeset: A túrádon van egy csomag egy környékbeli '
                'ismert focistának. Este elmeséled a baráti körben, '
                'melyik utcában lakik — semmi több, nincs név a közösségi '
                'médiában, csak barátok között. Adatvédelmi jogsértés ez?',
            answer: 'Igen. A cím személyes adat, és kizárólag a munkádból '
                'ismered. Harmadik félnek továbbadni sérti a célhoz '
                'kötöttséget (Art. 5 Abs. 1 lit. b DSGVO) és a '
                'bizalmasságot (lit. f). A kézenfekvő tévedés az, hogy '
                'egy privát kör „nem számít" — a DSGVO nem azt kérdezi, '
                'mekkora volt a közönséged, hanem hogy céltól eltérően '
                'fedted-e fel az adatot. Ha az egyik barátod továbbadja, '
                'ráadásul már semmilyen kontrollod nincs felette.',
          ),
          DoDontBlock(
            doTitle: 'Helyes',
            dos: [
              'A címzettek adatait csak a kézbesítésre használni, utána a '
                  'rendszerben hagyni',
              'Egy küldeménnyel kapcsolatos kérdéseknél a diszpécserhez '
                  'vagy az üzemvezetéshez irányítani',
              'A szkennert és a papírlistát úgy tartani, hogy mások ne '
                  'olvashassák',
              'A nem egyértelmű helyzeteket szóvá tenni ahelyett, hogy '
                  'magad döntenél',
            ],
            dontTitle: 'Helytelen',
            donts: [
              'Címeket vagy neveket a magánéletben elmesélni — „csak '
                  'barátok között" sem',
              'Hírességeket vagy feltűnő küldeményeket beszédtémává '
                  'tenni',
              'Címzettadatokat kíváncsiságból kikeresni anélkül, hogy '
                  'erre megbízásod lenne',
              'Arra hagyatkozni, hogy „úgysem tudja meg senki"',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista — 1. fejezet',
        blocks: [
          ParagraphBlock(
            'Menj végig röviden a pontokon. Ha valamelyiknél '
            'elbizonytalanodsz, lapozz vissza — a tesztben pontosan ezek '
            'a helyzetek jönnek elő újra.',
          ),
          ChecklistBlock(
            title: 'Ezt viszem magammal az 1. fejezetből',
            items: [
              'Tudom, mely adatok személyes adatok a túrámon',
              'Ismerem a célhoz kötöttséget, az adattakarékosságot és a '
                  'bizalmasságot',
              'Tudom, hogy a címzettek adatai nem valók a magánéletbe',
              'Tudom, miért dokumentáljuk ezt az oktatást '
                  '(Art. 5 Abs. 2 DSGVO)',
              'Világos számomra, hogy az oktatás évente ismétlődik',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ds2',
    title: 'Fotók és kézbesítési igazolások',
    summary: 'Mi kerülhet a képre, mi nem — és hová tartozik a fotó',
    asset: '',
    slides: [
      SafetySlide(
        title: 'A fotónak pontosan egy célja van',
        blocks: [
          ParagraphBlock(
            'A kézbesítési fotónak egyetlen kérdésre kell válaszolnia: '
            'hol van a csomag? Semmi másra. Minden, ami ezen túlmegy, '
            'több információ a szükségesnél — és ezzel az '
            'adattakarékosság megsértése.',
          ),
          ParagraphBlock(
            'A gyakorlatban ez azt jelenti: a kamerát le a csomagra, elég '
            'közel ahhoz, hogy a lerakóhely felismerhető legyen, és elég '
            'távol mindentől, ami embereket mutat vagy azonosíthatóvá '
            'tesz.',
          ),
          DoDontBlock(
            doTitle: 'Kerülhet a képre',
            dos: [
              'Maga a csomag a lerakóhelyen',
              'Egy darab házfal, ajtó vagy lépcső helymegjelölésként',
              'A házszám, ha az azonosításhoz szükséges',
              'Lerakási engedélynél: a megbeszélt lerakóhely',
            ],
            dontTitle: 'Nem kerülhet a képre',
            donts: [
              'Személyek — a címzett sem, még hátulról sem',
              'Parkoló járművek rendszámai',
              'Ablakok, erkélyek és belső terekre nyíló rálátás',
              'Gyerekek, háziállatok, látogatók, szomszédok a háttérben',
              'Harmadik személyek névtáblái, ha nem tartoznak a '
                  'küldeményhez',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A jogi háttér',
            text: 'Az Art. 5 Abs. 1 lit. c DSGVO adattakarékosságot '
                'követel: az adatoknak a cél szempontjából megfelelőnek '
                'és a szükséges mértékre korlátozottnak kell lenniük. Az '
                'a fotó, amelyen személyek, rendszámok vagy lakásbelsők '
                'láthatók, túlmegy a „kézbesítési igazolás" célján. A '
                'képen szereplő személyeknél emellett a saját képmáshoz '
                'való jog is érvényesül.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Hová tartozik a fotó — és hová nem',
        blocks: [
          ParagraphBlock(
            'A kép tartalmánál ugyanolyan fontos a tárolás helye. A fotó '
            'a munkahelyi appban készül, és ott is marad. Semmi '
            'keresnivalója a privát galériádban, és pláne nem egy '
            'messengerben.',
          ),
          BulletsBlock([
            'A fotót kizárólag a munkahelyi appban készítsd — ne előbb a '
                'kamera-appal, aztán feltöltve',
            'Nincs másolat a privát galériában, nincs felhőmentés a '
                'privát telefonon',
            'Nincs küldés WhatsAppon, Telegramon, Signalon vagy egy '
                'sofőr-chatcsoportban',
            'Ne tarts meg fotót „biztonság kedvéért" magadnak — az '
                'igazolás a rendszerben van',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'A leggyakoribb hiba',
            text: 'Először a normál kamerával fotózni, aztán a képet '
                'feltölteni az appba. Így a fotó tartósan a privát '
                'galériádban marad — gyakran ráadásul egy külföldi '
                'felhőben is. Ez megengedhetetlen adatkezelés, akkor is, '
                'ha soha senkinek nem mutatod meg.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ha mégis rajta van valaki',
        blocks: [
          ParagraphBlock(
            'Előfordul: a szomszéd pont az exponálás pillanatában lép ki '
            'az ajtón, vagy egy gyerek szalad át a képen. Ez nem dráma — '
            'amíg azonnal cselekszel.',
          ),
          StepsBlock([
            'A fotót azonnal töröld, mielőtt lezárod a megállót',
            'Fotózz újra, ezúttal személy nélkül a képen',
            'Ha a kép már fel van töltve: szólj a diszpécsernek vagy az '
                'üzemvezetésnek, hogy a rendszerből törölhessék',
            'Ha bizonytalan vagy, hogy valaki felismerhető-e: inkább '
                'jelentsd, mint hogy reménykedj',
          ]),
          RevealBlock(
            prompt: 'Példaeset: Egy csomagot a hátsó udvarban raksz le. A '
                'fotón látszik a csomag — és a háttérben egy padlóig érő '
                'ablakon át egy nappali, két emberrel a kanapén. Már '
                'lezártad a megállót, és a következő udvarban állsz. Mit '
                'teszel?',
            answer: 'Jelented. A kép belső teret és felismerhető '
                'személyeket mutat — messze túlmegy a „kézbesítési '
                'igazolás" célján, és el kell távolítani a rendszerből. A '
                'kézenfekvő tévedés az, hogy a hibát már nem éri meg '
                'jelenteni, mert a megálló le van zárva. Pont fordítva: a '
                'cég csak akkor tudja törölni a képet és dokumentálni az '
                'esetet, ha tud róla. Aki jelenti, mindent jól csinál — '
                'aki hallgat, fenntart egy jogsértést.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista — 2. fejezet',
        blocks: [
          ChecklistBlock(
            title: 'Minden kézbesítési fotó előtt',
            items: [
              'Csak a munkahelyi appban fotózok',
              'A képen nem látható személy',
              'Nincs rendszám, nincs ablak, nincs belső tér a képen',
              'A csomag és a lerakóhely egyértelműen felismerhető',
              'Egyetlen kép sem kerül a privát galériámba vagy egy '
                  'chatbe',
              'Ha véletlenül rajta van valaki: törlés, új kép, '
                  'jelentés',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ds3',
    title: 'A címzettadatok kezelése',
    summary: 'Szkenner, telefon és papírlisták — munkaeszközök, nem '
        'magánügy',
    asset: '',
    slides: [
      SafetySlide(
        title: 'A szkenner és a céges telefon nem magáneszköz',
        blocks: [
          ParagraphBlock(
            'A szkenneren és a céges telefonon naponta több száz ember '
            'adatai vannak. Mindkét eszköz a cégé, és kizárólag a munkára '
            'való — a szünetben is, és akkor is, ha hazaviszed.',
          ),
          BulletsBlock([
            'Nincs privát app, nincs privát bejelentkezés, nincs privát '
                'felhő a céges eszközön',
            'Az eszközt ne add tovább — rövid időre se kollégának, '
                'hozzátartozónak vagy ismerősnek',
            'A képernyőzár maradjon aktív, és soha ne hagyd az eszközt '
                'felügyelet nélkül',
            'A jármű elhagyásakor: a szkennert vidd magaddal vagy rakd el '
                'biztonságosan, ne láthatóan az ülésen',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Szigorúan tilos',
            text: 'Semmilyen képernyőkép címlistákról, túraáttekintésekről '
                'vagy címzettadatokról. Akkor sem, ha csak magadnak '
                'küldenéd, és „emlékeztetőnek" sem. A képernyőkép a '
                'rendszeren kívüli másolat — pontosan az, amit a cég már '
                'nem tud ellenőrizni.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Felvilágosítás szomszédoknak és idegeneknek',
        blocks: [
          ParagraphBlock(
            'Az ajtóban kérdezni fognak. Ez normális, és többnyire '
            'ártatlan szándékú. Mégis érvényes: csak annyit árulsz el, '
            'amennyi a kézbesítéshez szükséges — többet nem.',
          ),
          TableBlock(
            headers: ['Helyzet', 'Eddig mehetsz el'],
            rows: [
              [
                'A szomszéd átvesz egy csomagot',
                'A címzett nevét és a házszámot mondhatod — többre nincs '
                    'szüksége.',
              ],
              [
                'A szomszéd kérdezi, mi van benne',
                'Semmi felvilágosítás. A tartalom csak a címzettre '
                    'tartozik.',
              ],
              [
                'Valaki kérdezi, itt lakik-e X személy',
                'Semmi felvilágosítás. Lakcímeket nem erősítesz meg.',
              ],
              [
                'Valaki kérdezi, mikor jössz legközelebb',
                'Válaszolj általánosan, semmilyen adat más küldeményekről '
                    'vagy címzettekről.',
              ],
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A jogi háttér',
            text: 'A címzettadatok harmadik félnek való továbbadása az '
                'Art. 4 Nr. 2 DSGVO értelmében vett közlés, és az '
                'Art. 6 DSGVO szerinti jogalapot igényel. A szomszédnál '
                'történő leadáshoz a név és a cím közlése a szerződés '
                'teljesítéséhez szükséges — a csomagtartalomra, '
                'telefonszámokra vagy a más címzettekről szóló '
                'felvilágosításra viszont nincs jogalap.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A papír az alábecsült veszély',
        blocks: [
          ParagraphBlock(
            'A digitális adatokat legalább egy képernyőzár védi. Egy '
            'cetlit a járműben semmi. Egy túralista a szélvédő mögött '
            'kívülről olvasható — kétszáz háztartás nevével és címével.',
          ),
          BulletsBlock([
            'Papírlistát soha ne hagyj nyitva a járműben, pláne ne az '
                'üvegen át láthatóan',
            'A jármű elhagyásakor a listákat vidd magaddal vagy zárd el',
            'A túra végén: a listákat add le a telephelyen, ne vidd haza',
            'Megsemmisítés csak a cégnél kijelölt úton — nem a háztartási '
                'szemétbe, nem a benzinkúti szemetesbe',
            'A visszáruk és a téves csomagok címkéit ugyanúgy kezeld, '
                'mint a listákat',
          ]),
          RevealBlock(
            prompt: 'Példaeset: Végeztél a túrával, a túralista már csak '
                'papírhulladék. Hazafelé bedobod a lakóházad '
                'papírgyűjtőjébe. Rendben van ez?',
            answer: 'Nem. A listán nevek és címek szerepelnek — személyes '
                'adatok. Úgy kell megsemmisíteni, hogy senki ne tudja '
                'helyreállítani, jellemzően a cég adatvédelmi gyűjtőjén '
                'vagy iratmegsemmisítőjén keresztül. A kézenfekvő tévedés '
                'az, hogy egy elintézett lista „már nem ér semmit". Az '
                'adatvédelem szempontjából az elintézettség nem változtat '
                'semmin: az adatok ugyanazok, és egy nyitott papírgyűjtő '
                'nyilvánosan hozzáférhető hely. Ráadásul a listát eleve '
                'nem lett volna szabad hazavinned.',
          ),
          DoDontBlock(
            doTitle: 'Helyes',
            dos: [
              'A listákat a telephelyen leadni és ott szabályosan '
                  'megsemmisíteni',
              'A szkennert zárolni, mielőtt elhagyod a járművet',
              'Idegen küldeményekkel kapcsolatos kérdéseknél az '
                  'üzemvezetéshez irányítani',
            ],
            dontTitle: 'Helytelen',
            donts: [
              'Képernyőképet készíteni vagy küldeni címlistákról',
              'Túralistákat hazavinni vagy otthon kidobni',
              'Címzettadatokat szomszédoknak, ismerősöknek vagy harmadik '
                  'félnek továbbadni',
              'A céges eszközt másnak továbbadni',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista — 3. fejezet',
        blocks: [
          ChecklistBlock(
            title: 'Minden túra végén',
            items: [
              'Nincs képernyőkép címadatokról az eszközömön',
              'A szkenner és a céges telefon zárolva és biztonságosan '
                  'elrakva',
              'Semmilyen papírlista nem marad nyitva a járműben',
              'Minden listát és címkét leadtam a telephelyen',
              'Nem adtam tovább címzettadatot harmadik félnek',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ds4',
    title: 'A saját adataid és a kollégák adatai',
    summary: 'Betegjelentés, munkaidő-nyilvántartás, személyi akta — és '
        'az érintetti jogaid',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Az adatvédelem téged is véd',
        blocks: [
          ParagraphBlock(
            'Nem csak a címzetteknek vannak adatai a rendszerben — neked '
            'is. És ezek részben jóval érzékenyebbek, mint egy szállítási '
            'cím.',
          ),
          BulletsBlock([
            'Teljesítménymutatók a kézbesítési munkádból',
            'Betegjelentések és távollétek',
            'Munkaidő-nyilvántartás, műszakbeosztások, szünetidők',
            'Jogosítvány- és személyiigazolvány-adatok a személyi '
                'aktából',
            'Fotók, amelyeken te vagy a kollégák láthatók',
          ]),
          ParagraphBlock(
            'Ezeket az adatokat a cég kezelheti, amennyiben a '
            'munkaviszonyhoz szükséges. De nem adhatja tovább tetszés '
            'szerint — és te ugyanúgy nem, ha kollégákról van szó.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A jogi háttér',
            text: 'A munkavállalói adatok kezelése az Art. 6 Abs. 1 '
                'lit. b és f DSGVO alapján történik, a § 26 BDSG-vel '
                'összefüggésben — csak annyiban megengedett, amennyiben a '
                'munkaviszonyhoz szükséges. Az egészségügyi adatok, mint '
                'a betegjelentések, az Art. 9 DSGVO szerinti különleges '
                'kategóriák, és különösen szigorú védelem alatt állnak.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A kollégák adatai nem a tieid',
        blocks: [
          ParagraphBlock(
            'A depóban sok mindent hall az ember: ki beteg, kinek volt '
            'gondja egy túrával, ki kapott figyelmeztetést. Hallani egy '
            'dolog — továbbmesélni egy másik.',
          ),
          DoDontBlock(
            doTitle: 'Helyes',
            dos: [
              'A saját értékeidről beszélni, amennyit csak szeretnél',
              'Egy kollégával való problémát vele magával vagy az '
                  'üzemvezetéssel tisztázni',
              'Kollégákkal közös fotót csak akkor készíteni és '
                  'megosztani, ha minden szereplő beleegyezik',
              'A megfigyelt szabálysértéseket belül jelenteni ahelyett, '
                  'hogy a depóban terjesztenéd',
            ],
            dontTitle: 'Helytelen',
            donts: [
              'Kollégák teljesítményadatait vagy kimutatásait '
                  'továbbadni',
              'Egy kolléga betegségének okáról beszélni — akkor sem, ha '
                  'ismered',
              'Kollégákról fotót vagy videót a beleegyezésük nélkül '
                  'chatcsoportokba posztolni',
              'Belső listákból vagy kimutatásokból képernyőképeket '
                  'megosztani',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Különösen kényes',
            text: 'A betegjelentések. Az, hogy valaki beteg, az '
                'Art. 9 DSGVO szerinti egészségügyi adat. Az ok pláne. A '
                'továbbadás más sofőröknek akkor sem megengedett, ha az '
                'érintett maga már mesélt róla.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A jogaid érintettként',
        blocks: [
          ParagraphBlock(
            'A DSGVO jogokat ad neked a munkáltatóddal szemben. Nem kell '
            'megindokolnod őket, és a gyakorlásuk nem válhat a '
            'hátrányodra.',
          ),
          TableBlock(
            headers: ['Jog', 'Mit kérhetsz'],
            rows: [
              [
                'Hozzáférés (Art. 15)',
                'Áttekintést arról, milyen adatokat tárolnak rólad és '
                    'milyen célból.',
              ],
              [
                'Helyesbítés (Art. 16)',
                'A hibás adatok javítását, például egy rossz törzsszámot '
                    'vagy címet.',
              ],
              [
                'Törlés (Art. 17)',
                'Azoknak az adatoknak a törlését, amelyekre már nincs '
                    'szükség, és nem esnek megőrzési kötelezettség alá.',
              ],
            ],
          ),
          ParagraphBlock(
            'A kapcsolattartó az üzemvezetés vagy a cég adatvédelmi '
            'tisztviselője. Egy kérelemre főszabály szerint egy hónapon '
            'belül válaszolni kell.',
          ),
          RevealBlock(
            prompt: 'Példaeset: Egy kolléga megkér, hogy küldd el neki '
                'egy belső kimutatás képernyőképét — amelyen minden sofőr '
                'névvel és értékekkel szerepel. Csak azt akarja látni, ő '
                'maga hol áll. Megteszed?',
            answer: 'Nem. A képernyőképen az összes kolléga '
                'teljesítményadata szerepel; ez munkavállalói adatok '
                'jogalap nélküli továbbadása. Az, hogy a kolléga csak a '
                'saját sorát akarja látni, nem változtat semmin — így is '
                'megkapja az összes többiét. A helyes út: a saját '
                'értékeit az üzemvezetéstől kérdezi le. Az Art. 15 DSGVO '
                'szerinti hozzáférési joga kizárólag a saját adataira '
                'vonatkozik.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista — 4. fejezet',
        blocks: [
          ChecklistBlock(
            title: 'A kollégák adatainak kezelésénél',
            items: [
              'Nem adom tovább kollégák teljesítményadatait',
              'Nem beszélek mások betegjelentéseiről',
              'Nem posztolok fotót kollégákról a beleegyezésük nélkül',
              'Nem készítek képernyőképet belső kimutatásokból',
              'Tudom, kihez fordulok, ha a saját adataimról szeretnék '
                  'tájékoztatást',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ds5',
    title: 'Ha valami félremegy — adatvédelmi incidens',
    summary: '72 órás bejelentési határidő: miért kell azonnal '
        'jelentened',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Mi az adatvédelmi incidens',
        blocks: [
          ParagraphBlock(
            'Az adatvédelmi incidens nem csak a nagy hackertámadás. A '
            'kézbesítésben szinte mindig kis, hétköznapi malőrökről van '
            'szó — és pontosan ezek is számítanak.',
          ),
          BulletsBlock([
            'Céges telefon vagy szkenner elveszett vagy ellopták',
            'Csomag rossz címzettnél leadva, aki kinyitotta',
            'Csomag olvasható címcímkével nyitva hagyva a lépcsőházban '
                'vagy az utcán',
            'Fotó vagy címlista véletlenül rossz személynek elküldve',
            'Túralista elveszett vagy nyitva hagyva a járműben',
            'A szkenner felügyelet nélkül és feloldva hozzáférhető volt',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ökölszabály',
            text: 'Amint személyes adatok olyasvalaki számára váltak '
                'hozzáférhetővé, akinek nem lett volna szabad, az '
                'adatvédelmi incidens. Hogy a végén tényleg keletkezett-e '
                'kár, nem te döntöd el — azt a cég vizsgálja.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A 72 órás határidő',
        blocks: [
          ParagraphBlock(
            'A számodra döntő pont az óra. Amint a cég tudomást szerez '
            'egy adatvédelmi incidensről, egy nagyon rövid határidő indul '
            '— és fut attól függetlenül, hogy munkaidő vége, hétvége vagy '
            'ünnepnap van-e.',
          ),
          FactsBlock([
            FactItem('72 óra', 'a cég bejelentési határideje a '
                'felügyeleti hatóság felé az Art. 33 DSGVO szerint'),
            FactItem('azonnal', 'a te jelentésed a diszpécsernek vagy az '
                'üzemvezetésnek — még aznap'),
            FactItem('0', 'hátrány ér, ha egy saját hibát azonnal '
                'jelentesz'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A jogi háttér',
            text: 'Az Art. 33 Abs. 1 DSGVO arra kötelezi a céget, hogy a '
                'személyes adatok védelmének megsértését haladéktalanul, '
                'lehetőleg a tudomásszerzéstől számított 72 órán belül '
                'jelentse a felügyeleti hatóságnak. Magas kockázat esetén '
                'az Art. 34 DSGVO szerint az érintetteket is értesíteni '
                'kell. A cég ezt a határidőt csak akkor tudja tartani, ha '
                'te azonnal jelentesz.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Így jelentesz helyesen',
        blocks: [
          StepsBlock([
            'Azonnal hívd a diszpécsert vagy az üzemvezetést — ne várj a '
                'munkaidő végéig',
            'Mondd el, mi történt, mikor történt és milyen adatok '
                'érintettek',
            'Mondd el, ki láthatta az adatokat',
            'Semmit ne javíts saját szakállra: semmi naplótörlés, semmi '
                'visszaszerzés egyeztetés nélkül',
            'Ha lehet, őrizd meg az állapotot — például a tévesen '
                'kézbesített csomagot ne mozgasd tovább, amíg nincs '
                'egyeztetve, mi a teendő',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'A legfontosabb ebben a fejezetben',
            text: 'Aki egy hibát azonnal jelent, helyesen cselekszik. A '
                'jelentés kifejezetten kívánatos, és nem az alkalmatlanság '
                'beismerése. Az elhallgatás viszont egy kis malőrből '
                'igazi problémát csinál — az érintetteknek, a cégnek és '
                'végül neked is.',
          ),
          DoDontBlock(
            doTitle: 'Helyes',
            dos: [
              'Azonnal jelenteni, akkor is, ha kínos',
              'Mindent teljeskörűen elmondani, a saját hibákat is',
              'Rákérdezni, kell-e még tenned valamit',
            ],
            dontTitle: 'Helytelen',
            donts: [
              'Kivárni, hogy egyáltalán észreveszi-e valaki',
              'Csak a következő munkanapon szólni',
              'Az esetet bagatellizálni vagy részeket kihagyni',
              'Saját szakállra megpróbálni visszaszerezni a csomagot '
                  'vagy a fotót',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Példaeset és ellenőrzőlista',
        blocks: [
          RevealBlock(
            prompt: 'Példaeset: Este veszed észre, hogy egy csomagot a '
                '41. helyett a 14. szám alatt adtál le. Az ottani átvevő '
                'már ki is nyitotta. Holnap reggel egyszerűen el akarod '
                'hozni és jól kézbesíteni — így senkinek nem tűnik fel. '
                'Mi ezzel a baj?',
            answer: 'Két dolog. Először is már bekövetkezett egy '
                'adatvédelmi incidens: egy idegen személy megismerte a '
                'küldemény címzettjének nevét, címét és a tartalmát. Ezt '
                'a bejelentési kötelezettség szempontjából vizsgálni '
                'kell, és az Art. 33 DSGVO szerinti 72 órás határidő '
                'attól a pillanattól fut, amikor a cég tudomást szerez '
                'róla. Másodszor a kivárással pontosan azt akadályozod '
                'meg, amit a cégnek tennie kellene — értékelni, '
                'dokumentálni és adott esetben értesíteni az érintett '
                'címzettet. A kézenfekvő tévedés az, hogy a csendes '
                'korrekció senkinek nem árt. Valójában árt: ha az eset '
                'később kiderül, a cég határidőben tett bejelentés nélkül '
                'áll ott — te pedig elhallgattad a hibát ahelyett, hogy '
                'jelentetted volna.',
          ),
          ChecklistBlock(
            title: 'Adatvédelmi incidens minden gyanújánál',
            items: [
              'Még aznap jelentem, nem csak holnap',
              'Elmondom, mi történt, mikor és milyen adatok érintettek',
              'Semmit nem szépítek és semmit nem hagyok ki',
              'Semmit nem teszek saját szakállra',
              'Világos számomra: jelenteni helyes, elhallgatni csak '
                  'rosszabbá teszi',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'ds6',
    title: 'Titoktartás és lojalitás',
    summary: 'Mi mehet kifelé, mi nem — és miért kifejezetten megengedett '
        'a tárgyilagos kritika',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Az üzleti titkok a cégen belül maradnak',
        blocks: [
          ParagraphBlock(
            'A személyes adatok mellett van egy második információcsoport, '
            'amely nem való kifelé: a belső számok, valamint az üzemi és '
            'üzleti titkok. Ide tartozik sok minden, amit a depóban '
            'teljesen magától értetődően megbeszélnek.',
          ),
          BulletsBlock([
            'Árak, kondíciók és szerződések a megbízókkal',
            'Belső mutatószámok és kimutatások',
            'Túratervek, útvonallogika és kapacitásszámok',
            'Belső utasítások, oktatási anyagok és folyamatelőírások',
            'Depóban készült fotók, amelyeken listák, képernyők vagy '
                'küldemények felismerhetők',
          ]),
          ParagraphBlock(
            'Ez minden csatornán ugyanúgy érvényes: személyes '
            'beszélgetésben, közösségi hálózatokon és '
            'sofőr-chatcsoportokban. Egy hatvan sofőrből álló '
            'WhatsApp-csoport nem magánbeszélgetés.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A jogi háttér',
            text: 'Az üzleti titkokat az üzleti titkokról szóló német '
                'törvény (GeschGehG) védi. Ettől függetlenül a '
                'munkaszerződésből titoktartási kötelezettség következik '
                'mint munkaszerződési mellékkötelezettség a § 241 Abs. 2 '
                'BGB szerint. A személyes adatokra emellett az Art. 5 '
                'Abs. 1 lit. f DSGVO szerinti bizalmasság vonatkozik.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Valótlan állítások a cégről',
        blocks: [
          ParagraphBlock(
            'Itt gyakran összekeveredik, mi megengedett és mi nem. A '
            'határ nem a „pozitív" és a „negatív" között húzódik, hanem '
            'az igaz és a tudatosan valótlan, a kritika és a becsmérlés '
            'között.',
          ),
          ParagraphBlock(
            'A cégről, a vezetőkről vagy a kollégákról tett tudatosan '
            'valótlan tényállításokat a véleménynyilvánítás szabadsága '
            'nem fedi. Ugyanez érvényes a sértegetésre és a gyalázkodó '
            'kritikára — vagyis azokra a megnyilvánulásokra, amelyekben '
            'már nem a tárgyról van szó, hanem csak arról, hogy valakit '
            'lealacsonyítsanak.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A jogi háttér',
            text: 'Az Art. 5 Abs. 1 GG (a német alaptörvény) védi a '
                'véleménynyilvánítást, de nem védi a tudatosan valótlan '
                'tényállításokat és a gyalázkodó kritikát. Az ilyen '
                'megnyilvánulások a § 626 BGB szerinti azonnali '
                'felmondást indokolhatnak. Rossz hírbe hozásnál a § 186 '
                'StGB szerinti büntethetőség is felmerül; tudatosan hamis '
                'állításoknál a § 187 StGB (rágalmazás) lép be.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Tipikus félreértések',
            text: 'Egy privát profil nem privát, amint mások is '
                'olvashatják. Egy zárt chatcsoport nem védett, amint egy '
                'képernyőkép továbbmegy belőle. És az, hogy „ez csak a '
                'véleményem volt", nem segít, ha az állítás olyan '
                'tényállítás volt, amely bizonyíthatóan nem igaz.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A tárgyilagos kritika kifejezetten megengedett',
        blocks: [
          ParagraphBlock(
            'A határvonalnál ugyanolyan fontos, mi van rajta innen — és '
            'az sok. Mondhatsz kritikát, akár élesen, akár kényelmetlenül '
            'is. Mondhatod, hogy egy túra túl szűkre van tervezve, hogy '
            'egy jármű rossz állapotban van, vagy hogy egy depóbeli '
            'utasítás hibás volt.',
          ),
          ParagraphBlock(
            'És aki valódi visszásságokat jelent, nem áll védtelenül: '
            '2023. július 2. óta hatályos a bejelentővédelmi törvény '
            '(HinSchG). Tiltja a megtorlást a szabálysértéseket jelentő '
            'munkavállalókkal szemben — vagyis a felmondást, a '
            'figyelmeztetést, az áthelyezést vagy a hátrányba hozást a '
            'bejelentés miatt.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Bejelentővédelem',
            text: 'A HinSchG megvédi a megtorlástól azokat, akik szakmai '
                'összefüggésben szabálysértéseket jelentenek. A védelem '
                'csak tudatosan vagy súlyosan gondatlanul valótlan '
                'bejelentéseknél esik el. Aki tehát komolyan és legjobb '
                'tudása szerint jelent egy visszásságot, védett — akkor '
                'is, ha a gyanú a végén nem igazolódik be.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'A különbség egy mondatban',
            text: 'Mondd azt, amit átéltél — ne azt, amit összeraksz '
                'magadnak. Az igazságnak megfelelő kritika védett, a '
                'kitalált vádak nem.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A konstruktív út',
        blocks: [
          ParagraphBlock(
            'Szinte minden, amit a sofőrök kifelé visznek, belül '
            'gyorsabban megoldható lenne. A belső út ezért nemcsak a '
            'biztonságosabb, hanem többnyire a hatékonyabb is.',
          ),
          StepsBlock([
            'Először a diszpécsert szólítsd meg — a legtöbb probléma '
                'tervezési probléma, és ott megoldható',
            'Ha nem jön válasz: az üzemvezetést szólítsd meg, akár '
                'írásban, dátummal és konkrét esettel',
            'Súlyosabb szabálysértéseknél: használd a HinSchG szerinti '
                'belső bejelentőhelyet',
            'Csak ha belül semmi nem történik, jönnek szóba a külső '
                'szervek — de akkor is tárgyilagosan és bizonyítható '
                'tényekkel',
          ]),
          DoDontBlock(
            doTitle: 'Megengedett és kívánatos',
            dos: [
              'Elmondani, hogy egy túra rendszeresen nem teljesíthető',
              'Jelezni egy műszaki hibát a járművön — akár ismételten '
                  'is',
              'Elmondani egy konkrét esetet, amelyet magad éltél át',
              'Szabálysértést a belső bejelentőhelyen keresztül '
                  'jelenteni',
              'Utánakérdezni, ha egy bejelentésre nem történik semmi',
            ],
            dontTitle: 'Nem védett',
            donts: [
              'Olyan állításokat megfogalmazni, amelyekről tudod, hogy '
                  'nem igazak',
              'Vezetőket vagy kollégákat sértegetni vagy lealacsonyítani',
              'Belső számokat, szerződéseket vagy kimutatásokat '
                  'nyilvánosságra hozni',
              'Pletykákat chatcsoportokban továbbterjeszteni anélkül, '
                  'hogy ismernéd őket',
              'Konfliktusokat értékelőportálokon vagy közösségi '
                  'hálózatokon kihordani, mielőtt belül egyáltalán bárkit '
                  'megkérdeztek volna',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Példaeset és ellenőrzőlista',
        blocks: [
          RevealBlock(
            prompt: 'Példaeset: A sofőr-chatcsoportban valaki azt írja, '
                'hogy a cég szándékosan nem fizet ki órákat. Te ezt magad '
                'soha nem tapasztaltad, de éppen bosszankodsz a '
                'beosztásod miatt, és azt írod: „Így van, mindannyiunkat '
                'szisztematikusan átvernek." Másnap a csoportról készült '
                'képernyőkép kering körbe. Hogyan kell ezt megítélni?',
            answer: 'Kritikusan — nem a kritika, hanem a forma miatt. '
                'Tényállítást fogalmaztál meg („szisztematikusan '
                'átvernek"), amelyet magad nem tudsz bizonyítani, és nem '
                'is éltél át. A tudatosan valótlan tényállításokat a '
                'véleménynyilvánítás szabadsága nem fedi, és munkajogi '
                'következményeik lehetnek, egészen a § 626 BGB szerinti '
                'azonnali felmondásig; rossz hírbe hozásnál a § 186 StGB '
                'is belép. A képernyőkép ráadásul megmutatja, hogy egy '
                'zárt csoport nem védett tér. A helyes az lett volna: a '
                'saját esetedet megnevezni — „Nálam júliusban hiányzik '
                'két óra, jelentettem, és eddig nincs válasz" — és a '
                'diszpécsernek, az üzemvezetésnek vagy a belső '
                'bejelentőhelynek átadni. Ez az állítás igaz, '
                'ellenőrizhető, és a HinSchG védi. Az eredmény: ugyanaz '
                'az elégedetlenség, de helyesen kifejezve nem árthat '
                'neked.',
          ),
          ChecklistBlock(
            title: 'Mielőtt bármit kifelé viszek',
            items: [
              'Saját tapasztalatból tudom, hogy igaz',
              'Az esetet tárgyilagosan mondom el, sértegetés nélkül',
              'Nem adok ki belső számokat, szerződéseket vagy '
                  'kimutatásokat',
              'Először belül vetettem fel — diszpécser, üzemvezetés vagy '
                  'bejelentőhely',
              'Világos számomra: valódi visszásságot jelenteni védett, '
                  'kitaláltat állítani nem',
            ],
          ),
        ],
      ),
    ],
  ),
];
