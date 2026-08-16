// lib/data/safety_training/privacy_quiz_tr.dart
//
// Veri koruma eğitimi bitirme testinin soruları — Türkçe sürüm.
// privacy_quiz_de.dart dosyasının çevirisidir; yapı (soru sırası,
// seçenek sayısı, correctIndex değerleri) her zaman Almanca ana dosyayla
// eşzamanlı tutulmalıdır. On sekiz soru, privacy_content_tr.dart
// içindeki altı bölüme eşit dağıtılmış (ds1 … ds6, her bölüme üç soru).
//
// Soruların düzeyi: günlük teslimat işinden senaryolar ve hukuki sonuç
// soruları. Birden çok seçenek bilerek makul görünür — her seferinde bir
// ayrıntıya bağlıdır. `explanation` her zaman ikisini de açıklar: doğru
// cevap neden doğru ve akla gelen yanılgı neden yanlış.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> privacyQuestionsTr = [
  // ══════════════════════════ ds1 — Veri koruma seni neden ilgilendirir
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Aşağıdaki bilgilerden hangisi DSGVO (GDPR) anlamında '
        'kişisel veri DEĞİLDİR?',
    options: [
      'Bugün turda teslim edilen paketlerin toplam sayısı',
      'İlgili adresle birlikte “Paketi lütfen çöp konteynerinin arkasına '
          'bırakın” notu',
      'Bir alıcının kapısının önünde çekilen teslimat fotoğrafı',
    ],
    correctIndex: 0,
    explanation: 'Bir kişiyle bağlantısı olmayan salt bir adet sayısı '
        'kişisel veri değildir. Bırakma notu ise belirli bir insanın '
        'yaşam durumu hakkında bir şey söyler ve teslimat fotoğrafı bir '
        'adresle eşleştirilmiştir. Akla gelen yanılgı, yalnızca isimleri '
        'kişisel veri saymaktır — bir kişinin belirlenmesini sağlayan her '
        'bilgi kişisel veridir.',
  ),
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Akşam arkadaş ortamında, paketini teslim ettiğin tanınmış '
        'bir sporcunun hangi sokakta oturduğunu anlatıyorsun. Bu nasıl '
        'değerlendirilir?',
    options: [
      'İsmi internete koymadığın sürece sorunsuz',
      'Art. 5 DSGVO uyarınca amaçla sınırlılığın ve gizliliğin ihlali',
      'Bir adres zaten herkesçe bilindiği için sorunsuz',
    ],
    correctIndex: 1,
    explanation: 'Adresi yalnızca işinden biliyorsun. Onu üçüncü kişilere '
        'aktarmak amaç dışı bir açıklamadır ve Art. 5 Abs. 1 lit. b ile '
        'lit. f DSGVO’ya aykırıdır. Akla gelen yanılgı, küçük bir özel '
        'çevrenin sayılmadığıdır — DSGVO dinleyici kitlenin büyüklüğünü '
        'sormaz.',
  ),
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Şirketin seni veri koruma konusunda eğitmek zorunda olduğu '
        'hangi hükümlerden çıkar?',
    options: [
      '§ 12 Abs. 1 Arbeitsschutzgesetz’ten — veri koruma, yıllık iş '
          'güvenliği eğitiminin bir parçasıdır',
      'Art. 30 DSGVO’daki açık bir eğitim yükümlülüğünden',
      'Dolaylı olarak Art. 32, Art. 39 Abs. 1 lit. b ve Art. 5 Abs. 2 '
          'DSGVO’dan',
    ],
    correctIndex: 2,
    explanation: 'DSGVO açık bir eğitim yükümlülüğü içermez. Yükümlülük '
        'dolaylı olarak doğar: Art. 32 organizasyonel önlemler ister, '
        'Art. 39 Abs. 1 lit. b bilinçlendirme ve eğitimi veri koruma '
        'görevlisinin görevi olarak sayar ve Art. 5 Abs. 2 kurallara '
        'uyulduğunun kanıtlanmasını ister. Art. 30 ise işleme '
        'faaliyetleri kaydını düzenler ve ArbSchG iş güvenliğini '
        'düzenler, veri korumayı değil.',
  ),

  // ══════════════════════════ ds2 — Fotoğraflar ve teslimat kanıtları
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'Bir teslimat fotoğrafında ne görünebilir?',
    options: [
      'Çekime sözlü olarak onay verdiyse alıcı',
      'Bırakma yerindeki paket, konum referansı olarak kapı veya kapı '
          'numarası',
      'Daha iyi eşleştirme için paket ve önünde park eden aracın plakası',
    ],
    correctIndex: 1,
    explanation: 'Fotoğraf tam olarak tek bir soruyu yanıtlar: Paket '
        'nerede duruyor? Bunun ötesindeki her şey Art. 5 Abs. 1 lit. c '
        'DSGVO uyarınca veri minimizasyonuna aykırıdır. Kişiler sözlü '
        'onayla bile kanıtta yer almaz ve plaka, bu amaç için gerekli '
        'olmayan kişisel bir veridir.',
  ),
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'El terminali çalışmıyor. Bırakılan paketi normal telefon '
        'kamerasıyla fotoğraflıyor ve resmi sonra iş uygulamasına '
        'yüklüyorsun. Bunun nesi yanlış?',
    options: [
      'Hiçbir şey — önemli olan tek şey resmin sonunda uygulamada '
          'olmasıdır',
      'Yalnızca görüntü kalitesi, hukuken sakıncasızdır',
      'Resim sonrasında kalıcı olarak özel galeride, çoğu zaman ek '
          'olarak özel bir bulutta durur',
    ],
    correctIndex: 2,
    explanation: 'Yükleme kopyayı ortadan kaldırmaz: Orijinal özel '
        'galeride kalır ve çoğu zaman otomatik olarak bir buluta '
        'yedeklenir. Böylece kişisel veriler işletmenin kontrolü dışında '
        'durur. Akla gelen yanılgı, yalnızca son durumun saydığıdır — '
        'belirleyici olan, yol boyunca oluşan her kopyadır.',
  ),
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'Stopu tamamladıktan sonra, yüklenen fotoğrafta bir '
        'komşunun tanınabilir olduğunu fark ediyorsun. Ne yaparsın?',
    options: [
      'Resmin sistemden silinmesi için dispatcher’ı veya işletme '
          'yönetimini bilgilendirmek',
      'Hiçbir şey — stop tamamlandı, resim zaten artık değiştirilemez',
      'Ertesi gün komşunun kapısını çalıp izin istemek',
    ],
    correctIndex: 0,
    explanation: 'İşletme ancak bundan haberdar olursa resmi silebilir '
        've olayı belgeleyebilir. Akla gelen yanılgı, stop '
        'tamamlandıktan sonra bildirimin artık anlamı olmadığıdır. '
        'Sonradan alınan bir onay ihlali ortadan kaldırmaz ve iş '
        'bağlamında zaten sağlam bir hukuki dayanak değildir.',
  ),

  // ══════════════════════════ ds3 — Alıcı verileriyle çalışma
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Sırayı daha iyi aklında tutabilmek için adres listesinin '
        'ekran görüntüsünü alıyorsun. Başka kimse görmüyor. Bu caiz mi?',
    options: [
      'Evet, ekran görüntüsünü turun sonunda tekrar sildiğin sürece',
      'Evet, çünkü verileri zaten iş gereği işlemene izin var',
      'Hayır — ekran görüntüsü sistemin dışında bir kopyadır ve bu '
          'yüzden caiz değildir',
    ],
    correctIndex: 2,
    explanation: 'Ekran görüntüsüyle, işletmenin artık kontrol edemediği '
        'bir kişisel veri kopyası oluşur. Verileri iş gereği görebiliyor '
        'olman, onları sistemin dışında saklamana izin vermez. Sonradan '
        'silme niyeti de izinsiz işlemeyi değiştirmez.',
  ),
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Bir komşu paketi teslim alıyor ve içinde ne olduğunu, '
        'alıcının hala orada oturup oturmadığını soruyor. Ne söylersin?',
    options: [
      'Yalnızca alıcı adı ve kapı numarası — içerik ve diğer bilgiler '
          'hakkında bilgi yok',
      'Etikette yazan her şeyi, çünkü paketi o teslim alıyor',
      'Hiçbir şey, alıcının adını bile söylemem',
    ],
    correctIndex: 0,
    explanation: 'Komşuya teslimat için isim ve kapı numarası gereklidir '
        '— onlarsız komşu paketi iletemez. Bunun ötesindeki her şey, '
        'özellikle içerik veya ikamet durumunun doğrulanması, Art. 6 '
        'DSGVO uyarınca hukuki dayanağı olmayan bir açıklamadır. Hiçbir '
        'şey söylememek ise pratikten uzak olur ve teslimat böyle '
        'yapılamaz.',
  ),
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Tur bitti, kağıt tur listesi artık gerekmiyor. Onu nasıl '
        'doğru imha edersin?',
    options: [
      'Eve varır varmaz oturduğun binanın kağıt konteynerinde',
      'İşletmede öngörülen yolla — veri koruma konteyneri veya evrak '
          'imha makinesi',
      'Kimse okuyamasın diye yırtıp benzin istasyonundaki çöpe atarak',
    ],
    correctIndex: 1,
    explanation: 'Listede isimler ve adresler var; geri getirilemeyecek '
        'şekilde imha edilmesi gerekir — işletmede veri koruma '
        'konteyneri veya evrak imha makinesi üzerinden. Akla gelen '
        'yanılgı, işi biten bir listenin değersiz olduğudur. Herkesin '
        'erişebildiği çöp kutuları devre dışıdır ve listeyi zaten eve '
        'götürmemen gerekirdi.',
  ),

  // ══════════════════════════ ds4 — Kendi verilerin ve meslektaş verileri
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Bir meslektaşın, üzerinde bütün sürücülerin isim ve '
        'değerleriyle yer aldığı iç bir değerlendirmenin ekran '
        'görüntüsünü rica ediyor. Sadece kendi satırını görmek istiyor. '
        'Nasıl davranırsın?',
    options: [
      'Reddedip onu işletme yönetimine yönlendiririm — yalnızca kendi '
          'verileri üzerinde hakkı var',
      'Gönderirim, çünkü listede kendisi de var ve bu yüzden erişim '
          'yetkisi var',
      'Gönderirim, ama önce diğerlerinin isimlerini karartır, sonra '
          'ekran görüntüsünü silerim',
    ],
    correctIndex: 0,
    explanation: 'Ekran görüntüsüyle bütün meslektaşların performans '
        'verilerini almış olurdu — hukuki dayanak olmadan çalışan verisi '
        'aktarımı. Art. 15 DSGVO uyarınca bilgi edinme hakkı yalnızca '
        'kendi verilerini kapsar. Kendi elinle yaptığın bir karartma da '
        'izinsiz bir kopya oluşturduğun gerçeğini değiştirmez.',
  ),
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Meslektaşların hastalık bildirimleri neden özellikle '
        'korunur?',
    options: [
      'Çünkü iş sözleşmesinde açıkça gizli olarak nitelendirilirler',
      'Çünkü GeschGehG kapsamında işletme sırlarıdır',
      'Çünkü sağlık verileri Art. 9 DSGVO uyarınca özel kategori '
          'kişisel verilerdir',
    ],
    correctIndex: 2,
    explanation: 'Sağlık verileri Art. 9 DSGVO kapsamındadır ve sıradan '
        'verilerden daha sıkı bir korumaya tabidir. Hasta olma gerçeği '
        'bile böyle bir veridir, nedeni ise daha da fazlası. İşletme '
        'sırları ise şirket bilgisiyle ilgilidir, çalışanların sağlık '
        'verileriyle değil.',
  ),
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'İşverenin hakkında hangi verileri sakladığını öğrenmek '
        'istiyorsun. Bunun için hangi hakkı kullanırsın?',
    options: [
      'Art. 20 DSGVO uyarınca veri taşınabilirliği hakkını',
      'Art. 15 DSGVO uyarınca bilgi edinme hakkını',
      'Art. 21 DSGVO uyarınca itiraz hakkını',
    ],
    correctIndex: 1,
    explanation: 'Art. 15 DSGVO sana, hakkında saklanan verilerin ve '
        'amaçların bir özetini talep etme hakkı verir. Art. 20 verilerin '
        'taşınabilir bir formatta verilmesini, Art. 21 bir işlemeye '
        'itirazı düzenler — ikisi de neyin saklandığı sorusunu '
        'yanıtlamaz. Talebin kural olarak bir ay içinde yanıtlanması '
        'gerekir.',
  ),

  // ══════════════════════════ ds5 — Veri ihlali
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Bu olaylardan hangisi veri ihlali DEĞİLDİR?',
    options: [
      'Bir paketi yanlış alıcıya verdin ve o paketi açtı',
      'Günlük raporda iade sayısını yanlış saydın',
      'Tur listesini kilitlenmemiş araçta açıkta bıraktın',
    ],
    correctIndex: 1,
    explanation: 'İadelerdeki bir sayım hatası kişisel verileri '
        'ilgilendirmez ve onları kimsenin erişimine açmaz. Diğer iki '
        'durumda ise yetkisiz kişiler isimleri, adresleri veya gönderi '
        'içeriklerini öğrenebilmiştir — bu, kişisel verilerin '
        'korunmasının ihlalidir.',
  ),
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Art. 33 DSGVO’daki 72 saatlik süre ne anlama gelir?',
    options: [
      'Şirket bir veri ihlalini öğrendikten sonra mümkünse 72 saat '
          'içinde denetim makamına bildirmelidir',
      'Sürücünün olayı işletmeye bildirmek için 72 saati vardır',
      'İlgili kişiler 72 saat içinde şirkete şikayette bulunmalıdır, '
          'yoksa hakları düşer',
    ],
    correctIndex: 0,
    explanation: 'Süre, şirketi denetim makamına karşı bağlar ve '
        'öğrenme anından itibaren işler. Tam da bu yüzden hemen '
        'bildirmelisin — beklediğin her saat işletmeden eksilir. Akla '
        'gelen yanılgı, 72 saati sürücünün kendi zaman aralığı olarak '
        'okumaktır.',
  ),
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Akşam, bir paketin yanlış alıcıya gittiğini ve orada '
        'açıldığını fark ettin. Doğru olan nedir?',
    options: [
      'Yarın sabah sessizce alıp doğru adrese teslim etmek — böylece '
          'hata giderilmiş olur',
      'Zaten değiştirilebilecek bir şey olmadığı için ancak bir sonraki '
          'iş görüşmesinde söz etmek',
      'Aynı gün içinde dispatcher’ı veya işletme yönetimini '
          'bilgilendirmek ve kendi başına hiçbir girişimde bulunmamak',
    ],
    correctIndex: 2,
    explanation: 'Veri ihlali zaten gerçekleşti: Yabancı bir kişi ismi, '
        'adresi ve gönderi içeriğini öğrendi. İşletme değerlendirmeli, '
        'belgelemeli ve gerekirse Art. 33 DSGVO uyarınca bildirmelidir — '
        'bunun için bilgiye hemen ihtiyacı var. Sessiz düzeltme zararsız '
        'görünür ama tam olarak bu adımları engeller. Hemen bildiren '
        'doğru davranır.',
  ),

  // ══════════════════════════ ds6 — Sır saklama ve sadakat
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'Hangi söz ifade özgürlüğü kapsamında DEĞİLDİR?',
    options: [
      'Bir turun düzenli olarak planlanan sürede yetişilemediği sözü',
      'Bir aracın defalarca bildirilmesine rağmen onarılmadığı uyarısı',
      'Şirketin sürücülerini saatlerde sistematik olarak dolandırdığı '
          'yönündeki bilerek gerçek dışı iddia',
    ],
    correctIndex: 2,
    explanation: 'Görüş açıklamaları ve gerçeğe uygun eleştiri, rahatsız '
        'edici olsa da Art. 5 Abs. 1 GG ile korunur. Bilerek gerçek '
        'dışı olgu iddiaları korunmaz: § 626 BGB uyarınca derhal fesih '
        'gerekçesi olabilir ve kötüleme halinde ayrıca § 186 StGB '
        'uyarınca cezalandırılabilir.',
  ),
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'İşletmedeki bir aksaklığı bildiğin kadarıyla doğru '
        'biçimde bildiriyorsun. Sonunda şüphenin yerinde olmadığı ortaya '
        'çıkıyor. Ne geçerlidir?',
    options: [
      'Bildirim yanlış olduğu için koruma geriye dönük olarak düşer',
      'İhbarcıları koruma yasası sayesinde misillemeye karşı korunmaya '
          'devam edersin',
      'Koruma yalnızca bildirimi ek olarak dış bir mercie de yaptıysan '
          'geçerlidir',
    ],
    correctIndex: 1,
    explanation: 'HinSchG (2 Temmuz 2023’ten beri), ihlal bildiren '
        'çalışanları işten çıkarma, ihtar veya dezavantajlı konuma '
        'düşürme gibi misillemelere karşı korur. Koruma yalnızca '
        'bilerek veya ağır ihmalle yapılan yanlış bildirimlerde düşer — '
        'sonunda doğrulanmayan ciddi bir şüphede değil. Bunun için dış '
        'bir bildirim gerekli değildir.',
  ),
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'Sürücü sohbet grubunda sözde maaş kesintileri '
        'tartışılıyor. Sen de memnun değilsin. Doğru yol nedir?',
    options: [
      'Kendi somut durumunu anlatmak ve onu dispatcher’a, işletme '
          'yönetimine veya iç bildirim merciine iletmek',
      'Meslektaşlar uyarılmış olsun diye iddiayı grupta doğrulamak',
      'Bir şeyler değişsin diye suçlamayı bir değerlendirme portalında '
          'herkese açık paylaşmak',
    ],
    correctIndex: 0,
    explanation: 'Kendi doğrulanabilir durumun gerçektir, nesneldir ve '
        'HinSchG ile korunur — üstelik içeride en hızlı çözülebilecek '
        'olandır. Kendin yaşamadığın bir iddiayı doğrulamak gerçek dışı '
        'bir olgu iddiasıdır; kapalı bir sohbet grubu, bir ekran '
        'görüntüsü dolaşmaya başladığı anda korunaklı bir alan değildir. '
        'Dışarıya gitmek ancak içeride hiçbir şey olmazsa gündeme '
        'gelir.',
  ),
];
