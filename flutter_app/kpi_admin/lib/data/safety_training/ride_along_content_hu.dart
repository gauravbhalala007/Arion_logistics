// lib/data/safety_training/ride_along_content_hu.dart
//
// A Ride Along oktatás tartalma — magyar változat.
// A felépítés azonos a német alapváltozattal: ra1–ra5 fejezetek,
// ugyanazok a diák, ugyanazok a blokkok és ugyanazok az értékek.
//
// A „Ride Along" az új sofőrök kétnapos kísért fuvarja: az 1. napon
// kevesebb megállóval, a 2. napon lényegesen többel. A tréner közben
// végigmegy egy ellenőrzőlistán, minden pontot aláír, a végén pedig
// visszajelzést ad; a lapot fényképként adjátok le az illetékes
// diszpécsernél.
//
// Ennek az oktatásnak a célja: FELKÉSZÍTÉS. Aki előre végigmegy rajta,
// nem először hallja a két nap témáit, hanem célzottan tud kérdezni, és
// tudatosan tudja kihasználni a kísért fuvart.
//
// Több cégnél használható: SEMMILYEN személynév, állomásnév vagy
// cégspecifikus szám nem szerepel szabályként. A megállószámokat, a
// Waiting Area időit, a munkakezdést és a parkolási oldalt kifejezetten
// az adott állomás határozza meg — ezeket a tréner mondja meg. A cégen
// belüli eszközök, például a munkaidő-nyilvántartás, csak példaként
// szerepelnek („pl. Kenjo"). Konkrét maradhat: az Amazon eszközei
// (Flex, Mentor, ATLAS, Scorecard), a CoDriver alkalmazás, a § 4 ArbZG
// szerinti szünetszabályok és a § 1 Abs. 6 FPersV szerinti Green Book —
// mindhárom cégtől függetlenül érvényes. Ehhez a témához nincsenek
// illusztrációk, ezért `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> rideAlongContentHu = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ra1',
    title: 'Mi az a Ride Along',
    summary: 'Két nap kísért fuvar: a cél, a menete, kik vesznek részt '
        'benne és hogyan értékelnek',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Két nap egy tapasztalt sofőr mellett',
        blocks: [
          ParagraphBlock(
            'A Ride Along a betanulásod kísért fuvarja: két munkanap, '
            'amelyen egy tapasztalt sofőr trénerként veled tart. A túrát '
            'nem egy prezentációból ismered meg, hanem pontosan ott, '
            'ahol zajlik — az állomáson, a Loading Areán és az úton.',
          ),
          FactsBlock([
            FactItem('2 nap', 'kísért fuvar egy trénerrel'),
            FactItem('1. nap', 'kevesebb megálló — sok cégnél nagyjából '
                '20'),
            FactItem('2. nap', 'lényegesen több megálló — sok cégnél '
                'nagyjából 70'),
          ]),
          ParagraphBlock(
            'A két nap egymásra épül. Az első napon a hangsúly a '
            'folyamatokon van: hogyan jutsz be az állomásra, melyik '
            'alkalmazást mikor indítod, hogyan zajlik a rakodás, mikor '
            'van szünet. A második napon a mennyiség jelentősen nő, és '
            'te vezetsz és te kézbesítesz — a tréner kísér, de nem veszi '
            'át a munkát.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'A megállószámok irányértékek',
            text: 'Hogy az 1. és a 2. napra valójában hány megálló van '
                'betervezve, azt a céged, illetve az állomásod határozza '
                'meg. Elterjedt az első napon nagyjából 20 és a '
                'másodikon nagyjából 70 — kötelező érvényű azonban '
                'kizárólag az, amit a tréner vagy az illetékes '
                'diszpécser mond neked.',
          ),
          BulletsBlock([
            'Mindkét nap a saját fiókoddal zajlik, nem a trénerével',
            'A megállók valódi munkának számítanak, nem száraz '
                'gyakorlatnak',
            'A tréner elmagyarázza, megmutatja, utána pedig téged hagy '
                'dolgozni',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Röviden',
            text: 'A Ride Along a betanulásod éles üzemben. A végére '
                'képesnek kell lenned egyedül levinni egy túrát — ehhez '
                'a mércéhez igazodik minden.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kik vesznek részt benne és ki mit csinál',
        blocks: [
          ParagraphBlock(
            'A Ride Alongban három szerep vesz részt. Ha tudod, ki miért '
            'felel, nem a rossz embert kérdezed, és nem veszítesz időt.',
          ),
          TableBlock(
            headers: ['Szerep', 'Feladat'],
            rows: [
              [
                'Te',
                'Vezetsz, kézbesítesz, kérdezel, csinálod — mindkét nap '
                    'a saját fiókoddal',
              ],
              [
                'Tréner',
                'Tapasztalt sofőr: minden pontot elmagyaráz, megmutat, '
                    'figyel téged, kipipálja az ellenőrzőlistát és '
                    'aláírja',
              ],
              [
                'Diszpécser',
                'Beosztja a két napot, problémák esetén ő a '
                    'kapcsolattartó, és a végén ő kapja meg az '
                    'ellenőrzőlista fényképét',
              ],
            ],
          ),
          ParagraphBlock(
            'A tréner nem a főnököd, és nem is hatósági vizsgáztató. Ő '
            'az a kolléga, aki az állomást a legjobban ismeri. Pontosan '
            'ezért hozzá tartozik minden kérdés, ami a két nap alatt '
            'eszedbe jut — az is, amelyik jelentéktelennek tűnik.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'A kérdés nem kerül semmibe',
            text: 'Egy kérdés a Ride Alongon olcsó. Ugyanaz a kérdés a '
                'harmadik héten, egyedül a túrán, egy teli útvonallal '
                'magad előtt, drága.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Az ellenőrzőlista és a visszajelzés',
        blocks: [
          ParagraphBlock(
            'A tréner egy rögzített lapot dolgoz végig — ez a Ride '
            'Along ellenőrzőlista. Mindkét napra fel van rajta sorolva, '
            'mit kell elmagyarázni és megmutatni: a jármű-ellenőrzéstől '
            'a szünetszabályokon át a jelszavas csomagokig. Minden '
            'pontot aláírnak, minden napot dátummal és aláírással zárnak '
            'le.',
          ),
          BulletsBlock([
            'Az ellenőrzőlista a bizonyíték arra, hogy betanítottak',
            'Téged is véd: amit kipipáltak, azt elmagyarázták neked',
            'A második nap után a tréner visszajelzést ad a '
                'teljesítményedről és a vezetési képességeidről',
          ]),
          ParagraphBlock(
            'Ez nem bukós vizsga. Senki sem várja el, hogy az első napon '
            'úgy vidd le a túrát, mint egy háromévnyi tapasztalattal '
            'rendelkező sofőr. Értékelnek viszont: a tréner feljegyzi, '
            'hogyan dolgozol, és a lap eljut a céghez. Aki láthatóan '
            'gondolkodik, pontos és elfogadja a tanácsokat, jó '
            'visszajelzést kap — akkor is, ha lassú.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'A különbség, ami számít',
            text: 'Nem azt értékelik, hogy már mindent tudsz-e, hanem '
                'hogy tanulni akarsz-e, és komolyan veszed-e a '
                'szabályokat. A hiba természetes. Az viszont nem, ha egy '
                'hibát kétszer elmagyaráznak, és mégis figyelmen kívül '
                'hagyod.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: az első napon kétszer is elkevered a '
                'csomagok sorrendjét a görgős kocsin, és a megállóiddal '
                'a tervezettnél sokkal tovább tartasz. Biztos vagy '
                'benne, hogy ezzel a Ride Along elúszott. Így van?',
            answer: 'Nem. Pontosan ezért van az első nap. A tréner '
                'tempót jó, ha a második napon vár némileg, igazán pedig '
                'csak az azt követő hetekben. Az első napon mást '
                'értékel: rákérdezel-e, ha bizonytalan vagy? Harmadszorra '
                'is ugyanazt a hibát követed el? Utána magadtól '
                'rendezettebben pakolsz? Aki szóvá teszi a hibát, és a '
                'következő görgős kocsinál tudatosan másképp csinálja, '
                'jobb benyomást hagy, mint aki gyors, de semmit nem '
                'kérdőjelez meg.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista: 1. fejezet',
        blocks: [
          ChecklistBlock(
            title: 'Ezt viszem magammal az 1. fejezetből',
            items: [
              'A Ride Along két munkanap egy trénerrel',
              'Az 1. napon kevesebb megálló, a 2. napon lényegesen több '
                  '— a pontos számot a cégem adja meg (elterjedt a '
                  'nagyjából 20 és a nagyjából 70)',
              'Mindkét nap a saját fiókommal zajlik',
              'A tréner elmagyarázza, megmutatja, és engem hagy dolgozni',
              'Kipipál egy ellenőrzőlistát, és naponta aláírja',
              'A 2. nap után visszajelzést kapok a teljesítményemről és '
                  'a vezetési képességeimről',
              'Ez betanulás, de értékelik — a tanulási hajlandóság '
                  'többet számít a tempónál',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Egy mondat a két napra',
            text: '„Inkább kérdezek egyszer túl sokat, mint egyszer túl '
                'keveset — pontosan ezért van ez a két nap."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ra2',
    title: 'Az első nap',
    summary: 'Az első megállók, az alkalmazások indítása, ellenőrzés, '
        'Loading Area, szünetek és a járműkulcs',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Az első megállók a saját fiókoddal',
        blocks: [
          ParagraphBlock(
            'Az első napra megvan az a minimális megállószám, amelyet le '
            'kell vezetned és ki kell kézbesítened — a saját fiókoddal. '
            'Ez szándékosan alacsony (sok cégnél nagyjából 20); a rád '
            'vonatkozó kötelező számot a tréner mondja meg az '
            'állomásodra. Az 1. napon nem a mennyiség a lényeg, hanem '
            'hogy minden mozdulat egyszer jól üljön.',
          ),
          ParagraphBlock(
            'A saját fiók fontos. Nem a tréneré, nem egy közös '
            'hozzáférés. Minden, amit ezen a napon kézbesítesz, a te '
            'nevedben fut — pontosan úgy, ahogyan később is számít. Csak '
            'így látja a tréner és a cég, hogy valójában hogyan '
            'kézbesítesz.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Hozzáférés nélkül nincs Ride Along',
            text: 'Ha reggel nem működik a fiókod, azonnal szólj — még '
                'indulás előtt, nem az első megállónál. Egy tisztázatlan '
                'hozzáférés az egész napodba kerül.',
          ),
          SubheadBlock('A CoDriver alkalmazás'),
          ParagraphBlock(
            'A CoDriver a céged alkalmazása — ebben olvasol éppen most. '
            'Külön áll az Amazon eszközeitől: az Amazon a túrát '
            'irányítja, a CoDriver mindent, ami a cégen belüli munkáddal '
            'kapcsolatos. A tréner az első napon végigmegy rajta veled.',
          ),
          BulletsBlock([
            'Műszakterv és hullámterv: mikor dolgozol és melyik '
                'hullámban indulsz',
            'Távollétek és betegségek bejelentése',
            'DA Academy: oktatások, mint ez is, valamint az üzemi '
                'utasítások',
            'A cég üzenetei és értesítései',
            'Baleseti és kárbejelentések',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Jegyezd meg',
            text: 'Az Amazon alkalmazásai a túrát irányítják. A CoDriver '
                'a munkaviszonyodat. Mindkettőre naponta szükséged van, '
                'és mindkettőt érdemes az 1. napon egyszer végignézni.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Megérkezés: munkaidő, parkolási oldal, Waiting Area',
        blocks: [
          ParagraphBlock(
            'A nap nem az első megállóval kezdődik, hanem az állomásra '
            'érkezéssel. Három dolgot köt a tréner különösen a lelkedre '
            'az első napon, mert ezek minden egyes munkanapon '
            'megismétlődnek.',
          ),
          SubheadBlock('1 — Munkaidő'),
          ParagraphBlock(
            'A műszakodnak fix kezdete van. Ott áll a CoDriver '
            'műszaktervében, és a „kezdés" azt jelenti: ekkor már '
            'bevethető állapotban vagy az állomáson — nem úton oda. Az '
            'állomásod konkrét időpontjait a tréner mondja meg, ezek '
            'telephelyenként és hullámonként eltérnek.',
          ),
          SubheadBlock('2 — Parkolási oldal'),
          ParagraphBlock(
            'Minden állomáson van szabály arra, hol állhatnak a '
            'magánjárművek, és melyik oldalon sorakoznak fel a '
            'furgonok. Ez nem kekeckedés: az udvaron egyszerre sok jármű '
            'manőverezik, gyakran hátramenetben és rossz kilátással. Aki '
            'rosszul parkol, elzár egy közlekedősávot, vagy egy tolató '
            'holtterébe kerül. A rád vonatkozó oldalt a tréner mutatja '
            'meg.',
          ),
          SubheadBlock('3 — Waiting Area-időpontok'),
          ParagraphBlock(
            'A Waiting Area az a terület, ahol addig vársz, amíg a '
            'görgős kocsidat vagy a rakodóhelyedet szólítják. Erre '
            'hullámonként fix időablakok vannak. Aki túl korán áll oda, '
            'eltorlaszolja a területet; aki elkésik, lemarad a '
            'szólításról, és az egész hullámot hátratolja. Az állomásod '
            'pontos időpontjait a tréner mondja meg az első napon — írd '
            'fel őket.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'A három adat, amit érdemes felírnod',
            text: 'Műszakkezdés, parkolási oldal és a saját Waiting '
                'Area-időablakod. Erre a háromra a másnaptól kezdve '
                'minden reggel szükséged lesz — és utána már senki nem '
                'kérdez rá.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: pontosan a műszakkezdésre ott vagy a '
                'kapuban, de utána tíz percig keresel parkolóhelyet, '
                'mert rossz oldalon kerested. Így a Waiting Areába már '
                'elkéstél. Mekkora baj ez?',
            answer: 'Nagyobb, mint amilyennek látszik. A Waiting Areában '
                'a szólítás ütemezve van: ha lemaradsz az ablakodról, a '
                'hullámod többi sofőrje mögé csúszol. A görgős kocsid '
                'vár, a járműved eközben esetleg elfoglal egy helyet, és '
                'az indulásod többet csúszik, mint az a tíz perc, amit '
                'vesztettél. Ezért tartozik össze a parkolási oldal és a '
                'Waiting Area-időpont: a „pontosan a kapuban" nem '
                'ugyanaz, mint a „pontosan a Waiting Areában". Számold '
                'bele a parkolás és a gyaloglás idejét is.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A start: munkaidő-nyilvántartás, Mentor és Flex',
        blocks: [
          ParagraphBlock(
            'Három rendszernek kell futnia a műszak elején — méghozzá '
            'időben és ebben a sorrendben. Mindegyiknek más a célja, és '
            'mindegyik bosszúságot okoz, ha túl későn indul el.',
          ),
          StepsBlock([
            'A céged munkaidő-nyilvántartása (pl. Kenjo) — bejelentkezés '
                'a műszak kezdetén. Amit itt nem indítasz el, az nem '
                'fizetett munkaidő, és később hiányozni fog az '
                'elszámolásodból. Hogy a céged melyik rendszert '
                'használja, azt a tréner mutatja meg.',
            'Mentor — az Amazon vezetési stílust figyelő alkalmazása: '
                'már indulás előtt futnia kell. Rögzíti, hogyan vezetsz, '
                'és ez adja a pontszámod alapját.',
            'Flex — az Amazon kézbesítő alkalmazása: itt kapod meg az '
                'útvonaladat, itt szkenneled a csomagokat, és itt '
                'dokumentálsz minden kézbesítést.',
          ]),
          SubheadBlock('A Mentor 4 órája'),
          ParagraphBlock(
            'A Mentor nem fut korlátlanul: az alkalmazás egyhuzamban '
            'nagyjából négy órát rögzít. Utána újra kell indítanod, '
            'különben a túrád többi része rögzítetlen marad. Pontosan ez '
            'a leggyakoribb kezdő hiba — az alkalmazást reggel helyesen '
            'elindították, de az ebédszünet után nem kapcsolták be újra. '
            'A tréner az első napon megmutatja, miről ismered fel, hogy '
            'a Mentor még fut.',
          ),
          FactsBlock([
            FactItem('4 óra', 'a Mentor rögzítési ideje egyhuzamban'),
            FactItem('indulás előtt', 'indítsd el a Mentort — ne csak '
                'útközben'),
            FactItem('szünet után', 'ellenőrizd és indítsd újra a '
                'Mentort'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'A leggyakoribb hiba az első napon',
            text: 'A Flex fut, a Mentor nem. Így ugyan levezeted az '
                'útvonaladat, de a vezetési stílusod nem kerül '
                'rögzítésre — és a hiányzó Mentor-idő a cégnél éppúgy '
                'feltűnik, mint egy rossz érték.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: 14 órakor veszed észre, hogy a '
                'Mentor a szünet óta nem fut. Mit teszel — végigmész a '
                'műszakon, és holnap jobban csinálod, vagy azonnal '
                'reagálsz?',
            answer: 'Azonnal reagálsz: a következő biztonságos helyen '
                'megállsz, újraindítod a Mentort, és mész tovább. A '
                'kézenfekvő tévedés az, hogy egy fél nap rögzítés nélkül '
                'nem számít, hiszen rendesen vezettél. Pedig számít: a '
                'cég számára egy hiány úgy néz ki, mint egy hiány — nem '
                'úgy, mint a jó vezetés. A továbbhaladás pedig azt '
                'jelenti, hogy a hiány óráról órára nő. Jelezd '
                'ráadásként a trénerednek vagy az illetékes '
                'diszpécserednek is, hogy a hiány megmagyarázható '
                'legyen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Jármű-ellenőrzés és Loading Area',
        blocks: [
          SubheadBlock('A jármű-ellenőrzés'),
          ParagraphBlock(
            'Indulás előtt ellenőrzik a járművet — és a túra után még '
            'egyszer. Az ellenőrzés dokumentált szemrevételezés: '
            'körbejárod a furgont, megnézed minden oldalát, kipróbálod a '
            'funkciókat, és rögzíted, amit látsz.',
          ),
          BulletsBlock([
            'Körbejárás kívül: karosszéria, lökhárítók, tükrök, ablakok '
                '— minden horpadás és minden karcolás',
            'Gumik: profil, látható sérülések, a nyomás benyomása',
            'Világítás: tompított fény, féklámpa, index, tolatólámpa',
            'Utastér és raktér: tisztaság, laza tárgyak, válaszfal',
            'Felszerelés: elakadásjelző háromszög, láthatósági mellény, '
                'elsősegélydoboz',
            'Kilométeróra-állás és üzemanyag-, illetve töltöttségi szint',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Miért az indulás ELŐTTI ellenőrzés számít',
            text: 'Egy kár, amit előre dokumentálsz, korábbi kár. '
                'Ugyanaz a kár, amit nem dokumentálsz, estére a te '
                'károd. Az a két perc körbejárás a munkanapod '
                'legolcsóbb biztosítása.',
          ),
          SubheadBlock('A görgős kocsi berakodása a Loading Areán'),
          ParagraphBlock(
            'A Loading Areán ott áll a görgős kocsid az útvonalad '
            'csomagjaival. Az, ahogyan bepakolod a furgonba, eldönti az '
            'egész napodat: aki rendezetlenül rakodik, minden megállónál '
            'keresgél — és ez egy teli túrán órákra összeadódik.',
          ),
          BulletsBlock([
            'Az útvonal sorrendjében rakodj: ami elsőként megy ki, az '
                'kerül be utoljára, és elöl van',
            'Nehéz csomagok alulra, könnyűek felülre — nem fordítva',
            'Rögzítsd a rakományt: fékezésnél semmi nem csúszhat előre',
            'Semmit ne pakolj a közlekedőbe vagy a tolóajtó elé',
            'A különleges csomagokat (jelszavas, ATLAS, terjedelmes) '
                'külön és kézre esően tedd',
            'Az üres görgős kocsit oda tedd vissza, ahová való — ne csak '
                'valahová',
          ]),
          DoDontBlock(
            doTitle: 'Így csinálod jól',
            dos: [
              'Rakodás közben már gondolj arra, melyik lesz az első '
                  'megálló',
              'Emelésnél guggolj le, a terhet tartsd közel a testedhez',
              'Kérdezz, ha nem tudod, hová tartozik egy csomag',
            ],
            dontTitle: 'Ez később az idődbe kerül',
            donts: [
              'Mindent behajigálni és „útközben rendezni"',
              'A csomagokat a válaszfalra vagy a vezetőtérbe tenni',
              'A görgős kocsit a közlekedősáv közepén hagyni',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Szünetek, kulcs és automatikus zárás',
        blocks: [
          SubheadBlock('Szünetek: 30 és 45 perc'),
          ParagraphBlock(
            'Két szünethossz létezik, és hogy rád melyik vonatkozik, az '
            'kizárólag az aznapi munkaidődtől függ. A Waiting '
            'Area-időpontokkal vagy a megállószámokkal ellentétben ez '
            'nem az állomásod előírása, hanem törvény: § 4 '
            'Arbeitszeitgesetz (ArbZG — a német munkaidőtörvény). A '
            'szabály tehát minden cégnél ugyanúgy érvényes, és nem '
            'alku tárgya.',
          ),
          FactsBlock([
            FactItem('30 perc', '6 óránál több és legfeljebb 9 óra '
                'munkaidő esetén'),
            FactItem('45 perc', '9 óránál több munkaidő esetén'),
            FactItem('15 perc', 'a legkisebb beszámítható részszünet'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 4 ArbZG — a jogalap',
            text: 'A német munkaidőtörvény 6 óránál hosszabb munkaidő '
                'esetén legalább 30 perc, 9 óránál hosszabb esetén '
                'legalább 45 perc pihenőszünetet ír elő. Hat óránál '
                'hosszabb ideig szünet nélkül dolgozni kifejezetten '
                'tilos.',
          ),
          ParagraphBlock(
            'A szünet felosztható, de minden résznek legalább 15 percig '
            'kell tartania — kétszer 15 perc adja ki tehát a 30 perces, '
            'háromszor 15 perc a 45 perces szünetet. Az öt perc '
            'közbeiktatva nem számít. Fontos továbbá: a szünetnek hat '
            'óra munka letelte előtt el kell kezdődnie, nem csak a '
            'műszak végén.',
          ),
          ParagraphBlock(
            'Miért kell rögzíteni: a szüneted nem fizetett munkaidő, és '
            'a cégnek igazolnia kell tudni, hogy valóban kivetted. Ezért '
            'kerül be a munkaidő-nyilvántartásba — nem bizalmatlanságból, '
            'hanem mert egy nem dokumentált szünet egy ellenőrzésnél ki '
            'nem vett szünetnek számít. Ez szabálysértés, amelyért a cég '
            'felel. A tréner megmutatja, pontosan hová kell beírnod.',
          ),
          SubheadBlock('Automatikus zárás és a kulcs'),
          ParagraphBlock(
            'Sok Sprinter automatikusan zár: ha az ajtó becsapódik vagy '
            'a jármű elindul, a központi zár magától bezárja. Ez '
            'lopásvédelem a rakományodnak — és pontosan ez az oka annak, '
            'hogy a kulcs mindig nálad marad.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'A kulcs a testeden a helye',
            text: 'Nem az ülésen, nem a tárolóban, nem a járműben '
                'hagyott kabát zsebében. A kulcs a nadrágzsebedbe vagy '
                'az övedre akasztott szalagra való — minden alkalommal, '
                'amikor kiszállsz.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: rövid időre megállsz, a kulcsot a '
                'gyújtásban hagyod, kiveszel két csomagot, és a lábaddal '
                'becsukod a tolóajtót. A központi zár bezár. Mi történik '
                'most?',
            answer: 'Két csomaggal állsz egy bezárt furgon előtt, '
                'amelyben ott a kulcsod, a telefonod, a maradék rakomány '
                'és többnyire az irataid is. A nap ezzel elúszott: '
                'segítségre van szükséged az állomásról vagy egy '
                'zárszerelőtől, az egész útvonalad áll, a járműben lévő '
                'csomagok pedig ma már nem jutnak el a vevőikhez. A '
                'kézenfekvő tévedés a „hiszen csak tíz másodpercre '
                'megyek el" — az automatikus zár nem tesz különbséget '
                'tíz másodperc és tíz perc között. Ezért kivétel nélkül '
                'érvényes: kulcs ki, kulcs a testre, és csak utána '
                'szállj ki.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A túra vége: a Flex lezárása és az ellenőrzés',
        blocks: [
          ParagraphBlock(
            'A nap nem az utolsó megállónál ér véget, hanem az '
            'állomáson. Két dolog szerepel ott a tréner '
            'ellenőrzőlistáján — és mindkettőt szívesen elfelejtik, mert '
            'az ember fáradt és haza akar menni.',
          ),
          StepsBlock([
            'Zárd le rendesen a Flex alkalmazást: fejezd be az '
                'útvonalat, add le a visszárukat, és lépj ki az '
                'alkalmazásból — ne csak zsebre vágd a telefont.',
            'Jármű-ellenőrzés a túra után: ugyanaz a körbejárás, mint '
                'reggel, most az új sérülésekre, a kilométeróra-állásra '
                'és az üzemanyag-, illetve töltöttségi szintre '
                'figyelve.',
            'A járművet tisztán és üresen add át, ellenőrizd a rakteret '
                '— egy csomag sem maradhat bent.',
            'Jelentkezz ki a céged munkaidő-nyilvántartásában (pl. '
                'Kenjo), és a kulcsot ott add le, ahová való.',
          ]),
          ParagraphBlock(
            'A záró ellenőrzés a reggeli ellenőrzés párja. Csak a kettő '
            'együtt mutatja meg, mi történt aznap a járművel — és mi '
            'nem. Ha az esti elmarad, egy másnap reggel talált sérülést '
            'már senkihez nem lehet kötni, és a következő sofőr örökli a '
            'te problémádat, vagy te az övét.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Emlékeztető a műszak végére',
            text: 'Flex lezárva, körbejárás a jármű körül, üres raktér, '
                'kijelentkezve, kulcs leadva. Csak ezután van vége a '
                'napnak.',
          ),
          ChecklistBlock(
            title: 'Ezt viszem magammal az 1. napból',
            items: [
              'A cégem által előírt számú megálló a saját fiókommal',
              'Ismerem a CoDriver alkalmazást, és tudom, mit találok '
                  'benne',
              'Ismerem a műszakkezdésemet, az állomásom parkolási '
                  'szabályát és a Waiting Area-időablakomat',
              'Időben és ebben a sorrendben indítom a '
                  'munkaidő-nyilvántartást (pl. Kenjo), a Mentort és a '
                  'Flexet',
              'Tudom, hogy a Mentor nagyjából 4 órát rögzít, és utána '
                  'újra kell indítani',
              'Elvégzem a jármű-ellenőrzést a túra előtt és után',
              'A görgős kocsit az útvonal sorrendjében rakodom, a '
                  'nehezet alulra, a rakományt rögzítve',
              'Ismerem a § 4 ArbZG szerinti szünetszabályt: 30 perc 6 '
                  'óránál több, 45 perc 9 óránál több munkaidőtől — és '
                  'be is írom',
              'A kulcs mindig a testemen marad, mert a Sprinter '
                  'automatikusan zár',
              'A végén lezárom a Flexet, elvégzem az ellenőrzést és '
                  'kijelentkezem',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ra3',
    title: 'A második nap',
    summary: 'Lényegesen több megálló önállóan, Scorecard, a jármű '
        'védelme, Green Book, különleges csomagok, tankolás és töltés',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Lényegesen több megálló — te vezetsz, te kézbesítesz',
        blocks: [
          ParagraphBlock(
            'A második napon megfordul az arány. A megállószám '
            'jelentősen nő — sok cégnél nagyjából 70-re, kötelező '
            'érvényű az állomásod előírása —, és a megállókat önállóan '
            'végzed: te vezetsz, te navigálsz, te szkennelsz, te '
            'kézbesítesz, te dokumentálsz. A tréner melletted ül, és '
            'csak akkor avatkozik be, ha szükséges.',
          ),
          FactsBlock([
            FactItem('több', 'megálló, mint az 1. napon — a számot a cég '
                'írja elő'),
            FactItem('magad', 'vezetsz és kézbesítesz — a tréner csak '
                'kísér'),
            FactItem('1 nap', 'az első saját túráig'),
          ]),
          ParagraphBlock(
            'Ez a második nap tulajdonképpeni értelme: egyszer át kell '
            'élned, milyen érzés egy teli túra — a tempóval, a közbeni '
            'rendezgetéssel, a vevőkkel, akik nem nyitnak ajtót, és '
            'azzal az érzéssel, hogy ketyeg az óra. Ha ezt egyszer '
            'megcsináltad valakivel magad mellett, az első egyedüli út '
            'már csak feleakkora falat.',
          ),
          BulletsBlock([
            'Ne vetesd el magadtól, amit magad is meg tudsz csinálni — '
                'akkor sem, ha lassabban megy',
            'Minden megállóról, ami furcsa volt, kérdezz azonnal',
            'Jegyezd meg, mit kell felírnod: kódokat, folyamatokat, '
                'kapcsolattartókat',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'A 2. nap mércéje',
            text: 'Nem az, hogy „rekordidő alatt viszi-e le a túrát", '
                'hanem hogy „el lehetne-e küldeni holnap egyedül". '
                'Pontosan ezt méri fel a tréner.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Scorecard, minőség és teljesítmény',
        blocks: [
          ParagraphBlock(
            'A munkádat mérik. Az Amazon Scorecardja hétről hétre '
            'összefoglalja, hogyan teljesítettél te és a céged. A '
            'második napon a tréner elmagyarázza, milyen értékek '
            'szerepelnek benne, és hogyan tudod befolyásolni őket — mert '
            'szinte minden érték valamiből származik, ami a te kezedben '
            'van.',
          ),
          BulletsBlock([
            'Kézbesítési minőség: a megfelelő helyen adtad át vagy '
                'tetted le a csomagot, és tisztán dokumentáltad?',
            'Vezetési stílus a Mentorból: fékezés, gyorsítás, kanyarok, '
                'telefonhasználat, bekötés',
            'Megbízhatóság: pontos indulás, teljesen levezetett útvonal, '
                'szabályos visszaadás',
            'Vevői visszajelzések: a panaszok és a dicséretek is '
                'bekerülnek az értékelésbe',
          ]),
          ParagraphBlock(
            'A minőség és a teljesítmény két különböző dolog, amelyeket '
            'gyakran összekevernek. A teljesítmény a mennyiség: hány '
            'megálló mennyi idő alatt. A minőség az, hogy mennyire '
            'tisztán zártál le minden egyes megállót. Az a sofőr, aki '
            'nagy teljesítményt nyújt rossz minőséggel, több munkát okoz, '
            'mint amennyit megspórol — minden reklamáció a cégnek a '
            'megspórolt perc sokszorosába kerül.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'A legdrágább hiba a gyors hiba',
            text: 'Egy rossz helyre tett csomag és a gyors továbbhajtás '
                'neked egy percet spórol, a cégnek pedig egy '
                'reklamációba, egy utánajárásba és adott esetben az áru '
                'értékébe kerül.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: a vevő nem nyit ajtót, neked pedig '
                'még 30 megállód van hátra. A csomagot a kuka mögé '
                'teszed, és gyorsan lefényképezed a bejárati ajtót. '
                'Miért probléma ez?',
            answer: 'Rögtön kétszeresen is. Először: a lerakás helye nem '
                'egyezik azzal, amit dokumentáltál — ha a vevő nem '
                'találja meg a csomagot, a kézbesítésed igazolatlanul '
                'áll. Másodszor: a kuka mögötti lerakás nem alkalmas '
                'hely: az utcáról belátható, és a kukát ürítik. Helyesen '
                'az előírt utat kell járni — szomszéd, biztonságos '
                'lerakási hely a vevő engedélyével vagy visszaszállítás '
                '—, és pontosan azt dokumentálni, amit valóban tettél. '
                'Az az egy megspórolt perc egy reklamációval áll szemben, '
                'amely neked, a vevőnek és a cégnek is jóval többe '
                'kerül.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A jármű védelme, balesetek, tisztítás és ápolás',
        blocks: [
          ParagraphBlock(
            'A furgon a munkahelyed és a legdrágább eszköz, amelyet a '
            'cég rád bíz. Hogy hogyan bánsz vele, az a második napon '
            'külön pont az ellenőrzőlistán — három részben.',
          ),
          SubheadBlock('1 — A károk elkerülése'),
          BulletsBlock([
            'Hátramenet csak akkor, ha másképp nem megy — és akkor '
                'lassan, mindkét tükröt figyelve',
            'Ha a helyzet nem egyértelmű, szállj ki és nézd meg, ahelyett '
                'hogy találgatnál',
            'A szűk behajtók, az alacsony ágak, a mélygarázsok és az '
                'oszlopok a leggyakoribb károkozók',
            'Tarts távolságot és fékezz előrelátóan — ez egyszerre kíméli '
                'a járművet és a Scorecardot',
          ]),
          SubheadBlock('2 — Ha mégis történik valami'),
          StepsBlock([
            'Állj meg, biztosítsd a helyszínt: vészvillogó, láthatósági '
                'mellény, elakadásjelző háromszög.',
            'Lásd el a sérülteket, személyi sérülés esetén mindig hívd a '
                '112-t.',
            'Ne változtass semmin, készíts fényképeket: az egész '
                'helyzetről, a sérülésekről, a rendszámokról, a '
                'környezetről.',
            'Idegen jármű vagy tisztázatlan felelősség esetén hívd a '
                'rendőrséget — kis sérülésnél is.',
            'Azonnal értesítsd az illetékes diszpécseredet, és jelentsd '
                'az esetet a CoDriverben.',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Soha ne hajts tovább',
            text: 'Egy idegen járművön ejtett kis karcolás is '
                'cserbenhagyás, ha nem jelented — ez bűncselekmény. Egy '
                'cetli az ablaktörlő alatt jogilag nem elegendő.',
          ),
          SubheadBlock('3 — Tisztítás és ápolás'),
          BulletsBlock([
            'A vezetőfülkét naponta pakold ki: se szemét, se palack, se '
                'papír',
            'Söpörd ki a rakteret, és ellenőrizd, nem maradt-e ott csomag',
            'Tartsd tisztán az ablakokat és a tükröket — a rossz kilátás '
                'biztonsági probléma, nem szépséghiba',
            'Az üzemanyagokat, folyadékszinteket és a feltűnő zajokat '
                'jelentsd, ne hagyd figyelmen kívül',
          ]),
          RevealBlock(
            prompt: 'Esettanulmány: manőverezés közben nekiérsz egy '
                'oszlopnak. A járművön egy karcolás keletkezik, más '
                'semmi, és senki nem látta. Bejelented?',
            answer: 'Igen, mindig és még aznap. Nem a bűnösségről van '
                'szó, hanem a hozzárendelésről: egy bejelentett karcolás '
                'olyan eset, amelyet feldolgoznak. Ugyanaz a karcolás, '
                'amelyet másnap reggel egy másik sofőr talál meg az '
                'ellenőrzésénél, tisztázatlan kár — és ez mindenkinek '
                'kellemetlen lesz, neked is, mert a gyanú a végén mégis '
                'az utolsó használóra terelődik. A kézenfekvő tévedés a '
                '„ez úgysem tűnik fel". Fel fog tűnni a következő '
                'ellenőrzésnél, pontosan ezért van.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Green Book / menetellenőrző könyv',
        blocks: [
          ParagraphBlock(
            'A Green Book a menetellenőrző könyved: a § 1 Abs. 6 '
            'Fahrpersonalverordnung (FPersV — a német járművezetői '
            'személyzetről szóló rendelet) szerinti napi ellenőrzőlapok, '
            'amelyekkel igazolod a vezetési idődet, a vezetési '
            'megszakításokat és a pihenőidődet. Ez sem az állomásod '
            'szabálya, hanem hatályos jog — minden cégnél ugyanúgy '
            'érvényes. Kifejezetten nem jármű-ellenőrzés: a Green '
            'Bookban kizárólag időkről van szó, a te időidről.',
          ),
          BulletsBlock([
            'Munkanaponként egy lap, kézzel vezetve és aláírva',
            'Bejegyzendő a menet kezdete és vége, a kilométeróra-állások, '
                'a vezetési idők, a megszakítások és a pihenőidők',
            'Azonnal töltsd ki, ne este rekonstruáld emlékezetből',
            'Az elmúlt napok feljegyzéseit magaddal viszed, és '
                'ellenőrzéskor be kell mutatnod',
          ]),
          ParagraphBlock(
            'A tréner a második napon megmutatja, hol van a lap, hogyan '
            'kell kitölteni, és hová kell leadni a kész lapokat. Minden '
            'további nem itt szerepel: a DA Academyben van erre külön '
            '„Green Book" oktatás — a kötelező adatokkal, a vezetési és '
            'pihenőidőkkel, a magánál tartási kötelezettséggel és a '
            'szabálysértések következményeivel. Dolgozd végig, ahelyett '
            'hogy a részleteket a második napon a járműben próbálnád '
            'megjegyezni.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Maga a feljegyzés a kötelezettség',
            text: 'Hogy betartottad-e az időket, azt egy ellenőrzésnél '
                'senki nem tudja megállapítani, ha nincs semmi. Egy '
                'hiányzó lap ezért ugyanúgy szabálysértés, mint egy '
                'túllépett vezetési idő.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Különleges esetek: jelszavas és ATLAS-csomagok',
        blocks: [
          SubheadBlock('Jelszavas csomagok'),
          ParagraphBlock(
            'Bizonyos küldeményeket csak olyan jelszó vagy kód ellenében '
            'szabad átadni, amelyet a vevő előre megkapott. Jellemzően '
            'nagy értékű áruról és mindenről szó van, ami különösen '
            'lopásveszélyes. A Flex a megállónál figyelmeztet erre.',
          ),
          BulletsBlock([
            'A vevő mondja vagy mutatja meg a kódot — te nem olvasod fel '
                'és nem mondod ki elsőként',
            'Helyes kód nélkül nincs átadás: nincs kivétel, a szomszédnál '
                'sem',
            'Nincs ajtó előtti lerakás és nincs lépcsőházban hagyás',
            'Ha a kód nem stimmel, a küldeményt az előírt úton '
                'visszaszállítod és dokumentálod',
          ]),
          SubheadBlock('ATLAS-csomagok'),
          ParagraphBlock(
            'Az ATLAS-küldemények szintén különleges kezelésű csomagok: '
            'saját folyamatot követnek, további lépésekkel a szkennelési '
            'és átadási menetben. Számodra az a fontos, hogy felismerd '
            'őket, külön és kézre esően tárold őket, és ne rövidítsd le '
            'az előírt folyamatot. Hogy az állomásodon konkrétan hogyan '
            'néz ki a folyamat, és milyen lépéseket ír elő közben a '
            'Flex, azt a tréner a második napon egy valódi csomagon '
            'mutatja meg.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'A különleges csomagokat rakodd be elsőként',
            text: 'Egyik csomagfajtát sem akarod a megállónál 90 másik '
                'küldemény között keresni. Rakodáskor tudatosan tedd '
                'őket külön, és jegyezd meg a helyüket.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: a vevő ott van, de nincs kéznél a '
                'jelszava — „ez csak formaság, bármit aláírok Önnek". '
                'Mit teszel?',
            answer: 'Nem adod át. A jelszó annak a bizonyítéka, hogy az '
                'átvevő valóban az átvevő — pontosan ezért adták ki. Egy '
                'aláírás, egy igazolvány, amelyet nem is ellenőrizhetsz, '
                'vagy a rábeszélés nem pótolja. A kézenfekvő tévedés az, '
                'ha a kedvességet a folyamat elé helyezed: ha a '
                'küldeményt később meg nem érkezettként jelentik, a kód '
                'nélküli átadás a te neveden szerepel hibaként. Kérd meg '
                'a vevőt, hogy nézze meg a kódot a rendelési '
                'visszaigazolásában. Ha nem találja, a csomagot '
                'visszaviszed és szabályosan dokumentálod.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tankolás, töltés és a túra vége',
        blocks: [
          SubheadBlock('Tankolás'),
          ParagraphBlock(
            'A furgont a cég szabályai szerint tankolják: a kijelölt '
            'kutaknál, a jármű üzemanyagkártyájával és a megfelelő '
            'üzemanyaggal. A bizonylat a járműhöz tartozik, vagy ott kell '
            'leadni, ahol a tréner megmutatja. Hogy mikor tankolsz, egy '
            'egyszerű szabályon múlik: ne csak akkor, amikor kigyullad a '
            'tartalékjelző, hanem úgy, hogy a következő sofőrnek ne '
            'kelljen szinte üres tankkal indulnia.',
          ),
          BulletsBlock([
            'A megfelelő üzemanyagfajta — egy téves tankolás napokra '
                'kiüti a járművet',
            'Az üzemanyagkártya a járműhöz tartozik, nem a magántáskádba',
            'A bizonylatot őrizd meg, és az előírás szerint add le',
            'Motor leállítva, tilos a dohányzás, a telefon el a kútnál',
          ]),
          SubheadBlock('Elektromos töltés'),
          ParagraphBlock(
            'Elektromos jármű esetén a töltés lép a tankolás helyébe — '
            'egy fontos különbséggel: a töltés tovább tart, ezért '
            'tervezni kell. A tréner megmutatja, hol töltötök, melyik '
            'kábel tartozik a járműhöz, és milyen töltöttségi szinten '
            'kell lennie a járműnek a műszak végén.',
          ),
          BulletsBlock([
            'Tartsd szemmel a töltöttséget és tervezz időben, ne csak a '
                'maradék hatótávnál reagálj',
            'Csatlakoztatás után ellenőrizd, hogy a töltés valóban '
                'elindult-e',
            'A kábelt tekerd fel rendesen, és ne hagyj magad után '
                'botlásveszélyt',
            'A műszak végén úgy add át a járművet, ahogyan a cég előírja '
                '— a következő sofőr ezzel indul',
          ]),
          SubheadBlock('A túra vége — mint az 1. napon'),
          StepsBlock([
            'Zárd le rendesen a Flex alkalmazást, fejezd be az '
                'útvonalat, add le a visszárukat.',
            'Jármű-ellenőrzés a túra után: körbejárás, új sérülések, '
                'kilométeróra-állás, üzemanyag- vagy töltöttségi szint.',
            'A raktér üres és tiszta, a vezetőfülke rendben.',
            'Kijelentkezés, kulcs leadása, a Green Book kiegészítése.',
          ]),
          ChecklistBlock(
            title: 'Ezt viszem magammal a 2. napból',
            items: [
              'A cégem által előírt, lényegesen magasabb megállószám — '
                  'amelyet magam vezetek le és kézbesítek',
              'Tudom, mi szerepel a Scorecardban, és hogyan '
                  'befolyásolom',
              'A minőség nem ugyanaz, mint a teljesítmény — mindkettő '
                  'számít',
              'Aktívan kerülöm a károkat, és minden esetet azonnal '
                  'jelentek',
              'A járművet kívül-belül tisztán tartom',
              'Ismerem a § 1 Abs. 6 FPersV szerinti Green Bookot, és '
                  'elvégzem hozzá a külön oktatást a DA Academyben',
              'A jelszavas csomagokat csak a helyes kód ellenében adom '
                  'ki',
              'Az ATLAS-csomagokat felismerem, és követem az előírt '
                  'folyamatot',
              'Ismerem a tankolás és az elektromos töltés szabályait',
              'A végén: Flex lezárása, ellenőrzés, kijelentkezés',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ra4',
    title: 'Lezárás és leadás',
    summary: 'A tréner visszajelzése, naponkénti aláírások és a lap '
        'leadása fényképként',
    asset: '',
    slides: [
      SafetySlide(
        title: 'A tréner visszajelzése',
        blocks: [
          ParagraphBlock(
            'A második nap után a tréner leül veled, és visszajelzést ad '
            'a teljesítményedről és a vezetési képességeidről. Ez nem '
            'kétszavas ítélet, hanem értékelés: mi megy már jól, min '
            'kell dolgoznod, mire kell a következő hetekben különösen '
            'figyelned.',
          ),
          BulletsBlock([
            'Vezetés: nyugalom, előrelátás, tolatás, a szűk helyek '
                'kezelése',
            'Kézbesítés: gondosság, dokumentálás, a vevőkkel való bánás',
            'Szervezés: rendezés, időérzék, az alkalmazások kezelése',
            'Munkához való hozzáállás: pontosság, kérdezés, a tanácsok '
                'fogadása',
          ]),
          ParagraphBlock(
            'Vedd komolyan a visszajelzést, de ne vedd magadra. Ez az '
            'egyetlen alkalom, amikor valaki két teljes napon át '
            'figyelt téged. Kérdezz rá, ha egy pont nem világos, és '
            'kérdezz konkrétan: a „Mit csináljak pontosan másképp '
            'tolatásnál?" többet ér egy bólintásnál.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Az egy kérdés a végén',
            text: 'Kérdezd meg a végén a trénered: „Mi az az egy dolog, '
                'amire az első egyedüli hetemen különösen figyelnem '
                'kell?" A válasz a két nap legértékesebb hozadéka.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: a visszajelzésben az áll, hogy túl '
                'tétova vagy manőverezésnél, és ezzel időt veszítesz. Te '
                'úgy érzed, egyszerűen csak óvatos voltál. Hogyan kezeled '
                'ezt?',
            answer: 'Kérdezz, ne védekezz. Az óvatosság manőverezésnél '
                'helyes — a tréner a „tétova" alatt rendszerint mást ért: '
                'azt, hogy sokáig gondolkodsz ahelyett, hogy kiszállnál '
                'és gyorsan megnéznéd, vagy hogy többször nekifutsz ott, '
                'ahol egyetlen tolatás mindkét tükör figyelésével elég '
                'lett volna. Kérj konkrét példát az aznapról. Akkor lesz '
                'egy pontod, amin valóban tudsz dolgozni, egy olyan '
                'értékelés helyett, amelyet csak lebólintasz vagy '
                'elhárítasz.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A lap: dátum, nevek, aláírások',
        blocks: [
          ParagraphBlock(
            'A Ride Along ellenőrzőlista csak akkor teljes, ha a '
            'fejadatok stimmelnek. Nélkülük a lap csak egy pipákkal '
            'teli papír, amelyet semmilyen igazoláshoz nem lehet '
            'kötni.',
          ),
          TableBlock(
            headers: ['Adat', 'Mit jelent'],
            rows: [
              ['Dátum', 'A két nap mindegyikére külön beírva'],
              ['A tanuló neve', 'A te neved — az új sofőré'],
              ['Az oktató neve', 'A trénered neve'],
              [
                'Aláírás',
                'A trénertől, naponta külön — nem egyszer mindkét napra',
              ],
            ],
          ),
          ParagraphBlock(
            'Annak, hogy naponta írnak alá, oka van: minden napnak '
            'megvan a saját pontlistája. Ha a második nap elmarad vagy '
            'áthelyezik, akkor is tisztán dokumentált, mi készült el az '
            'első napon. Ezért minden nap végén magad is ellenőrizd, be '
            'van-e írva a dátum és az aláírás.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Nézz rá magad is',
            text: 'A lap a betanulásod igazolása. Ha hiányzik egy '
                'aláírás, hiányzik az igazolás — utólag pedig az ilyesmi '
                'mindig körülményes. Egy pillantás a műszak vége előtt '
                'elég.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Leadás: fénykép a diszpécsernek',
        blocks: [
          ParagraphBlock(
            'A második nap végén a kitöltött lapot fényképként adjátok '
            'le az illetékes diszpécserednél. Ezzel a Ride Along '
            'formálisan lezárult, és a betanulásod dokumentálva van.',
          ),
          StepsBlock([
            'Tedd a lapot sík felületre, keress jó fényt.',
            'Fényképezd felülről, az egész lap legyen a képen, árnyék '
                'nélkül és levágott szélek nélkül.',
            'Ellenőrizd, hogy a pipák, a dátum, a nevek és az aláírások '
                'olvashatók-e.',
            'Add le a fényképet az illetékes diszpécsernél — azon az '
                'úton, amelyet a tréner mond nektek.',
            'A papírlappal úgy járj el, ahogyan a céged előírja: '
                'elkérhetik.',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Az olvashatatlan annyi, mint a le nem adott',
            text: 'Egy bemozdult vagy félig levágott fényképet újra kell '
                'készíteni — és akkor talán már mindketten otthon '
                'vagytok. Nézd meg egyszer, mielőtt elküldöd.',
          ),
          ChecklistBlock(
            title: 'Ezt viszem magammal a lezárásból',
            items: [
              'A 2. nap után a tréner visszajelzést ad a '
                  'teljesítményemről és a vezetési képességeimről',
              'A nem világos pontokra konkrétan rákérdezek',
              'A lapon szerepel a dátum, a tanuló neve és az oktató neve',
              'A tréner naponta külön ír alá',
              'Minden nap végén magam is ellenőrzöm, hogy minden be van-e '
                  'írva',
              'A lapot a 2. nap végén olvasható fényképként adjuk le az '
                  'illetékes diszpécsernél',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ra5',
    title: 'Így készülsz fel',
    summary: 'Mit érdemes az 1. nap ELŐTT tisztáznod — hozzáférések, '
        'felszerelés, időtervezés és a kérdéseid',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Tisztázd előre: hozzáférések és technika',
        blocks: [
          ParagraphBlock(
            'A leggyakoribb ok, amiért egy első nap rosszul indul, nem a '
            'hiányzó tudás, hanem egy nem működő hozzáférés. Tisztázd '
            'ezt előre — akkor a Ride Alongod azzal kezdődik, amiről '
            'valójában szól.',
          ),
          BulletsBlock([
            'A saját kézbesítői fiókod: a belépési adatok megvannak, és '
                'egyszer sikeresen beléptél',
            'A céged munkaidő-nyilvántartása (pl. Kenjo): a hozzáférés '
                'beállítva, tudod, hogyan jelentkezel be és ki',
            'Mentor és Flex: alkalmazások telepítve, a belépés '
                'kipróbálva, a helyadatokra és a mozgásra vonatkozó '
                'engedélyek megadva',
            'CoDriver: bejelentkezve, az értesítések engedélyezve',
            'Telefon: feltöltve, elegendő tárhellyel, töltőkábel vagy '
                'powerbank a furgonhoz nálad',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Előző este ellenőrizd, ne reggel',
            text: 'Egy jelszó visszaállítása este 8-kor öt perc, reggel '
                '6-kor a Waiting Areában fél óra — ha egyáltalán elérhető '
                'valaki.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: az első nap reggelén nem tudsz '
                'belépni a kézbesítő alkalmazásba. A tréner vár, a hullám '
                'indul. Mi a legjobb reakció?',
            answer: 'Azonnal mondd meg, hogy a hozzáférés nem működik — '
                'méghozzá a trénernek, hogy be tudja vonni az illetékes '
                'diszpécseredet. A kézenfekvő tévedés az, ha csendben '
                'tovább próbálkozol, nehogy ügyetlennek tűnj. Ez pont '
                'azokat a perceket viszi el, amikor a probléma még '
                'megoldható lenne, a végén pedig egész nap a tréner '
                'fiókjával mész — amivel a saját fiókodon teljesítendő '
                'minimális megállószám nem teljesül, és rosszabb esetben '
                'a napot meg kell ismételni. Ezért: jelezd korán, és mondd '
                'el világosan, mit próbáltál már.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Öltözék, felszerelés és pontosság',
        blocks: [
          SubheadBlock('Amit felveszel'),
          BulletsBlock([
            'Munkavédelmi cipő: erős, zárt munkacipő — nem sportcipő, '
                'nem szandál',
            'Időjárásálló ruha: egész nap kint vagy, akkor is, ha reggel '
                'még száraznak tűnik',
            'Mozgásszabadság: több százszor szállsz ki és be',
            'A láthatósági mellény kéznél — a járműben van, de a fejedben '
                'a helye',
          ]),
          SubheadBlock('Amit magaddal viszel'),
          BulletsBlock([
            'Jogosítvány — nélküle nem vezetsz, az első napon sem',
            'Személyi igazolvány vagy tartózkodási okmány, ha a cég kéri',
            'Ital és valami ennivaló a szünetre',
            'Toll és egy kis jegyzetfüzet vagy jegyzetalkalmazás',
          ]),
          SubheadBlock('Pontosság'),
          ParagraphBlock(
            'A pontos azt jelenti: bevethető állapotban vagy az '
            'állomáson a műszakkezdésre, nem éppen érkezel a kapuhoz. '
            'Számold hozzá a parkolás, az udvaron való átjutás és a '
            'Waiting Area idejét. Aki az első napon késik, a tréner '
            'hullámát is hátratolja — és ez megmarad.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ökölszabály az első napokra',
            text: 'Úgy tervezd az odautat, hogy inkább korábban ott '
                'legyél. A nyert negyedórát arra használd, hogy '
                'körülnézz — mosdók, Waiting Area, felállási helyek.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A kérdéseid — és az előzetes ellenőrzőlista',
        blocks: [
          ParagraphBlock(
            'Két napon át van melletted valaki, aki mindent tud, amit '
            'tudnod kell. Ez a helyzet így nem tér vissza. A hiba, amit '
            'majdnem mindenki elkövet: nem jegyzik meg a kérdéseiket, és '
            'csak a második héten jutnak eszükbe, egyedül a furgonban.',
          ),
          BulletsBlock([
            'Már az 1. nap előtt írd fel, mit szeretnél tudni — az '
                'apróságokat is',
            'A túra közben jegyzeteld a válaszokat, ne bízz az '
                'emlékezetedben',
            'Vevői adatokról ne készíts fényképet, de a folyamatokat és a '
                'kapcsolattartókat írd fel',
            'Kérdezd meg minden nap végén: „Mit nem láttam még ma?"',
          ]),
          ParagraphBlock(
            'Jó kérdések a Ride Alonghoz például: pontosan mikor van a '
            'Waiting Area-időablakom? Hol parkolok magánautóval? Miről '
            'ismerem fel, hogy a Mentor még fut? Hová írom be a '
            'szünetemet? Kinek jelentek először egy kárt? Hol adom le a '
            'Green Bookot? Mit teszek, ha egy vevőnek nincs meg a kódja '
            'egy jelszavas csomaghoz?',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Miért végezted el ezt az oktatást',
            text: 'Nem azért, hogy a Ride Alongon már mindent tudj, '
                'hanem hogy ismerd a fogalmakat. Aki tudja, miről van '
                'szó, tud figyelni — aki mindent először hall, csak '
                'bólogatni tud.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: a tréner délelőtt tíz dolgot magyaráz '
                'el egymás után. Este háromra emlékszel közülük. Mi volt '
                'az oka — te?',
            answer: 'A módszer, nem te. Tíz új folyamatot egymás után '
                'elmagyarázva megjegyezni senkinél nem működik. Ami '
                'működik: ha a fogalmakat előre egyszer elolvastad — '
                'pontosan ezért van ez az oktatás —, és útközben '
                'jegyzetelsz. Témánként két hívószó elég ahhoz, hogy este '
                'az egész folyamatot fel tudd idézni. Ami pedig a '
                'második napon még hiányzik, arra célzottan rákérdezel, '
                'ahelyett hogy abban bíznál, hogy magától eszedbe jut.',
          ),
          ChecklistBlock(
            title: 'Az 1. nap előtt — magadnak kipipálni',
            items: [
              'A saját kézbesítői fiókom belépési adatait kipróbáltam',
              'A munkaidő-nyilvántartás (pl. Kenjo), a Mentor, a Flex és '
                  'a CoDriver telepítve, és beléptem mindegyikbe',
              'Telefon feltöltve, töltőkábel vagy powerbank becsomagolva',
              'Munkavédelmi cipő és időjárásálló ruha előkészítve',
              'Jogosítvány és a szükséges okmányok nálam',
              'Ital és étel a szünetre előkészítve',
              'Toll és jegyzetelési lehetőség nálam',
              'Az odaút megtervezve — a parkolással és a Waiting Areához '
                  'vezető úttal együtt',
              'A trénernek szánt kérdéseimet felírtam',
              'Ezt az oktatást végigcsináltam, hogy ismerjem a '
                  'fogalmakat',
            ],
          ),
        ],
      ),
    ],
  ),
];
