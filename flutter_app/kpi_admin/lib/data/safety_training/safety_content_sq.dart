// lib/data/safety_training/safety_content_sq.dart
//
// Përmbajtja e udhëzimit të sigurisë — versioni shqip.
// Struktura është identike me versionin gjerman (master).

import 'safety_blocks.dart';

const String _a = 'assets/academy/safety/';

const List<SafetyChapterContent> safetyContentSq = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ch01',
    title: 'Bazat ligjore dhe detyrimet e tua',
    summary: 'Pse ekziston siguria në punë — dhe çfarë duhet të japësh ti',
    asset: '${_a}ch01_grundlagen.svg',
    slides: [
      SafetySlide(
        title: 'Mbi çfarë ndërtohet siguria në punë',
        asset: '${_a}ch01_grundlagen.svg',
        blocks: [
          ParagraphBlock(
            'Siguria në punë nuk është një ofertë vullnetare e '
            'punëdhënësit tënd, por është e detyrueshme me ligj. Ajo '
            'mbështetet në dy shtylla: të drejtën shtetërore dhe rregullat '
            'e institucioneve të sigurimit ndaj aksidenteve.',
          ),
          BulletsBlock([
            'Arbeitsschutzgesetz (ArbSchG) — ligji për sigurinë në punë; '
                'rregullon detyrimet e punëdhënësit si dhe të drejtat e '
                'detyrimet e punonjësve',
            'Rregulloret — e konkretizojnë ligjin, p.sh. rregulloret për '
                'vendet e punës, për sigurinë e mjeteve të punës dhe për '
                'substancat e rrezikshme',
            'DGUV Vorschriften — rregulla të detyrueshme të shoqatës '
                'profesionale, të detyrueshme për ty si i siguruar',
            'DGUV Regeln dhe Informationen — ndihma zbatimi dhe '
                'rekomandime, jo të detyrueshme, por të provuara në '
                'praktikë',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Dallimi që ka rëndësi',
            text: 'DGUV Vorschriften janë të detyrueshme. DGUV Regeln '
                'tregojnë si zbatohen. DGUV Informationen janë rekomandime.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Gjashtë detyrimet e tua si punonjës',
        blocks: [
          ParagraphBlock(
            'Punëdhënësi duhet të të mbrojë — ti duhet të bashkëpunosh. '
            'Këto detyrime vlejnë për çdo punonjës, pavarësisht nga '
            'pozicioni dhe kontrata.',
          ),
          StepsBlock([
            'Kujdesu për sigurinë tënde dhe atë të kolegëve',
            'Zbato udhëzimet e punës dhe trajnimet',
            'Jep ndihmën e parë ose mbështet ndihmën e parë efektive',
            'Raporto aksidentet dhe gati-aksidentet — edhe të vegjlit',
            'Raporto menjëherë defektet dhe të metat (kabllo të prishura, '
                'pajisje të dëmtuara, procese të gabuara)',
            'Përdor pajisjet mbrojtëse sipas destinacionit — këpucë '
                'sigurie, doreza, jelek reflektues, mbrojtëse veshi',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Alkooli, droga, ilaçet',
            text: 'Nuk guxon të rrezikosh veten dhe të tjerët me substanca '
                'dehëse. Kjo vlen për të gjithë kohën e punës — edhe në '
                'pushim, sepse pas tij do të ngasësh sërish. Këtu hyjnë '
                'edhe ilaçet që të bëjnë të përgjumur: në rast dyshimi '
                'pyet mjekun tënd.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ch02',
    title: 'Udhëzimet e punës',
    summary: 'Udhëzime të detyrueshme — dhe pse të mbrojnë ty',
    asset: '${_a}ch02_betriebsanweisungen.svg',
    slides: [
      SafetySlide(
        title: 'Çfarë është një udhëzim pune',
        asset: '${_a}ch02_betriebsanweisungen.svg',
        blocks: [
          ParagraphBlock(
            'Një udhëzim pune është një urdhër i detyrueshëm i '
            'punëdhënësit tënd për përdorimin e automjeteve, mjeteve të '
            'punës dhe substancave të rrezikshme. Nuk është rekomandim.',
          ),
          BulletsBlock([
            'Është e afishuar në firmë — duhet ta njohësh',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Këtë duhet ta dish',
            text: 'Kush shkel një udhëzim pune, mund t\'i ngarkohet '
                'përgjegjësia gjatë hetimit të aksidentit. Në rastin më të '
                'keq kjo do të thotë bashkëpërgjegjësi për një aksident — '
                'edhe për ty personalisht.',
          ),
          ParagraphBlock(
            'Dallimi: udhëzimi i punës rregullon përdorimin e një mjeti '
            'pune ose të një substance të rrezikshme. Udhëzimi i procesit '
            'rregullon rrjedhën e një procesi pune.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Struktura — gjashtë pjesë',
        blocks: [
          ParagraphBlock(
            'Çdo udhëzim pune ka të njëjtën strukturë. Nëse e njeh '
            'strukturën, në rast urgjence e gjen menjëherë vendin e duhur.',
          ),
          StepsBlock([
            'Fusha e zbatimit — për çfarë dhe për kë vlen',
            'Rreziqet për njeriun dhe mjedisin',
            'Masat mbrojtëse dhe rregullat e sjelljes',
            'Sjellja në rast defektesh',
            'Sjellja në rast aksidentesh dhe ndihma e parë',
            'Asgjësimi dhe mirëmbajtja',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Shembull: ngasja me furgon',
        blocks: [
          ParagraphBlock(
            'Kështu duken rregullat konkrete nga një udhëzim pune për '
            'automjete deri në 3,5 t:',
          ),
          BulletsBlock([
            'Mbaj me vete patentën e vlefshme',
            'Pa alkool dhe pa drogë para dhe gjatë ngasjes',
            'Ngasje mbrapsht me rrezik vetëm me një person që të drejton',
            'Mbylle gjithmonë automjetin me çelës pasi e lë',
            'Tërheqje vetëm me shufër tërheqëse',
            'Siguro vendin e aksidentit, raporto menjëherë çdo aksident',
            'Trajto menjëherë edhe lëndimet e vogla dhe shënoji në librin '
                'e ndihmës së parë',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Në dyshim pyet',
            text: 'Nëse një udhëzim nuk të është i qartë, pyet dispeçerin '
                'tënd — para se të nisesh, jo pasi.',
          ),
          SubheadBlock('Udhëzimet më të rëndësishme'),
          ParagraphBlock(
            'Të gjitha udhëzimet e punës i gjen në çdo kohë në DA Academy '
            'te „Betriebsanweisungen".',
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
    title: '10 rregullat për punë të sigurt',
    summary: 'Thelbi i ditës sate të punës — i vlefshëm çdo ditë',
    asset: '${_a}ch03_sicheres_arbeiten.svg',
    slides: [
      SafetySlide(
        title: 'Dhjetë rregulla, çdo ditë',
        asset: '${_a}ch03_sicheres_arbeiten.svg',
        blocks: [
          StepsBlock([
            'Punë e sigurt dhe e kujdesshme',
            'Kontrolli i automjetit para nisjes',
            'Sigurimi i ngarkesës në automjet',
            'Ngasje profesionale dhe respektim i rregullave të qarkullimit',
            'Vendosja e rripit të sigurimit',
            'Mbajtja në rregull e automjeteve, veglave dhe pajisjeve',
            'Punë vetëm me këpucë të përshtatshme',
            'Sjellje e sjellshme me kolegët dhe klientët',
            'Respektimi i rregullave të pushimeve',
            'Sjellje tolerante dhe me respekt',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Të tria me efektin më të madh',
            text: 'Kontrolli para nisjes, sigurimi i ngarkesës, rripi i '
                'sigurimit. Këto të tria parandalojnë pjesën më të madhe '
                'të pasojave të rënda — dhe së bashku nuk kushtojnë as tre '
                'minuta.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ch04',
    title: 'Pajisjet personale mbrojtëse (PSA)',
    summary: 'Këpucët e sigurisë dhe jeleku — detyra jote e përditshme',
    asset: '${_a}ch04_psa.svg',
    slides: [
      SafetySlide(
        title: 'PSA jote si shpërndarës',
        asset: '${_a}ch04_psa.svg',
        blocks: [
          ParagraphBlock(
            'Pajisje personale mbrojtëse është gjithçka që mban në trup '
            'për t\'u mbrojtur nga rreziqet. Në shpërndarje dy pjesë janë '
            'të detyrueshme çdo ditë:',
          ),
          FactsBlock([
            FactItem('1', 'Këpucë sigurie'),
            FactItem('2', 'Jelek reflektues'),
          ]),
          BulletsBlock([
            'Këpucët e sigurisë — gjithë ditën e punës, si në stacion '
                'ashtu edhe në rrugë',
            'Jeleku reflektues — gati në automjet dhe i veshur para se të '
                'zbresësh në rast defekti, aksidenti ose ndalese në rrugë',
          ]),
          SubheadBlock('PSA të tjera — sipas punës'),
          ParagraphBlock(
            'Këto pajisje nuk janë të detyrueshme çdo ditë, por mund të '
            'nevojiten për punë të caktuara. Çfarë vlen për ty, shkruhet '
            'në vlerësimin e rrezikut dhe në udhëzimin e punës.',
          ),
          BulletsBlock([
            'Doreza mbrojtëse — te dërgesat me tehe të mprehta, te punët '
                'e pastrimit dhe të mirëmbajtjes, në dimër',
            'Mbrojtëse veshi — te zhurma, p.sh. në disa zona të hallës',
            'Syze mbrojtëse — te punët me rrezik spërkatjeje',
            'Mbrojtëse koke — në kantiere dhe kur ka rrezik nga objekte '
                'që bien',
            'Veshje kundër motit — te puna e vazhdueshme në ambient të '
                'hapur',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Detyrim përdorimi',
            text: 'PSA-në që ta jep punëdhënësi duhet ta përdorësh sipas '
                'destinacionit (§ 15 Arbeitsschutzgesetz). Punëdhënësi e '
                'jep falas dhe duhet të mbikëqyrë respektimin.',
          ),
          InstructionRefBlock(['baw_sicherheitsschuhe', 'baw_warnweste']),
        ],
      ),
      SafetySlide(
        title: 'Këpucët e sigurisë: efekti mbrojtës',
        blocks: [
          ParagraphBlock(
            'Mbrojtja e këmbëve është PSA që të duhet më shpesh — dhe që '
            'nënvlerësohet më shpesh.',
          ),
          SubheadBlock('Nga çfarë të mbrojnë'),
          BulletsBlock([
            'Mekanikisht — përplasje, shtypje, pako që bien, shkelje mbi '
                'objekte të mprehta',
            'Nga përdredhja — këpucët deri te kyçi e mbështesin nyjen dhe '
                'parandalojnë këputje ligamentesh e lëndime të kyçit',
            'Elektrikisht — shkarkim antistatik',
            'Kimikisht — acide, vajra, karburante',
            'Termikisht — nxehtësi dhe të ftohtë',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Pse deri te kyçi',
            text: 'Lëndimi më i shpeshtë në shpërndarje është përdredhja e '
                'këmbës kur zbret, mbi trotuare dhe rrugë të pabarabarta. '
                'Një këpucë deri te kyçi e mbështet nyjen pikërisht aty ku '
                'ajo përdridhet — një këpucë e ulët nuk e bën këtë.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Edhe kur janë të pakëndshme — edhe në verë',
            text: 'Detyrimi për t\'i mbajtur vlen çdo ditë pune, '
                'pavarësisht nga moti dhe rehatia. Pikërisht në verë '
                'ndërrohen — dhe pikërisht atëherë ndodhin lëndimet. Nëse '
                'këpucët shtrëngojnë ose gërvishtin, kjo është arsye për '
                'një model tjetër, jo arsye për atlete.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Kontrollo rregullisht këpucët',
            text: 'Profil i konsumuar, çarje ose ndotje e fortë: kërko '
                't\'i ndërrosh. Mos bëj vetë ndryshime dhe kurrë mos puno '
                'me atlete — as „vetëm për pak".',
          ),
        ],
      ),
      SafetySlide(
        title: 'Klasat e mbrojtjes në një pamje',
        blocks: [
          TableBlock(
            headers: ['Klasa', 'Vetitë'],
            rows: [
              [
                'S1',
                'Zonë e mbyllur e thembrës, antistatike, shollë '
                    'rezistente ndaj karburantit',
              ],
              ['S2', 'si S1 + së paku 60 minuta e papërshkueshme nga uji'],
              ['S3', 'si S2 + shollë kundër shpimit dhe me profil'],
              ['S4', 'si S2, tërësisht prej gome (e vulkanizuar)'],
              ['S5', 'si S4 + shollë kundër shpimit'],
            ],
          ),
          SubheadBlock('Kur janë veçanërisht të rëndësishme'),
          BulletsBlock([
            'Në shkallë, stola hipjeje dhe shkallare',
            'Te kontejnerët me rrota dhe karrocat hidraulike me dorë',
            'Në rrugë të pabarabarta dhe në rampa',
          ]),
          ParagraphBlock(
            'Tiparet e një këpuce të mirë: qëndrim i fortë, e mbyllur, '
            'mbajtje e thembrës me amortizim, shollë e lakueshme, takë e '
            'ulët, profil kundër rrëshqitjes.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ch05',
    title: 'Sjellja në rast zjarri',
    summary: 'Përdor drejt fikësen dhe menaxho zjarrin në automjet',
    asset: '${_a}ch05_brandfall.svg',
    slides: [
      SafetySlide(
        title: 'Përdorimi i fikëses së zjarrit',
        asset: '${_a}ch05_brandfall.svg',
        blocks: [
          ParagraphBlock(
            'Ka fikëse me pluhur, me ujë/shkumë dhe me CO₂. Përdorimi '
            'është i njëjtë te të gjitha:',
          ),
          StepsBlock([
            'Hiq sigurinë',
            'Shtyp butonin goditës',
            'Shtyp pistoletën e fikjes',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Ke vetëm sekonda',
            text: 'Një fikëse zbrazet më shpejt seç mendojnë shumica. '
                'Prandaj: më mirë përdor disa fikëse njëkohësisht sesa '
                'njërën pas tjetrës.',
          ),
          FactsBlock([
            FactItem('6–12 s', 'Pluhur 1–2 kg'),
            FactItem('15–23 s', 'Pluhur 6 kg'),
            FactItem('18–33 s', 'Pluhur 12 kg'),
            FactItem('20–30 s', 'Shkumë 6 l'),
            FactItem('5–10 s', 'CO₂ 2 kg'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Fikje e drejtë — hap pas hapi',
        blocks: [
          ParagraphBlock(
            'Radha vendos nëse zjarri fiket apo ndizet sërish. Gjashtë '
            'hapa që duhet t\'i mbash mend:',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}fire01_pin.svg',
              title: 'Përgatit fikësen',
              caption: 'Tërhiq sigurinë, shtyp butonin goditës, mbaje '
                  'fikësen drejt. Vetëm pastaj shko te zjarri.',
            ),
            IllustratedStep(
              asset: '${_a}fire02_wind.svg',
              title: 'Sulmo në drejtim të erës',
              caption: 'Era duhet të jetë pas shpinës sate dhe të çojë '
                  'mjetin fikës në zjarr — kurrë mos fik kundër erës. '
                  'Kështu nxehtësia dhe tymi rrinë larg teje.',
            ),
            IllustratedStep(
              asset: '${_a}fire03_surface.svg',
              title: 'Zjarr sipërfaqësor: fillo nga përpara',
              caption: 'Synoje buzën e përparme të flakëve, brenda në '
                  'prush — jo majat e flakëve. Pastaj puno copë-copë drejt '
                  'pjesës së pasme.',
            ),
            IllustratedStep(
              asset: '${_a}fire04_drip.svg',
              title: 'Zjarr që pikon: nga lart poshtë',
              caption: 'Nëse lëngu i ndezur rrjedh poshtë, fillo lart te '
                  'vendi ku del dhe puno drejt poshtë — përndryshe digjet '
                  'gjithmonë sërish nga lart.',
            ),
            IllustratedStep(
              asset: '${_a}fire05_together.svg',
              title: 'Disa fikëse njëkohësisht',
              caption: 'Nëse ka disa fikëse dhe ndihmës: përdorini bashkë '
                  'dhe në të njëjtën kohë. Njëra pas tjetrës i jep zjarrit '
                  'kohë të marrë veten mes fikëseve.',
            ),
            IllustratedStep(
              asset: '${_a}fire06_watch.svg',
              title: 'Vëzhgo vendin e zjarrit',
              caption: 'Pas fikjes qëndro aty dhe vëzhgo. Vatrat e prushit '
                  'ndizen shpesh sërish pas disa minutash — rri në '
                  'distancë me fikësen gati për përdorim.',
            ),
            IllustratedStep(
              asset: '${_a}fire07_refill.svg',
              title: 'Mbush sërish fikësen e përdorur',
              caption: 'Një fikëse e përdorur nuk kthehet kurrë në mur — '
                  'as pas një shtytjeje të shkurtër. Jepe menjëherë për '
                  'rimbushje dhe njofto për zëvendësimin.',
            ),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Kur nuk fik',
            text: 'Mos e vër kurrë veten në rrezik. Nëse zjarri është më i '
                'madh se një kosh letrash, del shumë tym ose rrezikon '
                'rrugën e ikjes: dil, mbyll derën, thirr 112 dhe '
                'paralajmëro të tjerët.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Zjarr në automjet',
        blocks: [
          SubheadBlock('Shkaqet më të shpeshta'),
          BulletsBlock([
            'Rrjedhje karburanti ose vaji',
            'Material izolues në pjesë të nxehta',
            'Dëmtime mekanike',
            'Defekte elektrike',
            'Kontejnerë mbeturinash që digjen',
          ]),
          SubheadBlock('Çfarë bën ti'),
          StepsBlock([
            'Mos ndalo në tunele ose mbi ura — nëse mundesh, dil jashtë '
                'tyre',
            'Ndiz dritat e rrezikut, gjej një vend të përshtatshëm, ndalo',
            'Dil nga automjeti, mbaj distancë',
            'Njofto zjarrfikësen 112 — trego vendndodhjen bashkë me '
                'drejtimin e lëvizjes',
            'Vetëm pastaj provo të fikësh vetë, nëse është e sigurt',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Kapaku i motorit: kujdes',
            text: 'Hape vetëm me doreza dhe vetëm pak. Nga futja e '
                'papritur e oksigjenit mund të dalin flakë të forta.',
          ),
          SubheadBlock('Çfarë duhet të dijë qendra e thirrjeve'),
          BulletsBlock([
            'Ku po digjet?',
            'Çfarë digjet dhe në ç\'përmasa?',
            'Sa të lënduar ka, çfarë lëndimesh?',
            'Çfarë ke të ngarkuar?',
            'Kush po lajmëron?',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Mos e mbyll telefonin',
            text: 'Kurrë mos e mbyll vetë bisedën. Prit pyetjet e '
                'mëtejshme — qendra e thirrjeve e mbyll bisedën.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'ch06',
    title: 'Ndihma e parë',
    summary: 'Detyra jote, mbrojtja jote dhe dokumentimi',
    asset: '${_a}ch06_erste_hilfe.svg',
    slides: [
      SafetySlide(
        title: 'Të ndihmosh është detyrim — dhe je i mbrojtur',
        asset: '${_a}ch06_erste_hilfe.svg',
        blocks: [
          ParagraphBlock(
            'Secili është i detyruar të japë ndihmën e parë — brenda asaj '
            'që është e arsyeshme dhe pa e rrezikuar rëndë veten. Edhe si '
            'jo-profesionist.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 323c StGB — mosdhënia e ndihmës',
            text: 'Kush nuk ndihmon, edhe pse do të ishte e arsyeshme, '
                'kryen vepër penale: deri në një vit burg ose gjobë. Kjo '
                'vlen edhe për kureshtarët që pengojnë ndihmuesit.',
          ),
          SubheadBlock('Kush ndihmon, nuk gabon'),
          BulletsBlock([
            'Si ndihmues i parë nuk përgjigjesh për gabime — përveç në '
                'rast dashjeje ose pakujdesie të rëndë',
            'Gjatë dhënies së ndihmës je i siguruar me ligj ndaj '
                'aksidenteve',
            'Shpenzimet nuk i mban ti; dëmet materiale zakonisht '
                'zëvendësohen',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Gabimi i vetëm i vërtetë',
            text: 'Të mos bësh asgjë. Çdo gjë tjetër është më mirë sesa ta '
                'kthesh kokën mënjanë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ndihmuesit e parë në stacion — dhe ti',
        blocks: [
          ParagraphBlock(
            'Në stacion ka ndihmues të parë të trajnuar. Për këtë kujdeset '
            'sipërmarrësi: organizimi i ndihmës së parë është detyra e tij '
            '(§ 24 DGUV Vorschrift 1), dhe ai duhet të sigurojë një numër '
            'minimal ndihmuesish të trajnuar (§ 26 DGUV Vorschrift 1).',
          ),
          FactsBlock([
            FactItem('1', 'ndihmues për 2–20 të pranishëm'),
            FactItem('10 %', 'e të pranishmëve në firma të tjera'),
            FactItem('2 vjet', 'rifreskim i trajnimit të ndihmuesve'),
          ]),
          ParagraphBlock(
            'Nëse punojnë disa punëdhënës në të njëjtin territor, ata '
            'duhet të koordinohen dhe të informojnë njëri-tjetrin '
            '(§ 8 Arbeitsschutzgesetz). Aty mund të merret vesh që të '
            'përdoret bashkërisht organizimi i ndihmës së parë i '
            'stacionit. Kjo rregullon bashkëpunimin e firmave — jo '
            'detyrimin tënd personal.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Kjo nuk të liron',
            text: 'Detyrimi për të ndihmuar sipas § 323c StGB i takon '
                'secilit personalisht. Ndihmuesit e trajnuar në stacion '
                'nuk e ndryshojnë këtë.',
          ),
          SubheadBlock('Si trajtohet kjo ligjërisht'),
          BulletsBlock([
            'Nëse dikush është tashmë aty dhe po ndihmon vërtet '
                'mjaftueshëm, ti nuk ke pse të veprosh vetë',
            'Detyrimi për të alarmuar shërbimin e shpëtimit dhe për të '
                'sjellë ndihmë mbetet gjithsesi',
            'Duhet të sigurohesh që po ndihmohet vërtet — ta kthesh kokën '
                'mënjanë me mendimin „dikush do të kujdeset" nuk mjafton',
            'Mbështet sipas udhëzimit të ndihmuesit: siguro vendin, prit '
                'dhe drejto shërbimin e shpëtimit, sill materialin, mbaj '
                'larg të tjerët',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Në rrugë je vetëm',
            text: 'Pjesën më të madhe të kohës së punës nuk je në stacion, '
                'por në rrugë. Atje nuk ka ndihmues të stacionit — në një '
                'urgjencë gjatë turit ndihmuesi i parë je ti.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Si bëhet thirrja e urgjencës',
        blocks: [
          FactsBlock([
            FactItem('112', 'numri i urgjencës, në gjithë Evropën'),
          ]),
          SubheadBlock('Pesë pyetjet'),
          StepsBlock([
            'Ku ndodhi?',
            'Sa persona janë lënduar?',
            'Çfarë ndodhi?',
            'Kush po telefonon?',
            'Prit pyetjet e mëtejshme',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Rregullat bazë kur ndihmon',
            text: 'Ruaj qetësinë · vepro shpejt · kujdesu për sigurinë '
                'tënde · siguro vendin e aksidentit · ndihmo sipas '
                'njohurive më të mira.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dokumentimi dhe raportimi',
        blocks: [
          ParagraphBlock(
            'Çdo lëndim dokumentohet — edhe prerja e vogël. Kjo të mbron '
            'ty, nëse më vonë dalin pasoja.',
          ),
          SubheadBlock('Në librin e ndihmës së parë shënohen'),
          BulletsBlock([
            'Koha dhe vendi',
            'Rrjedha e ngjarjes',
            'Lloji dhe shkalla e lëndimit',
            'Emri i personit të lënduar',
            'Dëshmitarët dhe ndihmuesit e parë',
          ]),
          FactsBlock([
            FactItem('> 3 ditë', 'paaftësi → nevojitet njoftim aksidenti'),
            FactItem('3 ditë', 'afati për njoftimin'),
            FactItem('5 vjet', 'ruajtje, në mënyrë konfidenciale'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Raporto menjëherë',
            text: 'Aksidentet me vdekje, aksidentet masive dhe dëmtimet e '
                'rënda shëndetësore i raporton sipërmarrësi pa vonesë — '
                'prandaj informoje gjithmonë menjëherë punëdhënësin tënd.',
          ),
          ParagraphBlock(
            'Kutitë e ndihmës së parë duhet të jenë të plota. Kontrollo '
            'datën e skadimit dhe raporto materialin që mungon.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 7
  SafetyChapterContent(
    id: 'ch07',
    title: 'Ulja dhe lëvizja',
    summary: 'Kurse kurrizin, ruaj përqendrimin',
    asset: '${_a}ch07_sitzen_bewegen.svg',
    slides: [
      SafetySlide(
        title: 'Pse ulja bëhet rrezik',
        asset: '${_a}ch07_sitzen_bewegen.svg',
        blocks: [
          ParagraphBlock(
            'Ulja e gjatë dhe e rregulluar keq është më shumë se e '
            'pakëndshme — të kushton vëmendje dhe kohë reagimi.',
          ),
          BulletsBlock([
            'Lodhje dhe rënie e përqendrimit',
            'Tension dhe dhimbje kurrizi',
            'Ankesa te qafa dhe te pjesa e poshtme e shtyllës kurrizore',
            'Aksidente nga reagimi i vonuar',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Rregullo drejt ndenjësen',
        blocks: [
          ParagraphBlock(
            'Merr dy minuta para udhëtimit të parë. Shtatë rregullime '
            'vendosin:',
          ),
          StepsBlock([
            'Lartësia e ndenjëses dhe pozicioni para-mbrapa',
            'Thellësia e sipërfaqes së ndenjëses',
            'Pjerrësia e sipërfaqes së ndenjëses',
            'Pjerrësia e mbështetëses së shpinës',
            'Mbështetja e mesit',
            'Mbështetësja e kokës',
            'Timoni dhe kalimi i rripit',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ulje dinamike',
            text: 'Kurrizin plotësisht te mbështetësja, ulu drejt — dhe '
                'ndrysho herë pas here lehtë qëndrimin. Pozicioni më i '
                'mirë i uljes është ai i ardhshmi.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ushtrime për mes punës',
        blocks: [
          SubheadBlock('Ulur'),
          BulletsBlock([
            'Tërhiq fort timonin nga të dyja anët — mbaj 3–6 sekonda, '
                '3 përsëritje',
            'Shtyp gjunjët kundër shtypjes së duarve — 3–6 sekonda, '
                '5 përsëritje',
            'Mbështetu në sipërfaqen e ndenjëses dhe ngri peshën — '
                '3 përsëritje',
          ]),
          SubheadBlock('Në këmbë'),
          BulletsBlock([
            'Shtri krahët lart — rreth 8 sekonda, 3–5 përsëritje',
            'Duart pas kokës, bërrylat prapa — rreth 8 sekonda, '
                '3–5 përsëritje',
            'Thembrën mbi një lartësi rreth 30 cm, shtri këmbën — rreth '
                '8 sekonda, 2–3 herë për çdo këmbë',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Një kurriz i stërvitur duron më shumë',
            text: 'Përdor kohën e pushimit — jo kohë shtesë.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 8
  SafetyChapterContent(
    id: 'ch08',
    title: 'Ngarkesa dhe përqendrimi',
    summary: 'I aftë dhe i vëmendshëm gjatë gjithë ditës',
    asset: '${_a}ch08_psychische_belastung.svg',
    slides: [
      SafetySlide(
        title: 'Pse kjo i takon sigurisë në punë',
        asset: '${_a}ch08_psychische_belastung.svg',
        blocks: [
          ParagraphBlock(
            'Kush është nën presion, reagon më ngadalë, sheh më pak dhe '
            'bën gabime. Pikërisht prandaj ngarkesa është temë sigurie — '
            'jo vetëm atëherë kur dikush sëmuret.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'E parashikuar me ligj',
            text: 'Që nga viti 2013 vlerësimi i rrezikut duhet të marrë '
                'parasysh shprehimisht edhe ngarkesat psikike në punë '
                '(§ 5 Abs. 3 Nr. 6 Arbeitsschutzgesetz). Vlerësohen '
                'kushtet e punës — jo personat e veçantë.',
          ),
          SubheadBlock('Çfarë krijon presion në përditshmërinë e ngasjes'),
          BulletsBlock([
            'Afate të ngushta, trafik, kantiere, kërkim vendparkimi',
            'Përgjegjësi të paqarta te ngarkimi dhe shkarkimi',
            'Informacione që mungojnë ose vijnë vonë për turin',
            'Probleme teknike te automjeti ose te pajisja',
            'Situata të vështira me klientët',
          ]),
          ParagraphBlock(
            'Këto janë kushte që firma mund t\'i ndryshojë. Prandaj '
            'rregulli më i rëndësishëm është: raporto, sa kohë që ende '
            'mund të zgjidhet.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Të mbetesh i përqendruar — praktikisht',
        blocks: [
          SubheadBlock('Gjatë turit'),
          BulletsBlock([
            'Përdor pushimet si mjet: dil pak jashtë, shiko larg, ec disa '
                'hapa — kjo e rikthen vëmendjen në mënyrë të matshme',
            'Pi mjaftueshëm ujë dhe ha rregullisht',
            'Mos manovro nën presion kohe — dy minuta kushtojnë më lirë se '
                'një dëm në llamarinë',
            'Përdore telefonin vetëm kur je ndalur, adresën futeje para '
                'nisjes',
            'Pas kontakteve të vështira me klientët merr frymë thellë para '
                'se të vazhdosh',
          ]),
          SubheadBlock('Fol herët në vend që ta durosh'),
          ParagraphBlock(
            'Nëse diçka nuk shkon vazhdimisht, thuaja dispeçerit tënd — '
            'herët dhe konkretisht. Një tur që rregullisht nuk arrihet, '
            'një automjet që bën probleme, një rrugë me mungesë të '
            'vazhdueshme vendparkimi: kjo mund të planifikohet, nëse dikush '
            'e di.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Raportimi konkret ndihmon më shumë se durimi',
            text: 'Thuaj çfarë saktësisht nuk shkon dhe ku — jo vetëm që '
                'ishte stresuese. Sa më konkret raportimi, aq më shumë '
                'ka gjasa të ndryshojë diçka në planifikim.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pas ngjarjeve të veçanta',
        blocks: [
          ParagraphBlock(
            'Disa situata lënë gjurmë: një aksident i rëndë, një grabitje, '
            'një ndërhyrje me ndihmë të parë me persona rëndë të lënduar. '
            'Ky është reagim normal ndaj një ngjarjeje jonormale — dhe nuk '
            'është shenjë dobësie.',
          ),
          BulletsBlock([
            'Raportoja ngjarjen eprorit tënd, edhe nëse ty vetë nuk të ka '
                'ndodhur asgjë',
            'Pas aksidenteve në punë ka oferta mbështetjeje përmes '
                'shoqatës profesionale',
            'Shumë firma kanë ndihmues të parë psikologjikë ose '
                'udhërrëfyes për traumat — pyet në zyrë',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Në urgjencë akute',
            text: 'Në një krizë akute shpirtërore në Gjermani: '
                'Telefonseelsorge 0800 111 0 111 — falas, anonim, i '
                'arritshëm 24 orë në ditë.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 9
  SafetyChapterContent(
    id: 'ch09',
    title: 'Ngasje e sigurt dhe kontrolli para nisjes',
    summary: 'Dy minuta kontroll para çdo turi',
    asset: '${_a}ch09_sicheres_fahren.svg',
    slides: [
      SafetySlide(
        title: 'Rrotullimi rreth automjetit',
        asset: '${_a}ch09_sicheres_fahren.svg',
        blocks: [
          ParagraphBlock(
            'Para çdo nisjeje kontrolli i automjetit është i detyrueshëm. '
            'Zgjat dy minuta dhe gjen pikërisht ato të meta që rrugës '
            'bëhen të shtrenjta ose të rrezikshme.',
          ),
          BulletsBlock([
            'Ndriçimi para dhe prapa',
            'Pamja — pasqyrat dhe xhamat të pastra dhe pa dëmtime',
            'Rrotat — presioni i ajrit, profili, fiksimi',
            'Frenat — provë frenimi, presioni i frenave',
            'Motori dhe transmisioni — vaji, lëngu ftohës dhe i frenave, '
                'uji i xhamave, pa rrjedhje',
            'Mbulesat dhe dyert të mbyllura',
            'Targat dhe tabelat paralajmëruese të pastra',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Ngarkesa dhe vendi i punës së shoferit',
        blocks: [
          SubheadBlock('Sigurimi i ngarkesës'),
          BulletsBlock([
            'A është automjeti i përshtatshëm për këtë ngarkesë?',
            'A janë rripat lidhës të padëmtuar?',
            'A është ngarkesa e siguruar dhe e mbrojtur nga rrëshqitja?',
            'A respektohen ngarkesat për bosht dhe masa e lejuar totale?',
          ]),
          SubheadBlock('Vendi yt i punës'),
          BulletsBlock([
            'Ndenjësja dhe timoni të rregulluar drejt',
            'Pajisjet e kontrollit pa sinjalizim defekti',
            'Prova e frenave pa vërejtje',
            'Sistemet ndihmëse të ngasjes të ndezura dhe gati',
            'Ajrimi funksional',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Në dimër gjithashtu',
            text: 'Goma të përshtatshme, sipas nevojës zinxhirë bore ose '
                'ndihmesa nisjeje, mjaftueshëm antifriz në lëngun ftohës '
                'dhe në ujin e xhamave, kruajtëse akulli në bord.',
          ),
          InstructionRefBlock(['baw_transporter', 'baw_winter']),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 10
  SafetyChapterContent(
    id: 'ch10',
    title: 'Defekte dhe aksidente',
    summary: 'Siguro, ndihmo, dokumento drejt',
    asset: '${_a}ch10_pannen_unfaelle.svg',
    slides: [
      SafetySlide(
        title: 'Rregulli bazë dhe defekti',
        asset: '${_a}ch10_pannen_unfaelle.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Rregulli bazë',
            text: 'Mbrojtja e vetes vjen para mbrojtjes së të tjerëve. '
                'Mbrojtja e personave vjen para mbrojtjes së sendeve.',
          ),
          SubheadBlock('Kur po vjen një defekt'),
          StepsBlock([
            'Kërko herët një vend të përshtatshëm ndalimi — p.sh. kur '
                'rritet temperatura e ujit ftohës',
            'Ndiz dritat e rrezikut që kur je duke ngadalësuar',
            'Nëse mundesh, shko te parkingu më i afërt, përndryshe në '
                'skajin e djathtë të rrugës',
            'Tërhiq frenën e dorës, në errësirë ndiz dritat e pozicionit',
            'Vish jelekun reflektues — para se të dalësh',
            'Vendos trekëndëshin paralajmërues',
          ]),
          FactsBlock([
            FactItem('100 m', 'trekëndëshi, rrugë ndërurbane'),
            FactItem('150–400 m', 'trekëndëshi, autostradë'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Plani i urgjencës në një aksident',
        blocks: [
          StepsBlock([
            'Ndalo — gjithmonë, edhe nëse nuk ka njeri aty',
            'Siguro vendin e aksidentit — dritat e rrezikut, frena e '
                'dorës, në errësirë dritat e pozicionit, jeleku para se të '
                'dalësh, trekëndëshi',
            'Jep ndihmën e parë — pa vonesë',
            'Bëj thirrjen e urgjencës 112 — në raste urgjente edhe para '
                'ndihmës së parë',
            'Shkëmbe të dhënat personale — emër, adresë, targë, sigurim',
            'Thirr policinë — te lëndimet e personave, te dëmi i lartë '
                'material ose te dyshimi për alkool/drogë',
            'Siguro provat — foto të vendit të aksidentit dhe të dëmeve, '
                'kontaktet e dëshmitarëve',
            'Informo punëdhënësin dhe bisedo për hapat e mëtejshëm, '
                'kontrollo aftësinë për të ngarë, mblidh sërish '
                'trekëndëshin',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Dëmi në parkim dhe lëndimi më i shpeshtë',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Një letër nuk mjafton',
            text: 'Nëse godet një makinë të parkuar dhe nuk ka njeri aty: '
                'prit së paku 30 minuta. Pastaj lër emrin dhe adresën DHE '
                'raporto aksidentin pa vonesë në stacionin më të afërt të '
                'policisë. Përndryshe është largim nga vendi i aksidentit.',
          ),
          SubheadBlock('Ku lëndohen vërtet shoferët'),
          FactsBlock([
            FactItem('51,6 %', 'rrëshqitje dhe rënie'),
            FactItem('7,2 %', 'aksidente trafiku'),
          ]),
          ParagraphBlock(
            'Shumica e aksidenteve që raportohen nuk ndodhin në trafik, '
            'por gjatë hipjes dhe zbritjes nga kabina ose nga zona e '
            'ngarkesës.',
          ),
          DoDontBlock(
            doTitle: 'Drejt',
            dos: [
              'Përdor shkallët dhe dorezat e parashikuara',
              'Kontakt në tre pika kur hyn dhe kur del',
              'Mbaji shkallët e pastra dhe të lira',
              'Mbaj këpucë të përshtatshme',
            ],
            dontTitle: 'E rrezikshme',
            donts: [
              'Të kërcesh nga kabina ose nga zona e ngarkesës',
              'Të ecësh mbi shkallë të ndotura, të ngrira ose të zëna',
              'Të hipësh mbi pjesë të automjetit që nuk janë për këtë ose '
                  'mbi ngarkesë',
              'Të përdorësh shkallë të dëmtuara',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 11
  SafetyChapterContent(
    id: 'ch11',
    title: 'Rregulli i 3 pikave',
    summary: 'Hyrja dhe dalja — rregulli i vetëm më i rëndësishëm',
    asset: '${_a}step3p_cover.svg',
    slides: [
      SafetySlide(
        title: 'Gjithmonë 3 nga 4 pika kontakti',
        asset: '${_a}step3p_cover.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Rregulli bazë',
            text: '2 duar + 1 këmbë  OSE  2 këmbë + 1 dorë. Tri pika kanë '
                'gjithmonë kontakt të fortë me automjetin.',
          ),
          ParagraphBlock(
            'Ti hyn dhe del dhjetëra herë në ditë — me nxitim, në shi, me '
            'duar plot. Pikërisht atëherë ndodhin shumica e aksidenteve. '
            'Tri pika të forta të japin mbështetje dhe parandalojnë rëniet '
            'e lëndimet te kyçi, gjuri dhe kurrizi.',
          ),
          FactsBlock([
            FactItem('51,6 %', 'e të gjitha aksidenteve janë rënie'),
            FactItem('7,2 %', 'janë aksidente trafiku'),
          ]),
          ParagraphBlock(
            'Asnjë lëvizje tjetër e përditshmërisë në punë nuk parandalon '
            'kaq shumë lëndime sa kjo. Prandaj qëndron në fund të këtij '
            'udhëzimi — si ajo që duhet të mbetet në mendje.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Katër rregullat një nga një',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}step3p_01_face.svg',
              title: 'Fytyra nga automjeti',
              caption: 'Dil gjithmonë i kthyer nga automjeti — kurrë mos '
                  'kërce mbrapsht ose anash. Kërcimi është shkaku më i '
                  'shpeshtë i aksidenteve. Përdor gjithmonë shkallëzën dhe '
                  'dorezat.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_02_hands.svg',
              title: 'Fillimisht vendose poshtë, pastaj kap',
              caption: 'Pa pako në dorë kur hyn dhe kur del. Vendose '
                  'dërgesën poshtë ose fut gjërat e vogla në çantë a në '
                  'rrip — duart mbeten të lira për t\'u mbajtur.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_03_onepoint.svg',
              title: 'Lëviz vetëm një pikë',
              caption: 'Lëviz gjithmonë vetëm një dorë ose një këmbë, '
                  'ndërsa tri të tjerat mbahen fort. Mos nxito — as kur '
                  'turi të shtyn.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_04_steps.svg',
              title: 'Kujdes për shkallët dhe mbështetjen',
              caption: 'Ki parasysh lagështinë, borën, vajin dhe '
                  'papastërtitë. Shkel qetë dhe i kontrolluar, pastro '
                  'shkallët paraprakisht nëse duhet.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Dy gjëra që i takojnë kësaj',
        blocks: [
          SubheadBlock('Këpucë sigurie gjysmë të larta'),
          ParagraphBlock(
            'Këpucët gjysmë të larta e mbyllin kyçin dhe e stabilizojnë '
            'nyjen dukshëm më mirë — pikërisht aty ndodh përdredhja gjatë '
            'zbritjes.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'A të është përdredhur ndonjëherë këmba?',
            text: 'Kush ka pasur tashmë probleme me kyçin, duhet të kërkojë '
                'këpucë gjysmë të larta — para turit të ardhshëm, jo pas '
                'tij.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}step3p_05_phone.svg',
              title: 'Pa telefon privat në dorë',
              caption: 'Të flasësh, të shkruash dhe të lëvizësh ekranin të '
                  'bën të pavëmendshëm — pikërisht nga kjo lindin rëniet '
                  'dhe aksidentet. Telefonatat dhe mesazhet private presin '
                  'deri në pushim. Kur hyn dhe kur del, telefoni duhet të '
                  'jetë i futur.',
            ),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Shkurt për mbajtje mend',
            text: 'Fytyra nga automjeti · mbaj tri pika · duart të lira · '
                'këpucë sigurie gjysmë të larta · pa telefon privat · '
                'përdor shkallët në vend që të kërcesh.',
          ),
        ],
      ),
    ],
  ),
];
