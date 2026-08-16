// lib/data/safety_training/driving_safety_content_hr.dart
//
// Sadrzaj DSP treninga sigurne voznje — hrvatska verzija.
// Moduli M1–M10, struktura identicna njemackom izvorniku:
// isti slajdovi, isti blokovi i iste slike.

import 'safety_blocks.dart';

const List<SafetyChapterContent> drivingSafetyContentHr = [
  // ══════════════════════════════════════════════════ M1
  SafetyChapterContent(
    id: 'm1',
    title: 'Kultura sigurnosti i odgovornost',
    summary: 'Shvati sigurnost kao vlastitu odluku — a ne kao propis',
    asset: 'assets/academy/driving/m01_sicherheitskultur.svg',
    slides: [
      SafetySlide(
        title: 'Tvoja tura, tvoja odgovornost',
        blocks: [
          ParagraphBlock(
            'Svaki dan prijeđeš stotine kilometara i staneš desetke puta. '
            'Svaka vožnja, svako stajanje, svako izlaženje iz vozila je '
            'odluka. Dobra vijest: gotovo svaka nesreća se može '
            'izbjeći. Sigurnost ne počinje za volanom, nego u glavi — '
            'prije nego što kreneš.',
          ),
          FactsBlock([
            FactItem('120+', 'stajanja u normalnom dostavnom danu'),
            FactItem('250+', 'puta ulaziš i izlaziš po turi'),
            FactItem('1', 'sekunda nepažnje dovoljna je za '
                'nesreću'),
          ]),
          ParagraphBlock(
            'Kod tolikog broja ponavljanja o danu ne odlučuje tvoje '
            'umijeće, nego tvoja rutina. Dobra rutina štiti te i kad si '
            'umoran ili pod pritiskom — loša rutina jednom će te skupo '
            'stajati.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Osnovna misao',
            text: 'Sigurnost nije nešto što radiš dodatno. Ona je način '
                'na koji radiš svoj posao.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Što se u dostavi stvarno događa',
        blocks: [
          ParagraphBlock(
            'Dostava spada među zanimanja s najviše nesreća na putu i na '
            'radu. Najčešći događaji nisu spektakularni: nalijetanje u '
            'koloni, štete pri vožnji unatrag, padovi pri izlasku, '
            'istegnuta leđa, uganuti gležnjevi. Svakodnevni — i upravo '
            'zato podcijenjeni.',
          ),
          FactsBlock([
            FactItem('70 %', 'šteta na kombijima nastaje pri '
                'manevriranju i vožnji unatrag'),
            FactItem('Br. 1', 'Spoticanje, klizanje i padanje najčešći '
                'je uzrok ozljeda u dostavi'),
            FactItem('24', 'dana izostanka u prosjeku nakon pada'),
          ]),
          ParagraphBlock(
            'Upada u oči: gotovo svi ti događaji zbivaju se pri maloj '
            'brzini ili u mjestu. To nisu dramatični manevri, nego posve '
            'obični pokreti koji su jednom loše izvedeni.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Sporo ne znači bezopasno',
            text: 'Šteta pri manevriranju brzinom pješaka tvrtku brzo '
                'stoji četveroznamenkasti iznos — a tebe pola dana '
                'gnjavaže.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tri osnovna stava',
        blocks: [
          ParagraphBlock(
            'Iz svega što slijedi u ovom treningu mogu se izvesti tri '
            'stava. Ako poneseš samo ta tri, najveći dio si obavio.',
          ),
          BulletsBlock([
            'Misliti unaprijed — prepoznati opasnosti prije nego što '
                'nastanu. Tko samo reagira, uvijek kasni',
            'Vrijeme pripada tebi — nijedan paket nije vrijedan nesreće. '
                'Vremenski pritisak je problem planiranja, a ne isprika',
            'Biti uzor — tvoje ponašanje štiti kolege, pješake i djecu. '
                'U prometu si profesionalac, a ne privatni vozač',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Zapamti',
            text: 'Najbolji vozač nije najbrži, nego onaj kojem se nikad '
                'ništa ne dogodi — jer to vidi na vrijeme.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Svaka vožnja je lanac odluka',
        asset: 'assets/academy/driving/m01b_entscheidung.svg',
        blocks: [
          ParagraphBlock(
            'Nesreća je rijetko jedna jedina pogreška. Najčešće je to pet '
            'ili šest malih odluka koje same za sebe djeluju bezopasno — '
            'a na kraju se zbroje. Upravo zato lanac možeš prekinuti na '
            'bilo kojoj karici.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: 17:40 je, imaš još 22 otvorena '
                'stajanja. Teretni prostor je neuredan, mobitel ti '
                'vibrira u držaču, a ispred tebe se sužava. Gdje je tu '
                'zapravo rizik?',
            answer: 'Ne u suženju ispred tebe — nego u prethodnoj '
                'povijesti. Neuredan teretni prostor te na svakom '
                'stajanju košta vremena, vrijeme stvara pritisak, '
                'pritisak ti smanjuje pažnju, a mobitel oduzima ostatak. '
                'Ispravna odluka bila je na redu dva sata ranije: '
                'posložiti teretni prostor, utišati mobitel, realno '
                'isplanirati ritam. Sada pomaže samo ovo: stani, duboko '
                'udahni, nastavi stajanje po stajanje i poslije prijavi '
                'planiranje.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Prekini lanac',
            text: 'Pitaj se kod svakog lošeg osjećaja: koja je sada ona '
                'jedna karika koju mogu ukloniti s 30 sekundi truda?',
          ),
        ],
      ),
      SafetySlide(
        title: 'Uzor u timu',
        asset: 'assets/academy/driving/m01c_vorbild.svg',
        blocks: [
          ParagraphBlock(
            'Kultura sigurnosti ne nastaje iz plakata, nego iz onoga što '
            'kolege preuzimaju jedni od drugih. Tko počinje kao novi, '
            'oponaša ono što iskusni pokazuju — i ono krivo.',
          ),
          DoDontBlock(
            doTitle: 'Kultura koja nosi',
            dos: [
              'Otvoreno govoriti o izbjegnutim nesrećama, a da nitko '
                  'nikoga ne gleda poprijeko',
              'Nove kolege aktivno upozoriti na stepenice, rukohvate i '
                  'mrtvi kut',
              'Kvarove odmah prijaviti, čak i ako tura zbog toga kreće '
                  'kasnije',
              'I pod vremenskim pritiskom vidljivo uredno manevrirati',
            ],
            dontTitle: 'Kultura koja šteti',
            donts: [
              '„Mi to ovdje uvijek tako radimo" kao obrazloženje',
              'Smijati se kolegi koji izađe i pogleda iza vozila',
              'Male štete rješavati međusobno umjesto da se prijave',
              'Pokazivati prečace koje novom kolegi nikad ne bi '
                  'objasnio',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Izbjegnute nesreće vrijede zlata',
            text: 'Svaka prijavljena izbjegnuta nesreća je nesreća koja '
                'se sljedećem kolegi više neće dogoditi. Prijaviti je '
                'snaga, a ne tužakanje.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tko zapravo odgovara?',
        blocks: [
          ParagraphBlock(
            'Za volanom si vozač vozila — i time osobno odgovoran. Tvrtka '
            'ti daje sigurno vozilo, poučava te i planira turu. Ali hoćeš '
            'li držati razmak, vezati pojas i izaći prije vožnje unatrag, '
            'odlučuješ samo ti.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Što zakon očekuje od tebe',
            text: '§ 1 StVO (njemački Zakon o cestovnom prometu) traži '
                'stalan oprez i uzajamnu obzirnost. § 3 st. 1 StVO traži '
                'da voziš samo onoliko brzo koliko možeš zaustaviti '
                'unutar preglednog dijela ceste. Oboje vrijedi neovisno o '
                'tome što piše na znaku.',
          ),
          BulletsBlock([
            'Kazne i bodovi pogađaju tebe osobno, a ne tvrtku',
            'Kod grube nepažnje osiguranje može od tebe tražiti '
                'djelomični regres',
            'Kad su drugi ugroženi, iz prometnog prekršaja može nastati '
                'kazneno djelo (§ 315c StGB)',
            'Zabrana vožnje za tebe kao profesionalnog vozača znači: bez '
                'posla',
          ]),
          RevealBlock(
            prompt: 'Ujutro primijetiš da je jedno stop-svjetlo u kvaru. '
                'Disponent kaže: „Ipak kreni, nemamo nikoga drugog." Tko '
                'nosi rizik?',
            answer: 'Ti. Kao vozač odgovaraš za prometno sigurno stanje '
                'vozila koje pokrećeš — usmeni nalog to ne ukida. '
                'Ispravno je: prijavi kvar, zatraži zamjensko vozilo ili '
                'popravak, dokumentiraj prijavu. Neispravno stop-svjetlo '
                'na kombiju je uz to točno onaj nedostatak koji vodi do '
                'nalijetanja straga.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista: tvoj stav',
        blocks: [
          ChecklistBlock(
            title: 'Ovo nosim iz modula 1',
            items: [
              'Znam da se većina šteta događa sporo i u svakodnevici',
              'Mislim unaprijed umjesto da samo reagiram',
              'Vremenski pritisak tretiram kao problem planiranja, a ne '
                  'kao problem vožnje',
              'Prijavljujem kvarove i izbjegnute nesreće, i one male',
              'Znam da kao vozač odgovaram osobno',
              'Svjestan sam da me novi kolege kopiraju',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Jedna rečenica za turu',
            text: '„Vozim tako da svi sigurno dođu kući — i ja."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M2
  SafetyChapterContent(
    id: 'm2',
    title: 'Provjera vozila i osiguranje tereta',
    summary: 'Prije ture provjeri vozilo i osiguraj teret tako da ništa ne '
        'postane opasnost',
    asset: 'assets/academy/driving/m02_fahrzeugcheck.svg',
    slides: [
      SafetySlide(
        title: 'Zašto provjera nije formalnost',
        blocks: [
          ParagraphBlock(
            'Obilazak vozila prije ture traje dvije minute. On sprječava '
            'kvarove nasred rute, kazne pri kontroli i, u najgorem '
            'slučaju, nesreću koju si mogao vidjeti prije nego što si '
            'krenuo.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Obveza provjere prije smjene',
            text: 'Prema DGUV Vorschrift 70 (njemački propis o vozilima) '
                'moraš svoje vozilo prije početka svake radne smjene '
                'provjeriti na očite nedostatke. Utvrdiš li nedostatke '
                'koji ugrožavaju pogonsku sigurnost, ne smiješ krenuti — '
                'prijavljuješ ih.',
          ),
          FactsBlock([
            FactItem('2 min', 'traje cijeli obilazak vozila'),
            FactItem('4', 'postaje: gume, svjetla, tekućine, '
                'teret'),
          ]),
          ParagraphBlock(
            'Važno: provjera ne zamjenjuje pregled u servisu. Ti tražiš '
            'ono što upada u oči — a ne skrivene kvarove.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Obilazak — četiri postaje',
        asset: 'assets/academy/driving/m02b_rundgang.svg',
        blocks: [
          ParagraphBlock(
            'Obilazi vozilo uvijek istim redoslijedom. Čvrst redoslijed '
            'jedini je način da ništa ne zaboraviš kad ujutro postane '
            'užurbano.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/load01_reifen.svg',
              title: '1 · Gume i kotači',
              caption: 'Obiđi vozilo u cijelosti i pogledaj sve četiri '
                  'gume: vidljivo ispuhane, pukotine, strana tijela, je '
                  'li dubina šare dovoljna? Guma koja ujutro već izgleda '
                  'mekano neće izdržati cijelu turu.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load02_licht.svg',
              title: '2 · Rasvjeta i registarska pločica',
              caption: 'Provjeri pozicijska svjetla, kratka svjetla, '
                  'žmigavce, stop-svjetla i svjetlo za vožnju unatrag — '
                  'stop-svjetla po potrebi preko odsjaja na zidu ili uz '
                  'pomoć kolege. Pločica mora biti slobodna i čitljiva.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load03_fluessigkeiten.svg',
              title: '3 · Tekućine i tlo',
              caption: 'Pogled ispod vozila: tragovi ulja, rashladne '
                  'tekućine ili kočione tekućine na tlu uvijek su razlog '
                  'za prijavu. Uz to dopuni tekućinu za pranje stakla — '
                  'zimi sa sredstvom protiv smrzavanja.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load04_ladung.svg',
              title: '4 · Teretni prostor i teret',
              caption: 'Otvori vrata i pogledaj unutra: stoji li sve '
                  'čvrsto, jesu li pregradna mreža i trake zategnute, '
                  'leži li nešto slobodno na vrhu? Ono što ovdje stoji '
                  'labavo, poletjet će naprijed pri prvom naglom '
                  'kočenju.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Gume: tvoj jedini dodir s cestom',
        blocks: [
          ParagraphBlock(
            'Četiri dodirne površine, svaka otprilike velika kao '
            'razglednica — ništa više ne povezuje tvoj natovareni kombi s '
            'kolnikom. Sve što učiš o kočenju, upravljanju i prianjanju '
            'visi o te četiri površine.',
          ),
          FactsBlock([
            FactItem('1,6 mm', 'zakonska najmanja dubina šare'),
            FactItem('3 mm', 'preporučena najmanja šara ljeti'),
            FactItem('4 mm', 'preporučena najmanja šara zimi'),
            FactItem('60 € + 1 bod', 'kod premale dubine šare'),
          ]),
          BulletsBlock([
            'Dubinu šare provjeri kovanicom od 1 eura: zlatni rub je 3 mm '
                'širok — nestane li u šari, imaš još dovoljno',
            'Tlak provjeri na hladnim gumama i prilagodi ga teretu — '
                'natovaren trebaš viši tlak nego prazan',
            'Pazi na neravnomjerno trošenje: istrošeno samo s jedne '
                'strane znači problem s geometrijom ili tlakom',
            'Izbočine, pukotine i zabodene vijke odmah prijavi',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Premali tlak opasniji je od prevelikog',
            text: 'Slabo napuhana guma se gnječi, pregrijava i pri punom '
                'teretu može puknuti. Uz to raste zaustavni put i '
                'povećava se opasnost od akvaplaninga.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Svjetla, stakla, ogledala',
        blocks: [
          ParagraphBlock(
            'Biti viđen jednako je važno kao i vidjeti. Neispravno '
            'stop-svjetlo na kombiju klasičan je uzrok nalijetanja '
            'straga, kod kojeg ti doduše nisi krivac — ali štetu ipak '
            'imaš.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Slobodan pogled je obveza',
            text: 'Prema § 23 st. 1 StVO moraš se pobrinuti da vidljivost '
                'i sluh nisu ometeni — teretom, putnicima, zaleđenim ili '
                'prljavim staklima. Ostrugana „rupica za gledanje" '
                'izričito nije dovoljna.',
          ),
          BulletsBlock([
            'Ogledala namjesti u mjestu, prije nego što motor radi — '
                'nikad tijekom vožnje',
            'Vanjska ogledala tako da ostane vidljiva uska traka '
                'vlastitog vozila: to je tvoja referentna točka',
            'Stakla i ogledala drži čistima iznutra i izvana — masnoća s '
                'unutarnje strane noću iznimno zasljepljuje',
            'Metlice koje razmazuju daj odmah zamijeniti',
          ]),
          RevealBlock(
            prompt: 'Pri obilasku primijetiš: desno vanjsko ogledalo se '
                'klima i ima pukotinu. Pred tobom je još 190 stajanja. '
                'Voziti ili ne?',
            answer: 'Ne vozi prije nego što je prijavljeno. Desno vanjsko '
                'ogledalo upravo je ono kojim osiguravaš mrtvi kut prema '
                'biciklistima i pločniku — baš ondje se događaju teške '
                'nesreće pri skretanju. Napuknuto, klimavo ogledalo je '
                'nedostatak koji se tiče prometne sigurnosti. Prijavi, '
                'zamijeni ili promijeni vozilo.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Osiguranje tereta: razumjeti sile',
        blocks: [
          ParagraphBlock(
            'Teret mora biti osiguran tako da se ni pri naglom kočenju ni '
            'pri iznenadnom izbjegavanju ne pomakne. Što to konkretno '
            'znači, stoji u priznatim pravilima tehnike — a ona računaju '
            's jasnim vrijednostima.',
          ),
          FactsBlock([
            FactItem('0,8 g', 'sila prema naprijed od koje se mora '
                'osigurati'),
            FactItem('0,5 g', 'sila prema natrag i u stranu'),
            FactItem('16 kg', 'sila držanja koju sam paket od 20 kg '
                'treba pri kočenju'),
          ]),
          ParagraphBlock(
            'Prevedeno: paket od 20 kg pri naglom kočenju pritišće s oko '
            '16 kg prema naprijed — kao da si punu gajbu vode gurnuo '
            'prema pregradnoj stijeni. Kod dvadeset takvih paketa to je '
            'preko 300 kg koji se istodobno žele pomaknuti naprijed.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 22 StVO — teret',
            text: 'Teret se mora smjestiti i osigurati tako da se ni pri '
                'naglom kočenju ni pri iznenadnom izbjegavanju ne može '
                'pomaknuti, prevrnuti, kotrljati ni pasti. Neosiguran '
                'teret kažnjava se novčano, a kod ugrožavanja i bodom — i '
                'pogađa vozača.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Što 20 kg napravi u ozbiljnom slučaju',
        blocks: [
          ParagraphBlock(
            '0,8 g vrijedi za kočenje i izbjegavanje. Kod pravog sudara '
            'djeluju znatno veća usporenja kroz vrlo kratko vrijeme — '
            'udarna sila neosiguranog paketa tada je višestruko iznad '
            'njegove težine.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: na suvozačevom sjedalu leži '
                'pošiljka od 12 kg jer je sljedeće stajanje. U naselju '
                'moraš naglo zakočiti pred djetetom. Što se događa s '
                'paketom?',
            answer: 'On se dalje kreće tvojom početnom brzinom dok ga '
                'nešto ne zaustavi — armaturna ploča, vjetrobran ili '
                'tvoja glava pri bočnom udaru. Već pri običnom kočenju u '
                'opasnosti odleti sa sjedala u prostor za noge i ondje '
                'može dospjeti pod papučicu kočnice. Upravo zato nijedna '
                'pošiljka ne ide naprijed: sljedeće stajanje se '
                'predsortira u teretnom prostoru, a ne odlaže na '
                'suvozačevo sjedalo.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Ništa u kabini',
            text: 'Nijedan paket, nijedna kutija, nijedan slobodan alat u '
                'vozačevom prostoru. Predmet pod papučicom kočnice '
                'oduzima ti kočnicu točno u trenutku kad ti treba.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ovako pravilno tovariš',
        asset: 'assets/academy/driving/m02c_ladung.svg',
        blocks: [
          ParagraphBlock(
            'Osnovno pravilo: teško dolje, teško naprijed, težina '
            'ravnomjerno raspoređena po osovinama. Visoko natovaren kombi '
            'ima visoko težište — a ono odlučuje hoćeš li u zavoju još '
            'kliziti ili se već prevrnuti.',
          ),
          DoDontBlock(
            doTitle: 'Osigurano',
            dos: [
              'Teški paketi dolje i naprijed uz pregradnu stijenu',
              'Težina ravnomjerno raspoređena lijevo/desno',
              'Tovariti bez praznina — zatvori rupe da se ništa ne može '
                  'zaletjeti',
              'Trake i pregradna mreža zategnuti, i kad se teretni '
                  'prostor prazni',
              'Nakon svakog dotovara kratko provjeri',
            ],
            dontTitle: 'Neosigurano',
            donts: [
              'Teški paketi labavo naslagani na vrhu',
              'Pošiljke u prostoru za noge ili na suvozačevom sjedalu',
              'Sve samo „nekako" ugurano, praznine otvorene',
              'Pregradna mreža otpuštena jer smeta pri hvatanju',
              'Teret „pridržan" samo vlastitom tjelesnom težinom',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Prazan teretni prostor je najopasniji',
            text: 'Što je manje unutra, to više puta ima preostali paket '
                'da uhvati brzinu. Poluprazno ne znači upola opasno — '
                'znači ponovno osigurati.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Red u kabini i pojas',
        blocks: [
          ParagraphBlock(
            'Piće, mobitel, skener, otpremnice — sve dobiva svoje čvrsto '
            'mjesto. Ono što se kotrlja, zvecka ili leti, odvlači ti '
            'pogled s ceste. Uredno vozačevo mjesto je sigurno vozačevo '
            'mjesto.',
          ),
          FactsBlock([
            FactItem('30 €', 'kazna bez sigurnosnog pojasa'),
            FactItem('Svako', 'stajanje: ponovno veži pojas, i za 200 '
                'metara'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 21a StVO — obveza pojasa',
            text: 'Sigurnosni pojas mora biti vezan tijekom vožnje — bez '
                'iznimke za kratke dionice između dva stajanja. Kod '
                'nesreće bez pojasa može ti se uz to pripisati i '
                'suodgovornost.',
          ),
          ParagraphBlock(
            'Upravo je u dostavi pojas najčešće izostavljeno osiguranje — '
            'jer između dva stajanja ima samo nekoliko stotina metara. '
            'Ali baš ondje se događa većina sudara unutar naselja.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista prije polaska',
        blocks: [
          ChecklistBlock(
            title: 'Prije nego što krenem',
            items: [
              'Obilazak obavljen čvrstim redoslijedom',
              'Gume: šara, tlak, oštećenja provjereni',
              'Rasvjeta provjerena uokolo, pločica čitljiva',
              'Nema tragova tekućine ispod vozila',
              'Stakla i ogledala čisti, ogledala namještena',
              'Teški paketi dolje i naprijed, težina raspoređena',
              'Trake i pregradna mreža zategnuti',
              'Ništa slobodno u kabini, mobitel u držaču',
              'Sigurnosni prsluk nadohvat ruke, trokut u vozilu',
              'Pojas vezan',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M3
  SafetyChapterContent(
    id: 'm3',
    title: 'Defenzivna i predviđajuća vožnja',
    summary: 'Upravljaj razmakom, brzinom i pažnjom tako da uvijek imaš '
        'rezervu',
    asset: 'assets/academy/driving/m03_defensiv.svg',
    slides: [
      SafetySlide(
        title: 'Zaustavni put = put reakcije + put kočenja',
        blocks: [
          ParagraphBlock(
            'Zaustavni put je udaljenost od trenutka prepoznavanja do '
            'potpunog zaustavljanja. Sastoji se od dva dijela: puta '
            'reakcije, koji još prelaziš punom brzinom, i samog puta '
            'kočenja.',
          ),
          FactsBlock([
            FactItem('oko 1 s', 'vrijeme reakcije budnog i trijeznog '
                'vozača'),
            FactItem('× 3', 'put reakcije = brzina ÷ 10, puta 3'),
            FactItem('²', 'put kočenja = (brzina ÷ 10) na kvadrat'),
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Praktične formule',
            text: 'Put reakcije = (km/h ÷ 10) × 3. Put kočenja = '
                '(km/h ÷ 10) × (km/h ÷ 10). Oboje zbrojeno daje zaustavni '
                'put. Kod kočenja u opasnosti put kočenja se prepolovi.',
          ),
          ParagraphBlock(
            'Ključna točka: put kočenja ne raste proporcionalno brzini, '
            'nego s kvadratom. Dvostruka brzina znači četverostruki put '
            'kočenja — to je razlog zašto 20 km/h više u stambenoj ulici '
            'mijenja sve.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Računaj umjesto da procjenjuješ',
        blocks: [
          TableBlock(
            headers: ['Brzina', 'Reakcija', 'Kočenje', 'Zaustavni put'],
            rows: [
              ['30 km/h', '9 m', '9 m', '18 m'],
              ['50 km/h', '15 m', '25 m', '40 m'],
              ['70 km/h', '21 m', '49 m', '70 m'],
              ['100 km/h', '30 m', '100 m', '130 m'],
            ],
          ),
          ParagraphBlock(
            'Za usporedbu: Sprinter je dug oko 6 metara. Pri brzini 50 '
            'trebaš dakle oko sedam duljina vozila do zaustavljanja — a '
            'prve dvije i pol prođu prije nego što uopće dodirneš '
            'papučicu.',
          ),
          RevealBlock(
            prompt: 'Računski zadatak: voziš 50 km/h kroz stambenu ulicu. '
                'Na 20 metara dijete istrčava između dva parkirana auta '
                'na kolnik. Uspiješ li se zaustaviti?',
            answer: 'Ne. Samo tvoj put reakcije iznosi 15 metara, zatim '
                'slijedi 25 metara puta kočenja — zajedno 40 metara. Čak '
                'i s kočenjem u opasnosti (15 m + 12,5 m = 27,5 m) 20 '
                'metara nije dovoljno. Pri brzini 30 pak: 9 m reakcije + '
                '9 m kočenja = 18 metara — stojiš dva metra prije. Upravo '
                'to je razlika između straha i teške nesreće.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pravilo dvije sekunde',
        asset: 'assets/academy/driving/m03b_abstand.svg',
        blocks: [
          ParagraphBlock(
            'Razmak nije pristojnost, nego tvoje vrijeme reakcije '
            'izraženo u metrima. A budući da funkcionira mišljen u '
            'sekundama, automatski se prilagođava tvojoj brzini.',
          ),
          StepsBlock([
            'Odaberi čvrstu točku uz rub ceste — znak, rasvjetni stup, '
                'oznaku na kolniku',
            'Kad vozilo ispred prođe tu točku, počni brojati: „dvadeset '
                'i jedan, dvadeset i dva"',
            'Ako si prije „dvadeset i dva" na točki, voziš preblizu',
            'Po mokrom, magli ili u mraku povećaj na tri sekunde',
          ]),
          FactsBlock([
            FactItem('2 s', 'najmanji razmak na suhom kolniku'),
            FactItem('3 s+', 'po mokrom, magli, u mraku'),
            FactItem('28 m', 'odgovara 2 sekunde pri brzini 50'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 4 st. 1 StVO — razmak',
            text: 'Razmak do vozila ispred u pravilu mora biti tolik da '
                'se i tada može stati iza njega ako ono naglo zakoči. Kao '
                'praktična formula izvan naselja vrijedi pola vrijednosti '
                'brzinomjera u metrima.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kad razmaka nema',
        blocks: [
          RevealBlock(
            prompt: 'Primjer iz prakse: na državnoj cesti pri brzini 80 '
                'uredno držiš 40 metara razmaka. Osobni auto se ubaci u '
                'prazninu i zatim uspori. Što je sada ispravno?',
            answer: 'Nemoj se ljutiti, nemoj trubiti, nemoj gurati — nego '
                'skini gas i ponovno izgradi razmak. To te košta nekoliko '
                'sekundi i jedina je reakcija koja smanjuje tvoj rizik. '
                'Tko se umjesto toga primakne da bi „obranio" prazninu, '
                'pri brzini 80 nema više 40 metara, nego možda 15 — manje '
                'od čistog puta reakcije od 24 metra.',
          ),
          DoDontBlock(
            doTitle: 'Smireno',
            dos: [
              'Nakon ubacivanja mirno ponovno izgradi razmak',
              'Ako te netko gura odostraga: drži se desno, pusti ga '
                  'proći',
              'Pred semaforima i radovima rano skini gas',
              'U koloni ostavi prazninu do vozila ispred da se možeš '
                  'izmaknuti',
            ],
            dontTitle: 'Rizično',
            donts: [
              'Primicati se da spriječiš ubacivanje',
              'Svjetlosni signali i truba kao sredstvo odgoja',
              'U stani-kreni voziti izravno na branik',
              'Razmak procjenjivati samo osjećajem umjesto u sekundama',
            ],
          ),
          FactsBlock([
            FactItem('do 400 €', 'kazna za prekršaj razmaka, uz to bodovi '
                'i zabrana vožnje'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Pogled daleko naprijed',
        asset: 'assets/academy/driving/m03c_blickfuehrung.svg',
        blocks: [
          ParagraphBlock(
            'Ne gledaj u branik ispred sebe, nego 12–15 sekundi unaprijed '
            '— u naselju dakle otprilike dva bloka. Tako rano vidiš '
            'stop-svjetla, semafore, pješake i suženja i ne moraš '
            'reagirati u panici.',
          ),
          BulletsBlock([
            'Dijete na rubniku koje još nije pogledalo',
            'Biciklist koji će odmah zaobići parkirani auto',
            'Vrata auta iza kojih netko sjedi — zadnja svjetla upaljena, '
                'glava u unutarnjem ogledalu',
            'Stop-svjetla tri vozila dalje naprijed',
            'Kante za smeće uz cestu: znak za manevriranje vozila',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Pogled upravlja vozilom',
            text: 'Kamo gledaš, onamo i voziš. Zato pri izbjegavanju '
                'uvijek gledaj u slobodnu prazninu — nikad u prepreku.',
          ),
          ParagraphBlock(
            'Svakih nekoliko sekundi ide i kratak pogled u ogledala. Tako '
            'u svakom trenutku znaš što se događa iza tebe, bez da u '
            'hitnom slučaju tek moraš pogledati.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Brzina je fizika',
        blocks: [
          ParagraphBlock(
            'Dopuštena brzina je maksimum, a ne cilj. U stambenim '
            'područjima, kod škola, uz parkirane aute i u uskim ulicama '
            'sporije od dopuštenog često je jedini ispravan izbor.',
          ),
          FactsBlock([
            FactItem('×4', 'put kočenja pri dvostrukoj brzini'),
            FactItem('18 m', 'zaustavni put pri 30 km/h'),
            FactItem('40 m', 'zaustavni put pri 50 km/h'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 3 st. 1 StVO — vožnja prema preglednosti',
            text: 'Smiješ voziti samo onoliko brzo da možeš stati unutar '
                'preglednog dijela ceste. U magli, mraku ili nepreglednom '
                'zavoju to je znatno manje nego što znak dopušta.',
          ),
          ParagraphBlock(
            'Izračunaj jednom što jurnjava zapravo donosi: na deset '
            'kilometara gradske dionice između brzine 50 i 60 uštediš u '
            'najboljem slučaju dvije minute — koje ti sljedeći crveni '
            'semafor opet oduzme.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Zašto tvoj natovaren kombi vozi drukčije',
        blocks: [
          ParagraphBlock(
            'Puno natovaren kombi drugo je vozilo od istog auta praznog '
            'ujutro. Više mase znači više energije kretanja koju kočnica '
            'mora poništiti — a više težište znači manje rezerve u '
            'zavoju.',
          ),
          FactsBlock([
            FactItem('3,5 t', 'dopuštena ukupna masa tvog kombija'),
            FactItem('do 1,4 t', 'nosivost — više od polovice prazne '
                'mase'),
            FactItem('visoko', 'težište: kombiji se prevrću ondje gdje '
                'osobni auti još kližu'),
          ]),
          BulletsBlock([
            'Natovaren koči ranije i blaže — kočnici treba dulje za isto '
                'usporenje',
            'U zavojima znatno sporije: teret se pomiče prema van i '
                'pojačava sklonost prevrtanju',
            'Pri izbjegavanju ne okreći volan trzajno — upravo to prevrće '
                'visoka vozila',
            'U kružne tokove i izlaze s autoceste ulazi znatno sporije '
                'nego što si navikao',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Trenutak prevrtanja dolazi bez najave',
            text: 'Za razliku od osobnog auta, visoki kombi jedva '
                'najavljuje prevrtanje. Kad se teret čujno pomakne, već '
                'si prebrz — skini brzinu prije ulaska u zavoj, a ne u '
                'njemu.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Mrtvi kut',
        asset: 'assets/academy/driving/m03d_toterwinkel.svg',
        blocks: [
          ParagraphBlock(
            'Tvoj kombi ima velike mrtve kutove — prije svega desno uz '
            'kabinu i koso iza nje. Ondje stane cijeli biciklist zajedno '
            's biciklom, a da ga ne vidiš u ogledalu.',
          ),
          FactsBlock([
            FactItem('desno', 'najveći mrtvi kut kod kombija'),
            FactItem('1,5 m', 'najmanji razmak pri pretjecanju '
                'biciklista u naselju'),
            FactItem('2 m', 'najmanji razmak izvan naselja'),
          ]),
          ParagraphBlock(
            'Pravilno namještanje ogledala smanjuje mrtvi kut, ali ga ne '
            'uklanja. Zato uz svaku promjenu trake i svako skretanje ide '
            'aktivan pogled preko ramena — kratak, pravi pogled preko '
            'ramena, a ne samo kimanje glavom prema ogledalu.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Nikad ne pretpostavljaj da su te vidjeli',
            text: 'Kontakt očima jedini je pouzdan dokaz da te je netko '
                'zamijetio. Žmigavac je namjera, a ne jamstvo.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Skretanje: najopasniji trenutak',
        blocks: [
          ParagraphBlock(
            'Većina teških sudara s biciklistima i pješacima događa se '
            'pri skretanju udesno. Razlog je uvijek isti: biciklist '
            'nastavlja ravno i nalazi se točno u onom području koje vozač '
            'pri zakretanju više ne može vidjeti.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: želiš na semaforu skrenuti '
                'udesno. Biciklist te pretekao slijeva i stoji pokraj '
                'tebe. Semafor se pali zeleno. Što činiš prvo?',
            answer: 'Ostani stajati i pusti ga naprijed. Čim krećeš i '
                'zakrećeš, on ulazi u mrtvi kut desno — a stražnji dio '
                'tvog vozila pri zakretanju dodatno zalazi u njegovu '
                'traku. Ispravno je: prije kretanja pogled preko desnog '
                'ramena, propusti bicikliste i pješake, zatim polako '
                'zakreni i tijekom skretanja ponovno pogledaj u desno '
                'ogledalo. Tko se oslanja samo na ogledalo, ne vidi ga '
                'baš onda kad je najvažnije.',
          ),
          DoDontBlock(
            doTitle: 'Sigurno skretanje',
            dos: [
              'Rano pokazati žmigavcem i znatno smanjiti brzinu',
              'Pogled preko ramena prije zakretanja — ne samo ogledalo',
              'Tijekom skretanja još jednom provjeriti desno',
              'U dvojbi stati i propustiti',
            ],
            dontTitle: 'Rizično',
            donts: [
              'Skretati u zaletu da se iskoristi praznina',
              'Samo pogled u ogledalo',
              'Pretpostaviti da biciklisti ostaju iza tebe',
              'Uključiti žmigavac tek kad već zakrećeš',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Pri skretanju i okretanju',
            text: '§ 9 st. 5 StVO: pri skretanju na posjed, pri okretanju '
                'i pri vožnji unatrag moraš isključiti ugrožavanje drugih '
                'sudionika u prometu — po potrebi moraš zatražiti da te '
                'netko navodi.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista: defenzivno na putu',
        blocks: [
          ChecklistBlock(
            title: 'Ovo provodim od danas',
            items: [
              'Znam praktične formule za put reakcije i put kočenja',
              'Provjeravam svoj razmak na čvrstoj točki s dvije sekunde',
              'Po mokrom i u mraku povećavam na tri sekunde',
              'Gledam 12–15 sekundi unaprijed umjesto u branik',
              'Natovaren vozim sporije u zavojima i kočim ranije',
              'Prije svakog skretanja i promjene trake radim pravi '
                  'pogled preko ramena',
              'Držim 1,5 m razmaka pri pretjecanju biciklista u '
                  'naselju',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M4
  SafetyChapterContent(
    id: 'm4',
    title: 'Vožnja unatrag i manevriranje',
    summary: 'Ovladaj najčešćim izvorom šteta — sigurno unatrag i '
        'manevriranje u uskim situacijama',
    asset: 'assets/academy/driving/m04_rueckwaerts.svg',
    slides: [
      SafetySlide(
        title: 'Izvor šteta broj 1',
        blocks: [
          ParagraphBlock(
            'Većina šteta na kombijima nastaje sporo — pri vožnji unatrag '
            'i manevriranju: stupići, zidovi, rasvjetni stupovi, drugi '
            'auti, otvorena vrata. A u najgorim slučajevima osobe koje '
            'stoje u mrtvom kutu iza vozila.',
          ),
          FactsBlock([
            FactItem('70 %', 'svih šteta na kombijima događa se pri '
                'manevriranju'),
            FactItem('< 10 km/h', 'brzina pri kojoj nastaje većina šteta '
                'od manevriranja'),
            FactItem('slijepo', 'područje od nekoliko metara neposredno '
                'iza vozila'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Zašto baš ovdje',
            text: 'Pri vožnji unatrag nedostaje ti ono što te inače '
                'štiti: slobodan pogled. Istodobno se doima sporo i zato '
                'bezopasno — najopasnija kombinacija u dostavnoj '
                'svakodnevici.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Izbjegavaj vožnju unatrag umjesto da je svladavaš',
        blocks: [
          ParagraphBlock(
            'Najsigurnija vožnja unatrag je ona koju ne napraviš. Već pri '
            'dolasku na stajanje misli na to kako ćeš opet otići — onda '
            'na kraju uopće ne moraš manevrirati.',
          ),
          BulletsBlock([
            'Ako je moguće, parkiraj se prednjim dijelom i prednjim '
                'dijelom opet odlazi',
            'Radije stani 40 metara dalje nego da se vraćaš u uski '
                'kolni ulaz',
            'Kod slijepih ulica i dvorišta: prije ulaska razmisli kako '
                'ćeš opet izaći',
            'Zapamti mjesta za okretanje na ruti — svaki dan su ista',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Što traže zakon i DGUV',
            text: '§ 9 st. 5 StVO: pri vožnji unatrag moraš isključiti '
                'ugrožavanje drugih, po potrebi zatražiti navodioca. DGUV '
                'Vorschrift 70 (njemački propis o vozilima) traži isto: '
                'vožnja unatrag samo ako je ugrožavanje osoba '
                'isključeno.',
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
            text: '„Get Out And Look" — stani, izađi, pogledaj iza vozila '
                'i tek onda kreni unatrag. To otkriva upravo one stvari '
                'koje sa sjedala nikad ne vidiš.',
          ),
          ParagraphBlock(
            'Obilazak traje deset do petnaest sekundi. U tom vremenu '
            'vidiš niske stupiće, rubnike, pad terena, labave poklopce '
            'šahtova, djecu koja se igraju i visinu ulaznog prolaza. '
            'Ništa od toga ti kamera za vožnju unatrag ne pokazuje '
            'pouzdano.',
          ),
          FactsBlock([
            FactItem('15 s', 'traje GOAL obilazak'),
            FactItem('90 cm', 'visina ispod koje dijete iza vozila ostaje '
                'nevidljivo'),
          ]),
          ParagraphBlock(
            'I još nešto: ono što si vidio pri izlasku, zadržavaš u '
            'glavi. Nakon toga ne voziš u nepoznato, nego prema slici '
            'koju poznaješ.',
          ),
        ],
      ),
      SafetySlide(
        title: 'GOAL korak po korak',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/goal01_stopp.svg',
              title: '1 · Stani',
              caption: 'Prije nego ubaciš u rikverc, potpuno staneš i '
                  'osiguraš vozilo. Tko se već kotrlja, više ne odlučuje '
                  '— on samo reagira.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal02_aussteigen.svg',
              title: '2 · Izađi',
              caption: 'Izađi umjesto da se izvijaš u sjedalu. Koristi '
                  'pritom stepenicu i rukohvate — pravilo triju točaka '
                  'vrijedi i ovdje.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal03_umschauen.svg',
              title: '3 · Osvrni se',
              caption: 'Obiđi vozilo u cijelosti: što stoji nisko iza '
                  'stražnjeg dijela, koliko je visok ulaz, gdje je pad '
                  'terena, ima li djece ili životinja u blizini? Zapamti '
                  'razmake i čvrste točke.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal04_zurueck.svg',
              title: '4 · Polako unatrag',
              caption: 'Tek sada kreni unatrag — brzinom pješaka, s '
                  'pogledom preko ramena i u oba ogledala. U dvojbi '
                  'ponovno stani i iznova pogledaj.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Sporo ne znači bezopasno',
        blocks: [
          StepsBlock([
            'Odaberi brzinu pješaka — nikad brže, ni na praznom '
                'dvorištu',
            'Spusti prozor da čuješ: dozivanje, trube, djecu',
            'Gledaj preko ramena i u oba ogledala, naizmjence',
            'Kameru koristi samo kao dopunu, nikad kao jedini izvor',
            'Kod svake dvojbe stani, izađi, iznova pogledaj',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Zabluda o kameri',
            text: 'Kamera za vožnju unatrag pokazuje isječak, iskrivljuje '
                'razmake i oslijepi od kiše, snijega i prljavštine. Ona '
                'ne vidi ništa što sa strane uz stražnji dio ulazi u tvoj '
                'put. Ona ne zamjenjuje GOAL.',
          ),
          FactsBlock([
            FactItem('pješak', 'najveća brzina pri manevriranju'),
            FactItem('2 s', 'treba djetetu da utrči u područje iza '
                'vozila'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Pravilno koristi navodioca',
        blocks: [
          ParagraphBlock(
            'Navodilac pomaže samo ako su pravila unaprijed jasna. Kolega '
            'koji stoji negdje iza vozila i maše nije sigurnost — on je '
            'dodatan rizik.',
          ),
          BulletsBlock([
            'Znakove dogovorite unaprijed: stop, polako, dalje, koliko '
                'ima mjesta',
            'Navodilac stoji sa strane, nikad neposredno iza vozila',
            'Moraš ga stalno vidjeti u ogledalu — inače vrijedi stop',
            'Navodi samo jedna osoba, ne više njih istodobno',
            'Navodilac nosi sigurnosni prsluk, osobito u sumrak',
          ]),
          RevealBlock(
            prompt: 'Voziš unatrag u uski kolni ulaz, kolega te navodi. '
                'Odjednom ga više ne vidiš u ogledalu. Što činiš?',
            answer: 'Odmah stani — ne usporiti, nego stati. Nema '
                'kontakta pogledom znači nema važećeg znaka. Možda je '
                'prošao iza vozila, poskliznuo se ili ga je zaustavio '
                'prolaznik. Kreni dalje tek kad ga opet vidiš i kad ti '
                'dade novi znak.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Primjer iz prakse: uski kolni ulaz',
        blocks: [
          RevealBlock(
            prompt: 'Primjer iz prakse: zadnje stajanje je u unutarnjem '
                'dvorištu. Ulaz je uzak, iza tebe čeka auto, pada kiša i '
                '40 si minuta iza plana. Naprijed ulaziš — van samo '
                'unatrag, pokraj zida i tri parkirana auta. Koja je '
                'ispravna odluka?',
            answer: 'Uopće nemoj ulaziti. Stani na ulici, zadnje metre '
                'prijeđi pješice ili koristi kolica. Ako si već unutra: '
                'upali sva četiri, izađi, pogledaj situaciju, po potrebi '
                'zamoli vozača koji čeka da se odmakne, i zatim izađi u '
                'nekoliko kratkih poteza s međuprovjerama. Vozač koji '
                'čeka iza tebe nije razlog za žurbu — šteta se na kraju '
                'pripisuje tebi, a ne njemu. Tih 40 minuta zakašnjenja ne '
                'nadoknađuje nijedan manevar, a šteta na limu košta te '
                'ostatak dana.',
          ),
          DoDontBlock(
            doTitle: 'Pravilno manevriranje',
            dos: [
              'U nekoliko kratkih poteza umjesto u jednom dugom',
              'Između stani i iznova provjeri situaciju',
              'Sva četiri pri manevriranju u prometnom prostoru',
              'Radije stani dalje i zadnje metre prijeđi pješice',
            ],
            dontTitle: 'Pogrešno',
            donts: [
              'Manevrirati brže pod pritiskom onih koji čekaju',
              'Sve „provući" u jednom potezu jer inače djeluje neugodno',
              'Oslanjati se samo na kameru ili senzore',
              'Manevrirati dok pješaci prelaze područje',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista: unatrag i manevriranje',
        blocks: [
          ChecklistBlock(
            title: 'Prije svakog manevra unatrag',
            items: [
              'Prvo provjeravam mogu li izbjeći vožnju unatrag',
              'Potpuno stajem prije nego ubacim u rikverc',
              'Izlazim i gledam iza vozila (GOAL)',
              'Unatrag vozim samo brzinom pješaka',
              'Gledam preko ramena i u oba ogledala, ne samo u kameru',
              'Spuštam prozor da čujem',
              'Odmah stajem kad više ne vidim navodioca',
              'Prijavljujem svaku štetu od manevriranja, i malu udubinu',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M5
  SafetyChapterContent(
    id: 'm5',
    title: 'Vrijeme, vidljivost i teški uvjeti',
    summary: 'Prilagodi način vožnje kiši, mokrom kolniku, magli, snijegu, '
        'mraku i vrućini',
    asset: 'assets/academy/driving/m05_wetter.svg',
    slides: [
      SafetySlide(
        title: 'Mokro mijenja sve',
        blocks: [
          ParagraphBlock(
            'Na mokrom kolniku prianjanje znatno pada — put kočenja se '
            'osjetno produljuje, u mnogim situacijama gotovo na '
            'dvostruko. Posebno je kritična prva kiša nakon duge suše: '
            'ulje i guma na kolniku s vodom tvore skliski film.',
          ),
          FactsBlock([
            FactItem('do ×2', 'toliko dug postaje put kočenja po '
                'mokrom'),
            FactItem('3 s+', 'najmanji razmak umjesto 2 sekunde'),
            FactItem('−20 %', 'brzina kao gruba orijentacija'),
          ]),
          BulletsBlock([
            'Koči ranije i blaže, ne u zavoju',
            'Pokrete volana izvodi meko, ne trzajno',
            'Pazi na oznake na kolniku, poklopce šahtova i tramvajske '
                'tračnice — ondje je najskliskije',
            'Izbjegavaj kolotrage, ondje stoji voda',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Brzina je obveza, a ne izbor',
            text: '§ 3 st. 1 StVO traži da brzinu prilagodiš stanju '
                'ceste, prometa, vidljivosti i vremena. Kod nesreće na '
                'mokroj cesti dopuštena ti brzina ne pomaže.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Akvaplaning: što se tu zapravo događa',
        asset: 'assets/academy/driving/m05b_aquaplaning.svg',
        blocks: [
          ParagraphBlock(
            'Akvaplaning znači: između gume i kolnika ugura se vodeni '
            'film. Guma pliva. Od tog trenutka upravljanje i kočnica '
            'nemaju više učinka — ne manji, nego nikakav.',
          ),
          ParagraphBlock(
            'Kanali u šari imaju točno jedan zadatak: odvesti vodu ispred '
            'gume. Pri većoj brzini guma mora svake sekunde istisnuti '
            'nekoliko litara vode. Što je šara plića i brzina veća, to '
            'prije to više ne uspijeva.',
          ),
          FactsBlock([
            FactItem('1,6 mm', 'zakonski minimum — za akvaplaning već '
                'premalo'),
            FactItem('3 mm', 'praktična donja granica po mokrom '
                'vremenu'),
            FactItem('Brzina²', 'toliko snažno raste opasnost od '
                'akvaplaninga s brzinom'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Po čemu to rano primijetiš',
            text: 'Volan odjednom postane lagan, zvukovi vožnje se '
                'mijenjaju, broj okretaja raste bez razloga. To su '
                'sekunde u kojima još možeš skinuti gas.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Akvaplaning: ispravna reakcija',
        blocks: [
          DoDontBlock(
            doTitle: 'Kod stajaće vode ispravno',
            dos: [
              'Skini gas — samo to, ne naglo do kraja',
              'Volan drži mirno i ravno',
              'Pritisni kvačilo odnosno pusti da se isključi',
              'Pusti vozilo da se izveze dok gume opet ne uhvate',
              'Tek nakon toga oprezno okreni volan ili koči',
            ],
            dontTitle: 'Pogrešno',
            donts: [
              'Snažno kočiti — kotači se beskorisno blokiraju',
              'Trzajno okretati ili kontrirati volanom',
              'Ubrzavati da se „probije"',
              'Mijenjati traku dok gume plivaju',
            ],
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: na državnoj cesti nakon oluje '
                'stoji voda u desnom kolotragu. Voziš 80 km/h, iza tebe '
                'te gura osobni auto. Što radiš?',
            answer: 'Znatno skini gas prije nego uđeš u vodu — a ne u '
                'njoj. Drži volan ravno i pusti onoga da gura; '
                'nalijetanje straga se popravlja, izlijetanje u '
                'suprotni trak ne. Tko umjesto toga usred vode koči ili '
                'skreće, izaziva upravo onaj gubitak kontrole koji želi '
                'izbjeći. Ako je moguće: nakon vode drži se desno i '
                'pusti ga da prođe.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Guma koja pliva ne upravlja',
            text: 'Dok god vodeni film nosi, svaki je pokret volana bez '
                'učinka — on djeluje naglo tek kad guma opet uhvati. '
                'Upravo iz toga nastaje proklizavanje.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dubina šare i zimske gume',
        blocks: [
          TableBlock(
            headers: ['Situacija', 'Šara / gume'],
            rows: [
              ['Zakonski minimum', '1,6 mm — cijele godine'],
              ['Ljeto, mokra cesta', 'preporučeno od 3 mm'],
              ['Zima, snijeg i bljuzga', 'preporučeno od 4 mm'],
              ['Poledica, snijeg, led', 'zimske gume s Alpine oznakom'],
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Situacijska obveza zimskih guma',
            text: 'Prema § 2 st. 3a StVO kod poledice, snježne poledice, '
                'snježne bljuzge, ledene ili inja smiješ voziti samo sa '
                'zimskim gumama. Prekršaji stoje novčane kazne i jedan '
                'bod — kod ometanja drugih i više.',
          ),
          BulletsBlock([
            'Zimske gume prepoznaješ po Alpine oznaci (planina s '
                'pahuljicom)',
            'I zimske gume s premalo šare gotovo više ne djeluju',
            'Pazi i na starost gume: guma otvrdne i gubi prianjanje, čak '
                'i ako je šara još tu',
            'Prijavi tanku šaru prije prvog mraza — a ne ujutro nakon '
                'njega',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Snijeg, led i struganje stakala',
        asset: 'assets/academy/driving/m05c_winter.svg',
        blocks: [
          ParagraphBlock(
            'Na poledici za sve vrijedi: blago. Blago kreni, blago koči, '
            'blago okreći volan. Svaki trzaj preopterećuje ionako slabo '
            'prianjanje. Mostovi, šumske dionice i sjenovita mjesta '
            'zaleđuju se prvi — a otapaju posljednji.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Nikakva „rupica za gledanje"',
            text: 'Sva stakla, ogledala, svjetla i registarska pločica '
                'moraju biti slobodni (§ 23 st. 1 StVO). Ostrugana rupica '
                'za gledanje je prekršaj — a kod nesreće težak prigovor '
                'krivnje. I snijeg s krova mora dolje prije nego što '
                'kreneš.',
          ),
          DoDontBlock(
            doTitle: 'Zimska rutina',
            dos: [
              'Sva stakla i ogledala potpuno ostrugati',
              'Krov, svjetla i pločicu očistiti od snijega',
              'Stepenice i rukohvate očistiti od leda i bljuzge',
              'Tekućinu za pranje dopuniti sredstvom protiv smrzavanja',
              'Krenuti znatno ranije umjesto sustizati na putu',
            ],
            dontTitle: 'Zimske pogreške',
            donts: [
              'Krenuti dok se staklo još odmrzava',
              'Politi staklo vrućom vodom',
              'Kočiti po snježnoj bljuzgi i istodobno zakretati',
              'Ignorirati zaleđene stepenice — ovdje padaš',
            ],
          ),
          FactsBlock([
            FactItem('0 °C', 'odavde prvo mostovi i sjenovita mjesta'),
            FactItem('×2 do ×10', 'toliko dulji postaje put kočenja na '
                'snijegu i ledu'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Magla, sumrak, mrak',
        blocks: [
          ParagraphBlock(
            'Kod loše vidljivosti nije teže samo vidjeti, nego i biti '
            'viđen. Upali svjetla na vrijeme — u dvojbi pola sata ranije '
            'nego što je potrebno.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Pravilo u magli',
            text: 'Vidljivost u metrima odgovara najvećoj brzini u km/h. '
                'Vidiš li samo 50 metara, voziš najviše 50 km/h — a kod '
                'vidljivosti ispod 50 metara ionako vrijedi brzina 50 kao '
                'gornja granica.',
          ),
          BulletsBlock([
            'Svjetla za maglu samo kod stvarno smanjene vidljivosti, ne '
                'kao stalna rasvjeta',
            'Stražnje svjetlo za maglu tek ispod 50 metara vidljivosti — '
                'ono jako zasljepljuje onoga iza',
            'Koristi smjerokaze uz rub kolnika za orijentaciju',
            'U sumrak posebno pazi na pješake u tamnoj odjeći',
            'Unutarnja rasvjeta isključena, stakla iznutra čista — oboje '
                'inače oduzima noćni vid',
          ]),
          FactsBlock([
            FactItem('50 m', 'razmak između dva smjerokaza izvan '
                'naselja'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Oluja i bočni vjetar',
        blocks: [
          ParagraphBlock(
            'Tvoj kombi je velika, visoka površina — na bočnom vjetru '
            'ponaša se posve drukčije od osobnog auta. Osobito su opasna '
            'mjesta na kojima vjetar naglo zapuše: mostovi, izlazi iz '
            'šume, praznine između zgrada i kad te pretječe kamion.',
          ),
          BulletsBlock([
            'Znatno smanji brzinu, obje ruke na volan',
            'Na poznatim vjetrovitim mjestima unaprijed pojačaj stisak i '
                'računaj s udarom',
            'Nakon pretjecanja kamiona računaj s naletom vjetra',
            'Za oluje ne parkiraj pod drvećem ni uz skele',
            'Drži vrata na vjetru — ona se otrgnu i oštete',
          ]),
          RevealBlock(
            prompt: 'Primjer iz prakse: upozorenje na oluju, voziš prazan '
                'preko mosta na autocesti. Zašto je baš prazan kritično?',
            answer: 'Jer vozilu nedostaje težina koja ga drži na cesti. '
                'Prazan kombi nudi vjetru istu površinu kao natovaren, '
                'ali teži dobru trećinu manje — isti ga udar znatno jače '
                'pomakne. Ispravno je: prije mosta skini brzinu, obje '
                'ruke na volan, računaj s naletom vjetra na kraju mosta i '
                'ne vozi uz kamion.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Vrućina i duge ture',
        blocks: [
          ParagraphBlock(
            'Ljeti radiš u vozilu koje se na suncu snažno zagrijava i '
            'pritom prehodaš mnogo kilometara. Pregrijan, dehidriran '
            'vozač reagira mjerljivo sporije — učinak je usporediv s onim '
            'od umora.',
          ),
          FactsBlock([
            FactItem('2–3 l', 'tekućine po smjeni na vrućini'),
            FactItem('> 60 °C', 'temperatura u vozilu koje stoji na '
                'suncu'),
          ]),
          BulletsBlock([
            'Pij redovito, prije nego što osjetiš žeđ',
            'Pauze u hladu, ne u pregrijanoj kabini',
            'Pokrivalo za glavu i zaštita od sunca kod dugih pješačenja',
            'Kod problema s krvotokom odmah javi i napravi pauzu',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Nikad ne ostavljaj',
            text: 'Nikad ne ostavljaj životinju ni osobu u pregrijanom '
                'vozilu — ni „samo pet minuta" ni s odškrinutim prozorom. '
                'Unutrašnjost u nekoliko minuta postane opasno vruća po '
                'život.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista: teški uvjeti',
        blocks: [
          ChecklistBlock(
            title: 'Kod vremena i loše vidljivosti',
            items: [
              'Prilagođavam brzinu i razmak, ne samo prema znaku',
              'Po mokrom povećavam na najmanje 3 sekunde razmaka',
              'Kod akvaplaninga: gas dolje, ravno, ne kočiti',
              'Znam svoju dubinu šare i rano prijavljujem tanke gume',
              'Struganjem oslobađam sva stakla, bez rupice za gledanje',
              'Uklanjam snijeg s krova, svjetala i registarske pločice',
              'Na mostovima i izlazima iz šume računam s bočnim vjetrom',
              'Pijem dovoljno i pauze radim u hladu',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M6
  SafetyChapterContent(
    id: 'm6',
    title: 'Ometanje, umor i vremenski pritisak',
    summary: 'Prepoznaj glavne ljudske uzroke nesreća i aktivno djeluj '
        'protiv njih',
    asset: 'assets/academy/driving/m06_ablenkung.svg',
    slides: [
      SafetySlide(
        title: 'Mobitel za volanom: ZABRANJENO',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Mobitel u ruci zabranjen je tijekom vožnje',
            text: 'Ni za telefoniranje, ni za tipkanje, ni za provjeru — '
                'a ni za biranje glazbe, podcasta ili poruka.',
          ),
          ParagraphBlock(
            'Posve jasno i bez iznimke. To nije samo naše pravilo tvrtke, '
            'nego zakon. I vrijedi za svaki elektronički uređaj koji '
            'služi komunikaciji, informiranju ili organizaciji — dakle i '
            'za skener.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 23 st. 1a StVO',
            text: 'Tko upravlja vozilom, smije koristiti elektronički '
                'uređaj samo ako ga pritom niti uzima niti drži. Već je '
                'uzimanje ili držanje u ruci prekršaj — neovisno o tome '
                'što s njim radiš.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dionica u slijepom letu',
        asset: 'assets/academy/driving/m06b_handy.svg',
        blocks: [
          ParagraphBlock(
            'Pogled na zaslon nije jedna sekunda — u prosjeku traje dvije '
            'do tri sekunde, pročitana poruka prije pet. U tom vremenu '
            'voziš zatvorenih očiju. Izračunaj to jednom u metrima.',
          ),
          FactsBlock([
            FactItem('14 m/s', 'prelaziš pri brzini 50 svake sekunde'),
            FactItem('28 m', 'slijepo pri 2 sekunde pogleda na mobitel'),
            FactItem('oko 70 m', 'slijepo kad čitaš poruku'),
          ]),
          RevealBlock(
            prompt: 'Računski zadatak: voziš 30 km/h kroz zonu '
                'usporenog prometa i gledaš 3 sekunde u skener. Koliko '
                'daleko voziš slijepo — i je li to dovoljno za nesreću?',
            answer: 'Pri 30 km/h prelaziš dobrih 8 metara u sekundi, u 3 '
                'sekunde dakle oko 25 metara. To je više od cijelog '
                'zaustavnog puta pri toj brzini (18 metara). Drukčije '
                'rečeno: slijepo prolaziš dionicu na kojoj bi uz pogled '
                'odavno mogao stati. Tko misli da je pri maloj brzini '
                'pogled bezopasan, brka sporo sa sigurnim — upravo u '
                'zonama usporenog prometa djeca istrčavaju na kolnik bez '
                'najave.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Glazba, navigacija, skener — sve unaprijed',
        blocks: [
          ParagraphBlock(
            'Glazba i podcasti su u redu — ali ne s mobitelom u ruci. Sve '
            'odaberi i pokreni prije polaska, u mjestu: playlistu, '
            'glasnoću, odredište navigacije, sljedeće stajanje. Kad '
            'jednom radi, tijekom vožnje se uređaja više ne dotiče.',
          ),
          DoDontBlock(
            doTitle: 'Dopušteno',
            dos: [
              'Playlistu i glasnoću namjestiti unaprijed u mjestu',
              'Odredište navigacije unijeti prije polaska',
              'Mobitel ostaviti u držaču i samo ga gledati',
              'Govoriti slobodnih ruku preko handsfree uređaja',
              'Za sve ostalo nakratko stati',
            ],
            dontTitle: 'Zabranjeno',
            donts: [
              'Mijenjati pjesmu ili podcast tijekom vožnje',
              'Čitati ili tipkati poruku tijekom vožnje',
              'Uzeti mobitel u ruku na crvenom semaforu',
              'Rukovati skenerom ili listom stajanja u vožnji',
              'Skinuti uređaj s držača da ga bolje vidiš',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Nikakve slušalice',
            text: 'Nikakve slušalice ni bubice tijekom vožnje — ni na '
                'jednom uhu. Moraš čuti promet, trube, dozivanje i vozila '
                'hitnih službi. Pri manevriranju je tvoj sluh često '
                'jedino upozorenje.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Jedina iznimka: u mjestu, motor ugašen',
        blocks: [
          ParagraphBlock(
            'Mobitelom, skenerom i navigacijom rukuješ samo dok sigurno '
            'stojiš. Praktičan tijek na stajanju: stani, ugasi motor, '
            'rukuj uređajem, zatim izađi. A prije polaska: uđi, namjesti '
            'odredište i glazbu, pa kreni.',
          ),
          RevealBlock(
            prompt: 'Od kada pravno vrijedi „stajanje" — i što je sa '
                'start-stop automatikom na crvenom semaforu?',
            answer: 'Pravno stajanje vrijedi tek kad je motor ugašen. '
                'Iznimka izričito ne vrijedi kad motor miruje samo zbog '
                'automatske start-stop funkcije. Na crvenom semaforu '
                'dakle ne smiješ uzeti uređaj u ruku — ni kad motor '
                'upravo miruje.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Iznimka samo kod ugašenog motora',
            text: 'Rukovanje je dopušteno samo ako vozilo stoji i motor '
                'je ugašen. Automatsko start-stop gašenje za to nije '
                'dovoljno.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Koliko to stoji',
        blocks: [
          FactsBlock([
            FactItem('100 € + 1 bod', 'mobitel u ruci tijekom vožnje'),
            FactItem('150 € + 2 boda', 'uz ugrožavanje, plus 1 mjesec '
                'zabrane vožnje'),
            FactItem('200 € + 2 boda', 'uz oštećenje stvari, plus 1 '
                'mjesec zabrane vožnje'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Probno razdoblje',
            text: 'U probnom razdoblju vozačke dozvole dolaze još '
                'dodatni seminar i produljenje probnog razdoblja na 4 '
                'godine.',
          ),
          ParagraphBlock(
            'Za tebe kao profesionalnog vozača zabrana vožnje znači: bez '
            'posla mjesec dana. A ako iz ometanja nastane nesreća s '
            'ozlijeđenima, neće ostati na novčanoj kazni — tada se '
            'postavlja optužba za ugrožavanje cestovnog prometa (§ 315c '
            'StGB), a to je kazneno djelo.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Najjednostavnije osiguranje',
            text: 'Odložiti mobitel ne stoji ništa, a štiti tvoju '
                'vozačku, tvoje radno mjesto i u ozbiljnom slučaju jedan '
                'život.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ometanje ima mnogo oblika',
        blocks: [
          ParagraphBlock(
            'Ne samo mobitel: jelo, piće, traženje paketa, razgovori, '
            'ljutnja zbog zadnjeg kupca, misli o sljedećem stajanju. '
            'Ometanje je sve što odvlači oči, ruke ili glavu s ceste.',
          ),
          DoDontBlock(
            doTitle: 'U redu tijekom vožnje',
            dos: [
              'Gledati na cestu',
              'Govoriti slobodnih ruku preko handsfree uređaja',
              'Kratki pogledi u ogledala',
              'Za sve ostalo nakratko stati',
            ],
            dontTitle: 'Nije u redu',
            donts: [
              'Raspakiravati jelo ili piće',
              'Tražiti sljedeći paket u teretnom prostoru',
              'Rukovati skenerom ili listom stajanja u vožnji',
              'Tijekom vožnje iznova slagati rutu u glavi umjesto da '
                  'nakratko staneš',
            ],
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: pri polasku primijetiš da si '
                'uzeo krivu pošiljku. Ispravno stajanje je 300 metara '
                'dalje. Što činiš?',
            answer: 'Odvezi se do sljedećeg sigurnog mjesta za '
                'zaustavljanje, stani, ugasi motor, pa zamijeni u '
                'teretnom prostoru. Posezanje unatrag tijekom vožnje '
                'klasična je situacija u kojoj vozači izlaze iz trake — '
                'pritom istodobno okrećeš glavu i gornji dio tijela. 300 '
                'metara zaobilaska traje 30 sekundi, a ogrebotina '
                'ostatak dana.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Umor: tvoje tijelo ne pregovara',
        asset: 'assets/academy/driving/m06c_muedigkeit.svg',
        blocks: [
          ParagraphBlock(
            'Umor nije problem volje. Od određene točke tvoj se mozak '
            'nakratko isključuje — htio ti to ili ne. Podmuklo je to što '
            'upravo u toj fazi najjače precjenjuješ vlastitu budnost.',
          ),
          SubheadBlock('Znakovi upozorenja koje moraš shvatiti ozbiljno'),
          BulletsBlock([
            'Često zijevanje, pekuće ili teške oči',
            'Ne sjećaš se zadnjih kilometara',
            'Promašuješ skretanja ili stajanja',
            'Razmak sjedala odjednom se čini krivim, vrpoljiš se',
            'Nemirno voziš u traci ili stalno ispravljaš',
            'Zima i napetost u vratu bez vanjskog razloga',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Rizična razdoblja',
            text: 'Najopasniji su rani jutarnji sati, pad nakon ručka i '
                'zadnji sat ture. Upravo ondje isplaniraj svoje pauze.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Mikrospavanje u metrima',
        blocks: [
          ParagraphBlock(
            'Mikrospavanje obično traje dvije do pet sekundi. To zvuči '
            'kratko — dok se ne izračuna u metrima.',
          ),
          FactsBlock([
            FactItem('56 m', 'pri brzini 50 u 4 sekunde '
                'mikrospavanja'),
            FactItem('89 m', 'pri brzini 80 u 4 sekunde'),
            FactItem('111 m', 'pri brzini 100 u 4 sekunde'),
          ]),
          RevealBlock(
            prompt: 'Računski zadatak: voziš 80 km/h na regionalnoj cesti '
                'i zaspiš na 4 sekunde. Koliko daleko voziš bez kontrole '
                '— i što se nalazi na toj dionici?',
            answer: '80 km/h je oko 22 metra u sekundi, u 4 sekunde dakle '
                'oko 89 metara. Na toj se dionici na regionalnoj cesti '
                'obično nalaze zavoj, drvored i promet iz suprotnog '
                'smjera. I za razliku od pogleda na mobitel, u tom '
                'vremenu ne upravljaš — vozilo izlazi iz trake. Zato '
                'protiv mikrospavanja pomaže samo jedno: stati '
                'unaprijed.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Male verzije toga nema',
            text: 'Tko je jednom zaspao, zaspat će opet — najčešće unutar '
                'nekoliko minuta. Vožnja završava ovdje, a ne na '
                'sljedećem stajanju.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Što pomaže — a što ne',
        blocks: [
          DoDontBlock(
            doTitle: 'Stvarno djeluje',
            dos: [
              'Stati i 15–20 minuta zatvoriti oči',
              'Izaći, hodati, svjež zrak i kretanje',
              'Nešto pojesti i popiti',
              'Prijaviti turu i zatražiti podršku ako to nije dovoljno',
            ],
            dontTitle: 'Ne djeluje (ili samo minutama)',
            donts: [
              'Otvoren prozor i glasna glazba',
              'Kava kao zamjena za san',
              'Održavati se budnim razgovorima',
              'Voziti brže da se prije završi',
            ],
          ),
          ParagraphBlock(
            'Kratak san od 15 do 20 minuta uz kretanje nakon njega jedina '
            'je mjera koja kratkoročno stvarno nešto donosi. Sve ostalo '
            'samo pomiče problem za nekoliko kilometara.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Nesposobnost za vožnju',
            text: 'Tko unatoč vidljivoj premorenosti nastavi voziti, '
                'upravlja vozilom nesposoban za vožnju. Dođe li pritom do '
                'ugrožavanja, to više nije novčana kazna, nego kazneno '
                'djelo (§ 315c StGB).',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pametno upravljaj vremenskim pritiskom i kontrolna lista',
        blocks: [
          ParagraphBlock(
            'Vremenski pritisak je stvaran — ali jurnjava i žurba jedva '
            'štede vrijeme, a stoje mnogo rizika. Dobitak na vremenu od '
            'brže vožnje u gradskom prometu je u rasponu minuta; jedna '
            'jedina šteta pri manevriranju košta te sat vremena.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Kad plan ne ide',
            text: 'To nije problem sigurnosti, to je tema planiranja — '
                'prijavi ga rano umjesto da ga nadoknađuješ za volanom. '
                'Prijava u 13 sati pomaže, ona u 18 sati više ne.',
          ),
          ChecklistBlock(
            title: 'Ovo nosim iz modula 6',
            items: [
              'Moj mobitel tijekom vožnje ostaje netaknut',
              'Glazbu, navigaciju i skener namještam prije polaska',
              'Znam da „stajanje" vrijedi tek uz ugašen motor',
              'Ne nosim slušalice',
              'Poznajem svoje osobne znakove umora',
              'Kod umora stajem umjesto da izdržavam',
              'Nerealan plan prijavljujem rano i pošteno',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M7
  SafetyChapterContent(
    id: 'm7',
    title: 'Nesreće na radu: ulazak/izlazak, dizanje i padovi',
    summary: 'Izbjegni ozljede izvan vožnje — težište na sigurnom ulasku i '
        'izlasku',
    asset: 'assets/academy/driving/m07_ein_aussteigen.svg',
    slides: [
      SafetySlide(
        title: 'Zašto je to najvažniji pokret dana',
        blocks: [
          ParagraphBlock(
            'Po turi ulaziš i izlaziš desetke puta — to je pokret koji '
            'najčešće radiš. Upravo se zato ovdje događa najviše ozljeda: '
            'uganuća, klizanje na rubu stepenice, pad iz vozila, krivi '
            'korak u promet.',
          ),
          FactsBlock([
            FactItem('100.000', 'nesreća klizanja, spoticanja i padanja '
                'kod profesionalnih vozača godišnje'),
            FactItem('24', 'dana izostanka u prosjeku po padu'),
            FactItem('Br. 1', 'najčešća vrsta ozljede u dostavi'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'BG Verkehr upozorava',
            text: 'BG Verkehr (njemačko strukovno osiguranje za promet) '
                'izričito upozorava da padovi pri ulasku i izlasku dovode '
                'do teških, ponekad smrtonosnih ozljeda.',
          ),
          ParagraphBlock(
            'Razlika između sigurnog i opasnog izlaska su dvije sekunde. '
            'Preračunato na 250 izlazaka dnevno to je dobrih osam minuta '
            '— najjeftinije osiguranje tvog tijela.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pravilo triju točaka (2+1)',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Dvije ruke i jedno stopalo — uvijek',
            text: 'Središnje pravilo BG Verkehr: dvije ruke i jedno '
                'stopalo uvijek su u dodiru s vozilom — „2+1".',
          ),
          ParagraphBlock(
            'Imaš dakle u svakom trenutku tri čvrste dodirne točke prije '
            'nego što otpustiš sljedeću. Tako pojedinačno klizanje nikad '
            'ne može postati pad, jer te i dalje drže dvije točke. Pomiči '
            'uvijek samo jednu točku, nikad dvije istodobno.',
          ),
          RevealBlock(
            prompt: 'Koje se tri dodirne točke misle — a što izričito ne '
                'spada među njih?',
            answer: 'Lijeva ruka na rukohvatu, desna ruka na rukohvatu, '
                'jedno stopalo na stepenici. Ne spadaju: volan, rub '
                'vrata, sjedalo, guma i glavčina kotača. Rub vrata i '
                'volan popuštaju ili se okreću — upravo onda kad ti '
                'trebaju.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Zapamti',
            text: 'Prvo siđi, pa onda uzmi. Predmete prvo odloži u '
                'vozilo, pa izađi slobodnih ruku.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pravilno unutra, pravilno van',
        blocks: [
          BulletsBlock([
            'Ulazak: licem prema vozilu, naprijed',
            'Izlazak: unatrag, licem prema vozilu — kao na ljestvama, '
                'nikad se okretati leđima prema vratima',
            'Koristi sve stepenice — nijednu ne preskači',
            'Koristi rukohvate, a ne rub vrata ili volan kao hvatište u '
                'nuždi',
            'Pri izlasku iz teretnog prostora isto pravilo: lice prema '
                'vozilu, stepenicu po stepenicu',
          ]),
          StepsBlock([
            'Stani i osiguraj vozilo',
            'Predmete odloži u vozilo',
            'Provjeri promet preko ramena i u ogledalu',
            'Vrata otvori kontrolirano',
            'Okreni se, lice prema vozilu',
            'Uspostavi tri dodirne točke',
            'Silazi stepenicu po stepenicu',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Nikada ne skači',
        asset: 'assets/academy/driving/m07b_springen.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Skakanje je najčešća pogreška',
            text: 'Skok iz kabine ili teretnog prostora najčešći je uzrok '
                'uganutih gležnjeva te ozljeda koljena i leđa u dostavi.',
          ),
          ParagraphBlock(
            'Pod teretnog prostora kombija je, ovisno o modelu, oko 55 do '
            '75 centimetara iznad ceste. Pri skoku, u trenutku doskoka, '
            'na skočni zglob, koljeno i kralježnicu djeluje višestruka '
            'tvoja tjelesna težina — i to pri svakom pojedinom skoku.',
          ),
          FactsBlock([
            FactItem('55–75 cm', 'visina poda teretnog prostora iznad '
                'ceste'),
            FactItem('250+', 'izlazaka po turi — svaki pojedini se broji '
                'zglobovima'),
          ]),
          RevealBlock(
            prompt: 'Primjer iz prakse: pada kiša, skačeš iz teretnog '
                'prostora na kosi pločnik s mokrim lišćem. Što točno tu '
                'krene po zlu?',
            answer: 'Pri skoku doskok više ne možeš ispraviti — u zraku '
                'si, a što se ispod tebe događa, odlučuje podloga. Mokro '
                'lišće na nagibu gotovo da ne daje trenje: stopalo pri '
                'doskoku otklizne, zglob se bočno uvrne. Tko umjesto toga '
                'silazi stepenicu po stepenicu s tri dodirne točke, '
                'osjeti sklisku podlogu prije nego na nju stavi punu '
                'težinu — i još može odustati.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tipične pogreške',
        blocks: [
          DoDontBlock(
            doTitle: 'Ispravno',
            dos: [
              'Predmete prvo odložiti u vozilo',
              'Silaziti slobodnih ruku i s tri dodirne točke',
              'Rubove stepenica i rukohvate držati čistima i slobodnima',
              'Po mokrom i ledu stepenice prije očistiti',
              'Uzeti si vremena — i na 180. stajanju',
            ],
            dontTitle: 'Pogrešno',
            donts: [
              'Skakati umjesto silaziti',
              'Pune ruke — mobitel, skener, kava, paketi',
              'Koristiti gumu ili glavčinu kotača kao stepenicu',
              'Pogled na mobitel pri silasku',
              'Ignorirati mokre, zaleđene ili prljave rubove stepenica',
              'Bočno se izvijati iz sjedala',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Stajanje nakon duže stanke je najopasnije',
            text: 'Nakon duljeg zaustavljanja noge su ukočene, a '
                'koncentracija je otišla. Upravo se tada dogodi krivi '
                'korak — nakratko se saberi, pa izađi.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Strana prometa: podcijenjeni trenutak',
        blocks: [
          ParagraphBlock(
            'Kod niskih Sprintera i kombija problem često nije visina, '
            'nego korak u promet koji teče. Ako je moguće, izlazi na '
            'stranu pločnika ili na sigurnu stranu. Ne otvaraj vrata '
            'široko prije nego što si pogledao.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 14 st. 1 StVO — ulazak i izlazak',
            text: 'Tko ulazi ili izlazi, mora se ponašati tako da je '
                'ugrožavanje drugih sudionika u prometu isključeno. Kod '
                'nesreće s vratima odgovornost praktički uvijek pogađa '
                'onoga tko izlazi.',
          ),
          RevealBlock(
            prompt: 'Stojiš uz rub kolnika, biciklist se približava '
                'straga — kako izlaziš?',
            answer: 'Prije otvaranja vrata pogledaj preko ramena i u '
                'ogledalo, pusti biciklista da prođe, vrata otvori samo '
                'kontrolirano i udaljenijom rukom. Takozvani „nizozemski '
                'hvat" — otvaranje vrata desnom rukom — automatski ti '
                'okreće gornji dio tijela unatrag i prisiljava te na '
                'pogled. Biciklisti i romobili prolaze tijesno uz vozilo '
                'i ne računaju s vratima koja se otvaraju.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Obuća i podloga',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Preporuka BG Verkehr',
            text: 'Obuća koja obuhvaća stopalo i ne kliže. Nikakve '
                'otvorene ni izlizane cipele. Sigurnosne cipele do gležnja '
                'podupiru upravo onaj zglob koji se pri silasku uvrne.',
          ),
          ParagraphBlock(
            'Prije izlaska nakratko obrati pažnju na podlogu: rubnik, '
            'nagib, lišće, mokro, led, sipina. Rukohvate i stepenice po '
            'snijegu i ledu drži slobodnima. Ako je moguće, stani na ravno '
            'i osvijetljeno mjesto.',
          ),
          ChecklistBlock(
            title: 'Prije izlaska',
            items: [
              'Čvrsta, protuklizna obuća na nogama',
              'Podloga provjerena — rubnik, nagib, mokro, led',
              'Ruke slobodne, predmeti odloženi',
              'Promet provjeren preko ramena i u ogledalu',
              'Stepenice čiste i slobodne',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Pravilno dizanje i nošenje',
        blocks: [
          ParagraphBlock(
            'Leđa su drugi najčešći rizik izostanka nakon padova. I za '
            'razliku od pada, oštećenje diska ne nastane u jednom danu — '
            'ono nastaje kroz tisuće krivih podizanja.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/lift01_nah.svg',
              title: '1 · Teret blizu tijela',
              caption: 'Priđi tijesno paketu prije nego što ga podigneš. '
                  'Svaki centimetar udaljenosti od tijela višestruko '
                  'povećava opterećenje na diskove.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift02_hocke.svg',
              title: '2 · Spusti se u čučanj',
              caption: 'Savij koljena i spusti se u čučanj umjesto da se '
                  'iz kukova preklopiš prema naprijed. Snaga dolazi iz '
                  'nogu — one su najjači mišić koji imaš.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift03_ruecken.svg',
              title: '3 · Leđa drži ravno',
              caption: 'Drži leđa ravno i pogled naprijed dok se dižeš '
                  'nogama. Zaobljena leđa pod teretom klasičan su položaj '
                  'za ozljedu diska.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift04_drehen.svg',
              title: '4 · Ne uvrći se — prekorači',
              caption: 'Nikad se ne okreći s teretom u gornjem dijelu '
                  'tijela. Umjesto toga prekorači stopalima i okreni '
                  'cijelo tijelo. Dizanje uz okretanje najopasnija je '
                  'kombinacija za kralježnicu.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Koliko je teško preteško?',
        blocks: [
          ParagraphBlock(
            'Čvrstih granica u kilogramima u zakonu nema — presudni su '
            'težina, držanje, učestalost i okolina zajedno. U praksi su '
            'se ipak potvrdile orijentacijske vrijednosti.',
          ),
          FactsBlock([
            FactItem('oko 25 kg', 'orijentacija za povremeno dizanje '
                '(muškarci)'),
            FactItem('oko 15 kg', 'orijentacija za povremeno dizanje '
                '(žene)'),
            FactItem('iznad toga', 'koristi pomagala ili nosite udvoje'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'LasthandhabV (propis o rukovanju teretima)',
            text: 'Poslodavac mora ručno dizanje i nošenje izbjeći koliko '
                'god je moguće i osigurati prikladna pomagala. Ti onda ta '
                'pomagala moraš i koristiti — ona ne stoje ondje kao '
                'ukras.',
          ),
          DoDontBlock(
            doTitle: 'Pravilno nošenje',
            dos: [
              'Koristi kolica ili transportnu kutiju umjesto da hodaš '
                  'dvaput',
              'Glomazne pošiljke nosite udvoje',
              'Vidno polje drži slobodnim — ne gledaj preko hrpe',
              'Prije podizanja odredi put i mjesto odlaganja',
            ],
            dontTitle: 'Pogrešno nošenje',
            donts: [
              'Zaobljena leđa, ispružene ruke',
              'Uvrtati se s teretom u gornjem dijelu tijela',
              'Uzeti zalet i trzajno podignuti',
              'Nositi tornjeve koji oduzimaju pogled na put',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Spoticanje, klizanje, padanje na putu',
        blocks: [
          ParagraphBlock(
            'Spoticanje, klizanje i padanje najčešći je uzrok ozljeda u '
            'dostavi — češći od bilo koje prometne nesreće. I gotovo '
            'uvijek se događa na zadnjim metrima između vozila i ulaznih '
            'vrata.',
          ),
          FactsBlock([
            FactItem('Br. 1', 'najčešća vrsta nesreće u dostavi'),
            FactItem('zadnjih 30 m', 'između vozila i vrata — najopasnija '
                'dionica'),
          ]),
          BulletsBlock([
            'Nosi čvrstu, protukliznu obuću — svaki dan, i ljeti',
            'Po poledici radi male korake i stavljaj cijelo stopalo',
            'Pogledaj i na put, ne samo na paket ili mobitel',
            'Noću koristi svjetiljku ili svjetlo mobitela za put',
            'Poznata mjesta spoticanja na ruti drži u glavi',
          ]),
          RevealBlock(
            prompt: 'Primjer iz prakse: nosiš dva paketa jedan na drugom '
                'do ulaznih vrata s tri stepenice. Što je ovdje pravi '
                'problem?',
            answer: 'Ne vidiš vlastita stopala ni rubove stepenica. '
                'Uspon stubama bez pogleda na stepenicu klasična je '
                'situacija pada — a s punim rukama se niti možeš uhvatiti '
                'za rukohvat niti zaustaviti pad. Ispravno: nosi '
                'pojedinačno, hrpu drži tako nisko da vidiš stepenice, '
                'ili koristi kolica. Dvaput prohodati traje 40 sekundi.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ozbiljno shvati male ozljede',
        blocks: [
          ParagraphBlock(
            'Istegnuta leđa ili uganuto stopalo postaju gori ako se '
            'nastavi. Iz sitnice kroz tjedne nastane pravi izostanak — a '
            'naknadno se povezanost s poslom često više ne može dokazati.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Dokumentiranje te štiti',
            text: 'Svaka ozljeda ide u knjigu prve pomoći — i ona mala. '
                'Kod liječničkog tretmana nakon nesreće na radu ideš '
                'ovlaštenom liječniku (Durchgangsarzt). Bez dokumentacije '
                'kasnije priznanje kao nesreće na radu je teško.',
          ),
          RevealBlock(
            prompt: 'Zašto bi male tegobe trebao odmah prijaviti — čak i '
                'ako možeš nastaviti raditi?',
            answer: 'Prvo medicinski: neliječen problem s ligamentima '
                'lošije zacjeljuje i vraća se. Drugo pravno: samo ono što '
                'je dokumentirano kasnije vrijedi kao nesreća na radu. '
                'Treće za sve: tek prijavljeni događaji pokazuju gdje u '
                'tvrtki treba poboljšati stepenicu, rukohvat ili postupak. '
                'Prijaviti je snaga, a ne slabost.',
          ),
          ChecklistBlock(
            title: 'Ovo nosim iz modula 7',
            items: [
              'Izlazim unatrag, licem prema vozilu',
              'Uvijek držim tri dodirne točke (2 ruke + 1 stopalo)',
              'Nikad ne skačem iz kabine ni teretnog prostora',
              'Predmete odlažem prije nego izađem',
              'Prije otvaranja vrata gledam preko ramena',
              'Dižem nogama i ne uvrćem se s teretom',
              'Koristim pomagala umjesto herojskih pothvata',
              'Prijavljujem svaku ozljedu, i onu malu',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M8
  SafetyChapterContent(
    id: 'm8',
    title: 'Na kućnim vratima: psi, ljudi i okolina',
    summary: 'Djeluj sigurno na mjestu dostave — sa životinjama, ljudima i '
        'okolinom',
    asset: 'assets/academy/driving/m08_haustuer.svg',
    slides: [
      SafetySlide(
        title: 'Mjesto dostave: tuđi teren',
        blocks: [
          ParagraphBlock(
            'Čim napustiš vozilo, stupaš na tuđi teren koji ne poznaješ i '
            'koji za tebe nitko nije osigurao: nepoznati putovi, labave '
            'ploče, mračna stubišta, životinje i ljudi u svakom '
            'raspoloženju.',
          ),
          FactsBlock([
            FactItem('120+', 'tuđih posjeda po turi'),
            FactItem('30 m', 'pješačkog puta u prosjeku po stajanju'),
            FactItem('0', 'od toga je za tebe pripremljeno'),
          ]),
          ParagraphBlock(
            'Zato na mjestu dostave vrijedi isti osnovni stav kao za '
            'volanom: prvo pogledaj, pa djeluj. A u dvojbi: ne dostavljaj. '
            'Pošiljka koja ne stigne je jedan postupak — ozljeda je '
            'izostanak.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pravilno procijeni pse',
        asset: 'assets/academy/driving/m08b_hund.svg',
        blocks: [
          ParagraphBlock(
            'Psi spadaju među najčešće uzroke ozljeda kod dostavljača. Iz '
            'perspektive psa ti si uljez koji se brzo kreće, strano '
            'miriše i nosi velik predmet — reakcija je obrana, a ne '
            'zloba.',
          ),
          BulletsBlock([
            'Ne bulji izravno u oči — to je za psa prijetnja',
            'Ne bježi i ne postaj glasan, nego mirno ostani stajati',
            'Okreni psu bok, a ne prednju stranu',
            'Ruke mirno uz tijelo, nikakvi nagli pokreti',
            'Paket može poslužiti kao prepreka između tebe i psa',
            'Polako se povlači unatrag, držeći psa na oku',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Mir je tvoja najbolja oprema',
            text: 'Pas reagira na pokret i ton glasa, a ne na argumente. '
                'Polako, tiho i bočno — to je cijela tehnika.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kad postane ozbiljno',
        blocks: [
          RevealBlock(
            prompt: 'Primjer iz prakse: na vrtnim vratima stoji velik pas '
                'i laje. Vrata su samo pritvorena, kupac je u napomenu za '
                'dostavu napisao „Pas je dobar". Što činiš?',
            answer: 'Ne stupaš na posjed. Napomena za dostavu nije '
                'sigurnosna dozvola — kupac poznaje svog psa u odnosu s '
                'obitelji, a ne u odnosu sa stranim čovjekom s paketom. '
                'Ispravno: odmakni se od vrata, pokušaj pozvoniti ili '
                'nazvati, pošiljku dokumentirano ne dostavi i unesi '
                'napomenu u sustav kako bi sljedeći kolega bio unaprijed '
                'upozoren. Ugriz te košta tjedne — pošiljka kupca košta '
                'jedan dan.',
          ),
          DoDontBlock(
            doTitle: 'Ispravno',
            dos: [
              'Prije otvaranja vrata obrati pažnju na zvukove pasa i '
                  'zdjelice',
              'Kod slobodnog psa uopće ne ulazi',
              'Napomene za kolege unesi u sustav',
              'Kod ugriza ili ogrebotine: odmah prijavi i idi liječniku',
            ],
            dontTitle: 'Pogrešno',
            donts: [
              'Maziti ili hraniti psa',
              'Proći pokraj životinje do vrata',
              'Bježati ili udariti psa paketom',
              'Osloniti se na „on ništa ne radi"',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Svaki ugriz psa ide liječniku',
            text: 'I mali ugriz ili ogrebotina mogu se inficirati. Odmah '
                'očisti, daj se liječnički zbrinuti, upiši u knjigu prve '
                'pomoći i prijavi — neovisno o tome koliko bezopasno '
                'izgleda.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Sigurni putovi na posjedu',
        asset: 'assets/academy/driving/m08c_stolperfallen.svg',
        blocks: [
          ParagraphBlock(
            'Put do ulaznih vrata nije radno mjesto koje je netko za tebe '
            'provjerio. Koristi označene putove i ne krati preko mokrih '
            'travnjaka, labavih ploča ili strmih nasipa.',
          ),
          BulletsBlock([
            'Vrtna crijeva, kabeli i rešetke za penjačice na tlu',
            'Labave ili propale ploče pločnika',
            'Mokro lišće, mahovina i alge na sjenovitim putovima',
            'Šljunak i sipina na glatkim pločama',
            'Neosvijetljene stube bez rukohvata',
            'Podrumska okna, otvoreni šahtovi i svjetlarnici',
            'Igračke, bicikli i kante za smeće na putu',
          ]),
          FactsBlock([
            FactItem('zadnjih 30 m', 'ovdje se događa većina padova'),
            FactItem('1 ruka', 'trebala bi ostati slobodna za rukohvat'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Prečac košta više nego što uštedi',
            text: 'Put preko travnjaka štedi deset sekundi. Pad na njemu '
                'košta u prosjeku 24 dana izostanka.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Stube, podrumi i mrak',
        blocks: [
          ParagraphBlock(
            'U stubištima i stražnjim dvorištima spajaju se dvije stvari: '
            'loše svjetlo i nepoznate visine stepenica. Oboje zajedno '
            'najčešća je situacija pada izvan vozila.',
          ),
          BulletsBlock([
            'Uvijek drži jednu ruku slobodnu za rukohvat',
            'Upali svjetlo umjesto „ide i ovako"',
            'Koristi svjetiljku ili svjetlo mobitela — ali u hodu ne '
                'gledaj u zaslon',
            'Kod stuba hrpu drži tako nisko da vidiš stepenice',
            'Pazi na različite visine stepenica u starim zgradama',
          ]),
          RevealBlock(
            prompt: 'Trebaš dostaviti u mračni podrumski hodnik. Prekidač '
                'za svjetlo ne radi. Koja je ispravna odluka?',
            answer: 'Ne ulaziti. Neosvijetljen hodnik s nepoznatim '
                'stepenicama, podrumskim oknima i odloženim stvarima nije '
                'mjesto na koje ulaziš s paketom u ruci — a u dvojbi '
                'nitko ne zna da si ondje. Ispravno: pozvoni kupcu, '
                'predaj na sigurnom mjestu ili pošiljku dokumentirano ne '
                'dostavi. Svjetlo mobitela ne zamjenjuje rasvjetu, jer za '
                'njega trebaš ruku koja ti treba na rukohvatu.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ljudi: smiriti umjesto pobijediti',
        blocks: [
          ParagraphBlock(
            'Za kupca si ti lice cijelog koncerna — i zato ponekad '
            'dobiješ ljutnju koja se ne odnosi na tebe. Ostati '
            'ljubazan, miran i profesionalan nije samo pristojno, to je '
            'tvoja najučinkovitija sigurnosna mjera.',
          ),
          StepsBlock([
            'Miran glas, spor tempo govora, otvoren stav tijela',
            'Slušaj i imenuj problem umjesto da odmah proturječiš',
            'Ostani pri onome što možeš učiniti — nikakva obećanja za '
                'druge',
            'Drži razmak: najmanje duljinu ruke, put za bijeg slobodan',
            'Ako eskalira: prekini razgovor i vrati se do vozila',
          ]),
          RevealBlock(
            prompt: 'Netko postane glasan, priđe ti vrlo blizu i blokira '
                'put do tvog vozila. Što vrijedi?',
            answer: 'Tvoja sigurnost ide ispred svake dostave. Ne '
                'raspravljaj, ne inzistiraj da si u pravu, ne izazivaj '
                'tjelesni kontakt. Uzmakni, uspostavi razmak, glasno i '
                'jasno zatraži odmak, u nuždi izađi među ljude i pozovi '
                'policiju. Nakon toga: prijavi događaj kako bi se '
                'stajanje označilo za kolege. Nijedan paket ne opravdava '
                'fizički sukob.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Vozilo kao sigurno mjesto',
        blocks: [
          ParagraphBlock(
            'Tvoje vozilo je alat, skladište i mjesto povlačenja. Kad ga '
            'napustiš, mora sigurno stajati — a ako se osjećaš ugroženo, '
            'to je mjesto na koje se vraćaš.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 14 st. 2 StVO',
            text: 'Tko napusti svoje vozilo, mora poduzeti potrebne mjere '
                'da izbjegne nesreće i smetnje u prometu i osigurati ga '
                'od neovlaštene uporabe.',
          ),
          DoDontBlock(
            doTitle: 'Pravilno odloženo',
            dos: [
              'Motor ugašen, ključ ponesi, zaključaj',
              'Na nagibu čvrsto zategni ručnu i okreni kotače',
              'Sva četiri pri zaustavljanju u prometnom prostoru',
              'Zatvori vrata teretnog prostora kad si izvan vidokruga',
            ],
            dontTitle: 'Rizično',
            donts: [
              'Motor radi, vrata otvorena — „ide brže tako"',
              'Ključ u bravi dok si na vratima',
              'Parkirati na nagibu bez okrenutih kotača',
              'Ostaviti teretni prostor otvoren u živim područjima',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolna lista na mjestu dostave',
        blocks: [
          ChecklistBlock(
            title: 'Na svakom stajanju',
            items: [
              'Motor ugašen, ključ sa mnom, vozilo zaključano',
              'Na nagibu osigurano, kotači okrenuti',
              'Prije ulaska pazio na pse i napomene',
              'Koristio označene putove, nisam kratio',
              'Jedna ruka slobodna za rukohvat',
              'Hrpa toliko niska da vidim stepenice',
              'U mraku se pobrinuo za svjetlo',
              'Kod agresije: razmak, povlačenje, prijava',
              'Kod ugriza, pada ili izbjegnute nesreće: prijavio',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M9
  SafetyChapterContent(
    id: 'm9',
    title: 'Hitni slučaj i postupanje nakon nesreće',
    summary: 'U ozbiljnom slučaju postupaj mirno, ispravno i pravno '
        'sigurno',
    asset: 'assets/academy/driving/m09_notfall.svg',
    slides: [
      SafetySlide(
        title: 'Osigurati — Prijaviti — Pomoći',
        blocks: [
          ParagraphBlock(
            'Nakon nesreće ili kod kvara uvijek vrijedi isti redoslijed: '
            'prvo osiguraj mjesto, zatim hitni poziv, zatim prva pomoć. '
            'Taj redoslijed nije formalizam — on sprječava drugu nesreću '
            'u kojoj pomagači sami postanu žrtve.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Zapamti redoslijed',
            text: 'Osigurati → Prijaviti → Pomoći. Tko odmah otrči do '
                'ozlijeđenog bez osiguravanja, na regionalnoj cesti ili '
                'autocesti bude i sam pregažen.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 34 StVO — nakon prometne nesreće',
            text: 'Moraš odmah stati, osigurati promet, kod neznatne '
                'štete izaći iz opasnog područja, pomoći ozlijeđenima i '
                'omogućiti utvrđivanje svoje osobe i svog vozila.',
          ),
          ParagraphBlock(
            'I vrlo važno: mir. Prvih deset sekundi nakon udarca odlučuje '
            'o sljedećih deset minuta. Jednom duboko udahni, pa redom.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Prvih pet koraka',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/acc01_absichern.svg',
              title: '1 · Upali sva četiri',
              caption: 'Odmah nakon zaustavljanja upali sva četiri '
                  'žmigavca — to je prvi signal za sve koji dolaze '
                  'straga. U mraku dodatno ostavi upaljena pozicijska '
                  'svjetla.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc02_warnweste.svg',
              title: '2 · Obuci sigurnosni prsluk',
              caption: 'Prsluk obučeš prije nego izađeš — a ne poslije. '
                  'Zato leži nadohvat ruke u kabini, a ne straga u '
                  'teretnom prostoru.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc03_dreieck.svg',
              title: '3 · Postavi sigurnosni trokut',
              caption: 'Kreni iza zaštitne ograde ili uz rub kolnika '
                  'suprotno smjeru vožnje i postavi trokut na dovoljnoj '
                  'udaljenosti — u naselju oko 50 m, izvan naselja 100 m, '
                  'na autocesti 150–200 m.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc04_notruf.svg',
              title: '4 · Uputi hitni poziv 112',
              caption: 'Reci gdje si, što se dogodilo, koliko je '
                  'ozlijeđenih i koje ozljede vidiš — i prekini vezu tek '
                  'kad centrala više nema pitanja.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc05_erstehilfe.svg',
              title: '5 · Pruži prvu pomoć',
              caption: 'Obrati se, provjeri disanje, zaustavi krvarenje, '
                  'ugrij i ostani uz ozlijeđenog. I jednostavne mjere '
                  'pomažu — ne učiniti ništa jedina je pogrešna odluka.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Sva četiri, prsluk, trokut',
        blocks: [
          TableBlock(
            headers: ['Područje', 'Udaljenost trokuta'],
            rows: [
              ['U naselju', 'oko 50 m'],
              ['Izvan naselja', 'oko 100 m'],
              ['Autocesta', 'oko 150–200 m'],
              ['Prije uzvišenja ili zavoja', 'ispred njega, ne iza'],
            ],
          ),
          ParagraphBlock(
            'Presudna nije točna vrijednost u metrima, nego da te promet '
            'koji nailazi pravodobno vidi. Prije uzvišenja ili zavoja '
            'trokut ide ispred njega — inače postane vidljiv tek kad je '
            'prekasno.',
          ),
          FactsBlock([
            FactItem('1', 'sigurnosni prsluk obvezan je u vozilu '
                '(§ 53a StVZO)'),
            FactItem('prije', 'prsluk obuci prije nego izađeš'),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Hodaj iza zaštitne ograde',
            text: 'Na autocesti i regionalnoj cesti nikad ne hodaj po '
                'kolniku do mjesta za trokut, nego iza zaštitne ograde '
                'ili po bankini — suprotno smjeru vožnje, kako bi vidio '
                'promet.',
          ),
          DoDontBlock(
            doTitle: 'Ispravno na mjestu nesreće',
            dos: [
              'Sva četiri odmah, prsluk prije izlaska',
              'Hodaj iza zaštitne ograde suprotno smjeru vožnje',
              'Trokut postavi prije uzvišenja ili zavoja',
              'Nakon osiguravanja i sam se skloni na sigurno',
            ],
            dontTitle: 'Tipične pogreške',
            donts: [
              'Izaći bez prsluka i „samo nakratko" pogledati',
              'Hodati po kolniku do trokuta',
              'Ostati stajati između vozila',
              'Prvo fotografirati umjesto osigurati',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Koridor za hitne službe',
        blocks: [
          ParagraphBlock(
            'Koridor za hitne službe stvara se čim promet zastane — a ne '
            'tek kad se vidi rotirajuće svjetlo. Tada je najčešće '
            'prekasno jer nitko više nema mjesta.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 11 st. 2 StVO',
            text: 'Na autocestama i cestama izvan naselja s najmanje dva '
                'prometna traka po smjeru koridor se uvijek stvara između '
                'krajnje lijevog i neposredno desno uz njega položenog '
                'traka — neovisno o tome koliko traka ima.',
          ),
          FactsBlock([
            FactItem('lijevo + 1', 'tako se stvara koridor'),
            FactItem('od 200 €', 'kazna ako se koridor ne stvori'),
            FactItem('2 boda', 'plus u pravilu 1 mjesec zabrane vožnje'),
          ]),
          RevealBlock(
            prompt: 'Na autocesti s tri traka promet stoji. Gdje je točno '
                'koridor za hitne službe — i smiješ li voziti njime ako '
                'baš želiš do izlaza?',
            answer: 'Uvijek između lijevog i srednjeg traka — nikad '
                'između sredine i desnog i nikad po zaustavnom traku. I '
                'ne: koridor je isključivo za vozila hitnih službi. Tko '
                'ga koristi da brže dođe do izlaza, plaća jednako visoku '
                'kaznu kao onaj tko ga uopće ne stvara, i riskira zabranu '
                'vožnje. Zaustavni trak nije alternativa — ondje voze '
                'spasioci kad je koridor blokiran.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pravilno uputi hitni poziv 112',
        blocks: [
          FactsBlock([
            FactItem('112', 'hitni poziv u cijeloj Europi, i bez '
                'kredita'),
            FactItem('110', 'policija — kod čiste štete na limu'),
          ]),
          StepsBlock([
            'Gdje se dogodilo? — mjesto, ulica, kilometar, smjer vožnje, '
                'markantne točke',
            'Što se dogodilo? — vrsta nesreće, uključena vozila, '
                'opasnosti poput istjecanja goriva',
            'Koliko je ozlijeđenih?',
            'Koje ozljede? — bez svijesti, krvarenje, zaglavljen',
            'Čekaj dodatna pitanja — razgovor završava centrala',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Pružanje pomoći je obveza',
            text: 'Nepružanje pomoći je kazneno djelo (§ 323c StGB). '
                'Očekuje se ono što je od tebe razumno tražiti — uputiti '
                'hitni poziv, osigurati, obratiti se, brinuti. Nitko ne '
                'traži da sebe dovedeš u opasnost.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Prva pomoć: stvari koje su bitne',
        blocks: [
          ParagraphBlock(
            'Ne moraš biti bolničar. Presudne mjere može svatko — i '
            'upravo one odlučuju o životu i smrti prije nego što stigne '
            'hitna pomoć.',
          ),
          StepsBlock([
            'Obrati se i oprezno protresi za rame — reagira li osoba?',
            'Nema reakcije: oslobodi dišne putove, zabaci glavu, '
                'provjeri disanje 10 sekundi',
            'Disanje normalno: bočni položaj, pokrij, ostani uz osobu',
            'Nema normalnog disanja: odmah počni masažu srca i ne '
                'prestaj',
            'Jako krvarenje: odmah pritisni, stavi kompresivni zavoj',
          ]),
          FactsBlock([
            FactItem('100–120', 'kompresija u minuti'),
            FactItem('5–6 cm', 'dubina pritiska kod odrasle osobe'),
            FactItem('10 s', 'dovoljno je za provjeru disanja'),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Kaciga i zaglavljene osobe',
            text: 'Motociklističku kacigu skidaš samo ako osoba ne diše '
                'normalno — tada nema druge. Zaglavljene osobe ne '
                'pomičeš, osim ako prijeti neposredna opasnost od '
                'požara.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Nakon štete na limu',
        blocks: [
          ParagraphBlock(
            'I kod malih šteta — udubina od manevriranja, otkinuto '
            'ogledalo, ogrebotina na parkiranom autu — vrijedi cijeli '
            'program. Šteta se uvijek prijavljuje, čak i ako djeluje mala '
            'i nitko nije gledao.',
          ),
          ChecklistBlock(
            title: 'Nakon štete na limu',
            items: [
              'Stani i osiguraj vozilo',
              'Sva četiri, po potrebi prsluk i trokut',
              'Razmijeni podatke odnosno pričekaj vlasnika',
              'Fotografije iz više kutova, mjesto, vrijeme, registracija',
              'Zapiši svjedoke i njihove kontakt podatke',
              'Ne potpisuj priznanje krivnje',
              'Prijavi štetu u tvrtki — još istog dana',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Nikad jednostavno ne odvezi dalje',
            text: 'Tko se udalji s mjesta nesreće bez da omogući '
                'utvrđivanje svoje osobe, čini nedopušteno udaljavanje s '
                'mjesta nesreće (§ 142 StGB) — kazneno djelo s novčanom '
                'ili zatvorskom kaznom, i kod male udubine.',
          ),
          RevealBlock(
            prompt: 'Primjer iz prakse: pri manevriranju okrzneš vanjsko '
                'ogledalo parkiranog auta. Nikoga nema. Je li dovoljna '
                'poruka iza brisača?',
            answer: 'Ne. Poruka pravno ne vrijedi kao dostatno '
                'utvrđivanje — može odletjeti, pokisnuti ili biti '
                'uklonjena. Ispravno je: pričekati primjereno vrijeme na '
                'mjestu nesreće (ovisno o situaciji uzima se oko 30 '
                'minuta kao orijentacijska vrijednost), a ako nitko ne '
                'dođe, obavijestiti policiju i ondje prijaviti štetu. '
                'Poruka uz to je dobra praksa, ali ne zamjenjuje ni '
                'čekanje ni prijavu.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Sačuvaj mir, prijavi, uči',
        blocks: [
          ParagraphBlock(
            'Duboko udahni, posloži situaciju, obavijesti disponenta i '
            'tvrtku. Poštena, brza prijava uvijek je bolja od '
            'zataškavanja — ona štiti tebe, štiti tvrtku, a iz svakog '
            'događaja učimo za sljedeću turu.',
          ),
          ChecklistBlock(
            title: 'Ovo nosim iz modula 9',
            items: [
              'Znam redoslijed: osigurati, prijaviti, pomoći',
              'Sigurnosni prsluk obučem prije nego izađem',
              'Sigurnosni trokut postavljam na dovoljnoj udaljenosti',
              'Koridor stvaram između lijevog i traka uz njega, čim '
                  'promet zastane',
              'Znam pet podataka kod hitnog poziva 112',
              'Znam da je nečinjenje jedina pogrešna odluka',
              'Prijavljujem svaku štetu istog dana — i malu udubinu',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M10
  SafetyChapterContent(
    id: 'm10',
    title: 'Sažetak i osobna obveza',
    summary: 'Usidri naučeno i pretvori ga u osobni stav',
    asset: 'assets/academy/driving/m10_selbstverpflichtung.svg',
    slides: [
      SafetySlide(
        title: 'Tvojih 7 osnovnih pravila',
        blocks: [
          BulletsBlock([
            'Misliti unaprijed jače je od brzo reagirati',
            'Razmak i prilagođena brzina uvijek ti daju rezervu',
            'Pri vožnji unatrag: izaći, pogledati, polako (GOAL)',
            'Mobitel i ometanje samo u mjestu uz ugašen motor',
            'Umor i vremenski pritisak shvatiti ozbiljno — sigurnost '
                'ispred plana',
            'Pravilno izlaziti, dizati, hodati — tvoje tijelo je tvoj '
                'alat',
            'U hitnom slučaju: osigurati, prijaviti, pomoći',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ako poneseš samo jedno pravilo',
            text: 'Uzmi vrijeme koje ti treba. Gotovo svaka nesreća u '
                'dostavi nastaje u trenutku u kojem je netko htio uštedjeti '
                'dvije sekunde.',
          ),
          DoDontBlock(
            doTitle: 'Ovako izgleda siguran dan',
            dos: [
              'Obilazak, teret osiguran, pojas vezan',
              'Dvije sekunde razmaka, pogled daleko naprijed',
              'Prije svakog manevra unatrag izaći i pogledati',
              'Mobitel u držaču, pauza kod umora',
              'Izlazak unatrag s tri dodirne točke',
            ],
            dontTitle: 'Pet najskupljih prečaca',
            donts: [
              'Obilazak „danas jednom" preskočiti',
              'Teret nakon dotovara ne osigurati iznova',
              'Kratko pogledati na zaslon jer je cesta slobodna',
              'Skočiti iz teretnog prostora jer ide brže',
              'Ne prijaviti štetu od manevriranja',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Brojke koje bi trebale ostati',
        blocks: [
          FactsBlock([
            FactItem('2 s', 'najmanji razmak'),
            FactItem('2 + 1', 'dodirne točke pri izlasku'),
            FactItem('112', 'hitni poziv kod ozlijeđenih'),
          ]),
          TableBlock(
            headers: ['Brojka', 'Značenje'],
            rows: [
              ['2 sekunde', 'najmanji razmak, po mokrom 3+'],
              ['18 / 40 m', 'zaustavni put pri 30 / 50 km/h'],
              ['28 m', 'slijepa vožnja pri 2 s pogleda na mobitel i '
                  'brzini 50'],
              ['89 m', 'mikrospavanje od 4 s pri brzini 80'],
              ['0,8 g', 'sila osiguranja prema naprijed za teret'],
              ['2 + 1', 'dodirne točke pri ulasku i izlasku'],
              ['70 %', 'šteta nastaje pri manevriranju'],
              ['112', 'hitni poziv kod ozlijeđenih'],
            ],
          ),
          ParagraphBlock(
            'Tih osam brojki tvrda je jezgra treninga. Tko ih ima u '
            'glavi, donosi ispravnu odluku i onda kad nema vremena za '
            'razmišljanje.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tvoja osobna samoprovjera',
        asset: 'assets/academy/driving/m10b_selbstcheck.svg',
        blocks: [
          ParagraphBlock(
            'Prođi ovu listu jednom pošteno — ne za tvrtku, nego za sebe. '
            'Svaka nepostavljena kvačica konkretna je stvar koju sutra '
            'možeš promijeniti.',
          ),
          ChecklistBlock(
            title: 'Moja samoprovjera sigurnosti',
            items: [
              'Obilazak radim svako jutro, čak i kad se žuri',
              'Teret osiguravam iznova kad se teretni prostor prazni',
              'Držim dvije sekunde razmaka i provjeravam to na čvrstoj '
                  'točki',
              'Prije svakog manevra unatrag izlazim i pogledam',
              'Mobitel tijekom vožnje ne diram',
              'Stajem kad postanem umoran',
              'Uvijek izlazim unatrag s tri dodirne točke',
              'Dižem nogama i koristim pomagala',
              'Prijavljujem štete, izbjegnute nesreće i ozljede',
              'Javljam kad plan nije sigurno izvediv',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Primjer iz prakse: dan kad se sve poklopi',
        blocks: [
          RevealBlock(
            prompt: 'Primjer iz prakse: petak, kiša, 190 stajanja. '
                'Krećeš 25 minuta prekasno, teretni prostor je od noćne '
                'smjene nesortiran, mobitel ti stalno zvoni, a u 16 sati '
                'primijetiš da od doručka nisi ništa jeo. Koji je sada '
                'ispravan redoslijed?',
            answer: 'Stani i prvo posloži teretni prostor — to nadoknadiš '
                'u četvrt sata i uštediš si 190 traženja. Zatim: mobitel '
                'na nečujno, u držač, pozivi u sljedećoj pauzi. Onda '
                'deset minuta jedi i pij, jer od sada ti pažnja inače '
                'pada svakim satom. I zatim poštena prijava dispoziciji '
                'da plan danas neće u cijelosti proći. Ono što ne radiš: '
                'pokušavati nadoknaditi vrijeme na cesti, brisati pauze, '
                'skraćivati manevre. Dan se više ne da spasiti — tvoja '
                'leđa, tvoja vozačka i tvoje vozilo da.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Pravi ispit',
            text: 'Sigurno voziti može svatko na dobar dan. Razlika se '
                'pokaže onog dana kad sve krene po zlu istodobno.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tvoja osobna obveza',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Tvoje obećanje',
            text: '„Vozim tako da svi sigurno dođu kući — i ja."',
          ),
          ParagraphBlock(
            'Sigurnost nije pravilnik, nego tvoja svakodnevna odluka. '
            'Nitko ne stoji pokraj tebe kad ujutro u šest odlučuješ hoćeš '
            'li napraviti obilazak, ili kad navečer u sedam odlučuješ '
            'hoćeš li prije vožnje unatrag još jednom izaći. Upravo zato '
            'su te odluke tako važne.',
          ),
          ChecklistBlock(
            title: 'Obvezujem se',
            items: [
              'Pridržavam se pravila i onda kad nitko ne gleda',
              'Uzimam si sekunde koje sigurnost košta',
              'Prijavljujem pošteno umjesto da zataškavam',
              'Pomažem novim kolegama da od početka rade ispravno',
              'Svaku večer dolazim zdrav kući',
            ],
          ),
        ],
      ),
    ],
  ),
];
