// lib/data/safety_training/operating_instructions_ro.dart
//
// Betriebsanweisungen — rumaenische Fassung (uebersetzt aus DE).
// Generisch für Zustellbetriebe formuliert; betriebsspezifische Angaben
// (Ansprechpartner, Standort der Verbandkästen, Sammelplatz) ergänzt
// der jeweilige Betrieb.

import 'operating_instructions.dart';

const List<OperatingInstruction> operatingInstructionsRo = [
  // ─────────────────────────────────────────── Fahrzeug
  OperatingInstruction(
    id: 'baw_transporter',
    title: 'Conducerea autoutilitarei de până la 3,5 t',
    subtitle: 'Condu, manevrează și parchează vehiculul de livrare',
    category: InstructionCategory.vehicle,
    scope: 'Se aplică tuturor angajaților care conduc vehicule de livrare '
        'de până la 3,5 t masă totală maximă autorizată.',
    hazards: [
      'Accidente rutiere din cauza distragerii, presiunii timpului și '
          'oboselii',
      'Lovirea persoanelor la mersul cu spatele — unghiul mort',
      'Alunecarea încărcăturii la frânare și în curbe',
      'Căderi la urcarea în vehicul și la coborârea din el',
      'Depășirea masei totale maxime autorizate',
    ],
    protection: [
      'Ai mereu la tine permisul de conducere valabil',
      'Controlul înainte de plecare: iluminat, anvelope, frâne, '
          'vizibilitate, asigurarea încărcăturii',
      'Reglează scaunul, oglinzile și tetiera înainte de prima cursă',
      'Pune-ți centura de siguranță — și pe distanțele scurte dintre '
          'două opriri',
      'Fără alcool, fără droguri, fără medicamente care îți afectează '
          'capacitatea de a conduce, înainte și în timpul cursei',
      'Telefonul mobil doar cu dispozitiv hands-free, introducerea '
          'adresei doar din staționare',
      'Mersul cu spatele în caz de pericol numai cu un ghidator; la '
          'orice îndoială coboară și verifică zona',
      'Asigură încărcătura împotriva alunecării, coletele grele jos și '
          'lipite de peretele frontal',
      'Încuie vehiculul de fiecare dată când îl părăsești, nu lăsa '
          'niciodată cheia în contact',
      'Respectă reglementările privind pauzele și timpii de conducere',
    ],
    onFailure: [
      'La lămpi de avertizare sau zgomote neobișnuite: oprește într-un '
          'loc sigur',
      'Pornește luminile de avarie, îmbracă vesta reflectorizantă, '
          'montează triunghiul (cca. 100 m, pe autostradă 150–400 m)',
      'Informează dispecerul și cere serviciul de depanare pe canalul '
          'stabilit',
      'Nu repara singur — remorcarea numai cu bară rigidă',
      'Nu deplasa mai departe un vehicul cu defecțiune vizibilă',
    ],
    onAccident: [
      'Oprește, asigură locul accidentului, vesta reflectorizantă '
          'înainte de a coborî',
      'Acordă primul ajutor, apelează 112',
      'Poliția în caz de vătămare corporală, pagube materiale mari sau '
          'suspiciune de alcool/droguri',
      'Schimbă datele personale și de asigurare, fă fotografii și '
          'notează martorii',
      'Informează imediat angajatorul; înregistrează în registrul de '
          'prim ajutor și rănile mici',
    ],
    maintenance: [
      'Raportează și documentează imediat defecțiunile',
      'Menține vehiculul curat, suprafețele de vizibilitate și treptele '
          'fără zăpadă, gheață și murdărie',
      'Verifică trusa sanitară, triunghiul și vesta reflectorizantă — '
          'completitudine și termen de valabilitate',
      'Respectă termenele de întreținere și inspecție',
    ],
  ),

  // ─────────────────────────────────────────── PSA
  OperatingInstruction(
    id: 'baw_sicherheitsschuhe',
    title: 'Încălțăminte de protecție',
    subtitle: 'Protecția picioarelor în activitatea de livrare',
    category: InstructionCategory.ppe,
    scope: 'Se aplică tuturor angajaților din livrare, depozit și curtea '
        'de vehicule.',
    hazards: [
      'Colete și părți din încărcătură care cad',
      'Călcarea pe obiecte ascuțite sau cu muchii tăioase',
      'Scrântiri și leziuni de ligamente la gleznă la coborârea din '
          'vehicul, pe borduri și pe drumuri denivelate',
      'Alunecarea pe suprafețe ude și înghețate',
      'Striviri provocate de containere rulante și transpalete manuale',
    ],
    protection: [
      'Poartă încălțămintea de protecție pe tot programul — în stație '
          'ca și pe rută, tot anul și indiferent de confortul purtării',
      'Preferă modelul care acoperă glezna — sprijină articulația '
          'împotriva scrântirii',
      'Cel puțin clasa de protecție S1; la umezeală S2, la pericol de '
          'perforare S3',
      'Leagă complet șireturile, poart-o închisă',
      'Verifică defectele înainte de lucru: profil, fisuri, aderența '
          'tălpii',
      'Nu face modificări proprii la încălțăminte',
      'Nu lucra niciodată în adidași sau în încălțăminte deschisă',
    ],
    onFailure: [
      'Profil uzat, fisuri sau talpă defectă: nu mai folosi '
          'încălțămintea',
      'Raportează încălțămintea care strânge sau freacă — există alte '
          'modele și mărimi; trecerea la adidașii personali nu este o '
          'soluție',
      'Cere înlocuirea de la superior — angajatorul pune la dispoziție '
          'echipamentul individual de protecție (PSA/PPE) gratuit',
    ],
    onAccident: [
      'Tratează imediat rănile la picioare, chiar și pe cele ușoare',
      'Înregistrare în registrul de prim ajutor',
      'La răni prin înțepare, tratament medical — verifică protecția '
          'antitetanică',
    ],
    maintenance: [
      'Curăță regulat încălțămintea și las-o să se usuce',
      'Înlocuiește încălțămintea foarte murdară sau îmbibată cu apă',
      'Interval de înlocuire conform indicațiilor producătorului și '
          'gradului de uzură',
    ],
  ),

  OperatingInstruction(
    id: 'baw_warnweste',
    title: 'Vesta reflectorizantă',
    subtitle: 'Să fii văzut în spațiul rutier',
    category: InstructionCategory.ppe,
    scope: 'Se aplică tuturor angajaților care se află în spațiul rutier, '
        'în curte sau la rampele de încărcare.',
    hazards: [
      'Riscul de a nu fi observat de ceilalți participanți la trafic',
      'Vizibilitate slabă în amurg, pe întuneric, la ploaie și ceață',
      'Trafic de manevră pe teritoriul stației',
    ],
    protection: [
      'Ține vesta la îndemână în cabină — nu în compartimentul de '
          'marfă',
      'Îmbrac-o înainte de a coborî la pană, la accident și la orice '
          'oprire în spațiul rutier',
      'Poart-o pe teritoriul stației și la rampele de încărcare, acolo '
          'unde circulă vehicule',
      'Folosește o vestă din clasa 2 sau 3 și închide-o complet',
      'Pe întuneric ai grijă suplimentar la iluminat și la luminile de '
          'poziție',
    ],
    onFailure: [
      'Înlocuiește vesta murdară, decolorată sau deteriorată — benzile '
          'reflectorizante trebuie să fie eficiente',
      'Raportează vesta lipsă înainte de plecare și cere înlocuirea',
    ],
    onAccident: [
      'După un accident în spațiul rutier păstrează vesta pe tine până '
          'când locul accidentului este eliberat',
      'Raportează și documentează rănile',
    ],
    maintenance: [
      'Păstrează vesta curată, spal-o conform indicațiilor '
          'producătorului',
      'Verifică prezența ei în vehicul — face parte din controlul '
          'înainte de plecare',
    ],
  ),

  // ─────────────────────────────────────────── Handhabung
  OperatingInstruction(
    id: 'baw_heben_tragen',
    title: 'Ridicarea și transportul manual',
    subtitle: 'Mută coletele fără să îți afectezi spatele',
    category: InstructionCategory.handling,
    scope: 'Se aplică ridicării, transportului și așezării manuale a '
        'coletelor și a suporturilor de încărcătură.',
    hazards: [
      'Leziuni ale coloanei vertebrale și ale discurilor '
          'intervertebrale din cauza tehnicii greșite de ridicare',
      'Leziuni musculare și tendinoase din cauza mișcărilor bruște',
      'Striviri la mâini și la picioare când lași sarcina jos',
      'Împiedicare din cauza vizibilității reduse la coletele mari',
    ],
    protection: [
      'Înainte de ridicare estimează greutatea și eliberează drumul',
      'Apropie-te de sarcină, picioarele la lățimea umerilor',
      'Ridică din picioare: îndoaie genunchii, ține spatele drept',
      'Poartă sarcina aproape de corp, nu la distanță de un braț',
      'Nu ridica și nu te răsuci în același timp — schimbă direcția din '
          'picioare',
      'Mută coletele grele sau voluminoase în doi sau cu mijloace '
          'ajutătoare (container rulant, liză, transpaletă manuală)',
      'Păstrează vizibilitatea liberă în timpul transportului; la '
          'îndoială mergi de două ori',
      'Poartă mănuși la coletele cu muchii tăioase',
    ],
    onFailure: [
      'Nu mișca singur o sarcină prea grea sau greu de manevrat — cere '
          'ajutor',
      'Nu folosi mijloacele ajutătoare defecte (roți blocate, liză '
          'deteriorată) și raportează-le',
    ],
    onAccident: [
      'La o durere bruscă în spate întrerupe imediat activitatea',
      'Informează superiorul, înregistrează în registrul de prim ajutor',
      'La dureri persistente mergi la medicul de traumatologie '
          'autorizat (Durchgangsarzt)',
    ],
    maintenance: [
      'Verifică regulat funcționarea mijloacelor auxiliare de transport',
      'Menține căile de circulație și suprafețele de încărcare libere '
          'și antiderapante',
    ],
  ),

  OperatingInstruction(
    id: 'baw_winter',
    title: 'Condiții de drum de iarnă',
    subtitle: 'Condusul și livrarea pe zăpadă, gheață și umezeală',
    category: InstructionCategory.vehicle,
    scope: 'Se aplică livrării și circulației în condiții de iarnă.',
    hazards: [
      'Distanță de frânare mărită, derapaj, acvaplanare',
      'Căderi pe trotuare, rampe și trepte înghețate',
      'Hipotermie la șederea îndelungată în aer liber',
      'Vizibilitate redusă din cauza parbrizului și oglinzilor '
          'înghețate',
    ],
    protection: [
      'Curăță complet vehiculul de zăpadă și gheață înainte de plecare '
          '— inclusiv plafonul, farurile și plăcuțele de înmatriculare',
      'Anvelope potrivite pentru iarnă; ia cu tine lanțuri și mijloace '
          'de pornire la nevoie',
      'Verifică antigelul din lichidul de răcire și din cel de spălare, '
          'ai racleta de gheață la bord',
      'Reduce clar viteza, cel puțin dublează distanța de siguranță',
      'Frânează, virează și accelerează lin',
      'Curăță de zăpadă treptele și zonele de urcare înainte de a le '
          'folosi',
      'Poartă îmbrăcăminte caldă, rezistentă la intemperii, și '
          'încălțăminte antiderapantă',
      'Evită presiunea timpului — mai bine ajungi mai târziu decât '
          'deloc',
    ],
    onFailure: [
      'La drumuri impracticabile întrerupe tura și informează '
          'dispecerul',
      'Dacă vehiculul se împotmolește nu forța ieșirea — cere ajutor',
    ],
    onAccident: [
      'Asigură locul accidentului cu grijă deosebită — montează '
          'triunghiul mai departe de vehicul',
      'Raportează și documentează rănile din căzături chiar și la '
          'simptome ușoare',
    ],
    maintenance: [
      'Controlează regulat lamelele ștergătoarelor și iluminatul',
      'Îngrijește garniturile ușilor, dezgheață încuietorile',
    ],
  ),

  // ─────────────────────────────────────────── Gefahrstoffe
  OperatingInstruction(
    id: 'baw_adblue',
    title: 'AdBlue (soluție de uree)',
    subtitle: 'Alimentarea cu AdBlue la vehiculul de livrare',
    category: InstructionCategory.hazardous,
    scope: 'Se aplică alimentării și manipulării AdBlue la vehiculele cu '
        'sistem SCR de tratare a gazelor de evacuare.',
    hazards: [
      'Iritarea ochilor, a pielii și a căilor respiratorii la contact',
      'Pericol de alunecare din cauza lichidului vărsat',
      'Cristalizare și coroziune la piesele vehiculului',
      'Poluarea mediului la pătrunderea în sol sau în canalizare',
    ],
    protection: [
      'Folosește numai bușonul albastru prevăzut — nu turna niciodată '
          'în rezervorul de motorină',
      'Poartă mănuși de protecție, evită contactul cu pielea',
      'Alimentează numai în aer liber sau bine ventilat, cu motorul '
          'oprit',
      'Închide bine recipientul, nu îl depozita la soare',
      'După manipulare spală-te bine pe mâini',
    ],
    onFailure: [
      'Diluează imediat cu apă lichidul vărsat și absoarbe-l',
      'Folosește material absorbant, nu spăla lichidul în canalizare',
      'La alimentare greșită nu porni vehiculul și anunță imediat',
    ],
    onAccident: [
      'Contact cu ochii: clătește cel puțin 15 minute cu apă și mergi '
          'la medic',
      'Contact cu pielea: spală cu multă apă, schimbă îmbrăcămintea '
          'stropită',
      'Înghițire: clătește gura, bea apă, mergi la medic',
      'Raportează incidentul și înregistrează-l în registrul de prim '
          'ajutor',
    ],
    maintenance: [
      'Menține curate recipientul și zona de alimentare',
      'Elimină ambalajele goale conform prevederilor',
    ],
  ),

  // ─────────────────────────────────────────── Hygiene
  OperatingInstruction(
    id: 'baw_hautschutz',
    title: 'Protecția pielii și igiena mâinilor',
    subtitle: 'Protejează-ți mâinile la contactul cu clienții și la '
        'încărcare',
    category: InstructionCategory.hygiene,
    scope: 'Se aplică tuturor angajaților cu contact frecvent al mâinilor '
        'cu colete, vehicule și clienți.',
    hazards: [
      'Uscarea și fisurarea pielii din cauza spălării și dezinfectării '
          'frecvente',
      'Iritații ale pielii din cauza murdăriei, frigului și '
          'detergenților',
      'Transmiterea infecțiilor la contactul cu clienții',
      'Tăieturi și julituri la muchiile cartoanelor',
    ],
    protection: [
      'Aplică produsul de protecție a pielii înainte de începerea '
          'lucrului',
      'Spală-te pe mâini după toaletă, înainte de pauze și după lucrul '
          'la încărcare',
      'Freacă dezinfectantul complet și lasă-l să se usuce — nu îl '
          'șterge',
      'După spălare folosește o cremă de îngrijire a pielii',
      'Mănuși de protecție la coletele cu muchii tăioase sau murdare',
      'Scoate inelele și ceasurile la lucrul de încărcare',
    ],
    onFailure: [
      'La roșeață persistentă, mâncărime sau fisuri raportează '
          'activitatea',
      'Nu mai folosi un produs pe care nu îl suporți — cere o '
          'alternativă',
    ],
    onAccident: [
      'Curăță și pansează imediat tăieturile și juliturile',
      'Înregistrare în registrul de prim ajutor, și la rănile mici',
      'La semne de inflamație, tratament medical',
    ],
    maintenance: [
      'Verifică nivelul din dozatoarele de săpun, de dezinfectant și de '
          'cremă',
      'Raportează dozatoarele goale sau defecte',
    ],
  ),

  // ─────────────────────────────────────────── Arbeitsplatz
  OperatingInstruction(
    id: 'baw_bildschirm',
    title: 'Postul de lucru la ecran',
    subtitle: 'Dispecerat și muncă de birou',
    category: InstructionCategory.workplace,
    scope: 'Se aplică angajaților care lucrează preponderent la ecran — '
        'în special dispecerilor și administrației.',
    hazards: [
      'Probleme ale ochilor din cauza reflexiilor și a focalizării '
          'îndelungate',
      'Tensiuni în ceafă, umeri și spate',
      'Iritarea tecilor tendoanelor din cauza poziției nepotrivite a '
          'mâinii și a brațului',
      'Împiedicare de cabluri',
    ],
    protection: [
      'Marginea superioară a ecranului aproximativ la nivelul ochilor, '
          'distanța de vizionare 50–70 cm',
      'Așază ecranul lateral față de fereastră — nu în fața ei și nu cu '
          'spatele la ea',
      'Alege înălțimea scaunului astfel încât antebrațele și brațele să '
          'formeze aproximativ un unghi drept',
      'Ține tălpile plat pe podea sau pe un suport pentru picioare',
      'Schimbă regulat poziția, fă scurte pauze privind în depărtare',
      'Ghidează și fixează cablurile',
    ],
    onFailure: [
      'Raportează ecranele și lămpile care pâlpâie sau sunt defecte',
      'Nu mai folosi scaunele defecte',
    ],
    onAccident: [
      'La dureri persistente informează superiorul',
      'Verifică dreptul la supraveghere medicală a muncii și la '
          'ochelari pentru lucrul la ecran',
    ],
    maintenance: [
      'Menține curate ecranul și dispozitivele de introducere a datelor',
      'Verifică regulat iluminatul postului de lucru',
    ],
  ),
];
