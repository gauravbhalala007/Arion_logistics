// lib/data/safety_training/driving_safety_content_ro.dart
//
// Continutul trainingului DSP de siguranta rutiera — versiunea romana.
// Structura este identica cu versiunea germana (master): modulele M1–M10,
// aceleasi folii si aceleasi blocuri. Caile imaginilor sunt neschimbate.

import 'safety_blocks.dart';

const List<SafetyChapterContent> drivingSafetyContentRo = [
  // ══════════════════════════════════════════════════ M1
  SafetyChapterContent(
    id: 'm1',
    title: 'Cultura siguranței și responsabilitatea',
    summary: 'Înțelege siguranța ca pe decizia ta — nu ca pe o '
        'prescripție',
    asset: 'assets/academy/driving/m01_sicherheitskultur.svg',
    slides: [
      SafetySlide(
        title: 'Tura ta, responsabilitatea ta',
        blocks: [
          ParagraphBlock(
            'În fiecare zi parcurgi sute de kilometri și oprești de zeci '
            'de ori. Fiecare drum, fiecare oprire, fiecare coborâre este '
            'o decizie. Vestea bună: aproape orice accident poate fi '
            'evitat. Siguranța nu începe la volan, ci în cap — înainte '
            'să pornești.',
          ),
          FactsBlock([
            FactItem('120+', 'opriri într-o zi normală de livrare'),
            FactItem('250+', 'urcări și coborâri pe tură'),
            FactItem('1', 'secundă de neatenție ajunge pentru un '
                'accident'),
          ]),
          ParagraphBlock(
            'La atâtea repetări, nu priceperea ta decide ziua, ci rutina '
            'ta. O rutină bună te protejează și atunci când ești obosit '
            'sau sub presiune — una proastă te va costa scump la un '
            'moment dat.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ideea de bază',
            text: 'Siguranța nu este ceva ce faci în plus. Este felul în '
                'care îți faci treaba.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ce se întâmplă cu adevărat în livrare',
        blocks: [
          ParagraphBlock(
            'Livrarea face parte dintre meseriile cu cele mai multe '
            'accidente de traseu și de muncă. Cele mai frecvente '
            'incidente nu sunt spectaculoase: tamponări în ambuteiaj, '
            'avarii la mersul înapoi, căderi la coborâre, spate întins '
            'greșit, glezne scrântite. Banale — și tocmai de aceea '
            'subestimate.',
          ),
          FactsBlock([
            FactItem('70 %', 'dintre avariile la autoutilitare apar la '
                'manevre și la mersul înapoi'),
            FactItem('Nr. 1', 'împiedicarea, alunecarea și căderea sunt '
                'cea mai frecventă cauză de rănire în livrare'),
            FactItem('24', 'zile de incapacitate în medie după o '
                'cădere'),
          ]),
          ParagraphBlock(
            'Este frapant: aproape toate aceste incidente se produc la '
            'viteză mică sau din staționare. Nu sunt manevre dramatice, '
            'ci gesturi obișnuite, executate o dată prost.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Încet nu înseamnă inofensiv',
            text: 'O avarie la manevre, în ritm de pas, costă firma '
                'repede o sumă de patru cifre — iar pe tine o jumătate '
                'de zi de bătaie de cap.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Cele trei atitudini de bază',
        blocks: [
          ParagraphBlock(
            'Din tot ce urmează în acest training se pot desprinde trei '
            'atitudini. Dacă iei cu tine doar aceste trei lucruri, ai '
            'rezolvat cea mai mare parte.',
          ),
          BulletsBlock([
            'Gândește înainte — recunoaște pericolele înainte să apară. '
                'Cine doar reacționează ajunge mereu prea târziu',
            'Timpul îți aparține — niciun colet nu valorează cât un '
                'accident. Presiunea timpului este o problemă de '
                'planificare, nu o scuză',
            'Fii un exemplu — comportamentul tău îi protejează pe '
                'colegi, pe pietoni și pe copii. În trafic ești un '
                'profesionist, nu un șofer particular',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Regulă de reținut',
            text: 'Cel mai bun șofer nu este cel mai rapid, ci acela '
                'căruia nu i se întâmplă niciodată nimic — pentru că '
                'vede pericolul venind.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Fiecare drum este un lanț de decizii',
        asset: 'assets/academy/driving/m01b_entscheidung.svg',
        blocks: [
          ParagraphBlock(
            'Un accident este rareori o singură greșeală. De cele mai '
            'multe ori sunt cinci-șase decizii mici, care fiecare în '
            'parte par inofensive — și care la final se adună. Tocmai de '
            'aceea poți rupe lanțul în orice punct.',
          ),
          RevealBlock(
            prompt: 'Studiu de caz: este ora 17:40, mai ai 22 de opriri. '
                'Compartimentul de marfă este în dezordine, telefonul '
                'îți vibrează în suport, iar în față drumul se '
                'îngustează. Unde este de fapt riscul aici?',
            answer: 'Nu în îngustarea din față — ci în ce s-a întâmplat '
                'înainte. Compartimentul dezordonat îți fură timp la '
                'fiecare oprire, timpul creează presiune, presiunea îți '
                'scade atenția, iar telefonul ia restul. Decizia corectă '
                'era necesară cu două ore mai devreme: sortează '
                'compartimentul, pune telefonul pe silențios, planifică '
                'realist. Acum mai ajută doar: oprește, respiră adânc, '
                'continuă oprire cu oprire și raportează problema de '
                'planificare după aceea.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Rupe lanțul',
            text: 'Întreabă-te la fiecare senzație proastă: care este '
                'veriga pe care o pot scoate cu 30 de secunde de efort?',
          ),
        ],
      ),
      SafetySlide(
        title: 'Exemplu în echipă',
        asset: 'assets/academy/driving/m01c_vorbild.svg',
        blocks: [
          ParagraphBlock(
            'Cultura siguranței nu apare din afișe, ci din ceea ce '
            'colegii preiau unii de la alții. Cine începe nou face la '
            'fel ca cei cu experiență — inclusiv ce este greșit.',
          ),
          DoDontBlock(
            doTitle: 'Cultura care ține',
            dos: [
              'Vorbește deschis despre incidentele la limită, fără ca '
                  'cineva să fie privit ciudat',
              'Atrage activ atenția colegilor noi asupra treptelor, a '
                  'mânerelor și a unghiului mort',
              'Raportează defecțiunile imediat, chiar dacă tura '
                  'pornește mai târziu',
              'Manevrează vizibil curat și sub presiunea timpului',
            ],
            dontTitle: 'Cultura care dăunează',
            donts: [
              '„Aici mereu facem așa" ca justificare',
              'Să râzi de colegul care coboară și verifică',
              'Să rezolvați între voi avariile mici în loc să le '
                  'raportați',
              'Să dai exemplu scurtături pe care nu le-ai învăța '
                  'niciodată pe cei noi',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Incidentele la limită valorează aur',
            text: 'Fiecare incident la limită raportat este un accident '
                'care nu i se mai întâmplă următorului coleg. A raporta '
                'înseamnă putere, nu pâră.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Cine răspunde de fapt?',
        blocks: [
          ParagraphBlock(
            'La volan ești conducător auto — și deci răspunzi personal. '
            'Firma îți pune la dispoziție un vehicul sigur, te '
            'instruiește și planifică tura. Dacă apoi păstrezi '
            'distanța, îți pui centura și cobori înainte de a da '
            'înapoi, decizi doar tu.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Ce așteaptă legea de la tine',
            text: '§ 1 StVO (codul rutier german) cere prudență '
                'permanentă și considerație reciprocă. § 3 Abs. 1 StVO '
                'cere să conduci doar atât de repede încât să poți opri '
                'în limita porțiunii vizibile. Ambele sunt valabile '
                'indiferent de ce scrie pe indicator.',
          ),
          BulletsBlock([
            'Amenzile și punctele te lovesc pe tine personal, nu firma',
            'În caz de neglijență gravă, asigurarea îți poate cere o '
                'parte în regres',
            'La punerea în pericol a altora, o abatere rutieră poate '
                'deveni infracțiune (§ 315c StGB)',
            'O suspendare a permisului înseamnă pentru tine, ca șofer '
                'profesionist: fără muncă',
          ]),
          RevealBlock(
            prompt: 'Dimineața observi că o lampă de frână s-a ars. '
                'Dispecerul spune: „Pleacă totuși, nu avem pe '
                'altcineva." Cine poartă riscul?',
            answer: 'Tu. În calitate de conducător auto răspunzi pentru '
                'starea de siguranță rutieră a vehiculului pe care îl '
                'conduci — o dispoziție verbală nu anulează asta. Corect '
                'este: raportează defectul, cere un vehicul de schimb '
                'sau o reparație, documentează raportarea. O lampă de '
                'frână defectă la autoutilitară este, în plus, exact '
                'defectul care duce la tamponare.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare: atitudinea ta',
        blocks: [
          ChecklistBlock(
            title: 'Asta iau cu mine din modulul 1',
            items: [
              'Știu că majoritatea avariilor se produc lent și banal',
              'Gândesc înainte, în loc să doar reacționez',
              'Tratez presiunea timpului ca pe o problemă de '
                  'planificare, nu de condus',
              'Raportez defecțiunile și incidentele la limită, inclusiv '
                  'pe cele mici',
              'Știu că, în calitate de conducător auto, răspund '
                  'personal',
              'Sunt conștient că noii colegi mă copiază',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'O frază pentru tură',
            text: '„Conduc astfel încât toți să ajungă acasă în '
                'siguranță — inclusiv eu."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M2
  SafetyChapterContent(
    id: 'm2',
    title: 'Verificarea vehiculului și asigurarea încărcăturii',
    summary: 'Verifică vehiculul înainte de tură și asigură încărcătura '
        'astfel încât nimic să nu devină un pericol',
    asset: 'assets/academy/driving/m02_fahrzeugcheck.svg',
    slides: [
      SafetySlide(
        title: 'De ce verificarea nu este o formalitate',
        blocks: [
          ParagraphBlock(
            'Turul de verificare dinaintea turei durează două minute. El '
            'previne panele în mijlocul traseului, amenzile la un '
            'control și, în cel mai rău caz, un accident pe care l-ai fi '
            'putut vedea înainte de a porni.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Obligația de verificare înainte de tură',
            text: 'Conform DGUV Vorschrift 70 (Fahrzeuge — prescripția '
                'germană de prevenire a accidentelor pentru vehicule), '
                'trebuie să verifici vehiculul înainte de începerea '
                'fiecărei ture de lucru pentru defecte evidente. Dacă '
                'constați defecte care pun în pericol siguranța în '
                'exploatare, nu ai voie să pleci — le raportezi.',
          ),
          FactsBlock([
            FactItem('2 min', 'durează turul complet'),
            FactItem('4', 'stații: anvelope, lumini, lichide, '
                'încărcătură'),
          ]),
          ParagraphBlock(
            'Important: verificarea nu înlocuiește o revizie în service. '
            'Cauți ceea ce sare în ochi — nu defecte ascunse.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Turul de verificare — patru stații',
        asset: 'assets/academy/driving/m02b_rundgang.svg',
        blocks: [
          ParagraphBlock(
            'Ocolește mașina mereu în aceeași ordine. O ordine fixă este '
            'singura cale să nu uiți nimic atunci când dimineața este '
            'agitată.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/load01_reifen.svg',
              title: '1 · Anvelope și roți',
              caption: 'Ocolește complet vehiculul și uită-te la toate '
                  'cele patru anvelope: vizibil dezumflate, fisuri, '
                  'corpuri străine, profil suficient? O anvelopă care '
                  'arată moale încă de dimineață nu rezistă o tură.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load02_licht.svg',
              title: '2 · Iluminare și număr de înmatriculare',
              caption: 'Verifică luminile de poziție, faza scurtă, '
                  'semnalizatoarele, lampa de frână și farul de mers '
                  'înapoi — lampa de frână, la nevoie, prin reflexia pe '
                  'un perete sau cu un coleg. Numărul trebuie să fie '
                  'liber și lizibil.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load03_fluessigkeiten.svg',
              title: '3 · Lichide și sol',
              caption: 'O privire sub mașină: urmele de ulei, de lichid '
                  'de răcire sau de frână pe sol sunt întotdeauna un '
                  'motiv de raportare. În plus, completează lichidul de '
                  'parbriz — iarna cu antigel.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load04_ladung.svg',
              title: '4 · Compartiment de marfă și încărcătură',
              caption: 'Deschide ușile și privește înăuntru: totul stă '
                  'ferm, plasa despărțitoare și chingile sunt întinse, '
                  'nu este nimic liber deasupra? Ce stă liber aici zboară '
                  'în față la prima frânare bruscă.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Anvelopele: singurul tău contact cu drumul',
        blocks: [
          ParagraphBlock(
            'Patru suprafețe de contact, fiecare cam cât o carte '
            'poștală — mai mult nu leagă autoutilitara ta încărcată de '
            'carosabil. Tot ce înveți despre frânare, direcție și '
            'aderență depinde de aceste patru suprafețe.',
          ),
          FactsBlock([
            FactItem('1,6 mm', 'adâncimea minimă legală a profilului'),
            FactItem('3 mm', 'profil minim recomandat vara'),
            FactItem('4 mm', 'profil minim recomandat iarna'),
            FactItem('60 € + 1 p.', 'la profil prea mic'),
          ]),
          BulletsBlock([
            'Verifică adâncimea profilului cu o monedă de 1 euro: '
                'marginea aurie are 3 mm — dacă dispare în profil, mai '
                'ai suficient',
            'Verifică presiunea la anvelope reci și adapteaz-o la '
                'încărcătură — încărcat ai nevoie de mai multă presiune '
                'decât gol',
            'Fii atent la uzura neuniformă: uzura pe o singură parte '
                'înseamnă o problemă de geometrie sau de presiune',
            'Raportează imediat umflăturile, fisurile și șuruburile '
                'intrate în cauciuc',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Presiunea prea mică este mai periculoasă decât cea '
                'prea mare',
            text: 'O anvelopă prea puțin umflată se deformează, se '
                'încinge și poate exploda la încărcătură maximă. În plus '
                'crește distanța de frânare și crește pericolul de '
                'acvaplanare.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lumini, geamuri, oglinzi',
        blocks: [
          ParagraphBlock(
            'Este la fel de important să fii văzut pe cât este să vezi. '
            'O lampă de frână arsă la autoutilitară este cauza clasică a '
            'unei tamponări în care tu nu ești vinovatul — dar ai totuși '
            'paguba.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Vizibilitatea liberă este obligatorie',
            text: 'Conform § 23 Abs. 1 StVO trebuie să te asiguri că '
                'vederea și auzul nu îți sunt îngrădite — de '
                'încărcătură, de pasageri, de geamuri înghețate sau '
                'murdare. O „gaură de privit" curățată nu este expres '
                'suficientă.',
          ),
          BulletsBlock([
            'Reglează oglinzile din staționare, înainte de a porni '
                'motorul — niciodată în timpul mersului',
            'Oglinzile exterioare astfel încât să rămână vizibilă o '
                'fâșie îngustă din propriul vehicul: acesta este '
                'reperul tău',
            'Ține geamurile și oglinzile curate pe interior și pe '
                'exterior — grăsimea pe interior orbește extrem noaptea',
            'Schimbă imediat lamelele de ștergător care lasă dâre',
          ]),
          RevealBlock(
            prompt: 'La turul de verificare observi: oglinda exterioară '
                'dreaptă se mișcă și are o fisură. Mai ai 190 de opriri '
                'în față. Pleci sau nu?',
            answer: 'Nu pleca înainte de a raporta. Oglinda exterioară '
                'dreaptă este exact cea cu care acoperi unghiul mort '
                'spre bicicliști și trotuar — și tocmai acolo se produc '
                'accidentele grave la viraj. O oglindă fisurată și '
                'instabilă este un defect care privește siguranța '
                'rutieră. Raportează, schimbă sau schimbă vehiculul.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Asigurarea încărcăturii: înțelege forțele',
        blocks: [
          ParagraphBlock(
            'Încărcătura trebuie asigurată astfel încât să nu alunece '
            'nici la o frânare bruscă, nici la o manevră de evitare '
            'neașteptată. Ce înseamnă asta concret scrie în regulile '
            'tehnice recunoscute — iar acestea lucrează cu valori clare.',
          ),
          FactsBlock([
            FactItem('0,8 g', 'forța spre față împotriva căreia trebuie '
                'asigurat'),
            FactItem('0,5 g', 'forța spre spate și lateral'),
            FactItem('16 kg', 'forța de reținere de care are nevoie '
                'singur un colet de 20 kg la frânare'),
          ]),
          ParagraphBlock(
            'Tradus: un colet de 20 kg împinge spre față cu aproximativ '
            '16 kg la o frânare bruscă — ca și cum ai fi împins o navetă '
            'plină cu apă spre peretele despărțitor. La douăzeci de '
            'astfel de colete sunt peste 300 kg care vor să se miște '
            'simultan spre față.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 22 StVO — încărcătura',
            text: 'Încărcătura trebuie stivuită și asigurată astfel '
                'încât, chiar la o frânare bruscă sau la o manevră de '
                'evitare, să nu poată aluneca, cădea, rostogoli sau cădea '
                'jos. Încărcătura neasigurată se sancționează cu amendă '
                'și, în caz de punere în pericol, cu punct — iar '
                'sancțiunea îl lovește pe șofer.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ce provoacă 20 kg în caz serios',
        blocks: [
          ParagraphBlock(
            'Cei 0,8 g sunt valabili pentru frânare și evitare. La un '
            'impact real acționează decelerări considerabil mai mari pe '
            'o durată foarte scurtă — forța de impact a unui colet '
            'neasigurat este atunci de multe ori mai mare decât '
            'greutatea lui.',
          ),
          RevealBlock(
            prompt: 'Studiu de caz: pe scaunul din dreapta stă un colet '
                'de 12 kg, pentru că este următoarea oprire. În '
                'localitate trebuie să frânezi brusc în fața unui copil. '
                'Ce se întâmplă cu coletul?',
            answer: 'Se mișcă mai departe cu viteza ta inițială până '
                'când ceva îl oprește — bordul, parbrizul sau capul tău '
                'la un impact lateral. Chiar și la o frânare de pericol '
                'obișnuită zboară de pe scaun în zona picioarelor și '
                'poate ajunge acolo sub pedala de frână. Tocmai de aceea '
                'niciun colet nu are ce căuta în față: următoarea oprire '
                'se pregătește în compartimentul de marfă, nu se '
                'depozitează între timp pe scaunul din dreapta.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Nimic în cabină',
            text: 'Niciun colet, nicio cutie cu rotile, nicio sculă '
                'liberă în habitaclu. Un obiect sub pedala de frână îți '
                'ia frâna exact în momentul în care ai nevoie de ea.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Așa încarci corect',
        asset: 'assets/academy/driving/m02c_ladung.svg',
        blocks: [
          ParagraphBlock(
            'Regula de bază: greu jos, greu în față, greutatea distribuită '
            'uniform pe axe. O autoutilitară încărcată sus are un centru '
            'de greutate ridicat — iar acesta decide dacă într-o curbă '
            'mai aluneci sau deja te răstorni.',
          ),
          DoDontBlock(
            doTitle: 'Asigurat',
            dos: [
              'Coletele grele jos și în față, la peretele despărțitor',
              'Greutatea distribuită uniform stânga/dreapta',
              'Încarcă compact — închide golurile, ca nimic să nu poată '
                  'lua avânt',
              'Chingile și plasa despărțitoare întinse, chiar și când '
                  'compartimentul se golește',
              'Verifică scurt după fiecare reîncărcare',
            ],
            dontTitle: 'Neasigurat',
            donts: [
              'Coletele grele stivuite liber deasupra',
              'Colete în zona picioarelor sau pe scaunul din dreapta',
              'Totul împins înăuntru „cumva", cu goluri deschise',
              'Plasa despărțitoare desfăcută, pentru că încurcă la '
                  'apucat',
              'Încărcătura „ținută" doar cu propria greutate corporală',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Compartimentul gol este cel mai periculos',
            text: 'Cu cât este mai puțin înăuntru, cu atât are coletul '
                'rămas mai mult drum ca să prindă viteză. Pe jumătate '
                'gol nu înseamnă pe jumătate periculos — înseamnă de '
                'asigurat din nou.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ordine în cabină și centura',
        blocks: [
          ParagraphBlock(
            'Băutură, telefon, scaner, avize de însoțire — toate au un '
            'loc fix. Ce se rostogolește, zăngăne sau zboară îți trage '
            'privirea de pe drum. Un post de conducere ordonat este un '
            'post de conducere sigur.',
          ),
          FactsBlock([
            FactItem('30 €', 'amendă de avertisment fără centură de '
                'siguranță'),
            FactItem('Fiecare', 'oprire: pune centura din nou, chiar și '
                'pentru 200 de metri'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 21a StVO — obligativitatea centurii',
            text: 'Centura de siguranță trebuie purtată în timpul '
                'mersului — fără excepție pentru distanțele scurte '
                'dintre două opriri. La un accident fără centură ți se '
                'poate reține în plus o culpă proprie.',
          ),
          ParagraphBlock(
            'Tocmai în livrare centura este elementul de siguranță cel '
            'mai des omis — pentru că între două opriri sunt doar câteva '
            'sute de metri. Exact acolo se produc însă cele mai multe '
            'coliziuni din localitate.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare înainte de plecare',
        blocks: [
          ChecklistBlock(
            title: 'Înainte să plec',
            items: [
              'Turul de verificare făcut în ordine fixă',
              'Anvelope: profil, presiune, deteriorări verificate',
              'Iluminarea verificată de jur împrejur, numărul lizibil',
              'Fără urme de lichide sub vehicul',
              'Geamuri și oglinzi curate, oglinzi reglate',
              'Coletele grele jos și în față, greutatea distribuită',
              'Chingile și plasa despărțitoare întinse',
              'Nimic liber în cabină, telefonul în suport',
              'Vesta reflectorizantă la îndemână, triunghiul la bord',
              'Centura pusă',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M3
  SafetyChapterContent(
    id: 'm3',
    title: 'Conducere defensivă și preventivă',
    summary: 'Gestionează distanța, viteza și atenția astfel încât să ai '
        'mereu o rezervă',
    asset: 'assets/academy/driving/m03_defensiv.svg',
    slides: [
      SafetySlide(
        title: 'Distanța de oprire = distanța de reacție + frânare',
        blocks: [
          ParagraphBlock(
            'Distanța de oprire este porțiunea din momentul recunoașterii '
            'până la oprirea completă. Ea are două părți: distanța de '
            'reacție, pe care o parcurgi încă la viteză maximă, și '
            'distanța de frânare propriu-zisă.',
          ),
          FactsBlock([
            FactItem('cca. 1 s', 'timpul de reacție al unui șofer treaz '
                'și odihnit'),
            FactItem('× 3', 'distanța de reacție = viteza ÷ 10, ori 3'),
            FactItem('²', 'distanța de frânare = (viteza ÷ 10) la '
                'pătrat'),
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Formulele practice',
            text: 'Distanța de reacție = (km/h ÷ 10) × 3. Distanța de '
                'frânare = (km/h ÷ 10) × (km/h ÷ 10). Adunate dau '
                'distanța de oprire. La o frânare de pericol, distanța de '
                'frânare se înjumătățește.',
          ),
          ParagraphBlock(
            'Punctul decisiv: distanța de frânare nu crește proporțional '
            'cu viteza, ci la pătrat. Viteză dublă înseamnă distanță de '
            'frânare de patru ori mai mare — de aceea 20 km/h în plus pe '
            'o stradă din cartier schimbă totul.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Calculează, nu estima',
        blocks: [
          TableBlock(
            headers: ['Viteză', 'Reacție', 'Frânare', 'Oprire'],
            rows: [
              ['30 km/h', '9 m', '9 m', '18 m'],
              ['50 km/h', '15 m', '25 m', '40 m'],
              ['70 km/h', '21 m', '49 m', '70 m'],
              ['100 km/h', '30 m', '100 m', '130 m'],
            ],
          ),
          ParagraphBlock(
            'Pentru comparație: un Sprinter are cam 6 metri lungime. La '
            'viteza de 50 ai nevoie deci de aproximativ șapte lungimi de '
            'vehicul până la oprire — iar primele două și jumătate trec '
            'înainte să atingi măcar pedala.',
          ),
          RevealBlock(
            prompt: 'Problemă de calcul: mergi cu 50 km/h pe o stradă din '
                'cartier. La 20 de metri, un copil aleargă pe carosabil '
                'între două mașini parcate. Reușești să oprești?',
            answer: 'Nu. Numai distanța ta de reacție este de 15 metri, '
                'apoi urmează 25 de metri de frânare — împreună 40 de '
                'metri. Nici cu frânare de pericol (15 m + 12,5 m = '
                '27,5 m) nu ajung 20 de metri. La viteza de 30, în '
                'schimb: 9 m reacție + 9 m frânare = 18 metri — te '
                'oprești cu doi metri înainte. Exact aceasta este '
                'diferența dintre o sperietură și un accident grav.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Regula celor două secunde',
        asset: 'assets/academy/driving/m03b_abstand.svg',
        blocks: [
          ParagraphBlock(
            'Distanța nu este politețe, ci timpul tău de reacție '
            'exprimat în metri. Și pentru că funcționează gândită în '
            'secunde, se adaptează automat la viteza ta.',
          ),
          StepsBlock([
            'Caută-ți un punct fix pe marginea drumului — un indicator, '
                'un stâlp, un marcaj rutier',
            'Când cel din față trece de acest punct, începe să numeri: '
                '„douăzeci și unu, douăzeci și doi"',
            'Dacă ajungi la punct înainte de „douăzeci și doi", mergi '
                'prea aproape',
            'Pe carosabil ud, în ceață sau pe întuneric crește la trei '
                'secunde',
          ]),
          FactsBlock([
            FactItem('2 s', 'distanța minimă pe carosabil uscat'),
            FactItem('3 s+', 'pe carosabil ud, în ceață, pe întuneric'),
            FactItem('28 m', 'corespund la 2 secunde la viteza de 50'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 4 Abs. 1 StVO — distanța',
            text: 'Distanța față de cel din față trebuie să fie de '
                'regulă atât de mare încât să poți opri în spatele lui '
                'și dacă frânează brusc. Ca formulă practică, în afara '
                'localității se ia jumătate din valoarea vitezometrului '
                'în metri.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Când lipsește distanța',
        blocks: [
          RevealBlock(
            prompt: 'Studiu de caz: pe drumul național păstrezi corect '
                '40 de metri distanță la viteza de 80. Un autoturism '
                'intră în spațiul liber și apoi frânează. Ce este corect '
                'acum?',
            answer: 'Nu te enerva, nu claxona, nu îl presa — ci ia '
                'piciorul de pe accelerație și reconstruiește distanța. '
                'Asta te costă câteva secunde și este singura reacție '
                'care îți scade riscul. Cine în schimb se apropie ca să '
                '„apere" spațiul nu mai are la 80 km/h 40 de metri, ci '
                'poate 15 — mai puțin decât simpla distanță de reacție '
                'de 24 de metri.',
          ),
          DoDontBlock(
            doTitle: 'Stăpân pe situație',
            dos: [
              'Reconstruiește calm distanța după ce cineva ți-a intrat '
                  'în față',
              'Dacă ești presat din spate: trage la dreapta, lasă-l să '
                  'treacă',
              'Ia piciorul de pe accelerație din timp înaintea '
                  'semafoarelor și a șantierelor',
              'În ambuteiaj lasă spațiu față de cel din față, ca să poți '
                  'ieși din coloană',
            ],
            dontTitle: 'Riscant',
            donts: [
              'Să te apropii ca să împiedici intrarea în față',
              'Semnalul cu farurile și claxonul ca mijloc de educare',
              'În trafic de tip stop-and-go să rulezi direct până la '
                  'bara din față',
              'Să estimezi distanța doar din senzație, în loc de '
                  'secunde',
            ],
          ),
          FactsBlock([
            FactItem('până la 400 €', 'amendă pentru nerespectarea '
                'distanței, plus puncte și suspendare'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Privirea departe în față',
        asset: 'assets/academy/driving/m03c_blickfuehrung.svg',
        blocks: [
          ParagraphBlock(
            'Nu te uita la bara din fața ta, ci cu 12–15 secunde '
            'înainte — în localitate deci aproximativ două cvartale. '
            'Așa vezi din timp luminile de frână, semafoarele, pietonii '
            'și îngustările și nu trebuie să reacționezi grăbit.',
          ),
          BulletsBlock([
            'Copil la bordură, care încă nu s-a uitat',
            'Biciclist care urmează să ocolească o mașină parcată',
            'Portieră în spatele căreia stă cineva — stopuri aprinse, '
                'cap în oglinda interioară',
            'Lumini de frână cu trei vehicule mai în față',
            'Pubele pe marginea drumului: semn de trafic cu manevre',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Privirea conduce vehiculul',
            text: 'Încotro privești, într-acolo mergi. De aceea, la '
                'evitare privește mereu spre spațiul liber — niciodată '
                'spre obstacol.',
          ),
          ParagraphBlock(
            'La fiecare câteva secunde, o privire scurtă în oglinzi face '
            'parte din rutină. Așa știi oricând ce se întâmplă în spatele '
            'tău și nu trebuie să verifici abia în caz de urgență.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Viteza este fizică',
        blocks: [
          ParagraphBlock(
            'Viteza permisă este un maxim, nu un obiectiv. În zone '
            'rezidențiale, la școli, lângă mașini parcate și pe străzi '
            'înguste, mai încet decât este permis este adesea singura '
            'alegere corectă.',
          ),
          FactsBlock([
            FactItem('×4', 'distanța de frânare la viteză dublă'),
            FactItem('18 m', 'distanța de oprire la 30 km/h'),
            FactItem('40 m', 'distanța de oprire la 50 km/h'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 3 Abs. 1 StVO — conducerea în limita vizibilității',
            text: 'Ai voie să conduci doar atât de repede încât să poți '
                'opri în limita porțiunii vizibile. În ceață, pe '
                'întuneric sau într-o curbă fără vizibilitate, asta '
                'înseamnă considerabil mai puțin decât permite '
                'indicatorul.',
          ),
          ParagraphBlock(
            'Calculează o dată ce aduce cu adevărat graba: pe zece '
            'kilometri de traseu urban, între viteza de 50 și cea de 60 '
            'economisești în cel mai bun caz două minute — pe care ți le '
            'ia înapoi următorul semafor roșu.',
          ),
        ],
      ),
      SafetySlide(
        title: 'De ce autoutilitara încărcată se comportă altfel',
        blocks: [
          ParagraphBlock(
            'O autoutilitară complet încărcată este alt vehicul decât '
            'aceeași mașină goală dimineața. Mai multă masă înseamnă mai '
            'multă energie cinetică pe care frâna trebuie să o consume — '
            'iar un centru de greutate mai ridicat înseamnă mai puțină '
            'rezervă în curbă.',
          ),
          FactsBlock([
            FactItem('3,5 t', 'masa totală maximă autorizată a '
                'autoutilitarei tale'),
            FactItem('până la 1,4 t', 'sarcină utilă — mai mult decât '
                'jumătate din masa proprie'),
            FactItem('ridicat', 'centrul de greutate: dubele se '
                'răstoarnă acolo unde autoturismele încă alunecă'),
          ]),
          BulletsBlock([
            'Încărcat, frânează mai devreme și mai lin — frâna are '
                'nevoie de mai mult timp pentru aceeași decelerare',
            'În curbe considerabil mai încet: încărcătura se deplasează '
                'spre exterior și amplifică tendința de răsturnare',
            'La manevre de evitare nu contravira brusc — exact asta '
                'răstoarnă vehiculele înalte',
            'Abordează sensurile giratorii și ieșirile de pe autostradă '
                'cu o viteză vizibil mai mică decât ești obișnuit',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Momentul răsturnării vine fără avertisment',
            text: 'Spre deosebire de un autoturism, o dubă înaltă abia '
                'dacă anunță răsturnarea. Dacă auzi cum se deplasează '
                'încărcătura, ești deja prea rapid — redu viteza înainte '
                'de curbă, nu în ea.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Unghiul mort',
        asset: 'assets/academy/driving/m03d_toterwinkel.svg',
        blocks: [
          ParagraphBlock(
            'Autoutilitara ta are unghiuri moarte mari — mai ales în '
            'dreapta, lângă cabină, și oblic în spatele ei. Un biciclist '
            'întreg, cu bicicletă cu tot, încape acolo fără să îl vezi '
            'în oglindă.',
          ),
          FactsBlock([
            FactItem('dreapta', 'cel mai mare unghi mort la dube'),
            FactItem('1,5 m', 'distanța laterală minimă la depășirea '
                'bicicliștilor în localitate'),
            FactItem('2 m', 'distanța minimă în afara localității'),
          ]),
          ParagraphBlock(
            'Reglarea corectă a oglinzilor reduce unghiul mort, dar nu '
            'îl elimină. De aceea, la fiecare schimbare de bandă și la '
            'fiecare viraj face parte privirea activă peste umăr — o '
            'privire scurtă, reală, peste umăr, nu doar o înclinare a '
            'capului spre oglindă.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Nu presupune niciodată că ești văzut',
            text: 'Contactul vizual este singura dovadă sigură că cineva '
                'te-a observat. Un semnalizator este o intenție, nu o '
                'garanție.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Virajul: cel mai periculos moment',
        blocks: [
          ParagraphBlock(
            'Majoritatea coliziunilor grave cu bicicliști și pietoni se '
            'produc la virajul la dreapta. Motivul este mereu același: '
            'biciclistul merge drept mai departe și se află exact în '
            'zona pe care șoferul nu o mai poate vedea când începe '
            'virajul.',
          ),
          RevealBlock(
            prompt: 'Studiu de caz: vrei să virezi la dreapta la un '
                'semafor. Un biciclist te-a depășit pe stânga și stă '
                'lângă tine. Semaforul se face verde. Ce faci mai '
                'întâi?',
            answer: 'Rămâi pe loc și îl lași să treacă. Imediat ce '
                'pornești și virezi, el intră în unghiul mort din '
                'dreapta — iar spatele vehiculului tău se deplasează în '
                'plus în banda lui la viraj. Corect este: înainte de '
                'pornire, privire peste umăr la dreapta, lasă bicicliștii '
                'și pietonii să treacă, apoi virează încet și, în timpul '
                'virajului, uită-te din nou în oglinda dreaptă. Cine se '
                'bazează doar pe oglindă nu îl mai vede exact atunci '
                'când contează.',
          ),
          DoDontBlock(
            doTitle: 'Viraj sigur',
            dos: [
              'Semnalizează din timp și redu clar viteza',
              'Privire peste umăr înainte de a vira — nu doar oglinda',
              'În timpul virajului verifică încă o dată la dreapta',
              'La îndoială oprește și lasă să treacă',
            ],
            dontTitle: 'Riscant',
            donts: [
              'Să virezi din elan, ca să folosești spațiul liber',
              'Doar privirea în oglindă',
              'Să presupui că biciclistul rămâne în spatele tău',
              'Să semnalizezi abia când deja virezi',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'La viraj și la întoarcere',
            text: '§ 9 Abs. 5 StVO: la virajul într-o proprietate, la '
                'întoarcere și la mersul înapoi trebuie să excluzi '
                'punerea în pericol a celorlalți participanți la trafic '
                '— la nevoie trebuie să apelezi la un dirijor.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare: defensiv pe drum',
        blocks: [
          ChecklistBlock(
            title: 'Asta pun în practică de azi',
            items: [
              'Cunosc formulele practice pentru distanța de reacție și '
                  'de frânare',
              'Îmi verific distanța la un punct fix, cu două secunde',
              'Pe carosabil ud și pe întuneric cresc la trei secunde',
              'Privesc cu 12–15 secunde înainte, nu la bara din față',
              'Încărcat merg mai încet în curbe și frânez mai devreme',
              'Înainte de fiecare viraj și schimbare de bandă fac o '
                  'privire reală peste umăr',
              'Păstrez 1,5 m distanță la depășirea bicicliștilor în '
                  'localitate',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M4
  SafetyChapterContent(
    id: 'm4',
    title: 'Mersul înapoi și manevrele',
    summary: 'Stăpânește cea mai frecventă sursă de avarii — mers înapoi '
        'sigur și manevre în spații înguste',
    asset: 'assets/academy/driving/m04_rueckwaerts.svg',
    slides: [
      SafetySlide(
        title: 'Sursa de avarii numărul 1',
        blocks: [
          ParagraphBlock(
            'Majoritatea avariilor la autoutilitare apar încet — la '
            'mersul înapoi și la manevre: stâlpi, ziduri, felinare, alte '
            'mașini, portiere deschise. Iar în cele mai grave cazuri, '
            'persoane care stau în unghiul mort din spatele vehiculului.',
          ),
          FactsBlock([
            FactItem('70 %', 'dintre toate avariile la autoutilitare se '
                'produc la manevre'),
            FactItem('< 10 km/h', 'viteza la care apar cele mai multe '
                'avarii de manevră'),
            FactItem('orb', 'o zonă de câțiva metri direct în spatele '
                'vehiculului'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'De ce tocmai aici',
            text: 'La mersul înapoi îți lipsește ceea ce te protejează '
                'de obicei: vizibilitatea liberă. În același timp pare '
                'lent și de aceea nepericulos — cea mai periculoasă '
                'combinație din rutina livrării.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Evită mersul înapoi, nu doar îl stăpâni',
        blocks: [
          ParagraphBlock(
            'Cel mai sigur mers înapoi este cel pe care nu îl faci. '
            'Gândește-te încă de la sosirea la oprire cum vei pleca de '
            'acolo — atunci nu mai trebuie să manevrezi deloc la final.',
          ),
          BulletsBlock([
            'Dacă se poate, parchează cu fața și pleacă tot cu fața',
            'Mai bine oprești cu 40 de metri mai departe decât să dai '
                'înapoi într-o intrare îngustă',
            'La fundături și curți: gândește-te înainte de a intra cum '
                'vei ieși',
            'Reține pe traseu locurile de întors — sunt aceleași în '
                'fiecare zi',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Ce cer legea și DGUV',
            text: '§ 9 Abs. 5 StVO: la mersul înapoi trebuie să excluzi '
                'punerea în pericol a altora, la nevoie apelând la un '
                'dirijor. DGUV Vorschrift 70 (Fahrzeuge) cere același '
                'lucru: mersul înapoi este permis doar dacă punerea în '
                'pericol a persoanelor este exclusă.',
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
            text: '„Get Out And Look" — oprește, coboară, uită-te în '
                'spatele vehiculului și abia apoi dă înapoi. Asta scoate '
                'la iveală exact lucrurile pe care de pe scaun nu le vezi '
                'niciodată.',
          ),
          ParagraphBlock(
            'Turul durează zece până la cincisprezece secunde. În acest '
            'timp vezi stâlpii joși, bordurile, panta, capacele de canal '
            'desprinse, copiii care se joacă și înălțimea porții. Nimic '
            'din toate acestea nu îți arată în mod fiabil o cameră de '
            'mers înapoi.',
          ),
          FactsBlock([
            FactItem('15 s', 'durează un tur GOAL'),
            FactItem('90 cm', 'înălțimea sub care un copil rămâne '
                'invizibil în spatele vehiculului'),
          ]),
          ParagraphBlock(
            'Și încă ceva: ce ai văzut la coborâre îți rămâne în minte. '
            'După aceea nu mai mergi în necunoscut, ci spre o imagine pe '
            'care o cunoști.',
          ),
        ],
      ),
      SafetySlide(
        title: 'GOAL pas cu pas',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/goal01_stopp.svg',
              title: '1 · Oprește',
              caption: 'Înainte de a băga în marșarier, oprești complet '
                  'și asiguri vehiculul. Cine deja rulează nu mai '
                  'decide — doar reacționează.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal02_aussteigen.svg',
              title: '2 · Coboară',
              caption: 'Coboară în loc să te răsucești în scaun. '
                  'Folosește treapta și mânerele de sprijin — regula '
                  'celor trei puncte este valabilă și aici.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal03_umschauen.svg',
              title: '3 · Uită-te în jur',
              caption: 'Ocolește complet vehiculul: ce se află jos în '
                  'spate, cât de înaltă este intrarea, unde este pantă, '
                  'sunt copii sau animale în apropiere? Memorează '
                  'distanțele și punctele de reper.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal04_zurueck.svg',
              title: '4 · Încet înapoi',
              caption: 'Abia acum dă înapoi — în ritm de pas, cu privirea '
                  'peste umăr și în ambele oglinzi. La îndoială oprește '
                  'din nou și uită-te încă o dată.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Încet nu înseamnă inofensiv',
        blocks: [
          StepsBlock([
            'Alege ritmul de pas — niciodată mai repede, nici măcar în '
                'curtea goală',
            'Coboară geamul ca să auzi: strigăte, claxoane, copii',
            'Privește peste umăr și în ambele oglinzi, alternativ',
            'Folosește camera doar ca supliment, niciodată ca sursă '
                'unică',
            'La orice îndoială oprește, coboară, uită-te din nou',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Iluzia camerei',
            text: 'Camera de mers înapoi arată un decupaj, deformează '
                'distanțele și orbește din cauza ploii, a zăpezii și a '
                'murdăriei. Nu vede nimic din ce intră lateral, pe lângă '
                'spate, în traiectoria ta. Nu înlocuiește GOAL.',
          ),
          FactsBlock([
            FactItem('pas', 'viteza maximă la manevre'),
            FactItem('2 s', 'îi trebuie unui copil ca să ajungă în zona '
                'din spatele vehiculului'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Folosește corect dirijorul',
        blocks: [
          ParagraphBlock(
            'Un dirijor ajută doar dacă regulile sunt clare dinainte. Un '
            'coleg care stă undeva în spatele vehiculului și face semne '
            'nu înseamnă siguranță — este un risc în plus.',
          ),
          BulletsBlock([
            'Stabiliți semnele dinainte: stop, încet, mai departe, cât '
                'spațiu mai este',
            'Dirijorul stă lateral, niciodată direct în spatele '
                'vehiculului',
            'Trebuie să îl vezi permanent în oglindă — altfel se '
                'oprește',
            'Dirijează o singură persoană, nu mai multe simultan',
            'Dirijorul poartă vestă reflectorizantă, mai ales în amurg',
          ]),
          RevealBlock(
            prompt: 'Dai înapoi într-o intrare de curte îngustă, colegul '
                'tău dirijează. Dintr-odată nu îl mai vezi în oglindă. Ce '
                'faci?',
            answer: 'Oprești imediat — nu încetinești, ci oprești. Fără '
                'contact vizual nu există semn valabil. Poate a trecut '
                'prin spatele vehiculului, a alunecat sau a fost abordat '
                'de un trecător. Continui abia când îl vezi din nou și '
                'îți dă un semn nou.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Studiu de caz: intrarea îngustă de curte',
        blocks: [
          RevealBlock(
            prompt: 'Studiu de caz: ultima oprire este într-o curte '
                'interioară. Intrarea este îngustă, în spatele tău '
                'așteaptă o mașină, plouă și ai 40 de minute întârziere '
                'față de plan. Cu fața intri — afară ieși doar cu '
                'spatele, pe lângă un zid și trei mașini parcate. Care '
                'este decizia corectă?',
            answer: 'Nici nu intra. Oprește pe stradă, du ultimii metri '
                'pe jos sau folosește liza. Dacă ești deja înăuntru: '
                'avarii pornite, coboară, evaluează situația, roagă-l '
                'eventual pe șoferul care așteaptă să dea înapoi, apoi '
                'ieși din manevră din mai multe mișcări scurte, cu '
                'verificări intermediare. Șoferul care așteaptă în '
                'spatele tău nu este un motiv de grabă — paguba îți '
                'aparține la final ție, nu lui. Cele 40 de minute de '
                'întârziere nu le recuperează nicio manevră, dar o '
                'avarie de tablă îți costă restul zilei.',
          ),
          DoDontBlock(
            doTitle: 'Manevre corecte',
            dos: [
              'Din mai multe mișcări scurte, în loc de una lungă',
              'Oprește între timp și evaluează din nou situația',
              'Avarii pornite când manevrezi în spațiul de circulație',
              'Mai bine oprește mai departe și mergi ultimii metri pe '
                  'jos',
            ],
            dontTitle: 'Greșit',
            donts: [
              'Să manevrezi mai repede sub presiunea celor care '
                  'așteaptă',
              'Să „tragi dintr-o mișcare", ca să nu pară jenant',
              'Să te bazezi doar pe cameră sau pe senzori',
              'Să manevrezi în timp ce pietonii traversează zona',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare: mers înapoi și manevre',
        blocks: [
          ChecklistBlock(
            title: 'Înainte de fiecare manevră cu spatele',
            items: [
              'Verific mai întâi dacă pot evita mersul înapoi',
              'Opresc complet înainte de a băga în marșarier',
              'Cobor și mă uit în spatele vehiculului (GOAL)',
              'Merg înapoi doar în ritm de pas',
              'Privesc peste umăr și în ambele oglinzi, nu doar la '
                  'cameră',
              'Cobor geamul ca să aud',
              'Opresc imediat dacă nu îl mai văd pe dirijor',
              'Raportez orice avarie de manevră, inclusiv mica '
                  'lovitură',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M5
  SafetyChapterContent(
    id: 'm5',
    title: 'Vreme, vizibilitate și condiții dificile',
    summary: 'Adaptează stilul de condus la ploaie, carosabil ud, ceață, '
        'zăpadă, întuneric și caniculă',
    asset: 'assets/academy/driving/m05_wetter.svg',
    slides: [
      SafetySlide(
        title: 'Umezeala schimbă totul',
        blocks: [
          ParagraphBlock(
            'Pe carosabil ud aderența scade considerabil — distanța de '
            'frânare se lungește semnificativ, în multe situații aproape '
            'până la dublu. Deosebit de critică este prima ploaie după o '
            'perioadă lungă de secetă: uleiul și cauciucul de pe '
            'carosabil formează cu apa o peliculă alunecoasă.',
          ),
          FactsBlock([
            FactItem('până la ×2', 'atât de lungă devine distanța de '
                'frânare pe umed'),
            FactItem('3 s+', 'distanță minimă în loc de 2 secunde'),
            FactItem('−20 %', 'viteza, ca orientare aproximativă'),
          ]),
          BulletsBlock([
            'Frânează mai devreme și mai lin, nu în curbă',
            'Execută mișcările de volan lin, nu brusc',
            'Fii atent la marcaje, la capacele de canal și la șinele de '
                'tramvai — acolo este cel mai alunecos',
            'Evită făgașele, acolo stă apa',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Viteza este obligație, nu opțiune',
            text: '§ 3 Abs. 1 StVO cere să îți adaptezi viteza la '
                'condițiile de drum, de trafic, de vizibilitate și de '
                'vreme. La un accident pe carosabil ud, viteza permisă '
                'nu te ajută cu nimic.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Acvaplanare: ce se întâmplă de fapt',
        asset: 'assets/academy/driving/m05b_aquaplaning.svg',
        blocks: [
          ParagraphBlock(
            'Acvaplanarea înseamnă: între anvelopă și carosabil se '
            'interpune o peliculă de apă. Anvelopa plutește. Din acest '
            'moment direcția și frâna nu mai au niciun efect — nu mai '
            'puțin, ci deloc.',
          ),
          ParagraphBlock(
            'Canelurile profilului au exact o sarcină: să evacueze apa '
            'din fața anvelopei. La viteză mai mare, o anvelopă trebuie '
            'să deplaseze în fiecare secundă mai mulți litri de apă. Cu '
            'cât profilul este mai plat și viteza mai mare, cu atât mai '
            'devreme nu mai reușește.',
          ),
          FactsBlock([
            FactItem('1,6 mm', 'minimul legal — pentru acvaplanare deja '
                'prea puțin'),
            FactItem('3 mm', 'limita practică inferioară pe vreme '
                'umedă'),
            FactItem('Viteză²', 'atât de puternic crește pericolul de '
                'acvaplanare cu viteza'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'După ce îți dai seama din timp',
            text: 'Direcția devine brusc ușoară, zgomotele de rulare se '
                'schimbă, turația crește fără motiv. Acestea sunt '
                'secundele în care mai poți lua piciorul de pe '
                'accelerație.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Acvaplanare: reacția corectă',
        blocks: [
          DoDontBlock(
            doTitle: 'Corect pe apă stătută',
            dos: [
              'Ia piciorul de pe accelerație — doar atât, nu brusc de '
                  'tot',
              'Ține volanul calm și drept',
              'Apasă ambreiajul, respectiv debreiază',
              'Lasă mașina să ruleze liber până când anvelopele prind '
                  'din nou',
              'Abia apoi virează sau frânează cu grijă',
            ],
            dontTitle: 'Greșit',
            donts: [
              'Să frânezi puternic — roțile se blochează fără efect',
              'Să virezi brusc sau să contravirezi',
              'Să accelerezi ca „să treci"',
              'Să schimbi banda în timp ce anvelopele plutesc',
            ],
          ),
          RevealBlock(
            prompt: 'Studiu de caz: pe drumul național, după o furtună, '
                'stă apă în făgașul din dreapta. Mergi cu 80 km/h, în '
                'spate te presează un autoturism. Ce faci?',
            answer: 'Ridică clar piciorul de pe accelerație înainte de a '
                'intra în apă — nu în ea. Ține volanul drept și lasă-l pe '
                'cel grăbit să se grăbească; o tamponare se repară, o '
                'ieșire pe contrasens nu. Cine în schimb frânează sau '
                'evită în mijlocul apei provoacă exact pierderea de '
                'control pe care vrea să o evite. Dacă se poate: după '
                'apă trage la dreapta și lasă-l pe cel grăbit să treacă.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'O anvelopă care plutește nu virează',
            text: 'Cât timp pelicula de apă susține, orice mișcare de '
                'volan este fără efect — ea acționează brusc abia când '
                'anvelopa prinde din nou. Exact de aici apare '
                'derapajul.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Adâncimea profilului și anvelopele de iarnă',
        blocks: [
          TableBlock(
            headers: ['Situație', 'Profil / anvelope'],
            rows: [
              ['Minimul legal', '1,6 mm — tot anul'],
              ['Vară, carosabil ud', 'recomandat de la 3 mm'],
              ['Iarnă, zăpadă și piatră', 'recomandat de la 4 mm'],
              ['Polei, zăpadă, gheață', 'anvelope de iarnă cu simbolul '
                  'Alpine'],
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Obligația situațională de anvelope de iarnă',
            text: 'Conform § 2 Abs. 3a StVO, pe polei, zăpadă bătătorită, '
                'piatră de zăpadă, gheață sau chiciură ai voie să conduci '
                'doar cu anvelope adecvate iernii. Abaterile costă amendă '
                'și un punct — la stânjenirea altora mai mult.',
          ),
          BulletsBlock([
            'Recunoști anvelopele de iarnă după simbolul Alpine (munte '
                'cu fulg de nea)',
            'Și anvelopele adecvate iernii aproape că nu mai au efect cu '
                'profil prea mic',
            'Ține cont de vechimea anvelopei: cauciucul se întărește și '
                'pierde aderență, chiar dacă profilul mai există',
            'Raportează profilul subțire înainte să vină primul îngheț — '
                'nu în dimineața de după',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Zăpadă, gheață și curățarea parbrizului',
        asset: 'assets/academy/driving/m05c_winter.svg',
        blocks: [
          ParagraphBlock(
            'Pe polei este valabil pentru tot: lin. Pornire lină, frânare '
            'lină, virare lină. Orice mișcare bruscă depășește aderența '
            'oricum redusă. Podurile, porțiunile de pădure și zonele '
            'umbrite îngheață primele — și se dezgheață ultimele.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Nicio „gaură de privit"',
            text: 'Toate geamurile, oglinzile, luminile și numărul de '
                'înmatriculare trebuie să fie libere (§ 23 Abs. 1 StVO). '
                'O gaură curățată în gheață este o contravenție — iar la '
                'un accident, o culpă gravă. Și zăpada de pe plafon '
                'trebuie dată jos înainte de plecare.',
          ),
          DoDontBlock(
            doTitle: 'Rutina de iarnă',
            dos: [
              'Curăță complet de gheață toate geamurile și oglinzile',
              'Eliberează de zăpadă plafonul, luminile și numărul de '
                  'înmatriculare',
              'Curăță treptele și mânerele de gheață și de zloată',
              'Completează lichidul de parbriz cu antigel',
              'Pleacă vizibil mai devreme, în loc să recuperezi pe drum',
            ],
            dontTitle: 'Greșeli de iarnă',
            donts: [
              'Să pleci în timp ce geamul încă se dezgheață',
              'Să torni apă fierbinte pe geam',
              'Să frânezi pe zloată și să virezi în același timp',
              'Să ignori treptele înghețate — aici cazi',
            ],
          ),
          FactsBlock([
            FactItem('0 °C', 'de aici mai întâi podurile și zonele '
                'umbrite'),
            FactItem('×2 până la ×10', 'cu atât se lungește distanța de '
                'frânare pe zăpadă și gheață'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Ceață, amurg, întuneric',
        blocks: [
          ParagraphBlock(
            'La vizibilitate redusă nu doar vederea este mai grea, ci și '
            'faptul de a fi văzut. Aprinde luminile din timp — la '
            'îndoială cu o jumătate de oră mai devreme decât ar fi '
            'necesar.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Regula practică la ceață',
            text: 'Vizibilitatea în metri corespunde vitezei maxime în '
                'km/h. Dacă vezi doar 50 de metri, conduci cel mult cu '
                '50 km/h — iar la o vizibilitate sub 50 de metri se '
                'aplică oricum viteza de 50 ca limită superioară.',
          ),
          BulletsBlock([
            'Farurile de ceață doar la vizibilitate real redusă, nu ca '
                'iluminare permanentă',
            'Lampa de ceață spate abia sub 50 de metri vizibilitate — '
                'orbește puternic pe cel din spate',
            'Folosește stâlpii de ghidaj de pe marginea drumului ca '
                'reper',
            'În amurg fii deosebit de atent la pietonii în haine '
                'închise la culoare',
            'Iluminarea interioară stinsă, geamurile curate pe '
                'interior — altfel ambele te costă vederea de noapte',
          ]),
          FactsBlock([
            FactItem('50 m', 'distanța dintre doi stâlpi de ghidaj în '
                'afara localității'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Furtună și vânt lateral',
        blocks: [
          ParagraphBlock(
            'Duba ta este o suprafață mare și înaltă — pe vânt lateral se '
            'comportă complet altfel decât un autoturism. Deosebit de '
            'periculoase sunt locurile unde vântul apare brusc: poduri, '
            'ieșiri din pădure, spații între clădiri și momentul în care '
            'ești depășit de un camion.',
          ),
          BulletsBlock([
            'Redu clar viteza, ambele mâini pe volan',
            'În locurile cunoscute cu vânt, strânge volanul din timp și '
                'așteaptă-te la o rafală',
            'După depășirea de către un camion, așteaptă-te la o rafală',
            'Pe furtună nu parca sub copaci și nici lângă schele',
            'Ține portierele pe vânt — sunt smulse și deteriorate',
          ]),
          RevealBlock(
            prompt: 'Studiu de caz: avertizare de furtună, treci gol '
                'peste un pod de autostradă. De ce este critic tocmai '
                'faptul că ești gol?',
            answer: 'Pentru că vehiculului îi lipsește greutatea care îl '
                'ține pe drum. O dubă goală oferă aceeași suprafață de '
                'atac ca una încărcată, dar cântărește cu o bună treime '
                'mai puțin — o rafală o deplasează considerabil mai '
                'mult. Corect este: redu viteza înainte de pod, ambele '
                'mâini pe volan, așteaptă-te la rafală la capătul podului '
                'și nu circula lângă un camion.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Caniculă și ture lungi',
        blocks: [
          ParagraphBlock(
            'Vara lucrezi într-un vehicul care se încinge puternic la '
            'soare și mergi pe jos mulți kilometri. Un șofer '
            'supraîncălzit și deshidratat reacționează măsurabil mai '
            'lent — efectul este comparabil cu cel al oboselii.',
          ),
          FactsBlock([
            FactItem('2–3 l', 'lichide pe tură pe caniculă'),
            FactItem('> 60 °C', 'temperatura din interiorul unui vehicul '
                'lăsat în soare'),
          ]),
          BulletsBlock([
            'Bea regulat, înainte să simți sete',
            'Pauze la umbră, nu în cabina încinsă',
            'Acoperământ pentru cap și protecție solară la drumurile '
                'lungi pe jos',
            'La probleme circulatorii raportează imediat și fă pauză',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Nu lăsa niciodată pe nimeni în mașină',
            text: 'Nu lăsa niciodată un animal sau o persoană în mașina '
                'încinsă — nici măcar „doar cinci minute" și nici cu '
                'geamul întredeschis. Interiorul devine în câteva minute '
                'periculos de fierbinte.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare: condiții dificile',
        blocks: [
          ChecklistBlock(
            title: 'Pe vreme rea și vizibilitate redusă',
            items: [
              'Adaptez viteza și distanța, nu doar la indicator',
              'Pe carosabil ud cresc la cel puțin 3 secunde distanță',
              'La acvaplanare: piciorul de pe accelerație, drept, fără '
                  'frână',
              'Îmi cunosc adâncimea profilului și raportez din timp '
                  'anvelopele subțiri',
              'Curăț toate geamurile de gheață, nicio gaură de privit',
              'Dau jos zăpada de pe plafon, de pe lumini și de pe număr',
              'La poduri și la ieșiri din pădure mă aștept la vânt '
                  'lateral',
              'Beau suficient și fac pauze la umbră',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M6
  SafetyChapterContent(
    id: 'm6',
    title: 'Distragere, oboseală și presiunea timpului',
    summary: 'Recunoaște principalele cauze umane ale accidentelor și '
        'contracarează-le activ',
    asset: 'assets/academy/driving/m06_ablenkung.svg',
    slides: [
      SafetySlide(
        title: 'Telefonul la volan: INTERZIS',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Telefonul în mână este interzis în timpul mersului',
            text: 'Nici pentru a vorbi, nici pentru a scrie, nici pentru '
                'a verifica ceva — și nici pentru a alege muzică, '
                'podcasturi sau mesaje.',
          ),
          ParagraphBlock(
            'Clar și fără excepție. Aceasta nu este doar regula firmei '
            'noastre, ci lege. Și este valabilă pentru orice dispozitiv '
            'electronic care servește comunicării, informării sau '
            'organizării — deci și pentru scaner.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 23 Abs. 1a StVO',
            text: 'Cine conduce un vehicul are voie să folosească un '
                'dispozitiv electronic doar dacă pentru asta nu trebuie '
                'nici ridicat, nici ținut în mână. Deja ridicarea sau '
                'ținerea în mână constituie abaterea — indiferent ce '
                'faci cu el.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Porțiunea parcursă în orb',
        asset: 'assets/academy/driving/m06b_handy.svg',
        blocks: [
          ParagraphBlock(
            'O privire pe ecran nu durează o secundă — durează în medie '
            'două-trei secunde, iar un mesaj citit mai degrabă cinci. În '
            'acest timp conduci cu ochii închiși. Calculează o dată în '
            'metri.',
          ),
          FactsBlock([
            FactItem('14 m/s', 'parcurgi pe secundă la viteza de 50'),
            FactItem('28 m', 'în orb la 2 secunde de privire pe telefon'),
            FactItem('cca. 70 m', 'în orb, dacă citești un mesaj'),
          ]),
          RevealBlock(
            prompt: 'Problemă de calcul: mergi cu 30 km/h printr-o zonă '
                'rezidențială și te uiți 3 secunde la scaner. Cât de '
                'departe mergi în orb — și ajunge asta pentru un '
                'accident?',
            answer: 'La 30 km/h parcurgi bine 8 metri pe secundă, deci în '
                '3 secunde aproximativ 25 de metri. Asta este mai mult '
                'decât întreaga distanță de oprire la această viteză (18 '
                'metri). Altfel spus: parcurgi în orb o porțiune pe care, '
                'cu vizibilitate, ai fi putut opri demult. Cine crede că '
                'la viteză mică o privire nu este critică confundă lent '
                'cu sigur — tocmai în zonele rezidențiale copiii aleargă '
                'pe carosabil fără avertisment.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Muzică, navigație, scaner — totul dinainte',
        blocks: [
          ParagraphBlock(
            'Muzica și podcasturile sunt în regulă — dar nu cu telefonul '
            'în mână. Alege și pornește totul înainte de plecare, din '
            'staționare: lista de redare, volumul, destinația din '
            'navigație, următoarea oprire. Odată pornit, în timpul '
            'mersului nu se mai atinge nimic la dispozitiv.',
          ),
          DoDontBlock(
            doTitle: 'Permis',
            dos: [
              'Setează lista de redare și volumul dinainte, din '
                  'staționare',
              'Introdu destinația în navigație înainte de plecare',
              'Lasă telefonul în suport și doar privește-l',
              'Vorbește cu mâinile libere, prin sistemul hands-free',
              'Pentru orice altceva oprește scurt',
            ],
            dontTitle: 'Interzis',
            donts: [
              'Să schimbi piesa sau podcastul în timpul mersului',
              'Să citești sau să scrii mesaje în timpul mersului',
              'Să iei telefonul în mână la semaforul roșu',
              'Să operezi scanerul sau lista de opriri în rulaj',
              'Să scoți dispozitivul din suport ca să îl vezi mai bine',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Fără căști',
            text: 'Nicio cască și niciun set de căști intraauriculare în '
                'timpul mersului — nici măcar pe o ureche. Trebuie să auzi '
                'traficul, claxoanele, strigătele și vehiculele de '
                'intervenție. La manevre, auzul este adesea singurul '
                'avertisment.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Singura excepție: din staționare, cu motorul oprit',
        blocks: [
          ParagraphBlock(
            'Telefonul, scanerul și navigația le folosești doar din '
            'staționare sigură. Procedura practică la oprire: oprești, '
            'motorul stins, operezi dispozitivul, apoi cobori. Iar '
            'înainte de plecare: urci, setezi destinația și muzica, apoi '
            'pornești.',
          ),
          RevealBlock(
            prompt: 'De când contează juridic „staționarea" — și cum '
                'stau lucrurile cu sistemul start-stop la semaforul '
                'roșu?',
            answer: 'Juridic, staționarea contează abia când motorul este '
                'oprit. Excepția nu se aplică în mod expres atunci când '
                'motorul stă doar din cauza unei funcții automate '
                'start-stop. La semaforul roșu nu ai deci voie să iei '
                'dispozitivul în mână — nici dacă motorul tocmai este '
                'oprit.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Excepție doar cu motorul oprit',
            text: 'Operarea este permisă doar dacă vehiculul staționează '
                'și motorul este oprit. O oprire automată start-stop nu '
                'este suficientă pentru asta.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Cât costă',
        blocks: [
          FactsBlock([
            FactItem('100 € + 1 punct', 'telefonul în mână în timpul '
                'mersului'),
            FactItem('150 € + 2 puncte', 'cu punere în pericol, plus '
                '1 lună suspendare'),
            FactItem('200 € + 2 puncte', 'cu producere de pagube, plus '
                '1 lună suspendare'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Perioada de probă',
            text: 'În perioada de probă a permisului se adaugă un seminar '
                'de perfecționare și prelungirea perioadei de probă la '
                '4 ani.',
          ),
          ParagraphBlock(
            'Pentru tine, ca șofer profesionist, o suspendare înseamnă: '
            'fără loc de muncă timp de o lună. Iar dacă din distragere '
            'rezultă un accident cu răniți, nu rămâne la amendă — atunci '
            'apare acuzația de punere în pericol a circulației rutiere '
            '(§ 315c StGB), iar aceasta este infracțiune.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Cea mai simplă asigurare',
            text: 'Să pui telefonul deoparte nu costă nimic și îți '
                'protejează permisul, locul de muncă și, la nevoie, o '
                'viață.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Distragerea are multe forme',
        blocks: [
          ParagraphBlock(
            'Nu doar telefonul: mâncatul, băutul, căutarea coletelor, '
            'discuțiile, supărarea pe ultimul client, gândurile la '
            'următoarea oprire. Distragere este tot ce îți ia ochii, '
            'mâinile sau mintea de pe drum.',
          ),
          DoDontBlock(
            doTitle: 'În regulă în timpul mersului',
            dos: [
              'Să privești drumul',
              'Să vorbești cu mâinile libere, prin sistemul hands-free',
              'Priviri scurte în oglinzi',
              'Pentru orice altceva oprește scurt',
            ],
            dontTitle: 'Nu este în regulă',
            donts: [
              'Să despachetezi mâncare sau băutură',
              'Să cauți următorul colet în compartimentul de marfă',
              'Să operezi scanerul sau lista de opriri în mers',
              'Să reorganizezi în minte traseul în timp ce conduci, în '
                  'loc să oprești scurt',
            ],
          ),
          RevealBlock(
            prompt: 'Studiu de caz: la plecare observi că ai luat coletul '
                'greșit. Oprirea corectă este la 300 de metri. Ce faci?',
            answer: 'Mergi până la următorul loc sigur de oprire, '
                'oprești, motorul stins, apoi schimbi în compartimentul '
                'de marfă. Întinderea spre spate în timpul mersului este '
                'situația clasică în care șoferii părăsesc banda — pentru '
                'că întorci simultan capul și trunchiul. Un ocol de 300 '
                'de metri durează 30 de secunde, o zgârietură restul '
                'zilei.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Oboseala: corpul tău nu negociază',
        asset: 'assets/academy/driving/m06c_muedigkeit.svg',
        blocks: [
          ParagraphBlock(
            'Oboseala nu este o problemă de voință. De la un anumit punct '
            'creierul tău se deconectează pentru scurt timp — fie că '
            'vrei, fie că nu. Partea perfidă: exact în această fază îți '
            'supraestimezi cel mai mult propria vigilență.',
          ),
          SubheadBlock('Semnalele de avertizare pe care trebuie să le iei '
              'în serios'),
          BulletsBlock([
            'Căscat frecvent, ochi care ard sau sunt grei',
            'Nu îți amintești ultimii kilometri',
            'Ratezi intersecții sau opriri',
            'Poziția scaunului ți se pare brusc greșită, te tot muți',
            'Mergi neregulat în bandă sau corectezi permanent',
            'Îți este frig și ai gâtul înțepenit fără motiv exterior',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Perioade de risc',
            text: 'Cele mai periculoase sunt orele dimineții devreme, '
                'căderea de după masa de prânz și ultima oră a turei. '
                'Planifică-ți pauzele exact acolo.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ațipirea de o secundă, exprimată în metri',
        blocks: [
          ParagraphBlock(
            'O ațipire durează de obicei două până la cinci secunde. '
            'Sună scurt — până când o calculezi în metri.',
          ),
          FactsBlock([
            FactItem('56 m', 'la viteza de 50, în 4 secunde de ațipire'),
            FactItem('89 m', 'la viteza de 80, în 4 secunde'),
            FactItem('111 m', 'la viteza de 100, în 4 secunde'),
          ]),
          RevealBlock(
            prompt: 'Problemă de calcul: mergi cu 80 km/h pe drumul '
                'județean și ațipești 4 secunde. Cât de departe mergi '
                'necontrolat — și ce se află pe această porțiune?',
            answer: '80 km/h înseamnă aproximativ 22 de metri pe secundă, '
                'deci în 4 secunde cam 89 de metri. Pe această porțiune '
                'se află, pe un drum județean, de obicei o curbă, un '
                'șir de copaci și traficul din sens opus. Și, spre '
                'deosebire de privirea pe telefon, în acest timp nu '
                'virezi deloc — vehiculul iese din bandă. De aceea, '
                'împotriva ațipirii ajută un singur lucru: să oprești '
                'înainte.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Nu există o variantă mică a acestui lucru',
            text: 'Cine a ațipit o dată ațipește din nou — de regulă în '
                'câteva minute. Cursa se termină aici, nu la următoarea '
                'oprire.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ce ajută — și ce nu',
        blocks: [
          DoDontBlock(
            doTitle: 'Chiar funcționează',
            dos: [
              'Să oprești și să închizi ochii 15–20 de minute',
              'Să cobori, să mergi, aer proaspăt și mișcare',
              'Să mănânci și să bei ceva',
              'Să raportezi tura și să ceri sprijin, dacă nu este de '
                  'ajuns',
            ],
            dontTitle: 'Nu funcționează (sau doar câteva minute)',
            donts: [
              'Geamul deschis și muzica tare',
              'Cafeaua ca înlocuitor pentru somn',
              'Să te menții treaz cu discuții',
              'Să mergi mai repede, ca să termini mai devreme',
            ],
          ),
          ParagraphBlock(
            'Un somn scurt de 15 până la 20 de minute, urmat de mișcare, '
            'este singura măsură care aduce cu adevărat ceva pe termen '
            'scurt. Orice altceva doar amână problema cu câțiva '
            'kilometri.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Incapacitatea de a conduce',
            text: 'Cine merge mai departe în ciuda unei epuizări '
                'evidente conduce vehiculul în stare de incapacitate. '
                'Dacă din asta rezultă o punere în pericol, nu mai este '
                'o amendă, ci o infracțiune (§ 315c StGB).',
          ),
        ],
      ),
      SafetySlide(
        title: 'Gestionarea inteligentă a presiunii și listă',
        blocks: [
          ParagraphBlock(
            'Presiunea timpului este reală — dar goana și graba abia dacă '
            'economisesc timp și costă mult risc. Câștigul de timp prin '
            'condus mai rapid se măsoară în trafic urban în minute; o '
            'singură avarie de manevră te costă o oră.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Când planul nu iese',
            text: 'Aceasta nu este o problemă de siguranță, este o temă '
                'de planificare — raportează din timp, în loc să o '
                'compensezi la volan. O raportare la ora 13 ajută, una la '
                'ora 18 nu mai ajută.',
          ),
          ChecklistBlock(
            title: 'Asta iau cu mine din modulul 6',
            items: [
              'Telefonul meu rămâne neatins în timpul mersului',
              'Setez muzica, navigația și scanerul înainte de plecare',
              'Știu că „staționarea" contează abia cu motorul oprit',
              'Nu port căști',
              'Îmi cunosc semnele personale de oboseală',
              'La oboseală opresc, în loc să rezist',
              'Raportez din timp și onest un plan nerealist',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M7
  SafetyChapterContent(
    id: 'm7',
    title: 'Accidente de muncă: urcare/coborâre, ridicare, căderi',
    summary: 'Evită rănirile din afara condusului — accent pe urcarea și '
        'coborârea în siguranță',
    asset: 'assets/academy/driving/m07_ein_aussteigen.svg',
    slides: [
      SafetySlide(
        title: 'De ce este cel mai important gest al zilei',
        blocks: [
          ParagraphBlock(
            'Pe tură urci și cobori de zeci de ori — este mișcarea pe '
            'care o faci cel mai des. Tocmai de aceea se produc aici '
            'cele mai multe răniri: scrântiri, alunecări pe muchia '
            'treptei, căderi din mașină, pași greșiți în trafic.',
          ),
          FactsBlock([
            FactItem('100.000', 'accidente prin alunecare, împiedicare '
                'și cădere la șoferii profesioniști pe an'),
            FactItem('24', 'zile de incapacitate în medie pe cădere'),
            FactItem('Nr. 1', 'cel mai frecvent tip de rănire în '
                'livrare'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'BG Verkehr avertizează',
            text: 'BG Verkehr (asigurarea germană de accidente de muncă '
                'pentru transporturi) avertizează expres că prăbușirile '
                'la urcare și coborâre duc la răniri grave, uneori '
                'mortale.',
          ),
          ParagraphBlock(
            'Diferența dintre o coborâre sigură și una periculoasă este '
            'de două secunde. Raportat la 250 de coborâri pe zi, asta '
            'înseamnă opt minute bune — cea mai ieftină asigurare a '
            'corpului tău.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Regula celor 3 puncte (2+1)',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Două mâini și un picior — întotdeauna',
            text: 'Regula centrală a BG Verkehr: două mâini și un picior '
                'sunt mereu în contact cu vehiculul — „2+1".',
          ),
          ParagraphBlock(
            'Ai deci în orice moment trei puncte de contact ferme '
            'înainte să îl desprinzi pe următorul. Astfel o singură '
            'alunecare nu poate deveni niciodată o cădere, pentru că te '
            'mai țin în continuare două puncte. Mișcă mereu un singur '
            'punct, niciodată două simultan.',
          ),
          RevealBlock(
            prompt: 'La ce trei puncte de contact se referă — și ce nu '
                'intră expres în această categorie?',
            answer: 'Mâna stângă pe mâner, mâna dreaptă pe mâner, un '
                'picior pe treaptă. Nu intră aici: volanul, muchia '
                'portierei, scaunul, anvelopa și butucul roții. Muchia '
                'portierei și volanul cedează sau se rotesc — exact '
                'atunci când ai nevoie de ele.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Regulă de reținut',
            text: 'Întâi coboară, apoi apucă. Pune obiectele mai întâi '
                'jos în vehicul, apoi coboară cu mâinile libere.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Corect înăuntru, corect afară',
        blocks: [
          BulletsBlock([
            'Urcare: cu fața înainte, spre vehicul',
            'Coborâre: cu spatele, cu fața spre vehicul — ca pe o '
                'scară, niciodată răsucindu-te cu spatele spre portieră',
            'Folosește toate treptele — nu sări niciuna',
            'Folosește mânerele, nu muchia portierei sau volanul ca '
                'sprijin de avarie',
            'La coborârea din compartimentul de marfă, aceeași regulă: '
                'cu fața spre vehicul, treaptă cu treaptă',
          ]),
          StepsBlock([
            'Oprește și asigură vehiculul',
            'Pune obiectele jos în vehicul',
            'Verifică traficul peste umăr și în oglindă',
            'Deschide portiera controlat',
            'Întoarce-te, cu fața spre vehicul',
            'Stabilește trei puncte de contact',
            'Coboară treaptă cu treaptă',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Nu sări niciodată',
        asset: 'assets/academy/driving/m07b_springen.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Săritura este cea mai frecventă greșeală',
            text: 'Săritura din cabină sau din compartimentul de marfă '
                'este cea mai frecventă cauză a gleznelor scrântite, '
                'precum și a leziunilor de genunchi și de spate în '
                'livrare.',
          ),
          ParagraphBlock(
            'Podeaua compartimentului de marfă al unei autoutilitare se '
            'află, în funcție de model, la aproximativ 55–75 de '
            'centimetri deasupra drumului. La săritură, la aterizare '
            'acționează asupra gleznei, genunchiului și coloanei un '
            'multiplu al greutății tale corporale — și asta la fiecare '
            'săritură în parte.',
          ),
          FactsBlock([
            FactItem('55–75 cm', 'înălțimea podelei de încărcare '
                'deasupra drumului'),
            FactItem('250+', 'coborâri pe tură — fiecare în parte '
                'contează pentru articulații'),
          ]),
          RevealBlock(
            prompt: 'Studiu de caz: plouă, sari din compartimentul de '
                'marfă pe un trotuar în pantă cu frunze ude. Ce anume '
                'merge prost aici?',
            answer: 'La săritură nu mai poți corecta aterizarea — ești '
                'în aer, iar ce se întâmplă sub tine decide solul. '
                'Frunzele ude pe pantă nu oferă aproape nicio frecare: '
                'piciorul alunecă la aterizare, articulația se răsucește '
                'lateral. Cine în schimb coboară treaptă cu treaptă, cu '
                'trei puncte de contact, simte solul alunecos înainte de '
                'a-și pune greutatea completă pe el — și poate încă '
                'renunța.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Greșelile tipice',
        blocks: [
          DoDontBlock(
            doTitle: 'Corect',
            dos: [
              'Pune obiectele mai întâi jos în vehicul',
              'Coboară cu mâinile libere și trei puncte de contact',
              'Ține muchiile treptelor și mânerele curate și libere',
              'Pe umezeală și gheață curăță treptele înainte',
              'Ia-ți timp — și la oprirea cu numărul 180',
            ],
            dontTitle: 'Greșit',
            donts: [
              'Să sari în loc să cobori',
              'Mâinile pline — telefon, scaner, cafea, colete',
              'Să folosești anvelopa sau butucul roții ca treaptă',
              'Să te uiți la telefon în timp ce cobori',
              'Să ignori muchiile de treaptă ude, înghețate sau '
                  'murdare',
              'Să te răsucești lateral afară din scaun',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Oprirea de după este cea mai periculoasă',
            text: 'După o oprire lungă, picioarele sunt înțepenite și '
                'concentrarea a dispărut. Exact atunci se produce pasul '
                'greșit — adună-te scurt, apoi coboară.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Partea dinspre trafic: momentul subestimat',
        blocks: [
          ParagraphBlock(
            'La Sprinterele și autoutilitarele joase, problema nu este '
            'adesea înălțimea, ci pasul în traficul în mișcare. Dacă se '
            'poate, coboară pe partea dinspre trotuar sau pe partea '
            'sigură. Nu deschide larg portiera înainte de a te uita.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 14 Abs. 1 StVO — urcarea și coborârea',
            text: 'Cine urcă sau coboară trebuie să se comporte astfel '
                'încât punerea în pericol a celorlalți participanți la '
                'trafic să fie exclusă. La un accident cu portiera, '
                'răspunderea îi revine practic întotdeauna celui care '
                'coboară.',
          ),
          RevealBlock(
            prompt: 'Oprești pe marginea carosabilului, un biciclist se '
                'apropie din spate — cum cobori?',
            answer: 'Înainte de a deschide portiera, uită-te peste umăr '
                'și în oglindă, lasă biciclistul să treacă și deschide '
                'portiera doar controlat, cu mâna mai depărtată. Așa-'
                'numita „prindere olandeză" — deschiderea portierei cu '
                'mâna dreaptă — îți rotește automat trunchiul spre spate '
                'și te obligă să privești. Bicicliștii și trotinetele '
                'trec strâns pe lângă mașină și nu se așteaptă la o '
                'portieră care se deschide.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Încălțămintea și solul',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Recomandarea BG Verkehr',
            text: 'Încălțăminte care închide piciorul și este '
                'antiderapantă. Fără pantofi deschiși sau uzați. '
                'Bocancii de protecție până peste gleznă sprijină exact '
                'articulația care se răsucește la coborâre.',
          ),
          ParagraphBlock(
            'Înainte de coborâre fii atent scurt la sol: bordură, pantă, '
            'frunze, umezeală, gheață, criblură. Pe zăpadă și gheață '
            'ține mânerele și treptele libere. Dacă se poate, oprește pe '
            'teren plan și iluminat.',
          ),
          ChecklistBlock(
            title: 'Înainte de coborâre',
            items: [
              'Încălțăminte solidă, antiderapantă',
              'Solul verificat — bordură, pantă, umezeală, gheață',
              'Mâinile libere, obiectele puse jos',
              'Traficul verificat peste umăr și în oglindă',
              'Treptele curate și libere',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Ridicarea și transportul corect',
        blocks: [
          ParagraphBlock(
            'Spatele este al doilea risc de incapacitate ca frecvență, '
            'după căderi. Și, spre deosebire de o cădere, leziunea de '
            'disc nu apare într-o zi — ea se formează prin mii de '
            'ridicări greșite.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/lift01_nah.svg',
              title: '1 · Sarcina aproape de corp',
              caption: 'Apropie-te de colet înainte de a-l ridica. '
                  'Fiecare centimetru de distanță față de corp '
                  'multiplică solicitarea asupra discurilor '
                  'intervertebrale.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift02_hocke.svg',
              title: '2 · Lasă-te pe vine',
              caption: 'Îndoaie genunchii și lasă-te pe vine, în loc să '
                  'te apleci înainte din șolduri. Forța vine din '
                  'picioare — sunt cel mai puternic mușchi pe care îl '
                  'ai.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift03_ruecken.svg',
              title: '3 · Ține spatele drept',
              caption: 'Ține spatele drept și privirea înainte în timp '
                  'ce te ridici cu picioarele. Un spate rotunjit sub '
                  'sarcină este poziția clasică de hernie de disc.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift04_drehen.svg',
              title: '4 · Nu te răsuci — pășește',
              caption: 'Nu te răsuci niciodată cu trunchiul când ai '
                  'sarcina în brațe. Mută în schimb picioarele și '
                  'rotește tot corpul. Ridicarea plus răsucirea este '
                  'cea mai periculoasă combinație pentru coloană.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Cât înseamnă prea greu?',
        blocks: [
          ParagraphBlock(
            'Limite fixe în kilograme nu există în lege — decisive sunt '
            'împreună greutatea, poziția, frecvența și mediul. În '
            'practică s-au impus însă valori orientative.',
          ),
          FactsBlock([
            FactItem('cca. 25 kg', 'orientare pentru ridicare ocazională '
                '(bărbați)'),
            FactItem('cca. 15 kg', 'orientare pentru ridicare ocazională '
                '(femei)'),
            FactItem('peste', 'folosește mijloace ajutătoare sau '
                'transportă în doi'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'LasthandhabV (regulamentul privind manipularea '
                'sarcinilor)',
            text: 'Angajatorul trebuie să evite pe cât posibil ridicarea '
                'și transportul manual și să pună la dispoziție mijloace '
                'ajutătoare potrivite. Iar tu trebuie apoi să folosești '
                'aceste mijloace — nu stau acolo ca decor.',
          ),
          DoDontBlock(
            doTitle: 'Transport corect',
            dos: [
              'Folosește liza sau cutia cu rotile, în loc să mergi de '
                  'două ori',
              'Transportă în doi coletele voluminoase',
              'Ține câmpul vizual liber — nu privi peste stivă',
              'Stabilește drumul și punctul de depunere înainte de '
                  'ridicare',
            ],
            dontTitle: 'Transport greșit',
            donts: [
              'Spate rotunjit, brațe întinse',
              'Să te răsucești cu trunchiul având sarcina în brațe',
              'Să iei avânt și să ridici brusc',
              'Să cari turnuri care îți iau vederea asupra drumului',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Împiedicare, alunecare, cădere pe drum',
        blocks: [
          ParagraphBlock(
            'Împiedicarea, alunecarea și căderea sunt cea mai frecventă '
            'cauză de rănire în livrare — mai frecventă decât orice '
            'accident de circulație. Și aproape întotdeauna se întâmplă '
            'pe ultimii metri dintre vehicul și ușa de la intrare.',
          ),
          FactsBlock([
            FactItem('Nr. 1', 'cel mai frecvent tip de accident în '
                'livrare'),
            FactItem('ultimii 30 m', 'între vehicul și ușă — porțiunea '
                'cea mai periculoasă'),
          ]),
          BulletsBlock([
            'Poartă încălțăminte solidă, antiderapantă — în fiecare zi, '
                'și vara',
            'Pe polei fă pași mici și pune talpa întreagă pe sol',
            'Uită-te și la drum, nu doar la colet sau la telefon',
            'Noaptea folosește lanterna sau lumina telefonului pentru '
                'drum',
            'Reține locurile cunoscute cu risc de împiedicare de pe '
                'traseu',
          ]),
          RevealBlock(
            prompt: 'Studiu de caz: duci două colete unul peste altul la '
                'o ușă de intrare cu trei trepte. Care este aici '
                'problema reală?',
            answer: 'Nu îți vezi propriile picioare și muchiile '
                'treptelor. O scară fără vizibilitate asupra treptei '
                'este situația clasică de cădere — iar cu mâinile pline '
                'nu te poți nici ține de balustradă, nici amortiza '
                'căderea. Corect: transportă câte unul, ține stiva atât '
                'de joasă încât să vezi treptele sau folosește liza. Să '
                'mergi de două ori durează 40 de secunde.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ia în serios rănirile mici',
        blocks: [
          ParagraphBlock(
            'Un spate întins greșit sau o gleznă scrântită se '
            'înrăutățesc dacă mergi mai departe. Dintr-o bagatelă devine '
            'în câteva săptămâni o incapacitate reală — iar retroactiv '
            'legătura cu munca adesea nu mai poate fi dovedită.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Documentarea te protejează',
            text: 'Fiecare rănire trebuie trecută în registrul de prim '
                'ajutor (Verbandbuch) — și cea mică. La tratament '
                'medical după un accident de muncă mergi la medicul '
                'desemnat (Durchgangsarzt). Fără documentare, '
                'recunoașterea ulterioară ca accident de muncă este '
                'dificilă.',
          ),
          RevealBlock(
            prompt: 'De ce ar trebui să raportezi imediat disconforturile '
                'mici — chiar dacă poți lucra mai departe?',
            answer: 'În primul rând medical: o problemă de ligamente '
                'netratată se vindecă mai prost și revine. În al doilea '
                'rând juridic: doar ce este documentat contează mai '
                'târziu ca accident de muncă. În al treilea rând pentru '
                'toți: doar incidentele raportate arată unde în firmă '
                'trebuie îmbunătățită o treaptă, un mâner sau un flux. A '
                'raporta înseamnă putere, nu slăbiciune.',
          ),
          ChecklistBlock(
            title: 'Asta iau cu mine din modulul 7',
            items: [
              'Cobor cu spatele, cu fața spre vehicul',
              'Păstrez mereu trei puncte de contact (2 mâini + 1 '
                  'picior)',
              'Nu sar niciodată din cabină sau din compartimentul de '
                  'marfă',
              'Pun obiectele jos înainte să cobor',
              'Înainte de a deschide portiera mă uit peste umăr',
              'Ridic din picioare și nu mă răsucesc cu sarcina în '
                  'brațe',
              'Folosesc mijloace ajutătoare în loc de acte de eroism',
              'Raportez fiecare rănire, inclusiv pe cea mică',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M8
  SafetyChapterContent(
    id: 'm8',
    title: 'La ușa clientului: câini, oameni și mediu',
    summary: 'Acționează în siguranță la punctul de livrare — cu animale, '
        'cu oameni și cu mediul',
    asset: 'assets/academy/driving/m08_haustuer.svg',
    slides: [
      SafetySlide(
        title: 'Punctul de livrare: teren străin',
        blocks: [
          ParagraphBlock(
            'De îndată ce părăsești vehiculul, pășești pe un teren '
            'străin, pe care nu îl cunoști și pe care nimeni nu l-a '
            'asigurat pentru tine: drumuri necunoscute, dale desprinse, '
            'case de scări întunecate, animale și oameni în orice stare '
            'de spirit.',
          ),
          FactsBlock([
            FactItem('120+', 'proprietăți străine pe tură'),
            FactItem('30 m', 'drum pe jos în medie la fiecare oprire'),
            FactItem('0', 'dintre ele sunt pregătite pentru tine'),
          ]),
          ParagraphBlock(
            'De aceea, la punctul de livrare este valabilă aceeași '
            'atitudine de bază ca la volan: întâi privește, apoi '
            'acționează. Iar la îndoială: nu livra. Un colet care nu '
            'ajunge este o procedură — o rănire este o incapacitate.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Evaluează corect câinii',
        asset: 'assets/academy/driving/m08b_hund.svg',
        blocks: [
          ParagraphBlock(
            'Câinii se numără printre cele mai frecvente cauze de rănire '
            'la curieri. Din perspectiva câinelui ești un intrus care se '
            'mișcă repede, miroase străin și cară un obiect mare — '
            'reacția este apărare, nu răutate.',
          ),
          BulletsBlock([
            'Nu privi direct în ochi — pentru câine este o amenințare',
            'Nu fugi și nu ridica vocea, ci rămâi liniștit pe loc',
            'Întoarce-i câinelui partea laterală, nu fața',
            'Brațele liniștite pe lângă corp, fără mișcări bruște',
            'Coletul poate fi o barieră între tine și câine',
            'Retrage-te încet cu spatele, ținând câinele în raza vizuală',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Calmul este cel mai bun echipament al tău',
            text: 'Un câine reacționează la mișcare și la tonul vocii, '
                'nu la argumente. Încet, în liniște și lateral — asta '
                'este toată tehnica.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Când devine serios',
        blocks: [
          RevealBlock(
            prompt: 'Studiu de caz: la poarta grădinii stă un câine mare '
                'și latră. Poarta este doar împinsă, clientul a scris în '
                'instrucțiunile de livrare: „Câinele este blând." Ce '
                'faci?',
            answer: 'Nu intri pe proprietate. O instrucțiune de livrare '
                'nu este o aprobare de siguranță — clientul își cunoaște '
                'câinele în relația cu familia, nu în relația cu un '
                'bărbat străin cu un colet. Corect: retrage-te de la '
                'poartă, încearcă să suni la sonerie sau la telefon, nu '
                'livra coletul și documentează asta, iar observația '
                'trece în sistem, ca următorul coleg să fie avertizat. O '
                'mușcătură te costă săptămâni — coletul îl costă pe '
                'client o zi.',
          ),
          DoDontBlock(
            doTitle: 'Corect',
            dos: [
              'Înainte de a deschide poarta, fii atent la zgomote de '
                  'câine și la castroane',
              'La un câine liber nu intra deloc',
              'Lasă observații în sistem pentru colegi',
              'La mușcătură sau zgârietură: raportează imediat și mergi '
                  'la medic',
            ],
            dontTitle: 'Greșit',
            donts: [
              'Să mângâi sau să hrănești câinele',
              'Să treci pe lângă animal până la ușă',
              'Să fugi sau să lovești câinele cu coletul',
              'Să te bazezi pe „nu face nimic"',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Orice mușcătură de câine ajunge la medic',
            text: 'Și o mușcătură sau o zgârietură mică se poate '
                'infecta. Curăț-o imediat, mergi la medic, treci-o în '
                'registrul de prim ajutor și raportează — indiferent cât '
                'de inofensivă pare.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Drumuri sigure pe proprietate',
        asset: 'assets/academy/driving/m08c_stolperfallen.svg',
        blocks: [
          ParagraphBlock(
            'Drumul până la ușa de la intrare nu este un loc de muncă pe '
            'care l-a verificat cineva pentru tine. Folosește drumurile '
            'marcate și nu scurta peste gazon ud, dale desprinse sau '
            'taluzuri abrupte.',
          ),
          BulletsBlock([
            'Furtunuri de grădină, cabluri și spaliere pe sol',
            'Dale de trotuar desprinse sau lăsate',
            'Frunze ude, mușchi și alge pe drumurile umbrite',
            'Pietriș și criblură pe dale netede',
            'Scări neiluminate, fără balustradă',
            'Guri de pivniță, canale deschise și puțuri de lumină',
            'Jucării, biciclete și pubele în drum',
          ]),
          FactsBlock([
            FactItem('ultimii 30 m', 'aici se produc cele mai multe '
                'căderi'),
            FactItem('1 mână', 'ar trebui să rămână liberă pentru '
                'balustradă'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Scurtătura costă mai mult decât economisește',
            text: 'Drumul peste gazon economisește zece secunde. O '
                'cădere pe el costă în medie 24 de zile de incapacitate.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Scări, pivnițe și întuneric',
        blocks: [
          ParagraphBlock(
            'În casele de scări și în curțile interioare se adună două '
            'lucruri: lumină slabă și înălțimi necunoscute ale '
            'treptelor. Ambele împreună formează cea mai frecventă '
            'situație de cădere în afara vehiculului.',
          ),
          BulletsBlock([
            'Ține mereu o mână liberă pentru balustradă',
            'Aprinde lumina, în loc de „merge și așa"',
            'Folosește lanterna sau lumina telefonului — dar nu privi '
                'ecranul în timp ce mergi',
            'La scări ține stiva atât de joasă încât să vezi treptele',
            'Fii atent la înălțimile diferite ale treptelor în clădirile '
                'vechi',
          ]),
          RevealBlock(
            prompt: 'Trebuie să livrezi pe un coridor de pivniță '
                'întunecat. Întrerupătorul nu funcționează. Care este '
                'decizia corectă?',
            answer: 'Nu intra. Un coridor neiluminat, cu trepte '
                'necunoscute, guri de pivniță și obiecte depozitate nu '
                'este un loc în care intri cu un colet în mână — iar la '
                'nevoie nimeni nu știe că ești acolo. Corect: sună la '
                'client, predă într-un loc sigur sau nu livra coletul și '
                'documentează asta. Lumina telefonului nu înlocuiește '
                'iluminatul, pentru că îți ocupă o mână de care ai nevoie '
                'la balustradă.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Oameni: dezamorsează, nu învinge',
        blocks: [
          ParagraphBlock(
            'Pentru client tu ești fața unui întreg concern — și de aceea '
            'primești uneori o supărare care nu ți se adresează ție. Să '
            'rămâi prietenos, calm și profesionist nu este doar politicos, '
            'este cea mai eficientă măsură de siguranță a ta.',
          ),
          StepsBlock([
            'Voce calmă, ritm lent de vorbire, postură deschisă',
            'Ascultă și numește problema, în loc să contrazici imediat',
            'Rămâi la ce poți face tu — fără promisiuni în numele '
                'altora',
            'Păstrează distanța: cel puțin o lungime de braț, calea de '
                'retragere liberă',
            'Dacă escaladează: încheie discuția și întoarce-te la '
                'vehicul',
          ]),
          RevealBlock(
            prompt: 'Cineva ridică vocea, se apropie foarte mult de tine '
                'și îți blochează drumul spre vehicul. Ce este valabil?',
            answer: 'Siguranța ta este mai presus de orice livrare. Nu '
                'discuta, nu încerca să ai dreptate, nu provoca un '
                'contact fizic. Retrage-te, creează distanță, cere clar '
                'și cu voce tare distanță, iar în caz de urgență mergi '
                'într-un loc public și cheamă poliția. După aceea: '
                'raportează incidentul, ca oprirea să fie marcată pentru '
                'colegi. Niciun colet nu justifică o confruntare fizică.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Mașina ca loc sigur',
        blocks: [
          ParagraphBlock(
            'Vehiculul tău este unealtă, depozit și loc de retragere. '
            'Când îl părăsești, trebuie să stea în siguranță — iar dacă '
            'te simți amenințat, este locul în care te întorci.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 14 Abs. 2 StVO',
            text: 'Cine își părăsește vehiculul trebuie să ia măsurile '
                'necesare pentru a evita accidentele și perturbările de '
                'trafic și trebuie să îl asigure împotriva utilizării '
                'neautorizate.',
          ),
          DoDontBlock(
            doTitle: 'Parcat corect',
            dos: [
              'Motorul oprit, cheia luată, mașina încuiată',
              'În pantă trage ferm frâna de mână și virează roțile',
              'Avarii pornite la oprirea în spațiul de circulație',
              'Închide ușa compartimentului de marfă când ești în afara '
                  'razei vizuale',
            ],
            dontTitle: 'Riscant',
            donts: [
              'Motorul merge, ușa deschisă — „așa e mai rapid"',
              'Cheia în contact în timp ce ești la ușa clientului',
              'Să parchezi în pantă fără roțile virate',
              'Să lași compartimentul de marfă deschis în zone '
                  'aglomerate',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare la punctul de livrare',
        blocks: [
          ChecklistBlock(
            title: 'La fiecare oprire',
            items: [
              'Motorul oprit, cheia la mine, vehiculul încuiat',
              'Asigurat în pantă, roțile virate',
              'Înainte de a intra am fost atent la câini și la '
                  'observații',
              'Am folosit drumurile marcate, nu am scurtat',
              'O mână liberă pentru balustradă',
              'Stiva atât de joasă încât văd treptele',
              'Pe întuneric am asigurat lumină',
              'La agresiune: distanță, retragere, raportare',
              'La mușcătură, cădere sau incident la limită: raportat',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M9
  SafetyChapterContent(
    id: 'm9',
    title: 'Urgență și comportament după un accident',
    summary: 'Acționează calm, corect și sigur juridic în caz serios',
    asset: 'assets/academy/driving/m09_notfall.svg',
    slides: [
      SafetySlide(
        title: 'Asigură — anunță — ajută',
        blocks: [
          ParagraphBlock(
            'După un accident sau la o pană este valabilă mereu aceeași '
            'ordine: întâi securizează locul, apoi apelul de urgență, '
            'apoi primul ajutor. Această ordine nu este un formalism — ea '
            'previne al doilea accident, în care salvatorii înșiși devin '
            'victime.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Reține ordinea',
            text: 'Asigură → anunță → ajută. Cine aleargă imediat la '
                'rănit, fără să asigure locul, este călcat el însuși pe '
                'un drum județean sau pe autostradă.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 34 StVO — după un accident de circulație',
            text: 'Trebuie să oprești imediat, să asiguri traficul, la '
                'pagube minore să ieși din zona de pericol, să îi ajuți '
                'pe răniți și să permiți identificarea persoanei tale și '
                'a vehiculului tău.',
          ),
          ParagraphBlock(
            'Și foarte important: calmul. Primele zece secunde după '
            'impact decid următoarele zece minute. Respiră adânc o dată, '
            'apoi pe rând.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Primii cinci pași',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/acc01_absichern.svg',
              title: '1 · Pornește avariile',
              caption: 'Imediat după oprire pornește luminile de avarie '
                  '— sunt primul semnal pentru toți cei care vin din '
                  'spate. Pe întuneric lasă aprinse în plus și luminile '
                  'de poziție.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc02_warnweste.svg',
              title: '2 · Îmbracă vesta reflectorizantă',
              caption: 'Vesta o îmbraci înainte de a coborî — nu după. '
                  'De aceea stă la îndemână în cabină, nu în spate, în '
                  'compartimentul de marfă.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc03_dreieck.svg',
              title: '3 · Așază triunghiul reflectorizant',
              caption: 'Mergi în spatele parapetului sau pe marginea '
                  'drumului, în sens invers deplasării, și așază '
                  'triunghiul la o distanță suficientă — în localitate '
                  'cca. 50 m, în afara ei 100 m, pe autostradă '
                  '150–200 m.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc04_notruf.svg',
              title: '4 · Sună la 112',
              caption: 'Spune unde ești, ce s-a întâmplat, câți răniți '
                  'sunt și ce răniri vezi — și închide abia când '
                  'dispeceratul nu mai are întrebări.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc05_erstehilfe.svg',
              title: '5 · Acordă primul ajutor',
              caption: 'Vorbește cu victima, verifică respirația, '
                  'oprește sângerările, ține-o la cald și rămâi lângă '
                  'ea. Și măsurile simple ajută — a nu face nimic este '
                  'singura decizie greșită.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Avarii, vestă, triunghi',
        blocks: [
          TableBlock(
            headers: ['Zonă', 'Distanța triunghiului'],
            rows: [
              ['În localitate', 'cca. 50 m'],
              ['În afara localității', 'cca. 100 m'],
              ['Autostradă', 'cca. 150–200 m'],
              ['Înainte de creastă sau curbă', 'înaintea ei, nu după'],
            ],
          ),
          ParagraphBlock(
            'Decisivă nu este valoarea exactă în metri, ci faptul că '
            'traficul care vine din spate te vede din timp. Înaintea '
            'unei creste sau a unei curbe, triunghiul se pune înainte — '
            'altfel devine vizibil abia când este prea târziu.',
          ),
          FactsBlock([
            FactItem('1', 'vestă reflectorizantă este obligatorie în '
                'vehicul (§ 53a StVZO)'),
            FactItem('înainte', 'îmbracă vesta înainte de a coborî'),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Mergi în spatele parapetului',
            text: 'Pe autostradă și pe drumul județean nu mergi '
                'niciodată pe carosabil ca să pui triunghiul, ci în '
                'spatele parapetului sau pe acostament — în sens invers '
                'deplasării, ca să vezi traficul.',
          ),
          DoDontBlock(
            doTitle: 'Corect la locul accidentului',
            dos: [
              'Avariile imediat, vesta înainte de a coborî',
              'Mergi în spatele parapetului, în sens invers '
                  'deplasării',
              'Așază triunghiul înaintea unei creste sau curbe',
              'După asigurare, pune-te tu însuți la adăpost',
            ],
            dontTitle: 'Greșeli tipice',
            donts: [
              'Să cobori fără vestă și să te uiți „doar scurt"',
              'Să mergi pe carosabil până la triunghi',
              'Să rămâi între vehicule',
              'Să faci întâi fotografii, în loc să asiguri locul',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Culoarul de urgență',
        blocks: [
          ParagraphBlock(
            'Culoarul de urgență se formează de îndată ce traficul '
            'începe să stagneze — nu abia când se vede girofarul. Atunci '
            'este de obicei prea târziu, pentru că nimeni nu mai are '
            'loc.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 11 Abs. 2 StVO',
            text: 'Pe autostrăzi și pe drumurile din afara localității cu '
                'cel puțin două benzi pe sens, culoarul se formează '
                'întotdeauna între banda cea mai din stânga și banda '
                'imediat următoare spre dreapta — indiferent câte benzi '
                'există.',
          ),
          FactsBlock([
            FactItem('stânga + 1', 'așa se formează culoarul'),
            FactItem('de la 200 €', 'amendă dacă nu se formează culoar'),
            FactItem('2 puncte', 'plus de regulă 1 lună suspendare'),
          ]),
          RevealBlock(
            prompt: 'Pe o autostradă cu trei benzi traficul este oprit. '
                'Unde este exact culoarul de urgență — și ai voie să '
                'circuli pe el, dacă tocmai vrei să ieși?',
            answer: 'Întotdeauna între banda din stânga și banda din '
                'mijloc — niciodată între mijloc și dreapta și niciodată '
                'pe banda de urgență. Și nu: culoarul de urgență este '
                'exclusiv pentru vehiculele de intervenție. Cine îl '
                'folosește ca să ajungă mai repede la ieșire plătește o '
                'amendă la fel de mare ca acela care nu formează deloc '
                'culoar și riscă suspendarea. Banda de urgență nu este o '
                'alternativă — pe ea circulă echipajele de salvare, dacă '
                'culoarul este blocat.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Apelul la 112 făcut corect',
        blocks: [
          FactsBlock([
            FactItem('112', 'apel de urgență în toată Europa, și fără '
                'credit'),
            FactItem('110', 'poliția — la pagube doar materiale'),
          ]),
          StepsBlock([
            'Unde s-a întâmplat? — localitate, stradă, kilometru, sens '
                'de mers, puncte de reper',
            'Ce s-a întâmplat? — tipul accidentului, vehicule '
                'implicate, pericole precum carburant scurs',
            'Câți răniți sunt?',
            'Ce răniri? — inconștient, sângerare, încarcerat',
            'Așteaptă întrebările — dispeceratul încheie convorbirea',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Acordarea ajutorului este obligatorie',
            text: 'Neacordarea ajutorului este infracțiune (§ 323c '
                'StGB). Se așteaptă de la tine ceea ce îți este '
                'rezonabil — să suni la urgențe, să asiguri locul, să '
                'vorbești cu victima, să o supraveghezi. Nimeni nu îți '
                'cere să te pui pe tine în pericol.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Primul ajutor: lucrurile care contează',
        blocks: [
          ParagraphBlock(
            'Nu trebuie să fii paramedic. Măsurile decisive le poate face '
            'oricine — și ele sunt cele care decid între viață și moarte, '
            'înainte ca ambulanța să ajungă.',
          ),
          StepsBlock([
            'Vorbește cu victima și scutur-o ușor de umăr — reacționează '
                'persoana?',
            'Fără reacție: eliberează căile respiratorii, extinde capul, '
                'verifică respirația 10 secunde',
            'Respirație normală: poziție laterală de siguranță, '
                'acoperire, rămâi lângă ea',
            'Fără respirație normală: începe imediat masajul cardiac și '
                'nu te opri',
            'Sângerare puternică: apasă direct, aplică un pansament '
                'compresiv',
          ]),
          FactsBlock([
            FactItem('100–120', 'compresii pe minut'),
            FactItem('5–6 cm', 'adâncimea compresiei la adult'),
            FactItem('10 s', 'sunt suficiente pentru controlul '
                'respirației'),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Casca și persoanele încarcerate',
            text: 'O cască de motociclist o scoți doar dacă persoana nu '
                'respiră normal — atunci nu există altă cale. Persoanele '
                'încarcerate nu le miști, cu excepția cazului în care '
                'există pericol imediat de incendiu.',
          ),
        ],
      ),
      SafetySlide(
        title: 'După o avarie de tablă',
        blocks: [
          ParagraphBlock(
            'Și la pagube mici — o lovitură la manevră, o oglindă ruptă, '
            'o zgârietură pe o mașină parcată — se aplică programul '
            'complet. Paguba se raportează întotdeauna, chiar dacă pare '
            'mică și nimeni nu a văzut.',
          ),
          ChecklistBlock(
            title: 'După o avarie de tablă',
            items: [
              'Oprește și asigură vehiculul',
              'Avarii, la nevoie vestă și triunghi',
              'Schimbă datele, respectiv așteaptă proprietarul',
              'Fotografii din mai multe unghiuri, loc, oră, număr de '
                  'înmatriculare',
              'Notează martorii și datele lor de contact',
              'Nu semna nicio recunoaștere a vinovăției',
              'Raportează paguba în firmă — chiar în aceeași zi',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Nu pleca niciodată pur și simplu',
            text: 'Cine se îndepărtează de locul accidentului fără a '
                'permite identificarea persoanei sale comite părăsirea '
                'nepermisă a locului accidentului (§ 142 StGB) — o '
                'infracțiune cu amendă penală sau închisoare, chiar și '
                'la o lovitură mică.',
          ),
          RevealBlock(
            prompt: 'Studiu de caz: la manevră atingi oglinda exterioară '
                'a unei mașini parcate. Nu este nimeni acolo. Ajunge un '
                'bilețel sub ștergător?',
            answer: 'Nu. Un bilețel nu contează juridic ca identificare '
                'suficientă — poate zbura, se poate uda sau poate fi '
                'îndepărtat. Corect este: să aștepți un timp rezonabil la '
                'locul accidentului (în funcție de situație se ia ca '
                'reper aproximativ 30 de minute) și, dacă nu vine '
                'nimeni, să informezi poliția și să raportezi paguba '
                'acolo. Un bilețel în plus este o practică bună, dar nu '
                'înlocuiește nici așteptarea, nici raportarea.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Păstrează calmul, raportează, învață',
        blocks: [
          ParagraphBlock(
            'Respiră adânc, ordonează situația, informează dispecerul și '
            'firma. O raportare onestă și rapidă este întotdeauna mai '
            'bună decât mușamalizarea — te protejează pe tine, protejează '
            'firma, iar din fiecare incident învățăm pentru tura '
            'următoare.',
          ),
          ChecklistBlock(
            title: 'Asta iau cu mine din modulul 9',
            items: [
              'Cunosc ordinea: asigură, anunță, ajută',
              'Îmbrac vesta reflectorizantă înainte de a coborî',
              'Așez triunghiul la o distanță suficientă',
              'Formez culoarul de urgență între banda din stânga și cea '
                  'de lângă ea, de îndată ce traficul stagnează',
              'Cunosc cele cinci informații de la apelul 112',
              'Știu că a nu face nimic este singura decizie greșită',
              'Raportez orice pagubă în aceeași zi — inclusiv mica '
                  'lovitură',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M10
  SafetyChapterContent(
    id: 'm10',
    title: 'Recapitulare și angajament personal',
    summary: 'Fixează ce ai învățat și transformă-l într-o atitudine '
        'personală',
    asset: 'assets/academy/driving/m10_selbstverpflichtung.svg',
    slides: [
      SafetySlide(
        title: 'Cele 7 reguli de bază ale tale',
        blocks: [
          BulletsBlock([
            'Gândirea anticipativă bate reacția rapidă',
            'Distanța și viteza adaptată îți dau mereu o rezervă',
            'La mersul înapoi: coboară, uită-te, încet (GOAL)',
            'Telefonul și distragerea doar din staționare, cu motorul '
                'oprit',
            'Ia în serios oboseala și presiunea timpului — siguranța '
                'înaintea planului',
            'Coboară, ridică și mergi corect — corpul tău este unealta '
                'ta',
            'În caz de urgență: asigură, anunță, ajută',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Dacă iei cu tine o singură regulă',
            text: 'Ia-ți timpul de care ai nevoie. Aproape orice '
                'accident din livrare apare în momentul în care cineva a '
                'vrut să economisească două secunde.',
          ),
          DoDontBlock(
            doTitle: 'Așa arată o zi sigură',
            dos: [
              'Turul de verificare, încărcătura asigurată, centura pusă',
              'Două secunde distanță, privirea departe în față',
              'Înainte de fiecare manevră cu spatele coboară și uită-te',
              'Telefonul în suport, pauză la oboseală',
              'Coborâre cu spatele, cu trei puncte de contact',
            ],
            dontTitle: 'Cele mai scumpe cinci scurtături',
            donts: [
              'Să sari turul de verificare „doar azi"',
              'Să nu reasiguri încărcătura după reîncărcare',
              'Să te uiți scurt pe ecran, pentru că drumul este liber',
              'Să sari din compartimentul de marfă, pentru că este mai '
                  'rapid',
              'Să nu raportezi o avarie de manevră',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Cifrele care ar trebui să îți rămână',
        blocks: [
          FactsBlock([
            FactItem('2 s', 'distanța minimă'),
            FactItem('2 + 1', 'puncte de contact la coborâre'),
            FactItem('112', 'apel de urgență la răniți'),
          ]),
          TableBlock(
            headers: ['Cifră', 'Semnificație'],
            rows: [
              ['2 secunde', 'distanța minimă, pe umed 3+'],
              ['18 / 40 m', 'distanța de oprire la 30 / 50 km/h'],
              ['28 m', 'condus în orb la 2 s privire pe telefon și '
                  'viteza 50'],
              ['89 m', 'ațipire de 4 s la viteza de 80'],
              ['0,8 g', 'forța de asigurare spre față pentru '
                  'încărcătură'],
              ['2 + 1', 'puncte de contact la urcare și coborâre'],
              ['70 %', 'dintre avarii apar la manevre'],
              ['112', 'apel de urgență la răniți'],
            ],
          ),
          ParagraphBlock(
            'Aceste opt cifre sunt nucleul dur al trainingului. Cine le '
            'are în minte ia decizia corectă și atunci când nu este timp '
            'de gândit.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Autoevaluarea ta personală',
        asset: 'assets/academy/driving/m10b_selbstcheck.svg',
        blocks: [
          ParagraphBlock(
            'Parcurge o dată onest această listă — nu pentru firmă, ci '
            'pentru tine. Fiecare bifă nepusă este un lucru concret pe '
            'care îl poți schimba mâine.',
          ),
          ChecklistBlock(
            title: 'Autoevaluarea mea de siguranță',
            items: [
              'Fac turul de verificare în fiecare dimineață, chiar și '
                  'când mă grăbesc',
              'Reasigur încărcătura când compartimentul se golește',
              'Păstrez două secunde distanță și verific asta la un punct '
                  'fix',
              'Înainte de fiecare manevră cu spatele cobor și mă uit',
              'Nu îmi ating telefonul în timpul mersului',
              'Opresc atunci când obosesc',
              'Cobor întotdeauna cu spatele, cu trei puncte de contact',
              'Ridic din picioare și folosesc mijloace ajutătoare',
              'Raportez pagubele, incidentele la limită și rănirile',
              'Spun când un plan nu poate fi realizat în siguranță',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Studiu de caz: ziua în care se adună totul',
        blocks: [
          RevealBlock(
            prompt: 'Studiu de caz: vineri, ploaie, 190 de opriri. '
                'Pornești cu 25 de minute întârziere, compartimentul de '
                'marfă nu a fost sortat de tura de noapte, telefonul îți '
                'sună permanent, iar la ora 16 observi că nu ai mâncat '
                'nimic de la micul dejun. Care este acum ordinea '
                'corectă?',
            answer: 'Oprește și sortează mai întâi compartimentul de '
                'marfă — asta recuperezi într-un sfert de oră și îți '
                'economisești 190 de căutări. Apoi: telefonul pe '
                'silențios, în suport, apelurile la următoarea pauză. '
                'Apoi zece minute de mâncat și băut, pentru că de acum '
                'atenția ta scade altfel din oră în oră. Și apoi o '
                'raportare onestă către dispecerat, că planul de azi nu '
                'iese complet. Ce nu faci: să vrei să recuperezi timpul '
                'pe drum, să renunți la pauze, să scurtezi manevrele. '
                'Ziua nu mai poate fi salvată — spatele tău, permisul '
                'tău și vehiculul tău, în schimb, da.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Adevăratul examen',
            text: 'Să conducă în siguranță într-o zi bună poate oricine. '
                'Diferența se vede în ziua în care totul merge prost în '
                'același timp.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Angajamentul tău',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Promisiunea ta',
            text: '„Conduc astfel încât toți să ajungă acasă în '
                'siguranță — inclusiv eu."',
          ),
          ParagraphBlock(
            'Siguranța nu este un regulament, ci decizia ta zilnică. '
            'Nimeni nu stă lângă tine când decizi dimineața la ora șase '
            'dacă faci turul de verificare, sau când decizi seara la ora '
            'șapte dacă mai cobori o dată înainte de a da înapoi. Tocmai '
            'asta face aceste decizii atât de importante.',
          ),
          ChecklistBlock(
            title: 'Mă angajez',
            items: [
              'Respect regulile și atunci când nu se uită nimeni',
              'Îmi iau secundele pe care le costă siguranța',
              'Raportez onest, în loc să mușamalizez',
              'Îi ajut pe colegii noi să facă lucrurile corect de la '
                  'început',
              'Ajung acasă sănătos în fiecare seară',
            ],
          ),
        ],
      ),
    ],
  ),
];
