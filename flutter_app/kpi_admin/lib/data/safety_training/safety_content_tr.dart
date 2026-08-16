// lib/data/safety_training/safety_content_tr.dart
//
// Güvenlik eğitimi içerikleri — Türkçe sürüm.

import 'safety_blocks.dart';

const String _a = 'assets/academy/safety/';

const List<SafetyChapterContent> safetyContentTr = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ch01',
    title: 'Yasal temeller ve yükümlülüklerin',
    summary: 'İş güvenliği neden var — ve senin katkın ne olmalı',
    asset: '${_a}ch01_grundlagen.svg',
    slides: [
      SafetySlide(
        title: 'İş güvenliği neye dayanır',
        asset: '${_a}ch01_grundlagen.svg',
        blocks: [
          ParagraphBlock(
            'İş güvenliği, işverenin gönüllü olarak sunduğu bir hizmet '
            'değil, yasayla zorunlu tutulan bir konudur. İki temel '
            'sütuna dayanır: devlet hukuku ve kaza sigortası '
            'kurumlarının kuralları.',
          ),
          BulletsBlock([
            'Arbeitsschutzgesetz (ArbSchG) — işverenin yükümlülüklerini '
                've çalışanların hak ile görevlerini düzenler',
            'Yönetmelikler — yasayı somutlaştırır, örn. işyeri, '
                'işletme güvenliği ve tehlikeli madde yönetmelikleri',
            'DGUV Vorschriften — meslek birliğinin bağlayıcı kuralları, '
                'sigortalı olarak senin için de bağlayıcı',
            'DGUV Regeln ve Informationen — uygulama yardımları ve '
                'tavsiyeler, bağlayıcı değil ama pratikte kanıtlanmış',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Önemli olan fark',
            text: 'DGUV Vorschriften bağlayıcıdır. DGUV Regeln bunların '
                'nasıl uygulanacağını gösterir. DGUV Informationen ise '
                'sadece tavsiyedir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Çalışan olarak altı yükümlülüğün',
        blocks: [
          ParagraphBlock(
            'İşveren seni korumak zorunda — sen de buna katılmalısın. '
            'Bu yükümlülükler pozisyon ve sözleşme fark etmeksizin her '
            'çalışan için geçerlidir.',
          ),
          StepsBlock([
            'Kendi güvenliğine ve iş arkadaşlarının güvenliğine dikkat et',
            'İşletme talimatlarına ve eğitimlere uy',
            'İlk yardım yap veya etkili ilk yardımı destekle',
            'Kazaları ve ramak kala olayları bildir — küçük olanları da',
            'Arızaları ve eksikleri hemen bildir (bozuk kablo, arızalı '
                'cihaz, hatalı iş akışı)',
            'Koruyucu donanımı amacına uygun kullan — iş ayakkabısı, '
                'eldiven, reflektörlü yelek, kulaklık',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Alkol, uyuşturucu, ilaç',
            text: 'Kendini ve başkalarını sarhoş edici maddelerle tehlikeye '
                'atamazsın. Bu, tüm çalışma süresi için geçerlidir — '
                'molada da, çünkü sonrasında yine araç kullanacaksın. '
                'Uyku yapan ilaçlar da buna dahildir: şüphelenirsen '
                'doktoruna sor.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ch02',
    title: 'İşletme talimatları',
    summary: 'Bağlayıcı talimatlar — ve seni neden korurlar',
    asset: '${_a}ch02_betriebsanweisungen.svg',
    slides: [
      SafetySlide(
        title: 'İşletme talimatı nedir',
        asset: '${_a}ch02_betriebsanweisungen.svg',
        blocks: [
          ParagraphBlock(
            'İşletme talimatı, araçlar, iş ekipmanları ve tehlikeli '
            'maddelerle çalışırken işverenin verdiği bağlayıcı bir '
            'talimattır. Tavsiye değildir.',
          ),
          BulletsBlock([
            'İşletmede erişilebilir durumdadır — onu bilmen gerekir',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Bunu bilmelisin',
            text: 'Bir işletme talimatına uymayan kişi, kaza incelemesinde '
                'sorumlu tutulabilir. En kötü durumda bu, bir kazada '
                'senin de kişisel olarak pay sahibi olman anlamına gelir.',
          ),
          ParagraphBlock(
            'Ayrım: İşletme talimatı bir iş ekipmanı veya tehlikeli madde '
            'ile çalışmayı düzenler. İş talimatı ise bir iş sürecinin '
            'akışını düzenler.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Yapısı — altı bölüm',
        blocks: [
          ParagraphBlock(
            'Her işletme talimatı aynı şekilde kurulmuştur. Yapıyı '
            'bilirsen, acil durumda doğru yeri hemen bulursun.',
          ),
          StepsBlock([
            'Geçerlilik alanı — ne için ve kimin için geçerli',
            'İnsan ve çevre için tehlikeler',
            'Koruyucu önlemler ve davranış kuralları',
            'Arıza durumunda davranış',
            'Kaza durumunda davranış ve ilk yardım',
            'Atık bertarafı ve bakım',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Örnek: Kamyonet kullanmak',
        blocks: [
          ParagraphBlock(
            '3,5 tona kadar araçlar için bir işletme talimatındaki somut '
            'kurallar şöyle görünür:',
          ),
          BulletsBlock([
            'Geçerli sürücü belgesini yanında taşı',
            'Yolculuk öncesinde ve sırasında alkol ve uyuşturucu yok',
            'Tehlike varsa geri manevrayı sadece bir yönlendirici ile yap',
            'Aracı terk ettikten sonra her zaman kilitle',
            'Çekme işlemini sadece çekme çubuğu ile yap',
            'Kaza yerini emniyete al, her kazayı gecikmeden bildir',
            'Küçük yaralanmaları da hemen tedavi et ve kaza defterine '
                'kaydet',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Şüphen varsa sor',
            text: 'Bir talimat sana net gelmiyorsa dispeçerine sor — '
                'yola çıkmadan önce, sonrasında değil.',
          ),
          SubheadBlock('En önemli talimatlar'),
          ParagraphBlock(
            'Tüm işletme talimatlarını istediğin zaman DA Academy '
            'içindeki „İşletme talimatları" bölümünde bulabilirsin.',
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
    title: 'Güvenli çalışmanın 10 kuralı',
    summary: 'İş gününün özü — her gün geçerli',
    asset: '${_a}ch03_sicheres_arbeiten.svg',
    slides: [
      SafetySlide(
        title: 'On kural, her gün',
        asset: '${_a}ch03_sicheres_arbeiten.svg',
        blocks: [
          StepsBlock([
            'Güvenli ve dikkatli çalışmak',
            'Yola çıkmadan önce araç kontrolü',
            'Yükü araç içinde emniyete almak',
            'Profesyonel sürüş ve StVO kurallarına uymak',
            'Emniyet kemerini takmak',
            'Araçları, aletleri ve donanımı düzenli tutmak',
            'Sadece uygun ayakkabılarla çalışmak',
            'İş arkadaşlarına ve müşterilere nazik davranmak',
            'Mola düzenine uymak',
            'Hoşgörülü ve saygılı davranmak',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'En büyük etkiyi yapan üç kural',
            text: 'Araç kontrolü, yük emniyeti, emniyet kemeri. Bu üçü '
                'ağır sonuçların çoğunu önler — ve toplamda üç dakikanı '
                'bile almaz.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ch04',
    title: 'Kişisel koruyucu donanım (KKD)',
    summary: 'İş ayakkabısı ve reflektörlü yelek — günlük zorunluluğun',
    asset: '${_a}ch04_psa.svg',
    slides: [
      SafetySlide(
        title: 'Kurye olarak koruyucu donanımın',
        asset: '${_a}ch04_psa.svg',
        blocks: [
          ParagraphBlock(
            'Kişisel koruyucu donanım, tehlikelerden korunmak için '
            'vücudunda taşıdığın her şeydir. Dağıtım işinde iki parça '
            'her gün zorunludur:',
          ),
          FactsBlock([
            FactItem('1', 'İş ayakkabısı'),
            FactItem('2', 'Reflektörlü yelek'),
          ]),
          BulletsBlock([
            'İş ayakkabısı — tüm iş günü boyunca, istasyonda ve rotada',
            'Reflektörlü yelek — araçta elinin altında, arıza, kaza veya '
                'yol kenarında duruşta inmeden önce giyilmiş olarak',
          ]),
          SubheadBlock('Diğer koruyucu donanım — işe göre'),
          ParagraphBlock(
            'Bu donanım her gün zorunlu değildir, ama bazı işler için '
            'gerekli olabilir. Senin için ne geçerli olduğu risk '
            'değerlendirmesinde ve işletme talimatında yazar.',
          ),
          BulletsBlock([
            'Koruyucu eldiven — keskin kenarlı gönderilerde, temizlik ve '
                'bakım işlerinde, kışın',
            'Kulak koruyucu — gürültüde, örn. bazı depo bölgelerinde',
            'Koruyucu gözlük — sıçrama tehlikesi olan işlerde',
            'Baret — şantiyelerde ve düşen cisim tehlikesinde',
            'Hava koşulu giysisi — sürekli açık havada çalışırken',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Kullanma zorunluluğu',
            text: 'İşverenin sağladığı koruyucu donanımı amacına uygun '
                'kullanmak zorundasın (§ 15 Arbeitsschutzgesetz). '
                'İşveren donanımı ücretsiz verir ve kullanımını denetlemek '
                'zorundadır.',
          ),
          InstructionRefBlock(['baw_sicherheitsschuhe', 'baw_warnweste']),
        ],
      ),
      SafetySlide(
        title: 'İş ayakkabısı: koruma etkisi',
        blocks: [
          ParagraphBlock(
            'Ayak koruması en sık ihtiyacın olan koruyucu donanımdır — '
            've en çok hafife alınanıdır.',
          ),
          SubheadBlock('Neye karşı korurlar'),
          BulletsBlock([
            'Mekanik — çarpma, ezilme, düşen paketler, sivri cisimlere '
                'basma',
            'Burkulma — bilek yüksekliğindeki ayakkabılar ayak bileğini '
                'destekler, bağ yırtığı ve bilek yaralanmalarını önler',
            'Elektrik — antistatik iletim',
            'Kimyasal — asitler, yağlar, yakıtlar',
            'Termik — sıcak ve soğuk',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Neden bilek yüksekliğinde',
            text: 'Dağıtım işinde en sık görülen yaralanma, araçtan '
                'inerken, kaldırımlarda ve engebeli yollarda burkulmadır. '
                'Bilek yüksekliğindeki ayakkabı eklemi tam burkulduğu '
                'yerde destekler — alçak ayakkabı bunu yapamaz.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Rahatsız etseler de — yazın da',
            text: 'Giyme zorunluluğu her iş gününde geçerlidir, hava ve '
                'rahatlık fark etmez. Özellikle yazın ayakkabı '
                'değiştirilir — ve yaralanmalar tam o zaman olur. '
                'Ayakkabı vuruyor veya sürtüyorsa bu, başka bir model '
                'istemek için sebeptir, spor ayakkabı için değil.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Ayakkabılarını düzenli kontrol et',
            text: 'Aşınmış taban, çatlaklar veya aşırı kirlenme varsa: '
                'değiştirilmesini iste. Kendi başına değişiklik yapma ve '
                'asla spor ayakkabıyla çalışma — „sadece kısa bir süre" '
                'bile olsa.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Koruma sınıflarına genel bakış',
        blocks: [
          TableBlock(
            headers: ['Sınıf', 'Özellikler'],
            rows: [
              [
                'S1',
                'Kapalı topuk bölgesi, antistatik, yakıta dayanıklı '
                    'taban',
              ],
              ['S2', 'S1 gibi + en az 60 dakika su geçirmez'],
              ['S3', 'S2 gibi + delinmez ve desenli taban'],
              ['S4', 'S2 gibi, tamamen kauçuk (vulkanize)'],
              ['S5', 'S4 gibi + delinmez taban'],
            ],
          ),
          SubheadBlock('Ne zaman özellikle önemliler'),
          BulletsBlock([
            'Merdivenlerde, basamaklarda ve sahanlıklarda',
            'Rulo konteynerlerde ve transpaletlerde',
            'Engebeli yollarda ve rampalarda',
          ]),
          ParagraphBlock(
            'İyi bir ayakkabının özellikleri: sıkı oturur, kapalıdır, '
            'topuğu darbe emici şekilde tutar, tabanı esnektir, ökçesi '
            'alçaktır, deseni kaymayı önler.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ch05',
    title: 'Yangın durumunda davranış',
    summary: 'Yangın söndürücüyü doğru kullan ve araç yangınını yönet',
    asset: '${_a}ch05_brandfall.svg',
    slides: [
      SafetySlide(
        title: 'Yangın söndürücüyü kullanmak',
        asset: '${_a}ch05_brandfall.svg',
        blocks: [
          ParagraphBlock(
            'Kuru tozlu, sulu/köpüklü ve CO₂ söndürücüler vardır. '
            'Kullanımı hepsinde aynıdır:',
          ),
          StepsBlock([
            'Emniyet pimini çek',
            'Darbe düğmesine bas',
            'Söndürme tabancasını çalıştır',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Sadece saniyelerin var',
            text: 'Bir söndürücü çoğu kişinin sandığından çok daha çabuk '
                'boşalır. Bu yüzden: birden fazla söndürücüyü arka arkaya '
                'değil, aynı anda kullan.',
          ),
          FactsBlock([
            FactItem('6–12 s', 'Toz 1–2 kg'),
            FactItem('15–23 s', 'Toz 6 kg'),
            FactItem('18–33 s', 'Toz 12 kg'),
            FactItem('20–30 s', 'Köpük 6 l'),
            FactItem('5–10 s', 'CO₂ 2 kg'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Doğru söndürme — adım adım',
        blocks: [
          ParagraphBlock(
            'Sıra, ateşin sönmesini mi yoksa yeniden alevlenmesini mi '
            'belirler. Aklında tutman gereken altı adım:',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}fire01_pin.svg',
              title: 'Söndürücüyü hazırla',
              caption: 'Emniyet pimini çek, darbe düğmesine bas, '
                  'söndürücüyü dik tut. Ancak ondan sonra yangına git.',
            ),
            IllustratedStep(
              asset: '${_a}fire02_wind.svg',
              title: 'Rüzgar yönünde saldır',
              caption: 'Rüzgar arkanda olmalı ve söndürme maddesini '
                  'ateşe taşımalı — asla rüzgara karşı söndürme. Böylece '
                  'sıcaklık ve duman senden uzak kalır.',
            ),
            IllustratedStep(
              asset: '${_a}fire03_surface.svg',
              title: 'Yüzey yangını: önden başla',
              caption: 'Alevlerin ön kenarını hedefle, kora doğru — alev '
                  'uçlarına değil. Sonra adım adım arkaya doğru çalış.',
            ),
            IllustratedStep(
              asset: '${_a}fire04_drip.svg',
              title: 'Damlayan yangın: yukarıdan aşağıya',
              caption: 'Yanan sıvı aşağı akıyorsa, yukarıda çıkış '
                  'noktasından başla ve aşağı doğru çalış — yoksa '
                  'yukarıdan sürekli yeniden tutuşur.',
            ),
            IllustratedStep(
              asset: '${_a}fire05_together.svg',
              title: 'Birden fazla söndürücüyü aynı anda',
              caption: 'Birden fazla söndürücü ve yardımcı varsa: birlikte '
                  've aynı anda kullanın. Sırayla kullanmak, ateşe '
                  'söndürücüler arasında toparlanma zamanı verir.',
            ),
            IllustratedStep(
              asset: '${_a}fire06_watch.svg',
              title: 'Yangın yerini gözle',
              caption: 'Söndürdükten sonra orada kal ve izle. Kor '
                  'yuvaları çoğu zaman dakikalar sonra yeniden tutuşur — '
                  'mesafeni koru ve söndürücüyü hazır tut.',
            ),
            IllustratedStep(
              asset: '${_a}fire07_refill.svg',
              title: 'Kullanılmış söndürücüyü doldurt',
              caption: 'Kullanılmış bir söndürücü asla duvara geri '
                  'asılmaz — kısa bir püskürtmeden sonra bile. Hemen '
                  'yeniden doldurulmaya ver ve yedeğini bildir.',
            ),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Ne zaman söndürmezsin',
            text: 'Kendini asla tehlikeye atma. Yangın bir çöp kutusundan '
                'büyükse, yoğun duman çıkıyorsa veya kaçış yolunu riske '
                'atıyorsan: dışarı çık, kapıyı kapat, 112 ara ve '
                'başkalarını uyar.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Araç yangını',
        blocks: [
          SubheadBlock('En sık nedenler'),
          BulletsBlock([
            'Yakıt veya yağ sızıntıları',
            'Sıcak parçalar üzerindeki yalıtım malzemesi',
            'Mekanik hasarlar',
            'Elektrik arızaları',
            'Yanan çöp kutuları',
          ]),
          SubheadBlock('Ne yaparsın'),
          StepsBlock([
            'Tünellerde veya köprülerde durma — mümkünse dışarı çık',
            'Dörtlüleri yak, uygun bir yer bul, dur',
            'Aracı terk et, mesafeni koru',
            'İtfaiyeyi 112 ile ara — konumu ve gidiş yönünü söyle',
            'Kendi söndürme denemeni ancak güvenliyse yap',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Motor kaputu: dikkat',
            text: 'Sadece eldivenle ve sadece bir parmak aralığında aç. '
                'Ani oksijen girişi alev püskürmesine yol açabilir.',
          ),
          SubheadBlock('Acil çağrı merkezinin bilmesi gerekenler'),
          BulletsBlock([
            'Nerede yanıyor?',
            'Ne yanıyor ve ne kadar büyüklükte?',
            'Kaç yaralı var, hangi yaralanmalar?',
            'Araçta ne yüklü?',
            'Kim bildiriyor?',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Telefonu kapatma',
            text: 'Görüşmeyi asla kendin bitirme. Soruları bekle — '
                'görüşmeyi acil çağrı merkezi sonlandırır.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'ch06',
    title: 'İlk yardım',
    summary: 'Yükümlülüğün, güvencen ve belgelendirme',
    asset: '${_a}ch06_erste_hilfe.svg',
    slides: [
      SafetySlide(
        title: 'Yardım etmek zorunludur — ve güvence altındadır',
        asset: '${_a}ch06_erste_hilfe.svg',
        blocks: [
          ParagraphBlock(
            'Herkes ilk yardım yapmakla yükümlüdür — makul ölçüde ve '
            'kendini ciddi şekilde tehlikeye atmadan. Uzman olmasan da '
            'bu geçerlidir.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 323c StGB — yardım etmemek',
            text: 'Makul olduğu halde yardım etmeyen kişi suç işlemiş '
                'olur: bir yıla kadar hapis veya para cezası. Bu, '
                'yardımcıları engelleyen meraklılar için de geçerlidir.',
          ),
          SubheadBlock('Yardım eden yanlış yapmaz'),
          BulletsBlock([
            'İlk yardımcı olarak hatalardan sorumlu tutulmazsın — kasıt '
                'veya ağır ihmal dışında',
            'Yardım ettiğin süre boyunca yasal kaza sigortası kapsamındasın',
            'Masrafları sen ödemezsin; maddi zararlar kural olarak '
                'karşılanır',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Tek gerçek hata',
            text: 'Hiçbir şey yapmamaktır. Diğer her şey görmezden '
                'gelmekten iyidir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'İstasyondaki ilk yardımcılar — ve sen',
        blocks: [
          ParagraphBlock(
            'İstasyonda eğitimli işyeri ilk yardımcıları bulunur. Bunu '
            'işveren sağlar: ilk yardımın organizasyonu onun görevidir '
            '(§ 24 DGUV Vorschrift 1) ve belirli bir asgari sayıda '
            'eğitimli ilk yardımcı bulundurmak zorundadır '
            '(§ 26 DGUV Vorschrift 1).',
          ),
          FactsBlock([
            FactItem('1', 'ilk yardımcı, 2–20 kişi bulunuyorsa'),
            FactItem('10 %', 'diğer işletmelerde bulunanların oranı'),
            FactItem('2 yıl', 'ilk yardımcıların tazeleme eğitimi'),
          ]),
          ParagraphBlock(
            'Aynı alanda birden fazla işveren çalışıyorsa, birbirleriyle '
            'uyum sağlamak ve bilgi alışverişinde bulunmak zorundadırlar '
            '(§ 8 Arbeitsschutzgesetz). Bu kapsamda istasyonun ilk yardım '
            'organizasyonunun ortak kullanılması kararlaştırılabilir. Bu, '
            'işletmelerin iş birliğini düzenler — senin kişisel '
            'yükümlülüğünü değil.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Bu seni sorumluluktan kurtarmaz',
            text: '§ 323c StGB uyarınca yardım etme yükümlülüğü herkesi '
                'kişisel olarak bağlar. İstasyondaki eğitimli ilk '
                'yardımcılar bunu değiştirmez.',
          ),
          SubheadBlock('Hukuken nasıl davranılır'),
          BulletsBlock([
            'Zaten biri oradaysa ve gerçekten yeterli yardım ediyorsa, '
                'kendin müdahale etmek zorunda değilsin',
            'Ambulansı çağırma ve yardım getirme yükümlülüğü her durumda '
                'devam eder',
            'Gerçekten yardım edildiğinden emin olmalısın — „nasılsa biri '
                'ilgilenir" diyerek uzaklaşmak yeterli değildir',
            'İlk yardımcının talimatıyla destek ol: alanı emniyete al, '
                'ambulansı yönlendir, malzeme getir, başkalarını uzak tut',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Turda yalnızsın',
            text: 'Çalışma süresinin büyük bölümünde istasyonda değil, '
                'yoldasın. Orada istasyon ilk yardımcısı yok — rotada bir '
                'acil durumda ilk yardımcı sensin.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Acil çağrı yapmak',
        blocks: [
          FactsBlock([
            FactItem('112', 'acil çağrı, tüm Avrupa'),
          ]),
          SubheadBlock('Beş temel soru'),
          StepsBlock([
            'Nerede oldu?',
            'Kaç kişi yaralandı?',
            'Ne oldu?',
            'Kim arıyor?',
            'Soruları bekle',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Yardım ederken temel kurallar',
            text: 'Sakin kal · hızlı davran · kendi güvenliğine dikkat et '
                '· kaza yerini emniyete al · bildiğin en iyi şekilde '
                'yardım et.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Belgelendirme ve bildirim',
        blocks: [
          ParagraphBlock(
            'Her yaralanma kayda geçer — küçük bir kesik bile. Bu, ileride '
            'sonuçlar ortaya çıkarsa seni korur.',
          ),
          SubheadBlock('Kaza defterine yazılacaklar'),
          BulletsBlock([
            'Zaman ve yer',
            'Olayın gelişimi',
            'Yaralanmanın türü ve kapsamı',
            'Yaralanan kişinin adı',
            'Tanıklar ve ilk yardımcılar',
          ]),
          FactsBlock([
            FactItem('> 3 gün', 'rapor → kaza bildirimi gerekli'),
            FactItem('3 gün', 'bildirim süresi'),
            FactItem('5 yıl', 'saklama süresi, gizli'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Hemen bildir',
            text: 'Ölümlü kazaları, toplu kazaları ve ağır sağlık '
                'zararlarını işveren gecikmeden bildirir — bu yüzden '
                'işverenini her zaman hemen bilgilendir.',
          ),
          ParagraphBlock(
            'İlk yardım çantaları eksiksiz olmalıdır. Son kullanma '
            'tarihini kontrol et ve eksik malzemeyi bildir.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 7
  SafetyChapterContent(
    id: 'ch07',
    title: 'Oturmak ve hareket etmek',
    summary: 'Beli koru, dikkati canlı tut',
    asset: '${_a}ch07_sitzen_bewegen.svg',
    slides: [
      SafetySlide(
        title: 'Oturmak neden risk olur',
        asset: '${_a}ch07_sitzen_bewegen.svg',
        blocks: [
          ParagraphBlock(
            'Uzun süre ve kötü ayarlanmış şekilde oturmak sadece rahatsız '
            'edici değildir — dikkatine ve tepki süresine mal olur.',
          ),
          BulletsBlock([
            'Yorgunluk ve azalan dikkat',
            'Kas gerginliği ve bel ağrısı',
            'Boyun ve bel omurgasında şikayetler',
            'Geciken tepki nedeniyle kazalar',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Koltuğu doğru ayarla',
        blocks: [
          ParagraphBlock(
            'İlk yolculuktan önce iki dakika ayır. Yedi ayar belirleyici '
            'olur:',
          ),
          StepsBlock([
            'Koltuk yüksekliği ve ileri-geri ayarı',
            'Oturma yüzeyinin derinliği',
            'Oturma yüzeyinin eğimi',
            'Sırt dayanağının eğimi',
            'Bel desteği',
            'Baş desteği',
            'Direksiyon ve kemer geçişi',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Hareketli oturmak',
            text: 'Sırtını tamamen dayamaya ver, dik otur — ve duruşunu '
                'sürekli biraz değiştir. En iyi oturma pozisyonu bir '
                'sonrakidir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Arada yapılacak egzersizler',
        blocks: [
          SubheadBlock('Otururken'),
          BulletsBlock([
            'Direksiyonu güçlü şekilde iki yana çek — 3–6 saniye tut, '
                '3 tekrar',
            'Dizini ellerinin baskısına karşı bastır — 3–6 saniye, '
                '5 tekrar',
            'Ellerini koltuğa dayayıp vücudunu kaldır — 3 tekrar',
          ]),
          SubheadBlock('Ayaktayken'),
          BulletsBlock([
            'Kollarını yukarı uzat — yaklaşık 8 saniye, 3–5 tekrar',
            'Ellerini ensene koy, dirseklerini geriye it — yaklaşık '
                '8 saniye, 3–5 tekrar',
            'Topuğunu yaklaşık 30 cm yüksekliğe koy, bacağını ger — '
                'yaklaşık 8 saniye, her bacak için 2–3 kez',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Çalışan bir bel daha çok dayanır',
            text: 'Mola süreni kullan — ek zaman değil.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 8
  SafetyChapterContent(
    id: 'ch08',
    title: 'Yük ve konsantrasyon',
    summary: 'Gün boyu performanslı ve dikkatli kalmak',
    asset: '${_a}ch08_psychische_belastung.svg',
    slides: [
      SafetySlide(
        title: 'Bu neden iş güvenliğine dahil',
        asset: '${_a}ch08_psychische_belastung.svg',
        blocks: [
          ParagraphBlock(
            'Baskı altındaki kişi daha yavaş tepki verir, daha çok şeyi '
            'gözden kaçırır ve hata yapar. Tam da bu yüzden zorlanma bir '
            'güvenlik konusudur — biri hastalanana kadar beklemeye gerek '
            'yok.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Yasal zorunluluk',
            text: '2013 yılından beri risk değerlendirmesi, işteki ruhsal '
                'zorlanmaları da açıkça dikkate almak zorundadır '
                '(§ 5 Abs. 3 Nr. 6 Arbeitsschutzgesetz). Değerlendirilen '
                'şey çalışma koşullarıdır — tek tek kişiler değil.',
          ),
          SubheadBlock('Sürüş gününde baskıyı ne yaratır'),
          BulletsBlock([
            'Dar zaman aralıkları, trafik, şantiyeler, park yeri arama',
            'Yükleme ve boşaltmada belirsiz sorumluluklar',
            'Tur hakkında eksik veya geç gelen bilgiler',
            'Araçta veya cihazda teknik sorunlar',
            'Zor müşteri durumları',
          ]),
          ParagraphBlock(
            'Bunlar işletmenin değiştirebileceği koşullardır. Bu yüzden en '
            'önemli kural şudur: hâlâ çözülebilecekken bildir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dikkatli kalmak — pratikte nasıl olur',
        blocks: [
          SubheadBlock('Tur sırasında'),
          BulletsBlock([
            'Molaları bir araç gibi kullan: kısa süre in, uzağa bak, '
                'birkaç adım yürü — bu, dikkati ölçülebilir şekilde geri '
                'getirir',
            'Yeterince su iç ve düzenli yemek ye',
            'Zaman baskısı altında manevra yapma — iki dakika, bir '
                'kaporta hasarından ucuzdur',
            'Telefonu sadece dururken kullan, adresi yola çıkmadan gir',
            'Zor müşteri temaslarından sonra devam etmeden önce kısa bir '
                'nefes al',
          ]),
          SubheadBlock('Katlanmak yerine erken dile getir'),
          ParagraphBlock(
            'Bir şey sürekli yolunda gitmiyorsa dispeçerine söyle — erken '
            've somut şekilde. Düzenli olarak yetiştirilemeyen bir tur, '
            'sürekli sorun çıkaran bir araç, sürekli park sıkıntısı olan '
            'bir rota: biri bunu bilirse planlanabilir.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Somut bildirmek katlanmaktan çok işe yarar',
            text: 'Tam olarak neyin ve nerede aksadığını söyle — sadece '
                'stresli olduğunu değil. Geri bildirim ne kadar somutsa, '
                'planlamada bir şeyin değişme ihtimali o kadar yüksektir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Özel olaylardan sonra',
        blocks: [
          ParagraphBlock(
            'Bazı durumlar sonradan etkisini gösterir: ağır bir kaza, bir '
            'saldırı, ağır yaralıların olduğu bir ilk yardım müdahalesi. '
            'Bu, normal olmayan bir olaya verilen normal bir tepkidir — '
            've zayıflık işareti değildir.',
          ),
          BulletsBlock([
            'Sana bir şey olmasa bile olayı amirine bildir',
            'İş kazalarından sonra meslek birliği üzerinden destek '
                'imkanları vardır',
            'Birçok işletmede psikolojik ilk yardımcılar veya travma '
                'danışmanları bulunur — büroya sor',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Akut acil durumda',
            text: 'Almanyada akut bir ruhsal kriz durumunda: '
                'Telefonseelsorge 0800 111 0 111 — ücretsiz, isimsiz, '
                'günün her saati ulaşılabilir.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 9
  SafetyChapterContent(
    id: 'ch09',
    title: 'Güvenli sürüş ve araç kontrolü',
    summary: 'Her turdan önce iki dakikalık kontrol',
    asset: '${_a}ch09_sicheres_fahren.svg',
    slides: [
      SafetySlide(
        title: 'Aracın etrafında tur',
        asset: '${_a}ch09_sicheres_fahren.svg',
        blocks: [
          ParagraphBlock(
            'Her yolculuktan önce araç kontrolü zorunludur. İki dakika '
            'sürer ve yolda pahalıya ya da tehlikeye mal olacak eksikleri '
            'tam olarak bulur.',
          ),
          BulletsBlock([
            'Aydınlatma, önde ve arkada',
            'Görüş — aynalar ve camlar temiz ve hasarsız',
            'Tekerlekler — hava basıncı, diş derinliği, sıkılık',
            'Frenler — fren denemesi, fren basıncı',
            'Motor ve aktarma — yağ, soğutma ve fren sıvısı, cam suyu, '
                'sızıntı yok',
            'Branda ve kapılar kapalı',
            'Plaka ve uyarı levhaları temiz',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Yük ve sürücü çalışma alanı',
        blocks: [
          SubheadBlock('Yük emniyeti'),
          BulletsBlock([
            'Araç bu yük için uygun mu?',
            'Bağlama gereçleri hasarsız mı?',
            'Yük emniyete alınmış ve kaymaya karşı korunmuş mu?',
            'Aks yükleri ve azami toplam ağırlık aşılmamış mı?',
          ]),
          SubheadBlock('Senin çalışma alanın'),
          BulletsBlock([
            'Koltuk ve direksiyon doğru ayarlanmış',
            'Gösterge panelinde arıza uyarısı yok',
            'Fren denemesi sorunsuz',
            'Sürücü destek sistemleri açık ve hazır',
            'Havalandırma çalışıyor',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Kışın ek olarak',
            text: 'Uygun lastikler, gerekirse kar zinciri veya kalkış '
                'yardımı, soğutma sıvısı ve cam suyunda yeterli antifriz, '
                'araçta buz kazıyıcı.',
          ),
          InstructionRefBlock(['baw_transporter', 'baw_winter']),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 10
  SafetyChapterContent(
    id: 'ch10',
    title: 'Arıza ve kazalar',
    summary: 'Emniyete al, yardım et, doğru belgele',
    asset: '${_a}ch10_pannen_unfaelle.svg',
    slides: [
      SafetySlide(
        title: 'Temel kural ve arıza',
        asset: '${_a}ch10_pannen_unfaelle.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Temel kural',
            text: 'Kendi güvenliğin başkasının güvenliğinden önce gelir. '
                'İnsanı korumak eşyayı korumaktan önce gelir.',
          ),
          SubheadBlock('Bir arıza kendini belli ederse'),
          StepsBlock([
            'Erkenden uygun bir durma yeri ara — örn. soğutma suyu '
                'sıcaklığı yükseliyorsa',
            'Yavaşlarken daha o anda dörtlüleri yak',
            'Mümkünse en yakın park yerine, olmazsa yolun en sağ kenarına',
            'El frenini çek, karanlıkta park lambasını yak',
            'Reflektörlü yeleği giy — araçtan inmeden önce',
            'Reflektörlü üçgeni yerleştir',
          ]),
          FactsBlock([
            FactItem('100 m', 'reflektörlü üçgen, şehirlerarası yol'),
            FactItem('150–400 m', 'reflektörlü üçgen, otoyol'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Kaza durumunda acil plan',
        blocks: [
          StepsBlock([
            'Dur — her zaman, kimse yoksa bile',
            'Kaza yerini emniyete al — dörtlüler, el freni, karanlıkta '
                'park lambası, inmeden önce reflektörlü yelek, '
                'reflektörlü üçgen',
            'İlk yardım yap — gecikmeden',
            'Acil çağrı 112 — acil ise ilk yardımdan da önce',
            'Kimlik bilgilerini paylaş — ad, adres, plaka, sigorta',
            'Polisi çağır — yaralanma, yüksek maddi hasar veya alkol '
                'ile uyuşturucu şüphesi varsa',
            'Delilleri koru — kaza yeri ve hasarların fotoğrafları, '
                'tanıkların iletişim bilgileri',
            'İşvereni bilgilendir ve nasıl devam edeceğini konuş, sürüş '
                'yeterliliğini kontrol et, reflektörlü üçgeni geri topla',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Park hasarı ve en sık görülen yaralanma',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Bir not kağıdı yetmez',
            text: 'Park halindeki bir araca çarparsan ve kimse yoksa: en '
                'az 30 dakika bekle. Sonra adını ve adresini bırak VE '
                'kazayı gecikmeden en yakın polis merkezine bildir. Aksi '
                'halde bu, kaza yerinden kaçmak olur.',
          ),
          SubheadBlock('Sürücüler gerçekte nerede yaralanıyor'),
          FactsBlock([
            FactItem('51,6 %', 'düşmeler ve yüksekten düşmeler'),
            FactItem('7,2 %', 'trafik kazaları'),
          ]),
          ParagraphBlock(
            'Bildirimi zorunlu kazaların çoğu trafikte değil, sürücü '
            'kabinine ya da yükleme alanına inip binerken olur.',
          ),
          DoDontBlock(
            doTitle: 'Doğru',
            dos: [
              'Öngörülen basamakları ve tutamakları kullan',
              'İnip binerken üç nokta teması',
              'Basamakları temiz ve boş tut',
              'Uygun ayakkabı giy',
            ],
            dontTitle: 'Tehlikeli',
            donts: [
              'Sürücü kabininden veya yükleme alanından atlamak',
              'Kirli, buzlu veya önü kapalı basamaklara basmak',
              'Bunun için öngörülmemiş araç parçalarına veya yükün '
                  'üstüne çıkmak',
              'Hasarlı merdiven kullanmak',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 11
  SafetyChapterContent(
    id: 'ch11',
    title: 'Üç nokta kuralı',
    summary: 'İnip binmek — en önemli tek kural',
    asset: '${_a}step3p_cover.svg',
    slides: [
      SafetySlide(
        title: 'Her zaman 4 temas noktasından 3 tanesi',
        asset: '${_a}step3p_cover.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Temel kural',
            text: '2 el + 1 ayak  VEYA  2 ayak + 1 el. Üç nokta her zaman '
                'araçla sıkı temas halinde olur.',
          ),
          ParagraphBlock(
            'Her gün onlarca kez inip biniyorsun — acele ederken, '
            'yağmurda, ellerin doluyken. Kazaların çoğu tam o anda olur. '
            'Üç sıkı nokta sana tutunma sağlar ve düşmeleri, bilek, diz '
            've bel yaralanmalarını önler.',
          ),
          FactsBlock([
            FactItem('51,6 %', 'tüm kazaların düşme olduğu oran'),
            FactItem('7,2 %', 'trafik kazası olan oran'),
          ]),
          ParagraphBlock(
            'İş gününde hiçbir hareket bu kadar çok yaralanmayı önlemez. '
            'Bu yüzden bu eğitimin sonunda yer alıyor — akılda kalması '
            'gereken şey olarak.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dört kural tek tek',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}step3p_01_face.svg',
              title: 'Yüzün araca dönük',
              caption: 'Her zaman yüzün araca dönük şekilde in — asla geri '
                  'geri veya yana doğru atlama. Atlamak en sık görülen '
                  'kaza nedenidir. Her zaman basamağı ve tutamakları '
                  'kullan.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_02_hands.svg',
              title: 'Önce bırak, sonra tutun',
              caption: 'İnip binerken elinde paket olmasın. Gönderiyi önce '
                  'yere bırak veya küçük parçaları çantaya ya da kemere '
                  'yerleştir — ellerin tutunmak için boş kalsın.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_03_onepoint.svg',
              title: 'Sadece bir noktayı hareket ettir',
              caption: 'Diğer üçü sıkıca tutarken her zaman sadece bir el '
                  'veya bir ayak hareket ettir. Acele etme — tur sıkışık '
                  'olsa bile.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_04_steps.svg',
              title: 'Basamaklara ve tutunmaya dikkat et',
              caption: 'Islaklık, kar, yağ ve kiri gözden kaçırma. Sakin '
                  've kontrollü bas, gerekirse basamakları önceden '
                  'temizle.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Buna dahil olan iki şey',
        blocks: [
          SubheadBlock('Bilek yüksekliğinde iş ayakkabısı'),
          ParagraphBlock(
            'Bilek yüksekliğindeki ayakkabılar bileği içine alır ve ayak '
            'eklemini belirgin şekilde daha iyi sabitler — burkulma tam '
            'orada, araçtan inerken olur.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Daha önce bileğin burkuldu mu?',
            text: 'Daha önce bilek sorunu yaşayan kişi, bilek '
                'yüksekliğinde ayakkabı istemeli — bir sonraki turdan '
                'önce, sonrasında değil.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}step3p_05_phone.svg',
              title: 'Elinde özel telefon olmasın',
              caption: 'Konuşmak, yazmak ve kaydırmak dikkatini dağıtır — '
                  'düşmeler ve kazalar tam bundan doğar. Özel aramalar ve '
                  'mesajlar molaya kadar bekleyebilir. İnip binerken '
                  'telefonun cebinde olmalı.',
            ),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Kısaca akılda kalsın',
            text: 'Yüzün araca dönük · üç noktayı tut · ellerin boş · '
                'bilek yüksekliğinde iş ayakkabısı · özel telefon yok · '
                'atlamak yerine basamağı kullan.',
          ),
        ],
      ),
    ],
  ),
];
