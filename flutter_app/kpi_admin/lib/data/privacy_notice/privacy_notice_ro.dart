// lib/data/privacy_notice/privacy_notice_ro.dart
//
// Informare privind protecția datelor pentru șoferi conform
// Art. 13 DSGVO — versiunea în limba română. Traducere 1:1 a versiunii
// germane master (`privacy_notice_de.dart`): aceleași secțiuni, aceeași
// ordine, aceleași blocuri.
//
// IMPORTANT: aceasta este o INFORMARE cu confirmare de luare la
// cunoștință, nu o declarație prin care șoferul permite o prelucrare.
// De aceea în tot textul: „am fost informat" / „am citit și am înțeles"
// — niciodată o formulare care sună a permisiune dată de șofer.
//
// Referințele juridice rămân în forma originală germană (Art. 6 Abs. 1
// lit. b DSGVO, § 26 BDSG, § 16 Abs. 2 ArbZG, § 147 AO …), cu o scurtă
// explicație în paranteză.

import '../safety_training/safety_blocks.dart';
import 'privacy_notice_content.dart';

const List<PrivacyNoticeSection> privacyNoticeSectionsRo = [
  // ══════════════════════════════════════════════════════════════ 1
  PrivacyNoticeSection(
    id: 'verantwortlich',
    title: 'Cine îți prelucrează datele',
    summary: 'Operatorul, persoana împuternicită și unde sunt stocate '
        'datele',
    blocks: [
      ParagraphBlock(
        'Ca să poți lucra în CoDriver, se prelucrează date despre tine. '
        'Conform Art. 13 DSGVO (Regulamentul general privind protecția '
        'datelor) ai dreptul să știi de la bun început care sunt aceste '
        'date, în ce scop sunt prelucrate, pe ce se întemeiază și cât '
        'timp rămân stocate. Exact asta scrie în paginile următoare.',
      ),
      SubheadBlock('Operatorul'),
      ParagraphBlock(
        'Operator pentru datele tale este angajatorul tău — Delivery '
        'Service Partner (DSP) la care ești angajat. Numele lui este '
        'scris sus, pe această pagină. La el te adresezi cu toate '
        'solicitările legate de datele tale; dacă a desemnat un '
        'responsabil cu protecția datelor, te poți adresa direct '
        'acestuia.',
      ),
      SubheadBlock('Cine operează software-ul'),
      ParagraphBlock(
        'CoDriver este pus la dispoziție de ARION Logistics GmbH. '
        'Aceasta prelucrează datele tale exclusiv din însărcinarea și '
        'după instrucțiunile angajatorului tău — ca persoană '
        'împuternicită conform Art. 28 DSGVO, în baza unui contract de '
        'împuternicire. Scopuri proprii nu urmărește cu datele tale.',
      ),
      SubheadBlock('Unde sunt stocate datele'),
      ParagraphBlock(
        'Datele se află la Google Firebase în Uniunea Europeană '
        '(regiunea Firestore eur3, centre de date Frankfurt și Belgia; '
        'Cloud Functions în europe-west3, Frankfurt). Ele sunt criptate '
        'în timpul transmiterii și în stocare. Un transfer către o țară '
        'terță din afara UE nu are loc.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Aceasta este o informare — nu o permisiune pe care o dai',
        text: 'Aici ești informat. Semnătura ta de la final confirmă '
            'exclusiv faptul că ai citit și ai înțeles această '
            'informare. Dacă datele tale pot fi prelucrate nu depinde '
            'de semnătura ta, ci de temeiurile juridice menționate la '
            'fiecare secțiune. De ce este așa scrie în ultima '
            'secțiune.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 2
  PrivacyNoticeSection(
    id: 'stammdaten',
    title: 'Datele tale de bază',
    summary: 'Nume, număr de personal, Transporter-ID și date de contact',
    blocks: [
      ParagraphBlock(
        'Fără un profil de șofer nimeni nu te poate planifica, nu îți '
        'poate atribui o tură și nu te poate contacta. Profilul tău '
        'este baza pentru tot ce urmează în aplicație.',
      ),
      SubheadBlock('Ce date'),
      BulletsBlock([
        'Prenumele și numele',
        'Transporter-ID — identificatorul tău în sistemul Amazon și, '
            'totodată, cheia ta în CoDriver',
        'Numărul de personal, dacă angajatorul tău a atribuit unul',
        'Adresa de e-mail de serviciu — ea este totodată contul tău de '
            'conectare',
        'Numărul de telefon, pentru a putea fi contactat în timpul '
            'turei',
        'Data nașterii și cetățenia, în măsura în care au fost preluate '
            'la onboarding sau din candidatura ta',
        'Fotografia de profil, dacă adaugi una',
        'Limba aleasă în aplicație',
        'Statutul raportului tău de muncă (activ, inactiv, plecat)',
      ]),
      SubheadBlock('În ce scop'),
      ParagraphBlock(
        'Pentru atribuirea clară a persoanei tale la ture, vehicule, '
        'timpi și dovezi, pentru comunicarea dintre tine și dispecerat '
        'și pentru administrarea accesului tău în aplicație.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Temeiul juridic',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (executarea contractului tău '
            'de muncă) coroborat cu § 26 Abs. 1 BDSG (prelucrarea '
            'datelor în scopurile raportului de muncă).',
      ),
      SubheadBlock('Cât timp'),
      ParagraphBlock(
        'Pe durata raportului de muncă și pe durata termenelor legale '
        'de păstrare. Ulterior profilul tău este șters sau blocat.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 3
  PrivacyNoticeSection(
    id: 'zeiterfassung',
    title: 'Pontajul și verificarea locației',
    summary: 'Pontarea cu verificare geofence — și ce anume nu se '
        'stochează',
    blocks: [
      ParagraphBlock(
        'Angajatorul tău este obligat prin lege să înregistreze timpul '
        'tău de lucru în mod obiectiv, fiabil și accesibil — așa scrie '
        'în § 16 ArbZG (Legea germană privind timpul de lucru) și în '
        'hotărârea Curții de Justiție a Uniunii Europene C-55/18. Când '
        'pontezi în CoDriver („Începe tura", „Pauză", „Încheie tura"), '
        'aplicația verifică dacă dispozitivul tău se află la locul de '
        'muncă convenit.',
      ),
      SubheadBlock('Ce date la fiecare pontare'),
      BulletsBlock([
        'Momentul, ca marcaj de timp al serverului',
        'Transporter-ID-ul tău',
        'Dacă ai activat permisiunea de locație pe dispozitivul tău',
        'Rezultatul verificării geofence: în interiorul sau în afara '
            'zonei hubului',
        'Identificatorul zonei hubului, de ex. „DBY5_main"',
        'Precizia determinării poziției, în metri',
        'Hub-ID și numărul de versiune al codului QR scanat',
        'Platforma dispozitivului și versiunea aplicației',
        'Adresa ta IP, stocată doar ca valoare hash SHA-256, niciodată '
            'în clar',
      ]),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Ce anume NU se stochează',
        text: 'Coordonatele tale GPS exacte nu se stochează. Ele sunt '
            'transmise o singură dată către server în momentul '
            'pontării, sunt evaluate acolo pentru verificarea geofence '
            'și apoi sunt eliminate. Rămâne doar răspunsul „a fost în '
            'zona hubului / nu a fost în zona hubului". Nu există '
            'urmărire a locației în fundal și niciun profil de mișcare '
            'între două pontări.',
      ),
      SubheadBlock('În ce scop'),
      BulletsBlock([
        'Documentarea cu siguranță juridică a timpului tău de lucru '
            'conform § 16 ArbZG',
        'Calcularea corectă a salariului și a asigurărilor sociale',
        'Protecția împotriva manipulării la pontare',
      ]),
      SubheadBlock('Permisiunea de locație este voluntară'),
      ParagraphBlock(
        'Dacă îi dai dispozitivului tău permisiunea de locație decizi '
        'singur și poți schimba asta oricând din setările '
        'dispozitivului. Fără permisiunea de locație poți ponta '
        'totuși — operațiunea este marcată atunci ca „locație '
        'neconfirmată" și este verificată manual de dispecerat. '
        'Dezavantaje de dreptul muncii nu îți rezultă din asta.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Temeiul juridic',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (executarea contractului de '
            'muncă), Art. 6 Abs. 1 lit. c DSGVO (obligație legală din '
            '§ 16 ArbZG), Art. 6 Abs. 1 lit. f DSGVO (interes legitim '
            'în împiedicarea manipulării) și § 26 BDSG.',
      ),
      SubheadBlock('Cât timp'),
      TableBlock(
        headers: ['Date', 'Păstrare', 'Temei'],
        rows: [
          ['Pontări individuale', '2 ani', '§ 16 Abs. 2 ArbZG'],
          ['Valori lunare (plan/realizat/sold)', '6 ani', '§ 147 AO'],
          ['Jurnalul de modificări', '2 ani', 'Trasabilitate'],
          ['Cereri de corecție', '2 ani', 'Trasabilitate'],
        ],
      ),
      SubheadBlock('Nicio decizie automată despre tine'),
      ParagraphBlock(
        'O decizie automatizată cu efect juridic conform Art. 22 DSGVO '
        'nu are loc. Indicațiile aplicației, de exemplu despre o pauză '
        'depășită, sunt pur informative; despre urmări decide '
        'întotdeauna un om. Înainte de introducerea pontajului a fost '
        'realizată o evaluare a impactului asupra protecției datelor '
        'conform Art. 35 DSGVO; riscul rămas a fost apreciat ca fiind '
        'scăzut, pentru că nu se stochează nici coordonate brute, nici '
        'profiluri de mișcare.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 4
  PrivacyNoticeSection(
    id: 'academy',
    title: 'DA Academy — instruiri și dovezi',
    summary: 'Rezultatele testelor, certificatele și semnătura ta pe ele',
    blocks: [
      ParagraphBlock(
        'În DA Academy parcurgi instructaje și cursuri — de exemplu '
        'instructajul de securitate, Green Book, instruirea privind '
        'protecția datelor sau instrucțiunile de lucru. Angajatorul tău '
        'trebuie să poată dovedi că ai fost instruit.',
      ),
      SubheadBlock('Ce date'),
      BulletsBlock([
        'Ce curs ai început și ai încheiat și când anume',
        'Rezultatul testului final: punctajul obținut, valoarea '
            'procentuală, promovat sau nepromovat, numărul de încercări',
        'Data promovării și expirarea valabilității',
        'Limba în care ai parcurs cursul',
        'Semnătura ta olografă, ca fișier imagine',
        'PDF-ul de dovadă generat din aceasta, cu nume, număr de '
            'personal, Transporter-ID, dată și semnătură',
        'Confirmările pentru fiecare instrucțiune de lucru și regulă',
      ]),
      SubheadBlock('În ce scop'),
      ParagraphBlock(
        'Pentru dovedirea instruirii față de autorități, față de '
        'asociația profesională de asigurare și față de client, pentru '
        'urmărirea instruirilor de reîmprospătare scadente și pentru '
        'îndeplinirea obligației de responsabilitate a angajatorului '
        'tău.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Temeiul juridic',
        text: 'Art. 6 Abs. 1 lit. c DSGVO (obligație legală din dreptul '
            'securității muncii și al protecției datelor, între altele '
            '§ 12 ArbSchG, § 4 DGUV Vorschrift 1, Art. 5 Abs. 2 și '
            'Art. 32 DSGVO), Art. 6 Abs. 1 lit. b DSGVO (executarea '
            'contractului de muncă) și § 26 BDSG.',
      ),
      SubheadBlock('Cât timp'),
      ParagraphBlock(
        'Pe durata raportului de muncă și pe durata termenelor legale '
        'de păstrare. Dovezile privind instruirile se păstrează cel '
        'puțin atât timp cât sunt necesare pentru dovedirea față de '
        'autorități.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 5
  PrivacyNoticeSection(
    id: 'dokumente',
    title: 'Documentele tale',
    summary: 'Permis de conducere, act de identitate, permis de ședere '
        'și alte dovezi',
    blocks: [
      ParagraphBlock(
        'Pentru activitatea de șofer trebuie să existe anumite dovezi și '
        'ele trebuie să fie valabile. Tu sau dispeceratul le depuneți în '
        'profilul tău de șofer.',
      ),
      SubheadBlock('Ce date'),
      BulletsBlock([
        'Permisul de conducere — față și verso',
        'Cartea de identitate sau pașaportul',
        'Permisul de ședere și autorizația de muncă, dacă sunt necesare',
        'Numărul de identificare fiscală',
        'Dovada asigurării sociale',
        'Contractul de muncă',
        'Datele de expirare și de valabilitate ale acestor documente',
      ]),
      SubheadBlock('În ce scop'),
      ParagraphBlock(
        'Pentru verificarea dacă poți fi repartizat în activitate — mai '
        'ales controlul permisului de conducere, ca obligație a '
        'deținătorului vehiculului care îi revine angajatorului —, '
        'pentru îndeplinirea obligațiilor de înregistrare, fiscale și '
        'de asigurări sociale și pentru o atenționare din timp, înainte '
        'ca un document să expire.',
      ),
      CalloutBlock(
        tone: CalloutTone.warning,
        title: 'Grijă deosebită',
        text: 'Documentele de identitate conțin informații sensibile. '
            'Ele sunt vizibile doar pentru tine și pentru dispeceratul '
            'firmei tale, se află criptate în UE și nu sunt transmise '
            'terților, în afară de cazul în care o autoritate le cere '
            'în temei legal.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Temeiul juridic',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (executarea contractului de '
            'muncă), Art. 6 Abs. 1 lit. c DSGVO (obligații legale, '
            'între altele § 21 StVG răspunderea deținătorului '
            'vehiculului, dreptul privind șederea, dreptul fiscal și '
            'cel al asigurărilor sociale), Art. 6 Abs. 1 lit. f DSGVO '
            '(interes legitim în capacitatea de repartizare) și '
            '§ 26 BDSG.',
      ),
      SubheadBlock('Cât timp'),
      ParagraphBlock(
        'Pe durata raportului de muncă și pe durata termenelor legale '
        'de păstrare.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 6
  PrivacyNoticeSection(
    id: 'abwesenheiten',
    title: 'Absențe, concediu și concedii medicale',
    summary: 'Cereri, aprobări și certificate de incapacitate de muncă',
    blocks: [
      ParagraphBlock(
        'Concediul, concediul medical și alte absențe le anunți în '
        'aplicație; dispeceratul decide asupra lor și planifică în '
        'consecință.',
      ),
      SubheadBlock('Ce date'),
      BulletsBlock([
        'Tipul absenței — concediu, boală, concediu fără plată și alte '
            'motive',
        'Perioada de la … până la și numărul de zile',
        'Statusul: solicitat, aprobat, respins',
        'Comentariul tău la cerere și răspunsul dispeceratului',
        'Dreptul tău la concediu și partea deja consumată',
        'Certificatul de incapacitate de muncă încărcat, dacă depui '
            'unul',
      ]),
      CalloutBlock(
        tone: CalloutTone.warning,
        title: 'Concediile medicale sunt protejate în mod special',
        text: 'Se înregistrează doar FAPTUL că ești în incapacitate de '
            'muncă și pentru ce perioadă. Un diagnostic nu trebuie să '
            'îl indici, iar certificatul destinat angajatorului nici nu '
            'conține unul. Datele privind sănătatea sunt date speciale '
            'conform Art. 9 DSGVO și sunt consultate doar de persoanele '
            'care au efectiv nevoie de ele pentru plata în continuare a '
            'salariului și pentru planificare.',
      ),
      SubheadBlock('În ce scop'),
      ParagraphBlock(
        'Pentru planificarea activității, pentru calcularea dreptului '
        'la concediu și a plății în continuare a salariului și pentru '
        'dovada față de instituțiile de asigurări sociale.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Temeiul juridic',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (executarea contractului de '
            'muncă), Art. 6 Abs. 1 lit. c DSGVO (între altele BUrlG și '
            'EntgFG), iar pentru datele privind incapacitatea de muncă '
            'Art. 9 Abs. 2 lit. b DSGVO coroborat cu § 26 Abs. 3 BDSG '
            '(exercitarea drepturilor și obligațiilor din dreptul '
            'muncii și din dreptul securității sociale).',
      ),
      SubheadBlock('Cât timp'),
      ParagraphBlock(
        'Pe durata raportului de muncă și pe durata termenelor legale '
        'de păstrare. Certificatele de incapacitate de muncă se șterg '
        'imediat ce nu mai sunt necesare pentru plata în continuare a '
        'salariului și ca dovadă.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 7
  PrivacyNoticeSection(
    id: 'planung',
    title: 'Planificarea turelor și a valurilor',
    summary: 'Cine, când, pe ce val, pe ce rută și cu ce vehicul '
        'conduce',
    blocks: [
      ParagraphBlock(
        'Dispeceratul planifică în fiecare zi cine lucrează, în ce val '
        'pornești și cu ce vehicul ești pe drum. Acest plan este vizibil '
        'pentru tine și pentru dispecerat.',
      ),
      SubheadBlock('Ce date'),
      BulletsBlock([
        'Repartizarea ta pe zile — planificat, liber, absență',
        'Ora valului și ora de start',
        'Ruta, respectiv turul atribuit',
        'Vehiculul atribuit, cu numărul de înmatriculare',
        'Confirmarea luării la cunoștință a planului tău',
        'Modificările planului și cine le-a făcut',
        'Sarcinile și mesajele care îți sunt atribuite, împreună cu '
            'confirmarea de citire',
      ]),
      SubheadBlock('În ce scop'),
      ParagraphBlock(
        'Pentru organizarea activității zilnice, pentru atribuirea '
        'vehiculului și a rutei și pentru trasabilitatea cine a condus '
        'ce tur și când.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Temeiul juridic',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (executarea contractului de '
            'muncă) și Art. 6 Abs. 1 lit. f DSGVO (interes legitim '
            'într-un flux de lucru funcțional), fiecare coroborat cu '
            '§ 26 BDSG.',
      ),
      SubheadBlock('Cât timp'),
      ParagraphBlock(
        'Pe durata raportului de muncă și pe durata termenelor legale '
        'de păstrare.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 8
  PrivacyNoticeSection(
    id: 'scorecard',
    title: 'Date de performanță din Scorecard',
    summary: 'Indicatori privind siguranța, calitatea și livrarea',
    blocks: [
      ParagraphBlock(
        'Clientul pune la dispoziție săptămânal indicatori despre '
        'activitatea ta de livrare. CoDriver citește această Scorecard '
        'și ți-o afișează ție și dispeceratului.',
      ),
      SubheadBlock('Ce date'),
      BulletsBlock([
        'Indicatori de siguranță precum scorul de conducere FICO, '
            'evenimentele de viteză la 100 de tururi și utilizarea '
            'Mentor',
        'Indicatori de conformitate precum controlul vehiculului și '
            'respectarea timpilor de lucru',
        'Indicatori de calitate precum cota de livrare, trimiterile '
            'nelivrate și cota de pierderi',
        'Indicatori privind calitatea livrării, precum fotografia ca '
            'dovadă de predare și respectarea regulilor de contactare',
        'Feedbackul clienților și escaladările',
        'Evaluarea generală pe săptămână și evoluția ei',
      ]),
      SubheadBlock('În ce scop'),
      ParagraphBlock(
        'Pentru îndeplinirea contractului dintre angajatorul tău și '
        'client, pentru identificarea riscurilor de siguranță, pentru '
        'instruire țintită și pentru feedback către tine.',
      ),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Niciun automatism peste capul tău',
        text: 'Dintr-un indicator nu decurge automat o măsură. '
            'Evaluările și discuțiile le poartă întotdeauna un om, iar '
            'tu îți poți expune punctul de vedere. O decizie '
            'automatizată conform Art. 22 DSGVO nu are loc.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Temeiul juridic',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (executarea contractului de '
            'muncă) și Art. 6 Abs. 1 lit. f DSGVO (interes legitim în '
            'siguranța rutieră, asigurarea calității și îndeplinirea '
            'obligațiilor contractuale față de client), coroborat cu '
            '§ 26 BDSG.',
      ),
      SubheadBlock('Cât timp'),
      ParagraphBlock(
        'Pe durata raportului de muncă și pe durata termenelor legale '
        'de păstrare.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 9
  PrivacyNoticeSection(
    id: 'empfaenger',
    title: 'Cine vede datele tale',
    summary: 'Destinatari din interiorul și din afara firmei',
    blocks: [
      SubheadBlock('În firmă'),
      BulletsBlock([
        'Conducerea angajatorului tău',
        'Dispeceratul și dispecerii autorizați de acesta — fiecare doar '
            'pentru propria firmă',
        'Tu însuți: propriile date le vezi oricând în aplicație',
      ]),
      SubheadBlock('În afara firmei'),
      BulletsBlock([
        'Google Ireland/Google LLC ca prestator de hosting (persoană '
            'împuternicită, servere în UE)',
        'ARION Logistics GmbH ca operatoare a CoDriver (persoană '
            'împuternicită)',
        'Consultanța fiscală și serviciul de salarizare, în măsura în '
            'care angajatorul tău le folosește — fiecare în baza unui '
            'contract de împuternicire',
        'Clientul, în măsura în care indicatorii din Scorecard provin '
            'oricum de acolo',
        'Autoritățile, instituțiile de asigurări sociale și asociația '
            'profesională de asigurare — doar dacă un temei legal le '
            'îndreptățește la asta',
      ]),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Nu sunt vândute, nu sunt folosite pentru publicitate',
        text: 'Datele tale nu sunt vândute, nu sunt folosite pentru '
            'publicitate și nu sunt transmise unor terți care ar vrea '
            'să le folosească în scopuri proprii.',
      ),
      SubheadBlock('De unde provin datele'),
      ParagraphBlock(
        'Cele mai multe date provin de la tine însuți — din candidatura '
        'ta, din onboarding și din utilizarea zilnică a aplicației. '
        'Indicatorii din Scorecard provin de la client, iar datele de '
        'plan și de tură de la dispecerat.',
      ),
      SubheadBlock('Trebuie să furnizezi datele?'),
      ParagraphBlock(
        'Unele informații sunt necesare pentru ca raportul de muncă să '
        'poată fi executat — de exemplu numele, permisul de conducere '
        'și timpii de lucru. Fără ele nu poți fi repartizat în '
        'activitate. Alte informații, de exemplu fotografia de profil, '
        'sunt voluntare; din asta nu îți rezultă niciun dezavantaj.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 10
  PrivacyNoticeSection(
    id: 'rechte',
    title: 'Drepturile tale',
    summary: 'Acces, rectificare, ștergere, opoziție și plângere',
    blocks: [
      ParagraphBlock(
        'Față de angajatorul tău, în calitate de operator, ai '
        'următoarele drepturi. Exercitarea lor este gratuită și din '
        'asta nu îți rezultă niciun dezavantaj.',
      ),
      BulletsBlock([
        'Acces (Art. 15 DSGVO): Poți afla dacă și ce date despre tine '
            'sunt prelucrate și poți cere o copie a acestora.',
        'Rectificare (Art. 16 DSGVO): Datele greșite trebuie să poți '
            'cere să fie corectate, iar cele incomplete completate — '
            'pentru pontări există în acest scop cererea de corecție '
            'din aplicație.',
        'Ștergere (Art. 17 DSGVO): Datele care nu mai sunt necesare și '
            'nu fac obiectul unei obligații de păstrare se șterg la '
            'cerere.',
        'Restricționarea prelucrării (Art. 18 DSGVO): Dacă este în '
            'dispută dacă datele sunt corecte sau dacă pot fi '
            'prelucrate, poți cere ca ele să fie doar stocate până la '
            'clarificare.',
        'Portabilitatea datelor (Art. 20 DSGVO): Datele pe care le-ai '
            'pus la dispoziție le primești într-un format uzual, care '
            'poate fi citit automat.',
        'Opoziție (Art. 21 DSGVO): Împotriva prelucrărilor întemeiate '
            'pe un interes legitim — de exemplu verificarea geofence '
            'automată — poți face opoziție din motive legate de '
            'situația ta particulară.',
        'Plângere (Art. 77 DSGVO): Te poți plânge oricând la o '
            'autoritate de supraveghere a protecției datelor.',
      ]),
      SubheadBlock('La cine te adresezi'),
      ParagraphBlock(
        'Mai întâi la angajatorul tău — DSP-ul al cărui nume este scris '
        'sus, pe această pagină. Dacă a desemnat un responsabil cu '
        'protecția datelor, te poți adresa direct acestuia; datele de '
        'contact ți le comunică conducerea. Pentru o plângere este '
        'competentă autoritatea de supraveghere a protecției datelor '
        'din landul federal în care firma ta își are sediul; te poți '
        'adresa și autorității de la domiciliul tău sau de la locul '
        'presupusei încălcări.',
      ),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Cât de repede primești răspuns',
        text: 'La o cerere, operatorul trebuie în principiu să îți '
            'răspundă în termen de o lună. Doar în cazuri complicate '
            'poate prelungi termenul și trebuie să te informeze despre '
            'asta.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 11
  PrivacyNoticeSection(
    id: 'bedeutung',
    title: 'Ce înseamnă confirmarea ta',
    summary: 'De ce ești informat aici și nu permiți ceva',
    blocks: [
      ParagraphBlock(
        'Imediat semnezi. Ca să fie clar ce semnezi: confirmi exclusiv '
        'faptul că ai citit și ai înțeles această informare. Prin ea nu '
        'permiți nicio prelucrare și nu eliberezi nimic.',
      ),
      SubheadBlock('De ce este important'),
      ParagraphBlock(
        'Într-un raport de muncă te afli într-o relație de dependență '
        'față de angajatorul tău. O declarație prin care ai permite o '
        'prelucrare cu greu ar fi vreodată cu adevărat voluntară — și '
        'ai putea să o retragi oricând, ceea ce ar face imposibile '
        'pontajul sau calculul salariilor. De aceea munca ta în '
        'CoDriver nu se întemeiază pe o astfel de declarație, ci pe '
        'ceea ce se aplică oricum: executarea contractului tău de muncă '
        '(Art. 6 Abs. 1 lit. b DSGVO), obligațiile legale ale '
        'angajatorului tău (Art. 6 Abs. 1 lit. c DSGVO) și interesele '
        'legitime ale firmei (Art. 6 Abs. 1 lit. f DSGVO), fiecare '
        'coroborat cu § 26 BDSG.',
      ),
      DoDontBlock(
        doTitle: 'Asta confirmi',
        dos: [
          'Am fost informat conform Art. 13 DSGVO despre prelucrarea '
              'datelor mele.',
          'Am citit și am înțeles această informare privind protecția '
              'datelor.',
          'Știu la cine mă adresez cu întrebări și cereri.',
        ],
        dontTitle: 'Asta nu confirmi',
        donts: [
          'Nicio permisiune pentru o prelucrare — temeiurile juridice '
              'sunt indicate la fiecare secțiune.',
          'Nicio renunțare la drepturile tale din Art. 15 până la '
              'Art. 21 DSGVO.',
          'Nicio renunțare la dreptul tău de a face plângere conform '
              'Art. 77 DSGVO.',
        ],
      ),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Și dacă se schimbă ceva?',
        text: 'Dacă această informare se modifică în conținut, numărul '
            'versiunii ei crește și ți se prezintă din nou la '
            'următoarea conectare. Astfel știi întotdeauna despre ce ai '
            'fost informat — și când.',
      ),
      ParagraphBlock(
        'Confirmarea în sine este și ea documentată: se stochează '
        'Transporter-ID-ul tău, numărul versiunii, data și ora, limba '
        'acestei vizualizări, precum și PDF-ul de dovadă cu semnătura '
        'ta. Temeiul pentru asta este obligația de responsabilitate '
        'conform Art. 5 Abs. 2 DSGVO.',
      ),
    ],
  ),
];
