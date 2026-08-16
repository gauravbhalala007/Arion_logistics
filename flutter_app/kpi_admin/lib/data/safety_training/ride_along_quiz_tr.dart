// lib/data/safety_training/ride_along_quiz_tr.dart
//
// Ride Along bitirme testinin soruları. On beş soru,
// ride_along_content_tr.dart içindeki beş bölüme (ra1 … ra5) dağıtılmış,
// her bölüme üç soru.
//
// Soruların düzeyi: iki refakat gününden senaryolar. Birden çok seçenek
// bilerek makul görünür — her seferinde bir ayrıntıya bağlıdır.
// `explanation` her zaman ikisini de açıklar: doğru cevap neden doğru ve
// akla gelen yanılgı neden yanlış.
//
// Çok işletmeli kullanım: Hiçbir yerde işletmeye özel sayılar (stop
// sayıları, Waiting Area saatleri, park tarafı) sorulmaz — yalnızca her
// yerde geçerli olanlar. Hukuki dayanaklı istisnalar: § 4 ArbZG (molalar)
// ve § 1 Abs. 6 FPersV (Green Book).

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> rideAlongQuestionsTr = [
  // ══════════════════════════ ra1 — Ride Along nedir
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'Ride Along nedir?',
    options: [
      'İlk iş gününden önce ofiste yapılan teorik bir bilgilendirme',
      'Deneyimli bir sürücünün eğitmen olarak eşlik ettiği iki iş günü '
          'refakatli sürüş',
      'Onsuz görevlendirilemeyeceğin resmi bir sürüş sınavı',
    ],
    correctIndex: 1,
    explanation: 'Ride Along, deneyimli bir sürücünün sana eşlik ettiği, '
        'her şeyi anlattığı ve sonra yapmayı sana bıraktığı iki gerçek iş '
        'günüdür. Ne ofis eğitimidir ne de resmi bir sınav — işleyen bir '
        'işletme içinde oryantasyondur, ama değerlendirilir ve '
        'belgelendirilir.',
  ),
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'İki günde kaç stop sürmen gerekir?',
    options: [
      'Bunu işletmen ya da istasyonun belirler — kuralı sana eğitmen '
          'söyler',
      'Her işletmede aynı: ilk günde tam 20, ikinci günde tam 70',
      'Kendine ne kadar güveniyorsan o kadar — bir kural yoktur',
    ],
    correctIndex: 0,
    explanation: 'Yaygın olan, ilk günde daha az, ikinci günde belirgin '
        'şekilde daha fazla stoptur (çoğu zaman yaklaşık 20 ve yaklaşık '
        '70), ama bunlar tek tek işletmelerin yol gösterici değerleridir. '
        'Bağlayıcı olan yalnızca istasyonunun kuralıdır. Akla gelen '
        'yanılgı, duyulan bir sayıyı genel bir kanun sanmaktır — senin '
        'için geçerli sayıyı eğitmenine sor.',
  ),
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'İlk günde planlanandan belirgin şekilde yavaşsın ve '
        'sıralamada birkaç hata yapıyorsun. Bu, değerlendirmeyi nasıl '
        'etkiler?',
    options: [
      'Ride Along böylece başarısız sayılır ve tekrarlanması gerekir',
      'Hiç önemi yok, çünkü ilk günde henüz hiçbir şey değerlendirilmez',
      'Belirleyici olan, soru sorup sormadığın ve hatayı sonrasında '
          'düzeltip düzeltmediğindir — hız değil',
    ],
    correctIndex: 2,
    explanation: 'İlk günde kimse hız beklemez; daha az stop sayısı tam da '
        'bunun içindir. Değerlendirilen, öğrenmeye açıklığındır: Soruyor '
        'musun, uyarıları kabul ediyor musun, aynı hatayı üçüncü kez de '
        'yapıyor musun? Her iki yöndeki yanılgı da tehlikelidir — bu ne '
        'giyotinli bir sınavdır ne de değerlendirmesiz bir gündür.',
  ),

  // ══════════════════════════ ra2 — Birinci gün
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Ride Along’daki stopların neden kendi hesabın üzerinden '
        'yürümesi gerekir?',
    options: [
      'Çünkü eğitmen o günlerde kendi hesabını kullanamaz',
      'Çünkü senin kendi teslimatının nasıl göründüğü ancak böyle görünür '
          '— teslimat senin adına sayılır',
      'Çünkü eğitmenin hesabı artık yeni stop kabul edemez',
    ],
    correctIndex: 1,
    explanation: 'O günlerde teslim ettiğin her şey senin adına işlenir — '
        'tam da sonraki günlük işteki gibi. Eğitmen ve işletme senin '
        'gerçek çalışma tarzını ancak böyle görür ve stoplar oryantasyonun '
        'için ancak böyle sayılır. Bu yüzden sabah çalışmayan bir erişim '
        'bir ayrıntı değil, hemen haber verilmesi gereken bir durumdur.',
  ),
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Mentor’un kayıt süresi için ne geçerlidir?',
    options: [
      'Mentor yaklaşık 4 saat aralıksız kaydeder ve sonra yeniden '
          'başlatılmalıdır',
      'Mentor bir kez başlatıldığında vardiya sonuna kadar çalışır',
      'Araç hareket eder etmez Mentor kendiliğinden başlar',
    ],
    correctIndex: 0,
    explanation: 'Kayıt her seferinde yaklaşık dört saat sürer. Sonrasında '
        'yeniden başlatman gerekir, aksi hâlde turun geri kalanı kayıtsız '
        'kalır. Yeni başlayanların en sık hatası tam da uygulamanın '
        'kendiliğinden devam ettiği yanılgısıdır: sabah doğru başlatılmış, '
        'moladan sonra yeniden etkinleştirilmemiş — ve yarım gün '
        'değerlendirmede eksik.',
  ),
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'O gün 9,5 saat çalışıyorsun. Molan en az ne kadar olmalı?',
    options: [
      '30 dakika, çünkü 45 dakika ancak 10 saatten itibaren geçerlidir',
      'Her biri 5 ila 10 dakikalık birkaç kısa mola yeterlidir',
      '45 dakika, çünkü çalışma süresi 9 saatin üzerinde',
    ],
    correctIndex: 2,
    explanation: '§ 4 ArbZG uyarınca 6 saatten fazlada en az 30 dakika, 9 '
        'saatten fazlada en az 45 dakika mola zorunludur — 9,5 saat sınırın '
        'üzerindedir. Mola bölünebilir, ama her parçası en az 15 dakika '
        'sürmelidir; aralarda beşer dakikalar sayılmaz.',
  ),

  // ══════════════════════════ ra3 — İkinci gün
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Şifreli paketi olan bir müşterinin kodu elinde değil, ama '
        'imzalamak istiyor. Ne yaparsın?',
    options: [
      'Teslim etmezsin — doğru kod olmadan istisna yoktur',
      'İmza karşılığında teslim edersin, çünkü o da aynı şekilde bir '
          'kanıttır',
      'Paketi komşuya bırakır ve müşteriyi bilgilendirirsin',
    ],
    correctIndex: 0,
    explanation: 'Şifre, alıcının gerçekten alıcı olduğunun kanıtıdır — '
        'bunun için verilmiştir. Bir imza ya da tatlı dil onun yerini '
        'tutmaz, komşuya bırakmak ise hiç tutmaz. Gönderi sonradan teslim '
        'alınmamış olarak bildirilirse, kodsuz teslim senin hatan olarak '
        'kalır. Doğrusu: kodu aratmak, bulunmazsa paketi doğru şekilde '
        'geri getirmek ve belgelemektir.',
  ),
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Manevra yaparken bir babaya sürtüyorsun. Kamyonette bir '
        'çizik kalıyor, kimse görmedi. Doğrusu nedir?',
    options: [
      'Hiçbir şey yapmamak — başkasına zarar vermeyen bir çizikte '
          'bildirilecek bir şey yoktur',
      'Önce bir sonraki muayenede fark edilip edilmeyeceğini beklemek',
      'Aynı gün içinde bildirmek ve CoDriver’da belgelemek',
    ],
    correctIndex: 2,
    explanation: 'Bildirilen bir hasar, işleme alınan bir olaydır; ertesi '
        'sabah başka birinin muayenesinde bulduğu aynı hasar ise '
        'açıklanmamış bir hasardır — ve şüphe sonunda yine son kullanıcıya '
        'yönelir. “Bu fark edilmez” yanılgısı işe yaramaz: Her turdan önce '
        've sonra yapılan muayene tam da bunun içindir.',
  ),
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Scorecard’da performans ile kalite arasındaki fark nedir?',
    options: [
      'İkisi de aynı şeydir — Scorecard yalnızca stop sayısını ölçer',
      'Performans, belirli sürede yapılan miktardır; kalite ise her bir '
          'stopun ne kadar düzgün tamamlandığıdır',
      'Kalite yalnızca aracı, performans yalnızca teslimatı ilgilendirir',
    ],
    correctIndex: 1,
    explanation: 'Performans miktardır — hangi sürede kaç stop. Kalite ise '
        'her bir stoptaki özendir: doğru yer, doğru belgeleme, şikâyet yok. '
        'İkisini bir tutan, başta bir dakika kazanır ve sonda işletmeye kat '
        'kat pahalıya mal olan bir araştırma yaratır.',
  ),

  // ══════════════════════════ ra4 — Kapanış ve teslim
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'Eğitmen Ride Along kontrol listesini kaç kez imzalar?',
    options: [
      'İkinci günün sonunda iki gün için tek seferde',
      'Hiç — teslimde yalnızca dispatcher imzalar',
      'Her gün için ayrı, her seferinde tarihle birlikte',
    ],
    correctIndex: 2,
    explanation: 'Her günün kendi madde listesi vardır ve bu yüzden ayrı '
        'ayrı tarih ve imzayla kapatılır. Bunun pratik bir nedeni var: '
        'İkinci gün iptal olur ya da ertelenirse, ilk günde nelerin '
        'yapıldığı yine de düzgün belgelenmiş olur. Sonda atılan toplu bir '
        'imza tam da bunu imkânsız kılardı.',
  ),
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'İkinci günün sonunda doldurulmuş kontrol listesine ne olur?',
    options: [
      'Fotoğraf olarak sorumlu dispatcher’a teslim edilir',
      'Onu eve götürür ve kendinde saklarsın',
      'Bir sonraki eğitmen devam etsin diye araçta kalır',
    ],
    correctIndex: 0,
    explanation: 'Form ikinci günün sonunda fotoğraflanır ve sorumlu '
        'dispatcher’a teslim edilir — böylece Ride Along resmen tamamlanır '
        've oryantasyonun belgelenir. Araçta ya da evde duran bir kâğıt, '
        'işletme için kanıt olarak değersizdir. Fotoğrafta işaretlerin, '
        'tarihin, adların ve imzaların okunaklı olmasına dikkat et.',
  ),
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'Geri bildirimde manevrada fazla tereddütlü olduğun '
        'söyleniyor. En anlamlı tepkin ne olur?',
    options: [
      'Bilinçli olarak dikkatli davrandığını açıklamak ve konuyu böylece '
          'kapatmak',
      'O günden somut bir örnek istemek',
      'Geri bildirimi not almak ve bir dahaki sefere daha hızlı manevra '
          'yapmak',
    ],
    correctIndex: 1,
    explanation: 'Manevrada dikkat doğru olandır — “tereddütlü” genellikle '
        'başka bir şeyi anlatır, örneğin kısaca inip bakmak yerine uzun '
        'uzun düşünmeyi. Somut bir örnekle elinde üzerinde çalışabileceğin '
        'bir nokta olur. Kendini savunmak bir işe yaramaz, sadece daha '
        'hızlı manevra yapmak ise üç tepkinin en tehlikelisi olurdu.',
  ),

  // ══════════════════════════ ra5 — Kendini böyle hazırlarsın
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Zaman kaydı, Mentor, Flex ve CoDriver erişimlerinin '
        'çalışıp çalışmadığını ne zaman kontrol etmelisin?',
    options: [
      'İlk günün sabahında eğitmenle birlikte',
      'Ancak çalışırken gerçekten bir sorun çıktığında',
      'İlk günden önce, en iyisi bir akşam önceden',
    ],
    correctIndex: 2,
    explanation: 'Bir şifreyi sıfırlamak akşamdan birkaç dakika, sabah '
        'Waiting Area’da yarım saat sürer — ulaşılabilecek biri varsa '
        'tabii. Akla gelen yanılgı, bunu eğitmene bırakmaktır: Kilitli bir '
        'erişimde sana yardım edemez ve kaybedilen süre kendi hesabın '
        'üzerindeki stoplardan eksilir.',
  ),
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Ride Along’da “dakik” ne demektir?',
    options: [
      'Vardiya başlangıcında istasyonda göreve hazır olmak — park etme ve '
          'yol zaten hesaba katılmış',
      'Vardiya başlangıcında istasyonun kapısına varmak',
      'En geç Waiting Area çağrısı yapıldığında orada olmak',
    ],
    correctIndex: 0,
    explanation: 'Vardiya başlangıcında göreve hazırsın, yolda değil. '
        'Ancak kapıya varan kişi park ederken ve sahadan yürürken zaman '
        'kaybeder, Waiting Area aralığını kaçırır — ve böylece eğitmenin '
        'dalgasını da öteler. Bu yüzden park etme ve yürüme süresini '
        'bilinçli olarak planla.',
  ),
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Eğitmene soracağın soruları daha 1. günden önce yazmak '
        'neden işe yarar?',
    options: [
      'Çünkü eğitmenin soruları önceden yazılı olarak alması gerekir',
      'Çünkü art arda anlatılan on süreci kimse aklında tutamaz — yazılı '
          'olursa hedefe yönelik sorarsın',
      'Çünkü sorulmayan sorular değerlendirmede eksi olarak yazılır',
    ],
    correctIndex: 1,
    explanation: 'Eğitmen iki günde bir anda çok şey anlatır; akşam not '
        'olmadan bundan geriye az şey kalır. Sorularını hazırlayan ve yolda '
        'konu başına iki anahtar kelime not eden, iki günden kat kat fazla '
        'verim alır. Bu resmi bir zorunluluk değildir — ve sorulmayan '
        'soruları kimse eksi olarak yazmaz. Tam da bu yüzden bunu kendin '
        'sağlamak zorundasın.',
  ),
];
