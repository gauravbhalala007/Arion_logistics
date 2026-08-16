// lib/data/safety_training/driving_safety_quiz_tr.dart
//
// DSP sürüş güvenliği eğitiminin soruları — Türkçe sürüm.
// Modül testleri ve final sınavı. Sıralama, modül ataması ve doğru
// cevaplar Almanca ana sürümle birebir aynıdır.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> drivingQuestionsTr = [
  // ══════════════════════════════════ M1 — Güvenlik kültürü
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Plandan 20 durak gerisin. Hangi tepki işletmedeki '
        'güvenlik kültürüne uygundur?',
    options: [
      'Duraklar arasında daha hızlı sürmek, ama durakların kendisinde '
          'özenli kalmak',
      'Gecikmeyi bildirmek ve tura alışılmış güvenli tempoda devam '
          'etmek',
      'Manevradaki kontrol sürelerini kısaltmak, ama sürüş tarzını '
          'değiştirmemek',
    ],
    correctIndex: 1,
    explanation: 'Zaman baskısı bir planlama sorunudur ve bildirilir, '
        'direksiyonda telafi edilmez. Diğer iki cevap uzlaşma gibi '
        'duruyor ama riski sadece kaydırıyor: duraklar arasında daha '
        'yüksek hız tam da duruş mesafesini uzatır ve kısaltılmış '
        'manevra kontrolleri, tüm hasarların % 70\'inin oluştuğu işi '
        'etkiler.',
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Sevkiyat sorumlun sana bozuk bir fren lambasıyla yola '
        'çıkmanı söylüyor. Bu yüzden bir arkadan çarpma olursa '
        'sorumluluğu kim taşır?',
    options: [
      'Sevkiyat sorumlusu, çünkü talimatı o verdi',
      'İşletme, çünkü aracı o sağlıyor',
      'Hiç kimse — tek bir fren lambası güvenlik açısından önemli bir '
          'arıza değildir',
      'Araç sürücüsü olarak sen',
    ],
    correctIndex: 3,
    explanation: 'Araç sürücüsü olarak kullandığın aracın trafiğe '
        'elverişli durumundan sen sorumlusun — sözlü bir talimat bunu '
        'ortadan kaldırmaz. Aracı işletmenin sağlaması akla yatkın '
        'geliyor ama seni aklamıyor: para cezası ve ceza puanları '
        'kişisel olarak seni bulur. Doğrusu arızayı bildirmek ve başka '
        'bir araç istemektir.',
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Manevrada bir babaya sadece birkaç santimetre kalmıştı — '
        'bir şey olmadı. Doğrusu nedir?',
    options: [
      'Ramak kala olay olarak bildirmek',
      'Hiçbir şey yapmamak, sonuçta hasar oluşmadı ve kimse tehlikeye '
          'girmedi',
      'Yalnızca bir meslektaş ya da bir kamera görmüşse bildirmek',
    ],
    correctIndex: 0,
    explanation: 'Ramak kala bir olay, bir tehlike noktasını daha '
        'kimseye zarar vermeden gösterir — bildirilirse bir sonraki '
        'meslektaş için etkisiz hâle gelir. “Hasar yok, konu yok” '
        'düşüncesi, aynı noktanın haftalar sonra yine de hasara yol '
        'açmasının en sık nedenidir.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Tüm panelvan hasarlarının yaklaşık % 70\'i hangi işte '
        'oluşur?',
    options: [
      'Otoyolda ve şehirler arası yolda yüksek hızda',
      'Şehir trafiğinde kavşaklarda dönerken',
      'Manevra ve geri gidiş sırasında',
    ],
    correctIndex: 2,
    explanation: 'Hasarların büyük çoğunluğu manevrada yürüme hızında '
        'oluşur. Yüksek hız en ağır kazalara yol açar ama en çok '
        'hasara değil — tam da bu karıştırma, manevrada yeterince '
        'dikkat edilmemesine yol açar.',
  ),

  // ══════════════════════════════════ M2 — Araç kontrolü ve yük
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Yük, kabul görmüş teknik kurallara göre öne doğru 0,8 g '
        'kuvvete karşı emniyete alınmalıdır. 20 kg\'lık bir pakette bu '
        'yaklaşık hangi tutma kuvvetine karşılık gelir?',
    options: [
      'yaklaşık 2 kg',
      'yaklaşık 8 kg',
      'yaklaşık 16 kg',
      'yaklaşık 200 kg',
    ],
    correctIndex: 2,
    explanation: '0,8 × 20 kg yaklaşık 16 kg tutma kuvveti eder. '
        '“Yaklaşık 2 kg” kuvveti fena hâlde küçümser ve paketlerin '
        'zararsız sanılmasının sebebidir; “200 kg” ise emniyet '
        'gereksinimini, gerçek bir çarpışmadaki ve aslında bunun çok '
        'üzerinde olan çarpma şiddetiyle karıştırır.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Yük bölümünü doğru şekilde nasıl yüklersin?',
    options: [
      'Ağır olan aşağı ve öne bölme duvarına, ağırlık eşit dağıtılmış',
      'Ağır olan yukarı, ki ağır paketler alırken hafiflerin altında '
          'kalmasın',
      'Ağır olan arkaya kapıya, ki ağır gönderiler önce çıksın',
    ],
    correctIndex: 0,
    explanation: 'Ağır + alçak + önde, ağırlık merkezini düşük ve '
        'kütleyi bölme duvarının karşılayabileceği yerde tutar. Diğer '
        'iki seçenek fizik değil, iş akışı düşünülerek kurulmuştur: '
        'yukarıdaki ağırlık devrilme eğilimini artırır, arkadaki '
        'ağırlık ön aksı boşaltır ve direksiyonu kötüleştirir.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Turun üçte ikisinden sonra yük bölümü yarı boş. Yük '
        'emniyeti için şimdi ne geçerlidir?',
    options: [
      'Daha az önemlidir, çünkü araçta belirgin biçimde daha az ağırlık '
          'var',
      'Yeniden kurulmalıdır — kalan paketlerin artık hız almak için '
          'daha çok yolu var',
      'Değişmeden geçerlidir, yapılacak bir şey yok',
    ],
    correctIndex: 1,
    explanation: 'Yük bölümü ne kadar boşsa, bir paketin çarpmadan önce '
        'hızlanabileceği mesafe o kadar uzundur. “Daha az ağırlık, daha '
        'az tehlike” mantıklı geliyor ama yanlış: belirleyici olan '
        'toplam kütle değil, emniyete alınmamış tek pakettir.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'DGUV Vorschrift 70 (Fahrzeuge) iş vardiyası başlamadan '
        'önce senden ne ister?',
    options: [
      'Lift ve fren test cihazıyla teknik bir muayene',
      'Aracın gözle görülür arızalar açısından kontrolü',
      'Yalnızca ilk kez kullandığın araçlarda bir kontrol',
    ],
    correctIndex: 1,
    explanation: 'İstenen, vardiya öncesi göze çarpan arıza kontrolüdür '
        '— tam da araç turunun yaptığı şey. Teknik muayene servisin '
        'işidir ve senin araç turunun yerini tutmaz; ayrıca bu '
        'yükümlülük yalnızca tanımadığın araçlar için değil, her gün '
        'her araç için geçerlidir.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Kanun asgari hangi diş derinliğini şart koşuyor — ve '
        'ıslak yolda ne mantıklıdır?',
    options: [
      'Yasal 3 mm; ıslakta o zaman 1,6 mm yeter',
      'Yasal 1,6 mm; bu ıslakta da aynen yeterlidir',
      'Yasal 4 mm, yıl boyunca bütün lastikler için',
      'Yasal 1,6 mm; ıslakta en az 3 mm mantıklıdır',
    ],
    correctIndex: 3,
    explanation: 'Yasal asgari 1,6 mm\'dir, ıslakta pratikte en az 3 mm '
        'mantıklıdır. “1,6 mm ıslakta da yeter” cevabı klasik yanılgıdır: '
        'asgari değer kabahatin sınırıdır, güvenliğin sınırı değil — '
        '1,6 mm\'de lastik neredeyse hiç su atamaz.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Çabuk alabilmek için bir sonraki durak yolcu koltuğunda '
        'duruyor. Bunun asıl sorunu nedir?',
    options: [
      'Paket bir fren sırasında mermiye dönüşür ve fren pedalının '
          'altına girebilir',
      'Bir trafik denetiminde düzensiz görünür',
      'Paket 10 kg\'dan hafif olduğu sürece buna izin verilir',
    ],
    correctIndex: 0,
    explanation: 'Sürücü kabinindeki her şey bir frende senin ilk '
        'hızınla hareketine devam eder — en kötü durumda ayak '
        'boşluğunda pedalın altına. Bunun için bir ağırlık sınırı '
        'yoktur: hafif bir paket de bir pedalı bloke eder.',
  ),

  // ══════════════════════════════════ M3 — Defansif sürüş
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Şehir dışında kuru yolda 80 km/sa gidiyorsun. Öndeki '
        'araca asgari hangi mesafe doğrudur?',
    options: [
      'Yaklaşık 20 metre — bu üç araç boyuna karşılık gelir',
      'Yaklaşık 45 metre — kabaca iki saniye ya da hız göstergesindeki '
          'değerin yarısı',
      'Yaklaşık 10 metre, dikkatli olduğun ve yol boş olduğu sürece',
    ],
    correctIndex: 1,
    explanation: 'İki saniye 80 km/sa hızda yaklaşık 45 metreye, hız '
        'göstergesindeki değerin yarısı 40 metreye karşılık gelir — '
        'ikisi birbiriyle uyumludur. 20 metre yolda çok görünür ama 24 '
        'metrelik salt tepki yolunun altındadır: fren tutmadan çarpmış '
        'olurdun.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Pratik formüllere göre 50 km/sa hızda duruş mesafesi ne '
        'kadardır (normal fren)?',
    options: [
      '15 metre',
      '25 metre',
      '40 metre',
      '65 metre',
    ],
    correctIndex: 2,
    explanation: 'Tepki yolu (50 ÷ 10) × 3 = 15 m artı fren mesafesi '
        '(50 ÷ 10)² = 25 m, toplam 40 m eder. 25 metre diyen yalnızca '
        'fren mesafesini hesaplamış ve tepki yolunu unutmuştur — en sık '
        'yapılan hesap hatası budur ve tam da yolun tam hızla aldığın '
        'bölümüdür.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Tepki yolunu pratik formüle göre nasıl hesaplarsın?',
    options: [
      '(Hız ÷ 10) × 3',
      '(Hız ÷ 10) × (Hız ÷ 10)',
      'Hız ÷ 2',
    ],
    correctIndex: 0,
    explanation: 'Tepki yolu (km/sa ÷ 10) × 3\'tür. İkinci formül fren '
        'mesafesi, üçüncüsü ise güvenli takip mesafesinin pratik '
        'değeridir — ikisi de benzer görünür ama tamamen başka şeyleri '
        'anlatır.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Hızını 30\'dan 60 km/sa\'ya iki katına çıkarıyorsun. '
        'Salt fren mesafesi nasıl değişir?',
    options: [
      'İki katına çıkar',
      'Dört katına çıkar',
      'Üç katına çıkar',
      'Neredeyse aynı kalır, çünkü fren yüksek hızda daha güçlü tutar',
    ],
    correctIndex: 1,
    explanation: 'Fren mesafesi hızın karesiyle büyür: 9 metre 36 metre '
        'olur. Akla yatkın gelen “iki katına çıkar” cevabı tam da bunu '
        'küçümser — yerleşim yolunda 20 km/sa fazlanın neden zararsız '
        'sanıldığını da o açıklar.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Tam yüklü bir panelvanla virajlara neden bir otomobile '
        'göre belirgin biçimde daha yavaş girmelisin?',
    options: [
      'Çünkü yüksek ağırlık merkezi devrilme eğilimini çok artırır',
      'Çünkü yükle birlikte direksiyon daha az hassas olur',
      'Çünkü lastikler yük altında yumuşar ve daha çok tutar',
    ],
    correctIndex: 0,
    explanation: 'Yüksek yüklü bir kapalı kasa araç, bir otomobilin '
        'hâlâ kaydığı yerde devrilir — ve bunu neredeyse hiç belli '
        'etmez. Direksiyon hassasiyeti de değişir ama asıl risk o '
        'değildir: devrilme aniden olur ve yolun dışında biter.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Işıklarda sağa dönmek istiyorsun, sağında bir bisikletli '
        'duruyor. Işık yeşile dönüyor. Önce ne yaparsın?',
    options: [
      'Bisikletli hızlanmadan hemen kalkıp dönmek',
      'Sağ dış aynaya bakıp sonra direksiyonu kırmak',
      'Sağa omuz üstü bakıp bisikletliyi geçirmek',
    ],
    correctIndex: 2,
    explanation: 'Hareket edip direksiyonu kırdığın anda bisikletli kör '
        'noktaya girer — üstelik aracının arkası da onun şeridine doğru '
        'savrulur. Aynaya bakmak doğru geliyor ama tam da iş '
        'ciddileştiğinde yetmez: ayna, sürücü kabininin sağ yanındaki '
        'bölgeyi tam olarak göstermez.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Şehir içinde bir bisikletliyi geçerken asgari hangi yan '
        'mesafeyi bırakmalısın?',
    options: [
      '1,0 metre',
      '1,5 metre',
      '2,0 metre',
    ],
    correctIndex: 1,
    explanation: 'Şehir içinde 1,5 metre, şehir dışında 2,0 metredir. '
        '2,0 metreyi şehir içi değer sanan ikisini karıştırır — ve 1,0 '
        'metreyle geçen asgari mesafenin altına iner ve bisikletli '
        'düşerse sorumlu olur.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Sürerken bakışın ne kadar ileriye yönelmiş olmalı?',
    options: [
      'Öndeki aracın tamponuna, ki fren yaptığını hemen göresin',
      'Kendi kaputuna, çünkü şeridi en iyi böyle tutarsın',
      '12–15 saniye ileriye',
    ],
    correctIndex: 2,
    explanation: 'Uzağa bakmak sana zaman kazandırır: trafik ışıklarını, '
        'fren lambalarını ve yayaları tepki vermek zorunda kalmadan '
        'önce görürsün. Tampona bakmak dikkatli hissettirir ama seni '
        'salt tepki verene çevirir — tehlikeyi ancak öndeki fren '
        'yaptığında öğrenirsin.',
  ),

  // ══════════════════════════════════ M4 — Geri gitme ve manevra
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Geri giderken GOAL neyin kısaltmasıdır?',
    options: [
      '“Get Out And Look” — dur, in, aracın arkasına bak',
      '“Go Only At Low speed” — yalnızca yürüme hızında geri gitmek',
      '“Guide On A Line” — yerdeki bir çizgiye göre yön bulmak',
    ],
    correctIndex: 0,
    explanation: 'GOAL, inip bakmak demektir — koltuktan asla '
        'göremeyeceğin alçak babaları, eğimi ve çocukları ortaya '
        'çıkarır. Yürüme hızı da zorunludur ama bakmanın yerini tutmaz: '
        'yürüme hızında da göremediğin bir alana giriyorsun.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Aracında geri görüş kamerası var. Bu GOAL açısından neyi '
        'değiştirir?',
    options: [
      'GOAL gerekmez, çünkü kamera aracın arkasındaki alanı gösterir',
      'Hiçbir şeyi',
      'GOAL artık yalnızca karanlıkta ve kötü görüşte gerekir',
    ],
    correctIndex: 1,
    explanation: 'Kamera yalnızca bir kesit gösterir, mesafeleri '
        'çarpıtır ve yağmurda, karda, çamurda kör olur — hepsinden '
        'önemlisi yandan senin yoluna gireni görmez. GOAL\'ı tamamlar, '
        'asla onun yerini tutmaz.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Bir yönlendirici nerede doğru durur?',
    options: [
      'Doğrudan aracın arkasında, çünkü mesafeyi en iyi oradan '
          'değerlendirebilir',
      'Aracın önünde, aynı anda trafiği de durdurabilmek için',
      'Yanda, onu sürekli aynada görebileceğin şekilde',
    ],
    correctIndex: 2,
    explanation: 'Yalnızca yanda ve sürekli görünür duran biri güvenli '
        'yönlendirebilir. Doğrudan aracın arkasındaki konum olayın en '
        'yakınıymış gibi görünse de, gözden kaybettiğin anda '
        'yönlendiricinin kendisinin ezildiği alan tam olarak orasıdır.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Yönlendiricini aynada aniden göremez oluyorsun. Ne '
        'yaparsın?',
    options: [
      'O yeniden görünene kadar daha yavaş devam etmek',
      'Hemen durmak',
      'Kısaca korna çalıp devam etmek, ki yeniden görünsün',
    ],
    correctIndex: 1,
    explanation: 'Görüş teması yoksa geçerli işaret de yoktur — yani '
        'yavaşlamak değil, durmak gerekir. “Daha yavaş devam etmek” '
        'temkinli geliyor ama artık kimsenin senin için gözlemediği bir '
        'alana girmeye devam ettiğin anlamına gelir.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: '§ 9 Abs. 5 StVO geri giderken ne ister?',
    options: [
      'Dörtlü flaşörün yakılmasını',
      'En fazla yürüme hızında gidilmesini',
      'Başkalarının tehlikeye girmesinin dışlanmasını — gerekirse '
          'yönlendiriciyle',
    ],
    correctIndex: 2,
    explanation: 'Kural, gerekirse bir yönlendirici aracılığıyla her '
        'türlü tehlikenin dışlanmasını ister — yani ölçüt belirli bir '
        'hız değil, sonuçtur. Yürüme hızı ve dörtlü flaşör iyi '
        'uygulamalardır ama tek başlarına bu yükümlülüğü karşılamaz.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Son durak dar bir iç avluda: içeri ileri girebiliyorsun, '
        'çıkış ise sadece bir duvarın yanından geri geri. En güvenli '
        'karar nedir?',
    options: [
      'Sokakta durup son metreleri yürüyerek ya da el arabasıyla '
          'gitmek',
      'İleri girmek, çünkü o zaman dönüş için girişi zaten tanımış '
          'olursun',
      'Yol hâlâ boşken hızlıca geri geri içeri girmek',
    ],
    correctIndex: 0,
    explanation: 'En güvenli geri manevra, hiç yapılmayandır. Girişi '
        '“içeri girdikten sonra tanımak” bir yanılgıdır: çıkarken '
        'kritik noktalar arkanda kalır ve bekleyen trafik ayrıca baskı '
        'yaratır.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M5 — Hava ve görüş
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Direksiyon aniden hafifliyor, lastikler bir su filminin '
        'üzerinde yüzüyor. Ne yaparsın?',
    options: [
      'Sert fren yapıp karşı direksiyon kırmak',
      'Gazı kesmek, direksiyonu sakin biçimde düz tutmak, aracı '
          'serbest bırakmak',
      'Su birikintisinden çabuk çıkmak için hızlanmak',
    ],
    correctIndex: 1,
    explanation: 'Su filmi aracı taşıdığı sürece fren ve direksiyon etki '
        'etmez — ancak lastik yeniden tuttuğunda bir anda etki eder ve '
        'savrulma tam olarak buradan doğar. Fren yapıp karşı direksiyon '
        'kırmak içgüdüsel ama yanlış tepkidir.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Su kızaklaması tehlikesi en çok neye bağlıdır?',
    options: [
      'Yükün ağırlığına',
      'Aracın yaşına ve fren sistemine',
      'Diş derinliğine, su yüksekliğine ve hepsinden çok hıza',
    ],
    correctIndex: 2,
    explanation: 'Tehlike hızla orantısız biçimde artar ve diş '
        'derinliğiyle azalır — diş, suyu lastiğin önünden uzaklaştırmak '
        'zorundadır. Yükün rolü ikincildir: fazla ağırlık lastiği yola '
        'daha çok bastırır ama sığ bir dişin hızda artık su atamadığı '
        'gerçeğini değiştirmez.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Siste yaklaşık 40 metre ileriyi görebiliyorsun. En fazla '
        'ne kadar hızlı gidebilirsin?',
    options: [
      'En fazla 40 km/sa',
      'Işıklar yanık olduğu sürece izin verilen azami hıza kadar',
      'Arka sis lambası yanıksa en fazla 80 km/sa',
    ],
    correctIndex: 0,
    explanation: 'Pratik kural: metre cinsinden görüş mesafesi, km/sa '
        'cinsinden üst sınırındır — 40 metre görüşte yani 40 km/sa. '
        'Işıklar ve arka sis lambası seni daha görünür kılar ama görüş '
        'mesafeni ve dolayısıyla izin verilen hızı uzatmaz.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: '§ 2 Abs. 3a StVO kışa uygun lastikleri ne zaman şart '
        'koşuyor?',
    options: [
      'Havadan bağımsız olarak, her zaman ekim ile Paskalya arasında',
      'Buzlanmada, kar kayganlığında, sulu karda, buz ya da kırağı '
          'kayganlığında',
      'Yalnızca yolda kapalı bir kar örtüsü varsa',
    ],
    correctIndex: 1,
    explanation: 'Almanya\'da duruma bağlı bir zorunluluk geçerlidir: '
        'takvime değil, yol durumuna bağlıdır. “Ekim ile Paskalya '
        'arası” yalnızca lastik değişimi için pratik bir hatırlatmadır, '
        'hukuki bir dayanak değil — ve sulu kar zaten yeterlidir, '
        'kapalı bir örtü olması gerekmez.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Hava buz gibi ve zaman baskısı altındasın. Ön camın '
        'sadece sürücü tarafını kazıyorsun. Ne geçerlidir?',
    options: [
      'Belirgin biçimde daha yavaş sürdüğün sürece izin verilir',
      'Kalanını kalorifer sürüş sırasında açacaksa izin verilir',
      'İzin verilmez — bütün camlar, aynalar, lambalar ve plaka açık '
          'olmalıdır',
    ],
    correctIndex: 2,
    explanation: 'Kazınarak açılan “gözetleme deliği” bir kabahattir ve '
        'kaza hâlinde ağır bir kusur isnadıdır. Kaloriferin sonradan '
        'açması bir istisna değildir: belirleyici olan yola çıkarkenki '
        'durumdur, üç dakika sonrası değil.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'BOŞ bir kapalı kasa araç fırtınada neden özellikle '
        'risk altındadır?',
    options: [
      'Çünkü onu yolda tutan yük ağırlığı yoktur',
      'Çünkü yüksüzken hava direnci daha büyüktür',
      'Çünkü boş hâlde lastik basıncı daha yüksektir',
    ],
    correctIndex: 0,
    explanation: 'Rüzgâra maruz yüzey boşken de yüklüyken de aynı '
        'büyüklüktedir, ama kütle belirgin biçimde küçüktür — aynı '
        'hamle aracı daha çok savurur. İçerideki yük hava direncini hiç '
        'değiştirmez, düşünce hatası buradadır.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M6 — Dikkat ve yorgunluk
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Müziği değiştirmek için sürüş sırasında telefonu eline '
        'alabilir misin?',
    options: [
      'Evet, sadece bir saniye sürüyorsa ve yol boşsa',
      'Yalnızca kırmızı ışıkta',
      'Hayır',
    ],
    correctIndex: 2,
    explanation: 'Cihazı eline almak ya da tutmak zaten ihlaldir — ne '
        'için olduğundan bağımsız olarak. Motor çalıştığı sürece '
        'kırmızı ışık bir istisna değildir. Müzik, hedef ve ses düzeyi '
        'yola çıkmadan önce araç dururken ayarlanır.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Telefonu ya da tarayıcıyı hukuken ne zaman eline '
        'alabilirsin?',
    options: [
      'Yalnızca araç duruyor VE motor kapalıysa',
      'Araç durur durmaz — bunun için dur-kalk sistemi yeterlidir',
      'Yol düz ve boşken sürüş sırasında kısaca',
    ],
    correctIndex: 0,
    explanation: 'İstisna yalnızca araç dururken ve motor kapalıyken '
        'geçerlidir. Otomatik dur-kalk sistemi açıkça sayılmaz — tam da '
        'buna güvenenler kırmızı ışıkta para cezasını yer.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: '50 km/sa gidiyorsun ve 2 saniye ekrana bakıyorsun. Bu '
        'sırada yolu görmeden ne kadar yol alırsın?',
    options: [
      'yaklaşık 8 metre',
      'yaklaşık 28 metre',
      'yaklaşık 14 metre',
      'yaklaşık 50 metre',
    ],
    correctIndex: 1,
    explanation: '50 km/sa saniyede yaklaşık 14 metre demektir, yani 2 '
        'saniyede aşağı yukarı 28 metre. “14 metre” diyen yalnızca bir '
        'saniye hesaplamıştır — kör mesafeyi yarıya inmiş gibi gösteren '
        'tipik bir hatadır.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: '80 hızda 4 saniye dalıyorsun. Kontrolsüz olarak ne kadar '
        'yol alırsın?',
    options: [
      'yaklaşık 30 metre',
      'yaklaşık 50 metre',
      'yaklaşık 90 metre',
      'yaklaşık 160 metre',
    ],
    correctIndex: 2,
    explanation: '80 km/sa saniyede yaklaşık 22 metre eder, 4 ile '
        'çarpınca aşağı yukarı 89 metre. Telefona bakmanın aksine bu '
        'süre boyunca direksiyon hiç tutmuyorsun — araç şeritten '
        'sürükleniyor. “Kısa” bir dalma fikri bu yüzden bu kadar '
        'tehlikelidir.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Direksiyondaki akut yorgunluğa gerçekten ne iyi gelir?',
    options: [
      'Camı açmak ve müziği açmak',
      'Kahve içmek ve erken bitirmek için daha hızlı sürmek',
      'Durmak, 15–20 dakika kısa uyku, ardından hareket',
    ],
    correctIndex: 2,
    explanation: 'Dikkati yalnızca uyku ve hareket geri getirir. Temiz '
        'hava ve yüksek müzik en fazla birkaç dakika etki eder ve bu '
        'sırada uyanıklık yanılsaması yaratır — insan kendini en çok bu '
        'evrede abartır.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Eller serbest işlevi için tek kulakta kulaklık, diğer '
        'kulak açık — sürüş sırasında bu uygun mudur?',
    options: [
      'Evet, trafik için bir açık kulak yeter',
      'Evet, ses düzeyi düşük ayarlandığı sürece',
      'Hayır',
    ],
    correctIndex: 2,
    explanation: 'Kornaları, sesleri ve acil durum araçlarını güvenle '
        'yerlerini belirleyerek duymak zorundasın — bunun için iki '
        'kulağın da gerekir; manevrada işitme çoğu zaman tek uyarıdır. '
        'Düşük ses düzeyi, bir kulağın meşgul olduğu gerçeğini '
        'değiştirmez.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Telefon elindeyken başka bir yol kullanıcısını tehlikeye '
        'atarsan seni ne bekler?',
    options: [
      '100 € ve 1 ceza puanı',
      '150 €, 2 ceza puanı ve 1 ay sürüş yasağı',
      'Kayda geçmeyen sözlü bir uyarı',
    ],
    correctIndex: 1,
    explanation: '100 € ve 1 ceza puanı, tehlike olmaksızın temel '
        'hâldir; tehlike eklenirse 150 €, 2 ceza puanı ve bir ay sürüş '
        'yasağına çıkar. Profesyonel sürücü olarak senin için sorun para '
        'değil, sürüş yasağıdır.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Tur planı bugün güvenli biçimde tamamlanamıyor. Doğru '
        'tepki nedir?',
    options: [
      'Güvenli biçimde çalışmayı sürdürmek ve planlama sorununu erken '
          'bildirmek',
      'Molaları iptal etmek ve manevradaki kontrolleri kısaltmak',
      'Duraklar arasında daha hızlı sürüp zamanı oradan kazanmak',
    ],
    correctIndex: 0,
    explanation: 'Uyarlanan plandır, güvenlik değil. Ayrıca belirleyici '
        'olan zamanlamadır: öğleden sonranın başında yapılan bir '
        'bildirim hâlâ bir şey değiştirebilir, akşam yapılan artık '
        'değiştiremez. Molaları iptal etmek sorunu ağırlaştırır, çünkü '
        'dikkatin tam da o zaman düşer.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M7 — İnip binme ve kaldırma
  DrivingQuestion(
    moduleId: 'm7',
    question: 'BG Verkehr\'in araca inip binmede uyguladığı 3 nokta '
        'kuralı (“2+1”) nasıldır?',
    options: [
      'Bir el ve iki ayak her zaman araçtadır',
      'İki el ve bir ayak her zaman araçla temas hâlindedir',
      'Tutamakları bırakmadan önce iki ayak da yerdedir',
    ],
    correctIndex: 1,
    explanation: 'İki el artı bir ayak üç sabit nokta eder, böylece tek '
        'bir kayma asla düşmeye yol açmaz. “Önce iki ayak da yere” '
        'seçeneği ise tam olarak hiçbir tutamağının kalmadığı anı '
        'tarif eder — bu, atlama versiyonudur.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Sürücü kabininden doğru şekilde nasıl inersin?',
    options: [
      'Öne doğru, sırtın kapıya dönük, son adımı atlayarak',
      'Koltuktan yana doğru dönerek çıkıp iki ayak üstüne inerek',
      'Geri geri, yüzün araca dönük, merdivenden iner gibi',
    ],
    correctIndex: 2,
    explanation: 'Yalnızca yüzün araca dönükken tutamakları ve basamağı '
        'kullanabilir ve üç temas noktasını koruyabilirsin. Koltuktan '
        'dönerek çıkmak daha hızlı görünür ama diz ve ayak bileğine tüm '
        'vücut ağırlığını bir anda bindirir — en sık yapılan iniş '
        'hatası budur.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Bu tutamaklardan hangisi güvenli bir temas noktası '
        'SAYILMAZ?',
    options: [
      'A direğindeki tutamak',
      'Kapı kenarı',
      'Kapı çerçevesindeki tutamak',
    ],
    correctIndex: 1,
    explanation: 'Kapı kenarı hareketli bir parçaya aittir: tam da '
        'ağırlığını ona verdiğinde kapı boşluk verebilir ya da '
        'kapanabilir. Aynısı direksiyon, koltuk, lastik ve poyra için '
        'de geçerlidir — güvenli noktalar yalnızca bunun için öngörülmüş '
        'tutamaklardır.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Ellerinde tarayıcı ve bir paket var, yük bölümünden '
        'inmek istiyorsun. Doğrusu nedir?',
    options: [
      'Önce ikisini de bırakmak, sonra eller boş şekilde inmek',
      'Paketi koltuk altına sıkıştırıp boş elle tutunmak',
      'Hızlıca inmek, sonuçta sadece iki basamak',
    ],
    correctIndex: 0,
    explanation: 'Eller doluyken üç temas noktan olmaz ve bir düşüşü '
        'karşılayamazsın. Tek elli seçenek uzlaşma gibi görünür ama tam '
        'da bir kaymanın doğrudan düşmeye dönüştüğü durumdur: tek bir '
        'nokta seni tutmaz.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Yol kenarında duruyorsun ve sürücü kapısını açmak '
        'istiyorsun. Arkadan gelen bir bisikletliyi en iyi ne korur?',
    options: [
      'Kapıyı sadece bir aralık açıp kısaca beklemek',
      'Kapıyı hızlı ve geniş açmak, ki iyi görünsün',
      'Açmadan önce kısaca dış aynaya bakmak',
      'Omuz üstü bakış ve ayna — ve kapıyı uzaktaki elle açmak',
    ],
    correctIndex: 3,
    explanation: 'Uzaktaki elle tutmak gövdeni kendiliğinden arkaya '
        'çevirir ve bakmayı zorunlu kılar. Tek başına kısa bir ayna '
        'bakışı yetmez, çünkü kör noktadaki bir bisikletli tam da o '
        'anda görünmez; bir parmak aralık açmak ise çoktan yanına gelmiş '
        'birini uyarmaz.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Kaldırırken omurga için en tehlikeli birleşim nedir?',
    options: [
      'Kaldırırken gövdeyi burarak döndürmek',
      'Dizleri iyice bükerek çömelmiş hâlde kaldırmak',
      'Yükü vücuda yakın tutarak kaldırmak',
    ],
    correctIndex: 0,
    explanation: 'Yük artı dönme, diskleri tek taraflı zorlar ve akut '
        'sırt hasarlarının klasik nedenidir — bunun yerine ayaklarla '
        'adım atarak dön. Çömelme ve yükün vücuda yakınlığı ise tam '
        'olarak doğru tekniktir.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'İnerken ayağın hafifçe burkuluyor ama çalışmaya devam '
        'edebiliyorsun. Doğrusu nedir?',
    options: [
      'Beklemek ve ancak ertesi gün hâlâ ağrıyorsa bildirmek',
      'Hiçbir şey yapmamak — sonuçta iş göremezlik olmadan basit bir '
          'burkulmaydı',
      'Hemen bildirmek ve kaza defterine yazdırmak',
    ],
    correctIndex: 2,
    explanation: 'Sonradan yalnızca belgelenmiş olaylar iş kazası '
        'sayılır ve tedavi edilmemiş bir bağ sorunu daha kötü iyileşir. '
        'Ertesi güne kadar beklemek yaygındır ve işle bağlantının '
        'sonradan çoğu zaman kabul edilmemesinin tam da sebebidir.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M8 — Kapı ve çevre
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Bahçe kapısında büyük bir köpek havlıyor. Müşteri '
        'teslimat notuna “köpek uysaldır” yazmış. Ne yaparsın?',
    options: [
      'Sakince içeri girmek — müşteri köpeğini en iyi tanır',
      'Parsele girmemek, iletişim kurmayı denemek ve notu '
          'meslektaşlar için sisteme işlemek',
      'Paketi çitin üzerinden atıp yola devam etmek',
    ],
    correctIndex: 1,
    explanation: 'Bir teslimat notu güvenlik onayı değildir: müşteri '
        'köpeğini aileyle ilişkisinden tanır, büyük bir cisim taşıyan '
        'yabancı bir insanla ilişkisinden değil. Ayrıca paketi çitin '
        'üzerinden atmak usulüne uygun bir teslimat da değildir.',
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Serbest dolaşan bir köpek havlayarak sana doğru geliyor. '
        'Doğrusu nedir?',
    options: [
      'Sakince olduğun yerde durmak, bakışını kaçırmak, ona yanını '
          'dönmek ve yavaşça geri gitmek',
      'Hızla araca geri koşup kapıyı kapatmak',
      'Sesini yükseltip paketi savunma için kaldırmak',
    ],
    correctIndex: 0,
    explanation: 'Sakinlik, kaçırılan bakış ve yavaş geri çekilme, '
        'köpeğin gerekçesini ortadan kaldırır. Araca koşmak mantıklı '
        'geliyor ama yanlış: kaçmak av refleksini tetikler ve köpek '
        'senden hızlıdır.',
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Kapıya giden en kısa yol ıslak bir çimenden geçiyor. Ne '
        'yaparsın?',
    options: [
      'Kestirmek — 120 durakta sapmalar hatırı sayılır biçimde birikir',
      'Kestirmek, ama yalnızca gündüz ve kuru havada',
      'Sağlam zeminli yolu kullanmak',
    ],
    correctIndex: 2,
    explanation: 'Takılma, kayma ve düşme dağıtımdaki en sık yaralanma '
        'nedenidir ve neredeyse her zaman son metrelerde olur. Zaman '
        'hesabı da tutmaz: sapma saniyelere, bir düşme ortalama 24 iş '
        'göremezlik gününe mal olur.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Bir teslimat için aracı terk ettiğinde ne geçerlidir?',
    options: [
      'Motor kapalı, anahtar yanında, kilitli, eğimde tekerlekler '
          'kırılmış',
      'Görüş alanında kaldığın sürece motor çalışabilir',
      'El frenini sıkıca çekmek yeterlidir',
    ],
    correctIndex: 0,
    explanation: 'Aracını terk eden, onu yetkisiz kullanıma karşı '
        'emniyete almak ve kazaları önlemek zorundadır. “Görüş alanında” '
        'bir istisna değildir — çalışır ve açık bir araç saniyeler '
        'içinde gider ve eğimde el freni tek başına yüklü bir panelvanı '
        'güvenilir biçimde tutmaz.',
  ),

  // ══════════════════════════════════ M9 — Acil durum ve kaza
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Yaralıların bulunduğu bir kaza yerinde hangi sırayla '
        'hareket edersin?',
    options: [
      'İlk yardım yapmak, sonra emniyete almak, sonra acil çağrı '
          'yapmak',
      'Emniyete almak, sonra acil çağrı, sonra ilk yardım',
      'Acil çağrı, sonra sigorta için fotoğraflar, sonra ilk yardım',
    ],
    correctIndex: 1,
    explanation: 'Önce yeri emniyete al, yoksa bir kazadan ikincisi '
        'doğar — kurbanı da sen olursun. Hemen yaralıya koşmak insani '
        'olarak doğru görünür ama şehirler arası yolda ve otoyolda '
        'hayati tehlike taşır; fotoğrafların ise bu aşamada hiç yeri '
        'yoktur.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Otoyolda reflektörlü üçgeni hangi mesafeye koyarsın?',
    options: [
      'yaklaşık 50 metre',
      'yaklaşık 100 metre',
      'yaklaşık 150–200 metre',
    ],
    correctIndex: 2,
    explanation: 'Şehir içinde yaklaşık 50 m, şehir dışında yaklaşık '
        '100 m, otoyolda 150–200 m — hız ne kadar yüksekse uyarı o '
        'kadar erken durmalıdır. Şehir dışı değerini alan, 120 km/sa '
        'hızdaki arkadan gelen trafiğe üç saniye bile bırakmaz. Tümsek '
        've virajlarda üçgen onların öncesine konur, sonrasına değil.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Üç şeritli bir otoyolda trafik duruyor. Kurtarma '
        'koridorunu nerede oluşturursun?',
    options: [
      'Sol şerit ile orta şerit arasında',
      'Orta şerit ile sağ şerit arasında',
      'Emniyet şeridinde',
      'Şerit sayısından bağımsız olarak yolun ortasında',
    ],
    correctIndex: 0,
    explanation: 'Koridor her zaman en soldaki şerit ile hemen onun '
        'sağındaki şerit arasındadır — kaç şerit olduğundan bağımsız '
        'olarak. Emniyet şeridi bir alternatif değildir: koridor '
        'kapalıysa acil ekipler oradan gider.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Kurtarma koridoru ne zaman oluşturulmalıdır?',
    options: [
      'Ancak mavi ışık görüldüğünde ya da duyulduğunda',
      'Trafik durur durmaz',
      'Ancak bilgi panosundan talimat verildiğinde',
    ],
    correctIndex: 1,
    explanation: 'Koridor mavi ışıkla değil, trafiğin durmasıyla '
        'oluşur. Acil durum aracı beklenirse araçlar çoktan birbirine '
        'çok yakın durur — o zaman kimsenin kenara çekilecek yeri '
        'kalmaz.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Manevra yaparken park hâlindeki bir araca zarar '
        'veriyorsun, yakında kimse yok. Silecek altına bir not yeterli '
        'mi?',
    options: [
      'Evet, üzerinde ad ve telefon numarası varsa',
      'Evet, not kanunun öngördüğü yoldur',
      'Hayır — ancak ayrıca fotoğraf da çekersen yeterlidir',
      'Hayır — makul bir süre beklemeli, yoksa polisi bilgilendirmelisin',
    ],
    correctIndex: 3,
    explanation: 'Bir not hukuken yeterli tespit sayılmaz — uçabilir ya '
        'da alınabilir; buna güvenen, kaza yerinden izinsiz uzaklaşma '
        'suçlamasını göze alır. Fotoğraflar hasarı belgeler ama ne '
        'beklemenin ne de bildirimin yerini tutar.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Kazadan sonra bir kişi normal solumuyor. Ne yaparsın?',
    options: [
      'Hemen kalp masajına başlarım, dakikada yaklaşık 100–120 kez',
      'Kişiyi koma pozisyonuna alır ve üstünü örterim',
      'Ambulansı beklerim — sıradan biri olarak bir şey yapamam',
    ],
    correctIndex: 0,
    explanation: 'Normal solunum yoksa her dakika değerlidir ve işe '
        'yarayan tek önlem bastırmaktır. Koma pozisyonu doğrudur — ama '
        'yalnızca normal solunum varsa. Ve hiçbir şey yapmamak tek '
        'yanlış karardır: yardım etmekten kaçınmak suçtur.',
  ),

  // ══════════════════════════════════ M10 — Özet
  DrivingQuestion(
    moduleId: 'm10',
    question: 'Bu eğitimin tutumunu en iyi ne özetler?',
    options: [
      'Kurallar özellikle denetim yapıldığında geçerlidir',
      'Güvenlik benim günlük kararımdır, ki herkes eve sağ salim '
          'dönsün',
      'Yeter ki tur zamanında tamamlansın',
    ],
    correctIndex: 1,
    explanation: 'Güvenlik bir tutumdur, zorunlu bir alıştırma değil — '
        've kendini tam da kimse bakmıyorken gösterir. Kuralları '
        'denetimlere bağlayan onları anlamamış, sadece katlanmıştır.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm10',
    question: 'Araca inip binerken kaç temas noktası tutarsın — ve kuru '
        'yolda en az kaç saniye mesafe bırakırsın?',
    options: [
      '2 temas noktası ve 1 saniye',
      '3 temas noktası ve 1 saniye',
      '3 temas noktası (2 el + 1 ayak) ve 2 saniye',
    ],
    correctIndex: 2,
    explanation: 'Üç temas noktası (“2+1”) ve iki saniye mesafe — '
        'ıslakta üç. Bir saniyelik mesafe 50 hızda tam olarak salt tepki '
        'yoluna karşılık gelir: hiçbir fren yedeğin olmadan çarpardın.',
  ),
];

// Dil çözümlemesi, `drivingQuestionsForModule()` ve `buildDrivingExam()`
// driving_safety_data.dart içinde bulunur.
