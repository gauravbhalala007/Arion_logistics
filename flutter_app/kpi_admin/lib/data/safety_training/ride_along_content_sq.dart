// lib/data/safety_training/ride_along_content_sq.dart
//
// Përmbajtja e trajnimit Ride Along — versioni shqip.
// Struktura është identike me versionin gjerman (master): kapitujt
// ra1–ra5, të njëjtat folie, të njëjtët blloqe dhe të njëjtat vlera.
//
// „Ride Along" është udhëtimi shoqërues dyditor për shoferët e rinj:
// Dita e Parë me një numër më të vogël ndalesash, Dita e Dytë me shumë
// më tepër. Trajneri plotëson një listë kontrolli, firmos çdo pikë dhe
// në fund jep një vlerësim; fleta dorëzohet si foto te dispeçeri
// përgjegjës.
//
// Qëllimi i këtij trajnimi: PËRGATITJE. Kush e punon më parë, nuk i
// dëgjon temat e dy ditëve për herë të parë, por mund të pyesë me
// qëllim dhe ta shfrytëzojë me vetëdije udhëtimin shoqërues.
//
// Ndërtimi si te Green Book-u: për çdo kapitull disa folie nga blloqe
// të tipizuara — pllaka me shifra, raste për të menduar (Reveal),
// Do/Don't, fjali për t'u mbajtur mend dhe një listë kontrolli në fund
// të kapitullit. Për këtë temë nuk ka ilustrime, prandaj `asset: ''`.
//
// Neutrale ndaj firmës: ASNJË emër personi, asnjë emër stacioni, asnjë
// shifër specifike e firmës si rregull. Numri i ndalesave, kohët e
// Waiting Area, fillimi i punës dhe ana e parkimit janë shprehimisht
// përcaktime të stacionit përkatës — i thotë trajneri. Mjetet e firmës
// si regjistrimi i kohës jepen vetëm si shembull („p.sh. Kenjo").
// Konkrete mbeten: mjetet e Amazon-it (Flex, Mentor, ATLAS,
// Scorecard), aplikacioni CoDriver, rregullat e pushimit sipas § 4
// ArbZG dhe Green Book-u sipas § 1 Abs. 6 FPersV — të treja vlejnë në
// çdo firmë.

import 'safety_blocks.dart';

const List<SafetyChapterContent> rideAlongContentSq = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ra1',
    title: 'Çfarë është Ride Along-u',
    summary: 'Dy ditë udhëtim shoqërues: qëllimi, ecuria, kush merr pjesë '
        'dhe si vlerësohet',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Dy ditë pranë një shoferi me përvojë',
        blocks: [
          ParagraphBlock(
            'Ride Along-u është udhëtimi yt shoqërues për të nisur punën: '
            'dy ditë pune, në të cilat një shofer me përvojë është me ty '
            'si trajner. Turin nuk e njeh nga një prezantim, por pikërisht '
            'aty ku ai zhvillohet — në stacion, në Loading Area dhe në '
            'rrugë.',
          ),
          FactsBlock([
            FactItem('2 ditë', 'udhëtim shoqërues me një trajner'),
            FactItem('Dita e Parë', 'numër më i vogël ndalesash — në shumë '
                'firma rreth 20'),
            FactItem('Dita e Dytë', 'shumë më tepër ndalesa — në shumë '
                'firma rreth 70'),
          ]),
          ParagraphBlock(
            'Të dyja ditët ndërtohen mbi njëra-tjetrën. Ditën e Parë '
            'theksi bie mbi ecuritë: si hyhet në stacion, cilat '
            'aplikacione nisen dhe kur, si ngarkohet, kur bëhet pushimi. '
            'Ditën e Dytë sasia rritet dukshëm dhe ti ngas e shpërndan '
            'vetë — trajneri të shoqëron, por nuk të zëvendëson.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Numrat e ndalesave janë vlera orientuese',
            text: 'Sa ndalesa janë parashikuar realisht për Ditën e Parë '
                'dhe Ditën e Dytë, e përcakton firma ose stacioni yt. Të '
                'përhapura janë rreth 20 ditën e parë dhe rreth 70 ditën e '
                'dytë — e detyrueshme është vetëm përcaktimi që të jep '
                'trajneri ose dispeçeri yt përgjegjës.',
          ),
          BulletsBlock([
            'Të dyja ditët zhvillohen përmes llogarisë sate, jo përmes '
                'asaj të trajnerit',
            'Ndalesat numërohen si punë e vërtetë, jo si ushtrim',
            'Trajneri shpjegon, tregon nga afër dhe më pas të lë ta bësh '
                'vetë',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Shkurt',
            text: 'Ride Along-u është trajnimi yt fillestar në punë reale. '
                'Në fund duhet të jesh në gjendje ta ngasësh një tur vetëm '
                '— ky është kriteri sipas të cilit orientohet gjithçka.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kush merr pjesë dhe kush bën çfarë',
        blocks: [
          ParagraphBlock(
            'Në Ride Along janë të përfshirë tre role. Kur e di kush është '
            'përgjegjës për çfarë, nuk pyet personin e gabuar dhe nuk '
            'humbet kohë.',
          ),
          TableBlock(
            headers: ['Roli', 'Detyra'],
            rows: [
              [
                'Ti',
                'Ngas, shpërndan, pyet, merr pjesë — të dyja ditët përmes '
                    'llogarisë sate',
              ],
              [
                'Trajneri',
                'Shofer me përvojë: shpjegon çdo pikë, e tregon nga afër, '
                    'të vëzhgon, plotëson listën e kontrollit dhe '
                    'nënshkruan',
              ],
              [
                'Dispeçeri',
                'Planifikon të dyja ditët, është personi i kontaktit në '
                    'rast problemesh dhe në fund pranon foton e listës së '
                    'kontrollit',
              ],
            ],
          ),
          ParagraphBlock(
            'Trajneri nuk është eprori yt dhe nuk është kontrollor në '
            'kuptimin e një autoriteti shtetëror. Ai është kolegu që e '
            'njeh stacionin më mirë se kushdo. Pikërisht prandaj është '
            'adresa e duhur për çdo pyetje që të vjen ndër mend gjatë dy '
            'ditëve — edhe për ato që të duken banale.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Pyetjet nuk kushtojnë asgjë',
            text: 'Një pyetje në Ride Along është e lirë. E njëjta pyetje '
                'në javën e tretë, vetëm në tur, me një rrugë plot para '
                'teje, është e shtrenjtë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista e kontrollit dhe vlerësimi',
        blocks: [
          ParagraphBlock(
            'Trajneri punon me një fletë të caktuar — listën e kontrollit '
            'të Ride Along-ut. Aty shkruhet për secilën nga të dyja ditët '
            'çfarë duhet të jetë shpjeguar dhe treguar: nga inspektimi i '
            'mjetit te rregullat e pushimit dhe deri te pakot me fjalëkalim. '
            'Çdo pikë firmoset, çdo ditë mbyllet me datë dhe nënshkrim.',
          ),
          BulletsBlock([
            'Lista e kontrollit është dëshmia se je trajnuar',
            'Ajo të mbron edhe ty: ajo që është shënuar, të është '
                'shpjeguar',
            'Pas ditës së dytë trajneri jep një vlerësim për performancën '
                'dhe aftësitë e ngasjes',
          ]),
          ParagraphBlock(
            'Nuk është një provim me gijotinë. Askush nuk pret që ditën e '
            'parë ta ngasësh turin si një shofer me tre vjet përvojë. Por '
            'vlerësohet: trajneri shkruan si punon ti, dhe fleta shkon te '
            'firma. Kush mendon dukshëm bashkë me punën, është në kohë dhe '
            'i pranon udhëzimet, merr një vlerësim të mirë — edhe nëse '
            'është i ngadaltë.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Dallimi që ka rëndësi',
            text: 'Nuk vlerësohet nëse di gjithçka, por nëse je i gatshëm '
                'të mësosh dhe i merr rregullat seriozisht. Gabimet janë '
                'normale. Të të shpjegohet një gabim dy herë dhe prapë ta '
                'shpërfillësh, nuk është normale.',
          ),
          RevealBlock(
            prompt: 'Rast praktik: Ditën e Parë e ngatërron dy herë '
                'radhën e pakove te karroca dhe për ndalesat e tua të '
                'duhet dukshëm më shumë kohë se sa ishte planifikuar. Je i '
                'bindur se Ride Along-u ka shkuar dëm. A është kështu?',
            answer: 'Jo. Pikërisht për këtë është dita e parë. Trajneri '
                'pret ritëm sadopak vetëm ditën e dytë dhe vërtet në javët '
                'që vijnë. Atë që vlerëson ditën e parë është diçka '
                'tjetër: A pyet kur nuk je i sigurt? A e bën të njëjtin '
                'gabim edhe herën e tretë? A rendit më pas vetë më '
                'pastër? Kush e përmend gabimin dhe te karroca tjetër '
                'vepron me vetëdije ndryshe, lë një përshtypje më të mirë '
                'se dikush që është i shpejtë dhe nuk pyet asgjë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listë kontrolli: Kapitulli 1',
        blocks: [
          ChecklistBlock(
            title: 'Këtë marr me vete nga Kapitulli 1',
            items: [
              'Ride Along-u janë dy ditë pune me një trajner',
              'Dita e Parë më pak ndalesa, Dita e Dytë dukshëm më shumë — '
                  'numrin e saktë e cakton firma ime (të përhapura rreth 20 '
                  'dhe rreth 70)',
              'Të dyja ditët zhvillohen përmes llogarisë sime',
              'Trajneri shpjegon, tregon nga afër dhe më lë ta bëj vetë',
              'Ai plotëson një listë kontrolli dhe nënshkruan për çdo ditë',
              'Pas Ditës së Dytë ka një vlerësim për performancën dhe '
                  'aftësitë e ngasjes',
              'Është trajnim fillestar, por vlerësohet — gatishmëria për '
                  'të mësuar vlen më shumë se ritmi',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Një fjali për të dyja ditët',
            text: '„Më mirë pyes një herë më shumë se një herë më pak — '
                'pikërisht për këtë janë këto dy ditë."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ra2',
    title: 'Dita e Parë',
    summary: 'Ndalesat e para, nisja e aplikacioneve, inspektimi, Loading '
        'Area, pushimet dhe çelësi i mjetit',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Ndalesat e para me llogarinë tënde',
        blocks: [
          ParagraphBlock(
            'Dita e Parë ka një numër minimal ndalesash që duhet t\'i kesh '
            'ngarë dhe shpërndarë — përmes llogarisë sate. Ai është mbajtur '
            'me qëllim i vogël (në shumë firma rreth 20); numrin e '
            'detyrueshëm për stacionin tënd ta thotë trajneri. Ditën e Parë '
            'nuk bëhet fjalë për sasi, por që çdo veprim të bëhet një herë '
            'si duhet.',
          ),
          ParagraphBlock(
            'E rëndësishme është llogaria jote. Jo ajo e trajnerit, jo një '
            'qasje e përbashkët. Gjithçka që shpërndan atë ditë shkon nën '
            'emrin tënd — pikërisht ashtu si numërohet edhe më vonë. Vetëm '
            'kështu shohin trajneri dhe firma si duket vërtet shpërndarja '
            'jote.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Pa qasje nuk ka Ride Along',
            text: 'Nëse llogaria jote nuk funksionon në mëngjes, thuaje '
                'menjëherë — para se të nisesh, jo te ndalesa e parë. Një '
                'qasje e pasqaruar kushton gjithë ditën.',
          ),
          SubheadBlock('Aplikacioni CoDriver'),
          ParagraphBlock(
            'CoDriver është aplikacioni i firmës — aplikacioni në të cilin '
            'po lexon tani. Ai është i ndarë nga mjetet e Amazon-it: Amazon '
            'drejton turin, CoDriver gjithçka rreth punës sate në '
            'ndërmarrje. Trajneri e kalon me ty Ditën e Parë.',
          ),
          BulletsBlock([
            'Plani i turnit dhe Wave-Plan: kur punon dhe në cilin valë '
                'nisesh',
            'Njoftimi i mungesave dhe i raporteve mjekësore',
            'DA Academy: trajnime si ky këtu, si dhe udhëzimet e punës',
            'Mesazhet dhe njoftimet e firmës',
            'Raportimet e aksidenteve dhe të dëmeve',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Mbaje mend',
            text: 'Aplikacionet e Amazon-it drejtojnë turin. CoDriver '
                'drejton marrëdhënien tënde të punës. Të dyja të duhen çdo '
                'ditë dhe të dyja duhen parë një herë të plota Ditën e '
                'Parë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Mbërritja: orari i punës, ana e parkimit, Waiting Area',
        blocks: [
          ParagraphBlock(
            'Dita nuk fillon me ndalesën e parë, por me mbërritjen në '
            'stacion. Tri gjëra t\'i vë trajneri fort në zemër Ditën e Parë, '
            'sepse ato përsëriten çdo ditë të vetme pune.',
          ),
          SubheadBlock('1 — Orari i punës'),
          ParagraphBlock(
            'Turni yt ka një fillim të caktuar. Ai shkruhet në planin e '
            'turnit në CoDriver, dhe „fillim" do të thotë: në atë kohë je '
            'gati për punë në stacion — jo në rrugë drejt tij. Orët konkrete '
            'të stacionit tënd t\'i thotë trajneri, ato ndryshojnë sipas '
            'vendndodhjes dhe valës.',
          ),
          SubheadBlock('2 — Ana e parkimit'),
          ParagraphBlock(
            'Çdo stacion ka një rregullim se ku lejohen të qëndrojnë mjetet '
            'private dhe në cilën anë vendosen furgonët. Kjo nuk është '
            'shqetësim i kotë: në oborr manovrojnë shumë mjete njëkohësisht, '
            'shpesh mbrapsht dhe me pamje të keqe. Kush parkon gabim, '
            'bllokon një korsi ose qëndron në këndin e vdekur të dikujt që '
            'manovron. Trajneri të tregon anën që vlen për ty.',
          ),
          SubheadBlock('3 — Kohët e Waiting Area'),
          ParagraphBlock(
            'Waiting Area është zona ku pret derisa të thirret karroca jote '
            'ose pozicioni yt i ngarkimit. Për këtë ka dritare kohore të '
            'caktuara sipas valës. Kush qëndron atje shumë herët, e zë '
            'zonën; kush vjen vonë, e humbet thirrjen e vet dhe e shtyn '
            'mbrapa gjithë valën. Kohët e sakta për stacionin tënd t\'i '
            'thotë trajneri Ditën e Parë — shkruaji.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Tri të dhënat që duhet t\'i shënosh',
            text: 'Fillimi i turnit, ana e parkimit dhe dritarja jote e '
                'Waiting Area. Këto tri të dhëna të duhen që nga dita '
                'pasardhëse çdo mëngjes — dhe atëherë nuk të pyet më '
                'askush.',
          ),
          RevealBlock(
            prompt: 'Rast praktik: Je në kohë te porta për fillimin e '
                'turnit, por pastaj të duhen dhjetë minuta për një '
                'vendparkim, sepse ke kërkuar në anën e gabuar. Në Waiting '
                'Area je kështu me vonesë. Sa e keqe është kjo?',
            answer: 'Më e keqe sesa duket. Thirrja në Waiting Area është e '
                'ndarë në intervale: nëse e humbet dritaren tënde, bie pas '
                'shoferëve të tjerë të valës sate. Karroca jote pret, mjeti '
                'yt ndoshta bllokon një pozicion, dhe nisja jote zhvendoset '
                'më shumë se dhjetë minutat që ke humbur. Prandaj ana e '
                'parkimit dhe koha e Waiting Area shkojnë bashkë: „në kohë '
                'te porta" nuk është e njëjta gjë me „në kohë në Waiting '
                'Area". Llogarite edhe kohën për të parkuar dhe për të '
                'ecur.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Nisja: regjistrimi i kohës, Mentor dhe Flex',
        blocks: [
          ParagraphBlock(
            'Tri sisteme duhet të jenë në punë në fillim të turnit — dhe '
            'pikërisht në kohë dhe në këtë radhë. Secili ka një qëllim '
            'tjetër dhe secili shkakton bezdi nëse niset me vonesë.',
          ),
          StepsBlock([
            'Regjistrimi i kohës i firmës sate (p.sh. Kenjo) — hyrja në '
                'fillim të turnit. Ajo që nuk e nis këtu, nuk është kohë '
                'pune e paguar dhe mungon më vonë në pagesën tënde. Cilin '
                'sistem përdor firma jote, ta tregon trajneri.',
            'Mentor — aplikacioni i Amazon-it për sjelljen në ngasje: duhet '
                'të jetë në punë para se të nisesh. Ai regjistron mënyrën '
                'tënde të ngasjes dhe jep të dhënat për rezultatin tënd.',
            'Flex — aplikacioni i shpërndarjes i Amazon-it: këtu merr '
                'rrugën tënde, skanon pakot dhe dokumenton çdo dorëzim.',
          ]),
          SubheadBlock('4 orët e Mentor-it'),
          ParagraphBlock(
            'Mentor nuk punon pa fund: aplikacioni regjistron rreth katër '
            'orë njëherësh. Pas kësaj duhet ta nisësh nga e para, përndryshe '
            'pjesa tjetër e turit mbetet e paregjistruar. Pikërisht ky është '
            'gabimi më i shpeshtë i fillestarëve — aplikacioni u nis '
            'saktë në mëngjes, por pas pushimit të drekës nuk u aktivizua '
            'sërish. Trajneri të tregon Ditën e Parë nga se e kupton që '
            'Mentor është ende në punë.',
          ),
          FactsBlock([
            FactItem('4 orë', 'kohëzgjatja e regjistrimit të Mentor-it '
                'njëherësh'),
            FactItem('para nisjes', 'nis Mentor-in — jo pasi je në rrugë'),
            FactItem('pas pushimit', 'kontrollo Mentor-in dhe nise nga e '
                'para'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Gabimi më i shpeshtë i Ditës së Parë',
            text: 'Flex punon, Mentor jo. Atëherë e ngas rrugën tënde, por '
                'sjellja jote në ngasje nuk regjistrohet — dhe koha që '
                'mungon te Mentor bie në sy në firmë njësoj si një vlerë e '
                'keqe.',
          ),
          RevealBlock(
            prompt: 'Rast praktik: Në orën 14 vëren se Mentor nuk është më '
                'në punë që nga pushimi. Çfarë bën — vazhdon deri në fund '
                'të turnit dhe nesër e bën më mirë, apo reagon menjëherë?',
            answer: 'Reago menjëherë: ndal te vendi i parë i sigurt, nise '
                'Mentor-in nga e para, vazhdo. Gabimi i afërt është të '
                'mendosh se gjysmë dite pa regjistrim nuk ka rëndësi, sepse '
                'ke ngarë si duhet. Nuk është kështu: për firmën një '
                'boshllëk duket si boshllëk — jo si ngasje e mirë. Dhe të '
                'vazhdosh do të thotë ta zgjerosh boshllëkun me çdo orë. '
                'Njoftoje veç kësaj trajnerin tënd ose dispeçerin tënd '
                'përgjegjës, që boshllëku të jetë i shpjegueshëm.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Inspektimi i mjetit dhe Loading Area',
        blocks: [
          SubheadBlock('Inspektimi i mjetit'),
          ParagraphBlock(
            'Para se të nisesh, mjeti kontrollohet — dhe pas turit edhe një '
            'herë. Inspektimi është një kontroll pamor me dokumentim: i bie '
            'një herë rrotull furgonit, shikon çdo anë, kontrollon '
            'funksionet dhe shënon atë që sheh.',
          ),
          BulletsBlock([
            'Rrotullimi nga jashtë: karroceria, parakolpët, pasqyrat, '
                'xhamat — çdo gropëz dhe çdo gërvishtje',
            'Gomat: profili, dëmtimet e dukshme, përshtypja për presionin',
            'Dritat: dritat e shkurtra, dritat e frenimit, sinjalet, '
                'projektorët e prapavajtjes',
            'Kabina dhe hapësira e ngarkesës: pastërtia, pjesët e lira, '
                'ndarësja',
            'Pajisjet: trekëndëshi i sigurisë, jeleku reflektues, kutia e '
                'ndihmës së parë',
            'Kilometrazhi dhe gjendja e karburantit ose e baterisë',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Pse ka rëndësi inspektimi PARA udhëtimit',
            text: 'Një dëm që e dokumenton më parë, është dëm i mëparshëm. '
                'I njëjti dëm që nuk e dokumenton, në mbrëmje është dëmi '
                'yt. Dy minutat e rrotullimit janë sigurimi më i lirë i '
                'ditës sate të punës.',
          ),
          SubheadBlock('Ngarkimi i karrocës në Loading Area'),
          ParagraphBlock(
            'Në Loading Area qëndron karroca jote me pakot e rrugës sate. '
            'Si e vendos atë në furgon, vendos për gjithë ditën tënde: kush '
            'ngarkon pa renditje, kërkon në çdo ndalesë — dhe kjo mblidhet '
            'gjatë një turi të plotë në orë të tëra.',
          ),
          BulletsBlock([
            'Ngarko sipas radhës së rrugës: ajo që del e para, hyn e fundit '
                'dhe rri përpara',
            'Pakot e rënda poshtë, të lehtat sipër — jo e kundërta',
            'Siguro ngarkesën: asgjë nuk duhet të rrëshqasë përpara gjatë '
                'frenimit',
            'Mos grumbullo asgjë në kalim ose para derës rrëshqitëse',
            'Pakot e veçanta (fjalëkalim, ATLAS, mallra vëllimore) vendosi '
                'veçmas dhe në dorë',
            'Ktheje karrocën bosh aty ku i takon — mos e lër diku kuturu',
          ]),
          DoDontBlock(
            doTitle: 'Kështu e bën si duhet',
            dos: [
              'Gjatë ngarkimit mendo që tani cila është ndalesa e parë',
              'Kur ngre peshë, ul gjunjët, ngarkesën afër trupit',
              'Pyet kur nuk e di se ku i takon një pako',
            ],
            dontTitle: 'Kjo të kushton kohë më vonë',
            donts: [
              'Ta hedhësh gjithçka brenda dhe „ta rendisësh rrugës"',
              'Të vendosësh pako mbi ndarësen ose në zonën e shoferit',
              'Ta lësh karrocën në mes të korsisë së kalimit',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Pushimet, çelësi dhe kyçja automatike',
        blocks: [
          SubheadBlock('Pushimet: 30 dhe 45 minuta'),
          ParagraphBlock(
            'Ka dy kohëzgjatje pushimi, dhe cila vlen për ty varet vetëm '
            'nga koha jote e punës atë ditë. Ndryshe nga kohët e Waiting '
            'Area ose numri i ndalesave, kjo nuk është përcaktim i '
            'stacionit tënd, por ligj: § 4 Arbeitszeitgesetz (ArbZG — ligji '
            'gjerman për kohën e punës). Rregulli vlen kështu njësoj në çdo '
            'firmë dhe nuk negociohet.',
          ),
          FactsBlock([
            FactItem('30 min', 'për më shumë se 6 deri në 9 orë punë'),
            FactItem('45 min', 'për më shumë se 9 orë punë'),
            FactItem('15 min', 'pjesa më e vogël e pushimit që njihet'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 4 ArbZG — baza ligjore',
            text: 'Ligji për kohën e punës parashikon të paktën 30 minuta '
                'pushim për më shumë se 6 orë punë dhe të paktën 45 minuta '
                'për më shumë se 9 orë. Të punosh më gjatë se 6 orë pa '
                'pushim është shprehimisht e ndaluar.',
          ),
          ParagraphBlock(
            'Pushimi mund të ndahet, por çdo pjesë duhet të zgjasë të '
            'paktën 15 minuta — dy herë nga 15 minuta japin pra pushimin e '
            '30-tës, tri herë nga 15 minuta atë të 45-tës. Pesë minuta '
            'ndërmjet nuk numërohen. E rëndësishme është veç kësaj: pushimi '
            'duhet të ketë filluar para se të mbushen gjashtë orë punë, jo '
            'vetëm në fund të turnit.',
          ),
          ParagraphBlock(
            'Pse duhet regjistruar: pushimi yt nuk është kohë pune e paguar '
            'dhe firma duhet të jetë në gjendje të dëshmojë se ti e ke bërë '
            'vërtet. Prandaj ai shënohet në regjistrimin e kohës — jo nga '
            'mosbesim, por sepse një pushim i padokumentuar në një kontroll '
            'vlen si pushim i pabërë. Ky është një shkelje për të cilën '
            'përgjigjet firma. Trajneri të tregon saktësisht ku e shënon.',
          ),
          SubheadBlock('Kyçja automatike dhe çelësi'),
          ParagraphBlock(
            'Shumë Sprinter kyçen automatikisht: nëse dera mbyllet vetë ose '
            'mjeti niset, mbyllja qendrore kyçet vetvetiu. Kjo është një '
            'mbrojtje nga vjedhja për ngarkesën tënde — dhe është pikërisht '
            'arsyeja pse çelësi mbetet gjithmonë te ti.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Çelësi i takon trupit tënd',
            text: 'Jo mbi sedilje, jo në raft, jo në xhepin e xhaketës që '
                'rri në mjet. Çelësi në xhepin e pantallonave ose te rripi '
                'në brezin tënd — çdo herë që zbret.',
          ),
          RevealBlock(
            prompt: 'Rast praktik: Ndalon shkurt, e lë çelësin te '
                'kontakti, merr dy pako dhe e mbyll derën rrëshqitëse me '
                'këmbë. Mbyllja qendrore kyçet. Çfarë ndodh tani?',
            answer: 'Rri me dy pako para një furgoni të kyçur, në të cilin '
                'janë çelësi yt, telefoni yt, pjesa tjetër e ngarkesës dhe '
                'zakonisht edhe dokumentet e tua. Dita ka shkuar dëm: të '
                'duhet ndihmë nga stacioni ose një shërbim çelësash, gjithë '
                'rruga jote ndalon, dhe pakot në mjet nuk i arrijnë klientët '
                'e tyre sot. Gabimi i afërt është „po unë jam larguar vetëm '
                'për dhjetë sekonda" — kyçja automatike nuk bën dallim mes '
                'dhjetë sekondave dhe dhjetë minutave. Prandaj vlen pa '
                'përjashtim: çelësi jashtë, çelësi te trupi, dhe vetëm '
                'pastaj zbrit.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Fundi i turit: mbyllja e Flex-it dhe inspektimi',
        blocks: [
          ParagraphBlock(
            'Dita nuk mbaron te ndalesa e fundit, por në stacion. Dy gjëra '
            'janë atje në listën e kontrollit të trajnerit — dhe të dyja '
            'harrohen lehtë, sepse je i lodhur dhe do të shkosh në shtëpi.',
          ),
          StepsBlock([
            'Mbylle si duhet aplikacionin Flex: përfundo rrugën, dorëzo '
                'kthimet dhe mbylle aplikacionin — jo thjesht ta fusësh '
                'telefonin në xhep.',
            'Inspektimi i mjetit pas udhëtimit: i njëjti rrotullim si në '
                'mëngjes, tani me syrin te dëmet e reja, kilometrazhi dhe '
                'gjendja e karburantit ose e baterisë.',
            'Dorëzo mjetin të pastër dhe bosh, kontrollo hapësirën e '
                'ngarkesës — asnjë pako nuk mbetet brenda.',
            'Dil nga regjistrimi i kohës i firmës sate (p.sh. Kenjo) dhe '
                'dorëzo çelësin aty ku i takon.',
          ]),
          ParagraphBlock(
            'Inspektimi përfundimtar është pjesa plotësuese e inspektimit '
            'të mëngjesit. Vetëm të dyja bashkë e bëjnë të qartë çfarë ka '
            'ndodhur atë ditë me mjetin — dhe çfarë jo. Nëse mungon ai i '
            'mbrëmjes, një dëm të nesërmen në mëngjes nuk i atribuohet dot '
            'më askujt, dhe shoferi tjetër merr përsipër problemin tënd ose '
            'ti të tijin.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Fjali për fundin e punës',
            text: 'Flex-i i mbyllur, një xhiro rreth mjetit, hapësira e '
                'ngarkesës bosh, dalje nga regjistrimi, çelësi i dorëzuar. '
                'Vetëm atëherë mbaron puna.',
          ),
          ChecklistBlock(
            title: 'Këtë marr me vete nga Dita e Parë',
            items: [
              'Numrin e ndalesave të caktuar nga firma ime përmes '
                  'llogarisë sime',
              'E njoh aplikacionin CoDriver dhe di çfarë gjej brenda tij',
              'E di fillimin e turnit tim, rregullin e parkimit të '
                  'stacionit tim dhe dritaren time të Waiting Area',
              'Nis regjistrimin e kohës (p.sh. Kenjo), Mentor-in dhe '
                  'Flex-in në kohë dhe në këtë radhë',
              'E di që Mentor regjistron rreth 4 orë dhe pas kësaj duhet '
                  'nisur nga e para',
              'E bëj inspektimin e mjetit para dhe pas turit',
              'E ngarkoj karrocën sipas radhës së rrugës, të rëndat poshtë, '
                  'ngarkesa e siguruar',
              'E njoh rregullin e pushimit sipas § 4 ArbZG: 30 minuta mbi 6 '
                  'orë, 45 minuta mbi 9 orë — dhe e shënoj',
              'Çelësi mbetet gjithmonë te trupi, sepse Sprinter-i kyçet '
                  'automatikisht',
              'Në fund e mbyll Flex-in, bëj inspektimin dhe dal nga '
                  'regjistrimi',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ra3',
    title: 'Dita e Dytë',
    summary: 'Dukshëm më shumë ndalesa në mënyrë të pavarur, Scorecard, '
        'mbrojtja e mjetit, Green Book, pako të veçanta, karburant dhe '
        'karikim',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Dukshëm më shumë ndalesa — ti ngas, ti shpërndan',
        blocks: [
          ParagraphBlock(
            'Ditën e Dytë raporti përmbyset. Numri i ndalesave rritet '
            'dukshëm — në shumë firma deri në rreth 70, e detyrueshëm është '
            'përcaktimi i stacionit tënd — dhe ti i kryen ndalesat në mënyrë '
            'të pavarur: ti ngas, ti navigon, ti skanon, ti shpërndan, ti '
            'dokumenton. Trajneri rri pranë dhe ndërhyn vetëm kur është e '
            'nevojshme.',
          ),
          FactsBlock([
            FactItem('më shumë', 'ndalesa se Dita e Parë — numri sipas '
                'përcaktimit të firmës'),
            FactItem('vetë', 'ngasje dhe shpërndarje — trajneri vetëm '
                'shoqëron'),
            FactItem('1 ditë', 'deri te turi yt i parë i pavarur'),
          ]),
          ParagraphBlock(
            'Ky është kuptimi i vërtetë i ditës së dytë: duhet ta kesh '
            'provuar një herë si ndihet një tur i plotë — me ritmin, me '
            'renditjen ndërmjet, me klientët që nuk hapin, dhe me ndjesinë '
            'që ora ecën. Kur e ke bërë këtë një herë me dikë pranë teje, '
            'dalja e parë vetëm nuk është më as gjysma aq e madhe.',
          ),
          BulletsBlock([
            'Mos lër të ta marrin nga dora atë që mund ta bësh vetë — edhe '
                'nëse ecën më ngadalë',
            'Pyet menjëherë për çdo ndalesë që të është dukur e çuditshme',
            'Mbaj mend çfarë duhet të shënosh: kodet, ecuritë, personat e '
                'kontaktit',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Kriteri i Ditës së Dytë',
            text: 'Jo „a e mbaron turin në kohë rekord", por „a mund të '
                'nisej nesër vetëm". Pikërisht këtë vlerëson trajneri.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Scorecard, cilësia dhe performanca',
        blocks: [
          ParagraphBlock(
            'Puna jote matet. Scorecard-i i Amazon-it përmbledh javë pas '
            'jave si keni ngarë ti dhe firma jote. Ditën e Dytë trajneri të '
            'shpjegon cilat vlera qëndrojnë brenda tij dhe si i ndikon ti — '
            'sepse pothuajse çdo vlerë lind nga diçka që e ke vetë në dorë.',
          ),
          BulletsBlock([
            'Cilësia e shpërndarjes: A u dorëzua apo u la pakoja në vendin '
                'e duhur dhe u dokumentua pastër?',
            'Sjellja në ngasje nga Mentor: frenimi, përshpejtimi, kthesat, '
                'përdorimi i telefonit, rripi i sigurimit',
            'Besueshmëria: nisja në kohë, rruga e ngarë e plotë, kthimi i '
                'saktë',
            'Reagimet e klientëve: ankesat dhe lavdërimet përfundojnë '
                'gjithashtu në vlerësim',
          ]),
          ParagraphBlock(
            'Cilësia dhe performanca janë këtu dy gjëra të ndryshme, që '
            'shpesh ngatërrohen. Performanca është sasia: sa ndalesa në sa '
            'kohë. Cilësia është se sa pastër u mbyll çdo ndalesë e vetme. '
            'Një shofer me performancë të lartë dhe cilësi të keqe shkakton '
            'më shumë punë sesa kursen — çdo reklamim i kushton firmës '
            'shumëfishin e minutës që u kursye përpara.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Gabimi më i shtrenjtë është gabimi i shpejtë',
            text: 'Ta lësh një pako në vendin e gabuar dhe të vazhdosh '
                'shpejt të kursen një minutë dhe i kushton firmës një '
                'reklamim, një hetim dhe në rastin më të keq vlerën e '
                'mallit.',
          ),
          RevealBlock(
            prompt: 'Rast praktik: Klienti nuk hap, ti ke edhe 30 ndalesa '
                'para vetes. E lë pakon pas koshit të mbeturinave dhe bën '
                'shpejt një foto të derës së hyrjes. Pse është kjo problem?',
            answer: 'Dyfish. Së pari, vendi i lënies nuk përputhet me atë '
                'që ke dokumentuar — nëse klienti nuk e gjen pakon, '
                'dorëzimi yt mbetet i padëshmuar. Së dyti, lënia pas një '
                'koshi mbeturinash nuk është vend i përshtatshëm: ai duket '
                'nga rruga dhe zbrazet. E drejta është të ndjekësh rrugën e '
                'parashikuar — fqinji, vend i sigurt lënieje me miratim të '
                'klientit ose kthim — dhe të dokumentosh saktësisht atë që '
                'ke bërë vërtet. Minuta e vetme e kursyer qëndron përballë '
                'një reklamimi që ty, klientit dhe firmës u kushton '
                'dukshëm më shumë secilit.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Mbrojtja e mjetit, aksidentet, pastrimi dhe kujdesi',
        blocks: [
          ParagraphBlock(
            'Furgoni është vendi yt i punës dhe mjeti më i shtrenjtë që të '
            'beson firma. Si sillesh me të, është Ditën e Dytë një pikë më '
            'vete në listën e kontrollit — në tri pjesë.',
          ),
          SubheadBlock('1 — Të shmangësh dëmet'),
          BulletsBlock([
            'Ngasje mbrapsht vetëm kur nuk bëhet ndryshe — dhe atëherë '
                'ngadalë, me shikim në të dyja pasqyrat',
            'Në situatë të paqartë zbrit dhe shiko, në vend që të '
                'hamendësosh',
            'Hyrjet e ngushta, degët e ulëta, garazhet nëntokësore dhe '
                'shtyllat janë burimet më të shpeshta të dëmeve',
            'Mbaj distancë dhe freno duke parashikuar — kjo kursen '
                'njëkohësisht mjetin dhe Scorecard-in',
          ]),
          SubheadBlock('2 — Nëse prapëseprapë ndodh diçka'),
          StepsBlock([
            'Ndal, siguro vendin: dritat e rrezikut, jeleku reflektues, '
                'trekëndëshi i sigurisë.',
            'Kujdesu për të lënduarit, në rast dëmtimi personash thirr '
                'gjithmonë 112.',
            'Mos ndrysho asgjë, bëj foto: situata e përgjithshme, dëmet, '
                'targat, mjedisi.',
            'Në rast mjeti të huaj ose faji të paqartë thirr policinë — '
                'edhe për dëme të vogla.',
            'Njofto menjëherë dispeçerin tënd përgjegjës dhe raporto '
                'ngjarjen në CoDriver.',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Kurrë mos vazhdo rrugën',
            text: 'Edhe një gërvishtje e vogël në një mjet të huaj është pa '
                'njoftim largim nga vendi i aksidentit — një vepër penale. '
                'Një fletë pas fshirëses së xhamit nuk mjafton ligjërisht.',
          ),
          SubheadBlock('3 — Pastrimi dhe kujdesi'),
          BulletsBlock([
            'Zbraze kabinën çdo ditë: pa mbeturina, pa shishe, pa letra',
            'Fshije hapësirën e ngarkesës dhe kontrollo për pako të '
                'harruara',
            'Mbaj xhamat dhe pasqyrat të pastra — pamja e keqe është '
                'problem sigurie, jo çështje estetike',
            'Raporto lëngjet e mjetit dhe zhurmat e pazakonta, mos i '
                'shpërfill',
          ]),
          RevealBlock(
            prompt: 'Rast praktik: Gjatë manovrimit prek një shtyllë. Në '
                'mjet ka një gërvishtje, asgjë tjetër, askush nuk e ka '
                'parë. A e raporton?',
            answer: 'Po, gjithmonë dhe po atë ditë. Nuk bëhet fjalë për '
                'faj, por për atribuim: një gërvishtje e raportuar është '
                'një ngjarje që trajtohet. E njëjta gërvishtje, që të '
                'nesërmen në mëngjes e gjen një shofer tjetër gjatë '
                'inspektimit të tij, është një dëm i pasqaruar — dhe kjo '
                'bëhet e pakëndshme për të gjithë të përfshirët, edhe për '
                'ty, sepse dyshimi në fund prapë drejtohet nga përdoruesi i '
                'fundit. Gabimi i afërt është „nuk bie në sy". Bie në sy te '
                'inspektimi i radhës, pikërisht për këtë është ai.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Green Book / libri i kontrollit',
        blocks: [
          ParagraphBlock(
            'Green Book-u është libri yt i kontrollit të udhëtimeve: fletët '
            'ditore të kontrollit sipas § 1 Abs. 6 Fahrpersonalverordnung '
            '(FPersV — rregullorja gjermane për personelin e ngasjes), me '
            'të cilat dëshmon kohët e tua të ngasjes, ndërprerjet e '
            'udhëtimit dhe kohët e pushimit. Edhe kjo nuk është rregull i '
            'stacionit tënd, por e drejtë në fuqi për personelin e ngasjes '
            '— ajo vlen njësoj në çdo firmë. Ai shprehimisht nuk është '
            'kontroll i mjetit: në Green Book bëhet fjalë vetëm për kohët, '
            'kohët e tua.',
          ),
          BulletsBlock([
            'Një fletë për çdo ditë pune, e mbajtur me dorë dhe e '
                'nënshkruar',
            'Shënohen fillimi dhe fundi i udhëtimit, kilometrazhet, kohët e '
                'ngasjes, ndërprerjet dhe kohët e pushimit',
            'Plotësoje menjëherë, mos e rindërto në mbrëmje nga kujtesa',
            'Regjistrimet e ditëve të fundit mbahen me vete dhe paraqiten '
                'në rast kontrolli',
          ]),
          ParagraphBlock(
            'Trajneri të tregon Ditën e Dytë ku ndodhet fleta, si '
            'plotësohet dhe ku dorëzohen fletët e përfunduara. Gjithçka '
            'tjetër nuk qëndron këtu: në DA Academy ka për këtë trajnimin e '
            'veçantë „Green Book" — me të dhënat e detyrueshme, kohët e '
            'ngasjes dhe të pushimit, detyrimin për t\'i mbajtur me vete dhe '
            'pasojat në rast shkeljeje. Punoje atë, në vend që të mundohesh '
            't\'i mbash mend detajet Ditën e Dytë brenda mjetit.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Vetë regjistrimi është detyrimi',
            text: 'Nëse i ke respektuar kohët, askush nuk mund ta '
                'konstatojë në një kontroll kur nuk paraqitet asgjë. Një '
                'fletë që mungon është prandaj shkelje njësoj si një kohë '
                'ngasjeje e tejkaluar.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Raste të veçanta: pako me fjalëkalim dhe pako ATLAS',
        blocks: [
          SubheadBlock('Pakot me fjalëkalim'),
          ParagraphBlock(
            'Disa dërgesa lejohen të dorëzohen vetëm kundrejt një '
            'fjalëkalimi ose një kodi që klienti e ka marrë më parë. Tipike '
            'janë mallrat me vlerë të lartë dhe gjithçka që rrezikohet '
            'veçanërisht nga vjedhja. Flex-i të njofton për këtë te '
            'ndalesa.',
          ),
          BulletsBlock([
            'Klienti ta thotë ose ta tregon kodin — ti nuk e lexon dhe nuk '
                'e thua i pari',
            'Pa kodin e saktë nuk ka dorëzim: asnjë përjashtim, as te '
                'fqinji',
            'Asnjë lënie te dera dhe asnjë vendosje në korridorin e '
                'pallatit',
            'Nëse kodi nuk përputhet, dërgesa kthehet sipas rrugës së '
                'parashikuar dhe dokumentohet',
          ]),
          SubheadBlock('Pakot ATLAS'),
          ParagraphBlock(
            'Dërgesat ATLAS janë gjithashtu pako që trajtohen veçmas: ato '
            'ndjekin një proces të vetin me hapa shtesë në ecurinë e '
            'skanimit dhe të dorëzimit. E rëndësishme për ty është që t\'i '
            'njohësh, t\'i ruash veçmas dhe në dorë dhe të mos e shkurtosh '
            'ecurinë e parashikuar. Si duket konkretisht procesi në '
            'stacionin tënd dhe cilat hapa të cakton Flex-i, ta tregon '
            'trajneri Ditën e Dytë te pakoja reale.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Rendit pakot e veçanta të parat',
            text: 'Të dyja llojet e pakove nuk do t\'i kërkosh te ndalesa '
                'nën 90 dërgesa të tjera. Vendosi me vetëdije veçmas gjatë '
                'ngarkimit dhe mbaje mend pozicionin e tyre.',
          ),
          RevealBlock(
            prompt: 'Rast praktik: Klienti është aty, por nuk e ka '
                'fjalëkalimin në dorë — „po kjo është vetëm formalitet, ju '
                'nënshkruaj çfarë të doni". Çfarë bën?',
            answer: 'Nuk e dorëzon. Fjalëkalimi është dëshmia se marrësi '
                'është vërtet marrësi — pikërisht prandaj u dha. Një '
                'nënshkrim, një dokument identiteti që ti nuk ke të drejtë '
                'ta kontrollosh, ose bindja me fjalë të mira nuk e '
                'zëvendësojnë atë. Gabimi i afërt është ta vendosësh '
                'mirësjelljen mbi procesin: nëse dërgesa raportohet më vonë '
                'si e pamarrë, dorëzimi pa kod qëndron si gabim në emrin '
                'tënd. Lutju klientit ta kërkojë kodin te konfirmimi i '
                'porosisë. Nëse nuk e gjen, e merr pakon prapë me vete dhe '
                'e dokumenton si duhet.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Karburanti, karikimi dhe fundi i turit',
        blocks: [
          SubheadBlock('Furnizimi me karburant'),
          ParagraphBlock(
            'Furgoni furnizohet me karburant sipas rregullave të firmës: në '
            'stacionet e parashikuara, me kartën e karburantit të mjetit '
            'dhe me karburantin e duhur. Fatura i takon mjetit ose '
            'dorëzohet aty ku ta tregon trajneri. Kur furnizohesh, varet '
            'nga një rregull i thjeshtë: jo vetëm kur ndizet drita e '
            'rezervës, por ashtu që shoferi tjetër të mos nisë me depozitë '
            'gati bosh.',
          ),
          BulletsBlock([
            'Lloji i duhur i karburantit — një furnizim i gabuar e mban '
                'mjetin ditë të tëra jashtë pune',
            'Karta e karburantit i takon mjetit, jo çantës sate private',
            'Ruaje faturën dhe dorëzoje siç është përcaktuar',
            'Motori i fikur, mos pi duhan, telefoni larg te pompa',
          ]),
          SubheadBlock('Karikimi elektrik'),
          ParagraphBlock(
            'Te një mjet elektrik karikimi zë vendin e furnizimit me '
            'karburant — me një ndryshim të rëndësishëm: karikimi zgjat më '
            'shumë dhe prandaj duhet planifikuar. Trajneri të tregon ku '
            'karikohet, cili kabull i takon mjetit dhe çfarë niveli '
            'karikimi duhet të ketë mjeti në fund të turnit.',
          ),
          BulletsBlock([
            'Mbaje nivelin e karikimit nën sy dhe planifiko në kohë, mos '
                'reago vetëm te rrezja e mbetur',
            'Pas lidhjes kontrollo nëse karikimi ka filluar vërtet',
            'Mblidhe kabllon pastër dhe mos lër vende ku dikush pengohet',
            'Në fund të turnit dorëzoje mjetin ashtu si e cakton firma — '
                'shoferi tjetër niset me të',
          ]),
          SubheadBlock('Fundi i turit — si te Dita e Parë'),
          StepsBlock([
            'Mbylle si duhet aplikacionin Flex, përfundo rrugën, dorëzo '
                'kthimet.',
            'Inspektimi i mjetit pas udhëtimit: rrotullimi, dëmet e reja, '
                'kilometrazhi, niveli i karburantit ose i karikimit.',
            'Hapësira e ngarkesës bosh dhe e pastër, kabina e rregulluar.',
            'Dil nga regjistrimi, dorëzo çelësin, plotëso Green Book-un.',
          ]),
          ChecklistBlock(
            title: 'Këtë marr me vete nga Dita e Dytë',
            items: [
              'Numrin dukshëm më të lartë të ndalesave të caktuar nga firma '
                  'ime — të cilat i ngas dhe i shpërndaj vetë',
              'E di çfarë qëndron në Scorecard dhe si e ndikoj atë',
              'Cilësia nuk është e njëjta gjë me performancën — të dyja '
                  'numërojnë',
              'I shmang dëmet në mënyrë aktive dhe raportoj menjëherë çdo '
                  'ngjarje',
              'E mbaj mjetin të pastër nga brenda dhe nga jashtë',
              'E njoh Green Book-un sipas § 1 Abs. 6 FPersV dhe bëj për të '
                  'trajnimin e veçantë në DA Academy',
              'Pakot me fjalëkalim i jap vetëm kundrejt kodit të saktë',
              'Pakot ATLAS i njoh dhe ndjek procesin e parashikuar',
              'I njoh rregullat për karburantin dhe për karikimin elektrik',
              'Në fund: mbyll Flex-in, inspektimi, dalja nga regjistrimi',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ra4',
    title: 'Përfundimi dhe dorëzimi',
    summary: 'Vlerësimi i trajnerit, nënshkrimet për çdo ditë dhe dorëzimi '
        'i fletës si foto',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Vlerësimi i trajnerit',
        blocks: [
          ParagraphBlock(
            'Pas Ditës së Dytë trajneri ulet me ty dhe jep një vlerësim për '
            'performancën tënde dhe për aftësitë e tua të ngasjes. Ky nuk '
            'është një gjykim me dy fjalë, por një vlerësim: çfarë ecën '
            'tashmë mirë, ku duhet të punosh, çfarë duhet të kesh parasysh '
            'veçanërisht në javët e ardhshme.',
          ),
          BulletsBlock([
            'Sjellja në ngasje: qetësia, parashikimi, ngasja mbrapsht, '
                'sjellja në vende të ngushta',
            'Shpërndarja: kujdesi, dokumentimi, sjellja me klientët',
            'Organizimi: renditja, ndjenja e kohës, përdorimi i '
                'aplikacioneve',
            'Qëndrimi ndaj punës: përpikëria, pyetjet, sjellja ndaj '
                'udhëzimeve',
          ]),
          ParagraphBlock(
            'Merre vlerësimin seriozisht, por jo personalisht. Është rasti '
            'i vetëm në të cilin dikush të ka parë duke punuar dy ditë të '
            'plota. Pyet kur një pikë nuk të është e qartë, dhe pyet '
            'konkretisht: „Çfarë saktësisht duhet të bëj ndryshe kur ngas '
            'mbrapsht?" të sjell më shumë sesa një tundje koke.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Pyetja e vetme në fund',
            text: 'Pyete trajnerin tënd në fund: „Cila është ajo gjëja e '
                'vetme për të cilën duhet të kem kujdes veçanërisht në '
                'javën time të parë vetëm?" Përgjigjja është gjëja më e '
                'vlefshme nga dy ditët.',
          ),
          RevealBlock(
            prompt: 'Rast praktik: Në vlerësim thuhet se je shumë hezitues '
                'gjatë manovrimit dhe humbet kohë me këtë. Ti mendon se '
                'ishe thjesht i kujdesshëm. Si sillesh me këtë?',
            answer: 'Pyet, mos u justifiko. Kujdesi gjatë manovrimit është '
                'i drejtë — trajneri me „hezitues" zakonisht ka parasysh '
                'diçka tjetër: që mendon gjatë në vend që të zbresësh e të '
                'shikosh shkurt, ose që fillon disa herë aty ku një herë e '
                'vetme mbrapsht me shikim në të dyja pasqyrat do të kishte '
                'mjaftuar. Kërko një shembull konkret nga ajo ditë. '
                'Atëherë ke një pikë në të cilën mund të punosh vërtet, në '
                'vend të një vlerësimi që vetëm e pranon me kokë ose e '
                'kundërshton.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Fleta: data, emrat, nënshkrimet',
        blocks: [
          ParagraphBlock(
            'Lista e kontrollit e Ride Along-ut është e plotë vetëm kur të '
            'dhënat e kokës janë të sakta. Pa to fleta është një letër me '
            'shenja dhe nuk i atribuohet dot asnjë dëshmie.',
          ),
          TableBlock(
            headers: ['Të dhëna', 'Çfarë nënkuptohet'],
            rows: [
              ['Data', 'E shënuar veçmas për secilën nga të dyja ditët'],
              ['Emri nxënësit', 'Emri yt — shoferi i ri'],
              ['Emri mësuesit', 'Emri i trajnerit tënd'],
              [
                'Nënshkrimi',
                'Nga trajneri, veçmas për çdo ditë — jo një herë për të '
                    'dyja ditët',
              ],
            ],
          ),
          ParagraphBlock(
            'Që nënshkruhet për çdo ditë, ka një arsye: çdo ditë ka listën '
            'e vet të pikave. Nëse dita e dytë bie ose shtyhet, mbetet '
            'prapë e dokumentuar pastër çfarë u krye ditën e parë. Prandaj '
            'kontrollo vetë në fund të çdo dite nëse data dhe nënshkrimi '
            'janë vendosur.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Shiko vetë',
            text: 'Fleta është dëshmia e trajnimit tënd. Nëse mungon një '
                'nënshkrim, mungon dëshmia — dhe më pas diçka e tillë është '
                'gjithmonë e mundimshme. Një vështrim para se të mbarosh '
                'punën mjafton.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dorëzimi: foto te dispeçeri',
        blocks: [
          ParagraphBlock(
            'Në fund të Ditës së Dytë fleta e plotësuar dorëzohet si foto '
            'te dispeçeri yt përgjegjës. Me këtë Ride Along-u është '
            'formalisht i mbyllur dhe trajnimi yt i dokumentuar.',
          ),
          StepsBlock([
            'Vendose fletën mbi një sipërfaqe të rrafshët, kërko dritë të '
                'mirë.',
            'Fotografoje nga lart, gjithë fleta brenda kuadrit, pa hije dhe '
                'pa skaje të prera.',
            'Kontrollo nëse shenjat, data, emrat dhe nënshkrimet janë të '
                'lexueshme.',
            'Dorëzoje foton te dispeçeri përgjegjës — në rrugën që ju '
                'thotë trajneri.',
            'Trajtoje fletën në letër ashtu si e cakton firma jote: ajo '
                'mund të kërkohet.',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'E palexueshme është si e padorëzuar',
            text: 'Një foto e lëvizur ose gjysmë e prerë duhet bërë nga e '
                'para — dhe atëherë ndoshta jeni të dy tashmë në shtëpi. '
                'Shikoje një herë para se ta dërgosh.',
          ),
          ChecklistBlock(
            title: 'Këtë marr me vete nga përfundimi',
            items: [
              'Pas Ditës së Dytë trajneri jep një vlerësim për performancën '
                  'dhe aftësitë e ngasjes',
              'Për pikat e paqarta pyes konkretisht',
              'Në fletë qëndrojnë data, Emri nxënësit dhe Emri mësuesit',
              'Trajneri nënshkruan veçmas për çdo ditë',
              'Në fund të çdo dite kontrolloj vetë nëse gjithçka është '
                  'shënuar',
              'Fleta dorëzohet në fund të Ditës së Dytë si foto e '
                  'lexueshme te dispeçeri përgjegjës',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ra5',
    title: 'Kështu përgatitesh',
    summary: 'Çfarë duhet sqaruar PARA Ditës së Parë — qasjet, pajisjet, '
        'planifikimi i kohës dhe pyetjet e tua',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Sqaro më parë: qasjet dhe teknika',
        blocks: [
          ParagraphBlock(
            'Arsyeja më e shpeshtë pse një ditë e parë nis keq nuk është '
            'mungesa e njohurive, por një qasje që nuk funksionon. Sqaroje '
            'këtë më parë — atëherë Ride Along-u yt fillon me atë për të '
            'cilën bëhet fjalë.',
          ),
          BulletsBlock([
            'Llogaria jote për shpërndarjen: të dhënat e qasjes ekzistojnë '
                'dhe je futur një herë me sukses',
            'Regjistrimi i kohës i firmës sate (p.sh. Kenjo): qasja e '
                'rregulluar, di si hyn dhe si del',
            'Mentor dhe Flex: aplikacionet e instaluara, hyrja e testuar, '
                'lejet për vendndodhjen dhe lëvizjen të dhëna',
            'CoDriver: i regjistruar, njoftimet e lejuara',
            'Telefoni: i karikuar, memorie e mjaftueshme, kabull karikimi '
                'ose powerbank me vete për në furgon',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Kontrollo në mbrëmje, jo në mëngjes',
            text: 'Rivendosja e një fjalëkalimi zgjat në orën 20 pesë '
                'minuta dhe në orën 6 në Waiting Area gjysmë ore — nëse '
                'gjendet fare dikush.',
          ),
          RevealBlock(
            prompt: 'Rast praktik: Në mëngjesin e Ditës së Parë '
                'aplikacioni yt i shpërndarjes nuk pranon të hyjë. '
                'Trajneri pret, vala po niset. Cili është reagimi më i '
                'mirë?',
            answer: 'Thuaje menjëherë se qasja nuk funksionon — dhe '
                'pikërisht trajnerit, që ai të mund të përfshijë '
                'dispeçerin tënd përgjegjës. Gabimi i afërt është të '
                'vazhdosh të provosh në '
                'heshtje, që të mos dukesh i paaftë. Kjo kushton minutat në '
                'të cilat problemi do të ishte ende i zgjidhshëm, dhe në '
                'fund ngas gjithë ditën përmes llogarisë së trajnerit — me '
                'çka numri minimal i ndalesave përmes llogarisë sate nuk '
                'plotësohet dhe dita në rastin më të keq duhet përsëritur. '
                'Prandaj: njofto herët, thuaj qartë çfarë ke provuar '
                'tashmë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Veshja, pajisjet dhe përpikëria',
        blocks: [
          SubheadBlock('Çfarë vesh'),
          BulletsBlock([
            'Këpucë sigurie: këpucë pune të forta e të mbyllura — jo '
                'atlete, jo sandale',
            'Veshje e përshtatshme për motin: je gjithë ditën jashtë, edhe '
                'kur në mëngjes duket ende thatë',
            'Liri lëvizjeje: hyn dhe del nga mjeti qindra herë',
            'Jeleku reflektues në dorë — ai rri në mjet, por i takon '
                'kokës sate',
          ]),
          SubheadBlock('Çfarë ke me vete'),
          BulletsBlock([
            'Patentën — pa të nuk ngas, as Ditën e Parë',
            'Letërnjoftimin ose dokumentin e qëndrimit, nëse firma e '
                'kërkon',
            'Pije dhe diçka për të ngrënë për pushimin',
            'Stilolaps dhe një bllok të vogël shënimesh ose aplikacion '
                'shënimesh',
          ]),
          SubheadBlock('Përpikëria'),
          ParagraphBlock(
            'Në kohë do të thotë: gati për punë në stacion në fillimin e '
            'turnit, jo duke mbërritur te porta. Llogarit edhe kohën për '
            'parkim, rrugën nëpër oborr dhe Waiting Area. Kush vjen vonë '
            'Ditën e Parë, e shtyn edhe valën e trajnerit — dhe kjo mbetet '
            'në mend.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Rregull praktik për ditët e para',
            text: 'Planifikoje rrugën ashtu që të jesh më mirë pak herët. '
                'Çerekun e orës që fiton e përdor për t\'u orientuar — '
                'tualetet, Waiting Area, vendet e vendosjes.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pyetjet e tua — dhe lista e kontrollit më parë',
        blocks: [
          ParagraphBlock(
            'Ke dy ditë me radhë pranë vetes dikë që di gjithçka që duhet '
            'të dish. Kjo është një situatë që nuk kthehet më kështu. '
            'Gabimi që e bëjnë pothuajse të gjithë: nuk i mbajnë mend '
            'pyetjet e tyre dhe u vijnë ndër mend vetëm në javën e dytë, '
            'vetëm në furgon.',
          ),
          BulletsBlock([
            'Shkruaj që para Ditës së Parë çfarë do të dish — edhe gjërat '
                'e vogla',
            'Shëno gjatë turit përgjigjet, mos u mbështet te kujtesa',
            'Mos fotografo asgjë nga të dhënat e klientëve, por shëno '
                'ecuritë dhe personat e kontaktit',
            'Pyet në fund të çdo dite: „Çfarë nuk kam parë ende sot?"',
          ]),
          ParagraphBlock(
            'Pyetje të mira për Ride Along-un janë për shembull: Kur '
            'saktësisht është dritarja ime e Waiting Area? Ku parkoj '
            'privatisht? Si e njoh nëse Mentor është ende në punë? Ku e '
            'shënoj pushimin tim? Kujt i raportoj i pari një dëm? Ku e '
            'dorëzoj Green Book-un? Çfarë bëj nëse një klient te një pako '
            'me fjalëkalim nuk e ka kodin?',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Pse e bëre këtë trajnim',
            text: 'Jo që të dish gjithçka që në Ride Along, por që t\'i '
                'njohësh konceptet. Kush e di se për çfarë bëhet fjalë, '
                'mund të dëgjojë — kush i dëgjon të gjitha për herë të '
                'parë, mund vetëm të tundë kokën.',
          ),
          RevealBlock(
            prompt: 'Rast praktik: Trajneri shpjegon paradite dhjetë gjëra '
                'njëra pas tjetrës. Në mbrëmje kujton tre prej tyre. Nga '
                'çfarë varet kjo — nga ti?',
            answer: 'Nga metoda, jo nga ti. Të të shpjegohen dhjetë ecuri '
                'të reja njëra pas tjetrës dhe t\'i mbash mend nuk '
                'funksionon te askush. Ajo që funksionon: t\'i kesh lexuar '
                'konceptet një herë më parë — pikërisht për këtë është ky '
                'trajnim — dhe të shënosh gjatë rrugës. Dy fjalë kyçe për '
                'çdo temë mjaftojnë që në mbrëmje ta rithërrasësh gjithë '
                'ecurinë. Dhe atë që mungon ende Ditën e Dytë, e pyet me '
                'qëllim, në vend që të shpresosh se do të kthehet vetvetiu.',
          ),
          ChecklistBlock(
            title: 'Para Ditës së Parë — për t\'u shënuar vetë',
            items: [
              'Të dhënat e qasjes për llogarinë time të shpërndarjes të '
                  'testuara',
              'Regjistrimi i kohës (p.sh. Kenjo), Mentor, Flex dhe CoDriver '
                  'të instaluara dhe me hyrje të bërë',
              'Telefoni i karikuar, kabulli i karikimit ose powerbank i '
                  'marrë',
              'Këpucët e sigurisë dhe veshja për motin të përgatitura',
              'Patenta dhe dokumentet e nevojshme në xhep',
              'Pija dhe ushqimi për pushimin të përgatitura',
              'Stilolapsi dhe mundësia për shënime me vete',
              'Rruga e planifikuar — përfshirë parkimin dhe rrugën deri te '
                  'Waiting Area',
              'Pyetjet e mia për trajnerin të shkruara',
              'Ky trajnim i punuar deri në fund, që t\'i njoh konceptet',
            ],
          ),
        ],
      ),
    ],
  ),
];
