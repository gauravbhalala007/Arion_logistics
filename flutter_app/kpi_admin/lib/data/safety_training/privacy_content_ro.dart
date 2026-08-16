// lib/data/safety_training/privacy_content_ro.dart
//
// Conținutul instruirii de protecție a datelor — versiunea română.
// Structura este identică cu versiunea germană (master,
// privacy_content_de.dart): capitolele ds1–ds6, aceleași folii,
// aceleași blocuri și aceleași valori. Orice modificare de structură
// se face mai întâi în fișierul german și se preia apoi aici.
//
// Referințele legale rămân la forma germană (Art. 5 DSGVO, § 26 BDSG
// etc.), cu o scurtă explicație în română acolo unde textul o cere.
// Pentru această temă nu există ilustrații, de aceea `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> privacyContentRo = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ds1',
    title: 'De ce te privește protecția datelor',
    summary: 'Datele cu caracter personal în livrarea de zi cu zi și '
        'principiile din Art. 5 DSGVO (GDPR)',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Lucrezi toată ziua cu datele altora',
        blocks: [
          ParagraphBlock(
            'Protecția datelor sună a birou, dulap de dosare și juriști. '
            'În realitate, aproape nimeni nu este atât de aproape de '
            'datele cu caracter personal ca tine. De la primul scan de '
            'dimineață până la ultima oprire de seară ai în mână nume, '
            'adrese și numere de telefon străine — plus fotografii cu '
            'ușile de intrare ale altor oameni.',
          ),
          ParagraphBlock(
            'Cu caracter personal este orice informație prin care o '
            'persoană poate fi identificată. Nu doar numele: și '
            'combinația de adresă, oră și conținutul coletului spune '
            'ceva despre un om. Exact de aceea există reguli pentru ele.',
          ),
          BulletsBlock([
            'Numele destinatarilor și adresele de pe etichetă, scanner '
                'și listă',
            'Numerele de telefon pentru contactare înainte de livrare',
            'Semnăturile de pe scanner drept confirmare de primire',
            'Fotografiile ca dovadă de livrare în fața ușii',
            'Datele de localizare ale scannerului și ale vehiculului',
            'Informațiile despre vecinii la care ai lăsat un colet',
            'Indicații precum „Coletul, te rog, în spatele tomberonului" '
                '— și asta este o informație despre situația locativă a '
                'unui om',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Pe scurt',
            text: 'Tot ce afli despre un destinatar ai aflat doar pentru '
                'că îi aduci coletul. Pentru orice altceva nu ai primit '
                'această informație.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Trei principii care contează zi de zi',
        blocks: [
          ParagraphBlock(
            'Art. 5 DSGVO (GDPR) stabilește șase principii. Trei dintre '
            'ele decid practic în fiecare zi dacă procedezi corect sau '
            'greșit. În limbaj simplu:',
          ),
          TableBlock(
            headers: ['Principiu', 'Ce înseamnă pentru tine'],
            rows: [
              [
                'Limitarea scopului',
                'Folosești datele doar în scopul pentru care le-ai '
                    'primit: livrarea. Nu în scop privat.',
              ],
              [
                'Reducerea datelor la minimum',
                'Colectezi și arăți doar cât este necesar. Nicio '
                    'fotografie în plus, nicio listă mai lungă decât '
                    'trebuie.',
              ],
              [
                'Confidențialitate',
                'Ce vezi rămâne la tine și în firmă. Nu în grupul de '
                    'chat, nu la masa din bucătărie, nu pe internet.',
              ],
            ],
          ),
          ParagraphBlock(
            'La acestea se adaugă exactitatea (corectezi datele greșite '
            'în loc să le duci mai departe), limitarea stocării (nu '
            'păstrezi nimic mai mult decât este necesar) și '
            'responsabilitatea — ultimul punct privește firma și este '
            'motivul acestei instruiri.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Temeiul legal',
            text: 'Art. 5 alin. 1 DSGVO cere, printre altele, limitarea '
                'scopului (lit. b), reducerea datelor la minimum (lit. c) '
                'precum și integritate și confidențialitate (lit. f). '
                'Aceste principii sunt valabile pentru oricine lucrează '
                'cu date cu caracter personal în numele firmei — deci și '
                'pentru tine, pe tură.',
          ),
        ],
      ),
      SafetySlide(
        title: 'De ce există această instruire',
        blocks: [
          ParagraphBlock(
            'DSGVO nu scrie nicăieri textual „angajații trebuie '
            'instruiți". O cere totuși — doar pe trei alte căi. De aceea '
            'stai acum aici și de aceea absolvirea se documentează.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'De unde rezultă obligația de instruire',
            text: 'Art. 32 DSGVO obligă firma la măsuri tehnice și '
                'organizatorice pentru securitatea prelucrării — '
                'angajații instruiți sunt o astfel de măsură. Art. 39 '
                'alin. 1 lit. b DSGVO numește explicit sensibilizarea și '
                'instruirea drept sarcină a responsabilului cu protecția '
                'datelor. Iar Art. 5 alin. 2 DSGVO cere ca firma să '
                'poată dovedi respectarea regulilor — responsabilitate.',
          ),
          ParagraphBlock(
            'Autoritățile de supraveghere se uită exact la asta la un '
            'control. Lipsa instruirii angajaților o consideră de regulă '
            'un indiciu că măsurile au fost insuficiente — mai ales '
            'atunci când deja s-a întâmplat ceva. După un incident de '
            'date, prima întrebare este aproape întotdeauna: au fost '
            'oamenii instruiți și puteți dovedi asta?',
          ),
          BulletsBlock([
            'Instruire de bază anuală pentru toți — absolvirea ta este '
                'valabilă douăsprezece luni',
            'Instruire ocazională, când se schimbă ceva sau s-a '
                'întâmplat ceva',
            'Instruirea noilor angajați înainte de prima zi pe cont '
                'propriu',
            'Documentarea testului și a semnăturii ca dovadă conform '
                'Art. 5 alin. 2 DSGVO',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Pe unde trece linia în viața de zi cu zi',
        blocks: [
          RevealBlock(
            prompt: 'Exemplu de caz: Pe tura ta se află un colet pentru '
                'un fotbalist cunoscut din regiune. Seara le povestești '
                'prietenilor pe ce stradă locuiește — nimic mai mult, '
                'niciun nume pe rețelele sociale, doar între prieteni. '
                'Este asta o încălcare a protecției datelor?',
            answer: 'Da. Adresa este o informație cu caracter personal '
                'și o cunoști exclusiv din munca ta. Să o dai mai '
                'departe unor terți încalcă limitarea scopului (Art. 5 '
                'alin. 1 lit. b DSGVO) și confidențialitatea (lit. f). '
                'Greșeala la îndemână este să crezi că un cerc privat '
                '„nu contează" — DSGVO nu întreabă cât de mare a fost '
                'publicul, ci dacă ai dezvăluit datele contrar scopului. '
                'Dacă unul dintre prieteni povestește mai departe, nu '
                'mai ai, în plus, niciun control.',
          ),
          DoDontBlock(
            doTitle: 'Corect',
            dos: [
              'Folosești datele destinatarilor doar pentru livrare și le '
                  'lași apoi în sistem',
              'La întrebări despre o trimitere, trimiți la dispecer sau '
                  'la conducerea firmei',
              'Ții scannerul și lista de hârtie astfel încât terții să '
                  'nu poată citi',
              'Situațiile neclare le ridici, în loc să decizi singur',
            ],
            dontTitle: 'Greșit',
            donts: [
              'Povestești adrese sau nume în cercul privat — nici măcar '
                  '„doar între prieteni"',
              'Faci din persoane celebre sau trimiteri deosebite subiect '
                  'de discuție',
              'Cauți date ale destinatarilor din curiozitate, fără să '
                  'existe o sarcină de lucru',
              'Te bazezi pe faptul că „oricum nu află nimeni"',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare — capitolul 1',
        blocks: [
          ParagraphBlock(
            'Parcurge pe scurt punctele. Dacă eziți la vreunul, mai '
            'răsfoiește o dată înapoi — în test apar exact aceste '
            'situații.',
          ),
          ChecklistBlock(
            title: 'Asta iau cu mine din capitolul 1',
            items: [
              'Știu care date de pe tura mea au caracter personal',
              'Cunosc limitarea scopului, reducerea datelor la minimum '
                  'și confidențialitatea',
              'Știu că datele destinatarilor nu au ce căuta în viața '
                  'privată',
              'Știu de ce se documentează această instruire '
                  '(Art. 5 alin. 2 DSGVO)',
              'Îmi este clar că instruirea se repetă anual',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ds2',
    title: 'Fotografiile și dovezile de livrare',
    summary: 'Ce are voie să apară în imagine, ce nu — și unde îi este '
        'locul fotografiei',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Fotografia are exact un singur scop',
        blocks: [
          ParagraphBlock(
            'Fotografia de livrare trebuie să răspundă la o singură '
            'întrebare: unde se află coletul? Nimic altceva. Tot ce '
            'trece dincolo de asta este mai multă informație decât '
            'necesar — și deci o încălcare a reducerii datelor la '
            'minimum.',
          ),
          ParagraphBlock(
            'Practic, asta înseamnă: camera în jos spre colet, destul '
            'de aproape cât să se recunoască locul de amplasare și '
            'destul de departe de tot ce arată oameni sau îi face '
            'identificabili.',
          ),
          DoDontBlock(
            doTitle: 'Are voie în imagine',
            dos: [
              'Coletul însuși, la locul de amplasare',
              'O bucată de fațadă, ușă sau scară ca reper al locului',
              'Numărul casei, dacă este necesar pentru identificare',
              'La permisiune de amplasare: locul de depunere convenit',
            ],
            dontTitle: 'Nu are voie în imagine',
            donts: [
              'Persoane — nici destinatarul, nici măcar din spate',
              'Numere de înmatriculare ale vehiculelor parcate',
              'Ferestre, balcoane și priveliști spre interiorul '
                  'locuinței',
              'Copii, animale de companie, vizitatori, vecini în fundal',
              'Plăcuțe cu numele terților, dacă nu țin de trimitere',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Temeiul legal',
            text: 'Art. 5 alin. 1 lit. c DSGVO cere reducerea datelor '
                'la minimum: datele trebuie să fie adecvate scopului și '
                'limitate la strictul necesar. O fotografie care arată '
                'persoane, numere de înmatriculare sau interiorul '
                'locuinței depășește scopul „dovadă de livrare". În '
                'plus, la persoanele fotografiate intervine dreptul la '
                'propria imagine.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Unde îi este locul fotografiei — și unde nu',
        blocks: [
          ParagraphBlock(
            'La fel de important ca și conținutul imaginii este locul '
            'de stocare. Fotografia se face în aplicația de serviciu și '
            'rămâne acolo. Nu are ce căuta în galeria ta privată și cu '
            'atât mai puțin într-un messenger.',
          ),
          BulletsBlock([
            'Faci fotografia exclusiv în aplicația de serviciu — nu mai '
                'întâi cu aplicația de cameră și apoi o încarci',
            'Nicio copie în galeria privată, nicio salvare în cloud a '
                'telefonului privat',
            'Nicio trimitere prin WhatsApp, Telegram, Signal sau un '
                'grup de chat al șoferilor',
            'Nu păstrezi nicio fotografie „de siguranță" pentru tine — '
                'dovada se află în sistem',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Cea mai frecventă greșeală',
            text: 'Să fotografiezi mai întâi cu camera normală și apoi '
                'să încarci imaginea în aplicație. Astfel, fotografia '
                'rămâne permanent în galeria ta privată — adesea și '
                'într-un cloud din străinătate. Aceasta este o '
                'prelucrare nepermisă, chiar dacă nu o arăți niciodată '
                'nimănui.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dacă totuși apare cineva în imagine',
        blocks: [
          ParagraphBlock(
            'Se întâmplă: vecina iese pe ușă exact în momentul '
            'declanșării sau un copil trece prin cadru. Nu este o dramă '
            '— atâta timp cât acționezi imediat.',
          ),
          StepsBlock([
            'Ștergi fotografia imediat, înainte să închizi oprirea',
            'Fotografiezi din nou, de data asta fără persoane în '
                'imagine',
            'Dacă imaginea este deja încărcată: informezi dispecerul '
                'sau conducerea firmei, ca să poată fi ștearsă din '
                'sistem',
            'Dacă nu ești sigur dacă cineva este recognoscibil: mai '
                'bine raportezi decât să speri',
          ]),
          RevealBlock(
            prompt: 'Exemplu de caz: Lași un colet în curtea '
                'interioară. În fotografie se vede coletul — iar în '
                'fundal, printr-o fereastră până la podea, un living cu '
                'două persoane pe canapea. Ai închis deja oprirea și te '
                'afli în curtea următoare. Ce faci?',
            answer: 'Raportezi. Imaginea arată un interior și persoane '
                'identificabile — trece astfel cu mult peste scopul '
                '„dovadă de livrare" și trebuie eliminată din sistem. '
                'Greșeala la îndemână este să crezi că nu mai merită '
                'raportat, pentru că oprirea este deja închisă. Exact '
                'invers: doar dacă firma știe, poate șterge imaginea și '
                'documenta cazul. Cine raportează face totul corect — '
                'cine tace lasă o încălcare să persiste.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare — capitolul 2',
        blocks: [
          ChecklistBlock(
            title: 'Înainte de fiecare fotografie de livrare',
            items: [
              'Fotografiez doar în aplicația de serviciu',
              'În imagine nu se vede nicio persoană',
              'Niciun număr de înmatriculare, nicio fereastră, niciun '
                  'interior în imagine',
              'Coletul și locul de amplasare se recunosc fără dubii',
              'Nicio imagine nu ajunge în galeria mea privată sau '
                  'într-un chat',
              'Dacă din greșeală apare cineva: șterg, refac fotografia, '
                  'raportez',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ds3',
    title: 'Lucrul cu datele destinatarilor',
    summary: 'Scanner, telefon și liste de hârtie — mijloace de '
        'serviciu, nu chestiuni private',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Scannerul și telefonul de serviciu nu sunt dispozitive '
            'private',
        blocks: [
          ParagraphBlock(
            'Pe scanner și pe telefonul de serviciu se află datele a '
            'sute de oameni pe zi. Ambele aparate aparțin firmei și '
            'sunt exclusiv pentru muncă — și în pauză, și atunci când '
            'le iei acasă.',
          ),
          BulletsBlock([
            'Fără aplicații private, fără conturi private, fără cloud '
                'privat pe aparatul de serviciu',
            'Nu dai aparatul mai departe — nici măcar pentru scurt timp '
                'colegilor, rudelor sau cunoscuților',
            'Lași blocarea ecranului activă și nu lași niciodată '
                'aparatul nesupravegheat',
            'Când părăsești vehiculul: iei scannerul cu tine sau îl '
                'depozitezi în siguranță, nu la vedere pe scaun',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Interdicție absolută',
            text: 'Fără capturi de ecran ale listelor de adrese, ale '
                'prezentărilor de tură sau ale datelor destinatarilor. '
                'Nici ca să ți le trimiți ție însuți, nici „ca aducere '
                'aminte". O captură de ecran este o copie în afara '
                'sistemului — exact ceea ce firma nu mai poate controla.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Informații către vecini și străini',
        blocks: [
          ParagraphBlock(
            'La ușă ți se pun întrebări. Este normal și de cele mai '
            'multe ori fără intenții rele. Totuși rămâne valabil: '
            'dezvălui doar atât cât este necesar pentru livrare — nu '
            'mai mult.',
          ),
          TableBlock(
            headers: ['Situație', 'Până unde ai voie să mergi'],
            rows: [
              [
                'Un vecin preia un colet',
                'Spui numele destinatarului și numărul casei — mai mult '
                    'nu îi trebuie.',
              ],
              [
                'Vecinul întreabă ce este înăuntru',
                'Nicio informație. Conținutul îl privește doar pe '
                    'destinatar.',
              ],
              [
                'Cineva întreabă dacă persoana X locuiește aici',
                'Nicio informație. Nu confirmi adrese de domiciliu.',
              ],
              [
                'Cineva întreabă când mai vii',
                'Răspunzi general, fără informații despre alte '
                    'trimiteri sau alți destinatari.',
              ],
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Temeiul legal',
            text: 'Transmiterea datelor destinatarilor către terți este '
                'o divulgare în sensul Art. 4 nr. 2 DSGVO și are nevoie '
                'de un temei legal conform Art. 6 DSGVO. Pentru '
                'predarea la vecin, menționarea numelui și a adresei '
                'este necesară executării contractului — pentru '
                'conținutul coletelor, numere de telefon sau informații '
                'despre alți destinatari nu există niciun temei.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Hârtia este pericolul subestimat',
        blocks: [
          ParagraphBlock(
            'Datele digitale sunt măcar protejate de o blocare a '
            'ecranului. O hârtie în vehicul nu este. O listă de tură '
            'după parbriz se poate citi de afară — cu numele și '
            'adresele a două sute de gospodării.',
          ),
          BulletsBlock([
            'Nu lași niciodată listele de hârtie la vedere în vehicul, '
                'cu atât mai puțin vizibile prin geam',
            'Când părăsești vehiculul, iei listele cu tine sau le '
                'depozitezi încuiate',
            'La sfârșitul turei: predai listele la firmă, nu le iei '
                'acasă',
            'Eliminarea, doar pe calea prevăzută în firmă — nu la '
                'gunoiul menajer, nu în coșul de hârtii de la benzinărie',
            'Tratezi etichetele retururilor și ale coletelor greșite la '
                'fel ca listele',
          ]),
          RevealBlock(
            prompt: 'Exemplu de caz: Ai terminat tura, lista de tură nu '
                'mai este decât maculatură. În drum spre casă o arunci '
                'în tomberonul de hârtie de la blocul tău. Este în '
                'regulă?',
            answer: 'Nu. Pe listă se află nume și adrese — date cu '
                'caracter personal. Ele trebuie eliminate astfel încât '
                'nimeni să nu le poată reconstitui, de regulă printr-un '
                'container de protecție a datelor sau distrugătorul de '
                'documente din firmă. Greșeala la îndemână este să '
                'crezi că o listă rezolvată „nu mai valorează nimic". '
                'Pentru protecția datelor, finalizarea nu schimbă '
                'nimic: datele sunt aceleași, iar un tomberon de hârtie '
                'deschis este un loc accesibil publicului. În plus, '
                'nici nu ai fi avut voie să iei lista acasă.',
          ),
          DoDontBlock(
            doTitle: 'Corect',
            dos: [
              'Predai listele la firmă și le elimini acolo conform '
                  'regulilor',
              'Blochezi scannerul înainte să părăsești vehiculul',
              'La întrebări despre trimiterile altora, trimiți la '
                  'conducerea firmei',
            ],
            dontTitle: 'Greșit',
            donts: [
              'Faci sau trimiți capturi de ecran ale listelor de adrese',
              'Iei listele de tură acasă sau le elimini privat',
              'Dai datele destinatarilor vecinilor, cunoscuților sau '
                  'terților',
              'Dai aparatul de serviciu altcuiva',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare — capitolul 3',
        blocks: [
          ChecklistBlock(
            title: 'La sfârșitul fiecărei ture',
            items: [
              'Nicio captură de ecran cu date de adrese pe aparatul meu',
              'Scannerul și telefonul de serviciu sunt blocate și '
                  'depozitate în siguranță',
              'Nicio listă de hârtie nu stă la vedere în vehicul',
              'Toate listele și etichetele sunt predate la firmă',
              'Nu am transmis date ale destinatarilor către terți',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ds4',
    title: 'Datele tale și ale colegilor',
    summary: 'Concediu medical, pontaj, dosar de personal — și '
        'drepturile tale de persoană vizată',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Protecția datelor te protejează și pe tine',
        blocks: [
          ParagraphBlock(
            'Nu doar destinatarii au date în sistem — și tu. Iar unele '
            'sunt considerabil mai sensibile decât o adresă de livrare.',
          ),
          BulletsBlock([
            'Indicatori de performanță din activitatea ta de livrare',
            'Concedii medicale și absențe',
            'Pontaj, planuri de schimb, timpi de pauză',
            'Date din permisul de conducere și actul de identitate, din '
                'dosarul de personal',
            'Fotografii în care apari tu sau colegii',
          ]),
          ParagraphBlock(
            'Firma are voie să prelucreze aceste date în măsura în care '
            'este necesar pentru raportul de muncă. Nu are însă voie să '
            'le transmită după bunul plac — și nici tu nu ai voie, când '
            'este vorba de colegi.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Temeiul legal',
            text: 'Datele angajaților se prelucrează în temeiul Art. 6 '
                'alin. 1 lit. b și f DSGVO coroborat cu § 26 BDSG '
                '(legea germană a protecției datelor) — permis doar în '
                'măsura necesară raportului de muncă. Datele de '
                'sănătate, precum concediile medicale, sunt categorii '
                'speciale conform Art. 9 DSGVO și beneficiază de o '
                'protecție deosebit de strictă.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Datele colegilor nu îți aparțin',
        blocks: [
          ParagraphBlock(
            'În depou afli multe: cine este bolnav, cine a avut '
            'probleme cu o tură, cine a primit un avertisment. Una este '
            'să afli — alta este să dai mai departe.',
          ),
          DoDontBlock(
            doTitle: 'Corect',
            dos: [
              'Vorbești despre propriile tale valori, cât vrei',
              'Clarifici problemele cu un coleg direct cu el sau cu '
                  'conducerea firmei',
              'Faci și distribui o fotografie cu colegi doar dacă toți '
                  'cei din imagine sunt de acord',
              'Raportezi intern încălcările observate, în loc să le '
                  'povestești prin depou',
            ],
            dontTitle: 'Greșit',
            donts: [
              'Transmiți date de performanță sau evaluări ale colegilor',
              'Vorbești despre motivul îmbolnăvirii unui coleg — chiar '
                  'dacă îl cunoști',
              'Postezi fotografii sau clipuri cu colegi fără acordul '
                  'lor în grupuri de chat',
              'Distribui capturi de ecran din liste sau evaluări interne',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Deosebit de delicat',
            text: 'Concediile medicale. Faptul că cineva este bolnav '
                'este o informație de sănătate conform Art. 9 DSGVO. '
                'Motivul, cu atât mai mult. Transmiterea către alți '
                'șoferi nu este permisă nici măcar atunci când persoana '
                'în cauză a povestit deja ea însăși despre asta.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Drepturile tale de persoană vizată',
        blocks: [
          ParagraphBlock(
            'DSGVO îți dă drepturi față de angajatorul tău. Nu trebuie '
            'să le motivezi, iar exercitarea lor nu are voie să îți '
            'aducă dezavantaje.',
          ),
          TableBlock(
            headers: ['Drept', 'Ce poți cere'],
            rows: [
              [
                'Acces (Art. 15)',
                'O privire de ansamblu asupra datelor stocate despre '
                    'tine și a scopurilor lor.',
              ],
              [
                'Rectificare (Art. 16)',
                'Corectarea datelor greșite, de exemplu un număr de '
                    'personal sau o adresă greșită.',
              ],
              [
                'Ștergere (Art. 17)',
                'Ștergerea datelor care nu mai sunt necesare și nu sunt '
                    'supuse unui termen de păstrare.',
              ],
            ],
          ),
          ParagraphBlock(
            'Persoana de contact este conducerea firmei sau '
            'responsabilul cu protecția datelor al companiei. O cerere '
            'trebuie, în principiu, să primească răspuns în termen de o '
            'lună.',
          ),
          RevealBlock(
            prompt: 'Exemplu de caz: Un coleg te roagă să îi trimiți o '
                'captură de ecran a unei evaluări interne — pe care '
                'apar toți șoferii cu nume și valori. Vrea doar să vadă '
                'unde se situează el. O faci?',
            answer: 'Nu. Pe captura de ecran se află datele de '
                'performanță ale tuturor colegilor; aceasta este o '
                'transmitere de date ale angajaților fără temei legal. '
                'Faptul că vrea să își vadă doar propriul rând nu '
                'schimbă nimic — le primește oricum și pe toate '
                'celelalte. Corect este: își cere propriile valori de '
                'la conducerea firmei. Dreptul lui de acces conform '
                'Art. 15 DSGVO se referă exclusiv la propriile lui '
                'date.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare — capitolul 4',
        blocks: [
          ChecklistBlock(
            title: 'În lucrul cu datele colegilor',
            items: [
              'Nu transmit date de performanță ale colegilor',
              'Nu vorbesc despre concediile medicale ale altora',
              'Nu postez fotografii cu colegi fără acordul lor',
              'Nu fac capturi de ecran din evaluările interne',
              'Știu cui mă adresez când vreau informații despre '
                  'propriile mele date',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ds5',
    title: 'Când ceva merge prost — incidentul de date',
    summary: 'Termen de notificare de 72 de ore: de ce trebuie să '
        'raportezi imediat',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Ce este un incident de date',
        blocks: [
          ParagraphBlock(
            'Un incident de date nu este doar marele atac al '
            'hackerilor. În livrare este vorba aproape întotdeauna de '
            'mici neplăceri de zi cu zi — și exact acestea contează la '
            'fel.',
          ),
          BulletsBlock([
            'Telefon de serviciu sau scanner pierdut ori furat',
            'Colet predat destinatarului greșit, care l-a deschis',
            'Colet cu eticheta de adresă lizibilă, lăsat la vedere pe '
                'casa scării sau pe stradă',
            'Fotografie sau listă de adrese trimisă din greșeală '
                'persoanei greșite',
            'Listă de tură pierdută sau lăsată la vedere în vehicul',
            'Scanner rămas nesupravegheat și accesibil deblocat',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Regulă simplă',
            text: 'De îndată ce date cu caracter personal au devenit '
                'accesibile cuiva care nu ar fi trebuit să aibă acces '
                'la ele, este un incident de date. Dacă la final s-a '
                'produs într-adevăr o pagubă nu decizi tu — asta '
                'verifică firma.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Termenul de 72 de ore',
        blocks: [
          ParagraphBlock(
            'Punctul decisiv pentru tine este ceasul. De îndată ce '
            'firma află de un incident de date, curge un termen foarte '
            'scurt — și curge indiferent dacă este sfârșit de program, '
            'weekend sau sărbătoare.',
          ),
          FactsBlock([
            FactItem('72 h', 'termenul de notificare al firmei către '
                'autoritatea de supraveghere conform Art. 33 DSGVO'),
            FactItem('imediat', 'raportarea ta către dispecer sau '
                'conducerea firmei — încă din aceeași zi'),
            FactItem('0', 'dezavantaje pentru tine, dacă îți raportezi '
                'imediat propria greșeală'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Temeiul legal',
            text: 'Art. 33 alin. 1 DSGVO obligă firma să notifice '
                'autorității de supraveghere o încălcare a securității '
                'datelor cu caracter personal fără întârziere și, pe '
                'cât posibil, în termen de 72 de ore de la aflare. La '
                'risc ridicat trebuie informate în plus persoanele '
                'vizate, conform Art. 34 DSGVO. Firma poate respecta '
                'acest termen doar dacă tu raportezi imediat.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Așa raportezi corect',
        blocks: [
          StepsBlock([
            'Suni imediat dispecerul sau conducerea firmei — nu aștepți '
                'până la finalul programului',
            'Spui ce s-a întâmplat, când s-a întâmplat și ce date sunt '
                'afectate',
            'Spui cine ar fi putut vedea datele',
            'Nu repari nimic pe cont propriu: nu ștergi protocoale, nu '
                'recuperezi nimic fără consultare',
            'Dacă este posibil, conservi situația — de exemplu nu mai '
                'muți coletul livrat greșit înainte să se stabilească '
                'cum se procedează',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Cel mai important lucru din acest capitol',
            text: 'Cine raportează imediat o greșeală procedează '
                'corect. Raportarea este explicit dorită și nu este o '
                'recunoaștere a incompetenței. Tăcerea, în schimb, '
                'transformă o mică neplăcere într-o problemă reală — '
                'pentru cei afectați, pentru firmă și, la final, și '
                'pentru tine.',
          ),
          DoDontBlock(
            doTitle: 'Corect',
            dos: [
              'Raportezi imediat, chiar dacă este jenant',
              'Descrii complet, inclusiv propriile greșeli',
              'Întrebi dacă mai trebuie să faci ceva',
            ],
            dontTitle: 'Greșit',
            donts: [
              'Aștepți să vezi dacă observă cineva',
              'Anunți abia în următoarea zi de lucru',
              'Minimalizezi incidentul sau omiți părți din el',
              'Încerci pe cont propriu să recuperezi coletul sau '
                  'fotografia',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Exemplu de caz și listă de verificare',
        blocks: [
          RevealBlock(
            prompt: 'Exemplu de caz: Observi seara că ai predat un '
                'colet la casa cu numărul 14 în loc de 41. Destinatarul '
                'de acolo l-a deschis deja. Vrei să îl iei mâine '
                'dimineață pur și simplu și să îl livrezi corect — așa '
                'nu observă nimeni. Ce este greșit aici?',
            answer: 'Două lucruri. În primul rând, incidentul de date '
                's-a produs deja: o persoană străină a aflat numele, '
                'adresa și conținutul trimiterii. Acest lucru trebuie '
                'verificat ca posibilă obligație de notificare, iar '
                'termenul de 72 de ore din Art. 33 DSGVO curge din '
                'momentul în care firma află. În al doilea rând, prin '
                'așteptare împiedici exact ceea ce ar trebui să facă '
                'firma — să evalueze, să documenteze și, dacă este '
                'cazul, să informeze destinatarul afectat. Greșeala la '
                'îndemână este să crezi că o corectură tăcută nu '
                'dăunează nimănui. De fapt dăunează: dacă incidentul '
                'devine cunoscut mai târziu, firma rămâne fără '
                'notificare în termen — iar tu ai ascuns greșeala în '
                'loc să o fi raportat.',
          ),
          ChecklistBlock(
            title: 'La orice suspiciune de incident de date',
            items: [
              'Raportez încă din aceeași zi, nu abia mâine',
              'Spun ce s-a întâmplat, când și ce date sunt afectate',
              'Nu cosmetizez nimic și nu omit nimic',
              'Nu întreprind nimic pe cont propriu',
              'Îmi este clar: a raporta este corect, a tăcea '
                  'înrăutățește totul',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'ds6',
    title: 'Confidențialitate și loialitate',
    summary: 'Ce are voie să iasă în afară, ce nu — și de ce critica '
        'obiectivă este explicit permisă',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Secretele firmei rămân în firmă',
        blocks: [
          ParagraphBlock(
            'Pe lângă datele cu caracter personal există o a doua '
            'categorie de informații care nu au ce căuta în afară: '
            'cifrele interne și secretele de afaceri. Aici intră multe '
            'lucruri care se discută în depou de la sine înțeles.',
          ),
          BulletsBlock([
            'Prețuri, condiții și contracte cu beneficiarii',
            'Indicatori și evaluări interne',
            'Planuri de tură, logica rutelor și cifre de capacitate',
            'Instrucțiuni interne, materiale de instruire și proceduri '
                'de lucru',
            'Fotografii din depou în care se recunosc liste, ecrane '
                'sau trimiteri',
          ]),
          ParagraphBlock(
            'Acest lucru este valabil la fel în orice canal: în '
            'discuția personală, în rețelele sociale și în grupurile de '
            'chat ale șoferilor. Un grup de WhatsApp cu șaizeci de '
            'șoferi nu este o conversație privată.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Temeiul legal',
            text: 'Secretele de afaceri sunt protejate prin legea '
                'germană a secretelor de afaceri (GeschGehG). '
                'Independent de aceasta, din contractul de muncă '
                'rezultă o obligație de confidențialitate ca obligație '
                'accesorie conform § 241 alin. 2 BGB (Codul civil '
                'german). Pentru datele cu caracter personal se aplică '
                'în plus confidențialitatea conform Art. 5 alin. 1 '
                'lit. f DSGVO.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Afirmații neadevărate despre firmă',
        blocks: [
          ParagraphBlock(
            'Aici se amestecă des ce este permis și ce nu. Granița nu '
            'trece între „pozitiv" și „negativ", ci între adevărat și '
            'conștient neadevărat, între critică și denigrare.',
          ),
          ParagraphBlock(
            'Afirmațiile factuale conștient neadevărate despre firmă, '
            'superiori sau colegi nu sunt acoperite de libertatea de '
            'exprimare. La fel insultele și critica denigratoare — '
            'adică afirmațiile în care nu mai este vorba despre '
            'subiect, ci doar despre a înjosi pe cineva.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Temeiul legal',
            text: 'Art. 5 alin. 1 GG (Constituția Germaniei) protejează '
                'exprimarea opiniilor, dar nu afirmațiile factuale '
                'conștient neadevărate și nici critica denigratoare. '
                'Astfel de afirmații pot justifica o concediere fără '
                'preaviz conform § 626 BGB. La defăimare se adaugă '
                'răspunderea penală conform § 186 StGB; la afirmații '
                'conștient false intervine § 187 StGB (calomnia).',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Neînțelegeri tipice',
            text: 'Un profil privat nu este privat de îndată ce pot '
                'citi și alții. Un grup de chat închis nu este protejat '
                'de îndată ce o captură de ecran pleacă mai departe. '
                'Iar „a fost doar părerea mea" nu ajută dacă enunțul a '
                'fost o afirmație factuală care în mod demonstrabil nu '
                'este adevărată.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Critica obiectivă este explicit permisă',
        blocks: [
          ParagraphBlock(
            'La fel de important ca granița este ce se află dincoace '
            'de ea — și asta este mult. Ai voie să exprimi critici, '
            'chiar apăsat, chiar incomod. Ai voie să spui că o tură '
            'este planificată prea strâns, că un vehicul este în stare '
            'proastă sau că un anunț din depou a fost greșit.',
          ),
          ParagraphBlock(
            'Iar cine raportează nereguli reale nu rămâne fără '
            'apărare: din 2 iulie 2023 este în vigoare legea germană '
            'privind protecția avertizorilor (HinSchG). Ea interzice '
            'represaliile împotriva angajaților care raportează '
            'încălcări — adică concediere, avertisment, transfer sau '
            'dezavantajare din cauza raportării.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Protecția avertizorilor',
            text: 'HinSchG protejează de represalii persoanele care '
                'raportează încălcări în context profesional. Protecția '
                'dispare doar la raportări neadevărate făcute cu bună '
                'știință sau din neglijență gravă. Deci cine raportează '
                'serios și după cea mai bună știință o neregulă este '
                'protejat — chiar și atunci când suspiciunea nu se '
                'confirmă la final.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Diferența într-o singură frază',
            text: 'Spune ce ai trăit — nu ce îți închipui. Critica '
                'adevărată este protejată, acuzațiile inventate nu.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Calea constructivă',
        blocks: [
          ParagraphBlock(
            'Aproape tot ce duc șoferii în afară s-ar putea rezolva '
            'mai repede intern. Calea spre interior nu este de aceea '
            'doar cea mai sigură, ci de cele mai multe ori și cea mai '
            'eficientă.',
          ),
          StepsBlock([
            'Vorbești mai întâi cu dispecerul — majoritatea problemelor '
                'sunt probleme de planificare și se rezolvă acolo',
            'Dacă nu vine nimic înapoi: te adresezi conducerii firmei, '
                'de preferat în scris, cu dată și incident concret',
            'La încălcări mai serioase: folosești canalul intern de '
                'raportare conform HinSchG',
            'Abia dacă intern nu se întâmplă nimic intră în discuție '
                'instituțiile externe — dar atunci obiectiv și cu fapte '
                'care pot fi dovedite',
          ]),
          DoDontBlock(
            doTitle: 'Permis și dorit',
            dos: [
              'Să spui că o tură nu poate fi dusă la capăt în mod '
                  'repetat',
              'Să semnalezi o defecțiune tehnică la vehicul — chiar și '
                  'repetat',
              'Să descrii un incident concret pe care l-ai trăit tu '
                  'însuți',
              'Să raportezi o încălcare prin canalul intern de '
                  'raportare',
              'Să insiști, dacă după o raportare nu se întâmplă nimic',
            ],
            dontTitle: 'Neacoperit',
            donts: [
              'Să faci afirmații despre care știi că nu sunt adevărate',
              'Să insulți sau să înjosești superiori ori colegi',
              'Să faci publice cifre, contracte sau evaluări interne',
              'Să răspândești zvonuri în grupuri de chat, fără să le '
                  'cunoști',
              'Să duci conflictele pe portaluri de recenzii sau rețele '
                  'sociale, înainte ca intern să fi fost măcar întrebat '
                  'cineva',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Exemplu de caz și listă de verificare',
        blocks: [
          RevealBlock(
            prompt: 'Exemplu de caz: În grupul de chat al șoferilor '
                'cineva scrie că firma nu plătește intenționat orele. '
                'Tu nu ai trăit asta niciodată, dar tocmai ești supărat '
                'pe planul tău de lucru și scrii: „Așa este, ne înșală '
                'pe toți sistematic." A doua zi circulă o captură de '
                'ecran a grupului. Cum se evaluează asta?',
            answer: 'Critic — nu din cauza criticii, ci din cauza '
                'formei. Ai făcut o afirmație factuală („ne înșală '
                'sistematic") pe care tu însuți nu o poți dovedi și nu '
                'ai trăit-o. Afirmațiile factuale conștient neadevărate '
                'nu sunt acoperite de libertatea de exprimare și pot '
                'avea consecințe de dreptul muncii, până la concedierea '
                'fără preaviz conform § 626 BGB; la defăimare se adaugă '
                '§ 186 StGB. Captura de ecran arată în plus că un grup '
                'închis nu este un spațiu protejat. Corect ar fi fost: '
                'să îți numești propriul caz — „Mie îmi lipsesc în '
                'iulie două ore, am raportat și până acum nu am '
                'răspuns" — și să îl duci la dispecer, la conducerea '
                'firmei sau la canalul intern de raportare. Această '
                'afirmație este adevărată, verificabilă și protejată de '
                'HinSchG. Rezultatul: aceeași nemulțumire, dar '
                'exprimată corect, nu îți poate dăuna.',
          ),
          ChecklistBlock(
            title: 'Înainte să duc ceva în afară',
            items: [
              'Știu din propria experiență că este adevărat',
              'Descriu incidentul obiectiv, fără insulte',
              'Nu dezvălui cifre, contracte sau evaluări interne',
              'Am ridicat problema mai întâi intern — dispecer, '
                  'conducerea firmei sau canalul de raportare',
              'Îmi este clar: a raporta nereguli reale este protejat, '
                  'a susține lucruri inventate nu',
            ],
          ),
        ],
      ),
    ],
  ),
];
