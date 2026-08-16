// lib/data/safety_training/safety_texts_hu.dart
//
// Safety instruction — Hungarian texts. Same key set as safety_texts_de.dart.

const Map<String, String> safetyTextsHu = {
  'ask_anytime':
      'Kérdésed van? Bármikor fordulj a menedzseredhez, a diszpécseredhez vagy az ügyvezetéshez — jobb egyszer többet kérdezni, mint hibázni.',
  // ── Meta / UI ──
  'training_title': 'Munkavédelmi oktatás',
  'training_subtitle': 'Munkavédelem futároknak — éves oktatás',
  'training_intro':
      'Ez az oktatás téged véd: kb. 15–20 perc alatt megtanulod a '
      'biztonságos munka és vezetés legfontosabb szabályait. A végén rövid '
      'teszt vár (20 kérdés, 80% a megfeleléshez), és aláírásoddal igazolod '
      'a részvételt.',
  'chapters_overview_title': 'Fejezetek',
  'chapters_overview_hint': 'Dolgozd fel a fejezeteket sorban. A teszt akkor nyílik meg, ha mindet elolvastad.',
  'chapter_pages': '{n} oldal',
  'btn_overview': 'Áttekintés',
  'btn_chapter_done': 'Fejezet befejezése',
  'btn_test_locked': 'Előbb olvasd el az összes fejezetet',
  'chapter_label': '{n}. fejezet / összesen {m}',
  'btn_start': 'Oktatás indítása',
  'btn_next': 'Tovább',
  'btn_back': 'Vissza',
  'btn_start_test': 'Tovább a teszthez',
  'btn_submit_test': 'Válaszok ellenőrzése',
  'btn_retry': 'Újrapróbálás',
  'btn_finish': 'Befejezés',
  'test_title': 'Záróteszt',
  'test_intro':
      '20 kérdés — legalább 80% (16 helyes) a megfeleléshez. A tesztet '
      'akárhányszor megismételheted.',
  'test_passed': 'Sikerült — {score} / {total} helyes!',
  'test_failed':
      'Sajnos nem sikerült ({score} / {total}). Nézd át újra a fejezeteket, '
      'és próbáld meg még egyszer.',
  'signature_title': 'Részvétel megerősítése',
  'signature_hint':
      'Aláírásoddal igazolod, hogy részt vettél az oktatáson és megértetted '
      'a tartalmát. Lehetőséged volt kérdéseket feltenni.',
  'confirm_checkbox':
      'Megértettem az oktatást, és megerősítem a részvételemet.',
  'btn_clear': 'Törlés',
  'btn_sign_submit': 'Aláírás és befejezés',
  'cert_done_title': 'Oktatás befejezve!',
  'cert_done_body':
      'Az igazolásod elkészült, és a dokumentumaid közé került. '
      'Az oktatás 12 hónapig érvényes.',
  'status_valid_until': 'Érvényes eddig: {date}',
  'status_expired': 'Lejárt — kérjük, végezd el újra',
  'status_open': 'Még nem végezted el',

  // ── Chapters ──
  'ch01_title': 'Alapok és a te kötelességeid',
  'ch01_body': 'A munkavédelmet törvény szabályozza (munkavédelmi törvény + '
      'DGUV-előírások), és az életedet, egészségedet védi. '
      'Neked is vannak kötelességeid:\n'
      '• Tartsd be a munkáltatód üzemi utasításait\n'
      '• Azonnal jelentsd a baleseteket és a majdnem-baleseteket\n'
      '• Nyújts elsősegélyt, illetve segíts benne\n'
      '• Jelentsd a hibákat és hiányosságokat (pl. sérült kábel, hibás '
      'készülék)\n'
      '• Használd rendeltetésszerűen a védőfelszerelést (munkavédelmi '
      'cipő, kesztyű, láthatósági mellény)\n'
      '• Semmi alkohol, semmi drog, semmi tudatmódosító gyógyszer — sem '
      'magadat, sem másokat nem sodorhatsz veszélybe.',
  'ch02_title': 'Üzemi utasítások',
  'ch02_body': 'Az üzemi utasítások a munkáltatód kötelező érvényű '
      'előírásai a járművek, eszközök és veszélyes anyagok kezelésére.\n'
      '• Megvédenek a balesetektől és az egészségkárosodástól\n'
      '• Aki megszegi őket, baleset esetén részfelelősséget kockáztat\n'
      '• Példák a mindennapokból: tolatás veszély esetén csak irányító '
      'személlyel · a járművet elhagyáskor mindig zárd be · vontatás csak '
      'vonórúddal · minden balesetet azonnal jelents\n'
      '• Kérdezz, ha egy utasítás nem világos — még mielőtt dolgozni '
      'kezdesz.',
  'ch03_title': 'A biztonságos munka 10 szabálya',
  'ch03_body': 'Ez a tíz szabály minden nap érvényes:\n'
      '1. Dolgozz biztonságosan és körültekintően\n'
      '2. Indulás előtti ellenőrzés minden út előtt\n'
      '3. Rögzítsd a rakományt a járműben\n'
      '4. Vezess profin, tartsd be a közlekedési szabályokat\n'
      '5. Mindig kapcsold be a biztonsági övet\n'
      '6. Tartsd rendben a járművet, a szerszámokat és a felszerelést\n'
      '7. Csak megfelelő cipőben dolgozz\n'
      '8. Bánj udvariasan a kollégákkal és az ügyfelekkel\n'
      '9. Tartsd be a pihenőidő-szabályokat\n'
      '10. Legyetek toleránsak és tisztelettudóak egymással',
  'ch04_title': 'Munkavédelmi cipő és védőfelszerelés',
  'ch04_body': 'A munkáltató által biztosított munkavédelmi cipőt viselni '
      'kell — ez kötelező (§ 15 ArbSchG).\n'
      '• Véd a leeső csomagoktól, ütődéstől, hegyes tárgyakba lépéstől, '
      'nedvességtől és csúszástól\n'
      '• Védelmi osztályok: S1 (antisztatikus, üzemanyagálló talp) · '
      'S2 (ezen felül legalább 60 percig vízálló) · S3 (ezen felül '
      'átszúrásbiztos, bordázott talp)\n'
      '• Rendszeresen ellenőrizd a cipődet: lekopott talp vagy sérülés → '
      'cseréltesd ki\n'
      '• Különösen fontos rámpákon, egyenetlen utakon, gurulós '
      'konténereknél és kézi raklapemelőknél\n'
      '• A láthatósági mellény legyen kéznél a járműben — defekt/baleset '
      'esetén kötelező.',
  'ch05_title': 'Teendők tűz esetén',
  'ch05_body': 'A tűzoltó készülék használata: 1. Húzd ki a '
      'biztosítószeget · 2. Üsd be az ütőgombot · 3. Nyomd meg a '
      'löveggombot.\n'
      '• Szélirányban olts, a felületi tüzeket elölről, több készüléket '
      'egyszerre, ne egymás után\n'
      '• Egy készülék csak másodpercekig tart (6 kg-os por: 15–23 mp) — '
      'a használt készüléket mindig töltesd újra\n'
      '• Járműtűz: NE állj meg alagútban vagy hídon — ha lehet, hajts ki, '
      'majd vészvillogó, megállás, kiszállás\n'
      '• Azonnal hívd a tűzoltókat a 112-n: Hol? Mi ég? Vannak sérültek? '
      'Mi a rakomány? Ne tedd le — a hívást a központ fejezi be\n'
      '• A motorháztetőt csak kesztyűben és óvatosan, résnyire nyisd — '
      'az oxigén miatt belobbanásveszély.',
  'ch06_title': 'Elsősegély',
  'ch06_body': 'Elsősegélyt nyújtani mindenki törvényi kötelessége '
      '(§ 323c StGB) — az elvárható kereteken belül.\n'
      '• Aki segít, alapvetően nem hibázhat: elsősegélynyújtóként '
      'baleset-biztosított vagy, és nem felelsz a hibákért — csak az '
      'büntethető, aki NEM segít\n'
      '• Alapszabályok: őrizd meg a nyugalmad · először a saját '
      'biztonságod · biztosítsd a helyszínt · utána segíts\n'
      '• Segélyhívás 112 — a fő kérdések: Hol? Mi történt? Hány sérült? '
      'Ki telefonál? Várd meg a visszakérdezéseket!\n'
      '• Minden sérülést — a kis vágásokat is — azonnal láss el, és '
      'jegyezd be az elsősegély-naplóba\n'
      '• Ha 3 napnál tovább vagy munkaképtelen, a munkáltatónak '
      'jelentenie kell a balesetet a balesetbiztosítónak — ezért mindig '
      'szólj neki.',
  'ch07_title': 'Helyes ülés és mozgás',
  'ch07_body': 'A hosszú, helytelen ülés fáraszt, feszültté tesz és '
      'lassítja a reakciódat.\n'
      '• Indulás előtt állítsd be az ülést: magasság, távolság, háttámla, '
      'deréktámasz, fejtámla, kormány, öv vezetése\n'
      '• A hátad legyen teljesen a támlán, ülj egyenesen, és időnként '
      'kicsit változtass a testtartásodon („dinamikus ülés")\n'
      '• Használd a szüneteket rövid gyakorlatokra: nyújtsd a karjaid '
      'felfelé (kb. 8 mp, 3–5×) · kezek a tarkóra, könyökök hátra · ülve '
      'húzd erősen szét a kormányt (3–6 mp)\n'
      '• Az edzett hát sokkal kevésbé hajlamos a panaszokra.',
  'ch08_title': 'Lelki terhelés',
  'ch08_body': 'Határidőnyomás, dugó, parkolóhely-keresés, konfliktusok — '
      'a futár hétköznapjai megterhelőek lehetnek. Ez normális, nem '
      'személyes kudarc.\n'
      '• A tartós stressz kimerültséghez, alvászavarhoz, hibákhoz és '
      'betegséghez vezet — vedd komolyan a figyelmeztető jeleket\n'
      '• Beszélj nyíltan a terhelésről: a diszpécserrel, személyes '
      'beszélgetésen vagy névtelenül\n'
      '• A reális túrák, a világos felelősségek és a visszajelzés a '
      'munkáltató feladata — a jelzésed mindenkinek segít\n'
      '• Segítséget kérni erő, nem gyengeség. Akut krízis esetén: '
      '(Németországban a lelkisegély-vonal, Telefonseelsorge: '
      '0800 111 0 111 — ingyenes, éjjel-nappal).',
  'ch09_title': 'Biztonságos vezetés és indulás előtti ellenőrzés',
  'ch09_body': 'MINDEN út előtt: rövid indulási ellenőrzés — 2 percig '
      'tart, és életet menthet.\n'
      '• Körbejárás: világítás elöl/hátul · gumik (nyomás, profil) · '
      'tükrök és üvegek tiszták · nincs szivárgás · ajtók/ponyvák zárva · '
      'rendszám tiszta\n'
      '• Rakomány rögzítve? Rögzítőeszközök sértetlenek, megengedett '
      'össztömeg betartva\n'
      '• Munkahely: ülés és tükrök beállítva, fékpróba, vezetéstámogató '
      'rendszerek bekapcsolva\n'
      '• Télen: megfelelő gumik, fagyálló, jégkaparó a fedélzeten\n'
      '• Útközben: öv bekapcsolva, közlekedési szabályok betartva, '
      'követési távolság — soha ne vezess alkohol/drog hatása alatt.',
  'ch10_title': 'Defekt és baleset',
  'ch10_body': 'Alapszabály: először a saját biztonságod — az ember '
      'előbbre való, mint a tárgyak.\n'
      '• Defekt: vészvillogót korán fel, lehetőleg parkolóba vagy '
      'teljesen jobbra húzódj, a láthatósági mellényt MÉG kiszállás előtt '
      'vedd fel, tedd ki az elakadásjelző háromszöget (kb. 100 m, '
      'autópályán 150–400 m)\n'
      '• Baleset: 1. Állj meg · 2. Biztosítsd a helyszínt · 3. '
      'Elsősegély · 4. Segélyhívás 112 · 5. Adatcsere · 6. Sérült vagy '
      'nagy kár esetén rendőrség · 7. Fotók + tanúk · 8. Értesítsd a '
      'munkáltatót\n'
      '• Megkoccantottál egy parkoló autót, és nincs ott senki? Várj '
      'legalább 30 percet, aztán a cetli NEM elég: azonnal menj a '
      'rendőrségre — különben cserbenhagyás\n'
      '• A legtöbb sérülés egyébként nem a forgalomban történik, hanem '
      'kiszálláskor: több mint 50% esés — soha ne ugorj le, mindig '
      'használd a fellépőket és a kapaszkodókat.',

  // ── Test questions ──
  'q01': 'Mi az első teendőd sérültekkel járó balesetnél?',
  'q01_a': 'Azonnal felhívod a munkáltatót',
  'q01_b': 'Megállsz, biztosítod a helyszínt (láthatósági mellény, '
      'elakadásjelző háromszög), majd elsősegély és segélyhívás',
  'q01_c': 'Fotókat készítesz és továbbhajtasz',
  'q02': 'Melyik segélyhívó számot hívod tűz vagy sérültek esetén?',
  'q02_a': '110',
  'q02_b': '112',
  'q02_c': '116117',
  'q03': 'Megkoccantasz egy parkoló autót, a tulajdonos nincs ott. '
      'Mi a helyes?',
  'q03_a': 'Cetlit hagysz a telefonszámoddal a szélvédőn, és '
      'továbbhajtasz',
  'q03_b': 'Legalább 30 percet vársz, majd a balesetet azonnal jelented '
      'a rendőrségen',
  'q03_c': 'Továbbhajtasz, ha a kár kicsinek tűnik',
  'q04': 'Milyen távolságra teszed ki az elakadásjelző háromszöget az '
      'autópályán?',
  'q04_a': 'Közvetlenül a jármű mögé',
  'q04_b': 'kb. 50 méterre',
  'q04_c': '150–400 méterre',
  'q05': 'Mi az alapszabály defekt- vagy balesethelyszínen?',
  'q05_a': 'A vagyonvédelem az első, hogy elkerüljük a költségeket',
  'q05_b': 'Először a saját biztonságod, az ember előbbre való, mint a '
      'tárgyak',
  'q05_c': 'Először a rakomány rögzítése, utána a személyek segítése',
  'q06': 'Mikor veszed fel a láthatósági mellényt defekt esetén?',
  'q06_a': 'Csak éjszaka',
  'q06_b': 'Csak autópályán',
  'q06_c': 'Mindig — már kiszállás előtt',
  'q07': 'Büntethető vagy, ha hibázol elsősegélynyújtás közben?',
  'q07_a': 'Igen, az elsősegélynyújtó mindig felel a hibákért',
  'q07_b': 'Nem — aki segít, alapvetően nem hibázhat. Csak az büntethető, '
      'aki egyáltalán nem segít',
  'q07_c': 'Igen, ezért csak képzett elsősegélynyújtó avatkozzon be',
  'q08': 'Mi történik a kisebb sérülésekkel (pl. vágás) a munkában?',
  'q08_a': 'Semmi, a kis sérülés magánügy',
  'q08_b': 'Azonnal ellátod és bejegyzed az elsősegély-naplóba',
  'q08_c': 'Csak akkor szólsz orvosnak, ha begyullad',
  'q09': 'Hogyan támadod meg a tüzet a tűzoltó készülékkel?',
  'q09_a': 'Széllel szemben, hátulról előre',
  'q09_b': 'Szélirányban, a felületi tüzeket elölről, több készülékkel '
      'egyszerre',
  'q09_c': 'Felülről a lángok közepébe, a készülékeket egymás után '
      'használva',
  'q10': 'Hol történik a futárok legtöbb bejelentésköteles balesete?',
  'q10_a': 'A közúti forgalomban, nagy sebességnél',
  'q10_b': 'Ki-/leszálláskor — esés, botlás, bokaficam (több mint 50%)',
  'q10_c': 'A jármű tankolásakor',
  'q11': 'Mi tartozik az indulás előtti ellenőrzéshez minden út előtt?',
  'q11_a': 'Csak egy pillantás az üzemanyagszintre',
  'q11_b': 'Világítás, gumik, fékek, tükrök, rakományrögzítés és '
      'ülésbeállítás ellenőrzése',
  'q11_c': 'Az ellenőrzés csak szervizlátogatás után szükséges',
  'q12': 'Mi vonatkozik az alkoholra és a drogokra a futár munkanapján?',
  'q12_a': 'Egy sör az ebédszünetben megengedett',
  'q12_b': 'Tilos — senki sem veszélyeztetheti magát vagy másokat bódító '
      'szerekkel',
  'q12_c': 'Csak vezetés közben tilos, szünetben megengedett',
};
