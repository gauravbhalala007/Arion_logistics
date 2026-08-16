// lib/data/safety_training/safety_texts_tr.dart
//
// Güvenlik eğitimi — Türkçe metinler. safety_texts_de.dart ile aynı
// anahtar kümesi.

const Map<String, String> safetyTextsTr = {
  'ask_anytime':
      'Sorun mu var? İstediğin zaman yöneticine, dispatcher’ına veya firma yönetimine başvurabilirsin — yanlış yapmaktansa bir kez fazla sormak daha iyidir.',
  // ── Meta / UI ──
  'training_title': 'Güvenlik eğitimi',
  'training_subtitle': 'Kuryeler için iş güvenliği — yıllık eğitim',
  'training_intro':
      'Bu eğitim seni korur: yaklaşık 15–20 dakikada güvenli çalışma ve '
      'sürüş için en önemli kuralları öğreneceksin. Sonunda kısa bir test '
      'var (20 soru, geçmek için %80) ve katılımını imzanla onaylıyorsun.',
  'chapters_overview_title': 'Bölümler',
  'chapters_overview_hint': 'Bölümleri sırayla çalış. Tüm bölümleri okuduğunda test açılır.',
  'chapter_pages': '{n} sayfa',
  'btn_overview': 'Genel bakış',
  'btn_chapter_done': 'Bölümü tamamla',
  'btn_test_locked': 'Önce tüm bölümleri oku',
  'chapter_label': 'Bölüm {n} / {m}',
  'btn_start': 'Eğitime başla',
  'btn_next': 'Devam',
  'btn_back': 'Geri',
  'btn_start_test': 'Teste git',
  'btn_submit_test': 'Cevapları kontrol et',
  'btn_retry': 'Tekrar dene',
  'btn_finish': 'Bitir',
  'test_title': 'Bitirme testi',
  'test_intro':
      '20 soru — geçmek için en az %80 (16 doğru). Testi istediğin kadar '
      'tekrarlayabilirsin.',
  'test_passed': 'Geçtin — {total} sorudan {score} doğru!',
  'test_failed':
      'Geçemedin ({total} sorudan {score}). Bölümleri tekrar gözden geçir ve '
      'yeniden dene.',
  'signature_title': 'Katılımı onayla',
  'signature_hint':
      'İmzanla eğitime katıldığını ve içeriği anladığını onaylıyorsun. Soru '
      'sorma imkânın oldu.',
  'confirm_checkbox': 'Eğitimi anladım ve katılımımı onaylıyorum.',
  'btn_clear': 'Temizle',
  'btn_sign_submit': 'İmzala ve bitir',
  'cert_done_title': 'Eğitim tamamlandı!',
  'cert_done_body':
      'Belgen oluşturuldu ve belgelerine kaydedildi. Eğitim 12 ay '
      'geçerlidir.',
  'status_valid_until': '{date} tarihine kadar geçerli',
  'status_expired': 'Süresi doldu — lütfen tekrar yap',
  'status_open': 'Henüz tamamlanmadı',

  // ── Bölümler ──
  'ch01_title': 'Temeller ve senin yükümlülüklerin',
  'ch01_body': 'İş güvenliği yasayla düzenlenmiştir (İş Güvenliği Kanunu + '
      'DGUV yönetmelikleri) ve yaşamını ve sağlığını korur. Senin de '
      'yükümlülüklerin var:\n'
      '• İşverenin çalışma talimatlarına uy\n'
      '• Kazaları ve ramak kala olayları hemen bildir\n'
      '• İlk yardım yap veya destek ol\n'
      '• Arıza ve eksiklikleri bildir (ör. bozuk kablolar, arızalı '
      'cihazlar)\n'
      '• Koruyucu donanımı (güvenlik ayakkabısı, eldiven, reflektörlü yelek) '
      'amacına uygun kullan\n'
      '• Alkol yok, uyuşturucu yok, etkileyen ilaç yok — ne kendini ne de '
      'başkalarını tehlikeye atabilirsin.',
  'ch02_title': 'Çalışma talimatları',
  'ch02_body': 'Çalışma talimatları; araç, ekipman ve tehlikeli maddelerin '
      'kullanımı için işverenin bağlayıcı kurallarıdır.\n'
      '• Seni kazalardan ve sağlık zararlarından korur\n'
      '• İhlal eden, kaza durumunda sorumluluğu paylaşma riski taşır\n'
      '• Günlük sürüşten örnekler: insanların yakınında geri manevra sadece '
      'yönlendirici ile · aracı terk ederken her zaman kilitle · çekme '
      'sadece çeki demiri ile · her kazayı derhal bildir\n'
      '• Bir talimat sana açık değilse sor — çalışmaya başlamadan önce.',
  'ch03_title': 'Güvenli çalışma için 10 kural',
  'ch03_body': 'Bu on kural her gün geçerlidir:\n'
      '1. Güvenli ve dikkatli çalış\n'
      '2. Her yolculuktan önce araç kontrolü\n'
      '3. Yükü araçta emniyete al\n'
      '4. Profesyonel sür, trafik kurallarına uy\n'
      '5. Emniyet kemerini her zaman tak\n'
      '6. Aracı, aletleri ve ekipmanı düzenli tut\n'
      '7. Sadece uygun ayakkabıyla çalış\n'
      '8. Meslektaşlarına ve müşterilere nazik davran\n'
      '9. Mola kurallarına uy\n'
      '10. Herkese hoşgörülü ve saygılı davran',
  'ch04_title': 'Güvenlik ayakkabısı ve koruyucu donanım',
  'ch04_body': 'İşveren tarafından verilen güvenlik ayakkabıları '
      'giyilmelidir — bu zorunludur (§ 15 ArbSchG).\n'
      '• Düşen paketlere, çarpmalara, sivri cisimlere basmaya, ıslaklığa ve '
      'kaymaya karşı korur\n'
      '• Koruma sınıfları: S1 (antistatik, yakıta dayanıklı taban) · S2 (ek '
      'olarak en az 60 dakika su geçirmez) · S3 (ek olarak delinmeye '
      'dayanıklı, profilli taban)\n'
      '• Ayakkabılarını düzenli kontrol et: aşınmış diş veya hasar → '
      'değişim iste\n'
      '• Özellikle rampalarda, engebeli yollarda, roll konteyner ve transpalet '
      'kullanırken önemli\n'
      '• Reflektörlü yeleği araçta elinin altında tut — arıza ve kazada '
      'zorunlu.',
  'ch05_title': 'Yangın durumunda davranış',
  'ch05_body': 'Yangın söndürücü kullanımı: 1. pimi çek · 2. tetik düğmesine '
      'bas · 3. tabancaya bas.\n'
      '• Rüzgâr yönünde söndür, yüzey yangınlarını önden başlayarak, art '
      'arda değil aynı anda birden fazla söndürücüyle\n'
      '• Bir söndürücü sadece saniyeler dayanır (6 kg toz: 15–23 s) — '
      'kullanılmış söndürücüleri mutlaka doldurt\n'
      '• Araç yangını: tünellerde veya köprülerde DURMA — mümkünse dışarı '
      'çık, sonra dörtlüler, dur, in\n'
      '• Hemen itfaiyeyi ara 112: Nerede? Ne yanıyor? Yaralı var mı? Yükün '
      'ne? Telefonu kapatma — merkez görüşmeyi bitirir\n'
      '• Motor kapağını sadece eldivenle ve az arala — oksijen nedeniyle '
      'alev tehlikesi.',
  'ch06_title': 'İlk yardım',
  'ch06_body': 'Herkes yasal olarak ilk yardım yapmakla yükümlüdür '
      '(§ 323c StGB) — makul ölçüde.\n'
      '• Yardım eden yanlış yapmaz: ilk yardımcı olarak sigortalısın ve '
      'hatalardan sorumlu değilsin — sadece yardım ETMEYEN cezalandırılır\n'
      '• Temel kurallar: sakin ol · önce kendi güvenliğin · kaza yerini '
      'emniyete al · sonra yardım et\n'
      '• Acil çağrı 112 — sorular: Nerede? Ne oldu? Kaç yaralı? Kim arıyor? '
      'Soruları bekle!\n'
      '• Her yaralanmayı — küçük kesikleri bile — hemen tedavi et ve ilk '
      'yardım defterine kaydet\n'
      '• 3 günden fazla iş göremezsen işveren kazayı bildirmek zorundadır — '
      'bu yüzden her zaman haber ver.',
  'ch07_title': 'Doğru oturmak ve hareket',
  'ch07_body': 'Uzun ve yanlış oturmak yorar, gerginlik yapar ve tepkini '
      'yavaşlatır.\n'
      '• Yola çıkmadan koltuğu ayarla: yükseklik, mesafe, sırtlık, bel '
      'desteği, koltuk başlığı, direksiyon, kemer geçişi\n'
      '• Sırtın tamamen sırtlıkta, dik otur, duruşunu sürekli biraz '
      'değiştir («dinamik oturuş»)\n'
      '• Molaları kısa egzersizler için kullan: kolları yukarı uzat (yaklaşık '
      '8 s, 3–5×) · eller ensede, dirsekler geriye · otururken direksiyonu '
      'kuvvetle iki yana çek (3–6 s)\n'
      '• Çalıştırılmış bir sırt çok daha az sorun yaşar.',
  'ch08_title': 'Psikolojik yük',
  'ch08_body': 'Zaman baskısı, trafik, park yeri aramak, çatışmalar — '
      'sürücünün günü yorucu olabilir. Bu normaldir ve kişisel bir '
      'başarısızlık değildir.\n'
      '• Sürekli stres tükenmeye, uyku sorunlarına, hatalara ve hastalığa '
      'yol açar — uyarı sinyallerini ciddiye al\n'
      '• Yükleri açıkça dile getir: dispeçerinle, personel görüşmesinde veya '
      'anonim olarak\n'
      '• Gerçekçi turlar, net sorumluluklar ve geri bildirim işverenin '
      'görevidir — uyarıların herkese yardımcı olur\n'
      '• Yardım istemek güçtür, zayıflık değil. Akut krizlerde '
      '(Almanya\'da): Telefonseelsorge 0800 111 0 111 (ücretsiz, 24 saat).',
  'ch09_title': 'Güvenli sürüş ve hareket öncesi kontrol',
  'ch09_body': 'HER yolculuktan önce: kısa bir kontrol — 2 dakika sürer ve '
      'hayat kurtarabilir.\n'
      '• Araç turu: ön/arka aydınlatma · lastikler (basınç, diş) · aynalar '
      've camlar temiz · sızıntı yok · kapılar/branda kapalı · plakalar '
      'temiz\n'
      '• Yük emniyete alındı mı? Bağlama gereçleri hasarsız, izin verilen '
      'toplam ağırlığa uyuldu\n'
      '• Çalışma yeri: koltuk ve aynalar ayarlı, fren testi, yardımcı '
      'sistemler açık\n'
      '• Kışın: uygun lastikler, antifriz, buz kazıyıcı araçta\n'
      '• Yolda: kemer takılı, kurallara uy, mesafeni koru — asla alkol/'
      'uyuşturucu etkisinde sürme.',
  'ch10_title': 'Arızalar ve kazalar',
  'ch10_body': 'Temel kural: önce kendi güvenliğin — insanlar eşyadan önce '
      'gelir.\n'
      '• Arıza: dörtlüleri erken yak, mümkünse park yerine veya en sağa çek, '
      'inmeden ÖNCE reflektörlü yeleği giy, üçgeni koy (yaklaşık 100 m, '
      'otoyolda 150–400 m)\n'
      '• Kaza: 1. dur · 2. yeri emniyete al · 3. ilk yardım · 4. acil çağrı '
      '112 · 5. bilgileri paylaş · 6. yaralı veya büyük hasar varsa polis · '
      '7. fotoğraf + tanıklar · 8. işvereni bilgilendir\n'
      '• Park hâlindeki araca çarptın ve kimse yok mu? En az 30 dakika bekle, '
      'not bırakmak YETMEZ: derhal polise git — aksi hâlde kaza yerinden '
      'kaçmadır\n'
      '• Yaralanmaların çoğu trafikte değil, araçtan inerken olur: %50\'den '
      'fazlası düşmedir — asla atlama, her zaman basamak ve tutamakları '
      'kullan.',

  // ── Test soruları ──
  'q01': 'Yaralıların olduğu bir kazada ilk ne yaparsın?',
  'q01_a': 'Hemen işvereni ararsın',
  'q01_b': 'Durur, kaza yerini emniyete alır (yelek, üçgen), sonra ilk '
      'yardım ve acil çağrı yaparsın',
  'q01_c': 'Fotoğraf çekip yoluna devam edersin',
  'q02': 'Yangın veya yaralı durumunda hangi acil numarayı ararsın?',
  'q02_a': '110',
  'q02_b': '112',
  'q02_c': '116117',
  'q03': 'Park hâlindeki bir araca çarptın, sahibi orada değil. Doğru olan '
      'nedir?',
  'q03_a': 'Cama telefon numaralı bir not bırakıp gitmek',
  'q03_b': 'En az 30 dakika beklemek, sonra kazayı derhal polise bildirmek',
  'q03_c': 'Hasar küçük görünüyorsa gitmek',
  'q04': 'Otoyolda üçgeni hangi mesafeye koyarsın?',
  'q04_a': 'Doğrudan aracın arkasına',
  'q04_b': 'Yaklaşık 50 m',
  'q04_c': '150 ile 400 m arası',
  'q05': 'Arıza veya kaza yerinde temel kural nedir?',
  'q05_a': 'Maliyetten kaçınmak için önce eşyanın korunması gelir',
  'q05_b': 'Önce kendi güvenliğin, insanlar eşyadan önce gelir',
  'q05_c': 'Önce yükü emniyete al, sonra insanlara yardım et',
  'q06': 'Arızada reflektörlü yeleği ne zaman giyersin?',
  'q06_a': 'Sadece geceleri',
  'q06_b': 'Sadece otoyolda',
  'q06_c': 'Her zaman — araçtan inmeden önce',
  'q07': 'İlk yardım yaparken hata edersen ceza alır mısın?',
  'q07_a': 'Evet, ilk yardımcılar hatalardan her zaman sorumludur',
  'q07_b': 'Hayır — yardım eden yanlış yapmaz. Sadece hiç yardım etmeyen '
      'cezalandırılır',
  'q07_c': 'Evet, bu yüzden sadece eğitimliler müdahale etmeli',
  'q08': 'İş yerindeki küçük yaralanmalarda (ör. kesik) ne olur?',
  'q08_a': 'Hiçbir şey, küçük yaralanmalar özel meseledir',
  'q08_b': 'Hemen tedavi edilir ve ilk yardım defterine kaydedilir',
  'q08_c': 'Sadece iltihaplanırsa doktora söylenir',
  'q09': 'Yangına söndürücüyle nasıl müdahale edersin?',
  'q09_a': 'Rüzgâra karşı, arkadan öne doğru',
  'q09_b': 'Rüzgâr yönünde, yüzey yangınlarını önden, birden fazla '
      'söndürücüyle aynı anda',
  'q09_c': 'Yukarıdan alevlerin ortasına, söndürücüleri sırayla',
  'q10': 'Sürücülerin bildirime tabi kazalarının çoğu nerede olur?',
  'q10_a': 'Yüksek hızda trafikte',
  'q10_b': 'Araçtan inerken — düşme, takılma, burkulma (%50\'den fazla)',
  'q10_c': 'Yakıt alırken',
  'q11': 'Her yolculuk öncesi kontrole neler dâhildir?',
  'q11_a': 'Sadece yakıt deposuna bir bakış',
  'q11_b': 'Aydınlatma, lastikler, frenler, aynalar, yük emniyeti ve koltuk '
      'ayarını kontrol etmek',
  'q11_c': 'Kontrol sadece servis ziyaretlerinden sonra gerekir',
  'q12': 'Sürücü olarak günlük işte alkol ve uyuşturucu için ne geçerlidir?',
  'q12_a': 'Öğle molasında bir bira serbesttir',
  'q12_b': 'Yasak — kimse kendini veya başkalarını uyuşturucu maddelerle '
      'tehlikeye atamaz',
  'q12_c': 'Sadece sürüş sırasında yasak, molada serbest',
};
