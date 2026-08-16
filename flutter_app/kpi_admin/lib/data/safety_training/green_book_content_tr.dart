// lib/data/safety_training/green_book_content_tr.dart
//
// Green Book eğitiminin içerikleri — Türkçe sürüm.
// Bölümler gb1–gb6, Almanca ana sürümle birebir aynı yapıda: aynı
// slaytlar, aynı bloklar ve aynı değerler.
//
// “Green Book”, sefer kontrol defteridir: § 1 fıkra 6
// Fahrpersonalverordnung (FPersV — Almanya’nın sürücü personel
// yönetmeliği) uyarınca tutulan günlük kontrol formlarının toplamı.

import 'safety_blocks.dart';

const List<SafetyChapterContent> greenBookContentTr = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'gb1',
    title: 'Green Book nedir',
    summary: '§ 1 fıkra 6 FPersV uyarınca sefer kontrol defteri — ve '
        'senin için neden zorunlu',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Sefer defteri, araç kontrolü değil',
        blocks: [
          ParagraphBlock(
            '“Green Book” senin sefer kontrol defterindir. İçinde günlük '
            'kontrol formlarını biriktirirsin: her iş günü için bir form '
            've o formda ne zaman araç kullandığın, ne zaman mola verdiğin '
            've dinlenme sürenin ne zaman başladığı yazar.',
          ),
          ParagraphBlock(
            'Bu kesinlikle bir araç kontrolü değildir. Lastikler, ışıklar '
            've kaporta başka yerde belgelenir. Green Book’ta yalnızca '
            'süreler söz konusudur — senin sürelerin.',
          ),
          BulletsBlock([
            'Kayıt tutma zorunluluğu olan bir araç kullandığın her gün '
                'için bir form',
            'El yazısıyla, silinmez şekilde tutulur ve imzalanır',
            'Sürüş sürelerine, molalara ve dinlenme sürelerine uyduğunu '
                'kanıtlar',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Kısaca',
            text: 'Green Book tek bir soruyu yanıtlar: ne zaman direksiyon '
                'başındaydın, ne zaman değildin? Başka hiçbir şeyin orada '
                'yeri yoktur.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kimin kayıt tutması gerekir',
        blocks: [
          ParagraphBlock(
            'Zorunluluk, Fahrpersonalverordnung’un (FPersV — Almanya’nın '
            'sürücü personel yönetmeliği) § 1 fıkra 6 hükmünden gelir. Bu '
            'zorunluluk kişisel olarak sana değil, araca ve seferin amacına '
            'bağlıdır: azami yüklü ağırlığı 2,8 t üzeri ile 3,5 t arasında '
            'olan bir araçla ticari yük taşımacılığı. Yani tam olarak tipik '
            'dağıtım aracı.',
          ),
          FactsBlock([
            FactItem('2,8 t altı', '§ 1 fıkra 6 FPersV uyarınca kayıt '
                'zorunluluğu yok'),
            FactItem('2,8–3,5 t', 'günlük kontrol formu — senin Green '
                'Book’un'),
            FactItem('3,5 t ve üzeri', 'kâğıt form yerine dijital takograf'),
          ]),
          ParagraphBlock(
            'Belirleyici olan, ruhsatta (Fahrzeugschein) yazan azami yüklü '
            'ağırlıktır — aracın bugün fiilen ne kadar yüklü olduğu değil. '
            'Yarı boş bir 3,5 tonluk araç da kayıt zorunluluğuna tabidir.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Yasal dayanak',
            text: '§ 1 fıkra 6 FPersV, sürüş sürelerini, sürüş molalarını '
                'ayrıca çalışma ve dinlenme sürelerini kayıt altına almanı '
                'zorunlu kılar. Bu form olmadan yola çıkarsan yönetmeliği '
                'ihlal etmiş olursun — sürelere uyup uymadığından bağımsız '
                'olarak.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kayıt ne işe yarar',
        blocks: [
          ParagraphBlock(
            'Bu kural kendi başına bir amaç değildir. Aşırı yorgun '
            'sürücüler trafikte tehlikeli olduğu için vardır — hem kendileri '
            'hem de herkes için. Form, iş günlerinin gerçekten uyulabilir '
            'şekilde planlanıp planlanmadığını görünür kılar.',
          ),
          BulletsBlock([
            'Yorgunluğa karşı koruma: molayı belgelemek zorunda olan onu '
                'gerçekten de daha çok yapar',
            'Senin için kanıt: form doğru çalıştığını gösterir — aylar '
                'sonra bile',
            'İddialara karşı kanıt: kayıt yoksa senin hatırladıkların '
                'denetimin varsayımına karşı kalır',
            'Tur planlaması için temel: sürekli çok sıkışık planlanan '
                'turlar formda göze çarpar',
          ]),
          RevealBlock(
            prompt: 'Uygulama örneği: bugün sürelere uydun — mola zamanında, '
                'paydos zamanında. Sadece formu doldurmadın, çünkü zaten her '
                'şey yolundaydı. Öğleden sonra denetim. Bu bir sorun mu?',
            answer: 'Evet. Kayıt zorunluluğu şu demektir: kanıtın kendisi '
                'zorunluluktur. Sürelere fiilen uyup uymadığını yol '
                'denetiminde kimse tespit edemez — ortada gösterilecek bir '
                'şey yoktur. Denetimin bakışıyla eksik bir form, aşılmış bir '
                'süreyle tamamen aynı şekilde değerlendirilir: bir ihlal '
                'vardır ve cezalandırılır. Kurallara uyman ancak '
                'kanıtlayabilirsen işine yarar.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrol listesi: temel anlayış',
        blocks: [
          ChecklistBlock(
            title: '1. bölümden yanıma alıyorum',
            items: [
              'Green Book’un aracın durumunu değil süreleri belgelediğini '
                  'biliyorum',
              'Yasal dayanağı biliyorum: § 1 fıkra 6 FPersV',
              '2,8 t üzeri ile 3,5 t arası araçların kapsandığını biliyorum',
              'Güncel yük ağırlığının değil, azami yüklü ağırlığın '
                  'sayıldığını biliyorum',
              '3,5 t ve üzerinde dijital takografın geçerli olduğunu '
                  'biliyorum',
              'Eksik bir formun tek başına da ihlal olduğu benim için açık',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Tur için bir cümle',
            text: '“Yazmadığımı kanıtlayamam.”',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'gb2',
    title: 'Tam olarak ne yazılır',
    summary: 'Tüm zorunlu alanlar — ve onları nasıl temiz doldurursun',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Formdaki zorunlu bilgiler',
        blocks: [
          ParagraphBlock(
            'Bir günlük kontrol formu, ancak öngörülen tüm bilgiler üzerinde '
            'yazıyorsa kanıttır. Bunlardan biri eksikse form tamamlanmamış '
            'sayılır — eksik bir formla aynı sonuçları doğurur.',
          ),
          BulletsBlock([
            'Sürücünün soyadı, adı ve adresi',
            'Aracın resmî plakası',
            'Günün tarihi',
            'Seferin başındaki ve sonundaki kilometre değeri',
            'Seferin başlangıç yeri ve bitiş yeri',
            'Saat bilgisiyle sürüş ve dinlenme süreleri',
            'Sürüş molaları',
            'Senin imzan',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Eksiksiz, eksiksiz demektir',
            text: '§ 1 fıkra 6 FPersV bilgileri sınırlı olarak sayar. '
                'Plakasız, adressiz veya imzasız bir form kayıt '
                'zorunluluğunu yerine getirmez — süreler doğru yazılmış olsa '
                'bile.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Adım adım doldurma',
        blocks: [
          ParagraphBlock(
            'Aşağıdaki sıra, hiçbir şeyi unutmayacak şekilde bilinçli '
            'seçildi: önce sabit bilgiler, sonra gün içindeki süreler, en '
            'sonda kapanış.',
          ),
          StepsBlock([
            'Yola çıkmadan önce: tarihi, soyadı, adı, adresi ve plakayı '
                'yaz',
            'Kilometre değerini göstergeden oku ve başlangıç değeri olarak '
                'yaz — tahmin etme',
            'Seferin başlangıç yerini yaz (depo, lokasyon, yer adı)',
            'Yola çıkar çıkmaz sürüş süresinin başlangıcını saatiyle yaz',
            'Her sürüş molasını başlangıç ve bitişiyle hemen yaz — akşama '
                'bırakma',
            'Tur sonunda: seferin bitiş yerini ve bitiş kilometre değerini '
                'yaz',
            'Sürüş süresinin bitişini ve dinlenme süresinin başlangıcını '
                'yaz',
            'Formu baştan sona oku, boşluk var mı diye kontrol et ve imzala',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Silinmez şekilde yaz',
            text: 'Tükenmez kalem, kurşun kalem değil. Silgiyle '
                'silinebilen bir kayıt kanıt değildir. Yazım hatası bir kez '
                'çizilir ve yanına yeniden yazılır — üzeri kapatılmaz, '
                'bant yapıştırılmaz.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Süreleri temiz yazmak',
        blocks: [
          ParagraphBlock(
            'En çok süreler yanlış gider. Günün her süre bloğu kendi '
            'satırına, saat olarak başlangıç–bitiş biçiminde girer. Normal '
            'bir dağıtım günü şöyle görünür:',
          ),
          TableBlock(
            headers: ['Başlangıç–bitiş', 'Tür', 'Açıklama'],
            rows: [
              ['06:30–07:00', 'Çalışma süresi', 'Depoda yükleme, henüz '
                  'sürüş süresi değil'],
              ['07:00–11:30', 'Sürüş süresi', '4,5 saat — mola şimdi '
                  'gerekiyor'],
              ['11:30–12:15', 'Sürüş molası', 'kesintisiz 45 dakika'],
              ['12:15–16:45', 'Sürüş süresi', 'ikinci blok, toplam 9 saat'],
              ['16:45–17:15', 'Çalışma süresi', 'teslim, iadeler, kapanış'],
              ['17:15’ten itibaren', 'Dinlenme süresi', 'sonraki başlangıca '
                  'kadar en az 11 saat'],
            ],
          ),
          BulletsBlock([
            'Sürüş süresi, yalnızca araç hareket hâlindeyken direksiyon '
                'başında geçen süredir',
            'Yükleme ve boşaltma, tarama, durakta bekleme çalışma '
                'süresidir, ama sürüş süresi değildir',
            'Bir sürüş molası, ancak o süre içinde gerçekten çalışmıyorsan '
                'moladır',
          ]),
          RevealBlock(
            prompt: 'Uygulama örneği: rampada 40 dakika duruyorsun ve '
                'boşaltılmasını bekliyorsun. Kabinde oturuyorsun ve hiçbir '
                'şey '
                'yapmıyorsun. Bunu sürüş molası olarak yazabilir misin?',
            answer: 'Yalnızca o süre üzerinde gerçekten serbestçe '
                'tasarrufta bulunabiliyorsan ve hiçbir iş görmüyorsan — ve '
                'bunu önceden biliyorsan. Her an hazır olman gerekiyorsa, '
                'çünkü hemen devam edilebilir, bu bekleme süresidir, mola '
                'değil. Akla ilk gelen yanılgı: “Hiçbir şey yapmadım, demek '
                'ki moladaydım.” Belirleyici olan hareket edip etmemen '
                'değil, o süre üzerinde tasarrufta bulunup '
                'bulunamamandır. Tereddüt hâlinde çalışma süresi olarak '
                'yazarsın — bu her zaman güvenli taraftır.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrol listesi: form eksiksiz mi?',
        blocks: [
          ChecklistBlock(
            title: 'İmzalamadan önce',
            items: [
              'Soyadı, adı ve adres yazılı',
              'Plaka, kullandığım araçla uyuşuyor',
              'Tarih yazılı',
              'Başlangıç ve bitiş kilometre değerleri göstergeden okundu',
              'Seferin başlangıç ve bitiş yeri yazılı',
              'Tüm sürüş süreleri saat olarak başlangıç–bitiş yazıldı',
              'Tüm sürüş molaları yazıldı',
              'Dinlenme süresinin başlangıcı yazıldı',
              'Her şey tükenmez kalemle, silinti yok, boşluk yok',
              'İmza atıldı',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'gb3',
    title: 'Sürüş süreleri, molalar, dinlenme süreleri',
    summary: 'İş gününün uyması gereken sayılar',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Önemli olan sayılar',
        blocks: [
          ParagraphBlock(
            'Green Book süreleri belgeler — ama yalnızca sınırlara uyup '
            'uymadığın izlenebilsin diye. Bu sınırları kâğıtta değil, '
            'kafanda taşıman gerekir.',
          ),
          FactsBlock([
            FactItem('9 s', 'kural olarak günlük sürüş süresi'),
            FactItem('10 s', 'istisna olarak haftada iki kez izinli'),
            FactItem('4,5 s', 'kesintisiz sürüş, sonrasında mola gerekir'),
          ]),
          FactsBlock([
            FactItem('45 dk', '4,5 saatten sonra sürüş molası'),
            FactItem('15 + 30', 'izin verilen bölme — bu sırayla'),
            FactItem('11 s', 'günlük dinlenme süresi, en az'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Kuralın istediği',
            text: 'Sürüş süresi günde en fazla 9 saattir, haftada iki kez '
                '10 saate uzatılabilir. En geç 4,5 saat sürüşten sonra en '
                'az 45 dakikalık bir sürüş molası verilmelidir. Günlük '
                'dinlenme süresi en az 11 saattir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Molayı doğru yerleştirmek',
        blocks: [
          ParagraphBlock(
            '45 dakika normal durumdur. Bunu bölebilirsin — ama yalnızca '
            'tam olarak iki parçaya ve yalnızca belirli bir sırayla: önce '
            'en az 15 dakika, sonra en az 30 dakika. Tersi geçerli '
            'sayılmaz.',
          ),
          DoDontBlock(
            doTitle: 'Mola böyle geçerlidir',
            dos: [
              'En geç 4,5 saat sürüşten sonra kesintisiz 45 dakika',
              'Ya da önce 15 dakika, sonra 30 dakika',
              'Her iki parça da aynı 4,5 saatlik blok içinde',
              'Her iki parça da forma saat olarak başlangıç–bitiş yazılır',
            ],
            dontTitle: 'Böyle sayılmaz',
            donts: [
              'Önce 30 dakika, sonra 15 dakika — yanlış sıra',
              'Her biri 15 dakikalık üç kısa mola',
              'İki kez 20 dakika — ikinci parça çok kısa',
              'Durak daha uygun geldi diye molayı ancak 5 saat sürüşten '
                  'sonra vermek',
            ],
          ),
          BulletsBlock([
            '4,5 saat saf sürüş süresidir — teslimat yapılan duraklar '
                'sayılmaz',
            'Mola, sınırın aşılmasından önce olmalıdır, sonra değil',
            'Tam mola tamamlandıktan sonra yeni bir 4,5 saatlik blok '
                'başlar',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'En sık yapılan düşünce hatası',
            text: 'Mola, 4,5 saattir görevde olduğunda değil, 4,5 saat araç '
                'kullandığında gerekir. Görev süresine göre hesaplayan '
                'molayı çoğunlukla çok erken verir — ve sonra bir kez de '
                'çok geç.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dağıtım gününde hesap',
        blocks: [
          ParagraphBlock(
            'Günlük işte tek bir blokla değil, duraklar arasındaki birçok '
            'kısa yolculukla hesap yaparsın. Onları topla — sürüş süreni '
            'onlar oluşturur.',
          ),
          RevealBlock(
            prompt: 'Uygulama örneği: saat 07:00’de başlıyorsun. 09:30’a '
                'kadar 2 saat direksiyon başındasın, kalanı duraklarda. '
                '12:00’ye kadar 2 saat daha sürüş süresi ekleniyor, 13:00’e '
                'kadar bir 30 dakika daha. Molan en geç ne zaman gerekir?',
            answer: 'Saat 13:00’te. O anda 2 + 2 + 0,5 = 4,5 saat saf sürüş '
                'süresine ulaşmış olursun — sürüş molasını tamamlamadan '
                'artık bir metre bile gidemezsin. Akla ilk gelen yanılgı, '
                '07:00’den itibaren altı saat görev süresi hesaplayıp '
                'molayı 11:30’a koymak olurdu. Sayılan saat, yalnızca araç '
                'hareket hâlindeyken işler.',
          ),
          RevealBlock(
            prompt: 'Uygulama örneği: bu hafta zaten iki kez 10 saat araç '
                'kullandın. Bugün cuma, 8,5 saat sürüş süresindesin ve '
                'toplam yaklaşık 40 dakikalık iki durağın daha var. Bu hâlâ '
                'olur mu?',
            answer: 'Hayır. 10 saate uzatmayı haftada yalnızca iki kez '
                'kullanabilirsin ve bunlar tükendi. Bugün yeniden 9 saatlik '
                'kural sınırı geçerli — yani sana 40 değil, 30 dakika sürüş '
                'süresi kalır. Ulaşabildiğin durağa gidersin, kalanı '
                'sevkiyat sorumlusuna bildirirsin ve sürüş süresini '
                'bitirirsin. Akla ilk gelen yanılgı: “10 saat her gün benim '
                'hakkım.” O, haftalık kontenjanı olan bir istisnadır.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrol listesi: süreler kontrolde',
        blocks: [
          ChecklistBlock(
            title: '3. bölümden yanıma alıyorum',
            items: [
              '9 saat sürüş süresinin kural olduğunu biliyorum',
              '10 saatin yalnızca haftada iki kez izinli olduğunu biliyorum',
              '4,5 saati görev süresi olarak değil, saf sürüş süresi olarak '
                  'sayıyorum',
              'En az 45 dakika sürüş molası veriyorum',
              'Molayı en fazla 15 + 30 dakika olarak, bu sırayla bölüyorum',
              'En az 11 saat günlük dinlenme süresine uyuyorum',
              'Her molayı akşam değil, hemen yazıyorum',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Aklında kalsın',
            text: '4,5 – 45 – 9 – 11. Gününü yapılandıran dört sayı. '
                'Bunları bilenin hesap yapmasına gerek kalmaz, yalnızca '
                'yazması yeter.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'gb4',
    title: 'Doldururken yapılan tipik hatalar',
    summary: 'Her denetimde göze çarpan altı hata',
    asset: '',
    slides: [
      SafetySlide(
        title: 'En sık yapılan altı hata',
        blocks: [
          ParagraphBlock(
            'İtiraza konu olan formların neredeyse tamamı sürelerden değil, '
            'tutuluş biçiminden dolayı kalır. Bu altı hata, başka türlü '
            'doğru olan bir formu değersiz kılar.',
          ),
          DoDontBlock(
            doTitle: 'Formu böyle doğru tutarsın',
            dos: [
              'Her kaydı süre bloğu biter bitmez hemen yaparsın',
              'Tükenmez kalem kullanırsın, silinmez şekilde',
              'Molaları gerçek saatiyle başlangıç–bitiş olarak yazarsın',
              'Kilometre değerini göstergeden okursun',
              'Gün sonunda imzalarsın',
              'Form araçta, senin yanında kalır',
            ],
            dontTitle: 'Form böyle itiraza uğrar',
            donts: [
              'Bütün haftayı cuma akşamı sonradan yazmak',
              '“Sonra düzeltirim” diye kurşun kalemle yazmak',
              'Molaları tahmin etmek (“aşağı yukarı üç çeyrek saat”)',
              'Kilometre değerini akıldan yazmak',
              'İmzayı unutmak',
              'Formları evde ya da depoda bırakmak',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'En pahalı hata, en rahat olanıdır',
            text: 'Sonradan doldurmak zararsız gibi hissettirir — en hızlı '
                'ortaya çıkan ve en ağır basan hata odur.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Sonradan yazmalar neden göze çarpar',
        blocks: [
          ParagraphBlock(
            'Tek seferde sonradan yazılmış bir form, gün boyunca oluşmuş '
            'bir formdan farklı görünür. Denetçiler her gün ikisini de '
            'görür ve farkı anında anlar.',
          ),
          BulletsBlock([
            'Bütün satırlarda aynı el yazısı, aynı kalem, aynı bastırma',
            'Dikkat çekecek kadar yuvarlak süreler: her şey tam ve buçuk '
                'saatlerde biter',
            'Yazılan güzergâha uymayan kilometre değerleri',
            'İrsaliyelere, taramalara veya yakıt fişlerine ters düşen '
                'bilgiler',
            'Her zaman tam 45 dakika süren molalar — bunun mümkün olmadığı '
                'günlerde bile',
          ]),
          ParagraphBlock(
            'Buna bir de şu eklenir: işletmede yapılan bir denetimde '
            'formlar diğer belgelerin yanında durur. Çelişkiler senin değil, '
            'kurumun gözüne çarpar.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Yanlış, boştan daha kötüdür',
            text: 'Eksik bir form, kayıt zorunluluğunun ihlalidir. Bilerek '
                'yanlış doldurulmuş bir form ise bundan fazlasıdır — orada '
                'artık yalnızca bir kabahat değil, aldatma sorunu söz '
                'konusudur. Bir süreyi uydurmaktansa fazla araç '
                'kullandığını yazmak daha iyidir.',
          ),
          RevealBlock(
            prompt: 'Uygulama örneği: perşembe günü, salı günkü öğle '
                'molasının yazılmadığını fark ediyorsun. Tam olarak '
                'hatırlıyorsun: 12:10 – 12:55. Ne yaparsın?',
            answer: 'Onu sonradan yazarsın — ama görünür biçimde sonradan '
                'yazma olarak, ekleme tarihiyle ve kısa bir notla, ayrıca '
                'sevkiyat sorumluna haber verirsin. Dürüst ve fark edilir '
                'bir düzeltme yapılabilir ve boşluktan açıkça daha iyidir. '
                'Akla ilk gelen yanılgı, kaydı sanki salı günü yazılmış gibi '
                'araya sokmak olurdu — ihmalden sahteciliğe geçiş tam olarak '
                'budur.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrol listesi: temiz tutuldu',
        blocks: [
          ChecklistBlock(
            title: 'Formum bir denetime dayanır',
            items: [
              'Her süre bloğunu akşam değil, hemen yazıyorum',
              'Tükenmez kalemle yazıyorum',
              'Saatleri ve kilometre değerlerini tahmin etmek yerine '
                  'okuyorum',
              'Her formu imzalıyorum',
              'Formlarım hep araçta, yanımda',
              'Düzeltmeleri görünür ve tarihli yapıyorum, asla gizlice '
                  'değil',
              'Bir süreyi uydurmaktansa bir ihlali yazmayı tercih ederim',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'gb5',
    title: 'Yanında bulundurma, teslim etme, saklama',
    summary: 'Sürücüde 28 gün, işletmede bir yıl',
    asset: '',
    slides: [
      SafetySlide(
        title: 'İki süre',
        blocks: [
          ParagraphBlock(
            'Doldurulmuş form, ancak doğru anda doğru yerdeyse bir değer '
            'taşır. Bunun için birbirinden ayırman gereken iki süre '
            'vardır.',
          ),
          FactsBlock([
            FactItem('28 gün', 'sürücü kayıtları yanında bulundurur'),
            FactItem('1 yıl', 'işveren onları işletmede saklar'),
          ]),
          BulletsBlock([
            '28 gün seni ilgilendirir: içinde bulunulan günün ve önceki 28 '
                'günün kayıtlarını yanında bulundurmalısın',
            'Bir yıllık süre işletmeyi ilgilendirir: formları bir yıl '
                'saklamalı ve istendiğinde ibraz etmelidir',
            'İkisi aynı anda geçerlidir — formlar ancak yanında bulundurma '
                'yükümlülüğü bittikten sonra arşive gider',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Yanında bulundurma yükümlülüğü',
            text: 'Son 28 günün kayıtları araca aittir — dolaba, eve ya da '
                'ofise değil. Denetimde eksiklerse, düzgün tutulmuş olmaları '
                'işe yaramaz.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Yol denetimi',
        blocks: [
          ParagraphBlock(
            'Denetimi BAG — Bundesamt für Logistik und Mobilität, Federal '
            'Lojistik ve Hareketlilik Dairesi — ve polis yapar. İkisi de yol '
            'kenarında denetleyebilir, BAG ayrıca işletmede de.',
          ),
          StepsBlock([
            'Kenara çek, motoru kapat, camı indir, ellerini görünür tut',
            'Sakin kal — denetim rutindir, şüphe değil',
            'Ehliyeti, araç belgelerini ve son 28 günün kayıtlarını ibraz '
                'et',
            'Sorulara olgusal biçimde yanıt ver, bir şey uydurma ve '
                'süsleme',
            'Bir itiraz durumunda: işlemi tutanağa geçirt, tartışma',
            'Sonrasında sevkiyat sorumluna haber ver ve olayı işletmede '
                'belgele',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Hazırlık, açıklamayı yener',
            text: 'Formlar eksiksiz olarak araçtaysa denetim birkaç dakika '
                'sürer. Bunun dışındaki her şey sana ve işletmeye bütün bir '
                'öğleden sonraya mal olur.',
          ),
          RevealBlock(
            prompt: 'Uygulama örneği: yol kenarında denetçi son 28 günü '
                'soruyor. Yanında yalnızca bu haftanınkiler var — daha eski '
                'formları usulüne uygun olarak depoda teslim ettin. Bu '
                'yeterli mi?',
            answer: 'Hayır. Yanında bulundurma yükümlülüğü, içinde '
                'bulunulan günü ve önceki 28 günü kapsar. Eski formların '
                'işletmede düzgünce durması saklama yükümlülüğünü yerine '
                'getirir, ama yanında bulundurma yükümlülüğünü değil — '
                'bunlar birbirinden ayrı iki yükümlülüktür. Doğrusu şudur: '
                'son 28 günün kopyaları ya da asılları sende kalır, ancak '
                'ondan sonra arşive giderler. Bunu işletmede nasıl '
                'düzenlediğinizi sevkiyat sorumlunla netleştir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'İşletmede teslim',
        blocks: [
          ParagraphBlock(
            'İşveren saklama yükümlülüğünü ancak formları eline geçerse '
            'yerine getirebilir. Bu yüzden teslim etmek bir evrak işi değil, '
            'senin kayıt zorunluluğunun bir parçasıdır.',
          ),
          BulletsBlock([
            'Formları, yanında bulundurma süresi dolduktan sonra eksiksiz '
                'teslim et, ay sonunda toplu hâlde değil',
            'Hiçbir şeyi atma, hatalı ya da düzeltmeli formları bile',
            'Bir form eksikse hemen söyle — bildirilen bir boşluk, '
                'keşfedilen bir boşluktan iyidir',
            'İzin, hastalık ve büro günlerini öylece atlama, işletmenin '
                'talimatına göre işaretle',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Boşluklar boşluk olarak kalır',
            text: 'Formu olmayan bir gün sonradan yeniden oluşturulamaz. '
                'Teslimi savsaklayan, tam da işletme denetiminde göze çarpan '
                'boşlukları üretir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrol listesi: belgeler kontrolde',
        blocks: [
          ChecklistBlock(
            title: 'Her vardiyadan önce ve her haftadan sonra',
            items: [
              'Son 28 günün kayıtları araçta',
              'Bugünkü form başlatıldı ve elimin altında',
              'Ehliyet ve araç belgeleri yanımda',
              'Süresi dolan formları işletmede teslim ettim',
              'Hiçbir formu atmadım, düzeltmeli olanları bile',
              'Bir denetimde kimi bilgilendirmem gerektiğini biliyorum',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'gb6',
    title: 'İhlallerin sonuçları',
    summary: 'Para cezası, işletmenin sorumluluğu, iç yaptırım basamakları',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Hukuken ne riski var',
        blocks: [
          ParagraphBlock(
            'Eksik olan ya da tamamlanmamış bir günlük kontrol formu bir '
            'kabahattir. Para cezasının ne kadar olacağı, ihlalin ne kadar '
            'ağır olduğuna ve ne sıklıkta yapıldığına bağlıdır.',
          ),
          FactsBlock([
            FactItem('100 €’dan itibaren', 'eksik ya da tamamlanmamış '
                'formlarda para cezası'),
            FactItem('ağırlığa göre', 'birden çok ya da tekrarlanan '
                'ihlallerde daha yüksek tutarlar'),
          ]),
          BulletsBlock([
            'Yalnızca sürücü etkilenmez — kayıtlardan işletme de sorumludur',
            'Ağır ya da tekrarlanan ihlallerde işletmenin güvenilirliğine '
                'ilişkin bir işlem başlatılabilir',
            'Denetimi BAG ve polis yapar, yol kenarında ve işletmede',
            'İşletme denetiminden çıkan itirazlar yalnızca denetlenen '
                'sürücüyü değil, tüm sürücüleri ilgilendirir',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'İki muhatap, tek yükümlülük',
            text: 'FPersV sürücüyü ve işvereni birlikte yükümlü kılar: sen '
                'kayıt tutmak ve yanında bulundurmak zorundasın, işletme '
                'saklamak ve denetlemek zorundadır. Bunlardan biri aksarsa, '
                'sorumlu olan taraf hesap verir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'İşletme içindeki yaptırım basamakları',
        blocks: [
          ParagraphBlock(
            'Bir kurumun bir şey tespit edip etmediğinden bağımsız olarak, '
            'işletmede sabit bir sıra geçerlidir. Herkes için aynıdır ve '
            'belgelenir.',
          ),
          StepsBlock([
            'Birinci basamak: sevkiyat sorumlusundan sözlü uyarı',
            'İkinci basamak: özlük dosyasına yazılı ihtar',
            'Üçüncü basamak: iş akdinin feshine kadar varan iş hukuku '
                'sonuçları',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'İhlal, eksik formun kendisidir',
            text: 'Basamaklar, bir şey olup olmadığından ya da denetim '
                'yapılıp yapılmadığından bağımsız işler. Tutulmamış form '
                'başlı başına ihlaldir.',
          ),
          RevealBlock(
            prompt: 'Uygulama örneği: sevkiyat sorumlusu bastırıyor: “Şu iki '
                'durağı da yap, molayı da öylece yaz, yoksa '
                'yetişemeyeceğiz.” Ne geçerlidir?',
            answer: 'Talimat senin yükümlülüğünü değiştirmez. Kaydı tutan ve '
                'imzalayan sensin — imzanla içeriği onaylarsın. Sözlü bir '
                'talimat seni ne denetimde ne de sonradan işletmede korur. '
                'Doğrusu şudur: molanı ver, doğru yaz, kalan durakları '
                'bildir ve talimatı belgele. İşletme kurallara uymayı '
                'mümkün kılmakla yükümlüdür — onları atlatmakla değil.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kontrol listesi: kapanış',
        blocks: [
          ChecklistBlock(
            title: 'Bu eğitimden yanıma alıyorum',
            items: [
              'Green Book, § 1 fıkra 6 FPersV uyarınca sefer kontrol '
                  'defteridir',
              'Tüm zorunlu bilgileri biliyorum ve eksiksiz dolduruyorum',
              '9 s sürüş süresine, molaya kadar 4,5 s’ye, 45 dk molaya ve '
                  '11 s dinlenmeye uyuyorum',
              'Hemen yazıyorum, tükenmez kalemle, ve imzalıyorum',
              'Son 28 günün kayıtlarını yanımda bulunduruyorum',
              'Süresi dolan formları işletmede teslim ediyorum',
              'Eksik bir formun 100 avrodan başlayan bir para cezasına yol '
                  'açabileceğini biliyorum',
              'Bir talimatın kayıt zorunluluğumu ortadan kaldırmadığını '
                  'biliyorum',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Tur için bir cümle',
            text: '“Form ben araç kullanırken benimle birlikte yazar — '
                'işim bittiğinde değil.”',
          ),
        ],
      ),
    ],
  ),
];
