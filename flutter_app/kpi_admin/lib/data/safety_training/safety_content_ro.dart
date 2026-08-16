// lib/data/safety_training/safety_content_ro.dart
//
// Continutul instruirii de securitate — versiunea in limba romana.

import 'safety_blocks.dart';

const String _a = 'assets/academy/safety/';

const List<SafetyChapterContent> safetyContentRo = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ch01',
    title: 'Baza legală și obligațiile tale',
    summary: 'De ce există protecția muncii — și cu ce trebuie să '
        'contribui tu',
    asset: '${_a}ch01_grundlagen.svg',
    slides: [
      SafetySlide(
        title: 'Pe ce se bazează protecția muncii',
        asset: '${_a}ch01_grundlagen.svg',
        blocks: [
          ParagraphBlock(
            'Protecția muncii nu este o ofertă opțională a angajatorului '
            'tău, ci este prevăzută prin lege. Ea se sprijină pe doi '
            'piloni: dreptul statului și dreptul asigurătorilor pentru '
            'accidente de muncă.',
          ),
          BulletsBlock([
            'Arbeitsschutzgesetz (ArbSchG) — reglementează obligațiile '
                'angajatorului, precum și drepturile și obligațiile '
                'angajaților',
            'Regulamente — concretizează legea, de ex. regulamentele '
                'privind locurile de muncă, siguranța în exploatare și '
                'substanțele periculoase',
            'DGUV Vorschriften — reguli obligatorii ale asociației '
                'profesionale, obligatorii pentru tine ca asigurat',
            'DGUV Regeln și Informationen — ajutoare de aplicare și '
                'recomandări, fără caracter obligatoriu, dar verificate '
                'în practică',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Diferența care contează',
            text: 'DGUV Vorschriften sunt obligatorii. DGUV Regeln arată '
                'cum se pun în aplicare. DGUV Informationen sunt '
                'recomandări.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Cele șase obligații ale tale ca angajat',
        blocks: [
          ParagraphBlock(
            'Angajatorul trebuie să te protejeze — tu trebuie să '
            'participi. Aceste obligații sunt valabile pentru fiecare '
            'angajat, indiferent de poziție și de contract.',
          ),
          StepsBlock([
            'Ai grijă de propria siguranță și de cea a colegilor tăi',
            'Respectă Betriebsanweisungen și instruirile primite',
            'Acordă primul ajutor, respectiv sprijină acordarea eficientă '
                'a primului ajutor',
            'Raportează accidentele și situațiile la limită — inclusiv '
                'pe cele mici',
            'Raportează imediat defecțiunile și lipsurile (cabluri '
                'defecte, aparate stricate, proceduri greșite)',
            'Folosește echipamentul de protecție conform destinației — '
                'bocanci de siguranță, mănuși, vestă reflectorizantă, '
                'protecție auditivă',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Alcool, droguri, medicamente',
            text: 'Nu ai voie să te pui pe tine și pe alții în pericol '
                'prin substanțe care te amețesc. Asta este valabil pe '
                'tot programul de lucru — și în pauză, pentru că după '
                'aceea conduci din nou. Intră aici și medicamentele care '
                'te fac somnoros: dacă ai dubii, întreabă-ți medicul.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ch02',
    title: 'Betriebsanweisungen',
    summary: 'Instrucțiuni obligatorii — și de ce te protejează',
    asset: '${_a}ch02_betriebsanweisungen.svg',
    slides: [
      SafetySlide(
        title: 'Ce este o Betriebsanweisung',
        asset: '${_a}ch02_betriebsanweisungen.svg',
        blocks: [
          ParagraphBlock(
            'O Betriebsanweisung este o instrucțiune obligatorie a '
            'angajatorului tău pentru lucrul cu vehicule, echipamente de '
            'muncă și substanțe periculoase. Nu este o recomandare.',
          ),
          BulletsBlock([
            'Este afișată în firmă — trebuie să o cunoști',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Asta ar trebui să știi',
            text: 'Cine încalcă o Betriebsanweisung poate fi tras la '
                'răspundere la cercetarea accidentului. În cel mai rău '
                'caz înseamnă coresponsabilitate pentru un accident — '
                'inclusiv pentru tine personal.',
          ),
          ParagraphBlock(
            'Delimitare: Betriebsanweisung reglementează lucrul cu un '
            'echipament de muncă sau cu o substanță periculoasă. '
            'Instrucțiunea de lucru reglementează desfășurarea unui '
            'proces de muncă.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Structura — șase secțiuni',
        blocks: [
          ParagraphBlock(
            'Fiecare Betriebsanweisung are aceeași structură. Dacă îi '
            'cunoști structura, găsești imediat locul potrivit atunci '
            'când chiar contează.',
          ),
          StepsBlock([
            'Domeniul de aplicare — pentru ce și pentru cine este '
                'valabilă',
            'Pericole pentru om și pentru mediu',
            'Măsuri de protecție și reguli de comportament',
            'Comportamentul în caz de defecțiuni',
            'Comportamentul în caz de accident și primul ajutor',
            'Eliminarea deșeurilor și întreținerea',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Exemplu: condusul autoutilitarei',
        blocks: [
          ParagraphBlock(
            'Așa arată reguli concrete dintr-o Betriebsanweisung pentru '
            'vehicule de până la 3,5 t:',
          ),
          BulletsBlock([
            'Ai la tine permisul de conducere valabil',
            'Fără alcool și fără droguri înainte și în timpul condusului',
            'Mersul cu spatele, dacă există pericol, doar cu o persoană '
                'care te dirijează',
            'Încuie vehiculul de fiecare dată când îl părăsești',
            'Remorcarea doar cu bară rigidă',
            'Asigură locul accidentului, raportează imediat orice '
                'accident',
            'Tratează imediat și rănile mici și notează-le în registrul '
                'de prim ajutor',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Dacă ai dubii, întreabă',
            text: 'Dacă o instrucțiune nu îți este clară, întreabă-ți '
                'dispecerul — înainte să pleci, nu după.',
          ),
          SubheadBlock('Cele mai importante instrucțiuni'),
          ParagraphBlock(
            'Toate Betriebsanweisungen le găsești oricând în DA Academy, '
            'la „Betriebsanweisungen".',
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
    title: 'Cele 10 reguli pentru lucrul în siguranță',
    summary: 'Esența zilei tale de lucru — valabilă în fiecare zi',
    asset: '${_a}ch03_sicheres_arbeiten.svg',
    slides: [
      SafetySlide(
        title: 'Zece reguli, în fiecare zi',
        asset: '${_a}ch03_sicheres_arbeiten.svg',
        blocks: [
          StepsBlock([
            'Lucru sigur și prevăzător',
            'Controlul vehiculului înainte de plecare',
            'Asigurarea încărcăturii în vehicul',
            'Condus profesionist și respectarea regulilor de circulație',
            'Punerea centurii de siguranță',
            'Menținerea în ordine a vehiculelor, uneltelor și '
                'echipamentelor',
            'Lucrul doar cu încălțăminte potrivită',
            'Comportament politicos față de colegi și clienți',
            'Respectarea regulilor privind pauzele',
            'Comportament tolerant și respectuos',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Cele trei cu cel mai mare efect',
            text: 'Controlul înainte de plecare, asigurarea încărcăturii, '
                'centura de siguranță. Aceste trei previn cele mai multe '
                'urmări grave — și împreună nu costă nici trei minute.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ch04',
    title: 'Echipamentul individual de protecție (EIP)',
    summary: 'Bocancii de siguranță și vesta reflectorizantă — obligația '
        'ta zilnică',
    asset: '${_a}ch04_psa.svg',
    slides: [
      SafetySlide(
        title: 'EIP-ul tău ca livrator',
        asset: '${_a}ch04_psa.svg',
        blocks: [
          ParagraphBlock(
            'Echipamentul individual de protecție înseamnă tot ce porți '
            'pe corp ca să te aperi de pericole. În livrări, două piese '
            'sunt obligatorii în fiecare zi:',
          ),
          FactsBlock([
            FactItem('1', 'Bocanci de siguranță'),
            FactItem('2', 'Vestă reflectorizantă'),
          ]),
          BulletsBlock([
            'Bocanci de siguranță — toată ziua de lucru, atât în stație, '
                'cât și pe rută',
            'Vestă reflectorizantă — la îndemână în vehicul și îmbrăcată '
                'înainte să cobori la o pană, un accident sau o oprire pe '
                'carosabil',
          ]),
          SubheadBlock('Alt EIP — în funcție de activitate'),
          ParagraphBlock(
            'Acest echipament nu este obligatoriu zilnic, dar poate fi '
            'necesar pentru anumite lucrări. Ce se aplică în cazul tău '
            'scrie în evaluarea riscurilor și în Betriebsanweisung.',
          ),
          BulletsBlock([
            'Mănuși de protecție — la colete cu muchii ascuțite, la '
                'lucrări de curățenie și întreținere, iarna',
            'Protecție auditivă — la zgomot, de ex. în anumite zone din '
                'hală',
            'Ochelari de protecție — la lucrări cu risc de stropire',
            'Cască de protecție — pe șantiere și când există pericol de '
                'cădere a obiectelor',
            'Îmbrăcăminte de protecție împotriva intemperiilor — la lucru '
                'permanent în aer liber',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Obligația de utilizare',
            text: 'EIP-ul pus la dispoziție de angajator trebuie folosit '
                'conform destinației (§ 15 Arbeitsschutzgesetz). '
                'Angajatorul îl pune la dispoziție gratuit și trebuie să '
                'supravegheze respectarea regulii.',
          ),
          InstructionRefBlock(['baw_sicherheitsschuhe', 'baw_warnweste']),
        ],
      ),
      SafetySlide(
        title: 'Bocancii de siguranță: efectul de protecție',
        blocks: [
          ParagraphBlock(
            'Protecția picioarelor este EIP-ul de care ai cel mai des '
            'nevoie — și cel mai des subestimat.',
          ),
          SubheadBlock('Împotriva a ce te protejează'),
          BulletsBlock([
            'Mecanic — lovire, strivire, colete care cad, călcatul pe '
                'obiecte ascuțite',
            'Scrântire — bocancii care acoperă glezna susțin articulația '
                'și previn rupturile de ligamente și rănirile gleznei',
            'Electric — descărcare antistatică',
            'Chimic — acizi, uleiuri, carburanți',
            'Termic — căldură și frig',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'De ce peste gleznă',
            text: 'Cea mai frecventă rănire în livrări este scrântirea '
                'gleznei la coborâre, pe borduri și pe drumuri '
                'denivelate. Un bocanc care acoperă glezna susține '
                'articulația exact acolo unde cedează — un pantof scund '
                'nu poate face asta.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Chiar dacă sunt incomozi — și vara la fel',
            text: 'Obligația de a-i purta este valabilă în fiecare zi de '
                'lucru, indiferent de vreme și de confort. Tocmai vara se '
                'schimbă încălțămintea — și exact atunci apar rănirile. '
                'Dacă bocancii strâng sau freacă, este un motiv pentru un '
                'alt model, nu un motiv pentru adidași.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Verifică-ți regulat bocancii',
            text: 'Profil tocit, fisuri sau murdărie puternică: cere să '
                'fie înlocuiți. Nu face modificări pe cont propriu și nu '
                'lucra niciodată în adidași — nici măcar „doar puțin".',
          ),
        ],
      ),
      SafetySlide(
        title: 'Clasele de protecție pe scurt',
        blocks: [
          TableBlock(
            headers: ['Clasa', 'Proprietăți'],
            rows: [
              [
                'S1',
                'Zona călcâiului închisă, antistatic, talpă rezistentă '
                    'la carburanți',
              ],
              ['S2', 'ca S1 + impermeabil cel puțin 60 de minute'],
              ['S3', 'ca S2 + talpă antiperforare și profilată'],
              ['S4', 'ca S2, complet din cauciuc (vulcanizat)'],
              ['S5', 'ca S4 + talpă antiperforare'],
            ],
          ),
          SubheadBlock('Când sunt deosebit de importanți'),
          BulletsBlock([
            'Pe scări mobile, trepte de urcare și scări fixe',
            'La cărucioare rulante și transpalete',
            'Pe drumuri denivelate și pe rampe',
          ]),
          ParagraphBlock(
            'Semnele unui bocanc bun: stă fix pe picior, este închis, '
            'ține călcâiul cu amortizare, talpă flexibilă, toc jos, '
            'profil antiderapant.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ch05',
    title: 'Comportamentul în caz de incendiu',
    summary: 'Folosește corect stingătorul și stăpânește incendiile de '
        'vehicul',
    asset: '${_a}ch05_brandfall.svg',
    slides: [
      SafetySlide(
        title: 'Utilizarea stingătorului',
        asset: '${_a}ch05_brandfall.svg',
        blocks: [
          ParagraphBlock(
            'Există stingătoare cu pulbere, cu apă/spumă și cu CO₂. '
            'Modul de utilizare este același la toate:',
          ),
          StepsBlock([
            'Scoate siguranța',
            'Apasă butonul de percuție',
            'Acționează pistolul de stingere',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Ai doar câteva secunde',
            text: 'Un stingător se golește mai repede decât cred cei mai '
                'mulți. De aceea: mai bine folosiți mai multe stingătoare '
                'în același timp decât unul după altul.',
          ),
          FactsBlock([
            FactItem('6–12 s', 'Pulbere 1–2 kg'),
            FactItem('15–23 s', 'Pulbere 6 kg'),
            FactItem('18–33 s', 'Pulbere 12 kg'),
            FactItem('20–30 s', 'Spumă 6 l'),
            FactItem('5–10 s', 'CO₂ 2 kg'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Stingerea corectă — pas cu pas',
        blocks: [
          ParagraphBlock(
            'Ordinea decide dacă focul se stinge sau se reaprinde. Șase '
            'pași pe care ar trebui să ți-i ții minte:',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}fire01_pin.svg',
              title: 'Pregătește stingătorul',
              caption: 'Trage siguranța, apasă butonul de percuție, ține '
                  'stingătorul vertical. Abia apoi mergi spre foc.',
            ),
            IllustratedStep(
              asset: '${_a}fire02_wind.svg',
              title: 'Atacă în direcția vântului',
              caption: 'Vântul trebuie să îți fie în spate și să ducă '
                  'agentul de stingere în foc — nu stinge niciodată '
                  'împotriva vântului. Așa rămân căldura și fumul departe '
                  'de tine.',
            ),
            IllustratedStep(
              asset: '${_a}fire03_surface.svg',
              title: 'Incendiu de suprafață: începe din față',
              caption: 'Țintește marginea din față a flăcărilor, în jar — '
                  'nu în vârful flăcărilor. Apoi lucrează bucată cu '
                  'bucată spre spate.',
            ),
            IllustratedStep(
              asset: '${_a}fire04_drip.svg',
              title: 'Incendiu prin scurgere: de sus în jos',
              caption: 'Dacă se scurge lichid care arde, începe sus, la '
                  'locul de ieșire, și lucrează în jos — altfel focul se '
                  'alimentează mereu de sus.',
            ),
            IllustratedStep(
              asset: '${_a}fire05_together.svg',
              title: 'Mai multe stingătoare în același timp',
              caption: 'Dacă sunt mai multe stingătoare și mai mulți '
                  'oameni care ajută: folosiți-le împreună și în același '
                  'timp. Unul după altul dă focului timp să își revină '
                  'între stingătoare.',
            ),
            IllustratedStep(
              asset: '${_a}fire06_watch.svg',
              title: 'Supraveghează locul incendiului',
              caption: 'După stingere rămâi la fața locului și '
                  'supraveghează. Focarele de jar se reaprind adesea după '
                  'câteva minute — stai la distanță și cu stingătorul '
                  'pregătit.',
            ),
            IllustratedStep(
              asset: '${_a}fire07_refill.svg',
              title: 'Dă la reumplut stingătorul folosit',
              caption: 'Un stingător folosit nu se pune niciodată înapoi '
                  'pe perete — nici după o apăsare scurtă. Dă-l imediat '
                  'la reumplere și anunță că trebuie înlocuit.',
            ),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Când nu stingi',
            text: 'Nu te pune niciodată în pericol. Dacă incendiul este '
                'mai mare decât un coș de hârtii, dacă se face mult fum '
                'sau dacă îți riști calea de ieșire: afară, închide ușa, '
                'sună la 112 și avertizează-i pe ceilalți.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Incendiu de vehicul',
        blocks: [
          SubheadBlock('Cele mai frecvente cauze'),
          BulletsBlock([
            'Scurgeri de carburant sau de ulei',
            'Material izolant pe piese fierbinți',
            'Daune mecanice',
            'Defecțiuni electrice',
            'Recipiente de deșeuri care ard',
          ]),
          SubheadBlock('Ce faci tu'),
          StepsBlock([
            'Nu opri în tuneluri sau pe poduri — dacă se poate, ieși de '
                'acolo',
            'Pornește avariile, caută un loc potrivit, oprește',
            'Părăsește vehiculul, păstrează distanța',
            'Alarmează pompierii la 112 — spune locul și sensul de mers',
            'Abia apoi încearcă să stingi singur, dacă este sigur',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Capota motorului: atenție',
            text: 'Doar cu mănuși și doar puțin întredeschisă. Din cauza '
                'aportului brusc de oxigen pot apărea limbi de foc.',
          ),
          SubheadBlock('Ce trebuie să știe dispeceratul'),
          BulletsBlock([
            'Unde arde?',
            'Ce arde și pe ce suprafață?',
            'Câți răniți, ce fel de răni?',
            'Ce marfă este încărcată?',
            'Cine anunță?',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Nu închide telefonul',
            text: 'Nu încheia niciodată tu convorbirea. Așteaptă '
                'întrebările — dispeceratul încheie discuția.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'ch06',
    title: 'Primul ajutor',
    summary: 'Obligația ta, protecția ta și documentarea',
    asset: '${_a}ch06_erste_hilfe.svg',
    slides: [
      SafetySlide(
        title: 'Ajutorul este obligatoriu — și ești acoperit',
        asset: '${_a}ch06_erste_hilfe.svg',
        blocks: [
          ParagraphBlock(
            'Fiecare are obligația să acorde primul ajutor — în limita a '
            'ceea ce i se poate cere și fără a se pune singur în pericol '
            'serios. Chiar și fără pregătire medicală.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 323c StGB — neacordarea ajutorului',
            text: 'Cine nu ajută, deși ar putea, comite o infracțiune: '
                'până la un an de închisoare sau amendă penală. Asta este '
                'valabil și pentru „gură-cască" care îi împiedică pe cei '
                'care ajută.',
          ),
          SubheadBlock('Cine ajută nu greșește'),
          BulletsBlock([
            'Ca prim salvator nu răspunzi pentru greșeli — cu excepția '
                'intenției sau a neglijenței grave',
            'Pe durata acordării ajutorului ești asigurat prin lege '
                'împotriva accidentelor',
            'Costurile nu le suporți tu; pagubele materiale sunt de '
                'regulă despăgubite',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Singura greșeală adevărată',
            text: 'Să nu faci nimic. Orice altceva este mai bun decât să '
                'te uiți în altă parte.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Salvatorii din stație — și tu',
        blocks: [
          ParagraphBlock(
            'În stație există salvatori instruiți pentru primul ajutor. '
            'De asta se ocupă angajatorul: organizarea primului ajutor '
            'este sarcina lui (§ 24 DGUV Vorschrift 1) și trebuie să '
            'asigure un număr minim de salvatori instruiți '
            '(§ 26 DGUV Vorschrift 1).',
          ),
          FactsBlock([
            FactItem('1', 'salvator la 2–20 persoane prezente'),
            FactItem('10 %', 'dintre cei prezenți în celelalte firme'),
            FactItem('2 ani', 'perfecționarea salvatorilor'),
          ]),
          ParagraphBlock(
            'Dacă mai mulți angajatori lucrează pe același teren, ei '
            'trebuie să se coordoneze și să se informeze reciproc '
            '(§ 8 Arbeitsschutzgesetz). Se poate conveni ca organizarea '
            'primului ajutor din stație să fie folosită în comun. Asta '
            'reglementează colaborarea firmelor — nu obligația ta '
            'personală.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Asta nu te scutește',
            text: 'Obligația de a acorda ajutor conform § 323c StGB îl '
                'privește pe fiecare personal. Salvatorii instruiți din '
                'stație nu schimbă nimic în această privință.',
          ),
          SubheadBlock('Cum se procedează din punct de vedere juridic'),
          BulletsBlock([
            'Dacă este deja cineva acolo și ajută cu adevărat suficient, '
                'nu trebuie să intervii și tu',
            'Obligația de a chema salvarea și de a aduce ajutor rămâne '
                'în orice caz',
            'Trebuie să te asiguri că se ajută cu adevărat — să te uiți '
                'în altă parte cu gândul „se ocupă deja cineva" nu este '
                'suficient',
            'Sprijină la indicația salvatorului: asigură locul, îndrumă '
                'echipajul de urgență, adu materiale, ține-i pe ceilalți '
                'la distanță',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Pe rută ești singur',
            text: 'Cea mai mare parte a timpului de lucru nu ești în '
                'stație, ci pe drum. Acolo nu există niciun salvator al '
                'stației — la o urgență pe rută, tu ești salvatorul.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Apelul de urgență',
        blocks: [
          FactsBlock([
            FactItem('112', 'Apel de urgență, în toată Europa'),
          ]),
          SubheadBlock('Cele cinci întrebări'),
          StepsBlock([
            'Unde s-a întâmplat?',
            'Câte persoane sunt rănite?',
            'Ce s-a întâmplat?',
            'Cine sună?',
            'Așteaptă întrebările',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Reguli de bază când ajuți',
            text: 'Păstrează calmul · acționează repede · ai grijă de '
                'propria siguranță · asigură locul accidentului · ajută '
                'după cum te pricepi cel mai bine.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Documentare și raportare',
        blocks: [
          ParagraphBlock(
            'Orice rănire se documentează — și tăietura mică. Asta te '
            'protejează dacă apar urmări mai târziu.',
          ),
          SubheadBlock('În registrul de prim ajutor se trec'),
          BulletsBlock([
            'Ora și locul',
            'Cum s-a întâmplat',
            'Tipul și gravitatea rănirii',
            'Numele persoanei rănite',
            'Martorii și salvatorii',
          ]),
          FactsBlock([
            FactItem('> 3 zile', 'concediu medical → e nevoie de '
                'declarație de accident'),
            FactItem('3 zile', 'termenul pentru declarație'),
            FactItem('5 ani', 'păstrare, confidențial'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Raportează imediat',
            text: 'Accidentele mortale, accidentele colective și '
                'afectările grave ale sănătății sunt raportate imediat de '
                'angajator — de aceea informează-ți întotdeauna imediat '
                'angajatorul.',
          ),
          ParagraphBlock(
            'Trusele de prim ajutor trebuie să fie complete. Verifică '
            'data de expirare și raportează materialele care lipsesc.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 7
  SafetyChapterContent(
    id: 'ch07',
    title: 'Statul jos și mișcarea',
    summary: 'Menajează-ți spatele, păstrează-ți concentrarea',
    asset: '${_a}ch07_sitzen_bewegen.svg',
    slides: [
      SafetySlide(
        title: 'De ce statul pe scaun devine un risc',
        asset: '${_a}ch07_sitzen_bewegen.svg',
        blocks: [
          ParagraphBlock(
            'Statul îndelungat pe un scaun prost reglat este mai mult '
            'decât incomod — te costă atenție și timp de reacție.',
          ),
          BulletsBlock([
            'Oboseală și scăderea concentrării',
            'Contracturi și dureri de spate',
            'Probleme la coloana cervicală și lombară',
            'Accidente din cauza reacției întârziate',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Reglează corect scaunul',
        blocks: [
          ParagraphBlock(
            'Ia-ți două minute înainte de prima cursă. Șapte reglaje sunt '
            'decisive:',
          ),
          StepsBlock([
            'Înălțimea scaunului și reglajul pe lungime',
            'Adâncimea șezutului',
            'Înclinarea șezutului',
            'Înclinarea spătarului',
            'Sprijinul lombar',
            'Tetiera',
            'Volanul și traseul centurii',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Statul dinamic',
            text: 'Spatele complet lipit de spătar, stai drept — și '
                'schimbă-ți ușor poziția din când în când. Cea mai bună '
                'poziție de ședere este următoarea.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Exerciții pentru între curse',
        blocks: [
          SubheadBlock('Așezat'),
          BulletsBlock([
            'Trage puternic de volan spre exterior — ține 3–6 secunde, '
                '3 repetări',
            'Apasă genunchii împotriva presiunii mâinilor — 3–6 secunde, '
                '5 repetări',
            'Sprijină-te pe scaun și ridică-ți greutatea — 3 repetări',
          ]),
          SubheadBlock('În picioare'),
          BulletsBlock([
            'Întinde brațele în sus — cca. 8 secunde, 3–5 repetări',
            'Mâinile la ceafă, coatele spre spate — cca. 8 secunde, '
                '3–5 repetări',
            'Călcâiul pe o ridicătură de cca. 30 cm, întinde piciorul — '
                'cca. 8 secunde, de 2–3 ori la fiecare picior',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Un spate antrenat rezistă mai mult',
            text: 'Folosește timpul de pauză — nu timp în plus.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 8
  SafetyChapterContent(
    id: 'ch08',
    title: 'Solicitare și concentrare',
    summary: 'Eficient și atent pe tot parcursul zilei',
    asset: '${_a}ch08_psychische_belastung.svg',
    slides: [
      SafetySlide(
        title: 'De ce ține asta de protecția muncii',
        asset: '${_a}ch08_psychische_belastung.svg',
        blocks: [
          ParagraphBlock(
            'Cine este sub presiune reacționează mai încet, scapă mai '
            'multe din vedere și face greșeli. Tocmai de aceea '
            'solicitarea este o temă de siguranță — nu abia atunci când '
            'cineva se îmbolnăvește.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Prevăzut prin lege',
            text: 'Din 2013, evaluarea riscurilor trebuie să ia în calcul '
                'în mod expres și solicitările psihice de la locul de '
                'muncă (§ 5 Abs. 3 Nr. 6 Arbeitsschutzgesetz). Se '
                'evaluează condițiile de muncă — nu persoanele.',
          ),
          SubheadBlock('Ce creează presiune în ziua de lucru la volan'),
          BulletsBlock([
            'Intervale de timp strânse, ambuteiaje, șantiere, căutarea '
                'unui loc de parcare',
            'Responsabilități neclare la încărcare și descărcare',
            'Informații lipsă sau întârziate despre tură',
            'Probleme tehnice la vehicul sau la aparat',
            'Situații dificile cu clienții',
          ]),
          ParagraphBlock(
            'Acestea sunt condiții pe care firma le poate schimba. De '
            'aceea, cea mai importantă regulă este: raportează cât timp '
            'se mai poate rezolva.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Cum rămâi concentrat — practic',
        blocks: [
          SubheadBlock('În timpul turei'),
          BulletsBlock([
            'Folosește pauzele ca instrument: coboară puțin, privește în '
                'depărtare, fă câțiva pași — asta îți reface atenția în '
                'mod măsurabil',
            'Bea suficientă apă și mănâncă regulat',
            'Nu manevra sub presiunea timpului — cele două minute sunt '
                'mai ieftine decât o tablă îndoită',
            'Folosește telefonul doar când stai pe loc, introdu adresa '
                'înainte de plecare',
            'După discuții dificile cu clienții, respiră adânc puțin '
                'înainte să pleci mai departe',
          ]),
          SubheadBlock('Spune din timp în loc să înduri'),
          ParagraphBlock(
            'Dacă ceva nu merge pe termen lung, spune-i dispecerului tău '
            '— din timp și concret. O tură care în mod regulat nu poate '
            'fi terminată, un vehicul care face probleme, o rută cu lipsă '
            'permanentă de locuri de parcare: toate se pot planifica, '
            'dacă cineva știe de ele.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Raportarea concretă ajută mai mult decât răbdarea',
            text: 'Spune ce anume nu merge și unde — nu doar că a fost '
                'stresant. Cu cât feedbackul este mai concret, cu atât se '
                'schimbă mai repede ceva în planificare.',
          ),
        ],
      ),
      SafetySlide(
        title: 'După evenimente deosebite',
        blocks: [
          ParagraphBlock(
            'Unele situații lasă urme: un accident grav, un jaf, o '
            'intervenție de prim ajutor cu persoane grav rănite. Este o '
            'reacție normală la un eveniment anormal — și nu un semn de '
            'slăbiciune.',
          ),
          BulletsBlock([
            'Raportează evenimentul șefului tău, chiar dacă ție nu ți '
                's-a întâmplat nimic',
            'După accidentele de muncă există oferte de sprijin prin '
                'asociația profesională',
            'Multe firme au salvatori psihologici sau consilieri pentru '
                'traume — întreabă la birou',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'În caz de urgență acută',
            text: 'La o criză psihică acută în Germania: Telefonseelsorge '
                '0800 111 0 111 — gratuit, anonim, disponibil non-stop.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 9
  SafetyChapterContent(
    id: 'ch09',
    title: 'Condusul în siguranță și controlul înainte de plecare',
    summary: 'Două minute de control înainte de fiecare tură',
    asset: '${_a}ch09_sicheres_fahren.svg',
    slides: [
      SafetySlide(
        title: 'Turul în jurul vehiculului',
        asset: '${_a}ch09_sicheres_fahren.svg',
        blocks: [
          ParagraphBlock(
            'Înainte de fiecare plecare, controlul este obligatoriu. '
            'Durează două minute și găsește exact acele defecte care '
            'devin scumpe sau periculoase pe drum.',
          ),
          BulletsBlock([
            'Iluminatul față și spate',
            'Vizibilitatea — oglinzi și geamuri curate și nedeteriorate',
            'Roțile — presiunea în anvelope, profilul, prinderea',
            'Frânele — proba de frânare, presiunea de frânare',
            'Motorul și transmisia — ulei, lichid de răcire și de frână, '
                'lichid de parbriz, fără scurgeri',
            'Prelatele și ușile închise',
            'Numărul de înmatriculare și plăcuțele de avertizare curate',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Încărcătura și postul de conducere',
        blocks: [
          SubheadBlock('Asigurarea încărcăturii'),
          BulletsBlock([
            'Este vehiculul potrivit pentru această încărcătură?',
            'Chingile de fixare sunt nedeteriorate?',
            'Încărcătura este asigurată și protejată împotriva alunecării?',
            'Sunt respectate sarcinile pe axe și masa totală admisă?',
          ]),
          SubheadBlock('Postul tău de lucru'),
          BulletsBlock([
            'Scaunul și volanul reglate corect',
            'Instrumentele de bord fără mesaje de eroare',
            'Proba de frânare fără probleme',
            'Sistemele de asistență pornite și gata de funcționare',
            'Ventilația funcționează',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Iarna, în plus',
            text: 'Anvelope potrivite, dacă este cazul lanțuri de zăpadă '
                'sau ajutoare de pornire, antigel suficient în lichidul '
                'de răcire și în lichidul de parbriz, racletă de gheață '
                'la bord.',
          ),
          InstructionRefBlock(['baw_transporter', 'baw_winter']),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 10
  SafetyChapterContent(
    id: 'ch10',
    title: 'Pene și accidente',
    summary: 'Asigură locul, ajută, documentează corect',
    asset: '${_a}ch10_pannen_unfaelle.svg',
    slides: [
      SafetySlide(
        title: 'Regula de bază și pana',
        asset: '${_a}ch10_pannen_unfaelle.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Regula de bază',
            text: 'Protecția proprie înaintea protecției altora. '
                'Protecția persoanelor înaintea protecției bunurilor.',
          ),
          SubheadBlock('Când se anunță o pană'),
          StepsBlock([
            'Caută din timp un loc potrivit de oprire — de ex. când '
                'crește temperatura lichidului de răcire',
            'Pornește avariile încă de când rulezi din inerție',
            'Dacă se poate, mergi până la următoarea parcare, altfel pe '
                'marginea din dreapta extremă a carosabilului',
            'Trage frâna de mână, pe întuneric aprinde luminile de '
                'poziție',
            'Îmbracă vesta reflectorizantă — înainte de a coborî',
            'Așază triunghiul reflectorizant',
          ]),
          FactsBlock([
            FactItem('100 m', 'triunghi, drum național'),
            FactItem('150–400 m', 'triunghi, autostradă'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Planul de urgență la un accident',
        blocks: [
          StepsBlock([
            'Oprește — întotdeauna, chiar dacă nu este nimeni acolo',
            'Asigură locul accidentului — avarii, frână de mână, pe '
                'întuneric luminile de poziție, vesta reflectorizantă '
                'înainte de a coborî, triunghiul',
            'Acordă primul ajutor — imediat',
            'Sună la 112 — dacă este urgent, chiar înainte de primul '
                'ajutor',
            'Faceți schimb de date — nume, adresă, număr de '
                'înmatriculare, asigurare',
            'Cheamă poliția — la vătămări corporale, pagube materiale '
                'mari sau suspiciune de alcool/droguri',
            'Asigură probele — fotografii ale locului accidentului și ale '
                'pagubelor, datele de contact ale martorilor',
            'Informează angajatorul și stabiliți cum procedați, verifică '
                'dacă mai ești apt să conduci, strânge triunghiul înapoi',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Zgârierea la parcare și cea mai frecventă rănire',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Un bilețel nu este de ajuns',
            text: 'Dacă atingi o mașină parcată și nu este nimeni acolo: '
                'așteaptă cel puțin 30 de minute. După aceea lasă numele '
                'și adresa ȘI raportează imediat accidentul la cea mai '
                'apropiată secție de poliție. Altfel este părăsirea '
                'locului accidentului.',
          ),
          SubheadBlock('Unde se rănesc de fapt șoferii'),
          FactsBlock([
            FactItem('51,6 %', 'căderi și căderi de la înălțime'),
            FactItem('7,2 %', 'accidente rutiere'),
          ]),
          ParagraphBlock(
            'Cele mai multe accidente care trebuie raportate nu se '
            'întâmplă în trafic, ci la urcarea și coborârea din cabină '
            'sau de pe platforma de încărcare.',
          ),
          DoDontBlock(
            doTitle: 'Corect',
            dos: [
              'Folosește treptele și mânerele prevăzute',
              'Contact în trei puncte la urcare și coborâre',
              'Ține treptele curate și libere',
              'Poartă încălțăminte potrivită',
            ],
            dontTitle: 'Periculos',
            donts: [
              'Să sari din cabină sau de pe platforma de încărcare',
              'Să calci pe trepte murdare, înghețate sau blocate',
              'Să te urci pe piese ale vehiculului care nu sunt '
                  'prevăzute pentru asta sau pe încărcătură',
              'Să folosești scări defecte',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 11
  SafetyChapterContent(
    id: 'ch11',
    title: 'Regula celor 3 puncte',
    summary: 'Urcarea și coborârea — cea mai importantă regulă',
    asset: '${_a}step3p_cover.svg',
    slides: [
      SafetySlide(
        title: 'Mereu 3 din 4 puncte de contact',
        asset: '${_a}step3p_cover.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Regula de bază',
            text: '2 mâini + 1 picior  SAU  2 picioare + 1 mână. Trei '
                'puncte au întotdeauna contact ferm cu vehiculul.',
          ),
          ParagraphBlock(
            'Urci și cobori de zeci de ori pe zi — în grabă, pe ploaie, '
            'cu mâinile pline. Exact atunci se întâmplă cele mai multe '
            'accidente. Trei puncte ferme îți dau sprijin și previn '
            'căderile și rănirile la gleznă, genunchi și spate.',
          ),
          FactsBlock([
            FactItem('51,6 %', 'dintre toate accidentele sunt căderi'),
            FactItem('7,2 %', 'sunt accidente rutiere'),
          ]),
          ParagraphBlock(
            'Niciun alt gest din munca de zi cu zi nu previne atâtea '
            'răniri ca acesta. De aceea se află la finalul acestei '
            'instruiri — ca lucrul care trebuie să îți rămână în minte.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Cele patru reguli în detaliu',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}step3p_01_face.svg',
              title: 'Cu fața spre vehicul',
              caption: 'Coboară întotdeauna cu fața spre vehicul — '
                  'niciodată cu spatele și nu sări în lateral. Săritul '
                  'este cea mai frecventă cauză de accident. Folosește '
                  'mereu treapta și mânerele.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_02_hands.svg',
              title: 'Întâi lasă jos, apoi apucă',
              caption: 'Fără colete în mână la urcare și coborâre. Lasă '
                  'întâi jos coletul sau pune piesele mici în geantă ori '
                  'la centură — mâinile rămân libere ca să te ții.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_03_onepoint.svg',
              title: 'Mișcă un singur punct',
              caption: 'Mișcă întotdeauna doar o mână sau un picior, în '
                  'timp ce celelalte trei au sprijin ferm. Nu te grăbi — '
                  'nici măcar când tura te presează.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_04_steps.svg',
              title: 'Atenție la trepte și la aderență',
              caption: 'Fii atent la umezeală, zăpadă, ulei și murdărie. '
                  'Calcă liniștit și controlat, iar la nevoie curăță '
                  'treptele înainte.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Două lucruri care fac parte din asta',
        blocks: [
          SubheadBlock('Bocanci de siguranță semiînalți'),
          ParagraphBlock(
            'Bocancii semiînalți cuprind glezna și stabilizează mult mai '
            'bine articulația — exact acolo se produce scrântirea la '
            'coborâre.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ai scrântit vreodată glezna?',
            text: 'Cine a avut deja probleme cu glezna ar trebui să ceară '
                'bocanci semiînalți — înainte de următoarea tură, nu '
                'după.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}step3p_05_phone.svg',
              title: 'Fără telefon personal în mână',
              caption: 'Vorbitul, scrisul și derulatul îți fură '
                  'concentrarea — exact așa apar căderile și accidentele. '
                  'Apelurile și mesajele private așteaptă până în pauză. '
                  'La urcare și coborâre, telefonul stă în buzunar.',
            ),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Pe scurt',
            text: 'Cu fața spre vehicul · ține trei puncte · mâinile '
                'libere · bocanci de siguranță semiînalți · fără telefon '
                'personal · folosește treptele în loc să sari.',
          ),
        ],
      ),
    ],
  ),
];
