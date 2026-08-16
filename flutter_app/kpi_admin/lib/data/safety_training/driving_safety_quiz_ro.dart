// lib/data/safety_training/driving_safety_quiz_ro.dart
//
// Intrebarile trainingului DSP de siguranta rutiera — versiunea romana.
// Structura este identica cu versiunea germana (master): acelasi numar de
// intrebari, aceeasi ordine, aceleasi raspunsuri corecte.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> drivingQuestionsRo = [
  // ══════════════════════════════════ M1 — Cultura siguranței
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Ai 20 de opriri întârziere față de plan. Care reacție '
        'corespunde culturii siguranței din firmă?',
    options: [
      'Să mergi mai repede între opriri, dar să rămâi atent la opririle '
          'propriu-zise',
      'Să raportezi întârzierea și să continui tura în ritmul sigur '
          'obișnuit',
      'Să scurtezi timpii de verificare la manevre, dar să lași stilul '
          'de condus neschimbat',
    ],
    correctIndex: 1,
    explanation: 'Presiunea timpului este o problemă de planificare și se '
        'raportează, nu se compensează la volan. Celelalte două '
        'răspunsuri sună a compromis, dar doar mută riscul: viteza mai '
        'mare între opriri lungește exact distanța de oprire, iar '
        'verificările scurtate la manevre lovesc tocmai activitatea la '
        'care apar 70 % din toate avariile.',
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Dispecerul tău îți dă dispoziție să pleci cu o lampă de '
        'frână defectă. Cine poartă răspunderea dacă din această cauză '
        'se produce o tamponare?',
    options: [
      'Dispecerul, pentru că el a dat dispoziția',
      'Firma, pentru că ea pune la dispoziție vehiculul',
      'Nimeni — o singură lampă de frână nu este un defect relevant '
          'pentru siguranță',
      'Tu, în calitate de conducător auto',
    ],
    correctIndex: 3,
    explanation: 'În calitate de conducător auto răspunzi pentru starea '
        'de siguranță rutieră a vehiculului pe care îl conduci — o '
        'dispoziție verbală nu anulează asta. Faptul că firma pune '
        'vehiculul sună plauzibil, dar nu te scutește: amenda și '
        'punctele te lovesc pe tine personal. Corect este să raportezi '
        'defectul și să ceri alt vehicul.',
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'La manevre au lipsit doar câțiva centimetri până la un '
        'stâlp — nu s-a întâmplat nimic. Ce este corect?',
    options: [
      'Să raportezi ca incident la limită',
      'Să nu faci nimic, doar nu s-a produs nicio pagubă și nimeni nu a '
          'fost pus în pericol',
      'Să raportezi doar dacă a observat un coleg sau o cameră',
    ],
    correctIndex: 0,
    explanation: 'Un incident la limită arată un loc periculos înainte ca '
        'el să lovească pe cineva — raportat, este dezamorsat pentru '
        'următorul coleg. Ideea „fără pagubă, fără subiect" este cel mai '
        'frecvent motiv pentru care același loc duce totuși la o pagubă '
        'câteva săptămâni mai târziu.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'La ce activitate apar aproximativ 70 % din toate avariile '
        'la autoutilitare?',
    options: [
      'Pe autostradă și pe drumul județean, la viteză mare',
      'La viraje în intersecții, în traficul urban',
      'La manevre și la mersul înapoi',
    ],
    correctIndex: 2,
    explanation: 'Marea majoritate a avariilor apar în ritm de pas, la '
        'manevre. Viteza mare provoacă cele mai grave accidente, dar nu '
        'cele mai multe avarii — tocmai această confuzie duce la faptul '
        'că la manevre se acordă prea puțină atenție.',
  ),

  // ══════════════════════════════════ M2 — Verificare și încărcătură
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Încărcătura trebuie asigurată conform regulilor tehnice '
        'recunoscute împotriva a 0,8 g spre față. Cărei forțe de '
        'reținere îi corespunde asta aproximativ la un colet de 20 kg?',
    options: [
      'circa 2 kg',
      'circa 8 kg',
      'circa 16 kg',
      'circa 200 kg',
    ],
    correctIndex: 2,
    explanation: '0,8 × 20 kg dă aproximativ 16 kg forță de reținere. '
        '„Circa 2 kg" subestimează dramatic forța și este motivul pentru '
        'care coletele sunt considerate inofensive; „200 kg" confundă '
        'cerința de asigurare cu forța de impact la o coliziune reală, '
        'care este de fapt chiar mult mai mare.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Cum încarci corect compartimentul de marfă?',
    options: [
      'Greu jos și în față, la peretele despărțitor, greutatea '
          'distribuită uniform',
      'Greu sus, ca la apucat coletele grele să nu stea sub cele '
          'ușoare',
      'Greu în spate, la ușă, ca trimiterile grele să iasă primele',
    ],
    correctIndex: 0,
    explanation: 'Greu + jos + în față menține centrul de greutate '
        'coborât și masa acolo unde peretele despărțitor o poate '
        'prelua. Celelalte două variante sunt gândite după fluxul de '
        'lucru, nu după fizică: greutatea sus crește tendința de '
        'răsturnare, greutatea în spate descarcă puntea față și '
        'înrăutățește direcția.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'După două treimi din tură, compartimentul de marfă este '
        'pe jumătate gol. Ce este valabil acum pentru asigurarea '
        'încărcăturii?',
    options: [
      'Este mai puțin importantă, pentru că la bord este considerabil '
          'mai puțină greutate',
      'Trebuie refăcută — coletele rămase au acum mai mult drum ca să '
          'prindă viteză',
      'Rămâne valabilă neschimbată, nu este nimic de făcut',
    ],
    correctIndex: 1,
    explanation: 'Cu cât compartimentul este mai gol, cu atât este mai '
        'mare porțiunea pe care un colet poate accelera înainte de a se '
        'izbi. „Mai puțină greutate, mai puțin pericol" sună logic, dar '
        'este greșit: decisivă nu este masa totală, ci coletul '
        'neasigurat luat individual.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Ce cere DGUV Vorschrift 70 (Fahrzeuge) de la tine înainte '
        'de începerea turei de lucru?',
    options: [
      'O verificare tehnică cu elevator și stand de frânare',
      'O verificare a vehiculului pentru defecte evidente',
      'O verificare doar la vehiculele pe care le conduci pentru prima '
          'dată',
    ],
    correctIndex: 1,
    explanation: 'Se cere verificarea defectelor vizibile înainte de '
        'tură — exact ceea ce oferă turul de verificare. Verificarea '
        'tehnică este treaba service-ului și nu îți înlocuiește turul; '
        'iar obligația este valabilă pentru fiecare vehicul în fiecare '
        'zi, nu doar pentru cele necunoscute.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Ce adâncime minimă a profilului prevede legea — și ce '
        'este rezonabil pe carosabil ud?',
    options: [
      '3 mm legal; pe umed ajung atunci 1,6 mm',
      '1,6 mm legal; asta ajunge neschimbat și pe umed',
      '4 mm legal, tot anul, pentru toate anvelopele',
      '1,6 mm legal; pe umed sunt rezonabili cel puțin 3 mm',
    ],
    correctIndex: 3,
    explanation: 'Minimul legal este 1,6 mm, practic rezonabil pe umed '
        'este cel puțin 3 mm. Răspunsul „1,6 mm ajung și pe umed" este '
        'eroarea clasică: minimul este limita spre contravenție, nu '
        'limita spre siguranță — la 1,6 mm anvelopa aproape că nu mai '
        'deplasează apă.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Coletul următoarei opriri stă pe scaunul din dreapta, ca '
        'să îl poți apuca repede. Care este principala problemă?',
    options: [
      'Coletul devine proiectil la o frânare și poate ajunge sub pedala '
          'de frână',
      'La un control în trafic arată dezordonat',
      'Este permis, atâta timp cât coletul cântărește mai puțin de 10 '
          'kg',
    ],
    correctIndex: 0,
    explanation: 'Tot ce se află în cabină se mișcă mai departe la o '
        'frânare cu viteza ta inițială — în cel mai rău caz în zona '
        'picioarelor, sub pedală. Nu există o limită de greutate pentru '
        'asta: și un colet ușor blochează o pedală.',
  ),

  // ══════════════════════════════════ M3 — Conducere defensivă
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Mergi în afara localității cu 80 km/h pe carosabil uscat. '
        'Ce distanță față de cel din față este corectă cel puțin?',
    options: [
      'Cam 20 de metri — asta corespunde la trei lungimi de vehicul',
      'Cam 45 de metri — aproximativ două secunde, respectiv jumătate '
          'din valoarea vitezometrului',
      'Cam 10 metri, atâta timp cât ești atent și drumul este liber',
    ],
    correctIndex: 1,
    explanation: 'Două secunde înseamnă la 80 km/h aproximativ 45 de '
        'metri, jumătate din valoarea vitezometrului 40 de metri — '
        'ambele se potrivesc. 20 de metri par mult pe drum, dar sunt sub '
        'simpla distanță de reacție de 24 de metri: ai fi intrat în cel '
        'din față înainte ca frâna să apuce.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Cât de lungă este distanța de oprire la 50 km/h conform '
        'formulelor practice (frânare normală)?',
    options: [
      '15 metri',
      '25 metri',
      '40 metri',
      '65 metri',
    ],
    correctIndex: 2,
    explanation: 'Distanța de reacție (50 ÷ 10) × 3 = 15 m plus distanța '
        'de frânare (50 ÷ 10)² = 25 m dau 40 m. Cine spune 25 de metri a '
        'calculat doar distanța de frânare și a uitat distanța de '
        'reacție — este cea mai frecventă greșeală de calcul și exact '
        'porțiunea pe care o parcurgi la viteză maximă.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Cum calculezi distanța de reacție după formula practică?',
    options: [
      '(viteza ÷ 10) × 3',
      '(viteza ÷ 10) × (viteza ÷ 10)',
      'viteza ÷ 2',
    ],
    correctIndex: 0,
    explanation: 'Distanța de reacție este (km/h ÷ 10) × 3. A doua '
        'formulă este distanța de frânare, a treia valoarea practică '
        'pentru distanța de siguranță — ambele arată asemănător, dar '
        'descriu ceva complet diferit.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Îți dublezi viteza de la 30 la 60 km/h. Cum se modifică '
        'distanța de frânare propriu-zisă?',
    options: [
      'Se dublează',
      'Se împătrește',
      'Se triplează',
      'Rămâne aproape la fel, pentru că frâna apucă mai puternic la '
          'viteză mai mare',
    ],
    correctIndex: 1,
    explanation: 'Distanța de frânare crește cu pătratul vitezei: din 9 '
        'metri devin 36 de metri. Răspunsul plauzibil „se dublează" '
        'subestimează exact asta — el explică de ce 20 km/h în plus pe o '
        'stradă din cartier sunt percepuți ca inofensivi.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'De ce trebuie să mergi cu autoutilitara complet încărcată '
        'considerabil mai încet în curbe decât cu un autoturism?',
    options: [
      'Pentru că centrul de greutate ridicat crește puternic tendința '
          'de răsturnare',
      'Pentru că direcția devine mai imprecisă la încărcătură',
      'Pentru că anvelopele devin mai moi sub sarcină și au mai multă '
          'aderență',
    ],
    correctIndex: 0,
    explanation: 'O dubă încărcată sus se răstoarnă acolo unde un '
        'autoturism încă alunecă — și abia dacă anunță asta. Precizia '
        'direcției se schimbă și ea, dar nu acesta este riscul real: '
        'răsturnarea se produce brusc și se termină în afara '
        'carosabilului.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Vrei să virezi la dreapta la un semafor, un biciclist '
        'stă în dreapta lângă tine. Semaforul se face verde. Ce faci mai '
        'întâi?',
    options: [
      'Pornești rapid și virezi înainte ca biciclistul să prindă viteză',
      'Te uiți în oglinda exterioară dreaptă și apoi virezi',
      'Privire peste umăr la dreapta și îl lași pe biciclist să treacă',
    ],
    correctIndex: 2,
    explanation: 'De îndată ce pornești și virezi, biciclistul intră în '
        'unghiul mort — iar spatele tău se deplasează în plus în banda '
        'lui. Privirea în oglindă sună corect, dar nu mai ajunge exact '
        'atunci când contează: oglinda nu arată complet zona din dreapta '
        'lângă cabină.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Ce distanță laterală minimă trebuie să păstrezi în '
        'localitate la depășirea unui biciclist?',
    options: [
      '1,0 metri',
      '1,5 metri',
      '2,0 metri',
    ],
    correctIndex: 1,
    explanation: 'În localitate sunt 1,5 metri, în afara ei 2,0 metri. '
        'Cine consideră 2,0 metri valoarea din localitate le confundă pe '
        'amândouă — iar cine depășește la 1,0 metru încalcă distanța '
        'minimă și răspunde dacă biciclistul cade.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Cât de departe în față ar trebui să îți fie îndreptată '
        'privirea în timpul condusului?',
    options: [
      'Spre bara celui din față, ca să îi vezi imediat frânarea',
      'Spre propriul capotă, pentru că astfel ții cel mai precis banda',
      'Cu 12–15 secunde înainte',
    ],
    correctIndex: 2,
    explanation: 'Privirea departe îți dă timp: vezi semafoarele, '
        'luminile de frână și pietonii înainte să fii nevoit să '
        'reacționezi. Privirea la bară pare atentă, dar te transformă '
        'într-un simplu reactiv — afli de pericol abia când cel din față '
        'deja frânează.',
  ),

  // ══════════════════════════════════ M4 — Mers înapoi și manevre
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Ce înseamnă GOAL la mersul înapoi?',
    options: [
      '„Get Out And Look" — oprește, coboară, uită-te în spatele '
          'vehiculului',
      '„Go Only At Low speed" — să dai înapoi exclusiv în ritm de pas',
      '„Guide On A Line" — să te orientezi după un marcaj de pe sol',
    ],
    correctIndex: 0,
    explanation: 'GOAL înseamnă să cobori și să te uiți — scoate la '
        'iveală stâlpi joși, pantă și copii pe care de pe scaun nu îi '
        'vezi niciodată. Ritmul de pas este de asemenea obligatoriu, dar '
        'nu înlocuiește verificarea: și în ritm de pas intri într-o zonă '
        'pe care nu o poți vedea.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Vehiculul tău are o cameră de mers înapoi. Ce schimbă '
        'asta la GOAL?',
    options: [
      'GOAL nu mai este necesar, pentru că camera arată zona din '
          'spatele vehiculului',
      'Nimic',
      'GOAL mai este necesar doar pe întuneric și la vizibilitate '
          'redusă',
    ],
    correctIndex: 1,
    explanation: 'Camera arată doar un decupaj, deformează distanțele și '
        'orbește din cauza ploii, a zăpezii și a murdăriei — mai ales nu '
        'vede ce intră lateral în traiectoria ta. Ea completează GOAL, '
        'nu îl înlocuiește niciodată.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Unde stă corect un dirijor?',
    options: [
      'Direct în spatele vehiculului, pentru că de acolo poate aprecia '
          'cel mai bine distanța',
      'În fața vehiculului, ca să oprească în același timp traficul',
      'Lateral, astfel încât să îl vezi permanent în oglindă',
    ],
    correctIndex: 2,
    explanation: 'Doar cine stă lateral și rămâne permanent vizibil poate '
        'dirija în siguranță. Poziția direct în spatele vehiculului pare '
        'cea mai apropiată de acțiune, dar este exact zona în care '
        'dirijorul însuși este călcat, de îndată ce îl pierzi din '
        'vedere.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Dintr-odată nu îți mai vezi dirijorul în oglindă. Ce '
        'faci?',
    options: [
      'Continui mai încet, până când reapare',
      'Oprești imediat',
      'Claxonezi scurt și continui, ca să se arate din nou',
    ],
    correctIndex: 1,
    explanation: 'Lipsa contactului vizual înseamnă lipsa unui semn '
        'valabil — deci oprești, nu doar încetinești. „Continui mai '
        'încet" sună prudent, dar înseamnă că intri în continuare '
        'într-o zonă pe care nimeni nu o mai supraveghează pentru tine.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Ce cere § 9 Abs. 5 StVO la mersul înapoi?',
    options: [
      'Să pornești luminile de avarie',
      'Să mergi cel mult în ritm de pas',
      'Să excluzi punerea în pericol a altora — la nevoie cu un '
          'dirijor',
    ],
    correctIndex: 2,
    explanation: 'Prescripția cere excluderea oricărei puneri în pericol, '
        'la nevoie printr-un dirijor — criteriul este deci rezultatul, '
        'nu o anumită viteză. Ritmul de pas și luminile de avarie sunt o '
        'practică bună, dar singure nu îndeplinesc obligația.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Ultima oprire este într-o curte interioară îngustă: cu '
        'fața intri, afară ieși doar cu spatele, pe lângă un zid. Care '
        'este decizia cea mai sigură?',
    options: [
      'Să oprești pe stradă și să faci ultimii metri pe jos, respectiv '
          'cu liza',
      'Să intri cu fața, pentru că apoi cunoști deja intrarea pentru '
          'drumul de întoarcere',
      'Să intri rapid cu spatele, cât timp strada este încă liberă',
    ],
    correctIndex: 0,
    explanation: 'Cel mai sigur mers înapoi este cel care nu are loc '
        'deloc. Faptul că „după ce ai intrat cunoști" intrarea este o '
        'iluzie: la ieșire punctele critice sunt în spatele tău, iar '
        'traficul care așteaptă creează în plus presiune.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M5 — Vreme și vizibilitate
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Direcția devine brusc ușoară, anvelopele plutesc pe o '
        'peliculă de apă. Ce faci?',
    options: [
      'Frânezi puternic și contravirezi',
      'Iei piciorul de pe accelerație, ții volanul calm și drept, lași '
          'mașina să ruleze liber',
      'Accelerezi, ca să părăsești repede porțiunea cu apă',
    ],
    correctIndex: 1,
    explanation: 'Cât timp pelicula de apă susține, frâna și direcția nu '
        'acționează — ele acționează brusc abia când anvelopa prinde din '
        'nou, și exact de aici apare derapajul. Frânarea și contravirarea '
        'sunt reacția intuitivă, dar greșită.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'De ce depinde cel mai mult pericolul de acvaplanare?',
    options: [
      'De greutatea încărcăturii',
      'De vechimea vehiculului și a sistemului de frânare',
      'De adâncimea profilului, de înălțimea apei și mai ales de '
          'viteză',
    ],
    correctIndex: 2,
    explanation: 'Pericolul crește disproporționat cu viteza și scade cu '
        'adâncimea profilului — profilul trebuie să evacueze apa din '
        'fața anvelopei. Încărcătura joacă un rol secundar: mai multă '
        'greutate apasă anvelopa mai tare pe drum, dar nu schimbă faptul '
        'că un profil plat nu mai deplasează apă la viteză.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'În ceață mai vezi aproximativ 40 de metri. Cu ce viteză '
        'ai voie să mergi cel mult?',
    options: [
      'Cel mult 40 km/h',
      'Până la viteza maximă permisă, cât timp luminile sunt aprinse',
      'Cel mult 80 km/h, dacă lampa de ceață spate este pornită',
    ],
    correctIndex: 0,
    explanation: 'Regulă practică: vizibilitatea în metri este limita ta '
        'superioară în km/h — la 40 de metri vizibilitate deci 40 km/h. '
        'Luminile și lampa de ceață spate te fac mai vizibil, dar nu îți '
        'lungesc vizibilitatea și, deci, nici viteza permisă.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Când prevede § 2 Abs. 3a StVO anvelope adecvate iernii?',
    options: [
      'Mereu în perioada octombrie–Paște, indiferent de vreme',
      'Pe polei, zăpadă bătătorită, piatră de zăpadă, gheață sau '
          'chiciură',
      'Doar dacă pe carosabil este un strat continuu de zăpadă',
    ],
    correctIndex: 1,
    explanation: 'În Germania este valabilă o obligație situațională: ea '
        'depinde de starea drumului, nu de calendar. „Octombrie–Paște" '
        'este doar o regulă practică pentru schimbarea anvelopelor și nu '
        'un temei legal — iar piatra de zăpadă ajunge deja, nu trebuie '
        'să fie un strat continuu.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Este ger și ești sub presiunea timpului. Cureți de gheață '
        'doar partea șoferului de pe parbriz. Ce este valabil?',
    options: [
      'Permis, atâta timp cât mergi considerabil mai încet',
      'Permis, dacă încălzirea eliberează restul în timpul mersului',
      'Nu este permis — toate geamurile, oglinzile, luminile și numărul '
          'de înmatriculare trebuie să fie libere',
    ],
    correctIndex: 2,
    explanation: '„Gaura de privit" curățată în gheață este o '
        'contravenție, iar la un accident o culpă gravă. Faptul că '
        'încălzirea rezolvă ulterior nu este o excepție: determinantă '
        'este starea la plecare, nu cea de trei minute mai târziu.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'De ce este o dubă GOALĂ deosebit de expusă pe furtună?',
    options: [
      'Pentru că îi lipsește greutatea încărcăturii, care o ține pe '
          'drum',
      'Pentru că rezistența la aer este mai mare fără încărcătură',
      'Pentru că presiunea în anvelope este mai mare în stare goală',
    ],
    correctIndex: 0,
    explanation: 'Suprafața de atac este la fel de mare goală ca și '
        'încărcată, dar masa este considerabil mai mică — aceeași rafală '
        'deplasează deci vehiculul mai puternic. Rezistența la aer nu se '
        'schimbă deloc din cauza încărcăturii din interior, aceasta este '
        'greșeala de raționament.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M6 — Distragere și oboseală
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Ai voie să iei telefonul în mână în timpul mersului, ca '
        'să schimbi muzica?',
    options: [
      'Da, dacă durează doar o secundă și drumul este liber',
      'Doar la semaforul roșu',
      'Nu',
    ],
    correctIndex: 2,
    explanation: 'Deja ridicarea sau ținerea dispozitivului constituie '
        'abaterea — indiferent pentru ce. Semaforul roșu nu este o '
        'excepție cât timp motorul merge. Muzica, destinația și volumul '
        'se setează înainte de plecare, din staționare.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Când ai voie juridic să iei telefonul sau scanerul în '
        'mână?',
    options: [
      'Doar dacă vehiculul staționează ȘI motorul este oprit',
      'De îndată ce vehiculul staționează — sistemul start-stop este '
          'suficient pentru asta',
      'Scurt în timpul mersului, dacă porțiunea este dreaptă și liberă',
    ],
    correctIndex: 0,
    explanation: 'Excepția se aplică doar la vehicul staționat cu motorul '
        'oprit. Sistemul start-stop nu contează în mod expres — tocmai pe '
        'asta se bazează mulți la semaforul roșu și acolo își încasează '
        'amenda.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Mergi cu 50 km/h și te uiți 2 secunde la ecran. Cât de '
        'departe mergi în acest timp fără să vezi drumul?',
    options: [
      'circa 8 metri',
      'circa 28 de metri',
      'circa 14 metri',
      'circa 50 de metri',
    ],
    correctIndex: 1,
    explanation: '50 km/h înseamnă aproximativ 14 metri pe secundă, deci '
        'în 2 secunde cam 28 de metri. Cine alege „14 metri" a calculat '
        'doar o secundă — o greșeală tipică, care face ca porțiunea '
        'parcursă în orb să pară înjumătățită.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Ațipești la viteza de 80 timp de 4 secunde. Ce distanță '
        'parcurgi necontrolat?',
    options: [
      'circa 30 de metri',
      'circa 50 de metri',
      'circa 90 de metri',
      'circa 160 de metri',
    ],
    correctIndex: 2,
    explanation: '80 km/h înseamnă aproximativ 22 de metri pe secundă, '
        'ori 4 dau cam 89 de metri. Spre deosebire de privirea pe '
        'telefon, în acest timp nu virezi deloc — vehiculul iese din '
        'bandă. De aceea este atât de periculoasă ideea unei ațipiri '
        '„scurte".',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Ce ajută cu adevărat împotriva oboselii acute la volan?',
    options: [
      'Să deschizi geamul și muzică tare',
      'Să bei cafea și să mergi mai repede, ca să termini mai devreme',
      'Să oprești, 15–20 de minute de somn scurt, apoi mișcare',
    ],
    correctIndex: 2,
    explanation: 'Doar somnul și mișcarea îți refac atenția. Aerul '
        'proaspăt și muzica tare acționează cel mult câteva minute și '
        'simulează în acest timp vigilența — exact în această fază omul '
        'se supraestimează cel mai mult.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'O cască intraauriculară pentru funcția hands-free, '
        'cealaltă ureche liberă — este asta în regulă în timpul '
        'mersului?',
    options: [
      'Da, o ureche liberă ajunge pentru trafic',
      'Da, atâta timp cât volumul este setat scăzut',
      'Nu',
    ],
    correctIndex: 2,
    explanation: 'Trebuie să poți localiza sigur claxoane, strigăte și '
        'vehicule de intervenție — și pentru asta ai nevoie de ambele '
        'urechi; la manevre auzul este adesea singurul avertisment. Un '
        'volum scăzut nu schimbă faptul că o ureche este ocupată.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Ce riști dacă pui în pericol un alt participant la trafic '
        'având telefonul în mână?',
    options: [
      '100 € și 1 punct',
      '150 €, 2 puncte și 1 lună suspendare a permisului',
      'Un avertisment verbal, fără înregistrare',
    ],
    correctIndex: 1,
    explanation: '100 € și 1 punct sunt fapta de bază fără punere în '
        'pericol; dacă se adaugă o punere în pericol, crește la 150 €, '
        '2 puncte și o lună de suspendare. Pentru tine, ca șofer '
        'profesionist, problema nu sunt banii, ci suspendarea.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Planul turei de azi nu poate fi realizat în siguranță. '
        'Care este reacția corectă?',
    options: [
      'Să lucrezi în siguranță mai departe și să raportezi din timp '
          'problema de planificare',
      'Să renunți la pauze și să scurtezi verificările la manevre',
      'Să mergi mai repede între opriri și să recuperezi timpul acolo',
    ],
    correctIndex: 0,
    explanation: 'Se adaptează planul, nu siguranța. Decisiv este în plus '
        'momentul: o raportare la începutul după-amiezii mai poate '
        'schimba ceva, una seara nu. Renunțarea la pauze agravează '
        'problema, pentru că exact atunci îți scade atenția.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M7 — Urcare/coborâre, ridicare
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Cum sună regula celor 3 puncte („2+1") a BG Verkehr la '
        'urcare și coborâre?',
    options: [
      'O mână și două picioare sunt mereu pe vehicul',
      'Două mâini și un picior sunt mereu în contact cu vehiculul',
      'Ambele picioare stau pe sol înainte să dai drumul mânerelor',
    ],
    correctIndex: 1,
    explanation: 'Două mâini plus un picior dau trei puncte ferme, astfel '
        'încât o singură alunecare nu duce niciodată la cădere. „Ambele '
        'picioare mai întâi pe sol" descrie exact momentul în care nu mai '
        'ai niciun sprijin — aceasta este varianta cu săritura.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Cum cobori corect din cabină?',
    options: [
      'Cu fața înainte, cu spatele la portieră, ultimul pas sărind',
      'Răsucindu-te lateral din scaun și aterizând pe ambele picioare',
      'Cu spatele, cu fața spre vehicul, ca pe o scară',
    ],
    correctIndex: 2,
    explanation: 'Doar cu fața spre vehicul poți folosi mânerele și '
        'treapta și poți păstra trei puncte de contact. Răsucirea afară '
        'din scaun pare mai rapidă, dar solicitează genunchiul și glezna '
        'cu întreaga greutate corporală dintr-odată — este cea mai '
        'frecventă greșeală la coborâre.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Care dintre aceste puncte de sprijin NU contează ca punct '
        'de contact sigur?',
    options: [
      'Mânerul de pe stâlpul A',
      'Muchia portierei',
      'Mânerul de pe rama portierei',
    ],
    correctIndex: 1,
    explanation: 'Muchia portierei aparține unei piese mobile: portiera '
        'poate ceda sau se poate închide, tocmai când îți muți greutatea '
        'pe ea. Același lucru este valabil pentru volan, scaun, anvelopă '
        'și butucul roții — puncte sigure sunt doar mânerele prevăzute '
        'pentru asta.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Ai scanerul și un colet în mâini și vrei să cobori din '
        'compartimentul de marfă. Ce este corect?',
    options: [
      'Să le pui întâi pe amândouă jos, apoi să cobori cu mâinile '
          'libere',
      'Să prinzi coletul sub braț și să te ții cu mâna liberă',
      'Să cobori repede, doar sunt două trepte',
    ],
    correctIndex: 0,
    explanation: 'Cu mâinile pline nu ai trei puncte de contact și nu '
        'poți amortiza o cădere. Varianta cu o mână sună a compromis, '
        'dar este exact situația în care o alunecare duce direct la '
        'cădere: un singur punct nu te ține.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Oprești pe marginea carosabilului și vrei să deschizi '
        'portiera șoferului. Ce îl protejează cel mai bine pe un '
        'biciclist care vine din spate?',
    options: [
      'Să deschizi portiera doar o palmă și să aștepți scurt',
      'Să deschizi portiera rapid și larg, ca să fie bine vizibilă',
      'Să te uiți scurt în oglinda exterioară înainte de a deschide',
      'Privire peste umăr și oglindă — și portiera deschisă cu mâna mai '
          'depărtată',
    ],
    correctIndex: 3,
    explanation: 'Prinderea cu mâna mai depărtată îți rotește automat '
        'trunchiul spre spate și impune privirea. Scurta privire în '
        'oglindă singură nu ajunge, pentru că un biciclist în unghiul '
        'mort nu este vizibil exact atunci; iar o deschidere de o palmă '
        'nu avertizează pe nimeni care este deja lângă tine.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Care este cea mai periculoasă combinație pentru coloană '
        'la ridicare?',
    options: [
      'Să ridici și să îți răsucești în același timp trunchiul',
      'Să ridici din poziție ghemuită, cu genunchii mult îndoiți',
      'Să ridici cu sarcina aproape de corp',
    ],
    correctIndex: 0,
    explanation: 'Sarcina plus răsucirea solicită unilateral discurile '
        'intervertebrale și este cauza clasică a leziunilor acute de '
        'spate — în loc de asta, mută picioarele. Poziția ghemuită și '
        'sarcina aproape de corp sunt, dimpotrivă, exact tehnica '
        'corectă.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Îți scrântești ușor glezna la coborâre, dar poți lucra '
        'mai departe. Ce este corect?',
    options: [
      'Să aștepți și să raportezi doar dacă a doua zi încă doare',
      'Să nu faci nimic — a fost doar o scrântire, fără incapacitate',
      'Să raportezi imediat și să treci în registrul de prim ajutor',
    ],
    correctIndex: 2,
    explanation: 'Doar incidentele documentate contează mai târziu ca '
        'accident de muncă, iar o problemă de ligamente netratată se '
        'vindecă mai prost. Așteptarea până a doua zi este răspândită și '
        'este exact motivul pentru care legătura cu munca adesea nu mai '
        'este recunoscută ulterior.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M8 — Ușa clientului și mediul
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Un câine mare latră la poarta grădinii. Clientul a notat '
        'în instrucțiunea de livrare: „Câinele este blând." Ce faci?',
    options: [
      'Intri liniștit — clientul își cunoaște cel mai bine câinele',
      'Nu intri pe proprietate, încerci să iei legătura și lași '
          'observația pentru colegi',
      'Pui coletul peste gard și pleci mai departe',
    ],
    correctIndex: 1,
    explanation: 'O instrucțiune de livrare nu este o aprobare de '
        'siguranță: clientul își cunoaște câinele în relația cu familia, '
        'nu cu un om străin care cară un obiect mare. În plus, a pune '
        'coletul peste gard nu este o livrare conformă.',
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Un câine liber vine lătrând spre tine. Ce este corect?',
    options: [
      'Să rămâi liniștit pe loc, să îți ferești privirea, să îi '
          'întorci partea laterală și să te retragi încet',
      'Să alergi repede înapoi la vehicul și să închizi ușa',
      'Să ridici vocea și să ridici coletul ca apărare',
    ],
    correctIndex: 0,
    explanation: 'Calmul, privirea ferită și retragerea lentă îi iau '
        'câinelui motivul. Să alergi la vehicul sună rezonabil, dar este '
        'greșit: fuga declanșează reflexul de vânătoare, iar câinele '
        'este mai rapid decât tine.',
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Cel mai scurt drum spre ușa de la intrare trece peste un '
        'gazon ud. Ce faci?',
    options: [
      'Scurtezi — la 120 de opriri ocolul se adună considerabil',
      'Scurtezi, dar doar la lumina zilei și pe vreme uscată',
      'Iei drumul pavat',
    ],
    correctIndex: 2,
    explanation: 'Împiedicarea, alunecarea și căderea sunt cea mai '
        'frecventă cauză de rănire în livrare și aproape întotdeauna se '
        'întâmplă pe ultimii metri. Socoteala nu iese: ocolul costă '
        'secunde, o cădere în medie 24 de zile de incapacitate.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Ce este valabil când părăsești vehiculul pentru o '
        'livrare?',
    options: [
      'Motorul oprit, cheia luată, mașina încuiată, roțile virate în '
          'pantă',
      'Motorul poate merge, atâta timp cât rămâi în raza vizuală',
      'Este suficient să tragi ferm frâna de mână',
    ],
    correctIndex: 0,
    explanation: 'Cine își părăsește vehiculul trebuie să îl asigure '
        'împotriva utilizării neautorizate și să evite accidentele. „În '
        'raza vizuală" nu este o excepție — un vehicul pornit și deschis '
        'dispare în câteva secunde, iar în pantă frâna de mână singură '
        'nu ține sigur o autoutilitară încărcată.',
  ),

  // ══════════════════════════════════ M9 — Urgență și accident
  DrivingQuestion(
    moduleId: 'm9',
    question: 'În ce ordine acționezi la locul unui accident cu răniți?',
    options: [
      'Acorzi primul ajutor, apoi asiguri locul, apoi suni la urgențe',
      'Asiguri, apoi apel de urgență, apoi primul ajutor',
      'Apel de urgență, apoi fotografii pentru asigurare, apoi primul '
          'ajutor',
    ],
    correctIndex: 1,
    explanation: 'Întâi asiguri locul, altfel dintr-un accident ies '
        'două — cu tine ca victimă. Să alergi imediat la rănit pare '
        'omenește corect, dar pe drumul județean și pe autostradă este '
        'periculos pentru viață; fotografiile nu au niciun loc în '
        'această fază.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'La ce distanță așezi triunghiul reflectorizant pe '
        'autostradă?',
    options: [
      'cca. 50 de metri',
      'cca. 100 de metri',
      'cca. 150–200 de metri',
    ],
    correctIndex: 2,
    explanation: 'În localitate cca. 50 m, în afara ei cca. 100 m, pe '
        'autostradă 150–200 m — cu cât viteza este mai mare, cu atât mai '
        'devreme trebuie să stea avertizarea. Cine ia valoarea din afara '
        'localității abia dacă îi dă traficului din spate trei secunde '
        'la 120 km/h. Înaintea crestelor și a curbelor triunghiul se pune '
        'înainte, nu după.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Pe o autostradă cu trei benzi traficul stagnează. Unde '
        'formezi culoarul de urgență?',
    options: [
      'Între banda din stânga și banda din mijloc',
      'Între banda din mijloc și cea din dreapta',
      'Pe banda de urgență',
      'La mijlocul carosabilului, indiferent de numărul de benzi',
    ],
    correctIndex: 0,
    explanation: 'Culoarul este întotdeauna între banda cea mai din '
        'stânga și banda imediat următoare spre dreapta — indiferent '
        'câte benzi există. Banda de urgență nu este o alternativă: pe '
        'ea circulă echipajele de intervenție, dacă culoarul este '
        'blocat.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Când trebuie format culoarul de urgență?',
    options: [
      'Abia când se vede sau se aude girofarul',
      'De îndată ce traficul stagnează',
      'Abia când este dispus prin panoul de afișaj',
    ],
    correctIndex: 1,
    explanation: 'Culoarul apare odată cu stagnarea, nu cu girofarul. '
        'Dacă aștepți vehiculul de intervenție, vehiculele stau demult '
        'prea aproape — atunci nimeni nu mai are loc să se dea la o '
        'parte.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'La manevre avariezi o mașină parcată, nu este nimeni în '
        'apropiere. Ajunge un bilețel sub ștergător?',
    options: [
      'Da, dacă pe el sunt trecute numele și numărul de telefon',
      'Da, bilețelul este calea prevăzută de lege',
      'Nu — ajunge doar dacă faci în plus și fotografii',
      'Nu — trebuie să aștepți un timp rezonabil, iar altfel să '
          'informezi poliția',
    ],
    correctIndex: 3,
    explanation: 'Un bilețel nu contează juridic ca identificare '
        'suficientă — poate zbura sau poate fi îndepărtat; cine se '
        'bazează pe el riscă acuzația de părăsire nepermisă a locului '
        'accidentului. Fotografiile documentează paguba, dar nu '
        'înlocuiesc nici așteptarea, nici raportarea.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'O persoană nu respiră normal după accident. Ce faci?',
    options: [
      'Începi imediat masajul cardiac, cam de 100–120 de ori pe minut',
      'Aduci persoana în poziție laterală de siguranță și o acoperi',
      'Aștepți ambulanța — ca nespecialist nu ai voie să faci nimic',
    ],
    correctIndex: 0,
    explanation: 'Fără respirație normală fiecare minut contează, iar '
        'compresia este singura măsură care ajută. Poziția laterală de '
        'siguranță este corectă — dar doar la o respirație normală '
        'existentă. Iar a nu face nimic este singura decizie greșită: '
        'neacordarea ajutorului se pedepsește.',
  ),

  // ══════════════════════════════════ M10 — Recapitulare
  DrivingQuestion(
    moduleId: 'm10',
    question: 'Ce rezumă cel mai bine atitudinea acestei instruiri?',
    options: [
      'Regulile sunt valabile mai ales atunci când se fac controale',
      'Siguranța este decizia mea zilnică, pentru ca toți să ajungă '
          'acasă în siguranță',
      'Important este ca tura să fie terminată la timp',
    ],
    correctIndex: 1,
    explanation: 'Siguranța este o atitudine, nu un exercițiu obligatoriu '
        '— și se vede tocmai atunci când nu se uită nimeni. Cine leagă '
        'regulile de controale nu le-a înțeles, ci doar le-a suportat.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm10',
    question: 'Câte puncte de contact păstrezi la urcare și coborâre — '
        'și câte secunde distanță cel puțin pe carosabil uscat?',
    options: [
      '2 puncte de contact și 1 secundă',
      '3 puncte de contact și 1 secundă',
      '3 puncte de contact (2 mâini + 1 picior) și 2 secunde',
    ],
    correctIndex: 2,
    explanation: 'Trei puncte de contact („2+1") și două secunde '
        'distanță — pe umed trei. O secundă de distanță corespunde la '
        'viteza de 50 exact simplei distanțe de reacție: ai intra în cel '
        'din față fără nicio rezervă de frânare.',
  ),
];
