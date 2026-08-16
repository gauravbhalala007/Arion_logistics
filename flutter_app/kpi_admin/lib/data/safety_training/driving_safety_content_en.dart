// lib/data/safety_training/driving_safety_content_en.dart
//
// DSP driving safety training content — English version.
// The structure is identical to the German master: modules M1–M10,
// the same slides and the same blocks. Only the wording is translated.

import 'safety_blocks.dart';

const List<SafetyChapterContent> drivingSafetyContentEn = [
  // ══════════════════════════════════════════════════ M1
  SafetyChapterContent(
    id: 'm1',
    title: 'Safety culture & responsibility',
    summary: 'Understand safety as your own decision — not as a rule '
        'book',
    asset: 'assets/academy/driving/m01_sicherheitskultur.svg',
    slides: [
      SafetySlide(
        title: 'Your round, your responsibility',
        blocks: [
          ParagraphBlock(
            'Every day you cover hundreds of kilometres and stop dozens '
            'of times. Every drive, every stop, every time you get out '
            'is a decision. The good news: almost every accident can be '
            'avoided. Safety does not start at the wheel, it starts in '
            'your head — before you set off.',
          ),
          FactsBlock([
            FactItem('120+', 'stops on a normal delivery day'),
            FactItem('250+', 'times getting in and out per round'),
            FactItem('1', 'second of inattention is enough for an '
                'accident'),
          ]),
          ParagraphBlock(
            'With that many repetitions it is not your skill that '
            'decides how the day goes, it is your routine. A good '
            'routine protects you even when you are tired or under '
            'pressure — a bad routine will get expensive sooner or '
            'later.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'The core idea',
            text: 'Safety is not something you do on top of the job. It '
                'is the way you do the job.',
          ),
        ],
      ),
      SafetySlide(
        title: 'What really happens in delivery work',
        blocks: [
          ParagraphBlock(
            'Delivery is one of the occupations with the most commuting '
            'and workplace accidents. The most common incidents are not '
            'spectacular: rear-end shunts in traffic, damage while '
            'reversing, falls when getting out, strained backs, twisted '
            'ankles. Everyday events — and underestimated for exactly '
            'that reason.',
          ),
          FactsBlock([
            FactItem('70 %', 'of van damage happens while manoeuvring '
                'and reversing'),
            FactItem('No. 1', 'tripping, slipping and falling is the '
                'most common cause of injury in delivery work'),
            FactItem('24', 'days off work on average after a fall'),
          ]),
          ParagraphBlock(
            'What stands out: almost all of these incidents happen at '
            'low speed or while stationary. They are not dramatic '
            'driving manoeuvres, they are normal, everyday actions that '
            'were carried out badly once.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Slow does not mean harmless',
            text: 'Damage caused while manoeuvring at walking pace '
                'quickly costs the company a four-figure sum — and costs '
                'you half a day of hassle.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The three basic attitudes',
        blocks: [
          ParagraphBlock(
            'Everything that follows in this training comes down to '
            'three attitudes. If you take away only these three, you '
            'have done the biggest part.',
          ),
          BulletsBlock([
            'Think ahead — spot hazards before they arise. Anyone who '
                'only reacts is always too late',
            'The time is yours — no parcel is worth an accident. Time '
                'pressure is a planning problem, not an excuse',
            'Set an example — your behaviour protects colleagues, '
                'pedestrians and children. On the road you are a '
                'professional, not a private driver',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Remember',
            text: 'The best driver is not the fastest one, but the one '
                'nothing ever happens to — because he sees it coming.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Every drive is a chain of decisions',
        asset: 'assets/academy/driving/m01b_entscheidung.svg',
        blocks: [
          ParagraphBlock(
            'An accident is rarely a single mistake. Usually it is five '
            'or six small decisions that all look harmless on their own '
            '— and add up in the end. That is exactly why you can break '
            'the chain at any point.',
          ),
          RevealBlock(
            prompt: 'Case study: it is 17:40, you still have 22 stops '
                'open. The load floor is a mess, your phone is '
                'vibrating in its holder, and the road ahead is getting '
                'narrow. Where is the real risk here?',
            answer: 'Not in the narrow road ahead — but in what came '
                'before. The messy load floor costs you time at every '
                'stop, the lost time creates pressure, the pressure '
                'lowers your attention, and the phone takes away what '
                'is left. The right decision was due two hours earlier: '
                'sort the load space, silence the phone, plan a '
                'realistic pace. Now the only thing that helps is to '
                'stop, take a breath, carry on stop by stop and report '
                'the planning problem afterwards.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Breaking the chain',
            text: 'Whenever something feels wrong, ask yourself: which '
                'single link can I take out right now with 30 seconds '
                'of effort?',
          ),
        ],
      ),
      SafetySlide(
        title: 'Setting an example in the team',
        asset: 'assets/academy/driving/m01c_vorbild.svg',
        blocks: [
          ParagraphBlock(
            'Safety culture is not created by notices on a wall, but by '
            'what colleagues copy from each other. Anyone who starts '
            'new copies what the experienced people do — including the '
            'wrong things.',
          ),
          DoDontBlock(
            doTitle: 'Culture that carries you',
            dos: [
              'Talk openly about near misses, without anyone being '
                  'given a funny look',
              'Actively point out steps, grab handles and the blind '
                  'spot to new colleagues',
              'Report defects immediately, even if the round starts '
                  'later because of it',
              'Manoeuvre visibly cleanly even under time pressure',
            ],
            dontTitle: 'Culture that harms',
            donts: [
              '"We always do it that way here" as a justification',
              'Laughing at the colleague who gets out and checks',
              'Settling minor damage between yourselves instead of '
                  'reporting it',
              'Demonstrating shortcuts you would never teach a new '
                  'starter',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Near misses are worth their weight in gold',
            text: 'Every near miss you report is an accident that will '
                'not happen to the next colleague. Reporting is '
                'strength, not telling tales.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Who is actually liable?',
        blocks: [
          ParagraphBlock(
            'At the wheel you are the driver in charge — and therefore '
            'personally responsible. The company provides you with a '
            'safe vehicle, instructs you and plans the round. Whether '
            'you then keep your distance, wear your seat belt and get '
            'out before reversing is entirely your decision.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'What the law expects of you',
            text: '§ 1 StVO (German road traffic regulations) requires '
                'constant care and mutual consideration. § 3 (1) StVO '
                'requires you to drive only as fast as you can stop '
                'within the distance you can see. Both apply no matter '
                'what the sign says.',
          ),
          BulletsBlock([
            'Fines and penalty points hit you personally, not the '
                'company',
            'In cases of gross negligence the insurer can recover part '
                'of the cost from you',
            'If you endanger others, a traffic offence can become a '
                'criminal offence (§ 315c StGB, German criminal code)',
            'A driving ban means one thing for you as a professional '
                'driver: no work',
          ]),
          RevealBlock(
            prompt: 'One morning you notice that a brake light has '
                'failed. The dispatcher says: "Drive anyway, we have '
                'nobody else." Who carries the risk?',
            answer: 'You do. As the driver in charge you are liable for '
                'the roadworthy condition of the vehicle you move — a '
                'verbal instruction does not cancel that out. The right '
                'thing to do: report the defect, ask for a replacement '
                'vehicle or a repair, document the report. A failed '
                'brake light on a van is also exactly the kind of '
                'defect that leads to a rear-end collision.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist: your attitude',
        blocks: [
          ChecklistBlock(
            title: 'What I take away from module 1',
            items: [
              'I know that most damage happens slowly and in everyday '
                  'situations',
              'I think ahead instead of only reacting',
              'I treat time pressure as a planning problem, not as a '
                  'driving problem',
              'I report defects and near misses, even small ones',
              'I know that as the driver in charge I am personally '
                  'liable',
              'I am aware that new colleagues copy me',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'One sentence for the round',
            text: '"I drive so that everyone gets home safely — myself '
                'included."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M2
  SafetyChapterContent(
    id: 'm2',
    title: 'Vehicle check & load securing',
    summary: 'Check the vehicle before the round and secure the load so '
        'that nothing becomes a hazard',
    asset: 'assets/academy/driving/m02_fahrzeugcheck.svg',
    slides: [
      SafetySlide(
        title: 'Why the check is not a formality',
        blocks: [
          ParagraphBlock(
            'The walk-around before the round takes two minutes. It '
            'prevents breakdowns in the middle of the route, fines at a '
            'roadside check and, in the worst case, an accident you '
            'could have seen coming before you set off.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Duty to check before the shift',
            text: 'Under DGUV Vorschrift 70 (German accident '
                'prevention rules for vehicles) you must check your '
                'vehicle for obvious defects before the start of every '
                'shift. If you find defects that endanger operational '
                'safety, you must not set off — you report them.',
          ),
          FactsBlock([
            FactItem('2 min', 'is how long the full walk-around takes'),
            FactItem('4', 'stations: tyres, lights, fluids, load'),
          ]),
          ParagraphBlock(
            'Important: the check does not replace a garage '
            'inspection. You are looking for what catches your eye — '
            'not for hidden defects.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The walk-around — four stations',
        asset: 'assets/academy/driving/m02b_rundgang.svg',
        blocks: [
          ParagraphBlock(
            'Always walk around the van in the same order. A fixed '
            'order is the only way to forget nothing when the morning '
            'gets hectic.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/load01_reifen.svg',
              title: '1 · Tyres and wheels',
              caption: 'Walk all the way round once and look at all '
                  'four tyres: visibly flat, cracks, foreign objects, '
                  'is the tread still deep enough? A tyre that already '
                  'looks soft in the morning will not last a full '
                  'round.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load02_licht.svg',
              title: '2 · Lights and number plate',
              caption: 'Check sidelights, dipped beam, indicators, '
                  'brake lights and reversing lights — brake lights via '
                  'the reflection on a wall or with a colleague if '
                  'needed. The number plate must be clear and legible.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load03_fluessigkeiten.svg',
              title: '3 · Fluids and ground',
              caption: 'One look under the van: traces of oil, coolant '
                  'or brake fluid on the ground are always a reason to '
                  'report. Also top up the screen wash — with antifreeze '
                  'in winter.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load04_ladung.svg',
              title: '4 · Load space and load',
              caption: 'Open the doors and look inside: is everything '
                  'firmly in place, are the bulkhead net and lashing '
                  'straps tensioned, is nothing lying loose on top? '
                  'Whatever stands loose here flies forward at the '
                  'first emergency stop.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Tyres: your only contact with the road',
        blocks: [
          ParagraphBlock(
            'Four contact patches, each about the size of a postcard — '
            'that is all that connects your loaded van to the road '
            'surface. Everything you learn about braking, steering and '
            'grip depends on those four patches.',
          ),
          FactsBlock([
            FactItem('1.6 mm', 'legal minimum tread depth'),
            FactItem('3 mm', 'recommended minimum tread in summer'),
            FactItem('4 mm', 'recommended minimum tread in winter'),
            FactItem('60 € + 1 pt', 'if the tread depth is too low'),
          ]),
          BulletsBlock([
            'Check tread depth with a 1-euro coin: the golden rim is '
                '3 mm wide — if it disappears into the tread, you still '
                'have enough',
            'Check tyre pressure on cold tyres and adjust it to the '
                'load — loaded you need more pressure than empty',
            'Watch for uneven wear: worn on one side means a tracking '
                'or pressure problem',
            'Report bulges, cracks and embedded screws immediately',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Too little pressure is more dangerous than too '
                'much',
            text: 'An underinflated tyre flexes, gets hot and can burst '
                'when fully loaded. On top of that the braking distance '
                'grows and the risk of aquaplaning rises.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lights, windows, mirrors',
        blocks: [
          ParagraphBlock(
            'Being seen is just as important as seeing. A failed brake '
            'light on a van is the classic cause of a rear-end '
            'collision in which you are not the one at fault — but end '
            'up with the damage anyway.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'A clear view is compulsory',
            text: 'Under § 23 (1) StVO you must make sure that your '
                'view and hearing are not impaired — by the load, by '
                'passengers, or by iced-up or dirty windows. A scraped '
                '"peephole" is expressly not enough.',
          ),
          BulletsBlock([
            'Adjust the mirrors while stationary, before the engine is '
                'running — never while driving',
            'Set the wing mirrors so that a narrow strip of your own '
                'vehicle stays visible: that is your reference point',
            'Keep windows and mirrors clean inside and out — grease on '
                'the inside dazzles badly at night',
            'Have smearing wiper blades replaced immediately',
          ]),
          RevealBlock(
            prompt: 'During the walk-around you notice: the right wing '
                'mirror wobbles and is cracked. You still have 190 '
                'stops ahead of you. Drive or not?',
            answer: 'Do not drive before it has been reported. The '
                'right wing mirror is exactly the one you use to cover '
                'the blind spot towards cyclists and the pavement — and '
                'that is precisely where the serious turning accidents '
                'happen. A cracked, wobbling mirror is a defect that '
                'affects road safety. Report it, have it replaced or '
                'change vehicles.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Load securing: understanding the forces',
        blocks: [
          ParagraphBlock(
            'The load must be secured so that it cannot shift even '
            'during an emergency stop or a sudden swerve. What that '
            'means in practice is set out in the recognised rules of '
            'engineering — and those work with clear figures.',
          ),
          FactsBlock([
            FactItem('0.8 g', 'forward force that must be secured '
                'against'),
            FactItem('0.5 g', 'force to the rear and to the sides'),
            FactItem('16 kg', 'restraining force a single 20 kg parcel '
                'needs under braking'),
          ]),
          ParagraphBlock(
            'In plain terms: during an emergency stop a 20 kg parcel '
            'pushes forward with around 16 kg — as if you had shoved a '
            'full crate of water towards the bulkhead. With twenty such '
            'parcels that is over 300 kg all trying to move forward at '
            'the same time.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 22 StVO — load',
            text: 'The load must be stowed and secured so that it '
                'cannot slip, fall over, roll back and forth or fall '
                'off even during an emergency stop or a sudden swerve. '
                'An unsecured load is punished with a fine, and with a '
                'penalty point if others are endangered — and it hits '
                'the driver.',
          ),
        ],
      ),
      SafetySlide(
        title: 'What 20 kg can do in an emergency',
        blocks: [
          ParagraphBlock(
            'The 0.8 g applies to braking and swerving. In a real '
            'impact, much higher decelerations act over a very short '
            'period — the impact force of an unsecured parcel is then '
            'many times its own weight.',
          ),
          RevealBlock(
            prompt: 'Case study: a 12 kg consignment is lying on the '
                'passenger seat because it is the next stop. In a '
                'built-up area you have to brake hard for a child. What '
                'happens to the parcel?',
            answer: 'It carries on at your original speed until '
                'something stops it — the dashboard, the windscreen or '
                'your head in a side impact. Even during a normal '
                'emergency stop it flies off the seat into the '
                'footwell, where it can end up under the brake pedal. '
                'That is exactly why no consignment belongs up front: '
                'the next stop is pre-sorted in the load space, not '
                'parked temporarily on the passenger seat.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Nothing in the cab',
            text: 'No parcel, no roll cage, no loose tools in the '
                'driver\'s area. An object under the brake pedal takes '
                'the brakes away from you at exactly the moment you '
                'need them.',
          ),
        ],
      ),
      SafetySlide(
        title: 'How to load correctly',
        asset: 'assets/academy/driving/m02c_ladung.svg',
        blocks: [
          ParagraphBlock(
            'The basic rule: heavy at the bottom, heavy at the front, '
            'weight spread evenly over the axles. A van loaded high has '
            'a high centre of gravity — and that decides whether you '
            'still slide in a bend or already tip over.',
          ),
          DoDontBlock(
            doTitle: 'Secured',
            dos: [
              'Heavy parcels at the bottom and at the front against '
                  'the bulkhead',
              'Weight spread evenly left and right',
              'Load tightly against each other — close gaps so that '
                  'nothing can build up momentum',
              'Lashing straps and bulkhead net tensioned, even as the '
                  'load space empties',
              'Check briefly after every reload',
            ],
            dontTitle: 'Unsecured',
            donts: [
              'Heavy parcels stacked loose on top',
              'Consignments in the footwell or on the passenger seat',
              'Everything just shoved in "somehow", gaps left open',
              'Bulkhead net released because it gets in the way when '
                  'reaching in',
              'Load "held in place" only by your own body weight',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'The empty load space is the most dangerous one',
            text: 'The less there is inside, the more distance the '
                'remaining parcel has to build up speed. Half empty '
                'does not mean half as dangerous — it means secure it '
                'again.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tidy cab & seat belt',
        blocks: [
          ParagraphBlock(
            'Drink, phone, scanner, delivery notes — everything gets a '
            'fixed place. Anything that rolls, rattles or flies pulls '
            'your eyes off the road. A tidy driving position is a safe '
            'driving position.',
          ),
          FactsBlock([
            FactItem('30 €', 'fine for not wearing a seat belt'),
            FactItem('Every', 'stop: put the belt back on, even for '
                '200 metres'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 21a StVO — seat belt requirement',
            text: 'The seat belt must be worn while driving — with no '
                'exception for short distances between two stops. In an '
                'accident without a belt you may also be held partly to '
                'blame.',
          ),
          ParagraphBlock(
            'In delivery work in particular, the seat belt is the '
            'safety device most often left off — because there are only '
            'a few hundred metres between two stops. Yet that is '
            'exactly where most built-up-area collisions happen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist before setting off',
        blocks: [
          ChecklistBlock(
            title: 'Before I set off',
            items: [
              'Walk-around done in a fixed order',
              'Tyres: tread, pressure and damage checked',
              'Lights checked all round, number plate legible',
              'No traces of fluid under the vehicle',
              'Windows and mirrors clean, mirrors adjusted',
              'Heavy parcels at the bottom and front, weight spread',
              'Lashing straps and bulkhead net tensioned',
              'Nothing loose in the cab, phone in its holder',
              'Hi-vis vest within reach, warning triangle on board',
              'Seat belt on',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M3
  SafetyChapterContent(
    id: 'm3',
    title: 'Defensive & anticipatory driving',
    summary: 'Manage distance, speed and attention so that you always '
        'have a reserve',
    asset: 'assets/academy/driving/m03_defensiv.svg',
    slides: [
      SafetySlide(
        title: 'Stopping distance = thinking distance + braking '
            'distance',
        blocks: [
          ParagraphBlock(
            'The stopping distance is the distance from the moment you '
            'spot the hazard until the vehicle stands still. It '
            'consists of two parts: the thinking distance, which you '
            'still cover at full speed, and the actual braking '
            'distance.',
          ),
          FactsBlock([
            FactItem('approx. 1 s', 'reaction time of an alert, sober '
                'driver'),
            FactItem('× 3', 'thinking distance = speed ÷ 10, times 3'),
            FactItem('²', 'braking distance = (speed ÷ 10) squared'),
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'The rules of thumb',
            text: 'Thinking distance = (km/h ÷ 10) × 3. Braking '
                'distance = (km/h ÷ 10) × (km/h ÷ 10). Added together '
                'they give the stopping distance. In an emergency stop '
                'the braking distance is halved.',
          ),
          ParagraphBlock(
            'The decisive point: the braking distance does not grow in '
            'proportion to speed, it grows with the square. Twice the '
            'speed means four times the braking distance — that is why '
            '20 km/h more in a residential street changes everything.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Calculate instead of guessing',
        blocks: [
          TableBlock(
            headers: ['Speed', 'Reaction', 'Braking', 'Stopping'],
            rows: [
              ['30 km/h', '9 m', '9 m', '18 m'],
              ['50 km/h', '15 m', '25 m', '40 m'],
              ['70 km/h', '21 m', '49 m', '70 m'],
              ['100 km/h', '30 m', '100 m', '130 m'],
            ],
          ),
          ParagraphBlock(
            'For comparison: a Sprinter is about 6 metres long. At '
            '50 km/h you therefore need around seven vehicle lengths to '
            'come to a stop — and the first two and a half of them pass '
            'before you even touch the pedal.',
          ),
          RevealBlock(
            prompt: 'Do the maths: you are driving at 50 km/h through a '
                'residential street. Twenty metres ahead a child runs '
                'onto the road between two parked cars. Will you stop '
                'in time?',
            answer: 'No. Your thinking distance alone is 15 metres, '
                'followed by 25 metres of braking distance — 40 metres '
                'in total. Even with an emergency stop (15 m + 12.5 m = '
                '27.5 m) 20 metres are not enough. At 30 km/h, by '
                'contrast: 9 m reaction + 9 m braking = 18 metres — you '
                'stop two metres short. That is exactly the difference '
                'between a fright and a serious accident.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The two-second rule',
        asset: 'assets/academy/driving/m03b_abstand.svg',
        blocks: [
          ParagraphBlock(
            'Keeping your distance is not politeness, it is your '
            'reaction time expressed in metres. And because it is '
            'thought of in seconds, it adjusts to your speed '
            'automatically.',
          ),
          StepsBlock([
            'Pick a fixed point at the roadside — a sign, a lamp post, '
                'a road marking',
            'When the vehicle in front passes that point, start '
                'counting: "one thousand and one, one thousand and '
                'two"',
            'If you reach the point before "two", you are following '
                'too closely',
            'In wet weather, fog or darkness increase it to three '
                'seconds',
          ]),
          FactsBlock([
            FactItem('2 s', 'minimum gap on a dry road'),
            FactItem('3 s+', 'in wet weather, fog and darkness'),
            FactItem('28 m', 'is what 2 seconds means at 50 km/h'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 4 (1) StVO — following distance',
            text: 'As a rule the gap to the vehicle in front must be '
                'large enough to stop behind it even if it brakes '
                'suddenly. Outside built-up areas the rule of thumb is '
                'half the speedometer reading in metres.',
          ),
        ],
      ),
      SafetySlide(
        title: 'When the gap is missing',
        blocks: [
          RevealBlock(
            prompt: 'Case study: on a main road you are keeping a clean '
                '40-metre gap at 80 km/h. A car pulls into the gap and '
                'then brakes. What is the right thing to do now?',
            answer: 'Do not get annoyed, do not sound the horn, do not '
                'tailgate — ease off the accelerator and rebuild the '
                'gap. It costs you a few seconds and it is the only '
                'reaction that lowers your risk. Anyone who instead '
                'closes up to "defend" the gap no longer has 40 metres '
                'at 80 km/h but perhaps 15 — less than the 24 metres of '
                'thinking distance alone.',
          ),
          DoDontBlock(
            doTitle: 'Composed',
            dos: [
              'Calmly rebuild the gap after someone cuts in',
              'If someone tailgates you: keep right and let them pass',
              'Ease off early before traffic lights and roadworks',
              'In a traffic jam leave a gap to the vehicle in front so '
                  'you can pull out',
            ],
            dontTitle: 'Risky',
            donts: [
              'Closing up to stop someone cutting in',
              'Using headlight flashes and the horn to teach lessons',
              'Rolling right onto the bumper in stop-and-go traffic',
              'Judging the gap by feel instead of counting seconds',
            ],
          ),
          FactsBlock([
            FactItem('up to 400 €', 'fine for following too closely, '
                'plus points and a driving ban'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Look far ahead',
        asset: 'assets/academy/driving/m03c_blickfuehrung.svg',
        blocks: [
          ParagraphBlock(
            'Do not look at the bumper in front of you, look 12–15 '
            'seconds ahead — in a town that is about two blocks. That '
            'way you see brake lights, traffic lights, pedestrians and '
            'narrow spots early and do not have to react in a panic.',
          ),
          BulletsBlock([
            'A child at the kerb who has not looked yet',
            'A cyclist about to pull out around a parked car',
            'A car door with someone sitting behind it — rear lights '
                'on, a head in the interior mirror',
            'Brake lights three vehicles further ahead',
            'Wheelie bins at the roadside: a sign of manoeuvring '
                'traffic',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Your eyes steer the vehicle',
            text: 'You drive where you look. That is why, when you '
                'swerve, you always look at the free gap — never at the '
                'obstacle.',
          ),
          ParagraphBlock(
            'A short glance in the mirrors every few seconds is part of '
            'it. That way you always know what is happening behind you '
            'and do not have to check first in an emergency.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Speed is physics',
        blocks: [
          ParagraphBlock(
            'The speed limit is a maximum, not a target. In residential '
            'areas, near schools, alongside parked cars and in narrow '
            'streets, slower than the limit is often the only right '
            'choice.',
          ),
          FactsBlock([
            FactItem('×4', 'braking distance at twice the speed'),
            FactItem('18 m', 'stopping distance at 30 km/h'),
            FactItem('40 m', 'stopping distance at 50 km/h'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 3 (1) StVO — drive within your sight line',
            text: 'You may only drive as fast as you can stop within '
                'the distance you can see. In fog, in darkness or on a '
                'blind bend that is considerably less than the sign '
                'allows.',
          ),
          ParagraphBlock(
            'Work out for once what speeding really gains you: over ten '
            'kilometres of town driving, the difference between 50 and '
            '60 km/h saves you two minutes at best — and the next red '
            'light takes them straight back.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Why your loaded van drives differently',
        blocks: [
          ParagraphBlock(
            'A fully loaded van is a different vehicle from the same '
            'van when it was empty that morning. More mass means more '
            'kinetic energy for the brakes to get rid of — and a higher '
            'centre of gravity means less reserve in a bend.',
          ),
          FactsBlock([
            FactItem('3.5 t', 'permitted gross weight of your van'),
            FactItem('up to 1.4 t', 'payload — more than half the '
                'unladen weight'),
            FactItem('high', 'centre of gravity: panel vans tip over '
                'where cars still slide'),
          ]),
          BulletsBlock([
            'When loaded, brake earlier and more gently — the brakes '
                'need longer for the same deceleration',
            'Take bends noticeably slower: the load shifts outwards '
                'and increases the tendency to tip',
            'When swerving, do not jerk the wheel back — that is '
                'exactly what tips tall vehicles over',
            'Approach roundabouts and motorway exits at considerably '
                'lower speeds than you are used to',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'The tipping point comes without warning',
            text: 'Unlike a car, a tall panel van gives almost no '
                'warning before it tips. If you can hear the load '
                'shifting, you are already too fast — take the speed '
                'off before the bend, not in it.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The blind spot',
        asset: 'assets/academy/driving/m03d_toterwinkel.svg',
        blocks: [
          ParagraphBlock(
            'Your van has large blind spots — above all to the right of '
            'and diagonally behind the cab. A whole cyclist and bike '
            'fits in there without you seeing them in the mirror.',
          ),
          FactsBlock([
            FactItem('right', 'the biggest blind spot on panel vans'),
            FactItem('1.5 m', 'minimum clearance when overtaking '
                'cyclists in built-up areas'),
            FactItem('2 m', 'minimum clearance outside built-up areas'),
          ]),
          ParagraphBlock(
            'Adjusting the mirrors properly reduces the blind spot but '
            'does not remove it. That is why every lane change and '
            'every turn includes an active shoulder check — a short, '
            'real look over your shoulder, not just a nod towards the '
            'mirror.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Never assume you have been seen',
            text: 'Eye contact is the only reliable proof that somebody '
                'has noticed you. An indicator is an intention, not a '
                'guarantee.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Turning: the most dangerous moment',
        blocks: [
          ParagraphBlock(
            'Most serious collisions with cyclists and pedestrians '
            'happen while turning right. The reason is always the same: '
            'the cyclist carries straight on and is exactly in the area '
            'the driver can no longer see once the steering goes in.',
          ),
          RevealBlock(
            prompt: 'Case study: you want to turn right at a set of '
                'traffic lights. A cyclist has overtaken you on the '
                'left and is standing next to you. The lights turn '
                'green. What do you do first?',
            answer: 'Stay put and let them go first. As soon as you '
                'move off and turn in, they move into the blind spot on '
                'the right — and the rear of your vehicle also swings '
                'into their lane as you steer. The right way: shoulder '
                'check to the right before moving off, let cyclists and '
                'pedestrians through, then turn in slowly and look into '
                'the right-hand mirror again while turning. Anyone who '
                'relies on the mirror alone loses sight of them at '
                'exactly the moment it matters.',
          ),
          DoDontBlock(
            doTitle: 'Turning safely',
            dos: [
              'Indicate early and reduce speed clearly',
              'Shoulder check before turning in — not just the mirror',
              'Check to the right again while turning',
              'If in doubt, stop and let them through',
            ],
            dontTitle: 'Risky',
            donts: [
              'Turning on the move to take advantage of the gap',
              'Relying on the mirror alone',
              'Assuming cyclists will stay behind you',
              'Indicating only once you are already turning in',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'When turning and turning round',
            text: '§ 9 (5) StVO: when turning into a property, when '
                'turning round and when reversing you must rule out any '
                'danger to other road users — if necessary you must '
                'have someone guide you.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist: driving defensively',
        blocks: [
          ChecklistBlock(
            title: 'What I will put into practice from today',
            items: [
              'I know the rules of thumb for thinking and braking '
                  'distance',
              'I check my gap against a fixed point using two seconds',
              'I increase it to three seconds in the wet and in the '
                  'dark',
              'I look 12–15 seconds ahead instead of at the bumper',
              'When loaded I take bends slower and brake earlier',
              'I do a real shoulder check before every turn and lane '
                  'change',
              'I keep 1.5 m clearance when overtaking cyclists in '
                  'built-up areas',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M4
  SafetyChapterContent(
    id: 'm4',
    title: 'Reversing & manoeuvring',
    summary: 'Master the most common source of damage — reverse and '
        'manoeuvre safely in tight situations',
    asset: 'assets/academy/driving/m04_rueckwaerts.svg',
    slides: [
      SafetySlide(
        title: 'The number one source of damage',
        blocks: [
          ParagraphBlock(
            'Most van damage happens slowly — while reversing and '
            'manoeuvring: bollards, walls, lamp posts, other cars, open '
            'doors. And in the worst cases people standing in the blind '
            'area behind the vehicle.',
          ),
          FactsBlock([
            FactItem('70 %', 'of all van damage happens while '
                'manoeuvring'),
            FactItem('< 10 km/h', 'the speed at which most manoeuvring '
                'damage occurs'),
            FactItem('blind', 'an area several metres deep directly '
                'behind the vehicle'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Why here of all places',
            text: 'When reversing you lose the very thing that '
                'otherwise protects you: a clear view. At the same time '
                'it feels slow and therefore harmless — the most '
                'dangerous combination in everyday delivery work.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Avoid reversing rather than mastering it',
        blocks: [
          ParagraphBlock(
            'The safest reversing manoeuvre is the one you do not do. '
            'Think about how you will get away again while you are '
            'still approaching the stop — then you will not need to '
            'manoeuvre at all in the end.',
          ),
          BulletsBlock([
            'Where possible park nose-in and drive out forwards',
            'Better to stop 40 metres further on than to reverse into '
                'a tight entrance',
            'With dead ends and courtyards: think about how you will '
                'get out again before you drive in',
            'Memorise the turning places on your route — they are the '
                'same every day',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'What the law and DGUV require',
            text: '§ 9 (5) StVO: when reversing you must rule out any '
                'danger to others and, if necessary, have someone guide '
                'you. DGUV Vorschrift 70 (vehicles) requires the same: '
                'reverse only when any danger to people can be ruled '
                'out.',
          ),
        ],
      ),
      SafetySlide(
        title: 'GOAL — Get Out And Look',
        asset: 'assets/academy/driving/m04b_goal.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'GOAL',
            text: '"Get Out And Look" — stop, get out, look behind the '
                'vehicle, and only then reverse. That reveals exactly '
                'the things you never see from the seat.',
          ),
          ParagraphBlock(
            'The walk-around takes ten to fifteen seconds. In that time '
            'you see low bollards, kerbs, slopes, loose drain covers, '
            'children playing and the height of the gateway. A '
            'reversing camera shows you none of that reliably.',
          ),
          FactsBlock([
            FactItem('15 s', 'is how long a GOAL walk-around takes'),
            FactItem('90 cm', 'the height below which a child stays '
                'invisible behind the vehicle'),
          ]),
          ParagraphBlock(
            'And one more thing: what you saw when you got out stays in '
            'your head. Afterwards you are not reversing into the '
            'unknown, you are reversing towards a picture you know.',
          ),
        ],
      ),
      SafetySlide(
        title: 'GOAL step by step',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/goal01_stopp.svg',
              title: '1 · Stop',
              caption: 'Before you select reverse gear, come to a '
                  'complete stop and secure the vehicle. Once you are '
                  'rolling you are no longer deciding — you are only '
                  'reacting.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal02_aussteigen.svg',
              title: '2 · Get out',
              caption: 'Get out instead of twisting round in your '
                  'seat. Use the step and the grab handles as you do — '
                  'the three-point rule applies here too.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal03_umschauen.svg',
              title: '3 · Look around',
              caption: 'Walk right around the vehicle: what is standing '
                  'low behind the rear, how high is the entrance, where '
                  'is the ground sloping, are there children or animals '
                  'nearby? Fix the distances and reference points in '
                  'your mind.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal04_zurueck.svg',
              title: '4 · Reverse slowly',
              caption: 'Only now start reversing — at walking pace, '
                  'looking over your shoulder and into both mirrors. If '
                  'in doubt, stop again and take another look.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Slow does not mean harmless',
        blocks: [
          StepsBlock([
            'Choose walking pace — never faster, not even in an empty '
                'yard',
            'Wind the window down so that you can hear: shouts, horns, '
                'children',
            'Look over your shoulder and into both mirrors, '
                'alternating',
            'Use the camera only as an addition, never as your only '
                'source',
            'At the slightest doubt stop, get out, look again',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'The camera fallacy',
            text: 'The reversing camera shows a section, distorts '
                'distances and goes blind in rain, snow and dirt. It '
                'sees nothing that walks into your path from beside the '
                'rear. It does not replace GOAL.',
          ),
          FactsBlock([
            FactItem('walking', 'maximum pace when manoeuvring'),
            FactItem('2 s', 'is all a child needs to walk into the area '
                'behind the vehicle'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Using a banksman properly',
        blocks: [
          ParagraphBlock(
            'A banksman only helps if the rules are clear beforehand. A '
            'colleague standing somewhere behind the vehicle waving is '
            'not safety — he is an extra risk.',
          ),
          BulletsBlock([
            'Agree the signals first: stop, slow, keep coming, how '
                'much room',
            'The banksman stands to the side, never directly behind '
                'the vehicle',
            'You must be able to see him in the mirror at all times — '
                'otherwise it means stop',
            'Only one person guides, not several at the same time',
            'The banksman wears a hi-vis vest, especially at dusk',
          ]),
          RevealBlock(
            prompt: 'You are reversing into a tight yard entrance and '
                'your colleague is guiding you. Suddenly you can no '
                'longer see him in the mirror. What do you do?',
            answer: 'Stop immediately — do not slow down, stop. No '
                'visual contact means no valid signal. He may have '
                'walked along behind the vehicle, slipped, or been '
                'stopped by a passer-by. Only carry on once you can see '
                'him again and he gives you a fresh signal.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Case study: the tight yard entrance',
        blocks: [
          RevealBlock(
            prompt: 'Case study: the last stop is in an inner '
                'courtyard. The entrance is narrow, a car is waiting '
                'behind you, it is raining and you are 40 minutes '
                'behind schedule. You can get in forwards — but only '
                'out in reverse, past a wall and three parked cars. '
                'What is the right decision?',
            answer: 'Do not drive in at all. Stop on the street, carry '
                'the last few metres on foot or use the sack truck. If '
                'you are already inside: hazard lights on, get out, '
                'look at the situation, ask the waiting driver to back '
                'up if necessary, and then manoeuvre out in several '
                'short moves with checks in between. The driver waiting '
                'behind you is no reason to rush — in the end the '
                'damage is down to you, not to him. No manoeuvre will '
                'make up the 40 minutes, but a dented panel costs you '
                'the rest of the day.',
          ),
          DoDontBlock(
            doTitle: 'Manoeuvring correctly',
            dos: [
              'In several short moves rather than one long one',
              'Stopping in between and reassessing the situation',
              'Hazard lights on when manoeuvring in traffic',
              'Better to stop further away and walk the last few '
                  'metres',
            ],
            dontTitle: 'Wrong',
            donts: [
              'Manoeuvring faster under pressure from people waiting',
              'Forcing it through "in one go" because anything else '
                  'looks embarrassing',
              'Trusting only the camera or the sensors',
              'Manoeuvring while pedestrians are crossing the area',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist: reversing & manoeuvring',
        blocks: [
          ChecklistBlock(
            title: 'Before every reversing manoeuvre',
            items: [
              'I first check whether I can avoid reversing altogether',
              'I come to a complete stop before selecting reverse '
                  'gear',
              'I get out and look behind the vehicle (GOAL)',
              'I only reverse at walking pace',
              'I look over my shoulder and into both mirrors, not just '
                  'at the camera',
              'I wind the window down so that I can hear',
              'I stop immediately if I can no longer see the banksman',
              'I report every manoeuvring incident, even a small dent',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M5
  SafetyChapterContent(
    id: 'm5',
    title: 'Weather, visibility & difficult conditions',
    summary: 'Adapt your driving to rain, wet roads, fog, snow, '
        'darkness and heat',
    asset: 'assets/academy/driving/m05_wetter.svg',
    slides: [
      SafetySlide(
        title: 'Wet roads change everything',
        blocks: [
          ParagraphBlock(
            'On a wet road surface grip drops considerably — the '
            'braking distance grows substantially, in many situations '
            'to almost double. The first rain after a long dry spell is '
            'particularly critical: oil and rubber on the road form a '
            'slippery film with the water.',
          ),
          FactsBlock([
            FactItem('up to ×2', 'is how long the braking distance '
                'becomes in the wet'),
            FactItem('3 s+', 'minimum gap instead of 2 seconds'),
            FactItem('−20 %', 'speed as a rough guide'),
          ]),
          BulletsBlock([
            'Brake earlier and more gently, not in the bend',
            'Make steering movements smooth, not jerky',
            'Watch out for road markings, drain covers and tram '
                'rails — that is where it is most slippery',
            'Avoid the wheel ruts, that is where the water stands',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Speed is a duty, not a choice',
            text: '§ 3 (1) StVO requires you to adapt your speed to the '
                'road, traffic, visibility and weather conditions. In '
                'an accident on a wet road the posted limit will not '
                'help you.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Aquaplaning: what really happens',
        asset: 'assets/academy/driving/m05b_aquaplaning.svg',
        blocks: [
          ParagraphBlock(
            'Aquaplaning means a film of water pushes itself between '
            'tyre and road. The tyre floats up. From that moment on '
            'steering and brakes have no effect at all — not less '
            'effect, none.',
          ),
          ParagraphBlock(
            'The tread grooves have exactly one job: to channel the '
            'water away in front of the tyre. At higher speeds a tyre '
            'has to displace several litres of water every second. The '
            'shallower the tread and the higher the speed, the sooner '
            'it can no longer manage.',
          ),
          FactsBlock([
            FactItem('1.6 mm', 'legal minimum — already too little for '
                'aquaplaning'),
            FactItem('3 mm', 'practical lower limit in wet weather'),
            FactItem('speed²', 'is how steeply the aquaplaning risk '
                'rises with speed'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'How you notice it early',
            text: 'The steering suddenly goes light, the driving noise '
                'changes, the engine revs rise for no reason. Those are '
                'the seconds in which you can still ease off the '
                'accelerator.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Aquaplaning: the right reaction',
        blocks: [
          DoDontBlock(
            doTitle: 'Correct in standing water',
            dos: [
              'Ease off the accelerator — just that, no sudden lift',
              'Hold the steering calm and straight',
              'Press the clutch or let the drive disengage',
              'Let the van roll on until the tyres grip again',
              'Only then steer or brake carefully',
            ],
            dontTitle: 'Wrong',
            donts: [
              'Braking hard — the wheels lock with no effect',
              'Jerking the wheel or steering back sharply',
              'Accelerating to "get through it"',
              'Changing lane while the tyres are floating',
            ],
          ),
          RevealBlock(
            prompt: 'Case study: after a thunderstorm there is standing '
                'water in the right-hand wheel rut on a main road. You '
                'are doing 80 km/h and a car is tailgating you. What do '
                'you do?',
            answer: 'Ease off clearly before you enter the water — not '
                'in it. Keep the steering straight and let the '
                'tailgater tailgate; a rear-end shunt can be repaired, '
                'flying into oncoming traffic cannot. Anyone who brakes '
                'or swerves in the middle of the water provokes exactly '
                'the loss of control they want to avoid. If possible: '
                'after the water keep right and let the tailgater '
                'past.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'A floating tyre does not steer',
            text: 'As long as the film of water carries the tyre, every '
                'steering movement is ineffective — it only takes '
                'effect all at once when the tyre grips again. That is '
                'exactly how a skid starts.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tread depth & winter tyres',
        blocks: [
          TableBlock(
            headers: ['Situation', 'Tread / tyres'],
            rows: [
              ['Legal minimum', '1.6 mm — all year round'],
              ['Summer, wet road', 'from 3 mm recommended'],
              ['Winter, snow & slush', 'from 4 mm recommended'],
              ['Ice, snow, slippery', 'winter tyres with Alpine '
                  'symbol'],
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Situational winter tyre requirement',
            text: 'Under § 2 (3a) StVO you may only drive with winter-'
                'capable tyres in black ice, packed snow, slush, ice or '
                'frost. Breaches cost a fine and a penalty point — more '
                'if you obstruct others.',
          ),
          BulletsBlock([
            'You recognise winter tyres by the Alpine symbol (mountain '
                'with a snowflake)',
            'Even winter-capable tyres do little with too little '
                'tread',
            'Mind the age of the tyre: rubber hardens and loses grip, '
                'even if the tread is still there',
            'Report thin tread before the first frost arrives — not '
                'the morning after',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Snow, ice & scraping the windows',
        asset: 'assets/academy/driving/m05c_winter.svg',
        blocks: [
          ParagraphBlock(
            'On slippery surfaces one word covers everything: gently. '
            'Pull away gently, brake gently, steer gently. Every jerky '
            'movement overloads what little grip there is. Bridges, '
            'wooded stretches and shaded spots freeze first — and thaw '
            'last.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'No "peephole"',
            text: 'All windows, mirrors, lights and the number plate '
                'must be clear (§ 23 (1) StVO). A scraped peephole is '
                'an offence — and in an accident a serious allegation '
                'of fault. Snow on the roof must come off too before '
                'you set off.',
          ),
          DoDontBlock(
            doTitle: 'Winter routine',
            dos: [
              'Scrape all windows and mirrors completely clear',
              'Clear snow off the roof, the lights and the number '
                  'plate',
              'Clean ice and slush off the steps and grab handles',
              'Top up the screen wash with antifreeze',
              'Set off considerably earlier instead of catching up on '
                  'the way',
            ],
            dontTitle: 'Winter mistakes',
            donts: [
              'Setting off while the windscreen is still defrosting',
              'Pouring hot water on the windscreen',
              'Braking and steering at the same time on slush',
              'Ignoring iced-up steps — this is where you fall',
            ],
          ),
          FactsBlock([
            FactItem('0 °C', 'from here on bridges and shaded spots go '
                'first'),
            FactItem('×2 to ×10', 'is how much longer the braking '
                'distance becomes on snow and ice'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Fog, dusk, darkness',
        blocks: [
          ParagraphBlock(
            'In poor visibility it is not only harder to see, it is '
            'also harder to be seen. Switch the lights on in good '
            'time — if in doubt half an hour earlier than necessary.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Rule of thumb in fog',
            text: 'Visibility in metres equals your maximum speed in '
                'km/h. If you can only see 50 metres, you drive at no '
                'more than 50 km/h — and with visibility below 50 '
                'metres 50 km/h is the upper limit anyway.',
          ),
          BulletsBlock([
            'Fog lights only when visibility is genuinely impaired, '
                'not as permanent lighting',
            'Rear fog light only below 50 metres visibility — it '
                'dazzles the driver behind badly',
            'Use the roadside marker posts for orientation',
            'At dusk watch especially for pedestrians in dark '
                'clothing',
            'Interior light off, windows clean inside — both cost you '
                'night vision otherwise',
          ]),
          FactsBlock([
            FactItem('50 m', 'spacing between two marker posts outside '
                'built-up areas'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Storms & crosswinds',
        blocks: [
          ParagraphBlock(
            'Your panel van is a large, tall surface — in a crosswind '
            'it behaves completely differently from a car. Particularly '
            'dangerous are the places where the wind hits suddenly: '
            'bridges, the ends of wooded stretches, gaps between '
            'buildings and being overtaken by a lorry.',
          ),
          BulletsBlock([
            'Reduce speed clearly, both hands on the wheel',
            'At known windy spots tighten your grip beforehand and '
                'expect a gust',
            'Expect a gust after overtaking a lorry',
            'In a storm do not park under trees or next to '
                'scaffolding',
            'Hold on to the doors in the wind — they get torn open and '
                'damaged',
          ]),
          RevealBlock(
            prompt: 'Case study: there is a storm warning and you are '
                'driving empty across a motorway bridge. Why is being '
                'empty of all things critical here?',
            answer: 'Because the vehicle lacks the weight that keeps it '
                'on the road. An empty panel van offers the same '
                'surface to the wind as a loaded one but weighs a good '
                'third less — a gust pushes it aside far more. The '
                'right thing to do: take the speed off before the '
                'bridge, both hands on the wheel, expect a gust at the '
                'end of the bridge and do not drive alongside a '
                'lorry.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Heat & long rounds',
        blocks: [
          ParagraphBlock(
            'In summer you work in a vehicle that heats up strongly in '
            'the sun, and you walk many kilometres while doing it. An '
            'overheated, dehydrated driver reacts measurably more '
            'slowly — the effect is comparable to that of fatigue.',
          ),
          FactsBlock([
            FactItem('2–3 l', 'of fluid per shift in hot weather'),
            FactItem('> 60 °C', 'interior temperature in a vehicle '
                'standing in the sun'),
          ]),
          BulletsBlock([
            'Drink regularly, before you feel thirsty',
            'Take breaks in the shade, not in the overheated cab',
            'Head covering and sun protection for long walking '
                'stretches',
            'Report circulation problems immediately and take a break',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Never leave anyone behind',
            text: 'Never leave an animal or a person in a hot vehicle — '
                'not even "just for five minutes" and not with the '
                'window ajar either. The interior becomes dangerously '
                'hot within minutes.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist: difficult conditions',
        blocks: [
          ChecklistBlock(
            title: 'In bad weather and poor visibility',
            items: [
              'I adapt speed and distance, not just to the sign',
              'In the wet I increase the gap to at least 3 seconds',
              'Aquaplaning: off the accelerator, straight, no braking',
              'I know my tread depth and report thin tyres early',
              'I scrape all windows clear, no peephole',
              'I clear snow off the roof, the lights and the number '
                  'plate',
              'I expect crosswinds on bridges and at the end of wooded '
                  'stretches',
              'I drink enough and take breaks in the shade',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M6
  SafetyChapterContent(
    id: 'm6',
    title: 'Distraction, fatigue & time pressure',
    summary: 'Recognise the main human causes of accidents and actively '
        'counteract them',
    asset: 'assets/academy/driving/m06_ablenkung.svg',
    slides: [
      SafetySlide(
        title: 'Phone at the wheel: FORBIDDEN',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Holding a phone while driving is forbidden',
            text: 'Not for calls, not for typing, not for checking '
                'something — and not for choosing music, podcasts or '
                'messages either.',
          ),
          ParagraphBlock(
            'Completely clear and without exception. This is not just '
            'our company rule, it is the law. And it applies to every '
            'electronic device used for communication, information or '
            'organisation — so it applies to the scanner too.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 23 (1a) StVO',
            text: 'Anyone driving a vehicle may only use an electronic '
                'device if it is neither picked up nor held to do so. '
                'Picking it up or holding it in your hand is already '
                'the offence — regardless of what you do with it.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The stretch you drive blind',
        asset: 'assets/academy/driving/m06b_handy.svg',
        blocks: [
          ParagraphBlock(
            'A glance at the display is not one second — on average it '
            'takes two to three seconds, and reading a message closer '
            'to five. During that time you are driving with your eyes '
            'shut. Work it out in metres for once.',
          ),
          FactsBlock([
            FactItem('14 m/s', 'is what you cover per second at '
                '50 km/h'),
            FactItem('28 m', 'blind for a 2-second glance at the '
                'phone'),
            FactItem('approx. 70 m', 'blind if you read a message'),
          ]),
          RevealBlock(
            prompt: 'Do the maths: you are driving at 30 km/h through a '
                'home zone and look at the scanner for 3 seconds. How '
                'far do you drive blind — and is that enough for an '
                'accident?',
            answer: 'At 30 km/h you cover a good 8 metres per second, '
                'so about 25 metres in 3 seconds. That is more than the '
                'entire stopping distance at that speed (18 metres). To '
                'put it another way: you drive blind through a stretch '
                'in which you could long since have stopped had you '
                'been looking. Anyone who thinks a glance is harmless '
                'at low speed is confusing slow with safe — in home '
                'zones in particular children run onto the road with no '
                'warning.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Music, sat nav, scanner — all beforehand',
        blocks: [
          ParagraphBlock(
            'Music and podcasts are fine — but not with the phone in '
            'your hand. Select and start everything while stationary '
            'before you set off: playlist, volume, sat nav destination, '
            'next stop. Once it is running, nothing on the device gets '
            'touched while driving.',
          ),
          DoDontBlock(
            doTitle: 'Allowed',
            dos: [
              'Set the playlist and volume beforehand while stationary',
              'Enter the sat nav destination before setting off',
              'Leave the phone in its holder and only look at it',
              'Speak hands-free via the hands-free system',
              'Stop briefly for everything else',
            ],
            dontTitle: 'Forbidden',
            donts: [
              'Changing song or podcast while driving',
              'Reading or typing a message while driving',
              'Picking up the phone at a red light',
              'Operating the scanner or stop list while rolling',
              'Taking the device out of the holder to see it better',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'No headphones',
            text: 'No headphones or earbuds while driving — not even in '
                'one ear. You have to hear traffic, horns, shouts and '
                'emergency vehicles. When manoeuvring, your hearing is '
                'often the only warning you get.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The only exception: stationary, engine off',
        blocks: [
          ParagraphBlock(
            'You only operate the phone, scanner and sat nav when '
            'safely stationary. The practical sequence at the stop: '
            'pull up, engine off, operate the device, then get out. And '
            'before setting off: get in, set the destination and the '
            'music, then start.',
          ),
          RevealBlock(
            prompt: 'When does "stationary" count in law — and what '
                'about the automatic stop-start system at a red light?',
            answer: 'In law, stationary only counts once the engine is '
                'switched off. The exception expressly does not apply '
                'if the engine is merely resting because of an '
                'automatic stop-start function. So at a red light you '
                'must not pick the device up — not even while the '
                'engine happens to be silent.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Exception only with the engine switched off',
            text: 'Operating the device is only permitted when the '
                'vehicle is stationary and the engine is switched off. '
                'An automatic stop-start shutdown is not enough for '
                'that.',
          ),
        ],
      ),
      SafetySlide(
        title: 'What it costs',
        blocks: [
          FactsBlock([
            FactItem('100 € + 1 point', 'phone in your hand while '
                'driving'),
            FactItem('150 € + 2 points', 'with endangerment, plus a '
                '1-month driving ban'),
            FactItem('200 € + 2 points', 'with damage to property, plus '
                'a 1-month driving ban'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Probationary period',
            text: 'During the probationary period of your licence, a '
                'follow-up seminar and an extension of the probationary '
                'period to 4 years are added.',
          ),
          ParagraphBlock(
            'For you as a professional driver a driving ban means one '
            'thing: no job for a month. And if the distraction turns '
            'into an accident with injuries, it does not stop at a '
            'fine — then the allegation of endangering road traffic is '
            'on the table (§ 315c StGB), and that is a criminal '
            'offence.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'The simplest insurance policy',
            text: 'Putting the phone away costs nothing and protects '
                'your licence, your job and, in an emergency, a life.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Distraction takes many forms',
        blocks: [
          ParagraphBlock(
            'Not just the phone: eating, drinking, searching for '
            'parcels, conversations, annoyance about the last customer, '
            'thinking about the next stop. Distraction is anything that '
            'takes your eyes, hands or mind off the road.',
          ),
          DoDontBlock(
            doTitle: 'Fine while driving',
            dos: [
              'Looking at the road',
              'Speaking hands-free via the hands-free system',
              'Short glances in the mirrors',
              'Stopping briefly for everything else',
            ],
            dontTitle: 'Not fine',
            donts: [
              'Unwrapping food or a drink',
              'Searching the load space for the next parcel',
              'Operating the scanner or stop list on the move',
              'Re-sorting the route in your head while driving '
                  'instead of stopping briefly',
            ],
          ),
          RevealBlock(
            prompt: 'Case study: as you set off you notice you have '
                'picked up the wrong consignment. The right stop is 300 '
                'metres further on. What do you do?',
            answer: 'Drive to the next safe place to stop, pull up, '
                'engine off, then swap it in the load space. Reaching '
                'behind you while driving is the classic situation in '
                'which drivers leave their lane — you turn your head '
                'and upper body away at the same time. A 300-metre '
                'detour takes 30 seconds, a scrape costs you the rest '
                'of the day.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Fatigue: your body does not negotiate',
        asset: 'assets/academy/driving/m06c_muedigkeit.svg',
        blocks: [
          ParagraphBlock(
            'Fatigue is not a question of willpower. Beyond a certain '
            'point your brain switches off briefly — whether you want '
            'it to or not. The treacherous part: it is in exactly that '
            'phase that you overestimate your own alertness the most.',
          ),
          SubheadBlock('The warning signs you must take seriously'),
          BulletsBlock([
            'Frequent yawning, burning or heavy eyes',
            'You cannot remember the last few kilometres',
            'You miss turnings or stops',
            'The seat position suddenly feels wrong and you keep '
                'shifting about',
            'You wander within your lane or correct constantly',
            'Feeling cold and a stiff neck with no outside cause',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'High-risk times',
            text: 'The most dangerous times are the early hours of the '
                'morning, the dip after lunch and the last hour of the '
                'round. Plan your breaks exactly there.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Microsleep in metres',
        blocks: [
          ParagraphBlock(
            'A microsleep typically lasts two to five seconds. That '
            'sounds short — until you work it out in metres.',
          ),
          FactsBlock([
            FactItem('56 m', 'at 50 km/h during 4 seconds of '
                'microsleep'),
            FactItem('89 m', 'at 80 km/h in 4 seconds'),
            FactItem('111 m', 'at 100 km/h in 4 seconds'),
          ]),
          RevealBlock(
            prompt: 'Do the maths: you are doing 80 km/h on a country '
                'road and nod off for 4 seconds. How far do you travel '
                'out of control — and what lies along that stretch?',
            answer: '80 km/h is around 22 metres per second, so about '
                '89 metres in 4 seconds. On a country road that stretch '
                'typically contains a bend, a line of trees and the '
                'oncoming traffic. And unlike a glance at the phone, '
                'you are not steering during that time — the vehicle '
                'drifts out of its lane. That is why only one thing '
                'helps against microsleep: stopping beforehand.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'There is no small version of this',
            text: 'Anyone who has nodded off once will nod off again — '
                'usually within a few minutes. The drive ends here, not '
                'at the next stop.',
          ),
        ],
      ),
      SafetySlide(
        title: 'What helps — and what does not',
        blocks: [
          DoDontBlock(
            doTitle: 'Really works',
            dos: [
              'Stopping and closing your eyes for 15–20 minutes',
              'Getting out, walking, fresh air and movement',
              'Eating and drinking something',
              'Reporting the round and asking for support if that is '
                  'not enough',
            ],
            dontTitle: 'Does not work (or only for minutes)',
            donts: [
              'Window open and loud music',
              'Coffee as a substitute for sleep',
              'Keeping yourself awake with conversation',
              'Driving faster to finish earlier',
            ],
          ),
          ParagraphBlock(
            'A short sleep of 15 to 20 minutes followed by some '
            'movement is the only measure that genuinely achieves '
            'anything in the short term. Everything else just pushes '
            'the problem a few kilometres further down the road.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Unfit to drive',
            text: 'Anyone who carries on despite obvious exhaustion is '
                'driving while unfit. If that endangers someone, it is '
                'no longer a fine but a criminal offence '
                '(§ 315c StGB).',
          ),
        ],
      ),
      SafetySlide(
        title: 'Managing time pressure cleverly & checklist',
        blocks: [
          ParagraphBlock(
            'Time pressure is real — but speeding and rushing save '
            'hardly any time and cost a great deal of risk. In town '
            'traffic the time gained by driving faster is a matter of '
            'minutes; a single manoeuvring incident costs you an hour.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'When the plan does not work out',
            text: 'That is not a safety problem, it is a planning '
                'issue — report it early instead of making up for it at '
                'the wheel. A report at 1 pm helps, one at 6 pm no '
                'longer does.',
          ),
          ChecklistBlock(
            title: 'What I take away from module 6',
            items: [
              'My phone stays untouched while I am driving',
              'I set music, sat nav and scanner before setting off',
              'I know that "stationary" only counts with the engine '
                  'switched off',
              'I do not wear headphones',
              'I know my personal signs of fatigue',
              'When I am tired I stop instead of pushing through',
              'I report an unrealistic plan early and honestly',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M7
  SafetyChapterContent(
    id: 'm7',
    title: 'Workplace accidents: getting in/out, lifting & falls',
    summary: 'Avoid injuries away from driving — with a focus on safe '
        'getting in and out',
    asset: 'assets/academy/driving/m07_ein_aussteigen.svg',
    slides: [
      SafetySlide(
        title: 'Why this is the most important move of the day',
        blocks: [
          ParagraphBlock(
            'You get in and out dozens of times per round — it is the '
            'movement you make most often. That is exactly why most '
            'injuries happen here: twisted ankles, slipping off the '
            'step edge, falling out of the van, a misstep into '
            'traffic.',
          ),
          FactsBlock([
            FactItem('100,000', 'slip, trip and fall accidents among '
                'professional drivers per year'),
            FactItem('24', 'days off work on average per fall'),
            FactItem('No. 1', 'most common type of injury in delivery '
                'work'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'BG Verkehr warns',
            text: 'BG Verkehr (the German transport employers\' '
                'liability insurance body) expressly warns that falls '
                'when getting in and out lead to serious and sometimes '
                'fatal injuries.',
          ),
          ParagraphBlock(
            'The difference between a safe and a dangerous way of '
            'getting out is two seconds. Multiplied by 250 exits a day '
            'that is a good eight minutes — the cheapest insurance '
            'policy your body will ever get.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The 3-point rule (2+1)',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Two hands and one foot — always',
            text: 'The central rule from BG Verkehr: two hands and one '
                'foot are always in contact with the vehicle — "2+1".',
          ),
          ParagraphBlock(
            'So you always have three firm points of contact before you '
            'release the next one. That way a single slip can never '
            'become a fall, because two points are still holding you. '
            'Only ever move one point, never two at the same time.',
          ),
          RevealBlock(
            prompt: 'Which three points of contact are meant — and what '
                'expressly does not count?',
            answer: 'Left hand on the grab handle, right hand on the '
                'grab handle, one foot on the step. What does not '
                'count: the steering wheel, the door edge, the seat, '
                'the tyre and the wheel hub. The door edge and the '
                'steering wheel give way or turn away — at exactly the '
                'moment you need them.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Remember',
            text: 'Climb down first, then pick things up. Put items '
                'down in the vehicle first, then get out with your '
                'hands free.',
          ),
        ],
      ),
      SafetySlide(
        title: 'In properly, out properly',
        blocks: [
          BulletsBlock([
            'Getting in: facing forwards towards the vehicle',
            'Getting out: backwards, facing the vehicle — like on a '
                'ladder, never twisting out with your back to the '
                'door',
            'Use all the steps — do not skip any',
            'Use the grab handles, not the door edge or the steering '
                'wheel as an emergency hold',
            'The same rule applies when getting out of the load '
                'space: face the vehicle, step by step',
          ]),
          StepsBlock([
            'Stop and secure the vehicle',
            'Put items down in the vehicle',
            'Check traffic over your shoulder and in the mirror',
            'Open the door in a controlled way',
            'Turn round, face the vehicle',
            'Establish three points of contact',
            'Climb down step by step',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Never jump',
        asset: 'assets/academy/driving/m07b_springen.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Jumping is the most common mistake',
            text: 'Jumping down from the cab or the load space is the '
                'most common cause of twisted ankles as well as knee '
                'and back injuries in delivery work.',
          ),
          ParagraphBlock(
            'Depending on the model, the load floor of a van sits about '
            '55 to 75 centimetres above the road. When you jump down, '
            'several times your body weight acts on your ankle, knee '
            'and spine on landing — and that happens with every single '
            'jump.',
          ),
          FactsBlock([
            FactItem('55–75 cm', 'height of the load floor above the '
                'road'),
            FactItem('250+', 'exits per round — every single one adds '
                'up on your joints'),
          ]),
          RevealBlock(
            prompt: 'Case study: it is raining and you jump out of the '
                'load space onto a sloping pavement covered in wet '
                'leaves. What exactly goes wrong here?',
            answer: 'Once you have jumped you can no longer correct '
                'your landing — you are in the air, and what happens '
                'below you is decided by the surface. Wet leaves on a '
                'slope offer almost no friction: your foot slides away '
                'as you land and the joint twists sideways. Anyone who '
                'instead climbs down step by step with three points of '
                'contact feels the slippery surface before putting '
                'their full weight on it — and can still stop.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The typical mistakes',
        blocks: [
          DoDontBlock(
            doTitle: 'Right',
            dos: [
              'Put items down in the vehicle first',
              'Climb down with free hands and three points of contact',
              'Keep step edges and handles clean and clear',
              'Clean the steps beforehand in wet and icy conditions',
              'Take your time — even at the 180th stop',
            ],
            dontTitle: 'Wrong',
            donts: [
              'Jumping instead of climbing down',
              'Hands full — phone, scanner, coffee, parcels',
              'Using the tyre or the wheel hub as a step',
              'Looking at your phone while climbing down',
              'Ignoring wet, icy or dirty step edges',
              'Twisting sideways out of the seat',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'The stop after a long drive is the most dangerous',
            text: 'After a long spell at the wheel your legs are stiff '
                'and your concentration is gone. That is exactly when '
                'the misstep happens — gather yourself briefly, then '
                'get out.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The traffic side: the underestimated moment',
        blocks: [
          ParagraphBlock(
            'On low Sprinters and vans the problem is often not the '
            'height but the step into moving traffic. Where possible '
            'get out on the pavement side or the safe side. Do not '
            'fling the door wide open before you have looked.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 14 (1) StVO — getting in and out',
            text: 'Anyone getting in or out must behave in such a way '
                'that any danger to other road users is ruled out. In a '
                'car-door accident the responsibility practically '
                'always lies with the person getting out.',
          ),
          RevealBlock(
            prompt: 'You stop at the kerb and a cyclist is approaching '
                'from behind — how do you get out?',
            answer: 'Before opening the door look over your shoulder '
                'and in the mirror, let the cyclist pass, and open the '
                'door only in a controlled way and with your far hand. '
                'The so-called "Dutch reach" — opening the door with '
                'your right hand — automatically turns your upper body '
                'to the rear and forces you to look. Cyclists and '
                'scooters pass close to the van and do not expect a '
                'door to open.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Footwear & ground surface',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'BG Verkehr recommendation',
            text: 'Footwear that encloses the foot and is slip '
                'resistant. No open or worn-out shoes. Ankle-high '
                'safety boots support exactly the joint that twists '
                'when you climb down.',
          ),
          ParagraphBlock(
            'Before getting out, take a quick look at the ground: kerb, '
            'slope, leaves, wet, ice, loose chippings. Keep handles and '
            'steps clear in snow and ice. Where possible stop somewhere '
            'level and lit.',
          ),
          ChecklistBlock(
            title: 'Before getting out',
            items: [
              'Sturdy, slip-resistant footwear on',
              'Ground checked — kerb, slope, wet, ice',
              'Hands free, items put down',
              'Traffic checked over the shoulder and in the mirror',
              'Steps clean and clear',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Lifting and carrying correctly',
        blocks: [
          ParagraphBlock(
            'The back is the second biggest risk of time off work after '
            'falls. And unlike a fall, a slipped disc does not happen '
            'in a single day — it builds up through thousands of '
            'incorrect lifts.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/lift01_nah.svg',
              title: '1 · Load close to your body',
              caption: 'Step right up to the parcel before you lift '
                  'it. Every centimetre of distance from your body '
                  'multiplies the load on your discs.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift02_hocke.svg',
              title: '2 · Squat down',
              caption: 'Bend your knees and squat down instead of '
                  'folding forwards from the hips. The power comes from '
                  'your legs — they are the strongest muscles you '
                  'have.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift03_ruecken.svg',
              title: '3 · Keep your back straight',
              caption: 'Keep your back straight and your eyes forward '
                  'while you straighten up with your legs. A rounded '
                  'back under load is the classic slipped-disc '
                  'position.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift04_drehen.svg',
              title: '4 · Do not twist — step round',
              caption: 'Never twist your upper body while holding the '
                  'load. Instead move your feet and turn your whole '
                  'body. Lifting plus twisting is the most dangerous '
                  'combination for the spine.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'How heavy is too heavy?',
        blocks: [
          ParagraphBlock(
            'There are no fixed weight limits in law — what matters is '
            'the combination of weight, posture, frequency and '
            'surroundings. In practice, though, some guide values have '
            'proved useful.',
          ),
          FactsBlock([
            FactItem('approx. 25 kg', 'guide value for occasional '
                'lifting (men)'),
            FactItem('approx. 15 kg', 'guide value for occasional '
                'lifting (women)'),
            FactItem('above that', 'use an aid or carry it between '
                'two'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'LasthandhabV (manual handling regulation)',
            text: 'The employer must avoid manual lifting and carrying '
                'as far as possible and provide suitable aids. You then '
                'have to use those aids as well — they are not there '
                'for decoration.',
          ),
          DoDontBlock(
            doTitle: 'Carrying correctly',
            dos: [
              'Use the sack truck or roll cage instead of walking '
                  'twice',
              'Carry bulky consignments between two people',
              'Keep your field of view clear — do not peer over the '
                  'stack',
              'Decide on the route and where to set it down before '
                  'lifting',
            ],
            dontTitle: 'Carrying wrongly',
            donts: [
              'Rounded back, arms stretched out',
              'Twisting your upper body while holding the load',
              'Swinging into it and lifting with a jerk',
              'Carrying towers that block your view of the path',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Tripping, slipping and falling on the way',
        blocks: [
          ParagraphBlock(
            'Tripping, slipping and falling is the most common cause of '
            'injury in delivery work — more common than any road '
            'accident. And it almost always happens on the last few '
            'metres between the vehicle and the front door.',
          ),
          FactsBlock([
            FactItem('No. 1', 'most common type of accident in delivery '
                'work'),
            FactItem('last 30 m', 'between vehicle and door — the most '
                'dangerous stretch'),
          ]),
          BulletsBlock([
            'Wear sturdy, slip-resistant footwear — every day, in '
                'summer too',
            'On slippery ground take small steps and put the whole '
                'foot down',
            'Look at the path now and then, not only at the parcel or '
                'your phone',
            'At night use a torch or your phone light for the path',
            'Keep known trip hazards on the route in mind',
          ]),
          RevealBlock(
            prompt: 'Case study: you are carrying two parcels stacked '
                'on top of each other to a front door with three steps. '
                'What is the real problem here?',
            answer: 'You cannot see your own feet or the edges of the '
                'steps. A flight of steps you cannot see is the classic '
                'fall situation — and with your hands full you can '
                'neither hold the handrail nor break your fall. The '
                'right way: carry them one at a time, keep the stack '
                'low enough to see the steps, or use the sack truck. '
                'Walking twice takes 40 seconds.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Take small injuries seriously',
        blocks: [
          ParagraphBlock(
            'A strained back or a twisted ankle gets worse if you carry '
            'on. Over weeks a trivial matter turns into real time off '
            'work — and in hindsight the connection with your job often '
            'can no longer be proven.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Documenting protects you',
            text: 'Every injury belongs in the first-aid record book — '
                'even a small one. If you need medical treatment after '
                'a workplace accident you go to a Durchgangsarzt (an '
                'accident insurance consultant). Without documentation '
                'it is hard to have it recognised later as a workplace '
                'accident.',
          ),
          RevealBlock(
            prompt: 'Why should you report minor complaints '
                'immediately — even if you can carry on working?',
            answer: 'First, medically: an untreated ligament problem '
                'heals worse and comes back. Second, legally: only what '
                'is documented counts later as a workplace accident. '
                'Third, for everyone: only reported incidents show '
                'where a step, a handle or a procedure in the company '
                'needs improving. Reporting is strength, not weakness.',
          ),
          ChecklistBlock(
            title: 'What I take away from module 7',
            items: [
              'I climb out backwards, facing the vehicle',
              'I always keep three points of contact (2 hands + '
                  '1 foot)',
              'I never jump out of the cab or the load space',
              'I put items down before getting out',
              'I look over my shoulder before opening the door',
              'I lift with my legs and do not twist while holding a '
                  'load',
              'I use the aids instead of playing the hero',
              'I report every injury, even a small one',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M8
  SafetyChapterContent(
    id: 'm8',
    title: 'At the front door: dogs, people & surroundings',
    summary: 'Act safely at the delivery point — with animals, people '
        'and the surroundings',
    asset: 'assets/academy/driving/m08_haustuer.svg',
    slides: [
      SafetySlide(
        title: 'The delivery point: someone else\'s ground',
        blocks: [
          ParagraphBlock(
            'As soon as you leave the vehicle you step onto ground you '
            'do not know and that nobody has made safe for you: unknown '
            'paths, loose slabs, dark stairwells, animals and people in '
            'every kind of mood.',
          ),
          FactsBlock([
            FactItem('120+', 'other people\'s properties per round'),
            FactItem('30 m', 'walking distance on average per stop'),
            FactItem('0', 'of them are prepared for you'),
          ]),
          ParagraphBlock(
            'That is why the same basic attitude applies at the '
            'delivery point as at the wheel: look first, then act. And '
            'if in doubt: do not deliver. A consignment that does not '
            'arrive is a piece of paperwork — an injury is time off '
            'work.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Judging dogs correctly',
        asset: 'assets/academy/driving/m08b_hund.svg',
        blocks: [
          ParagraphBlock(
            'Dogs are among the most common causes of injury to '
            'delivery drivers. From the dog\'s point of view you are an '
            'intruder who moves quickly, smells strange and is carrying '
            'a large object — the reaction is defence, not malice.',
          ),
          BulletsBlock([
            'Do not stare straight into its eyes — to a dog that is a '
                'threat',
            'Do not run away and do not raise your voice, stand still '
                'and stay calm',
            'Turn your side towards the dog, not your front',
            'Arms calm at your sides, no hectic movements',
            'The parcel can go as a barrier between you and the dog',
            'Walk backwards slowly, keeping the dog in sight',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Calm is your best equipment',
            text: 'A dog reacts to movement and tone of voice, not to '
                'arguments. Slow, quiet and side-on — that is the whole '
                'technique.',
          ),
        ],
      ),
      SafetySlide(
        title: 'When it gets serious',
        blocks: [
          RevealBlock(
            prompt: 'Case study: a large dog is standing at the garden '
                'gate barking. The gate is only pushed to, and the '
                'customer has written "the dog is friendly" in the '
                'delivery notes. What do you do?',
            answer: 'You do not enter the property. A delivery note is '
                'not a safety clearance — the customer knows their dog '
                'around the family, not around a strange man with a '
                'parcel. The right thing: step back from the gate, try '
                'to ring the bell or phone, record the consignment as '
                'not delivered and leave a note in the system so that '
                'the next colleague is warned. A bite costs you weeks — '
                'the consignment costs the customer a day.',
          ),
          DoDontBlock(
            doTitle: 'Right',
            dos: [
              'Before opening the gate, listen for dogs and look for '
                  'bowls',
              'With a loose dog, do not enter at all',
              'Leave notes for colleagues in the system',
              'After a bite or scratch: report it immediately and get '
                  'medical treatment',
            ],
            dontTitle: 'Wrong',
            donts: [
              'Stroking or feeding the dog',
              'Walking past the animal to the door',
              'Running away or hitting the dog with the parcel',
              'Relying on "he won\'t hurt you"',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Every dog bite goes to a doctor',
            text: 'Even a small bite or scratch can become infected. '
                'Clean it immediately, get medical treatment, enter it '
                'in the first-aid record book and report it — no matter '
                'how harmless it looks.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Safe routes on the property',
        asset: 'assets/academy/driving/m08c_stolperfallen.svg',
        blocks: [
          ParagraphBlock(
            'The path to the front door is not a workplace that anyone '
            'has inspected for you. Use the marked paths and do not cut '
            'across wet lawns, loose slabs or steep banks.',
          ),
          BulletsBlock([
            'Garden hoses, cables and trellises on the ground',
            'Loose or sunken paving slabs',
            'Wet leaves, moss and algae on shaded paths',
            'Gravel and loose chippings on smooth slabs',
            'Unlit steps with no handrail',
            'Cellar shafts, open drains and light wells',
            'Toys, bicycles and wheelie bins in the way',
          ]),
          FactsBlock([
            FactItem('last 30 m', 'this is where most falls happen'),
            FactItem('1 hand', 'should stay free for the handrail'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Cutting corners costs more than it saves',
            text: 'The route across the lawn saves ten seconds. A fall '
                'on it costs 24 days off work on average.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Stairs, cellars & darkness',
        blocks: [
          ParagraphBlock(
            'In stairwells and rear courtyards two things come '
            'together: poor light and unfamiliar step heights. Together '
            'they make up the most common fall situation away from the '
            'vehicle.',
          ),
          BulletsBlock([
            'Always keep one hand free for the handrail',
            'Switch the light on instead of "it will be fine"',
            'Use a torch or your phone light — but do not look at the '
                'display while walking',
            'On stairs keep the stack low enough to see the steps',
            'Watch out for uneven step heights in older buildings',
          ]),
          RevealBlock(
            prompt: 'You are supposed to deliver into a dark cellar '
                'corridor. The light switch does not work. What is the '
                'right decision?',
            answer: 'Do not go in. An unlit corridor with unknown '
                'steps, cellar shafts and stored junk is not a place '
                'you enter with a parcel in your hand — and if '
                'something happens nobody knows you are there. The '
                'right thing: ring the customer\'s bell, hand it over '
                'somewhere safe, or record the consignment as not '
                'delivered. A phone light does not replace proper '
                'lighting, because it needs the hand you need for the '
                'handrail.',
          ),
        ],
      ),
      SafetySlide(
        title: 'People: de-escalate instead of winning',
        blocks: [
          ParagraphBlock(
            'To the customer you are the face of an entire corporation '
            '— and that is why you sometimes get the anger that is not '
            'meant for you. Staying friendly, calm and professional is '
            'not just polite, it is your most effective safety '
            'measure.',
          ),
          StepsBlock([
            'Calm voice, slow speaking pace, open body language',
            'Listen and name the concern instead of contradicting '
                'straight away',
            'Stick to what you can do — no promises on behalf of '
                'others',
            'Keep your distance: at least an arm\'s length, escape '
                'route clear',
            'If it escalates: end the conversation and go back to the '
                'vehicle',
          ]),
          RevealBlock(
            prompt: 'Someone becomes loud, comes very close to you and '
                'blocks the way to your vehicle. What applies?',
            answer: 'Your safety comes before any delivery. Do not '
                'argue, do not try to be right, do not provoke physical '
                'contact. Back off, create distance, demand space '
                'loudly and clearly, and in an emergency move into a '
                'public place and call the police. Afterwards: report '
                'the incident so that the stop is flagged for '
                'colleagues. No parcel justifies a physical '
                'confrontation.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The van as a safe place',
        blocks: [
          ParagraphBlock(
            'Your vehicle is a tool, a store and a refuge. When you '
            'leave it, it must be standing safely — and if you feel '
            'threatened, it is the place you go back to.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 14 (2) StVO',
            text: 'Anyone leaving their vehicle must take the necessary '
                'measures to avoid accidents and traffic disruption, '
                'and secure it against unauthorised use.',
          ),
          DoDontBlock(
            doTitle: 'Parked correctly',
            dos: [
              'Engine off, take the key, lock up',
              'On a slope apply the handbrake firmly and turn the '
                  'wheels into the kerb',
              'Hazard lights when stopping in traffic',
              'Close the load space door when you are out of sight',
            ],
            dontTitle: 'Risky',
            donts: [
              'Engine running, door open — "it is quicker that way"',
              'Key left in while you are at the door',
              'Parking on a hill without turning the wheels',
              'Leaving the load space open in busy areas',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist at the delivery point',
        blocks: [
          ChecklistBlock(
            title: 'At every stop',
            items: [
              'Engine off, key with me, vehicle locked',
              'Secured on a slope, wheels turned in',
              'Checked for dogs and notes before entering',
              'Used the marked paths, did not cut corners',
              'One hand free for the handrail',
              'Stack low enough for me to see the steps',
              'Made sure there is light in the dark',
              'If someone turns aggressive: distance, retreat, report',
              'After a bite, fall or near miss: reported',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M9
  SafetyChapterContent(
    id: 'm9',
    title: 'Emergencies & what to do after an accident',
    summary: 'Act calmly, correctly and lawfully when it matters',
    asset: 'assets/academy/driving/m09_notfall.svg',
    slides: [
      SafetySlide(
        title: 'Make safe — call — help',
        blocks: [
          ParagraphBlock(
            'After an accident or a breakdown the order is always the '
            'same: first make the scene safe, then call the emergency '
            'services, then give first aid. This order is not red '
            'tape — it prevents the second accident, the one in which '
            'the helpers become casualties themselves.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Remember the order',
            text: 'Make safe → call → help. Anyone who runs straight to '
                'the casualty without making the scene safe gets run '
                'over themselves on a country road or motorway.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 34 StVO — after a road accident',
            text: 'You must stop immediately, make the traffic safe, '
                'move out of the danger area if the damage is minor, '
                'help the injured and enable your identity and your '
                'vehicle to be established.',
          ),
          ParagraphBlock(
            'And most importantly: stay calm. The first ten seconds '
            'after a bang decide the next ten minutes. Take one deep '
            'breath, then work through it in order.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The first five steps',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/acc01_absichern.svg',
              title: '1 · Hazard lights on',
              caption: 'Switch the hazard lights on immediately after '
                  'stopping — they are the first signal for everyone '
                  'coming up behind. In the dark leave the sidelights '
                  'on as well.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc02_warnweste.svg',
              title: '2 · Put on the hi-vis vest',
              caption: 'You put the vest on before you get out — not '
                  'afterwards. That is why it is kept within reach in '
                  'the cab and not in the back of the load space.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc03_dreieck.svg',
              title: '3 · Set up the warning triangle',
              caption: 'Walk behind the crash barrier or along the edge '
                  'of the road against the direction of travel and set '
                  'the triangle up at a sufficient distance — about '
                  '50 m in built-up areas, 100 m outside them, '
                  '150–200 m on the motorway.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc04_notruf.svg',
              title: '4 · Call 112',
              caption: 'Say where you are, what has happened, how many '
                  'casualties there are and what injuries you can see — '
                  'and only hang up once the control room has no more '
                  'questions.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc05_erstehilfe.svg',
              title: '5 · Give first aid',
              caption: 'Speak to them, check their breathing, stop '
                  'bleeding, keep them warm and stay with the casualty. '
                  'Even simple measures help — doing nothing is the '
                  'only wrong decision.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Hazard lights, vest, triangle',
        blocks: [
          TableBlock(
            headers: ['Area', 'Triangle distance'],
            rows: [
              ['Built-up area', 'approx. 50 m'],
              ['Outside built-up areas', 'approx. 100 m'],
              ['Motorway', 'approx. 150–200 m'],
              ['Before a crest or bend', 'before it, not after it'],
            ],
          ),
          ParagraphBlock(
            'What matters is not the exact number of metres but that '
            'the traffic behind sees you in good time. Before a crest '
            'or a bend the triangle belongs in front of it — otherwise '
            'it only becomes visible when it is too late.',
          ),
          FactsBlock([
            FactItem('1', 'hi-vis vest is compulsory in the vehicle '
                '(§ 53a StVZO)'),
            FactItem('first', 'put the vest on before you get out'),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Walk behind the crash barrier',
            text: 'On the motorway and on country roads you never walk '
                'on the carriageway to set up the triangle, but behind '
                'the crash barrier or on the verge — against the '
                'direction of travel so that you can see the traffic.',
          ),
          DoDontBlock(
            doTitle: 'Right at the scene',
            dos: [
              'Hazard lights immediately, vest before getting out',
              'Walk behind the crash barrier against the direction of '
                  'travel',
              'Set the triangle up before a crest or bend',
              'Move yourself to safety once the scene is secured',
            ],
            dontTitle: 'Typical mistakes',
            donts: [
              'Getting out without a vest "just to take a quick look"',
              'Walking on the carriageway to place the triangle',
              'Standing between the vehicles',
              'Taking photos first instead of making the scene safe',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Emergency corridor',
        blocks: [
          ParagraphBlock(
            'The emergency corridor is formed as soon as traffic slows '
            'to a crawl — not only once you can see blue lights. By '
            'then it is usually too late, because nobody has any room '
            'left.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 11 (2) StVO',
            text: 'On motorways and roads outside built-up areas with '
                'at least two lanes per direction, the corridor is '
                'always formed between the far left lane and the lane '
                'immediately to its right — no matter how many lanes '
                'there are.',
          ),
          FactsBlock([
            FactItem('left + 1', 'that is how the corridor is formed'),
            FactItem('from 200 €', 'fine for failing to form a '
                'corridor'),
            FactItem('2 points', 'plus usually a 1-month driving ban'),
          ]),
          RevealBlock(
            prompt: 'Traffic is at a standstill on a three-lane '
                'motorway. Where exactly is the emergency corridor — '
                'and may you drive in it if you are heading for the '
                'exit anyway?',
            answer: 'Always between the left-hand lane and the middle '
                'lane — never between the middle and the right, and '
                'never on the hard shoulder. And no: the emergency '
                'corridor is exclusively for emergency vehicles. Anyone '
                'who uses it to reach the exit faster pays a fine as '
                'high as someone who fails to form one at all, and '
                'risks a driving ban. The hard shoulder is no '
                'alternative — emergency services drive there when the '
                'corridor is blocked.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Making the 112 call properly',
        blocks: [
          FactsBlock([
            FactItem('112', 'emergency number across Europe, even with '
                'no credit'),
            FactItem('110', 'police — for damage to property only'),
          ]),
          StepsBlock([
            'Where did it happen? — place, road, marker post, '
                'direction of travel, landmarks',
            'What happened? — type of accident, vehicles involved, '
                'hazards such as leaking fuel',
            'How many casualties?',
            'What injuries? — unconscious, bleeding, trapped',
            'Wait for further questions — the control room ends the '
                'call',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Giving help is a duty',
            text: 'Failure to give assistance is a criminal offence '
                '(§ 323c StGB). What is expected is what is reasonable '
                'for you — make the emergency call, secure the scene, '
                'talk to people, look after them. Nobody expects you to '
                'put yourself in danger.',
          ),
        ],
      ),
      SafetySlide(
        title: 'First aid: the things that count',
        blocks: [
          ParagraphBlock(
            'You do not have to be a paramedic. Anyone can do the '
            'crucial things — and they are what decides between life '
            'and death before the ambulance arrives.',
          ),
          StepsBlock([
            'Speak to them and shake their shoulder gently — does the '
                'person respond?',
            'No response: clear the airway, tilt the head back, check '
                'breathing for 10 seconds',
            'Breathing normally: recovery position, cover them up, '
                'stay with them',
            'No normal breathing: start chest compressions '
                'immediately and do not stop',
            'Heavy bleeding: apply direct pressure, put on a pressure '
                'dressing',
          ]),
          FactsBlock([
            FactItem('100–120', 'chest compressions per minute'),
            FactItem('5–6 cm', 'compression depth in an adult'),
            FactItem('10 s', 'is enough to check the breathing'),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Helmets and trapped casualties',
            text: 'You only take a motorcycle helmet off if the person '
                'is not breathing normally — then there is no way '
                'around it. You do not move trapped casualties unless '
                'there is an immediate danger from fire.',
          ),
        ],
      ),
      SafetySlide(
        title: 'After minor bodywork damage',
        blocks: [
          ParagraphBlock(
            'Even with minor damage — a dent from manoeuvring, a '
            'knocked-off mirror, a scratch on a parked car — the full '
            'procedure applies. The damage is always reported, even if '
            'it looks small and nobody was watching.',
          ),
          ChecklistBlock(
            title: 'After minor bodywork damage',
            items: [
              'Stop and secure the vehicle',
              'Hazard lights, vest and triangle if needed',
              'Exchange details or wait for the keeper',
              'Photos from several angles, place, time, registration',
              'Note down witnesses and their contact details',
              'Do not sign any admission of liability',
              'Report the damage to the company — the same day',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Never simply drive on',
            text: 'Anyone who leaves the scene of an accident without '
                'enabling their identity to be established commits the '
                'offence of leaving the scene of an accident '
                '(§ 142 StGB) — a criminal offence carrying a fine or '
                'imprisonment, even for a small dent.',
          ),
          RevealBlock(
            prompt: 'Case study: while manoeuvring you clip the wing '
                'mirror of a parked car. Nobody is around. Is a note '
                'under the windscreen wiper enough?',
            answer: 'No. In law a note does not count as sufficient '
                'establishment of identity — it can blow away, get wet '
                'or be removed. The right thing: wait at the scene for '
                'a reasonable time (depending on the situation around '
                '30 minutes is used as a guide), and if nobody comes, '
                'inform the police and report the damage to them. A '
                'note as well is good practice, but it replaces neither '
                'the waiting nor the report.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Stay calm, report, learn',
        blocks: [
          ParagraphBlock(
            'Take a breath, sort out the situation, inform the '
            'dispatcher and the company. An honest, quick report is '
            'always better than covering things up — it protects you, '
            'it protects the company, and we learn from every incident '
            'for the next round.',
          ),
          ChecklistBlock(
            title: 'What I take away from module 9',
            items: [
              'I know the order: make safe, call, help',
              'I put the hi-vis vest on before I get out',
              'I set the warning triangle up at a sufficient distance',
              'I form the emergency corridor between the left lane '
                  'and the one next to it as soon as traffic slows',
              'I know the five pieces of information for a 112 call',
              'I know that doing nothing is the only wrong decision',
              'I report every incident the same day — even a small '
                  'dent',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M10
  SafetyChapterContent(
    id: 'm10',
    title: 'Summary & personal commitment',
    summary: 'Anchor what you have learnt and turn it into a personal '
        'attitude',
    asset: 'assets/academy/driving/m10_selbstverpflichtung.svg',
    slides: [
      SafetySlide(
        title: 'Your 7 core rules',
        blocks: [
          BulletsBlock([
            'Thinking ahead beats reacting quickly',
            'Distance and an appropriate speed always give you a '
                'reserve',
            'When reversing: get out, look, go slowly (GOAL)',
            'Phone and other distractions only while stationary with '
                'the engine switched off',
            'Take fatigue and time pressure seriously — safety before '
                'the plan',
            'Get out, lift and walk properly — your body is your tool',
            'In an emergency: make safe, call, help',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'If you take away just one rule',
            text: 'Take the time you need. Almost every accident in '
                'delivery work happens at the moment somebody tried to '
                'save two seconds.',
          ),
          DoDontBlock(
            doTitle: 'What a safe day looks like',
            dos: [
              'Walk-around done, load secured, seat belt on',
              'Two seconds of distance, eyes far ahead',
              'Get out and look before every reversing manoeuvre',
              'Phone in its holder, break when tired',
              'Climb out backwards with three points of contact',
            ],
            dontTitle: 'The five most expensive shortcuts',
            donts: [
              'Skipping the walk-around "just for today"',
              'Not re-securing the load after a reload',
              'A quick look at the display because the road is clear',
              'Jumping out of the load space because it is quicker',
              'Not reporting damage caused while manoeuvring',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'The numbers that should stick',
        blocks: [
          FactsBlock([
            FactItem('2 s', 'minimum gap'),
            FactItem('2 + 1', 'points of contact when getting out'),
            FactItem('112', 'emergency number when someone is hurt'),
          ]),
          TableBlock(
            headers: ['Number', 'Meaning'],
            rows: [
              ['2 seconds', 'minimum gap, 3+ in the wet'],
              ['18 / 40 m', 'stopping distance at 30 / 50 km/h'],
              ['28 m', 'driven blind for a 2 s phone glance at '
                  '50 km/h'],
              ['89 m', 'a 4 s microsleep at 80 km/h'],
              ['0.8 g', 'forward securing force for the load'],
              ['2 + 1', 'points of contact when getting in and out'],
              ['70 %', 'of damage happens while manoeuvring'],
              ['112', 'emergency number when someone is hurt'],
            ],
          ),
          ParagraphBlock(
            'These eight numbers are the hard core of the training. If '
            'you have them in your head, you will make the right '
            'decision even when there is no time to think.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Your personal self-check',
        asset: 'assets/academy/driving/m10b_selbstcheck.svg',
        blocks: [
          ParagraphBlock(
            'Go through this list honestly once — not for the company, '
            'but for yourself. Every box you cannot tick is a concrete '
            'thing you can change tomorrow.',
          ),
          ChecklistBlock(
            title: 'My safety self-check',
            items: [
              'I do the walk-around every morning, even when I am in '
                  'a hurry',
              'I re-secure the load as the load space empties',
              'I keep a two-second gap and check it against a fixed '
                  'point',
              'I get out and look before every reversing manoeuvre',
              'I do not touch my phone while driving',
              'I stop when I get tired',
              'I always climb out backwards with three points of '
                  'contact',
              'I lift with my legs and use the aids',
              'I report damage, near misses and injuries',
              'I speak up when a plan cannot be done safely',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Case study: the day when everything comes at once',
        blocks: [
          RevealBlock(
            prompt: 'Case study: Friday, rain, 190 stops. You start 25 '
                'minutes late, the load space was left unsorted by the '
                'night shift, your phone rings constantly, and at 4 pm '
                'you realise you have not eaten since breakfast. What '
                'is the right order of priorities now?',
            answer: 'Stop and sort the load space first — you make that '
                'back within a quarter of an hour and save yourself 190 '
                'searches. Then: phone on silent, into the holder, '
                'calls at the next break. Then ten minutes to eat and '
                'drink, because from now on your attention will '
                'otherwise drop every hour. And then an honest report '
                'to dispatch that the plan will not fully work out '
                'today. What you do not do: try to make the time up on '
                'the road, cut out breaks, take shortcuts when '
                'manoeuvring. The day cannot be saved any more — your '
                'back, your licence and your vehicle can.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'The real test',
            text: 'Anyone can drive safely on a good day. The '
                'difference shows on the day when everything goes wrong '
                'at once.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Your personal commitment',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Your promise',
            text: '"I drive so that everyone gets home safely — myself '
                'included."',
          ),
          ParagraphBlock(
            'Safety is not a rule book, it is your daily decision. '
            'Nobody is standing next to you at six in the morning when '
            'you decide whether to do the walk-around, or at seven in '
            'the evening when you decide whether to get out once more '
            'before reversing. That is exactly what makes those '
            'decisions so important.',
          ),
          ChecklistBlock(
            title: 'I commit myself to',
            items: [
              'I follow the rules even when nobody is watching',
              'I take the seconds that safety costs',
              'I report honestly instead of covering things up',
              'I help new colleagues to do it right from the start',
              'I get home safe and sound every evening',
            ],
          ),
        ],
      ),
    ],
  ),
];
