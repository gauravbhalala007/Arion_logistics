// lib/data/safety_training/green_book_content_sq.dart
//
// Përmbajtja e trajnimit Green Book — versioni shqip.
// Struktura është identike me versionin gjerman (master): kapitujt
// gb1–gb6, të njëjtat folie, të njëjtët blloqe dhe të njëjtat vlera.
//
// „Green Book" është libri i kontrollit të udhëtimeve: mbledhja e fletëve
// ditore të kontrollit sipas § 1 Abs. 6 Fahrpersonalverordnung (FPersV —
// rregullorja gjermane për personelin e ngasjes). Me të dëshmohen kohët e
// ngasjes, ndërprerjet e udhëtimit si dhe kohët e punës e të pushimit —
// ai NUK është kontroll pamor i mjetit. Për këtë temë nuk ka ilustrime,
// prandaj `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> greenBookContentSq = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'gb1',
    title: 'Çfarë është Green Book-u',
    summary: 'Libri i kontrollit të udhëtimeve sipas § 1 Abs. 6 FPersV — '
        'dhe pse është i detyrueshëm për ty',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Libër kontrolli udhëtimesh, jo kontroll i mjetit',
        blocks: [
          ParagraphBlock(
            '„Green Book" është libri yt i kontrollit të udhëtimeve. Aty '
            'mbledh fletët ditore të kontrollit: për çdo ditë pune një '
            'fletë, në të cilën shkruhet kur ke ngarë, kur ke bërë pushim '
            'dhe kur ka filluar koha jote e pushimit.',
          ),
          ParagraphBlock(
            'Ai shprehimisht nuk është kontroll i mjetit. Gomat, dritat '
            'dhe karroceria dokumentohen diku tjetër. Në Green Book bëhet '
            'fjalë vetëm për kohët — kohët e tua.',
          ),
          BulletsBlock([
            'Një fletë për çdo ditë në të cilën lëviz një mjet që i '
                'nënshtrohet detyrimit të regjistrimit',
            'Mbahet me dorë, me shkrim të pafshirshëm dhe nënshkruhet',
            'Ajo dëshmon se ke respektuar kohët e ngasjes, pushimet dhe '
                'kohët e pushimit',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Shkurt',
            text: 'Green Book-u i përgjigjet një pyetjeje të vetme: kur ke '
                'qenë në timon dhe kur jo? Çdo gjë tjetër nuk hyn aty.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kush duhet të regjistrojë',
        blocks: [
          ParagraphBlock(
            'Detyrimi vjen nga § 1 Abs. 6 i Fahrpersonalverordnung '
            '(FPersV — rregullorja gjermane për personelin e ngasjes). Ai '
            'nuk lidhet me ty personalisht, por me mjetin dhe me qëllimin '
            'e udhëtimit: transport tregtar mallrash me një mjet mbi 2,8 t '
            'deri në 3,5 t masë maksimale të lejuar. Pikërisht furgoni '
            'tipik i shpërndarjes.',
          ),
          FactsBlock([
            FactItem('nën 2,8 t', 'pa detyrim regjistrimi sipas § 1 '
                'Abs. 6 FPersV'),
            FactItem('2,8–3,5 t', 'fletë ditore kontrolli — Green Book-u'),
            FactItem('nga 3,5 t', 'tahograf digjital në vend të fletës'),
          ]),
          ParagraphBlock(
            'Vendimtare është masa maksimale e lejuar që shkruhet në lejen '
            'e qarkullimit — jo sa i ngarkuar është furgoni sot në të '
            'vërtetë. Një mjet 3,5 t gjysmë bosh mbetet me detyrim '
            'regjistrimi.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Baza ligjore',
            text: '§ 1 Abs. 6 FPersV të detyron të regjistrosh kohët e '
                'ngasjes, ndërprerjet e udhëtimit si dhe kohët e punës e '
                'të pushimit. Nëse ngas pa këtë fletë, shkel rregulloren — '
                'pavarësisht nëse i ke respektuar kohët.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Për çfarë shërben regjistrimi',
        blocks: [
          ParagraphBlock(
            'Rregulli nuk është qëllim në vetvete. Ai ekziston sepse '
            'shoferët e lodhur janë të rrezikshëm në trafik — për vete dhe '
            'për të gjithë të tjerët. Fleta e bën të dukshme nëse ditët e '
            'tua të punës janë planifikuar fare në mënyrë të zbatueshme.',
          ),
          BulletsBlock([
            'Mbrojtje nga lodhja: kush duhet ta dokumentojë pushimin, e '
                'bën atë më lehtë edhe në të vërtetë',
            'Dëshmi për ty: fleta vërteton se ke ngarë saktë — edhe muaj '
                'më vonë',
            'Dëshmi kundër pretendimeve: pa regjistrim, kujtesa jote '
                'qëndron përballë asaj që supozon kontrolli',
            'Bazë për planifikimin e turave: turat vazhdimisht të ngushta '
                'bien në sy te fleta',
          ]),
          RevealBlock(
            prompt: 'Rast studimi: sot i ke respektuar kohët — pushim në '
                'kohë, mbarim me kohë. Vetëm fletën nuk e ke plotësuar, '
                'sepse gjithsesi gjithçka ishte në rregull. Kontroll '
                'pasdite. A është kjo problem?',
            answer: 'Po. Detyrim regjistrimi do të thotë: vetë dëshmia '
                'është detyrimi. Askush në një kontroll rrugor nuk mund të '
                'konstatojë nëse i ke respektuar vërtet kohët — nuk ka '
                'çfarë të paraqitet. Nga këndvështrimi i kontrollit, një '
                'fletë që mungon trajtohet saktësisht si një afat kohor i '
                'tejkaluar: ekziston një shkelje dhe ajo ndëshkohet. '
                'Respektimi të ndihmon vetëm nëse mund ta vërtetosh.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listë kontrolli: kuptimi bazë',
        blocks: [
          ChecklistBlock(
            title: 'Këtë marr me vete nga kapitulli 1',
            items: [
              'E di se Green Book-u dokumenton kohët dhe jo gjendjen e '
                  'mjetit',
              'E njoh bazën ligjore: § 1 Abs. 6 FPersV',
              'E di se preken mjetet mbi 2,8 t deri në 3,5 t',
              'E di se vlen masa maksimale e lejuar, jo pesha e sotme e '
                  'ngarkesës',
              'E di se nga 3,5 t hyn në punë tahografi digjital',
              'E kam të qartë se një fletë që mungon është vetvetiu '
                  'shkelje',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Një fjali për turin',
            text: '„Atë që nuk e kam shkruar, nuk mund ta provoj."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'gb2',
    title: 'Çfarë shënohet saktësisht',
    summary: 'Të gjitha fushat e detyrueshme — dhe si i plotëson pastër',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Të dhënat e detyrueshme në fletë',
        blocks: [
          ParagraphBlock(
            'Një fletë ditore kontrolli është dëshmi vetëm nëse mbi të '
            'ndodhen të gjitha të dhënat e parashikuara. Nëse mungon njëra '
            'prej tyre, fleta quhet e paplotë — me të njëjtat pasoja si '
            'një fletë që mungon.',
          ),
          BulletsBlock([
            'Mbiemri, emri dhe adresa e shoferit',
            'Targa zyrtare e mjetit',
            'Data e ditës',
            'Gjendja e kilometrazhit në fillim dhe në fund të udhëtimit',
            'Vendi i nisjes dhe vendi i mbarimit të udhëtimit',
            'Kohët e ngasjes dhe kohët e pushimit me orë të shënuara',
            'Ndërprerjet e udhëtimit (pushimet)',
            'Nënshkrimi yt',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'E plotë do të thotë e plotë',
            text: '§ 1 Abs. 6 FPersV i rendit të dhënat në mënyrë '
                'përfundimtare. Një fletë pa targë, pa adresë ose pa '
                'nënshkrim nuk e përmbush detyrimin e regjistrimit — edhe '
                'nëse kohët janë shënuar saktë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Plotësimi hap pas hapi',
        blocks: [
          ParagraphBlock(
            'Rendi më poshtë është zgjedhur me qëllim që të mos harrosh '
            'asgjë: fillimisht të dhënat fikse, pastaj kohët gjatë ditës, '
            'në fund mbyllja.',
          ),
          StepsBlock([
            'Para nisjes: shëno datën, mbiemrin, emrin, adresën dhe targën',
            'Lexo kilometrazhin nga paneli dhe shënoje si gjendje '
                'fillestare — mos e hamendëso',
            'Shëno vendin e nisjes së udhëtimit (depo, vendndodhje, emër '
                'vendi)',
            'Shëno fillimin e kohës së ngasjes me orë, sapo të nisesh',
            'Çdo ndërprerje udhëtimi shënoje menjëherë me fillim dhe '
                'mbarim — jo vetëm në mbrëmje',
            'Në fund të turit: shëno vendin e mbarimit dhe kilometrazhin '
                'përfundimtar',
            'Shëno mbarimin e kohës së ngasjes dhe fillimin e kohës së '
                'pushimit',
            'Lexoje fletën, kontrolloje për boshllëqe dhe nënshkruaje',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Shkruaj me shkrim të pafshirshëm',
            text: 'Stilolaps, jo laps. Një shënim që mund të fshihet nuk '
                'është dëshmi. Një gabim shkrimi vijëzohet një herë dhe '
                'rishkruhet pranë — nuk lyhet dhe nuk mbulohet.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Shënimi i pastër i kohëve',
        blocks: [
          ParagraphBlock(
            'Më së shumti gabohet te kohët. Çdo bllok kohor i ditës shkon '
            'në një rresht të vetin, me orë nga–deri. Kështu duket një '
            'ditë normale shpërndarjeje:',
          ),
          TableBlock(
            headers: ['Nga–deri', 'Lloji', 'Shënim'],
            rows: [
              ['06:30–07:00', 'Kohë pune', 'Ngarkim në depo, ende jo kohë '
                  'ngasjeje'],
              ['07:00–11:30', 'Kohë ngasjeje', '4,5 orë — tani duhet '
                  'pushimi'],
              ['11:30–12:15', 'Ndërprerje udhëtimi', '45 minuta pa '
                  'ndërprerje'],
              ['12:15–16:45', 'Kohë ngasjeje', 'blloku i dytë, bashkë 9 '
                  'orë'],
              ['16:45–17:15', 'Kohë pune', 'dorëzim, kthime, mbyllje'],
              ['nga 17:15', 'Kohë pushimi', 'të paktën 11 orë deri te '
                  'nisja tjetër'],
            ],
          ),
          BulletsBlock([
            'Kohë ngasjeje është vetëm koha në timon kur mjeti lëviz',
            'Ngarkimi, shkarkimi, skanimi dhe pritja te ndalesa janë kohë '
                'pune, por jo kohë ngasjeje',
            'Një ndërprerje udhëtimi është pushim vetëm nëse gjatë asaj '
                'kohe vërtet nuk punon',
          ]),
          RevealBlock(
            prompt: 'Rast studimi: rri 40 minuta te rampa dhe pret të '
                'shkarkohet. Ulesh në kabinë dhe nuk bën asgjë. A mund ta '
                'shënosh këtë si ndërprerje udhëtimi?',
            answer: 'Vetëm nëse gjatë asaj kohe mund të disponosh lirisht '
                'dhe nuk kryen asnjë punë — dhe nëse e di këtë '
                'paraprakisht. Nëse duhet të jesh gati në çdo moment, '
                'sepse mund të vazhdohet menjëherë, ajo është kohë pritjeje '
                'dhe jo pushim. Gabimi i afërt: „Nuk bëra asgjë, pra ishte '
                'pushim." Vendimtare nuk është nëse lëvize, por nëse mund '
                'ta disponoje kohën. Në dyshim e shënon si kohë pune — kjo '
                'është gjithmonë ana e sigurt.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listë kontrolli: a është fleta e plotë?',
        blocks: [
          ChecklistBlock(
            title: 'Para se të nënshkruaj',
            items: [
              'Mbiemri, emri dhe adresa janë shkruar',
              'Targa e mjetit përputhet me mjetin që kam ngarë',
              'Data është shënuar',
              'Kilometrazhi fillestar dhe përfundimtar janë lexuar nga '
                  'paneli',
              'Vendi i nisjes dhe i mbarimit janë shkruar',
              'Të gjitha kohët e ngasjes janë shënuar me orë nga–deri',
              'Të gjitha ndërprerjet e udhëtimit janë shënuar',
              'Fillimi i kohës së pushimit është shënuar',
              'Gjithçka me stilolaps, pa fshirje, pa boshllëk',
              'Nënshkrimi është vënë',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'gb3',
    title: 'Kohët e ngasjes, pushimet, kohët e pushimit',
    summary: 'Numrat që duhet t’i respektojë dita jote e punës',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Numrat që kanë rëndësi',
        blocks: [
          ParagraphBlock(
            'Green Book-u dokumenton kohët — por vetëm që të mund të '
            'kuptohet nëse i ke respektuar kufijtë. Këta kufij duhet t’i '
            'kesh në kokë, jo vetëm në letër.',
          ),
          FactsBlock([
            FactItem('9 h', 'kohë ngasjeje në ditë si rregull'),
            FactItem('10 h', 'lejohet dy herë në javë si përjashtim'),
            FactItem('4,5 h', 'ngasje rresht, pastaj duhet pushimi'),
          ]),
          FactsBlock([
            FactItem('45 min', 'ndërprerje udhëtimi pas 4,5 orësh'),
            FactItem('15 + 30', 'ndarja e lejuar — në këtë rend'),
            FactItem('11 h', 'pushimi ditor, të paktën'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Çfarë kërkon rregullorja',
            text: 'Koha e ngasjes është më së shumti 9 orë në ditë, dy '
                'herë në javë ajo mund të zgjatet në 10 orë. Pas 4,5 orësh '
                'ngasje më së voni duhet bërë një ndërprerje udhëtimi prej '
                'të paktën 45 minutash. Pushimi ditor është të paktën 11 '
                'orë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Vendosja e drejtë e pushimit',
        blocks: [
          ParagraphBlock(
            '45 minutat janë rasti normal. Mund t’i ndash — por vetëm në '
            'saktësisht dy pjesë dhe vetëm në një rend të caktuar: '
            'fillimisht të paktën 15 minuta, pastaj të paktën 30 minuta. E '
            'kundërta nuk vlen.',
          ),
          DoDontBlock(
            doTitle: 'Kështu pushimi është i vlefshëm',
            dos: [
              '45 minuta rresht, më së voni pas 4,5 orësh ngasje',
              'Ose 15 minuta në fillim, pastaj 30 minuta',
              'Të dyja pjesët brenda të njëjtit bllok 4,5-orësh',
              'Të dyja pjesët shënohen në fletë me orë nga–deri',
            ],
            dontTitle: 'Kështu nuk vlen',
            donts: [
              '30 minuta në fillim dhe 15 minuta pas — rend i gabuar',
              'Tri pushime të shkurtra nga 15 minuta',
              'Dy herë nga 20 minuta — pjesa e dytë është shumë e shkurtër',
              'Pushim vetëm pas 5 orësh ngasje, sepse ndalesa përshtatej '
                  'më mirë',
            ],
          ),
          BulletsBlock([
            '4,5 orët janë kohë e pastër ngasjeje — ndalesat me dorëzime '
                'nuk numërohen',
            'Pushimi duhet të bjerë para tejkalimit, jo pas tij',
            'Pas ndërprerjes së plotë fillon një bllok i ri 4,5-orësh',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Gabimi më i shpeshtë në mendim',
            text: 'Pushimi nuk duhet kur ke 4,5 orë në shërbim, por kur ke '
                'ngarë 4,5 orë. Kush llogarit sipas kohës së shërbimit, e '
                'bën pushimin zakonisht shumë herët — dhe pastaj edhe një '
                'herë shumë vonë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Llogaritja në përditshmërinë e shpërndarjes',
        blocks: [
          ParagraphBlock(
            'Në përditshmëri nuk llogarit me një bllok të vetëm, por me '
            'shumë udhëtime të shkurtra mes ndalesave. Mblidhi bashkë — '
            'ato japin kohën tënde të ngasjes.',
          ),
          RevealBlock(
            prompt: 'Rast studimi: nisesh në orën 07:00. Deri në 09:30 '
                'rri 2 orë në timon, pjesën tjetër te ndalesat. Deri në '
                '12:00 shtohen edhe 2 orë kohë ngasjeje, deri në 13:00 '
                'edhe 30 minuta. Kur duhet pushimi më së voni?',
            answer: 'Në orën 13:00. Në atë moment ke arritur 2 + 2 + 0,5 = '
                '4,5 orë kohë të pastër ngasjeje — tani nuk guxon të '
                'ngasësh asnjë metër para se të kryhet ndërprerja e '
                'udhëtimit. Gabimi i afërt do të ishte të llogarisje '
                'gjashtë orë shërbim nga ora 07:00 dhe ta vendosje pushimin '
                'në 11:30. Ora që numëron ecën vetëm kur mjeti lëviz.',
          ),
          RevealBlock(
            prompt: 'Rast studimi: këtë javë ke ngarë tashmë dy herë nga '
                '10 orë. Sot është e premte, je te 8,5 orë kohë ngasjeje '
                'dhe ke edhe dy ndalesa, bashkë rreth 40 minuta udhëtim. A '
                'shkon ende?',
            answer: 'Jo. Zgjatjen në 10 orë mund ta përdorësh vetëm dy '
                'herë në javë dhe ato janë shpenzuar. Sot vlen sërish '
                'kufiri i rregullt prej 9 orësh — pra të mbeten 30 minuta '
                'kohë ngasjeje, jo 40. Ngas ndalesën që arrin, pjesën '
                'tjetër ia raporton dispeçerit dhe e mbyll kohën e ngasjes. '
                'Gabimi i afërt: „10 orët më takojnë çdo ditë." Ato janë '
                'përjashtim me kuotë javore.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listë kontrolli: kohët nën kontroll',
        blocks: [
          ChecklistBlock(
            title: 'Këtë marr me vete nga kapitulli 3',
            items: [
              'E di se 9 orë kohë ngasjeje janë rregulli',
              'E di se 10 orë lejohen vetëm dy herë në javë',
              'I numëroj 4,5 orët si kohë të pastër ngasjeje, jo si kohë '
                  'shërbimi',
              'Bëj të paktën 45 minuta ndërprerje udhëtimi',
              'Pushimin e ndaj më së shumti në 15 + 30 minuta, në këtë '
                  'rend',
              'Respektoj të paktën 11 orë pushim ditor',
              'Çdo pushim e shënoj menjëherë, jo në mbrëmje',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Fjalë për mendje',
            text: '4,5 – 45 – 9 – 11. Katër numra që e strukturojnë ditën '
                'tënde. Kush i njeh, nuk ka nevojë të llogarisë, por '
                'vetëm të shënojë.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'gb4',
    title: 'Gabimet tipike gjatë plotësimit',
    summary: 'Gjashtë gabimet që bien në sy në çdo kontroll',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Gjashtë gabimet më të shpeshta',
        blocks: [
          ParagraphBlock(
            'Pothuajse të gjitha fletët e kundërshtuara nuk dështojnë te '
            'kohët, por te mënyra se si janë mbajtur. Këto gjashtë gabime '
            'e bëjnë të pavlefshme një fletë përndryshe të saktë.',
          ),
          DoDontBlock(
            doTitle: 'Kështu e mban fletën drejt',
            dos: [
              'Çdo shënim e bën menjëherë, kur mbaron blloku kohor',
              'Përdor stilolaps, me shkrim të pafshirshëm',
              'Pushimet i shënon me orën e vërtetë nga–deri',
              'Kilometrazhin e lexon nga paneli',
              'Në fund të ditës nënshkruan',
              'Fleta mbetet në mjet, te ti',
            ],
            dontTitle: 'Kështu fleta kundërshtohet',
            donts: [
              'E gjithë java plotësohet të premten në mbrëmje',
              'Shkruhet me laps, që „të korrigjohet më vonë"',
              'Pushimet hamendësohen („rreth tri çerekë ore")',
              'Kilometrazhi shkruhet nga kujtesa',
              'Harrohet nënshkrimi',
              'Fletët lihen në shtëpi ose në depo',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Gabimi më i shtrenjtë është më i rehatshmi',
            text: 'Plotësimi më vonë duket i padëmshëm — është gabimi që '
                'zbulohet më shpejt dhe peshon më rëndë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pse bien në sy shënimet e mëvonshme',
        blocks: [
          ParagraphBlock(
            'Një fletë e shkruar e tëra më vonë duket ndryshe nga një fletë '
            'që ka lindur gjatë gjithë ditës. Kontrollorët i shohin të '
            'dyja çdo ditë dhe e dallojnë menjëherë ndryshimin.',
          ),
          BulletsBlock([
            'I njëjti shkrim, i njëjti stilolaps, i njëjti presion në të '
                'gjitha rreshtat',
            'Kohë çuditërisht të rrumbullakëta: gjithçka mbaron në gjysmë '
                'ose në orë të plotë',
            'Kilometrazhe që nuk përputhen me rrugën e shënuar',
            'Të dhëna që bien ndesh me fletëdorëzimet, skanimet ose '
                'faturat e karburantit',
            'Pushime që zgjasin gjithmonë saktësisht 45 minuta — edhe në '
                'ditë kur kjo ishte e pamundur',
          ]),
          ParagraphBlock(
            'Kësaj i shtohet: në një kontroll në firmë fletët qëndrojnë '
            'pranë dokumenteve të tjera. Kundërthëniet nuk të bien ty në '
            'sy, por autoritetit.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Gabim është më keq se bosh',
            text: 'Një fletë e paplotë është shkelje e detyrimit të '
                'regjistrimit. Një fletë e plotësuar me vetëdije gabim '
                'është më shumë se kaq — aty nuk bëhet fjalë vetëm për një '
                'kundërvajtje administrative, por për çështjen e mashtrimit. '
                'Më mirë shëno se ke ngarë shumë gjatë, sesa të shpikësh '
                'një kohë.',
          ),
          RevealBlock(
            prompt: 'Rast studimi: të enjten vëren se të martën pushimi i '
                'drekës nuk është shënuar. E mban mend saktë: 12:10 deri '
                '12:55. Çfarë bën?',
            answer: 'E shënon më vonë — por dukshëm si shtesë, me datën e '
                'plotësimit dhe një vërejtje të shkurtër, dhe njofton '
                'dispeçerin tënd. Një korrigjim i ndershëm dhe i dallueshëm '
                'është i lejuar dhe dukshëm më i mirë se një boshllëk. '
                'Gabimi i afërt do të ishte ta futje shënimin sikur të '
                'kishte lindur të martën — pikërisht ky është hapi nga '
                'pakujdesia te falsifikimi.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listë kontrolli: e mbajtur pastër',
        blocks: [
          ChecklistBlock(
            title: 'Fleta ime i qëndron një kontrolli',
            items: [
              'Çdo bllok kohor e shënoj menjëherë, jo në mbrëmje',
              'Shkruaj me stilolaps',
              'I lexoj orët dhe kilometrazhet, në vend që t’i hamendësoj',
              'Nënshkruaj çdo fletë',
              'Fletët e mia janë gjithmonë me mua në mjet',
              'Korrigjimet i bëj dukshëm dhe me datë, kurrë padukshëm',
              'Më mirë shënoj një shkelje, sesa të shpik një kohë',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'gb5',
    title: 'Mbajtja me vete, dorëzimi, ruajtja',
    summary: '28 ditë te shoferi, një vit në firmë',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Dy afatet',
        blocks: [
          ParagraphBlock(
            'Fleta e plotësuar vlen diçka vetëm kur ndodhet në momentin e '
            'duhur në vendin e duhur. Për këtë ka dy afate që duhet t’i '
            'mbash të ndara.',
          ),
          FactsBlock([
            FactItem('28 ditë', 'regjistrimet i mban me vete shoferi'),
            FactItem('1 vit', 'sipërmarrësi i ruan në firmë'),
          ]),
          BulletsBlock([
            '28 ditët të përkasin ty: duhet të kesh me vete regjistrimet e '
                'ditës në vazhdim dhe të 28 ditëve të mëparshme',
            'Afati vjetor i përket firmës: ajo duhet t’i ruajë fletët një '
                'vit dhe t’i paraqesë me kërkesë',
            'Të dyja vlejnë njëkohësisht — fletët shkojnë në arkiv vetëm '
                'pas mbarimit të detyrimit të mbajtjes me vete',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Detyrimi i mbajtjes me vete',
            text: 'Regjistrimet e 28 ditëve të fundit i takojnë mjetit — '
                'jo dollapit, jo shtëpisë dhe jo zyrës. Nëse mungojnë në '
                'një kontroll, nuk ndihmon që janë mbajtur me rregull.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrolli rrugor',
        blocks: [
          ParagraphBlock(
            'Kontrollohet nga BAG — Bundesamt für Logistik und Mobilität, '
            'zyra federale gjermane për logjistikë dhe mobilitet — dhe nga '
            'policia. Të dyja mund të kontrollojnë në rrugë, BAG-u përveç '
            'kësaj edhe në firmë.',
          ),
          StepsBlock([
            'Ndalo, fik motorin, ul xhamin, duart mbaji të dukshme',
            'Qëndro i qetë — një kontroll është rutinë, jo dyshim',
            'Paraqit patentën, dokumentet e mjetit dhe regjistrimet e 28 '
                'ditëve të fundit',
            'Përgjigju pyetjeve me fakte, mos shpik dhe mos zbukuro asgjë',
            'Në rast kundërshtimi: lëre të regjistrohet rasti, mos diskuto',
            'Pastaj njofto dispeçerin dhe dokumento rastin në firmë',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Përgatitja e mund shpjegimin',
            text: 'Një kontroll zgjat pak minuta, nëse fletët janë të '
                'plota në mjet. Çdo gjë tjetër të kushton ty dhe firmës '
                'gjithë pasditen.',
          ),
          RevealBlock(
            prompt: 'Rast studimi: në buzë të rrugës kontrollori pyet për '
                '28 ditët e fundit. Ke me vete vetëm javën aktuale — '
                'fletët më të vjetra i ke dorëzuar me rregull në depo. A '
                'mjafton kjo?',
            answer: 'Jo. Detyrimi i mbajtjes me vete përfshin ditën në '
                'vazhdim dhe 28 ditët e mëparshme. Fakti që fletët më të '
                'vjetra qëndrojnë me rregull në firmë e përmbush detyrimin '
                'e ruajtjes, por jo atë të mbajtjes me vete — janë dy '
                'detyrime të ndara. E drejta është: kopjet ose origjinalet '
                'e 28 ditëve të fundit mbeten te ti, vetëm pastaj shkojnë '
                'në arkiv. Sqaro me dispeçerin tënd se si e organizoni '
                'këtë në firmë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dorëzimi në firmë',
        blocks: [
          ParagraphBlock(
            'Sipërmarrësi mund ta përmbushë detyrimin e ruajtjes vetëm '
            'nëse i merr edhe fletët. Prandaj dorëzimi nuk është punë '
            'zyrtarie, por pjesë e detyrimit tënd të regjistrimit.',
          ),
          BulletsBlock([
            'Fletët dorëzoji të plota pas mbarimit të afatit të mbajtjes, '
                'jo me tufa në fund të muajit',
            'Mos hidh asgjë, as fletët me gabime ose korrigjime',
            'Nëse të mungon një fletë, thuaje menjëherë — një boshllëk i '
                'lajmëruar është më i mirë se një i zbuluar',
            'Ditët e pushimeve, të sëmundjes dhe të zyrës mos i lër thjesht '
                'jashtë, por shënoji sipas rregullit të firmës',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Boshllëqet mbeten boshllëqe',
            text: 'Një ditë pa fletë nuk mund të rindërtohet më vonë. Kush '
                'e lë pas dore dorëzimin, prodhon pikërisht ato boshllëqe '
                'që bien në sy në një kontroll në firmë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listë kontrolli: dokumentet nën kontroll',
        blocks: [
          ChecklistBlock(
            title: 'Para çdo turni dhe pas çdo jave',
            items: [
              'Regjistrimet e 28 ditëve të fundit janë në mjet',
              'Fleta e sotme është filluar dhe rri afër dore',
              'Patenta dhe dokumentet e mjetit janë me mua',
              'Fletët e skaduara i kam dorëzuar në firmë',
              'Nuk kam hedhur asnjë fletë, as ndonjë me korrigjime',
              'E di se kë duhet të njoftoj në rast kontrolli',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'gb6',
    title: 'Pasojat në rast shkeljesh',
    summary: 'Gjobë, përgjegjësia e firmës, eskalimi i brendshëm',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Çfarë rrezikon ligjërisht',
        blocks: [
          ParagraphBlock(
            'Një fletë ditore kontrolli që mungon ose është e paplotë '
            'është kundërvajtje administrative. Sa e lartë del gjoba varet '
            'nga rëndësia e shkeljes dhe nga sa shpesh është shkelur.',
          ),
          FactsBlock([
            FactItem('nga 100 €', 'gjobë për fletë që mungojnë ose janë '
                'të paplota'),
            FactItem('sipas rëndësisë', 'shuma më të larta për shkelje të '
                'shumta ose të përsëritura'),
          ]),
          BulletsBlock([
            'I prekur nuk është vetëm shoferi — edhe firma mban përgjegjësi '
                'për regjistrimet',
            'Në shkelje të rënda ose të përsëritura rrezikohet një '
                'procedurë për besueshmërinë e firmës',
            'Kontrollohet nga BAG-u dhe policia, në rrugë dhe në firmë',
            'Kundërshtimet nga një kontroll në firmë prekin të gjithë '
                'shoferët, jo vetëm atë të kontrolluarin',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Dy adresues, një detyrim',
            text: 'FPersV i vë shoferët dhe sipërmarrësit bashkërisht në '
                'detyrim: ti duhet të regjistrosh dhe të mbash me vete, '
                'firma duhet të ruajë dhe të mbikëqyrë. Nëse bie njëra nga '
                'të dyja, përgjigjet ana përkatëse.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Eskalimi në firmë',
        blocks: [
          ParagraphBlock(
            'Pavarësisht nëse një autoritet konstaton diçka, në firmë vlen '
            'një radhë e fiksuar. Ajo është e njëjtë për të gjithë dhe '
            'dokumentohet.',
          ),
          StepsBlock([
            'Shkalla e parë: vërejtje gojore nga dispeçeri',
            'Shkalla e dytë: vërejtje me shkrim në dosjen e personelit',
            'Shkalla e tretë: pasoja sipas së drejtës së punës deri te '
                'shkëputja e kontratës',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Shkelja është fleta që mungon',
            text: 'Shkallët ecin pavarësisht nëse ka ndodhur diçka ose '
                'nëse ka pasur kontroll. Tashmë fleta e pambajtur është '
                'shkelja.',
          ),
          RevealBlock(
            prompt: 'Rast studimi: dispeçeri këmbëngul: „Ngaji edhe dy '
                'ndalesat, pushimin shkruaje thjesht brenda, përndryshe '
                'nuk dalim." Çfarë vlen?',
            answer: 'Urdhri nuk ndryshon asgjë nga detyrimi yt. Ti je ai '
                'që regjistron dhe nënshkruan — me nënshkrimin tënd '
                'vërteton përmbajtjen. Një urdhër gojor nuk të mbron as në '
                'kontroll, as më vonë në firmë. E drejta është: bëj '
                'pushimin, shënoje saktë, raporto ndalesat e mbetura dhe '
                'dokumento urdhrin. Firma është e detyruar ta mundësojë '
                'respektimin — jo ta anashkalojë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listë kontrolli: mbyllja',
        blocks: [
          ChecklistBlock(
            title: 'Këtë marr me vete nga trajnimi',
            items: [
              'Green Book-u është libri i kontrollit të udhëtimeve sipas '
                  '§ 1 Abs. 6 FPersV',
              'I njoh të gjitha të dhënat e detyrueshme dhe i plotësoj të '
                  'plota',
              'Respektoj 9 h kohë ngasjeje, 4,5 h deri te pushimi, 45 min '
                  'ndërprerje dhe 11 h pushim',
              'Shënoj menjëherë, me stilolaps, dhe nënshkruaj',
              'Mbaj me vete regjistrimet e 28 ditëve të fundit',
              'Fletët e skaduara i dorëzoj në firmë',
              'E di se një fletë që mungon mund të shkaktojë gjobë nga 100 '
                  'euro',
              'E di se një urdhër nuk e heq detyrimin tim të regjistrimit',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Një fjali për turin',
            text: '„Fleta shkruan bashkë me mua ndërsa ngas — jo kur kam '
                'mbaruar."',
          ),
        ],
      ),
    ],
  ),
];
