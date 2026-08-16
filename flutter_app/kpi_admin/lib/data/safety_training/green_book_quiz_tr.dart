// lib/data/safety_training/green_book_quiz_tr.dart
//
// Green Book bitirme testinin soruları (§ 1 fıkra 6 FPersV uyarınca sefer
// kontrol defteri) — Türkçe sürüm.
// Yapı Almanca ana sürümle birebir aynıdır: aynı soru sayısı, aynı sıra,
// aynı doğru yanıtlar.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> greenBookQuestionsTr = [
  // ══════════════════════════ gb1 — Green Book nedir
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Green Book’ta neyi belgelersin?',
    options: [
      'Yola çıkmadan önce aracın durumunu',
      'Teslim edilen paket ve iade sayısını',
      'Sürüş sürelerini, sürüş molalarını ayrıca çalışma ve dinlenme '
          'sürelerini',
    ],
    correctIndex: 2,
    explanation: 'Green Book sefer kontrol defteridir — § 1 fıkra 6 FPersV '
        'uyarınca tutulan günlük kontrol formlarının toplamı. Yalnızca '
        'süreleri kanıtlar. Aracın durumu başka yerde belgelenir ve açıkça '
        'buraya ait değildir.',
  ),
  DrivingQuestion(
    moduleId: 'gb1',
    question: '§ 1 fıkra 6 FPersV uyarınca kayıt zorunluluğu hangi araçlar '
        'için geçerlidir?',
    options: [
      'Ticari yük taşımacılığında 2,8 t üzeri ile 3,5 t arası azami yüklü '
          'ağırlık',
      'Ticari olarak paket taşınan her araç için',
      'Ancak 3,5 t azami yüklü ağırlıktan itibaren',
    ],
    correctIndex: 0,
    explanation: 'Zorunluluk 2,8 t üzeri ile 3,5 t arasındaki aralıkta '
        'geçerlidir — tam olarak tipik dağıtım aracı. 2,8 t altında yoktur, '
        '3,5 t ve üzerinde kaydı dijital takograf üstlenir.',
  ),
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Aracının ruhsatına göre azami yüklü ağırlığı 3,5 t, ama bugün '
        'yalnızca 900 kg yüklü. Ne geçerlidir?',
    options: [
      'Kayıt zorunluluğu yok — fiilî ağırlık 2,8 t altında',
      'Kayıt zorunluluğu devam eder',
      'Zorunluluk ancak 100 kilometrelik günlük mesafeden itibaren geçerli',
    ],
    correctIndex: 1,
    explanation: 'Belirleyici olan ruhsattaki azami yüklü ağırlıktır, '
        'bugünkü yük ağırlığı değil. Akla ilk gelen yanılgı her gün yüke '
        'göre yeniden hesap yapmaktır — aracın sınıflandırması bununla '
        'değişmez.',
  ),

  // ══════════════════════════ gb2 — Tam olarak ne yazılır
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Hangi bilgi günlük kontrol formunun zorunlu bilgilerinden '
        'DEĞİLDİR?',
    options: [
      'Seferin başındaki ve sonundaki kilometre değeri',
      'Teslim edilen gönderi sayısı',
      'Seferin başlangıç ve bitiş yeri',
    ],
    correctIndex: 1,
    explanation: 'Öngörülenler arasında sürücünün soyadı, adı ve adresi, '
        'plaka, tarih, kilometre değerleri, yerler, süreler ve imza vardır. '
        'Adet sayıları işletmeye ait bir göstergedir ve formda yer almaz.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Günlük kontrol formunu neyle doldurursun?',
    options: [
      'Tükenmez kalemle, silinmez şekilde',
      'Kurşun kalemle, hatalar temiz düzeltilebilsin diye',
      'Yazı gereci fark etmez, okunabildiği sürece',
    ],
    correctIndex: 0,
    explanation: 'Silgiyle silinebilen bir kayıt kanıt değildir. Tam da bu '
        'yüzden kurşun kalem kabul edilmez — düzeltme iyi niyetli olsa '
        'bile. Hata bir kez çizilir ve yanına yeniden yazılır.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Tüm süreler ve kilometre değerleri yazılmış, yalnızca imza '
        'eksik. Bu form için ne geçerlidir?',
    options: [
      'Geçerlidir — imza sadece şeklî bir konudur',
      'Tamamlanmamış sayılır ve kayıt zorunluluğunu yerine getirmez',
      'Sevkiyat sorumlusu işletmede sonradan karşı imza atabilir',
    ],
    correctIndex: 1,
    explanation: 'İmza, öngörülen bilgilerden biridir — onunla içeriği '
        'onaylarsın. O olmadan form tamamlanmamıştır, eksik bir formla aynı '
        'sonuçları doğurur. Başkasının imzası seninkinin yerine geçmez.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Rampada 40 dakika bekliyorsun. Hiçbir şey yapmıyorsun, ama '
        'hemen devam edilebileceği için her an hazır olman gerekiyor. Bu '
        'süreyi nasıl yazarsın?',
    options: [
      'Sürüş molası olarak — sonuçta çalışmadın',
      'Günlük dinlenme süresinin başlangıcı olarak',
      'Çalışma süresi olarak',
    ],
    correctIndex: 2,
    explanation: 'Bir sürüş molası, ancak o süre üzerinde serbestçe '
        'tasarrufta bulunabiliyorsan ve bunu önceden biliyorsan moladır. '
        'Hazır beklemek bekleme süresidir, dolayısıyla çalışma süresidir. '
        'Akla ilk gelen yanılgı “hiçbir şey yapmadım, demek ki moladaydım” '
        'olur — belirleyici olan yaptığın iş değil, hazır bulunma '
        'zorunluluğudur.',
  ),

  // ══════════════════════════ gb3 — Süreler, molalar, dinlenme
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Normal bir günde en fazla ne kadar araç kullanabilirsin?',
    options: [
      '9 saat',
      '10 saat',
      '8 saat, sonrasında yalnızca sevkiyat sorumlusunun onayıyla',
    ],
    correctIndex: 0,
    explanation: 'Günlük sürüş süresi en fazla 9 saattir. 10 saat ikinci '
        'bir kural sınırı değil, dar sınırlı bir istisnadır — ve işletme '
        'onayının bu sınır için hiçbir önemi yoktur.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Sürüş süresini 10 saate ne sıklıkla uzatabilirsin?',
    options: [
      'Haftada bir kez',
      'Haftada iki kez',
      'Turun gerektirdiği her gün',
    ],
    correctIndex: 1,
    explanation: 'Günlük sürüş süresi haftada iki kez 10 saate '
        'uzatılabilir. Bu haftalık bir kontenjandır, günlük bir hak değil — '
        've turun büyüklüğü onu uzatmaz.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: '45 dakikalık sürüş molasını bölmek istiyorsun. Hangi bölme '
        'kabul edilir?',
    options: [
      'Önce 30 dakika, sonra 15 dakika',
      'Gün içine yayılmış üç kez 15 dakika',
      'Önce 15 dakika, sonra 30 dakika',
    ],
    correctIndex: 2,
    explanation: 'Bölme yalnızca iki parça hâlinde ve yalnızca bu sırayla '
        'kabul edilir: önce en az 15, sonra en az 30 dakika. Ters sıra '
        'sayılmaz, üç kısa parça da sayılmaz — toplam doğru olsa bile.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Saat 07:00’de başlıyorsun. 09:30’a kadar 2 saat direksiyon '
        'başındasın, 12:00’ye kadar 2 saat daha sürüş süresi ekleniyor, '
        '13:00’e kadar bir 30 dakika daha. Sürüş molası en geç ne zaman '
        'gerekir?',
    options: [
      'Saat 11:30’da, yani işe başlamadan 4,5 saat sonra',
      'Saat 12:00’de, çünkü öğle vakti bunun için öngörülmüştür',
      'Saat 13:00’te',
    ],
    correctIndex: 2,
    explanation: '2 + 2 + 0,5 saat, 13:00’te tam olarak 4,5 saat saf sürüş '
        'süresi eder — molayı tamamlamadan artık bir metre bile '
        'gidemezsin. Akla ilk gelen yanılgı işe başlamadan itibaren hesap '
        'yapmaktır: saat yalnızca araç hareket hâlindeyken işler.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Sürüş süresini saat 17:15’te bitiriyorsun. En erken ne zaman '
        'yeniden yola çıkabilirsin?',
    options: [
      'Saat 02:15’te — 9 saat dinlenme yeter',
      'Saat 04:15’te',
      'Kendini dinlenmiş hissettiğin an, sabit bir sınır yok',
    ],
    correctIndex: 1,
    explanation: 'Günlük dinlenme süresi en az 11 saattir, yani en erken '
        '04:15. 9 saat sürüş süresinin sınırıdır, dinlenmenin değil — bu '
        'iki sayı sık sık karıştırılır.',
  ),

  // ══════════════════════════ gb4 — Tipik hatalar
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Bir iş arkadaşın bütün haftanın formlarını cuma akşamı '
        'dolduruyor. Süreler içerik olarak doğru. Bu nasıl değerlendirilir?',
    options: [
      'Bu bir ihlaldir ve denetimde göze çarpar',
      'Yazılan süreler gerçeğe uyduğu sürece sorun değil',
      'Yalnızca bir düzen meselesi, hukuki bir anlamı yok',
    ],
    correctIndex: 0,
    explanation: 'Kayıt tutmak, zamanında kayıt tutmak demektir. Sonradan '
        'yazılmış formlar aynı el yazısından, dikkat çekecek kadar yuvarlak '
        'sürelerden ve güzergâha uymayan kilometre değerlerinden anlaşılır. '
        'Sürelerin doğru olması, kayıt zorunluluğunun ihlalini ortadan '
        'kaldırmaz.',
  ),
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Perşembe günü, salı günkü öğle molasının yazılmadığını fark '
        'ediyorsun. Saati kesin hatırlıyorsun. Ne yaparsın?',
    options: [
      'Ekleme tarihiyle sonradan yazma olarak yazarım ve sevkiyat '
          'sorumluma haber veririm',
      'Kaydı, salı günü yazılmış gibi görünecek şekilde araya sokarım',
      'Boşluğu bırakırım — sonradan yazmak durumu daha da kötüleştirir',
    ],
    correctIndex: 0,
    explanation: 'Dürüst ve fark edilir biçimde tarihlendirilmiş bir '
        'düzeltme yapılabilir ve boşluktan iyidir. Kaydı salı günü yazılmış '
        'gibi göstermek, ihmalden aldatmaya geçiştir — ve çok daha ağır '
        'basar.',
  ),
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Bugün 9,5 saat araç kullandın, oysa 10 saatlik haftalık '
        'kontenjanın çoktan tükenmişti. Ne yazarsın?',
    options: [
      'Tam 9,0 saat — form kurallara uygun görünsün diye',
      'Fiilen sürdüğün 9,5 saati',
      'Bu gün için hiçbir şey, o zaman göze çarpmaz',
    ],
    correctIndex: 1,
    explanation: 'Her zaman gerçek süreleri yazarsın. Güzelleştirilmiş bir '
        'kayıt, aşımı yanlış beyana dönüştürür ve durumu kötüleştirir. '
        'Eksik bir form da başlı başına ayrı bir ihlaldir — atlamak işe '
        'yaramaz.',
  ),

  // ══════════════════════════ gb5 — Bulundurma, teslim, saklama
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Araçta hangi kayıtları yanında bulundurman gerekir?',
    options: [
      'Yalnızca içinde bulunulan günün formunu',
      'İçinde bulunulan takvim haftasının formlarını',
      'İçinde bulunulan günü ve önceki 28 günü',
    ],
    correctIndex: 2,
    explanation: 'Yanında bulundurulması gerekenler, içinde bulunulan gün '
        'dâhil son 28 günün kayıtlarıdır. Eski formların işletmede düzgünce '
        'durması saklama yükümlülüğünü yerine getirir, ama yanında '
        'bulundurma yükümlülüğünü değil — bunlar ayrı iki yükümlülüktür.',
  ),
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'İşveren günlük kontrol formlarını işletmede ne kadar süre '
        'saklamak zorundadır?',
    options: [
      'Bir yıl',
      '28 gün, sonrasında imha edilebilirler',
      'Çeyrek dönem sonundan itibaren üç ay',
    ],
    correctIndex: 0,
    explanation: 'İşveren kayıtları bir yıl saklar ve istendiğinde ibraz '
        'eder. 28 gün, sürücünün yanında bulundurma süresidir — sık sık '
        'saklama süresiyle karıştırılır.',
  ),
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Kayıt zorunluluğuna uyulup uyulmadığını kim denetler?',
    options: [
      'Yalnızca polis, o da sadece yol denetimlerinde',
      'BAG ve polis — yol denetimlerinde ve işletmede',
      'Aracın muayenesi kapsamında TÜV',
    ],
    correctIndex: 1,
    explanation: 'Denetimi BAG (Bundesamt für Logistik und Mobilität, '
        'Federal Lojistik ve Hareketlilik Dairesi) ve polis yapar, hem yol '
        'kenarında hem de işletmede. Araç muayenesi aracın teknik durumunu '
        'ilgilendirir ve kayıtlarla ilgisi yoktur.',
  ),

  // ══════════════════════════ gb6 — Sonuçlar
  DrivingQuestion(
    moduleId: 'gb6',
    question: 'Formlar eksikse ya da tamamlanmamışsa neyle karşılaşılır?',
    options: [
      '100 avrodan başlayan, ağırlığa göre daha da yüksek bir para cezasıyla',
      'Hiçbir sonuçla — bu tamamen işletmeye ait bir kuraldır',
      'Başka sonucu olmayan ücretsiz bir uyarıyla',
    ],
    correctIndex: 0,
    explanation: 'Eksik ya da tamamlanmamış kayıtlar bir kabahattir; para '
        'cezası yaklaşık 100 avrodan başlar ve ağırlıkla birlikte yükselir. '
        'Ağır ya da tekrarlanan ihlallerde ayrıca işletmenin güvenilirliğine '
        'ilişkin bir işlem başlatılabilir.',
  ),
  DrivingQuestion(
    moduleId: 'gb6',
    question: 'Sevkiyat sorumlusu diyor ki: “Şu iki durağı da yap, molayı da '
        'öylece yazıver.” Nasıl tepki verirsin?',
    options: [
      'Talimata uyarım — sorumluluğu o zaman sevkiyat sorumlusu taşır',
      'Molayı vermem, ama en azından eksik olduğunu dürüstçe yazarım',
      'Molayı veririm, doğru yazarım ve kalan durakları bildiririm',
    ],
    correctIndex: 2,
    explanation: 'Sözlü bir talimat kayıt zorunluluğunu ortadan kaldırmaz — '
        'formu sen imzalar ve böylece içeriği onaylarsın. Molayı bilerek '
        'vermemek ayrıca sürüş süresi kurallarının da ihlali olurdu. '
        'İşletme kurallara uymayı mümkün kılmalıdır, onları atlatmamalıdır.',
  ),
];

// Dil seçimi ve bölümlere göre filtreleme, eğitimin veri katmanındadır —
// bkz. green_book_quiz_de.dart.
