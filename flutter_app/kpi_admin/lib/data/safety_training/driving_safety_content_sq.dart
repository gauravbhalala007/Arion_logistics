// lib/data/safety_training/driving_safety_content_sq.dart
//
// Përmbajtja e trajnimit DSP për sigurinë në ngasje — versioni shqip.
// Struktura është identike me versionin gjerman (master): modulet M1–M10,
// të njëjtat folie, të njëjtët blloqe dhe të njëjtat figura.

import 'safety_blocks.dart';

const List<SafetyChapterContent> drivingSafetyContentSq = [
  // ══════════════════════════════════════════════════ M1
  SafetyChapterContent(
    id: 'm1',
    title: 'Kultura e sigurisë dhe përgjegjësia',
    summary: 'Kupto sigurinë si vendim tëndin — jo si rregullore',
    asset: 'assets/academy/driving/m01_sicherheitskultur.svg',
    slides: [
      SafetySlide(
        title: 'Turi yt, përgjegjësia jote',
        blocks: [
          ParagraphBlock(
            'Çdo ditë bën qindra kilometra dhe ndalon dhjetëra herë. Çdo '
            'udhëtim, çdo ndalesë, çdo zbritje nga makina është një '
            'vendim. Lajmi i mirë: pothuajse çdo aksident mund të '
            'shmanget. Siguria nuk fillon te timoni, por në kokë — para '
            'se të nisesh.',
          ),
          FactsBlock([
            FactItem('120+', 'ndalesa në një ditë normale shpërndarjeje'),
            FactItem('250+', 'herë hipje dhe zbritje nga makina për tur'),
            FactItem('1', 'sekondë pavëmendje mjafton për një '
                'aksident'),
          ]),
          ParagraphBlock(
            'Me kaq shumë përsëritje, ditën nuk ta vendos aftësia jote, '
            'por rutina jote. Një rutinë e mirë të mbron edhe kur je i '
            'lodhur ose nën presion — një rutinë e keqe një ditë të del '
            'shtrenjtë.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ideja bazë',
            text: 'Siguria nuk është diçka që e bën veç e veç. Ajo është '
                'mënyra si e bën punën tënde.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Çfarë ndodh vërtet në shpërndarje',
        blocks: [
          ParagraphBlock(
            'Shpërndarja bën pjesë te profesionet me më shumë aksidente '
            'rrugore dhe në punë. Ngjarjet më të shpeshta nuk janë '
            'spektakolare: përplasje nga pas në trafik, dëmtime gjatë '
            'lëvizjes prapa, rrëzime gjatë zbritjes, shpina e dëmtuar '
            'nga ngritja, kyçe këmbësh të përdredhura. Të përditshme — '
            'dhe pikërisht prandaj të nënvlerësuara.',
          ),
          FactsBlock([
            FactItem('70 %', 'e dëmtimeve të furgonëve ndodhin gjatë '
                'manovrimit dhe lëvizjes prapa'),
            FactItem('Nr. 1', 'Pengimi, rrëshqitja dhe rrëzimi është '
                'shkaku më i shpeshtë i lëndimeve në shpërndarje'),
            FactItem('24', 'ditë mungese mesatarisht pas një rrëzimi'),
          ]),
          ParagraphBlock(
            'Bie në sy se pothuajse të gjitha këto ngjarje ndodhin me '
            'shpejtësi të ulët ose në vend. Nuk janë manovra dramatike, '
            'por veprime krejt normale që një herë u kryen keq.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Ngadalë nuk do të thotë pa rrezik',
            text: 'Një dëmtim gjatë manovrimit me shpejtësi këmbësori i '
                'kushton firmës shpejt një shumë katërshifrore — dhe ty '
                'gjysmë dite telashe.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tri qëndrimet bazë',
        blocks: [
          ParagraphBlock(
            'Nga gjithçka që vjen në këtë trajnim mund të nxirren tri '
            'qëndrime. Nëse merr me vete vetëm këto të tria, pjesën më '
            'të madhe e ke kryer.',
          ),
          BulletsBlock([
            'Të mendosh përpara — të njohësh rreziqet para se të '
                'lindin. Kush vetëm reagon, është gjithmonë vonë',
            'Koha është e jotja — asnjë pako nuk vlen sa një aksident. '
                'Presioni i kohës është problem planifikimi, jo '
                'justifikim',
            'Të jesh shembull — sjellja jote mbron kolegët, këmbësorët '
                'dhe fëmijët. Në rrugë je profesionist, jo shofer '
                'privat',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Frazë për ta mbajtur mend',
            text: 'Shoferi më i mirë nuk është më i shpejti, por ai të '
                'cilit nuk i ndodh kurrë asgjë — sepse e sheh që kur '
                'vjen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Çdo udhëtim është një zinxhir vendimesh',
        asset: 'assets/academy/driving/m01b_entscheidung.svg',
        blocks: [
          ParagraphBlock(
            'Një aksident rrallë është një gabim i vetëm. Zakonisht janë '
            'pesë a gjashtë vendime të vogla, secili për vete i '
            'padëmshëm — dhe në fund mblidhen. Pikërisht prandaj mund ta '
            'ndërpresësh zinxhirin te çdo hallkë.',
          ),
          RevealBlock(
            prompt: 'Rast praktik: Është ora 17:40, ke edhe 22 ndalesa '
                'të hapura. Dyshemeja e ngarkesës është e parregullt, '
                'telefoni të dridhet te mbajtësja dhe përpara teje '
                'ngushtohet rruga. Ku qëndron këtu në të vërtetë '
                'rreziku?',
            answer: 'Jo te ngushtica përpara — por te historia '
                'paraprake. Dyshemeja e parregullt e ngarkesës të merr '
                'kohë te çdo ndalesë, koha krijon presion, presioni ta '
                'ul vëmendjen dhe telefoni ta merr pjesën tjetër. '
                'Vendimi i duhur duhej marrë dy orë më parë: rregullo '
                'hapësirën e ngarkesës, hiqja zërin telefonit, planifiko '
                'realisht. Tani ndihmon vetëm kjo: ndalo, merr frymë '
                'thellë, vazhdo ndalesë pas ndalese dhe pastaj njofto '
                'për planifikimin.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Këpute zinxhirin',
            text: 'Pyet veten sa herë ke një ndjesi jo të mirë: cila '
                'është tani ajo hallkë që mund ta heq me 30 sekonda '
                'punë?',
          ),
        ],
      ),
      SafetySlide(
        title: 'Shembull në ekip',
        asset: 'assets/academy/driving/m01c_vorbild.svg',
        blocks: [
          ParagraphBlock(
            'Kultura e sigurisë nuk lind nga afishet, por nga ajo që '
            'kolegët marrin nga njëri-tjetri. Kush fillon i ri, imiton '
            'atë që bëjnë të përvojshmit — edhe gabimin.',
          ),
          DoDontBlock(
            doTitle: 'Kulturë që të mban',
            dos: [
              'Të flitet hapur për situatat për pak aksident, pa e parë '
                  'njeri shtrembër tjetrin',
              'Kolegëve të rinj t\'u tregohen aktivisht shkallët, '
                  'dorezat dhe këndi i vdekur',
              'Defektet të njoftohen menjëherë, edhe nëse turi nis më '
                  'vonë për këtë arsye',
              'Të manovrohet dukshëm pastër edhe nën presion kohe',
            ],
            dontTitle: 'Kulturë që dëmton',
            donts: [
              '„Këtu e kemi bërë gjithmonë kështu" si arsyetim',
              'Të qeshet me kolegun që zbret dhe shikon prapa',
              'Dëmet e vogla të rregullohen mes vete në vend që të '
                  'njoftohen',
              'Të praktikohen shkurtore që një kolegu të ri nuk do t\'ia '
                  'mësoje kurrë',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Situatat për pak aksident vlejnë ar',
            text: 'Çdo situatë e njoftuar për pak aksident është një '
                'aksident që nuk i ndodh më kolegut tjetër. Njoftimi '
                'është forcë, jo spiunim.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kush përgjigjet në të vërtetë?',
        blocks: [
          ParagraphBlock(
            'Në timon je drejtues mjeti — dhe rrjedhimisht personalisht '
            'përgjegjës. Firma të jep një mjet të sigurt, të udhëzon dhe '
            'planifikon turin. Por nëse ti mban distancë, vendos rripin '
            'dhe zbret para se të lëvizësh prapa, e vendos vetëm ti.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Çfarë pret ligji prej teje',
            text: '§ 1 StVO (Kodi Rrugor gjerman) kërkon kujdes të '
                'vazhdueshëm dhe konsideratë të ndërsjellë. § 3 par. 1 '
                'StVO kërkon që të ngasësh vetëm aq shpejt sa të mund të '
                'ndalosh brenda pjesës së dukshme të rrugës. Të dyja '
                'vlejnë pavarësisht nga ajo që shkruan në tabelë.',
          ),
          BulletsBlock([
            'Gjobat dhe pikët të prekin ty personalisht, jo firmën',
            'Në rast pakujdesie të rëndë, sigurimi mund të kërkojë '
                'pjesërisht rimbursim nga ti',
            'Kur rrezikohen të tjerët, nga një shkelje trafiku mund të '
                'bëhet vepër penale (§ 315c StGB)',
            'Një ndalim drejtimi për ty si shofer profesionist do të '
                'thotë: pa punë',
          ]),
          RevealBlock(
            prompt: 'Në mëngjes vëren se një dritë frenimi nuk punon. '
                'Dispeçeri thotë: „Nisu prapëseprapë, nuk kemi njeri '
                'tjetër." Kush e mban rrezikun?',
            answer: 'Ti. Si drejtues mjeti përgjigjesh për gjendjen e '
                'sigurt në trafik të mjetit që ngas — një urdhër gojor '
                'nuk e heq këtë. E saktë është: njofto defektin, kërko '
                'mjet zëvendësues ose riparim, dokumento njoftimin. Një '
                'dritë frenimi e prishur te furgoni është përveç kësaj '
                'pikërisht defekti që të çon te përplasja nga pas.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listë kontrolli: qëndrimi yt',
        blocks: [
          ChecklistBlock(
            title: 'Këtë marr me vete nga Moduli 1',
            items: [
              'E di se shumica e dëmeve ndodhin ngadalë dhe në '
                  'përditshmëri',
              'Mendoj përpara, në vend që vetëm të reagoj',
              'Presionin e kohës e trajtoj si problem planifikimi, jo si '
                  'problem ngasjeje',
              'Njoftoj defektet dhe situatat për pak aksident, edhe të '
                  'voglat',
              'E di se si drejtues mjeti përgjigjem personalisht',
              'Jam i vetëdijshëm se kolegët e rinj më kopjojnë',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Një fjali për turin',
            text: '„Ngas ashtu që të gjithë të kthehen të sigurt në '
                'shtëpi — edhe unë."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M2
  SafetyChapterContent(
    id: 'm2',
    title: 'Kontrolli i mjetit dhe sigurimi i ngarkesës',
    summary: 'Kontrollo mjetin para turit dhe siguro ngarkesën ashtu që '
        'asgjë të mos bëhet rrezik',
    asset: 'assets/academy/driving/m02_fahrzeugcheck.svg',
    slides: [
      SafetySlide(
        title: 'Pse kontrolli nuk është formalitet',
        blocks: [
          ParagraphBlock(
            'Rrotullimi rreth mjetit para turit zgjat dy minuta. Ai '
            'parandalon defekte në mes të rrugës, gjoba gjatë një '
            'kontrolli dhe, në rastin më të keq, një aksident që do të '
            'mund ta shihje para se të nisesh.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Detyrimi i kontrollit para ndërrimit',
            text: 'Sipas DGUV Vorschrift 70 (rregullorja gjermane për '
                'mjetet) duhet ta kontrollosh mjetin para fillimit të '
                'çdo ndërrimi pune për defekte të dukshme. Nëse gjen '
                'defekte që rrezikojnë sigurinë e punës së mjetit, nuk '
                'lejohet të nisesh — i njofton ato.',
          ),
          FactsBlock([
            FactItem('2 min', 'zgjat rrotullimi i plotë rreth mjetit'),
            FactItem('4', 'stacione: gomat, dritat, lëngjet, '
                'ngarkesa'),
          ]),
          ParagraphBlock(
            'E rëndësishme: Kontrolli nuk zëvendëson kontrollin në '
            'ofiçinë. Ti kërkon atë që bie në sy — jo defekte të '
            'fshehura.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Rrotullimi — katër stacione',
        asset: 'assets/academy/driving/m02b_rundgang.svg',
        blocks: [
          ParagraphBlock(
            'Rrotullohu gjithmonë me të njëjtin radhë rreth makinës. Një '
            'radhë e fiksuar është e vetmja rrugë që të mos harrosh '
            'asgjë kur mëngjeset bëhen të nxituara.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/load01_reifen.svg',
              title: '1 · Gomat dhe rrotat',
              caption: 'Bëj një rrotullim të plotë dhe shiko të katër '
                  'gomat: dukshëm të shfryra, plasaritje, trupa të huaj, '
                  'a mjafton ende profili? Një gomë që në mëngjes duket '
                  'e butë, nuk e mban dot një tur të tërë.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load02_licht.svg',
              title: '2 · Ndriçimi dhe targa',
              caption: 'Kontrollo dritat e pozicionit, të shkurtrat, '
                  'sinjalet, dritat e frenimit dhe fenerin e lëvizjes '
                  'prapa — dritat e frenimit në rast nevoje përmes '
                  'reflektimit në një mur ose me një koleg. Targa duhet '
                  'të jetë e lirë dhe e lexueshme.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load03_fluessigkeiten.svg',
              title: '3 · Lëngjet dhe toka',
              caption: 'Një vështrim nën makinë: gjurmët e vajit, të '
                  'lëngut ftohës ose të lëngut të frenave në tokë janë '
                  'gjithmonë arsye për njoftim. Përveç kësaj mbush ujin '
                  'e fshirësve — në dimër me antifriz.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load04_ladung.svg',
              title: '4 · Hapësira e ngarkesës dhe ngarkesa',
              caption: 'Hap dyert dhe shiko brenda: a rri gjithçka fort, '
                  'a janë rrjeta ndarëse dhe rripat lidhës të shtrënguar, '
                  'a ka gjë të lirë sipër? Ajo që rri e lirshme këtu, '
                  'fluturon përpara te frenimi i parë i plotë.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Gomat: kontakti yt i vetëm me rrugën',
        blocks: [
          ParagraphBlock(
            'Katër sipërfaqe kontakti, secila afërsisht sa një kartolinë '
            '— asgjë më shumë nuk e lidh furgonin tënd të ngarkuar me '
            'rrugën. Gjithçka që mëson për frenimin, drejtimin dhe '
            'mbërthimin varet nga këto katër sipërfaqe.',
          ),
          FactsBlock([
            FactItem('1,6 mm', 'thellësia minimale ligjore e profilit'),
            FactItem('3 mm', 'profili minimal i rekomanduar në verë'),
            FactItem('4 mm', 'profili minimal i rekomanduar në dimër'),
            FactItem('60 € + 1 pikë', 'për profil shumë të hollë'),
          ]),
          BulletsBlock([
            'Kontrollo thellësinë e profilit me një monedhë 1 euro: buza '
                'e artë është 3 mm e gjerë — nëse zhduket brenda '
                'profilit, ke ende mjaftueshëm',
            'Kontrollo presionin me goma të ftohta dhe përshtate me '
                'ngarkesën — i ngarkuar të duhet më shumë presion se '
                'bosh',
            'Kujdes ndaj konsumimit të pabarabartë: e konsumuar vetëm në '
                'njërën anë do të thotë problem me gjeometrinë ose '
                'presionin',
            'Fryrjet, plasaritjet dhe vidat e ngulura njoftohen '
                'menjëherë',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Presioni i pakët është më i rrezikshëm se i tepërti',
            text: 'Një gomë e fryrë pak deformohet, nxehet dhe me '
                'ngarkesë të plotë mund të shpërthejë. Përveç kësaj '
                'rritet rruga e frenimit dhe rreziku i akuaplanimit.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dritat, xhamat, pasqyrat',
        blocks: [
          ParagraphBlock(
            'Të të shohin është po aq e rëndësishme sa të shohësh. Një '
            'dritë frenimi e prishur te furgoni është shkaku klasik i '
            'një përplasjeje nga pas, te e cila ti nuk je shkaktari — '
            'por dëmin e ke prapëseprapë.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Pamja e lirë është detyrim',
            text: 'Sipas § 23 par. 1 StVO duhet të kujdesesh që pamja '
                'dhe dëgjimi të mos jenë të penguara — nga ngarkesa, '
                'pasagjerët, xhamat e ngrirë ose të pisët. Një „vrimë '
                'shikimi" e kruar në xham shprehimisht nuk mjafton.',
          ),
          BulletsBlock([
            'Rregullo pasqyrat në vend, para se të ndizet motori — kurrë '
                'gjatë udhëtimit',
            'Pasqyrat e jashtme ashtu që të mbetet e dukshme një shirit '
                'i ngushtë i mjetit tënd: ky është pika jote e '
                'referimit',
            'Mbaji xhamat dhe pasqyrat pastër brenda e jashtë — yndyra '
                'në anën e brendshme verbon jashtëzakonisht natën',
            'Fshirëset që lyejnë xhamin, ndërrohen menjëherë',
          ]),
          RevealBlock(
            prompt: 'Gjatë rrotullimit vëren: pasqyra e jashtme e djathtë '
                'lëkundet dhe ka një plasaritje. Ke edhe 190 ndalesa '
                'përpara. Të nisesh apo jo?',
            answer: 'Mos u nis para se të jetë njoftuar. Pasqyra e '
                'jashtme e djathtë është pikërisht ajo me të cilën '
                'siguron këndin e vdekur ndaj çiklistëve dhe trotuarit — '
                'pikërisht atje ndodhin aksidentet e rënda gjatë kthimit. '
                'Një pasqyrë e plasaritur dhe e lëkundur është defekt që '
                'prek sigurinë në trafik. Njofto, ndërro pasqyrën ose '
                'ndërro mjetin.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Sigurimi i ngarkesës: kupto forcat',
        blocks: [
          ParagraphBlock(
            'Ngarkesa duhet të jetë e siguruar ashtu që të mos rrëshqasë '
            'as gjatë një frenimi të plotë, as gjatë një manovre të '
            'papritur shmangieje. Çfarë do të thotë kjo konkretisht, '
            'shkruhet në rregullat e njohura të teknikës — dhe ato '
            'llogaritin me vlera të qarta.',
          ),
          FactsBlock([
            FactItem('0,8 g', 'forca përpara, kundër së cilës duhet '
                'siguruar'),
            FactItem('0,5 g', 'forca prapa dhe anash'),
            FactItem('16 kg', 'forcë mbajtëse që i duhet vetëm një pakoje '
                '20-kilogramëshe gjatë frenimit'),
          ]),
          ParagraphBlock(
            'Përkthyer: Një pako 20 kg shtyn gjatë një frenimi të plotë '
            'me rreth 16 kg përpara — sikur të kishe shtyrë një kasë të '
            'plotë ujë drejt murit ndarës. Me njëzet pako të tilla janë '
            'mbi 300 kg që duan të lëvizin njëkohësisht përpara.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 22 StVO — ngarkesa',
            text: 'Ngarkesa duhet të vendoset dhe të sigurohet ashtu që '
                'as gjatë frenimit të plotë as gjatë një lëvizjeje të '
                'papritur shmangieje të mos rrëshqasë, të mos rrëzohet, '
                'të mos rrokulliset dhe të mos bjerë. Ngarkesa e '
                'pasiguruar dënohet me gjobë dhe, kur rrezikon të '
                'tjerët, edhe me pikë — dhe prek shoferin.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Çfarë shkaktojnë 20 kg në rast serioz',
        blocks: [
          ParagraphBlock(
            '0,8 g vlejnë për frenimin dhe shmangien. Në një përplasje '
            'të vërtetë veprojnë ngadalësime dukshëm më të larta për një '
            'kohë shumë të shkurtër — forca e goditjes së një pakoje të '
            'pasiguruar është atëherë shumëfish mbi peshën e saj.',
          ),
          RevealBlock(
            prompt: 'Rast praktik: Në sedilen e pasagjerit rri një '
                'dërgesë 12 kg, sepse është ndalesa e radhës. Brenda '
                'qytetit duhet të frenosh plotësisht para një fëmije. '
                'Çfarë ndodh me pakon?',
            answer: 'Ajo lëviz më tej me shpejtësinë tënde fillestare, '
                'derisa diçka ta ndalë — tabloja e instrumenteve, xhami '
                'i përparmë ose koka jote gjatë një përplasjeje anësore. '
                'Edhe gjatë një frenimi të zakonshëm rreziku fluturon nga '
                'sedilja në hapësirën e këmbëve dhe mund të futet aty nën '
                'pedalin e frenave. Pikërisht prandaj asnjë dërgesë nuk '
                'shkon përpara: ndalesa e radhës parapërgatitet në '
                'hapësirën e ngarkesës, jo në sedilen e pasagjerit.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Asgjë në kabinë',
            text: 'Asnjë pako, asnjë kuti rrotullimi, asnjë vegël e '
                'lirshme në hapësirën e shoferit. Një send nën pedalin e '
                'frenave ta merr frenimin pikërisht në atë çast kur ke '
                'nevojë për të.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kështu ngarkon drejt',
        asset: 'assets/academy/driving/m02c_ladung.svg',
        blocks: [
          ParagraphBlock(
            'Rregulla bazë: e rënda poshtë, e rënda përpara, pesha e '
            'shpërndarë njësoj mbi boshtet. Një furgon i ngarkuar lart ka '
            'qendër rëndese të lartë — dhe ajo vendos nëse në një kthesë '
            'ende rrëshqet apo tashmë përmbyset.',
          ),
          DoDontBlock(
            doTitle: 'E siguruar',
            dos: [
              'Pakot e rënda poshtë dhe përpara te muri ndarës',
              'Pesha e shpërndarë njësoj majtas/djathtas',
              'Ngarkim i mbyllur — mbylli boshllëqet, që asgjë të mos '
                  'marrë vrull',
              'Rripat lidhës dhe rrjeta ndarëse të shtrënguar, edhe kur '
                  'hapësira e ngarkesës zbrazet',
              'Pas çdo ringarkimi bëj një kontroll të shkurtër',
            ],
            dontTitle: 'E pasiguruar',
            donts: [
              'Pakot e rënda të stivosura lirshëm sipër',
              'Dërgesa në hapësirën e këmbëve ose në sedilen e '
                  'pasagjerit',
              'Gjithçka e futur brenda „si të vijë", boshllëqet hapur',
              'Rrjeta ndarëse e liruar, sepse pengon gjatë kapjes',
              'Ngarkesa e „mbajtur" vetëm me peshën e trupit tënd',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Hapësira e zbrazët e ngarkesës është më e rrezikshmja',
            text: 'Sa më pak të ketë brenda, aq më shumë rrugë ka pakoja '
                'e mbetur për të marrë shpejtësi. Gjysmë bosh nuk do të '
                'thotë gjysmë e rrezikshme — do të thotë siguro '
                'sërish.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Rregull në kabinë dhe rripi',
        blocks: [
          ParagraphBlock(
            'Pija, telefoni, skaneri, fletëdërgesat — gjithçka merr një '
            'vend të fiksuar. Ajo që rrokulliset, kërcet ose fluturon, '
            'ta tërheq shikimin nga rruga. Një vend shoferi i rregulluar '
            'është një vend shoferi i sigurt.',
          ),
          FactsBlock([
            FactItem('30 €', 'gjobë paralajmëruese pa rrip sigurimi'),
            FactItem('Çdo', 'ndalesë: vendos rripin sërish, edhe për 200 '
                'metra'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 21a StVO — detyrimi i rripit',
            text: 'Rripi i sigurimit duhet të jetë i vendosur gjatë '
                'udhëtimit — pa përjashtim për distanca të shkurtra mes '
                'dy ndalesave. Në një aksident pa rrip mund të të '
                'ngarkohet përveç kësaj edhe një pjesë e fajit.',
          ),
          ParagraphBlock(
            'Pikërisht në shpërndarje rripi është siguresa që lihet më '
            'shpesh pas dore — sepse mes dy ndalesave ka vetëm pak '
            'qindra metra. Por pikërisht atje ndodhin shumica e '
            'përplasjeve brenda qytetit.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listë kontrolli para nisjes',
        blocks: [
          ChecklistBlock(
            title: 'Para se të nisem',
            items: [
              'Rrotullimin e kam bërë me radhë të fiksuar',
              'Gomat: profili, presioni, dëmtimet të kontrolluara',
              'Ndriçimi i kontrolluar rreth e rrotull, targa e '
                  'lexueshme',
              'Asnjë gjurmë lëngu nën mjet',
              'Xhamat dhe pasqyrat pastër, pasqyrat e rregulluara',
              'Pakot e rënda poshtë dhe përpara, pesha e shpërndarë',
              'Rripat lidhës dhe rrjeta ndarëse të shtrënguar',
              'Asgjë e lirshme në kabinë, telefoni në mbajtëse',
              'Jelek sinjalizues afër dore, trekëndësh në bord',
              'Rripi i vendosur',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M3
  SafetyChapterContent(
    id: 'm3',
    title: 'Ngasje mbrojtëse dhe parashikuese',
    summary: 'Drejto distancën, shpejtësinë dhe vëmendjen ashtu që të kesh '
        'gjithmonë një rezervë',
    asset: 'assets/academy/driving/m03_defensiv.svg',
    slides: [
      SafetySlide(
        title: 'Rruga e ndalimit = rruga e reagimit + rruga e frenimit',
        blocks: [
          ParagraphBlock(
            'Rruga e ndalimit është distanca nga çasti i vërejtjes deri '
            'në ndalim të plotë. Ajo përbëhet nga dy pjesë: rruga e '
            'reagimit, të cilën e bën ende me shpejtësi të plotë, dhe '
            'vetë rruga e frenimit.',
          ),
          FactsBlock([
            FactItem('rreth 1 s', 'koha e reagimit e një shoferi të '
                'zgjuar dhe të esëll'),
            FactItem('× 3', 'rruga e reagimit = shpejtësia ÷ 10, herë 3'),
            FactItem('²', 'rruga e frenimit = (shpejtësia ÷ 10) në '
                'katror'),
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Formulat praktike',
            text: 'Rruga e reagimit = (km/h ÷ 10) × 3. Rruga e frenimit = '
                '(km/h ÷ 10) × (km/h ÷ 10). Të dyja së bashku japin rrugën '
                'e ndalimit. Gjatë një frenimi urgjent rruga e frenimit '
                'përgjysmohet.',
          ),
          ParagraphBlock(
            'Pika vendimtare: rruga e frenimit nuk rritet në përpjesëtim '
            'me shpejtësinë, por në katror. Shpejtësi e dyfishtë do të '
            'thotë rrugë frenimi katërfish — ky është shkaku pse 20 km/h '
            'më shumë në një rrugë banimi ndryshojnë gjithçka.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Llogarit, mos gjyko me sy',
        blocks: [
          TableBlock(
            headers: ['Shpejtësia', 'Reagimi', 'Frenimi', 'Ndalimi'],
            rows: [
              ['30 km/h', '9 m', '9 m', '18 m'],
              ['50 km/h', '15 m', '25 m', '40 m'],
              ['70 km/h', '21 m', '49 m', '70 m'],
              ['100 km/h', '30 m', '100 m', '130 m'],
            ],
          ),
          ParagraphBlock(
            'Për krahasim: një Sprinter është rreth 6 metra i gjatë. Me '
            'shpejtësi 50 të duhen pra afërsisht shtatë gjatësi mjeti deri '
            'në ndalim — dhe dy e gjysmë të parat kalojnë para se ta '
            'prekësh fare pedalin.',
          ),
          RevealBlock(
            prompt: 'Detyrë llogaritëse: Ngas 50 km/h nëpër një rrugë '
                'banimi. Në 20 metra një fëmijë del mes dy makinave të '
                'parkuara në rrugë. A arrin të ndalosh?',
            answer: 'Jo. Vetëm rruga jote e reagimit është 15 metra, '
                'pastaj vijnë 25 metra rrugë frenimi — bashkë 40 metra. '
                'Edhe me frenim urgjent (15 m + 12,5 m = 27,5 m) 20 metra '
                'nuk mjaftojnë. Me shpejtësi 30 përkundrazi: 9 m reagim + '
                '9 m frenim = 18 metra — ndalon dy metra më parë. '
                'Pikërisht ky është ndryshimi mes një frike dhe një '
                'aksidenti të rëndë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Rregulli i dy sekondave',
        asset: 'assets/academy/driving/m03b_abstand.svg',
        blocks: [
          ParagraphBlock(
            'Distanca nuk është mirësjellje, por koha jote e reagimit e '
            'shprehur në metra. Dhe meqë funksionon e menduar në sekonda, '
            'ajo përshtatet automatikisht me shpejtësinë tënde.',
          ),
          StepsBlock([
            'Zgjidh një pikë të fiksuar në anë të rrugës — tabelë, '
                'shtyllë drite, shenjë në asfalt',
            'Kur mjeti para teje kalon atë pikë, fillo të numërosh: '
                '„njëzetenjë, njëzetedy"',
            'Nëse je te pika para „njëzetedy", ngas shumë afër',
            'Në lagështi, mjegull ose errësirë rrite në tri sekonda',
          ]),
          FactsBlock([
            FactItem('2 s', 'distanca minimale në rrugë të thatë'),
            FactItem('3 s+', 'në lagështi, mjegull, errësirë'),
            FactItem('28 m', 'i përgjigjen 2 sekondave me shpejtësi 50'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 4 par. 1 StVO — distanca',
            text: 'Distanca ndaj mjetit përpara duhet të jetë si rregull '
                'aq e madhe sa të mund të ndalosh pas tij edhe kur ai '
                'frenon papritur. Si formulë praktike vlen jashtë qytetit '
                'gjysma e vlerës së shpejtësimatësit në metra.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kur mungon distanca',
        blocks: [
          RevealBlock(
            prompt: 'Rast praktik: Në rrugën nacionale mban me shpejtësi '
                '80 një distancë të pastër prej 40 metrash. Një veturë '
                'futet në hapësirë dhe pastaj frenon. Çfarë është e saktë '
                'tani?',
            answer: 'Mos u nervozo, mos i bjer borisë, mos e shtyj — por '
                'hiqe gazin dhe ndërto sërish distancën. Kjo të kushton '
                'disa sekonda dhe është reagimi i vetëm që ta ul rrezikun. '
                'Kush përkundrazi afrohet për ta „mbrojtur" hapësirën, nuk '
                'ka më 40 metra me shpejtësi 80, por ndoshta 15 — më pak '
                'se rruga e pastër e reagimit prej 24 metrash.',
          ),
          DoDontBlock(
            doTitle: 'Me qetësi',
            dos: [
              'Pas futjes së tjetrit ndërto qetësisht sërish distancën',
              'Nëse dikush të shtyn nga pas: mbaj djathtas, lëre të '
                  'kalojë',
              'Para semaforëve dhe punimeve hiqe gazin herët',
              'Në trafik të ngeshëm lër hapësirë ndaj mjetit përpara, që '
                  'të mund të dalësh anash',
            ],
            dontTitle: 'Rrezik',
            donts: [
              'Të afrohesh që tjetri të mos futet',
              'Dritat dhe boria si mjet edukimi',
              'Në ecje-ndalim të shkosh drejt e mbi parakolp',
              'Distancën ta gjykosh vetëm me ndjenjë e jo me sekonda',
            ],
          ),
          FactsBlock([
            FactItem('deri 400 €', 'gjobë për shkelje të distancës, plus '
                'pikë dhe ndalim drejtimi'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Shiko larg përpara',
        asset: 'assets/academy/driving/m03c_blickfuehrung.svg',
        blocks: [
          ParagraphBlock(
            'Mos shiko parakolpin përpara teje, por 12–15 sekonda përpara '
            '— brenda qytetit pra rreth dy blloqe rrugësh. Kështu i sheh '
            'herët dritat e frenimit, semaforët, këmbësorët dhe ngushticat '
            'dhe nuk duhet të reagosh me nxitim.',
          ),
          BulletsBlock([
            'Fëmija te trotuari që ende nuk ka shikuar',
            'Çiklisti që do të dalë anash një makine të parkuar',
            'Dera e makinës pas së cilës ulet dikush — dritat e prapme '
                'ndezur, koka në pasqyrën e brendshme',
            'Dritat e frenimit tri mjete më përpara',
            'Kontejnerët e mbeturinave në anë të rrugës: shenjë për '
                'trafik manovrimi',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Shikimi e drejton mjetin',
            text: 'Aty ku shikon, atje shkon. Prandaj gjatë shmangies '
                'shiko gjithmonë hapësirën e lirë — kurrë pengesën.',
          ),
          ParagraphBlock(
            'Çdo pak sekonda bën pjesë edhe një vështrim i shkurtër në '
            'pasqyra. Kështu e di në çdo çast se çfarë ndodh pas teje, pa '
            'qenë nevoja të shikosh vetëm në rast urgjence.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Shpejtësia është fizikë',
        blocks: [
          ParagraphBlock(
            'Shpejtësia e lejuar është maksimum, jo qëllim. Në lagje '
            'banimi, pranë shkollave, te makinat e parkuara dhe në rrugë '
            'të ngushta, më ngadalë se e lejuara është shpesh zgjidhja e '
            'vetme e drejtë.',
          ),
          FactsBlock([
            FactItem('×4', 'rruga e frenimit me shpejtësi të dyfishtë'),
            FactItem('18 m', 'rruga e ndalimit me 30 km/h'),
            FactItem('40 m', 'rruga e ndalimit me 50 km/h'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 3 par. 1 StVO — ngasja sipas pamjes',
            text: 'Lejohet të ngasësh vetëm aq shpejt sa të mund të '
                'ndalosh brenda pjesës së dukshme të rrugës. Në mjegull, '
                'errësirë ose kthesë të mbyllur kjo është dukshëm më pak '
                'se sa lejon tabela.',
          ),
          ParagraphBlock(
            'Llogarit njëherë sa të sjell në të vërtetë vrapimi: në dhjetë '
            'kilometra rrugë qyteti, mes shpejtësisë 50 dhe 60 kursen në '
            'rastin më të mirë dy minuta — të cilat t\'i merr sërish '
            'semafori i parë i kuq.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pse furgoni yt i ngarkuar ecën ndryshe',
        blocks: [
          ParagraphBlock(
            'Një furgon plot i ngarkuar është mjet tjetër nga i njëjti '
            'mjet bosh në mëngjes. Më shumë masë do të thotë më shumë '
            'energji lëvizjeje që frenat duhet ta shuajnë — dhe qendër '
            'rëndese më e lartë do të thotë më pak rezervë në kthesë.',
          ),
          FactsBlock([
            FactItem('3,5 t', 'pesha e lejuar e përgjithshme e furgonit '
                'tënd'),
            FactItem('deri 1,4 t', 'ngarkesë — më shumë se gjysma e peshës '
                'bosh'),
            FactItem('e lartë', 'qendra e rëndesës: furgonët përmbysen aty '
                'ku veturat ende rrëshqasin'),
          ]),
          BulletsBlock([
            'I ngarkuar freno më herët dhe më butë — frenave u duhet më '
                'gjatë për të njëjtin ngadalësim',
            'Në kthesa dukshëm më ngadalë: ngarkesa zhvendoset nga jashtë '
                'dhe e forcon prirjen për përmbysje',
            'Gjatë manovrave të shmangies mos e kthe timonin me shkulje — '
                'pikërisht kjo i përmbys mjetet e larta',
            'Rrethrrotullimet dhe daljet e autostradës futi me dukshëm më '
                'pak shpejtësi se zakonisht',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Çasti i përmbysjes vjen pa paralajmërim',
            text: 'Ndryshe nga një veturë, një furgon i lartë pothuajse '
                'nuk e paralajmëron përmbysjen. Kur ngarkesa zhvendoset '
                'dëgjueshëm, ti je tashmë shumë shpejt — hiqe shpejtësinë '
                'para se të hysh në kthesë, jo brenda saj.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Këndi i vdekur',
        asset: 'assets/academy/driving/m03d_toterwinkel.svg',
        blocks: [
          ParagraphBlock(
            'Furgoni yt ka kënde të vdekura të mëdha — sidomos djathtas '
            'pranë dhe pjerrtazi pas kabinës. Aty futet një çiklist i '
            'tërë bashkë me biçikletën, pa e parë ti në pasqyrë.',
          ),
          FactsBlock([
            FactItem('djathtas', 'këndi i vdekur më i madh te furgonët'),
            FactItem('1,5 m', 'distanca minimale gjatë tejkalimit të '
                'çiklistëve brenda qytetit'),
            FactItem('2 m', 'distanca minimale jashtë qytetit'),
          ]),
          ParagraphBlock(
            'Rregullimi i drejtë i pasqyrave e zvogëlon këndin e vdekur, '
            'por nuk e heq. Prandaj te çdo ndërrim shiriti dhe te çdo '
            'kthesë bën pjesë vështrimi aktiv mbi sup — një vështrim i '
            'shkurtër, i vërtetë mbi sup, jo vetëm një tundje koke drejt '
            'pasqyrës.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Kurrë mos supozo se të kanë parë',
            text: 'Kontakti me sy është prova e vetme e besueshme se '
                'dikush të ka vënë re. Sinjali është një qëllim, jo një '
                'garanci.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kthesa: çasti më i rrezikshëm',
        blocks: [
          ParagraphBlock(
            'Shumica e përplasjeve të rënda me çiklistë dhe këmbësorë '
            'ndodhin gjatë kthimit djathtas. Shkaku është gjithmonë i '
            'njëjti: çiklisti vazhdon drejt dhe ndodhet pikërisht në atë '
            'zonë që shoferi gjatë kthimit nuk e sheh më.',
          ),
          RevealBlock(
            prompt: 'Rast praktik: Do të kthehesh djathtas te një '
                'semafor. Një çiklist të ka tejkaluar majtas dhe qëndron '
                'pranë teje. Semafori bëhet i gjelbër. Çfarë bën së '
                'pari?',
            answer: 'Qëndro dhe lëre të kalojë. Sapo të nisesh dhe të '
                'kthesh timonin, ai kalon në këndin e vdekur djathtas — '
                'dhe pjesa e prapme e mjetit tënd gjatë kthimit hyn '
                'përveç kësaj në shiritin e tij. E saktë është: para '
                'nisjes vështrim mbi sup djathtas, lër të kalojnë '
                'çiklistët dhe këmbësorët, pastaj kthehu ngadalë dhe gjatë '
                'kthimit shiko sërish në pasqyrën e djathtë. Kush '
                'mbështetet vetëm te pasqyra, nuk e sheh pikërisht atëherë '
                'kur ka rëndësi.',
          ),
          DoDontBlock(
            doTitle: 'Kthim i sigurt',
            dos: [
              'Sinjalizo herët dhe ule dukshëm shpejtësinë',
              'Vështrim mbi sup para kthimit — jo vetëm pasqyra',
              'Gjatë kthimit kontrollo edhe një herë djathtas',
              'Në dyshim ndalo dhe lëri të kalojnë',
            ],
            dontTitle: 'Rrezik',
            donts: [
              'Të kthehesh me vrull, për ta shfrytëzuar hapësirën',
              'Vetëm vështrimi në pasqyrë',
              'Të supozosh se çiklistët mbeten pas teje',
              'Ta ndezësh sinjalin vetëm kur po kthen tashmë',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Gjatë kthimit dhe kthimit të plotë',
            text: '§ 9 par. 5 StVO: Gjatë kthimit në një pronë, gjatë '
                'kthimit të plotë dhe gjatë lëvizjes prapa duhet të '
                'përjashtosh çdo rrezik për pjesëmarrësit e tjerë në '
                'trafik — nëse është e nevojshme duhet të kërkosh dikë që '
                'të të udhëzojë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listë kontrolli: në rrugë me kujdes',
        blocks: [
          ChecklistBlock(
            title: 'Këtë e zbatoj që sot',
            items: [
              'I njoh formulat praktike për rrugën e reagimit dhe të '
                  'frenimit',
              'E kontrolloj distancën time te një pikë fikse me dy '
                  'sekonda',
              'Në lagështi dhe errësirë e rrit në tri sekonda',
              'Shikoj 12–15 sekonda përpara në vend të parakolpit',
              'I ngarkuar ngas më ngadalë në kthesa dhe frenoj më herët',
              'Para çdo kthimi dhe ndërrimi shiriti bëj një vështrim të '
                  'vërtetë mbi sup',
              'Mbaj 1,5 m distancë gjatë tejkalimit të çiklistëve brenda '
                  'qytetit',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M4
  SafetyChapterContent(
    id: 'm4',
    title: 'Lëvizja prapa dhe manovrimi',
    summary: 'Zotëro burimin më të shpeshtë të dëmeve — lëviz prapa dhe '
        'manovro i sigurt në situata të ngushta',
    asset: 'assets/academy/driving/m04_rueckwaerts.svg',
    slides: [
      SafetySlide(
        title: 'Burimi numër 1 i dëmeve',
        blocks: [
          ParagraphBlock(
            'Shumica e dëmeve te furgonët lindin ngadalë — gjatë lëvizjes '
            'prapa dhe manovrimit: shtylla, mure, fenerë, makina të tjera, '
            'dyer të hapura. Dhe në rastet më të këqija persona që '
            'qëndrojnë në këndin e vdekur pas mjetit.',
          ),
          FactsBlock([
            FactItem('70 %', 'e të gjitha dëmeve të furgonëve ndodhin '
                'gjatë manovrimit'),
            FactItem('< 10 km/h', 'shpejtësia me të cilën lindin shumica e '
                'dëmeve të manovrimit'),
            FactItem('e verbër', 'një zonë prej disa metrash pikërisht pas '
                'mjetit'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Pse pikërisht këtu',
            text: 'Gjatë lëvizjes prapa të mungon ajo që të mbron '
                'zakonisht: pamja e lirë. Njëkohësisht duket ngadalë dhe '
                'prandaj pa rrezik — kombinimi më i rrezikshëm në '
                'përditshmërinë e shpërndarjes.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Shmange lëvizjen prapa, mos u mundo ta zotërosh',
        blocks: [
          ParagraphBlock(
            'Lëvizja prapa më e sigurt është ajo që nuk e bën. Mendo që '
            'kur i afrohesh ndalesës se si do të dalësh sërish — atëherë '
            'në fund nuk të duhet fare të manovrosh.',
          ),
          BulletsBlock([
            'Nëse është e mundur, parkohu me kokë përpara dhe dil sërish '
                'përpara',
            'Më mirë ndalo 40 metra më tutje sesa të futesh prapa në një '
                'hyrje të ngushtë',
            'Te rrugët pa dalje dhe oborret: para se të futesh mendo si do '
                'të dalësh sërish',
            'Mba mend vendet e kthimit në itinerar — ato janë çdo ditë të '
                'njëjtat',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Çfarë kërkojnë ligji dhe DGUV',
            text: '§ 9 par. 5 StVO: Gjatë lëvizjes prapa duhet të '
                'përjashtosh rrezikimin e të tjerëve, nëse është e '
                'nevojshme të kërkosh dikë që të të udhëzojë. DGUV '
                'Vorschrift 70 (rregullorja gjermane për mjetet) kërkon të '
                'njëjtën gjë: lëvizje prapa vetëm nëse rrezikimi i '
                'personave është i përjashtuar.',
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
            text: '„Get Out And Look" — ndalo, zbrit, shiko pas mjetit dhe '
                'vetëm pastaj lëviz prapa. Kjo zbulon pikërisht ato gjëra '
                'që nga sedilja nuk i sheh kurrë.',
          ),
          ParagraphBlock(
            'Rrotullimi zgjat dhjetë deri në pesëmbëdhjetë sekonda. Në '
            'këtë kohë i sheh shtyllat e ulëta, buzët e trotuarit, '
            'pjerrësinë, kapakët e liruar të pusetave, fëmijët duke '
            'luajtur dhe lartësinë e hyrjes. Asnjë nga këto nuk të tregon '
            'me siguri një kamerë e lëvizjes prapa.',
          ),
          FactsBlock([
            FactItem('15 s', 'zgjat një rrotullim GOAL'),
            FactItem('90 cm', 'lartësia nën të cilën një fëmijë mbetet i '
                'padukshëm pas mjetit'),
          ]),
          ParagraphBlock(
            'Dhe diçka tjetër: atë që ke parë gjatë zbritjes, e mban në '
            'kokë. Pas kësaj nuk ngas drejt së panjohurës, por drejt një '
            'pamjeje që e njeh.',
          ),
        ],
      ),
      SafetySlide(
        title: 'GOAL hap pas hapi',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/goal01_stopp.svg',
              title: '1 · Ndalo',
              caption: 'Para se të vësh marshin prapa, ndalon plotësisht '
                  'dhe siguron mjetin. Kush tashmë ecën, nuk vendos më — '
                  'ai vetëm reagon.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal02_aussteigen.svg',
              title: '2 · Zbrit',
              caption: 'Zbrit, në vend që të përdridhesh në sedilje. '
                  'Përdor shkallën dhe dorezat — rregulli i tri pikave '
                  'vlen edhe këtu.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal03_umschauen.svg',
              title: '3 · Shiko rrotull',
              caption: 'Bëj një rrotullim të plotë rreth mjetit: çfarë rri '
                  'ulët pas pjesës së prapme, sa e lartë është hyrja, ku '
                  'ka pjerrësi, a ka fëmijë ose kafshë afër? Mba mend '
                  'distancat dhe pikat fikse.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal04_zurueck.svg',
              title: '4 · Ngadalë prapa',
              caption: 'Vetëm tani lëviz prapa — me shpejtësi këmbësori, '
                  'me vështrim mbi sup dhe në të dyja pasqyrat. Në dyshim '
                  'ndalo edhe një herë dhe shiko sërish.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Ngadalë nuk do të thotë pa rrezik',
        blocks: [
          StepsBlock([
            'Zgjidh shpejtësinë e këmbësorit — kurrë më shpejt, as në '
                'oborrin e zbrazët',
            'Ule xhamin që të dëgjosh: thirrje, bori, fëmijë',
            'Shiko mbi sup dhe në të dyja pasqyrat, me radhë',
            'Kamerën përdore vetëm si shtesë, kurrë si burim të vetëm',
            'Në çdo dyshim ndalo, zbrit, shiko sërish',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Mashtrimi i kamerës',
            text: 'Kamera e lëvizjes prapa tregon një prerje, i shtrembëron '
                'distancat dhe verbohet nga shiu, bora dhe balta. Ajo nuk '
                'sheh asgjë që hyn anash pjesës së prapme në rrugën tënde. '
                'Ajo nuk e zëvendëson GOAL.',
          ),
          FactsBlock([
            FactItem('këmbësor', 'shpejtësia maksimale gjatë manovrimit'),
            FactItem('2 s', 'i duhen një fëmije për të vrapuar në zonën '
                'pas mjetit'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Përdore drejt udhëzuesin',
        blocks: [
          ParagraphBlock(
            'Një udhëzues ndihmon vetëm nëse rregullat janë të qarta që '
            'më parë. Një koleg që rri diku pas mjetit dhe bën me dorë '
            'nuk është siguri — ai është rrezik shtesë.',
          ),
          BulletsBlock([
            'Merruni vesh më parë për shenjat: ndal, ngadalë, vazhdo, sa '
                'hapësirë',
            'Udhëzuesi qëndron anash, kurrë drejtpërdrejt pas mjetit',
            'Duhet ta shohësh vazhdimisht në pasqyrë — përndryshe vlen '
                'ndalimi',
            'Udhëzon vetëm një person, jo disa njëkohësisht',
            'Udhëzuesi mban jelek sinjalizues, sidomos në muzg',
          ]),
          RevealBlock(
            prompt: 'Po futesh prapa në një hyrje të ngushtë oborri, '
                'kolegu të udhëzon. Papritur nuk e sheh më në pasqyrë. '
                'Çfarë bën?',
            answer: 'Ndalo menjëherë — jo të ngadalësosh, por të ndalosh. '
                'Pa kontakt me sy nuk ka shenjë të vlefshme. Ndoshta ka '
                'kaluar pas mjetit, ka rrëshqitur ose e ka ndalur një '
                'kalimtar. Vazhdo vetëm kur ta shohësh sërish dhe ai të '
                'të japë një shenjë të re.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Rast praktik: hyrja e ngushtë e oborrit',
        blocks: [
          RevealBlock(
            prompt: 'Rast praktik: Ndalesa e fundit ndodhet në një oborr '
                'të brendshëm. Hyrja është e ngushtë, pas teje pret një '
                'makinë, bie shi dhe je 40 minuta pas planit. Përpara futesh '
                '— dil vetëm prapa, pranë një muri dhe tri makinave të '
                'parkuara. Cili është vendimi i drejtë?',
            answer: 'Mos u fut fare brenda. Ndalo në rrugë, bëji metrat e '
                'fundit në këmbë ose përdor karrocën. Nëse je tashmë '
                'brenda: ndiz dritat e rrezikut, zbrit, shiko gjendjen, '
                'nëse duhet lute shoferin që pret të lëvizë prapa, dhe '
                'pastaj dil me disa lëvizje të shkurtra me kontrolle në '
                'mes. Shoferi që pret pas teje nuk është arsye për nxitim '
                '— dëmi në fund të ngarkohet ty, jo atij. 40 minutat e '
                'vonesës nuk i kthen asnjë manovër, por një dëm llamarine '
                'të kushton pjesën tjetër të ditës.',
          ),
          DoDontBlock(
            doTitle: 'Manovrim i drejtë',
            dos: [
              'Me disa lëvizje të shkurtra në vend të një të gjatë',
              'Ndalo në mes dhe kontrollo sërish gjendjen',
              'Dritat e rrezikut gjatë manovrimit në hapësirën e trafikut',
              'Më mirë ndalo më larg dhe bëji metrat e fundit në këmbë',
            ],
            dontTitle: 'Gabim',
            donts: [
              'Të manovrosh më shpejt nën presionin e atyre që presin',
              'Ta „kalosh" me një lëvizje të vetme, sepse ndryshe duket '
                  'turp',
              'Të mbështetesh vetëm te kamera ose sensorët',
              'Të manovrosh ndërsa këmbësorët kalojnë zonën',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Listë kontrolli: prapa dhe manovrim',
        blocks: [
          ChecklistBlock(
            title: 'Para çdo manovre prapa',
            items: [
              'Së pari kontrolloj a mund ta shmang lëvizjen prapa',
              'Ndaloj plotësisht para se të vë marshin prapa',
              'Zbres dhe shikoj pas mjetit (GOAL)',
              'Lëviz prapa vetëm me shpejtësi këmbësori',
              'Shikoj mbi sup dhe në të dyja pasqyrat, jo vetëm te '
                  'kamera',
              'E ul xhamin që të dëgjoj',
              'Ndaloj menjëherë kur nuk e shoh më udhëzuesin',
              'Njoftoj çdo dëm manovrimi, edhe gërvishtjen e vogël',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M5
  SafetyChapterContent(
    id: 'm5',
    title: 'Moti, pamja dhe kushtet e vështira',
    summary: 'Përshtat mënyrën e ngasjes me shiun, lagështinë, mjegullën, '
        'borën, errësirën dhe vapën',
    asset: 'assets/academy/driving/m05_wetter.svg',
    slides: [
      SafetySlide(
        title: 'Lagështia ndryshon gjithçka',
        blocks: [
          ParagraphBlock(
            'Në rrugë të lagur mbërthimi bie dukshëm — rruga e frenimit '
            'zgjatet ndjeshëm, në shumë situata pothuajse në dyfishin. '
            'Veçanërisht kritik është shiu i parë pas një periudhe të '
            'gjatë thatësire: vaji dhe guma në asfalt formojnë me ujin '
            'një cipë rrëshqitëse.',
          ),
          FactsBlock([
            FactItem('deri ×2', 'kaq e gjatë bëhet rruga e frenimit në '
                'lagështi'),
            FactItem('3 s+', 'distanca minimale në vend të 2 sekondave'),
            FactItem('−20 %', 'shpejtësia si orientim i përafërt'),
          ]),
          BulletsBlock([
            'Freno më herët dhe më butë, jo në kthesë',
            'Lëvizjet e timonit bëji butë, jo me shkulje',
            'Kujdes ndaj shenjave në asfalt, kapakëve të pusetave dhe '
                'shinave të tramvajit — atje është më rrëshqitëse',
            'Shmang gjurmët e thelluara, aty qëndron uji',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Shpejtësia është detyrim, jo zgjedhje',
            text: '§ 3 par. 1 StVO kërkon që ta përshtatësh shpejtësinë me '
                'kushtet e rrugës, të trafikut, të pamjes dhe të motit. Në '
                'një aksident në rrugë të lagur shpejtësia e lejuar nuk të '
                'ndihmon.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Akuaplanimi: çfarë ndodh vërtet aty',
        asset: 'assets/academy/driving/m05b_aquaplaning.svg',
        blocks: [
          ParagraphBlock(
            'Akuaplanim do të thotë: mes gomës dhe rrugës futet një cipë '
            'uji. Goma noton. Nga ai çast timoni dhe frenat nuk kanë më '
            'efekt — jo më pak, por asnjë.',
          ),
          ParagraphBlock(
            'Kanalet e profilit kanë pikërisht një detyrë: ta largojnë '
            'ujin para gomës. Me shpejtësi më të lartë një gomë duhet të '
            'zhvendosë disa litra ujë në çdo sekondë. Sa më i hollë '
            'profili dhe sa më e lartë shpejtësia, aq më herët nuk ia del '
            'më.',
          ),
          FactsBlock([
            FactItem('1,6 mm', 'minimumi ligjor — për akuaplanimin '
                'tashmë shumë pak'),
            FactItem('3 mm', 'kufiri praktik i poshtëm në mot të '
                'lagësht'),
            FactItem('Shpejtësia²', 'kaq fort rritet rreziku i '
                'akuaplanimit me shpejtësinë'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Nga çfarë e vëren herët',
            text: 'Timoni bëhet papritur i lehtë, zhurmat e udhëtimit '
                'ndryshojnë, xhirot ngriten pa arsye. Këto janë sekondat '
                'në të cilat mund të heqësh ende gazin.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Akuaplanimi: reagimi i drejtë',
        blocks: [
          DoDontBlock(
            doTitle: 'Me ujë të ndenjur kështu është drejt',
            dos: [
              'Hiqe gazin — vetëm kaq, jo heqje e menjëhershme e plotë',
              'Mbaje timonin qetë dhe drejt',
              'Shtyp friksionin, përkatësisht lëre të shkëputet',
              'Lëre makinën të ecë deri sa gomat të kapin sërish',
              'Vetëm pastaj kthe timonin ose freno me kujdes',
            ],
            dontTitle: 'Gabim',
            donts: [
              'Të frenosh fort — rrotat bllokohen pa efekt',
              'Të kthesh ose të kundërkthesh timonin me shkulje',
              'Të përshpejtosh, për „ta kaluar"',
              'Të ndërrosh shiritin ndërsa gomat notojnë',
            ],
          ),
          RevealBlock(
            prompt: 'Rast praktik: Në rrugën nacionale, pas një stuhie, '
                'ka ujë në gjurmën e djathtë. Ngas 80 km/h, pas teje të '
                'shtyn një veturë. Çfarë bën?',
            answer: 'Hiqe dukshëm gazin para se të futesh në ujë — jo '
                'brenda tij. Mbaje timonin drejt dhe lëre atë që të shtyn '
                'të shtyjë; një përplasje nga pas riparohet, një dalje në '
                'korsinë e kundërt jo. Kush përkundrazi frenon ose '
                'shmanget në mes të ujit, provokon pikërisht atë humbje '
                'kontrolli që do ta shmangë. Nëse është e mundur: pas '
                'ujit mbaj djathtas dhe lëre të kalojë.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Një gomë që noton nuk drejton',
            text: 'Për sa kohë që cipa e ujit mban, çdo lëvizje e timonit '
                'është pa efekt — ajo vepron papritur vetëm kur goma kap '
                'sërish. Pikërisht nga kjo lind rrëshqitja anësore.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Thellësia e profilit dhe gomat e dimrit',
        blocks: [
          TableBlock(
            headers: ['Situata', 'Profili / gomat'],
            rows: [
              ['Minimumi ligjor', '1,6 mm — gjatë gjithë vitit'],
              ['Verë, rrugë e lagur', 'nga 3 mm e rekomanduar'],
              ['Dimër, borë dhe llucë', 'nga 4 mm e rekomanduar'],
              ['Ngricë, borë, akull', 'goma dimri me simbolin Alpine'],
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Detyrimi situativ i gomave të dimrit',
            text: 'Sipas § 2 par. 3a StVO, në akull, ngricë bore, llucë '
                'bore, akull ose brymë lejohet të ngasësh vetëm me goma të '
                'përshtatshme për dimër. Shkeljet kushtojnë gjobë dhe një '
                'pikë — kur pengohen të tjerët, edhe më shumë.',
          ),
          BulletsBlock([
            'Gomat e dimrit i njeh nga simboli Alpine (mal me flok bore)',
            'Edhe gomat e përshtatshme për dimër me profil shumë të hollë '
                'nuk veprojnë më',
            'Kujdes edhe moshën e gomës: guma ngurtësohet dhe humb '
                'kapjen, edhe kur profili është ende aty',
            'Njofto profilin e hollë para se të vijë ngrica e parë — jo '
                'në mëngjesin pas saj',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Bora, akulli dhe pastrimi i xhamave',
        asset: 'assets/academy/driving/m05c_winter.svg',
        blocks: [
          ParagraphBlock(
            'Në ngricë vlen për gjithçka: butë. Nisu butë, freno butë, '
            'ktheje timonin butë. Çdo lëvizje me shkulje e tejkalon kapjen '
            'tashmë të vogël. Urat, pjesët pyjore dhe vendet me hije '
            'ngrijnë të parat — dhe shkrijnë të fundit.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Asnjë „vrimë shikimi"',
            text: 'Të gjitha xhamat, pasqyrat, dritat dhe targa duhet të '
                'jenë të lira (§ 23 par. 1 StVO). Një vrimë shikimi e '
                'kruar është kundërvajtje — dhe në një aksident një akuzë '
                'e rëndë faji. Edhe bora mbi çati duhet hequr para se të '
                'nisesh.',
          ),
          DoDontBlock(
            doTitle: 'Rutina e dimrit',
            dos: [
              'Pastro plotësisht të gjitha xhamat dhe pasqyrat',
              'Hiq borën nga çatia, dritat dhe targa',
              'Pastro shkallët dhe dorezat nga akulli dhe llucë',
              'Mbush ujin e fshirësve me antifriz',
              'Nisu dukshëm më herët në vend që të nxitosh rrugës',
            ],
            dontTitle: 'Gabimet e dimrit',
            donts: [
              'Të nisesh ndërsa xhami ende po shkrin',
              'Të hedhësh ujë të nxehtë mbi xham',
              'Të frenosh mbi llucë bore dhe njëkohësisht të kthesh',
              'Të shpërfillësh shkallët e akullta — këtu rrëzohesh',
            ],
          ),
          FactsBlock([
            FactItem('0 °C', 'nga këtu së pari urat dhe vendet me hije'),
            FactItem('×2 deri ×10', 'kaq më e gjatë bëhet rruga e frenimit '
                'në borë dhe akull'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Mjegull, muzg, errësirë',
        blocks: [
          ParagraphBlock(
            'Në pamje të keqe nuk është më e vështirë vetëm të shohësh, '
            'por edhe të të shohin. Ndiz dritat me kohë — në dyshim gjysmë '
            'ore më herët se sa duhet.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Rregull praktik në mjegull',
            text: 'Distanca e dukshme në metra i përgjigjet shpejtësisë '
                'maksimale në km/h. Nëse sheh vetëm 50 metra, ngas së '
                'shumti 50 km/h — dhe me pamje nën 50 metra vlen '
                'gjithsesi shpejtësia 50 si kufi i sipërm.',
          ),
          BulletsBlock([
            'Dritat e mjegullës vetëm në pengim të vërtetë të pamjes, jo '
                'si ndriçim i vazhdueshëm',
            'Drita e prapme e mjegullës vetëm nën 50 metra pamje — ajo e '
                'verbon fort atë që vjen pas',
            'Përdor shtyllat udhëzuese në anë të rrugës si orientim',
            'Në muzg kujdes veçanërisht ndaj këmbësorëve me veshje të '
                'errët',
            'Ndriçimi i brendshëm fikur, xhamat pastër nga brenda — '
                'përndryshe të dyja të marrin pamjen e natës',
          ]),
          FactsBlock([
            FactItem('50 m', 'distanca mes dy shtyllave udhëzuese jashtë '
                'qytetit'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Stuhia dhe era anësore',
        blocks: [
          ParagraphBlock(
            'Furgoni yt është një sipërfaqe e madhe dhe e lartë — në erë '
            'anësore sillet krejt ndryshe nga një veturë. Veçanërisht të '
            'rrezikshme janë vendet ku era fillon papritur: urat, daljet '
            'nga pyjet, hapësirat mes ndërtesave dhe kur të tejkalon një '
            'kamion.',
          ),
          BulletsBlock([
            'Ule dukshëm shpejtësinë, të dyja duart në timon',
            'Në vendet e njohura me erë forco kapjen që më parë dhe prit '
                'një shkulm',
            'Pas tejkalimit të një kamioni prit një shkulm ere',
            'Në stuhi mos parko nën pemë dhe as pranë skelave',
            'Mbaji dyert në erë — ato hapen me forcë dhe dëmtohen',
          ]),
          RevealBlock(
            prompt: 'Rast praktik: Paralajmërim stuhie, ngas bosh mbi një '
                'urë autostrade. Pse është kritike pikërisht bosh?',
            answer: 'Sepse mjetit i mungon pesha që e mban në rrugë. Një '
                'furgon bosh ofron të njëjtën sipërfaqe ndaj erës si një i '
                'ngarkuar, por peshon rreth një të tretën më pak — një '
                'shkulm e zhvendos dukshëm më fort. E saktë është: para '
                'urës hiqe shpejtësinë, të dyja duart në timon, prit '
                'shkulmin e erës në fund të urës dhe mos ngas pranë një '
                'kamioni.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Vapa dhe turet e gjata',
        blocks: [
          ParagraphBlock(
            'Në verë punon në një mjet që nxehet fort në diell dhe bën '
            'shumë kilometra në këmbë. Një shofer i mbinxehur dhe i '
            'dehidratuar reagon matshëm më ngadalë — efekti është i '
            'krahasueshëm me atë të lodhjes.',
          ),
          FactsBlock([
            FactItem('2–3 l', 'lëng për ndërrim në vapë'),
            FactItem('> 60 °C', 'temperatura e brendshme në një mjet të '
                'ndalur në diell'),
          ]),
          BulletsBlock([
            'Pi rregullisht, para se të ndiesh etje',
            'Pushimet në hije, jo në kabinën e nxehur',
            'Mbulesë koke dhe mbrojtje nga dielli në rrugë të gjata në '
                'këmbë',
            'Në probleme me qarkullimin e gjakut njofto menjëherë dhe bëj '
                'pushim',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Kurrë mos i lër brenda',
            text: 'Kurrë mos lër një kafshë ose një person në makinën e '
                'nxehur — as „vetëm pesë minuta" dhe as me xhamin pak të '
                'hapur. Brendësia bëhet për minuta nxehtësisht e '
                'rrezikshme për jetën.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listë kontrolli: kushte të vështira',
        blocks: [
          ChecklistBlock(
            title: 'Në mot dhe pamje të keqe',
            items: [
              'Përshtat shpejtësinë dhe distancën, jo vetëm sipas '
                  'tabelës',
              'Në lagështi e rrit distancën në së paku 3 sekonda',
              'Në akuaplanim: hiq gazin, drejt, mos freno',
              'E njoh thellësinë e profilit tim dhe njoftoj herët gomat e '
                  'holluara',
              'I pastroj të gjitha xhamat, asnjë vrimë shikimi',
              'Heq borën nga çatia, dritat dhe targa',
              'Te urat dhe daljet nga pyjet llogaris me erë anësore',
              'Pi mjaftueshëm dhe bëj pushime në hije',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M6
  SafetyChapterContent(
    id: 'm6',
    title: 'Shpërqendrimi, lodhja dhe presioni i kohës',
    summary: 'Njih shkaqet kryesore njerëzore të aksidenteve dhe vepro '
        'aktivisht kundër tyre',
    asset: 'assets/academy/driving/m06_ablenkung.svg',
    slides: [
      SafetySlide(
        title: 'Telefoni në timon: I NDALUAR',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Telefoni në dorë është i ndaluar gjatë udhëtimit',
            text: 'As për të folur, as për të shkruar, as për të parë — '
                'dhe as për të zgjedhur muzikë, podkast apo mesazhe.',
          ),
          ParagraphBlock(
            'Krejt qartë dhe pa përjashtim. Kjo nuk është vetëm rregull i '
            'firmës sonë, por ligj. Dhe vlen për çdo pajisje elektronike '
            'që shërben për komunikim, informim ose organizim — pra edhe '
            'për skanerin.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 23 par. 1a StVO',
            text: 'Kush drejton një mjet, mund të përdorë një pajisje '
                'elektronike vetëm nëse për këtë nuk e merr dhe nuk e mban '
                'në dorë. Vetëm marrja ose mbajtja në dorë është shkelja — '
                'pavarësisht se çfarë bën me të.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Distanca me sy të mbyllur',
        asset: 'assets/academy/driving/m06b_handy.svg',
        blocks: [
          ParagraphBlock(
            'Një vështrim në ekran nuk është një sekondë — mesatarisht ai '
            'zgjat dy deri tri sekonda, një mesazh i lexuar më shumë pesë. '
            'Në këtë kohë ngas me sy të mbyllur. Llogarite njëherë në '
            'metra.',
          ),
          FactsBlock([
            FactItem('14 m/s', 'bën me shpejtësi 50 për çdo sekondë'),
            FactItem('28 m', 'verbërisht me 2 sekonda vështrim në '
                'telefon'),
            FactItem('rreth 70 m', 'verbërisht, kur lexon një mesazh'),
          ]),
          RevealBlock(
            prompt: 'Detyrë llogaritëse: Ngas 30 km/h nëpër një rrugë '
                'lojërash dhe shikon 3 sekonda te skaneri. Sa larg ngas '
                'verbërisht — dhe a mjafton kjo për një aksident?',
            answer: 'Me 30 km/h bën mbi 8 metra për sekondë, pra në 3 '
                'sekonda rreth 25 metra. Kjo është më shumë se e gjithë '
                'rruga e ndalimit me këtë shpejtësi (18 metra). Me fjalë '
                'të tjera: kalon verbërisht një distancë në të cilën me '
                'pamje do të kishe ndaluar prej kohësh. Kush mendon se me '
                'shpejtësi të ulët një vështrim është pa rrezik, e '
                'ngatërron ngadalë me të sigurt — pikërisht në rrugët e '
                'lojërave fëmijët dalin në rrugë pa paralajmërim.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Muzika, navigimi, skaneri — gjithçka që më parë',
        blocks: [
          ParagraphBlock(
            'Muzika dhe podkastet janë në rregull — por jo me telefonin në '
            'dorë. Gjithçka zgjidhet dhe niset para nisjes, në vend: '
            'lista e këngëve, zëri, destinacioni i navigimit, ndalesa e '
            'radhës. Sapo të ecë, gjatë udhëtimit nuk preket më asgjë te '
            'pajisja.',
          ),
          DoDontBlock(
            doTitle: 'E lejuar',
            dos: [
              'Listën e këngëve dhe zërin rregulloji më parë në vend',
              'Destinacionin e navigimit fute para nisjes',
              'Lëre telefonin në mbajtëse dhe vetëm shikoje',
              'Fol pa duar përmes sistemit të bisedës',
              'Për gjithçka tjetër ndalo shkurt',
            ],
            dontTitle: 'E ndaluar',
            donts: [
              'Të ndërrosh këngën ose podkastin gjatë udhëtimit',
              'Të lexosh ose të shkruash mesazh gjatë udhëtimit',
              'Të marrësh telefonin në dorë te semafori i kuq',
              'Të përdorësh skanerin ose listën e ndalesave në lëvizje',
              'Ta heqësh pajisjen nga mbajtësja, për ta parë më mirë',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Asnjë kufje',
            text: 'Asnjë kufje ose dëgjuese gjatë udhëtimit — as në një '
                'vesh. Duhet të dëgjosh trafikun, boritë, thirrjet dhe '
                'mjetet e urgjencës. Gjatë manovrimit dëgjimi është shpesh '
                'paralajmërimi yt i vetëm.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Përjashtimi i vetëm: në vend, motori i fikur',
        blocks: [
          ParagraphBlock(
            'Telefonin, skanerin dhe navigimin i përdor vetëm në ndalim të '
            'sigurt. Rrjedha praktike te ndalesa: ndalo, fike motorin, '
            'përdor pajisjen, pastaj zbrit. Dhe para nisjes: hip, rregullo '
            'destinacionin dhe muzikën, pastaj nisu.',
          ),
          RevealBlock(
            prompt: 'Prej kur llogaritet ligjërisht „në vend" — dhe si '
                'qëndron puna me sistemin start-stop te semafori i kuq?',
            answer: 'Ligjërisht ndalimi llogaritet vetëm kur motori është '
                'i fikur. Përjashtimi shprehimisht nuk vlen kur motori '
                'pushon vetëm përmes një funksioni automatik start-stop. '
                'Te semafori i kuq pra nuk lejohet ta marrësh pajisjen në '
                'dorë — as kur motori sapo është i heshtur.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Përjashtim vetëm me motor të fikur',
            text: 'Përdorimi lejohet vetëm nëse mjeti është i ndalur dhe '
                'motori është i fikur. Një fikje automatike start-stop nuk '
                'mjafton për këtë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Sa kushton',
        blocks: [
          FactsBlock([
            FactItem('100 € + 1 pikë', 'telefoni në dorë gjatë '
                'udhëtimit'),
            FactItem('150 € + 2 pikë', 'me rrezikim, plus 1 muaj ndalim '
                'drejtimi'),
            FactItem('200 € + 2 pikë', 'me dëmtim sendi, plus 1 muaj '
                'ndalim drejtimi'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Periudha e provës',
            text: 'Në periudhën e provës së patentës shtohen një seminar '
                'plotësues dhe zgjatja e periudhës së provës në 4 vjet.',
          ),
          ParagraphBlock(
            'Për ty si shofer profesionist një ndalim drejtimi do të '
            'thotë: pa punë për një muaj. Dhe nëse nga shpërqendrimi lind '
            'një aksident me të lënduar, nuk mbetet vetëm te gjoba — '
            'atëherë del akuza e rrezikimit të trafikut rrugor (§ 315c '
            'StGB), dhe ajo është vepër penale.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Sigurimi më i thjeshtë',
            text: 'Ta lësh telefonin mënjanë nuk kushton asgjë dhe ta '
                'mbron patentën, vendin e punës dhe, në rast serioz, një '
                'jetë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Shpërqendrimi ka shumë forma',
        blocks: [
          ParagraphBlock(
            'Jo vetëm telefoni: të hash, të pish, të kërkosh pako, bisedat, '
            'nervat për klientin e fundit, mendimet te ndalesa e radhës. '
            'Shpërqendrim është gjithçka që të merr sytë, duart ose kokën '
            'nga rruga.',
          ),
          DoDontBlock(
            doTitle: 'Në rregull gjatë udhëtimit',
            dos: [
              'Të shikosh rrugën',
              'Të flasësh pa duar përmes sistemit të bisedës',
              'Vështrime të shkurtra në pasqyra',
              'Për gjithçka tjetër ndalo shkurt',
            ],
            dontTitle: 'Jo në rregull',
            donts: [
              'Të hapësh ushqim ose pije',
              'Të kërkosh pakon e radhës në hapësirën e ngarkesës',
              'Të përdorësh skanerin ose listën e ndalesave duke ngarë',
              'Ta rirendisësh itinerarin në kokë gjatë udhëtimit, në '
                  'vend që të ndalosh shkurt',
            ],
          ),
          RevealBlock(
            prompt: 'Rast praktik: Gjatë nisjes vëren se ke marrë dërgesën '
                'e gabuar. Ndalesa e duhur është 300 metra më tutje. '
                'Çfarë bën?',
            answer: 'Shko deri te vendi i parë i sigurt i ndalimit, ndalo, '
                'fike motorin, pastaj ndërroje në hapësirën e ngarkesës. '
                'Kapja prapa gjatë udhëtimit është situata klasike në të '
                'cilën shoferët dalin nga shiriti — sepse aty kthen '
                'njëkohësisht kokën dhe trupin. 300 metra rrugë shtesë '
                'zgjatin 30 sekonda, një gërvishtje pjesën tjetër të '
                'ditës.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lodhja: trupi yt nuk negocion',
        asset: 'assets/academy/driving/m06c_muedigkeit.svg',
        blocks: [
          ParagraphBlock(
            'Lodhja nuk është problem vullneti. Nga një pikë e caktuar '
            'truri yt fiket për pak — pavarësisht a do ti apo jo. E '
            'rrezikshmja: pikërisht në këtë fazë e mbivlerëson më së '
            'shumti zgjuarsinë tënde.',
          ),
          SubheadBlock('Shenjat paralajmëruese që duhet t\'i marrësh '
              'seriozisht'),
          BulletsBlock([
            'Gogësitje të shpeshta, sy që digjen ose të rëndë',
            'Nuk i kujton kilometrat e fundit',
            'Humb kthesat ose ndalesat',
            'Distanca e sediljes ndihet papritur e gabuar, lëviz vazhdimisht',
            'Ngas i shqetësuar brenda shiritit ose korrigjon vazhdimisht',
            'Ftohje dhe tendosje e qafës pa arsye të jashtme',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Kohët me rrezik',
            text: 'Më të rrezikshmet janë orët e para të mëngjesit, rënia '
                'pas drekës dhe ora e fundit e turit. Planifiko pikërisht '
                'atje pushimet e tua.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Gjumi i çastit në metra',
        blocks: [
          ParagraphBlock(
            'Një gjumë i çastit zgjat zakonisht dy deri në pesë sekonda. '
            'Kjo tingëllon shkurt — derisa ta llogarisësh në metra.',
          ),
          FactsBlock([
            FactItem('56 m', 'me shpejtësi 50 në 4 sekonda gjumë çasti'),
            FactItem('89 m', 'me shpejtësi 80 në 4 sekonda'),
            FactItem('111 m', 'me shpejtësi 100 në 4 sekonda'),
          ]),
          RevealBlock(
            prompt: 'Detyrë llogaritëse: Ngas 80 km/h në rrugë '
                'ndërqytetëse dhe të zë gjumi 4 sekonda. Sa larg ngas pa '
                'kontroll — dhe çfarë ndodhet në këtë distancë?',
            answer: '80 km/h janë rreth 22 metra për sekondë, pra në 4 '
                'sekonda rreth 89 metra. Në këtë distancë, në një rrugë '
                'ndërqytetëse, ndodhen zakonisht një kthesë, një rresht '
                'pemësh dhe trafiku i kundërt. Dhe ndryshe nga vështrimi '
                'te telefoni, në këtë kohë nuk e drejton timonin — mjeti '
                'del nga shiriti. Prandaj kundër gjumit të çastit ndihmon '
                'vetëm një gjë: të ndalosh më parë.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Nuk ka version të vogël të kësaj',
            text: 'Kush ka rënë një herë në gjumë, bie sërish — zakonisht '
                'brenda pak minutash. Udhëtimi mbaron këtu, jo te ndalesa '
                'e radhës.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Çfarë ndihmon — dhe çfarë jo',
        blocks: [
          DoDontBlock(
            doTitle: 'Vepron vërtet',
            dos: [
              'Të ndalosh dhe të mbyllësh sytë 15–20 minuta',
              'Të zbresësh, të ecësh, ajër i pastër dhe lëvizje',
              'Të hash dhe të pish diçka',
              'Ta njoftosh turin dhe të kërkosh mbështetje, kur nuk '
                  'mjafton',
            ],
            dontTitle: 'Nuk vepron (ose vetëm për minuta)',
            donts: [
              'Xhami hapur dhe muzikë e lartë',
              'Kafeja si zëvendësim i gjumit',
              'Të mbahesh zgjuar me biseda',
              'Të ngasësh më shpejt, për të mbaruar më herët',
            ],
          ),
          ParagraphBlock(
            'Një gjumë i shkurtër prej 15 deri 20 minutash me lëvizje pas '
            'tij është masa e vetme që afatshkurt sjell vërtet diçka. '
            'Gjithçka tjetër e shtyn problemin vetëm disa kilometra më '
            'tutje.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Paaftësi për të ngarë',
            text: 'Kush vazhdon të ngasë pavarësisht lodhjes së dukshme, e '
                'drejton mjetin i paaftë për ngasje. Nëse nga kjo lind një '
                'rrezikim, kjo nuk është më gjobë, por vepër penale '
                '(§ 315c StGB).',
          ),
        ],
      ),
      SafetySlide(
        title: 'Menaxho me zgjuarsi presionin e kohës dhe listë kontrolli',
        blocks: [
          ParagraphBlock(
            'Presioni i kohës është real — por vrapimi dhe nxitimi kursejnë '
            'pak kohë dhe kushtojnë shumë rrezik. Fitimi i kohës nga ngasja '
            'më e shpejtë në trafikun e qytetit është në rendin e minutave; '
            'një dëm i vetëm manovrimi të kushton një orë.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Kur plani nuk del',
            text: 'Ky nuk është problem sigurie, ky është çështje '
                'planifikimi — njoftoje herët, në vend që ta kompensosh në '
                'timon. Një njoftim në orën 13 ndihmon, një në orën 18 jo '
                'më.',
          ),
          ChecklistBlock(
            title: 'Këtë marr me vete nga Moduli 6',
            items: [
              'Telefoni im mbetet i paprekur gjatë udhëtimit',
              'Muzikën, navigimin dhe skanerin i rregulloj para nisjes',
              'E di se „në vend" llogaritet vetëm me motor të fikur',
              'Nuk mbaj kufje',
              'I njoh shenjat e mia personale të lodhjes',
              'Në lodhje ndaloj, në vend që të vazhdoj me forcë',
              'Një plan joreal e njoftoj herët dhe me ndershmëri',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M7
  SafetyChapterContent(
    id: 'm7',
    title: 'Aksidentet në punë: hipja/zbritja, ngritja dhe rrëzimet',
    summary: 'Shmang lëndimet jashtë ngasjes — theksi te hipja dhe zbritja '
        'e sigurt',
    asset: 'assets/academy/driving/m07_ein_aussteigen.svg',
    slides: [
      SafetySlide(
        title: 'Pse ky është veprimi më i rëndësishëm i ditës',
        blocks: [
          ParagraphBlock(
            'Për çdo tur hip e zbret dhjetëra herë — kjo është lëvizja që '
            'e bën më shpesh. Pikërisht prandaj këtu ndodhin shumica e '
            'lëndimeve: përdredhje kyçesh, rrëshqitje te buza e shkallës, '
            'rrëzim nga makina, hap i gabuar në trafik.',
          ),
          FactsBlock([
            FactItem('100.000', 'aksidente rrëshqitjeje, pengimi dhe '
                'rrëzimi te shoferët profesionistë në vit'),
            FactItem('24', 'ditë mungese mesatarisht për çdo rrëzim'),
            FactItem('Nr. 1', 'lloji më i shpeshtë i lëndimit në '
                'shpërndarje'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'BG Verkehr paralajmëron',
            text: 'BG Verkehr (sigurimi gjerman i aksidenteve në transport) '
                'paralajmëron shprehimisht se rëniet gjatë hipjes dhe '
                'zbritjes çojnë në lëndime të rënda, ndonjëherë vdekjeprurëse.',
          ),
          ParagraphBlock(
            'Dallimi mes një zbritjeje të sigurt dhe një të rrezikshme janë '
            'dy sekonda. Të llogaritura për 250 zbritje në ditë, kjo bëjnë '
            'mbi tetë minuta — sigurimi më i lirë i trupit tënd.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Rregulli i 3 pikave (2+1)',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Dy duar dhe një këmbë — gjithmonë',
            text: 'Rregulli qendror i BG Verkehr: dy duar dhe një këmbë '
                'janë gjithmonë në kontakt me mjetin — „2+1".',
          ),
          ParagraphBlock(
            'Ke pra në çdo çast tri pika të forta kontakti, para se ta '
            'lëshosh të radhës. Kështu një rrëshqitje e vetme nuk mund të '
            'bëhet kurrë rrëzim, sepse gjithmonë të mbajnë dy pika. Lëviz '
            'gjithmonë vetëm një pikë, kurrë dy njëkohësisht.',
          ),
          RevealBlock(
            prompt: 'Cilat tri pika kontakti nënkuptohen — dhe çfarë '
                'shprehimisht nuk hyn aty?',
            answer: 'Dora e majtë te doreza, dora e djathtë te doreza, një '
                'këmbë mbi shkallë. Nuk hyjnë aty: timoni, buza e derës, '
                'sedilja, goma dhe qendra e rrotës. Buza e derës dhe '
                'timoni lëshojnë ose rrotullohen — pikërisht atëherë kur '
                'ke nevojë për to.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Frazë për ta mbajtur mend',
            text: 'Së pari zbrit, pastaj kap. Sendet lëri së pari në mjet, '
                'pastaj zbrit me duar të lira.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Drejt brenda, drejt jashtë',
        blocks: [
          BulletsBlock([
            'Hipja: me fytyrë përpara drejt mjetit',
            'Zbritja: me shpinë nga jashtë, me fytyrë nga mjeti — si në '
                'një shkallë, kurrë duke u kthyer me shpinë nga dera',
            'Përdor të gjitha shkallët — mos e kapërce asnjë',
            'Përdor dorezat, jo buzën e derës ose timonin si kapje '
                'urgjence',
            'Gjatë zbritjes nga hapësira e ngarkesës i njëjti rregull: '
                'fytyra nga mjeti, shkallë pas shkalle',
          ]),
          StepsBlock([
            'Ndalo dhe siguro mjetin',
            'Lëri sendet në mjet',
            'Kontrollo trafikun mbi sup dhe në pasqyrë',
            'Hape derën e kontrolluar',
            'Kthehu, fytyra nga mjeti',
            'Krijo tri pika kontakti',
            'Zbrit shkallë pas shkalle',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Kurrë mos kërce',
        asset: 'assets/academy/driving/m07b_springen.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Kërcimi është gabimi më i shpeshtë',
            text: 'Kërcimi nga kabina ose nga hapësira e ngarkesës është '
                'shkaku më i shpeshtë i kyçeve të përdredhura si dhe i '
                'lëndimeve të gjurit dhe të shpinës në shpërndarje.',
          ),
          ParagraphBlock(
            'Dyshemeja e ngarkesës së një furgoni ndodhet, sipas modelit, '
            'rreth 55 deri 75 centimetra mbi rrugë. Gjatë kërcimit, në '
            'çastin e uljes, mbi kyçin e këmbës, gjurin dhe shtyllën '
            'kurrizore vepron shumëfishi i peshës sate — dhe kjo në çdo '
            'kërcim të vetëm.',
          ),
          FactsBlock([
            FactItem('55–75 cm', 'lartësia e dyshemesë së ngarkesës mbi '
                'rrugë'),
            FactItem('250+', 'zbritje për tur — secila e vetme numëron te '
                'nyjet'),
          ]),
          RevealBlock(
            prompt: 'Rast praktik: Bie shi, kërcen nga hapësira e '
                'ngarkesës mbi një trotuar të pjerrët me gjethe të lagura. '
                'Çfarë shkon keq pikërisht aty?',
            answer: 'Gjatë kërcimit nuk e korrigjon dot më uljen — je në '
                'ajër, dhe çfarë ndodh nën ty e vendos siperfaqja. Gjethet '
                'e lagura në pjerrësi nuk ofrojnë pothuajse asnjë fërkim: '
                'këmba rrëshqet gjatë uljes, nyja përdridhet anash. Kush '
                'përkundrazi zbret shkallë pas shkalle me tri pika '
                'kontakti, e ndien sipërfaqen rrëshqitëse para se të vërë '
                'mbi të gjithë peshën — dhe mund ta ndërpresë ende.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Gabimet tipike',
        blocks: [
          DoDontBlock(
            doTitle: 'Drejt',
            dos: [
              'Sendet lëri së pari në mjet',
              'Zbrit me duar të lira dhe tri pika kontakti',
              'Mbaji buzët e shkallëve dhe dorezat pastër e të lira',
              'Në lagështi dhe akull pastro më parë shkallët',
              'Merr kohën tënde — edhe te ndalesa e 180-të',
            ],
            dontTitle: 'Gabim',
            donts: [
              'Të kërcesh në vend që të zbresësh',
              'Duart plot — telefon, skaner, kafe, pako',
              'Të përdorësh gomën ose qendrën e rrotës si shkallë',
              'Vështrimi te telefoni gjatë zbritjes',
              'Të shpërfillësh buzët e lagura, të akullta ose të pista të '
                  'shkallëve',
              'Të kthehesh anash duke dalë nga sedilja',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Ndalesa pas një pauze të gjatë është më e rrezikshmja',
            text: 'Pas një ndalimi të gjatë këmbët janë të ngurta dhe '
                'përqendrimi ka ikur. Pikërisht atëherë ndodh hapi i '
                'gabuar — mblidh veten shkurt, pastaj zbrit.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ana e trafikut: çasti i nënvlerësuar',
        blocks: [
          ParagraphBlock(
            'Te Sprinterët dhe furgonët e ulët problemi shpesh nuk është '
            'lartësia, por hapi në trafikun që rrjedh. Nëse është e mundur '
            'zbrit nga ana e trotuarit ose nga ana e sigurt. Mos e hap '
            'derën gjerësisht para se të kesh shikuar.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 14 par. 1 StVO — hipja dhe zbritja',
            text: 'Kush hipën ose zbret, duhet të sillet ashtu që të '
                'përjashtohet rrezikimi i pjesëmarrësve të tjerë në '
                'trafik. Në një aksident me derë përgjegjësia i takon '
                'praktikisht gjithmonë atij që zbret.',
          ),
          RevealBlock(
            prompt: 'Ndalon në anë të rrugës, një çiklist afrohet nga pas '
                '— si zbret?',
            answer: 'Para se ta hapësh derën shiko mbi sup dhe në pasqyrë, '
                'lëre çiklistin të kalojë, hape derën vetëm e kontrolluar '
                'dhe me dorën më të largët. E ashtuquajtura „kapje '
                'holandeze" — hapja e derës me dorën e djathtë — ta kthen '
                'trupin automatikisht prapa dhe të detyron të shikosh. '
                'Çiklistët dhe skuterat kalojnë ngushtë pranë makinës dhe '
                'nuk presin një derë që hapet.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Këpucët dhe sipërfaqja',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Rekomandimi i BG Verkehr',
            text: 'Këpucë që e mbyllin këmbën dhe nuk rrëshqasin. Asnjë '
                'këpucë e hapur ose e konsumuar. Këpucët e sigurisë deri '
                'te kyçi mbështesin pikërisht atë nyje që përdridhet gjatë '
                'zbritjes.',
          ),
          ParagraphBlock(
            'Para zbritjes kushtoji vëmendje shkurt sipërfaqes: buzë '
            'trotuari, pjerrësi, gjethe, lagështi, akull, zhavorr. Mbaji '
            'dorezat dhe shkallët të lira në borë dhe akull. Nëse është e '
            'mundur ndalo në vend të rrafshët dhe të ndriçuar.',
          ),
          ChecklistBlock(
            title: 'Para zbritjes',
            items: [
              'Këpucë të forta, jorrëshqitëse të veshura',
              'Sipërfaqja e kontrolluar — buzë trotuari, pjerrësi, '
                  'lagështi, akull',
              'Duart e lira, sendet të lëna mënjanë',
              'Trafiku i kontrolluar mbi sup dhe në pasqyrë',
              'Shkallët pastër dhe të lira',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Ngri dhe bart drejt',
        blocks: [
          ParagraphBlock(
            'Shpina është rreziku i dytë më i shpeshtë i mungesës pas '
            'rrëzimeve. Dhe ndryshe nga një rrëzim, dëmtimi i diskut nuk '
            'ndodh në një ditë — ai lind nga mijëra ngritje të gabuara.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/lift01_nah.svg',
              title: '1 · Ngarkesa afër trupit',
              caption: 'Afrohu ngushtë te pakoja para se ta ngresh. Çdo '
                  'centimetër distancë nga trupi e shumëfishon ngarkesën '
                  'mbi disqet e shtyllës kurrizore.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift02_hocke.svg',
              title: '2 · Ulu në gjunjë',
              caption: 'Përkul gjunjët dhe ulu, në vend që të palosesh '
                  'përpara nga ijet. Forca vjen nga këmbët — ato janë '
                  'muskuli më i fortë që ke.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift03_ruecken.svg',
              title: '3 · Mbaje shpinën drejt',
              caption: 'Mbaje shpinën drejt dhe shikimin përpara, ndërsa '
                  'ngrihesh me këmbët. Një shpinë e rrumbullakosur nën '
                  'ngarkesë është pozicioni klasik i dëmtimit të diskut.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift04_drehen.svg',
              title: '4 · Mos u përdridh — lëviz këmbët',
              caption: 'Kurrë mos u përdridh me ngarkesën në trup. Në vend '
                  'të kësaj zhvendos këmbët dhe ktheje tërë trupin. '
                  'Ngritja plus përdredhja është kombinimi më i rrezikshëm '
                  'për shtyllën kurrizore.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Sa i rëndë është shumë i rëndë?',
        blocks: [
          ParagraphBlock(
            'Kufij të fiksuar në kilogramë nuk ka në ligj — vendimtare '
            'janë pesha, qëndrimi, shpeshtësia dhe mjedisi së bashku. Në '
            'praktikë janë vërtetuar megjithatë vlera orientuese.',
          ),
          FactsBlock([
            FactItem('rreth 25 kg', 'orientim për ngritje të rastësishme '
                '(burra)'),
            FactItem('rreth 15 kg', 'orientim për ngritje të rastësishme '
                '(gra)'),
            FactItem('mbi këtë', 'përdor mjete ndihmëse ose bartni në dy '
                'veta'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'LasthandhabV (rregullorja për ngritjen e ngarkesave)',
            text: 'Punëdhënësi duhet ta shmangë sa më shumë të jetë e '
                'mundur ngritjen dhe bartjen manuale dhe të vërë në '
                'dispozicion mjete ndihmëse të përshtatshme. Ti pastaj '
                'duhet edhe t\'i përdorësh këto mjete — ato nuk qëndrojnë '
                'aty për zbukurim.',
          ),
          DoDontBlock(
            doTitle: 'Bartje e drejtë',
            dos: [
              'Përdor karrocën ose kutinë me rrota, në vend që të ecësh '
                  'dy herë',
              'Dërgesat e mëdha bartni në dy veta',
              'Mbaje fushëpamjen të lirë — mos shiko përtej stivës',
              'Para ngritjes përcakto rrugën dhe vendin e lëshimit',
            ],
            dontTitle: 'Bartje e gabuar',
            donts: [
              'Shpinë e rrumbullakosur, krahë të shtrirë',
              'Të përdridhesh me ngarkesë në trup',
              'Të marrësh vrull dhe të ngresh me shkulje',
              'Të bartësh kulla që ta marrin pamjen e rrugës',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Pengimi, rrëshqitja, rrëzimi rrugës',
        blocks: [
          ParagraphBlock(
            'Pengimi, rrëshqitja dhe rrëzimi është shkaku më i shpeshtë i '
            'lëndimeve në shpërndarje — më i shpeshtë se çdo aksident '
            'trafiku. Dhe pothuajse gjithmonë ndodh në metrat e fundit mes '
            'mjetit dhe derës së shtëpisë.',
          ),
          FactsBlock([
            FactItem('Nr. 1', 'lloji më i shpeshtë i aksidentit në '
                'shpërndarje'),
            FactItem('30 m e fundit', 'mes mjetit dhe derës — pjesa më e '
                'rrezikshme'),
          ]),
          BulletsBlock([
            'Vish këpucë të forta, jorrëshqitëse — çdo ditë, edhe në '
                'verë',
            'Në ngricë bëj hapa të vegjël dhe vendos tërë shputën',
            'Hidhe shikimin edhe te rruga, jo vetëm te pakoja ose te '
                'telefoni',
            'Natën përdor elektrik dore ose dritën e telefonit për rrugën',
            'Mba mend vendet e njohura të pengimit në itinerar',
          ]),
          RevealBlock(
            prompt: 'Rast praktik: Bart dy pako njëra mbi tjetrën drejt '
                'një dere shtëpie me tri shkallë. Cili është këtu problemi '
                'i vërtetë?',
            answer: 'Nuk i sheh as këmbët e tua as buzët e shkallëve. Një '
                'ngjitje shkallësh pa pamje te shkalla është situata '
                'klasike e rrëzimit — dhe me duar plot nuk mund as të '
                'mbahesh te parmakët as ta ndalosh rrëzimin. E saktë: '
                'barti veç e veç, mbaje stivën aq të ulët sa t\'i shohësh '
                'shkallët, ose përdor karrocën. Të ecësh dy herë zgjat 40 '
                'sekonda.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Merri seriozisht lëndimet e vogla',
        blocks: [
          ParagraphBlock(
            'Një shpinë e dëmtuar nga ngritja ose një këmbë e përdredhur '
            'keqësohet nëse vazhdon. Nga një gjë e vogël bëhet për javë '
            'një mungesë e vërtetë — dhe më vonë lidhja me punën shpesh '
            'nuk provohet dot.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Dokumentimi të mbron',
            text: 'Çdo lëndim shkon në librin e ndihmës së parë — edhe ai '
                'i vogli. Në rast trajtimi mjekësor pas një aksidenti në '
                'punë shkon te mjeku i autorizuar (Durchgangsarzt). Pa '
                'dokumentim njohja e mëvonshme si aksident në punë është '
                'e vështirë.',
          ),
          RevealBlock(
            prompt: 'Pse duhet t\'i njoftosh menjëherë ankesat e vogla — '
                'edhe nëse mund të vazhdosh punën?',
            answer: 'Së pari mjekësisht: një problem i patrajtuar i '
                'ligamenteve shërohet më keq dhe kthehet. Së dyti '
                'ligjërisht: vetëm ajo që dokumentohet vlen më vonë si '
                'aksident në punë. Së treti për të gjithë: vetëm rastet e '
                'njoftuara tregojnë ku në firmë duhet përmirësuar një '
                'shkallë, një dorezë ose një procedurë. Njoftimi është '
                'forcë, jo dobësi.',
          ),
          ChecklistBlock(
            title: 'Këtë marr me vete nga Moduli 7',
            items: [
              'Zbres me shpinë nga jashtë, me fytyrë nga mjeti',
              'Mbaj gjithmonë tri pika kontakti (2 duar + 1 këmbë)',
              'Kurrë nuk kërcej nga kabina ose hapësira e ngarkesës',
              'I lë sendet mënjanë para se të zbres',
              'Para hapjes së derës shikoj mbi sup',
              'Ngre me këmbët dhe nuk përdridhem me ngarkesë',
              'Përdor mjete ndihmëse në vend të akteve heroike',
              'Njoftoj çdo lëndim, edhe atë të voglin',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M8
  SafetyChapterContent(
    id: 'm8',
    title: 'Te dera: qentë, njerëzit dhe mjedisi',
    summary: 'Vepro i sigurt te pika e dorëzimit — me kafshët, njerëzit dhe '
        'mjedisin',
    asset: 'assets/academy/driving/m08_haustuer.svg',
    slides: [
      SafetySlide(
        title: 'Pika e dorëzimit: terren i huaj',
        blocks: [
          ParagraphBlock(
            'Sapo del nga mjeti, hyn në një terren të huaj që nuk e njeh '
            'dhe që askush nuk e ka siguruar për ty: rrugë të panjohura, '
            'pllaka të liruara, shkallë të errëta, kafshë dhe njerëz në çdo '
            'humor.',
          ),
          FactsBlock([
            FactItem('120+', 'prona të huaja për tur'),
            FactItem('30 m', 'rrugë në këmbë mesatarisht për ndalesë'),
            FactItem('0', 'prej tyre janë përgatitur për ty'),
          ]),
          ParagraphBlock(
            'Prandaj te pika e dorëzimit vlen i njëjti qëndrim bazë si në '
            'timon: së pari shiko, pastaj vepro. Dhe në dyshim: mos e '
            'dorëzo. Një dërgesë që nuk arrin është një procedurë — një '
            'lëndim është një mungesë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Vlerëso drejt qentë',
        asset: 'assets/academy/driving/m08b_hund.svg',
        blocks: [
          ParagraphBlock(
            'Qentë bëjnë pjesë te shkaqet më të shpeshta të lëndimeve te '
            'shpërndarësit. Nga këndvështrimi i qenit ti je një ndërhyrës '
            'që lëviz shpejt, ka erë të huaj dhe mban një objekt të madh — '
            'reagimi është mbrojtje, jo ligësi.',
          ),
          BulletsBlock([
            'Mos e shiko drejt në sy — kjo për qenin është kërcënim',
            'Mos ik me vrap dhe mos bërtit, por qëndro i qetë',
            'Kthejani qenit anën, jo pjesën e përparme',
            'Krahët qetë pranë trupit, asnjë lëvizje e nxituar',
            'Pakoja mund të vihet si pengesë mes teje dhe qenit',
            'Ec ngadalë prapa, duke e mbajtur qenin në shikim',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Qetësia është pajisja jote më e mirë',
            text: 'Një qen reagon ndaj lëvizjes dhe tonit të zërit, jo '
                'ndaj argumenteve. Ngadalë, qetë dhe anash — kjo është '
                'tërë teknika.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kur bëhet serioze',
        blocks: [
          RevealBlock(
            prompt: 'Rast praktik: Te porta e kopshtit rri një qen i madh '
                'dhe leh. Porta është vetëm e mbyllur lehtë, klienti ka '
                'shkruar „qeni është i mirë" te udhëzimet e dorëzimit. '
                'Çfarë bën?',
            answer: 'Nuk hyn në pronë. Një udhëzim dorëzimi nuk është '
                'leje sigurie — klienti e njeh qenin e vet në kontakt me '
                'familjen, jo në kontakt me një burrë të huaj me pako. E '
                'saktë: tërhiqu nga porta, provo të biesh ziles ose të '
                'telefonosh, mos e dorëzo dërgesën duke e dokumentuar dhe '
                'shëno udhëzimin në sistem, që kolegu i radhës të jetë i '
                'paralajmëruar. Një kafshim të kushton javë — dërgesa i '
                'kushton klientit një ditë.',
          ),
          DoDontBlock(
            doTitle: 'Drejt',
            dos: [
              'Para hapjes së portës kushtoji vëmendje zhurmave të qenve '
                  'dhe enëve të ushqimit',
              'Me qen të lirë mos hyr fare',
              'Shëno udhëzime për kolegët në sistem',
              'Në rast kafshimi ose gërvishtjeje: njofto menjëherë dhe '
                  'trajtohu te mjeku',
            ],
            dontTitle: 'Gabim',
            donts: [
              'Ta përkëdhelësh ose ta ushqesh qenin',
              'Të kalosh përtej kafshës drejt derës',
              'Të ikësh me vrap ose ta godasësh qenin me pako',
              'Të mbështetesh te „ai nuk bën gjë"',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Çdo kafshim qeni shkon te mjeku',
            text: 'Edhe një kafshim ose gërvishtje e vogël mund të '
                'infektohet. Pastro menjëherë, trajtohu te mjeku, shëno në '
                'librin e ndihmës së parë dhe njofto — pavarësisht se sa e '
                'padëmshme duket.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Rrugë të sigurta në pronë',
        asset: 'assets/academy/driving/m08c_stolperfallen.svg',
        blocks: [
          ParagraphBlock(
            'Rruga deri te dera nuk është vend pune që dikush e ka '
            'kontrolluar për ty. Përdor rrugët e caktuara dhe mos shkurto '
            'nëpër barishte të lagura, pllaka të liruara ose pjerrësira të '
            'thepisura.',
          ),
          BulletsBlock([
            'Zorrë kopshti, kabllo dhe skela bimësh në tokë',
            'Pllaka trotuari të liruara ose të fundosura',
            'Gjethe të lagura, myshk dhe alga në rrugë me hije',
            'Zhavorr dhe rërë mbi pllaka të lëmuara',
            'Shkallë të pandriçuara pa parmak',
            'Puse bodrumi, gropa të hapura dhe dritare bodrumi',
            'Lodra, biçikleta dhe kontejnerë mbeturinash në rrugë',
          ]),
          FactsBlock([
            FactItem('30 m e fundit', 'këtu ndodhin shumica e rrëzimeve'),
            FactItem('1 dorë', 'duhet të mbetet e lirë për parmakun'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Shkurtimi kushton më shumë se sa kursen',
            text: 'Rruga nëpër barishte kursen dhjetë sekonda. Një rrëzim '
                'mbi të kushton mesatarisht 24 ditë mungese.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Shkallët, bodrumet dhe errësira',
        blocks: [
          ParagraphBlock(
            'Në shkallëza dhe oborre të brendshme bashkohen dy gjëra: '
            'drita e keqe dhe lartësi të panjohura shkallësh. Të dyja së '
            'bashku janë situata më e shpeshtë e rrëzimit jashtë mjetit.',
          ),
          BulletsBlock([
            'Mbaje gjithmonë një dorë të lirë për parmakun',
            'Ndiz dritën, në vend të „shkon edhe kështu"',
            'Përdor elektrikun e dorës ose dritën e telefonit — por duke '
                'ecur mos shiko te ekrani',
            'Te shkallët mbaje stivën aq të ulët sa t\'i shohësh shkallët',
            'Kujdes ndaj lartësive të ndryshme të shkallëve në ndërtesat e '
                'vjetra',
          ]),
          RevealBlock(
            prompt: 'Duhet të dorëzosh në një korridor të errët bodrumi. '
                'Çelësi i dritës nuk punon. Cili është vendimi i drejtë?',
            answer: 'Mos hyr brenda. Një korridor i pandriçuar me shkallë '
                'të panjohura, puse bodrumi dhe sende të lëna nuk është '
                'vend ku hyn me një pako në dorë — dhe në dyshim askush '
                'nuk e di se ti je aty. E saktë: bjeri ziles klientit, '
                'dorëzoje në një vend të sigurt ose mos e dorëzo dërgesën '
                'duke e dokumentuar. Drita e telefonit nuk e zëvendëson '
                'ndriçimin, sepse për të të duhet një dorë që të nevojitet '
                'te parmaku.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Njerëzit: qetëso, mos fito',
        blocks: [
          ParagraphBlock(
            'Për klientin ti je fytyra e një koncerni të tërë — dhe '
            'prandaj ndonjëherë të bie mbi kokë një nervozizëm që nuk të '
            'takon. Të mbetesh i sjellshëm, i qetë dhe profesional nuk '
            'është vetëm mirësjellje, është masa jote më efektive e '
            'sigurisë.',
          ),
          StepsBlock([
            'Zë i qetë, ritëm i ngadaltë i të folurit, qëndrim i hapur i '
                'trupit',
            'Dëgjo dhe emërto shqetësimin, në vend që të kundërshtosh '
                'menjëherë',
            'Rri te ajo që mund të bësh — asnjë premtim për të tjerët',
            'Mbaj distancë: së paku një gjatësi krahu, rruga e daljes e '
                'lirë',
            'Nëse përshkallëzohet: mbylle bisedën dhe kthehu te mjeti',
          ]),
          RevealBlock(
            prompt: 'Dikush bërtet, të afrohet shumë dhe ta zë rrugën '
                'drejt mjetit tënd. Çfarë vlen?',
            answer: 'Siguria jote vjen para çdo dorëzimi. Mos diskuto, mos '
                'kërko të kesh të drejtë, mos provoko kontakt fizik. '
                'Tërhiqu, krijo distancë, kërko qartë dhe me zë të lartë '
                'distancë, në rast urgjence dil në vend publik dhe thirr '
                'policinë. Pastaj: njofto rastin, që ndalesa të shënohet '
                'për kolegët. Asnjë pako nuk e justifikon një përleshje '
                'fizike.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Makina si vend i sigurt',
        blocks: [
          ParagraphBlock(
            'Mjeti yt është vegël, depo dhe vend tërheqjeje. Kur e lë, ai '
            'duhet të qëndrojë i sigurt — dhe kur ndihesh i kërcënuar, ai '
            'është vendi ku kthehesh.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 14 par. 2 StVO',
            text: 'Kush e lë mjetin e vet, duhet të marrë masat e '
                'nevojshme për të shmangur aksidentet dhe pengesat në '
                'trafik dhe ta sigurojë atë kundër përdorimit të '
                'paautorizuar.',
          ),
          DoDontBlock(
            doTitle: 'I ndalur drejt',
            dos: [
              'Motori fikur, çelësi merret, mjeti mbyllet',
              'Në pjerrësi tërhiq fort frenin e dorës dhe ktheji rrotat',
              'Dritat e rrezikut kur ndalon në hapësirën e trafikut',
              'Mbylle derën e hapësirës së ngarkesës, kur je jashtë '
                  'pamjes',
            ],
            dontTitle: 'Rrezik',
            donts: [
              'Motori punon, dera hapur — „shkon më shpejt kështu"',
              'Çelësi i futur, ndërsa ti je te dera',
              'Të parkosh në pjerrësi pa i kthyer rrotat',
              'Ta lësh hapësirën e ngarkesës hapur në zona të gjalla',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Listë kontrolli te pika e dorëzimit',
        blocks: [
          ChecklistBlock(
            title: 'Te çdo ndalesë',
            items: [
              'Motori fikur, çelësi me vete, mjeti i mbyllur',
              'I siguruar në pjerrësi, rrotat të kthyera',
              'Para hyrjes i kushtova vëmendje qenve dhe udhëzimeve',
              'Përdora rrugët e caktuara, nuk shkurtova',
              'Një dorë e lirë për parmakun',
              'Stiva aq e ulët sa t\'i shoh shkallët',
              'Në errësirë u kujdesa për dritë',
              'Në agresion: distancë, tërheqje, njoftim',
              'Në kafshim, rrëzim ose situatë për pak aksident: '
                  'njoftova',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M9
  SafetyChapterContent(
    id: 'm9',
    title: 'Urgjenca dhe sjellja pas një aksidenti',
    summary: 'Vepro me qetësi, drejt dhe i sigurt ligjërisht në rast '
        'serioz',
    asset: 'assets/academy/driving/m09_notfall.svg',
    slides: [
      SafetySlide(
        title: 'Siguro — Njofto — Ndihmo',
        blocks: [
          ParagraphBlock(
            'Pas një aksidenti ose në rast defekti vlen gjithmonë e njëjta '
            'radhë: së pari bëje vendin të sigurt, pastaj thirrja e '
            'urgjencës, pastaj ndihma e parë. Kjo radhë nuk është '
            'formalizëm — ajo parandalon aksidentin e dytë, në të cilin '
            'ndihmuesit bëhen vetë viktima.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Mba mend radhën',
            text: 'Siguro → Njofto → Ndihmo. Kush vrapon menjëherë te i '
                'lënduari pa siguruar vendin, shtypet vetë në një rrugë '
                'ndërqytetëse ose në autostradë.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 34 StVO — pas një aksidenti trafiku',
            text: 'Duhet të ndalosh menjëherë, të sigurosh trafikun, në '
                'rast dëmi të vogël të largohesh nga zona e rrezikut, t\'u '
                'ndihmosh të lënduarve dhe të mundësosh identifikimin e '
                'personit tënd dhe të mjetit tënd.',
          ),
          ParagraphBlock(
            'Dhe krejt e rëndësishme: qetësia. Dhjetë sekondat e para pas '
            'një përplasjeje i vendosin dhjetë minutat e ardhshme. Merr '
            'frymë njëherë thellë, pastaj sipas radhës.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pesë hapat e parë',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/acc01_absichern.svg',
              title: '1 · Ndiz dritat e rrezikut',
              caption: 'Menjëherë pas ndalimit ndiz dritat e rrezikut — '
                  'ato janë sinjali i parë për të gjithë ata që vijnë nga '
                  'pas. Në errësirë lëri ndezur edhe dritat e pozicionit.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc02_warnweste.svg',
              title: '2 · Vish jelekun sinjalizues',
              caption: 'Jelekun e vesh para se të zbresësh — jo pas '
                  'kësaj. Prandaj ai qëndron afër dore në kabinë dhe jo '
                  'prapa në hapësirën e ngarkesës.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc03_dreieck.svg',
              title: '3 · Vendos trekëndëshin',
              caption: 'Ec pas mbrojtëses së rrugës ose në buzë të saj në '
                  'drejtim të kundërt të lëvizjes dhe vendose '
                  'trekëndëshin në distancë të mjaftueshme — brenda '
                  'qytetit rreth 50 m, jashtë qytetit 100 m, në '
                  'autostradë 150–200 m.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc04_notruf.svg',
              title: '4 · Bëj thirrjen e urgjencës 112',
              caption: 'Thuaj ku je, çfarë ka ndodhur, sa të lënduar ka '
                  'dhe çfarë lëndimesh sheh — dhe mbylle telefonin vetëm '
                  'kur qendra të mos ketë më pyetje.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc05_erstehilfe.svg',
              title: '5 · Jep ndihmën e parë',
              caption: 'Foli, kontrollo frymëmarrjen, ndal gjakderdhjet, '
                  'ngrohe dhe rri pranë të lënduarit. Edhe masat e thjeshta '
                  'ndihmojnë — të mos bësh asgjë është vendimi i vetëm i '
                  'gabuar.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Dritat e rrezikut, jeleku, trekëndëshi',
        blocks: [
          TableBlock(
            headers: ['Zona', 'Distanca e trekëndëshit'],
            rows: [
              ['Brenda qytetit', 'rreth 50 m'],
              ['Jashtë qytetit', 'rreth 100 m'],
              ['Autostradë', 'rreth 150–200 m'],
              ['Para një kodrine ose kthese', 'para saj, jo pas saj'],
            ],
          ),
          ParagraphBlock(
            'Vendimtare nuk është vlera e saktë në metra, por që trafiku '
            'që vjen pas të të shohë me kohë. Para një kodrine ose kthese '
            'trekëndëshi shkon para saj — përndryshe bëhet i dukshëm '
            'vetëm kur është vonë.',
          ),
          FactsBlock([
            FactItem('1', 'jelek sinjalizues është detyrim në mjet '
                '(§ 53a StVZO)'),
            FactItem('më parë', 'vish jelekun para se të zbresësh'),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Ec pas mbrojtëses së rrugës',
            text: 'Në autostradë dhe rrugë ndërqytetëse kurrë mos ec në '
                'karrexhatë për të vendosur trekëndëshin, por pas '
                'mbrojtëses ose në bankinë — në drejtim të kundërt të '
                'lëvizjes, që ta shohësh trafikun.',
          ),
          DoDontBlock(
            doTitle: 'Drejt te vendi i aksidentit',
            dos: [
              'Dritat e rrezikut menjëherë, jeleku para zbritjes',
              'Ec pas mbrojtëses në drejtim të kundërt të lëvizjes',
              'Vendos trekëndëshin para kodrinës ose kthesës',
              'Pas sigurimit shko vetë në vend të sigurt',
            ],
            dontTitle: 'Gabimet tipike',
            donts: [
              'Të zbresësh pa jelek dhe të shikosh „vetëm shkurt"',
              'Të ecësh në karrexhatë drejt trekëndëshit',
              'Të qëndrosh mes mjeteve',
              'Së pari të bësh foto, në vend që të sigurosh vendin',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Korridori i shpëtimit',
        blocks: [
          ParagraphBlock(
            'Korridori i shpëtimit formohet sapo trafiku ngadalësohet — '
            'jo vetëm kur duket drita blu. Atëherë zakonisht është vonë, '
            'sepse askush nuk ka më vend.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 11 par. 2 StVO',
            text: 'Në autostrada dhe rrugë jashtë qytetit me së paku dy '
                'korsi për drejtim, korridori formohet gjithmonë mes '
                'korsisë krejt të majtë dhe asaj menjëherë djathtas saj — '
                'pavarësisht se sa korsi ka.',
          ),
          FactsBlock([
            FactItem('majtas + 1', 'kështu formohet korridori'),
            FactItem('nga 200 €', 'gjobë, kur nuk formohet korridori'),
            FactItem('2 pikë', 'plus si rregull 1 muaj ndalim drejtimi'),
          ]),
          RevealBlock(
            prompt: 'Në një autostradë me tri korsi trafiku ka ndalur. Ku '
                'saktësisht është korridori i shpëtimit — dhe a lejohet të '
                'ngasësh në të, nëse do të dalësh te dalja?',
            answer: 'Gjithmonë mes korsisë së majtë dhe asaj të mesme — '
                'kurrë mes së mesmes dhe së djathtës dhe kurrë në korsinë '
                'e emergjencës. Dhe jo: korridori i shpëtimit është '
                'vetëm për mjetet e urgjencës. Kush e përdor për të '
                'arritur më shpejt te dalja, paguan një gjobë po aq të '
                'lartë sa ai që nuk formon fare korridor, dhe rrezikon '
                'ndalimin e drejtimit. Korsia e emergjencës nuk është '
                'alternativë — atje lëvizin forcat e shpëtimit, kur '
                'korridori është i bllokuar.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Bëj drejt thirrjen e urgjencës 112',
        blocks: [
          FactsBlock([
            FactItem('112', 'urgjenca në tërë Evropën, edhe pa kredit'),
            FactItem('110', 'policia — te dëmi vetëm material'),
          ]),
          StepsBlock([
            'Ku ka ndodhur? — vendi, rruga, kilometri, drejtimi i '
                'lëvizjes, pika dalluese',
            'Çfarë ka ndodhur? — lloji i aksidentit, mjetet e '
                'përfshira, rreziqet si karburanti që rrjedh',
            'Sa të lënduar ka?',
            'Çfarë lëndimesh? — pa ndjenja, me gjakderdhje, i bllokuar',
            'Prit pyetjet e mëtejshme — bisedën e mbyll qendra',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Dhënia e ndihmës është detyrim',
            text: 'Mosdhënia e ndihmës është vepër penale (§ 323c StGB). '
                'Pritet ajo që është e arsyeshme për ty — të bësh '
                'thirrjen e urgjencës, të sigurosh vendin, të flasësh, të '
                'kujdesesh. Askush nuk kërkon që ta vësh veten në '
                'rrezik.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ndihma e parë: gjërat që kanë rëndësi',
        blocks: [
          ParagraphBlock(
            'Nuk duhet të jesh mjek urgjence. Masat vendimtare i bën '
            'secili — dhe janë pikërisht ato që vendosin mes jetës dhe '
            'vdekjes, para se të vijë shërbimi i shpëtimit.',
          ),
          StepsBlock([
            'Foli dhe shkunde me kujdes te supi — a reagon personi?',
            'Asnjë reagim: liro rrugët e frymëmarrjes, kthe kokën prapa, '
                'kontrollo frymëmarrjen 10 sekonda',
            'Frymëmarrja normale: pozicion i qëndrueshëm anash, mbulo, '
                'rri pranë',
            'Pa frymëmarrje normale: fillo menjëherë masazhin e zemrës '
                'dhe mos u ndal',
            'Gjakderdhje e fortë: mbuloje drejtpërdrejt me presion, vër '
                'fashë shtrënguese',
          ]),
          FactsBlock([
            FactItem('100–120', 'shtypje masazhi për minutë'),
            FactItem('5–6 cm', 'thellësia e shtypjes te i rrituri'),
            FactItem('10 s', 'mjaftojnë për kontrollin e frymëmarrjes'),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Helmeta dhe personat e bllokuar',
            text: 'Një helmetë motoçiklete e heq vetëm nëse personi nuk '
                'merr frymë normalisht — atëherë nuk ka rrugë tjetër. '
                'Personat e bllokuar nuk i lëviz, përveç kur kërcënon '
                'rrezik i drejtpërdrejtë nga zjarri.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pas një dëmi llamarine',
        blocks: [
          ParagraphBlock(
            'Edhe te dëmet e vogla — gërvishtje manovrimi, pasqyrë e '
            'shkulur, gërvishtje te një makinë e parkuar — vlen programi i '
            'plotë. Dëmi njoftohet gjithmonë, edhe kur duket i vogël dhe '
            'askush nuk ka parë.',
          ),
          ChecklistBlock(
            title: 'Pas një dëmi llamarine',
            items: [
              'Ndalo dhe siguro mjetin',
              'Dritat e rrezikut, sipas nevojës jeleku dhe trekëndëshi',
              'Shkëmbe të dhënat përkatësisht prit pronarin',
              'Foto nga disa kënde, vendi, koha, targa',
              'Shëno dëshmitarët dhe të dhënat e tyre të kontaktit',
              'Mos nënshkruaj asnjë pranim faji',
              'Njofto dëmin në firmë — ende po atë ditë',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Kurrë mos vazhdo thjesht rrugën',
            text: 'Kush largohet nga vendi i aksidentit pa mundësuar '
                'identifikimin e personit të vet, kryen largim të '
                'palejuar nga vendi i aksidentit (§ 142 StGB) — vepër '
                'penale me dënim me para ose me burg, edhe te një '
                'gërvishtje e vogël.',
          ),
          RevealBlock(
            prompt: 'Rast praktik: Gjatë manovrimit gërvisht pasqyrën e '
                'jashtme të një makine të parkuar. Askush nuk është aty. A '
                'mjafton një letër nën fshirësin e xhamit?',
            answer: 'Jo. Një letër ligjërisht nuk vlen si identifikim i '
                'mjaftueshëm — ajo mund të fluturojë, të lagët ose të '
                'hiqet. E saktë është: të presësh një kohë të arsyeshme te '
                'vendi i aksidentit (sipas situatës merren rreth 30 minuta '
                'si vlerë orientuese), dhe nëse nuk vjen askush, të '
                'informosh policinë dhe ta njoftosh dëmin atje. Një letër '
                'shtesë është praktikë e mirë, por nuk e zëvendëson as '
                'pritjen as njoftimin.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ruaj qetësinë, njofto, mëso',
        blocks: [
          ParagraphBlock(
            'Merr frymë thellë, rregullo situatën, informo dispeçerin dhe '
            'firmën. Një njoftim i ndershëm dhe i shpejtë është gjithmonë '
            'më i mirë se fshehja — ai të mbron ty, mbron firmën, dhe nga '
            'çdo rast mësojmë për turin e ardhshëm.',
          ),
          ChecklistBlock(
            title: 'Këtë marr me vete nga Moduli 9',
            items: [
              'E njoh radhën: siguro, njofto, ndihmo',
              'E vesh jelekun sinjalizues para se të zbres',
              'E vendos trekëndëshin në distancë të mjaftueshme',
              'E formoj korridorin e shpëtimit mes së majtës dhe korsisë '
                  'pranë saj, sapo trafiku ngadalësohet',
              'I njoh pesë të dhënat te thirrja e urgjencës 112',
              'E di se të mos bësh asgjë është vendimi i vetëm i '
                  'gabuar',
              'Njoftoj çdo dëm po atë ditë — edhe gërvishtjen e vogël',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M10
  SafetyChapterContent(
    id: 'm10',
    title: 'Përmbledhje dhe vetëzotim',
    summary: 'Ngulit atë që ke mësuar dhe shndërroje në një qëndrim '
        'personal',
    asset: 'assets/academy/driving/m10_selbstverpflichtung.svg',
    slides: [
      SafetySlide(
        title: '7 rregullat e tua bazë',
        blocks: [
          BulletsBlock([
            'Të mendosh përpara ia kalon reagimit të shpejtë',
            'Distanca dhe shpejtësia e përshtatur të japin gjithmonë një '
                'rezervë',
            'Gjatë lëvizjes prapa: zbrit, shiko, ngadalë (GOAL)',
            'Telefoni dhe shpërqendrimi vetëm në vend me motor të '
                'fikur',
            'Merri seriozisht lodhjen dhe presionin e kohës — siguria '
                'para planit',
            'Zbrit, ngri dhe ec drejt — trupi yt është vegla jote',
            'Në urgjencë: siguro, njofto, ndihmo',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Nëse merr me vete vetëm një rregull',
            text: 'Merre kohën që të duhet. Pothuajse çdo aksident në '
                'shpërndarje lind në çastin kur dikush deshi të kursente '
                'dy sekonda.',
          ),
          DoDontBlock(
            doTitle: 'Kështu duket një ditë e sigurt',
            dos: [
              'Rrotullimi rreth mjetit, ngarkesa e siguruar, rripi '
                  'vendosur',
              'Dy sekonda distancë, shikimi larg përpara',
              'Para çdo manovre prapa zbrit dhe shiko',
              'Telefoni në mbajtëse, pushim në lodhje',
              'Zbritje me shpinë nga jashtë me tri pika kontakti',
            ],
            dontTitle: 'Pesë shkurtoret më të shtrenjta',
            donts: [
              'Ta lësh rrotullimin „vetëm sot"',
              'Të mos e sigurosh sërish ngarkesën pas ringarkimit',
              'Të shikosh shkurt te ekrani, sepse rruga është e lirë',
              'Të kërcesh nga hapësira e ngarkesës, sepse shkon më '
                  'shpejt',
              'Të mos njoftosh një dëm manovrimi',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Numrat që duhet të mbeten në kokë',
        blocks: [
          FactsBlock([
            FactItem('2 s', 'distanca minimale'),
            FactItem('2 + 1', 'pika kontakti gjatë zbritjes'),
            FactItem('112', 'urgjenca kur ka të lënduar'),
          ]),
          TableBlock(
            headers: ['Numri', 'Kuptimi'],
            rows: [
              ['2 sekonda', 'distanca minimale, në lagështi 3+'],
              ['18 / 40 m', 'rruga e ndalimit me 30 / 50 km/h'],
              ['28 m', 'ngasje verbërisht me 2 s vështrim në telefon dhe '
                  'shpejtësi 50'],
              ['89 m', 'gjumë çasti prej 4 s me shpejtësi 80'],
              ['0,8 g', 'forca e sigurimit përpara për ngarkesën'],
              ['2 + 1', 'pika kontakti gjatë hipjes dhe zbritjes'],
              ['70 %', 'e dëmeve lindin gjatë manovrimit'],
              ['112', 'urgjenca kur ka të lënduar'],
            ],
          ),
          ParagraphBlock(
            'Këta tetë numra janë bërthama e fortë e trajnimit. Kush i ka '
            'në kokë, merr vendimin e drejtë edhe atëherë kur nuk ka kohë '
            'për të menduar.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Vetëkontrolli yt personal',
        asset: 'assets/academy/driving/m10b_selbstcheck.svg',
        blocks: [
          ParagraphBlock(
            'Kaloje njëherë këtë listë me ndershmëri — jo për firmën, por '
            'për vete. Çdo shenjë e pavendosur është një gjë konkrete që '
            'mund ta ndryshosh nesër.',
          ),
          ChecklistBlock(
            title: 'Vetëkontrolli im i sigurisë',
            items: [
              'E bëj rrotullimin çdo mëngjes, edhe kur nxitoj',
              'E siguroj sërish ngarkesën, kur hapësira e ngarkesës '
                  'zbrazet',
              'Mbaj dy sekonda distancë dhe e kontrolloj te një pikë '
                  'fikse',
              'Para çdo manovre prapa zbres dhe shikoj',
              'Telefonin nuk e prek gjatë udhëtimit',
              'Ndaloj, kur bëhem i lodhur',
              'Zbres gjithmonë me shpinë nga jashtë me tri pika '
                  'kontakti',
              'Ngre me këmbët dhe përdor mjete ndihmëse',
              'Njoftoj dëmet, situatat për pak aksident dhe lëndimet',
              'Njoftoj, kur një plan nuk është i realizueshëm në mënyrë '
                  'të sigurt',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Rast praktik: dita kur gjithçka bashkohet',
        blocks: [
          RevealBlock(
            prompt: 'Rast praktik: E premte, shi, 190 ndalesa. Nisesh 25 '
                'minuta me vonesë, hapësira e ngarkesës është e '
                'parregulluar nga ndërrimi i natës, telefoni të bie '
                'vazhdimisht, dhe në orën 16 vëren se nuk ke ngrënë asgjë '
                'që nga mëngjesi. Cila është tani radha e drejtë?',
            answer: 'Ndalo dhe rregullo së pari hapësirën e ngarkesës — '
                'këtë e kthen brenda një çerek ore dhe i kursen vetes 190 '
                'kërkime. Pastaj: telefoni pa zë, në mbajtëse, telefonatat '
                'në pushimin e radhës. Pastaj dhjetë minuta ushqim dhe '
                'pije, sepse që nga tani vëmendja jote përndryshe bie çdo '
                'orë. Dhe pastaj një njoftim i ndershëm te dispozicioni se '
                'plani sot nuk del i plotë. Çfarë nuk bën: të duash ta '
                'nxjerrësh kohën në rrugë, të heqësh pushimet, të '
                'shkurtosh manovrat. Dita nuk shpëtohet më — shpina jote, '
                'patenta jote dhe mjeti yt po.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Provimi i vërtetë',
            text: 'Të ngasë i sigurt mundet secili në një ditë të mirë. '
                'Dallimi tregohet në ditën kur gjithçka shkon keq '
                'njëkohësisht.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Vetëzotimi yt',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Premtimi yt',
            text: '„Ngas ashtu që të gjithë të kthehen të sigurt në '
                'shtëpi — edhe unë."',
          ),
          ParagraphBlock(
            'Siguria nuk është libër rregullash, por vendimi yt i '
            'përditshëm. Askush nuk rri pranë teje kur në orën gjashtë të '
            'mëngjesit vendos a do ta bësh rrotullimin, ose kur në orën '
            'shtatë të mbrëmjes vendos a do të zbresësh edhe një herë para '
            'se të lëvizësh prapa. Pikërisht kjo i bën këto vendime kaq të '
            'rëndësishme.',
          ),
          ChecklistBlock(
            title: 'Unë zotohem',
            items: [
              'I zbatoj rregullat edhe atëherë kur askush nuk shikon',
              'I marr sekondat që kushton siguria',
              'Njoftoj me ndershmëri, në vend që të fsheh',
              'I ndihmoj kolegët e rinj ta bëjnë drejt që nga fillimi',
              'Kthehem çdo mbrëmje shëndoshë në shtëpi',
            ],
          ),
        ],
      ),
    ],
  ),
];
