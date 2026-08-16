// lib/data/safety_training/driving_safety_texts.dart
//
// Bedien-/UI-Texte des DSP-Fahrsicherheitstrainings, je Sprache eine Map
// mit identischem Key-Satz (Vertrag). Platzhalter in geschweiften
// Klammern, z. B. {n}, {p}, {date}. Auflösung mit Fallback-Kette
// locale -> en -> de, analog zu safety_texts_*.dart.
//
// Bewusst NICHT uebersetzt (bleiben in allen Sprachen gleich):
// der Trainingsname 'DSP Fahrsicherheitstraining', die Zertifikatsnummer,
// der Firmenname sowie deutsche Rechtsbegriffe.

// ── Deutsch (Master) ────────────────────────────────────────────────
const Map<String, String> drivingTextsDe = {
  'title': 'Fahrsicherheit',
  'intro_meta': '{n} Module · ca. {min} Minuten · Abschlusstest mit '
      'Zertifikat',
  'intro_body': 'Ziel dieser Schulung ist, Verkehrsunfälle und '
      'Arbeitsunfälle aktiv zu vermeiden. Nach dem Abschluss kennst du '
      'die häufigsten Unfallursachen im Zustellalltag und weißt, wie du '
      'sie vermeidest — beim Fahren, beim Rangieren und rund ums '
      'Fahrzeug.',
  'status_valid': 'Zertifikat gültig bis {date}',
  'status_cert_no': ' · Nr. {no}',
  'status_expired': 'Zertifikat abgelaufen — bitte auffrischen',
  'status_open': 'Noch nicht abgeschlossen',
  'btn_start': 'Training starten',
  'btn_continue': 'Fortsetzen',
  'modules_title': 'Module',
  'modules_hint': 'Jedes Modul endet mit einem kurzen Quiz. Ab {t} % gilt '
      'es als bestanden. Sind alle Module geschafft, öffnet sich der '
      'Abschlusstest.',
  'btn_exam_start': 'Abschlusstest starten',
  'btn_exam_locked': 'Erst alle Module bestehen',
  'module_passed': 'Quiz bestanden · {p} %',
  'module_pages': '{n} Seiten · Quiz',
  'btn_back': 'Zurück',
  'btn_overview': 'Übersicht',
  'btn_to_quiz': 'Zum Quiz',
  'btn_next': 'Weiter',
  'quiz_title': 'Quiz — {title}',
  'quiz_intro': '{n} Fragen · ab {t} % bestanden',
  'exam_title': 'Abschlusstest',
  'exam_attempt': ' · Versuch {n}',
  'result_passed': 'Bestanden — {p} % richtig',
  'result_failed': 'Nicht bestanden — {p} %. Schau dir die Erklärungen an '
      'und versuch es erneut.',
  'btn_retry': 'Nochmal versuchen',
  'btn_check': 'Antworten prüfen',
  'btn_check_progress': 'Antworten prüfen ({a}/{b})',
  'err_certificate': 'Zertifikat fehlgeschlagen: {error}',
  'done_title': 'Training bestanden!',
  'done_body': 'Dein Zertifikat wurde erstellt und in deinen Dokumenten '
      'abgelegt. Es ist {months} Monate gültig.',
  'done_cert_no': 'Zertifikat-Nr. {no}',
  'done_valid_until': 'Gültig bis {date}',
  'btn_done': 'Fertig',
  'pdf_heading': 'ZERTIFIKAT - FAHRSICHERHEIT',
  'pdf_confirm': 'Hiermit wird bestätigt, dass',
  'pdf_completed': 'das {training} erfolgreich abgeschlossen hat.',
  'pdf_employee_no': 'Personalnummer',
  'pdf_transporter_id': 'Transporter-ID',
  'pdf_result': 'Ergebnis',
  'pdf_result_value': '{p} % (bestanden ab {t} %)',
  'pdf_issued_at': 'Ausgestellt am',
  'pdf_valid_until': 'Gültig bis',
  'pdf_cert_no': 'Zertifikat-Nr.',
  'pdf_version': 'Inhaltsversion',
  'pdf_issued_by': 'Ausgestellt von',
  'pdf_contents': 'Inhalte: Sicherheitskultur, Fahrzeugcheck und '
      'Ladungssicherung, defensives Fahren, Rückwärtsfahren und '
      'Rangieren, Wetter und Sicht, Ablenkung und Müdigkeit, Ein- und '
      'Aussteigen sowie Heben, Verhalten an der Haustür, Notfall und '
      'Unfall.',
  'pdf_checksum': 'Prüfsumme (SHA-256):',
  'pdf_generated': 'Digital erstellt über CoDriver DA Academy',
};

// ── English ─────────────────────────────────────────────────────────
const Map<String, String> drivingTextsEn = {
  'title': 'Driving safety',
  'intro_meta': '{n} modules · approx. {min} minutes · final test with '
      'certificate',
  'intro_body': 'The goal of this training is to actively prevent traffic '
      'and workplace accidents. When you are done you will know the most '
      'common causes of accidents in daily delivery work and how to avoid '
      'them — while driving, while manoeuvring and around the van.',
  'status_valid': 'Certificate valid until {date}',
  'status_cert_no': ' · No. {no}',
  'status_expired': 'Certificate expired — please refresh',
  'status_open': 'Not completed yet',
  'btn_start': 'Start training',
  'btn_continue': 'Continue',
  'modules_title': 'Modules',
  'modules_hint': 'Every module ends with a short quiz. {t} % or more '
      'counts as passed. Once all modules are done, the final test '
      'unlocks.',
  'btn_exam_start': 'Start final test',
  'btn_exam_locked': 'Pass all modules first',
  'module_passed': 'Quiz passed · {p} %',
  'module_pages': '{n} pages · quiz',
  'btn_back': 'Back',
  'btn_overview': 'Overview',
  'btn_to_quiz': 'Go to quiz',
  'btn_next': 'Next',
  'quiz_title': 'Quiz — {title}',
  'quiz_intro': '{n} questions · pass mark {t} %',
  'exam_title': 'Final test',
  'exam_attempt': ' · attempt {n}',
  'result_passed': 'Passed — {p} % correct',
  'result_failed': 'Not passed — {p} %. Read the explanations and try '
      'again.',
  'btn_retry': 'Try again',
  'btn_check': 'Check answers',
  'btn_check_progress': 'Check answers ({a}/{b})',
  'err_certificate': 'Certificate failed: {error}',
  'done_title': 'Training passed!',
  'done_body': 'Your certificate has been created and filed in your '
      'documents. It is valid for {months} months.',
  'done_cert_no': 'Certificate no. {no}',
  'done_valid_until': 'Valid until {date}',
  'btn_done': 'Done',
  'pdf_heading': 'CERTIFICATE - DRIVING SAFETY',
  'pdf_confirm': 'This is to certify that',
  'pdf_completed': 'has successfully completed the {training}.',
  'pdf_employee_no': 'Employee number',
  'pdf_transporter_id': 'Transporter ID',
  'pdf_result': 'Result',
  'pdf_result_value': '{p} % (pass mark {t} %)',
  'pdf_issued_at': 'Issued on',
  'pdf_valid_until': 'Valid until',
  'pdf_cert_no': 'Certificate no.',
  'pdf_version': 'Content version',
  'pdf_issued_by': 'Issued by',
  'pdf_contents': 'Contents: safety culture, vehicle check and load '
      'securing, defensive driving, reversing and manoeuvring, weather '
      'and visibility, distraction and fatigue, getting in and out plus '
      'lifting, conduct at the front door, emergency and accident.',
  'pdf_checksum': 'Checksum (SHA-256):',
  'pdf_generated': 'Created digitally via CoDriver DA Academy',
};

// ── Shqip / Albanian ────────────────────────────────────────────────
const Map<String, String> drivingTextsSq = {
  'title': 'Siguria në vozitje',
  'intro_meta': '{n} module · rreth {min} minuta · test përfundimtar me '
      'certifikatë',
  'intro_body': 'Qëllimi i këtij trajnimi është parandalimi aktiv i '
      'aksidenteve në trafik dhe në punë. Në fund do t\'i njohësh shkaqet '
      'më të shpeshta të aksidenteve në punën e përditshme të dërgesave '
      'dhe do të dish si t\'i shmangësh — gjatë vozitjes, gjatë manovrimit '
      'dhe rreth automjetit.',
  'status_valid': 'Certifikata vlen deri më {date}',
  'status_cert_no': ' · Nr. {no}',
  'status_expired': 'Certifikata ka skaduar — të lutem përsërite',
  'status_open': 'Ende e papërfunduar',
  'btn_start': 'Fillo trajnimin',
  'btn_continue': 'Vazhdo',
  'modules_title': 'Modulet',
  'modules_hint': 'Çdo modul përfundon me një kuiz të shkurtër. Nga {t} % '
      'quhet i kaluar. Kur t\'i kalosh të gjitha modulet, hapet testi '
      'përfundimtar.',
  'btn_exam_start': 'Fillo testin përfundimtar',
  'btn_exam_locked': 'Kalo së pari të gjitha modulet',
  'module_passed': 'Kuizi u kalua · {p} %',
  'module_pages': '{n} faqe · kuiz',
  'btn_back': 'Prapa',
  'btn_overview': 'Pasqyra',
  'btn_to_quiz': 'Te kuizi',
  'btn_next': 'Vazhdo',
  'quiz_title': 'Kuiz — {title}',
  'quiz_intro': '{n} pyetje · kalohet nga {t} %',
  'exam_title': 'Testi përfundimtar',
  'exam_attempt': ' · përpjekja {n}',
  'result_passed': 'Kaluar — {p} % saktë',
  'result_failed': 'Nuk u kalua — {p} %. Shiko shpjegimet dhe provo '
      'sërish.',
  'btn_retry': 'Provo sërish',
  'btn_check': 'Kontrollo përgjigjet',
  'btn_check_progress': 'Kontrollo përgjigjet ({a}/{b})',
  'err_certificate': 'Certifikata dështoi: {error}',
  'done_title': 'Trajnimi u kalua!',
  'done_body': 'Certifikata jote u krijua dhe u ruajt te dokumentet e '
      'tua. Ajo vlen për {months} muaj.',
  'done_cert_no': 'Certifikata nr. {no}',
  'done_valid_until': 'Vlen deri më {date}',
  'btn_done': 'Gati',
  'pdf_heading': 'CERTIFIKATE - SIGURIA NE VOZITJE',
  'pdf_confirm': 'Me këtë vërtetohet se',
  'pdf_completed': 'e ka përfunduar me sukses {training}.',
  'pdf_employee_no': 'Numri i punonjësit',
  'pdf_transporter_id': 'Transporter-ID',
  'pdf_result': 'Rezultati',
  'pdf_result_value': '{p} % (kalohet nga {t} %)',
  'pdf_issued_at': 'Lëshuar më',
  'pdf_valid_until': 'Vlen deri më',
  'pdf_cert_no': 'Certifikata nr.',
  'pdf_version': 'Versioni i përmbajtjes',
  'pdf_issued_by': 'Lëshuar nga',
  'pdf_contents': 'Përmbajtja: kultura e sigurisë, kontrolli i automjetit '
      'dhe sigurimi i ngarkesës, vozitja defensive, lëvizja mbrapa dhe '
      'manovrimi, moti dhe dukshmëria, shpërqendrimi dhe lodhja, hyrja e '
      'dalja nga automjeti si dhe ngritja e peshave, sjellja te dera, '
      'emergjenca dhe aksidenti.',
  'pdf_checksum': 'Shuma e kontrollit (SHA-256):',
  'pdf_generated': 'Krijuar dixhitalisht përmes CoDriver DA Academy',
};

// ── Magyar / Hungarian ──────────────────────────────────────────────
const Map<String, String> drivingTextsHu = {
  'title': 'Vezetésbiztonság',
  'intro_meta': '{n} modul · kb. {min} perc · záróteszt tanúsítvánnyal',
  'intro_body': 'Ennek a képzésnek a célja a közlekedési és munkahelyi '
      'balesetek aktív megelőzése. A végén ismerni fogod a kézbesítői '
      'munka leggyakoribb baleseti okait, és tudni fogod, hogyan kerüld '
      'el őket — vezetés közben, tolatásnál és a jármű körül.',
  'status_valid': 'A tanúsítvány érvényes eddig: {date}',
  'status_cert_no': ' · sz. {no}',
  'status_expired': 'A tanúsítvány lejárt — kérlek, frissítsd',
  'status_open': 'Még nincs teljesítve',
  'btn_start': 'Képzés indítása',
  'btn_continue': 'Folytatás',
  'modules_title': 'Modulok',
  'modules_hint': 'Minden modul rövid kvízzel zárul. {t} % felett '
      'teljesítettnek számít. Ha minden modul megvan, megnyílik a '
      'záróteszt.',
  'btn_exam_start': 'Záróteszt indítása',
  'btn_exam_locked': 'Előbb teljesítsd az összes modult',
  'module_passed': 'Kvíz teljesítve · {p} %',
  'module_pages': '{n} oldal · kvíz',
  'btn_back': 'Vissza',
  'btn_overview': 'Áttekintés',
  'btn_to_quiz': 'Irány a kvíz',
  'btn_next': 'Tovább',
  'quiz_title': 'Kvíz — {title}',
  'quiz_intro': '{n} kérdés · {t} %-tól teljesítve',
  'exam_title': 'Záróteszt',
  'exam_attempt': ' · {n}. próbálkozás',
  'result_passed': 'Teljesítve — {p} % helyes',
  'result_failed': 'Nem sikerült — {p} %. Nézd át a magyarázatokat, és '
      'próbáld újra.',
  'btn_retry': 'Újrapróbálom',
  'btn_check': 'Válaszok ellenőrzése',
  'btn_check_progress': 'Válaszok ellenőrzése ({a}/{b})',
  'err_certificate': 'A tanúsítvány nem készült el: {error}',
  'done_title': 'Képzés teljesítve!',
  'done_body': 'A tanúsítványod elkészült, és a dokumentumaid közé '
      'került. {months} hónapig érvényes.',
  'done_cert_no': 'Tanúsítvány sz. {no}',
  'done_valid_until': 'Érvényes eddig: {date}',
  'btn_done': 'Kész',
  'pdf_heading': 'TANUSITVANY - VEZETESBIZTONSAG',
  'pdf_confirm': 'Ezennel igazoljuk, hogy',
  'pdf_completed': 'sikeresen elvégezte a következőt: {training}.',
  'pdf_employee_no': 'Személyi szám',
  'pdf_transporter_id': 'Transporter-ID',
  'pdf_result': 'Eredmény',
  'pdf_result_value': '{p} % (teljesítve {t} %-tól)',
  'pdf_issued_at': 'Kiállítva',
  'pdf_valid_until': 'Érvényes eddig',
  'pdf_cert_no': 'Tanúsítvány sz.',
  'pdf_version': 'Tartalomverzió',
  'pdf_issued_by': 'Kiállító',
  'pdf_contents': 'Tartalom: biztonsági kultúra, járműellenőrzés és '
      'rakományrögzítés, defenzív vezetés, tolatás és manőverezés, '
      'időjárás és látási viszonyok, figyelemelterelés és fáradtság, '
      'be- és kiszállás, valamint emelés, viselkedés a bejáratnál, '
      'vészhelyzet és baleset.',
  'pdf_checksum': 'Ellenőrző összeg (SHA-256):',
  'pdf_generated': 'Digitálisan létrehozva a CoDriver DA Academy révén',
};

// ── Română / Romanian ───────────────────────────────────────────────
const Map<String, String> drivingTextsRo = {
  'title': 'Siguranța la volan',
  'intro_meta': '{n} module · cca. {min} minute · test final cu certificat',
  'intro_body': 'Scopul acestui curs este prevenirea activă a '
      'accidentelor de circulație și de muncă. La final vei cunoaște cele '
      'mai frecvente cauze de accidente din activitatea zilnică de '
      'livrare și vei ști cum să le eviți — la volan, la manevre și în '
      'jurul mașinii.',
  'status_valid': 'Certificat valabil până la {date}',
  'status_cert_no': ' · nr. {no}',
  'status_expired': 'Certificat expirat — te rugăm să îl reînnoiești',
  'status_open': 'Încă nefinalizat',
  'btn_start': 'Începe cursul',
  'btn_continue': 'Continuă',
  'modules_title': 'Module',
  'modules_hint': 'Fiecare modul se încheie cu un scurt test. De la {t} % '
      'este considerat promovat. După ce termini toate modulele, se '
      'deschide testul final.',
  'btn_exam_start': 'Începe testul final',
  'btn_exam_locked': 'Promovează întâi toate modulele',
  'module_passed': 'Test promovat · {p} %',
  'module_pages': '{n} pagini · test',
  'btn_back': 'Înapoi',
  'btn_overview': 'Prezentare',
  'btn_to_quiz': 'La test',
  'btn_next': 'Continuă',
  'quiz_title': 'Test — {title}',
  'quiz_intro': '{n} întrebări · promovat de la {t} %',
  'exam_title': 'Test final',
  'exam_attempt': ' · încercarea {n}',
  'result_passed': 'Promovat — {p} % corect',
  'result_failed': 'Nepromovat — {p} %. Citește explicațiile și încearcă '
      'din nou.',
  'btn_retry': 'Încearcă din nou',
  'btn_check': 'Verifică răspunsurile',
  'btn_check_progress': 'Verifică răspunsurile ({a}/{b})',
  'err_certificate': 'Certificatul nu a putut fi emis: {error}',
  'done_title': 'Curs promovat!',
  'done_body': 'Certificatul tău a fost creat și salvat în documentele '
      'tale. Este valabil {months} luni.',
  'done_cert_no': 'Certificat nr. {no}',
  'done_valid_until': 'Valabil până la {date}',
  'btn_done': 'Gata',
  'pdf_heading': 'CERTIFICAT - SIGURANTA LA VOLAN',
  'pdf_confirm': 'Prin prezenta se confirmă că',
  'pdf_completed': 'a absolvit cu succes {training}.',
  'pdf_employee_no': 'Număr personal',
  'pdf_transporter_id': 'Transporter-ID',
  'pdf_result': 'Rezultat',
  'pdf_result_value': '{p} % (promovat de la {t} %)',
  'pdf_issued_at': 'Emis la',
  'pdf_valid_until': 'Valabil până la',
  'pdf_cert_no': 'Certificat nr.',
  'pdf_version': 'Versiunea conținutului',
  'pdf_issued_by': 'Emis de',
  'pdf_contents': 'Conținut: cultura siguranței, verificarea vehiculului '
      'și asigurarea încărcăturii, conducerea defensivă, mersul cu '
      'spatele și manevrele, vremea și vizibilitatea, distragerea '
      'atenției și oboseala, urcarea și coborârea, precum și ridicarea '
      'coletelor, comportamentul la ușă, urgența și accidentul.',
  'pdf_checksum': 'Sumă de control (SHA-256):',
  'pdf_generated': 'Creat digital prin CoDriver DA Academy',
};

// ── Hrvatski / Croatian ─────────────────────────────────────────────
const Map<String, String> drivingTextsHr = {
  'title': 'Sigurnost u vožnji',
  'intro_meta': '{n} modula · oko {min} minuta · završni test s '
      'certifikatom',
  'intro_body': 'Cilj ove obuke je aktivno sprječavanje prometnih i '
      'radnih nezgoda. Na kraju ćeš znati najčešće uzroke nezgoda u '
      'svakodnevnoj dostavi i kako ih izbjeći — u vožnji, pri manevriranju '
      'i oko vozila.',
  'status_valid': 'Certifikat vrijedi do {date}',
  'status_cert_no': ' · br. {no}',
  'status_expired': 'Certifikat je istekao — molimo obnovi ga',
  'status_open': 'Još nije završeno',
  'btn_start': 'Pokreni obuku',
  'btn_continue': 'Nastavi',
  'modules_title': 'Moduli',
  'modules_hint': 'Svaki modul završava kratkim kvizom. Od {t} % smatra '
      'se položenim. Kad položiš sve module, otvara se završni test.',
  'btn_exam_start': 'Pokreni završni test',
  'btn_exam_locked': 'Najprije položi sve module',
  'module_passed': 'Kviz položen · {p} %',
  'module_pages': '{n} stranica · kviz',
  'btn_back': 'Natrag',
  'btn_overview': 'Pregled',
  'btn_to_quiz': 'Na kviz',
  'btn_next': 'Dalje',
  'quiz_title': 'Kviz — {title}',
  'quiz_intro': '{n} pitanja · položeno od {t} %',
  'exam_title': 'Završni test',
  'exam_attempt': ' · pokušaj {n}',
  'result_passed': 'Položeno — {p} % točno',
  'result_failed': 'Nije položeno — {p} %. Pogledaj objašnjenja i pokušaj '
      'ponovno.',
  'btn_retry': 'Pokušaj ponovno',
  'btn_check': 'Provjeri odgovore',
  'btn_check_progress': 'Provjeri odgovore ({a}/{b})',
  'err_certificate': 'Certifikat nije uspio: {error}',
  'done_title': 'Obuka položena!',
  'done_body': 'Tvoj certifikat je izrađen i spremljen u tvoje dokumente. '
      'Vrijedi {months} mjeseci.',
  'done_cert_no': 'Certifikat br. {no}',
  'done_valid_until': 'Vrijedi do {date}',
  'btn_done': 'Gotovo',
  'pdf_heading': 'CERTIFIKAT - SIGURNOST U VOZNJI',
  'pdf_confirm': 'Ovime se potvrđuje da je',
  'pdf_completed': 'uspješno završio/la {training}.',
  'pdf_employee_no': 'Matični broj',
  'pdf_transporter_id': 'Transporter-ID',
  'pdf_result': 'Rezultat',
  'pdf_result_value': '{p} % (položeno od {t} %)',
  'pdf_issued_at': 'Izdano dana',
  'pdf_valid_until': 'Vrijedi do',
  'pdf_cert_no': 'Certifikat br.',
  'pdf_version': 'Verzija sadržaja',
  'pdf_issued_by': 'Izdao',
  'pdf_contents': 'Sadržaj: kultura sigurnosti, provjera vozila i '
      'osiguranje tereta, defenzivna vožnja, vožnja unatrag i '
      'manevriranje, vrijeme i vidljivost, ometanje i umor, ulazak i '
      'izlazak te podizanje tereta, ponašanje na kućnim vratima, hitni '
      'slučaj i nesreća.',
  'pdf_checksum': 'Kontrolni zbroj (SHA-256):',
  'pdf_generated': 'Digitalno izrađeno putem CoDriver DA Academy',
};

// ── Türkçe / Turkish ────────────────────────────────────────────────
const Map<String, String> drivingTextsTr = {
  'title': 'Sürüş güvenliği',
  'intro_meta': '{n} modül · yaklaşık {min} dakika · sertifikalı bitirme '
      'testi',
  'intro_body': 'Bu eğitimin amacı trafik ve iş kazalarını aktif olarak '
      'önlemektir. Eğitimin sonunda günlük dağıtım işindeki en sık kaza '
      'nedenlerini bilecek ve bunlardan nasıl kaçınacağını öğreneceksin — '
      'sürüşte, manevrada ve araç çevresinde.',
  'status_valid': 'Sertifika {date} tarihine kadar geçerli',
  'status_cert_no': ' · No. {no}',
  'status_expired': 'Sertifikanın süresi doldu — lütfen yenile',
  'status_open': 'Henüz tamamlanmadı',
  'btn_start': 'Eğitimi başlat',
  'btn_continue': 'Devam et',
  'modules_title': 'Modüller',
  'modules_hint': 'Her modül kısa bir testle biter. {t} % ve üzeri başarılı '
      'sayılır. Tüm modüller tamamlandığında bitirme testi açılır.',
  'btn_exam_start': 'Bitirme testini başlat',
  'btn_exam_locked': 'Önce tüm modülleri geç',
  'module_passed': 'Test geçildi · {p} %',
  'module_pages': '{n} sayfa · test',
  'btn_back': 'Geri',
  'btn_overview': 'Genel bakış',
  'btn_to_quiz': 'Teste git',
  'btn_next': 'Devam',
  'quiz_title': 'Test — {title}',
  'quiz_intro': '{n} soru · {t} % ile geçilir',
  'exam_title': 'Bitirme testi',
  'exam_attempt': ' · {n}. deneme',
  'result_passed': 'Geçtin — {p} % doğru',
  'result_failed': 'Geçemedin — {p} %. Açıklamalara bak ve tekrar dene.',
  'btn_retry': 'Tekrar dene',
  'btn_check': 'Cevapları kontrol et',
  'btn_check_progress': 'Cevapları kontrol et ({a}/{b})',
  'err_certificate': 'Sertifika oluşturulamadı: {error}',
  'done_title': 'Eğitimi geçtin!',
  'done_body': 'Sertifikan oluşturuldu ve belgelerine kaydedildi. '
      '{months} ay geçerlidir.',
  'done_cert_no': 'Sertifika No. {no}',
  'done_valid_until': '{date} tarihine kadar geçerli',
  'btn_done': 'Bitti',
  'pdf_heading': 'SERTIFIKA - SURUS GUVENLIGI',
  'pdf_confirm': 'İşbu belge ile onaylanır ki',
  'pdf_completed': 'adlı kişi {training} eğitimini başarıyla '
      'tamamlamıştır.',
  'pdf_employee_no': 'Personel numarası',
  'pdf_transporter_id': 'Transporter-ID',
  'pdf_result': 'Sonuç',
  'pdf_result_value': '{p} % ({t} % ile geçilir)',
  'pdf_issued_at': 'Düzenlenme tarihi',
  'pdf_valid_until': 'Geçerlilik tarihi',
  'pdf_cert_no': 'Sertifika No.',
  'pdf_version': 'İçerik sürümü',
  'pdf_issued_by': 'Düzenleyen',
  'pdf_contents': 'İçerik: güvenlik kültürü, araç kontrolü ve yük '
      'emniyeti, defansif sürüş, geri manevra, hava ve görüş koşulları, '
      'dikkat dağınıklığı ve yorgunluk, araca iniş biniş ve kaldırma '
      'tekniği, kapı önünde davranış, acil durum ve kaza.',
  'pdf_checksum': 'Sağlama toplamı (SHA-256):',
  'pdf_generated': 'CoDriver DA Academy üzerinden dijital olarak '
      'oluşturuldu',
};

// ── Русский / Russian ───────────────────────────────────────────────
const Map<String, String> drivingTextsRu = {
  'title': 'Безопасность вождения',
  'intro_meta': '{n} модулей · примерно {min} минут · итоговый тест с '
      'сертификатом',
  'intro_body': 'Цель этого обучения — активно предотвращать дорожные и '
      'производственные происшествия. В конце ты будешь знать самые '
      'частые причины аварий в ежедневной доставке и как их избежать — '
      'за рулём, при маневрировании и вокруг машины.',
  'status_valid': 'Сертификат действует до {date}',
  'status_cert_no': ' · № {no}',
  'status_expired': 'Срок сертификата истёк — пройди обучение заново',
  'status_open': 'Ещё не пройдено',
  'btn_start': 'Начать обучение',
  'btn_continue': 'Продолжить',
  'modules_title': 'Модули',
  'modules_hint': 'Каждый модуль завершается коротким тестом. От {t} % '
      'считается сданным. Когда все модули пройдены, открывается итоговый '
      'тест.',
  'btn_exam_start': 'Начать итоговый тест',
  'btn_exam_locked': 'Сначала пройди все модули',
  'module_passed': 'Тест сдан · {p} %',
  'module_pages': '{n} страниц · тест',
  'btn_back': 'Назад',
  'btn_overview': 'Обзор',
  'btn_to_quiz': 'К тесту',
  'btn_next': 'Далее',
  'quiz_title': 'Тест — {title}',
  'quiz_intro': '{n} вопросов · сдано от {t} %',
  'exam_title': 'Итоговый тест',
  'exam_attempt': ' · попытка {n}',
  'result_passed': 'Сдано — {p} % правильно',
  'result_failed': 'Не сдано — {p} %. Прочитай пояснения и попробуй ещё '
      'раз.',
  'btn_retry': 'Попробовать ещё раз',
  'btn_check': 'Проверить ответы',
  'btn_check_progress': 'Проверить ответы ({a}/{b})',
  'err_certificate': 'Не удалось создать сертификат: {error}',
  'done_title': 'Обучение пройдено!',
  'done_body': 'Твой сертификат создан и сохранён в твоих документах. Он '
      'действует {months} месяцев.',
  'done_cert_no': 'Сертификат № {no}',
  'done_valid_until': 'Действует до {date}',
  'btn_done': 'Готово',
  'pdf_heading': 'CERTIFICATE - DRIVING SAFETY',
  'pdf_confirm': 'This is to certify that',
  'pdf_completed': 'has successfully completed the {training}.',
  'pdf_employee_no': 'Employee number',
  'pdf_transporter_id': 'Transporter ID',
  'pdf_result': 'Result',
  'pdf_result_value': '{p} % (pass mark {t} %)',
  'pdf_issued_at': 'Issued on',
  'pdf_valid_until': 'Valid until',
  'pdf_cert_no': 'Certificate no.',
  'pdf_version': 'Content version',
  'pdf_issued_by': 'Issued by',
  'pdf_contents': 'Contents: safety culture, vehicle check and load '
      'securing, defensive driving, reversing and manoeuvring, weather '
      'and visibility, distraction and fatigue, getting in and out plus '
      'lifting, conduct at the front door, emergency and accident.',
  'pdf_checksum': 'Checksum (SHA-256):',
  'pdf_generated': 'Created digitally via CoDriver DA Academy',
};

// ── Български / Bulgarian ───────────────────────────────────────────
const Map<String, String> drivingTextsBg = {
  'title': 'Безопасност при шофиране',
  'intro_meta': '{n} модула · около {min} минути · финален тест със '
      'сертификат',
  'intro_body': 'Целта на това обучение е активно да предотвратява пътни '
      'и трудови злополуки. Накрая ще познаваш най-честите причини за '
      'злополуки в ежедневната доставка и ще знаеш как да ги избягваш — '
      'при шофиране, при маневриране и около автомобила.',
  'status_valid': 'Сертификатът важи до {date}',
  'status_cert_no': ' · № {no}',
  'status_expired': 'Сертификатът е изтекъл — моля, обнови го',
  'status_open': 'Още не е завършено',
  'btn_start': 'Започни обучението',
  'btn_continue': 'Продължи',
  'modules_title': 'Модули',
  'modules_hint': 'Всеки модул завършва с кратък тест. От {t} % се счита '
      'за издържан. Когато всички модули са готови, се отключва финалният '
      'тест.',
  'btn_exam_start': 'Започни финалния тест',
  'btn_exam_locked': 'Първо издържи всички модули',
  'module_passed': 'Тестът е издържан · {p} %',
  'module_pages': '{n} страници · тест',
  'btn_back': 'Назад',
  'btn_overview': 'Преглед',
  'btn_to_quiz': 'Към теста',
  'btn_next': 'Напред',
  'quiz_title': 'Тест — {title}',
  'quiz_intro': '{n} въпроса · издържан от {t} %',
  'exam_title': 'Финален тест',
  'exam_attempt': ' · опит {n}',
  'result_passed': 'Издържан — {p} % верни',
  'result_failed': 'Неиздържан — {p} %. Прегледай обясненията и опитай '
      'отново.',
  'btn_retry': 'Опитай отново',
  'btn_check': 'Провери отговорите',
  'btn_check_progress': 'Провери отговорите ({a}/{b})',
  'err_certificate': 'Сертификатът не бе създаден: {error}',
  'done_title': 'Обучението е издържано!',
  'done_body': 'Сертификатът ти е създаден и запазен в документите ти. '
      'Той важи {months} месеца.',
  'done_cert_no': 'Сертификат № {no}',
  'done_valid_until': 'Важи до {date}',
  'btn_done': 'Готово',
  'pdf_heading': 'CERTIFICATE - DRIVING SAFETY',
  'pdf_confirm': 'This is to certify that',
  'pdf_completed': 'has successfully completed the {training}.',
  'pdf_employee_no': 'Employee number',
  'pdf_transporter_id': 'Transporter ID',
  'pdf_result': 'Result',
  'pdf_result_value': '{p} % (pass mark {t} %)',
  'pdf_issued_at': 'Issued on',
  'pdf_valid_until': 'Valid until',
  'pdf_cert_no': 'Certificate no.',
  'pdf_version': 'Content version',
  'pdf_issued_by': 'Issued by',
  'pdf_contents': 'Contents: safety culture, vehicle check and load '
      'securing, defensive driving, reversing and manoeuvring, weather '
      'and visibility, distraction and fatigue, getting in and out plus '
      'lifting, conduct at the front door, emergency and accident.',
  'pdf_checksum': 'Checksum (SHA-256):',
  'pdf_generated': 'Created digitally via CoDriver DA Academy',
};

// ── العربية / Arabic ────────────────────────────────────────────────
const Map<String, String> drivingTextsAr = {
  'title': 'سلامة القيادة',
  'intro_meta': '{n} وحدات · حوالي {min} دقيقة · اختبار نهائي مع شهادة',
  'intro_body': 'الهدف من هذا التدريب هو منع حوادث المرور وحوادث العمل '
      'بشكل فعّال. في النهاية ستعرف أكثر أسباب الحوادث شيوعاً في عمل '
      'التوصيل اليومي وكيف تتجنبها — أثناء القيادة وأثناء المناورة وحول '
      'السيارة.',
  'status_valid': 'الشهادة صالحة حتى {date}',
  'status_cert_no': ' · رقم {no}',
  'status_expired': 'انتهت صلاحية الشهادة — يرجى التجديد',
  'status_open': 'لم يتم الإنهاء بعد',
  'btn_start': 'ابدأ التدريب',
  'btn_continue': 'متابعة',
  'modules_title': 'الوحدات',
  'modules_hint': 'كل وحدة تنتهي باختبار قصير. من {t} % يُعتبر ناجحاً. '
      'عند إنهاء كل الوحدات يُفتح الاختبار النهائي.',
  'btn_exam_start': 'ابدأ الاختبار النهائي',
  'btn_exam_locked': 'اجتز كل الوحدات أولاً',
  'module_passed': 'تم اجتياز الاختبار · {p} %',
  'module_pages': '{n} صفحات · اختبار',
  'btn_back': 'رجوع',
  'btn_overview': 'نظرة عامة',
  'btn_to_quiz': 'إلى الاختبار',
  'btn_next': 'التالي',
  'quiz_title': 'اختبار — {title}',
  'quiz_intro': '{n} أسئلة · النجاح من {t} %',
  'exam_title': 'الاختبار النهائي',
  'exam_attempt': ' · المحاولة {n}',
  'result_passed': 'ناجح — {p} % صحيحة',
  'result_failed': 'غير ناجح — {p} %. راجع التوضيحات وحاول مرة أخرى.',
  'btn_retry': 'حاول مرة أخرى',
  'btn_check': 'تحقق من الإجابات',
  'btn_check_progress': 'تحقق من الإجابات ({a}/{b})',
  'err_certificate': 'فشل إصدار الشهادة: {error}',
  'done_title': 'تم اجتياز التدريب!',
  'done_body': 'تم إنشاء شهادتك وحفظها في مستنداتك. وهي صالحة لمدة '
      '{months} شهراً.',
  'done_cert_no': 'الشهادة رقم {no}',
  'done_valid_until': 'صالحة حتى {date}',
  'btn_done': 'تم',
  'pdf_heading': 'CERTIFICATE - DRIVING SAFETY',
  'pdf_confirm': 'This is to certify that',
  'pdf_completed': 'has successfully completed the {training}.',
  'pdf_employee_no': 'Employee number',
  'pdf_transporter_id': 'Transporter ID',
  'pdf_result': 'Result',
  'pdf_result_value': '{p} % (pass mark {t} %)',
  'pdf_issued_at': 'Issued on',
  'pdf_valid_until': 'Valid until',
  'pdf_cert_no': 'Certificate no.',
  'pdf_version': 'Content version',
  'pdf_issued_by': 'Issued by',
  'pdf_contents': 'Contents: safety culture, vehicle check and load '
      'securing, defensive driving, reversing and manoeuvring, weather '
      'and visibility, distraction and fatigue, getting in and out plus '
      'lifting, conduct at the front door, emergency and accident.',
  'pdf_checksum': 'Checksum (SHA-256):',
  'pdf_generated': 'Created digitally via CoDriver DA Academy',
};

// ── Español / Spanish ───────────────────────────────────────────────
const Map<String, String> drivingTextsEs = {
  'title': 'Seguridad vial',
  'intro_meta': '{n} módulos · aprox. {min} minutos · examen final con '
      'certificado',
  'intro_body': 'El objetivo de esta formación es evitar activamente los '
      'accidentes de tráfico y los accidentes laborales. Al terminar '
      'conocerás las causas de accidente más frecuentes en el reparto '
      'diario y sabrás cómo evitarlas: al conducir, al maniobrar y '
      'alrededor del vehículo.',
  'status_valid': 'Certificado válido hasta el {date}',
  'status_cert_no': ' · n.º {no}',
  'status_expired': 'Certificado caducado: renuévalo, por favor',
  'status_open': 'Aún sin completar',
  'btn_start': 'Empezar la formación',
  'btn_continue': 'Continuar',
  'modules_title': 'Módulos',
  'modules_hint': 'Cada módulo termina con un test breve. A partir del '
      '{t} % se considera aprobado. Cuando superes todos los módulos, se '
      'desbloquea el examen final.',
  'btn_exam_start': 'Empezar el examen final',
  'btn_exam_locked': 'Aprueba primero todos los módulos',
  'module_passed': 'Test aprobado · {p} %',
  'module_pages': '{n} páginas · test',
  'btn_back': 'Atrás',
  'btn_overview': 'Resumen',
  'btn_to_quiz': 'Ir al test',
  'btn_next': 'Siguiente',
  'quiz_title': 'Test — {title}',
  'quiz_intro': '{n} preguntas · se aprueba a partir del {t} %',
  'exam_title': 'Examen final',
  'exam_attempt': ' · intento {n}',
  'result_passed': 'Aprobado — {p} % correcto',
  'result_failed': 'No aprobado — {p} %. Lee las explicaciones e '
      'inténtalo de nuevo.',
  'btn_retry': 'Intentar de nuevo',
  'btn_check': 'Comprobar respuestas',
  'btn_check_progress': 'Comprobar respuestas ({a}/{b})',
  'err_certificate': 'Error al emitir el certificado: {error}',
  'done_title': '¡Formación aprobada!',
  'done_body': 'Tu certificado se ha creado y guardado en tus documentos. '
      'Tiene una validez de {months} meses.',
  'done_cert_no': 'Certificado n.º {no}',
  'done_valid_until': 'Válido hasta el {date}',
  'btn_done': 'Listo',
  'pdf_heading': 'CERTIFICADO - SEGURIDAD VIAL',
  'pdf_confirm': 'Por la presente se certifica que',
  'pdf_completed': 'ha superado con éxito {training}.',
  'pdf_employee_no': 'Número de empleado',
  'pdf_transporter_id': 'Transporter-ID',
  'pdf_result': 'Resultado',
  'pdf_result_value': '{p} % (aprobado a partir del {t} %)',
  'pdf_issued_at': 'Fecha de emisión',
  'pdf_valid_until': 'Válido hasta',
  'pdf_cert_no': 'Certificado n.º',
  'pdf_version': 'Versión del contenido',
  'pdf_issued_by': 'Emitido por',
  'pdf_contents': 'Contenidos: cultura de seguridad, revisión del '
      'vehículo y sujeción de la carga, conducción defensiva, marcha '
      'atrás y maniobras, meteorología y visibilidad, distracción y '
      'fatiga, subir y bajar del vehículo y levantar cargas, '
      'comportamiento en la puerta del cliente, emergencia y accidente.',
  'pdf_checksum': 'Suma de comprobación (SHA-256):',
  'pdf_generated': 'Creado digitalmente con CoDriver DA Academy',
};

const Map<String, Map<String, String>> drivingTextsByLang = {
  'de': drivingTextsDe,
  'en': drivingTextsEn,
  'sq': drivingTextsSq,
  'hu': drivingTextsHu,
  'ro': drivingTextsRo,
  'hr': drivingTextsHr,
  'tr': drivingTextsTr,
  'ru': drivingTextsRu,
  'bg': drivingTextsBg,
  'ar': drivingTextsAr,
  'es': drivingTextsEs,
};

/// Text-Lookup mit Fallback locale -> en -> de.
///
/// [vars] ersetzt Platzhalter der Form `{key}`.
String drivingText(
  String languageCode,
  String key, [
  Map<String, String>? vars,
]) {
  final lang = drivingTextsByLang[languageCode];
  var out = lang?[key] ?? drivingTextsEn[key] ?? drivingTextsDe[key] ?? key;
  if (vars != null) {
    vars.forEach((k, v) => out = out.replaceAll('{$k}', v));
  }
  return out;
}
