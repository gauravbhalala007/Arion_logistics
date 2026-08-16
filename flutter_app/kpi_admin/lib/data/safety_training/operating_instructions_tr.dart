// lib/data/safety_training/operating_instructions_tr.dart
//
// Betriebsanweisungen — tuerkische Fassung (uebersetzt aus DE-Master).
// Generisch für Zustellbetriebe formuliert; betriebsspezifische Angaben
// (Ansprechpartner, Standort der Verbandkästen, Sammelplatz) ergänzt
// der jeweilige Betrieb.

import 'operating_instructions.dart';

const List<OperatingInstruction> operatingInstructionsTr = [
  // ─────────────────────────────────────────── Fahrzeug / Araç
  OperatingInstruction(
    id: 'baw_transporter',
    title: '3,5 t’ye kadar panelvan ile sürüş',
    subtitle: 'Dağıtım aracını kullanma, manevra yapma, park etme',
    category: InstructionCategory.vehicle,
    scope: 'Azami yüklü ağırlığı 3,5 t’ye kadar olan dağıtım araçlarını '
        'kullanan tüm çalışanlar için geçerlidir.',
    hazards: [
      'Dikkat dağınıklığı, zaman baskısı ve yorgunluk nedeniyle trafik '
          'kazaları',
      'Geri giderken kişilere çarpma — kör nokta',
      'Frenlemede ve virajlarda yükün kayması',
      'İnip binerken düşmeler',
      'Azami yüklü ağırlığın aşılması',
    ],
    protection: [
      'Geçerli sürücü belgesini yanında bulundur',
      'Yola çıkmadan önce hareket öncesi kontrol: aydınlatma, lastikler, '
          'frenler, görüş, yük emniyeti',
      'Koltuğu, aynaları ve baş desteğini ilk sürüşten önce ayarla',
      'Emniyet kemerini bağla — iki durak arasındaki kısa mesafelerde de',
      'Sürüşten önce ve sürüş sırasında alkol, uyuşturucu ve etkiyi '
          'bozan ilaç yok',
      'Cep telefonunu yalnızca eller serbest düzenekle kullan, adres '
          'girişini yalnızca duruşta yap',
      'Tehlike varsa geri manevrayı yalnızca yönlendirici ile yap; '
          'şüphede araçtan in ve çevreyi kontrol et',
      'Yükü kaymaya karşı emniyete al, ağır gönderileri alta ve ön '
          'panele yerleştir',
      'Aracı terk ettikten sonra daima kilitle, anahtarı asla üzerinde '
          'bırakma',
      'Mola ve sürüş süresi kurallarına uy',
    ],
    onFailure: [
      'Uyarı lambaları veya alışılmadık sesler durumunda: güvenli bir '
          'yere yanaş ve dur',
      'Dörtlü flaşörü aç, reflektörlü yeleği giy, reflektörlü üçgeni '
          'yerleştir (yaklaşık 100 m, otoyolda 150–400 m)',
      'Dispeçeri bilgilendir, yol yardımını belirlenen yoldan çağır',
      'Kendin tamir etme — çekme işlemi yalnızca çekme demiri ile',
      'Belirgin arızası olan aracı hareket ettirmeye devam etme',
    ],
    onAccident: [
      'Dur, kaza yerini emniyete al, inmeden önce reflektörlü yeleği giy',
      'İlk yardım uygula, acil çağrı 112',
      'Yaralanma, yüksek maddi hasar veya alkol/uyuşturucu şüphesi '
          'durumunda polis çağır',
      'Kimlik ve sigorta bilgilerini paylaş, fotoğraf ve tanık bilgisi '
          'topla',
      'İşvereni gecikmeden bilgilendir; küçük yaralanmaları da kaza '
          'defterine (Verbandbuch) kaydet',
    ],
    maintenance: [
      'Eksiklikleri hemen bildir ve belgele',
      'Aracı temiz tut, görüş ve basamak yüzeylerini kar, buz ve '
          'kirden arındır',
      'İlk yardım çantasını, reflektörlü üçgeni ve yeleği eksiksizlik ve '
          'son kullanma tarihi açısından kontrol et',
      'Bakım ve muayene randevularına uy',
    ],
  ),

  // ─────────────────────────────────────────── PSA / KKD
  OperatingInstruction(
    id: 'baw_sicherheitsschuhe',
    title: 'İş güvenliği ayakkabıları',
    subtitle: 'Dağıtım işletmesinde ayak koruması',
    category: InstructionCategory.ppe,
    scope: 'Dağıtım, depo ve araç sahasındaki tüm çalışanlar için '
        'geçerlidir.',
    hazards: [
      'Düşen gönderiler ve yük parçaları',
      'Sivri veya keskin kenarlı cisimlere basma',
      'Araçtan inerken, kaldırımlarda ve engebeli yollarda ayak bileğinin '
          'burkulması ve bağ yaralanmaları',
      'Islak ve buzlu zeminlerde kayma',
      'Rolteynerler ve transpaletler nedeniyle ezilmeler',
    ],
    protection: [
      'İş güvenliği ayakkabılarını tüm çalışma süresi boyunca giy — '
          'istasyonda olduğu gibi rotada da, yıl boyu ve giyim '
          'konforundan bağımsız olarak',
      'Bilek boyu modeli tercih et — ayak bileğini burkulmaya karşı '
          'destekler',
      'En az S1 koruma sınıfı; ıslaklıkta S2, delinme riskinde S3',
      'Ayakkabıları tamamen bağla, kapalı şekilde giy',
      'İşe başlamadan önce kusurları kontrol et: taban deseni, çatlaklar, '
          'taban yapışması',
      'Ayakkabılarda kendi başına değişiklik yapma',
      'Asla spor ayakkabı veya açık ayakkabı ile çalışma',
    ],
    onFailure: [
      'Aşınmış taban deseni, çatlaklar veya bozuk taban: ayakkabıları '
          'kullanmaya devam etme',
      'Vuran veya tahriş eden ayakkabıları bildir — başka modeller ve '
          'bedenler var; özel spor ayakkabıya geçmek çözüm değildir',
      'Yenisini amirinden talep et — KKD’yi işveren ücretsiz sağlar',
    ],
    onAccident: [
      'Ayak yaralanmalarını hemen tedavi ettir, görünüşte hafif olanları '
          'da',
      'Kaza defterine (Verbandbuch) kayıt',
      'Delici yaralanmalarda tıbbi tedavi — tetanoz korumasını kontrol '
          'ettir',
    ],
    maintenance: [
      'Ayakkabıları düzenli olarak temizle ve kurumaya bırak',
      'Çok kirlenmiş veya iyice ıslanmış ayakkabıları değiştir',
      'Değiştirme aralığı üretici bilgisine ve aşınmaya göre',
    ],
  ),

  OperatingInstruction(
    id: 'baw_warnweste',
    title: 'Reflektörlü yelek',
    subtitle: 'Trafik alanında görünür olmak',
    category: InstructionCategory.ppe,
    scope: 'Trafik alanında, sahada veya yükleme alanlarında bulunan tüm '
        'çalışanlar için geçerlidir.',
    hazards: [
      'Diğer trafik katılımcıları tarafından fark edilmemek',
      'Alacakaranlık, karanlık, yağmur ve siste kötü görüş',
      'İstasyon sahasındaki manevra trafiği',
    ],
    protection: [
      'Reflektörlü yeleği el altında sürücü kabininde bulundur — yük '
          'bölümünde değil',
      'Arıza, kaza ve trafik alanındaki her duruşta inmeden önce giy',
      'İstasyon sahasında ve yükleme alanlarında araç trafiği varsa giy',
      'Sınıf 2 veya 3 reflektörlü yelek kullan, tamamen kapat',
      'Karanlıkta ayrıca aydınlatmaya ve park lambasına dikkat et',
    ],
    onFailure: [
      'Kirlenmiş, solmuş veya hasarlı yeleği değiştir — reflektör '
          'şeritlerinin etkili olması gerekir',
      'Eksik yeleği yola çıkmadan önce bildir ve yenisini iste',
    ],
    onAccident: [
      'Trafik alanındaki bir kazadan sonra kaza yeri temizlenene kadar '
          'yeleği çıkarma',
      'Yaralanmaları bildir ve belgele',
    ],
    maintenance: [
      'Yeleği temiz tut, üretici bilgisine göre yıka',
      'Araçta eksiksiz olduğunu kontrol et — hareket öncesi kontrolün '
          'bir parçasıdır',
    ],
  ),

  // ─────────────────────────────────────────── Handhabung / Elleçleme
  OperatingInstruction(
    id: 'baw_heben_tragen',
    title: 'Kaldırma ve taşıma',
    subtitle: 'Gönderileri beli zorlamadan hareket ettirmek',
    category: InstructionCategory.handling,
    scope: 'Gönderilerin ve yük taşıyıcılarının elle kaldırılması, '
        'taşınması ve indirilmesi için geçerlidir.',
    hazards: [
      'Yanlış kaldırma tekniği nedeniyle omurga ve disk hasarları',
      'Ani hareketler nedeniyle kas ve tendon yaralanmaları',
      'İndirirken ellerde ve ayaklarda ezilmeler',
      'Büyük gönderilerde kısıtlı görüş nedeniyle tökezleme',
    ],
    protection: [
      'Kaldırmadan önce ağırlığı tahmin et ve yolu boşalt',
      'Yüke yaklaş, ayaklar omuz genişliğinde',
      'Bacaklardan kaldır: dizlerini bük, sırtını düz tut',
      'Yükü vücuda yakın taşı, kol boyu mesafede değil',
      'Kaldırıp aynı anda dönme — ayaklarınla yön değiştir',
      'Ağır veya hantal gönderileri iki kişiyle ya da yardımcı '
          'ekipmanla taşı (rolteyner, çeki arabası, transpalet)',
      'Taşırken görüşünü açık tut; şüphede iki kez git',
      'Keskin kenarlı gönderilerde eldiven giy',
    ],
    onFailure: [
      'Çok ağır veya kullanışsız olan yükü tek başına hareket ettirme — '
          'yardım iste',
      'Arızalı yardımcı ekipmanı (sıkışan tekerlekler, hasarlı çeki '
          'arabası) kullanma ve bildir',
    ],
    onAccident: [
      'Sırtta ani ağrı olursa faaliyeti hemen durdur',
      'Amiri bilgilendir, kaza defterine (Verbandbuch) kayıt yap',
      'Şikâyetler sürerse iş kazası uzman hekimine (Durchgangsarzt) '
          'başvur',
    ],
    maintenance: [
      'Taşıma yardımcı ekipmanlarını düzenli olarak işlev açısından '
          'kontrol et',
      'Ulaşım yollarını ve yükleme alanlarını boş ve kaymaz tut',
    ],
  ),

  OperatingInstruction(
    id: 'baw_winter',
    title: 'Kış koşullarında yol durumu',
    subtitle: 'Kar, buz ve ıslaklıkta sürüş ve dağıtım',
    category: InstructionCategory.vehicle,
    scope: 'Kış koşullarında dağıtım ve araç kullanımı için geçerlidir.',
    hazards: [
      'Uzayan fren mesafesi, savrulma, su kızağı (aquaplaning)',
      'Buzlu yaya yollarında, rampalarda ve basamaklarda düşmeler',
      'Açık havada uzun süre kalma nedeniyle üşüme ve hipotermi',
      'Buzlanmış camlar ve aynalar nedeniyle kısıtlı görüş',
    ],
    protection: [
      'Yola çıkmadan önce aracı kar ve buzdan tamamen temizle — tavan, '
          'farlar ve plaka dahil',
      'Kışa uygun lastikler; gerektiğinde kar zinciri ve kalkış '
          'yardımcılarını yanında bulundur',
      'Soğutma suyunda ve cam yıkama suyunda antifrizi kontrol et, buz '
          'kazıyıcı araçta olsun',
      'Hızı belirgin şekilde düşür, takip mesafesini en az iki katına '
          'çıkar',
      'Yumuşak fren yap, yumuşak direksiyon çevir ve hızlan',
      'Basamak yüzeylerini ve çıkışları kullanmadan önce kardan temizle',
      'Sıcak, hava koşullarına dayanıklı giysi ve kaymaz ayakkabı giy',
      'Zaman baskısından kaçın — hiç varamamaktansa geç varmak yeğdir',
    ],
    onFailure: [
      'Geçilmez yollarda turu iptal et ve dispeçeri bilgilendir',
      'Araç saplandığında zorla kurtarmaya çalışma — yardım iste',
    ],
    onAccident: [
      'Kaza yerini özellikle özenli şekilde emniyete al — reflektörlü '
          'üçgeni daha uzağa yerleştir',
      'Düşme yaralanmalarını hafif belirtilerde de bildir ve belgele',
    ],
    maintenance: [
      'Silecek lastiklerini ve aydınlatmayı düzenli olarak kontrol et',
      'Kapı fitillerinin bakımını yap, kilitlerin buzunu çöz',
    ],
  ),

  // ─────────────────────────────────────────── Gefahrstoffe / Tehlikeli
  OperatingInstruction(
    id: 'baw_adblue',
    title: 'AdBlue (üre çözeltisi)',
    subtitle: 'Dağıtım aracında AdBlue takviyesi',
    category: InstructionCategory.hazardous,
    scope: 'SCR egzoz gazı arıtmalı araçlarda AdBlue takviyesi ve '
        'kullanımı için geçerlidir.',
    hazards: [
      'Temas hâlinde gözlerde, ciltte ve solunum yollarında tahriş',
      'Dökülen sıvı nedeniyle kayma tehlikesi',
      'Araç parçalarında kristalleşme ve korozyon',
      'Toprağa veya kanalizasyona karışması hâlinde çevre kirliliği',
    ],
    protection: [
      'Yalnızca öngörülen mavi dolum ağzını kullan — asla dizel deposuna '
          'doldurma',
      'Koruyucu eldiven giy, cilt temasından kaçın',
      'Yalnızca açık havada veya iyi havalandırılmış yerde takviye yap, '
          'motoru durdur',
      'Kabı temiz şekilde kapat, güneş altında depolama',
      'Kullanımdan sonra elleri iyice yıka',
    ],
    onFailure: [
      'Dökülen sıvıyı hemen suyla seyrelt ve topla',
      'Emici madde kullan, kanalizasyona akıtma',
      'Yanlış yakıt doldurulduğunda aracı çalıştırma ve hemen bildir',
    ],
    onAccident: [
      'Göz teması: en az 15 dakika suyla yıka, doktora başvur',
      'Cilt teması: bol suyla durula, bulaşan giysiyi değiştir',
      'Yutma: ağzı çalkala, su iç, doktora başvur',
      'Olayı bildir ve kaza defterine (Verbandbuch) kaydet',
    ],
    maintenance: [
      'Kabı ve dolum bölgesini temiz tut',
      'Boş ambalajları talimata uygun şekilde bertaraf et',
    ],
  ),

  // ─────────────────────────────────────────── Hygiene / Hijyen
  OperatingInstruction(
    id: 'baw_hautschutz',
    title: 'Cilt koruma ve el hijyeni',
    subtitle: 'Müşteri temasında ve yükleme işinde elleri korumak',
    category: InstructionCategory.hygiene,
    scope: 'Gönderiler, araçlar ve müşterilerle sık el teması olan tüm '
        'çalışanlar için geçerlidir.',
    hazards: [
      'Sık yıkama ve dezenfeksiyon nedeniyle kuruma ve çatlaklar',
      'Kir, soğuk ve temizlik maddeleri nedeniyle cilt tahrişleri',
      'Müşteri temasında enfeksiyon bulaşması',
      'Karton kenarlarında kesik ve sıyrık yaraları',
    ],
    protection: [
      'İşe başlamadan önce cilt koruma ürünü uygula',
      'Tuvaletten sonra, molalardan önce ve yükleme işinden sonra '
          'elleri yıka',
      'Dezenfektanı tamamen ovarak yedir ve kurumaya bırak — silme',
      'Yıkadıktan sonra cilt bakım ürünü kullan',
      'Keskin kenarlı veya kirli gönderilerde koruyucu eldiven',
      'Yükleme işinde yüzükleri ve kol saatlerini çıkar',
    ],
    onFailure: [
      'Kalıcı kızarıklık, kaşıntı veya çatlaklarda faaliyeti bildir',
      'Uyumsuz ürünü kullanmaya devam etme — alternatif talep et',
    ],
    onAccident: [
      'Kesik ve sıyrık yaralarını hemen temizle ve sar',
      'Küçük yaralanmalarda da kaza defterine (Verbandbuch) kayıt',
      'İltihap belirtilerinde tıbbi tedavi',
    ],
    maintenance: [
      'Sabun, dezenfektan ve bakım ürünü dispenserlerini dolum düzeyi '
          'açısından kontrol et',
      'Boş veya arızalı dispenserleri bildir',
    ],
  ),

  // ─────────────────────────────────────────── Arbeitsplatz / İş yeri
  OperatingInstruction(
    id: 'baw_bildschirm',
    title: 'Ekranlı çalışma yeri',
    subtitle: 'Sevkiyat planlama ve büro işi',
    category: InstructionCategory.workplace,
    scope: 'Ağırlıklı olarak ekran başında çalışan personel için '
        'geçerlidir — özellikle dispeçerler ve idari birim.',
    hazards: [
      'Kamaşma ve uzun süreli odaklanma nedeniyle göz şikâyetleri',
      'Boyun, omuz ve sırtta gerginlikler',
      'Elverişsiz el ve kol duruşu nedeniyle tendon kılıfı tahrişi',
      'Kablolara takılıp tökezleme',
    ],
    protection: [
      'Ekranın üst kenarı yaklaşık göz hizasında, görme mesafesi '
          '50–70 cm',
      'Ekranı pencereye yan konumlandır — önüne veya karşısına değil',
      'Oturma yüksekliğini, ön kol ile üst kol yaklaşık dik açı '
          'oluşturacak şekilde seç',
      'Ayaklar yerde düz veya bir ayak desteği üzerinde',
      'Duruşunu düzenli olarak değiştir, uzağa kısa bakış molaları ver',
      'Kabloları düzenle ve sabitle',
    ],
    onFailure: [
      'Titreşen veya arızalı ekranları ve lambaları bildir',
      'Arızalı sandalyeleri kullanmaya devam etme',
    ],
    onAccident: [
      'Şikâyetler sürerse amiri bilgilendir',
      'İş sağlığı muayenesi ve ekran çalışması gözlüğü hakkını kontrol '
          'ettir',
    ],
    maintenance: [
      'Ekranı ve giriş cihazlarını temiz tut',
      'Çalışma yeri aydınlatmasını düzenli olarak kontrol et',
    ],
  ),
];
