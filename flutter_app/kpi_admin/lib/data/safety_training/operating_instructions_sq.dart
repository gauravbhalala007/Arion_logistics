// lib/data/safety_training/operating_instructions_sq.dart
//
// Betriebsanweisungen — albanische Fassung (Übersetzung des Masters).
// Generisch für Zustellbetriebe formuliert; betriebsspezifische Angaben
// (Ansprechpartner, Standort der Verbandkästen, Sammelplatz) ergänzt
// der jeweilige Betrieb.

import 'operating_instructions.dart';

const List<OperatingInstruction> operatingInstructionsSq = [
  // ─────────────────────────────────────────── Fahrzeug / Automjeti
  OperatingInstruction(
    id: 'baw_transporter',
    title: 'Drejtimi i furgonit deri në 3,5 t',
    subtitle: 'Drejto, manovro dhe parko automjetin e shpërndarjes',
    category: InstructionCategory.vehicle,
    scope: 'Vlen për të gjithë punonjësit që drejtojnë automjete '
        'shpërndarjeje deri në 3,5 t masë totale të lejuar.',
    hazards: [
      'Aksidente në trafik nga shpërqendrimi, presioni i kohës dhe lodhja',
      'Përplasja e personave gjatë lëvizjes prapa — këndi i vdekur',
      'Rrëshqitja e ngarkesës gjatë frenimit dhe në kthesa',
      'Rrëzime gjatë hipjes dhe zbritjes nga automjeti',
      'Tejkalimi i masës totale të lejuar',
    ],
    protection: [
      'Mbaj me vete lejen e vlefshme të drejtimit',
      'Kontrolli para nisjes: ndriçimi, gomat, frenat, pamja, sigurimi '
          'i ngarkesës',
      'Rregullo sedilen, pasqyrat dhe mbështetësen e kokës para nisjes '
          'së parë',
      'Vendos rripin e sigurimit — edhe në distancat e shkurtra mes dy '
          'ndalesave',
      'Pa alkool, pa drogë dhe pa barna që ndikojnë në aftësinë për të '
          'drejtuar, para dhe gjatë udhëtimit',
      'Telefoni vetëm me sistem duarlirë, adresa vendoset vetëm kur '
          'automjeti është i ndalur',
      'Lëvizja prapa në rast rreziku vetëm me një person udhëzues; në '
          'dyshim zbrit dhe kontrollo rrethinën',
      'Siguro ngarkesën kundër rrëshqitjes, dërgesat e rënda poshtë dhe '
          'pranë murit të përparmë',
      'Mbylle gjithmonë automjetin kur e lë, mos i lër çelësat brenda',
      'Respekto rregullat e pauzave dhe të kohës së drejtimit',
    ],
    onFailure: [
      'Në rast dritash paralajmëruese ose zhurmash të pazakonta: afrohu '
          'në një vend të sigurt dhe ndalo',
      'Ndiz dritat e avarisë, vish jelekun reflektues, vendos trekëndëshin '
          'e sigurisë (rreth 100 m, në autostradë 150–400 m)',
      'Njofto dispeçerin, kërko shërbimin e defekteve sipas rrugës së '
          'përcaktuar',
      'Mos e riparo vetë — tërheqja vetëm me shufër tërheqëse',
      'Mos e lëviz më tej automjetin me defekt të dukshëm',
    ],
    onAccident: [
      'Ndalo, siguro vendin e aksidentit, vish jelekun para se të zbresësh',
      'Jep ndihmën e parë, telefono 112',
      'Policia në rast lëndimesh të personave, dëmesh të mëdha materiale '
          'ose dyshimi për alkool/drogë',
      'Shkëmbe të dhënat personale dhe të sigurimit, siguro foto dhe '
          'dëshmitarë',
      'Njofto menjëherë punëdhënësin; regjistro në librin e ndihmës së '
          'parë edhe lëndimet e vogla',
    ],
    maintenance: [
      'Raporto dhe dokumento menjëherë defektet',
      'Mbaje automjetin të pastër, sipërfaqet e pamjes dhe të shkeljes pa '
          'borë, akull dhe papastërti',
      'Kontrollo plotësinë dhe datën e skadimit të kutisë së ndihmës së '
          'parë, trekëndëshit dhe jelekut reflektues',
      'Respekto afatet e mirëmbajtjes dhe të inspektimit',
    ],
  ),

  // ─────────────────────────────────────────── PSA / PPE
  OperatingInstruction(
    id: 'baw_sicherheitsschuhe',
    title: 'Këpucët e sigurisë',
    subtitle: 'Mbrojtja e këmbëve në punën e shpërndarjes',
    category: InstructionCategory.ppe,
    scope: 'Vlen për të gjithë punonjësit në shpërndarje, magazinë dhe '
        'oborrin e automjeteve.',
    hazards: [
      'Dërgesa dhe pjesë ngarkese që bien nga lart',
      'Shkelja mbi objekte të mprehta ose me kënde therëse',
      'Përdredhja dhe lëndimet e ligamenteve të nyjës së këmbës gjatë '
          'zbritjes, mbi trotuare dhe rrugë të parregullta',
      'Rrëshqitje mbi sipërfaqe të lagura dhe të ngrira',
      'Shtypje nga kontejnerët me rrota dhe transpaletët e dorës',
    ],
    protection: [
      'Mbaji këpucët e sigurisë gjatë gjithë kohës së punës — si në '
          'stacion ashtu edhe në rrugë, gjatë gjithë vitit dhe pavarësisht '
          'komoditetit',
      'Prefero modelin që mbulon kyçin — ai mbështet nyjën e këmbës '
          'kundër përdredhjes',
      'Së paku klasa e mbrojtjes S1; në lagështi S2, në rrezik shpimi S3',
      'Lidhi këpucët plotësisht dhe mbaji të mbyllura',
      'Kontrollo për defekte para fillimit të punës: profili, plasaritjet, '
          'ngjitja e shollës',
      'Mos bëj ndryshime vetjake në këpucë',
      'Mos puno kurrë me atlete ose me këpucë të hapura',
    ],
    onFailure: [
      'Profil i konsumuar, plasaritje ose shollë e dëmtuar: mos i përdor '
          'më këpucët',
      'Raporto këpucët që shtrëngojnë ose gërryejnë — ka modele dhe masa '
          'të tjera; kalimi te atletet private nuk është zgjidhje',
      'Kërko zëvendësimin te eprori — punëdhënësi e vë PSA/PPE në '
          'dispozicion pa pagesë',
    ],
    onAccident: [
      'Kërko menjëherë trajtim për lëndimet e këmbës, edhe për ato që '
          'duken të lehta',
      'Regjistrim në librin e ndihmës së parë',
      'Në rast plagësh nga shpimi kërko trajtim mjekësor — kontrollo '
          'mbrojtjen kundër tetanozit',
    ],
    maintenance: [
      'Pastroji këpucët rregullisht dhe lëri të thahen',
      'Zëvendëso këpucët shumë të ndotura ose të lagura tejpërtej',
      'Intervali i zëvendësimit sipas të dhënave të prodhuesit dhe '
          'konsumit',
    ],
  ),

  OperatingInstruction(
    id: 'baw_warnweste',
    title: 'Jeleku reflektues',
    subtitle: 'Të jesh i dukshëm në hapësirën rrugore',
    category: InstructionCategory.ppe,
    scope: 'Vlen për të gjithë punonjësit që qëndrojnë në hapësirën '
        'rrugore, në oborr ose në sipërfaqet e ngarkimit.',
    hazards: [
      'Të mos të shohin pjesëmarrësit e tjerë në trafik',
      'Pamje e keqe në muzg, errësirë, shi dhe mjegull',
      'Trafiku i manovrimit brenda territorit të stacionit',
    ],
    protection: [
      'Mbaje jelekun gjithmonë të arritshëm në kabinë — jo në hapësirën '
          'e ngarkesës',
      'Vishe para se të zbresësh në rast defekti, aksidenti dhe në çdo '
          'ndalesë në hapësirën rrugore',
      'Mbaje në territorin e stacionit dhe në sipërfaqet e ngarkimit kur '
          'atje lëvizin automjete',
      'Përdor jelek të klasës 2 ose 3 dhe mbylle plotësisht',
      'Në errësirë kujdesu edhe për ndriçimin dhe dritat e pozicionit',
    ],
    onFailure: [
      'Zëvendëso jelekun e ndotur, të zbehur ose të dëmtuar — shiritat '
          'reflektues duhet të jenë efektivë',
      'Raporto mungesën e jelekut para nisjes dhe kërko zëvendësimin',
    ],
    onAccident: [
      'Pas një aksidenti në hapësirën rrugore mbaje jelekun derisa vendi '
          'i aksidentit të jetë liruar',
      'Raporto dhe dokumento lëndimet',
    ],
    maintenance: [
      'Mbaje jelekun të pastër, laje sipas të dhënave të prodhuesit',
      'Kontrollo praninë e tij në automjet — pjesë e kontrollit para '
          'nisjes',
    ],
  ),

  // ─────────────────────────────────────────── Handhabung / Trajtimi
  OperatingInstruction(
    id: 'baw_heben_tragen',
    title: 'Ngritja dhe bartja',
    subtitle: 'Lëviz dërgesat pa dëmtuar shpinën',
    category: InstructionCategory.handling,
    scope: 'Vlen për ngritjen, bartjen dhe uljen manuale të dërgesave dhe '
        'të mbajtësve të ngarkesës.',
    hazards: [
      'Dëmtime të shtyllës kurrizore dhe të disqeve nga teknika e gabuar '
          'e ngritjes',
      'Lëndime të muskujve dhe të tendinave nga lëvizjet e befta',
      'Shtypje të duarve dhe të këmbëve gjatë uljes së ngarkesës',
      'Pengim nga pamja e kufizuar te dërgesat e mëdha',
    ],
    protection: [
      'Para ngritjes vlerëso peshën dhe liro rrugën',
      'Afrohu pranë ngarkesës, këmbët në gjerësinë e shpatullave',
      'Ngri me këmbë: përkulu në gjunjë, mbaje shpinën drejt',
      'Mbaje ngarkesën pranë trupit, jo në gjatësinë e krahut',
      'Mos ngri dhe rrotullohu njëkohësisht — zhvendosu me këmbë',
      'Lëviz dërgesat e rënda ose të parehatshme në dy veta ose me mjete '
          'ndihmëse (kontejner me rrota, karrocë dore, transpalet dore)',
      'Mbaje pamjen të lirë gjatë bartjes; në dyshim bëj dy herë rrugën',
      'Vish doreza te dërgesat me kënde të mprehta',
    ],
    onFailure: [
      'Mos e lëviz vetëm një ngarkesë shumë të rëndë ose të papërshtatshme '
          '— kërko ndihmë',
      'Mos përdor mjete ndihmëse me defekt (rrota të bllokuara, karrocë '
          'dore e dëmtuar) dhe raportoji',
    ],
    onAccident: [
      'Në rast dhimbjeje të papritur në shpinë ndërprit menjëherë punën',
      'Njofto eprorin, regjistrim në librin e ndihmës së parë',
      'Në rast ankesash të vazhdueshme vizito mjekun e specializuar për '
          'aksidente në punë (Durchgangsarzt)',
    ],
    maintenance: [
      'Kontrollo rregullisht funksionimin e mjeteve ndihmëse të '
          'transportit',
      'Mbaji rrugët e kalimit dhe sipërfaqet e ngarkimit të lira dhe '
          'kundër rrëshqitjes',
    ],
  ),

  OperatingInstruction(
    id: 'baw_winter',
    title: 'Kushtet dimërore të rrugës',
    subtitle: 'Drejtimi dhe shpërndarja në borë, akull dhe lagështi',
    category: InstructionCategory.vehicle,
    scope: 'Vlen për shpërndarjen dhe qarkullimin në kushte dimërore.',
    hazards: [
      'Rrugë frenimi më e gjatë, rrëshqitje anësore, akuaplanim',
      'Rrëzime mbi trotuare, rampa dhe shkallë të ngrira',
      'Ftohje e tepërt gjatë qëndrimit të gjatë jashtë',
      'Pamje e kufizuar nga xhamat dhe pasqyrat e ngrira',
    ],
    protection: [
      'Pastro plotësisht automjetin nga bora dhe akulli para nisjes — '
          'edhe çatinë, fenerët dhe targat',
      'Goma të përshtatshme për dimër; mbaj me vete zinxhirë dhe mjete '
          'ndihmëse nisjeje sipas nevojës',
      'Kontrollo antifrizin në ujin ftohës dhe në atë të xhamave, mbaj '
          'kruajtësen e akullit në bord',
      'Ul ndjeshëm shpejtësinë, dyfisho të paktën distancën',
      'Freno, drejto dhe përshpejto butësisht',
      'Pastro nga bora sipërfaqet e shkeljes dhe shkallët para përdorimit',
      'Vish veshje të ngrohta e rezistente ndaj motit dhe këpucë kundër '
          'rrëshqitjes',
      'Shmang presionin e kohës — më mirë të arrish më vonë sesa aspak',
    ],
    onFailure: [
      'Në rrugë të pakalueshme ndërprit turin dhe njofto dispeçerin',
      'Nëse automjeti ngec, mos u përpjek ta lirosh me forcë — kërko '
          'ndihmë',
    ],
    onAccident: [
      'Siguro vendin e aksidentit me kujdes të veçantë — vendose '
          'trekëndëshin më larg',
      'Raporto dhe dokumento lëndimet nga rrëzimi edhe në simptoma të '
          'lehta',
    ],
    maintenance: [
      'Kontrollo rregullisht fshirëset dhe ndriçimin',
      'Kujdesu për gominat e dyerve, shkrij akullin e brave',
    ],
  ),

  // ────────────────────────────── Gefahrstoffe / Substanca të rrezikshme
  OperatingInstruction(
    id: 'baw_adblue',
    title: 'AdBlue (tretësirë ureje)',
    subtitle: 'Mbushja e AdBlue në automjetin e shpërndarjes',
    category: InstructionCategory.hazardous,
    scope: 'Vlen për mbushjen dhe trajtimin e AdBlue në automjete me '
        'sistem pastrimi të gazrave SCR.',
    hazards: [
      'Irritim i syve, i lëkurës dhe i rrugëve të frymëmarrjes në kontakt',
      'Rrezik rrëshqitjeje nga lëngu i derdhur',
      'Kristalizim dhe korrozion në pjesët e automjetit',
      'Ndotje e mjedisit në rast futjeje në tokë ose në kanalizim',
    ],
    protection: [
      'Përdor vetëm gropëzën e parashikuar blu të mbushjes — kurrë mos e '
          'derdh në rezervuarin e naftës',
      'Vish doreza mbrojtëse, shmang kontaktin me lëkurën',
      'Mbush vetëm jashtë ose në vend të ajrosur mirë, fike motorin',
      'Mbylle mirë enën, mos e ruaj në diell',
      'Pas përdorimit laji duart mirë',
    ],
    onFailure: [
      'Holo menjëherë me ujë lëngun e derdhur dhe mblidhe',
      'Përdor material thithës, mos e shpëlaj në kanalizim',
      'Në rast mbushjeje të gabuar mos e ndiz automjetin dhe raporto '
          'menjëherë',
    ],
    onAccident: [
      'Kontakt me sytë: shpëlaj me ujë të paktën 15 minuta, vizito mjekun',
      'Kontakt me lëkurën: shpëlaj me shumë ujë, ndërro rrobat e njomura',
      'Gëlltitje: shpëlaj gojën, pi ujë, vizito mjekun',
      'Raporto incidentin dhe regjistroje në librin e ndihmës së parë',
    ],
    maintenance: [
      'Mbaji të pastra enën dhe zonën e mbushjes',
      'Asgjëso enët e zbrazëta sipas rregullave',
    ],
  ),

  // ─────────────────────────────────────────── Hygiene / Higjiena
  OperatingInstruction(
    id: 'baw_hautschutz',
    title: 'Mbrojtja e lëkurës dhe higjiena e duarve',
    subtitle: 'Mbro duart në kontaktin me klientët dhe në ngarkim',
    category: InstructionCategory.hygiene,
    scope: 'Vlen për të gjithë punonjësit me kontakt të shpeshtë të '
        'duarve me dërgesa, automjete dhe klientë.',
    hazards: [
      'Tharje dhe plasaritje nga larja dhe dezinfektimi i shpeshtë',
      'Irritime të lëkurës nga papastërtia, të ftohtit dhe detergjentët',
      'Përhapje e infeksioneve në kontaktin me klientët',
      'Prerje dhe gërvishtje në skajet e kartonëve',
    ],
    protection: [
      'Vendos kremin mbrojtës të lëkurës para fillimit të punës',
      'Laji duart pas tualetit, para pauzave dhe pas punës së ngarkimit',
      'Fërko plotësisht dezinfektuesin dhe lëre të thahet — mos e fshij',
      'Pas larjes përdor krem kujdesi për lëkurën',
      'Doreza mbrojtëse te dërgesat me kënde të mprehta ose të ndotura',
      'Hiq unazat dhe orët e dorës gjatë punës së ngarkimit',
    ],
    onFailure: [
      'Në rast skuqjeje të vazhdueshme, kruajtjeje ose plasaritjeje '
          'raporto punën',
      'Mos e përdor më produktin që nuk e duron — kërko një alternativë',
    ],
    onAccident: [
      'Pastro dhe fasho menjëherë prerjet dhe gërvishtjet',
      'Regjistrim në librin e ndihmës së parë, edhe te lëndimet e vogla',
      'Në shenja inflamacioni kërko trajtim mjekësor',
    ],
    maintenance: [
      'Kontrollo nivelin e mbushjes së dozuesve të sapunit, të '
          'dezinfektuesit dhe të kremit',
      'Raporto dozuesit e zbrazët ose me defekt',
    ],
  ),

  // ─────────────────────────────────────────── Arbeitsplatz / Vendi i punës
  OperatingInstruction(
    id: 'baw_bildschirm',
    title: 'Vendi i punës me ekran',
    subtitle: 'Disponimi i turneve dhe puna në zyrë',
    category: InstructionCategory.workplace,
    scope: 'Vlen për punonjësit që punojnë kryesisht para ekranit — '
        'veçanërisht dispeçerët dhe administrata.',
    hazards: [
      'Ankesa të syve nga shkëlqimi dhe fokusimi i gjatë',
      'Tendosje në qafë, shpatulla dhe shpinë',
      'Irritim i tendinave nga qëndrimi i papërshtatshëm i dorës dhe i '
          'krahut',
      'Pengim te kabllot',
    ],
    protection: [
      'Skaji i sipërm i ekranit afërsisht në lartësinë e syve, distanca '
          'e shikimit 50–70 cm',
      'Vendose ekranin anash dritares — jo përpara dhe jo kundrejt saj',
      'Zgjidh lartësinë e uljes ashtu që parakrahu dhe krahu të formojnë '
          'afërsisht një kënd të drejtë',
      'Këmbët të shtrira në dysheme ose mbi një mbështetëse këmbësh',
      'Ndrysho rregullisht qëndrimin, bëj pauza të shkurtra duke shikuar '
          'larg',
      'Vendos dhe siguro kabllot',
    ],
    onFailure: [
      'Raporto ekranet dhe ndriçuesit që dridhen ose janë me defekt',
      'Mos i përdor më karriget me defekt',
    ],
    onAccident: [
      'Në rast ankesash të vazhdueshme njofto eprorin',
      'Kontrollo të drejtën për kujdes mjekësor të punës dhe për syze të '
          'punës me ekran',
    ],
    maintenance: [
      'Mbaji të pastra ekranin dhe pajisjet hyrëse',
      'Kontrollo rregullisht ndriçimin e vendit të punës',
    ],
  ),
];
