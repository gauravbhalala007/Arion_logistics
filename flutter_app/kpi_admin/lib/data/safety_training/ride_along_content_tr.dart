// lib/data/safety_training/ride_along_content_tr.dart
//
// Ride Along eğitiminin içerikleri — Türkçe sürüm.
//
// “Ride Along”, yeni sürücüler için iki günlük refakatli sürüştür: 1. gün
// daha az sayıda stop, 2. gün belirgin şekilde daha fazla. Eğitmen bu
// sırada bir kontrol listesini işler, her maddeyi imzalar ve sonunda geri
// bildirim verir; form fotoğraf olarak sorumlu dispatcher’a teslim edilir.
//
// Bu eğitimin amacı: HAZIRLIK. Önceden çalışan kişi iki günün konularını
// ilk kez duymaz, hedefe yönelik soru sorabilir ve refakatli sürüşü
// bilinçli olarak değerlendirebilir.
//
// Yapı Green Book’taki gibi: her bölümde tiplenmiş bloklardan oluşan
// birden çok slayt — sayı kutuları, düşündüren örnek olaylar (Reveal),
// doğru/yanlış, akılda kalıcı notlar ve bölüm sonunda bir kontrol
// listesi. Bu konuya ait çizim olmadığı için `asset: ''`.
//
// Çok işletmeli kullanım: KİŞİ adı yok, istasyon adı yok, işletmeye özel
// sayılar kural olarak yok. Stop sayıları, Waiting Area saatleri, işe
// başlama ve park tarafı açıkça ilgili istasyonun kuralıdır — bunları
// eğitmen söyler. Zaman kaydı gibi firma araçları yalnızca örnek olarak
// geçer (“örneğin Kenjo”). Somut kalabilecek olanlar: Amazon araçları
// (Flex, Mentor, ATLAS, Scorecard), CoDriver uygulaması, § 4 ArbZG
// uyarınca mola kuralları ve § 1 Abs. 6 FPersV uyarınca Green Book —
// üçü de işletmeden bağımsız olarak geçerlidir.

import 'safety_blocks.dart';

const List<SafetyChapterContent> rideAlongContentTr = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ra1',
    title: 'Ride Along nedir',
    summary: 'İki gün refakatli sürüş: amaç, akış, kimler var ve '
        'değerlendirme nasıl yapılır',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Deneyimli bir sürücünün yanında iki gün',
        blocks: [
          ParagraphBlock(
            'Ride Along, işe girişteki refakatli sürüşündür: deneyimli bir '
            'sürücünün eğitmen olarak seninle birlikte yolda olduğu iki iş '
            'günü. Turu bir sunumdan değil, tam olarak gerçekleştiği yerde '
            'öğrenirsin — istasyonda, Loading Area’da ve sokakta.',
          ),
          FactsBlock([
            FactItem('2 gün', 'bir eğitmenle refakatli sürüş'),
            FactItem('1. gün', 'daha az sayıda stop — birçok işletmede '
                'yaklaşık 20'),
            FactItem('2. gün', 'belirgin şekilde daha fazla stop — birçok '
                'işletmede yaklaşık 70'),
          ]),
          ParagraphBlock(
            'İki gün birbirinin üzerine kurulur. İlk günün ağırlığı '
            'süreçlerdedir: istasyona nasıl girilir, hangi uygulama ne '
            'zaman başlatılır, yükleme nasıl yapılır, mola ne zaman. '
            'İkinci günde miktar belirgin şekilde artar ve sürüşü de '
            'teslimatı da sen yaparsın — eğitmen eşlik eder, ama işi '
            'devralmaz.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Stop sayıları yol gösterici değerlerdir',
            text: '1. ve 2. günde gerçekte kaç stop öngörüldüğünü işletmen '
                'ya da istasyonun belirler. Yaygın olan, ilk günde '
                'yaklaşık 20, ikinci günde yaklaşık 70’tir — ama bağlayıcı '
                'olan yalnızca eğitmeninin veya sorumlu dispatcher’ının '
                'sana söylediği sayıdır.',
          ),
          BulletsBlock([
            'Her iki gün de eğitmenin hesabı üzerinden değil, senin kendi '
                'hesabın üzerinden yürür',
            'Stoplar kuru alıştırma değil, gerçek iş olarak sayılır',
            'Eğitmen anlatır, önce kendisi gösterir, sonra da yapmayı sana '
                'bırakır',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Kısaca',
            text: 'Ride Along, gerçek işletme içindeki oryantasyonundur. '
                'Sonunda bir turu tek başına sürebilmen beklenir — her şey '
                'bu ölçüte göre yürür.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kimler var ve kim ne yapıyor',
        blocks: [
          ParagraphBlock(
            'Ride Along’da üç rol yer alır. Kimin neyden sorumlu olduğunu '
            'bilirsen yanlış kişiye sormaz ve zaman kaybetmezsin.',
          ),
          TableBlock(
            headers: ['Rol', 'Görev'],
            rows: [
              [
                'Sen',
                'Sürersin, teslim edersin, soru sorarsın, işin içinde '
                    'olursun — iki gün de kendi hesabın üzerinden',
              ],
              [
                'Eğitmen',
                'Deneyimli sürücü: her maddeyi anlatır, önce gösterir, '
                    'seni gözlemler, kontrol listesini işaretler ve imzalar',
              ],
              [
                'Dispatcher',
                'İki günü planlar, sorunlarda muhatabındır ve sonunda '
                    'kontrol listesinin fotoğrafını teslim alır',
              ],
            ],
          ),
          ParagraphBlock(
            'Eğitmen ne amirindir ne de resmi bir kurum anlamında '
            'sınav görevlin. O, istasyonu en iyi tanıyan meslektaşındır. '
            'Tam da bu yüzden iki gün boyunca aklına gelen her soru için '
            'doğru adres odur — sana basit görünenler için bile.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Soru sormanın bedeli yok',
            text: 'Ride Along’da bir soru ucuzdur. Aynı soru üçüncü '
                'haftada, turda tek başınayken ve önünde dolu bir rota '
                'varken pahalıdır.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrol listesi ve geri bildirim',
        blocks: [
          ParagraphBlock(
            'Eğitmen sabit bir formu işler — Ride Along kontrol listesi. '
            'Formda iki günün her biri için nelerin anlatılmış ve '
            'gösterilmiş olması gerektiği yazar: araç muayenesinden mola '
            'kurallarına, oradan şifreli paketlere kadar. Her madde '
            'imzalanır, her gün tarih ve imzayla kapatılır.',
          ),
          BulletsBlock([
            'Kontrol listesi, sana oryantasyon verildiğinin kanıtıdır',
            'Seni de korur: işaretlenmiş olan sana anlatılmış demektir',
            'İkinci günden sonra eğitmen performansın ve sürüş becerilerin '
                'hakkında geri bildirim verir',
          ]),
          ParagraphBlock(
            'Bu, giyotinli bir sınav değildir. Kimse ilk günde turu üç '
            'yıllık deneyimi olan bir sürücü gibi sürmeni beklemez. Ama '
            'değerlendirilirsin: Eğitmen nasıl çalıştığını yazar ve form '
            'işletmeye gider. Görünür şekilde düşünen, dakik olan ve '
            'uyarıları kabul eden kişi — yavaş olsa bile — iyi bir geri '
            'bildirim alır.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Asıl önemli olan fark',
            text: 'Değerlendirilen, her şeyi bilip bilmediğin değil, '
                'öğrenmeye açık olup olmadığın ve kuralları ciddiye alıp '
                'almadığındır. Hata yapmak normaldir. Bir hatayı iki kez '
                'anlatılmasına rağmen görmezden gelmek normal değildir.',
          ),
          RevealBlock(
            prompt: 'Örnek olay: İlk günde paketlerin roll kafesteki '
                'sırasını iki kez karıştırıyorsun ve stopların için '
                'planlanandan belirgin şekilde uzun süre harcıyorsun. Ride '
                'Along’ın bittiğinden eminsin. Doğru mu?',
            answer: 'Hayır. İlk gün tam da bunun içindir. Eğitmen hızı '
                'ancak ikinci günde kısmen, sonraki haftalarda ise gerçek '
                'anlamda bekler. İlk günde değerlendirdiği şey başkadır: '
                'Emin değilken soruyor musun? Aynı hatayı üçüncü kez de '
                'yapıyor musun? Sonrasında kendiliğinden daha düzenli mi '
                'sıralıyorsun? Hatayı dile getiren ve bir sonraki roll '
                'kafeste bilinçli olarak farklı davranan kişi, hızlı olup '
                'hiçbir şeyi sorgulamayandan daha iyi bir izlenim bırakır.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrol listesi: 1. bölüm',
        blocks: [
          ChecklistBlock(
            title: '1. bölümden aklımda kalanlar',
            items: [
              'Ride Along, bir eğitmenle geçen iki iş günüdür',
              '1. gün daha az stop, 2. gün belirgin şekilde daha fazla — '
                  'kesin sayıyı işletmem belirler (yaygın olarak yaklaşık '
                  '20 ve yaklaşık 70)',
              'Her iki gün de kendi hesabım üzerinden yürür',
              'Eğitmen anlatır, gösterir ve yapmayı bana bırakır',
              'Bir kontrol listesini işaretler ve her gün için imzalar',
              '2. günden sonra performans ve sürüş becerileri hakkında bir '
                  'geri bildirim verilir',
              'Bu bir oryantasyondur, ama değerlendirilir — öğrenmeye '
                  'açıklık hızdan daha çok sayılır',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'İki gün için tek cümle',
            text: '“Bir kez az sormaktansa bir kez fazla sorarım — bu iki '
                'gün bunun için var.”',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ra2',
    title: 'Birinci gün',
    summary: 'İlk stoplar, uygulama başlatma, muayene, Loading Area, '
        'molalar ve araç anahtarı',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Kendi hesabınla ilk stoplar',
        blocks: [
          ParagraphBlock(
            'Birinci günün, sürüp teslim etmiş olman beklenen asgari bir '
            'stop sayısı vardır — kendi hesabın üzerinden. Bu sayı bilerek '
            'küçük tutulur (birçok işletmede yaklaşık 20); istasyonun için '
            'bağlayıcı sayıyı sana eğitmenin söyler. 1. günde konu miktar '
            'değil, her hareketin bir kez doğru oturmasıdır.',
          ),
          ParagraphBlock(
            'Önemli olan kendi hesabındır. Eğitmenin hesabı değil, ortak '
            'bir erişim de değil. O gün teslim ettiğin her şey senin adına '
            'işlenir — tam da sonradan sayılacağı gibi. Eğitmen ve işletme '
            'ancak böyle senin teslimatının gerçekte nasıl göründüğünü '
            'görür.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Erişim yoksa Ride Along da yok',
            text: 'Sabah hesabın çalışmıyorsa bunu hemen söyle — yola '
                'çıkmadan önce, ilk stopta değil. Çözülmemiş bir erişim '
                'sorunu bütün güne mal olur.',
          ),
          SubheadBlock('CoDriver uygulaması'),
          ParagraphBlock(
            'CoDriver işletmenin uygulamasıdır — şu anda içinde okuduğun '
            'uygulama. Amazon araçlarından ayrıdır: Amazon turu yönetir, '
            'CoDriver ise şirketteki işinle ilgili her şeyi. Eğitmen '
            'birinci günde uygulamayı seninle birlikte gözden geçirir.',
          ),
          BulletsBlock([
            'Vardiya planı ve Wave planı: ne zaman çalıştığın ve hangi '
                'dalgada başladığın',
            'Devamsızlık ve hastalık bildirimi',
            'DA Academy: buradaki gibi eğitimler, ayrıca işletme '
                'talimatları',
            'İşletmenin mesajları ve bildirimleri',
            'Kaza ve hasar bildirimleri',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Aklında tut',
            text: 'Amazon uygulamaları turu yönetir. CoDriver iş ilişkini '
                'yönetir. İkisine de her gün ihtiyacın var ve ikisine de '
                '1. günde bir kez baştan sona bakmak gerekir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Varış: çalışma saatleri, park tarafı, Waiting Area',
        blocks: [
          ParagraphBlock(
            'Gün ilk stopla değil, istasyona varışla başlar. Eğitmen '
            'birinci günde üç şeyi özellikle sana tembihler, çünkü bunlar '
            'her iş gününde tekrarlanır.',
          ),
          SubheadBlock('1 — Çalışma saatleri'),
          ParagraphBlock(
            'Vardiyanın sabit bir başlangıcı vardır. Bu, CoDriver’daki '
            'vardiya planında yazar ve “başlangıç” şu demektir: o saatte '
            'istasyonda göreve hazırsın — oraya giden yolda değil. '
            'İstasyonunun somut saatlerini sana eğitmen söyler; saatler '
            'lokasyona ve dalgaya göre değişir.',
          ),
          SubheadBlock('2 — Park tarafı'),
          ParagraphBlock(
            'Her istasyonun özel araçların nereye park edebileceğine ve '
            'kamyonetlerin hangi tarafa dizileceğine dair bir düzeni '
            'vardır. Bu bir zorbalık değildir: Sahada aynı anda çok sayıda '
            'araç manevra yapar, çoğu zaman geri geri ve görüş kötüyken. '
            'Yanlış park eden bir geçiş yolunu kapatır ya da manevra '
            'yapanın kör noktasında durur. Senin için geçerli tarafı '
            'eğitmen gösterir.',
          ),
          SubheadBlock('3 — Waiting Area saatleri'),
          ParagraphBlock(
            'Waiting Area, roll kafesin veya yükleme pozisyonun '
            'çağrılana kadar beklediğin alandır. Bunun için her dalgada '
            'sabit zaman aralıkları vardır. Çok erken gelen alanı tıkar; '
            'geç kalan çağrısını kaçırır ve bütün dalgayı geriye iter. '
            'İstasyonunun kesin saatlerini eğitmen birinci günde söyler — '
            'bunları not al.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Not etmen gereken üç bilgi',
            text: 'Vardiya başlangıcı, park tarafı ve Waiting Area '
                'aralığın. Bu üç bilgiye ertesi günden itibaren her sabah '
                'ihtiyacın olur — ve o zaman kimse sana sormaz.',
          ),
          RevealBlock(
            prompt: 'Örnek olay: Vardiya başlangıcında kapıda tam '
                'zamanındasın, ama yanlış tarafta aradığın için park yeri '
                'bulmak on dakikanı alıyor. Böylece Waiting Area’ya geç '
                'kalıyorsun. Bu ne kadar kötü?',
            answer: 'Göründüğünden daha kötü. Waiting Area’daki çağrı '
                'zamanlanmıştır: Aralığını kaçırırsan dalganın diğer '
                'sürücülerinin arkasına düşersin. Roll kafesin bekler, '
                'aracın bu sırada muhtemelen bir pozisyonu kapatır ve '
                'başlangıcın kaybettiğin on dakikadan çok daha fazla '
                'ötelenir. Park tarafı ile Waiting Area saati bu yüzden '
                'birbirine bağlıdır: “kapıda dakik olmak”, “Waiting '
                'Area’da dakik olmak” ile aynı şey değildir. Park etme ve '
                'yürüme süresini de hesaba kat.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Başlangıç: zaman kaydı, Mentor ve Flex',
        blocks: [
          ParagraphBlock(
            'Vardiyanın başında üç sistem çalışıyor olmalı — hem de '
            'zamanında ve bu sırayla. Her birinin farklı bir amacı vardır '
            've geç başlatıldığında her biri sorun çıkarır.',
          ),
          StepsBlock([
            'İşletmenin zaman kaydı (örneğin Kenjo) — vardiya başında '
                'giriş yap. Burada başlatmadığın şey ücretli çalışma '
                'süresi değildir ve sonradan bordronda eksik kalır. '
                'İşletmenin hangi sistemi kullandığını eğitmen gösterir.',
            'Mentor — Amazon’un sürüş davranışı uygulaması: yola '
                'çıkmadan önce çalışıyor olmalı. Sürüş davranışını kaydeder '
                've skorunun verilerini sağlar.',
            'Flex — Amazon’un teslimat uygulaması: rotanı buradan alır, '
                'paketleri tarar ve her teslimatı belgelendirirsin.',
          ]),
          SubheadBlock('Mentor’un 4 saati'),
          ParagraphBlock(
            'Mentor sınırsız çalışmaz: Uygulama her seferinde yaklaşık '
            'dört saat aralıksız kayıt yapar. Sonrasında onu yeniden '
            'başlatman gerekir, aksi hâlde turunun geri kalanı kayıtsız '
            'geçer. Yeni başlayanların en sık yaptığı hata tam da budur — '
            'uygulama sabah doğru başlatılmış, ama öğle molasından sonra '
            'yeniden etkinleştirilmemiştir. Mentor’un hâlâ çalıştığını '
            'nereden anlayacağını eğitmen birinci günde gösterir.',
          ),
          FactsBlock([
            FactItem('4 sa', 'Mentor’un aralıksız kayıt süresi'),
            FactItem('yola çıkmadan', 'Mentor’u başlat — yolda değil'),
            FactItem('moladan sonra', 'Mentor’u kontrol et ve yeniden '
                'başlat'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Birinci günün en sık hatası',
            text: 'Flex çalışıyor, Mentor çalışmıyor. O zaman rotanı '
                'sürersin ama sürüş davranışın kaydedilmez — ve eksik '
                'Mentor süresi işletmede kötü bir değer kadar dikkat '
                'çeker.',
          ),
          RevealBlock(
            prompt: 'Örnek olay: Saat 14’te Mentor’un moladan beri '
                'çalışmadığını fark ediyorsun. Ne yaparsın — mesai '
                'bitimine kadar devam edip yarın daha iyisini mi '
                'yaparsın, yoksa hemen mi tepki verirsin?',
            answer: 'Hemen tepki ver: bir sonraki güvenli yerde dur, '
                'Mentor’u yeniden başlat, yoluna devam et. Akla gelen '
                'yanılgı, düzgün sürdüğün için kayıtsız geçen yarım günün '
                'önemsiz olduğunu sanmaktır. Önemsiz değildir: İşletme '
                'için bir boşluk boşluk gibi görünür — iyi sürüş gibi '
                'değil. Ayrıca devam etmek, boşluğu her saat biraz daha '
                'büyütmek demektir. Boşluğun açıklanabilir olması için '
                'durumu ayrıca eğitmenine veya sorumlu dispatcher’ına '
                'bildir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Araç muayenesi ve Loading Area',
        blocks: [
          SubheadBlock('Araç muayenesi'),
          ParagraphBlock(
            'Yola çıkmadan önce araç kontrol edilir — ve turdan sonra bir '
            'kez daha. Muayene, belgelendirmeli bir gözle kontroldür: '
            'Kamyonetin etrafında bir tur atarsın, her tarafına bakarsın, '
            'işlevleri kontrol edersin ve gördüğünü kayda geçirirsin.',
          ),
          BulletsBlock([
            'Dış tur: kaporta, tamponlar, aynalar, camlar — her göçük ve '
                'her çizik',
            'Lastikler: diş derinliği, görünür hasarlar, hava basıncı '
                'izlenimi',
            'Aydınlatma: kısa far, fren lambası, sinyal, geri vites farı',
            'Kabin ve yük bölümü: temizlik, gevşek parçalar, ayırma '
                'duvarı',
            'Donanım: reflektörlü üçgen, uyarı yeleği, ilk yardım çantası',
            'Kilometre durumu ve yakıt ya da şarj durumu',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Muayenenin neden sürüşten ÖNCE önemi var',
            text: 'Önceden belgelediğin bir hasar, önceki hasardır. '
                'Belgelemediğin aynı hasar, akşam senin hasarındır. İki '
                'dakikalık tur, iş gününün en ucuz sigortasıdır.',
          ),
          SubheadBlock('Loading Area’da roll kafesin yüklenmesi'),
          ParagraphBlock(
            'Loading Area’da rotanın paketleriyle dolu roll kafesin durur. '
            'Onu kamyonete nasıl yerleştirdiğin bütün gününü belirler: '
            'Düzensiz yükleyen her stopta arar — ve bu, dolu bir tur '
            'boyunca saatlere ulaşır.',
          ),
          BulletsBlock([
            'Rota sırasına göre yükle: ilk çıkacak olan en son girer ve '
                'önde durur',
            'Ağır paketler alta, hafifler üste — tersi değil',
            'Yükü emniyete al: fren yapınca hiçbir şey öne kaymamalı',
            'Geçide ya da sürgülü kapının önüne hiçbir şey istifleme',
            'Özel paketleri (şifreli, ATLAS, havaleli) ayrı ve elinin '
                'altında tut',
            'Boş roll kafesi ait olduğu yere geri koy — rastgele bir yere '
                'bırakma',
          ]),
          DoDontBlock(
            doTitle: 'Doğrusu şöyle',
            dos: [
              'Yüklerken ilk stopun hangisi olduğunu şimdiden düşün',
              'Kaldırırken dizlerini bük, yükü gövdene yakın tut',
              'Bir paketin nereye ait olduğunu bilmiyorsan sor',
            ],
            dontTitle: 'Bu sana sonradan zaman kaybettirir',
            donts: [
              'Her şeyi içeri atıp “yolda sıralarım” demek',
              'Paketleri ayırma duvarına ya da sürücü bölümüne koymak',
              'Roll kafesi geçiş yolunun ortasında bırakmak',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Molalar, anahtar ve otomatik kilitleme',
        blocks: [
          SubheadBlock('Molalar: 30 ve 45 dakika'),
          ParagraphBlock(
            'İki mola süresi vardır ve hangisinin senin için geçerli '
            'olduğu yalnızca o günkü çalışma süresine bağlıdır. Waiting '
            'Area saatlerinin veya stop sayılarının aksine bu, '
            'istasyonunun bir kuralı değil, kanundur: § 4 '
            'Arbeitszeitgesetz (ArbZG — Almanya’nın çalışma süresi '
            'kanunu). Kural böylece her işletmede aynıdır ve pazarlığa '
            'açık değildir.',
          ),
          FactsBlock([
            FactItem('30 dk', '6 saatten fazla, 9 saate kadar çalışma '
                'süresinde'),
            FactItem('45 dk', '9 saatten fazla çalışma süresinde'),
            FactItem('15 dk', 'sayılabilecek en kısa kısmi mola'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 4 ArbZG — hukuki dayanak',
            text: 'Arbeitszeitgesetz (çalışma süresi kanunu), 6 saatten '
                'fazla çalışma süresinde en az 30 dakika, 9 saatten fazla '
                'çalışmada en az 45 dakika dinlenme molası öngörür. '
                'Molasız 6 saatten uzun çalışmak açıkça yasaktır.',
          ),
          ParagraphBlock(
            'Mola bölünebilir, ama her parçası en az 15 dakika sürmelidir '
            '— yani iki kez 15 dakika 30 dakikalık molayı, üç kez 15 '
            'dakika 45 dakikalık molayı verir. Aralarda beşer dakikalar '
            'sayılmaz. Ayrıca önemli: Mola, altı saatlik çalışma dolmadan '
            'başlamış olmalıdır, vardiyanın sonunda değil.',
          ),
          ParagraphBlock(
            'Neden kaydedilmesi gerekir: Molan ücretli çalışma süresi '
            'değildir ve işletmenin molayı gerçekten kullandığını '
            'kanıtlayabilmesi gerekir. Bu yüzden mola zaman kaydına '
            'işlenir — güvensizlikten değil, belgelenmemiş bir mola bir '
            'denetimde kullanılmamış mola sayıldığı için. Bu, işletmenin '
            'sorumlu olduğu bir ihlaldir. Molayı tam olarak nereye '
            'işleyeceğini eğitmen gösterir.',
          ),
          SubheadBlock('Otomatik kilitleme ve anahtar'),
          ParagraphBlock(
            'Birçok Sprinter otomatik kilitlenir: Kapı kapandığında ya da '
            'araç hareket ettiğinde merkezi kilit kendiliğinden kapanır. '
            'Bu, yükün için bir hırsızlık korumasıdır — ve anahtarın '
            'neden hep üstünde kalması gerektiğinin tam sebebidir.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Anahtarın yeri senin üzerindir',
            text: 'Koltuğa değil, torpido gözüne değil, araçta kalan '
                'ceketin cebine değil. Anahtar pantolon cebine ya da '
                'kemerindeki kayışa — her indiğinde.',
          ),
          RevealBlock(
            prompt: 'Örnek olay: Kısa bir süre duruyorsun, anahtarı '
                'kontakta bırakıyorsun, iki paket alıyorsun ve sürgülü '
                'kapıyı ayağınla kapatıyorsun. Merkezi kilit kapanıyor. '
                'Şimdi ne olur?',
            answer: 'Elinde iki paketle kilitli bir kamyonetin önünde '
                'kalırsın; içinde anahtarın, telefonun, geri kalan yükün '
                've çoğu zaman evrakların vardır. Gün böylece biter: '
                'İstasyondan yardım ya da bir çilingir gerekir, bütün '
                'rotan durur ve araçtaki paketler bugün müşterilerine '
                'ulaşmaz. Akla gelen yanılgı “sadece on saniyeliğine '
                'iniyorum”dur — otomatik kilit on saniye ile on dakika '
                'arasında ayrım yapmaz. Bu yüzden istisnasız kural '
                'şudur: anahtarı çıkar, anahtarı üzerine al, ancak ondan '
                'sonra in.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tur sonu: Flex’i kapatmak ve muayene',
        blocks: [
          ParagraphBlock(
            'Gün son stopta değil, istasyonda biter. Orada eğitmenin '
            'kontrol listesinde iki madde vardır — ve insan yorgun olup '
            'eve gitmek istediği için ikisi de sıkça unutulur.',
          ),
          StepsBlock([
            'Flex uygulamasını düzgün kapat: rotayı bitir, iadeleri teslim '
                'et ve uygulamadan çık — telefonu öylece cebe koyma.',
            'Sürüşten sonra araç muayenesi: sabahki turun aynısı, şimdi '
                'yeni hasarlara, kilometre durumuna ve yakıt ya da şarj '
                'durumuna bakarak.',
            'Aracı temiz ve boş teslim et, yük bölümünü kontrol et — '
                'içinde tek bir paket kalmaz.',
            'İşletmenin zaman kaydında (örneğin Kenjo) çıkış yap ve '
                'anahtarı ait olduğu yere teslim et.',
          ]),
          ParagraphBlock(
            'Kapanış muayenesi, sabahki muayenenin karşılığıdır. O günün '
            'araçta neyin olup neyin olmadığı ancak ikisi birlikte açık '
            'olur. Akşamki muayene eksikse, ertesi sabah bulunan bir '
            'hasar artık kimseye bağlanamaz ve bir sonraki sürücü senin '
            'sorununu, sen de onunkini devralırsın.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Mesai sonu için akılda kalıcı not',
            text: 'Flex kapalı, araç etrafında tur, yük bölümü boş, çıkış '
                'yapıldı, anahtar teslim edildi. Mesai ancak o zaman '
                'biter.',
          ),
          ChecklistBlock(
            title: '1. günden aklımda kalanlar',
            items: [
              'İşletmemin belirlediği sayıda stopu kendi hesabım '
                  'üzerinden yaptım',
              'CoDriver uygulamasını tanıyorum ve içinde ne bulacağımı '
                  'biliyorum',
              'Vardiya başlangıcımı, istasyonumun park düzenini ve '
                  'Waiting Area aralığımı biliyorum',
              'Zaman kaydını (örneğin Kenjo), Mentor’u ve Flex’i '
                  'zamanında ve bu sırayla başlatıyorum',
              'Mentor’un yaklaşık 4 saat kaydettiğini ve sonra yeniden '
                  'başlatılması gerektiğini biliyorum',
              'Araç muayenesini turdan önce ve sonra yapıyorum',
              'Roll kafesi rota sırasına göre, ağırı alta koyarak ve yükü '
                  'emniyete alarak yüklüyorum',
              '§ 4 ArbZG uyarınca mola kuralını biliyorum: 6 saatten '
                  'fazlada 30 dakika, 9 saatten fazlada 45 dakika — ve '
                  'molayı kaydediyorum',
              'Sprinter otomatik kilitlendiği için anahtar hep üzerimde '
                  'kalır',
              'Sonunda Flex’i kapatıyorum, muayeneyi yapıyorum ve çıkış '
                  'yapıyorum',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ra3',
    title: 'İkinci gün',
    summary: 'Belirgin şekilde daha fazla stop bağımsız olarak, Scorecard, '
        'araç koruması, Green Book, özel paketler, yakıt ve şarj',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Belirgin şekilde daha fazla stop — sen sürer, sen teslim '
            'edersin',
        blocks: [
          ParagraphBlock(
            'İkinci günde denge tersine döner. Stop sayısı belirgin '
            'şekilde artar — birçok işletmede yaklaşık 70’e, bağlayıcı '
            'olan istasyonunun kuralıdır — ve stopları bağımsız olarak sen '
            'yaparsın: Sen sürersin, sen yön bulursun, sen tararsın, sen '
            'teslim edersin, sen belgelendirirsin. Eğitmen yanında oturur '
            've yalnızca gerektiğinde müdahale eder.',
          ),
          FactsBlock([
            FactItem('daha çok', '1. güne göre stop — sayıyı işletme '
                'belirler'),
            FactItem('kendin', 'sürüş ve teslimat — eğitmen yalnızca eşlik '
                'eder'),
            FactItem('1 gün', 'ilk kendi turuna kadar'),
          ]),
          ParagraphBlock(
            'İkinci günün asıl anlamı budur: Dolu bir turun nasıl bir his '
            'olduğunu bir kez yaşamış olman gerekir — tempoyla, arada '
            'sıralamayla, kapıyı açmayan müşterilerle ve saatin işlediği '
            'duygusuyla. Bunu bir kez yanında biri varken yaşadıysan, ilk '
            'tek başına çıkış artık yarı yarıya küçülür.',
          ),
          BulletsBlock([
            'Kendin yapabileceğin hiçbir şeyi başkasına bırakma — daha '
                'yavaş olsa bile',
            'Sana tuhaf gelen her stopu hemen sonrasında sor',
            'Not etmen gerekenleri aklında tut: kodlar, süreçler, '
                'muhataplar',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: '2. günün ölçütü',
            text: '“Turu rekor sürede bitiriyor mu” değil, “yarın tek '
                'başına gönderilebilir mi”. Eğitmenin değerlendirdiği tam '
                'olarak budur.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Scorecard, kalite ve performans',
        blocks: [
          ParagraphBlock(
            'İşin ölçülür. Amazon’un Scorecard’ı hafta hafta senin ve '
            'işletmenin nasıl çalıştığını özetler. İkinci günde eğitmen '
            'sana içinde hangi değerlerin bulunduğunu ve bunları nasıl '
            'etkilediğini anlatır — çünkü neredeyse her değer, senin '
            'elinde olan bir şeyden doğar.',
          ),
          BulletsBlock([
            'Teslimat kalitesi: Paket doğru yerde mi teslim edildi ya da '
                'bırakıldı ve düzgün belgelendi mi?',
            'Mentor’dan sürüş davranışı: frenleme, hızlanma, virajlar, '
                'telefon kullanımı, emniyet kemeri',
            'Güvenilirlik: dakik başlangıç, tamamen sürülen rota, doğru '
                'iade',
            'Müşteri geri bildirimleri: şikâyetler ve övgüler de '
                'değerlendirmeye girer',
          ]),
          ParagraphBlock(
            'Kalite ile performans bu arada sık karıştırılan iki farklı '
            'şeydir. Performans miktardır: hangi sürede kaç stop. Kalite '
            'ise her bir stopun ne kadar düzgün tamamlandığıdır. Yüksek '
            'performansı ve kötü kalitesi olan bir sürücü, kazandırdığından '
            'daha fazla iş çıkarır — her şikâyet işletmeye, başta '
            'kazanılan dakikanın kat kat fazlasına mal olur.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'En pahalı hata, hızlı yapılan hatadır',
            text: 'Bir paketi yanlış yere bırakıp hızla yola devam etmek '
                'sana bir dakika kazandırır, işletmeye ise bir şikâyete, '
                'bir araştırmaya ve şüpheli durumda malın bedeline mal '
                'olur.',
          ),
          RevealBlock(
            prompt: 'Örnek olay: Müşteri kapıyı açmıyor, önünde daha 30 '
                'stop var. Paketi çöp kovasının arkasına bırakıp hızlıca '
                'ev kapısının fotoğrafını çekiyorsun. Bu neden sorun?',
            answer: 'İki kez sorun. Birincisi, bırakma yeri belgelediğin '
                'yerle örtüşmüyor — müşteri paketi bulamazsa teslimatın '
                'kanıtsız kalır. İkincisi, çöp kovasının arkası uygun bir '
                'yer değildir: Sokaktan görünür ve kova boşaltılır. '
                'Doğrusu, öngörülen yolu izlemektir — komşu, müşteri '
                'onayıyla güvenli bırakma yeri ya da geri getirme — ve '
                'gerçekte ne yaptıysan tam olarak onu belgelemektir. '
                'Kazanılan o bir dakika, sana da müşteriye de işletmeye de '
                'çok daha pahalıya mal olan bir şikâyetle karşı karşıya '
                'kalır.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Araç koruması, kazalar, temizlik ve bakım',
        blocks: [
          ParagraphBlock(
            'Kamyonet senin iş yerin ve işletmenin sana emanet ettiği en '
            'pahalı araçtır. Onunla nasıl davrandığın ikinci günde kontrol '
            'listesinde ayrı bir maddedir — üç bölüm hâlinde.',
          ),
          SubheadBlock('1 — Hasarı önlemek'),
          BulletsBlock([
            'Geri geri gitmeyi yalnızca başka çare yoksa yap — o zaman da '
                'yavaş ve her iki aynaya bakarak',
            'Durum belirsizse tahmin etmek yerine in ve bak',
            'Dar girişler, alçak dallar, kapalı otoparklar ve babalar en '
                'sık hasar kaynaklarıdır',
            'Mesafe bırak ve önden görerek fren yap — bu hem aracı hem '
                'Scorecard’ı aynı anda korur',
          ]),
          SubheadBlock('2 — Yine de bir şey olursa'),
          StepsBlock([
            'Dur, güvenliği sağla: dörtlü flaşör, uyarı yeleği, '
                'reflektörlü üçgen.',
            'Yaralılara yardım et, yaralanma varsa mutlaka 112’yi ara.',
            'Hiçbir şeyi değiştirme, fotoğraf çek: genel durum, hasarlar, '
                'plakalar, çevre.',
            'Yabancı araç varsa ya da kusur belirsizse polisi çağır — '
                'küçük hasarlarda bile.',
            'Sorumlu dispatcher’ına hemen haber ver ve olayı CoDriver’da '
                'bildir.',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Asla yoluna devam etme',
            text: 'Yabancı bir araçtaki küçük bir çizik bile bildirim '
                'yapılmazsa kaza yerini terk etmektir — bir suçtur. Silecek '
                'altına bırakılan bir not hukuken yeterli değildir.',
          ),
          SubheadBlock('3 — Temizlik ve bakım'),
          BulletsBlock([
            'Sürücü kabinini her gün boşalt: çöp yok, şişe yok, kâğıt yok',
            'Yük bölümünü süpür ve unutulan paket var mı kontrol et',
            'Camları ve aynaları temiz tut — kötü görüş bir güvenlik '
                'sorunudur, estetik kusur değil',
            'Sıvı kaçaklarını ve dikkat çeken sesleri bildir, görmezden '
                'gelme',
          ]),
          RevealBlock(
            prompt: 'Örnek olay: Manevra yaparken bir babaya sürtüyorsun. '
                'Araçta bir çizik var, başka bir şey yok, kimse görmedi. '
                'Bunu bildirir misin?',
            answer: 'Evet, her zaman ve aynı gün içinde. Konu kusur değil, '
                'ilişkilendirmedir: Bildirilen bir çizik, işleme alınan bir '
                'olaydır. Ertesi sabah başka bir sürücünün muayenesinde '
                'bulduğu aynı çizik ise açıklanmamış bir hasardır — ve bu, '
                'ilgili herkes için, senin için de rahatsız edici olur, '
                'çünkü şüphe sonunda yine son kullanıcıya yönelir. Akla '
                'gelen yanılgı “bu fark edilmez”dir. Bir sonraki muayenede '
                'fark edilir, muayene bunun içindir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Green Book / kontrol defteri',
        blocks: [
          ParagraphBlock(
            'Green Book senin sefer kontrol defterindir: § 1 Abs. 6 '
            'Fahrpersonalverordnung (FPersV — Almanya’nın sürücü personeli '
            'yönetmeliği) uyarınca tutulan, sürüş sürelerini, sürüş '
            'aralarını ve dinlenme sürelerini kanıtladığın günlük kontrol '
            'formları. Bu da istasyonunun bir kuralı değil, yürürlükteki '
            'sürücü personeli hukukudur — her işletmede aynı geçerlidir. '
            'Açıkça bir araç kontrolü değildir: Green Book’ta konu '
            'yalnızca sürelerdir, senin sürelerin.',
          ),
          BulletsBlock([
            'Her iş günü için bir form, el yazısıyla doldurulur ve '
                'imzalanır',
            'Sürüşün başlangıcı ve bitişi, kilometre değerleri, sürüş '
                'süreleri, aralar ve dinlenme süreleri yazılır',
            'Hemen doldur, akşam hafızandan yeniden kurgulama',
            'Son günlerin kayıtları araçta taşınır ve bir denetimde ibraz '
                'edilir',
          ]),
          ParagraphBlock(
            'Eğitmen ikinci günde sana formun nerede durduğunu, nasıl '
            'doldurulduğunu ve biten formların nereye teslim edildiğini '
            'gösterir. Gerisi burada değil: DA Academy’de bunun için ayrı '
            'bir “Green Book” eğitimi var — zorunlu bilgiler, sürüş ve '
            'dinlenme süreleri, taşıma zorunluluğu ve ihlallerin sonuçları '
            'ile birlikte. Ayrıntıları ikinci günde araçta aklında tutmaya '
            'çalışmak yerine o eğitimi baştan sona çalış.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Asıl yükümlülük kaydın kendisidir',
            text: 'Ortada hiçbir belge yoksa, sürelere uyup uymadığını bir '
                'denetimde kimse tespit edemez. Bu yüzden eksik bir form, '
                'aşılmış bir sürüş süresi kadar ihlaldir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Özel durumlar: şifreli paketler ve ATLAS paketleri',
        blocks: [
          SubheadBlock('Şifreli paketler'),
          ParagraphBlock(
            'Bazı gönderiler yalnızca müşterinin önceden aldığı bir şifre '
            'ya da kod karşılığında teslim edilebilir. Tipik olarak değerli '
            'mallar ve hırsızlık riski yüksek olan her şey böyledir. Flex '
            'seni stopta bu konuda uyarır.',
          ),
          BulletsBlock([
            'Kodu müşteri söyler ya da gösterir — sen kodu okumaz ve önce '
                'sen söylemezsin',
            'Doğru kod yoksa teslim yok: istisna yok, komşuya da olmaz',
            'Kapıya bırakma ve apartman girişinde bırakma yok',
            'Kod uymuyorsa gönderi öngörülen yola göre geri getirilir ve '
                'belgelenir',
          ]),
          SubheadBlock('ATLAS paketleri'),
          ParagraphBlock(
            'ATLAS gönderileri de özel işlem gören paketlerdir: Tarama ve '
            'teslim akışında ek adımları olan kendi süreçlerini izlerler. '
            'Senin için önemli olan, onları tanıman, ayrı ve elinin altında '
            'saklaman ve öngörülen akışı kısaltmamandır. Sürecin senin '
            'istasyonunda somut olarak nasıl işlediğini ve Flex’in sana '
            'hangi adımları verdiğini eğitmen ikinci günde gerçek paket '
            'üzerinde gösterir.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Özel paketleri önce yerleştir',
            text: 'Her iki paket türünü de stopta 90 başka gönderinin '
                'altında aramak istemezsin. Yüklerken onları bilinçli '
                'olarak ayrı koy ve yerlerini aklında tut.',
          ),
          RevealBlock(
            prompt: 'Örnek olay: Müşteri kapıda, ama şifresi elinde değil '
                '— “bu sadece formalite, size ne isterseniz imzalarım”. Ne '
                'yaparsın?',
            answer: 'Teslim etmezsin. Şifre, alıcının gerçekten alıcı '
                'olduğunun kanıtıdır — tam da bu yüzden verilmiştir. Bir '
                'imza, kontrol etme yetkin olmayan bir kimlik ya da tatlı '
                'dil onun yerini tutmaz. Akla gelen yanılgı, nezaketi '
                'sürecin önüne koymaktır: Gönderi sonradan teslim '
                'alınmamış olarak bildirilirse, kodsuz teslim senin adına '
                'hata olarak kalır. Müşteriden kodu sipariş onayında '
                'aramasını iste. Bulamazsa paketi geri götürür ve doğru '
                'şekilde belgelendirirsin.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Yakıt almak, şarj etmek ve tur sonu',
        blocks: [
          SubheadBlock('Yakıt almak'),
          ParagraphBlock(
            'Kamyonet işletmenin kurallarına göre yakıt alır: öngörülen '
            'istasyonlarda, aracın yakıt kartıyla ve doğru yakıtla. Fiş '
            'araçta kalır ya da eğitmenin sana gösterdiği yere teslim '
            'edilir. Ne zaman yakıt alacağın basit bir kurala bağlıdır: '
            'yedek lambası yanınca değil, bir sonraki sürücünün neredeyse '
            'boş depoyla yola çıkmak zorunda kalmayacağı şekilde.',
          ),
          BulletsBlock([
            'Doğru yakıt türü — yanlış yakıt aracı günlerce durdurur',
            'Yakıt kartı araca aittir, senin özel çantana değil',
            'Fişi sakla ve belirtildiği şekilde teslim et',
            'Motor kapalı, sigara yok, pompada telefon yok',
          ]),
          SubheadBlock('Elektrikli şarj'),
          ParagraphBlock(
            'Elektrikli araçta şarj, yakıt almanın yerini alır — önemli bir '
            'farkla: Şarj daha uzun sürer ve bu yüzden planlanmalıdır. '
            'Eğitmen sana nerede şarj edildiğini, hangi kablonun araca ait '
            'olduğunu ve aracın vardiya sonunda hangi şarj seviyesinde '
            'olması gerektiğini gösterir.',
          ),
          BulletsBlock([
            'Şarj seviyesini takip et ve zamanında planla, kalan menzile '
                'gelince tepki verme',
            'Fişi taktıktan sonra şarjın gerçekten başlayıp başlamadığını '
                'kontrol et',
            'Kabloyu düzgün sar ve takılma noktası bırakma',
            'Vardiya sonunda aracı işletmenin öngördüğü şekilde teslim et '
                '— bir sonraki sürücü onunla yola çıkar',
          ]),
          SubheadBlock('Tur sonu — 1. gündeki gibi'),
          StepsBlock([
            'Flex uygulamasını düzgün kapat, rotayı bitir, iadeleri teslim '
                'et.',
            'Sürüşten sonra araç muayenesi: tur at, yeni hasarlar, '
                'kilometre durumu, yakıt ya da şarj seviyesi.',
            'Yük bölümü boş ve temiz, sürücü kabini derli toplu.',
            'Çıkış yap, anahtarı teslim et, Green Book’u tamamla.',
          ]),
          ChecklistBlock(
            title: '2. günden aklımda kalanlar',
            items: [
              'İşletmemin belirlediği, belirgin şekilde daha yüksek stop '
                  'sayısı — bunları kendim sürüp teslim ediyorum',
              'Scorecard’da ne yazdığını ve onu nasıl etkilediğimi '
                  'biliyorum',
              'Kalite ile performans aynı şey değildir — ikisi de sayılır',
              'Hasarları etkin biçimde önlüyorum ve her olayı hemen '
                  'bildiriyorum',
              'Aracı içeriden ve dışarıdan temiz tutuyorum',
              '§ 1 Abs. 6 FPersV uyarınca Green Book’u biliyorum ve bunun '
                  'için DA Academy’deki ayrı eğitimi yapıyorum',
              'Şifreli paketleri yalnızca doğru kod karşılığında teslim '
                  'ediyorum',
              'ATLAS paketlerini tanıyorum ve öngörülen süreci izliyorum',
              'Yakıt alma ve elektrikli şarj kurallarını biliyorum',
              'Sonunda: Flex’i kapat, muayene, çıkış yap',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ra4',
    title: 'Kapanış ve teslim',
    summary: 'Eğitmenin geri bildirimi, her gün için imzalar ve formun '
        'fotoğraf olarak teslimi',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Eğitmenin geri bildirimi',
        blocks: [
          ParagraphBlock(
            'İkinci günden sonra eğitmen seninle oturur ve performansın ile '
            'sürüş becerilerin hakkında geri bildirim verir. Bu iki '
            'kelimelik bir hüküm değil, bir değerlendirmedir: Neler zaten '
            'yolunda, neyin üzerinde çalışman gerekiyor, önümüzdeki '
            'haftalarda özellikle neye dikkat etmelisin.',
          ),
          BulletsBlock([
            'Sürüş davranışı: sakinlik, öngörü, geri manevra, dar yerlerle '
                'başa çıkma',
            'Teslimat: özen, belgeleme, müşterilerle iletişim',
            'Organizasyon: sıralama, zaman duygusu, uygulamaların '
                'kullanımı',
            'İş tutumu: dakiklik, soru sorma, uyarılara yaklaşım',
          ]),
          ParagraphBlock(
            'Geri bildirimi ciddiye al, ama kişisel algılama. Birinin seni '
            'iki tam gün boyunca izlediği tek fırsat budur. Bir nokta sana '
            'belirsiz geliyorsa sor, hem de somut sor: “Geri manevrada tam '
            'olarak neyi farklı yapmalıyım?” sorusu, bir baş sallamadan '
            'daha çok işine yarar.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Sona saklanacak tek soru',
            text: 'Eğitmenine sonunda sor: “Tek başıma geçireceğim ilk '
                'haftamda özellikle dikkat etmem gereken tek şey nedir?” '
                'Cevap, iki günün en değerli çıktısıdır.',
          ),
          RevealBlock(
            prompt: 'Örnek olay: Geri bildirimde manevrada fazla tereddütlü '
                'olduğun ve bu yüzden zaman kaybettiğin söyleniyor. Sen '
                'sadece dikkatli davrandığını düşünüyorsun. Bununla nasıl '
                'başa çıkarsın?',
            answer: 'Kendini savunmak yerine sor. Manevrada dikkat doğru '
                'olandır — eğitmen “tereddütlü” derken genellikle başka bir '
                'şeyi kasteder: İnip kısaca bakmak yerine uzun uzun '
                'düşünmeni ya da her iki aynaya bakarak bir kez geri almanın '
                'yeteceği yerde defalarca hamle yapmanı. Günden somut bir '
                'örnek iste. O zaman elinde yalnızca başını salladığın ya '
                'da reddettiğin bir değerlendirme değil, üzerinde gerçekten '
                'çalışabileceğin bir nokta olur.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Form: tarih, adlar, imzalar',
        blocks: [
          ParagraphBlock(
            'Ride Along kontrol listesi ancak baş bilgileri doğruysa '
            'tamamlanmış olur. Onlar olmadan form, işaretlerle dolu ama '
            'hiçbir kanıta bağlanamayan bir kâğıttır.',
          ),
          TableBlock(
            headers: ['Bilgi', 'Ne kastediliyor'],
            rows: [
              ['Tarih', 'İki günün her biri için ayrı yazılır'],
              ['Öğrencinin adı', 'Senin adın — yeni sürücü'],
              ['Eğitmenin adı', 'Eğitmeninin adı'],
              [
                'İmza',
                'Eğitmenden, her gün için ayrı — iki gün için tek seferde '
                    'değil',
              ],
            ],
          ),
          ParagraphBlock(
            'Her gün için ayrı imza atılmasının bir nedeni var: Her günün '
            'kendi madde listesi vardır. İkinci gün iptal olur ya da '
            'ertelenirse, ilk günde nelerin yapıldığı yine de düzgün '
            'belgelenmiş olur. Bu yüzden her günün sonunda tarih ve imzanın '
            'yazılıp yazılmadığını kendin kontrol et.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Kendin bak',
            text: 'Form, oryantasyonunun kanıtıdır. Bir imza eksikse kanıt '
                'da eksiktir — ve böyle bir şeyi sonradan tamamlamak her '
                'zaman zahmetlidir. Mesai bitmeden atılacak bir bakış '
                'yeter.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Teslim: dispatcher’a fotoğraf',
        blocks: [
          ParagraphBlock(
            'İkinci günün sonunda doldurulmuş form, fotoğraf olarak sorumlu '
            'dispatcher’ına teslim edilir. Böylece Ride Along resmen '
            'tamamlanmış ve oryantasyonun belgelenmiş olur.',
          ),
          StepsBlock([
            'Formu düz bir zemine koy, iyi ışık bul.',
            'Yukarıdan fotoğrafla; formun tamamı karede olsun, gölge '
                'olmasın ve kenarlar kesilmesin.',
            'İşaretlerin, tarihin, adların ve imzaların okunaklı olup '
                'olmadığını kontrol et.',
            'Fotoğrafı sorumlu dispatcher’a teslim et — eğitmenin size '
                'söylediği yoldan.',
            'Kâğıt formu işletmenin öngördüğü şekilde sakla: istenebilir.',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Okunmayan, teslim edilmemiş sayılır',
            text: 'Titrek ya da yarısı kesilmiş bir fotoğrafın yeniden '
                'çekilmesi gerekir — ve o sırada ikiniz de belki çoktan '
                'evdesinizdir. Göndermeden önce bir kez bak.',
          ),
          ChecklistBlock(
            title: 'Kapanıştan aklımda kalanlar',
            items: [
              '2. günden sonra eğitmen performans ve sürüş becerileri '
                  'hakkında geri bildirim verir',
              'Belirsiz noktalarda somut olarak soru soruyorum',
              'Formda tarih, öğrencinin adı ve eğitmenin adı yazar',
              'Eğitmen her gün için ayrı imza atar',
              'Her günün sonunda her şeyin yazılıp yazılmadığını kendim '
                  'kontrol ediyorum',
              'Form, 2. günün sonunda okunaklı bir fotoğraf olarak sorumlu '
                  'dispatcher’a teslim edilir',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ra5',
    title: 'Kendini böyle hazırlarsın',
    summary: '1. günden ÖNCE netleştirmen gerekenler — erişimler, donanım, '
        'zaman planı ve soruların',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Önceden netleştir: erişimler ve teknik',
        blocks: [
          ParagraphBlock(
            'Bir ilk günün kötü başlamasının en sık nedeni eksik bilgi '
            'değil, çalışmayan bir erişimdir. Bunu önceden hallet — o zaman '
            'Ride Along’ın asıl konusuyla başlar.',
          ),
          BulletsBlock([
            'Teslimat için kendi hesabın: giriş bilgileri elinde ve bir kez '
                'başarıyla giriş yapılmış',
            'İşletmenin zaman kaydı (örneğin Kenjo): erişim kurulmuş, giriş '
                've çıkışı nasıl yapacağını biliyorsun',
            'Mentor ve Flex: uygulamalar kurulu, giriş test edilmiş, konum '
                've hareket izinleri verilmiş',
            'CoDriver: giriş yapılmış, bildirimlere izin verilmiş',
            'Telefon: şarjı dolu, yeterli depolama alanı, kamyonet için '
                'şarj kablosu ya da powerbank yanında',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Akşamdan kontrol et, sabah değil',
            text: 'Bir şifreyi sıfırlamak akşam 20’de beş dakika, sabah '
                '6’da Waiting Area’da yarım saat sürer — ulaşılabilecek '
                'biri varsa tabii.',
          ),
          RevealBlock(
            prompt: 'Örnek olay: İlk günün sabahında teslimat uygulamana '
                'giriş yapılamıyor. Eğitmen bekliyor, dalga başlıyor. En '
                'iyi tepki nedir?',
            answer: 'Erişimin çalışmadığını hemen söyle — hem de sorumlu '
                'dispatcher’ını devreye sokabilmesi için eğitmene. Akla '
                'gelen yanılgı, beceriksiz görünmemek için sessizce '
                'denemeye devam etmektir. Bu, sorunun hâlâ çözülebileceği '
                'dakikalara mal olur ve sonunda bütün gün eğitmenin hesabı '
                'üzerinden çalışırsın — böylece kendi hesabın üzerinden '
                'asgari stop sayısı yerine gelmemiş olur ve en kötü '
                'ihtimalle gün tekrarlanmak zorunda kalır. Bu yüzden: erken '
                'bildir, neyi denediğini açıkça söyle.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kıyafet, donanım ve dakiklik',
        blocks: [
          SubheadBlock('Ne giyeceksin'),
          BulletsBlock([
            'İş güvenliği ayakkabısı: sağlam, kapalı iş ayakkabısı — spor '
                'ayakkabı ya da sandalet olmaz',
            'Hava koşullarına uygun kıyafet: Bütün gün dışarıdasın, sabah '
                'hava kuru görünse bile',
            'Rahat hareket: yüzlerce kez inip bineceksin',
            'Uyarı yeleği elinin altında — araçta durur, ama aklında da '
                'olmalı',
          ]),
          SubheadBlock('Yanında ne olacak'),
          BulletsBlock([
            'Ehliyet — onsuz araç kullanmazsın, ilk günde bile',
            'İşletme istiyorsa kimlik ya da oturum belgesi',
            'Mola için içecek ve yiyecek bir şeyler',
            'Kalem ve küçük bir defter ya da not uygulaması',
          ]),
          SubheadBlock('Dakiklik'),
          ParagraphBlock(
            'Dakik olmak şu demektir: vardiya başlangıcında istasyonda '
            'göreve hazır olmak, kapıya yeni varıyor olmak değil. Park '
            'etme, sahadan yürüme ve Waiting Area süresini de hesaba kat. '
            'İlk günde geç kalan, eğitmenin dalgasını da öteler — ve bu '
            'akılda kalır.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'İlk günler için pratik kural',
            text: 'Yolu, biraz erken varacak şekilde planla. Kazandığın '
                'çeyrek saati etrafa bakmak için kullanırsın — tuvaletler, '
                'Waiting Area, dizilme yerleri.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Soruların — ve önceden kontrol listesi',
        blocks: [
          ParagraphBlock(
            'İki gün boyunca yanında, bilmen gereken her şeyi bilen biri '
            'var. Bu, bir daha böyle gelmeyecek bir durumdur. Neredeyse '
            'herkesin yaptığı hata: Sorularını not etmezler ve sorular '
            'ancak ikinci haftada, kamyonette tek başlarınayken akıllarına '
            'gelir.',
          ),
          BulletsBlock([
            '1. günden önce bilmek istediklerini yaz — küçük şeyleri de',
            'Tur sırasında cevapları not et, hafızana güvenme',
            'Müşteri verilerinden hiçbir şey fotoğraflama, ama süreçleri ve '
                'muhatapları not et',
            'Her günün sonunda sor: “Bugün daha neyi görmedim?”',
          ]),
          ParagraphBlock(
            'Ride Along için iyi sorular örneğin şunlardır: Waiting Area '
            'aralığım tam olarak ne zaman? Özel aracımı nereye park '
            'ederim? Mentor’un hâlâ çalıştığını nasıl anlarım? Molamı '
            'nereye işlerim? Bir hasarı önce kime bildiririm? Green Book’u '
            'nereye teslim ederim? Şifreli bir pakette müşterinin kodu '
            'yoksa ne yaparım?',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Bu eğitimi neden yaptın',
            text: 'Ride Along’da her şeyi zaten bilesin diye değil, '
                'kavramları tanıyasın diye. Neyin kastedildiğini bilen '
                'dinleyebilir — her şeyi ilk kez duyan yalnızca başını '
                'sallayabilir.',
          ),
          RevealBlock(
            prompt: 'Örnek olay: Eğitmen sabah art arda on şey anlatıyor. '
                'Akşam bunların üçünü hatırlıyorsun. Sebep neydi — sen mi?',
            answer: 'Sen değil, yöntem. On yeni süreci art arda dinleyip '
                'akılda tutmak kimsede işe yaramaz. İşe yarayan şudur: '
                'kavramları önceden bir kez okumuş olmak — bu eğitim tam da '
                'bunun için var — ve yolda not almak. Konu başına iki '
                'anahtar kelime, akşam bütün akışı yeniden hatırlamaya '
                'yeter. İkinci günde hâlâ eksik olanı da kendiliğinden geri '
                'gelmesini ummak yerine hedefe yönelik olarak sorarsın.',
          ),
          ChecklistBlock(
            title: '1. günden önce — kendin işaretle',
            items: [
              'Kendi teslimat hesabımın giriş bilgilerini test ettim',
              'Zaman kaydı (örneğin Kenjo), Mentor, Flex ve CoDriver '
                  'kurulu ve giriş yapılmış',
              'Telefon şarjı dolu, şarj kablosu ya da powerbank çantada',
              'İş güvenliği ayakkabısı ve hava koşullarına uygun kıyafet '
                  'hazır',
              'Ehliyet ve gerekli belgeler yanımda',
              'Mola için içecek ve yiyecek hazırlandı',
              'Kalem ve not alma imkânı yanımda',
              'Yol planlandı — park etme ve Waiting Area’ya yürüme dâhil',
              'Eğitmene soracağım soruları yazdım',
              'Kavramları tanıyayım diye bu eğitimi baştan sona çalıştım',
            ],
          ),
        ],
      ),
    ],
  ),
];
