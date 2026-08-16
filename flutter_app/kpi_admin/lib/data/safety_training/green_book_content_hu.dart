// lib/data/safety_training/green_book_content_hu.dart
//
// A Green Book képzés tartalma — magyar változat.
// A felépítés megegyezik a német mesterváltozattal: gb1–gb6 fejezetek,
// ugyanazok a diák, ugyanazok a blokkok és ugyanazok az értékek.
//
// A „Green Book" a menetellenőrző könyv: a napi ellenőrző lapok
// gyűjteménye a Fahrpersonalverordnung (FPersV — a német vezetési és
// pihenőidőkre vonatkozó rendelet) § 1 Abs. 6 pontja szerint. Ezzel
// igazolod a vezetési időt, a vezetési szüneteket, valamint a munka- és
// pihenőidőt — ez NEM járműellenőrzés. Ehhez a témához nincsenek
// illusztrációk, ezért `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> greenBookContentHu = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'gb1',
    title: 'Mi az a Green Book',
    summary: 'Menetellenőrző könyv a § 1 Abs. 6 FPersV szerint — és miért '
        'kötelező neked',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Menetellenőrző könyv, nem járműellenőrzés',
        blocks: [
          ParagraphBlock(
            'A „Green Book" a te menetellenőrző könyved. Ebben gyűjtöd a '
            'napi ellenőrző lapokat: minden munkanapra egy lapot, amelyen '
            'ott áll, mikor vezettél, mikor tartottál szünetet és mikor '
            'kezdődött a pihenőidőd.',
          ),
          ParagraphBlock(
            'Kifejezetten nem járműellenőrzés. A gumikat, a világítást és '
            'a karosszériát máshol dokumentálják. A Green Bookban '
            'kizárólag az időkről van szó — a te időidről.',
          ),
          BulletsBlock([
            'Egy lap minden olyan napra, amelyen nyilvántartási '
                'kötelezettség alá eső járművet mozgatsz',
            'Kézzel vezetve, letörölhetetlen írással és aláírva',
            'Azt igazolja, hogy betartottad a vezetési időt, a szüneteket '
                'és a pihenőidőt',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Röviden',
            text: 'A Green Book egyetlen kérdésre válaszol: mikor ültél a '
                'volánnál, és mikor nem? Minden más nem tartozik bele.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kinek kell nyilvántartást vezetnie',
        blocks: [
          ParagraphBlock(
            'A kötelezettség a Fahrpersonalverordnung (FPersV — a német '
            'vezetési és pihenőidőkre vonatkozó rendelet) § 1 Abs. 6 '
            'pontjából ered. Nem hozzád mint személyhez kötődik, hanem a '
            'járműhöz és az út céljához: üzletszerű árufuvarozás 2,8 t '
            'feletti, 3,5 t-ig terjedő megengedett legnagyobb össztömegű '
            'járművel. Pontosan ez a tipikus kézbesítő furgon.',
          ),
          FactsBlock([
            FactItem('2,8 t alatt', 'nincs nyilvántartási kötelezettség a '
                '§ 1 Abs. 6 FPersV szerint'),
            FactItem('2,8–3,5 t', 'napi ellenőrző lap — a Green Bookod'),
            FactItem('3,5 t-tól', 'digitális tachográf a papírlap helyett'),
          ]),
          ParagraphBlock(
            'A forgalmi engedélyben szereplő megengedett legnagyobb '
            'össztömeg a mérvadó — nem az, hogy ma valójában mennyire van '
            'megrakva a furgon. Egy félig üres 3,5 tonnás is '
            'nyilvántartásköteles marad.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A jogalap',
            text: 'A § 1 Abs. 6 FPersV arra kötelez, hogy nyilvántartsd a '
                'vezetési időt, a vezetési szüneteket, valamint a munka- '
                'és pihenőidőt. Ha e lap nélkül vezetsz, megsérted a '
                'rendeletet — függetlenül attól, hogy betartottad-e az '
                'időket.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Mire jó a nyilvántartás',
        blocks: [
          ParagraphBlock(
            'Az előírás nem öncélú. Azért létezik, mert a kimerült sofőrök '
            'veszélyesek a közúton — magukra és mindenki másra nézve. A '
            'lap láthatóvá teszi, hogy a munkanapjaid egyáltalán '
            'betarthatóan vannak-e megtervezve.',
          ),
          BulletsBlock([
            'Védelem a kimerültség ellen: aki köteles dokumentálni a '
                'szünetet, azt inkább meg is tartja',
            'Bizonyíték neked: a lap igazolja, hogy szabályosan vezettél — '
                'még hónapokkal később is',
            'Bizonyíték az állításokkal szemben: nyilvántartás nélkül az '
                'emlékezeted áll szemben azzal, amit az ellenőrzés feltesz',
            'Alap a túratervezéshez: az ismétlődően túl szoros túrák '
                'feltűnnek a lapon',
          ]),
          RevealBlock(
            prompt: 'Esettanulmány: ma betartottad az időket — szünet '
                'időben, munkavége időben. Csak a lapot nem töltötted ki, '
                'mert úgyis minden rendben volt. Délután ellenőrzés. '
                'Probléma ez?',
            answer: 'Igen. A nyilvántartási kötelezettség azt jelenti, '
                'hogy maga a bizonyítás a kötelezettség. Egy közúti '
                'ellenőrzésen senki nem tudja megállapítani, hogy tényleg '
                'betartottad-e az időket — nincs mit felmutatni. Az '
                'ellenőrzés szemszögéből a hiányzó lapot pontosan úgy kell '
                'kezelni, mint a túllépett időkeretet: szabálysértés '
                'történt, és azt szankcionálják. A szabálykövetés csak '
                'akkor segít, ha bizonyítani is tudod.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista: az alapok',
        blocks: [
          ChecklistBlock(
            title: 'Ezt viszem magammal az 1. fejezetből',
            items: [
              'Tudom, hogy a Green Book időket dokumentál, nem a jármű '
                  'állapotát',
              'Ismerem a jogalapot: § 1 Abs. 6 FPersV',
              'Tudom, hogy a 2,8 t feletti, 3,5 t-ig terjedő járművek '
                  'érintettek',
              'Tudom, hogy a megengedett legnagyobb össztömeg számít, nem '
                  'az aktuális rakomány',
              'Tudom, hogy 3,5 t-tól a digitális tachográf lép életbe',
              'Világos számomra, hogy a hiányzó lap önmagában '
                  'szabálysértés',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Egy mondat a túrára',
            text: '„Amit nem írtam le, azt nem tudom bizonyítani."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'gb2',
    title: 'Mit kell pontosan bejegyezni',
    summary: 'Minden kötelező adat — és hogyan töltöd ki tisztán',
    asset: '',
    slides: [
      SafetySlide(
        title: 'A lap kötelező adatai',
        blocks: [
          ParagraphBlock(
            'Egy napi ellenőrző lap csak akkor bizonyíték, ha minden '
            'előírt adat rajta van. Ha ezek közül egy hiányzik, a lap '
            'hiányosnak számít — ugyanolyan következményekkel, mint egy '
            'hiányzó lap.',
          ),
          BulletsBlock([
            'A sofőr vezetékneve, keresztneve és lakcíme',
            'A jármű hatósági rendszáma',
            'A nap dátuma',
            'Kilométeróra-állás az út elején és az út végén',
            'Az indulás helye és az út végének helye',
            'Vezetési és pihenőidők órában megadva',
            'Vezetési szünetek (a pihenők)',
            'Az aláírásod',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A teljes az teljes',
            text: 'A § 1 Abs. 6 FPersV tételesen sorolja fel az adatokat. '
                'Egy rendszám, lakcím vagy aláírás nélküli lap nem '
                'teljesíti a nyilvántartási kötelezettséget — akkor sem, '
                'ha az idők helyesen szerepelnek.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kitöltés lépésről lépésre',
        blocks: [
          ParagraphBlock(
            'Az alábbi sorrend szándékosan úgy van kialakítva, hogy semmit '
            'ne felejts el: először az állandó adatok, aztán az idők a nap '
            'folyamán, végül a lezárás.',
          ),
          StepsBlock([
            'Indulás előtt: írd be a dátumot, a vezeték- és keresztnevet, '
                'a lakcímet és a rendszámot',
            'Olvasd le a kilométeróra-állást, és írd be kezdőállásként — '
                'ne becsüld meg',
            'Írd be az indulás helyét (depó, telephely, településnév)',
            'Írd be a vezetési idő kezdetét órával, amint elindulsz',
            'Minden vezetési szünetet azonnal írj be kezdettel és véggel — '
                'ne csak este',
            'A túra végén: írd be az érkezés helyét és a záró '
                'kilométeróra-állást',
            'Írd be a vezetési idő végét és a pihenőidő kezdetét',
            'Olvasd át a lapot, ellenőrizd, nincs-e hiány, és írd alá',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Letörölhetetlenül írj',
            text: 'Golyóstoll, nem ceruza. Egy kiradírozható bejegyzés nem '
                'bizonyíték. Az elírást egyszer áthúzod, és mellé '
                'újraírod — nem fested le és nem ragasztod le.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Az idők tiszta bejegyzése',
        blocks: [
          ParagraphBlock(
            'A legtöbb hiba az időknél csúszik el. A nap minden '
            'időblokkja külön sorba kerül, mettől–meddig órával. Így néz '
            'ki egy szokásos kézbesítési nap:',
          ),
          TableBlock(
            headers: ['Mettől–meddig', 'Típus', 'Megjegyzés'],
            rows: [
              ['06:30–07:00', 'Munkaidő', 'Rakodás a depóban, még nem '
                  'vezetési idő'],
              ['07:00–11:30', 'Vezetési idő', '4,5 óra — most esedékes a '
                  'szünet'],
              ['11:30–12:15', 'Vezetési szünet', '45 perc egyben'],
              ['12:15–16:45', 'Vezetési idő', 'második blokk, összesen 9 '
                  'óra'],
              ['16:45–17:15', 'Munkaidő', 'visszaadás, visszáru, lezárás'],
              ['17:15-től', 'Pihenőidő', 'legalább 11 óra a következő '
                  'indulásig'],
            ],
          ),
          BulletsBlock([
            'Vezetési idő csak a volánnál töltött idő, amíg a jármű halad',
            'A be- és kirakodás, a szkennelés, a megállónál való '
                'várakozás munkaidő, de nem vezetési idő',
            'Egy vezetési szünet csak akkor pihenő, ha ez alatt tényleg '
                'nem dolgozol',
          ]),
          RevealBlock(
            prompt: 'Esettanulmány: 40 percet állsz a rakodórámpánál, és '
                'arra vársz, hogy lepakoljanak. A fülkében ülsz, és nem '
                'csinálsz semmit. Beírhatod ezt vezetési szünetként?',
            answer: 'Csak akkor, ha ez alatt az idő alatt valóban szabadon '
                'rendelkezel vele, és nem végzel munkát — és ha ezt előre '
                'tudod. Ha bármelyik pillanatban készen kell állnod, mert '
                'azonnal folytatódhat, az várakozási idő és nem pihenő. A '
                'kézenfekvő tévedés: „Nem csináltam semmit, tehát szünet '
                'volt." Nem az a döntő, hogy mozogtál-e, hanem hogy '
                'rendelkezhettél-e az idővel. Kétség esetén munkaidőként '
                'írod be — ez mindig a biztonságos oldal.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista: teljes a lap?',
        blocks: [
          ChecklistBlock(
            title: 'Mielőtt aláírom',
            items: [
              'A vezetéknév, a keresztnév és a lakcím rajta van',
              'A jármű rendszáma egyezik a ténylegesen vezetett járművel',
              'A dátum be van írva',
              'A kezdő és a záró kilométeróra-állást a műszerről olvastam '
                  'le',
              'Az indulás és az érkezés helye rajta van',
              'Minden vezetési idő mettől–meddig órával szerepel',
              'Minden vezetési szünet be van írva',
              'A pihenőidő kezdete be van írva',
              'Minden golyóstollal, radírozás nélkül, hiány nélkül',
              'Az aláírás rákerült',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'gb3',
    title: 'Vezetési idő, szünetek, pihenőidő',
    summary: 'A számok, amelyeket a munkanapodnak be kell tartania',
    asset: '',
    slides: [
      SafetySlide(
        title: 'A számok, amelyek számítanak',
        blocks: [
          ParagraphBlock(
            'A Green Book időket dokumentál — de csak azért, hogy nyomon '
            'követhető legyen, betartottad-e a határokat. Ezeket a '
            'határokat a fejedben kell tartanod, nem csak a papíron.',
          ),
          FactsBlock([
            FactItem('9 h', 'vezetési idő naponta, főszabály szerint'),
            FactItem('10 h', 'hetente kétszer megengedett kivételként'),
            FactItem('4,5 h', 'vezetés egyhuzamban, utána jön a szünet'),
          ]),
          FactsBlock([
            FactItem('45 min', 'vezetési szünet 4,5 óra után'),
            FactItem('15 + 30', 'megengedett felosztás — ebben a sorrendben'),
            FactItem('11 h', 'napi pihenőidő, legalább'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Mit követel az előírás',
            text: 'A vezetési idő naponta legfeljebb 9 óra, hetente '
                'kétszer 10 órára hosszabbítható. Legkésőbb 4,5 óra '
                'vezetési idő után legalább 45 perces vezetési szünetet '
                'kell tartani. A napi pihenőidő legalább 11 óra.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A szünet helyes elhelyezése',
        blocks: [
          ParagraphBlock(
            'A 45 perc a normál eset. Feloszthatod — de csak pontosan két '
            'részre, és csak meghatározott sorrendben: először legalább 15 '
            'perc, utána legalább 30 perc. Fordítva nem számít.',
          ),
          DoDontBlock(
            doTitle: 'Így érvényes a szünet',
            dos: [
              '45 perc egyben, legkésőbb 4,5 óra vezetési idő után',
              'Vagy először 15 perc, utána 30 perc',
              'Mindkét rész ugyanazon a 4,5 órás blokkon belül',
              'Mindkét részt mettől–meddig órával beírod a lapra',
            ],
            dontTitle: 'Így nem számít',
            donts: [
              'Először 30 perc, utána 15 perc — rossz sorrend',
              'Három rövid, egyenként 15 perces szünet',
              'Kétszer 20 perc — a második rész túl rövid',
              'Szünet csak 5 óra vezetés után, mert a megálló jobban '
                  'passzolt',
            ],
          ),
          BulletsBlock([
            'A 4,5 óra tiszta vezetési idő — a kézbesítéssel töltött '
                'megállók nem számítanak bele',
            'A szünetnek a túllépés elé kell esnie, nem utána',
            'A teljes szünet után új 4,5 órás blokk kezdődik',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'A leggyakoribb gondolkodási hiba',
            text: 'A szünet nem akkor esedékes, amikor 4,5 órája '
                'szolgálatban vagy, hanem amikor 4,5 órát vezettél. Aki '
                'szolgálati idő szerint számol, általában túl korán tartja '
                'meg a szünetet — aztán még egyszer túl későn.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Számolás a kézbesítés mindennapjaiban',
        blocks: [
          ParagraphBlock(
            'A mindennapokban nem egyetlen blokkal számolsz, hanem sok '
            'rövid úttal a megállók között. Add össze őket — ezek adják ki '
            'a vezetési idődet.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: 07:00-kor indulsz. 09:30-ig 2 órát '
                'ülsz a volánnál, a többit a megállóknál. 12:00-ig további '
                '2 óra vezetési idő jön hozzá, 13:00-ig még 30 perc. Mikor '
                'esedékes legkésőbb a szüneted?',
            answer: '13:00 órakor. Ekkorra érted el a 2 + 2 + 0,5 = 4,5 '
                'óra tiszta vezetési időt — most egyetlen métert sem '
                'vezethetsz, amíg a vezetési szünetet le nem tudtad. A '
                'kézenfekvő tévedés az lenne, hogy 07:00-tól hat óra '
                'szolgálati időt számolsz, és a szünetet 11:30-ra teszed. '
                'Az az óra, amelyik számít, csak akkor jár, amikor a jármű '
                'halad.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: ezen a héten már kétszer vezettél 10 '
                'órát. Ma péntek van, 8,5 óra vezetési időnél tartasz, és '
                'még két megállód van, összesen körülbelül 40 perc út. '
                'Belefér még?',
            answer: 'Nem. A 10 órára történő hosszabbítást hetente csak '
                'kétszer használhatod, és ezek elfogytak. Ma ismét a 9 '
                'órás alapkorlát érvényes — így 30 perc vezetési időd '
                'marad, nem 40. Elviszed az elérhető megállót, a többit '
                'jelented a diszpécsernek, és lezárod a vezetési időt. A '
                'kézenfekvő tévedés: „A 10 óra minden nap jár nekem." Ez '
                'kivétel, heti kerettel.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista: az idők kézben',
        blocks: [
          ChecklistBlock(
            title: 'Ezt viszem magammal a 3. fejezetből',
            items: [
              'Tudom, hogy 9 óra vezetési idő a főszabály',
              'Tudom, hogy 10 óra csak hetente kétszer megengedett',
              'A 4,5 órát tiszta vezetési időként számolom, nem '
                  'szolgálati időként',
              'Legalább 45 perc vezetési szünetet tartok',
              'A szünetet legfeljebb 15 + 30 percre osztom, ebben a '
                  'sorrendben',
              'Legalább 11 óra napi pihenőidőt tartok be',
              'Minden szünetet azonnal beírok, nem este',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Emlékeztető',
            text: '4,5 – 45 – 9 – 11. Négy szám, amely felépíti a napodat. '
                'Aki ismeri őket, annak nem számolnia kell, csak '
                'feljegyeznie.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'gb4',
    title: 'Tipikus hibák a kitöltésnél',
    summary: 'A hat hiba, amely minden ellenőrzésen feltűnik',
    asset: '',
    slides: [
      SafetySlide(
        title: 'A hat leggyakoribb hiba',
        blocks: [
          ParagraphBlock(
            'A kifogásolt lapok szinte mindegyike nem az időkön bukik el, '
            'hanem azon, ahogyan vezették őket. Ez a hat hiba egy '
            'egyébként helyes lapot is értéktelenné tesz.',
          ),
          DoDontBlock(
            doTitle: 'Így vezeted helyesen a lapot',
            dos: [
              'Minden bejegyzést azonnal megteszel, amint az időblokk '
                  'véget ér',
              'Golyóstollat használsz, letörölhetetlenül',
              'A szüneteket a tényleges mettől–meddig órával írod be',
              'A kilométeróra-állást a műszerről olvasod le',
              'A nap végén aláírsz',
              'A lap a járműben marad, nálad',
            ],
            dontTitle: 'Így kifogásolják a lapot',
            donts: [
              'Az egész hetet péntek este pótolni',
              'Ceruzával írni, hogy „később javítani" lehessen',
              'A szüneteket megbecsülni („nagyjából háromnegyed óra")',
              'A kilométeróra-állást fejből odaírni',
              'Elfelejteni az aláírást',
              'A lapokat otthon vagy a depóban hagyni',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'A legdrágább hiba a legkényelmesebb',
            text: 'Az utólagos kitöltés ártalmatlannak tűnik — ez az a '
                'hiba, amely a leggyorsabban kiderül, és a legtöbbet nyom '
                'a latban.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Miért tűnnek fel az utólagos bejegyzések',
        blocks: [
          ParagraphBlock(
            'Egy egyben, utólag megírt lap másképp néz ki, mint az, amely '
            'a nap folyamán keletkezett. Az ellenőrök naponta látják '
            'mindkettőt, és azonnal felismerik a különbséget.',
          ),
          BulletsBlock([
            'Ugyanaz az írókép, ugyanaz a toll, ugyanaz a nyomás minden '
                'soron',
            'Feltűnően kerek idők: minden fél és egész órára esik',
            'Kilométeróra-állások, amelyek nem illenek a beírt útvonalhoz',
            'Adatok, amelyek ellentmondanak a szállítóleveleknek, a '
                'szkenneléseknek vagy a tankolási bizonylatoknak',
            'Szünetek, amelyek mindig pontosan 45 percig tartanak — olyan '
                'napokon is, amikor ez lehetetlen volt',
          ]),
          ParagraphBlock(
            'Ehhez jön még: egy céges ellenőrzésnél a lapok a többi irat '
            'mellett fekszenek. Az ellentmondások nem neked tűnnek fel, '
            'hanem a hatóságnak.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A hamis rosszabb, mint az üres',
            text: 'Egy hiányos lap a nyilvántartási kötelezettség '
                'megsértése. Egy tudatosan hamisan kitöltött lap ennél '
                'több — ott már nem csupán szabálysértésről van szó, hanem '
                'a megtévesztés kérdéséről. Inkább írd be, hogy túl sokat '
                'vezettél, mint hogy kitalálj egy időpontot.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: csütörtökön veszed észre, hogy kedden '
                'nincs beírva az ebédszünet. Pontosan emlékszel: '
                '12:10-től 12:55-ig. Mit teszel?',
            answer: 'Pótolod — de láthatóan utólagos bejegyzésként, a '
                'kiegészítés dátumával és egy rövid megjegyzéssel, és '
                'tájékoztatod a diszpécseredet. Az őszinte, felismerhető '
                'javítás megengedett, és lényegesen jobb, mint egy hiány. '
                'A kézenfekvő tévedés az lenne, hogy úgy illeszted be a '
                'bejegyzést, mintha kedden keletkezett volna — pontosan ez '
                'a lépés a hanyagságtól a hamisításig.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista: rendben vezetve',
        blocks: [
          ChecklistBlock(
            title: 'A lapom kiállja az ellenőrzést',
            items: [
              'Minden időblokkot azonnal beírok, nem este',
              'Golyóstollal írok',
              'Az órákat és a kilométeróra-állásokat leolvasom, nem '
                  'megbecsülöm',
              'Minden lapot aláírok',
              'A lapjaim mindig nálam vannak a járműben',
              'A javításokat láthatóan és dátummal végzem, soha nem '
                  'észrevétlenül',
              'Inkább beírok egy szabálysértést, mint hogy kitaláljak egy '
                  'időpontot',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'gb5',
    title: 'Magánál tartás, leadás, megőrzés',
    summary: '28 nap a sofőrnél, egy év a cégnél',
    asset: '',
    slides: [
      SafetySlide(
        title: 'A két határidő',
        blocks: [
          ParagraphBlock(
            'A kitöltött lap csak akkor ér valamit, ha a megfelelő '
            'pillanatban a megfelelő helyen van. Erre két határidő van, '
            'amelyeket külön kell tartanod.',
          ),
          FactsBlock([
            FactItem('28 nap', 'a nyilvántartást a sofőr magánál tartja'),
            FactItem('1 év', 'a vállalkozó megőrzi a cégnél'),
          ]),
          BulletsBlock([
            'A 28 nap rád vonatkozik: az aktuális nap és az azt megelőző '
                '28 nap nyilvántartását magadnál kell tartanod',
            'Az egyéves határidő a céget érinti: egy évig meg kell '
                'őriznie a lapokat, és kérésre be kell mutatnia',
            'Mindkettő egyszerre érvényes — a lapok csak a magánál tartási '
                'kötelezettség lejárta után kerülnek az irattárba',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Magánál tartási kötelezettség',
            text: 'Az utolsó 28 nap nyilvántartása a járműbe való — nem a '
                'szekrénybe, nem haza és nem az irodába. Ha ellenőrzéskor '
                'hiányoznak, nem segít, hogy rendesen vezetted őket.',
          ),
        ],
      ),
      SafetySlide(
        title: 'A közúti ellenőrzés',
        blocks: [
          ParagraphBlock(
            'Az ellenőrzést a BAG — a Bundesamt für Logistik und '
            'Mobilität, a német szövetségi logisztikai és mobilitási '
            'hivatal — és a rendőrség végzi. Mindkettő ellenőrizhet az út '
            'szélén, a BAG ezenfelül a cégnél is.',
          ),
          StepsBlock([
            'Állj félre, motort le, ablakot le, a kezed maradjon látható',
            'Maradj nyugodt — az ellenőrzés rutin, nem gyanúsítás',
            'Mutasd be a vezetői engedélyt, a jármű okmányait és az utolsó '
                '28 nap nyilvántartását',
            'A kérdésekre tárgyszerűen válaszolj, ne találj ki és ne '
                'szépíts semmit',
            'Kifogás esetén: vetesd jegyzőkönyvbe az esetet, ne vitatkozz',
            'Utána tájékoztasd a diszpécsert, és dokumentáld az esetet a '
                'cégnél',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'A felkészülés többet ér a magyarázatnál',
            text: 'Egy ellenőrzés néhány percig tart, ha a lapok '
                'hiánytalanul a járműben vannak. Minden más neked és a '
                'cégnek is egy egész délutánba kerül.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: az út szélén az ellenőr az utolsó 28 '
                'napot kéri. Csak az aktuális hét van nálad — a régebbi '
                'lapokat szabályosan leadtad a depóban. Elég ez?',
            answer: 'Nem. A magánál tartási kötelezettség az aktuális napra '
                'és az azt megelőző 28 napra terjed ki. Az, hogy a régebbi '
                'lapok rendben a cégnél vannak, a megőrzési '
                'kötelezettséget teljesíti, de a magánál tartásit nem — ez '
                'két külön kötelezettség. Helyesen: az utolsó 28 nap '
                'másolata vagy eredetije nálad marad, és csak azután kerül '
                'az irattárba. Beszéld meg a diszpécsereddel, hogyan '
                'szervezitek ezt meg a cégnél.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Leadás a cégnél',
        blocks: [
          ParagraphBlock(
            'A vállalkozó csak akkor tudja teljesíteni a megőrzési '
            'kötelezettségét, ha meg is kapja a lapokat. Ezért a leadás '
            'nem papírmunka, hanem a nyilvántartási kötelezettséged része.',
          ),
          BulletsBlock([
            'A lapokat a magánál tartási határidő lejárta után '
                'hiánytalanul add le, ne kötegben a hónap végén',
            'Semmit ne dobj ki, a hibás vagy javított lapokat sem',
            'Ha hiányzik egy lapod, mondd el azonnal — a bejelentett hiány '
                'jobb, mint a felfedezett',
            'A szabadságos, betegállományos és irodai napokat ne '
                'egyszerűen hagyd ki, hanem a cégnél előírt módon jelöld',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'A hiány hiány marad',
            text: 'Egy lap nélküli nap utólag nem rekonstruálható. Aki '
                'elhanyagolja a leadást, pontosan azokat a hiányokat '
                'termeli, amelyek egy céges ellenőrzésen feltűnnek.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista: az iratok kézben',
        blocks: [
          ChecklistBlock(
            title: 'Minden műszak előtt és minden hét után',
            items: [
              'Az utolsó 28 nap nyilvántartása a járműben van',
              'A mai lap el van kezdve, és kéznél van',
              'A vezetői engedély és a jármű okmányai nálam vannak',
              'A lejárt lapokat leadtam a cégnél',
              'Egyetlen lapot sem dobtam ki, javítottat sem',
              'Tudom, kit kell értesítenem ellenőrzés esetén',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'gb6',
    title: 'Jogkövetkezmények szabálysértés esetén',
    summary: 'Bírság, a cég felelőssége, belső eszkaláció',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Mi fenyeget jogilag',
        blocks: [
          ParagraphBlock(
            'A hiányzó vagy hiányos napi ellenőrző lap szabálysértés. Hogy '
            'milyen magas a bírság, attól függ, mennyire súlyos és milyen '
            'gyakori volt a szabálysértés.',
          ),
          FactsBlock([
            FactItem('100 €-tól', 'bírság hiányzó vagy hiányos lapok '
                'esetén'),
            FactItem('súlyosság szerint', 'magasabb összeg több vagy '
                'ismételt szabálysértésnél'),
          ]),
          BulletsBlock([
            'Nem csak a sofőr érintett — a nyilvántartásért a vállalkozás '
                'is felelősséget visel',
            'Súlyos vagy ismételt szabálysértéseknél eljárás indulhat a '
                'vállalkozás megbízhatóságáról',
            'Az ellenőrzést a BAG és a rendőrség végzi, az út szélén és a '
                'cégnél',
            'Egy céges ellenőrzés kifogásai minden sofőrt érintenek, nem '
                'csak az ellenőrzöttet',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Két címzett, egy kötelezettség',
            text: 'Az FPersV a sofőrt és a vállalkozót együtt kötelezi: '
                'neked nyilvántartanod és magadnál tartanod kell, a cégnek '
                'megőriznie és felügyelnie. Ha valamelyik kiesik, a '
                'felelős oldal áll helyt.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Az eszkaláció a cégen belül',
        blocks: [
          ParagraphBlock(
            'Függetlenül attól, hogy egy hatóság megállapít-e valamit, a '
            'cégnél rögzített sorrend érvényes. Ez mindenkire ugyanaz, és '
            'dokumentálják.',
          ),
          StepsBlock([
            'Első fokozat: szóbeli figyelmeztetés a diszpécsertől',
            'Második fokozat: írásbeli figyelmeztetés a személyi anyagban',
            'Harmadik fokozat: munkajogi következmények egészen a '
                'felmondásig',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'A szabálysértés maga a hiányzó lap',
            text: 'A fokozatok attól függetlenül futnak, hogy történt-e '
                'valami, vagy hogy volt-e ellenőrzés. Már a nem vezetett '
                'lap maga a szabálysértés.',
          ),
          RevealBlock(
            prompt: 'Esettanulmány: a diszpécser nyomul: „Vidd még el a '
                'két megállót, a szünetet meg egyszerűen írd bele, '
                'különben nem érünk a végére." Mi érvényes?',
            answer: 'Az utasítás semmit nem változtat a kötelezettségeden. '
                'Te vagy az, aki nyilvántart és aláír — az aláírásoddal '
                'igazolod a tartalmat. Egy szóbeli utasítás sem az '
                'ellenőrzésnél, sem később a cégnél nem véd meg. Helyesen: '
                'tartsd meg a szünetet, írd be helyesen, jelentsd a '
                'fennmaradó megállókat, és dokumentáld az utasítást. A cég '
                'köteles lehetővé tenni a szabálykövetést — nem '
                'megkerülni.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ellenőrzőlista: zárás',
        blocks: [
          ChecklistBlock(
            title: 'Ezt viszem magammal a képzésből',
            items: [
              'A Green Book a menetellenőrző könyv a § 1 Abs. 6 FPersV '
                  'szerint',
              'Ismerem az összes kötelező adatot, és hiánytalanul kitöltöm '
                  'őket',
              'Betartok 9 h vezetési időt, 4,5 h-t a szünetig, 45 min '
                  'szünetet és 11 h pihenőidőt',
              'Azonnal beírok, golyóstollal, és aláírok',
              'Magamnál tartom az utolsó 28 nap nyilvántartását',
              'A lejárt lapokat leadom a cégnél',
              'Tudom, hogy egy hiányzó lap 100 eurótól induló bírságot '
                  'vonhat maga után',
              'Tudom, hogy egy utasítás nem szünteti meg a nyilvántartási '
                  'kötelezettségemet',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Egy mondat a túrára',
            text: '„A lap velem együtt ír, miközben vezetek — nem akkor, '
                'amikor már végeztem."',
          ),
        ],
      ),
    ],
  ),
];
