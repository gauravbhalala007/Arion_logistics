// lib/data/safety_training/safety_texts_en.dart
//
// Safety instruction — English texts. Same key set as safety_texts_de.dart.

const Map<String, String> safetyTextsEn = {
  'ask_anytime':
      'Questions? Speak to your manager, your dispatcher or the management at any time — better to ask once too often than to get it wrong.',
  // ── Meta / UI ──
  'training_title': 'Safety Instruction',
  'training_subtitle':
      'Occupational safety for delivery drivers — annual instruction',
  'training_intro':
      'This instruction protects you: in about 15–20 minutes you will learn '
      'the most important rules for safe working and driving. At the end '
      'there is a short test (20 questions, 80% to pass) and you confirm '
      'your participation with your signature.',
  'chapters_overview_title': 'Chapters',
  'chapters_overview_hint': 'Work through the chapters one by one. The test unlocks once you have read them all.',
  'chapter_pages': '{n} pages',
  'btn_overview': 'Overview',
  'btn_chapter_done': 'Complete chapter',
  'btn_test_locked': 'Read all chapters first',
  'chapter_label': 'Chapter {n} of {m}',
  'btn_start': 'Start instruction',
  'btn_next': 'Next',
  'btn_back': 'Back',
  'btn_start_test': 'Go to test',
  'btn_submit_test': 'Check answers',
  'btn_retry': 'Try again',
  'btn_finish': 'Finish',
  'test_title': 'Final test',
  'test_intro':
      '20 questions — at least 80% (16 correct) to pass. You can repeat the '
      'test as often as you like.',
  'test_passed': 'Passed — {score} of {total} correct!',
  'test_failed':
      'Not passed ({score} of {total}). Review the chapters and try again.',
  'signature_title': 'Confirm participation',
  'signature_hint':
      'With your signature you confirm that you took part in the '
      'instruction and understood its content. You had the opportunity to '
      'ask questions.',
  'confirm_checkbox':
      'I have understood the instruction and confirm my participation.',
  'btn_clear': 'Clear',
  'btn_sign_submit': 'Sign & finish',
  'cert_done_title': 'Instruction completed!',
  'cert_done_body':
      'Your certificate has been created and filed in your documents. '
      'The instruction is valid for 12 months.',
  'status_valid_until': 'Valid until {date}',
  'status_expired': 'Expired — please complete again',
  'status_open': 'Not completed yet',

  // ── Chapters ──
  'ch01_title': 'Basics & your duties',
  'ch01_body': 'Occupational safety is regulated by law (Occupational '
      'Safety Act + DGUV regulations) and protects your life and health. '
      'You have duties too:\n'
      '• Follow your employer\'s operating instructions\n'
      '• Report accidents and near-misses immediately\n'
      '• Provide or support first aid\n'
      '• Report defects and faults (e.g. broken cables, faulty devices)\n'
      '• Use protective equipment (safety shoes, gloves, hi-vis vest) as '
      'intended\n'
      '• No alcohol, no drugs, no impairing medication — you must not '
      'endanger yourself or others.',
  'ch02_title': 'Operating instructions',
  'ch02_body': 'Operating instructions are binding rules from your '
      'employer for handling vehicles, equipment and hazardous '
      'substances.\n'
      '• They protect you from accidents and damage to your health\n'
      '• If you violate them, you risk sharing responsibility after an '
      'accident\n'
      '• Examples from daily driving: reversing near people only with a '
      'guide · always lock the vehicle when leaving it · towing only with '
      'a tow bar · report every accident immediately\n'
      '• Ask if an instruction is unclear — before you start working.',
  'ch03_title': '10 rules for safe working',
  'ch03_body': 'These ten rules apply every day:\n'
      '1. Work safely and attentively\n'
      '2. Departure check before every trip\n'
      '3. Secure the load in the vehicle\n'
      '4. Drive professionally, obey traffic law\n'
      '5. Always wear your seatbelt\n'
      '6. Keep vehicle, tools and equipment in good condition\n'
      '7. Work only in suitable shoes\n'
      '8. Be polite to colleagues and customers\n'
      '9. Observe break regulations\n'
      '10. Treat everyone with tolerance and respect',
  'ch04_title': 'Safety shoes & protective equipment',
  'ch04_body': 'Safety shoes provided by your employer must be worn — it '
      'is mandatory (§ 15 ArbSchG).\n'
      '• They protect against falling parcels, impacts, stepping into '
      'sharp objects, wetness and slipping\n'
      '• Protection classes: S1 (antistatic, fuel-resistant sole) · S2 '
      '(plus waterproof for at least 60 min) · S3 (plus '
      'penetration-resistant, profiled sole)\n'
      '• Check your shoes regularly: worn-out tread or damage → have them '
      'replaced\n'
      '• Especially important on ramps, uneven paths, with roll cages and '
      'hand pallet trucks\n'
      '• Keep the hi-vis vest within reach in the vehicle — mandatory at '
      'breakdowns/accidents.',
  'ch05_title': 'Behaviour in case of fire',
  'ch05_body': 'Using a fire extinguisher: 1. pull the safety pin · '
      '2. strike the knob · 3. press the nozzle.\n'
      '• Extinguish with the wind, area fires from the front, several '
      'extinguishers at once instead of one after another\n'
      '• An extinguisher lasts only seconds (6 kg powder: 15–23 s) — '
      'always have used extinguishers refilled\n'
      '• Vehicle fire: do NOT stop in tunnels or on bridges — drive out '
      'if possible, then hazard lights, stop, get out\n'
      '• Call the fire brigade 112 immediately: Where? What is burning? '
      'Injured? What is loaded? Don\'t hang up — the control centre ends '
      'the call\n'
      '• Open the bonnet only with gloves and only a crack — risk of '
      'flash flames from oxygen.',
  'ch06_title': 'First aid',
  'ch06_body': 'Everyone is legally obliged to provide first aid '
      '(§ 323c StGB) — within reason.\n'
      '• Whoever helps does nothing wrong: as a first aider you are '
      'insured and not liable for mistakes — only NOT helping is a '
      'criminal offence\n'
      '• Ground rules: stay calm · your own safety first · secure the '
      'scene · then help\n'
      '• Emergency call 112 — the W questions: Where? What? How many '
      'injured? Who is calling? Wait for questions!\n'
      '• Treat every injury — even small cuts — immediately and record '
      'it in the first aid log book\n'
      '• If you are unfit for work for more than 3 days, your employer '
      'must report the accident — so always tell them.',
  'ch07_title': 'Sitting & moving correctly',
  'ch07_body': 'Long, incorrect sitting makes you tired, tense and slows '
      'your reactions.\n'
      '• Adjust the seat before driving: height, distance, backrest, '
      'lumbar support, headrest, steering wheel, belt routing\n'
      '• Back fully against the backrest, sit upright, keep changing '
      'your posture slightly ("dynamic sitting")\n'
      '• Use breaks for short exercises: stretch your arms up (about 8 s, '
      '3–5×) · hands behind your head, elbows back · in the seat pull '
      'the steering wheel apart firmly (3–6 s)\n'
      '• A trained back is far less prone to problems.',
  'ch08_title': 'Mental stress',
  'ch08_body': 'Time pressure, traffic jams, searching for parking, '
      'conflicts — a driver\'s day can be stressful. That is normal and '
      'not a personal failure.\n'
      '• Constant stress leads to exhaustion, sleep problems, mistakes '
      'and illness — take warning signs seriously\n'
      '• Speak openly about stress: with your dispatcher, in staff talks '
      'or anonymously\n'
      '• Realistic routes, clear responsibilities and feedback are your '
      'employer\'s job — your input helps everyone\n'
      '• Getting help is strength, not weakness.',
  'ch09_title': 'Safe driving & departure check',
  'ch09_body': 'Before EVERY trip: a short departure check — it takes 2 '
      'minutes and can save lives.\n'
      '• Walk-around: lights front/rear · tyres (pressure, tread) · '
      'mirrors and windows clean · no leaks · doors/tarpaulins closed · '
      'number plates clean\n'
      '• Load secured? Lashing equipment undamaged, permissible total '
      'weight observed\n'
      '• Workplace: seat and mirrors adjusted, brake test, driver '
      'assistance systems switched on\n'
      '• In winter: suitable tyres, antifreeze, ice scraper on board\n'
      '• On the road: seatbelt on, obey traffic law, keep your distance — '
      'never drive under alcohol/drugs.',
  'ch10_title': 'Breakdowns & accidents',
  'ch10_body': 'Ground rule: your own safety first — people before '
      'property.\n'
      '• Breakdown: hazard lights on early, reach a parking area or pull '
      'far right, put on the hi-vis vest BEFORE getting out, set up the '
      'warning triangle (about 100 m, motorway 150–400 m)\n'
      '• Accident: 1. stop · 2. secure the scene · 3. first aid · '
      '4. emergency call 112 · 5. exchange details · 6. police if anyone '
      'is injured or damage is high · 7. photos + witnesses · 8. inform '
      'your employer\n'
      '• Touched a parked car and nobody is there? Wait at least 30 '
      'minutes, then a note is NOT enough: report to the police '
      'immediately — otherwise it is hit-and-run\n'
      '• Most injuries do not happen in traffic but when getting out: '
      'over 50% are falls — never jump off, always use the steps and '
      'handles.',

  // ── Test questions ──
  'q01': 'What do you do first at an accident with injured people?',
  'q01_a': 'Call the employer immediately',
  'q01_b': 'Stop, secure the scene (hi-vis vest, warning triangle), then '
      'first aid and emergency call',
  'q01_c': 'Take photos and drive on',
  'q02': 'Which emergency number do you call for a fire or injured '
      'people?',
  'q02_a': '110',
  'q02_b': '112',
  'q02_c': '116117',
  'q03': 'You touch a parked car and the owner is not there. What is '
      'correct?',
  'q03_a': 'Leave a note with your phone number and drive on',
  'q03_b': 'Wait at least 30 minutes, then report the accident to the '
      'police immediately',
  'q03_c': 'Drive on if the damage looks small',
  'q04': 'At what distance do you place the warning triangle on the '
      'motorway?',
  'q04_a': 'Directly behind the vehicle',
  'q04_b': 'About 50 m',
  'q04_c': '150 to 400 m',
  'q05': 'What is the ground rule at a breakdown or accident scene?',
  'q05_a': 'Protecting property comes first to avoid costs',
  'q05_b': 'Your own safety before others, people before property',
  'q05_c': 'Secure the load first, then help people',
  'q06': 'When do you put on the hi-vis vest at a breakdown?',
  'q06_a': 'Only at night',
  'q06_b': 'Only on the motorway',
  'q06_c': 'Always — before getting out',
  'q07': 'Can you be punished for making a mistake while giving first '
      'aid?',
  'q07_a': 'Yes, first aiders are always liable for mistakes',
  'q07_b': 'No — whoever helps does nothing wrong. Only NOT helping is a '
      'criminal offence',
  'q07_c': 'Yes, that is why only trained first aiders should help',
  'q08': 'What happens with small injuries (e.g. a cut) at work?',
  'q08_a': 'Nothing, small injuries are a private matter',
  'q08_b': 'Treat immediately and record in the first aid log book',
  'q08_c': 'Only tell a doctor if it gets infected',
  'q09': 'How do you attack a fire with the extinguisher?',
  'q09_a': 'Against the wind, from back to front',
  'q09_b': 'With the wind, area fires from the front, several '
      'extinguishers at once',
  'q09_c': 'From above into the middle of the flames, extinguishers one '
      'after another',
  'q10': 'Where do most reportable driver accidents happen?',
  'q10_a': 'In traffic at high speed',
  'q10_b': 'When getting out/climbing down — falls, stumbling, twisting '
      '(over 50%)',
  'q10_c': 'While refuelling the vehicle',
  'q11': 'What is part of the departure check before every trip?',
  'q11_a': 'Only a glance at the fuel tank',
  'q11_b': 'Check lights, tyres, brakes, mirrors, load securing and seat '
      'adjustment',
  'q11_c': 'The check is only needed after workshop visits',
  'q12': 'What applies to alcohol and drugs in your daily work as a '
      'driver?',
  'q12_a': 'One beer at lunch break is allowed',
  'q12_b': 'Forbidden — nobody may endanger themselves or others through '
      'intoxicating substances',
  'q12_c': 'Only forbidden while driving, allowed during breaks',
  'q13': 'A colleague is lying on the yard after a fall. A trained station first aider is already with him. What applies to you?',
  'q13_a': 'Nothing further — a first aider is there, your duty is done',
  'q13_b': 'You must make sure help is actually happening and alert or guide in the emergency services — the duty to alert always remains',
  'q13_c': 'You must treat him yourself because you saw him first',
  'q14': 'Burning liquid is running down the outside of a container. How do you extinguish it?',
  'q14_a': 'From the bottom up, so the puddle goes out first',
  'q14_b': 'From the side, straight through the flames',
  'q14_c': 'Start at the top where it escapes and work downwards',
  'q15': 'You get out of the vehicle with a parcel in your left hand. What is the mistake?',
  'q15_a': 'With a parcel in your hand only two contact points remain — put it down first, then get out',
  'q15_b': 'No mistake, as long as you hold on with your right hand',
  'q15_c': 'No mistake, as long as you get out slowly',
  'q16': 'You used a 6 kg powder extinguisher but only pressed briefly. It still feels full. What do you do?',
  'q16_a': 'Hang it back on the wall bracket, it is still full',
  'q16_b': 'Send it for refilling and report the need for a replacement — a used extinguisher never goes back on the wall',
  'q16_c': 'Keep it in the vehicle as a spare',
  'q17': 'For three weeks you have had a route that regularly cannot be completed. What is the right way?',
  'q17_a': 'Put up with it, that is part of the job',
  'q17_b': 'Just drive slower and skip stops',
  'q17_c': 'Tell your dispatcher specifically what does not work and where — the more precise, the sooner planning changes',
  'q18': 'When must the employer report an accident at work to the accident insurance institution?',
  'q18_a': 'For every injury, however small',
  'q18_b': 'When the inability to work lasts more than 3 calendar days — the report must be filed within 3 days',
  'q18_c': 'Only for fatal accidents',
  'q19': 'What does protection class S3 mean for safety shoes?',
  'q19_a': 'Waterproof for at least 60 minutes plus penetration-resistant and profiled sole',
  'q19_b': 'Only antistatic with a fuel-resistant sole',
  'q19_c': 'Made completely of rubber',
  'q20': 'Why does the rule "move only one point" apply when climbing down?',
  'q20_a': 'To make it faster',
  'q20_b': 'Because three points must always keep a firm hold — if one slips, the others still carry you',
  'q20_c': 'Because it protects the step',
};
