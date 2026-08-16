// lib/data/safety_training/ride_along_content_ro.dart
//
// Conținutul instruirii Ride Along — versiunea română.
// Structura este identică cu versiunea germană (master): capitolele
// ra1–ra5, aceleași folii, aceleași blocuri și aceleași valori.
//
// „Ride Along" este cursa de însoțire de două zile pentru șoferii noi:
// ziua 1 cu un număr mai mic de opriri, ziua 2 cu semnificativ mai
// multe. Antrenorul parcurge o listă de verificare, confirmă fiecare
// punct și dă la final un feedback; fișa se predă ca fotografie
// dispecerului responsabil.
//
// Scopul acestei instruiri: PREGĂTIREA. Cine o parcurge înainte nu aude
// pentru prima dată temele celor două zile, ci poate întreba țintit și
// poate folosi conștient cursa de însoțire.
//
// Compatibil cu mai mulți operatori: fără nume de persoane, fără nume
// de stații, fără cifre specifice unei firme drept regulă. Numărul de
// opriri, orele din Waiting Area, începutul programului și partea de
// parcare sunt indicații ale stației respective — le comunică
// antrenorul. Instrumentele firmei, cum ar fi pontajul, apar doar ca
// exemplu („de ex. Kenjo"). Pot rămâne concrete: instrumentele Amazon
// (Flex, Mentor, ATLAS, Scorecard), aplicația CoDriver, regulile de
// pauză conform § 4 ArbZG și Green Book conform § 1 alin. 6 FPersV —
// toate trei sunt valabile în orice firmă. Pentru această temă nu
// există ilustrații, de aceea `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> rideAlongContentRo = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ra1',
    title: 'Ce este Ride Along',
    summary: 'Două zile de cursă însoțită: scopul, desfășurarea, cine '
        'participă și cum se evaluează',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Două zile alături de un șofer cu experiență',
        blocks: [
          ParagraphBlock(
            'Ride Along este cursa ta de însoțire la început: două zile '
            'de lucru în care un șofer cu experiență te însoțește ca '
            'antrenor. Nu înveți tura dintr-o prezentare, ci exact acolo '
            'unde ea se desfășoară — în stație, în Loading Area și pe '
            'stradă.',
          ),
          FactsBlock([
            FactItem('2 zile', 'cursă însoțită cu un antrenor'),
            FactItem('Ziua 1', 'număr mai mic de opriri — în multe firme '
                'în jur de 20'),
            FactItem('Ziua 2', 'semnificativ mai multe opriri — în multe '
                'firme în jur de 70'),
          ]),
          ParagraphBlock(
            'Cele două zile se construiesc una peste alta. În prima zi '
            'accentul cade pe procese: cum ajungi în stație, ce aplicații '
            'pornești și când, cum se încarcă, când este pauza. În a doua '
            'zi cantitatea crește semnificativ, iar tu conduci și livrezi '
            'singur — antrenorul te însoțește, dar nu preia.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Numerele de opriri sunt valori orientative',
            text: 'Câte opriri sunt prevăzute efectiv în ziua 1 și în ziua '
                '2 stabilește firma ta, respectiv stația ta. Frecvent sunt '
                'în jur de 20 în prima zi și în jur de 70 în a doua — '
                'obligatorie este însă doar indicația pe care ți-o dă '
                'antrenorul tău sau dispecerul tău responsabil.',
          ),
          BulletsBlock([
            'Ambele zile se desfășoară pe contul tău propriu, nu pe cel '
                'al antrenorului',
            'Opririle contează ca muncă reală, nu ca exercițiu pe uscat',
            'Antrenorul explică, arată și apoi te lasă să faci singur',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Pe scurt',
            text: 'Ride Along este integrarea ta în activitatea reală. La '
                'final trebuie să poți conduce o tură singur — acesta este '
                'etalonul după care se orientează totul.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Cine participă și cine ce face',
        blocks: [
          ParagraphBlock(
            'La Ride Along participă trei roluri. Dacă știi cine de ce '
            'răspunde, nu întrebi persoana greșită și nu pierzi timp.',
          ),
          TableBlock(
            headers: ['Rol', 'Sarcină'],
            rows: [
              [
                'Tu',
                'Conduci, livrezi, întrebi, pui mâna — ambele zile pe '
                    'contul tău propriu',
              ],
              [
                'Antrenor',
                'Șofer cu experiență: explică fiecare punct, arată cum se '
                    'face, te observă, bifează lista de verificare și '
                    'semnează',
              ],
              [
                'Dispecer',
                'Planifică cele două zile, este persoana de contact la '
                    'probleme și primește la final fotografia listei de '
                    'verificare',
              ],
            ],
          ),
          ParagraphBlock(
            'Antrenorul nu este șeful tău și nici examinatorul tău în '
            'sensul unei autorități. Este colegul care cunoaște stația cel '
            'mai bine. Tocmai de aceea el este adresa potrivită pentru '
            'orice întrebare care îți vine în cele două zile — inclusiv '
            'pentru cea care ți se pare banală.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Întrebările nu costă nimic',
            text: 'O întrebare la Ride Along este ieftină. Aceeași '
                'întrebare în săptămâna a treia, singur pe tură, cu o rută '
                'plină în față, este scumpă.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de verificare și feedbackul',
        blocks: [
          ParagraphBlock(
            'Antrenorul parcurge o fișă fixă — lista de verificare Ride '
            'Along. Pe ea scrie, pentru fiecare dintre cele două zile, ce '
            'trebuie să fi fost explicat și arătat: de la inspecția '
            'vehiculului, trecând prin regulile de pauză, până la coletele '
            'cu parolă. Fiecare punct se confirmă, fiecare zi se încheie '
            'cu dată și semnătură.',
          ),
          BulletsBlock([
            'Lista de verificare este dovada că ai fost instruit',
            'Ea te protejează și pe tine: ce este bifat ți-a fost explicat',
            'După a doua zi antrenorul dă un feedback despre prestație și '
                'abilitățile de conducere',
          ]),
          ParagraphBlock(
            'Nu este un examen cu ghilotină. Nimeni nu se așteaptă ca în '
            'prima zi să conduci tura ca un șofer cu trei ani de '
            'experiență. Dar se evaluează: antrenorul notează cum '
            'lucrezi, iar fișa ajunge la firmă. Cine gândește vizibil '
            'împreună, este punctual și acceptă indicațiile primește un '
            'feedback bun — chiar dacă este lent.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Diferența care contează',
            text: 'Nu se evaluează dacă știi totul, ci dacă ești dispus să '
                'înveți și dacă iei regulile în serios. Greșelile sunt '
                'normale. Să primești de două ori explicații pentru o '
                'greșeală și totuși să o ignori nu este.',
          ),
          RevealBlock(
            prompt: 'Studiu de caz: în prima zi încurci de două ori '
                'ordinea coletelor de pe containerul rulant și ai nevoie '
                'de mult mai mult timp pentru opririle tale decât era '
                'planificat. Ești sigur că Ride Along este compromis. Este '
                'adevărat?',
            answer: 'Nu. Exact pentru asta există prima zi. Antrenorul '
                'așteaptă ritm abia în a doua zi, și atunci doar în parte, '
                'iar cu adevărat în săptămânile care urmează. Ce evaluează '
                'el în prima zi este altceva: întrebi când nu ești sigur? '
                'Faci aceeași greșeală și a treia oară? Sortezi după aceea '
                'mai ordonat, din proprie inițiativă? Cine își recunoaște '
                'greșeala și procedează conștient altfel la următorul '
                'container rulant lasă o impresie mai bună decât cineva '
                'care este rapid și nu pune nimic sub semnul întrebării.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Listă de verificare: capitolul 1',
        blocks: [
          ChecklistBlock(
            title: 'Ce rețin din capitolul 1',
            items: [
              'Ride Along înseamnă două zile de lucru cu un antrenor',
              'Ziua 1 mai puține opriri, ziua 2 semnificativ mai multe — '
                  'numărul exact îl stabilește firma mea (frecvent în jur '
                  'de 20 și în jur de 70)',
              'Ambele zile se desfășoară pe contul meu propriu',
              'Antrenorul explică, arată și mă lasă să fac singur',
              'El bifează o listă de verificare și semnează pentru fiecare '
                  'zi',
              'După ziua 2 primesc un feedback despre prestație și '
                  'abilitățile de conducere',
              'Este integrare, dar se evaluează — disponibilitatea de a '
                  'învăța contează mai mult decât ritmul',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'O frază pentru cele două zile',
            text: '„Mai bine întreb o dată în plus decât o dată în minus — '
                'pentru asta există aceste două zile."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ra2',
    title: 'Prima zi',
    summary: 'Primele opriri, pornirea aplicațiilor, inspecția, Loading '
        'Area, pauzele și cheia vehiculului',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Primele opriri pe contul tău propriu',
        blocks: [
          ParagraphBlock(
            'Prima zi are un număr minim de opriri pe care trebuie să le '
            'fi condus și livrat — pe contul tău propriu. El este ținut '
            'intenționat mic (în multe firme în jur de 20); numărul '
            'obligatoriu ți-l spune antrenorul pentru stația ta. În ziua 1 '
            'nu este vorba despre cantitate, ci despre faptul că fiecare '
            'mișcare iese o dată corect.',
          ),
          ParagraphBlock(
            'Important este contul propriu. Nu cel al antrenorului, nu un '
            'acces colectiv. Tot ce livrezi în această zi merge pe numele '
            'tău — exact așa cum va conta și mai târziu. Numai așa văd '
            'antrenorul și firma cum arată livrarea ta în realitate.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Fără acces nu există Ride Along',
            text: 'Dacă dimineața contul tău nu funcționează, spune-o '
                'imediat — înainte de plecare, nu la prima oprire. Un '
                'acces nelămurit costă toată ziua.',
          ),
          SubheadBlock('Aplicația CoDriver'),
          ParagraphBlock(
            'CoDriver este aplicația firmei — aplicația în care citești '
            'chiar acum. Ea este separată de instrumentele Amazon: Amazon '
            'conduce tura, CoDriver tot ce ține de munca ta în firmă. '
            'Antrenorul o parcurge cu tine în prima zi.',
          ),
          BulletsBlock([
            'Planul de ture și Wave-Plan: când lucrezi și în ce val '
                'pornești',
            'Anunțarea absențelor și a concediilor medicale',
            'DA Academy: instruiri ca aceasta, plus instrucțiunile de lucru',
            'Mesajele și notificările firmei',
            'Anunțarea accidentelor și a daunelor',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Reține',
            text: 'Aplicațiile Amazon conduc tura. CoDriver conduce '
                'raportul tău de muncă. Ai nevoie zilnic de amândouă, și '
                'amândouă trebuie văzute o dată complet în ziua 1.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Sosirea: program, partea de parcare, Waiting Area',
        blocks: [
          ParagraphBlock(
            'Ziua nu începe cu prima oprire, ci cu sosirea la stație. '
            'Trei lucruri ți le pune antrenorul la suflet în prima zi, '
            'pentru că se repetă în fiecare zi de lucru.',
          ),
          SubheadBlock('1 — Programul de lucru'),
          ParagraphBlock(
            'Tura ta are un început fix. El este trecut în planul de ture '
            'din CoDriver, iar „început" înseamnă: la această oră ești '
            'gata de lucru la stație — nu pe drum într-acolo. Orele '
            'concrete ale stației tale ți le spune antrenorul, ele diferă '
            'în funcție de locație și de val.',
          ),
          SubheadBlock('2 — Partea de parcare'),
          ParagraphBlock(
            'Fiecare stație are o regulă privind locul unde pot sta '
            'autoturismele private și partea pe care se aliniază '
            'furgonetele. Nu este o șicană: în curte manevrează multe '
            'vehicule în același timp, adesea cu spatele și cu vizibilitate '
            'proastă. Cine parchează greșit blochează un culoar de '
            'circulație sau stă în unghiul mort al celui care manevrează. '
            'Antrenorul îți arată partea valabilă pentru tine.',
          ),
          SubheadBlock('3 — Orele din Waiting Area'),
          ParagraphBlock(
            'Waiting Area este zona în care aștepți până când sunt '
            'strigate containerul tău rulant sau poziția ta de încărcare. '
            'Pentru asta există intervale fixe pe fiecare val. Cine stă '
            'acolo prea devreme înfundă zona; cine ajunge prea târziu își '
            'ratează apelul și împinge tot valul în spate. Orele exacte '
            'pentru stația ta ți le spune antrenorul în prima zi — '
            'notează-ți-le.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Cele trei date pe care ar trebui să ți le notezi',
            text: 'Începutul turei, partea de parcare și fereastra ta din '
                'Waiting Area. Aceste trei informații îți trebuie din ziua '
                'următoare în fiecare dimineață — și atunci nu te mai '
                'întreabă nimeni.',
          ),
          RevealBlock(
            prompt: 'Studiu de caz: ajungi punctual la poartă la începutul '
                'turei, dar apoi ai nevoie de zece minute pentru un loc de '
                'parcare, pentru că ai căutat pe partea greșită. În Waiting '
                'Area ajungi astfel prea târziu. Cât de grav este?',
            answer: 'Mai grav decât pare. Apelul din Waiting Area este '
                'cadențat: dacă îți ratezi fereastra, aluneci în urma '
                'celorlalți șoferi din valul tău. Containerul tău rulant '
                'așteaptă, vehiculul tău blochează eventual o poziție, iar '
                'startul tău se decalează cu mai mult decât cele zece '
                'minute pe care le-ai pierdut. De aceea partea de parcare '
                'și ora din Waiting Area merg împreună: „punctual la '
                'poartă" nu este același lucru cu „punctual în Waiting '
                'Area". Include în calcul timpul pentru parcare și pentru '
                'mers pe jos.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Startul: pontajul, Mentor și Flex',
        blocks: [
          ParagraphBlock(
            'Trei sisteme trebuie să funcționeze la începutul turei — și '
            'anume la timp și în această ordine. Fiecare are alt scop și '
            'fiecare provoacă necazuri dacă este pornit prea târziu.',
          ),
          StepsBlock([
            'Pontajul firmei tale (de ex. Kenjo) — pontarea la începutul '
                'turei. Ce nu pornești aici nu este timp de lucru plătit '
                'și lipsește mai târziu din decontul tău. Ce sistem '
                'folosește firma ta îți arată antrenorul.',
            'Mentor — aplicația Amazon pentru stilul de condus: trebuie să '
                'funcționeze înainte de a pleca. Ea îți înregistrează '
                'stilul de condus și livrează datele pentru scorul tău.',
            'Flex — aplicația Amazon de livrare: aici primești ruta, '
                'scanezi coletele și documentezi fiecare livrare.',
          ]),
          SubheadBlock('Cele 4 ore ale aplicației Mentor'),
          ParagraphBlock(
            'Mentor nu merge la nesfârșit: aplicația înregistrează de '
            'fiecare dată în jur de patru ore la rând. După aceea trebuie '
            'să o repornești, altfel restul turei tale rămâne '
            'neînregistrat. Exact aceasta este cea mai frecventă greșeală '
            'de începător — aplicația a fost pornită corect dimineața, dar '
            'nu a fost reactivată după pauza de prânz. Antrenorul îți '
            'arată în prima zi după ce recunoști că Mentor mai rulează.',
          ),
          FactsBlock([
            FactItem('4 h', 'durata de înregistrare a aplicației Mentor'),
            FactItem('înainte de plecare', 'pornește Mentor — nu abia pe '
                'drum'),
            FactItem('după pauză', 'verifică Mentor și pornește-l din nou'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Cea mai frecventă greșeală din prima zi',
            text: 'Flex merge, Mentor nu. Atunci îți conduci ruta, dar '
                'stilul tău de condus nu este înregistrat — iar timpul '
                'lipsă în Mentor se observă în firmă la fel ca o valoare '
                'proastă.',
          ),
          RevealBlock(
            prompt: 'Studiu de caz: observi la ora 14 că Mentor nu mai '
                'merge de la pauză. Ce faci — mergi mai departe până la '
                'finalul turei și mâine faci mai bine, sau reacționezi '
                'imediat?',
            answer: 'Reacționezi imediat: oprești la următorul loc sigur, '
                'repornești Mentor, mergi mai departe. Greșeala la '
                'îndemână este să crezi că o jumătate de zi fără '
                'înregistrare nu contează, pentru că oricum ai condus '
                'cuminte. Nu este așa: pentru firmă o lacună arată ca o '
                'lacună — nu ca o conducere bună. Iar mersul mai departe '
                'înseamnă să faci lacuna mai mare cu fiecare oră. '
                'Anunță-l suplimentar pe antrenorul tău sau pe dispecerul '
                'tău responsabil, ca lacuna să fie explicabilă.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Inspecția vehiculului și Loading Area',
        blocks: [
          SubheadBlock('Inspecția vehiculului'),
          ParagraphBlock(
            'Înainte de plecare vehiculul este verificat — și încă o dată '
            'după tură. Inspecția este o verificare vizuală cu '
            'documentare: faci o dată ocolul furgonetei, te uiți la '
            'fiecare parte, verifici funcțiile și consemnezi ce vezi.',
          ),
          BulletsBlock([
            'Tur exterior: caroserie, bare de protecție, oglinzi, geamuri '
                '— fiecare lovitură și fiecare zgârietură',
            'Anvelope: profil, deteriorări vizibile, impresia de presiune',
            'Lumini: faza scurtă, stopuri, semnalizatoare, lumina de mers '
                'înapoi',
            'Habitaclu și compartiment de marfă: curățenie, piese libere, '
                'peretele despărțitor',
            'Dotare: triunghi reflectorizant, vestă reflectorizantă, trusă '
                'de prim ajutor',
            'Kilometrajul și nivelul de carburant, respectiv de încărcare',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'De ce contează inspecția DINAINTE de cursă',
            text: 'O daună pe care o documentezi înainte este o daună '
                'preexistentă. Aceeași daună, nedocumentată, este seara '
                'dauna ta. Cele două minute de tur sunt cea mai ieftină '
                'asigurare a zilei tale de lucru.',
          ),
          SubheadBlock('Încărcarea containerului rulant în Loading Area'),
          ParagraphBlock(
            'În Loading Area stă containerul tău rulant cu coletele rutei '
            'tale. Cum îl muți în furgonetă îți decide toată ziua: cine '
            'încarcă nesortat caută la fiecare oprire — iar asta se adună '
            'peste o tură plină la ore întregi.',
          ),
          BulletsBlock([
            'Încarcă în ordinea rutei: ce iese primul intră ultimul și '
                'stă în față',
            'Coletele grele jos, cele ușoare sus — nu invers',
            'Asigură încărcătura: nimic nu are voie să alunece în față la '
                'frânare',
            'Nu stivui nimic pe culoar sau în fața ușii glisante',
            'Coletele speciale (parolă, ATLAS, gabarit mare) se pun separat '
                'și la îndemână',
            'Pune containerul rulant gol înapoi unde îi este locul — nu-l '
                'lăsa oriunde',
          ]),
          DoDontBlock(
            doTitle: 'Așa procedezi corect',
            dos: [
              'La încărcare gândește-te deja care este prima oprire',
              'La ridicare îndoaie genunchii, ține greutatea aproape de '
                  'corp',
              'Întreabă atunci când nu știi unde aparține un colet',
            ],
            dontTitle: 'Asta te costă timp mai târziu',
            donts: [
              'Să arunci totul înăuntru și să „sortezi pe drum"',
              'Să pui colete pe peretele despărțitor sau în zona șoferului',
              'Să lași containerul rulant în mijlocul culoarului de '
                  'circulație',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Pauzele, cheia și încuierea automată',
        blocks: [
          SubheadBlock('Pauzele: 30 și 45 de minute'),
          ParagraphBlock(
            'Există două durate de pauză, iar care este valabilă pentru '
            'tine depinde exclusiv de timpul tău de lucru din ziua '
            'respectivă. Spre deosebire de orele din Waiting Area sau de '
            'numărul de opriri, aceasta nu este o indicație a stației tale, '
            'ci lege: § 4 Arbeitszeitgesetz (ArbZG — legea germană a '
            'timpului de lucru). Regula este astfel identică în orice '
            'firmă și nu este negociabilă.',
          ),
          FactsBlock([
            FactItem('30 min', 'la peste 6 și până la 9 ore de lucru'),
            FactItem('45 min', 'la peste 9 ore de lucru'),
            FactItem('15 min', 'cea mai mică fracțiune de pauză care se '
                'ia în calcul'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 4 ArbZG — temeiul legal',
            text: 'Legea germană a timpului de lucru prevede la peste 6 ore '
                'de lucru cel puțin 30 de minute de pauză, iar la peste 9 '
                'ore cel puțin 45 de minute. Este interzis expres să '
                'lucrezi mai mult de 6 ore fără pauză.',
          ),
          ParagraphBlock(
            'Pauza poate fi împărțită, dar fiecare parte trebuie să dureze '
            'cel puțin 15 minute — de două ori câte 15 minute dau deci '
            'pauza de 30, de trei ori câte 15 minute pe cea de 45. Cinci '
            'minute printre picături nu contează. Important este în plus: '
            'pauza trebuie să fi început înainte de a se împlini șase ore '
            'de muncă, nu abia la finalul turei.',
          ),
          ParagraphBlock(
            'De ce trebuie înregistrată: pauza ta nu este timp de lucru '
            'plătit, iar firma trebuie să poată dovedi că ai făcut-o cu '
            'adevărat. De aceea se trece în pontaj — nu din neîncredere, '
            'ci pentru că o pauză nedocumentată este considerată la un '
            'control drept pauză neefectuată. Aceasta este o încălcare '
            'pentru care răspunde firma. Antrenorul îți arată exact unde o '
            'introduci.',
          ),
          SubheadBlock('Încuierea automată și cheia'),
          ParagraphBlock(
            'Multe furgonete Sprinter se încuie automat: dacă ușa se '
            'închide sau vehiculul pornește din loc, închiderea centralizată '
            'se blochează singură. Este o protecție împotriva furtului '
            'pentru încărcătura ta — și exact acesta este motivul pentru '
            'care cheia rămâne mereu la tine.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Cheia stă pe corpul tău',
            text: 'Nu pe scaun, nu în torpedou, nu în buzunarul geacii care '
                'stă în vehicul. Cheia în buzunarul pantalonilor sau pe '
                'șnurul de la centură — de fiecare dată când cobori.',
          ),
          RevealBlock(
            prompt: 'Studiu de caz: oprești scurt, lași cheia în contact, '
                'iei două colete și închizi ușa glisantă cu piciorul. '
                'Închiderea centralizată se blochează. Ce se întâmplă acum?',
            answer: 'Stai cu două colete în fața unei furgonete încuiate, '
                'în care se află cheia ta, telefonul tău, restul '
                'încărcăturii și de obicei și actele tale. Ziua este '
                'compromisă: ai nevoie de ajutor de la stație sau de un '
                'lăcătuș, toată ruta ta stă pe loc, iar coletele din '
                'vehicul nu mai ajung azi la clienții lor. Greșeala la '
                'îndemână este „doar zece secunde lipsesc" — încuierea '
                'automată nu face diferența între zece secunde și zece '
                'minute. De aceea este valabil fără excepție: scoți cheia, '
                'cheia pe corp, abia apoi cobori.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Finalul turei: închiderea Flex și inspecția',
        blocks: [
          ParagraphBlock(
            'Ziua nu se termină la ultima oprire, ci la stație. Două '
            'lucruri stau acolo pe lista de verificare a antrenorului — și '
            'amândouă sunt uitate cu plăcere, pentru că ești obosit și vrei '
            'acasă.',
          ),
          StepsBlock([
            'Închide aplicația Flex ca la carte: finalizează ruta, predă '
                'returile și închide aplicația — nu pune pur și simplu '
                'telefonul în buzunar.',
            'Inspecția vehiculului după cursă: același tur ca dimineața, '
                'acum cu ochii pe daune noi, kilometraj și nivelul de '
                'carburant, respectiv de încărcare.',
            'Predă vehiculul curat și gol, controlează compartimentul de '
                'marfă — niciun colet nu rămâne înăuntru.',
            'Pontează ieșirea în pontajul firmei tale (de ex. Kenjo) și '
                'predă cheia acolo unde îi este locul.',
          ]),
          ParagraphBlock(
            'Inspecția finală este perechea inspecției de dimineață. Abia '
            'prin amândouă împreună este clar ce s-a întâmplat cu vehiculul '
            'în acea zi — și ce nu. Dacă lipsește cea de seara, o daună nu '
            'mai poate fi atribuită nimănui a doua zi dimineață, iar '
            'următorul șofer preia problema ta sau tu pe a lui.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Formulă pentru finalul programului',
            text: 'Flex închis, tur în jurul vehiculului, compartiment gol, '
                'pontat la ieșire, cheia predată. Abia atunci este final de '
                'program.',
          ),
          ChecklistBlock(
            title: 'Ce rețin din ziua 1',
            items: [
              'Numărul de opriri stabilit de firma mea, pe contul meu '
                  'propriu',
              'Cunosc aplicația CoDriver și știu ce găsesc în ea',
              'Îmi cunosc începutul turei, regula de parcare a stației mele '
                  'și fereastra mea din Waiting Area',
              'Pornesc pontajul (de ex. Kenjo), Mentor și Flex la timp și '
                  'în această ordine',
              'Știu că Mentor înregistrează în jur de 4 ore și că după '
                  'aceea trebuie repornit',
              'Fac inspecția vehiculului înainte și după tură',
              'Încarc containerul rulant în ordinea rutei, greul jos, '
                  'încărcătura asigurată',
              'Cunosc regula de pauză conform § 4 ArbZG: 30 de minute de '
                  'la peste 6 ore, 45 de minute de la peste 9 ore — și o '
                  'înregistrez',
              'Cheia rămâne mereu pe corp, pentru că Sprinterul se încuie '
                  'automat',
              'La final închid Flex, fac inspecția și pontez ieșirea',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ra3',
    title: 'A doua zi',
    summary: 'Semnificativ mai multe opriri făcute singur, Scorecard, '
        'protecția vehiculului, Green Book, colete speciale, alimentare '
        'și încărcare',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Semnificativ mai multe opriri — tu conduci, tu livrezi',
        blocks: [
          ParagraphBlock(
            'În a doua zi raportul se inversează. Numărul de opriri crește '
            'semnificativ — în multe firme până la circa 70, obligatorie '
            'este indicația stației tale — iar tu efectuezi opririle '
            'singur: tu conduci, tu navighezi, tu scanezi, tu livrezi, tu '
            'documentezi. Antrenorul stă alături și intervine doar când '
            'este necesar.',
          ),
          FactsBlock([
            FactItem('mai multe', 'opriri decât în ziua 1 — numărul '
                'conform indicației firmei'),
            FactItem('singur', 'condusul și livrarea — antrenorul doar '
                'însoțește'),
            FactItem('1 zi', 'până la prima tură pe cont propriu'),
          ]),
          ParagraphBlock(
            'Acesta este sensul propriu-zis al celei de-a doua zile: să fi '
            'trăit o dată cum se simte o tură plină — cu ritmul, cu '
            'sortatul dintre opriri, cu clienții care nu deschid și cu '
            'senzația că ceasul merge. Dacă ai făcut asta o dată cu cineva '
            'alături, prima ieșire de unul singur este doar pe jumătate '
            'atât de mare.',
          ),
          BulletsBlock([
            'Nu lăsa pe altul ce poți face singur — chiar dacă merge mai '
                'încet',
            'Întreabă imediat după fiecare oprire care ți s-a părut ciudată',
            'Reține ce trebuie să-ți notezi: coduri, procese, persoane de '
                'contact',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Etalonul zilei 2',
            text: 'Nu „reușește tura în timp record", ci „ar putea fi '
                'trimis mâine singur". Exact asta apreciază antrenorul.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Scorecard, calitate și prestație',
        blocks: [
          ParagraphBlock(
            'Munca ta se măsoară. Scorecard-ul Amazon rezumă săptămână de '
            'săptămână cum ați condus tu și firma ta. În a doua zi '
            'antrenorul îți explică ce valori stau în el și cum le '
            'influențezi — pentru că aproape fiecare valoare ia naștere '
            'din ceva ce ai tu însuți în mână.',
          ),
          BulletsBlock([
            'Calitatea livrării: coletul a fost predat sau lăsat în locul '
                'corect și documentat curat?',
            'Stilul de condus din Mentor: frânare, accelerare, viraje, '
                'folosirea telefonului, centura',
            'Fiabilitatea: start punctual, rută parcursă complet, predare '
                'corectă',
            'Reacțiile clienților: reclamațiile și laudele ajung tot în '
                'evaluare',
          ]),
          ParagraphBlock(
            'Calitatea și prestația sunt însă două lucruri diferite, care '
            'sunt adesea confundate. Prestația este cantitatea: câte opriri '
            'în cât timp. Calitatea este cât de curat a fost încheiată '
            'fiecare oprire în parte. Un șofer cu prestație mare și '
            'calitate proastă provoacă mai multă muncă decât economisește — '
            'fiecare reclamație costă firma de câteva ori minutul economisit '
            'la început.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Cea mai scumpă greșeală este greșeala rapidă',
            text: 'Un colet lăsat în locul greșit și plecarea rapidă mai '
                'departe îți economisește un minut și costă firma o '
                'reclamație, o cercetare și, la nevoie, valoarea mărfii.',
          ),
          RevealBlock(
            prompt: 'Studiu de caz: clientul nu deschide, mai ai 30 de '
                'opriri în față. Pui coletul în spatele pubelei și faci '
                'repede o fotografie a ușii de la intrare. De ce este asta '
                'o problemă?',
            answer: 'Dublu. În primul rând locul de depunere nu corespunde '
                'cu ceea ce ai documentat — dacă clientul nu găsește '
                'coletul, livrarea ta rămâne nedovedită. În al doilea rând, '
                'depunerea în spatele unei pubele nu este un loc potrivit: '
                'se vede din stradă și pubela se golește. Corect este să '
                'mergi pe drumul prevăzut — vecin, loc sigur de depunere cu '
                'acordul clientului sau returnare — și să documentezi exact '
                'ce ai făcut cu adevărat. Minutul economisit stă împotriva '
                'unei reclamații care te costă pe tine, pe client și pe '
                'firmă considerabil mai mult.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Protecția vehiculului, accidente, curățenie și '
            'întreținere',
        blocks: [
          ParagraphBlock(
            'Furgoneta este locul tău de muncă și cea mai scumpă unealtă '
            'pe care ți-o încredințează firma. Cum te porți cu ea este în '
            'a doua zi un punct separat pe lista de verificare — în trei '
            'părți.',
          ),
          SubheadBlock('1 — Evitarea daunelor'),
          BulletsBlock([
            'Mersul cu spatele doar când nu se poate altfel — și atunci '
                'încet, cu privirea pe ambele oglinzi',
            'În situații neclare coboară și uită-te, în loc să ghicești',
            'Intrările înguste, crengile joase, parcările subterane și '
                'stâlpișorii sunt cele mai frecvente surse de daune',
            'Păstrează distanța și frânează anticipat — asta menajează '
                'simultan vehiculul și Scorecard-ul',
          ]),
          SubheadBlock('2 — Dacă totuși se întâmplă ceva'),
          StepsBlock([
            'Oprește, asigură locul: avarii, vestă reflectorizantă, '
                'triunghi.',
            'Îngrijește răniții, la vătămări corporale sună întotdeauna la '
                '112.',
            'Nu schimba nimic, fă fotografii: situația de ansamblu, '
                'daunele, numerele de înmatriculare, împrejurimile.',
            'La vehicul străin sau vinovăție neclară cheamă poliția — și '
                'la daune mici.',
            'Informează imediat dispecerul tău responsabil și anunță '
                'incidentul în CoDriver.',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Niciodată nu pleca mai departe',
            text: 'Și o zgârietură mică pe un vehicul străin este, fără '
                'anunțare, părăsirea locului accidentului — o faptă '
                'penală. Un bilețel sub ștergătorul de parbriz nu este '
                'suficient din punct de vedere juridic.',
          ),
          SubheadBlock('3 — Curățenie și întreținere'),
          BulletsBlock([
            'Golește zilnic cabina: fără gunoi, fără sticle, fără hârtii',
            'Mătură compartimentul de marfă și verifică dacă au rămas '
                'colete uitate',
            'Ține geamurile și oglinzile curate — vizibilitatea proastă '
                'este o problemă de siguranță, nu un defect estetic',
            'Anunță lichidele de exploatare și zgomotele suspecte, nu le '
                'ignora',
          ]),
          RevealBlock(
            prompt: 'Studiu de caz: la manevrare atingi un stâlpișor. Pe '
                'vehicul este o zgârietură, altceva nimic, nimeni nu a '
                'văzut. O anunți?',
            answer: 'Da, întotdeauna și chiar în aceeași zi. Nu este vorba '
                'despre vinovăție, ci despre atribuire: o zgârietură '
                'anunțată este un incident care se prelucrează. Aceeași '
                'zgârietură, găsită a doua zi dimineață de alt șofer la '
                'inspecția lui, este o daună nelămurită — și asta devine '
                'neplăcut pentru toți cei implicați, inclusiv pentru tine, '
                'pentru că bănuiala se îndreaptă la final tot spre ultimul '
                'utilizator. Greșeala la îndemână este „nu se observă". Se '
                'observă la următoarea inspecție, pentru asta există ea.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Green Book / registrul de control',
        blocks: [
          ParagraphBlock(
            'Green Book este registrul tău de control al curselor: fișele '
            'zilnice de control conform § 1 alin. 6 '
            'Fahrpersonalverordnung (FPersV — regulamentul german privind '
            'personalul de conducere auto), cu care dovedești timpii de '
            'conducere, întreruperile cursei și perioadele de odihnă. Nici '
            'aceasta nu este o regulă a stației tale, ci dreptul în '
            'vigoare privind personalul de conducere — este identic în '
            'orice firmă. Nu este nicidecum o verificare a vehiculului: în '
            'Green Book este vorba exclusiv despre timpi, despre timpii '
            'tăi.',
          ),
          BulletsBlock([
            'O fișă pe zi de lucru, completată de mână și semnată',
            'Se trec începutul și sfârșitul cursei, kilometrajele, timpii '
                'de conducere, întreruperile și perioadele de odihnă',
            'Se completează imediat, nu se reconstruiește seara din '
                'memorie',
            'Înregistrările din ultimele zile se poartă cu tine și trebuie '
                'prezentate la un control',
          ]),
          ParagraphBlock(
            'Antrenorul îți arată în a doua zi unde stă fișa, cum se '
            'completează și unde se predau fișele terminate. Restul nu '
            'stă aici: în DA Academy există pentru asta instruirea proprie '
            '„Green Book" — cu datele obligatorii, timpii de conducere și '
            'de odihnă, obligația de a le purta cu tine și consecințele în '
            'caz de încălcări. Parcurge-o, în loc să vrei să reții '
            'detaliile în a doua zi, în vehicul.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Însăși înregistrarea este obligația',
            text: 'Dacă nu există nimic, nimeni nu poate constata la un '
                'control dacă ai respectat timpii. O fișă lipsă este de '
                'aceea la fel de mult o încălcare ca un timp de conducere '
                'depășit.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Cazuri speciale: colete cu parolă și colete ATLAS',
        blocks: [
          SubheadBlock('Coletele cu parolă'),
          ParagraphBlock(
            'Unele trimiteri pot fi predate doar contra unei parole sau a '
            'unui cod pe care clientul l-a primit dinainte. Tipice sunt '
            'mărfurile de valoare și tot ce este deosebit de expus '
            'furtului. Flex îți semnalează acest lucru la oprire.',
          ),
          BulletsBlock([
            'Clientul îți spune sau îți arată codul — tu nu îl citești cu '
                'voce tare și nu îl numești primul',
            'Fără cod corect nu există predare: nicio excepție, nici măcar '
                'la vecin',
            'Nicio depunere la ușă și nicio lăsare pe casa scării',
            'Dacă nu se potrivește codul, trimiterea se returnează pe '
                'drumul prevăzut și se documentează',
          ]),
          SubheadBlock('Coletele ATLAS'),
          ParagraphBlock(
            'Trimiterile ATLAS sunt de asemenea colete tratate special: '
            'ele urmează un proces propriu, cu pași suplimentari în '
            'scanare și în predare. Pentru tine este important să le '
            'recunoști, să le depozitezi separat și la îndemână și să nu '
            'scurtezi procesul prevăzut. Cum arată concret procesul în '
            'stația ta și ce pași îți impune Flex îți arată antrenorul în '
            'a doua zi, pe un colet real.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Coletele speciale se sortează primele',
            text: 'Pe niciunul dintre cele două tipuri de colete nu vrei '
                'să-l cauți la oprire sub alte 90 de trimiteri. Pune-le '
                'separat, conștient, la încărcare și reține-le poziția.',
          ),
          RevealBlock(
            prompt: 'Studiu de caz: clientul este acolo, dar nu are parola '
                'la îndemână — „este doar o formalitate, vă semnez orice". '
                'Ce faci?',
            answer: 'Nu predai. Parola este dovada că destinatarul este '
                'într-adevăr destinatarul — exact de aceea a fost '
                'atribuită. O semnătură, un act de identitate pe care nu ai '
                'voie să-l verifici sau vorbele bune nu o înlocuiesc. '
                'Greșeala la îndemână este să pui amabilitatea deasupra '
                'procesului: dacă trimiterea este anunțată mai târziu ca '
                'neprimită, predarea fără cod rămâne ca greșeală pe numele '
                'tău. Roagă clientul să caute codul în confirmarea '
                'comenzii. Dacă nu îl găsește, iei coletul înapoi cu tine '
                'și documentezi corect.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Alimentarea, încărcarea și finalul turei',
        blocks: [
          SubheadBlock('Alimentarea'),
          ParagraphBlock(
            'Furgoneta se alimentează după regulile firmei: la stațiile '
            'prevăzute, cu cardul de carburant al vehiculului și cu '
            'combustibilul corect. Bonul aparține vehiculului sau se predă '
            'acolo unde îți arată antrenorul. Când alimentezi ține de o '
            'regulă simplă: nu abia când se aprinde martorul de rezervă, '
            'ci astfel încât următorul șofer să nu fie nevoit să plece cu '
            'rezervorul aproape gol.',
          ),
          BulletsBlock([
            'Tipul corect de combustibil — o alimentare greșită '
                'imobilizează vehiculul zile întregi',
            'Cardul de carburant aparține vehiculului, nu geantei tale '
                'personale',
            'Păstrează bonul și predă-l așa cum este prevăzut',
            'Motorul oprit, fumatul interzis, telefonul deoparte la pompă',
          ]),
          SubheadBlock('Încărcarea electrică'),
          ParagraphBlock(
            'La un vehicul electric încărcarea ia locul alimentării — cu o '
            'diferență importantă: încărcarea durează mai mult și de aceea '
            'trebuie planificată. Antrenorul îți arată unde se încarcă, ce '
            'cablu aparține vehiculului și ce nivel de încărcare trebuie '
            'să aibă vehiculul la finalul turei.',
          ),
          BulletsBlock([
            'Ține nivelul de încărcare sub observație și planifică din '
                'timp, nu reacționa abia la autonomie rămasă',
            'După conectare verifică dacă procesul de încărcare a pornit '
                'cu adevărat',
            'Înfășoară cablul ordonat și nu lăsa locuri de împiedicare',
            'La finalul turei predă vehiculul așa cum prevede firma — '
                'următorul șofer pornește cu el',
          ]),
          SubheadBlock('Finalul turei — ca în ziua 1'),
          StepsBlock([
            'Închide aplicația Flex ca la carte, finalizează ruta, predă '
                'returile.',
            'Inspecția vehiculului după cursă: tur, daune noi, kilometraj, '
                'nivel de carburant, respectiv de încărcare.',
            'Compartimentul de marfă gol și curat, cabina făcută ordine.',
            'Pontează ieșirea, predă cheia, completează Green Book.',
          ]),
          ChecklistBlock(
            title: 'Ce rețin din ziua 2',
            items: [
              'Numărul semnificativ mai mare de opriri stabilit de firma '
                  'mea — pe care le conduc și le livrez singur',
              'Știu ce scrie în Scorecard și cum îl influențez',
              'Calitatea nu este același lucru cu prestația — contează '
                  'amândouă',
              'Evit activ daunele și anunț imediat orice incident',
              'Țin vehiculul curat pe dinăuntru și pe dinafară',
              'Cunosc Green Book conform § 1 alin. 6 FPersV și fac pentru '
                  'el instruirea proprie din DA Academy',
              'Coletele cu parolă le predau doar contra codului corect',
              'Coletele ATLAS le recunosc și urmez procesul prevăzut',
              'Cunosc regulile pentru alimentare și pentru încărcarea '
                  'electrică',
              'La final: închid Flex, fac inspecția, pontez ieșirea',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ra4',
    title: 'Încheierea și predarea',
    summary: 'Feedbackul antrenorului, semnăturile pentru fiecare zi și '
        'predarea fișei ca fotografie',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Feedbackul antrenorului',
        blocks: [
          ParagraphBlock(
            'După a doua zi antrenorul se așază cu tine și dă un feedback '
            'despre prestația ta și despre abilitățile tale de conducere. '
            'Nu este o sentință în două cuvinte, ci o evaluare: ce merge '
            'deja bine, la ce trebuie să lucrezi, la ce să fii deosebit de '
            'atent în săptămânile următoare.',
          ),
          BulletsBlock([
            'Stilul de condus: calmul, anticiparea, mersul cu spatele, '
                'descurcatul în locuri înguste',
            'Livrarea: grija, documentarea, relația cu clienții',
            'Organizarea: sortarea, simțul timpului, folosirea aplicațiilor',
            'Atitudinea la muncă: punctualitatea, întrebările, felul în '
                'care primești indicațiile',
          ]),
          ParagraphBlock(
            'Ia feedbackul în serios, dar nu personal. Este singura ocazie '
            'în care cineva te-a urmărit două zile întregi. Întreabă atunci '
            'când un punct îți este neclar, și întreabă concret: „Ce anume '
            'să fac altfel la mersul cu spatele?" îți aduce mai mult decât '
            'o încuviințare din cap.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Singura întrebare de la final',
            text: 'Întreabă-ți antrenorul la sfârșit: „Care este acel '
                'singur lucru la care să fiu deosebit de atent în prima '
                'mea săptămână singur?" Răspunsul este cel mai valoros '
                'lucru din cele două zile.',
          ),
          RevealBlock(
            prompt: 'Studiu de caz: în feedback se spune că ești prea '
                'ezitant la manevrare și că pierzi astfel timp. Tu '
                'consideri că ai fost pur și simplu precaut. Cum '
                'reacționezi?',
            answer: 'Întrebi în loc să te justifici. Prudența la manevrare '
                'este corectă — antrenorul înțelege prin „ezitant" de '
                'regulă altceva: că te gândești îndelung în loc să cobori '
                'și să te uiți scurt, sau că reiei manevra de mai multe '
                'ori acolo unde ar fi fost de ajuns o singură dare înapoi '
                'cu privirea pe ambele oglinzi. Cere un exemplu concret din '
                'ziua respectivă. Atunci ai un punct la care poți lucra cu '
                'adevărat, în loc de o evaluare pe care doar o aprobi din '
                'cap sau o respingi.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Fișa: data, numele, semnăturile',
        blocks: [
          ParagraphBlock(
            'Lista de verificare Ride Along este completă abia când datele '
            'din antet sunt corecte. Fără ele fișa este o hârtie cu bife '
            'și nu poate fi atribuită niciunei dovezi.',
          ),
          TableBlock(
            headers: ['Indicație', 'Ce se înțelege prin ea'],
            rows: [
              ['Data', 'Trecută separat pentru fiecare dintre cele două '
                  'zile'],
              ['Numele cursantului', 'Numele tău — noul șofer'],
              ['Numele instructorului', 'Numele antrenorului tău'],
              [
                'Semnătura',
                'De la antrenor, separat pentru fiecare zi — nu o singură '
                    'dată pentru amândouă',
              ],
            ],
          ),
          ParagraphBlock(
            'Faptul că se semnează pentru fiecare zi are un motiv: fiecare '
            'zi are propria listă de puncte. Dacă a doua zi cade sau se '
            'amână, rămâne totuși documentat curat ce s-a rezolvat în prima '
            'zi. Verifică de aceea singur, la finalul fiecărei zile, dacă '
            'data și semnătura sunt trecute.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Uită-te singur',
            text: 'Fișa este dovada integrării tale. Dacă lipsește o '
                'semnătură, lipsește dovada — iar ulterior așa ceva este '
                'mereu anevoios. O privire înainte de final de program '
                'ajunge.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Predarea: fotografie la dispecer',
        blocks: [
          ParagraphBlock(
            'La finalul celei de-a doua zile fișa completată se predă ca '
            'fotografie dispecerului tău responsabil. Cu asta Ride Along '
            'este încheiat formal și integrarea ta este documentată.',
          ),
          StepsBlock([
            'Pune fișa pe o suprafață plană, caută lumină bună.',
            'Fotografiază de sus, toată fișa în cadru, fără umbre și fără '
                'margini tăiate.',
            'Verifică dacă bifele, data, numele și semnăturile sunt '
                'lizibile.',
            'Predă fotografia dispecerului responsabil — pe calea pe care '
                'v-o indică antrenorul.',
            'Tratează fișa pe hârtie așa cum prevede firma ta: poate fi '
                'cerută.',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ilizibil înseamnă nepredat',
            text: 'O fotografie mișcată sau tăiată pe jumătate trebuie '
                'făcută din nou — și atunci poate că sunteți amândoi deja '
                'acasă. Uită-te o dată la ea înainte să o trimiți.',
          ),
          ChecklistBlock(
            title: 'Ce rețin din încheiere',
            items: [
              'După ziua 2 antrenorul dă un feedback despre prestație și '
                  'abilitățile de conducere',
              'La punctele neclare întreb concret',
              'Pe fișă stau data, numele cursantului și numele '
                  'instructorului',
              'Antrenorul semnează separat pentru fiecare zi',
              'Verific singur, la finalul fiecărei zile, dacă totul este '
                  'trecut',
              'Fișa se predă la finalul zilei 2 ca fotografie lizibilă '
                  'dispecerului responsabil',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ra5',
    title: 'Așa te pregătești',
    summary: 'Ce ar trebui să lămurești ÎNAINTE de ziua 1 — accesuri, '
        'echipament, planificarea timpului și întrebările tale',
    asset: '',
    slides: [
      SafetySlide(
        title: 'De lămurit dinainte: accesuri și tehnică',
        blocks: [
          ParagraphBlock(
            'Cel mai frecvent motiv pentru care o primă zi pornește prost '
            'nu este lipsa de cunoștințe, ci un acces care nu '
            'funcționează. Lămurește asta dinainte — atunci Ride Along-ul '
            'tău începe cu ceea ce contează cu adevărat.',
          ),
          BulletsBlock([
            'Contul tău propriu pentru livrare: datele de acces există și '
                'te-ai conectat o dată cu succes',
            'Pontajul firmei tale (de ex. Kenjo): acces configurat, știi '
                'cum pontezi intrarea și ieșirea',
            'Mentor și Flex: aplicații instalate, conectare testată, '
                'permisiuni acordate pentru locație și mișcare',
            'CoDriver: conectat, notificări permise',
            'Telefonul: încărcat, memorie suficientă, cablu de încărcare '
                'sau baterie externă pentru furgonetă',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Verifică în seara dinainte, nu dimineața',
            text: 'Resetarea unei parole durează la ora 20 cinci minute, '
                'iar la ora 6 în Waiting Area o jumătate de oră — dacă '
                'este cineva de găsit.',
          ),
          RevealBlock(
            prompt: 'Studiu de caz: în dimineața primei zile aplicația ta '
                'de livrare nu se conectează. Antrenorul așteaptă, valul '
                'pornește. Care este cea mai bună reacție?',
            answer: 'Spune imediat că accesul nu funcționează — și anume '
                'antrenorului, ca el să poată implica dispecerul tău '
                'responsabil. Greșeala la îndemână este să încerci mai '
                'departe în tăcere, ca să nu pari incapabil. Asta costă '
                'exact minutele în care problema ar mai fi rezolvabilă, iar '
                'la final mergi toată ziua pe contul antrenorului — cu '
                'ceea ce numărul minim de opriri pe contul tău propriu nu '
                'este îndeplinit, iar ziua trebuie repetată în cel mai rău '
                'caz. De aceea: anunță devreme, spune clar ce ai încercat '
                'deja.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Îmbrăcăminte, echipament și punctualitate',
        blocks: [
          SubheadBlock('Cu ce te îmbraci'),
          BulletsBlock([
            'Încălțăminte de protecție: pantof de lucru solid și închis — '
                'fără adidași, fără sandale',
            'Haine rezistente la vreme: ești toată ziua afară, chiar dacă '
                'dimineața pare încă uscat',
            'Libertate de mișcare: urci și cobori de sute de ori',
            'Vesta reflectorizantă la îndemână — ea stă în vehicul, dar '
                'trebuie să fie în capul tău',
          ]),
          SubheadBlock('Ce ai la tine'),
          BulletsBlock([
            'Permisul de conducere — fără el nu conduci, nici în prima zi',
            'Actul de identitate sau documentul de ședere, dacă firma îl '
                'cere',
            'Băutură și ceva de mâncare pentru pauză',
            'Pix și un carnețel mic sau o aplicație de notițe',
          ]),
          SubheadBlock('Punctualitatea'),
          ParagraphBlock(
            'Punctual înseamnă: gata de lucru la stație la începutul turei, '
            'nu sosind la poartă. Adaugă timpul pentru parcare, pentru '
            'drumul prin curte și pentru Waiting Area. Cine întârzie în '
            'prima zi decalează și valul antrenorului — iar asta rămâne '
            'ținută minte.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Regulă de bază pentru primele zile',
            text: 'Planifică drumul astfel încât să fii mai degrabă prea '
                'devreme acolo. Sfertul de oră câștigat îl folosești ca să '
                'te uiți în jur — toalete, Waiting Area, locuri de '
                'aliniere.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Întrebările tale — și lista de verificare dinainte',
        blocks: [
          ParagraphBlock(
            'Ai două zile la rând pe cineva lângă tine care știe tot ce '
            'trebuie să știi. Este o situație care nu se mai repetă așa. '
            'Greșeala pe care o fac aproape toți: nu își rețin întrebările '
            'și își amintesc de ele abia în săptămâna a doua, singuri în '
            'furgonetă.',
          ),
          BulletsBlock([
            'Scrie încă dinainte de ziua 1 ce vrei să afli — inclusiv '
                'fleacuri',
            'Notează răspunsurile în timpul turei, nu te baza pe memorie',
            'Nu fotografia nimic din datele clienților, dar notează '
                'procesele și persoanele de contact',
            'Întreabă la finalul fiecărei zile: „Ce nu am văzut încă '
                'astăzi?"',
          ]),
          ParagraphBlock(
            'Întrebări bune pentru Ride Along sunt de exemplu: când anume '
            'este fereastra mea din Waiting Area? Unde parchez personal? '
            'Cum recunosc dacă Mentor mai merge? Unde îmi înregistrez '
            'pauza? Cui anunț prima dată o daună? Unde predau Green Book? '
            'Ce fac dacă un client nu are codul la un colet cu parolă?',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'De ce ai făcut această instruire',
            text: 'Nu ca să știi deja totul la Ride Along, ci ca să '
                'cunoști noțiunile. Cine știe despre ce este vorba poate '
                'asculta — cine aude totul pentru prima dată poate doar să '
                'dea din cap.',
          ),
          RevealBlock(
            prompt: 'Studiu de caz: antrenorul îți explică dimineața zece '
                'lucruri unul după altul. Seara îți amintești trei dintre '
                'ele. De la ce a fost — de la tine?',
            answer: 'De la metodă, nu de la tine. Să primești explicații '
                'pentru zece procese noi unul după altul și să le reții nu '
                'funcționează la nimeni. Ce funcționează: să fi citit '
                'noțiunile o dată dinainte — exact pentru asta există '
                'această instruire — și să notezi pe parcurs. Două cuvinte '
                'cheie pe temă ajung ca să reconstruiești seara tot '
                'procesul. Iar ce mai lipsește în a doua zi întrebi țintit, '
                'în loc să speri că îți vine de la sine.',
          ),
          ChecklistBlock(
            title: 'Înainte de ziua 1 — de bifat singur',
            items: [
              'Datele de acces pentru contul meu propriu de livrare '
                  'testate',
              'Pontajul (de ex. Kenjo), Mentor, Flex și CoDriver instalate '
                  'și conectate',
              'Telefon încărcat, cablu de încărcare sau baterie externă în '
                  'bagaj',
              'Încălțăminte de protecție și haine rezistente la vreme '
                  'pregătite',
              'Permisul de conducere și documentele necesare luate cu mine',
              'Băutură și mâncare pentru pauză pregătite',
              'Pix și posibilitate de a nota la mine',
              'Drumul planificat — inclusiv parcarea și traseul spre '
                  'Waiting Area',
              'Întrebările mele pentru antrenor scrise',
              'Această instruire parcursă, ca să cunosc noțiunile',
            ],
          ),
        ],
      ),
    ],
  ),
];
