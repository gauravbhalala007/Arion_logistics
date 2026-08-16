// lib/data/safety_training/privacy_content_sq.dart
//
// Përmbajtja e trajnimit për mbrojtjen e të dhënave — versioni shqip.
// Struktura është identike me versionin gjerman (master,
// privacy_content_de.dart): kapitujt ds1–ds6, të njëjtat folie, të
// njëjtët blloqe dhe të njëjtat vlera. Çdo ndryshim strukturor bëhet
// gjithmonë më parë në master dhe pastaj pasqyrohet këtu.
//
// Ndërtimi si te Green Book-u: për çdo kapitull disa folie nga blloqe
// të tipizuara — referenca ligjore (CalloutTone.law), raste për të
// menduar (Reveal), Do/Don't dhe një listë kontrolli në fund të
// kapitullit. Për këtë temë nuk ka ilustrime, prandaj `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> privacyContentSq = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ds1',
    title: 'Pse mbrojtja e të dhënave të prek ty',
    summary: 'Të dhënat personale në përditshmërinë e dorëzimit dhe '
        'parimet e Art. 5 DSGVO',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Ti punon gjithë ditën me të dhëna të huaja',
        blocks: [
          ParagraphBlock(
            'Mbrojtja e të dhënave tingëllon si zyrë, dosje dhe juristë. '
            'Në të vërtetë, pothuajse askush nuk është aq afër të dhënave '
            'personale sa ti. Nga skanimi i parë në mëngjes deri te ndalesa '
            'e fundit në mbrëmje ke në dorë emra, adresa dhe numra '
            'telefoni të njerëzve të tjerë — dhe përveç tyre foto të '
            'dyerve të huaja.',
          ),
          ParagraphBlock(
            'Personale është çdo e dhënë me të cilën mund të identifikohet '
            'një person. Jo vetëm emri: edhe kombinimi i adresës, orës dhe '
            'përmbajtjes së pakos tregon diçka për një njeri. Pikërisht '
            'prandaj për to vlejnë rregulla.',
          ),
          BulletsBlock([
            'Emrat e marrësve dhe adresat në etiketë, skaner dhe listë',
            'Numrat e telefonit për kontakt para dorëzimit',
            'Nënshkrimet në skaner si konfirmim i marrjes',
            'Fotot si provë dorëzimi para derës',
            'Të dhënat e vendndodhjes së skanerit dhe të automjetit',
            'Të dhëna për fqinjët, te të cilët ke lënë një pako',
            'Udhëzime si „Pakon lëre pas koshit të plehrave" — edhe kjo '
                'është një informacion për mënyrën e banimit të një njeriu',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Shkurt',
            text: 'Gjithçka që mëson për një marrës, e ke mësuar vetëm '
                'sepse i sjell pakon. Për asgjë tjetër nuk ta kanë dhënë '
                'këtë informacion.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tre parime që vlejnë çdo ditë',
        blocks: [
          ParagraphBlock(
            'Art. 5 DSGVO (GDPR) përcakton gjashtë parime. Tre prej tyre '
            'vendosin praktikisht çdo ditë nëse po vepron drejt apo gabim. '
            'Në gjuhë të thjeshtë:',
          ),
          TableBlock(
            headers: ['Parimi', 'Çfarë do të thotë kjo për ty'],
            rows: [
              [
                'Kufizimi i qëllimit',
                'Të dhënat përdori vetëm për qëllimin për të cilin i ke '
                    'marrë: dorëzimin. Jo për gjëra private.',
              ],
              [
                'Minimizimi i të dhënave',
                'Mblidh dhe trego vetëm aq sa duhet. Asnjë foto më shumë '
                    'se duhet, asnjë listë më e gjatë se duhet.',
              ],
              [
                'Konfidencialiteti',
                'Ajo që sheh, mbetet te ti dhe në firmë. Jo në grupin e '
                    'chatit, jo në tryezën e kuzhinës, jo në internet.',
              ],
            ],
          ),
          ParagraphBlock(
            'Përveç tyre vijnë saktësia (të dhënat e gabuara korrigjohen, '
            'jo tërhiqen zvarrë), kufizimi i ruajtjes (asgjë nuk mbahet '
            'më gjatë se duhet) dhe llogaridhënia — pika e fundit e prek '
            'firmën dhe është arsyeja e këtij trajnimi.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Baza ligjore',
            text: 'Art. 5 Abs. 1 DSGVO kërkon ndër të tjera kufizimin e '
                'qëllimit (lit. b), minimizimin e të dhënave (lit. c) si '
                'dhe integritetin dhe konfidencialitetin (lit. f). Këto '
                'parime vlejnë për këdo që punon me të dhëna personale në '
                'emër të firmës — pra edhe për ty gjatë turit.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pse ekziston ky trajnim',
        blocks: [
          ParagraphBlock(
            'DSGVO-ja nuk shkruan askund fjalë për fjalë „punonjësit duhet '
            'të trajnohen". E kërkon megjithatë — vetëm përmes tre rrugëve '
            'të tjera. Prandaj je ulur këtu, dhe prandaj përfundimi '
            'dokumentohet.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Nga rrjedh detyrimi për trajnim',
            text: 'Art. 32 DSGVO e detyron firmën për masa teknike dhe '
                'organizative për sigurinë e përpunimit — punonjësit e '
                'trajnuar janë një masë e tillë. Art. 39 Abs. 1 lit. b '
                'DSGVO e përmend shprehimisht sensibilizimin dhe trajnimin '
                'si detyrë të përgjegjësit për mbrojtjen e të dhënave. Dhe '
                'Art. 5 Abs. 2 DSGVO kërkon që firma të mund ta provojë '
                'respektimin — llogaridhënia.',
          ),
          ParagraphBlock(
            'Autoritetet mbikëqyrëse e shohin këtë me kujdes gjatë një '
            'kontrolli. Mungesën e trajnimeve të punonjësve e vlerësojnë '
            'rregullisht si tregues se masat kanë qenë të pamjaftueshme — '
            'sidomos kur diçka ka ndodhur tashmë. Pas një incidenti me të '
            'dhënat, pyetja e parë është pothuajse gjithmonë: A ishin '
            'njerëzit të trajnuar, dhe a mund ta provoni?',
          ),
          BulletsBlock([
            'Trajnim bazë vjetor për të gjithë — përfundimi yt vlen '
                'dymbëdhjetë muaj',
            'Trajnim sipas rastit, kur diçka ndryshon ose kur ka ndodhur '
                'diçka',
            'Njohja e punonjësve të rinj para ditës së parë të tyre',
            'Dokumentimi i testit dhe i nënshkrimit si provë sipas '
                'Art. 5 Abs. 2 DSGVO',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Ku kalon vija në përditshmëri',
        blocks: [
          RevealBlock(
            prompt: 'Rast studimor: Në turin tënd ndodhet një pako për '
                'një futbollist të njohur të zonës. Në mbrëmje u tregon '
                'miqve në cilën rrugë banon ai — asgjë më shumë, asnjë '
                'emër në rrjetet sociale, vetëm mes miqsh. A është kjo '
                'shkelje e mbrojtjes së të dhënave?',
            answer: 'Po. Adresa është një e dhënë personale, dhe ti e '
                'njeh vetëm nga puna jote. T\'ua japësh të tjerëve shkel '
                'kufizimin e qëllimit (Art. 5 Abs. 1 lit. b DSGVO) dhe '
                'konfidencialitetin (lit. f). Gabimi i afërt është të '
                'mendosh se një rreth privat „nuk llogaritet" — DSGVO-ja '
                'nuk pyet sa i madh ishte publiku yt, por nëse i ke '
                'zbuluar të dhënat jashtë qëllimit. Nëse njëri nga miqtë '
                'e tu e tregon më tej, ti nuk ke më asnjë kontroll.',
          ),
          DoDontBlock(
            doTitle: 'Drejt',
            dos: [
              'Të dhënat e marrësve përdori vetëm për dorëzimin dhe lëri '
                  'pastaj në sistem',
              'Për pyetje rreth një dërgese drejtoji te dispeçeri ose '
                  'drejtoria e firmës',
              'Mbaje skanerin dhe listën e letrës ashtu që të tjerët të '
                  'mos mund të lexojnë',
              'Situatat e paqarta ngriji si temë në vend që të vendosësh '
                  'vetë',
            ],
            dontTitle: 'Gabim',
            donts: [
              'Të tregosh adresa ose emra në rrethin privat — as „vetëm '
                  'mes miqsh"',
              'T\'i bësh temë bisede personat e njohur ose dërgesat që '
                  'bien në sy',
              'Të kërkosh të dhëna marrësish nga kurioziteti, pa pasur '
                  'ndonjë detyrë për këtë',
              'Të mbështetesh te ideja se „këtë s\'e merr vesh njeri"',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista e kontrollit — Kapitulli 1',
        blocks: [
          ParagraphBlock(
            'Kaloji shkurt pikat. Nëse hezitohesh te ndonjëra, kthehu '
            'edhe një herë pas — në test vijnë pikërisht këto situata.',
          ),
          ChecklistBlock(
            title: 'Këtë e marr me vete nga Kapitulli 1',
            items: [
              'E di cilat të dhëna në turin tim janë personale',
              'I njoh kufizimin e qëllimit, minimizimin e të dhënave dhe '
                  'konfidencialitetin',
              'E di që të dhënat e marrësve nuk kanë vend në jetën private',
              'E di pse ky trajnim dokumentohet (Art. 5 Abs. 2 DSGVO)',
              'E kam të qartë se trajnimi përsëritet çdo vit',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ds2',
    title: 'Fotot dhe provat e dorëzimit',
    summary: 'Çfarë lejohet në foto, çfarë jo — dhe ku i takon fotos të '
        'jetë',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Fotoja ka saktësisht një qëllim',
        blocks: [
          ParagraphBlock(
            'Fotoja e dorëzimit duhet t\'i përgjigjet një pyetjeje të '
            'vetme: Ku ndodhet pakoja? Asgjë tjetër. Gjithçka që shkon '
            'përtej kësaj është më shumë informacion se duhet — dhe me '
            'këtë një shkelje e minimizimit të të dhënave.',
          ),
          ParagraphBlock(
            'Në praktikë do të thotë: kamera poshtë drejt pakos, aq afër '
            'sa të njihet vendi i lënies, dhe aq larg nga gjithçka që '
            'tregon njerëz ose i bën ata të identifikueshëm.',
          ),
          DoDontBlock(
            doTitle: 'Lejohet në foto',
            dos: [
              'Vetë pakoja në vendin e lënies',
              'Një pjesë muri, dere ose shkalle si referencë vendi',
              'Numri i shtëpisë, nëse duhet për identifikim',
              'Me leje lënieje: vendi i dakorduar i lënies',
            ],
            dontTitle: 'Nuk lejohet në foto',
            donts: [
              'Persona — as marrësi, as nga pas',
              'Targat e automjeteve të parkuara',
              'Dritare, ballkone dhe pamje brenda banesave',
              'Fëmijë, kafshë shtëpiake, vizitorë, fqinj në sfond',
              'Etiketa emrash të të tjerëve, kur nuk lidhen me dërgesën',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Baza ligjore',
            text: 'Art. 5 Abs. 1 lit. c DSGVO kërkon minimizimin e të '
                'dhënave: të dhënat duhet të jenë të përshtatshme për '
                'qëllimin dhe të kufizuara në masën e nevojshme. Një foto '
                'që tregon persona, targa ose ambiente brenda banesës '
                'shkon përtej qëllimit „provë dorëzimi". Për personat e '
                'fotografuar vlen përveç kësaj e drejta mbi imazhin e vet.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ku i takon fotos të jetë — dhe ku jo',
        blocks: [
          ParagraphBlock(
            'Po aq i rëndësishëm sa përmbajtja e fotos është vendi i '
            'ruajtjes. Fotoja krijohet në aplikacionin e punës dhe mbetet '
            'aty. Nuk ka çfarë kërkon në galerinë tënde private dhe aq më '
            'pak në një messenger.',
          ),
          BulletsBlock([
            'Fotografo vetëm në aplikacionin e punës — jo më parë me '
                'aplikacionin e kamerës dhe pastaj ngarko',
            'Asnjë kopje në galerinë private, asnjë ruajtje cloud e '
                'telefonit privat',
            'Asnjë dërgim me WhatsApp, Telegram, Signal ose një grup '
                'chati shoferësh',
            'Asnjë foto „për siguri" për vete — prova ndodhet në sistem',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Gabimi më i shpeshtë',
            text: 'Të fotografosh më parë me kamerën normale dhe pastaj '
                'ta ngarkosh foton në aplikacion. Kështu fotoja mbetet '
                'përgjithmonë në galerinë tënde private — shpesh edhe në '
                'një cloud jashtë vendit. Ky është një përpunim i '
                'palejueshëm, edhe nëse nuk ia tregon kurrë askujt.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Nëse dikush megjithatë del në foto',
        blocks: [
          ParagraphBlock(
            'Ndodh: Fqinja del nga dera pikërisht në momentin e shkrepjes, '
            'ose një fëmijë kalon nëpër foto. Nuk është dramë — për sa '
            'kohë vepron menjëherë.',
          ),
          StepsBlock([
            'Fshije foton menjëherë, para se ta mbyllësh ndalesën',
            'Fotografo sërish, kësaj here pa person në foto',
            'Nëse fotoja është ngarkuar tashmë: njofto dispeçerin ose '
                'drejtorinë e firmës, që të fshihet në sistem',
            'Nëse je i pasigurt nëse dikush njihet: më mirë raporto sesa '
                'shpreso',
          ]),
          RevealBlock(
            prompt: 'Rast studimor: E lë një pako në oborrin e pasmë. Në '
                'foto duket pakoja — dhe në sfond, përmes një dritareje '
                'deri në dysheme, një dhomë ndenjjeje me dy persona në '
                'divan. E ke mbyllur tashmë ndalesën dhe je në oborrin '
                'tjetër. Çfarë bën?',
            answer: 'E raporton. Fotoja tregon një ambient të brendshëm '
                'dhe persona të identifikueshëm — shkon kështu shumë '
                'përtej qëllimit „provë dorëzimi" dhe duhet hequr nga '
                'sistemi. Gabimi i afërt është të mendosh se raportimi '
                's\'ia vlen më, sepse ndalesa është mbyllur. Pikërisht e '
                'kundërta: Vetëm nëse firma e di, mund ta fshijë foton '
                'dhe ta dokumentojë rastin. Kush e raporton, vepron '
                'krejtësisht drejt — kush hesht, e lë shkeljen të '
                'vazhdojë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista e kontrollit — Kapitulli 2',
        blocks: [
          ChecklistBlock(
            title: 'Para çdo fotoje dorëzimi',
            items: [
              'Fotografoj vetëm në aplikacionin e punës',
              'Në foto nuk duket asnjë person',
              'Asnjë targë, asnjë dritare, asnjë ambient i brendshëm në '
                  'foto',
              'Pakoja dhe vendi i lënies njihen qartë',
              'Asnjë foto nuk përfundon në galerinë time private ose në '
                  'një chat',
              'Nëse dikush del rastësisht në foto: fshij, bëj të re, '
                  'raportoj',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ds3',
    title: 'Puna me të dhënat e marrësve',
    summary: 'Skaneri, telefoni dhe listat e letrës — mjete pune, jo '
        'çështje private',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Skaneri dhe telefoni i punës nuk janë pajisje private',
        blocks: [
          ParagraphBlock(
            'Në skaner dhe në telefonin e punës ndodhen të dhënat e '
            'qindra njerëzve në ditë. Të dyja pajisjet i takojnë firmës '
            'dhe janë vetëm për punën — edhe gjatë pushimit dhe edhe kur '
            'i merr me vete në shtëpi.',
          ),
          BulletsBlock([
            'Asnjë aplikacion privat, asnjë llogari private, asnjë cloud '
                'privat në pajisjen e punës',
            'Mos ia jep pajisjen tjetërkujt — as për pak kolegëve, '
                'familjarëve ose të njohurve',
            'Mbaje aktive bllokimin e ekranit dhe mos e lër kurrë pajisjen '
                'pa mbikëqyrje',
            'Kur del nga automjeti: merre skanerin me vete ose ruaje në '
                'vend të sigurt, jo dukshëm mbi sedilje',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Ndalim absolut',
            text: 'Asnjë screenshot i listave të adresave, pasqyrave të '
                'tureve ose të dhënave të marrësve. As për t\'ia dërguar '
                'vetes, as „si ndihmë kujtese". Një screenshot është një '
                'kopje jashtë sistemit — pikërisht ajo që firma nuk mund '
                'ta kontrollojë më.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Informacion për fqinjët dhe të panjohurit',
        blocks: [
          ParagraphBlock(
            'Te dera të pyesin. Kjo është normale dhe zakonisht pa qëllim '
            'të keq. Megjithatë vlen: Ti zbulon vetëm aq sa duhet për '
            'dorëzimin — jo më shumë.',
          ),
          TableBlock(
            headers: ['Situata', 'Deri ku mund të shkosh'],
            rows: [
              [
                'Fqinji merr një pako',
                'Thuaj emrin e marrësit dhe numrin e shtëpisë — më shumë '
                    'nuk i duhet.',
              ],
              [
                'Fqinji pyet çfarë ka brenda',
                'Asnjë informacion. Përmbajtja i takon vetëm marrësit.',
              ],
              [
                'Dikush pyet nëse personi X banon këtu',
                'Asnjë informacion. Ti nuk konfirmon adresa banimi.',
              ],
              [
                'Dikush pyet kur vjen sërish',
                'Përgjigju në përgjithësi, pa të dhëna për dërgesa ose '
                    'marrës të tjerë.',
              ],
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Baza ligjore',
            text: 'Dhënia e të dhënave të marrësve palëve të treta është '
                'një zbulim sipas Art. 4 Nr. 2 DSGVO dhe kërkon një bazë '
                'ligjore sipas Art. 6 DSGVO. Për dorëzimin te fqinji, '
                'thënia e emrit dhe adresës është e nevojshme për '
                'përmbushjen e kontratës — për përmbajtjen e pakos, '
                'numrat e telefonit ose informacione për marrës të tjerë '
                'nuk ka asnjë bazë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Letra është rreziku i nënvlerësuar',
        blocks: [
          ParagraphBlock(
            'Të dhënat digjitale janë të paktën të mbrojtura nga një '
            'bllokim ekrani. Një copë letër në automjet nuk është. Një '
            'listë turi pas xhamit të përparmë lexohet nga jashtë — me '
            'emra dhe adresa të dyqind familjeve.',
          ),
          BulletsBlock([
            'Mos i lër kurrë listat e letrës hapur në automjet, aq më '
                'pak dukshëm përmes xhamit',
            'Kur del nga automjeti, merri listat me vete ose ruaji të '
                'mbyllura',
            'Në fund të turit: dorëzoji listat në firmë, mos i merr me '
                'vete në shtëpi',
            'Asgjësimi vetëm përmes rrugës së caktuar në firmë — jo në '
                'plehrat e shtëpisë, jo në koshin e karburantit',
            'Etiketat e kthimeve dhe të pakove të gabuara trajtoji njësoj '
                'si listat',
          ]),
          RevealBlock(
            prompt: 'Rast studimor: E ke mbaruar turin, lista e turit '
                'është veç letër e vjetër. Rrugës për në shtëpi e hedh në '
                'kazanin e letrës te banesa jote. A është kjo në rregull?',
            answer: 'Jo. Në listë ka emra dhe adresa — të dhëna '
                'personale. Ato duhet të asgjësohen ashtu që askush të '
                'mos mund t\'i rikuperojë, zakonisht përmes një koshi për '
                'mbrojtjen e të dhënave ose grirëses së letrës në firmë. '
                'Gabimi i afërt është të mendosh se një listë e kryer '
                '„nuk vlen më asgjë". Për mbrojtjen e të dhënave kryerja '
                'nuk ndryshon asgjë: Të dhënat janë po ato, dhe një kazan '
                'i hapur letre është një vend i aksesueshëm publikisht. '
                'Përveç kësaj, listën nuk do të duhej ta kishe marrë fare '
                'me vete në shtëpi.',
          ),
          DoDontBlock(
            doTitle: 'Drejt',
            dos: [
              'Dorëzoji listat në firmë dhe asgjësoji atje siç duhet',
              'Blloko skanerin para se të dalësh nga automjeti',
              'Për pyetje rreth dërgesave të huaja drejtoji te drejtoria '
                  'e firmës',
            ],
            dontTitle: 'Gabim',
            donts: [
              'Të bësh ose të dërgosh screenshot-e të listave të adresave',
              'Të marrësh listat e turit në shtëpi ose t\'i asgjësosh '
                  'privatisht',
              'T\'u japësh të dhëna marrësish fqinjëve, të njohurve ose '
                  'të tretëve',
              'T\'ia japësh pajisjen e punës dikujt tjetër',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista e kontrollit — Kapitulli 3',
        blocks: [
          ChecklistBlock(
            title: 'Në fund të çdo turi',
            items: [
              'Asnjë screenshot i të dhënave të adresave në pajisjen time',
              'Skaneri dhe telefoni i punës janë të bllokuar dhe të ruajtur '
                  'sigurt',
              'Asnjë listë letre nuk ndodhet hapur në automjet',
              'Të gjitha listat dhe etiketat janë dorëzuar në firmë',
              'Nuk u kam dhënë të dhëna marrësish palëve të treta',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ds4',
    title: 'Të dhënat e tua dhe ato të kolegëve',
    summary: 'Raportimi si i sëmurë, regjistrimi i kohës, dosja e '
        'personelit — dhe të drejtat e tua',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Mbrojtja e të dhënave të mbron edhe ty',
        blocks: [
          ParagraphBlock(
            'Jo vetëm marrësit kanë të dhëna në sistem — edhe ti. Dhe '
            'ato janë pjesërisht shumë më të ndjeshme se një adresë '
            'dorëzimi.',
          ),
          BulletsBlock([
            'Treguesit e performancës nga puna jote e dorëzimit',
            'Raportimet si i sëmurë dhe mungesat',
            'Regjistrimi i kohës, planet e turneve, kohët e pushimit',
            'Të dhënat e patentës dhe të letërnjoftimit nga dosja e '
                'personelit',
            'Fotot ku dukesh ti ose kolegët',
          ]),
          ParagraphBlock(
            'Këto të dhëna firma mund t\'i përpunojë, për aq sa është e '
            'nevojshme për marrëdhënien e punës. Por nuk mund t\'i japë '
            'sipas dëshirës — dhe as ti nuk mundesh, kur bëhet fjalë për '
            'kolegët.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Baza ligjore',
            text: 'Të dhënat e punonjësve përpunohen mbi bazën e Art. 6 '
                'Abs. 1 lit. b dhe f DSGVO në lidhje me § 26 BDSG — e '
                'lejueshme vetëm për aq sa është e nevojshme për '
                'marrëdhënien e punës. Të dhënat shëndetësore si '
                'raportimet si i sëmurë janë kategori të veçanta sipas '
                'Art. 9 DSGVO dhe mbrohen veçanërisht rreptë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Të dhënat e kolegëve nuk të takojnë ty',
        blocks: [
          ParagraphBlock(
            'Në depo merr vesh shumë gjëra: kush është i sëmurë, kush '
            'pati telashe me një tur, kush mori një vërejtje. Të marrësh '
            'vesh është një gjë — të tregosh më tej është tjetër.',
          ),
          DoDontBlock(
            doTitle: 'Drejt',
            dos: [
              'Fol për vlerat e tua sa të duash',
              'Problemet me një koleg sqaroji drejtpërdrejt me të ose me '
                  'drejtorinë e firmës',
              'Një foto me kolegë bëje dhe ndaje vetëm nëse të gjithë të '
                  'fotografuarit janë dakord',
              'Shkeljet e vëzhguara raportoji brenda firmës në vend që '
                  't\'i përhapësh nëpër depo',
            ],
            dontTitle: 'Gabim',
            donts: [
              'Të japësh të dhëna performance ose analiza të kolegëve',
              'Të flasësh për arsyen e sëmundjes së një kolegu — edhe '
                  'nëse e di',
              'Të postosh foto ose video të kolegëve pa pëlqimin e tyre '
                  'në grupe chati',
              'Të ndash screenshot-e nga listat ose analizat e brendshme',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Veçanërisht delikate',
            text: 'Raportimet si i sëmurë. Fakti që dikush është i '
                'sëmurë është një e dhënë shëndetësore sipas Art. 9 '
                'DSGVO. Arsyeja aq më tepër. Dhënia shoferëve të tjerë '
                'nuk lejohet as atëherë kur i prekuri vetë ka treguar '
                'tashmë për të.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Të drejtat e tua si person i prekur',
        blocks: [
          ParagraphBlock(
            'DSGVO-ja të jep të drejta ndaj punëdhënësit tënd. Nuk ke '
            'nevojë t\'i arsyetosh, dhe ushtrimi i tyre nuk mund të të '
            'sjellë disavantazhe.',
          ),
          TableBlock(
            headers: ['E drejta', 'Çfarë mund të kërkosh'],
            rows: [
              [
                'Informim (Art. 15)',
                'Një pasqyrë se cilat të dhëna për ty janë ruajtur dhe '
                    'për çfarë.',
              ],
              [
                'Korrigjim (Art. 16)',
                'Korrigjimin e të dhënave të gabuara, p.sh. të një numri '
                    'personeli ose adrese të gabuar.',
              ],
              [
                'Fshirje (Art. 17)',
                'Fshirjen e të dhënave që nuk nevojiten më dhe nuk i '
                    'nënshtrohen ndonjë afati ruajtjeje.',
              ],
            ],
          ),
          ParagraphBlock(
            'Personi i kontaktit është drejtoria e firmës ose përgjegjësi '
            'për mbrojtjen e të dhënave i firmës. Një kërkesë duhet t\'i '
            'përgjigjet në parim brenda një muaji.',
          ),
          RevealBlock(
            prompt: 'Rast studimor: Një koleg të lutet t\'i dërgosh një '
                'screenshot të një analize të brendshme — ku janë të '
                'gjithë shoferët me emra dhe vlera. Ai do të shohë vetëm '
                'ku qëndron vetë. A e bën?',
            answer: 'Jo. Në screenshot janë të dhënat e performancës së '
                'të gjithë kolegëve; kjo është një dhënie e të dhënave të '
                'punonjësve pa bazë ligjore. Që kolegu do të shohë vetëm '
                'rreshtin e vet, nuk ndryshon asgjë — ai i merr '
                'megjithatë të gjithë të tjerët. E drejta është: Ai i '
                'kërkon vlerat e veta te drejtoria e firmës. E drejta e '
                'tij e informimit sipas Art. 15 DSGVO ka të bëjë vetëm me '
                'të dhënat e tij.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista e kontrollit — Kapitulli 4',
        blocks: [
          ChecklistBlock(
            title: 'Në punën me të dhënat e kolegëve',
            items: [
              'Nuk jap të dhëna performance të kolegëve',
              'Nuk flas për raportimet si i sëmurë të të tjerëve',
              'Nuk postoj foto të kolegëve pa pëlqimin e tyre',
              'Nuk bëj screenshot-e nga analizat e brendshme',
              'E di te kush drejtohem kur dua informim për të dhënat e '
                  'mia',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ds5',
    title: 'Kur diçka shkon keq — incidenti i të dhënave',
    summary: 'Afati 72-orësh i raportimit: pse duhet të raportosh '
        'menjëherë',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Çfarë është një incident i të dhënave',
        blocks: [
          ParagraphBlock(
            'Një incident i të dhënave nuk është vetëm sulmi i madh i '
            'hakerëve. Në dorëzim janë pothuajse gjithmonë ngatërresa të '
            'vogla të përditshme — dhe pikërisht ato llogariten po ashtu.',
          ),
          BulletsBlock([
            'Telefoni i punës ose skaneri i humbur a i vjedhur',
            'Pako e dorëzuar te marrësi i gabuar, që e ka hapur',
            'Pako me etiketë adrese të lexueshme e lënë hapur në korridor '
                'ose në rrugë',
            'Foto ose listë adresash e dërguar gabimisht te personi i '
                'gabuar',
            'Listë turi e humbur ose e lënë hapur në automjet',
            'Skaner i lënë pa mbikëqyrje dhe i aksesueshëm i zhbllokuar',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Rregulli bazë',
            text: 'Sapo të dhënat personale i janë bërë të aksesueshme '
                'dikujt që nuk duhej t\'i kishte, është një incident i të '
                'dhënave. Nëse në fund ka ndodhur vërtet një dëm, nuk e '
                'vendos ti — atë e shqyrton firma.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Afati 72-orësh',
        blocks: [
          ParagraphBlock(
            'Pika vendimtare për ty është ora. Sapo firma merr vesh për '
            'një incident të të dhënave, fillon një afat shumë i shkurtër '
            '— dhe ai ecën pavarësisht nëse është fund dite, fundjavë apo '
            'ditë feste.',
          ),
          FactsBlock([
            FactItem('72 orë', 'afati i raportimit të firmës te autoriteti '
                'mbikëqyrës sipas Art. 33 DSGVO'),
            FactItem('menjëherë', 'raportimi yt te dispeçeri ose drejtoria '
                'e firmës — po atë ditë'),
            FactItem('0', 'disavantazhe për ty, kur një gabim tëndin e '
                'raporton menjëherë'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Baza ligjore',
            text: 'Art. 33 Abs. 1 DSGVO e detyron firmën ta raportojë një '
                'shkelje të mbrojtjes së të dhënave personale pa vonesë '
                'dhe mundësisht brenda 72 orësh pas marrjes dijeni te '
                'autoriteti mbikëqyrës. Në rrezik të lartë duhet sipas '
                'Art. 34 DSGVO të njoftohen edhe personat e prekur. Firma '
                'mund ta respektojë këtë afat vetëm nëse ti raporton '
                'menjëherë.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kështu raporton drejt',
        blocks: [
          StepsBlock([
            'Telefono menjëherë dispeçerin ose drejtorinë e firmës — mos '
                'prit deri në fund të ditës',
            'Thuaj çfarë ka ndodhur, kur ka ndodhur dhe cilat të dhëna '
                'janë prekur',
            'Thuaj kush mund t\'i ketë parë të dhënat',
            'Mos riparo asgjë me kokën tënde: asnjë fshirje protokollesh, '
                'asnjë tërheqje pa marrëveshje',
            'Nëse mundesh, ruaje gjendjen — p.sh. mos e lëviz pakon e '
                'dorëzuar gabim, para se të merret vesh si duhet vepruar',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Më e rëndësishmja në këtë kapitull',
            text: 'Kush e raporton një gabim menjëherë, vepron drejt. '
                'Raportimi është shprehimisht i dëshiruar dhe nuk është '
                'pranim paaftësie. Fshehja, përkundrazi, e kthen një '
                'ngatërresë të vogël në problem të vërtetë — për të '
                'prekurit, për firmën dhe në fund edhe për ty.',
          ),
          DoDontBlock(
            doTitle: 'Drejt',
            dos: [
              'Raporto menjëherë, edhe kur është e sikletshme',
              'Tregoje plotësisht, edhe gabimet e tua',
              'Pyet nëse duhet të bësh edhe diçka tjetër',
            ],
            dontTitle: 'Gabim',
            donts: [
              'Të presësh nëse e vë re fare dikush',
              'Të njoftosh vetëm ditën tjetër të punës',
              'Ta zvogëlosh rastin ose të lësh pjesë jashtë',
              'Të përpiqesh me kokën tënde ta rimarrësh pakon ose foton',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Rast studimor dhe listë kontrolli',
        blocks: [
          RevealBlock(
            prompt: 'Rast studimor: Në mbrëmje vë re se një pako e ke '
                'lënë në shtëpinë numër 14 në vend të 41. Marrësi atje e '
                'ka hapur tashmë. Do ta marrësh nesër në mëngjes thjesht '
                'dhe ta dorëzosh drejt — kështu nuk e vë re askush. '
                'Çfarë është gabim këtu?',
            answer: 'Dy gjëra. Së pari, tashmë ka ndodhur një incident i '
                'të dhënave: Një person i huaj ka mësuar emrin, adresën '
                'dhe përmbajtjen e dërgesës. Kjo duhet shqyrtuar për '
                'detyrim raportimi, dhe afati 72-orësh i Art. 33 DSGVO '
                'ecën nga momenti kur firma merr vesh. Së dyti, me '
                'pritjen pengon pikërisht atë që firma duhet të bëjë — '
                'të vlerësojë, të dokumentojë dhe sipas rastit të '
                'njoftojë marrësin e prekur. Gabimi i afërt është të '
                'mendosh se një korrigjim i heshtur nuk dëmton askënd. Në '
                'fakt dëmton: Nëse rasti bëhet i njohur më vonë, firma '
                'mbetet pa raportim brenda afatit — dhe ti e ke fshehur '
                'gabimin në vend që ta kishe raportuar.',
          ),
          ChecklistBlock(
            title: 'Në çdo dyshim për incident të të dhënave',
            items: [
              'Raportoj po atë ditë, jo nesër',
              'Them çfarë ka ndodhur, kur dhe cilat të dhëna janë prekur',
              'Nuk zbukuroj asgjë dhe nuk lë asgjë jashtë',
              'Nuk ndërmarr asgjë me kokën time',
              'E kam të qartë: raportimi është e drejta, fshehja e bën '
                  'më keq',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'ds6',
    title: 'Diskrecioni dhe besnikëria',
    summary: 'Çfarë mund të dalë jashtë, çfarë jo — dhe pse kritika '
        'objektive lejohet shprehimisht',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Sekretet e firmës mbeten në firmë',
        blocks: [
          ParagraphBlock(
            'Përveç të dhënave personale ekziston një grup i dytë '
            'informacionesh që nuk kanë vend jashtë: shifrat e brendshme '
            'dhe sekretet tregtare e të biznesit. Këtu hyn shumëçka që në '
            'depo diskutohet fare natyrshëm.',
          ),
          BulletsBlock([
            'Çmimet, kushtet dhe kontratat me porositësit',
            'Treguesit dhe analizat e brendshme',
            'Planet e tureve, logjika e rrugëve dhe shifrat e kapacitetit',
            'Udhëzimet e brendshme, materialet e trajnimit dhe rregullat '
                'e proceseve',
            'Fotot nga depoja, ku njihen lista, ekrane ose dërgesa',
          ]),
          ParagraphBlock(
            'Kjo vlen njësoj në çdo kanal: në bisedë personale, në '
            'rrjetet sociale dhe në grupet e chatit të shoferëve. Një '
            'grup WhatsApp me gjashtëdhjetë shoferë nuk është bisedë '
            'private.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Baza ligjore',
            text: 'Sekretet e biznesit mbrohen nga ligji për sekretet '
                'tregtare (GeschGehG). Pavarësisht prej tij, nga kontrata '
                'e punës rrjedh një detyrim diskrecioni si detyrim '
                'anësor kontraktual sipas § 241 Abs. 2 BGB. Për të dhënat '
                'personale vlen përveç kësaj konfidencialiteti sipas '
                'Art. 5 Abs. 1 lit. f DSGVO.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Pohime të pavërteta për firmën',
        blocks: [
          ParagraphBlock(
            'Këtu ngatërrohet shpesh çfarë lejohet dhe çfarë jo. Vija nuk '
            'kalon midis „pozitives" dhe „negatives", por midis së '
            'vërtetës dhe së pavërtetës së vetëdijshme, midis kritikës '
            'dhe sharjes.',
          ),
          ParagraphBlock(
            'Pohime faktesh të pavërteta me vetëdije për firmën, eprorët '
            'ose kolegët nuk mbulohen nga liria e shprehjes. E njëjta gjë '
            'vlen për fyerjet dhe kritikën sharëse — pra shprehje ku nuk '
            'bëhet më fjalë për çështjen, por vetëm për ta poshtëruar '
            'dikë.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Baza ligjore',
            text: 'Art. 5 Abs. 1 GG mbron shprehjet e mendimit, por jo '
                'pohimet e fakteve të pavërteta me vetëdije dhe jo '
                'kritikën sharëse. Shprehje të tilla mund të justifikojnë '
                'një pushim të menjëhershëm nga puna sipas § 626 BGB. Në '
                'rast përgojimi shtohet ndëshkueshmëria sipas § 186 StGB; '
                'në pohime të rreme me vetëdije zbatohet § 187 StGB '
                '(shpifja).',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Keqkuptime tipike',
            text: 'Një profil privat nuk është privat sapo të tjerët mund '
                'të lexojnë. Një grup chati i mbyllur nuk është i '
                'mbrojtur sapo një screenshot i tij shkon më tej. Dhe '
                '„ky ishte veç mendimi im" nuk ndihmon, kur thënia ishte '
                'një pohim fakti që provueshëm nuk qëndron.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kritika objektive lejohet shprehimisht',
        blocks: [
          ParagraphBlock(
            'Po aq e rëndësishme sa vija është ajo që qëndron këtej saj '
            '— dhe kjo është shumë. Ti mund të shprehësh kritikë, edhe '
            'qartë, edhe në mënyrë të pakëndshme. Mund të thuash se një '
            'tur është planifikuar shumë ngushtë, se një automjet është '
            'në gjendje të keqe ose se një njoftim në depo ishte i '
            'gabuar.',
          ),
          ParagraphBlock(
            'Dhe kush raporton parregullsi të vërteta, nuk mbetet i '
            'pambrojtur: Që nga 2 korriku 2023 vlen ligji për mbrojtjen '
            'e sinjalizuesve (HinSchG). Ai ndalon hakmarrjet ndaj '
            'punonjësve që raportojnë shkelje — pra pushim nga puna, '
            'vërejtje, transferim ose disfavorizim për shkak të '
            'raportimit.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Mbrojtja e sinjalizuesve',
            text: 'HinSchG i mbron personat që raportojnë shkelje në '
                'kontekst profesional nga hakmarrjet. Mbrojtja bie vetëm '
                'në raportime të pasakta me vetëdije ose nga pakujdesia e '
                'rëndë. Pra, kush raporton seriozisht dhe sipas dijes më '
                'të mirë një parregullsi, është i mbrojtur — edhe atëherë '
                'kur dyshimi në fund nuk konfirmohet.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Dallimi në një fjali',
            text: 'Thuaj çfarë ke përjetuar — jo çfarë hamendëson. '
                'Kritika e vërtetë është e mbrojtur, akuzat e shpikura '
                'jo.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Rruga konstruktive',
        blocks: [
          ParagraphBlock(
            'Pothuajse gjithçka që shoferët nxjerrin jashtë, do të '
            'zgjidhej më shpejt brenda. Rruga nga brenda është prandaj jo '
            'vetëm më e sigurta, por zakonisht edhe më efektivja.',
          ),
          StepsBlock([
            'Fillimisht foli dispeçerit — shumica e problemeve janë '
                'probleme planifikimi dhe zgjidhen aty',
            'Nëse s\'kthehet asgjë: foli drejtorisë së firmës, mundësisht '
                'me shkrim, me datë dhe rast konkret',
            'Në shkelje më serioze: përdor zyrën e brendshme të '
                'raportimit sipas HinSchG',
            'Vetëm kur brenda nuk ndodh asgjë, vijnë në konsideratë '
                'instancat e jashtme — por atëherë objektivisht dhe me '
                'fakte të provueshme',
          ]),
          DoDontBlock(
            doTitle: 'E lejuar dhe e dëshiruar',
            dos: [
              'Të thuash se një tur rregullisht nuk arrihet',
              'Të tregosh një defekt teknik të automjetit — edhe në '
                  'mënyrë të përsëritur',
              'Të përshkruash një rast konkret që e ke përjetuar vetë',
              'Të raportosh një shkelje përmes zyrës së brendshme të '
                  'raportimit',
              'Të insistosh kur pas një raportimi nuk ndodh asgjë',
            ],
            dontTitle: 'E pambuluar',
            donts: [
              'Të ngresh pohime për të cilat e di se nuk qëndrojnë',
              'Të fyesh ose të poshtërosh eprorët a kolegët',
              'Të bësh publike shifra, kontrata ose analiza të brendshme',
              'Të përhapësh thashetheme në grupe chati pa i njohur',
              'T\'i zhvillosh konfliktet nëpër portale vlerësimi ose '
                  'rrjete sociale, para se brenda të jetë pyetur fare '
                  'dikush',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Rast studimor dhe listë kontrolli',
        blocks: [
          RevealBlock(
            prompt: 'Rast studimor: Në grupin e chatit të shoferëve '
                'dikush shkruan se firma nuk i paguan orët me qëllim. Ti '
                'vetë kurrë nuk e ke përjetuar këtë, por je i nervozuar '
                'me planin tënd të punës dhe shkruan: „E vërtetë, na '
                'mashtrojnë të gjithëve sistematikisht." Të nesërmen '
                'qarkullon një screenshot i grupit. Si vlerësohet kjo?',
            answer: 'Në mënyrë kritike — jo për shkak të kritikës, por '
                'për shkak të formës. Ke ngritur një pohim fakti („na '
                'mashtrojnë sistematikisht") që vetë nuk mund ta provosh '
                'dhe nuk e ke përjetuar. Pohimet e fakteve të pavërteta '
                'me vetëdije nuk mbulohen nga liria e shprehjes dhe mund '
                'të kenë pasoja të së drejtës së punës deri te pushimi i '
                'menjëhershëm sipas § 626 BGB; në rast përgojimi shtohet '
                '§ 186 StGB. Screenshot-i tregon veç kësaj se një grup i '
                'mbyllur nuk është hapësirë e mbrojtur. E drejtë do të '
                'kishte qenë: të përmendje rastin tënd — „Mua më '
                'mungojnë në korrik dy orë, e kam raportuar dhe deri tani '
                's\'kam përgjigje" — dhe t\'ia jepje dispeçerit, '
                'drejtorisë së firmës ose zyrës së brendshme të '
                'raportimit. Kjo thënie është e vërtetë, e verifikueshme '
                'dhe e mbrojtur nga HinSchG. Rezultati: E njëjta '
                'pakënaqësi, por e shprehur drejt, nuk mund të të '
                'dëmtojë.',
          ),
          ChecklistBlock(
            title: 'Para se të nxjerr diçka jashtë',
            items: [
              'E di nga përvoja ime se qëndron',
              'E përshkruaj rastin objektivisht, pa fyerje',
              'Nuk zbuloj shifra, kontrata ose analiza të brendshme',
              'E kam ngritur më parë brenda — dispeçer, drejtori firme '
                  'ose zyrë raportimi',
              'E kam të qartë: raportimi i parregullsive të vërteta '
                  'është i mbrojtur, pohimi i të shpikurave jo',
            ],
          ),
        ],
      ),
    ],
  ),
];
