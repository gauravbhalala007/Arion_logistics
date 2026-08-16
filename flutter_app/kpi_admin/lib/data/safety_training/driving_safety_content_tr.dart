// lib/data/safety_training/driving_safety_content_tr.dart
//
// DSP sürüş güvenliği eğitiminin içerikleri — Türkçe sürüm.
// Modüller M1–M10, Almanca ana sürümle birebir aynı yapıda.

import 'safety_blocks.dart';

const List<SafetyChapterContent> drivingSafetyContentTr = [
  // ══════════════════════════════════════════════════ M1
  SafetyChapterContent(
    id: 'm1',
    title: 'Güvenlik kültürü ve sorumluluk',
    summary: 'Güvenliği bir kural olarak değil, kendi kararın olarak '
        'anla',
    asset: 'assets/academy/driving/m01_sicherheitskultur.svg',
    slides: [
      SafetySlide(
        title: 'Senin turun, senin sorumluluğun',
        blocks: [
          ParagraphBlock(
            'Her gün yüzlerce kilometre yol yapıyor ve onlarca kez '
            'duruyorsun. Her sürüş, her durak, her araçtan iniş bir '
            'karardır. İyi haber: kazaların neredeyse tamamı '
            'önlenebilir. Güvenlik direksiyonda değil, kafanda başlar '
            '— daha yola çıkmadan önce.',
          ),
          FactsBlock([
            FactItem('120+', 'normal bir dağıtım gününde durak sayısı'),
            FactItem('250+', 'bir turda araca inip binme sayısı'),
            FactItem('1', 'saniyelik dikkatsizlik bir kaza için yeter'),
          ]),
          ParagraphBlock(
            'Bu kadar çok tekrarda günü belirleyen şey yeteneğin değil, '
            'rutinindir. İyi bir rutin yorgunken ya da baskı altındayken '
            'de seni korur — kötü bir rutin ise er ya da geç pahalıya '
            'mal olur.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Temel düşünce',
            text: 'Güvenlik, işine ek olarak yaptığın bir şey değildir. '
                'Güvenlik, işini yapma biçimindir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dağıtımda gerçekte neler oluyor',
        blocks: [
          ParagraphBlock(
            'Dağıtım, yol ve iş kazasının en çok yaşandığı meslekler '
            'arasındadır. En sık görülen olaylar hiç de gösterişli '
            'değil: trafikte arkadan çarpma, geri giderken hasar, '
            'araçtan inerken düşme, incinen beller, burkulan ayak '
            'bilekleri. Sıradan — ve tam da bu yüzden hafife alınıyor.',
          ),
          FactsBlock([
            FactItem('% 70', 'panelvan hasarı manevra ve geri gidiş '
                'sırasında oluşur'),
            FactItem('1 numara', 'takılma, kayma ve düşme dağıtımdaki en '
                'sık yaralanma nedenidir'),
            FactItem('24', 'bir düşme sonrası ortalama iş göremezlik '
                'günü'),
          ]),
          ParagraphBlock(
            'Dikkat çekici olan şu: bu olayların neredeyse hepsi düşük '
            'hızda ya da araç dururken oluyor. Dramatik sürüş '
            'manevraları değil, bir kez kötü yapılmış sıradan hareketler '
            'söz konusu.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Yavaş olması zararsız olduğu anlamına gelmez',
            text: 'Yürüme hızında manevra sırasında oluşan bir hasar, '
                'işletmeye kolayca dört haneli bir tutara — sana da yarım '
                'gün derde mal olur.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Üç temel tutum',
        blocks: [
          ParagraphBlock(
            'Bu eğitimde göreceğin her şeyden üç tutum çıkarılabilir. '
            'Sadece bu üçünü yanında götürürsen, işin büyük bölümünü '
            'halletmiş olursun.',
          ),
          BulletsBlock([
            'Önceden düşünmek — tehlikeleri daha oluşmadan fark et. '
                'Sadece tepki veren her zaman geç kalır',
            'Zaman senindir — hiçbir paket bir kazaya değmez. Zaman '
                'baskısı bir planlama sorunudur, bahane değil',
            'Örnek olmak — davranışın meslektaşlarını, yayaları ve '
                'çocukları korur. Trafikte bir profesyonelsin, özel '
                'sürücü değil',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Akılda kalsın',
            text: 'En iyi sürücü en hızlı olan değil, başına hiçbir şey '
                'gelmeyendir — çünkü olacakları önceden görür.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Her sürüş bir kararlar zinciridir',
        asset: 'assets/academy/driving/m01b_entscheidung.svg',
        blocks: [
          ParagraphBlock(
            'Kaza nadiren tek bir hatadır. Çoğu zaman tek tek zararsız '
            'görünen beş altı küçük karar üst üste birikir. Tam da bu '
            'yüzden zinciri her noktasında kırabilirsin.',
          ),
          RevealBlock(
            prompt: 'Örnek olay: Saat 17.40, hâlâ 22 durağın açık. Yük '
                'zemini dağınık, telefonun tutucuda titriyor ve önünde '
                'yol daralıyor. Buradaki risk aslında nerede?',
            answer: 'Önündeki darlıkta değil — önceki saatlerde. Dağınık '
                'yük zemini her durakta sana zaman kaybettirir, kaybedilen '
                'zaman baskı yaratır, baskı dikkatini düşürür, telefon da '
                'kalanı alır. Doğru karar iki saat önce verilmeliydi: yük '
                'bölümünü düzenle, telefonu sessize al, gerçekçi bir tempo '
                'kur. Şimdi sadece şu işe yarar: dur, derin bir nefes al, '
                'durak durak devam et ve planlamayı sonrasında bildir.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Zinciri kır',
            text: 'İçine bir kurt düştüğünde kendine sor: 30 saniyelik '
                'çabayla çıkarabileceğim halka şu an hangisi?',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ekipte örnek olmak',
        asset: 'assets/academy/driving/m01c_vorbild.svg',
        blocks: [
          ParagraphBlock(
            'Güvenlik kültürü panolardaki duyurularla değil, '
            'meslektaşların birbirinden gördükleriyle oluşur. Yeni '
            'başlayan, deneyimlilerin yaşayarak gösterdiğini taklit eder '
            '— yanlış olanı da.',
          ),
          DoDontBlock(
            doTitle: 'Taşıyan kültür',
            dos: [
              'Ramak kala olayları, kimse alaya alınmadan açıkça '
                  'konuşmak',
              'Yeni meslektaşlara basamakları, tutamakları ve kör '
                  'noktayı bizzat göstermek',
              'Arızaları hemen bildirmek, tur bu yüzden geç başlasa '
                  'bile',
              'Zaman baskısı altında bile görünür biçimde düzgün '
                  'manevra yapmak',
            ],
            dontTitle: 'Zarar veren kültür',
            donts: [
              '“Burada hep böyle yaparız” gerekçesi',
              'Araçtan inip arkasına bakan meslektaşa gülmek',
              'Küçük hasarları bildirmek yerine aramızda halletmek',
              'Yeni birine asla öğretmeyeceğin kestirmeleri yaşayarak '
                  'göstermek',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ramak kala olaylar altın değerindedir',
            text: 'Bildirilen her ramak kala olay, bir sonraki '
                'meslektaşın başına gelmeyecek bir kazadır. Bildirmek '
                'güçtür, ispiyonculuk değil.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Sorumluluk aslında kimde?',
        blocks: [
          ParagraphBlock(
            'Direksiyondayken araç sürücüsüsün — yani kişisel olarak '
            'sorumlusun. İşletme sana güvenli bir araç verir, seni '
            'bilgilendirir ve turu planlar. Ama mesafe bırakıp '
            'bırakmadığına, kemeri takıp takmadığına ve geri gitmeden '
            'önce inip bakıp bakmadığına yalnızca sen karar verirsin.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Kanun senden ne bekliyor',
            text: '§ 1 StVO (Alman Karayolları Trafik Yönetmeliği) sürekli '
                'dikkat ve karşılıklı saygı ister. § 3 Abs. 1 StVO ancak '
                'görebildiğin mesafede durabileceğin kadar hızlı gitmeni '
                'ister. Her ikisi de levhada ne yazdığından bağımsız '
                'geçerlidir.',
          ),
          BulletsBlock([
            'Para cezaları ve ceza puanları işletmeyi değil, kişisel '
                'olarak seni bulur',
            'Ağır ihmal durumunda sigorta sana rücu ederek payını '
                'isteyebilir',
            'Başkalarını tehlikeye atarsan trafik ihlali suça '
                'dönüşebilir (§ 315c StGB, Alman Ceza Kanunu)',
            'Sürüş yasağı, profesyonel sürücü olarak senin için şu '
                'demektir: görev yok',
          ]),
          RevealBlock(
            prompt: 'Sabah bir fren lambasının yanmadığını fark ediyorsun. '
                'Sevkiyat sorumlusu diyor ki: “Yine de git, başka kimse '
                'yok.” Riski kim taşıyor?',
            answer: 'Sen. Araç sürücüsü olarak kullandığın aracın trafiğe '
                'elverişli durumundan sen sorumlusun — sözlü bir talimat '
                'bunu ortadan kaldırmaz. Doğrusu şu: arızayı bildir, yedek '
                'araç ya da onarım iste, bildirimi belgele. Panelvanda '
                'bozuk bir fren lambası, üstelik tam da arkadan çarpmaya '
                'yol açan arızadır.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrol listesi: senin tutumun',
        blocks: [
          ChecklistBlock(
            title: 'Modül 1\'den yanıma alıyorum',
            items: [
              'Hasarların çoğunun yavaş ve sıradan durumlarda '
                  'oluştuğunu biliyorum',
              'Sadece tepki vermek yerine önceden düşünüyorum',
              'Zaman baskısını bir sürüş sorunu değil, planlama sorunu '
                  'olarak görüyorum',
              'Küçük de olsa arızaları ve ramak kala olayları '
                  'bildiriyorum',
              'Araç sürücüsü olarak kişisel sorumluluk taşıdığımı '
                  'biliyorum',
              'Yeni meslektaşların beni kopyaladığının farkındayım',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Tur için tek cümle',
            text: '“Herkesin — benim de — eve sağ salim dönmesini '
                'sağlayacak şekilde sürüyorum.”',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M2
  SafetyChapterContent(
    id: 'm2',
    title: 'Araç kontrolü ve yük emniyeti',
    summary: 'Tur öncesi aracı kontrol et ve yükü hiçbir şey tehlike '
        'oluşturmayacak biçimde emniyete al',
    asset: 'assets/academy/driving/m02_fahrzeugcheck.svg',
    slides: [
      SafetySlide(
        title: 'Kontrol neden bir formalite değil',
        blocks: [
          ParagraphBlock(
            'Tur öncesi araç turu iki dakika sürer. Rota ortasında '
            'arızayı, denetimde para cezasını ve en kötü durumda daha '
            'yola çıkmadan görebileceğin bir kazayı önler.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Vardiya öncesi kontrol yükümlülüğü',
            text: 'DGUV Vorschrift 70 (Fahrzeuge — Alman kaza sigortası '
                'araç yönetmeliği) uyarınca her iş vardiyası başlamadan '
                'önce aracını gözle görülür arızalar açısından kontrol '
                'etmelisin. İşletme güvenliğini tehlikeye atan bir arıza '
                'bulursan yola çıkamazsın — bildirirsin.',
          ),
          FactsBlock([
            FactItem('2 dk', 'komple araç turu bu kadar sürer'),
            FactItem('4', 'istasyon: lastik, ışık, sıvılar, yük'),
          ]),
          ParagraphBlock(
            'Önemli: Bu kontrol servis muayenesinin yerini tutmaz. Göze '
            'çarpanı ararsın — gizli arızaları değil.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Araç turu — dört istasyon',
        asset: 'assets/academy/driving/m02b_rundgang.svg',
        blocks: [
          ParagraphBlock(
            'Aracın etrafında her zaman aynı sırayla dolaş. Sabah işler '
            'karıştığında hiçbir şeyi unutmamanın tek yolu sabit bir '
            'sıradır.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/load01_reifen.svg',
              title: '1 · Lastikler ve tekerlekler',
              caption: 'Aracın etrafını bir kez tam dolaş ve dört '
                  'lastiğe de bak: gözle görülür inik, çatlak, yabancı '
                  'cisim, diş derinliği yeterli mi? Sabah bile yumuşak '
                  'görünen bir lastik turu tamamlayamaz.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load02_licht.svg',
              title: '2 · Aydınlatma ve plaka',
              caption: 'Park lambası, kısa far, sinyal, fren lambası ve '
                  'geri vites lambasını kontrol et — fren lambasını '
                  'gerekirse duvardaki yansımadan ya da bir meslektaşla '
                  'birlikte. Plaka açık ve okunur olmalı.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load03_fluessigkeiten.svg',
              title: '3 · Sıvılar ve zemin',
              caption: 'Aracın altına bir bak: zeminde yağ, soğutma '
                  'suyu ya da fren hidroliği izleri her zaman bildirim '
                  'sebebidir. Ayrıca cam suyunu tamamla — kışın '
                  'antifrizli.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load04_ladung.svg',
              title: '4 · Yük bölümü ve yük',
              caption: 'Kapıları aç ve içeri bak: her şey sabit mi, '
                  'ayırma filesi ve bağlama kayışları gergin mi, üstte '
                  'gevşek duran bir şey var mı? Burada gevşek duran, ilk '
                  'sert frende öne uçar.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Lastikler: yolla tek temasın',
        blocks: [
          ParagraphBlock(
            'Dört temas yüzeyi, her biri aşağı yukarı bir kartpostal '
            'büyüklüğünde — yüklü panelvanını yola bağlayan başka bir '
            'şey yok. Fren, direksiyon ve yol tutuşu hakkında '
            'öğrendiğin her şey bu dört yüzeye bağlıdır.',
          ),
          FactsBlock([
            FactItem('1,6 mm', 'yasal asgari diş derinliği'),
            FactItem('3 mm', 'yazın önerilen asgari diş derinliği'),
            FactItem('4 mm', 'kışın önerilen asgari diş derinliği'),
            FactItem('60 € + 1 puan', 'diş derinliği yetersizse'),
          ]),
          BulletsBlock([
            'Diş derinliğini 1 euroluk madenî parayla ölç: altın rengi '
                'kenar 3 mm genişliğindedir — dişin içinde kayboluyorsa '
                'yeterli lastiğin var',
            'Hava basıncını lastikler soğukken ölç ve yüke göre ayarla '
                '— yüklüyken boş haldekinden daha fazla basınç gerekir',
            'Düzensiz aşınmaya dikkat et: tek taraflı aşınma rot ya da '
                'basınç sorunu demektir',
            'Şişkinlikleri, çatlakları ve saplanmış vidaları hemen '
                'bildir',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Az basınç, fazla basınçtan daha tehlikelidir',
            text: 'Yetersiz şişirilmiş lastik ezilerek çalışır, ısınır '
                've tam yükte patlayabilir. Ayrıca fren mesafesi uzar ve '
                'su kızaklaması tehlikesi artar.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Işık, camlar, aynalar',
        blocks: [
          ParagraphBlock(
            'Görülmek, görmek kadar önemlidir. Panelvanda yanmayan bir '
            'fren lambası, kusurlu taraf sen olmasan bile zararı senin '
            'çektiğin arkadan çarpmaların klasik nedenidir.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Açık görüş zorunludur',
            text: '§ 23 Abs. 1 StVO uyarınca görüş ve işitmenin '
                'engellenmemesini sağlamak zorundasın — yük, yolcu, '
                'buzlanmış ya da kirli camlar yüzünden. Kazınarak açılan '
                'bir “gözetleme deliği” açıkça yeterli değildir.',
          ),
          BulletsBlock([
            'Aynaları araç dururken, motor çalışmadan önce ayarla — '
                'asla sürüş sırasında',
            'Dış aynaları kendi aracının ince bir şeridi görünecek '
                'şekilde ayarla: bu senin referans noktandır',
            'Camları ve aynaları içeriden de dışarıdan da temiz tut — '
                'iç yüzeydeki yağ geceleri aşırı kamaştırır',
            'İz bırakan silecek lastiklerini hemen değiştirt',
          ]),
          RevealBlock(
            prompt: 'Araç turunda fark ediyorsun: sağ dış ayna oynuyor '
                've çatlamış. Önünde daha 190 durak var. Yola çıkmalı '
                'mısın?',
            answer: 'Bildirilmeden yola çıkma. Sağ dış ayna, bisikletli '
                've kaldırım tarafındaki kör noktayı emniyete aldığın '
                'aynadır — ağır dönüş kazaları tam da orada olur. '
                'Çatlamış, oynayan bir ayna trafik güvenliğini ilgilendiren '
                'bir arızadır. Bildir, değiştirt ya da araç değiştir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Yük emniyeti: kuvvetleri anlamak',
        blocks: [
          ParagraphBlock(
            'Yük, sert bir frende ya da ani bir kaçınma manevrasında '
            'bile kaymayacak şekilde emniyete alınmalıdır. Bunun somut '
            'olarak ne anlama geldiği kabul görmüş teknik kurallarda '
            'yazar — ve bu kurallar net değerlerle hesap yapar.',
          ),
          FactsBlock([
            FactItem('0,8 g', 'öne doğru etki eden ve karşı emniyet '
                'alınması gereken kuvvet'),
            FactItem('0,5 g', 'arkaya ve yana doğru etki eden kuvvet'),
            FactItem('16 kg', 'tek başına 20 kg\'lık bir paketin frende '
                'ihtiyaç duyduğu tutma kuvveti'),
          ]),
          ParagraphBlock(
            'Türkçesi: 20 kg\'lık bir paket sert frende yaklaşık 16 kg '
            'kuvvetle öne bastırır — sanki dolu bir su kasasını bölme '
            'duvarına doğru itmişsin gibi. Bu paketlerden yirmi tane '
            'olduğunda, aynı anda öne gitmek isteyen 300 kg\'ın üzerinde '
            'bir kütle demektir.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 22 StVO — Yük',
            text: 'Yük, sert frende ya da ani kaçınma hareketinde bile '
                'kaymayacak, devrilmeyecek, ileri geri yuvarlanmayacak '
                'ya da düşmeyecek şekilde yerleştirilmeli ve emniyete '
                'alınmalıdır. Emniyete alınmamış yük para cezasıyla, '
                'tehlike oluşursa ceza puanıyla yaptırıma bağlanır — ve '
                'sürücüyü bulur.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ciddi bir durumda 20 kg neye yol açar',
        blocks: [
          ParagraphBlock(
            '0,8 g değeri fren ve kaçınma için geçerlidir. Gerçek bir '
            'çarpışmada çok kısa bir süre boyunca çok daha yüksek '
            'yavaşlamalar etki eder — emniyete alınmamış bir paketin '
            'çarpma şiddeti o zaman ağırlığının kat kat üzerindedir.',
          ),
          RevealBlock(
            prompt: 'Örnek olay: Bir sonraki durak olduğu için yolcu '
                'koltuğunda 12 kg\'lık bir gönderi duruyor. Şehir içinde '
                'bir çocuk yüzünden sert fren yapmak zorunda kalıyorsun. '
                'Pakete ne olur?',
            answer: 'Bir şey onu durdurana kadar senin ilk hızınla '
                'hareketine devam eder — gösterge paneli, ön cam ya da '
                'yandan çarpmada senin kafan. Normal bir tehlike freninde '
                'bile koltuktan ayak boşluğuna uçar ve orada fren '
                'pedalının altına girebilir. Tam da bu yüzden hiçbir '
                'gönderi öne ait değildir: bir sonraki durak yolcu '
                'koltuğunda değil, yük bölümünde önceden ayrılarak '
                'hazırlanır.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Sürücü kabininde hiçbir şey olmaz',
            text: 'Sürücü bölümünde paket yok, rulo kutu yok, gevşek '
                'alet yok. Fren pedalının altındaki bir cisim, tam da ona '
                'ihtiyacın olan anda freni elinden alır.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Doğru yükleme böyle yapılır',
        asset: 'assets/academy/driving/m02c_ladung.svg',
        blocks: [
          ParagraphBlock(
            'Temel kural: ağır olan aşağı, ağır olan öne, ağırlık '
            'akslara eşit dağılsın. Yüksek yüklenmiş bir panelvanın '
            'ağırlık merkezi yüksektir — ve virajda daha kayacak mısın '
            'yoksa çoktan devrilecek misin, bunu o belirler.',
          ),
          DoDontBlock(
            doTitle: 'Emniyete alınmış',
            dos: [
              'Ağır paketler altta ve önde, bölme duvarına dayalı',
              'Ağırlık sağa/sola eşit dağıtılmış',
              'Boşluk bırakmadan yükle — aralıkları kapat ki hiçbir şey '
                  'hız alamasın',
              'Bağlama kayışları ve ayırma filesi gergin, yük bölümü '
                  'boşalsa bile',
              'Her ilave yüklemeden sonra kısaca kontrol et',
            ],
            dontTitle: 'Emniyetsiz',
            donts: [
              'Ağır paketler üste gevşekçe istiflenmiş',
              'Gönderiler ayak boşluğunda ya da yolcu koltuğunda',
              'Her şey sadece “bir şekilde” içeri itilmiş, boşluklar '
                  'açık',
              'Ayırma filesi, uzanırken engel olduğu için çözülmüş',
              'Yük sadece kendi vücut ağırlığınla “tutuluyor”',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'En tehlikelisi boş yük bölümüdür',
            text: 'İçeride ne kadar az şey varsa, kalan paketin hız '
                'almak için o kadar çok yolu vardır. Yarı boş, yarı '
                'tehlikeli demek değildir — yeniden emniyete al demektir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kabinde düzen ve emniyet kemeri',
        blocks: [
          ParagraphBlock(
            'İçecek, telefon, tarayıcı, irsaliyeler — her şeyin sabit '
            'bir yeri olur. Yuvarlanan, tıkırdayan ya da uçan her şey '
            'bakışını yoldan alır. Toplu bir sürücü yeri, güvenli bir '
            'sürücü yeridir.',
          ),
          FactsBlock([
            FactItem('30 €', 'emniyet kemeri takılı değilse idari para '
                'cezası'),
            FactItem('Her', 'durakta kemeri yeniden tak, 200 metre için '
                'bile'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 21a StVO — Kemer zorunluluğu',
            text: 'Emniyet kemeri sürüş boyunca takılı olmalıdır — iki '
                'durak arasındaki kısa mesafeler için bir istisna yoktur. '
                'Kemersiz bir kazada ayrıca müterafik kusur sayılabilir.',
          ),
          ParagraphBlock(
            'Özellikle dağıtımda kemer, en sık atlanan emniyet '
            'önlemidir — çünkü iki durak arasında sadece birkaç yüz '
            'metre vardır. Oysa şehir içi çarpışmaların çoğu tam da '
            'orada olur.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Yola çıkmadan önce kontrol listesi',
        blocks: [
          ChecklistBlock(
            title: 'Yola çıkmadan önce',
            items: [
              'Araç turunu sabit sırayla yaptım',
              'Lastikler: diş, basınç, hasar kontrol edildi',
              'Aydınlatma baştan sona kontrol edildi, plaka okunur',
              'Aracın altında sıvı izi yok',
              'Camlar ve aynalar temiz, aynalar ayarlı',
              'Ağır paketler altta ve önde, ağırlık dağıtılmış',
              'Bağlama kayışları ve ayırma filesi gergin',
              'Sürücü kabininde gevşek bir şey yok, telefon tutucuda',
              'Reflektörlü yelek elimin altında, reflektörlü üçgen '
                  'araçta',
              'Kemer takılı',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M3
  SafetyChapterContent(
    id: 'm3',
    title: 'Defansif ve öngörülü sürüş',
    summary: 'Mesafeyi, hızı ve dikkati her zaman bir yedeğin kalacak '
        'şekilde yönet',
    asset: 'assets/academy/driving/m03_defensiv.svg',
    slides: [
      SafetySlide(
        title: 'Duruş mesafesi = tepki yolu + fren mesafesi',
        blocks: [
          ParagraphBlock(
            'Duruş mesafesi, tehlikeyi fark ettiğin andan tam durmaya '
            'kadar geçen yoldur. İki parçadan oluşur: hâlâ tam hızla '
            'aldığın tepki yolu ve asıl fren mesafesi.',
          ),
          FactsBlock([
            FactItem('yaklaşık 1 sn', 'uyanık ve ayık bir sürücünün '
                'tepki süresi'),
            FactItem('× 3', 'tepki yolu = hız ÷ 10, çarpı 3'),
            FactItem('²', 'fren mesafesi = (hız ÷ 10) kare'),
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Pratik formüller',
            text: 'Tepki yolu = (km/sa ÷ 10) × 3. Fren mesafesi = '
                '(km/sa ÷ 10) × (km/sa ÷ 10). İkisinin toplamı duruş '
                'mesafesini verir. Tehlike freninde fren mesafesi yarıya '
                'iner.',
          ),
          ParagraphBlock(
            'Belirleyici nokta şu: fren mesafesi hızla orantılı değil, '
            'karesiyle büyür. İki kat hız, dört kat fren mesafesi demek '
            '— yerleşim yolunda 20 km/sa fazlanın neden her şeyi '
            'değiştirdiğinin sebebi budur.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tahmin etme, hesapla',
        blocks: [
          TableBlock(
            headers: ['Hız', 'Tepki', 'Fren mesafesi', 'Duruş mesafesi'],
            rows: [
              ['30 km/sa', '9 m', '9 m', '18 m'],
              ['50 km/sa', '15 m', '25 m', '40 m'],
              ['70 km/sa', '21 m', '49 m', '70 m'],
              ['100 km/sa', '30 m', '100 m', '130 m'],
            ],
          ),
          ParagraphBlock(
            'Karşılaştırma için: bir Sprinter yaklaşık 6 metre '
            'uzunluğundadır. Yani 50 hızda tam durmak için aşağı yukarı '
            'yedi araç boyuna ihtiyacın var — ve bunun ilk iki buçuğu '
            'daha pedala dokunmadan geçer.',
          ),
          RevealBlock(
            prompt: 'Hesap sorusu: Bir yerleşim yolunda 50 km/sa '
                'gidiyorsun. 20 metre ileride park hâlindeki iki arabanın '
                'arasından bir çocuk yola fırlıyor. Durabilir misin?',
            answer: 'Hayır. Tek başına tepki yolun 15 metre, ardından 25 '
                'metre fren mesafesi geliyor — toplam 40 metre. Tehlike '
                'freniyle bile (15 m + 12,5 m = 27,5 m) 20 metre yetmez. '
                'Buna karşılık 30 hızda: 9 m tepki + 9 m fren mesafesi = '
                '18 metre — iki metre önce durursun. Bir korku ile ağır '
                'bir kaza arasındaki fark tam olarak budur.',
          ),
        ],
      ),
      SafetySlide(
        title: 'İki saniye kuralı',
        asset: 'assets/academy/driving/m03b_abstand.svg',
        blocks: [
          ParagraphBlock(
            'Takip mesafesi bir nezaket değil, metre cinsinden tepki '
            'sürendir. Saniye olarak düşünüldüğünde de kendiliğinden '
            'hızına uyum sağlar.',
          ),
          StepsBlock([
            'Yol kenarında sabit bir nokta seç — levha, direk, yol '
                'çizgisi',
            'Öndeki araç bu noktayı geçtiğinde saymaya başla: '
                '“bin bir, bin iki”',
            '“Bin iki” demeden noktaya varıyorsan, çok yakın '
                'gidiyorsun',
            'Islak zeminde, siste ya da karanlıkta üç saniyeye çıkar',
          ]),
          FactsBlock([
            FactItem('2 sn', 'kuru zeminde asgari takip mesafesi'),
            FactItem('3 sn+', 'ıslak zeminde, siste, karanlıkta'),
            FactItem('28 m', '50 hızda 2 saniyeye karşılık gelir'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 4 Abs. 1 StVO — Takip mesafesi',
            text: 'Öndeki araca mesafe kural olarak, o ani fren yapsa '
                'bile arkasında durulabilecek kadar büyük olmalıdır. '
                'Pratik kural olarak şehir dışında hız göstergesindeki '
                'değerin yarısı metre cinsinden geçerlidir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Mesafe olmadığında',
        blocks: [
          RevealBlock(
            prompt: 'Örnek olay: Şehirler arası yolda 80 hızda düzgün '
                'biçimde 40 metre mesafe bırakıyorsun. Bir otomobil bu '
                'boşluğa giriyor ve sonra yavaşlıyor. Şimdi doğrusu ne?',
            answer: 'Sinirlenme, korna çalma, sıkıştırma — gazı bırak ve '
                'mesafeyi yeniden oluştur. Bu sana birkaç saniyeye mal '
                'olur ve riskini düşüren tek tepkidir. Bunun yerine '
                'boşluğu “savunmak” için yaklaşan biri, 80 hızda artık 40 '
                'metreye değil belki 15 metreye sahiptir — ki bu, 24 '
                'metrelik salt tepki yolundan bile azdır.',
          ),
          DoDontBlock(
            doTitle: 'Sakin ve hâkim',
            dos: [
              'Araç önüne girdikten sonra mesafeyi sakince yeniden '
                  'oluştur',
              'Arkanda sıkıştıran varsa: sağa yanaş, geçmesine izin ver',
              'Işıklardan ve şantiyelerden önce erken gaz kes',
              'Trafik sıkışıklığında öndeki araçla boşluk bırak ki '
                  'şerit değiştirebilesin',
            ],
            dontTitle: 'Riskli',
            donts: [
              'Araya girilmesini engellemek için yaklaşmak',
              'Selektör ve kornayı terbiye aracı olarak kullanmak',
              'Dur kalk trafiğinde doğrudan tamponun dibine kadar '
                  'ilerlemek',
              'Mesafeyi saniyeyle değil, sadece hisle tahmin etmek',
            ],
          ),
          FactsBlock([
            FactItem('400 €\'ya kadar', 'takip mesafesi ihlalinde para '
                'cezası, ayrıca ceza puanı ve sürüş yasağı'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Bakışını uzağa at',
        asset: 'assets/academy/driving/m03c_blickfuehrung.svg',
        blocks: [
          ParagraphBlock(
            'Önündeki tampona değil, 12–15 saniye ileriye bak — şehir '
            'içinde yaklaşık iki sokak öteye. Böylece fren lambalarını, '
            'trafik ışıklarını, yayaları ve darlıkları erken görür, '
            'telaşla tepki vermek zorunda kalmazsın.',
          ),
          BulletsBlock([
            'Kaldırım kenarında henüz etrafına bakmamış bir çocuk',
            'Birazdan park hâlindeki bir arabanın etrafından dolanacak '
                'bisikletli',
            'Arkasında birinin oturduğu araç kapısı — arka lambalar '
                'yanıyor, iç aynada baş görünüyor',
            'Üç araç ötede yanan fren lambaları',
            'Yol kenarındaki çöp konteynerleri: manevra trafiğinin '
                'işareti',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Bakış aracı yönlendirir',
            text: 'Nereye bakarsan oraya gidersin. Bu yüzden kaçınırken '
                'her zaman boş alana bak — asla engele değil.',
          ),
          ParagraphBlock(
            'Birkaç saniyede bir aynalara atılan kısa bir bakış da buna '
            'dahildir. Böylece arkanda ne olduğunu her an bilirsin ve '
            'acil durumda önce bakmak zorunda kalmazsın.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Hız fizik demektir',
        blocks: [
          ParagraphBlock(
            'İzin verilen hız bir üst sınırdır, bir hedef değil. '
            'Yerleşim bölgelerinde, okul çevrelerinde, park hâlindeki '
            'araçların yanında ve dar sokaklarda izin verilenden yavaş '
            'gitmek çoğu zaman tek doğru seçimdir.',
          ),
          FactsBlock([
            FactItem('×4', 'hız iki katına çıkınca fren mesafesi'),
            FactItem('18 m', '30 km/sa hızda duruş mesafesi'),
            FactItem('40 m', '50 km/sa hızda duruş mesafesi'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 3 Abs. 1 StVO — Görüş mesafesinde sürme kuralı',
            text: 'Ancak görebildiğin mesafede durabileceğin kadar hızlı '
                'gidebilirsin. Siste, karanlıkta ya da görüşün kapalı '
                'olduğu bir virajda bu, levhanın izin verdiğinden çok '
                'daha azdır.',
          ),
          ParagraphBlock(
            'Bir kez hesapla, hız yapmak gerçekte ne kazandırıyor: on '
            'kilometrelik şehir içi güzergâhta 50 ile 60 arasında en iyi '
            'ihtimalle iki dakika kazanırsın — onu da bir sonraki kırmızı '
            'ışık geri alır.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Yüklü panelvanın neden farklı davranır',
        blocks: [
          ParagraphBlock(
            'Tam yüklü bir panelvan, sabah boş hâlindeki aynı araçtan '
            'başka bir araçtır. Daha fazla kütle, frenin sönümlemesi '
            'gereken daha fazla hareket enerjisi demektir — ve daha '
            'yüksek bir ağırlık merkezi, virajda daha az yedek demektir.',
          ),
          FactsBlock([
            FactItem('3,5 t', 'panelvanının azami yüklü ağırlığı'),
            FactItem('1,4 t\'a kadar', 'yük kapasitesi — boş ağırlığın '
                'yarısından fazlası'),
            FactItem('yüksek', 'ağırlık merkezi: otomobillerin hâlâ '
                'kaydığı yerde kapalı kasa devrilir'),
          ]),
          BulletsBlock([
            'Yüklüyken daha erken ve daha yumuşak fren yap — aynı '
                'yavaşlama için fren daha uzun süreye ihtiyaç duyar',
            'Virajlarda belirgin biçimde daha yavaş: yük dışa kayar ve '
                'devrilme eğilimini artırır',
            'Kaçınma manevralarında ani karşı direksiyon kırma — yüksek '
                'araçları devirense tam da budur',
            'Göbeklere ve otoyol çıkışlarına alışık olduğundan çok daha '
                'düşük hızla gir',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Devrilme anı uyarı vermeden gelir',
            text: 'Bir otomobilin aksine, yüksek kapalı kasa bir araç '
                'devrileceğini neredeyse hiç belli etmez. Yükün '
                'kaydığını duyuyorsan zaten çok hızlısın — hızı viraja '
                'girmeden önce düşür, virajın içinde değil.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kör nokta',
        asset: 'assets/academy/driving/m03d_toterwinkel.svg',
        blocks: [
          ParagraphBlock(
            'Panelvanının büyük kör noktaları var — özellikle sürücü '
            'kabininin sağ yanında ve sağ arka çaprazında. Oraya '
            'bisikletiyle birlikte koca bir bisikletli sığar ve sen onu '
            'aynada göremezsin.',
          ),
          FactsBlock([
            FactItem('sağ', 'kapalı kasa araçlarda en büyük kör nokta'),
            FactItem('1,5 m', 'şehir içinde bisikletlileri geçerken '
                'asgari yan mesafe'),
            FactItem('2 m', 'şehir dışında asgari yan mesafe'),
          ]),
          ParagraphBlock(
            'Aynaları doğru ayarlamak kör noktayı küçültür ama ortadan '
            'kaldırmaz. Bu yüzden her şerit değişimi ve her dönüşte omuz '
            'üstü bakış şarttır — omzunun üzerinden atılan kısa ve '
            'gerçek bir bakış, sadece aynaya doğru baş sallamak değil.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Görüldüğünü asla varsayma',
            text: 'Göz teması, birinin seni fark ettiğinin tek güvenilir '
                'kanıtıdır. Sinyal bir niyettir, garanti değil.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dönüş: en tehlikeli an',
        blocks: [
          ParagraphBlock(
            'Bisikletli ve yayalarla yaşanan ağır çarpışmaların çoğu '
            'sağa dönüşte olur. Nedeni hep aynıdır: bisikletli düz '
            'devam eder ve tam olarak sürücünün direksiyonu kırarken '
            'artık göremediği bölgede bulunur.',
          ),
          RevealBlock(
            prompt: 'Örnek olay: Işıklarda sağa dönmek istiyorsun. Bir '
                'bisikletli seni soldan geçti ve yanında duruyor. Işık '
                'yeşile dönüyor. Önce ne yaparsın?',
            answer: 'Durur ve onu geçirirsin. Hareket edip direksiyonu '
                'kırdığın anda sağdaki kör noktaya girer — üstelik aracın '
                'arka kısmı dönüş sırasında onun şeridine doğru savrulur. '
                'Doğrusu şu: kalkmadan önce sağa omuz üstü bak, '
                'bisikletli ve yayaları geçir, sonra yavaşça direksiyonu '
                'kır ve dönüş sırasında sağ aynaya bir kez daha bak. '
                'Sadece aynaya güvenen, tam da iş ciddileştiğinde onu '
                'göremez.',
          ),
          DoDontBlock(
            doTitle: 'Güvenli dönüş',
            dos: [
              'Erken sinyal ver ve hızı belirgin biçimde düşür',
              'Direksiyonu kırmadan önce omuz üstü bak — sadece ayna '
                  'değil',
              'Dönüş sırasında sağı bir kez daha kontrol et',
              'Tereddüt edersen dur ve geçir',
            ],
            dontTitle: 'Riskli',
            donts: [
              'Boşluğu kullanmak için hız almışken dönmek',
              'Sadece aynaya bakmak',
              'Bisikletlilerin arkanda kalacağını varsaymak',
              'Sinyali ancak direksiyonu kırarken vermek',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Dönüşte ve dönüş manevrasında',
            text: '§ 9 Abs. 5 StVO: Bir araziye dönerken, U dönüşü '
                'yaparken ve geri giderken diğer yol kullanıcılarının '
                'tehlikeye girmesini kesin olarak engellemelisin — '
                'gerekirse bir yönlendirici yardımı almalısın.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrol listesi: defansif sürüş',
        blocks: [
          ChecklistBlock(
            title: 'Bugünden itibaren uyguluyorum',
            items: [
              'Tepki yolu ve fren mesafesi için pratik formülleri '
                  'biliyorum',
              'Mesafemi sabit bir noktada iki saniyeyle kontrol '
                  'ediyorum',
              'Islak zeminde ve karanlıkta üç saniyeye çıkıyorum',
              'Tampona değil, 12–15 saniye ileriye bakıyorum',
              'Yüklüyken virajlara daha yavaş giriyor ve daha erken '
                  'fren yapıyorum',
              'Her dönüş ve şerit değişiminden önce gerçek bir omuz '
                  'üstü bakış yapıyorum',
              'Şehir içinde bisikletlileri geçerken 1,5 m mesafe '
                  'bırakıyorum',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M4
  SafetyChapterContent(
    id: 'm4',
    title: 'Geri gitme ve manevra',
    summary: 'En sık hasar kaynağını kontrol altına al — güvenli geri '
        'git ve dar durumlarda manevra yap',
    asset: 'assets/academy/driving/m04_rueckwaerts.svg',
    slides: [
      SafetySlide(
        title: '1 numaralı hasar kaynağı',
        blocks: [
          ParagraphBlock(
            'Panelvan hasarlarının çoğu yavaşken oluşur — geri giderken '
            've manevra yaparken: babalar, duvarlar, direkler, başka '
            'araçlar, açık kapılar. Ve en kötü durumda aracın arkasında '
            'kör noktada duran insanlar.',
          ),
          FactsBlock([
            FactItem('% 70', 'tüm panelvan hasarları manevra sırasında '
                'oluşur'),
            FactItem('< 10 km/sa', 'manevra hasarlarının çoğunun '
                'oluştuğu hız'),
            FactItem('kör', 'aracın hemen arkasında birkaç metrelik bir '
                'bölge'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Neden tam da burada',
            text: 'Geri giderken seni normalde koruyan şey eksiktir: '
                'açık görüş. Aynı anda yavaş ve bu yüzden tehlikesiz '
                'hissettirir — dağıtım gününün en tehlikeli '
                'birleşimidir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Geri gitmeyi ustalaşmak yerine ondan kaçın',
        blocks: [
          ParagraphBlock(
            'En güvenli geri manevra, hiç yapmadığındır. Daha durağa '
            'yanaşırken oradan nasıl çıkacağını düşün — o zaman sonunda '
            'manevra yapmana hiç gerek kalmaz.',
          ),
          BulletsBlock([
            'Mümkünse ileri geri park et ve ileri geri çık',
            'Dar bir girişe geri gitmektense 40 metre ileride durmayı '
                'tercih et',
            'Çıkmaz sokak ve avlularda: girmeden önce nasıl '
                'çıkacağını düşün',
            'Rota üzerindeki dönüş imkânlarını aklında tut — her gün '
                'aynılar',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Hukuk ve DGUV ne istiyor',
            text: '§ 9 Abs. 5 StVO: Geri giderken başkalarının tehlikeye '
                'girmesini kesin olarak engellemeli, gerekirse bir '
                'yönlendiriciden yardım almalısın. DGUV Vorschrift 70 '
                '(Fahrzeuge) da aynısını ister: geri gitme, ancak '
                'kişilerin tehlikeye girmesi kesin olarak dışlandığında '
                'yapılır.',
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
            text: '“Get Out And Look” — dur, in, aracın arkasına bak, '
                'ancak ondan sonra geri git. Bu, koltuktan asla '
                'göremeyeceğin şeyleri tam olarak ortaya çıkarır.',
          ),
          ParagraphBlock(
            'Bu tur on ila on beş saniye sürer. Bu sürede alçak '
            'babaları, kaldırım kenarlarını, eğimi, gevşek rögar '
            'kapaklarını, oynayan çocukları ve kapı girişinin yüksekliğini '
            'görürsün. Bunların hiçbirini bir geri görüş kamerası sana '
            'güvenilir biçimde göstermez.',
          ),
          FactsBlock([
            FactItem('15 sn', 'bir GOAL turu bu kadar sürer'),
            FactItem('90 cm', 'bir çocuğun aracın arkasında görünmez '
                'kaldığı boy sınırı'),
          ]),
          ParagraphBlock(
            'Bir şey daha: İnerken gördüklerin aklında kalır. Sonrasında '
            'bilinmezliğe doğru değil, tanıdığın bir görüntüye doğru '
            'gidersin.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Adım adım GOAL',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/goal01_stopp.svg',
              title: '1 · Dur',
              caption: 'Geri vitese takmadan önce tamamen durur ve '
                  'aracı emniyete alırsın. Çoktan hareket hâlinde olan '
                  'artık karar vermez — sadece tepki verir.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal02_aussteigen.svg',
              title: '2 · İn',
              caption: 'Koltukta kıvrılıp bakmak yerine araçtan in. '
                  'Bunu yaparken basamağı ve tutamakları kullan — üç '
                  'nokta kuralı burada da geçerli.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal03_umschauen.svg',
              title: '3 · Etrafına bak',
              caption: 'Aracın etrafını bir kez tam dolaş: arkada alçak '
                  'ne var, giriş ne kadar yüksek, eğim nerede, yakında '
                  'çocuk ya da hayvan var mı? Mesafeleri ve sabit '
                  'noktaları aklına kazı.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal04_zurueck.svg',
              title: '4 · Yavaşça geri',
              caption: 'Ancak şimdi geri git — yürüme hızında, omuz '
                  'üstünden ve iki aynadan bakarak. Tereddüt edersen bir '
                  'kez daha dur ve yeniden bak.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Yavaş olmak zararsız demek değildir',
        blocks: [
          StepsBlock([
            'Yürüme hızını seç — asla daha hızlı, boş avluda bile',
            'Duyabilmek için camı indir: sesler, kornalar, çocuklar',
            'Dönüşümlü olarak omuz üstünden ve iki aynadan bak',
            'Kamerayı sadece tamamlayıcı olarak kullan, asla tek '
                'kaynak olarak',
            'Her tereddütte dur, in, yeniden bak',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Kamera yanılgısı',
            text: 'Geri görüş kamerası yalnızca bir kesit gösterir, '
                'mesafeleri çarpıtır ve yağmurda, karda, çamurda kör '
                'olur. Arkanın yan tarafından senin yoluna girecek '
                'hiçbir şeyi görmez. GOAL\'ın yerini tutmaz.',
          ),
          FactsBlock([
            FactItem('yürüme', 'manevrada azami hız'),
            FactItem('2 sn', 'bir çocuğun aracın arkasındaki bölgeye '
                'koşması bu kadar sürer'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Yönlendiriciyi doğru kullanmak',
        blocks: [
          ParagraphBlock(
            'Bir yönlendirici ancak kurallar önceden netse işe yarar. '
            'Aracın arkasında bir yerde durup el sallayan bir '
            'meslektaş güvenlik değildir — ek bir risktir.',
          ),
          BulletsBlock([
            'İşaretleri önceden kararlaştır: dur, yavaş, devam, ne '
                'kadar yer var',
            'Yönlendirici yandan durur, asla doğrudan aracın arkasında '
                'değil',
            'Onu aynada sürekli görmelisin — göremiyorsan dur demektir',
            'Sadece tek bir kişi yönlendirir, aynı anda birkaç kişi '
                'değil',
            'Yönlendirici reflektörlü yelek giyer, özellikle alacakaranlıkta',
          ]),
          RevealBlock(
            prompt: 'Dar bir avlu girişine geri gidiyorsun, meslektaşın '
                'yönlendiriyor. Aniden onu aynada göremez oluyorsun. Ne '
                'yaparsın?',
            answer: 'Derhâl dur — yavaşlama, tamamen dur. Görüş teması '
                'yoksa geçerli bir işaret de yoktur. Belki aracın '
                'arkasından geçti, ayağı kaydı ya da bir yoldan geçen '
                'onunla konuşmaya başladı. Ancak onu yeniden gördüğünde '
                've sana yeni bir işaret verdiğinde devam et.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Örnek olay: dar avlu girişi',
        blocks: [
          RevealBlock(
            prompt: 'Örnek olay: Son durak bir iç avluda. Giriş dar, '
                'arkanda bir araç bekliyor, yağmur yağıyor ve plandan 40 '
                'dakika gerisin. İçeri ileri girebiliyorsun — çıkış ise '
                'sadece geri geri, bir duvar ve park hâlindeki üç aracın '
                'yanından. Doğru karar nedir?',
            answer: 'Hiç içeri girme. Sokakta dur, son metreleri yürüyerek '
                'taşı ya da el arabasını kullan. Zaten içerideysen: dörtlü '
                'flaşörü yak, in, durumu incele, gerekirse bekleyen '
                'sürücüden geri gitmesini rica et ve ardından ara '
                'kontrollerle birkaç kısa hamlede manevra yaparak çık. '
                'Arkanda bekleyen sürücü acele etmek için bir sebep değil '
                '— hasar sonunda sana yazılır, ona değil. 40 dakikalık '
                'gecikmeyi hiçbir manevra kapatmaz, ama bir sac hasarı '
                'sana günün geri kalanına mal olur.',
          ),
          DoDontBlock(
            doTitle: 'Doğru manevra',
            dos: [
              'Tek uzun hamle yerine birkaç kısa hamlede',
              'Arada durup durumu yeniden kontrol et',
              'Trafiğe açık alanda manevra yaparken dörtlü flaşör',
              'Daha uzakta durup son metreleri yürümeyi tercih et',
            ],
            dontTitle: 'Yanlış',
            donts: [
              'Bekleyenlerin baskısıyla daha hızlı manevra yapmak',
              'Aksi hâlde utanç verici görüneceği için “tek hamlede '
                  'bitirmek”',
              'Sadece kameraya ya da sensörlere güvenmek',
              'Yayalar bölgeden geçerken manevra yapmak',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrol listesi: geri gitme ve manevra',
        blocks: [
          ChecklistBlock(
            title: 'Her geri manevradan önce',
            items: [
              'Önce geri gitmekten kaçınıp kaçınamayacağımı kontrol '
                  'ediyorum',
              'Geri vitese takmadan önce tamamen duruyorum',
              'Araçtan inip aracın arkasına bakıyorum (GOAL)',
              'Geri geri sadece yürüme hızında gidiyorum',
              'Sadece kameraya değil, omuz üstünden ve iki aynadan da '
                  'bakıyorum',
              'Duyabilmek için camı indiriyorum',
              'Yönlendiriciyi göremez olduğumda hemen duruyorum',
              'Küçük göçük de olsa her manevra hasarını bildiriyorum',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M5
  SafetyChapterContent(
    id: 'm5',
    title: 'Hava, görüş ve zorlu koşullar',
    summary: 'Sürüş tarzını yağmura, ıslaklığa, sise, kara, karanlığa '
        've sıcağa uyarla',
    asset: 'assets/academy/driving/m05_wetter.svg',
    slides: [
      SafetySlide(
        title: 'Islaklık her şeyi değiştirir',
        blocks: [
          ParagraphBlock(
            'Islak yolda yol tutuşu belirgin biçimde azalır — fren '
            'mesafesi hatırı sayılır ölçüde, birçok durumda neredeyse '
            'iki katına kadar uzar. Özellikle kritik olan, uzun bir '
            'kuraklıktan sonraki ilk yağmurdur: yoldaki yağ ve lastik '
            'kalıntısı suyla birlikte kaygan bir film oluşturur.',
          ),
          FactsBlock([
            FactItem('×2\'ye kadar', 'ıslakta fren mesafesi bu kadar '
                'uzar'),
            FactItem('3 sn+', '2 saniye yerine asgari takip mesafesi'),
            FactItem('−% 20', 'kaba bir yönlendirme olarak hız'),
          ]),
          BulletsBlock([
            'Daha erken ve daha yumuşak fren yap, virajın içinde değil',
            'Direksiyon hareketlerini yumuşak yap, ani değil',
            'Yol çizgilerine, rögar kapaklarına ve tramvay raylarına '
                'dikkat et — en kaygan yerler oralardır',
            'Tekerlek izlerinden kaçın, su orada birikir',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Hız bir zorunluluktur, tercih değil',
            text: '§ 3 Abs. 1 StVO hızını yol, trafik, görüş ve hava '
                'koşullarına uyarlamanı ister. Islak yolda bir kazada '
                'izin verilen hız seni kurtarmaz.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Su kızaklaması: gerçekte ne oluyor',
        asset: 'assets/academy/driving/m05b_aquaplaning.svg',
        blocks: [
          ParagraphBlock(
            'Su kızaklaması şu demektir: lastikle yol arasına bir su '
            'filmi girer. Lastik su üzerinde yüzer. O andan itibaren '
            'direksiyonun ve frenin etkisi kalmaz — azalmaz, hiç '
            'kalmaz.',
          ),
          ParagraphBlock(
            'Diş kanallarının tam olarak tek bir görevi vardır: suyu '
            'lastiğin önünden uzaklaştırmak. Yüksek hızda bir lastiğin '
            'her saniye litrelerce suyu yerinden atması gerekir. Diş ne '
            'kadar sığ ve hız ne kadar yüksekse, bunu o kadar erken '
            'başaramaz olur.',
          ),
          FactsBlock([
            FactItem('1,6 mm', 'yasal asgari — su kızaklaması için '
                'zaten az'),
            FactItem('3 mm', 'yağışlı havada pratik alt sınır'),
            FactItem('Hız²', 'su kızaklaması tehlikesi hızla bu kadar '
                'güçlü artar'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Erken nasıl fark edersin',
            text: 'Direksiyon aniden hafifler, sürüş sesleri değişir, '
                'devir sebepsiz yükselir. Bunlar hâlâ gazı '
                'kesebileceğin saniyelerdir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Su kızaklaması: doğru tepki',
        blocks: [
          DoDontBlock(
            doTitle: 'Birikmiş suda doğrusu',
            dos: [
              'Gazı kes — sadece bunu, ani biçimde tümden değil',
              'Direksiyonu sakin ve düz tut',
              'Debriyaja bas ya da vitesi boşa al',
              'Lastikler yeniden tutana kadar aracı serbest bırak',
              'Ancak ondan sonra dikkatlice direksiyon kır ya da fren '
                  'yap',
            ],
            dontTitle: 'Yanlış',
            donts: [
              'Sert fren yapmak — tekerlekler etkisizce kilitlenir',
              'Ani direksiyon ya da karşı direksiyon kırmak',
              '“Geçip kurtulmak” için hızlanmak',
              'Lastikler suda yüzerken şerit değiştirmek',
            ],
          ),
          RevealBlock(
            prompt: 'Örnek olay: Şehirler arası yolda sağanaktan sonra '
                'sağ tekerlek izinde su birikmiş. 80 km/sa gidiyorsun, '
                'arkanda bir otomobil sıkıştırıyor. Ne yaparsın?',
            answer: 'Suya girmeden önce belirgin biçimde gazı kes — '
                'suyun içinde değil. Direksiyonu düz tut ve sıkıştıran '
                'sıkıştırsın; arkadan çarpma onarılabilir, karşı şeride '
                'uçmak onarılamaz. Bunun yerine suyun ortasında fren '
                'yapan ya da manevra yapan, tam da kaçınmak istediği '
                'kontrol kaybını davet eder. Mümkünse: suyu geçtikten '
                'sonra sağa yanaş ve sıkıştıranı geçir.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Su üzerinde yüzen lastik yön vermez',
            text: 'Su filmi aracı taşıdığı sürece her direksiyon '
                'hareketi etkisizdir — ancak lastik yeniden tuttuğunda '
                'bir anda etki eder. Savrulma tam olarak buradan doğar.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Diş derinliği ve kış lastikleri',
        blocks: [
          TableBlock(
            headers: ['Durum', 'Diş / lastik'],
            rows: [
              ['Yasal asgari', '1,6 mm — yıl boyunca'],
              ['Yaz, ıslak yol', '3 mm\'den itibaren önerilir'],
              ['Kış, kar ve sulu kar', '4 mm\'den itibaren önerilir'],
              ['Buzlanma, kar, buz', 'Alpine sembollü kış lastiği'],
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Duruma bağlı kış lastiği zorunluluğu',
            text: '§ 2 Abs. 3a StVO uyarınca buzlanmada, kar '
                'kayganlığında, sulu karda, buz ya da kırağı '
                'kayganlığında yalnızca kışa uygun lastiklerle yola '
                'çıkabilirsin. İhlaller para cezasına ve bir ceza '
                'puanına mal olur — başkalarını engellersen daha '
                'fazlasına.',
          ),
          BulletsBlock([
            'Kış lastiğini Alpine sembolünden tanırsın (kar taneli '
                'dağ)',
            'Kışa uygun lastikler bile diş yetersizse neredeyse hiç '
                'işe yaramaz',
            'Lastik yaşına dikkat et: kauçuk sertleşir ve diş hâlâ '
                'yerindeyken bile tutuşunu kaybeder',
            'İnce dişi ilk don gelmeden bildir — ertesi sabah değil',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Kar, buz ve cam kazıma',
        asset: 'assets/academy/driving/m05c_winter.svg',
        blocks: [
          ParagraphBlock(
            'Buzlanmada her şey için tek kural: yumuşak. Yumuşak kalk, '
            'yumuşak fren yap, yumuşak direksiyon kır. Her ani hareket '
            'zaten az olan tutuşu aşar. Köprüler, orman içi kesimler ve '
            'gölgeli yerler önce donar — ve en son çözülür.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '“Gözetleme deliği” olmaz',
            text: 'Bütün camlar, aynalar, lambalar ve plaka açık olmak '
                'zorundadır (§ 23 Abs. 1 StVO). Kazınarak açılan bir '
                'gözetleme deliği bir kabahattir — ve kaza hâlinde ağır '
                'bir kusur isnadıdır. Yola çıkmadan önce tavandaki karın '
                'da inmesi gerekir.',
          ),
          DoDontBlock(
            doTitle: 'Kış rutini',
            dos: [
              'Bütün camları ve aynaları tamamen kazı',
              'Tavanı, lambaları ve plakayı kardan temizle',
              'Basamakları ve tutamakları buzdan ve çamurdan temizle',
              'Cam suyunu antifrizle tamamla',
              'Yolda açık kapatmak yerine belirgin biçimde erken çık',
            ],
            dontTitle: 'Kış hataları',
            donts: [
              'Cam hâlâ buzunu atarken yola çıkmak',
              'Camın üzerine sıcak su dökmek',
              'Sulu karda aynı anda hem fren yapıp hem direksiyon '
                  'kırmak',
              'Buzlanmış basamakları görmezden gelmek — düştüğün yer '
                  'burasıdır',
            ],
          ),
          FactsBlock([
            FactItem('0 °C', 'buradan itibaren önce köprüler ve gölgeli '
                'yerler'),
            FactItem('×2 ile ×10', 'karda ve buzda fren mesafesi bu '
                'kadar uzar'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Sis, alacakaranlık, karanlık',
        blocks: [
          ParagraphBlock(
            'Görüş kötüyken sadece görmek değil, görülmek de zorlaşır. '
            'Işıkları zamanında yak — tereddüt edersen gerekenden yarım '
            'saat önce.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Siste pratik kural',
            text: 'Metre cinsinden görüş mesafesi, km/sa cinsinden azami '
                'hıza karşılık gelir. Sadece 50 metre görüyorsan en fazla '
                '50 km/sa gidersin — ve görüş mesafesi 50 metrenin '
                'altındayken zaten 50 hız üst sınırdır.',
          ),
          BulletsBlock([
            'Sis farlarını yalnızca gerçek görüş engelinde kullan, '
                'sürekli aydınlatma olarak değil',
            'Arka sis lambasını ancak 50 metrenin altındaki görüşte — '
                'arkadakini fena hâlde kamaştırır',
            'Yol kenarındaki kılavuz direklerini yön bulmak için kullan',
            'Alacakaranlıkta özellikle koyu giysili yayalara dikkat et',
            'İç aydınlatma kapalı, camlar içeriden temiz — ikisi de '
                'yoksa gece görüşünden olursun',
          ]),
          FactsBlock([
            FactItem('50 m', 'şehir dışında iki kılavuz direk arasındaki '
                'mesafe'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Fırtına ve yan rüzgâr',
        blocks: [
          ParagraphBlock(
            'Kapalı kasa aracın büyük ve yüksek bir yüzeydir — yan '
            'rüzgârda bir otomobilden tamamen farklı davranır. Özellikle '
            'tehlikeli olan, rüzgârın aniden bastırdığı yerlerdir: '
            'köprüler, orman çıkışları, binalar arasındaki boşluklar ve '
            'bir kamyon seni geçerken.',
          ),
          BulletsBlock([
            'Hızı belirgin biçimde düşür, iki elin de direksiyonda',
            'Bilinen rüzgârlı yerlerde tutuşunu önceden sıkılaştır ve '
                'bir hamle bekle',
            'Bir kamyonu geçtikten sonra bir rüzgâr darbesi bekle',
            'Fırtınada ağaçların altına ve iskelelerin yanına park '
                'etme',
            'Kapıları rüzgârda sıkı tut — açılıp savrulur ve zarar '
                'görürler',
          ]),
          RevealBlock(
            prompt: 'Örnek olay: Fırtına uyarısı var, boş hâlde bir '
                'otoyol köprüsünden geçiyorsun. Neden tam da boşken '
                'kritik?',
            answer: 'Çünkü araçta onu yolda tutan ağırlık yok. Boş bir '
                'kapalı kasa araç, yüklü olanla aynı rüzgâr yüzeyini '
                'sunar ama yaklaşık üçte bir daha hafiftir — bir hamle '
                'onu belirgin biçimde daha çok savurur. Doğrusu şu: '
                'köprüden önce hızı düşür, iki elini direksiyona koy, '
                'köprü sonunda bir rüzgâr darbesi bekle ve bir kamyonun '
                'yanında gitme.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Sıcak ve uzun turlar',
        blocks: [
          ParagraphBlock(
            'Yazın güneşte fena hâlde ısınan bir araçta çalışır ve bu '
            'sırada kilometrelerce yürürsün. Aşırı ısınmış, susuz kalmış '
            'bir sürücü ölçülebilir biçimde daha yavaş tepki verir — '
            'etkisi yorgunlukla kıyaslanabilir.',
          ),
          FactsBlock([
            FactItem('2–3 l', 'sıcakta vardiya başına sıvı'),
            FactItem('> 60 °C', 'güneşte duran bir araçtaki iç '
                'sıcaklık'),
          ]),
          BulletsBlock([
            'Susuzluk hissetmeden önce düzenli olarak su iç',
            'Molaları gölgede ver, ısınmış sürücü kabininde değil',
            'Uzun yürüyüşlerde başlık ve güneş koruması kullan',
            'Dolaşım sorunlarında hemen bildir ve mola ver',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Asla geride bırakma',
            text: 'Isınmış araçta asla bir hayvan ya da bir insan bırakma '
                '— “sadece beş dakika” için de, camı aralık bırakarak da '
                'olmaz. İç mekân dakikalar içinde hayati tehlike '
                'oluşturacak kadar ısınır.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrol listesi: zorlu koşullar',
        blocks: [
          ChecklistBlock(
            title: 'Hava ve kötü görüş koşullarında',
            items: [
              'Hızımı ve mesafemi sadece levhaya göre değil, koşullara '
                  'göre ayarlıyorum',
              'Islakta takip mesafesini en az 3 saniyeye çıkarıyorum',
              'Su kızaklamasında: gazı kes, düz git, fren yapma',
              'Diş derinliğimi biliyorum ve inceleri erken bildiriyorum',
              'Bütün camları kazıyorum, gözetleme deliği yok',
              'Tavandaki, lambalardaki ve plakadaki karı temizliyorum',
              'Köprülerde ve orman çıkışlarında yan rüzgâr bekliyorum',
              'Yeterince su içiyor ve molalarımı gölgede veriyorum',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M6
  SafetyChapterContent(
    id: 'm6',
    title: 'Dikkat dağınıklığı, yorgunluk ve zaman baskısı',
    summary: 'Kazaların başlıca insani nedenlerini fark et ve etkin '
        'biçimde önlem al',
    asset: 'assets/academy/driving/m06_ablenkung.svg',
    slides: [
      SafetySlide(
        title: 'Direksiyonda telefon: YASAK',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Sürüş sırasında telefonu elde tutmak yasaktır',
            text: 'Ne konuşmak için, ne yazmak için, ne bakmak için — '
                've müzik, podcast ya da mesaj seçmek için de değil.',
          ),
          ParagraphBlock(
            'Çok net ve istisnasız. Bu sadece bizim şirket kuralımız '
            'değil, kanundur. Ve iletişim, bilgi ya da organizasyona '
            'yarayan her elektronik cihaz için geçerlidir — yani tarayıcı '
            'için de.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 23 Abs. 1a StVO',
            text: 'Araç kullanan biri, elektronik bir cihazı ancak onu '
                'ne eline alması ne de tutması gerekmiyorsa '
                'kullanabilir. Cihazı eline almak ya da elde tutmak '
                'zaten ihlaldir — onunla ne yaptığından bağımsız olarak.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Körlemesine alınan yol',
        asset: 'assets/academy/driving/m06b_handy.svg',
        blocks: [
          ParagraphBlock(
            'Ekrana atılan bir bakış bir saniye değildir — ortalama iki '
            'ila üç saniye sürer, okunan bir mesaj ise daha çok beş. Bu '
            'sürede gözlerin kapalı gidiyorsun. Bir kez metre cinsinden '
            'hesapla.',
          ),
          FactsBlock([
            FactItem('14 m/sn', '50 hızda saniyede aldığın yol'),
            FactItem('28 m', 'telefona 2 saniyelik bakışta körlemesine'),
            FactItem('yaklaşık 70 m', 'bir mesaj okursan körlemesine'),
          ]),
          RevealBlock(
            prompt: 'Hesap sorusu: Bir oyun sokağında 30 km/sa gidiyor '
                've 3 saniye tarayıcıya bakıyorsun. Ne kadar yolu '
                'körlemesine alırsın — ve bu bir kazaya yeter mi?',
            answer: '30 km/sa hızda saniyede 8 metrenin biraz üzerinde '
                'yol alırsın, yani 3 saniyede yaklaşık 25 metre. Bu, o '
                'hızdaki komple duruş mesafesinden (18 metre) daha '
                'fazladır. Başka bir deyişle: görebilseydin çoktan '
                'durmuş olacağın bir mesafeyi körlemesine geçiyorsun. '
                'Düşük hızda bir bakışın sorun olmadığını sanan, yavaşı '
                'güvenliyle karıştırıyor — özellikle oyun sokaklarında '
                'çocuklar hiçbir uyarı vermeden yola çıkar.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Müzik, navigasyon, tarayıcı — hepsi önceden',
        blocks: [
          ParagraphBlock(
            'Müzik ve podcast sorun değil — ama telefon elde değil. Her '
            'şeyi yola çıkmadan önce araç dururken seç ve başlat: çalma '
            'listesi, ses düzeyi, navigasyon hedefi, bir sonraki durak. '
            'Bir kez çalışmaya başladıysa, sürüş sırasında cihaza artık '
            'dokunulmaz.',
          ),
          DoDontBlock(
            doTitle: 'İzin var',
            dos: [
              'Çalma listesini ve sesi önceden, araç dururken ayarla',
              'Navigasyon hedefini yola çıkmadan gir',
              'Telefonu tutucuda bırak ve sadece bak',
              'Eller serbest sistemiyle konuş',
              'Diğer her şey için kısaca dur',
            ],
            dontTitle: 'Yasak',
            donts: [
              'Sürüş sırasında şarkı ya da podcast değiştirmek',
              'Sürüş sırasında mesaj okumak ya da yazmak',
              'Kırmızı ışıkta telefonu eline almak',
              'Araç hareket hâlindeyken tarayıcıyı ya da durak '
                  'listesini kullanmak',
              'Daha iyi görmek için cihazı tutucudan almak',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Kulaklık yok',
            text: 'Sürüş sırasında kulaklık ya da kulak içi kulaklık yok '
                '— tek kulakta bile olmaz. Trafiği, kornaları, sesleri '
                've acil durum araçlarını duymak zorundasın. Manevrada '
                'işitmen çoğu zaman tek uyarındır.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tek istisna: araç dururken, motor kapalı',
        blocks: [
          ParagraphBlock(
            'Telefonu, tarayıcıyı ve navigasyonu yalnızca araç güvenli '
            'biçimde dururken kullanırsın. Durakta pratik akış: dur, '
            'motoru kapat, cihazı kullan, sonra in. Ve yola çıkmadan '
            'önce: bin, hedefi ve müziği ayarla, sonra çalıştır.',
          ),
          RevealBlock(
            prompt: 'Hukuken “duruş” ne zaman sayılır — ve kırmızı '
                'ışıktaki dur-kalk sistemi ne olacak?',
            answer: 'Hukuken duruş ancak motor kapatıldığında sayılır. '
                'Motor yalnızca otomatik bir dur-kalk işlevi nedeniyle '
                'sustuğunda istisna açıkça geçerli değildir. Yani kırmızı '
                'ışıkta cihazı eline alamazsın — motor o an sessiz olsa '
                'bile.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'İstisna yalnızca motor kapalıyken',
            text: 'Cihazın kullanımı yalnızca araç duruyor ve motor '
                'kapalıysa mümkündür. Otomatik bir dur-kalk kapanması '
                'bunun için yeterli değildir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Bedeli ne',
        blocks: [
          FactsBlock([
            FactItem('100 € + 1 puan', 'sürüş sırasında telefon elde'),
            FactItem('150 € + 2 puan', 'tehlike oluşursa, ayrıca 1 ay '
                'sürüş yasağı'),
            FactItem('200 € + 2 puan', 'maddi hasar oluşursa, ayrıca '
                '1 ay sürüş yasağı'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Deneme süresi',
            text: 'Ehliyetin deneme süresindeysen buna bir eğitim '
                'semineri ve deneme süresinin 4 yıla uzatılması eklenir.',
          ),
          ParagraphBlock(
            'Profesyonel sürücü olarak senin için sürüş yasağı şu '
            'demektir: bir ay iş yok. Ve dikkat dağınıklığından '
            'yaralanmalı bir kaza çıkarsa iş para cezasıyla kalmaz — o '
            'zaman karayolu trafiğini tehlikeye atma suçlaması gündeme '
            'gelir (§ 315c StGB) ve bu bir suçtur.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'En basit sigorta',
            text: 'Telefonu bir kenara koymak hiçbir şeye mal olmaz ve '
                'ehliyetini, işini ve ciddi durumda bir hayatı korur.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dikkat dağınıklığının birçok biçimi vardır',
        blocks: [
          ParagraphBlock(
            'Sadece telefon değil: yemek, içmek, paket aramak, '
            'konuşmalar, son müşteriye duyulan kızgınlık, bir sonraki '
            'durağın düşüncesi. Dikkat dağınıklığı, gözü, elleri ya da '
            'aklı yoldan alan her şeydir.',
          ),
          DoDontBlock(
            doTitle: 'Sürüş sırasında sorun değil',
            dos: [
              'Yola bakmak',
              'Eller serbest sistemiyle konuşmak',
              'Aynalara kısa bakışlar',
              'Diğer her şey için kısaca durmak',
            ],
            dontTitle: 'Sorun',
            donts: [
              'Yiyecek ya da içecek açmak',
              'Yük bölümünde bir sonraki paketi aramak',
              'Sürerken tarayıcıyı ya da durak listesini kullanmak',
              'Kısaca durmak yerine sürerken rotayı kafada yeniden '
                  'sıralamak',
            ],
          ),
          RevealBlock(
            prompt: 'Örnek olay: Yola çıkarken yanlış gönderiyi almış '
                'olduğunu fark ediyorsun. Doğru durak 300 metre ileride. '
                'Ne yaparsın?',
            answer: 'Bir sonraki güvenli yere kadar git, dur, motoru '
                'kapat, sonra yük bölümünde değiştir. Sürüş sırasında '
                'arkaya uzanmak, sürücülerin şeritten çıktığı klasik '
                'durumdur — bunu yaparken aynı anda başını ve gövdeni de '
                'çevirirsin. 300 metrelik sapma 30 saniye sürer, bir '
                'sürtme hasarı ise günün geri kalanını alır.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Yorgunluk: bedenin pazarlık yapmaz',
        asset: 'assets/academy/driving/m06c_muedigkeit.svg',
        blocks: [
          ParagraphBlock(
            'Yorgunluk bir irade sorunu değildir. Belirli bir noktadan '
            'sonra beynin kısa süreliğine kapanır — istesen de '
            'istemesen de. İşin sinsi tarafı: tam da bu evrede kendi '
            'uyanıklığını en çok abartırsın.',
          ),
          SubheadBlock('Ciddiye alman gereken uyarı işaretleri'),
          BulletsBlock([
            'Sık esneme, yanan ya da ağırlaşan gözler',
            'Son kilometreleri hatırlamıyorsun',
            'Sapakları ya da durakları kaçırıyorsun',
            'Koltuk mesafesi aniden yanlış geliyor, sürekli '
                'kıpırdanıyorsun',
            'Şeritte huzursuz gidiyor ya da sürekli düzeltiyorsun',
            'Dışarıdan bir sebep olmadan üşüme ve ense tutulması',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Riskli saatler',
            text: 'En tehlikelisi sabahın erken saatleri, öğle '
                'yemeğinden sonraki çöküş ve turun son saatidir. '
                'Molalarını tam da oralara planla.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Metre cinsinden mikro uyku',
        blocks: [
          ParagraphBlock(
            'Bir mikro uyku genellikle iki ila beş saniye sürer. Kısa '
            'geliyor kulağa — ta ki metre cinsinden hesaplanana kadar.',
          ),
          FactsBlock([
            FactItem('56 m', '50 hızda 4 saniyelik mikro uykuda'),
            FactItem('89 m', '80 hızda 4 saniyede'),
            FactItem('111 m', '100 hızda 4 saniyede'),
          ]),
          RevealBlock(
            prompt: 'Hesap sorusu: Şehirler arası yolda 80 km/sa gidiyor '
                've 4 saniye dalıyorsun. Ne kadar yolu kontrolsüz '
                'alırsın — ve bu mesafede neler var?',
            answer: '80 km/sa saniyede yaklaşık 22 metre demektir, yani '
                '4 saniyede aşağı yukarı 89 metre. Şehirler arası bir '
                'yolda bu mesafede tipik olarak bir viraj, bir ağaç '
                'sırası ve karşıdan gelen trafik bulunur. Ve telefona '
                'bakmanın aksine bu süre boyunca direksiyon tutmuyorsun '
                '— araç şeritten sürükleniyor. Bu yüzden mikro uykuya '
                'karşı tek bir şey işe yarar: önceden durmak.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Bunun küçük bir sürümü yoktur',
            text: 'Bir kez dalan yeniden dalar — çoğunlukla birkaç '
                'dakika içinde. Sürüş burada biter, bir sonraki durakta '
                'değil.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ne işe yarar — ne yaramaz',
        blocks: [
          DoDontBlock(
            doTitle: 'Gerçekten işe yarar',
            dos: [
              'Durup 15–20 dakika gözlerini kapatmak',
              'İnmek, yürümek, temiz hava ve hareket',
              'Bir şeyler yiyip içmek',
              'Yetmiyorsa turu bildirmek ve destek istemek',
            ],
            dontTitle: 'İşe yaramaz (ya da sadece dakikalarca)',
            donts: [
              'Camı açmak ve müziği açmak',
              'Uykunun yerine kahve koymak',
              'Kendini sohbetle uyanık tutmak',
              'Erken bitirmek için daha hızlı sürmek',
            ],
          ),
          ParagraphBlock(
            '15 ila 20 dakikalık kısa bir uyku ve ardından hareket, kısa '
            'vadede gerçekten işe yarayan tek önlemdir. Diğer her şey '
            'sorunu sadece birkaç kilometre öteler.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Sürüşe elverişsizlik',
            text: 'Fark edilir bir aşırı yorgunluğa rağmen devam eden, '
                'aracı sürüşe elverişsiz hâlde kullanır. Bu sırada bir '
                'tehlike doğarsa bu artık para cezası değil, bir suçtur '
                '(§ 315c StGB).',
          ),
        ],
      ),
      SafetySlide(
        title: 'Zaman baskısını akıllıca yönet ve kontrol listesi',
        blocks: [
          ParagraphBlock(
            'Zaman baskısı gerçektir — ama hız yapmak ve acele etmek '
            'neredeyse hiç zaman kazandırmaz, buna karşılık büyük risk '
            'getirir. Şehir trafiğinde daha hızlı sürerek kazanılan '
            'zaman dakikalar mertebesindedir; tek bir manevra hasarı '
            'sana bir saate mal olur.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Plan tutmadığında',
            text: 'Bu bir güvenlik sorunu değil, bir planlama '
                'konusudur — direksiyonda telafi etmeye çalışmak yerine '
                'erken bildir. Saat 13.00\'teki bir bildirim işe yarar, '
                '18.00\'deki artık yaramaz.',
          ),
          ChecklistBlock(
            title: 'Modül 6\'dan yanıma alıyorum',
            items: [
              'Telefonuma sürüş sırasında dokunmuyorum',
              'Müziği, navigasyonu ve tarayıcıyı yola çıkmadan '
                  'ayarlıyorum',
              '“Duruş”un ancak motor kapalıyken sayıldığını biliyorum',
              'Kulaklık takmıyorum',
              'Kendi yorgunluk işaretlerimi biliyorum',
              'Yorulduğumda dayanmak yerine duruyorum',
              'Gerçekçi olmayan bir planı erken ve dürüstçe '
                  'bildiriyorum',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M7
  SafetyChapterContent(
    id: 'm7',
    title: 'İş kazaları: araca inip binme, kaldırma ve düşmeler',
    summary: 'Sürüş dışındaki yaralanmaları önle — odak: güvenli inip '
        'binme',
    asset: 'assets/academy/driving/m07_ein_aussteigen.svg',
    slides: [
      SafetySlide(
        title: 'Günün en önemli hareketi neden budur',
        blocks: [
          ParagraphBlock(
            'Her turda onlarca kez araca inip biniyorsun — en sık '
            'yaptığın hareket budur. Tam da bu yüzden yaralanmaların '
            'çoğu burada olur: burkulma, basamak kenarında kayma, '
            'araçtan düşme, trafiğe yanlış adım.',
          ),
          FactsBlock([
            FactItem('100.000', 'profesyonel sürücülerde yılda kayma, '
                'takılma ve düşme kazası'),
            FactItem('24', 'düşme başına ortalama iş göremezlik günü'),
            FactItem('1 numara', 'dağıtımdaki en sık yaralanma türü'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'BG Verkehr uyarıyor',
            text: 'BG Verkehr (ulaştırma meslek sigortası) araca inip '
                'binerken yaşanan düşmelerin ağır, kimi zaman ölümcül '
                'yaralanmalara yol açtığı konusunda açıkça uyarıyor.',
          ),
          ParagraphBlock(
            'Güvenli bir iniş ile tehlikeli bir iniş arasındaki fark iki '
            'saniyedir. Günde 250 inişe vurulduğunda bu sekiz dakikayı '
            'biraz geçer — bedeninin en ucuz sigortasıdır.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Üç nokta kuralı (2+1)',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'İki el ve bir ayak — her zaman',
            text: 'BG Verkehr\'in temel kuralı: iki el ve bir ayak her '
                'zaman araçla temas hâlindedir — “2+1”.',
          ),
          ParagraphBlock(
            'Yani bir sonrakini bırakmadan önce her an üç sabit temas '
            'noktan olur. Böylece tek bir kayma asla düşmeye dönüşemez, '
            'çünkü seni hâlâ iki nokta tutar. Her seferinde yalnızca bir '
            'noktayı hareket ettir, asla aynı anda ikisini.',
          ),
          RevealBlock(
            prompt: 'Hangi üç temas noktası kastediliyor — ve açıkça '
                'buna dahil olmayan nedir?',
            answer: 'Sol el tutamakta, sağ el tutamakta, bir ayak '
                'basamakta. Buna dahil olmayanlar: direksiyon, kapı '
                'kenarı, koltuk, lastik ve poyra. Kapı kenarı ve '
                'direksiyon boşluk verir ya da döner — hem de tam onlara '
                'ihtiyaç duyduğun anda.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Akılda kalsın',
            text: 'Önce in, sonra al. Eşyaları önce araçta bırak, sonra '
                'elleri boş şekilde in.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Doğru biniş, doğru iniş',
        blocks: [
          BulletsBlock([
            'Binerken: yüzün araca dönük şekilde',
            'İnerken: geri geri, yüzün araca dönük — merdivenden iner '
                'gibi, asla sırtın kapıya dönük olacak şekilde dönerek '
                'değil',
            'Bütün basamakları kullan — hiçbirini atlama',
            'Tutamakları kullan, acil tutamak olarak kapı kenarını ya '
                'da direksiyonu değil',
            'Yük bölümünden inerken de aynı kural: yüz araca dönük, '
                'basamak basamak',
          ]),
          StepsBlock([
            'Dur ve aracı emniyete al',
            'Eşyaları araçta bırak',
            'Trafiği omuz üstünden ve aynadan kontrol et',
            'Kapıyı kontrollü aç',
            'Dön, yüzün araca dönük olsun',
            'Üç temas noktası oluştur',
            'Basamak basamak in',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Asla atlama',
        asset: 'assets/academy/driving/m07b_springen.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Atlamak en sık yapılan hatadır',
            text: 'Sürücü kabininden ya da yük bölümünden atlamak, '
                'dağıtımda burkulan ayak bilekleri ile diz ve sırt '
                'yaralanmalarının en sık nedenidir.',
          ),
          ParagraphBlock(
            'Bir panelvanın yük zemini modele göre yoldan aşağı yukarı '
            '55 ila 75 santimetre yüksektedir. Atlarken yere inişte '
            'vücut ağırlığının katları ayak bileğine, dize ve omurgaya '
            'biner — hem de her bir atlayışta.',
          ),
          FactsBlock([
            FactItem('55–75 cm', 'yük zemininin yoldan yüksekliği'),
            FactItem('250+', 'turda iniş sayısı — her biri eklemlere '
                'yazılır'),
          ]),
          RevealBlock(
            prompt: 'Örnek olay: Yağmur yağıyor, yük bölümünden ıslak '
                'yapraklı, eğimli bir kaldırıma atlıyorsun. Burada tam '
                'olarak ne ters gider?',
            answer: 'Atladığında inişi artık düzeltemezsin — havadasın '
                've altında ne olacağına zemin karar verir. Eğimdeki '
                'ıslak yaprak neredeyse hiç sürtünme sunmaz: ayak yere '
                'inerken kayar, eklem yana burkulur. Buna karşılık üç '
                'temas noktasıyla basamak basamak inen, tüm ağırlığını '
                'vermeden önce kaygan zemini hisseder — ve hâlâ '
                'vazgeçebilir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tipik hatalar',
        blocks: [
          DoDontBlock(
            doTitle: 'Doğru',
            dos: [
              'Eşyaları önce araçta bırak',
              'Eller boş ve üç temas noktasıyla in',
              'Basamak kenarlarını ve tutamakları temiz ve boş tut',
              'Islakta ve buzda basamakları önceden temizle',
              'Kendine zaman tanı — 180. durakta bile',
            ],
            dontTitle: 'Yanlış',
            donts: [
              'İnmek yerine atlamak',
              'Eller dolu — telefon, tarayıcı, kahve, paketler',
              'Lastiği ya da poyrayı basamak olarak kullanmak',
              'İnerken telefona bakmak',
              'Islak, buzlanmış ya da kirli basamak kenarlarını '
                  'görmezden gelmek',
              'Koltuktan yana doğru dönerek çıkmak',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Sonraki durak en tehlikelisidir',
            text: 'Uzun bir duruştan sonra bacaklar tutulur ve dikkat '
                'dağılır. Yanlış adım tam da o zaman atılır — kısaca '
                'kendine gel, sonra in.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Trafik tarafı: hafife alınan an',
        blocks: [
          ParagraphBlock(
            'Alçak Sprinter ve panelvanlarda sorun çoğu zaman yükseklik '
            'değil, akan trafiğe atılan adımdır. Mümkünse kaldırım ya da '
            'güvenli taraftan in. Bakmadan önce kapıyı ardına kadar '
            'açma.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 14 Abs. 1 StVO — Araca inip binme',
            text: 'Araca inen ya da binen, diğer yol kullanıcılarının '
                'tehlikeye girmesi kesin olarak dışlanacak şekilde '
                'davranmak zorundadır. Kapı kazasında sorumluluk '
                'pratikte her zaman inen kişiye aittir.',
          ),
          RevealBlock(
            prompt: 'Yol kenarında duruyorsun, arkadan bir bisikletli '
                'yaklaşıyor — nasıl inersin?',
            answer: 'Kapıyı açmadan önce omuz üstünden ve aynadan bak, '
                'bisikletliyi geçir, kapıyı yalnızca kontrollü biçimde '
                've uzaktaki elinle aç. “Hollanda tutuşu” denen yöntem — '
                'kapıyı sağ elle açmak — gövdeni kendiliğinden arkaya '
                'çevirir ve seni bakmaya zorlar. Bisikletliler ve '
                'scooterlar araca yakın geçer ve açılan bir kapıyı hesaba '
                'katmaz.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ayakkabı ve zemin',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'BG Verkehr\'in tavsiyesi',
            text: 'Ayağı saran ve kaymayan ayakkabı. Açık ya da tabanı '
                'aşınmış ayakkabı olmaz. Bilek boyu iş ayakkabıları, '
                'inerken burkulan eklemi tam da o noktadan destekler.',
          ),
          ParagraphBlock(
            'İnmeden önce kısaca zemine dikkat et: kaldırım taşı, eğim, '
            'yaprak, ıslaklık, buz, mıcır. Kar ve buzda tutamakları ve '
            'basamakları temiz tut. Mümkünse düz ve aydınlık yerde dur.',
          ),
          ChecklistBlock(
            title: 'İnmeden önce',
            items: [
              'Sağlam, kaymayan ayakkabı giyili',
              'Zemin kontrol edildi — kaldırım, eğim, ıslaklık, buz',
              'Eller boş, eşyalar bırakıldı',
              'Trafik omuz üstünden ve aynadan kontrol edildi',
              'Basamaklar temiz ve boş',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Doğru kaldırma ve taşıma',
        blocks: [
          ParagraphBlock(
            'Sırt, düşmelerden sonra ikinci en sık iş göremezlik '
            'riskidir. Ve bir düşmenin aksine disk hasarı tek bir günde '
            'oluşmaz — binlerce yanlış kaldırma hareketiyle ortaya '
            'çıkar.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/lift01_nah.svg',
              title: '1 · Yükü vücuduna yaklaştır',
              caption: 'Kaldırmadan önce pakete iyice yaklaş. Vücuda '
                  'olan her santimetre mesafe, disklere binen yükü kat '
                  'kat artırır.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift02_hocke.svg',
              title: '2 · Çömel',
              caption: 'Kalçadan öne katlanmak yerine dizlerini bük ve '
                  'çömel. Güç bacaklardan gelir — sahip olduğun en '
                  'güçlü kas onlardır.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift03_ruecken.svg',
              title: '3 · Sırtını düz tut',
              caption: 'Bacaklarınla doğrulurken sırtını düz ve bakışını '
                  'ileriye dönük tut. Yük altında yuvarlaklaşan bir '
                  'sırt, klasik disk pozisyonudur.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift04_drehen.svg',
              title: '4 · Dönme — adım at',
              caption: 'Yük gövdendeyken asla dönme. Bunun yerine '
                  'ayaklarını yeniden konumlandır ve tüm vücudunu '
                  'çevir. Kaldırma artı dönme, omurga için en tehlikeli '
                  'birleşimdir.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Ne kadar ağır fazla ağırdır?',
        blocks: [
          ParagraphBlock(
            'Kanunda sabit kilogram sınırları yoktur — belirleyici olan '
            'ağırlık, duruş, sıklık ve çevrenin tümüdür. Ancak pratikte '
            'yol gösterici değerler kendini kanıtlamıştır.',
          ),
          FactsBlock([
            FactItem('yaklaşık 25 kg', 'ara sıra kaldırma için '
                'yönlendirme (erkekler)'),
            FactItem('yaklaşık 15 kg', 'ara sıra kaldırma için '
                'yönlendirme (kadınlar)'),
            FactItem('üzerinde', 'yardımcı araç kullan ya da iki kişi '
                'taşıyın'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Lastenhandhabungsverordnung (yük taşıma yönetmeliği)',
            text: 'İşveren elle kaldırma ve taşımayı mümkün olduğunca '
                'önlemek ve uygun yardımcı araçları sağlamak '
                'zorundadır. Sen de bu yardımcı araçları kullanmak '
                'zorundasın — süs olsun diye durmuyorlar.',
          ),
          DoDontBlock(
            doTitle: 'Doğru taşıma',
            dos: [
              'İki kez yürümek yerine el arabası ya da rulo kutu kullan',
              'Hantal gönderileri iki kişi taşıyın',
              'Görüş alanını açık tut — istifin üzerinden bakma',
              'Kaldırmadan önce yolu ve bırakma noktasını belirle',
            ],
            dontTitle: 'Yanlış taşıma',
            donts: [
              'Yuvarlak sırt, gergin kollar',
              'Yük gövdedeyken burularak dönmek',
              'Hız alıp ani biçimde kaldırmak',
              'Yolu görmeni engelleyen kuleler taşımak',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Yolda takılma, kayma, düşme',
        blocks: [
          ParagraphBlock(
            'Takılma, kayma ve düşme, dağıtımdaki en sık yaralanma '
            'nedenidir — her trafik kazasından daha sık. Ve neredeyse '
            'her zaman araçla kapı arasındaki son metrelerde olur.',
          ),
          FactsBlock([
            FactItem('1 numara', 'dağıtımdaki en sık kaza türü'),
            FactItem('son 30 m', 'araçla kapı arası — en tehlikeli '
                'bölüm'),
          ]),
          BulletsBlock([
            'Sağlam, kaymayan ayakkabı giy — her gün, yazın da',
            'Buzlanmada küçük adımlar at ve ayağını tam bas',
            'Ara sıra yola da bak, sadece pakete ya da telefona değil',
            'Geceleri yol için el feneri ya da telefon ışığı kullan',
            'Rotadaki bilinen takılma noktalarını aklında tut',
          ]),
          RevealBlock(
            prompt: 'Örnek olay: Üç basamaklı bir kapıya iki paketi üst '
                'üste taşıyorsun. Buradaki asıl sorun nedir?',
            answer: 'Kendi ayaklarını ve basamak kenarlarını göremezsin. '
                'Basamağı görmeden çıkılan bir merdiven klasik düşme '
                'durumudur — üstelik eller doluyken ne korkuluğa '
                'tutunabilir ne de düşüşü karşılayabilirsin. Doğrusu: '
                'tek tek taşı, istifi basamakları görecek kadar alçak '
                'tut ya da el arabasını kullan. İki kez yürümek 40 '
                'saniye sürer.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Küçük yaralanmaları ciddiye al',
        blocks: [
          ParagraphBlock(
            'İncinmiş bir bel ya da burkulmuş bir ayak, devam edilirse '
            'kötüleşir. Önemsiz görünen bir şey haftalar içinde gerçek '
            'bir iş göremezliğe dönüşür — ve geriye dönük olarak işle '
            'bağlantısı çoğu zaman artık kanıtlanamaz.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Belgelemek seni korur',
            text: 'Her yaralanma kaza defterine yazılır — küçük olanı '
                'da. Bir iş kazası sonrası tıbbi tedavi gerekiyorsa '
                'Durchgangsarzt\'a (yetkili kaza hekimi) gidersin. '
                'Belgeleme olmadan sonradan iş kazası olarak kabul '
                'edilmesi zordur.',
          ),
          RevealBlock(
            prompt: 'Küçük şikâyetleri neden hemen bildirmelisin — '
                'çalışmaya devam edebilecek olsan bile?',
            answer: 'Birincisi tıbben: tedavi edilmemiş bir bağ sorunu '
                'daha kötü iyileşir ve tekrar eder. İkincisi hukuken: '
                'yalnızca belgelenmiş olan sonradan iş kazası sayılır. '
                'Üçüncüsü herkes için: ancak bildirilen olaylar '
                'işletmede hangi basamağın, tutamağın ya da akışın '
                'iyileştirilmesi gerektiğini gösterir. Bildirmek güçtür, '
                'zayıflık değil.',
          ),
          ChecklistBlock(
            title: 'Modül 7\'den yanıma alıyorum',
            items: [
              'Araçtan geri geri, yüzüm araca dönük iniyorum',
              'Her zaman üç temas noktası tutuyorum (2 el + 1 ayak)',
              'Sürücü kabininden ya da yük bölümünden asla atlamıyorum',
              'İnmeden önce eşyaları bırakıyorum',
              'Kapıyı açmadan önce omuz üstünden bakıyorum',
              'Bacaklarımla kaldırıyor ve yükle birlikte dönmüyorum',
              'Kahramanlık yerine yardımcı araç kullanıyorum',
              'Küçük de olsa her yaralanmayı bildiriyorum',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M8
  SafetyChapterContent(
    id: 'm8',
    title: 'Kapıda: köpekler, insanlar ve çevre',
    summary: 'Teslimat noktasında güvenli hareket et — hayvanlarla, '
        'insanlarla ve çevreyle',
    asset: 'assets/academy/driving/m08_haustuer.svg',
    slides: [
      SafetySlide(
        title: 'Teslimat noktası: yabancı arazi',
        blocks: [
          ParagraphBlock(
            'Aracı terk ettiğin anda tanımadığın ve senin için kimsenin '
            'güvenli hâle getirmediği yabancı bir araziye adım atarsın: '
            'bilinmeyen yollar, gevşek karolar, karanlık merdiven '
            'boşlukları, her ruh hâlinde hayvanlar ve insanlar.',
          ),
          FactsBlock([
            FactItem('120+', 'tur başına yabancı parsel'),
            FactItem('30 m', 'durak başına ortalama yürüme yolu'),
            FactItem('0', 'bunların senin için hazırlanmış olanı'),
          ]),
          ParagraphBlock(
            'Bu yüzden teslimat noktasında direksiyondakiyle aynı temel '
            'tutum geçerlidir: önce bak, sonra hareket et. Ve tereddüt '
            'edersen: teslim etme. Ulaşmayan bir gönderi bir işlemdir — '
            'bir yaralanma ise iş göremezliktir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Köpekleri doğru değerlendirmek',
        asset: 'assets/academy/driving/m08b_hund.svg',
        blocks: [
          ParagraphBlock(
            'Köpekler, dağıtıcılarda en sık yaralanma nedenleri '
            'arasındadır. Köpeğin gözünde sen hızlı hareket eden, '
            'yabancı kokan ve büyük bir cisim taşıyan bir davetsiz '
            'misafirsin — tepkisi savunmadır, kötülük değil.',
          ),
          BulletsBlock([
            'Doğrudan gözlerinin içine bakma — bu köpek için bir '
                'tehdittir',
            'Kaçma ve sesini yükseltme, sakin biçimde olduğun yerde '
                'dur',
            'Köpeğe yanını dön, cepheni değil',
            'Kollar sakin biçimde vücuda yakın, telaşlı hareket yok',
            'Paketi kendinle köpek arasında engel olarak kullanabilirsin',
            'Yavaşça geri geri yürü, bu sırada köpeği gözden kaçırma',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Sakinlik en iyi donanımındır',
            text: 'Köpek harekete ve ses tonuna tepki verir, '
                'gerekçelere değil. Yavaş, sessiz ve yandan — bütün '
                'teknik bu.',
          ),
        ],
      ),
      SafetySlide(
        title: 'İş ciddileştiğinde',
        blocks: [
          RevealBlock(
            prompt: 'Örnek olay: Bahçe kapısında büyük bir köpek durmuş '
                've havlıyor. Kapı sadece aralık, müşteri teslimat '
                'notuna “köpek uysaldır” yazmış. Ne yaparsın?',
            answer: 'Parsele girmezsin. Bir teslimat notu güvenlik onayı '
                'değildir — müşteri köpeğini aileyle ilişkisinden tanır, '
                'elinde paketle gelen yabancı bir adamla ilişkisinden '
                'değil. Doğrusu: kapıdan geri çekil, zili çalmayı ya da '
                'aramayı dene, gönderiyi belgeleyerek teslim etme ve '
                'notu sisteme işle ki bir sonraki meslektaşın haberi '
                'olsun. Bir ısırık sana haftalara mal olur — gönderi '
                'müşteriye bir gün.',
          ),
          DoDontBlock(
            doTitle: 'Doğru',
            dos: [
              'Kapıyı açmadan önce köpek seslerine ve mama kaplarına '
                  'dikkat et',
              'Serbest dolaşan köpek varsa hiç girme',
              'Meslektaşlar için notları sisteme işle',
              'Isırık ya da tırmık hâlinde: hemen bildir ve tıbbi '
                  'tedavi gör',
            ],
            dontTitle: 'Yanlış',
            donts: [
              'Köpeği sevmek ya da beslemek',
              'Hayvanın yanından geçip kapıya yürümek',
              'Kaçmak ya da paketle köpeğe vurmak',
              '“Bir şey yapmaz” sözüne güvenmek',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Her köpek ısırığı doktora gider',
            text: 'Küçük bir ısırık ya da tırmık bile enfeksiyon '
                'kapabilir. Hemen temizle, tıbbi tedavi gör, kaza '
                'defterine yaz ve bildir — ne kadar zararsız görünürse '
                'görünsün.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Parselde güvenli yollar',
        asset: 'assets/academy/driving/m08c_stolperfallen.svg',
        blocks: [
          ParagraphBlock(
            'Kapıya giden yol, birinin senin için kontrol ettiği bir '
            'çalışma yeri değildir. Belirlenmiş yolları kullan ve ıslak '
            'çimenlerden, gevşek karolardan ya da dik şevlerden '
            'kestirme yapma.',
          ),
          BulletsBlock([
            'Yerdeki bahçe hortumları, kablolar ve bitki kafesleri',
            'Gevşek ya da çökmüş kaldırım karoları',
            'Gölgeli yollarda ıslak yaprak, yosun ve alg',
            'Düz karolar üzerinde çakıl ve mıcır',
            'Korkuluksuz, aydınlatmasız merdivenler',
            'Bodrum kuyuları, açık rögarlar ve ışıklıklar',
            'Yolda oyuncak, bisiklet ve çöp konteyneri',
          ]),
          FactsBlock([
            FactItem('son 30 m', 'düşmelerin çoğu burada olur'),
            FactItem('1 el', 'korkuluk için boş kalmalı'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Kestirme, kazandırdığından fazlasına mal olur',
            text: 'Çimenden geçen yol on saniye kazandırır. Orada bir '
                'düşme ortalama 24 iş göremezlik gününe mal olur.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Merdivenler, bodrumlar ve karanlık',
        blocks: [
          ParagraphBlock(
            'Merdiven boşluklarında ve arka avlularda iki şey bir araya '
            'gelir: kötü ışık ve bilinmeyen basamak yükseklikleri. '
            'İkisi birlikte, araç dışındaki en sık düşme durumudur.',
          ),
          BulletsBlock([
            'Her zaman bir eli korkuluk için boş tut',
            '“Böyle de olur” demek yerine ışığı aç',
            'El feneri ya da telefon ışığı kullan — ama yürürken '
                'ekrana bakma',
            'Merdivenlerde istifi basamakları görecek kadar alçak tut',
            'Eski binalarda farklı basamak yüksekliklerine dikkat et',
          ]),
          RevealBlock(
            prompt: 'Karanlık bir bodrum koridoruna teslimat yapman '
                'gerekiyor. Işık düğmesi çalışmıyor. Doğru karar nedir?',
            answer: 'İçeri girme. Bilinmeyen basamakları, bodrum '
                'kuyuları ve depolanmış eşyalarla dolu, aydınlatmasız '
                'bir koridor, elinde paketle adım atacağın bir yer '
                'değildir — üstelik olur da bir şey olursa orada '
                'olduğunu kimse bilmez. Doğrusu: müşterinin zilini çal, '
                'güvenli bir yerde teslim et ya da gönderiyi belgeleyerek '
                'teslim etme. Telefon ışığı aydınlatmanın yerini tutmaz, '
                'çünkü bunun için korkulukta gereken bir ele ihtiyacın '
                'var.',
          ),
        ],
      ),
      SafetySlide(
        title: 'İnsanlar: kazanmak yerine gerilimi düşür',
        blocks: [
          ParagraphBlock(
            'Müşteri için koca bir şirketin yüzü sensin — ve bu yüzden '
            'bazen sana ait olmayan bir öfkeyi üstlenirsin. Nazik, sakin '
            've profesyonel kalmak sadece kibarlık değildir, en etkili '
            'güvenlik önlemindir.',
          ),
          StepsBlock([
            'Sakin ses, yavaş konuşma temposu, açık beden duruşu',
            'Hemen karşı çıkmak yerine dinle ve talebi adlandır',
            'Yapabileceğinle sınırlı kal — başkaları adına söz verme',
            'Mesafeni koru: en az bir kol boyu, kaçış yolu açık',
            'Gerilim tırmanırsa: konuşmayı bitir ve araca dön',
          ]),
          RevealBlock(
            prompt: 'Biri sesini yükseltiyor, sana çok yaklaşıyor ve '
                'aracına giden yolu kapatıyor. Ne geçerlidir?',
            answer: 'Güvenliğin her teslimatın önündedir. Tartışma, '
                'haklı çıkmaya çalışma, fiziksel temas kışkırtma. Geri '
                'çekil, mesafe oluştur, yüksek ve net biçimde mesafe '
                'iste, acil durumda kalabalığa çık ve polisi ara. '
                'Sonrasında: olayı bildir ki durak meslektaşlar için '
                'işaretlensin. Hiçbir paket fiziksel bir çatışmayı haklı '
                'çıkarmaz.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Güvenli bir yer olarak araç',
        blocks: [
          ParagraphBlock(
            'Aracın hem alet, hem depo, hem de sığınaktır. Onu terk '
            'ettiğinde güvenli biçimde durmalıdır — ve kendini tehdit '
            'altında hissedersen geri döneceğin yer orasıdır.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 14 Abs. 2 StVO',
            text: 'Aracını terk eden kişi, kazaları ve trafik '
                'aksamalarını önlemek için gerekli önlemleri almak ve '
                'aracı yetkisiz kullanıma karşı emniyete almak '
                'zorundadır.',
          ),
          DoDontBlock(
            doTitle: 'Doğru park edilmiş',
            dos: [
              'Motor kapalı, anahtar yanında, kapılar kilitli',
              'Eğimde el frenini sıkıca çek ve tekerlekleri kır',
              'Trafiğe açık alanda dururken dörtlü flaşör',
              'Görüş alanının dışına çıkacaksan yük kapısını kapat',
            ],
            dontTitle: 'Riskli',
            donts: [
              'Motor çalışıyor, kapı açık — “böylesi daha hızlı”',
              'Sen kapıdayken anahtar kontakta',
              'Yokuşta tekerlekleri kırmadan park etmek',
              'İşlek yerlerde yük bölümünü açık bırakmak',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Teslimat noktasında kontrol listesi',
        blocks: [
          ChecklistBlock(
            title: 'Her durakta',
            items: [
              'Motor kapalı, anahtar yanımda, araç kilitli',
              'Eğimde emniyete alındı, tekerlekler kırıldı',
              'Girmeden önce köpeklere ve notlara dikkat ettim',
              'Belirlenmiş yolları kullandım, kestirme yapmadım',
              'Korkuluk için bir elim boş',
              'İstif, basamakları görecek kadar alçak',
              'Karanlıkta ışık sağladım',
              'Saldırganlık hâlinde: mesafe, geri çekilme, bildirim',
              'Isırık, düşme ya da ramak kala olayda: bildirdim',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M9
  SafetyChapterContent(
    id: 'm9',
    title: 'Acil durum ve kaza sonrası davranış',
    summary: 'Ciddi durumda sakin, doğru ve hukuken güvenli hareket et',
    asset: 'assets/academy/driving/m09_notfall.svg',
    slides: [
      SafetySlide(
        title: 'Emniyete al — bildir — yardım et',
        blocks: [
          ParagraphBlock(
            'Bir kazadan ya da arızadan sonra her zaman aynı sıra '
            'geçerlidir: önce yeri güvenli hâle getir, sonra acil '
            'çağrı, sonra ilk yardım. Bu sıra bir formalite değildir — '
            'yardım edenlerin kendilerinin kurban olduğu ikinci kazayı '
            'önler.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Sırayı aklında tut',
            text: 'Emniyete al → bildir → yardım et. Emniyete almadan '
                'hemen yaralıya koşan, şehirler arası bir yolda ya da '
                'otoyolda kendisi ezilir.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 34 StVO — trafik kazasından sonra',
            text: 'Derhâl durmalı, trafiği emniyete almalı, hasar '
                'önemsizse tehlike bölgesinden çıkmalı, yaralılara '
                'yardım etmeli ve kendinin ve aracının tespitini mümkün '
                'kılmalısın.',
          ),
          ParagraphBlock(
            'Ve çok önemlisi: sakinlik. Bir çarpma sesinden sonraki ilk '
            'on saniye, sonraki on dakikayı belirler. Bir kez derin '
            'nefes al, sonra sırayla.',
          ),
        ],
      ),
      SafetySlide(
        title: 'İlk beş adım',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/acc01_absichern.svg',
              title: '1 · Dörtlü flaşörü yak',
              caption: 'Durur durmaz dörtlü flaşörü yak — arkadan gelen '
                  'herkes için ilk sinyal odur. Karanlıkta ayrıca park '
                  'lambasını açık bırak.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc02_warnweste.svg',
              title: '2 · Reflektörlü yeleği giy',
              caption: 'Yeleği inmeden önce giyersin — sonra değil. Bu '
                  'yüzden yelek arkada yük bölümünde değil, sürücü '
                  'kabininde elinin altında durur.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc03_dreieck.svg',
              title: '3 · Reflektörlü üçgeni koy',
              caption: 'Bariyerin arkasından ya da yol kenarından '
                  'gidiş yönünün tersine yürü ve üçgeni yeterli mesafeye '
                  'koy — şehir içinde yaklaşık 50 m, şehir dışında '
                  '100 m, otoyolda 150–200 m.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc04_notruf.svg',
              title: '4 · 112 acil çağrısı yap',
              caption: 'Nerede olduğunu, ne olduğunu, kaç yaralı '
                  'bulunduğunu ve hangi yaralanmaları gördüğünü söyle — '
                  've ancak merkezin sorusu kalmadığında telefonu kapat.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc05_erstehilfe.svg',
              title: '5 · İlk yardım yap',
              caption: 'Seslen, solunumu kontrol et, kanamayı durdur, '
                  'üstünü ört ve yaralının yanında kal. Basit önlemler '
                  'bile işe yarar — hiçbir şey yapmamak tek yanlış '
                  'karardır.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Dörtlü flaşör, yelek, üçgen',
        blocks: [
          TableBlock(
            headers: ['Alan', 'Üçgen mesafesi'],
            rows: [
              ['Şehir içi', 'yaklaşık 50 m'],
              ['Şehir dışı', 'yaklaşık 100 m'],
              ['Otoyol', 'yaklaşık 150–200 m'],
              ['Tümsek ya da viraj öncesi', 'öncesine, sonrasına değil'],
            ],
          ),
          ParagraphBlock(
            'Belirleyici olan tam metre değeri değil, arkadan gelen '
            'trafiğin seni zamanında görmesidir. Bir tümsek ya da viraj '
            'varsa üçgen onun öncesine konur — yoksa ancak iş işten '
            'geçtiğinde görünür olur.',
          ),
          FactsBlock([
            FactItem('1', 'reflektörlü yelek araçta zorunludur '
                '(§ 53a StVZO)'),
            FactItem('önce', 'yeleği inmeden önce giy'),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Bariyerin arkasından yürü',
            text: 'Otoyolda ve şehirler arası yolda üçgeni koymak için '
                'asla yol üzerinden yürümezsin, bariyerin arkasından ya '
                'da banketten yürürsün — trafiği görebilmek için gidiş '
                'yönünün tersine.',
          ),
          DoDontBlock(
            doTitle: 'Kaza yerinde doğrusu',
            dos: [
              'Dörtlü flaşör hemen, yelek inmeden önce',
              'Bariyerin arkasından gidiş yönünün tersine yürümek',
              'Üçgeni tümsek ya da viraj öncesine koymak',
              'Emniyete aldıktan sonra kendin de güvenli yere geçmek',
            ],
            dontTitle: 'Tipik hatalar',
            donts: [
              'Yeleksiz inip “sadece kısaca” bakmak',
              'Üçgene doğru yol üzerinden yürümek',
              'Araçların arasında durmak',
              'Emniyete almak yerine önce fotoğraf çekmek',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Kurtarma koridoru',
        blocks: [
          ParagraphBlock(
            'Kurtarma koridoru, trafik durur durmaz oluşturulur — mavi '
            'ışık göründüğünde değil. O zaman genellikle çok geçtir, '
            'çünkü kimsenin yer açacak alanı kalmaz.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 11 Abs. 2 StVO',
            text: 'Otoyollarda ve her yönde en az iki şeridi bulunan '
                'şehir dışı yollarda koridor her zaman en soldaki şerit '
                'ile hemen onun sağındaki şerit arasında oluşturulur — '
                'kaç şerit olduğundan bağımsız olarak.',
          ),
          FactsBlock([
            FactItem('sol + 1', 'koridor böyle oluşturulur'),
            FactItem('200 €\'dan itibaren', 'koridor oluşturulmazsa para '
                'cezası'),
            FactItem('2 ceza puanı', 'artı kural olarak 1 ay sürüş '
                'yasağı'),
          ]),
          RevealBlock(
            prompt: 'Üç şeritli bir otoyolda trafik durmuş. Kurtarma '
                'koridoru tam olarak nerede — ve tam çıkışa gidecekken '
                'onun içinde gidebilir misin?',
            answer: 'Her zaman sol şerit ile orta şerit arasında — asla '
                'orta ile sağ arasında ve asla emniyet şeridinde. Ve '
                'hayır: kurtarma koridoru yalnızca acil durum araçlarına '
                'aittir. Çıkışa daha çabuk varmak için onu kullanan, hiç '
                'koridor oluşturmayanla benzer yükseklikte para cezası '
                'öder ve sürüş yasağını göze alır. Emniyet şeridi de bir '
                'alternatif değildir — koridor kapalıysa kurtarma '
                'ekipleri oradan gider.',
          ),
        ],
      ),
      SafetySlide(
        title: '112 acil çağrısını doğru yapmak',
        blocks: [
          FactsBlock([
            FactItem('112', 'Avrupa genelinde acil çağrı, kontör '
                'olmadan da'),
            FactItem('110', 'polis — sadece maddi hasarda'),
          ]),
          StepsBlock([
            'Nerede oldu? — yer, cadde, kilometre bilgisi, gidiş '
                'yönü, belirgin noktalar',
            'Ne oldu? — kazanın türü, karışan araçlar, akan yakıt gibi '
                'tehlikeler',
            'Kaç yaralı var?',
            'Hangi yaralanmalar? — bilinci kapalı, kanamalı, sıkışmış',
            'Ek soruları bekle — görüşmeyi merkez bitirir',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Yardım etmek zorunludur',
            text: 'Yardım etmekten kaçınmak bir suçtur (§ 323c StGB). '
                'Senden beklenen, makul olan şeydir — acil çağrı yapmak, '
                'emniyete almak, seslenmek, yanında olmak. Kimse kendini '
                'tehlikeye atmanı istemiyor.',
          ),
        ],
      ),
      SafetySlide(
        title: 'İlk yardım: asıl önemli olanlar',
        blocks: [
          ParagraphBlock(
            'Sağlık görevlisi olmana gerek yok. Belirleyici önlemleri '
            'herkes yapabilir — ve ambulans gelene kadar yaşamla ölüm '
            'arasında karar veren de onlardır.',
          ),
          StepsBlock([
            'Seslen ve omzundan hafifçe salla — kişi tepki veriyor mu?',
            'Tepki yok: hava yolunu aç, başı geriye yatır, solunumu 10 '
                'saniye kontrol et',
            'Solunum normal: koma pozisyonuna al, üstünü ört, yanında '
                'kal',
            'Normal solunum yok: hemen kalp masajına başla ve bırakma',
            'Şiddetli kanama: doğrudan bastırarak müdahale et, baskılı '
                'sargı uygula',
          ]),
          FactsBlock([
            FactItem('100–120', 'dakikada bası sayısı'),
            FactItem('5–6 cm', 'yetişkinde bası derinliği'),
            FactItem('10 sn', 'solunum kontrolü için yeter'),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Kask ve sıkışmış kişiler',
            text: 'Bir motosiklet kaskını yalnızca kişi normal '
                'solumuyorsa çıkarırsın — o zaman da başka yol yoktur. '
                'Sıkışmış kişileri, yangın gibi doğrudan bir tehlike '
                'yoksa yerinden oynatmazsın.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Maddi hasardan sonra',
        blocks: [
          ParagraphBlock(
            'Küçük hasarlarda da — manevra göçüğü, kopan ayna, park '
            'hâlindeki araçtaki çizik — programın tamamı geçerlidir. '
            'Hasar her zaman bildirilir, küçük görünse ve kimse görmemiş '
            'olsa bile.',
          ),
          ChecklistBlock(
            title: 'Maddi hasardan sonra',
            items: [
              'Dur ve aracı emniyete al',
              'Dörtlü flaşör, gerekirse yelek ve üçgen',
              'Bilgileri paylaş ya da araç sahibini bekle',
              'Birkaç açıdan fotoğraf, yer, saat, plaka',
              'Tanıkları ve iletişim bilgilerini not et',
              'Kusur kabul belgesi imzalama',
              'Hasarı işletmeye bildir — aynı gün içinde',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Asla öylece devam etme',
            text: 'Kimliğinin tespitini mümkün kılmadan kaza yerinden '
                'ayrılan, kaza yerinden izinsiz uzaklaşma suçunu işler '
                '(§ 142 StGB) — küçük bir göçükte bile para ya da hapis '
                'cezası gerektiren bir suçtur.',
          ),
          RevealBlock(
            prompt: 'Örnek olay: Manevra yaparken park hâlindeki bir '
                'aracın dış aynasını sıyırıyorsun. Ortada kimse yok. '
                'Silecek altına bırakılan bir not yeter mi?',
            answer: 'Hayır. Bir not hukuken yeterli tespit sayılmaz — '
                'uçabilir, ıslanabilir ya da alınabilir. Doğrusu şu: kaza '
                'yerinde makul bir süre bekle (duruma göre yaklaşık 30 '
                'dakika yol gösterici değer olarak alınır) ve kimse '
                'gelmezse polisi bilgilendirip hasarı orada bildir. Ek '
                'olarak bir not bırakmak iyi bir uygulamadır ama ne '
                'beklemenin ne de bildirimin yerini tutar.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Sakin kal, bildir, öğren',
        blocks: [
          ParagraphBlock(
            'Derin nefes al, durumu düzene sok, sevkiyat sorumlusunu ve '
            'işletmeyi bilgilendir. Dürüst ve hızlı bir bildirim her '
            'zaman örtbas etmekten iyidir — seni korur, işletmeyi korur '
            've her olaydan bir sonraki tur için ders çıkarırız.',
          ),
          ChecklistBlock(
            title: 'Modül 9\'dan yanıma alıyorum',
            items: [
              'Sırayı biliyorum: emniyete al, bildir, yardım et',
              'Reflektörlü yeleği inmeden önce giyiyorum',
              'Reflektörlü üçgeni yeterli mesafeye koyuyorum',
              'Trafik durur durmaz kurtarma koridorunu sol şerit ile '
                  'yanındaki şerit arasında oluşturuyorum',
              '112 acil çağrısındaki beş bilgiyi biliyorum',
              'Hiçbir şey yapmamanın tek yanlış karar olduğunu '
                  'biliyorum',
              'Her hasarı aynı gün bildiriyorum — küçük göçüğü de',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M10
  SafetyChapterContent(
    id: 'm10',
    title: 'Özet ve kişisel taahhüt',
    summary: 'Öğrenilenleri pekiştir ve kişisel bir tutuma dönüştür',
    asset: 'assets/academy/driving/m10_selbstverpflichtung.svg',
    slides: [
      SafetySlide(
        title: '7 temel kuralın',
        blocks: [
          BulletsBlock([
            'Önceden düşünmek, hızlı tepki vermekten üstündür',
            'Mesafe ve koşullara uygun hız sana her zaman bir yedek '
                'bırakır',
            'Geri giderken: in, bak, yavaş git (GOAL)',
            'Telefon ve dikkat dağınıklığı yalnızca araç dururken ve '
                'motor kapalıyken',
            'Yorgunluğu ve zaman baskısını ciddiye al — güvenlik '
                'plandan önce gelir',
            'Doğru in, doğru kaldır, doğru yürü — bedenin senin '
                'aletindir',
            'Acil durumda: emniyete al, bildir, yardım et',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Sadece tek bir kural alacaksan',
            text: 'İhtiyacın olan zamanı kendine tanı. Dağıtımdaki '
                'kazaların neredeyse hepsi, birinin iki saniye kazanmak '
                'istediği anda oluşur.',
          ),
          DoDontBlock(
            doTitle: 'Güvenli bir gün böyle görünür',
            dos: [
              'Araç turu, yük emniyete alınmış, kemer takılı',
              'İki saniye mesafe, bakış uzağa',
              'Her geri manevradan önce inip bakmak',
              'Telefon tutucuda, yorgunlukta mola',
              'Üç temas noktasıyla geri geri inmek',
            ],
            dontTitle: 'En pahalı beş kestirme',
            donts: [
              'Araç turunu “bugünlük” atlamak',
              'İlave yüklemeden sonra yükü yeniden emniyete almamak',
              'Yol boş diye ekrana kısaca bakmak',
              'Daha hızlı olduğu için yük bölümünden atlamak',
              'Bir manevra hasarını bildirmemek',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Akılda kalması gereken sayılar',
        blocks: [
          FactsBlock([
            FactItem('2 sn', 'asgari takip mesafesi'),
            FactItem('2 + 1', 'inerken temas noktası'),
            FactItem('112', 'yaralı varsa acil çağrı'),
          ]),
          TableBlock(
            headers: ['Sayı', 'Anlamı'],
            rows: [
              ['2 saniye', 'asgari mesafe, ıslakta 3+'],
              ['18 / 40 m', '30 / 50 km/sa hızda duruş mesafesi'],
              ['28 m', '50 hızda 2 sn telefon bakışında kör sürüş'],
              ['89 m', '80 hızda 4 sn mikro uyku'],
              ['0,8 g', 'yük için öne doğru emniyet kuvveti'],
              ['2 + 1', 'araca inip binerken temas noktası'],
              ['% 70', 'hasarların manevrada oluşan oranı'],
              ['112', 'yaralı varsa acil çağrı'],
            ],
          ),
          ParagraphBlock(
            'Bu sekiz sayı eğitimin sert çekirdeğidir. Onları aklında '
            'tutan, düşünmeye vakit olmadığında da doğru kararı verir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kişisel öz kontrolün',
        asset: 'assets/academy/driving/m10b_selbstcheck.svg',
        blocks: [
          ParagraphBlock(
            'Bu listeyi bir kez dürüstçe gözden geçir — işletme için '
            'değil, kendin için. İşaretlemediğin her madde, yarın '
            'değiştirebileceğin somut bir şeydir.',
          ),
          ChecklistBlock(
            title: 'Güvenlik öz kontrolüm',
            items: [
              'Acelem olsa da araç turunu her sabah yapıyorum',
              'Yük bölümü boşaldıkça yükü yeniden emniyete alıyorum',
              'İki saniye mesafe bırakıyor ve bunu sabit bir noktada '
                  'kontrol ediyorum',
              'Her geri manevradan önce inip bakıyorum',
              'Sürüş sırasında telefonuma dokunmuyorum',
              'Yorulduğumda duruyorum',
              'Her zaman üç temas noktasıyla geri geri iniyorum',
              'Bacaklarımla kaldırıyor ve yardımcı araç kullanıyorum',
              'Hasarları, ramak kala olayları ve yaralanmaları '
                  'bildiriyorum',
              'Bir plan güvenli biçimde yapılamıyorsa haber veriyorum',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Örnek olay: her şeyin üst üste geldiği gün',
        blocks: [
          RevealBlock(
            prompt: 'Örnek olay: Cuma, yağmur, 190 durak. 25 dakika geç '
                'başlıyorsun, yük bölümü gece vardiyasından dağınık '
                'kalmış, telefonun sürekli çalıyor ve saat 16.00\'da '
                'kahvaltıdan beri hiçbir şey yemediğini fark ediyorsun. '
                'Şimdi doğru sıra nedir?',
            answer: 'Dur ve önce yük bölümünü düzenle — bunu çeyrek '
                'saatte telafi eder ve 190 arama işleminden kurtulursun. '
                'Sonra: telefon sessize, tutucuya, aramalar bir sonraki '
                'molada. Sonra on dakika ye ve iç, çünkü aksi hâlde '
                'bundan sonra dikkatin saat başı düşer. Ve ardından '
                'sevkiyata dürüst bir bildirim: plan bugün tam olarak '
                'tutmuyor. Yapmayacakların: zamanı yolda kapatmaya '
                'çalışmak, molaları iptal etmek, manevraları kısa '
                'kesmek. Gün artık kurtarılamaz — ama sırtın, ehliyetin '
                've aracın kurtarılabilir.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Asıl sınav',
            text: 'İyi bir günde herkes güvenli sürebilir. Fark, her '
                'şeyin aynı anda ters gittiği günde ortaya çıkar.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kişisel taahhüdün',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Sözün',
            text: '“Herkesin — benim de — eve sağ salim dönmesini '
                'sağlayacak şekilde sürüyorum.”',
          ),
          ParagraphBlock(
            'Güvenlik bir kural kitabı değil, senin günlük kararındır. '
            'Sabah altıda araç turunu yapıp yapmayacağına karar '
            'verirken ya da akşam yedide geri gitmeden önce bir kez daha '
            'inip inmeyeceğine karar verirken kimse yanında durmuyor. '
            'Bu kararları bu kadar önemli kılan da tam olarak budur.',
          ),
          ChecklistBlock(
            title: 'Taahhüt ediyorum',
            items: [
              'Kimse bakmıyorken de kurallara uyuyorum',
              'Güvenliğin gerektirdiği saniyeleri kendime tanıyorum',
              'Örtbas etmek yerine dürüstçe bildiriyorum',
              'Yeni meslektaşların baştan doğru yapmasına yardım '
                  'ediyorum',
              'Her akşam sağ salim eve dönüyorum',
            ],
          ),
        ],
      ),
    ],
  ),
];
