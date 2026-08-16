// lib/data/privacy_notice/privacy_notice_sq.dart
//
// Informacion për mbrojtjen e të dhënave për shoferët sipas
// Art. 13 DSGVO — versioni shqip. Përkthim strukturalisht identik i
// versionit gjerman (`privacy_notice_de.dart`, master).
//
// E rëndësishme: ky është një INFORMIM me konfirmim të marrjes dijeni,
// jo një deklaratë e shoferit që lejon një përpunim. Prandaj kudo
// „Unë jam informuar" / „Unë e kam lexuar dhe kuptuar" — kurrë një
// formulim që tingëllon si dhënie leje.
//
// Referencat ligjore mbeten në formën origjinale gjermane/evropiane
// (Art. 6 Abs. 1 lit. b DSGVO, § 26 BDSG, § 16 Abs. 2 ArbZG, § 147 AO),
// me një shpjegim të shkurtër shqip në kllapa aty ku ndihmon.

import '../safety_training/safety_blocks.dart';
import 'privacy_notice_content.dart';

const List<PrivacyNoticeSection> privacyNoticeSectionsSq = [
  // ══════════════════════════════════════════════════════════════ 1
  PrivacyNoticeSection(
    id: 'verantwortlich',
    title: 'Kush i përpunon të dhënat e tua',
    summary: 'Kontrolluesi, përpunuesi i porositur dhe ku ruhen të '
        'dhënat',
    blocks: [
      ParagraphBlock(
        'Që të mund të punosh në CoDriver, përpunohen të dhëna për ty. '
        'Sipas Art. 13 DSGVO (Rregullorja e Përgjithshme për Mbrojtjen '
        'e të Dhënave) ke të drejtë të dish që në fillim cilat janë '
        'ato, për çfarë përpunohen, mbi çfarë mbështeten dhe sa gjatë '
        'ruhen. Pikërisht kjo shpjegohet në faqet që vijnë.',
      ),
      SubheadBlock('Kush është përgjegjës'),
      ParagraphBlock(
        'Përgjegjës për të dhënat e tua është punëdhënësi yt — Delivery '
        'Service Partner (DSP) te i cili je i punësuar. Emri i tij '
        'shënohet në krye të kësaj faqeje. Atij i drejtohesh për çdo '
        'çështje që lidhet me të dhënat e tua; nëse ka caktuar një '
        'person përgjegjës për mbrojtjen e të dhënave, mund t\'i '
        'drejtohesh drejtpërdrejt atij.',
      ),
      SubheadBlock('Kush e operon softuerin'),
      ParagraphBlock(
        'CoDriver ofrohet nga ARION Logistics GmbH. Ajo i përpunon të '
        'dhënat e tua vetëm me porosi dhe sipas udhëzimeve të '
        'punëdhënësit tënd — si përpunuese e porositur sipas '
        'Art. 28 DSGVO, mbi bazën e një kontrate për përpunimin e të '
        'dhënave. Për qëllime të vetat nuk i përdor të dhënat e tua.',
      ),
      SubheadBlock('Ku ruhen të dhënat'),
      ParagraphBlock(
        'Të dhënat ruhen te Google Firebase brenda Bashkimit Evropian '
        '(rajoni Firestore eur3, qendra të dhënash në Frankfurt dhe '
        'Belgjikë; Cloud Functions në europe-west3, Frankfurt). Ato '
        'janë të enkriptuara gjatë transmetimit dhe në ruajtje. Një '
        'transferim në një vend të tretë jashtë BE-së nuk ndodh.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Ky është informim — jo një leje që e jep ti',
        text: 'Këtu ti informohesh. Nënshkrimi yt në fund vërteton '
            'vetëm se e ke lexuar dhe kuptuar këtë informacion. Nëse '
            'të dhënat e tua mund të përpunohen, kjo nuk varet nga '
            'nënshkrimi yt, por nga bazat ligjore që përmenden te '
            'secili seksion. Pse është kështu, shpjegohet në '
            'seksionin e fundit.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 2
  PrivacyNoticeSection(
    id: 'stammdaten',
    title: 'Të dhënat e tua bazë',
    summary: 'Emri, numri i personelit, Transporter-ID dhe kontaktet',
    blocks: [
      ParagraphBlock(
        'Pa një profil shoferi askush nuk mund të të planifikojë, të '
        'të caktojë një turn ose të të kontaktojë. Profili yt është '
        'baza për gjithçka tjetër në aplikacion.',
      ),
      SubheadBlock('Cilat të dhëna'),
      BulletsBlock([
        'Emri dhe mbiemri',
        'Transporter-ID — identifikuesi yt në sistemin e Amazon dhe '
            'njëkohësisht çelësi yt në CoDriver',
        'Numri i personelit, nëse punëdhënësi yt ka caktuar një të tillë',
        'Adresa e e-mailit të punës — ajo është njëkohësisht hyrja jote',
        'Numri i telefonit për të qenë i arritshëm gjatë punës',
        'Data e lindjes dhe shtetësia, për aq sa janë marrë gjatë '
            'onboarding-ut ose nga aplikimi yt',
        'Fotoja e profilit, nëse vendos një të tillë',
        'Gjuha e zgjedhur e aplikacionit',
        'Statusi i marrëdhënies sate të punës (aktiv, joaktiv, i '
            'larguar)',
      ]),
      SubheadBlock('Për çfarë'),
      ParagraphBlock(
        'Për caktimin e qartë të personit tënd te turnet, automjetet, '
        'oraret dhe dëshmitë, për komunikimin mes teje dhe dispeçerisë '
        'dhe për administrimin e aksesit tënd në aplikacion.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Baza ligjore',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (zbatimi i kontratës sate të '
            'punës) në lidhje me § 26 Abs. 1 BDSG (përpunimi i të '
            'dhënave për qëllime të marrëdhënies së punës).',
      ),
      SubheadBlock('Sa gjatë'),
      ParagraphBlock(
        'Për kohëzgjatjen e marrëdhënies së punës dhe afatet ligjore '
        'të ruajtjes. Më pas profili yt fshihet ose bllokohet.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 3
  PrivacyNoticeSection(
    id: 'zeiterfassung',
    title: 'Regjistrimi i kohës dhe kontrolli i vendndodhjes',
    summary: 'Pikimi me kontroll geofence — dhe çfarë shprehimisht '
        'nuk ruhet',
    blocks: [
      ParagraphBlock(
        'Punëdhënësi yt është i detyruar me ligj ta regjistrojë kohën '
        'tënde të punës në mënyrë objektive, të besueshme dhe të '
        'aksesueshme — kështu e kërkon § 16 ArbZG (ligji gjerman për '
        'kohën e punës) dhe vendimi i Gjykatës Evropiane të Drejtësisë '
        'C-55/18. Kur pikon në CoDriver („Fillo turnin", „Pauzë", '
        '„Përfundo turnin"), aplikacioni kontrollon nëse pajisja jote '
        'ndodhet në vendin e caktuar të punës.',
      ),
      SubheadBlock('Cilat të dhëna te çdo pikim'),
      BulletsBlock([
        'Momenti si vulë kohore e serverit',
        'Transporter-ID jote',
        'Nëse e ke dhënë lejen e vendndodhjes në pajisjen tënde',
        'Rezultati i kontrollit geofence: brenda ose jashtë zonës së '
            'hub-it',
        'Identifikuesi i zonës së hub-it, p.sh. „DBY5_main"',
        'Saktësia e përcaktimit të vendndodhjes në metra',
        'Hub-ID dhe numri i versionit të kodit QR të skanuar',
        'Platforma e pajisjes dhe versioni i aplikacionit',
        'Adresa jote IP, e ruajtur vetëm si vlerë hash SHA-256, kurrë '
            'e lexueshme',
      ]),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Çfarë shprehimisht NUK ruhet',
        text: 'Koordinatat e tua të sakta GPS nuk ruhen. Ato dërgohen '
            'një herë te serveri në çastin e pikimit, vlerësohen atje '
            'për kontrollin geofence dhe pastaj hidhen tej. Mbetet '
            'vetëm përgjigjja „ishte në zonën e hub-it / nuk ishte në '
            'zonën e hub-it". Nuk ka ndjekje të vendndodhjes në sfond '
            'dhe asnjë profil lëvizjeje mes dy pikimeve.',
      ),
      SubheadBlock('Për çfarë'),
      BulletsBlock([
        'Dokumentim i sigurt ligjërisht i kohës sate të punës sipas '
            '§ 16 ArbZG',
        'Llogaritje e saktë e pagës dhe e sigurimeve shoqërore',
        'Mbrojtje nga manipulimi gjatë pikimit',
      ]),
      SubheadBlock('Leja e vendndodhjes është vullnetare'),
      ParagraphBlock(
        'A ia jep pajisjes sate lejen e vendndodhjes, e vendos vetë '
        'dhe mund ta ndryshosh në çdo kohë te cilësimet e pajisjes. '
        'Edhe pa lejen e vendndodhjes mund të pikosh — procesi shënohet '
        'atëherë si „vendndodhje e pakonfirmuar" dhe kontrollohet '
        'manualisht nga dispeçeria. Prej kësaj nuk të lindin pasoja '
        'negative në planin e së drejtës së punës.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Baza ligjore',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (zbatimi i kontratës së '
            'punës), Art. 6 Abs. 1 lit. c DSGVO (detyrim ligjor nga '
            '§ 16 ArbZG), Art. 6 Abs. 1 lit. f DSGVO (interes legjitim '
            'për parandalimin e manipulimit) dhe § 26 BDSG.',
      ),
      SubheadBlock('Sa gjatë'),
      TableBlock(
        headers: ['Të dhënat', 'Ruajtja', 'Baza'],
        rows: [
          ['Regjistrime të veçanta kohore', '2 vjet', '§ 16 Abs. 2 ArbZG'],
          ['Vlerat mujore (plan/fakt/bilanc)', '6 vjet', '§ 147 AO'],
          ['Protokolli i ndryshimeve', '2 vjet', 'Gjurmueshmëria'],
          ['Kërkesat për korrigjim', '2 vjet', 'Gjurmueshmëria'],
        ],
      ),
      SubheadBlock('Asnjë vendim automatik për ty'),
      ParagraphBlock(
        'Një vendim i automatizuar me pasojë juridike sipas '
        'Art. 22 DSGVO nuk ndodh. Njoftimet e aplikacionit, p.sh. për '
        'një pauzë të tejkaluar, janë thjesht informuese; për pasojat '
        'vendos gjithmonë një njeri. Para futjes së regjistrimit të '
        'kohës u krye një vlerësim i ndikimit në mbrojtjen e të '
        'dhënave sipas Art. 35 DSGVO; rreziku i mbetur u vlerësua i '
        'ulët, sepse nuk ruhen as koordinata të papërpunuara as '
        'profile lëvizjeje.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 4
  PrivacyNoticeSection(
    id: 'academy',
    title: 'DA Academy — trajnimet dhe dëshmitë',
    summary: 'Rezultatet e testeve, certifikatat dhe nënshkrimi yt mbi '
        'to',
    blocks: [
      ParagraphBlock(
        'Në DA Academy kryen udhëzime dhe trajnime — për shembull '
        'udhëzimin e sigurisë, Green Book, trajnimin për mbrojtjen e '
        'të dhënave ose udhëzimet e punës. Punëdhënësi yt duhet të '
        'jetë në gjendje të dëshmojë se ti je udhëzuar.',
      ),
      SubheadBlock('Cilat të dhëna'),
      BulletsBlock([
        'Cilin trajnim e ke filluar e përfunduar dhe kur',
        'Rezultati i testit përfundimtar: pikët e arritura, përqindja, '
            'i kaluar ose i pakaluar, numri i tentativave',
        'Data e kalimit dhe skadimi i vlefshmërisë',
        'Gjuha në të cilën e ke kryer trajnimin',
        'Nënshkrimi yt i shkruar me dorë si skedar imazhi',
        'PDF-ja e dëshmisë e krijuar prej tij, me emrin, numrin e '
            'personelit, Transporter-ID, datën dhe nënshkrimin',
        'Konfirmimet e udhëzimeve dhe rregullave të veçanta të punës',
      ]),
      SubheadBlock('Për çfarë'),
      ParagraphBlock(
        'Për të dëshmuar udhëzimin para autoriteteve, sigurimit ligjor '
        'të aksidenteve në punë dhe klientit, për të drejtuar '
        'trajnimet përsëritëse që bëhen të detyrueshme dhe për të '
        'përmbushur detyrimin e llogaridhënies të punëdhënësit tënd.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Baza ligjore',
        text: 'Art. 6 Abs. 1 lit. c DSGVO (detyrim ligjor nga e drejta '
            'e sigurisë në punë dhe e mbrojtjes së të dhënave, ndër të '
            'tjera § 12 ArbSchG, § 4 DGUV Vorschrift 1, Art. 5 Abs. 2 '
            'dhe Art. 32 DSGVO), Art. 6 Abs. 1 lit. b DSGVO (zbatimi i '
            'kontratës së punës) dhe § 26 BDSG.',
      ),
      SubheadBlock('Sa gjatë'),
      ParagraphBlock(
        'Për kohëzgjatjen e marrëdhënies së punës dhe afatet ligjore '
        'të ruajtjes. Dëshmitë për udhëzimet ruhen të paktën aq gjatë '
        'sa nevojiten për t\'u paraqitur para autoriteteve.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 5
  PrivacyNoticeSection(
    id: 'dokumente',
    title: 'Dokumentet e tua',
    summary: 'Patenta, letërnjoftimi, leja e qëndrimit dhe dëshmi të '
        'tjera',
    blocks: [
      ParagraphBlock(
        'Për punën si shofer duhet të ekzistojnë dhe të jenë të '
        'vlefshme disa dëshmi. Ti ose dispeçeria i vendos ato në '
        'profilin tënd të shoferit.',
      ),
      SubheadBlock('Cilat të dhëna'),
      BulletsBlock([
        'Patenta e shoferit — ana e përparme dhe ana e prapme',
        'Letërnjoftimi ose pasaporta',
        'Leja e qëndrimit dhe leja e punës, nëse janë të nevojshme',
        'Numri i identifikimit tatimor',
        'Dëshmia e sigurimeve shoqërore',
        'Kontrata e punës',
        'Datat e skadimit dhe të vlefshmërisë së këtyre dokumenteve',
      ]),
      SubheadBlock('Për çfarë'),
      ParagraphBlock(
        'Për të kontrolluar nëse ti fare mund të vihesh në punë — '
        'sidomos kontrolli i patentës si detyrim i mbajtësit të '
        'automjetit që i takon punëdhënësit —, për të përmbushur '
        'detyrimet e regjistrimit, ato tatimore dhe ato të sigurimeve '
        'shoqërore dhe për të të kujtuar me kohë, para se një dokument '
        'të skadojë.',
      ),
      CalloutBlock(
        tone: CalloutTone.warning,
        title: 'Kujdes i veçantë',
        text: 'Dokumentet e identitetit përmbajnë të dhëna të '
            'ndjeshme. Ato janë të dukshme vetëm për ty dhe për '
            'dispeçerinë e firmës sate, ruhen të enkriptuara në BE '
            'dhe nuk u jepen të tretëve, përveç nëse një autoritet i '
            'kërkon mbi një bazë ligjore.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Baza ligjore',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (zbatimi i kontratës së '
            'punës), Art. 6 Abs. 1 lit. c DSGVO (detyrime ligjore, '
            'ndër të tjera § 21 StVG përgjegjësia e mbajtësit të '
            'automjetit, e drejta e qëndrimit, ajo tatimore dhe ajo e '
            'sigurimeve shoqërore), Art. 6 Abs. 1 lit. f DSGVO '
            '(interes legjitim për aftësinë tënde për punë) dhe '
            '§ 26 BDSG.',
      ),
      SubheadBlock('Sa gjatë'),
      ParagraphBlock(
        'Për kohëzgjatjen e marrëdhënies së punës dhe afatet ligjore '
        'të ruajtjes.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 6
  PrivacyNoticeSection(
    id: 'abwesenheiten',
    title: 'Mungesat, pushimet dhe raportimet e sëmundjes',
    summary: 'Kërkesat, miratimet dhe raportet e paaftësisë për punë',
    blocks: [
      ParagraphBlock(
        'Pushimin, raportimin e sëmundjes dhe mungesa të tjera i '
        'njofton në aplikacion; dispeçeria vendos për to dhe '
        'planifikon në përputhje me këtë.',
      ),
      SubheadBlock('Cilat të dhëna'),
      BulletsBlock([
        'Lloji i mungesës — pushim, sëmundje, lirim i papaguar nga '
            'puna dhe arsye të tjera',
        'Periudha nga … deri … dhe numri i ditëve',
        'Statusi: e kërkuar, e miratuar, e refuzuar',
        'Komenti yt te kërkesa dhe përgjigjja e dispeçerisë',
        'E drejta jote për pushim dhe pjesa e shfrytëzuar tashmë',
        'Raporti i ngarkuar i paaftësisë për punë, nëse paraqet një '
            'të tillë',
      ]),
      CalloutBlock(
        tone: CalloutTone.warning,
        title: 'Raportimet e sëmundjes janë veçanërisht të mbrojtura',
        text: 'Regjistrohet vetëm FAKTI se je i paaftë për punë dhe '
            'për cilën periudhë. Një diagnozë nuk duhet ta japësh dhe '
            'as raporti për punëdhënësin nuk përmban ndonjë. Të '
            'dhënat shëndetësore janë të dhëna të veçanta sipas '
            'Art. 9 DSGVO dhe shihen vetëm nga personat që u '
            'nevojiten vërtet për vazhdimin e pagesës së pagës dhe '
            'për planifikimin.',
      ),
      SubheadBlock('Për çfarë'),
      ParagraphBlock(
        'Për planifikimin e punës, për llogaritjen e së drejtës për '
        'pushim dhe të vazhdimit të pagesës së pagës dhe për dëshmi '
        'para institucioneve të sigurimeve shoqërore.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Baza ligjore',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (zbatimi i kontratës së '
            'punës), Art. 6 Abs. 1 lit. c DSGVO (ndër të tjera BUrlG '
            'dhe EntgFG), ndërsa për të dhënat mbi paaftësinë për '
            'punë Art. 9 Abs. 2 lit. b DSGVO në lidhje me '
            '§ 26 Abs. 3 BDSG (ushtrimi i të drejtave dhe i '
            'detyrimeve nga e drejta e punës dhe nga e drejta e '
            'sigurisë sociale).',
      ),
      SubheadBlock('Sa gjatë'),
      ParagraphBlock(
        'Për kohëzgjatjen e marrëdhënies së punës dhe afatet ligjore '
        'të ruajtjes. Raportet e paaftësisë për punë fshihen sapo nuk '
        'nevojiten më për vazhdimin e pagesës së pagës dhe si dëshmi.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 7
  PrivacyNoticeSection(
    id: 'planung',
    title: 'Planifikimi i turneve dhe i valëve',
    summary: 'Kush ngas kur, në cilën valë, në cilën rrugë dhe me '
        'cilin automjet',
    blocks: [
      ParagraphBlock(
        'Dispeçeria planifikon çdo ditë kush punon, në cilën valë nis '
        'ti dhe me cilin automjet je në rrugë. Ky plan është i '
        'dukshëm për ty dhe për dispeçerinë.',
      ),
      SubheadBlock('Cilat të dhëna'),
      BulletsBlock([
        'Caktimi yt për çdo ditë — i planifikuar, i lirë, mungesë',
        'Ora e valës dhe ora e nisjes',
        'Rruga përkatësisht turi i caktuar',
        'Automjeti i caktuar me targën e tij',
        'Konfirmimi i marrjes dijeni për planin tënd',
        'Ndryshimet në plan dhe kush i ka bërë',
        'Detyrat dhe njoftimet që të janë caktuar, bashkë me '
            'konfirmimin e leximit',
      ]),
      SubheadBlock('Për çfarë'),
      ParagraphBlock(
        'Për organizimin e punës së përditshme, për caktimin e '
        'automjetit dhe të rrugës dhe për gjurmueshmërinë se kush e '
        'ka bërë cilin tur dhe kur.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Baza ligjore',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (zbatimi i kontratës së '
            'punës) dhe Art. 6 Abs. 1 lit. f DSGVO (interes legjitim '
            'për një rrjedhë pune funksionale), secili në lidhje me '
            '§ 26 BDSG.',
      ),
      SubheadBlock('Sa gjatë'),
      ParagraphBlock(
        'Për kohëzgjatjen e marrëdhënies së punës dhe afatet ligjore '
        'të ruajtjes.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 8
  PrivacyNoticeSection(
    id: 'scorecard',
    title: 'Të dhënat e performancës nga Scorecard',
    summary: 'Treguesit për sigurinë, cilësinë dhe shpërndarjen',
    blocks: [
      ParagraphBlock(
        'Klienti vë në dispozicion çdo javë tregues për veprimtarinë '
        'tënde të shpërndarjes. CoDriver e lexon këtë Scorecard dhe '
        'ta shfaq ty dhe dispeçerisë.',
      ),
      SubheadBlock('Cilat të dhëna'),
      BulletsBlock([
        'Tregues sigurie si rezultati i drejtimit FICO, ngjarjet e '
            'shpejtësisë për 100 ture dhe përdorimi i Mentor',
        'Tregues përputhshmërie si kontrolli i automjetit dhe '
            'respektimi i orareve të punës',
        'Tregues cilësie si kuota e dorëzimit, dërgesat e padorëzuara '
            'dhe kuota e humbjeve',
        'Tregues për cilësinë e dorëzimit si fotoja si dëshmi e '
            'dorëzimit dhe përputhshmëria e kontaktimit',
        'Reagimet e klientëve dhe përshkallëzimet',
        'Vlerësimi i përgjithshëm për çdo javë dhe zhvillimi i tij',
      ]),
      SubheadBlock('Për çfarë'),
      ParagraphBlock(
        'Për përmbushjen e kontratës mes punëdhënësit tënd dhe '
        'klientit, për njohjen e rreziqeve të sigurisë, për trajnim '
        'të synuar dhe për kthim informacioni te ti.',
      ),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Asnjë automatizëm mbi kokën tënde',
        text: 'Nga një tregues nuk rrjedh asnjë masë automatike. '
            'Vlerësimet dhe bisedat i bën gjithmonë një njeri dhe ti '
            'mund ta paraqesësh këndvështrimin tënd. Një vendim i '
            'automatizuar sipas Art. 22 DSGVO nuk ndodh.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Baza ligjore',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (zbatimi i kontratës së '
            'punës) dhe Art. 6 Abs. 1 lit. f DSGVO (interes legjitim '
            'për sigurinë rrugore, sigurimin e cilësisë dhe '
            'përmbushjen e detyrimeve kontraktuale ndaj klientit), në '
            'lidhje me § 26 BDSG.',
      ),
      SubheadBlock('Sa gjatë'),
      ParagraphBlock(
        'Për kohëzgjatjen e marrëdhënies së punës dhe afatet ligjore '
        'të ruajtjes.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 9
  PrivacyNoticeSection(
    id: 'empfaenger',
    title: 'Kush i sheh të dhënat e tua',
    summary: 'Marrësit brenda dhe jashtë firmës',
    blocks: [
      SubheadBlock('Brenda firmës'),
      BulletsBlock([
        'Drejtuesit e punëdhënësit tënd',
        'Dispeçeria dhe dispeçerët e autorizuar prej saj — secili '
            'vetëm për firmën e vet',
        'Ti vetë: të dhënat e tua i sheh në aplikacion në çdo kohë',
      ]),
      SubheadBlock('Jashtë firmës'),
      BulletsBlock([
        'Google Ireland/Google LLC si ofrues i hostimit (përpunim me '
            'porosi, serverë në BE)',
        'ARION Logistics GmbH si operatore e CoDriver (përpunim me '
            'porosi)',
        'Konsulenca tatimore dhe llogaritja e pagave, për aq sa '
            'punëdhënësi yt i përdor — secila mbi bazën e një '
            'kontrate për përpunimin e të dhënave',
        'Klienti, për aq sa treguesit e Scorecard vijnë gjithsesi '
            'prej andej',
        'Autoritetet, institucionet e sigurimeve shoqërore dhe '
            'sigurimi ligjor i aksidenteve në punë — vetëm nëse një '
            'bazë ligjore u jep të drejtë për këtë',
      ]),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Nuk shiten, nuk përdoren për reklama',
        text: 'Të dhënat e tua nuk shiten, nuk përdoren për reklama '
            'dhe nuk u jepen të tretëve që do të donin t\'i përdornin '
            'për qëllime të veta.',
      ),
      SubheadBlock('Nga vijnë të dhënat'),
      ParagraphBlock(
        'Pjesa më e madhe e të dhënave vjen nga ti vetë — nga aplikimi '
        'yt, nga onboarding-u dhe nga përdorimi i përditshëm i '
        'aplikacionit. Treguesit e Scorecard vijnë nga klienti, '
        'ndërsa të dhënat e planit dhe të turneve nga dispeçeria.',
      ),
      SubheadBlock('A duhet t\'i japësh të dhënat?'),
      ParagraphBlock(
        'Disa të dhëna janë të domosdoshme që marrëdhënia e punës të '
        'mund të zbatohet fare — për shembull emri, patenta dhe '
        'oraret e punës. Pa to nuk mund të vihesh në punë. Të dhëna '
        'të tjera, si fotoja e profilit, janë vullnetare; prej tyre '
        'nuk të lind asnjë disavantazh.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 10
  PrivacyNoticeSection(
    id: 'rechte',
    title: 'Të drejtat e tua',
    summary: 'Qasje, korrigjim, fshirje, kundërshtim dhe ankesë',
    blocks: [
      ParagraphBlock(
        'Ndaj punëdhënësit tënd si përgjegjës ke të drejtat e '
        'mëposhtme. Ushtrimi i tyre është pa pagesë dhe prej tij nuk '
        'të lind asnjë disavantazh.',
      ),
      BulletsBlock([
        'Qasje (Art. 15 DSGVO): Mund të mësosh nëse dhe cilat të '
            'dhëna për ty përpunohen dhe të kërkosh një kopje të tyre.',
        'Korrigjim (Art. 16 DSGVO): Të dhënat e gabuara duhet të '
            'mund t\'i korrigjosh dhe ato jo të plota t\'i plotësosh '
            '— për regjistrimet e kohës ekziston për këtë kërkesa për '
            'korrigjim në aplikacion.',
        'Fshirje (Art. 17 DSGVO): Të dhënat që nuk nevojiten më dhe '
            'që nuk i nënshtrohen asnjë detyrimi ruajtjeje, fshihen '
            'me kërkesë.',
        'Kufizim i përpunimit (Art. 18 DSGVO): Nëse është e '
            'diskutueshme a janë të sakta të dhënat ose a lejohet '
            'përpunimi i tyre, mund të kërkosh që ato deri në sqarim '
            'vetëm të ruhen.',
        'Transferueshmëri e të dhënave (Art. 20 DSGVO): Të dhënat që '
            'ke vënë në dispozicion i merr në një format të '
            'zakonshëm, të lexueshëm nga makina.',
        'Kundërshtim (Art. 21 DSGVO): Kundër përpunimeve që '
            'mbështeten në një interes legjitim — si p.sh. kontrolli '
            'automatik geofence — mund të bësh kundërshtim për arsye '
            'që lidhen me situatën tënde të veçantë.',
        'Ankesë (Art. 77 DSGVO): Mund të ankohesh në çdo kohë te një '
            'autoritet mbikëqyrës për mbrojtjen e të dhënave.',
      ]),
      SubheadBlock('Kujt i drejtohesh'),
      ParagraphBlock(
        'Së pari punëdhënësit tënd — DSP-së, emri i të cilit shënohet '
        'në krye të kësaj faqeje. Nëse ka caktuar një person '
        'përgjegjës për mbrojtjen e të dhënave, mund t\'i drejtohesh '
        'drejtpërdrejt atij; të dhënat e kontaktit t\'i jep drejtimi '
        'i firmës. Për një ankesë është kompetent autoriteti '
        'mbikëqyrës për mbrojtjen e të dhënave i landit ku firma jote '
        'e ka selinë; mund t\'i drejtohesh edhe autoritetit në '
        'vendbanimin tënd ose në vendin e shkeljes së dyshuar.',
      ),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Kaq shpejt merr përgjigje',
        text: 'Për një kërkesë përgjegjësi duhet të të përgjigjet në '
            'parim brenda një muaji. Vetëm në raste të ndërlikuara '
            'mund ta zgjasë afatin dhe duhet të të informojë për këtë.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 11
  PrivacyNoticeSection(
    id: 'bedeutung',
    title: 'Çfarë do të thotë konfirmimi yt',
    summary: 'Pse këtu informohesh dhe nuk lejon diçka',
    blocks: [
      ParagraphBlock(
        'Tani do të nënshkruash. Që të jetë e qartë çfarë nënshkruan: '
        'ti vërteton vetëm se e ke lexuar dhe kuptuar këtë '
        'informacion. Me të nuk lejon asnjë përpunim dhe nuk liron '
        'asgjë.',
      ),
      SubheadBlock('Pse kjo është e rëndësishme'),
      ParagraphBlock(
        'Në një marrëdhënie pune ti je në varësi ndaj punëdhënësit '
        'tënd. Prandaj një deklaratë me të cilën do të lejoje një '
        'përpunim vështirë se do të ishte ndonjëherë vërtet '
        'vullnetare — dhe ti do të mund ta tërhiqje në çdo kohë, gjë '
        'që do ta bënte të pamundur regjistrimin e kohës ose '
        'llogaritjen e pagave. Prandaj puna jote në CoDriver nuk '
        'mbështetet në një deklaratë të tillë, por në atë që vlen '
        'gjithsesi: zbatimi i kontratës sate të punës '
        '(Art. 6 Abs. 1 lit. b DSGVO), detyrimet ligjore të '
        'punëdhënësit tënd (Art. 6 Abs. 1 lit. c DSGVO) dhe interesat '
        'legjitime të firmës (Art. 6 Abs. 1 lit. f DSGVO), secili në '
        'lidhje me § 26 BDSG.',
      ),
      DoDontBlock(
        doTitle: 'Këtë vërteton',
        dos: [
          'Unë jam informuar sipas Art. 13 DSGVO për përpunimin e të '
              'dhënave të mia.',
          'Unë e kam lexuar dhe kuptuar këtë informacion për '
              'mbrojtjen e të dhënave.',
          'Unë e di se kujt i drejtohem me pyetje dhe kërkesa.',
        ],
        dontTitle: 'Këtë nuk e vërteton',
        donts: [
          'Asnjë leje për një përpunim — bazat ligjore shënohen te '
              'secili seksion.',
          'Asnjë heqje dorë nga të drejtat e tua sipas Art. 15 deri '
              'Art. 21 DSGVO.',
          'Asnjë heqje dorë nga e drejta jote e ankesës sipas '
              'Art. 77 DSGVO.',
        ],
      ),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Po nëse ndryshon diçka?',
        text: 'Nëse ky informacion ndryshon në përmbajtje, numri i '
            'versionit të tij rritet dhe ai të paraqitet sërish në '
            'hyrjen e ardhshme. Kështu e di gjithmonë për çfarë je '
            'informuar — dhe kur.',
      ),
      ParagraphBlock(
        'Vetë konfirmimi dokumentohet gjithashtu: ruhen Transporter-ID '
        'jote, numri i versionit, data dhe ora, gjuha e kësaj pamjeje '
        'si dhe PDF-ja e dëshmisë me nënshkrimin tënd. Bazë për këtë '
        'është detyrimi i llogaridhënies sipas Art. 5 Abs. 2 DSGVO.',
      ),
    ],
  ),
];
