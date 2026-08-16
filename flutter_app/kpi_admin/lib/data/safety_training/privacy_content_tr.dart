// lib/data/safety_training/privacy_content_tr.dart
//
// Veri koruma eğitiminin içerikleri — Türkçe sürüm.
// privacy_content_de.dart dosyasının çevirisidir; yapı (bölümler,
// slaytlar, bloklar, id ve asset değerleri) her zaman Almanca ana
// dosyayla eşzamanlı tutulmalıdır.
//
// Yapı Green Book’taki gibi: her bölümde tiplenmiş bloklardan oluşan
// birden çok slayt — hukuki notlar (CalloutTone.law), düşündüren örnek
// olaylar (Reveal), doğru/yanlış ve bölüm sonunda bir kontrol listesi.
// Bu konuya ait çizim olmadığı için `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> privacyContentTr = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ds1',
    title: 'Veri koruma seni neden ilgilendirir',
    summary: 'Günlük teslimat işinde kişisel veriler ve Art. 5 DSGVO '
        '(GDPR) ilkeleri',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Bütün gün başkalarının verileriyle çalışıyorsun',
        blocks: [
          ParagraphBlock(
            'Veri koruma denince akla ofis, dosya dolabı ve avukat gelir. '
            'Oysa gerçekte kişisel verilere neredeyse hiç kimse senin kadar '
            'yakın değil. Sabahki ilk taramadan akşamki son stopa kadar '
            'elinde başkalarına ait isimler, adresler ve telefon numaraları '
            'var — üstelik yabancı kapıların fotoğrafları da.',
          ),
          ParagraphBlock(
            'Bir kişinin kim olduğunun belirlenmesini sağlayan her bilgi '
            'kişisel veridir. Sadece isim değil: adres, saat ve paket '
            'içeriğinin birleşimi de bir insan hakkında bir şey söyler. '
            'Kurallar tam da bu yüzden var.',
          ),
          BulletsBlock([
            'Etiket, el terminali ve listedeki alıcı adları ve adresleri',
            'Teslimat öncesi iletişim için telefon numaraları',
            'El terminalindeki teslim alma onayı olarak imzalar',
            'Kapı önünde teslimat kanıtı olarak çekilen fotoğraflar',
            'El terminalinin ve aracın konum verileri',
            'Paket bıraktığın komşulara ait bilgiler',
            '“Paketi lütfen çöp konteynerinin arkasına bırakın” gibi '
                'notlar — bu da bir insanın yaşam durumu hakkında bilgidir',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Kısacası',
            text: 'Bir alıcı hakkında öğrendiğin her şeyi, yalnızca paketi '
                'sen getirdiğin için öğrendin. Başka hiçbir amaç için bu '
                'bilgi sana verilmedi.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Günlük işte önemli olan üç ilke',
        blocks: [
          ParagraphBlock(
            'Art. 5 DSGVO altı ilke koyar. Bunlardan üçü, pratikte her gün '
            'doğru mu yanlış mı davrandığına karar verir. Basit bir dille:',
          ),
          TableBlock(
            headers: ['İlke', 'Senin için anlamı'],
            rows: [
              [
                'Amaçla sınırlılık',
                'Verileri yalnızca sana verildiği amaç için kullan: '
                    'teslimat. Özel işler için değil.',
              ],
              [
                'Veri minimizasyonu',
                'Sadece gerektiği kadar veri topla ve göster. Gereğinden '
                    'fazla fotoğraf yok, gereğinden uzun liste yok.',
              ],
              [
                'Gizlilik',
                'Gördüğün şey sende ve işletmede kalır. Sohbet grubunda '
                    'değil, yemek masasında değil, internette değil.',
              ],
            ],
          ),
          ParagraphBlock(
            'Bunlara doğruluk (yanlış bilgiyi sürüklemek yerine düzeltmek), '
            'saklama süresinin sınırlanması (hiçbir şeyi gerekenden uzun '
            'tutmamak) ve hesap verebilirlik eklenir — son madde şirketi '
            'ilgilendirir ve bu eğitimin var olma nedenidir.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Hukuki dayanak',
            text: 'Art. 5 Abs. 1 DSGVO, diğerlerinin yanında amaçla '
                'sınırlılık (lit. b), veri minimizasyonu (lit. c) ile '
                'bütünlük ve gizlilik (lit. f) ister. Bu ilkeler, şirket '
                'adına kişisel verilerle çalışan herkes için geçerlidir — '
                'yani turdaki senin için de.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Bu eğitim neden var',
        blocks: [
          ParagraphBlock(
            'DSGVO hiçbir yerde kelimesi kelimesine “çalışanlar '
            'eğitilmelidir” demez. Yine de bunu ister — üç ayrı yoldan. Bu '
            'yüzden şu anda buradasın ve bu yüzden bitirmen belgeleniyor.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Eğitim yükümlülüğü nereden geliyor',
            text: 'Art. 32 DSGVO, şirketi işlemenin güvenliği için teknik '
                've organizasyonel önlemler almakla yükümlü kılar — eğitimli '
                'çalışanlar böyle bir önlemdir. Art. 39 Abs. 1 lit. b '
                'DSGVO, bilinçlendirme ve eğitimi açıkça veri koruma '
                'görevlisinin görevi olarak sayar. Ve Art. 5 Abs. 2 DSGVO, '
                'şirketin kurallara uyduğunu kanıtlayabilmesini ister — '
                'hesap verebilirlik.',
          ),
          ParagraphBlock(
            'Denetim makamları bir incelemede buna dikkatle bakar. Eksik '
            'çalışan eğitimlerini düzenli olarak önlemlerin yetersiz '
            'olduğuna işaret sayarlar — özellikle de bir şey olduktan '
            'sonra. Bir veri ihlalinin ardından ilk soru neredeyse hep '
            'şudur: Çalışanlar eğitilmiş miydi ve bunu belgeleyebiliyor '
            'musunuz?',
          ),
          BulletsBlock([
            'Herkes için yıllık temel eğitim — bitirmen on iki ay '
                'geçerlidir',
            'Bir şey değiştiğinde veya bir olay yaşandığında ek eğitim',
            'Yeni çalışanlara ilk kendi günlerinden önce tanıtım eğitimi',
            'Art. 5 Abs. 2 DSGVO uyarınca kanıt olarak testin ve imzanın '
                'belgelenmesi',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Günlük işte sınır nereden geçiyor',
        blocks: [
          RevealBlock(
            prompt: 'Örnek olay: Turunda bölgeden tanınmış bir futbolcuya '
                'ait bir paket var. Akşam arkadaş ortamında hangi sokakta '
                'oturduğunu anlatıyorsun — başka bir şey yok, sosyal '
                'medyada isim yok, sadece arkadaşlar arasında. Bu bir veri '
                'koruma ihlali mi?',
            answer: 'Evet. Adres kişisel bir veridir ve sen onu yalnızca '
                'işinden biliyorsun. Üçüncü kişilere aktarmak amaçla '
                'sınırlılığa (Art. 5 Abs. 1 lit. b DSGVO) ve gizliliğe '
                '(lit. f) aykırıdır. Akla gelen yanılgı, özel bir çevrenin '
                '“sayılmadığıdır” — DSGVO dinleyici kitlenin ne kadar büyük '
                'olduğunu sormaz, verileri amaç dışı açıklayıp '
                'açıklamadığını sorar. Arkadaşlarından biri bunu başkasına '
                'anlatırsa üstelik artık hiçbir kontrolün kalmaz.',
          ),
          DoDontBlock(
            doTitle: 'Doğru',
            dos: [
              'Alıcı verilerini yalnızca teslimat için kullanmak ve sonra '
                  'sistemde bırakmak',
              'Bir gönderiyle ilgili sorularda dispatcher’a veya işletme '
                  'yönetimine yönlendirmek',
              'El terminalini ve kağıt listeyi üçüncü kişiler okuyamayacak '
                  'şekilde tutmak',
              'Belirsiz durumları kendin karar vermek yerine dile getirmek',
            ],
            dontTitle: 'Yanlış',
            donts: [
              'Adresleri veya isimleri özel çevrede anlatmak — “sadece '
                  'arkadaşlar arasında” bile olsa',
              'Ünlüleri veya dikkat çeken gönderileri sohbet konusu yapmak',
              'Bir görev olmadan salt meraktan alıcı verilerine bakmak',
              '“Bunu zaten kimse öğrenmez” diye güvenmek',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrol listesi Bölüm 1',
        blocks: [
          ParagraphBlock(
            'Maddeleri kısaca gözden geçir. Bir maddede duraksıyorsan geri '
            'dön ve tekrar bak — testte tam olarak bu durumlar yeniden '
            'karşına çıkacak.',
          ),
          ChecklistBlock(
            title: 'Bölüm 1’den aklımda kalanlar',
            items: [
              'Turumdaki hangi verilerin kişisel veri olduğunu biliyorum',
              'Amaçla sınırlılığı, veri minimizasyonunu ve gizliliği '
                  'tanıyorum',
              'Alıcı verilerinin özel hayata taşınmayacağını biliyorum',
              'Bu eğitimin neden belgelendiğini biliyorum '
                  '(Art. 5 Abs. 2 DSGVO)',
              'Eğitimin her yıl tekrarlandığının farkındayım',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ds2',
    title: 'Fotoğraflar ve teslimat kanıtları',
    summary: 'Fotoğrafta ne olabilir, ne olamaz — ve fotoğrafın yeri '
        'neresi',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Fotoğrafın tam olarak tek bir amacı var',
        blocks: [
          ParagraphBlock(
            'Teslimat fotoğrafı tek bir soruyu yanıtlamalı: Paket nerede '
            'duruyor? Başka hiçbir şeyi değil. Bunun ötesine geçen her '
            'şey gerekenden fazla bilgidir — ve dolayısıyla veri '
            'minimizasyonuna aykırıdır.',
          ),
          ParagraphBlock(
            'Pratikte bu şu demek: Kamerayı pakete indir, bırakma yerinin '
            'anlaşılacağı kadar yakın ve insanları gösteren ya da '
            'kimliklerini belli eden her şeyden yeterince uzak.',
          ),
          DoDontBlock(
            doTitle: 'Fotoğrafta olabilir',
            dos: [
              'Bırakma yerindeki paketin kendisi',
              'Konum referansı olarak bir parça duvar, kapı veya merdiven',
              'Eşleştirme için gerekliyse kapı numarası',
              'Bırakma izni varsa: kararlaştırılan bırakma yeri',
            ],
            dontTitle: 'Fotoğrafta olamaz',
            donts: [
              'Kişiler — alıcı bile olsa, arkadan bile olsa',
              'Park halindeki araçların plakaları',
              'Pencereler, balkonlar ve iç mekanlara bakan görüntüler',
              'Arka planda çocuklar, evcil hayvanlar, ziyaretçiler, '
                  'komşular',
              'Gönderiyle ilgisi olmayan üçüncü kişilerin isim tabelaları',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Hukuki dayanak',
            text: 'Art. 5 Abs. 1 lit. c DSGVO veri minimizasyonu ister: '
                'Veriler amaca uygun ve gerekli olanla sınırlı olmalıdır. '
                'Kişileri, plakaları veya ev içlerini gösteren bir '
                'fotoğraf “teslimat kanıtı” amacının ötesine geçer. '
                'Görüntülenen kişilerde ayrıca kendi görüntüsü üzerindeki '
                'hak devreye girer.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Fotoğrafın yeri neresi — ve neresi değil',
        blocks: [
          ParagraphBlock(
            'Fotoğrafın içeriği kadar kaydedildiği yer de önemli. Fotoğraf '
            'iş uygulamasında çekilir ve orada kalır. Özel galerinde işi '
            'yok, bir mesajlaşma uygulamasında ise hiç yok.',
          ),
          BulletsBlock([
            'Fotoğrafı yalnızca iş uygulamasında çek — önce kamera '
                'uygulamasıyla çekip sonra yüklemek yok',
            'Özel galeride kopya yok, özel telefonun bulut yedeğinde yok',
            'WhatsApp, Telegram, Signal veya bir sürücü sohbet grubu '
                'üzerinden gönderme yok',
            '“Ne olur ne olmaz” diye kendine fotoğraf saklamak yok — '
                'kanıt sistemde duruyor',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'En sık yapılan hata',
            text: 'Önce normal kamerayla fotoğraf çekip resmi sonra '
                'uygulamaya yüklemek. Böylece fotoğraf kalıcı olarak özel '
                'galerinde kalır — çoğu zaman ek olarak yurt dışındaki bir '
                'bulutta. Bu, kimseye göstermesen bile izinsiz bir '
                'işlemedir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Yine de kareye biri girdiyse',
        blocks: [
          ParagraphBlock(
            'Olur böyle şeyler: Komşu tam deklanşöre bastığın anda '
            'kapıdan çıkar veya bir çocuk kareden geçer. Bu bir felaket '
            'değil — hemen harekete geçtiğin sürece.',
          ),
          StepsBlock([
            'Stopu tamamlamadan önce fotoğrafı hemen sil',
            'Yeniden çek, bu kez karede kimse olmadan',
            'Fotoğraf zaten yüklendiyse: sistemden silinebilmesi için '
                'dispatcher’ı veya işletme yönetimini bilgilendir',
            'Birinin tanınıp tanınmadığından emin değilsen: ummak yerine '
                'bildir',
          ]),
          RevealBlock(
            prompt: 'Örnek olay: Bir paketi arka avluya bırakıyorsun. '
                'Fotoğrafta paket görünüyor — ve arka planda yere kadar '
                'inen bir pencereden, kanepede oturan iki kişiyle bir '
                'oturma odası. Stopu çoktan tamamladın ve bir sonraki '
                'avludasın. Ne yaparsın?',
            answer: 'Bildirirsin. Fotoğraf bir iç mekanı ve tanınabilir '
                'kişileri gösteriyor — böylece “teslimat kanıtı” amacının '
                'çok ötesine geçiyor ve sistemden kaldırılması gerekiyor. '
                'Akla gelen yanılgı, stop zaten tamamlandığı için hatayı '
                'bildirmenin artık anlamı olmadığıdır. Tam tersi: Şirket '
                'ancak bundan haberdar olursa fotoğrafı silebilir ve olayı '
                'belgeleyebilir. Bildiren her şeyi doğru yapar — susan ise '
                'bir ihlalin sürmesine izin verir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrol listesi Bölüm 2',
        blocks: [
          ChecklistBlock(
            title: 'Her teslimat fotoğrafından önce',
            items: [
              'Yalnızca iş uygulamasında fotoğraf çekiyorum',
              'Fotoğrafta hiçbir kişi görünmüyor',
              'Karede plaka yok, pencere yok, iç mekan yok',
              'Paket ve bırakma yeri açıkça anlaşılıyor',
              'Hiçbir fotoğraf özel galerime veya bir sohbete gitmiyor',
              'Yanlışlıkla biri kareye girdiyse: sil, yeniden çek, bildir',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ds3',
    title: 'Alıcı verileriyle çalışma',
    summary: 'El terminali, telefon ve kağıt listeler — iş araçları, özel '
        'eşya değil',
    asset: '',
    slides: [
      SafetySlide(
        title: 'El terminali ve iş telefonu özel cihaz değildir',
        blocks: [
          ParagraphBlock(
            'El terminalinde ve iş telefonunda her gün yüzlerce insanın '
            'verisi duruyor. İki cihaz da işletmeye ait ve yalnızca iş '
            'için var — molada da, eve götürdüğünde de.',
          ),
          BulletsBlock([
            'İş cihazında özel uygulama yok, özel oturum açma yok, özel '
                'bulut yok',
            'Cihazı başkasına verme — kısa süreliğine bile; ne '
                'meslektaşlara, ne aile üyelerine, ne tanıdıklara',
            'Ekran kilidini açık tut ve cihazı asla gözetimsiz bırakma',
            'Araçtan inerken: el terminalini yanına al veya güvenle '
                'sakla, koltukta görünür şekilde değil',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Kesin yasak',
            text: 'Adres listelerinin, tur özetlerinin veya alıcı '
                'verilerinin ekran görüntüsü yok. Kendine göndermek için '
                'de yok, “hatırlatma” olarak da yok. Ekran görüntüsü, '
                'sistemin dışında bir kopyadır — işletmenin artık kontrol '
                'edemediği şey tam olarak budur.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Komşulara ve yabancılara bilgi verme',
        blocks: [
          ParagraphBlock(
            'Kapıda sana sorular sorulur. Bu normaldir ve çoğunlukla iyi '
            'niyetlidir. Yine de kural şu: Yalnızca teslimat için gereken '
            'kadarını açıklarsın — fazlasını değil.',
          ),
          TableBlock(
            headers: ['Durum', 'Nereye kadar gidebilirsin'],
            rows: [
              [
                'Komşu bir paketi teslim alıyor',
                'Alıcının adını ve kapı numarasını söyle — daha fazlasına '
                    'ihtiyacı yok.',
              ],
              [
                'Komşu içinde ne olduğunu soruyor',
                'Bilgi yok. İçerik yalnızca alıcıyı ilgilendirir.',
              ],
              [
                'Biri, X kişisinin burada oturup oturmadığını soruyor',
                'Bilgi yok. Hiçbir ikamet adresini doğrulamazsın.',
              ],
              [
                'Biri, ne zaman tekrar geleceğini soruyor',
                'Genel yanıt ver, başka gönderiler veya alıcılar hakkında '
                    'bilgi verme.',
              ],
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Hukuki dayanak',
            text: 'Alıcı verilerinin üçüncü kişilere aktarılması, '
                'Art. 4 Nr. 2 DSGVO anlamında bir açıklamadır ve Art. 6 '
                'DSGVO uyarınca bir hukuki dayanak gerektirir. Komşuya '
                'teslimatta isim ve adresin söylenmesi sözleşmenin ifası '
                'için gereklidir — paket içerikleri, telefon numaraları '
                'veya başka alıcılar hakkında bilgiler için ise hiçbir '
                'dayanak yoktur.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kağıt, hafife alınan tehlikedir',
        blocks: [
          ParagraphBlock(
            'Dijital veriler en azından bir ekran kilidiyle korunuyor. '
            'Araçtaki bir kağıt korunmuyor. Ön camın arkasındaki bir tur '
            'listesi dışarıdan okunabilir — iki yüz hanenin isim ve '
            'adresleriyle birlikte.',
          ),
          BulletsBlock([
            'Kağıt listeleri asla araçta açıkta bırakma, hele camdan '
                'görünür şekilde asla',
            'Araçtan inerken listeleri yanına al veya kilitli şekilde '
                'sakla',
            'Turun sonunda: listeleri işletmede teslim et, eve götürme',
            'İmha yalnızca işletmedeki öngörülen yolla — ev çöpüne değil, '
                'benzin istasyonundaki çöp kutusuna değil',
            'İade ve hatalı paketlerin etiketlerine de listeler gibi '
                'davran',
          ]),
          RevealBlock(
            prompt: 'Örnek olay: Turu bitirdin, tur listesi artık sadece '
                'atık kağıt. Eve dönerken listeyi oturduğun binanın kağıt '
                'konteynerine atıyorsun. Bu uygun mu?',
            answer: 'Hayır. Listede isimler ve adresler var — kişisel '
                'veriler. Kimsenin geri getiremeyeceği şekilde imha '
                'edilmeleri gerekir; kural olarak işletmedeki veri koruma '
                'konteyneri veya evrak imha makinesi üzerinden. Akla gelen '
                'yanılgı, işi biten bir listenin “artık değersiz” '
                'olduğudur. Veri koruma açısından işin bitmiş olması '
                'hiçbir şeyi değiştirmez: Veriler aynıdır ve açık bir '
                'kağıt konteyneri herkesin erişebileceği bir yerdir. '
                'Üstelik listeyi zaten en baştan eve götürmemen '
                'gerekirdi.',
          ),
          DoDontBlock(
            doTitle: 'Doğru',
            dos: [
              'Listeleri işletmede teslim etmek ve orada usulüne uygun '
                  'imha etmek',
              'Araçtan inmeden önce el terminalini kilitlemek',
              'Başkalarının gönderileriyle ilgili sorularda işletme '
                  'yönetimine yönlendirmek',
            ],
            dontTitle: 'Yanlış',
            donts: [
              'Adres listelerinin ekran görüntüsünü almak veya göndermek',
              'Tur listelerini eve götürmek veya özel yolla imha etmek',
              'Alıcı verilerini komşulara, tanıdıklara veya üçüncü '
                  'kişilere aktarmak',
              'İş cihazını başka birine vermek',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrol listesi Bölüm 3',
        blocks: [
          ChecklistBlock(
            title: 'Her turun sonunda',
            items: [
              'Cihazımda adres verilerinin ekran görüntüsü yok',
              'El terminali ve iş telefonu kilitli ve güvenle saklanmış',
              'Araçta açıkta hiçbir kağıt liste yok',
              'Bütün listeler ve etiketler işletmede teslim edildi',
              'Hiçbir alıcı verisini üçüncü kişilere aktarmadım',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ds4',
    title: 'Kendi verilerin ve meslektaşlarının verileri',
    summary: 'Hastalık bildirimi, zaman kaydı, özlük dosyası — ve ilgili '
        'kişi olarak hakların',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Veri koruma seni de korur',
        blocks: [
          ParagraphBlock(
            'Sistemde yalnızca alıcıların değil, senin de verilerin var. '
            'Ve bunların bir kısmı bir teslimat adresinden çok daha '
            'hassas.',
          ),
          BulletsBlock([
            'Teslimat işinden gelen performans göstergeleri',
            'Hastalık bildirimleri ve devamsızlıklar',
            'Zaman kaydı, vardiya planları, mola süreleri',
            'Özlük dosyasındaki ehliyet ve kimlik verileri',
            'Senin veya meslektaşlarının göründüğü fotoğraflar',
          ]),
          ParagraphBlock(
            'İşletme bu verileri, iş ilişkisi için gerekli olduğu ölçüde '
            'işleyebilir. Ama onları keyfince aktaramaz — ve konu '
            'meslektaşların olduğunda sen de aktaramazsın.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Hukuki dayanak',
            text: 'Çalışan verileri, Art. 6 Abs. 1 lit. b ve f DSGVO ile '
                'bağlantılı olarak § 26 BDSG temelinde işlenir — yalnızca '
                'iş ilişkisi için gerekli olduğu ölçüde caizdir. Hastalık '
                'bildirimleri gibi sağlık verileri, Art. 9 DSGVO uyarınca '
                'özel kategorilerdir ve özellikle sıkı korunur.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Meslektaş verileri sana ait değil',
        blocks: [
          ParagraphBlock(
            'Depoda insan çok şey duyar: kimin hasta olduğunu, kimin bir '
            'turla başının derde girdiğini, kimin ihtar aldığını. Duymak '
            'başka bir şey — başkalarına anlatmak başka.',
          ),
          DoDontBlock(
            doTitle: 'Doğru',
            dos: [
              'Kendi değerlerin hakkında istediğin kadar konuşmak',
              'Bir meslektaşla yaşanan sorunu doğrudan onunla veya işletme '
                  'yönetimiyle çözmek',
              'Meslektaşlarla fotoğrafı yalnızca görünen herkes kabul '
                  'ediyorsa çekmek ve paylaşmak',
              'Gözlemlediğin ihlalleri depoda anlatmak yerine içeriden '
                  'bildirmek',
            ],
            dontTitle: 'Yanlış',
            donts: [
              'Meslektaşların performans verilerini veya değerlendirmelerini '
                  'aktarmak',
              'Bir meslektaşın hastalık nedeni hakkında konuşmak — bilsen '
                  'bile',
              'Meslektaşların fotoğraflarını veya videolarını onların '
                  'onayı olmadan sohbet gruplarında paylaşmak',
              'İç listelerden veya değerlendirmelerden ekran görüntüleri '
                  'paylaşmak',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Özellikle hassas',
            text: 'Hastalık bildirimleri. Birinin hasta olduğu bilgisi, '
                'Art. 9 DSGVO uyarınca bir sağlık verisidir. Nedeni ise '
                'daha da fazlası. İlgili kişi kendisi anlatmış olsa bile '
                'bunu diğer sürücülere aktarmak yine de caiz değildir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'İlgili kişi olarak hakların',
        blocks: [
          ParagraphBlock(
            'DSGVO sana işverenine karşı haklar verir. Onları '
            'gerekçelendirmen gerekmez ve kullanman senin aleyhine '
            'olamaz.',
          ),
          TableBlock(
            headers: ['Hak', 'Ne talep edebilirsin'],
            rows: [
              [
                'Bilgi edinme (Art. 15)',
                'Hakkında hangi verilerin ne için saklandığına dair bir '
                    'özet.',
              ],
              [
                'Düzeltme (Art. 16)',
                'Yanlış bilgilerin düzeltilmesi, örneğin yanlış bir sicil '
                    'numarası veya adres.',
              ],
              [
                'Silme (Art. 17)',
                'Artık ihtiyaç duyulmayan ve saklama süresine tabi '
                    'olmayan verilerin silinmesi.',
              ],
            ],
          ),
          ParagraphBlock(
            'Muhatabın işletme yönetimi veya şirketin veri koruma '
            'görevlisidir. Bir talebin kural olarak bir ay içinde '
            'yanıtlanması gerekir.',
          ),
          RevealBlock(
            prompt: 'Örnek olay: Bir meslektaşın, üzerinde bütün '
                'sürücülerin isim ve değerleriyle yer aldığı iç bir '
                'değerlendirmenin ekran görüntüsünü ona göndermeni rica '
                'ediyor. Sadece kendisinin nerede olduğunu görmek istiyor. '
                'Yapar mısın?',
            answer: 'Hayır. Ekran görüntüsünde bütün meslektaşların '
                'performans verileri var; bu, hukuki dayanak olmadan '
                'çalışan verisi aktarımıdır. Meslektaşının yalnızca kendi '
                'satırını görmek istemesi bir şey değiştirmez — yine de '
                'diğer herkesi görür. Doğrusu şu: Kendi değerlerini '
                'işletme yönetiminden sorar. Art. 15 DSGVO uyarınca bilgi '
                'edinme hakkı yalnızca kendi verilerini kapsar.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrol listesi Bölüm 4',
        blocks: [
          ChecklistBlock(
            title: 'Meslektaş verileriyle çalışırken',
            items: [
              'Meslektaşların performans verilerini aktarmıyorum',
              'Başkalarının hastalık bildirimleri hakkında konuşmuyorum',
              'Meslektaşların fotoğraflarını onayları olmadan '
                  'paylaşmıyorum',
              'İç değerlendirmelerden ekran görüntüsü almıyorum',
              'Kendi verilerim hakkında bilgi istediğimde kime '
                  'başvuracağımı biliyorum',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ds5',
    title: 'Bir şeyler ters giderse — veri ihlali',
    summary: '72 saatlik bildirim süresi: neden hemen bildirmek '
        'zorundasın',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Veri ihlali nedir',
        blocks: [
          ParagraphBlock(
            'Veri ihlali sadece büyük hacker saldırısı değildir. '
            'Teslimatta neredeyse her zaman küçük, gündelik aksiliklerdir '
            '— ve tam olarak bunlar da sayılır.',
          ),
          BulletsBlock([
            'İş telefonunun veya el terminalinin kaybolması ya da '
                'çalınması',
            'Paketin yanlış alıcıya verilmesi ve onun paketi açması',
            'Okunabilir adres etiketli paketin apartman girişinde veya '
                'sokakta açıkta bırakılması',
            'Fotoğrafın veya adres listesinin yanlışlıkla yanlış kişiye '
                'gönderilmesi',
            'Tur listesinin kaybolması veya araçta açıkta bırakılması',
            'El terminalinin gözetimsiz ve kilidi açık şekilde erişilebilir '
                'olması',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Pratik kural',
            text: 'Kişisel veriler, erişmemesi gereken birinin erişimine '
                'açık hale geldiği anda bu bir veri ihlalidir. Sonunda '
                'gerçekten bir zarar doğup doğmadığına sen karar vermezsin '
                '— bunu işletme inceler.',
          ),
        ],
      ),
      SafetySlide(
        title: '72 saatlik süre',
        blocks: [
          ParagraphBlock(
            'Senin için belirleyici nokta saat. Şirket bir veri ihlalini '
            'öğrendiği anda çok kısa bir süre işlemeye başlar — ve mesai '
            'bitimi, hafta sonu veya tatil olmasından bağımsız olarak '
            'işler.',
          ),
          FactsBlock([
            FactItem('72 saat', 'Art. 33 DSGVO uyarınca şirketin denetim '
                'makamına bildirim süresi'),
            FactItem('hemen', 'senin dispatcher’a veya işletme yönetimine '
                'bildirimin — aynı gün içinde'),
            FactItem('0', 'kendi hatanı hemen bildirirsen senin için '
                'doğacak olumsuz sonuç'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Hukuki dayanak',
            text: 'Art. 33 Abs. 1 DSGVO, şirketi kişisel verilerin '
                'korunmasının ihlalini öğrendikten sonra gecikmeksizin ve '
                'mümkünse 72 saat içinde denetim makamına bildirmekle '
                'yükümlü kılar. Yüksek risk varsa Art. 34 DSGVO uyarınca '
                'ayrıca ilgili kişilerin de bilgilendirilmesi gerekir. '
                'Şirket bu süreye ancak sen hemen bildirirsen uyabilir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Doğru bildirim böyle yapılır',
        blocks: [
          StepsBlock([
            'Hemen dispatcher’ı veya işletme yönetimini ara — mesai '
                'bitimini bekleme',
            'Ne olduğunu, ne zaman olduğunu ve hangi verilerin '
                'etkilendiğini söyle',
            'Verileri kimin görmüş olabileceğini söyle',
            'Kendi başına hiçbir şeyi onarma: kayıt silmek yok, habersiz '
                'geri almak yok',
            'Mümkünse durumu koru — örneğin yanlış teslim edilen paketi, '
                'nasıl ilerleneceği kararlaştırılmadan yerinden oynatma',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Bu bölümdeki en önemli şey',
            text: 'Bir hatayı hemen bildiren doğru davranır. Bildirmek '
                'açıkça istenen davranıştır ve bir yetersizlik itirafı '
                'değildir. Susmak ise küçük bir aksiliği gerçek bir '
                'soruna dönüştürür — ilgili kişiler için, işletme için ve '
                'sonunda senin için de.',
          ),
          DoDontBlock(
            doTitle: 'Doğru',
            dos: [
              'Utandırıcı olsa bile hemen bildirmek',
              'Kendi hataların dahil eksiksiz anlatmak',
              'Yapman gereken başka bir şey olup olmadığını sormak',
            ],
            dontTitle: 'Yanlış',
            donts: [
              'Acaba biri fark eder mi diye beklemek',
              'Ancak bir sonraki iş günü haber vermek',
              'Olayı küçümsemek veya bazı kısımları atlamak',
              'Paketi veya fotoğrafı kendi başına geri almaya çalışmak',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Örnek olay ve kontrol listesi',
        blocks: [
          RevealBlock(
            prompt: 'Örnek olay: Akşam, bir paketi 41 numara yerine 14 '
                'numaraya bıraktığını fark ediyorsun. Oradaki alıcı paketi '
                'çoktan açmış. Yarın sabah sessizce alıp doğru adrese '
                'teslim etmek istiyorsun — böylece kimse fark etmez. '
                'Bunun nesi yanlış?',
            answer: 'İki şey. Birincisi, veri ihlali zaten gerçekleşti: '
                'Yabancı bir kişi gönderinin adını, adresini ve içeriğini '
                'öğrendi. Bunun bildirim yükümlülüğü açısından '
                'incelenmesi gerekir ve Art. 33 DSGVO’daki 72 saatlik '
                'süre, şirketin bunu öğrendiği andan itibaren işler. '
                'İkincisi, beklemekle işletmenin yapması gerekeni tam '
                'olarak engellemiş olursun — değerlendirmeyi, '
                'belgelemeyi ve gerekirse etkilenen alıcıyı '
                'bilgilendirmeyi. Akla gelen yanılgı, sessiz bir '
                'düzeltmenin kimseye zarar vermediğidir. Gerçekte zarar '
                'verir: Olay sonradan ortaya çıkarsa şirket süresinde '
                'yapılmış bir bildirim olmadan kalır — ve sen hatayı '
                'bildirmek yerine gizlemiş olursun.',
          ),
          ChecklistBlock(
            title: 'Her veri ihlali şüphesinde',
            items: [
              'Yarın değil, aynı gün içinde bildiriyorum',
              'Ne olduğunu, ne zaman olduğunu ve hangi verilerin '
                  'etkilendiğini söylüyorum',
              'Hiçbir şeyi güzelleştirmiyorum ve hiçbir şeyi atlamıyorum',
              'Kendi başıma hiçbir girişimde bulunmuyorum',
              'Şunu biliyorum: Bildirmek doğrudur, gizlemek işleri '
                  'kötüleştirir',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'ds6',
    title: 'Sır saklama ve sadakat',
    summary: 'Dışarıya ne çıkabilir, ne çıkamaz — ve nesnel eleştiri '
        'neden açıkça serbesttir',
    asset: '',
    slides: [
      SafetySlide(
        title: 'İşletme sırları işletmede kalır',
        blocks: [
          ParagraphBlock(
            'Kişisel verilerin yanında dışarıya ait olmayan ikinci bir '
            'bilgi grubu daha var: iç rakamlar ile işletme ve ticaret '
            'sırları. Depoda gayet doğal biçimde konuşulan pek çok şey '
            'buna dahildir.',
          ),
          BulletsBlock([
            'İş verenlerle fiyatlar, koşullar ve sözleşmeler',
            'İç göstergeler ve değerlendirmeler',
            'Tur planları, rota mantığı ve kapasite rakamları',
            'İç talimatlar, eğitim belgeleri ve süreç kuralları',
            'Depodan çekilen, listelerin, ekranların veya gönderilerin '
                'seçilebildiği fotoğraflar',
          ]),
          ParagraphBlock(
            'Bu her kanalda aynı şekilde geçerlidir: yüz yüze sohbette, '
            'sosyal ağlarda ve sürücü sohbet gruplarında. Altmış '
            'sürücülü bir WhatsApp grubu özel bir konuşma değildir.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Hukuki dayanak',
            text: 'Ticari sırlar, ticari sırların korunması yasası '
                '(GeschGehG) ile korunur. Bundan bağımsız olarak iş '
                'sözleşmesinden, § 241 Abs. 2 BGB uyarınca yan yükümlülük '
                'olarak bir sır saklama yükümlülüğü doğar. Kişisel '
                'veriler için ayrıca Art. 5 Abs. 1 lit. f DSGVO uyarınca '
                'gizlilik geçerlidir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Şirket hakkında gerçek dışı iddialar',
        blocks: [
          ParagraphBlock(
            'Burada neyin serbest neyin yasak olduğu sık sık birbirine '
            'karıştırılır. Sınır “olumlu” ile “olumsuz” arasından değil, '
            'doğru ile bilerek söylenen yalan arasından, eleştiri ile '
            'aşağılama arasından geçer.',
          ),
          ParagraphBlock(
            'Şirket, yöneticiler veya meslektaşlar hakkında bilerek '
            'gerçek dışı olgu iddiaları ifade özgürlüğü kapsamında '
            'değildir. Aynısı hakaretler ve aşağılayıcı eleştiri için de '
            'geçerlidir — yani artık konunun kendisiyle değil, yalnızca '
            'birini küçük düşürmekle ilgili olan sözler.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Hukuki dayanak',
            text: 'Art. 5 Abs. 1 GG görüş açıklamalarını korur, ama '
                'bilerek gerçek dışı olgu iddialarını ve aşağılayıcı '
                'eleştiriyi korumaz. Böyle sözler § 626 BGB uyarınca '
                'derhal fesih gerekçesi olabilir. Kötüleme halinde '
                '§ 186 StGB uyarınca cezai sorumluluk eklenir; bilerek '
                'yanlış iddialarda § 187 StGB (iftira) devreye girer.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Tipik yanlış anlamalar',
            text: 'Özel bir profil, başkaları okuyabildiği anda özel '
                'değildir. Kapalı bir sohbet grubu, ondan bir ekran '
                'görüntüsü dışarı çıktığı anda korunaklı değildir. Ve '
                'söz, kanıtlanabilir biçimde doğru olmayan bir olgu '
                'iddiasıysa “bu sadece benim fikrimdi” demek işe '
                'yaramaz.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Nesnel eleştiri açıkça serbesttir',
        blocks: [
          ParagraphBlock(
            'Sınır kadar önemli olan, sınırın bu tarafında kalanlardır — '
            've bu çok şeydir. Eleştiri dile getirebilirsin; sert de olsa, '
            'rahatsız edici de olsa. Bir turun fazla sıkışık planlandığını, '
            'bir aracın kötü durumda olduğunu veya depodaki bir talimatın '
            'yanlış olduğunu söyleyebilirsin.',
          ),
          ParagraphBlock(
            'Ve gerçek aksaklıkları bildiren korumasız kalmaz: 2 Temmuz '
            '2023’ten beri ihbarcıları koruma yasası (HinSchG) yürürlükte. '
            'Yasa, ihlalleri bildiren çalışanlara karşı misillemeyi '
            'yasaklar — yani bildirim nedeniyle işten çıkarma, ihtar, '
            'yer değiştirme veya dezavantajlı konuma düşürme.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'İhbarcı koruması',
            text: 'HinSchG, mesleki bağlamda ihlal bildiren kişileri '
                'misillemeye karşı korur. Koruma yalnızca bilerek veya '
                'ağır ihmalle yapılan yanlış bildirimlerde ortadan '
                'kalkar. Yani bir aksaklığı ciddi biçimde ve bildiği '
                'kadarıyla doğru bildiren korunur — şüphe sonunda '
                'doğrulanmasa bile.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Fark tek cümlede',
            text: 'Yaşadığını anlat — kafanda kurduğunu değil. Gerçeğe '
                'uygun eleştiri korunur, uydurulmuş suçlamalar korunmaz.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Yapıcı yol',
        blocks: [
          ParagraphBlock(
            'Sürücülerin dışarıya taşıdığı hemen her şey içeride daha '
            'hızlı çözülebilirdi. Bu yüzden içerideki yol yalnızca daha '
            'güvenli değil, çoğunlukla daha etkili olandır.',
          ),
          StepsBlock([
            'Önce dispatcher’la konuş — sorunların çoğu planlama sorunudur '
                've orada çözülebilir',
            'Yanıt gelmezse: işletme yönetimiyle konuş, mümkünse yazılı, '
                'tarih ve somut olayla birlikte',
            'Daha ciddi ihlallerde: HinSchG kapsamındaki iç bildirim '
                'merciini kullan',
            'Ancak içeride hiçbir şey olmazsa dış merciler gündeme gelir — '
                'o zaman da nesnel biçimde ve kanıtlanabilir olgularla',
          ]),
          DoDontBlock(
            doTitle: 'Serbest ve istenen',
            dos: [
              'Bir turun düzenli olarak yetişilemez olduğunu söylemek',
              'Araçtaki teknik bir kusura dikkat çekmek — tekrar tekrar '
                  'da olsa',
              'Bizzat yaşadığın somut bir olayı anlatmak',
              'Bir ihlali iç bildirim mercii üzerinden bildirmek',
              'Bir bildirime yanıt gelmezse üstüne gitmek',
            ],
            dontTitle: 'Korunmayan',
            donts: [
              'Doğru olmadığını bildiğin iddialar ortaya atmak',
              'Yöneticilere veya meslektaşlara hakaret etmek ya da onları '
                  'aşağılamak',
              'İç rakamları, sözleşmeleri veya değerlendirmeleri '
                  'kamuya açmak',
              'Bilmediğin söylentileri sohbet gruplarında yaymak',
              'İçeride daha kimseye sorulmadan çatışmaları değerlendirme '
                  'portallarında veya sosyal ağlarda yürütmek',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Örnek olay ve kontrol listesi',
        blocks: [
          RevealBlock(
            prompt: 'Örnek olay: Sürücü sohbet grubunda biri, şirketin '
                'çalışılan saatleri bilerek ödemediğini yazıyor. Sen bunu '
                'hiç yaşamadın, ama o sırada vardiya planına '
                'sinirlisin ve şöyle yazıyorsun: “Doğru, hepimizi '
                'sistematik olarak dolandırıyorlar.” Ertesi gün grubun '
                'bir ekran görüntüsü elden ele dolaşıyor. Bu nasıl '
                'değerlendirilir?',
            answer: 'Kritik — eleştiri yüzünden değil, biçimi yüzünden. '
                'Kendin kanıtlayamadığın ve yaşamadığın bir olgu iddiası '
                'ortaya attın (“bizi sistematik olarak dolandırıyorlar”). '
                'Bilerek gerçek dışı olgu iddiaları ifade özgürlüğü '
                'kapsamında değildir ve § 626 BGB uyarınca derhal fesihe '
                'kadar varan iş hukuku sonuçları doğurabilir; kötüleme '
                'halinde § 186 StGB eklenir. Ekran görüntüsü ayrıca '
                'kapalı bir grubun korunaklı bir alan olmadığını '
                'gösteriyor. Doğrusu şu olurdu: kendi durumunu anlatmak — '
                '“Temmuzda iki saatim eksik, bildirdim ve şimdiye kadar '
                'yanıt almadım” — ve bunu dispatcher’a, işletme '
                'yönetimine veya iç bildirim merciine iletmek. Bu söz '
                'doğrudur, doğrulanabilir ve HinSchG ile korunur. Sonuç: '
                'Aynı memnuniyetsizlik, ama doğru dile getirilirse sana '
                'zarar veremez.',
          ),
          ChecklistBlock(
            title: 'Bir şeyi dışarıya taşımadan önce',
            items: [
              'Doğru olduğunu kendi gözlemimden biliyorum',
              'Olayı hakaret etmeden, nesnel biçimde anlatıyorum',
              'İç rakamları, sözleşmeleri veya değerlendirmeleri '
                  'açıklamıyorum',
              'Önce içeride dile getirdim — dispatcher, işletme yönetimi '
                  'veya bildirim mercii',
              'Şunu biliyorum: gerçek aksaklıkları bildirmek korunur, '
                  'uydurma iddialarda bulunmak korunmaz',
            ],
          ),
        ],
      ),
    ],
  ),
];
