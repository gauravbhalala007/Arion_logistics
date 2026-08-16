// lib/data/safety_training/safety_content_en.dart
//
// Inhalte der Sicherheitsunterweisung — englische Fassung
// (uebersetzt aus DE-Master). Aufbau, IDs, Assets und CalloutTone
// identisch zur deutschen Fassung.

import 'safety_blocks.dart';

const String _a = 'assets/academy/safety/';

const List<SafetyChapterContent> safetyContentEn = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ch01',
    title: 'Legal basis & your duties',
    summary: 'Why health and safety exists — and what you must contribute',
    asset: '${_a}ch01_grundlagen.svg',
    slides: [
      SafetySlide(
        title: 'What health and safety is built on',
        asset: '${_a}ch01_grundlagen.svg',
        blocks: [
          ParagraphBlock(
            'Health and safety at work is not a voluntary offer from your '
            'employer, it is required by law. It rests on two pillars: '
            'state law and the rules of the accident insurance '
            'institutions.',
          ),
          BulletsBlock([
            'Arbeitsschutzgesetz (ArbSchG) — the German health and safety '
                'act; it sets out the duties of the employer and the '
                'rights and duties of employees',
            'Ordinances — they put the act into concrete terms, e.g. on '
                'workplaces, work equipment safety and hazardous '
                'substances',
            'DGUV Vorschriften — binding rules of the employers\' liability '
                'insurance association, binding on you as an insured person',
            'DGUV Regeln und Informationen — implementation guidance and '
                'recommendations; not binding, but proven in practice',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'The difference that counts',
            text: 'DGUV Vorschriften are binding. DGUV Regeln show you how '
                'to apply them. DGUV Informationen are recommendations.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Your six duties as an employee',
        blocks: [
          ParagraphBlock(
            'Your employer has to protect you — you have to play your '
            'part. These duties apply to every employee, whatever your '
            'position and contract.',
          ),
          StepsBlock([
            'Look after your own safety and that of your colleagues',
            'Follow Betriebsanweisungen (operating instructions) and '
                'training',
            'Give first aid, or support effective first aid',
            'Report accidents and near misses — including small ones',
            'Report defects and faults immediately (damaged cables, '
                'broken equipment, faulty procedures)',
            'Use protective equipment as intended — safety shoes, gloves, '
                'high-visibility vest, hearing protection',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Alcohol, drugs, medication',
            text: 'You must not put yourself or others at risk through '
                'intoxicating substances. This applies for your whole '
                'working time — including your break, because you drive '
                'again afterwards. Medication that makes you drowsy counts '
                'too: if in doubt, ask your doctor.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ch02',
    title: 'Betriebsanweisungen (operating instructions)',
    summary: 'Binding instructions — and why they protect you',
    asset: '${_a}ch02_betriebsanweisungen.svg',
    slides: [
      SafetySlide(
        title: 'What a Betriebsanweisung is',
        asset: '${_a}ch02_betriebsanweisungen.svg',
        blocks: [
          ParagraphBlock(
            'A Betriebsanweisung is a binding instruction from your '
            'employer on how to handle vehicles, work equipment and '
            'hazardous substances. It is not a recommendation.',
          ),
          BulletsBlock([
            'It is on display at the depot — you are expected to know it',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'What you should know',
            text: 'If you breach a Betriebsanweisung, it can be held '
                'against you in an accident investigation. In the worst '
                'case that means shared responsibility for an accident — '
                'for you personally too.',
          ),
          ParagraphBlock(
            'The difference: the Betriebsanweisung governs how you handle '
            'a piece of work equipment or a hazardous substance. The '
            'Arbeitsanweisung (work instruction) governs how a work '
            'process runs.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Structure — six sections',
        blocks: [
          ParagraphBlock(
            'Every Betriebsanweisung is built the same way. Once you know '
            'the structure, you find the right section straight away when '
            'it matters.',
          ),
          StepsBlock([
            'Scope — what and who it applies to',
            'Hazards to people and the environment',
            'Protective measures and rules of conduct',
            'What to do if something goes wrong',
            'What to do after accidents, and first aid',
            'Disposal and maintenance',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Example: driving the van',
        blocks: [
          ParagraphBlock(
            'This is what concrete rules from a Betriebsanweisung for '
            'vehicles up to 3,5 t look like:',
          ),
          BulletsBlock([
            'Carry a valid driving licence',
            'No alcohol and no drugs before or during the drive',
            'Reverse only with a banksman where others are at risk',
            'Always lock the vehicle once you have left it',
            'Tow only with a tow bar',
            'Secure the scene, report every accident without delay',
            'Treat even minor injuries straight away and enter them in '
                'the Verbandbuch (first aid log)',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ask if in doubt',
            text: 'If an instruction is not clear to you, ask your '
                'dispatcher — before you set off, not afterwards.',
          ),
          SubheadBlock('The most important instructions'),
          ParagraphBlock(
            'You can find all Betriebsanweisungen at any time in the DA '
            'Academy under “Betriebsanweisungen”.',
          ),
          InstructionRefBlock([
            'baw_transporter',
            'baw_heben_tragen',
            'baw_winter',
          ]),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ch03',
    title: 'The 10 rules for working safely',
    summary: 'The core of your working day — valid every single day',
    asset: '${_a}ch03_sicheres_arbeiten.svg',
    slides: [
      SafetySlide(
        title: 'Ten rules, every day',
        asset: '${_a}ch03_sicheres_arbeiten.svg',
        blocks: [
          StepsBlock([
            'Work safely and with care',
            'Pre-departure check before setting off',
            'Secure the load in the vehicle',
            'Drive professionally and observe the StVO (German road '
                'traffic regulations)',
            'Put on your seat belt',
            'Keep vehicles, tools and equipment in good order',
            'Work only in suitable footwear',
            'Be polite with colleagues and customers',
            'Keep to the break rules',
            'Be tolerant and respectful',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'The three with the biggest effect',
            text: 'Pre-departure check, load securing, seat belt. These '
                'three prevent most serious consequences — and together '
                'they cost you less than three minutes.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ch04',
    title: 'Personal protective equipment (PPE)',
    summary: 'Safety shoes and high-visibility vest — your daily duty',
    asset: '${_a}ch04_psa.svg',
    slides: [
      SafetySlide(
        title: 'Your PPE as a delivery driver',
        asset: '${_a}ch04_psa.svg',
        blocks: [
          ParagraphBlock(
            'Personal protective equipment is everything you wear on your '
            'body to protect yourself from hazards. In delivery work two '
            'items are compulsory every day:',
          ),
          FactsBlock([
            FactItem('1', 'Safety shoes'),
            FactItem('2', 'High-visibility vest'),
          ]),
          BulletsBlock([
            'Safety shoes — the whole working day, at the station as much '
                'as on the route',
            'High-visibility vest — within reach in the vehicle and put on '
                'before you get out at a breakdown, an accident or any '
                'stop at the roadside',
          ]),
          SubheadBlock('More PPE — depending on the task'),
          ParagraphBlock(
            'This equipment is not compulsory every day, but it may be '
            'needed for certain jobs. What applies to you is set out in '
            'the risk assessment and the Betriebsanweisung.',
          ),
          BulletsBlock([
            'Protective gloves — for sharp-edged consignments, cleaning '
                'and maintenance work, and in winter',
            'Hearing protection — where it is noisy, e.g. in certain '
                'areas of the hall',
            'Safety goggles — for work where liquid may splash',
            'Head protection — on building sites and where objects may '
                'fall',
            'Weather protection clothing — for continuous work outdoors',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Duty to use it',
            text: 'You must use PPE provided by your employer as intended '
                '(§ 15 Arbeitsschutzgesetz). Your employer provides it '
                'free of charge and has to monitor that it is used.',
          ),
          InstructionRefBlock(['baw_sicherheitsschuhe', 'baw_warnweste']),
        ],
      ),
      SafetySlide(
        title: 'Safety shoes: what they protect',
        blocks: [
          ParagraphBlock(
            'Foot protection is the PPE you need most often — and the one '
            'that is underestimated most often.',
          ),
          SubheadBlock('What they protect you from'),
          BulletsBlock([
            'Mechanical — knocks, crushing, falling parcels, treading on '
                'sharp objects',
            'Twisting your ankle — ankle-high shoes support the joint and '
                'prevent torn ligaments and ankle injuries',
            'Electrical — antistatic dissipation',
            'Chemical — acids, oils, fuels',
            'Thermal — heat and cold',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Why ankle-high',
            text: 'The most common injury in delivery work is twisting '
                'your ankle when getting out, on kerbs and on uneven '
                'paths. An ankle-high shoe supports the joint exactly '
                'where it gives way — a low shoe cannot do that.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Even when they are uncomfortable — and in summer too',
            text: 'You have to wear them on every working day, whatever '
                'the weather and however they feel. Summer is exactly when '
                'people switch — and exactly then the injuries happen. If '
                'the shoes pinch or rub, that is a reason for a different '
                'model, not a reason for trainers.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Check your shoes regularly',
            text: 'Worn tread, cracks or heavy soiling: have them '
                'replaced. Do not modify them yourself and never work in '
                'trainers — not even “just for a minute”.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Protection classes at a glance',
        blocks: [
          TableBlock(
            headers: ['Class', 'Properties'],
            rows: [
              [
                'S1',
                'Closed heel area, antistatic, fuel-resistant sole',
              ],
              ['S2', 'like S1 + water-resistant for at least 60 minutes'],
              ['S3', 'like S2 + penetration-resistant and profiled sole'],
              ['S4', 'like S2, all rubber (vulcanised)'],
              ['S5', 'like S4 + penetration-resistant sole'],
            ],
          ),
          SubheadBlock('When they matter most'),
          BulletsBlock([
            'On ladders, steps and stairs',
            'Around roll cages and pallet trucks',
            'On uneven paths and ramps',
          ]),
          ParagraphBlock(
            'What makes a good shoe: a firm fit, closed, heel support with '
            'cushioning, a flexible sole, a low heel and a slip-resistant '
            'tread.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ch05',
    title: 'What to do in a fire',
    summary: 'Use extinguishers properly and deal with vehicle fires',
    asset: '${_a}ch05_brandfall.svg',
    slides: [
      SafetySlide(
        title: 'Operating a fire extinguisher',
        asset: '${_a}ch05_brandfall.svg',
        blocks: [
          ParagraphBlock(
            'There are powder, water/foam and CO₂ extinguishers. They are '
            'all operated the same way:',
          ),
          StepsBlock([
            'Pull out the safety pin',
            'Press the striking knob',
            'Squeeze the nozzle lever',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'You only have seconds',
            text: 'An extinguisher runs empty faster than most people '
                'think. So use several extinguishers at the same time '
                'rather than one after another.',
          ),
          FactsBlock([
            FactItem('6–12 s', 'powder 1–2 kg'),
            FactItem('15–23 s', 'powder 6 kg'),
            FactItem('18–33 s', 'powder 12 kg'),
            FactItem('20–30 s', 'foam 6 l'),
            FactItem('5–10 s', 'CO₂ 2 kg'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Fighting a fire properly — step by step',
        blocks: [
          ParagraphBlock(
            'The order decides whether the fire goes out or flares up '
            'again. Seven steps worth remembering:',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}fire01_pin.svg',
              title: 'Get the extinguisher ready',
              caption: 'Pull the pin, press the striking knob, hold the '
                  'extinguisher upright. Only then walk to the fire.',
            ),
            IllustratedStep(
              asset: '${_a}fire02_wind.svg',
              title: 'Attack with the wind',
              caption: 'The wind must be at your back and carry the '
                  'extinguishing agent into the fire — never fight against '
                  'it. That keeps heat and smoke away from you.',
            ),
            IllustratedStep(
              asset: '${_a}fire03_surface.svg',
              title: 'Surface fire: start at the front',
              caption: 'Aim at the front edge of the flames, into the '
                  'embers — not at the tips of the flames. Then work '
                  'backwards bit by bit.',
            ),
            IllustratedStep(
              asset: '${_a}fire04_drip.svg',
              title: 'Dripping fire: from top to bottom',
              caption: 'If burning liquid runs down, start at the top '
                  'where it escapes and work downwards — otherwise it '
                  'keeps re-igniting from above.',
            ),
            IllustratedStep(
              asset: '${_a}fire05_together.svg',
              title: 'Several extinguishers at once',
              caption: 'If several extinguishers and helpers are there, '
                  'use them together at the same time. One after another '
                  'gives the fire time to recover in between.',
            ),
            IllustratedStep(
              asset: '${_a}fire06_watch.svg',
              title: 'Keep watching the fire site',
              caption: 'After putting it out, stay at the spot and watch. '
                  'Pockets of embers often re-ignite minutes later — keep '
                  'your distance and an extinguisher ready.',
            ),
            IllustratedStep(
              asset: '${_a}fire07_refill.svg',
              title: 'Have a used extinguisher refilled',
              caption: 'A used extinguisher never goes back on the wall — '
                  'not even after a short burst. Hand it in for refilling '
                  'straight away and report that a spare is needed.',
            ),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'When not to fight the fire',
            text: 'Never put yourself in danger. If the fire is bigger '
                'than a waste-paper bin, there is heavy smoke or you would '
                'risk your escape route: get out, close the door, call 112 '
                'and warn others.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Vehicle fire',
        blocks: [
          SubheadBlock('Most common causes'),
          BulletsBlock([
            'Leaks of fuel or oil',
            'Insulating material on hot components',
            'Mechanical damage',
            'Electrical faults',
            'Burning waste containers',
          ]),
          SubheadBlock('What you do'),
          StepsBlock([
            'Do not stop in tunnels or on bridges — drive out if you can',
            'Hazard lights on, head for a suitable spot, stop',
            'Leave the vehicle, keep your distance',
            'Alert the fire brigade on 112 — give the location and the '
                'direction of travel',
            'Only try to fight the fire yourself once it is safe',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Bonnet: take care',
            text: 'Open it only with gloves and only a crack. The sudden '
                'supply of oxygen can cause a jet of flame.',
          ),
          SubheadBlock('What the control room needs to know'),
          BulletsBlock([
            'Where is the fire?',
            'What is burning, and how much of it?',
            'How many people are injured, and how badly?',
            'What is loaded?',
            'Who is reporting it?',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Do not hang up',
            text: 'Never end the call yourself. Wait for questions — the '
                'control room ends the conversation.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'ch06',
    title: 'First aid',
    summary: 'Your duty, your cover and the paperwork',
    asset: '${_a}ch06_erste_hilfe.svg',
    slides: [
      SafetySlide(
        title: 'Helping is a duty — and you are covered',
        asset: '${_a}ch06_erste_hilfe.svg',
        blocks: [
          ParagraphBlock(
            'Everyone is obliged to give first aid — as far as can '
            'reasonably be expected and without putting yourself at '
            'serious risk. As a layperson too.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 323c StGB — failure to render assistance',
            text: 'Anyone who does not help although it could reasonably '
                'be expected is committing an offence: up to one year in '
                'prison or a fine. That also applies to “rubberneckers” '
                'who get in the way of helpers.',
          ),
          SubheadBlock('If you help, you cannot get it wrong'),
          BulletsBlock([
            'As a first aider you are not liable for mistakes — except in '
                'cases of intent or gross negligence',
            'You are covered by statutory accident insurance while helping',
            'You do not bear any costs; damage to your property is '
                'normally reimbursed',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'The only real mistake',
            text: 'Doing nothing. Anything else is better than looking '
                'away.',
          ),
        ],
      ),
      SafetySlide(
        title: 'First aiders at the station — and you',
        blocks: [
          ParagraphBlock(
            'There are trained workplace first aiders at the station. The '
            'employer sees to that: organising first aid is his job '
            '(§ 24 DGUV Vorschrift 1), and he has to provide a minimum '
            'number of trained first aiders '
            '(§ 26 DGUV Vorschrift 1).',
          ),
          FactsBlock([
            FactItem('1', 'first aider for 2–20 people present'),
            FactItem('10 %', 'of those present in other businesses'),
            FactItem('2 years', 'refresher training for first aiders'),
          ]),
          ParagraphBlock(
            'Where several employers work on the same site, they have to '
            'coordinate and inform each other '
            '(§ 8 Arbeitsschutzgesetz). They can agree that the '
            'first aid setup of the station is shared. That governs how '
            'the businesses work together — not your personal duty.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'That does not let you off',
            text: 'The duty to render assistance under § 323c StGB applies '
                'to everyone personally. Trained first aiders at the '
                'station change nothing about that.',
          ),
          SubheadBlock('How it works legally'),
          BulletsBlock([
            'If someone is already there and really is helping enough, '
                'you do not have to step in yourself',
            'The duty to alert the emergency services and fetch help '
                'remains in every case',
            'You have to satisfy yourself that help really is being given '
                '— looking away and thinking “someone will take care of '
                'it” is not enough',
            'Support the first aider as instructed: secure the scene, '
                'guide in the emergency services, fetch supplies, keep '
                'others away',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'On the road you are on your own',
            text: 'You spend most of your working time not at the station '
                'but out on the road. There is no station first aider '
                'there — in an emergency on your route, you are the first '
                'aider.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Making an emergency call',
        blocks: [
          FactsBlock([
            FactItem('112', 'emergency number, Europe-wide'),
          ]),
          SubheadBlock('The five W questions'),
          StepsBlock([
            'Where did it happen?',
            'How many people are injured?',
            'What happened?',
            'Who is calling?',
            'Wait for questions',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Basic rules when helping',
            text: 'Stay calm · act fast · watch your own safety · secure '
                'the scene · help to the best of your knowledge.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Documentation & reporting',
        blocks: [
          ParagraphBlock(
            'Every injury is documented — including the small cut. That '
            'protects you if there are consequences later on.',
          ),
          SubheadBlock('What goes in the Verbandbuch (first aid log)'),
          BulletsBlock([
            'Time and place',
            'How it happened',
            'Type and extent of the injury',
            'Name of the injured person',
            'Witnesses and first aiders',
          ]),
          FactsBlock([
            FactItem('> 3 days', 'off sick → accident report needed'),
            FactItem('3 days', 'deadline for the report'),
            FactItem('5 years', 'retention, confidential'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Report immediately',
            text: 'Fatal accidents, mass accidents and serious damage to '
                'health are reported by the employer without delay — so '
                'always inform your employer straight away.',
          ),
          ParagraphBlock(
            'First aid kits must be complete. Check the expiry date and '
            'report anything missing.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 7
  SafetyChapterContent(
    id: 'ch07',
    title: 'Sitting & moving',
    summary: 'Protect your back, keep your concentration',
    asset: '${_a}ch07_sitzen_bewegen.svg',
    slides: [
      SafetySlide(
        title: 'Why sitting becomes a risk',
        asset: '${_a}ch07_sitzen_bewegen.svg',
        blocks: [
          ParagraphBlock(
            'Sitting for a long time in a badly adjusted seat is more '
            'than uncomfortable — it costs you attention and reaction '
            'time.',
          ),
          BulletsBlock([
            'Fatigue and dropping concentration',
            'Tension and back pain',
            'Trouble in the cervical and lumbar spine',
            'Accidents caused by a delayed reaction',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Adjusting your seat properly',
        blocks: [
          ParagraphBlock(
            'Take two minutes before your first drive. Seven settings '
            'make the difference:',
          ),
          StepsBlock([
            'Seat height and fore-and-aft position',
            'Seat cushion depth',
            'Angle of the seat cushion',
            'Angle of the backrest',
            'Lumbar support',
            'Head restraint',
            'Steering wheel and belt routing',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Dynamic sitting',
            text: 'Back right against the backrest, sit upright — and keep '
                'changing your posture slightly. The best seating position '
                'is the next one.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Exercises for in between',
        blocks: [
          SubheadBlock('Seated'),
          BulletsBlock([
            'Pull the steering wheel firmly apart — hold for 3–6 seconds, '
                '3 repetitions',
            'Press your knees against the pressure of your hands — '
                '3–6 seconds, 5 repetitions',
            'Push down on the seat cushion and lift your weight — '
                '3 repetitions',
          ]),
          SubheadBlock('Standing'),
          BulletsBlock([
            'Stretch your arms upwards — about 8 seconds, 3–5 repetitions',
            'Hands behind your head, elbows back — about '
                '8 seconds, 3–5 repetitions',
            'Heel on a step about 30 cm high, stretch the leg — about '
                '8 seconds, 2–3 times per leg',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'A trained back takes more',
            text: 'Use your break time — not extra time.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 8
  SafetyChapterContent(
    id: 'ch08',
    title: 'Pressure & concentration',
    summary: 'Staying capable and alert through the day',
    asset: '${_a}ch08_psychische_belastung.svg',
    slides: [
      SafetySlide(
        title: 'Why this belongs to health and safety',
        asset: '${_a}ch08_psychische_belastung.svg',
        blocks: [
          ParagraphBlock(
            'People under pressure react more slowly, miss more and make '
            'mistakes. That is exactly why pressure is a safety topic — '
            'not only once somebody falls ill.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Required by law',
            text: 'Since 2013 the risk assessment has had to cover mental '
                'strain at work explicitly '
                '(§ 5 Abs. 3 Nr. 6 Arbeitsschutzgesetz). What is assessed '
                'are the working conditions — not individual people.',
          ),
          SubheadBlock('What creates pressure on the road'),
          BulletsBlock([
            'Tight time windows, traffic jams, roadworks, hunting for a '
                'parking space',
            'Unclear responsibilities when loading and unloading',
            'Missing or late information about the route',
            'Technical problems with the vehicle or a device',
            'Difficult situations with customers',
          ]),
          ParagraphBlock(
            'These are conditions the business can do something about. So '
            'the most important rule is: report it while it can still be '
            'sorted out.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Staying focused — how it works in practice',
        blocks: [
          SubheadBlock('During the route'),
          BulletsBlock([
            'Use breaks as a tool: get out for a moment, look into the '
                'distance, walk a few steps — that measurably restores '
                'your attention',
            'Drink enough and eat regularly',
            'Do not manoeuvre under time pressure — those two minutes are '
                'cheaper than a dent',
            'Only use your phone when stopped, enter addresses before you '
                'set off',
            'After a difficult customer contact, take a breath before you '
                'drive on',
          ]),
          SubheadBlock('Speak up early instead of putting up with it'),
          ParagraphBlock(
            'If something is permanently wrong, tell your dispatcher — '
            'early and specifically. A route that regularly cannot be '
            'done, a vehicle that causes trouble, a route with constant '
            'parking problems: all of that can be planned around once '
            'somebody knows.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Reporting specifics beats putting up with it',
            text: 'Say what exactly is going wrong and where — not just '
                'that it was stressful. The more specific your feedback, '
                'the more likely the planning changes.',
          ),
        ],
      ),
      SafetySlide(
        title: 'After exceptional events',
        blocks: [
          ParagraphBlock(
            'Some situations stay with you: a serious accident, a '
            'robbery, a first aid call with badly injured people. That is '
            'a normal reaction to an abnormal event — and no sign of '
            'weakness.',
          ),
          BulletsBlock([
            'Report the event to your supervisor, even if nothing '
                'happened to you',
            'After accidents at work there is support available through '
                'the Berufsgenossenschaft',
            'Many businesses have psychological first aiders or trauma '
                'guides — ask in the office',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'In an acute emergency',
            text: 'For an acute mental health crisis in Germany: '
                'Telefonseelsorge 0800 111 0 111 — free, anonymous, '
                'available around the clock.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 9
  SafetyChapterContent(
    id: 'ch09',
    title: 'Safe driving & the pre-departure check',
    summary: 'Two minutes of checks before every route',
    asset: '${_a}ch09_sicheres_fahren.svg',
    slides: [
      SafetySlide(
        title: 'The walk around the vehicle',
        asset: '${_a}ch09_sicheres_fahren.svg',
        blocks: [
          ParagraphBlock(
            'A pre-departure check is compulsory before every journey. It '
            'takes two minutes and finds exactly the faults that become '
            'expensive or dangerous out on the road.',
          ),
          BulletsBlock([
            'Lights front and rear',
            'Vision — mirrors and windows clean and undamaged',
            'Wheels — tyre pressure, tread, fixings',
            'Brakes — brake test, brake pressure',
            'Engine and drivetrain — oil, coolant and brake fluid, '
                'screen wash, no leaks',
            'Curtains and doors closed',
            'Number plates and warning boards clean',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Load & your workplace at the wheel',
        blocks: [
          SubheadBlock('Securing the load'),
          BulletsBlock([
            'Is the vehicle suitable for this load?',
            'Are the lashing straps undamaged?',
            'Is the load secured and protected against slipping?',
            'Are the axle loads and the permissible gross mass kept to?',
          ]),
          SubheadBlock('Your workplace'),
          BulletsBlock([
            'Seat and steering wheel adjusted properly',
            'No fault messages on the instruments',
            'Brake test unremarkable',
            'Driver assistance systems switched on and ready',
            'Ventilation working',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'In winter as well',
            text: 'Suitable tyres, snow chains or traction aids where '
                'needed, enough antifreeze in the coolant and screen wash, '
                'an ice scraper on board.',
          ),
          InstructionRefBlock(['baw_transporter', 'baw_winter']),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 10
  SafetyChapterContent(
    id: 'ch10',
    title: 'Breakdowns & accidents',
    summary: 'Secure the scene, help, document it properly',
    asset: '${_a}ch10_pannen_unfaelle.svg',
    slides: [
      SafetySlide(
        title: 'Basic rule and breakdowns',
        asset: '${_a}ch10_pannen_unfaelle.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'The basic rule',
            text: 'Protecting yourself comes before protecting others. '
                'Protecting people comes before protecting property.',
          ),
          SubheadBlock('When a breakdown is coming'),
          StepsBlock([
            'Look for a suitable place to stop early — e.g. when the '
                'coolant temperature is rising',
            'Switch on the hazard lights while you are still rolling',
            'Get to the next parking area if you can, otherwise the far '
                'right-hand edge of the carriageway',
            'Apply the parking brake, side lights on in the dark',
            'Put on your high-visibility vest — before you get out',
            'Set up the warning triangle',
          ]),
          FactsBlock([
            FactItem('100 m', 'warning triangle, country road'),
            FactItem('150–400 m', 'warning triangle, motorway'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Emergency plan after an accident',
        blocks: [
          StepsBlock([
            'Stop — always, even if nobody is there',
            'Secure the scene — hazard lights, parking brake, side lights '
                'in the dark, high-visibility vest before you get out, '
                'warning triangle',
            'Give first aid — without delay',
            'Call 112 — if it is urgent, even before first aid',
            'Exchange personal details — name, address, registration, '
                'insurance',
            'Call the police — for personal injury, high property damage '
                'or suspected alcohol/drugs',
            'Secure evidence — photos of the scene and the damage, '
                'contact details of witnesses',
            'Inform your employer and agree what happens next, check that '
                'you are fit to drive, pack the warning triangle away',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Parking damage & the most common injury',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'A note is not enough',
            text: 'If you clip a parked car and nobody is there: wait at '
                'least 30 minutes. After that leave your name and address '
                'AND report the accident without delay at the nearest '
                'police station. Otherwise it is a hit and run.',
          ),
          SubheadBlock('Where drivers really get hurt'),
          FactsBlock([
            FactItem('51,6 %', 'slips, trips and falls'),
            FactItem('7,2 %', 'road traffic accidents'),
          ]),
          ParagraphBlock(
            'Most reportable accidents do not happen in traffic but when '
            'climbing into and out of the cab or the load area.',
          ),
          DoDontBlock(
            doTitle: 'Right',
            dos: [
              'Use the steps and grab handles provided',
              'Three points of contact when getting in and out',
              'Keep the steps clean and clear',
              'Wear suitable footwear',
            ],
            dontTitle: 'Dangerous',
            donts: [
              'Jumping down from the cab or the load area',
              'Using steps that are dirty, iced up or blocked',
              'Climbing on parts of the vehicle not meant for it, or on '
                  'the load',
              'Using damaged ladders',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 11
  SafetyChapterContent(
    id: 'ch11',
    title: 'The 3-point rule',
    summary: 'Getting in and out — the single most important rule',
    asset: '${_a}step3p_cover.svg',
    slides: [
      SafetySlide(
        title: 'Always 3 of 4 points of contact',
        asset: '${_a}step3p_cover.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'The basic rule',
            text: '2 hands + 1 foot  OR  2 feet + 1 hand. Three points '
                'always have firm contact with the vehicle.',
          ),
          ParagraphBlock(
            'You get in and out dozens of times a day — in a hurry, in '
            'the rain, with your hands full. That is exactly when most '
            'accidents happen. Three firm points give you support and '
            'prevent falls and injuries to ankle, knee and back.',
          ),
          FactsBlock([
            FactItem('51,6 %', 'of all accidents are falls'),
            FactItem('7,2 %', 'are road traffic accidents'),
          ]),
          ParagraphBlock(
            'No other single habit in your working day prevents as many '
            'injuries as this one. That is why it comes at the end of '
            'this training — as the thing that should stick.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The four rules in detail',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}step3p_01_face.svg',
              title: 'Face the vehicle',
              caption: 'Always get out facing the vehicle — never jump '
                  'out backwards or sideways. Jumping is the most common '
                  'cause of accidents. Always use the step and the grab '
                  'handles.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_02_hands.svg',
              title: 'Put it down first, then grip',
              caption: 'No parcels in your hand when getting in and out. '
                  'Put the consignment down first or stow small items in '
                  'a bag or on your belt — your hands stay free to hold '
                  'on.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_03_onepoint.svg',
              title: 'Move one point only',
              caption: 'Move only one hand or one foot at a time, while '
                  'the other three have a firm hold. Do not rush — not '
                  'even when the route is pressing.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_04_steps.svg',
              title: 'Watch the steps and your grip',
              caption: 'Keep an eye on wet, snow, oil and dirt. Step '
                  'calmly and under control, and clean the steps first if '
                  'you need to.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Two things that go with it',
        blocks: [
          SubheadBlock('Mid-height safety shoes'),
          ParagraphBlock(
            'Mid-height shoes enclose the ankle and stabilise the joint '
            'considerably better — and that is exactly where you twist it '
            'when climbing down.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Twisted it before?',
            text: 'If you have had ankle trouble already, ask for '
                'mid-height shoes — before the next route, not after it.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}step3p_05_phone.svg',
              title: 'No private phone in your hand',
              caption: 'Calling, typing and scrolling breaks your '
                  'concentration — and that is exactly what causes falls '
                  'and accidents. Private calls and messages wait until '
                  'your break. When getting in and out, the phone stays '
                  'put away.',
            ),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'The short version',
            text: 'Face the vehicle · keep three points · hands free · '
                'mid-height safety shoes · no private phone · use the '
                'steps instead of jumping.',
          ),
        ],
      ),
    ],
  ),
];
