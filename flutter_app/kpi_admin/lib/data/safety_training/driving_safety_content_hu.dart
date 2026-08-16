// lib/data/safety_training/driving_safety_content_hu.dart
//
// A DSP vezetesbiztonsagi trening tartalma — magyar valtozat.
// A felepites azonos a nemet (master) valtozattal: M1–M10 modulok,
// ugyanazok a diak es ugyanazok a blokkok. A kepek utjai valtozatlanok.

import 'safety_blocks.dart';

const List<SafetyChapterContent> drivingSafetyContentHu = [
  // ══════════════════════════════════════════════════ M1
  SafetyChapterContent(
    id: 'm1',
    title: 'Biztonsági kultúra és felelősség',
    summary: 'Értsd a biztonságot saját döntésedként — ne előírásként',
    asset: 'assets/academy/driving/m01_sicherheitskultur.svg',
    slides: [
      SafetySlide(
        title: 'A te túrád, a te felelősséged',
        blocks: [
          ParagraphBlock(
            'Minden nap több száz kilométert teszel meg, és több '
            'tucatszor állsz meg. Minden út, minden megálló, minden '
            'kiszállás egy döntés. A jó hír: majdnem minden baleset '
            'elkerülhető. A biztonság nem a kormánynál kezdődik, hanem '
            'a fejedben — még mielőtt elindulnál.',
          ),
          FactsBlock([
            FactItem('120+', 'megálló egy szokásos kézbesítési napon'),
            FactItem('250+', 'be- és kiszállás túránként'),
            FactItem('1', 'másodperc figyelmetlenség elég egy '
                'balesethez'),
          ]),
          ParagraphBlock(
            'Ennyi ismétlésnél nem a tudásod dönti el a napot, hanem a '
            'rutinod. A jó rutin akkor is megvéd, ha fáradt vagy, vagy '
            'nyomás alatt állsz — a rossz rutin egyszer drágán '
            'megbosszulja magát.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'A lényeg',
            text: 'A biztonság nem valami, amit ráadásként csinálsz. Az '
                'a mód, ahogyan a munkádat végzed.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Mi történik valójában a kézbesítésben',
        blocks: [
          ParagraphBlock(
            'A kézbesítés azok közé a szakmák közé tartozik, ahol a '
            'legtöbb úti és munkabaleset történik. A leggyakoribb esetek '
            'nem látványosak: ráfutás a dugóban, károk tolatáskor, '
            'esések kiszálláskor, megemelt hátak, kificamodott bokák. '
            'Hétköznapiak — és pont ezért alábecsültek.',
          ),
          FactsBlock([
            FactItem('70 %', 'a furgonkárok ennyi része tolatás és '
                'manőverezés közben keletkezik'),
            FactItem('No. 1', 'a botlás, csúszás, esés a leggyakoribb '
                'sérülési ok a kézbesítésben'),
            FactItem('24', 'kiesett munkanap átlagosan egy esés után'),
          ]),
          ParagraphBlock(
            'Feltűnő: ezek az esetek szinte mind alacsony sebességnél '
            'vagy álló helyzetben történnek. Nem drámai manőverek, hanem '
            'hétköznapi mozdulatok, amelyeket egyszer rosszul hajtottak '
            'végre.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'A lassú nem ártalmatlan',
            text: 'Egy lépésben tolatva okozott kár a cégnek gyorsan '
                'négyjegyű összegbe kerül — neked pedig fél nap '
                'bosszúságba.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A három alapállás',
        blocks: [
          ParagraphBlock(
            'Mindabból, ami ebben a tréningben jön, három alapállás '
            'vezethető le. Ha csak ezt a hármat viszed magaddal, a '
            'nagyobbik részét már elvégezted.',
          ),
          BulletsBlock([
            'Előre gondolkodni — felismerni a veszélyt, mielőtt '
                'kialakul. Aki csak reagál, mindig elkésik',
            'Az idő a tiéd — egy csomag sem ér meg egy balesetet. Az '
                'időnyomás tervezési probléma, nem kifogás',
            'Példát mutatni — a viselkedésed védi a kollégákat, a '
                'gyalogosokat és a gyerekeket. Az utcán profi vagy, nem '
                'magánsofőr',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Vezérgondolat',
            text: 'A legjobb sofőr nem a leggyorsabb, hanem az, akivel '
                'sosem történik semmi — mert előre látja.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Minden út döntések láncolata',
        asset: 'assets/academy/driving/m01b_entscheidung.svg',
        blocks: [
          ParagraphBlock(
            'Egy baleset ritkán egyetlen hiba. Többnyire öt-hat apró '
            'döntés, amelyek külön-külön ártalmatlannak tűnnek — és a '
            'végén összeadódnak. Pont ezért tudod a láncot bármelyik '
            'ponton megszakítani.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: 17:40 van, még 22 megállód van '
                'hátra. A rakodótér rendetlen, a telefonod rezeg a '
                'tartóban, előtted pedig beszűkül az út. Hol van itt '
                'valójában a kockázat?',
            answer: 'Nem az előtted lévő szűkületben — hanem az '
                'előzményekben. A rendetlen rakodótér minden megállónál '
                'időt visz el, az idő nyomást szül, a nyomás csökkenti a '
                'figyelmedet, a telefon pedig elviszi a maradékot. A '
                'helyes döntés két órával korábban lett volna esedékes: '
                'rakteret rendezni, telefont némítani, reálisan '
                'ütemezni. Most már csak az segít: megállni, mély '
                'levegőt venni, megállóról megállóra haladni, és utána '
                'jelezni a tervezési gondot.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Törd meg a láncot',
            text: 'Kérdezd meg magadtól minden rossz érzésnél: melyik az '
                'az egy szem, amit 30 másodperc alatt ki tudok venni?',
          ),
        ],
      ),
      SafetySlide(
        title: 'Példakép a csapatban',
        asset: 'assets/academy/driving/m01c_vorbild.svg',
        blocks: [
          ParagraphBlock(
            'A biztonsági kultúra nem hirdetményekből születik, hanem '
            'abból, amit a kollégák egymástól ellesnek. Aki újonnan '
            'kezd, azt utánozza, amit a tapasztaltak elé élnek — a '
            'rosszat is.',
          ),
          DoDontBlock(
            doTitle: 'Kultúra, ami tart',
            dos: [
              'A majdnem-baleseteket nyíltan szóba hozni anélkül, hogy '
                  'bárkire furcsán néznének',
              'Az új kollégákat aktívan figyelmeztetni a fellépőkre, a '
                  'kapaszkodókra és a holttérre',
              'A hibákat azonnal jelenteni, akkor is, ha a túra emiatt '
                  'később indul',
              'Időnyomás alatt is láthatóan tisztán manőverezni',
            ],
            dontTitle: 'Kultúra, ami árt',
            donts: [
              '„Itt mindig így csináljuk" mint indoklás',
              'Kinevetni a kollégát, aki kiszáll és megnézi',
              'A kis károkat egymás közt elintézni jelentés helyett',
              'Olyan rövidítéseket elé élni, amiket újaknak sosem '
                  'tanítanál',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'A majdnem-balesetek aranyat érnek',
            text: 'Minden bejelentett majdnem-baleset egy olyan baleset, '
                'ami a következő kollégával már nem történik meg. A '
                'jelentés erő, nem árulkodás.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ki felel valójában?',
        blocks: [
          ParagraphBlock(
            'A kormánynál te vagy a járművezető — és ezzel személyesen '
            'felelős. A cég biztonságos járművet ad, kioktat és '
            'megtervezi a túrát. Hogy aztán tartod-e a követési '
            'távolságot, becsatolod-e az övet és kiszállsz-e tolatás '
            'előtt, azt egyedül te döntöd el.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Mit vár el tőled a törvény',
            text: 'A § 1 StVO (német KRESZ) folyamatos óvatosságot és '
                'kölcsönös figyelmességet követel. A § 3 Abs. 1 StVO '
                'megköveteli, hogy csak olyan gyorsan hajts, hogy a '
                'belátható szakaszon belül meg tudj állni. Mindkettő '
                'attól függetlenül érvényes, mi áll a táblán.',
          ),
          BulletsBlock([
            'A bírságok és a pontok téged érintenek személyesen, nem a '
                'céget',
            'Súlyos gondatlanság esetén a biztosító arányosan '
                'visszakövetelhet tőled',
            'Mások veszélyeztetésénél a közlekedési szabálysértésből '
                'bűncselekmény lehet (§ 315c StGB)',
            'Egy vezetéstől eltiltás számodra hivatásos sofőrként azt '
                'jelenti: nincs bevetés',
          ]),
          RevealBlock(
            prompt: 'Reggel észreveszed, hogy egy féklámpa kiégett. A '
                'diszpécser azt mondja: „Menj csak, nincs más '
                'emberünk." Ki viseli a kockázatot?',
            answer: 'Te. Járművezetőként te felelsz annak a járműnek a '
                'közlekedésbiztos állapotáért, amelyet mozgatsz — egy '
                'szóbeli utasítás ezt nem szünteti meg. Helyes: hibát '
                'jelenteni, csereautót vagy javítást kérni, a '
                'bejelentést dokumentálni. Egy hibás féklámpa a '
                'furgonon ráadásul pont az a hiba, ami ráfutásos '
                'balesethez vezet.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista: a hozzáállásod',
        blocks: [
          ChecklistBlock(
            title: 'Ezt viszem magammal az 1. modulból',
            items: [
              'Tudom, hogy a legtöbb kár lassan és hétköznapian '
                  'történik',
              'Előre gondolkodom ahelyett, hogy csak reagálnék',
              'Az időnyomást tervezési problémaként kezelem, nem '
                  'vezetési problémaként',
              'Jelentem a hibákat és a majdnem-baleseteket, a kicsiket '
                  'is',
              'Tudom, hogy járművezetőként személyesen felelek',
              'Tudatában vagyok, hogy az új kollégák engem másolnak',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Egy mondat a túrára',
            text: '„Úgy vezetek, hogy mindenki épségben hazaérjen — én '
                'is."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M2
  SafetyChapterContent(
    id: 'm2',
    title: 'Járműellenőrzés és rakományrögzítés',
    summary: 'Túra előtt ellenőrizd a járművet, és úgy rögzítsd a '
        'rakományt, hogy semmi ne váljon veszéllyé',
    asset: 'assets/academy/driving/m02_fahrzeugcheck.svg',
    slides: [
      SafetySlide(
        title: 'Miért nem formaság az ellenőrzés',
        blocks: [
          ParagraphBlock(
            'A túra előtti körbejárás két percig tart. Megelőzi az út '
            'közepén bekövetkező meghibásodást, a bírságot egy '
            'ellenőrzésnél, és a legrosszabb esetben egy olyan '
            'balesetet, amit már indulás előtt megláthattál volna.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Ellenőrzési kötelezettség műszak előtt',
            text: 'A DGUV Vorschrift 70 (Fahrzeuge — német baleset-'
                'megelőzési előírás a járművekről) szerint minden '
                'műszak kezdete előtt ellenőrizned kell a járművedet '
                'szemmel látható hibákra. Ha a biztonságos üzemet '
                'veszélyeztető hibát találsz, nem indulhatsz el — '
                'jelented.',
          ),
          FactsBlock([
            FactItem('2 perc', 'ennyi a teljes körbejárás'),
            FactItem('4', 'állomás: gumi, világítás, folyadékok, '
                'rakomány'),
          ]),
          ParagraphBlock(
            'Fontos: az ellenőrzés nem helyettesíti a szervizvizsgálatot. '
            'Azt keresed, ami szembeötlik — nem a rejtett hibákat.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A körbejárás — négy állomás',
        asset: 'assets/academy/driving/m02b_rundgang.svg',
        blocks: [
          ParagraphBlock(
            'Mindig ugyanabban a sorrendben járd körbe a kocsit. A fix '
            'sorrend az egyetlen mód arra, hogy semmit ne felejts el, ha '
            'reggel kapkodás van.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/load01_reifen.svg',
              title: '1 · Gumik és kerekek',
              caption: 'Járd körbe egyszer teljesen, és nézd meg mind a '
                  'négy gumit: láthatóan lapos, repedések, idegen test, '
                  'elég a profil? Egy gumi, ami reggel már puhának '
                  'látszik, nem bír ki egy túrát.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load02_licht.svg',
              title: '2 · Világítás és rendszám',
              caption: 'Ellenőrizd a helyzetjelzőt, a tompított fényt, '
                  'az indexet, a féklámpát és a tolatólámpát — a '
                  'féklámpát szükség esetén egy fal visszaverődésével '
                  'vagy egy kollégával. A rendszám legyen szabad és '
                  'olvasható.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load03_fluessigkeiten.svg',
              title: '3 · Folyadékok és talaj',
              caption: 'Egy pillantás a kocsi alá: olaj-, hűtő- vagy '
                  'fékfolyadéknyomok a talajon mindig okot adnak a '
                  'bejelentésre. Ehhez tölts ablakmosót — télen '
                  'fagyállóval.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load04_ladung.svg',
              title: '4 · Raktér és rakomány',
              caption: 'Ajtót ki és nézz be: minden szilárdan áll, '
                  'feszül az elválasztóháló és a hevederek, nincs semmi '
                  'lazán a tetején? Ami itt lazán áll, az első '
                  'vészfékezésnél előrerepül.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Gumik: az egyetlen kapcsolatod az úttal',
        blocks: [
          ParagraphBlock(
            'Négy érintkezési felület, mindegyik nagyjából akkora, mint '
            'egy képeslap — ennél több nem köti össze a megrakott '
            'furgonodat az úttal. Minden, amit a fékezésről, a '
            'kormányzásról és a tapadásról tanulsz, ezen a négy '
            'felületen múlik.',
          ),
          FactsBlock([
            FactItem('1,6 mm', 'törvényi minimális profilmélység'),
            FactItem('3 mm', 'ajánlott minimum profil nyáron'),
            FactItem('4 mm', 'ajánlott minimum profil télen'),
            FactItem('60 € + 1 p.', 'túl kevés profilmélységnél'),
          ]),
          BulletsBlock([
            'A profilmélységet egy 1 eurós érmével ellenőrizheted: az '
                'arany perem 3 mm széles — ha eltűnik a profilban, még '
                'elég van',
            'A légnyomást hideg gumin ellenőrizd, és igazítsd a '
                'terheléshez — megrakva nagyobb nyomás kell, mint '
                'üresen',
            'Figyelj az egyenetlen kopásra: egyoldali kopás futómű- '
                'vagy nyomásproblémát jelent',
            'A dudorokat, repedéseket és a beleállt csavarokat azonnal '
                'jelentsd',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'A túl kevés nyomás veszélyesebb, mint a túl sok',
            text: 'A túl gyengén felfújt gumi gyűrődik, felforrósodik, '
                'és teljes terhelésnél ki is durranhat. Ráadásul nő a '
                'fékút és az aquaplaning veszélye.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Világítás, ablakok, tükrök',
        blocks: [
          ParagraphBlock(
            'Ugyanolyan fontos, hogy lássanak, mint hogy láss. Egy '
            'kiégett féklámpa a furgonon a klasszikus oka a ráfutásos '
            'balesetnek, amelyben ugyan nem te vagy az okozó — de a kár '
            'mégis nálad van.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A szabad kilátás kötelező',
            text: 'A § 23 Abs. 1 StVO szerint gondoskodnod kell arról, '
                'hogy a látásodat és a hallásodat semmi ne korlátozza — '
                'sem a rakomány, sem az utasok, sem a jeges vagy piszkos '
                'ablak. Egy kikapart „kukucskálólyuk" kifejezetten nem '
                'elég.',
          ),
          BulletsBlock([
            'A tükröket álló helyzetben állítsd be, még a motor '
                'beindítása előtt — soha menet közben',
            'A külső tükröket úgy, hogy a saját járműved egy keskeny '
                'csíkja látható maradjon: ez a viszonyítási pontod',
            'Az ablakokat és a tükröket kívül-belül tartsd tisztán — a '
                'belső oldalon a zsír éjjel rendkívül vakít',
            'A kenő ablaktörlő lapátokat azonnal cseréltesd ki',
          ]),
          RevealBlock(
            prompt: 'A körbejárásnál feltűnik: a jobb külső tükör '
                'billeg és repedt. Még 190 megállód van hátra. Elindulsz '
                'vagy sem?',
            answer: 'Ne indulj el, amíg nincs bejelentve. A jobb külső '
                'tükör pont az, amivel a kerékpárosok és a járda felé '
                'eső holtteret biztosítod — és pont ott történnek a '
                'súlyos kanyarodási balesetek. Egy repedt, billegő tükör '
                'olyan hiba, ami a közlekedésbiztonságot érinti. '
                'Jelenteni, cserélni vagy járművet váltani.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Rakományrögzítés: értsd meg az erőket',
        blocks: [
          ParagraphBlock(
            'A rakományt úgy kell rögzíteni, hogy vészfékezésnél vagy '
            'hirtelen kitérő manővernél se csússzon el. Hogy ez '
            'konkrétan mit jelent, azt a technika elismert szabályai '
            'írják le — és azok világos értékekkel számolnak.',
          ),
          FactsBlock([
            FactItem('0,8 g', 'előre ható erő, ami ellen rögzíteni kell'),
            FactItem('0,5 g', 'hátra és oldalra ható erő'),
            FactItem('16 kg', 'visszatartó erő, amit önmagában egy '
                '20 kg-os csomag igényel fékezésnél'),
          ]),
          ParagraphBlock(
            'Lefordítva: egy 20 kg-os csomag vészfékezésnél nagyjából '
            '16 kg-mal nyom előre — mintha egy teli rekesz ásványvizet '
            'tolnál a válaszfal felé. Húsz ilyen csomagnál ez több mint '
            '300 kg, ami egyszerre akar előre mozdulni.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 22 StVO — rakomány',
            text: 'A rakományt úgy kell elhelyezni és rögzíteni, hogy '
                'vészfékezésnél vagy hirtelen kitérésnél se csúszhasson '
                'el, ne dőlhessen fel, ne guruljon ide-oda és ne eshessen '
                'le. A rögzítetlen rakományt bírsággal, veszélyeztetés '
                'esetén ponttal is büntetik — és a sofőrt sújtja.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Mit okoz 20 kg éles helyzetben',
        blocks: [
          ParagraphBlock(
            'A 0,8 g a fékezésre és a kitérésre vonatkozik. Egy valódi '
            'ütközésnél jóval nagyobb lassulás hat, nagyon rövid idő '
            'alatt — egy rögzítetlen csomag ütőereje ilyenkor a '
            'súlyának a többszöröse.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: az anyósülésen fekszik egy 12 kg-os '
                'küldemény, mert az a következő megálló. Lakott '
                'területen vészfékezned kell egy gyerek előtt. Mi '
                'történik a csomaggal?',
            answer: 'Tovább mozog a kiindulási sebességeddel, amíg '
                'valami meg nem állítja — a műszerfal, a szélvédő vagy '
                'oldalütközésnél a fejed. Már egy szokásos '
                'vészfékezésnél is leesik az ülésről a lábtérbe, és ott '
                'a fékpedál alá kerülhet. Pont ezért nem való küldemény '
                'előre: a következő megállót a raktérben készíted elő, '
                'nem az anyósülésen tárolod közben.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Semmi a vezetőfülkében',
            text: 'Se csomag, se görgős doboz, se laza szerszám a '
                'vezetőtérben. Egy tárgy a fékpedál alatt pont akkor '
                'veszi el a féket, amikor szükséged van rá.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Így rakodsz helyesen',
        asset: 'assets/academy/driving/m02c_ladung.svg',
        blocks: [
          ParagraphBlock(
            'Az alapszabály: nehezet le, nehezet előre, a súlyt '
            'egyenletesen a tengelyekre. A magasra rakott furgonnak magas '
            'a súlypontja — és ez dönti el, hogy egy kanyarban még '
            'csúszol, vagy már borulsz.',
          ),
          DoDontBlock(
            doTitle: 'Rögzítve',
            dos: [
              'A nehéz csomagok alul és elöl, a válaszfalnál',
              'A súly egyenletesen elosztva bal és jobb oldalon',
              'Hézagmentesen rakodni — a réseket zárni, hogy semmi ne '
                  'tudjon nekilendülni',
              'A hevederek és az elválasztóháló feszesek, akkor is, ha a '
                  'raktér ürül',
              'Minden utánrakodás után röviden ellenőrizni',
            ],
            dontTitle: 'Rögzítetlenül',
            donts: [
              'A nehéz csomagok lazán a tetejére halmozva',
              'Küldemények a lábtérben vagy az anyósülésen',
              'Minden csak „valahogy" betolva, a rések nyitva',
              'Az elválasztóháló kioldva, mert zavar a nyúláskor',
              'A rakományt csak a saját testsúlyoddal „megtartani"',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'A félig üres raktér a legveszélyesebb',
            text: 'Minél kevesebb van benne, annál nagyobb utat tehet '
                'meg a maradék csomag, hogy sebességre tegyen szert. A '
                'félig üres nem félig veszélyes — azt jelenti: újra '
                'rögzíteni.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Rend a vezetőfülkében és biztonsági öv',
        blocks: [
          ParagraphBlock(
            'Ital, telefon, szkenner, szállítólevelek — mindennek fix '
            'helye van. Ami gurul, zörög vagy repül, elviszi a '
            'tekintetedet az útról. A rendezett vezetőhely biztonságos '
            'vezetőhely.',
          ),
          FactsBlock([
            FactItem('30 €', 'figyelmeztető bírság biztonsági öv nélkül'),
            FactItem('Minden', 'megállónál: az övet újra becsatolni, '
                '200 méterre is'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 21a StVO — övhasználati kötelezettség',
            text: 'A biztonsági övet menet közben be kell csatolni — nincs '
                'kivétel a két megálló közti rövid szakaszra. Öv nélküli '
                'balesetnél ráadásul közrehatást is felróhatnak neked.',
          ),
          ParagraphBlock(
            'Épp a kézbesítésben az öv a leggyakrabban elhagyott '
            'biztonsági eszköz — mert két megálló között csak néhány '
            'száz méter van. Viszont pont ott történik a legtöbb lakott '
            'területi koccanás.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista indulás előtt',
        blocks: [
          ChecklistBlock(
            title: 'Mielőtt elindulok',
            items: [
              'Körbejárás fix sorrendben megtörtént',
              'Gumik: profil, nyomás, sérülések ellenőrizve',
              'Világítás körben ellenőrizve, rendszám olvasható',
              'Nincs folyadéknyom a jármű alatt',
              'Ablakok és tükrök tiszták, tükrök beállítva',
              'A nehéz csomagok alul és elöl, a súly elosztva',
              'A hevederek és az elválasztóháló feszesek',
              'Semmi laza a vezetőfülkében, telefon a tartóban',
              'Láthatósági mellény kéznél, elakadásjelző háromszög a '
                  'fedélzeten',
              'Az öv becsatolva',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M3
  SafetyChapterContent(
    id: 'm3',
    title: 'Védekező és előrelátó vezetés',
    summary: 'Úgy kezeld a követési távolságot, a tempót és a figyelmet, '
        'hogy mindig legyen tartalékod',
    asset: 'assets/academy/driving/m03_defensiv.svg',
    slides: [
      SafetySlide(
        title: 'Megállási út = reakcióút + fékút',
        blocks: [
          ParagraphBlock(
            'A megállási út az a szakasz, amit a felismerés '
            'pillanatától a megállásig teszel meg. Két részből áll: a '
            'reakcióútból, amelyet még teljes sebességgel futsz be, és '
            'a tulajdonképpeni fékútból.',
          ),
          FactsBlock([
            FactItem('kb. 1 mp', 'egy éber, józan sofőr reakcióideje'),
            FactItem('× 3', 'reakcióút = tempó ÷ 10, szorozva 3-mal'),
            FactItem('²', 'fékút = (tempó ÷ 10) a négyzeten'),
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'A hüvelykujjszabályok',
            text: 'Reakcióút = (km/h ÷ 10) × 3. Fékút = (km/h ÷ 10) × '
                '(km/h ÷ 10). A kettő összege a megállási út. '
                'Vészfékezésnél a fékút megfeleződik.',
          ),
          ParagraphBlock(
            'A döntő pont: a fékút nem a sebességgel arányosan nő, '
            'hanem annak négyzetével. Dupla tempó négyszeres fékutat '
            'jelent — ezért változtat meg mindent 20 km/h többlet egy '
            'lakóutcában.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Számolj, ne becsülj',
        blocks: [
          TableBlock(
            headers: ['Tempó', 'Reakció', 'Fékút', 'Megállási út'],
            rows: [
              ['30 km/h', '9 m', '9 m', '18 m'],
              ['50 km/h', '15 m', '25 m', '40 m'],
              ['70 km/h', '21 m', '49 m', '70 m'],
              ['100 km/h', '30 m', '100 m', '130 m'],
            ],
          ),
          ParagraphBlock(
            'Összehasonlításul: egy Sprinter körülbelül 6 méter hosszú. '
            '50-es tempónál tehát nagyjából hét járműhossz kell a '
            'megállásig — és ebből az első két és fél úgy telik el, '
            'hogy még hozzá sem értél a pedálhoz.',
          ),
          RevealBlock(
            prompt: 'Számolási feladat: 50 km/h-val hajtasz egy '
                'lakóutcán. 20 méterre előtted egy gyerek szalad ki két '
                'parkoló autó közül az úttestre. Meg tudsz állni?',
            answer: 'Nem. Már a reakcióutad is 15 méter, utána jön 25 '
                'méter fékút — összesen 40 méter. Még vészfékezéssel is '
                '(15 m + 12,5 m = 27,5 m) kevés a 20 méter. 30-as '
                'tempónál viszont: 9 m reakció + 9 m fékút = 18 méter — '
                'két méterrel előbb megállsz. Pont ez a különbség egy '
                'ijedtség és egy súlyos baleset között.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A két másodperces szabály',
        asset: 'assets/academy/driving/m03b_abstand.svg',
        blocks: [
          ParagraphBlock(
            'A követési távolság nem udvariasság, hanem a reakcióidőd '
            'méterben. És mivel másodpercben gondolkodva működik, '
            'automatikusan igazodik a tempódhoz.',
          ),
          StepsBlock([
            'Keress egy fix pontot az út szélén — táblát, lámpaoszlopot, '
                'útburkolati jelet',
            'Amint az előtted haladó elhalad e mellett a pont mellett, '
                'kezdj számolni: „huszonegy, huszonkettő"',
            'Ha „huszonkettő" előtt érsz a ponthoz, túl közel vagy',
            'Nedves úton, ködben vagy sötétben emeld három '
                'másodpercre',
          ]),
          FactsBlock([
            FactItem('2 mp', 'minimális követési távolság száraz úton'),
            FactItem('3 mp+', 'nedves úton, ködben, sötétben'),
            FactItem('28 m', 'ennyi a 2 másodperc 50-es tempónál'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 4 Abs. 1 StVO — követési távolság',
            text: 'Az előtted haladótól a távolságnak általában akkorának '
                'kell lennie, hogy mögötte akkor is meg tudj állni, ha '
                'hirtelen lefékez. Hüvelykujjszabályként lakott területen '
                'kívül a sebességmérő értékének fele méterben.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Amikor hiányzik a távolság',
        blocks: [
          RevealBlock(
            prompt: 'Esettanulmány: főúton 80-as tempónál szépen tartasz '
                '40 méter követési távolságot. Egy személyautó behúz a '
                'résbe, majd lefékez. Mi a helyes most?',
            answer: 'Nem bosszankodni, nem dudálni, nem szorongatni — '
                'hanem levenni a gázt és újraépíteni a távolságot. Ez '
                'néhány másodpercedbe kerül, és ez az egyetlen reakció, '
                'ami csökkenti a kockázatodat. Aki helyette felzárkózik, '
                'hogy „megvédje" a rést, annak 80-as tempónál már nincs '
                '40 métere, hanem talán 15 — kevesebb, mint a puszta '
                '24 méteres reakcióút.',
          ),
          DoDontBlock(
            doTitle: 'Higgadtan',
            dos: [
              'A besorolás után nyugodtan újraépíteni a távolságot',
              'Ha mögötted szorongatnak: jobbra húzódni, elengedni',
              'Lámpák és útépítések előtt korán levenni a gázt',
              'Dugóban rést hagyni az előtted haladóig, hogy ki tudj '
                  'sorolni',
            ],
            dontTitle: 'Kockázatos',
            donts: [
              'Felzárkózni, hogy megakadályozd a besorolást',
              'A fényváltó és a duda mint nevelőeszköz',
              'Torlódásban közvetlenül a lökhárítóig gurulni',
              'A távolságot csak érzésre becsülni másodpercek helyett',
            ],
          ),
          FactsBlock([
            FactItem('akár 400 €', 'bírság követési távolság '
                'megsértésénél, plusz pontok és eltiltás'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Nézz messzire előre',
        asset: 'assets/academy/driving/m03c_blickfuehrung.svg',
        blocks: [
          ParagraphBlock(
            'Ne az előtted lévő lökhárítót nézd, hanem 12–15 '
            'másodperccel előre — lakott területen tehát nagyjából két '
            'háztömbnyire. Így korán meglátod a féklámpákat, a '
            'lámpákat, a gyalogosokat és a szűkületeket, és nem kell '
            'kapkodva reagálnod.',
          ),
          BulletsBlock([
            'Gyerek a járdaszegélyen, aki még nem nézett szét',
            'Kerékpáros, aki mindjárt kikerül egy parkoló autót',
            'Autóajtó, ami mögött ül valaki — hátsó lámpa ég, fej a '
                'belső tükörben',
            'Féklámpák három járművel előrébb',
            'Kukák az út szélén: jele a manőverező forgalomnak',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'A tekintet vezeti a járművet',
            text: 'Amerre nézel, arra mész. Ezért kitéréskor mindig a '
                'szabad résre nézz — soha ne az akadályra.',
          ),
          ParagraphBlock(
            'Néhány másodpercenként egy rövid pillantás a tükrökbe is '
            'hozzátartozik. Így bármikor tudod, mi történik mögötted, '
            'és vészhelyzetben nem kell előbb hátranézned.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A tempó fizika',
        blocks: [
          ParagraphBlock(
            'A megengedett sebesség maximum, nem cél. Lakóövezetben, '
            'iskoláknál, parkoló autóknál és szűk utcákban a '
            'megengedettnél lassabban haladni gyakran az egyetlen '
            'helyes választás.',
          ),
          FactsBlock([
            FactItem('×4', 'fékút dupla tempónál'),
            FactItem('18 m', 'megállási út 30 km/h-nál'),
            FactItem('40 m', 'megállási út 50 km/h-nál'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 3 Abs. 1 StVO — belátható távolságon belüli '
                'megállás',
            text: 'Csak olyan gyorsan hajthatsz, hogy a belátható '
                'szakaszon belül meg tudj állni. Ködben, sötétben vagy '
                'beláthatatlan kanyarban ez jóval kevesebb, mint amit a '
                'tábla enged.',
          ),
          ParagraphBlock(
            'Számold ki egyszer, mit hoz valójában a száguldás: tíz '
            'kilométer városi szakaszon az 50-es és a 60-as tempó '
            'között legfeljebb két percet spórolsz — amit a következő '
            'piros lámpa úgyis elvesz.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Miért viselkedik másként a megrakott furgonod',
        blocks: [
          ParagraphBlock(
            'A teljesen megrakott furgon más jármű, mint ugyanaz a '
            'kocsi reggel üresen. Nagyobb tömeg nagyobb mozgási '
            'energiát jelent, amit a féknek le kell építenie — a '
            'magasabb súlypont pedig kevesebb tartalékot a kanyarban.',
          ),
          FactsBlock([
            FactItem('3,5 t', 'a furgonod megengedett össztömege'),
            FactItem('akár 1,4 t', 'hasznos teher — több, mint a saját '
                'tömeg fele'),
            FactItem('magas', 'súlypont: a dobozos furgonok ott '
                'borulnak, ahol a személyautók még csúsznak'),
          ]),
          BulletsBlock([
            'Megrakva korábban és lágyabban fékezz — a féknek több idő '
                'kell ugyanahhoz a lassuláshoz',
            'Kanyarban lényegesen lassabban: a rakomány kifelé '
                'helyeződik és növeli a borulási hajlamot',
            'Kitérő manővernél ne ránts vissza a kormányon — pont ettől '
                'borulnak fel a magas járművek',
            'A körforgalmakat és az autópálya-lehajtókat a megszokottnál '
                'jóval kisebb tempóval közelítsd meg',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'A borulás pillanata figyelmeztetés nélkül jön',
            text: 'A személyautóval ellentétben a magas dobozos furgon '
                'alig jelzi előre a borulást. Ha hallhatóan elmozdul a '
                'rakomány, már túl gyors vagy — a tempót a kanyar előtt '
                'vedd le, ne benne.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A holttér',
        asset: 'assets/academy/driving/m03d_toterwinkel.svg',
        blocks: [
          ParagraphBlock(
            'A furgonodnak nagy holtterei vannak — mindenekelőtt jobbra '
            'a vezetőfülke mellett és attól ferdén hátra. Egy teljes '
            'kerékpáros a biciklijével együtt elfér ott anélkül, hogy '
            'látnád a tükörben.',
          ),
          FactsBlock([
            FactItem('jobbra', 'a legnagyobb holttér a dobozos '
                'furgonoknál'),
            FactItem('1,5 m', 'minimális oldaltávolság kerékpáros '
                'előzésekor lakott területen'),
            FactItem('2 m', 'minimális távolság lakott területen kívül'),
          ]),
          ParagraphBlock(
            'A tükrök helyes beállítása csökkenti a holtteret, de nem '
            'szünteti meg. Ezért minden sávváltáshoz és kanyarodáshoz '
            'hozzátartozik az aktív vállpillantás — egy rövid, valódi '
            'pillantás a vállad fölött, nem csak egy fejbiccentés a '
            'tükör felé.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Soha ne feltételezd, hogy látnak',
            text: 'A szemkontaktus az egyetlen megbízható bizonyíték '
                'arra, hogy valaki észlelt téged. Az index szándék, nem '
                'garancia.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kanyarodás: a legveszélyesebb pillanat',
        blocks: [
          ParagraphBlock(
            'A kerékpárosokkal és gyalogosokkal történő legsúlyosabb '
            'ütközések többsége jobbra kanyarodáskor történik. Az ok '
            'mindig ugyanaz: a kerékpáros egyenesen halad tovább, és '
            'pont abban a zónában van, amelyet a sofőr a bekanyarodás '
            'közben már nem lát be.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: egy lámpánál jobbra akarsz '
                'kanyarodni. Egy kerékpáros balról előzött és most '
                'melletted áll. A lámpa zöldre vált. Mit teszel '
                'először?',
            answer: 'Állva maradsz és elengeded. Amint elindulsz és '
                'befordulsz, a kerékpáros a jobb oldali holttérbe kerül '
                '— a járműved hátulja pedig bekanyarodáskor ráadásul '
                'belendül a sávjába. Helyes: indulás előtt vállpillantás '
                'jobbra, a kerékpárosokat és gyalogosokat átengedni, '
                'aztán lassan bekanyarodni, és kanyarodás közben újra a '
                'jobb tükörbe nézni. Aki csak a tükörre hagyatkozik, '
                'pont akkor nem látja, amikor számít.',
          ),
          DoDontBlock(
            doTitle: 'Biztonságos kanyarodás',
            dos: [
              'Korán indexelni és jelentősen csökkenteni a tempót',
              'Vállpillantás a bekanyarodás előtt — nem csak tükör',
              'Kanyarodás közben még egyszer ellenőrizni jobbra',
              'Kétség esetén megállni és átengedni',
            ],
            dontTitle: 'Kockázatos',
            donts: [
              'Lendületből kanyarodni, hogy kihasználd a rést',
              'Csak a tükörbe nézni',
              'Feltételezni, hogy a kerékpáros mögötted marad',
              'Csak akkor indexelni, amikor már befordulsz',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Kanyarodásnál és megfordulásnál',
            text: '§ 9 Abs. 5 StVO: telekre kanyarodásnál, '
                'megfordulásnál és tolatásnál ki kell zárnod a többi '
                'közlekedő veszélyeztetését — szükség esetén irányítót '
                'kell igénybe venned.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista: védekezően úton',
        blocks: [
          ChecklistBlock(
            title: 'Ezt valósítom meg a mai naptól',
            items: [
              'Ismerem a reakció- és fékútra vonatkozó '
                  'hüvelykujjszabályokat',
              'Fix pontnál két másodperccel ellenőrzöm a követési '
                  'távolságomat',
              'Nedves úton és sötétben három másodpercre emelem',
              '12–15 másodperccel előre nézek a lökhárító helyett',
              'Megrakva lassabban megyek a kanyarban és korábban '
                  'fékezek',
              'Minden kanyarodás és sávváltás előtt valódi '
                  'vállpillantást teszek',
              'Lakott területen 1,5 m távolságot tartok kerékpáros '
                  'előzésekor',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M4
  SafetyChapterContent(
    id: 'm4',
    title: 'Tolatás és manőverezés',
    summary: 'Uralni a leggyakoribb kárforrást — biztonságosan tolatni és '
        'szűk helyzetekben manőverezni',
    asset: 'assets/academy/driving/m04_rueckwaerts.svg',
    slides: [
      SafetySlide(
        title: 'Az 1. számú kárforrás',
        blocks: [
          ParagraphBlock(
            'A legtöbb furgonkár lassan keletkezik — tolatás és '
            'manőverezés közben: oszlopok, falak, lámpaoszlopok, más '
            'autók, nyitott ajtók. A legrosszabb esetekben pedig '
            'emberek, akik a jármű mögötti holttérben állnak.',
          ),
          FactsBlock([
            FactItem('70 %', 'az összes furgonkár ennyi része '
                'manőverezés közben történik'),
            FactItem('< 10 km/h', 'tempó, amelynél a legtöbb '
                'manőverezési kár keletkezik'),
            FactItem('vak', 'több méteres zóna közvetlenül a jármű '
                'mögött'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Miért pont itt',
            text: 'Tolatáskor hiányzik az, ami egyébként megvéd: a '
                'szabad kilátás. Közben lassúnak, és ezért '
                'veszélytelennek érződik — ez a legveszélyesebb '
                'kombináció a kézbesítés hétköznapjaiban.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A tolatást kerüld el, ne csak uraljad',
        blocks: [
          ParagraphBlock(
            'A legbiztonságosabb tolatás az, amit el sem végzel. Már a '
            'megállóhoz érkezéskor gondolj arra, hogyan jutsz onnan '
            'ismét el — akkor a végén egyáltalán nem kell manővereznod.',
          ),
          BulletsBlock([
            'Ha lehet, előre parkolj be és előre is hajts ki',
            'Inkább állj meg 40 méterrel arrébb, mint hogy egy szűk '
                'bejáróba tolass be',
            'Zsákutcáknál és udvaroknál: behajtás előtt gondold végig, '
                'hogyan jutsz ki',
            'Jegyezd meg az útvonalon a megfordulási lehetőségeket — '
                'minden nap ugyanazok',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Mit követel a jog és a DGUV',
            text: '§ 9 Abs. 5 StVO: tolatásnál ki kell zárnod mások '
                'veszélyeztetését, szükség esetén irányítót kell '
                'igénybe venned. A DGUV Vorschrift 70 (Fahrzeuge) '
                'ugyanezt követeli: tolatni csak akkor szabad, ha '
                'kizárt a személyek veszélyeztetése.',
          ),
        ],
      ),
      SafetySlide(
        title: 'GOAL — Get Out And Look',
        asset: 'assets/academy/driving/m04b_goal.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'GOAL',
            text: '„Get Out And Look" — állj meg, szállj ki, nézz körül '
                'a jármű mögött, és csak azután tolass. Ez pont azokat a '
                'dolgokat tárja fel, amiket az ülésből sosem látsz.',
          ),
          ParagraphBlock(
            'A körbejárás tíz-tizenöt másodpercig tart. Ez alatt '
            'meglátod az alacsony oszlopokat, a járdaszegélyeket, a '
            'lejtőt, a laza csatornafedeleket, a játszó gyerekeket és a '
            'kapubejáró magasságát. Ezek közül semmit sem mutat meg '
            'megbízhatóan egy tolatókamera.',
          ),
          FactsBlock([
            FactItem('15 mp', 'ennyi egy GOAL-körbejárás'),
            FactItem('90 cm', 'magasság, amely alatt egy gyerek '
                'láthatatlan marad a jármű mögött'),
          ]),
          ParagraphBlock(
            'És még valami: amit kiszálláskor láttál, azt a fejedben '
            'tartod. Utána nem a bizonytalanba tolatsz, hanem egy olyan '
            'kép felé, amelyet ismersz.',
          ),
        ],
      ),
      SafetySlide(
        title: 'GOAL lépésről lépésre',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/goal01_stopp.svg',
              title: '1 · Megállni',
              caption: 'Mielőtt hátramenetbe kapcsolsz, teljesen megállsz '
                  'és rögzíted a járművet. Aki már gurul, az nem dönt '
                  'többé — csak reagál.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal02_aussteigen.svg',
              title: '2 · Kiszállni',
              caption: 'Szállj ki, ahelyett hogy az ülésben '
                  'kicsavarodnál. Használd közben a fellépőt és a '
                  'kapaszkodókat — a hárompontos szabály itt is '
                  'érvényes.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal03_umschauen.svg',
              title: '3 · Körülnézni',
              caption: 'Járd körbe egyszer teljesen a járművet: mi áll '
                  'alacsonyan a hátulja mögött, milyen magas a bejáró, '
                  'hol van lejtő, vannak-e a közelben gyerekek vagy '
                  'állatok? Jegyezd meg a távolságokat és a fix '
                  'pontokat.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal04_zurueck.svg',
              title: '4 · Lassan hátra',
              caption: 'Csak most tolass — lépésben, a vállad fölött és '
                  'mindkét tükörbe nézve. Kétség esetén állj meg még '
                  'egyszer és nézz körül újra.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'A lassú nem jelent ártalmatlant',
        blocks: [
          StepsBlock([
            'Válassz lépéstempót — soha ne gyorsabban, még az üres '
                'udvaron sem',
            'Engedd le az ablakot, hogy hallj: kiáltást, dudát, '
                'gyerekeket',
            'Nézz a vállad fölött és mindkét tükörbe, felváltva',
            'A kamerát csak kiegészítésként használd, soha ne egyetlen '
                'forrásként',
            'Minden kétség esetén állj meg, szállj ki, nézz körül újra',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'A kamera-tévhit',
            text: 'A tolatókamera egy kivágatot mutat, torzítja a '
                'távolságokat, és megvakul az esőtől, a hótól és a '
                'kosztól. Nem lát semmit abból, ami oldalról a hátulja '
                'mellett a pályádba lép. Nem helyettesíti a GOAL-t.',
          ),
          FactsBlock([
            FactItem('lépés', 'maximális tempó manőverezéskor'),
            FactItem('2 mp', 'ennyi kell egy gyereknek, hogy a jármű '
                'mögötti zónába szaladjon'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Használd helyesen az irányítót',
        blocks: [
          ParagraphBlock(
            'Az irányító csak akkor segít, ha előre tisztázottak a '
            'szabályok. Egy kolléga, aki valahol a jármű mögött áll és '
            'integet, nem biztonság — hanem további kockázat.',
          ),
          BulletsBlock([
            'A jeleket előre beszéljétek meg: stop, lassan, tovább, '
                'mennyi hely van',
            'Az irányító oldalt áll, soha nem közvetlenül a jármű '
                'mögött',
            'Folyamatosan látnod kell őt a tükörben — különben stop',
            'Csak egy személy irányít, nem többen egyszerre',
            'Az irányító láthatósági mellényt visel, különösen '
                'szürkületben',
          ]),
          RevealBlock(
            prompt: 'Egy szűk udvari bejáróba tolatsz, a kollégád '
                'irányít. Hirtelen nem látod őt a tükörben. Mit teszel?',
            answer: 'Azonnal megállsz — nem lassítasz, hanem megállsz. '
                'A szemkontaktus hiánya azt jelenti: nincs érvényes jel. '
                'Talán elment a jármű mögött, megcsúszott, vagy '
                'megszólította egy járókelő. Csak akkor haladj tovább, '
                'ha újra látod és új jelet ad neked.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Esettanulmány: a szűk udvari bejáró',
        blocks: [
          RevealBlock(
            prompt: 'Esettanulmány: az utolsó megálló egy belső udvarban '
                'van. A bejáró szűk, mögötted egy autó vár, esik az eső, '
                'és 40 perccel csúszol a tervhez képest. Előre be tudsz '
                'menni — kifelé csak tolatva, egy fal és három parkoló '
                'autó mellett. Mi a helyes döntés?',
            answer: 'Be se hajts. Állj meg az utcán, vidd az utolsó '
                'métereket gyalog, vagy használd a kézikocsit. Ha már '
                'bent vagy: elakadásjelzőt be, kiszállni, felmérni a '
                'helyzetet, adott esetben megkérni a várakozó sofőrt, '
                'hogy tolasson, és aztán több rövid mozdulattal, közbenső '
                'ellenőrzésekkel kimanőverezni. A mögötted várakozó sofőr '
                'nem ok a sietségre — a kár a végén neked számít, nem '
                'neki. A 40 perc csúszást semmilyen manőver nem hozza be, '
                'de egy karambol elviszi a napod maradékát.',
          ),
          DoDontBlock(
            doTitle: 'Helyes manőverezés',
            dos: [
              'Több rövid mozdulattal egy hosszú helyett',
              'Közben megállni és újra felmérni a helyzetet',
              'Elakadásjelző, ha a forgalmi térben manőverezel',
              'Inkább messzebb megállni és az utolsó métereket '
                  'gyalogolni',
            ],
            dontTitle: 'Hibás',
            donts: [
              'A várakozók nyomására gyorsabban manőverezni',
              'Egy mozdulattal „átnyomni", mert különben ciki',
              'Csak a kamerában vagy a szenzorokban bízni',
              'Manőverezni, miközben gyalogosok keresztezik a zónát',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista: tolatás és manőverezés',
        blocks: [
          ChecklistBlock(
            title: 'Minden tolatási manőver előtt',
            items: [
              'Először azt vizsgálom, el tudom-e kerülni a tolatást',
              'Teljesen megállok, mielőtt hátramenetbe kapcsolok',
              'Kiszállok és megnézem a jármű mögötti területet (GOAL)',
              'Csak lépésben tolatok',
              'A vállam fölött és mindkét tükörbe nézek, nem csak a '
                  'kamerára',
              'Leengedem az ablakot, hogy halljak',
              'Azonnal megállok, ha nem látom többé az irányítót',
              'Minden manőverezési kárt jelentek, a kis horpadást is',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M5
  SafetyChapterContent(
    id: 'm5',
    title: 'Időjárás, látási viszonyok és nehéz körülmények',
    summary: 'Igazítsd a vezetésedet esőhöz, nedves úthoz, ködhöz, hóhoz, '
        'sötétséghez és hőséghez',
    asset: 'assets/academy/driving/m05_wetter.svg',
    slides: [
      SafetySlide(
        title: 'A nedvesség mindent megváltoztat',
        blocks: [
          ParagraphBlock(
            'Nedves úton jelentősen csökken a tapadás — a fékút '
            'számottevően meghosszabbodik, sok helyzetben közel a '
            'kétszeresére. Különösen kritikus a hosszú száraz időszak '
            'utáni első eső: az olaj és a gumi az úton a vízzel csúszós '
            'filmet képez.',
          ),
          FactsBlock([
            FactItem('akár ×2', 'ilyen hosszú lesz a fékút nedves úton'),
            FactItem('3 mp+', 'minimális követési távolság 2 másodperc '
                'helyett'),
            FactItem('−20 %', 'tempó, durva tájékozódásként'),
          ]),
          BulletsBlock([
            'Korábban és lágyabban fékezz, ne a kanyarban',
            'A kormánymozdulatokat puhán végezd, ne rántva',
            'Figyelj az útburkolati jelekre, a csatornafedelekre és a '
                'villamossínekre — ott a legcsúszósabb',
            'Kerüld a keréknyomokat, ott áll meg a víz',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A sebesség kötelesség, nem választás',
            text: 'A § 3 Abs. 1 StVO megköveteli, hogy a sebességedet az '
                'út-, forgalmi, látási és időjárási viszonyokhoz igazítsd. '
                'Egy nedves úti balesetnél nem segít rajtad a megengedett '
                'tempó.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Aquaplaning: mi történik valójában',
        asset: 'assets/academy/driving/m05b_aquaplaning.svg',
        blocks: [
          ParagraphBlock(
            'Az aquaplaning azt jelenti: a gumi és az úttest közé '
            'vízfilm tolakszik. A gumi felúszik. Ettől a pillanattól a '
            'kormányzásnak és a féknek nincs többé hatása — nem '
            'kevesebb, hanem semmi.',
          ),
          ParagraphBlock(
            'A profilhornyoknak pontosan egy feladatuk van: elvezetni a '
            'vizet a gumi elől. Nagyobb tempónál egy guminak minden '
            'másodpercben több liter vizet kell kiszorítania. Minél '
            'laposabb a profil és minél nagyobb a tempó, annál előbb nem '
            'bírja már.',
          ),
          FactsBlock([
            FactItem('1,6 mm', 'törvényi minimum — aquaplaninghez már '
                'túl kevés'),
            FactItem('3 mm', 'gyakorlati alsó határ nedves időben'),
            FactItem('tempó²', 'ilyen erősen nő az aquaplaning veszélye '
                'a sebességgel'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Miről veszed észre korán',
            text: 'A kormány hirtelen könnyűvé válik, a menetzaj '
                'megváltozik, a fordulatszám ok nélkül emelkedik. Ezek '
                'azok a másodpercek, amelyekben még le tudod venni a '
                'gázt.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Aquaplaning: a helyes reakció',
        blocks: [
          DoDontBlock(
            doTitle: 'Álló víznél helyesen',
            dos: [
              'Levenni a gázt — csak azt, nem hirtelen teljesen',
              'A kormányt nyugodtan egyenesen tartani',
              'Kuplungot lenyomni, illetve kikapcsolni a hajtást',
              'Hagyni kigurulni a kocsit, amíg a gumik újra fognak',
              'Csak azután óvatosan kormányozni vagy fékezni',
            ],
            dontTitle: 'Hibás',
            donts: [
              'Erősen fékezni — a kerekek hatástalanul blokkolnak',
              'Rántva kormányozni vagy ellenkormányozni',
              'Gyorsítani, hogy „átjuss"',
              'Sávot váltani, miközben a gumik felúsznak',
            ],
          ),
          RevealBlock(
            prompt: 'Esettanulmány: a főúton egy zivatar után víz áll a '
                'jobb keréknyomban. 80 km/h-val hajtasz, mögötted egy '
                'személyautó szorongat. Mit teszel?',
            answer: 'Jelentősen vedd le a gázt, mielőtt a vízbe hajtasz '
                '— nem benne. Tartsd egyenesen a kormányt, és hagyd a '
                'türelmetlent türelmetlenkedni; egy ráfutásos baleset '
                'javítható, egy kirepülés a szembejövő forgalomba nem. '
                'Aki helyette a víz közepén fékez vagy kitér, pont azt a '
                'kontrollvesztést provokálja ki, amit el akar kerülni. '
                'Ha lehet: a víz után húzódj jobbra és engedd el a '
                'türelmetlent.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'A felúszó gumi nem kormányoz',
            text: 'Amíg a vízfilm tart, minden kormánymozdulat '
                'hatástalan — és csak akkor hat, hirtelen, amikor a gumi '
                'újra fog. Pont ebből keletkezik a megcsúszás.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Profilmélység és téli gumi',
        blocks: [
          TableBlock(
            headers: ['Helyzet', 'Profil / gumi'],
            rows: [
              ['Törvényi minimum', '1,6 mm — egész évben'],
              ['Nyár, nedves út', '3 mm-től ajánlott'],
              ['Tél, hó és latyak', '4 mm-től ajánlott'],
              ['Síkosság, hó, jég', 'téli gumi Alpine-jellel'],
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Helyzetfüggő téligumi-kötelezettség',
            text: 'A § 2 Abs. 3a StVO szerint jégen, hósíkosságon, '
                'latyakban, jég- vagy zúzmarasíkosságon csak télre '
                'alkalmas gumival hajthatsz. A szabálysértés bírságba és '
                'egy pontba kerül — mások akadályozása esetén többe.',
          ),
          BulletsBlock([
            'A téli gumit az Alpine-jelről ismered fel (hegy '
                'hópehellyel)',
            'A télre alkalmas gumik is alig hatásosak túl kevés '
                'profillal',
            'Figyelj a gumi korára: a gumianyag kikeményedik és elveszti '
                'a tapadását, akkor is, ha a profil még megvan',
            'A vékony profilt jelentsd, mielőtt jön az első fagy — ne '
                'másnap reggel',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Hó, jég és jégkaparás',
        asset: 'assets/academy/driving/m05c_winter.svg',
        blocks: [
          ParagraphBlock(
            'Síkosságnál mindenre ugyanaz érvényes: lágyan. Lágyan '
            'elindulni, lágyan fékezni, lágyan kormányozni. Minden rántó '
            'mozdulat túlterheli az amúgy is csekély tapadást. A hidak, '
            'az erdős szakaszok és az árnyékos helyek fagynak be először '
            '— és olvadnak fel utoljára.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Semmi „kukucskálólyuk"',
            text: 'Minden ablaknak, tükörnek, lámpának és a rendszámnak '
                'szabadnak kell lennie (§ 23 Abs. 1 StVO). A kikapart '
                'kukucskálólyuk szabálysértés — és baleset esetén súlyos '
                'felróhatóság. A tetőn lévő havat is le kell szedni '
                'indulás előtt.',
          ),
          DoDontBlock(
            doTitle: 'Téli rutin',
            dos: [
              'Minden ablakot és tükröt teljesen lekaparni',
              'A tetőt, a lámpákat és a rendszámot megtisztítani a '
                  'hótól',
              'A fellépőket és a kapaszkodókat megtisztítani a jégtől '
                  'és a latyaktól',
              'Fagyálló ablakmosót utántölteni',
              'Jelentősen korábban elindulni ahelyett, hogy útközben '
                  'hoznád be',
            ],
            dontTitle: 'Téli hibák',
            donts: [
              'Elindulni, amíg az ablak még olvad',
              'Forró vizet önteni az ablakra',
              'Latyakon fékezni és közben kormányozni',
              'Figyelmen kívül hagyni a jeges fellépőket — itt esel el',
            ],
          ),
          FactsBlock([
            FactItem('0 °C', 'innentől először a hidak és az árnyékos '
                'helyek'),
            FactItem('×2 – ×10', 'ennyivel lesz hosszabb a fékút havon '
                'és jégen'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Köd, szürkület, sötétség',
        blocks: [
          ParagraphBlock(
            'Rossz látási viszonyoknál nemcsak a látás nehezebb, hanem '
            'az is, hogy téged lássanak. Kapcsold fel időben a '
            'világítást — kétség esetén fél órával korábban, mint '
            'szükséges.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Hüvelykujjszabály ködben',
            text: 'A látótávolság méterben megegyezik a maximális '
                'tempóval km/h-ban. Ha csak 50 méterre látsz, legfeljebb '
                '50 km/h-val hajts — és 50 méter alatti látótávolságnál '
                'amúgy is 50-es tempó a felső határ.',
          ),
          BulletsBlock([
            'Ködlámpát csak valódi látáskorlátozásnál, nem állandó '
                'világításként',
            'Hátsó ködlámpát csak 50 méter látótávolság alatt — erősen '
                'vakítja a mögötted haladót',
            'Használd tájékozódásra az út szélén lévő '
                'irányoszlopokat',
            'Szürkületben különösen figyelj a sötét ruhás gyalogosokra',
            'Belső világítás ki, az ablakok belül tiszták — mindkettő '
                'különben az éjszakai látásodba kerül',
          ]),
          FactsBlock([
            FactItem('50 m', 'két irányoszlop közti távolság lakott '
                'területen kívül'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Vihar és oldalszél',
        blocks: [
          ParagraphBlock(
            'A dobozos furgonod nagy, magas felület — oldalszélben '
            'teljesen másként viselkedik, mint egy személyautó. '
            'Különösen veszélyesek azok a helyek, ahol a szél hirtelen '
            'lép fel: hidak, erdőkijáratok, épületek közti rések, és '
            'amikor egy kamion előz.',
          ),
          BulletsBlock([
            'Jelentősen csökkentsd a tempót, mindkét kéz a kormányon',
            'Ismert szeles helyeknél előre erősítsd meg a fogást és '
                'számíts széllökésre',
            'Egy kamion előzése után számíts széllökésre',
            'Viharban ne parkolj fák alatt és állványok mellett',
            'Szélben tartsd meg az ajtókat — kirántja és megrongálja '
                'őket',
          ]),
          RevealBlock(
            prompt: 'Esettanulmány: viharriasztás van, üresen hajtasz át '
                'egy autópályahídon. Miért kritikus pont az, hogy üres '
                'vagy?',
            answer: 'Mert hiányzik a járműről a súly, ami az úton '
                'tartja. Egy üres dobozos furgon ugyanakkora támadási '
                'felületet kínál, mint egy megrakott, de jó egyharmaddal '
                'kevesebbet nyom — egy széllökés jóval erősebben tolja '
                'el. Helyes: a híd előtt levenni a tempót, mindkét kéz a '
                'kormányra, a híd végén számítani a széllökésre, és nem '
                'egy kamion mellett haladni.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Hőség és hosszú túrák',
        blocks: [
          ParagraphBlock(
            'Nyáron olyan járműben dolgozol, amely a napon erősen '
            'felmelegszik, és közben sok kilométert gyalogolsz. Egy '
            'túlhevült, kiszáradt sofőr mérhetően lassabban reagál — a '
            'hatás a fáradtságéhoz hasonlítható.',
          ),
          FactsBlock([
            FactItem('2–3 l', 'folyadék műszakonként hőségben'),
            FactItem('> 60 °C', 'belső hőmérséklet egy napon álló '
                'járműben'),
          ]),
          BulletsBlock([
            'Igyál rendszeresen, mielőtt szomjas lennél',
            'Szünetek árnyékban, ne a felforrósodott vezetőfülkében',
            'Fejfedő és napvédelem a hosszú gyalogutakhoz',
            'Keringési panaszoknál azonnal jelentsd és tarts szünetet',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Soha ne hagyj hátra senkit',
            text: 'Soha ne hagyj állatot vagy embert a felforrósodott '
                'kocsiban — „csak öt percre" sem, és résnyire nyitott '
                'ablakkal sem. A belső tér percek alatt életveszélyesen '
                'felforrósodik.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista: nehéz körülmények',
        blocks: [
          ChecklistBlock(
            title: 'Időjárásnál és rossz látási viszonyoknál',
            items: [
              'A tempót és a távolságot igazítom, nem csak a táblához',
              'Nedves úton legalább 3 másodperc távolságra emelem',
              'Aquaplaningnál: gázt le, egyenesen, nem fékezni',
              'Ismerem a profilmélységemet és korán jelentem a vékony '
                  'gumit',
              'Minden ablakot lekaparok, semmi kukucskálólyuk',
              'Leszedem a havat a tetőről, a lámpákról és a '
                  'rendszámról',
              'Hidaknál és erdőkijáratoknál számítok oldalszélre',
              'Eleget iszom és árnyékban tartok szünetet',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M6
  SafetyChapterContent(
    id: 'm6',
    title: 'Figyelemelterelés, fáradtság és időnyomás',
    summary: 'Ismerd fel a balesetek emberi fő okait, és lépj fel ellenük '
        'aktívan',
    asset: 'assets/academy/driving/m06_ablenkung.svg',
    slides: [
      SafetySlide(
        title: 'Telefon a volánnál: TILOS',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'A kézben tartott telefon menet közben tilos',
            text: 'Sem telefonálni, sem gépelni, sem megnézni valamit — '
                'és zenét, podcastot vagy üzenetet választani sem.',
          ),
          ParagraphBlock(
            'Egyértelműen és kivétel nélkül. Ez nemcsak a mi '
            'cégszabályunk, hanem törvény. És minden olyan elektronikus '
            'eszközre vonatkozik, amely kommunikációt, tájékoztatást '
            'vagy szervezést szolgál — tehát a szkennerre is.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 23 Abs. 1a StVO',
            text: 'Aki járművet vezet, elektronikus eszközt csak akkor '
                'használhat, ha ahhoz sem felvennie, sem tartania nem '
                'kell. Már a kézbe vétel vagy a kézben tartás maga a '
                'szabálysértés — függetlenül attól, mit csinálsz vele.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A szakasz vakon',
        asset: 'assets/academy/driving/m06b_handy.svg',
        blocks: [
          ParagraphBlock(
            'Egy pillantás a kijelzőre nem egy másodperc — átlagosan '
            'két-három másodpercig tart, egy elolvasott üzenet inkább '
            'ötig. Ez alatt csukott szemmel vezetsz. Számold ki egyszer '
            'méterben.',
          ),
          FactsBlock([
            FactItem('14 m/mp', 'ennyit teszel meg 50-es tempónál '
                'másodpercenként'),
            FactItem('28 m', 'vakon 2 másodperc telefonra pillantásnál'),
            FactItem('kb. 70 m', 'vakon, ha elolvasol egy üzenetet'),
          ]),
          RevealBlock(
            prompt: 'Számolási feladat: 30 km/h-val hajtasz egy '
                'lakó-pihenő övezetben, és 3 másodpercig a szkennerre '
                'nézel. Milyen messzire mész vakon — és elég ez egy '
                'balesethez?',
            answer: '30 km/h-nál jó 8 métert teszel meg másodpercenként, '
                '3 másodperc alatt tehát nagyjából 25 métert. Ez több, '
                'mint a teljes megállási út ennél a tempónál (18 méter). '
                'Másképp fogalmazva: vakon futsz be egy olyan szakaszt, '
                'amelyen látva már rég megállhattál volna. Aki azt hiszi, '
                'hogy alacsony tempónál egy pillantás nem kritikus, '
                'összekeveri a lassút a biztonságossal — pont a '
                'lakó-pihenő övezetekben szaladnak a gyerekek '
                'figyelmeztetés nélkül az úttestre.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Zene, navi, szkenner — mindent előre',
        blocks: [
          ParagraphBlock(
            'A zene és a podcast rendben van — de nem kézben tartott '
            'telefonnal. Mindent indulás előtt, állva válassz ki és '
            'indíts el: lejátszási listát, hangerőt, navi-célt, '
            'következő megállót. Ha egyszer megy, menet közben többé '
            'nem nyúlsz az eszközhöz.',
          ),
          DoDontBlock(
            doTitle: 'Megengedett',
            dos: [
              'A lejátszási listát és a hangerőt előre, állva '
                  'beállítani',
              'A navi célját indulás előtt megadni',
              'A telefont a tartóban hagyni és csak ránézni',
              'Kihangosítón keresztül, kézmentesen beszélni',
              'Minden máshoz röviden megállni',
            ],
            dontTitle: 'Tilos',
            donts: [
              'Számot vagy podcastot váltani menet közben',
              'Üzenetet olvasni vagy írni menet közben',
              'A telefont a piros lámpánál kézbe venni',
              'A szkennert vagy a megállólistát gurulás közben '
                  'kezelni',
              'Az eszközt kivenni a tartóból, hogy jobban lásd',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Semmi fülhallgató',
            text: 'Menet közben semmilyen fejhallgató vagy fülhallgató — '
                'egyik fülön sem. Hallanod kell a forgalmat, a dudálást, '
                'a kiáltásokat és a megkülönböztetett járműveket. '
                'Manőverezéskor a hallásod gyakran az egyetlen '
                'figyelmeztetés.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Az egyetlen kivétel: álló helyzetben, motor kikapcsolva',
        blocks: [
          ParagraphBlock(
            'A telefont, a szkennert és a navit csak biztonságos álló '
            'helyzetben kezeled. A gyakorlati menet a megállónál: '
            'megállni, motort le, eszközt kezelni, aztán kiszállni. És '
            'indulás előtt: beülni, célt és zenét beállítani, aztán '
            'indítani.',
          ),
          RevealBlock(
            prompt: 'Mikortól számít jogilag az „álló helyzet" — és mi a '
                'helyzet a start-stop automatikával a piros lámpánál?',
            answer: 'Jogilag az álló helyzet csak akkor számít, ha a '
                'motor ki van kapcsolva. A kivétel kifejezetten nem '
                'érvényes, ha a motor csak egy automatikus start-stop '
                'funkció miatt áll. A piros lámpánál tehát nem veheted '
                'kézbe az eszközt — akkor sem, ha a motor éppen csendben '
                'van.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Kivétel csak kikapcsolt motornál',
            text: 'A kezelés csak akkor megengedett, ha a jármű áll és a '
                'motor ki van kapcsolva. Egy automatikus start-stop '
                'leállás ehhez nem elég.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Mennyibe kerül',
        blocks: [
          FactsBlock([
            FactItem('100 € + 1 pont', 'telefon a kézben menet közben'),
            FactItem('150 € + 2 pont', 'veszélyeztetéssel, plusz 1 hónap '
                'vezetéstől eltiltás'),
            FactItem('200 € + 2 pont', 'rongálással, plusz 1 hónap '
                'vezetéstől eltiltás'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Próbaidő',
            text: 'A jogosítvány próbaideje alatt ehhez jön egy '
                'utóképzés és a próbaidő 4 évre hosszabbítása.',
          ),
          ParagraphBlock(
            'Számodra hivatásos sofőrként az eltiltás azt jelenti: egy '
            'hónapig nincs munka. És ha a figyelemelterelésből sérültes '
            'baleset lesz, az nem marad bírságnál — akkor a közúti '
            'közlekedés veszélyeztetésének vádja merül fel (§ 315c '
            'StGB), és az bűncselekmény.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'A legegyszerűbb biztosítás',
            text: 'A telefont letenni semmibe sem kerül, és megvédi a '
                'jogosítványodat, a munkahelyedet és éles helyzetben egy '
                'életet.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A figyelemelterelésnek sok formája van',
        blocks: [
          ParagraphBlock(
            'Nemcsak a telefon: evés, ivás, csomagok keresése, '
            'beszélgetések, bosszúság az előző ügyfél miatt, gondolatok '
            'a következő megállónál. Figyelemelterelés minden, ami a '
            'szemet, a kezet vagy a fejet elveszi az úttól.',
          ),
          DoDontBlock(
            doTitle: 'Rendben menet közben',
            dos: [
              'Az útra nézni',
              'Kihangosítón keresztül, kézmentesen beszélni',
              'Rövid pillantások a tükrökbe',
              'Minden máshoz röviden megállni',
            ],
            dontTitle: 'Nincs rendben',
            donts: [
              'Ételt vagy italt kicsomagolni',
              'A raktérben a következő csomagot keresni',
              'A szkennert vagy a megállólistát vezetés közben '
                  'kezelni',
              'Vezetés közben fejben újrarendezni az útvonalat '
                  'ahelyett, hogy röviden megállnál',
            ],
          ),
          RevealBlock(
            prompt: 'Esettanulmány: induláskor észreveszed, hogy rossz '
                'küldeményt fogtál meg. A helyes megálló 300 méterrel '
                'arrébb van. Mit teszel?',
            answer: 'Elhajtasz a következő biztonságos megállóig, '
                'megállsz, motort le, aztán a raktérben cserélsz. A '
                'hátranyúlás menet közben az a klasszikus helyzet, '
                'amelyben a sofőrök elhagyják a sávot — közben egyszerre '
                'fordítod el a fejed és a felsőtested. A 300 méter '
                'kerülő 30 másodpercig tart, egy súrolt kár a nap '
                'maradékáig.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Fáradtság: a tested nem alkuszik',
        asset: 'assets/academy/driving/m06c_muedigkeit.svg',
        blocks: [
          ParagraphBlock(
            'A fáradtság nem akarat kérdése. Egy bizonyos ponttól az '
            'agyad rövid időre kikapcsol — akár akarod, akár nem. Az '
            'alattomos benne: pont ebben a fázisban becsülöd túl a '
            'legjobban a saját éberségedet.',
          ),
          SubheadBlock('A figyelmeztető jelek, amiket komolyan kell '
              'venned'),
          BulletsBlock([
            'Gyakori ásítás, égő vagy nehéz szemek',
            'Nem emlékszel az utolsó kilométerekre',
            'Elmulasztasz elágazásokat vagy megállókat',
            'Az üléstávolság hirtelen rossznak érződik, csúszkálsz',
            'Nyugtalanul haladsz a sávban vagy folyton korrigálsz',
            'Fázás és nyaki feszülés külső ok nélkül',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Kockázatos időszakok',
            text: 'A legveszélyesebb a kora reggel, az ebéd utáni '
                'holtpont és a túra utolsó órája. Pont oda tervezd a '
                'szüneteidet.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A mikroalvás méterben',
        blocks: [
          ParagraphBlock(
            'Egy mikroalvás jellemzően két-öt másodpercig tart. Ez '
            'rövidnek hangzik — amíg ki nem számolod méterben.',
          ),
          FactsBlock([
            FactItem('56 m', '50-es tempónál 4 másodperc mikroalvásnál'),
            FactItem('89 m', '80-as tempónál 4 másodperc alatt'),
            FactItem('111 m', '100-as tempónál 4 másodperc alatt'),
          ]),
          RevealBlock(
            prompt: 'Számolási feladat: 80 km/h-val hajtasz országúton '
                'és 4 másodpercre elbóbiskolsz. Milyen messzire mész '
                'kontroll nélkül — és mi van ezen a szakaszon?',
            answer: '80 km/h nagyjából 22 méter másodpercenként, 4 '
                'másodperc alatt tehát körülbelül 89 méter. Ezen a '
                'szakaszon egy országúton jellemzően van egy kanyar, egy '
                'fasor és a szembejövő forgalom. És a telefonra '
                'pillantással ellentétben ez alatt nem kormányzol — a '
                'jármű kisodródik a sávból. Ezért a mikroalvás ellen '
                'csak egy dolog segít: előtte megállni.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Ennek nincs kicsi változata',
            text: 'Aki egyszer elbóbiskolt, újra el fog — többnyire '
                'néhány percen belül. Az út itt ér véget, nem a '
                'következő megállónál.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Mi segít — és mi nem',
        blocks: [
          DoDontBlock(
            doTitle: 'Valóban hat',
            dos: [
              'Megállni és 15–20 percre lehunyni a szemed',
              'Kiszállni, sétálni, friss levegő és mozgás',
              'Enni és inni valamit',
              'Jelenteni a túrát és támogatást kérni, ha nem elég',
            ],
            dontTitle: 'Nem hat (vagy csak percekig)',
            donts: [
              'Ablakot le és hangos zene',
              'Kávé az alvás pótlására',
              'Beszélgetéssel ébren tartani magad',
              'Gyorsabban hajtani, hogy előbb végezz',
            ],
          ),
          ParagraphBlock(
            'Egy 15–20 perces rövid alvás utána mozgással az egyetlen '
            'intézkedés, ami rövid távon valóban hoz valamit. Minden más '
            'csak néhány kilométerrel tolja el a problémát.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Vezetésre alkalmatlanság',
            text: 'Aki felismerhető kimerültség ellenére továbbhajt, '
                'vezetésre alkalmatlanul vezeti a járművet. Ha ebből '
                'veszélyeztetés lesz, az már nem bírság, hanem '
                'bűncselekmény (§ 315c StGB).',
          ),
        ],
      ),
      SafetySlide(
        title: 'Okos időnyomás-kezelés és ellenőrzőlista',
        blocks: [
          ParagraphBlock(
            'Az időnyomás valós — de a száguldás és a kapkodás alig '
            'spórol időt, és sok kockázatba kerül. A gyorsabb '
            'vezetésből származó időnyereség városi forgalomban percekben '
            'mérhető; egyetlen manőverezési kár egy órádba kerül.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ha nem jön ki a terv',
            text: 'Ez nem biztonsági probléma, ez tervezési kérdés — '
                'jelezd korán ahelyett, hogy a volánnál egyenlítenéd ki. '
                'Egy 13 órai jelzés segít, egy 18 órai már nem.',
          ),
          ChecklistBlock(
            title: 'Ezt viszem magammal a 6. modulból',
            items: [
              'A telefonomat menet közben nem érintem meg',
              'A zenét, a navit és a szkennert indulás előtt állítom '
                  'be',
              'Tudom, hogy az „álló helyzet" csak kikapcsolt motornál '
                  'számít',
              'Nem hordok fülhallgatót',
              'Ismerem a személyes fáradtságjeleimet',
              'Fáradtságnál megállok ahelyett, hogy kitartanék',
              'Egy irreális tervet korán és őszintén jelzek',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M7
  SafetyChapterContent(
    id: 'm7',
    title: 'Munkabalesetek: be- és kiszállás, emelés, esések',
    summary: 'Kerüld el a vezetésen kívüli sérüléseket — hangsúly a '
        'biztonságos be- és kiszálláson',
    asset: 'assets/academy/driving/m07_ein_aussteigen.svg',
    slides: [
      SafetySlide(
        title: 'Miért ez a nap legfontosabb mozdulata',
        blocks: [
          ParagraphBlock(
            'Túránként több tucatszor szállsz be és ki — ez az a '
            'mozdulat, amit a leggyakrabban végzel. Pont ezért történik '
            'itt a legtöbb sérülés: kificamodás, megcsúszás a fellépő '
            'peremén, esés a kocsiból, félrelépés a forgalomba.',
          ),
          FactsBlock([
            FactItem('100.000', 'csúszásos, botlásos és eséses baleset '
                'hivatásos sofőröknél évente'),
            FactItem('24', 'kiesett munkanap átlagosan esésenként'),
            FactItem('No. 1', 'a leggyakoribb sérüléstípus a '
                'kézbesítésben'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A BG Verkehr figyelmeztet',
            text: 'A BG Verkehr (a német közlekedési szakmai '
                'baleset-biztosító) kifejezetten figyelmeztet, hogy a '
                'be- és kiszállásnál történő lezuhanások súlyos, '
                'olykor halálos sérülésekhez vezetnek.',
          ),
          ParagraphBlock(
            'A biztonságos és a veszélyes kiszállás között két másodperc '
            'a különbség. Napi 250 kiszállásra vetítve ez jó nyolc perc '
            '— a tested legolcsóbb biztosítása.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A hárompontos szabály (2+1)',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Két kéz és egy láb — mindig',
            text: 'A BG Verkehr központi szabálya: két kéz és egy láb '
                'mindig érintkezik a járművel — „2+1".',
          ),
          ParagraphBlock(
            'Vagyis bármikor három szilárd érintkezési pontod van, '
            'mielőtt a következőt elengeded. Így egyetlen megcsúszás '
            'sosem válhat eséssé, mert még mindig tart két pont. Mindig '
            'csak egy pontot mozgass, sosem kettőt egyszerre.',
          ),
          RevealBlock(
            prompt: 'Melyik három érintkezési pontról van szó — és mi '
                'nem tartozik kifejezetten ide?',
            answer: 'Bal kéz a kapaszkodón, jobb kéz a kapaszkodón, egy '
                'láb a fellépőn. Nem tartozik ide: a kormány, az '
                'ajtóperem, az ülés, a gumi és a kerékagy. Az ajtóperem '
                'és a kormány enged vagy elfordul — pont akkor, amikor '
                'szükséged lenne rájuk.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Vezérgondolat',
            text: 'Előbb leszállni, aztán nyúlni. A tárgyakat először '
                'tedd le a járműben, aztán szabad kézzel szállj ki.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Helyesen be, helyesen ki',
        blocks: [
          BulletsBlock([
            'Beszállás: arccal előre, a jármű felé',
            'Kiszállás: háttal kifelé, arccal a jármű felé — mint egy '
                'létrán, soha ne háttal az ajtónak kifordulva',
            'Használd az összes fellépőt — egyet se hagyj ki',
            'Használd a kapaszkodókat, ne az ajtóperemet vagy a '
                'kormányt vészkapaszkodóként',
            'A raktérből kiszállásnál ugyanez a szabály: arccal a jármű '
                'felé, fokról fokra',
          ]),
          StepsBlock([
            'Megállni és rögzíteni a járművet',
            'A tárgyakat letenni a járműben',
            'A forgalmat vállpillantással és tükörrel ellenőrizni',
            'Az ajtót kontrollálva kinyitni',
            'Megfordulni, arccal a jármű felé',
            'Három érintkezési pontot kialakítani',
            'Fokról fokra leszállni',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Soha ne ugorj',
        asset: 'assets/academy/driving/m07b_springen.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Az ugrás a leggyakoribb hiba',
            text: 'A vezetőfülkéből vagy a raktérből való leugrás a '
                'leggyakoribb oka a kificamodott bokáknak, valamint a '
                'térd- és hátsérüléseknek a kézbesítésben.',
          ),
          ParagraphBlock(
            'A furgon rakodópadlója modelltől függően nagyjából 55–75 '
            'centiméterre van az úttest felett. Leugráskor a földet '
            'éréskor a testsúlyod többszöröse hat a bokaízületre, a '
            'térdre és a gerincre — mégpedig minden egyes ugrásnál.',
          ),
          FactsBlock([
            FactItem('55–75 cm', 'a rakodópadló magassága az úttest '
                'felett'),
            FactItem('250+', 'kiszállás túránként — mindegyik számít az '
                'ízületeknek'),
          ]),
          RevealBlock(
            prompt: 'Esettanulmány: esik az eső, kiugrasz a raktérből '
                'egy lejtős járdára nedves avarral. Mi megy itt pontosan '
                'félre?',
            answer: 'Leugrás közben már nem tudod korrigálni a '
                'földet érést — a levegőben vagy, és hogy mi történik '
                'alattad, azt a talaj dönti el. A lejtőn lévő nedves '
                'avar szinte semmilyen súrlódást nem ad: a láb '
                'földet éréskor megcsúszik, az ízület oldalra kifordul. '
                'Aki helyette fokról fokra, három érintkezési ponttal '
                'száll le, megérzi a csúszós talajt, mielőtt a teljes '
                'súlyát ráteszi — és még meg tudja szakítani.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A tipikus hibák',
        blocks: [
          DoDontBlock(
            doTitle: 'Helyes',
            dos: [
              'A tárgyakat először letenni a járműben',
              'Szabad kézzel és három érintkezési ponttal leszállni',
              'A fellépőket és a kapaszkodókat tisztán és szabadon '
                  'tartani',
              'Nedvességnél és jégnél előbb megtisztítani a fokokat',
              'Időt szánni rá — a 180. megállónál is',
            ],
            dontTitle: 'Hibás',
            donts: [
              'Ugrani leszállás helyett',
              'Tele kézzel — telefon, szkenner, kávé, csomagok',
              'A gumit vagy a kerékagyat fellépőnek használni',
              'A telefont nézni leszállás közben',
              'Figyelmen kívül hagyni a nedves, jeges vagy koszos '
                  'fellépőperemet',
              'Az ülésből oldalra kifordulni',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Az utána következő megálló a legveszélyesebb',
            text: 'Egy hosszú állás után merevek a lábak és elment a '
                'koncentráció. Pont akkor történik a félrelépés — szedd '
                'össze magad röviden, aztán szállj ki.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A forgalmi oldal: az alábecsült pillanat',
        blocks: [
          ParagraphBlock(
            'Az alacsony Sprintereknél és furgonoknál gyakran nem a '
            'magasság a probléma, hanem a lépés a haladó forgalomba. Ha '
            'lehet, a járda felőli vagy a biztonságos oldalon szállj ki. '
            'Ne rántsd szélesre az ajtót, mielőtt körülnéztél.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 14 Abs. 1 StVO — be- és kiszállás',
            text: 'Aki be- vagy kiszáll, úgy köteles viselkedni, hogy '
                'kizárt legyen a többi közlekedő veszélyeztetése. Egy '
                'ajtós balesetnél a felelősség gyakorlatilag mindig a '
                'kiszállót terheli.',
          ),
          RevealBlock(
            prompt: 'Az út szélén állsz meg, hátulról közeledik egy '
                'kerékpáros — hogyan szállsz ki?',
            answer: 'Az ajtó kinyitása előtt nézz a vállad fölött és a '
                'tükörbe, engedd el a kerékpárost, és az ajtót csak '
                'kontrollálva, a távolabbi kezeddel nyisd. Az úgynevezett '
                '„holland fogás" — az ajtót a jobb kézzel nyitni — '
                'automatikusan hátrafordítja a felsőtestedet és rákényszerít '
                'a pillantásra. A kerékpárosok és a rollerek szorosan a '
                'kocsi mellett húznak el, és nem számítanak nyíló '
                'ajtóra.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lábbeli és talaj',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A BG Verkehr ajánlása',
            text: 'Olyan lábbeli, amely körbezárja a lábat és '
                'csúszásmentes. Semmi nyitott vagy lejárt cipő. A '
                'bokáig érő munkavédelmi cipő pont azt az ízületet '
                'támasztja meg, amelyik leszálláskor kifordul.',
          ),
          ParagraphBlock(
            'Kiszállás előtt figyelj röviden a talajra: járdaszegély, '
            'lejtő, avar, nedvesség, jég, zúzalék. Havas és jeges időben '
            'tartsd szabadon a kapaszkodókat és a fokokat. Ha lehet, '
            'sík és megvilágított helyen állj meg.',
          ),
          ChecklistBlock(
            title: 'Kiszállás előtt',
            items: [
              'Erős, csúszásmentes lábbeli rajtam',
              'A talaj ellenőrizve — járdaszegély, lejtő, nedvesség, '
                  'jég',
              'A kezek szabadok, a tárgyak letéve',
              'A forgalom vállpillantással és tükörrel ellenőrizve',
              'A fellépők tiszták és szabadok',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Helyes emelés és cipelés',
        blocks: [
          ParagraphBlock(
            'A hát a második leggyakoribb kiesési kockázat az esések '
            'után. És egy eséssel ellentétben a porckorongsérülés nem '
            'egy nap alatt keletkezik — hanem több ezer rossz emelésből '
            'áll össze.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/lift01_nah.svg',
              title: '1 · A terhet közel a testhez',
              caption: 'Menj közel a csomaghoz, mielőtt megemeled. A '
                  'testtől mért minden centiméter távolság '
                  'megsokszorozza a porckorongok terhelését.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift02_hocke.svg',
              title: '2 · Menj guggolásba',
              caption: 'Hajlítsd be a térded és menj guggolásba, '
                  'ahelyett hogy a csípődből előrehajolnál. Az erő a '
                  'lábakból jön — ezek a legerősebb izmaid.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift03_ruecken.svg',
              title: '3 · Tartsd egyenesen a hátad',
              caption: 'Tartsd egyenesen a hátad és a tekinteted előre, '
                  'miközben a lábaiddal felegyenesedsz. A terhelés '
                  'alatti görbe hát a klasszikus porckorong-pozíció.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift04_drehen.svg',
              title: '4 · Ne csavarodj — lépj át',
              caption: 'Soha ne csavarodj el a felsőtesteddel a '
                  'teherrel. Helyette lépj át a lábaiddal és fordítsd el '
                  'az egész testedet. Az emelés plusz csavarodás a '
                  'legveszélyesebb kombináció a gerincnek.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Mennyi a túl nehéz?',
        blocks: [
          ParagraphBlock(
            'Fix kilogrammhatárok nincsenek a törvényben — együtt dönt a '
            'súly, a testtartás, a gyakoriság és a környezet. A '
            'gyakorlatban azonban beváltak tájékoztató értékek.',
          ),
          FactsBlock([
            FactItem('kb. 25 kg', 'tájékoztató érték alkalmi emeléshez '
                '(férfiak)'),
            FactItem('kb. 15 kg', 'tájékoztató érték alkalmi emeléshez '
                '(nők)'),
            FactItem('efelett', 'segédeszközt használni vagy ketten '
                'vinni'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'LasthandhabV (teherkezelési rendelet)',
            text: 'A munkáltatónak a lehető legnagyobb mértékben el kell '
                'kerülnie a kézi emelést és cipelést, és megfelelő '
                'segédeszközöket kell biztosítania. Neked pedig '
                'használnod is kell ezeket a segédeszközöket — nem '
                'dísznek állnak ott.',
          ),
          DoDontBlock(
            doTitle: 'Helyes cipelés',
            dos: [
              'Kézikocsit vagy görgős dobozt használni ahelyett, hogy '
                  'kétszer mennél',
              'A terjedelmes küldeményeket ketten vinni',
              'A látóteret szabadon tartani — ne a rakás fölött '
                  'nézz át',
              'Megemelés előtt meghatározni az utat és a lerakási '
                  'pontot',
            ],
            dontTitle: 'Hibás cipelés',
            donts: [
              'Görbe hát, nyújtott karok',
              'A felsőtesttel elcsavarodni a teherrel',
              'Lendületet venni és rántva megemelni',
              'Olyan tornyokat cipelni, amelyek elveszik a kilátást az '
                  'útról',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Botlás, csúszás, esés az úton',
        blocks: [
          ParagraphBlock(
            'A botlás, a csúszás és az esés a leggyakoribb sérülési ok a '
            'kézbesítésben — gyakoribb, mint bármelyik közlekedési '
            'baleset. És szinte mindig az utolsó métereken történik a '
            'jármű és a bejárati ajtó között.',
          ),
          FactsBlock([
            FactItem('No. 1', 'a leggyakoribb balesettípus a '
                'kézbesítésben'),
            FactItem('utolsó 30 m', 'a jármű és az ajtó között — a '
                'legveszélyesebb szakasz'),
          ]),
          BulletsBlock([
            'Viselj erős, csúszásmentes lábbelit — minden nap, nyáron '
                'is',
            'Síkosságnál tégy kis lépéseket és tedd le a teljes talpad',
            'Nézz olykor az útra is, ne csak a csomagra vagy a '
                'telefonra',
            'Éjjel használj zseblámpát vagy a telefon fényét az úton',
            'Tartsd fejben az útvonal ismert botlásveszélyes helyeit',
          ]),
          RevealBlock(
            prompt: 'Esettanulmány: két csomagot viszel egymáson egy '
                'háromlépcsős bejárati ajtóhoz. Mi itt a valódi '
                'probléma?',
            answer: 'Nem látod a saját lábadat és a lépcsőfokok '
                'peremét. Egy lépcsőfeljáró a fokok látása nélkül a '
                'klasszikus esési helyzet — és tele kézzel sem a '
                'korlátba nem tudsz kapaszkodni, sem az esést nem tudod '
                'felfogni. Helyes: egyesével vinni, a rakást olyan '
                'alacsonyan tartani, hogy lásd a fokokat, vagy '
                'kézikocsit használni. Kétszer menni 40 másodpercig '
                'tart.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Vedd komolyan a kis sérüléseket',
        blocks: [
          ParagraphBlock(
            'Egy megemelt hát vagy egy kificamodott láb rosszabb lesz, '
            'ha folytatod. Egy bagatellből hetek alatt valódi kiesés '
            'lesz — és visszamenőleg a munkával való összefüggést '
            'gyakran már nem lehet igazolni.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A dokumentálás megvéd téged',
            text: 'Minden sérülés a sérülési naplóba (Verbandbuch) '
                'tartozik — a kicsi is. Munkabaleset utáni orvosi '
                'ellátásnál üzemorvoshoz (Durchgangsarzt) mész. '
                'Dokumentáció nélkül nehéz a későbbi elismerés '
                'munkabalesetként.',
          ),
          RevealBlock(
            prompt: 'Miért kellene a kis panaszokat azonnal jelentened — '
                'akkor is, ha tudsz tovább dolgozni?',
            answer: 'Először orvosilag: egy kezeletlen szalagprobléma '
                'rosszabbul gyógyul és visszatér. Másodszor jogilag: '
                'csak az számít később munkabalesetnek, ami '
                'dokumentálva van. Harmadszor mindenki miatt: csak a '
                'bejelentett esetek mutatják meg, hol kell a cégnél egy '
                'lépcsőt, egy fogantyút vagy egy folyamatot javítani. A '
                'jelentés erő, nem gyengeség.',
          ),
          ChecklistBlock(
            title: 'Ezt viszem magammal a 7. modulból',
            items: [
              'Háttal kifelé szállok ki, arccal a jármű felé',
              'Mindig három érintkezési pontot tartok (2 kéz + 1 láb)',
              'Soha nem ugrom ki a vezetőfülkéből vagy a raktérből',
              'Leteszem a tárgyakat, mielőtt kiszállok',
              'Az ajtónyitás előtt a vállam fölött nézek hátra',
              'A lábamból emelek és nem csavarodom el teherrel',
              'Segédeszközöket használok hőstettek helyett',
              'Minden sérülést jelentek, a kicsit is',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M8
  SafetyChapterContent(
    id: 'm8',
    title: 'A bejárati ajtónál: kutyák, emberek és környezet',
    summary: 'Biztonságosan cselekedni a kézbesítési ponton — állatokkal, '
        'emberekkel és a környezettel',
    asset: 'assets/academy/driving/m08_haustuer.svg',
    slides: [
      SafetySlide(
        title: 'A kézbesítési pont: idegen terep',
        blocks: [
          ParagraphBlock(
            'Amint elhagyod a járművet, idegen terepre lépsz, amit nem '
            'ismersz, és amit senki nem biztosított be neked: ismeretlen '
            'utak, laza lapok, sötét lépcsőházak, állatok és emberek a '
            'legkülönbözőbb hangulatban.',
          ),
          FactsBlock([
            FactItem('120+', 'idegen ingatlan túránként'),
            FactItem('30 m', 'gyalogút átlagosan megállónként'),
            FactItem('0', 'ebből ennyi van előkészítve neked'),
          ]),
          ParagraphBlock(
            'Ezért a kézbesítési ponton ugyanaz az alapállás érvényes, '
            'mint a volánnál: előbb nézni, aztán cselekedni. És kétség '
            'esetén: nem kézbesíteni. Egy küldemény, ami nem érkezik '
            'meg, egy ügy — egy sérülés egy kiesés.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ismerd fel helyesen a kutyákat',
        asset: 'assets/academy/driving/m08b_hund.svg',
        blocks: [
          ParagraphBlock(
            'A kutyák a kézbesítők leggyakoribb sérülési okai közé '
            'tartoznak. A kutya szemszögéből behatoló vagy, aki gyorsan '
            'mozog, idegen szagú és nagy tárgyat cipel — a reakció '
            'védekezés, nem rosszindulat.',
          ),
          BulletsBlock([
            'Ne nézz közvetlenül a szemébe — a kutya ezt fenyegetésnek '
                'veszi',
            'Ne fuss el és ne kiabálj, hanem maradj nyugodtan állva',
            'Fordítsd a kutya felé az oldaladat, ne a frontodat',
            'A karok nyugodtan a test mellett, semmi kapkodó mozdulat',
            'A csomag lehet akadály közted és a kutya között',
            'Lassan hátrálj, közben tartsd szemmel a kutyát',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'A nyugalom a legjobb felszerelésed',
            text: 'A kutya a mozgásra és a hangszínre reagál, nem az '
                'érvekre. Lassan, halkan és oldalról — ennyi az egész '
                'technika.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Amikor komolyra fordul',
        blocks: [
          RevealBlock(
            prompt: 'Esettanulmány: a kertkapunál egy nagy kutya áll és '
                'ugat. A kapu csak be van hajtva, az ügyfél azt írta a '
                'szállítási megjegyzésbe: „A kutya kedves." Mit teszel?',
            answer: 'Nem lépsz be az ingatlanra. Egy szállítási '
                'megjegyzés nem biztonsági engedély — az ügyfél a '
                'családdal való bánásmódban ismeri a kutyáját, nem egy '
                'idegen, csomagot cipelő emberrel szemben. Helyes: '
                'hátralépni a kaputól, megpróbálni csengetni vagy '
                'telefonálni, a küldeményt dokumentáltan nem '
                'kézbesíteni, és a megjegyzést berögzíteni a rendszerbe, '
                'hogy a következő kolléga előre figyelmeztetve legyen. '
                'Egy harapás hetekbe kerül neked — a küldemény az '
                'ügyfélnek egy napba.',
          ),
          DoDontBlock(
            doTitle: 'Helyes',
            dos: [
              'A kapu kinyitása előtt figyelni a kutyahangokra és a '
                  'tálakra',
              'Szabadon futó kutyánál be sem lépni',
              'A kollégáknak szóló megjegyzéseket berögzíteni a '
                  'rendszerbe',
              'Harapásnál vagy karcolásnál: azonnal jelenteni és '
                  'orvoshoz menni',
            ],
            dontTitle: 'Hibás',
            donts: [
              'Megsimogatni vagy megetetni a kutyát',
              'Az állat mellett elhaladva az ajtóhoz menni',
              'Elfutni vagy a csomaggal a kutyára ütni',
              'A „nem bánt" kijelentésre hagyatkozni',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Minden kutyaharapás orvoshoz tartozik',
            text: 'Egy kis harapás vagy karcolás is elfertőződhet. '
                'Azonnal kitisztítani, orvossal elláttatni, a sérülési '
                'naplóba bevezetni és jelenteni — függetlenül attól, '
                'milyen ártalmatlannak látszik.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Biztonságos utak az ingatlanon',
        asset: 'assets/academy/driving/m08c_stolperfallen.svg',
        blocks: [
          ParagraphBlock(
            'A bejárati ajtóhoz vezető út nem olyan munkahely, amit '
            'valaki ellenőrzött volna neked. Használd a kijelölt utakat, '
            'és ne vágj át nedves gyepen, laza lapokon vagy meredek '
            'rézsűkön.',
          ),
          BulletsBlock([
            'Kerti tömlők, kábelek és futtatórácsok a földön',
            'Laza vagy megsüllyedt járdalapok',
            'Nedves avar, moha és alga az árnyékos utakon',
            'Kavics és zúzalék a sima lapokon',
            'Világítatlan lépcsők korlát nélkül',
            'Pinceaknák, nyitott csatornák és fényaknák',
            'Játékok, kerékpárok és kukák az útban',
          ]),
          FactsBlock([
            FactItem('utolsó 30 m', 'itt történik a legtöbb esés'),
            FactItem('1 kéz', 'maradjon szabadon a korláthoz'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'A rövidítés többe kerül, mint amit spórol',
            text: 'A gyepen át vezető út tíz másodpercet spórol. Egy '
                'esés rajta átlagosan 24 kiesett munkanapba kerül.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lépcsők, pince és sötétség',
        blocks: [
          ParagraphBlock(
            'A lépcsőházakban és a hátsó udvarokban két dolog jön '
            'össze: rossz világítás és ismeretlen lépcsőfok-magasságok. '
            'A kettő együtt a leggyakoribb esési helyzet a járművön '
            'kívül.',
          ),
          BulletsBlock([
            'Mindig tarts egy kezet szabadon a korláthoz',
            'Kapcsold fel a villanyt ahelyett, hogy „így is megy"',
            'Használj zseblámpát vagy telefonfényt — de menet közben ne '
                'nézz a kijelzőre',
            'Lépcsőknél tartsd olyan alacsonyan a rakást, hogy lásd a '
                'fokokat',
            'Figyelj a régi épületek eltérő lépcsőfok-magasságaira',
          ]),
          RevealBlock(
            prompt: 'Egy sötét pincefolyosóra kell kézbesítened. A '
                'villanykapcsoló nem működik. Mi a helyes döntés?',
            answer: 'Ne menj be. Egy világítatlan folyosó ismeretlen '
                'lépcsőfokokkal, pinceaknákkal és lerakott holmival nem '
                'olyan hely, ahová csomaggal a kezedben belépsz — és '
                'kétség esetén senki nem tudja, hogy ott vagy. Helyes: '
                'becsengetni az ügyfélhez, biztonságos helyen átadni, '
                'vagy a küldeményt dokumentáltan nem kézbesíteni. A '
                'telefonfény nem pótolja a világítást, mert ahhoz egy '
                'kéz kell, amelyre a korlátnál van szükséged.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Emberek: deeszkalálni, nem nyerni',
        blocks: [
          ParagraphBlock(
            'Az ügyfél számára te vagy egy egész konszern arca — és '
            'ezért néha olyan bosszúságot kapsz meg, ami nem neked '
            'szól. Barátságosnak, nyugodtnak és profinak maradni nemcsak '
            'udvarias, hanem a leghatásosabb biztonsági intézkedésed.',
          ),
          StepsBlock([
            'Nyugodt hang, lassú beszédtempó, nyitott testtartás',
            'Meghallgatni és megnevezni a kérést ahelyett, hogy azonnal '
                'ellentmondanál',
            'Annál maradni, amit te meg tudsz tenni — semmi ígéret '
                'mások nevében',
            'Távolságot tartani: legalább egy karnyi, a menekülési út '
                'szabad',
            'Ha eszkalálódik: befejezni a beszélgetést és visszamenni a '
                'járműhöz',
          ]),
          RevealBlock(
            prompt: 'Valaki hangoskodik, nagyon közel jön hozzád és '
                'elzárja az utat a járműved felé. Mi érvényes?',
            answer: 'A te biztonságod minden kézbesítés előtt van. Nem '
                'vitatkozni, nem akarni igazad lenni, nem provokálni '
                'testi kontaktust. Hátrálni, távolságot teremteni, '
                'hangosan és érthetően távolságot követelni, '
                'vészhelyzetben nyilvános helyre menni és hívni a '
                'rendőrséget. Utána: jelenteni az esetet, hogy a megálló '
                'meg legyen jelölve a kollégáknak. Egyetlen csomag sem '
                'indokol tettlegességet.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A kocsi mint biztonságos hely',
        blocks: [
          ParagraphBlock(
            'A járműved szerszám, raktár és visszavonulási hely. Ha '
            'elhagyod, biztonságosan kell állnia — és ha fenyegetve '
            'érzed magad, ez az a hely, ahová visszamész.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 14 Abs. 2 StVO',
            text: 'Aki elhagyja a járművét, köteles megtenni a szükséges '
                'intézkedéseket a balesetek és a forgalmi zavarok '
                'elkerülésére, és biztosítania kell azt a jogosulatlan '
                'használat ellen.',
          ),
          DoDontBlock(
            doTitle: 'Helyesen leállítva',
            dos: [
              'Motor le, kulcsot magaddal, bezárni',
              'Lejtőn a kéziféket erősen behúzni és a kerekeket '
                  'elfordítani',
              'Elakadásjelző, ha a forgalmi térben állsz meg',
              'A raktér ajtaját becsukni, ha látótávolságon kívül vagy',
            ],
            dontTitle: 'Kockázatos',
            donts: [
              'Jár a motor, nyitva az ajtó — „úgyis gyorsabb"',
              'Benne a kulcs, miközben az ajtónál vagy',
              'Lejtőn elfordított kerekek nélkül leállni',
              'A rakteret nyitva hagyni forgalmas környéken',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista a kézbesítési ponton',
        blocks: [
          ChecklistBlock(
            title: 'Minden megállónál',
            items: [
              'Motor le, kulcs velem, a jármű bezárva',
              'Lejtőn biztosítva, a kerekek elfordítva',
              'Belépés előtt figyeltem a kutyákra és a megjegyzésekre',
              'A kijelölt utakat használtam, nem vágtam át',
              'Egy kéz szabadon a korláthoz',
              'A rakás olyan alacsony, hogy látom a lépcsőfokokat',
              'Sötétben gondoskodtam fényről',
              'Agresszió esetén: távolság, visszavonulás, jelentés',
              'Harapás, esés vagy majdnem-baleset esetén: jelentve',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M9
  SafetyChapterContent(
    id: 'm9',
    title: 'Vészhelyzet és teendők baleset után',
    summary: 'Éles helyzetben nyugodtan, helyesen és jogilag biztosan '
        'cselekedni',
    asset: 'assets/academy/driving/m09_notfall.svg',
    slides: [
      SafetySlide(
        title: 'Biztosítani — jelenteni — segíteni',
        blocks: [
          ParagraphBlock(
            'Baleset vagy műszaki hiba után mindig ugyanaz a sorrend '
            'érvényes: előbb biztonságossá tenni a helyszínt, aztán a '
            'segélyhívás, aztán az elsősegély. Ez a sorrend nem '
            'formalizmus — megakadályozza a második balesetet, amelyben '
            'maguk a segítők válnak áldozattá.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Jegyezd meg a sorrendet',
            text: 'Biztosítani → jelenteni → segíteni. Aki azonnal a '
                'sérülthöz szalad biztosítás nélkül, azt egy országúton '
                'vagy autópályán magát is elütik.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 34 StVO — közlekedési baleset után',
            text: 'Haladéktalanul meg kell állnod, biztosítanod kell a '
                'forgalmat, csekély kár esetén ki kell hajtanod a '
                'veszélyzónából, segítened kell a sérülteken, és lehetővé '
                'kell tenned a személyed és a járműved azonosítását.',
          ),
          ParagraphBlock(
            'És ami nagyon fontos: nyugalom. A csattanás utáni első tíz '
            'másodperc dönt a következő tíz percről. Egyszer mély '
            'levegőt venni, aztán sorban.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Az első öt lépés',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/acc01_absichern.svg',
              title: '1 · Elakadásjelzőt be',
              caption: 'Közvetlenül a megállás után kapcsold be az '
                  'elakadásjelzőt — ez az első jel mindenkinek, aki '
                  'hátulról jön. Sötétben hagyd égve a helyzetjelzőt '
                  'is.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc02_warnweste.svg',
              title: '2 · Láthatósági mellényt felvenni',
              caption: 'A mellényt még kiszállás előtt veszed fel — nem '
                  'utána. Ezért van kéznél a vezetőfülkében, és nem '
                  'hátul a raktérben.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc03_dreieck.svg',
              title: '3 · Elakadásjelző háromszöget kitenni',
              caption: 'Menj a szalagkorlát mögött vagy az út szélén a '
                  'haladási iránnyal szemben, és állítsd ki a '
                  'háromszöget elegendő távolságra — lakott területen '
                  'kb. 50 m, azon kívül 100 m, autópályán 150–200 m.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc04_notruf.svg',
              title: '4 · Segélyhívás 112',
              caption: 'Mondd meg, hol vagy, mi történt, hány sérült van '
                  'és milyen sérüléseket látsz — és csak akkor tedd le, '
                  'ha az ügyeletnek nincs több kérdése.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc05_erstehilfe.svg',
              title: '5 · Elsősegélyt nyújtani',
              caption: 'Megszólítani, légzést ellenőrizni, vérzést '
                  'csillapítani, melegen tartani és a sérültnél '
                  'maradni. Az egyszerű intézkedések is segítenek — a '
                  'semmittevés az egyetlen rossz döntés.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Elakadásjelző, mellény, háromszög',
        blocks: [
          TableBlock(
            headers: ['Terület', 'Háromszög távolsága'],
            rows: [
              ['Lakott területen', 'kb. 50 m'],
              ['Lakott területen kívül', 'kb. 100 m'],
              ['Autópálya', 'kb. 150–200 m'],
              ['Bukkanó vagy kanyar előtt', 'elé, ne mögé'],
            ],
          ),
          ParagraphBlock(
            'Nem a pontos méterérték a döntő, hanem hogy a mögötted jövő '
            'forgalom időben meglásson. Bukkanó vagy kanyar előtt a '
            'háromszög elé tartozik — különben csak akkor válik '
            'láthatóvá, amikor már késő.',
          ),
          FactsBlock([
            FactItem('1', 'láthatósági mellény kötelező a járműben '
                '(§ 53a StVZO)'),
            FactItem('előbb', 'a mellényt felvenni, mielőtt kiszállsz'),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'A szalagkorlát mögött menj',
            text: 'Autópályán és országúton soha ne az úttesten menj a '
                'háromszög kihelyezéséhez, hanem a szalagkorlát mögött '
                'vagy a padkán — a haladási iránnyal szemben, hogy lásd '
                'a forgalmat.',
          ),
          DoDontBlock(
            doTitle: 'A baleset helyszínén helyesen',
            dos: [
              'Elakadásjelző azonnal, mellény kiszállás előtt',
              'A szalagkorlát mögött, a haladási iránnyal szemben '
                  'menni',
              'A háromszöget bukkanó vagy kanyar elé kitenni',
              'A biztosítás után magad is biztonságba menni',
            ],
            dontTitle: 'Tipikus hibák',
            donts: [
              'Mellény nélkül kiszállni és „csak röviden" megnézni',
              'Az úttesten menni a háromszöghöz',
              'A járművek között megállni',
              'Előbb fotózni ahelyett, hogy biztosítanál',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Mentősáv',
        blocks: [
          ParagraphBlock(
            'A mentősávot akkor kell kialakítani, amint a forgalom '
            'lelassul — nem csak akkor, amikor már látszik a kék '
            'villogó. Akkor többnyire már késő, mert senkinek nincs '
            'helye.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 11 Abs. 2 StVO',
            text: 'Autópályákon és lakott területen kívüli, irányonként '
                'legalább két sávos utakon a sávot mindig a legszélső '
                'bal és a közvetlenül mellette jobbra lévő forgalmi sáv '
                'között kell kialakítani — függetlenül attól, hány sáv '
                'van.',
          ),
          FactsBlock([
            FactItem('bal + 1', 'így alakul ki a sáv'),
            FactItem('200 €-tól', 'bírság, ha nem alakítanak ki sávot'),
            FactItem('2 pont', 'plusz általában 1 hónap vezetéstől '
                'eltiltás'),
          ]),
          RevealBlock(
            prompt: 'Egy háromsávos autópályán áll a forgalom. Hol van '
                'pontosan a mentősáv — és hajthatsz-e benne, ha éppen a '
                'lehajtóhoz igyekszel?',
            answer: 'Mindig a bal sáv és a középső sáv között — soha nem '
                'a közép és a jobb között, és soha nem a leállósávon. És '
                'nem: a mentősáv kizárólag a megkülönböztetett '
                'járműveké. Aki arra használja, hogy gyorsabban '
                'kijusson a lehajtóhoz, ugyanolyan magas bírságot fizet, '
                'mint az, aki egyáltalán nem alakít ki sávot, és '
                'kockáztatja az eltiltást. A leállósáv sem alternatíva — '
                'ott haladnak a mentőerők, ha a sáv el van torlaszolva.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Helyes segélyhívás a 112-n',
        blocks: [
          FactsBlock([
            FactItem('112', 'segélyhívó Európa-szerte, egyenleg nélkül '
                'is'),
            FactItem('110', 'rendőrség — tisztán anyagi kárnál'),
          ]),
          StepsBlock([
            'Hol történt? — helység, utca, kilométerjelzés, haladási '
                'irány, feltűnő pontok',
            'Mi történt? — a baleset típusa, érintett járművek, '
                'veszélyek, például kifolyó üzemanyag',
            'Hány sérült van?',
            'Milyen sérülések? — eszméletlen, vérző, beszorult',
            'Várni a visszakérdezésre — az ügyelet fejezi be a '
                'beszélgetést',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A segítségnyújtás kötelező',
            text: 'A segítségnyújtás elmulasztása bűncselekmény '
                '(§ 323c StGB). Azt várják el, ami tőled elvárható — '
                'segélyhívást leadni, biztosítani, megszólítani, '
                'gondoskodni. Senki nem kéri, hogy magadat veszélybe '
                'sodord.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Elsősegély: ami igazán számít',
        blocks: [
          ParagraphBlock(
            'Nem kell mentősnek lenned. A döntő intézkedéseket bárki '
            'meg tudja tenni — és ezek döntenek élet és halál között, '
            'mielőtt a mentő megérkezik.',
          ),
          StepsBlock([
            'Megszólítani és óvatosan megrázni a vállát — reagál a '
                'személy?',
            'Nincs reakció: légutakat szabaddá tenni, fejet hátrahajtani, '
                'a légzést 10 másodpercig ellenőrizni',
            'A légzés normális: stabil oldalfekvés, betakarni, mellette '
                'maradni',
            'Nincs normális légzés: azonnal elkezdeni a mellkasi '
                'nyomkodást és nem abbahagyni',
            'Erős vérzés: közvetlen nyomással ellátni, nyomókötést '
                'felhelyezni',
          ]),
          FactsBlock([
            FactItem('100–120', 'nyomás percenként'),
            FactItem('5–6 cm', 'nyomásmélység felnőttnél'),
            FactItem('10 mp', 'elég a légzés ellenőrzéséhez'),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Bukósisak és beszorultak',
            text: 'A motoros bukósisakot csak akkor veszed le, ha a '
                'személy nem lélegzik normálisan — akkor viszont nincs '
                'más út. A beszorult személyeket nem mozgatod, kivéve ha '
                'közvetlen tűzveszély fenyeget.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Karambol után',
        blocks: [
          ParagraphBlock(
            'Kis károknál is — manőverezési horpadás, letört tükör, '
            'karcolás egy parkoló autón — a teljes program érvényes. A '
            'kárt mindig jelenteni kell, akkor is, ha kicsinek látszik, '
            'és senki nem nézte végig.',
          ),
          ChecklistBlock(
            title: 'Karambol után',
            items: [
              'Megállni és rögzíteni a járművet',
              'Elakadásjelző, szükség esetén mellény és háromszög',
              'Adatokat cserélni, illetve megvárni a tulajdonost',
              'Fotók több szögből, hely, idő, rendszám',
              'Tanúkat és elérhetőségeiket feljegyezni',
              'Ne írj alá felelősségelismerést',
              'A kárt a cégnél jelenteni — még aznap',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Soha ne hajts el egyszerűen',
            text: 'Aki eltávolodik a baleset helyszínéről anélkül, hogy '
                'lehetővé tenné a személye azonosítását, cserbenhagyást '
                'követ el (§ 142 StGB) — ez bűncselekmény pénz- vagy '
                'szabadságvesztéssel, egy kis horpadásnál is.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: manőverezés közben elkapod egy '
                'parkoló autó külső tükrét. Senki nincs a közelben. Elég '
                'egy cédula az ablaktörlő alatt?',
            answer: 'Nem. Egy cédula jogilag nem számít elegendő '
                'azonosításnak — elrepülhet, elázhat vagy eltávolíthatják. '
                'Helyes: megfelelő ideig várni a baleset helyszínén '
                '(helyzettől függően nagyjából 30 percet vesznek '
                'irányértéknek), és ha senki nem jön, értesíteni a '
                'rendőrséget és ott bejelenteni a kárt. Egy cédula '
                'ráadásként jó gyakorlat, de nem pótolja sem a várást, '
                'sem a bejelentést.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Őrizd meg a nyugalmad, jelents, tanulj',
        blocks: [
          ParagraphBlock(
            'Mély levegő, rendezd a helyzetet, tájékoztasd a diszpécsert '
            'és a céget. Egy őszinte, gyors bejelentés mindig jobb, mint '
            'az eltussolás — megvéd téged, megvédi a céget, és minden '
            'esetből tanulunk a következő túrára.',
          ),
          ChecklistBlock(
            title: 'Ezt viszem magammal a 9. modulból',
            items: [
              'Ismerem a sorrendet: biztosítani, jelenteni, segíteni',
              'Felveszem a láthatósági mellényt, mielőtt kiszállok',
              'Elegendő távolságra kiteszem az elakadásjelző '
                  'háromszöget',
              'A mentősávot a bal sáv és a mellette lévő sáv között '
                  'alakítom ki, amint lelassul a forgalom',
              'Ismerem a 112-es segélyhívás öt adatát',
              'Tudom, hogy a semmittevés az egyetlen rossz döntés',
              'Minden kárt még aznap jelentek — a kis horpadást is',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M10
  SafetyChapterContent(
    id: 'm10',
    title: 'Összefoglalás és önkötelezés',
    summary: 'Rögzítsd a tanultakat és alakítsd személyes hozzáállássá',
    asset: 'assets/academy/driving/m10_selbstverpflichtung.svg',
    slides: [
      SafetySlide(
        title: 'A te 7 alapszabályod',
        blocks: [
          BulletsBlock([
            'Az előregondolkodás legyőzi a gyors reagálást',
            'A követési távolság és az igazított tempó mindig ad '
                'tartalékot',
            'Tolatásnál: kiszállni, megnézni, lassan (GOAL)',
            'Telefon és figyelemelterelés csak álló helyzetben, '
                'kikapcsolt motornál',
            'Vedd komolyan a fáradtságot és az időnyomást — a biztonság '
                'a terv előtt',
            'Helyesen kiszállni, emelni, járni — a tested a szerszámod',
            'Vészhelyzetben: biztosítani, jelenteni, segíteni',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ha csak egy szabályt viszel magaddal',
            text: 'Szánd rá az időt, amire szükséged van. A kézbesítés '
                'szinte minden balesete abban a pillanatban keletkezik, '
                'amikor valaki két másodpercet akart spórolni.',
          ),
          DoDontBlock(
            doTitle: 'Így néz ki egy biztonságos nap',
            dos: [
              'Körbejárás, rakomány rögzítve, öv becsatolva',
              'Két másodperc távolság, tekintet messze előre',
              'Minden tolatási manőver előtt kiszállni és megnézni',
              'Telefon a tartóban, szünet fáradtságnál',
              'Háttal kifelé kiszállni három érintkezési ponttal',
            ],
            dontTitle: 'Az öt legdrágább rövidítés',
            donts: [
              'A körbejárást „ma az egyszer" kihagyni',
              'Utánrakodás után nem rögzíteni újra a rakományt',
              'Röviden a kijelzőre nézni, mert szabad az út',
              'Kiugrani a raktérből, mert úgy gyorsabb',
              'Nem jelenteni egy manőverezési kárt',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'A számok, amelyeknek meg kell maradniuk',
        blocks: [
          FactsBlock([
            FactItem('2 mp', 'minimális követési távolság'),
            FactItem('2 + 1', 'érintkezési pont kiszálláskor'),
            FactItem('112', 'segélyhívó sérülteknél'),
          ]),
          TableBlock(
            headers: ['Szám', 'Jelentés'],
            rows: [
              ['2 másodperc', 'minimális távolság, nedves úton 3+'],
              ['18 / 40 m', 'megállási út 30 / 50 km/h-nál'],
              ['28 m', 'vak szakasz 2 mp telefonpillantásnál 50-es '
                  'tempón'],
              ['89 m', '4 mp mikroalvás 80-as tempónál'],
              ['0,8 g', 'előre ható rögzítési erő a rakománynál'],
              ['2 + 1', 'érintkezési pont be- és kiszálláskor'],
              ['70 %', 'a károk ennyi része manőverezéskor keletkezik'],
              ['112', 'segélyhívó sérülteknél'],
            ],
          ),
          ParagraphBlock(
            'Ez a nyolc szám a tréning kemény magja. Aki fejben tartja '
            'őket, akkor is a helyes döntést hozza, amikor nincs idő '
            'gondolkodni.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A személyes önellenőrzésed',
        asset: 'assets/academy/driving/m10b_selbstcheck.svg',
        blocks: [
          ParagraphBlock(
            'Menj végig egyszer őszintén ezen a listán — nem a cégnek, '
            'hanem magadnak. Minden ki nem pipált pont egy konkrét '
            'dolog, amit holnap meg tudsz változtatni.',
          ),
          ChecklistBlock(
            title: 'A biztonsági önellenőrzésem',
            items: [
              'Minden reggel megcsinálom a körbejárást, akkor is, ha '
                  'sürgős',
              'Újra rögzítem a rakományt, amikor a raktér ürül',
              'Két másodperc távolságot tartok, és fix pontnál '
                  'ellenőrzöm',
              'Minden tolatási manőver előtt kiszállok és megnézem',
              'Menet közben nem nyúlok a telefonomhoz',
              'Megállok, ha fáradt leszek',
              'Mindig háttal kifelé szállok ki három érintkezési '
                  'ponttal',
              'A lábamból emelek és segédeszközöket használok',
              'Jelentem a károkat, a majdnem-baleseteket és a '
                  'sérüléseket',
              'Szólok, ha egy terv nem valósítható meg biztonságosan',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Esettanulmány: a nap, amikor minden összejön',
        blocks: [
          RevealBlock(
            prompt: 'Esettanulmány: péntek, eső, 190 megálló. 25 perccel '
                'később indulsz, a rakteret az éjszakai műszak nem '
                'rendezte, a telefonod folyton csörög, és 16 órakor '
                'veszed észre, hogy reggeli óta nem ettél semmit. Mi '
                'most a helyes sorrend?',
            answer: 'Állj meg és rendezd először a rakteret — ezt egy '
                'negyed óra alatt behozod, és megspórolsz magadnak 190 '
                'keresgélést. Aztán: telefont némítani, a tartóba tenni, '
                'a hívásokat a következő szünetben intézni. Aztán tíz '
                'perc evés és ivás, mert innentől különben óránként '
                'csökken a figyelmed. És aztán egy őszinte jelzés a '
                'diszpozíciónak, hogy a terv ma nem jön ki teljesen. '
                'Amit nem csinálsz: az időt az úton akarni behozni, '
                'szüneteket elhagyni, manővereket lerövidíteni. A nap '
                'már nem menthető meg — a hátad, a jogosítványod és a '
                'járműved viszont igen.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Az igazi vizsga',
            text: 'Egy jó napon bárki tud biztonságosan vezetni. A '
                'különbség azon a napon látszik, amikor minden '
                'egyszerre megy félre.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Az önkötelezésed',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Az ígéreted',
            text: '„Úgy vezetek, hogy mindenki épségben hazaérjen — én '
                'is."',
          ),
          ParagraphBlock(
            'A biztonság nem szabálykönyv, hanem a napi döntésed. Senki '
            'nem áll melletted, amikor reggel hatkor eldöntöd, hogy '
            'megcsinálod-e a körbejárást, vagy amikor este hétkor '
            'eldöntöd, hogy tolatás előtt kiszállsz-e még egyszer. Pont '
            'ez teszi ezeket a döntéseket olyan fontossá.',
          ),
          ChecklistBlock(
            title: 'Elkötelezem magam',
            items: [
              'Betartom a szabályokat akkor is, ha senki sem néz oda',
              'Rászánom azokat a másodperceket, amikbe a biztonság '
                  'kerül',
              'Őszintén jelentek ahelyett, hogy eltussolnám',
              'Segítek az új kollégáknak, hogy kezdettől fogva jól '
                  'csinálják',
              'Minden este egészségesen érek haza',
            ],
          ),
        ],
      ),
    ],
  ),
];
