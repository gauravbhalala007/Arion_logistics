// lib/data/safety_training/ride_along_content_en.dart
//
// Content of the Ride Along training — English version.
// The structure is identical to the German master: chapters ra1–ra5,
// the same slides, the same blocks and the same values.
//
// The "Ride Along" is the two-day accompanied drive for new drivers:
// day 1 with a smaller number of stops, day 2 with considerably more.
// The trainer works through a checklist, signs off every point and gives
// feedback at the end; the sheet is handed in as a photo to the
// responsible dispatcher.
//
// Purpose of this training: PREPARATION. Anyone who works through it
// beforehand does not hear the topics of the two days for the first
// time, but can ask targeted questions and use the accompanied drive
// deliberately.
//
// Multi-client capable: NO personal names, no station names, no
// company-specific figures presented as a rule. Stop counts, waiting
// area times, start of work and parking side are expressly requirements
// of the individual station — the trainer states them. Company tools
// such as time tracking appear only as an example ("e.g. Kenjo").
// These may stay concrete: the Amazon tools (Flex, Mentor, ATLAS,
// Scorecard), the CoDriver app, the break rules under § 4 ArbZG and the
// Green Book under § 1 Abs. 6 FPersV — all three apply across
// companies. There are no illustrations for this topic, hence
// `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> rideAlongContentEn = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ra1',
    title: 'What the Ride Along is',
    summary: 'Two days of accompanied driving: aim, sequence, who is '
        'involved and how you are assessed',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Two days alongside an experienced driver',
        blocks: [
          ParagraphBlock(
            'The Ride Along is your accompanied drive at the start: two '
            'working days on which an experienced driver goes out with '
            'you as your trainer. You do not get to know the route from '
            'a presentation, but exactly where it happens — in the '
            'station, in the Loading Area and out on the road.',
          ),
          FactsBlock([
            FactItem('2 days', 'accompanied drive with a trainer'),
            FactItem('day 1', 'smaller number of stops — around 20 in '
                'many companies'),
            FactItem('day 2', 'considerably more stops — around 70 in '
                'many companies'),
          ]),
          ParagraphBlock(
            'The two days build on each other. On the first day the '
            'focus is on the procedures: how you get into the station, '
            'which apps you start and when, how loading works, when the '
            'break is due. On the second day the volume rises sharply '
            'and you drive and deliver yourself — the trainer '
            'accompanies you but does not take over.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'The stop counts are guide values',
            text: 'How many stops are actually planned for day 1 and '
                'day 2 is set by your company or your station. Around '
                '20 on the first day and around 70 on the second are '
                'common — but the only binding figure is the one your '
                'trainer or your responsible dispatcher gives you.',
          ),
          BulletsBlock([
            'Both days run on your own account, not on the trainer\'s',
            'The stops count as real work, not as a dry run',
            'The trainer explains, demonstrates and then lets you do it '
                'yourself',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'In short',
            text: 'The Ride Along is your induction in live operation. '
                'By the end you should be able to drive a route on your '
                'own — that is the yardstick everything is measured by.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Who is involved and who does what',
        blocks: [
          ParagraphBlock(
            'Three roles are involved in the Ride Along. If you know who '
            'is responsible for what, you will not ask the wrong person '
            'and you will not lose time.',
          ),
          TableBlock(
            headers: ['Role', 'Task'],
            rows: [
              [
                'You',
                'Drive, deliver, ask questions, join in — both days on '
                    'your own account',
              ],
              [
                'Trainer',
                'Experienced driver: explains every point, demonstrates '
                    'it, watches you, ticks off the checklist and signs '
                    'it',
              ],
              [
                'Dispatcher',
                'Schedules the two days, is your contact if there are '
                    'problems and receives the photo of the checklist at '
                    'the end',
              ],
            ],
          ),
          ParagraphBlock(
            'The trainer is not your line manager and not your examiner '
            'in any official sense. He is the colleague who knows the '
            'station best. That is exactly why he is the right person '
            'for every question that occurs to you during the two days — '
            'including the ones that feel trivial.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Questions cost nothing',
            text: 'A question during the Ride Along is cheap. The same '
                'question in week three, alone on the route, with a full '
                'day ahead of you, is expensive.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The checklist and the feedback',
        blocks: [
          ParagraphBlock(
            'The trainer works through a fixed sheet — the Ride Along '
            'checklist. For each of the two days it lists what must have '
            'been explained and demonstrated: from the vehicle '
            'inspection through the break rules to the password '
            'parcels. Every point is signed off, every day is closed '
            'with a date and a signature.',
          ),
          BulletsBlock([
            'The checklist is the proof that you were properly inducted',
            'It protects you too: whatever is ticked was explained to you',
            'After the second day the trainer gives feedback on your '
                'performance and driving skills',
          ]),
          ParagraphBlock(
            'It is not a pass-or-fail exam. Nobody expects you to drive '
            'the route on the first day like a driver with three years '
            'of experience. But you are assessed: the trainer records '
            'how you work, and the sheet goes to the company. Anyone who '
            'visibly thinks along, is punctual and takes advice on board '
            'gets good feedback — even if they are slow.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'The difference that matters',
            text: 'What is assessed is not whether you can already do '
                'everything, but whether you are willing to learn and '
                'take the rules seriously. Mistakes are normal. Having a '
                'mistake explained twice and still ignoring it is not.',
          ),
          RevealBlock(
            prompt: 'Case study: on the first day you twice mix up the '
                'order of the parcels on the roll cage and take much '
                'longer for your stops than planned. You are convinced '
                'the Ride Along is a write-off. Is that true?',
            answer: 'No. That is exactly what the first day is for. The '
                'trainer only expects a hint of speed on the second day '
                'and the real thing in the weeks after. What he assesses '
                'on the first day is something else: do you ask when you '
                'are unsure? Are you still making the same mistake the '
                'third time round? Do you then sort more carefully of '
                'your own accord? Anyone who raises the mistake and '
                'deliberately does it differently at the next roll cage '
                'leaves a better impression than someone who is fast and '
                'questions nothing.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist: chapter 1',
        blocks: [
          ChecklistBlock(
            title: 'What I take away from chapter 1',
            items: [
              'The Ride Along is two working days with a trainer',
              'Day 1 fewer stops, day 2 considerably more — the exact '
                  'figure is set by my company (commonly around 20 and '
                  'around 70)',
              'Both days run on my own account',
              'The trainer explains, demonstrates and lets me do it '
                  'myself',
              'He ticks off a checklist and signs for each day',
              'After day 2 there is feedback on performance and driving '
                  'skills',
              'It is induction, but it is assessed — willingness to '
                  'learn counts more than speed',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'One sentence for the two days',
            text: '"I would rather ask one question too many than one '
                'too few — that is what these two days are for."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ra2',
    title: 'The first day',
    summary: 'First stops, app start-up, inspection, Loading Area, '
        'breaks and vehicle keys',
    asset: '',
    slides: [
      SafetySlide(
        title: 'The first stops on your own account',
        blocks: [
          ParagraphBlock(
            'The first day has a minimum number of stops that you should '
            'have driven and delivered — on your own account. It is '
            'deliberately kept small (around 20 in many companies); the '
            'binding figure for your station is given to you by your '
            'trainer. Day 1 is not about volume, but about getting every '
            'single move right once.',
          ),
          ParagraphBlock(
            'Your own account matters. Not the trainer\'s, not a shared '
            'login. Everything you deliver on this day runs under your '
            'name — exactly as it will count later on. That is the only '
            'way the trainer and the company can see what your delivery '
            'work really looks like.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'No access, no Ride Along',
            text: 'If your account does not work in the morning, say so '
                'immediately — before setting off, not at the first '
                'stop. Unresolved access costs you the whole day.',
          ),
          SubheadBlock('The CoDriver app'),
          ParagraphBlock(
            'CoDriver is the company\'s app — the app you are reading in '
            'right now. It is separate from the Amazon tools: Amazon '
            'controls the route, CoDriver everything around your work '
            'inside the company. The trainer goes through it with you on '
            'the first day.',
          ),
          BulletsBlock([
            'Shift plan and wave plan: when you work and which wave you '
                'start in',
            'Reporting absences and sickness',
            'DA Academy: training courses like this one, plus the '
                'operating instructions',
            'Messages and notifications from the company',
            'Accident and damage reports',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Remember',
            text: 'Amazon apps control the route. CoDriver controls your '
                'employment. You need both every day, and both should be '
                'looked at once in full on day 1.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Arriving: working hours, parking side, Waiting Area',
        blocks: [
          ParagraphBlock(
            'The day does not begin with the first stop, but with '
            'arriving at the station. There are three things the trainer '
            'will impress on you on the first day, because they repeat '
            'on every single working day.',
          ),
          SubheadBlock('1 — Working hours'),
          ParagraphBlock(
            'Your shift has a fixed start. It is in the shift plan in '
            'CoDriver, and "start" means: at that time you are ready to '
            'work at the station — not on your way there. The specific '
            'times for your station are given to you by the trainer; '
            'they differ by site and by wave.',
          ),
          SubheadBlock('2 — Parking side'),
          ParagraphBlock(
            'Every station has a rule about where private vehicles may '
            'stand and on which side the vans are lined up. That is not '
            'red tape: many vehicles manoeuvre on the yard at the same '
            'time, often in reverse and with poor visibility. Park in '
            'the wrong place and you block a lane or sit in the blind '
            'spot of someone reversing. The trainer shows you the side '
            'that applies to you.',
          ),
          SubheadBlock('3 — Waiting Area times'),
          ParagraphBlock(
            'The Waiting Area is where you wait until your roll cage or '
            'your loading position is called. There are fixed time slots '
            'for this per wave. Turn up too early and you clog the area; '
            'turn up too late and you miss your call and push the whole '
            'wave back. The exact times for your station are given to '
            'you by the trainer on the first day — write them down.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'The three figures you should note down',
            text: 'Shift start, parking side and your Waiting Area slot. '
                'You need these three every morning from the next day '
                'onwards — and then nobody has to tell you again.',
          ),
          RevealBlock(
            prompt: 'Case study: you are at the gate on time for the '
                'start of your shift, but then need ten minutes to find '
                'a parking space because you looked on the wrong side. '
                'That makes you late for the Waiting Area. How bad is '
                'that?',
            answer: 'Worse than it looks. Calls in the Waiting Area run '
                'to a clock: if you miss your slot, you drop behind the '
                'other drivers in your wave. Your roll cage waits, your '
                'vehicle may be blocking a position in the meantime, and '
                'your start shifts by more than the ten minutes you '
                'lost. That is why the parking side and the Waiting Area '
                'time belong together: "on time at the gate" is not the '
                'same as "on time in the Waiting Area". Factor in the '
                'time for parking and walking.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The start: time tracking, Mentor and Flex',
        blocks: [
          ParagraphBlock(
            'Three systems have to be running at the beginning of the '
            'shift — in good time and in this order. Each has a '
            'different purpose, and each causes trouble if it is started '
            'too late.',
          ),
          StepsBlock([
            'Your company\'s time tracking (e.g. Kenjo) — clock in at '
                'the start of the shift. Whatever you do not start here '
                'is not paid working time and will be missing from your '
                'pay later. Which system your company uses is shown to '
                'you by the trainer.',
            'Mentor — the driving behaviour app from Amazon: it must be '
                'running before you set off. It records how you drive '
                'and supplies the data for your score.',
            'Flex — the delivery app from Amazon: this is where you get '
                'your route, scan the parcels and document every '
                'delivery.',
          ]),
          SubheadBlock('Mentor\'s 4 hours'),
          ParagraphBlock(
            'Mentor does not run indefinitely: the app records around '
            'four hours at a time. After that you have to restart it, '
            'otherwise the rest of your route goes unrecorded. That is '
            'the most common beginner\'s mistake — the app was started '
            'correctly in the morning but not reactivated after the '
            'lunch break. The trainer shows you on the first day how to '
            'tell that Mentor is still running.',
          ),
          FactsBlock([
            FactItem('4 h', 'recording time of Mentor in one go'),
            FactItem('before setting off', 'start Mentor — not once you '
                'are already out'),
            FactItem('after the break', 'check Mentor and restart it'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Most common mistake on the first day',
            text: 'Flex is running, Mentor is not. You still drive your '
                'route, but your driving behaviour is not recorded — and '
                'missing Mentor time is just as noticeable in the '
                'company as a poor score.',
          ),
          RevealBlock(
            prompt: 'Case study: at 2 p.m. you notice that Mentor has '
                'not been running since the break. What do you do — '
                'carry on until the end of the shift and do better '
                'tomorrow, or react straight away?',
            answer: 'React straight away: stop at the next safe place, '
                'restart Mentor, carry on. The obvious mistake is to '
                'think that half a day without recording does not '
                'matter because you drove properly anyway. It does '
                'matter: to the company a gap looks like a gap — not '
                'like good driving. And carrying on means making the gap '
                'bigger with every hour. Report it to your trainer or '
                'your responsible dispatcher as well, so the gap can be '
                'explained.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Vehicle inspection and Loading Area',
        blocks: [
          SubheadBlock('The vehicle inspection'),
          ParagraphBlock(
            'Before you set off the vehicle is checked — and again after '
            'the route. The inspection is a visual check with '
            'documentation: you walk once around the van, look at every '
            'side, test the functions and record what you see.',
          ),
          BulletsBlock([
            'Walk-round outside: bodywork, bumpers, mirrors, windows — '
                'every dent and every scratch',
            'Tyres: tread, visible damage, impression of the pressure',
            'Lights: dipped beam, brake lights, indicators, reversing '
                'lights',
            'Cab and load area: cleanliness, loose parts, bulkhead',
            'Equipment: warning triangle, hi-vis vest, first-aid kit',
            'Odometer reading and fuel or charge level',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Why the inspection BEFORE the drive counts',
            text: 'Damage you document beforehand is pre-existing '
                'damage. The same damage you do not document is your '
                'damage by the evening. Those two minutes of walking '
                'round are the cheapest insurance of your working day.',
          ),
          SubheadBlock('Loading the roll cage in the Loading Area'),
          ParagraphBlock(
            'In the Loading Area your roll cage is waiting with the '
            'parcels for your route. How you move it into the van '
            'decides your whole day: load it unsorted and you will be '
            'searching at every stop — and over a full route that adds '
            'up to hours.',
          ),
          BulletsBlock([
            'Load in route order: whatever goes out first goes in last '
                'and lies at the front',
            'Heavy parcels at the bottom, light ones on top — not the '
                'other way round',
            'Secure the load: nothing may slide forward under braking',
            'Do not stack anything in the walkway or in front of the '
                'sliding door',
            'Keep special parcels (password, ATLAS, oversized) separate '
                'and within easy reach',
            'Put the empty roll cage back where it belongs — not just '
                'anywhere',
          ]),
          DoDontBlock(
            doTitle: 'This is how you do it right',
            dos: [
              'While loading, think ahead about which stop is the first',
              'Bend your knees when lifting, keep the load close to your '
                  'body',
              'Ask if you do not know where a parcel belongs',
            ],
            dontTitle: 'This costs you time later',
            donts: [
              'Throwing everything in and "sorting it on the way"',
              'Putting parcels on the bulkhead or in the driver\'s area',
              'Leaving the roll cage standing in the middle of the lane',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Breaks, keys and automatic locking',
        blocks: [
          SubheadBlock('Breaks: 30 and 45 minutes'),
          ParagraphBlock(
            'There are two break lengths, and which one applies to you '
            'depends solely on your working time that day. Unlike '
            'Waiting Area times or stop counts, this is not a rule set '
            'by your station but law: § 4 Arbeitszeitgesetz (ArbZG — the '
            'German Working Hours Act). The rule therefore applies in '
            'the same way in every company and is not negotiable.',
          ),
          FactsBlock([
            FactItem('30 min', 'for more than 6 and up to 9 hours of '
                'working time'),
            FactItem('45 min', 'for more than 9 hours of working time'),
            FactItem('15 min', 'smallest part-break that counts'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 4 ArbZG — the legal basis',
            text: 'The German Working Hours Act requires at least 30 '
                'minutes of rest break for more than 6 hours of working '
                'time and at least 45 minutes for more than 9 hours. '
                'Working longer than 6 hours without a break is '
                'expressly prohibited.',
          ),
          ParagraphBlock(
            'The break may be split, but each part must last at least 15 '
            'minutes — so two times 15 minutes make up the 30-minute '
            'break and three times 15 minutes the 45-minute one. Five '
            'minutes here and there do not count. It is also important '
            'that the break must have started before six hours of work '
            'have elapsed, not only at the end of the shift.',
          ),
          ParagraphBlock(
            'Why it has to be recorded: your break is not paid working '
            'time, and the company must be able to prove that you '
            'actually took it. That is why it is entered in the time '
            'tracking — not out of mistrust, but because an undocumented '
            'break counts as a break not taken if it is ever inspected. '
            'That is a breach the company is liable for. The trainer '
            'shows you exactly where you enter it.',
          ),
          SubheadBlock('Automatic locking and the key'),
          ParagraphBlock(
            'Many Sprinters lock automatically: if the door falls shut '
            'or the vehicle starts moving, the central locking engages '
            'by itself. That is theft protection for your load — and it '
            'is exactly why the key stays on your person at all times.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'The key belongs on your body',
            text: 'Not on the seat, not in the tray, not in the jacket '
                'pocket of a jacket lying in the vehicle. Key in your '
                'trouser pocket or on the lanyard on your belt — every '
                'single time you get out.',
          ),
          RevealBlock(
            prompt: 'Case study: you stop briefly, leave the key in the '
                'ignition, pick up two parcels and close the sliding '
                'door with your foot. The central locking engages. What '
                'happens now?',
            answer: 'You are standing with two parcels in front of a '
                'locked van containing your key, your phone, the rest of '
                'the load and usually your paperwork as well. That is '
                'your day gone: you need help from the station or a '
                'locksmith, your entire route is at a standstill, and '
                'the parcels in the vehicle will not reach their '
                'customers today. The obvious mistake is "but I am only '
                'away for ten seconds" — automatic locking does not '
                'distinguish between ten seconds and ten minutes. So the '
                'rule applies without exception: key out, key on your '
                'body, and only then get out.',
          ),
        ],
      ),
      SafetySlide(
        title: 'End of route: closing Flex and the inspection',
        blocks: [
          ParagraphBlock(
            'The day does not end at the last stop, but at the station. '
            'Two things are on the trainer\'s checklist there — and both '
            'are easily forgotten because you are tired and want to go '
            'home.',
          ),
          StepsBlock([
            'Close the Flex app properly: finish the route, hand in '
                'returns and exit the app — do not simply pocket the '
                'phone.',
            'Vehicle inspection after the drive: the same walk-round as '
                'in the morning, now looking for new damage, the '
                'odometer reading and the fuel or charge level.',
            'Hand the vehicle over clean and empty, check the load area '
                '— no parcel stays inside.',
            'Clock out in your company\'s time tracking (e.g. Kenjo) and '
                'hand in the key where it belongs.',
          ]),
          ParagraphBlock(
            'The closing inspection is the counterpart to the inspection '
            'in the morning. Only the two together make it clear what '
            'happened to the vehicle on that day — and what did not. If '
            'the evening one is missing, damage found the next morning '
            'can no longer be attributed to anyone, and the next driver '
            'inherits your problem or you inherit theirs.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'A rule of thumb for finishing up',
            text: 'Flex closed, walk round the vehicle, load area empty, '
                'clocked out, key handed in. Only then are you done for '
                'the day.',
          ),
          ChecklistBlock(
            title: 'What I take away from day 1',
            items: [
              'The number of stops set by my company, on my own account',
              'I know the CoDriver app and what I find in it',
              'I know my shift start, my station\'s parking rule and my '
                  'Waiting Area slot',
              'I start the time tracking (e.g. Kenjo), Mentor and Flex '
                  'in good time and in that order',
              'I know that Mentor records around 4 hours and has to be '
                  'restarted afterwards',
              'I do the vehicle inspection before and after the route',
              'I load the roll cage in route order, heavy at the bottom, '
                  'load secured',
              'I know the break rule under § 4 ArbZG: 30 minutes from '
                  'more than 6 hours, 45 minutes from more than 9 hours '
                  '— and I record it',
              'The key always stays on my body, because the Sprinter '
                  'locks automatically',
              'At the end I close Flex, do the inspection and clock out',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ra3',
    title: 'The second day',
    summary: 'Considerably more stops on your own, Scorecard, vehicle '
        'care, Green Book, special parcels, refuelling and charging',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Considerably more stops — you drive, you deliver',
        blocks: [
          ParagraphBlock(
            'On the second day the balance shifts. The number of stops '
            'rises sharply — to around 70 in many companies, but the '
            'binding figure is the one set by your station — and you '
            'carry out the stops on your own: you drive, you navigate, '
            'you scan, you deliver, you document. The trainer sits '
            'beside you and only steps in when it is necessary.',
          ),
          FactsBlock([
            FactItem('more', 'stops than on day 1 — the figure is set by '
                'the company'),
            FactItem('yourself', 'driving and delivering — the trainer '
                'only accompanies'),
            FactItem('1 day', 'until your first route on your own'),
          ]),
          ParagraphBlock(
            'That is the real point of the second day: you should have '
            'experienced once what a full route feels like — with the '
            'pace, the sorting in between, the customers who do not '
            'answer, and the feeling that the clock is running. Once you '
            'have done that with somebody next to you, going out alone '
            'for the first time is only half as daunting.',
          ),
          BulletsBlock([
            'Do not let anyone take over what you can do yourself — even '
                'if it is slower',
            'Ask about every stop that felt odd, straight away',
            'Note what you need to write down: codes, procedures, '
                'contacts',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'The yardstick of day 2',
            text: 'Not "can he do the route in record time", but "could '
                'you send him out alone tomorrow". That is exactly what '
                'the trainer is judging.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Scorecard, quality and performance',
        blocks: [
          ParagraphBlock(
            'Your work is measured. The Amazon Scorecard sums up week by '
            'week how you and your company have performed. On the second '
            'day the trainer explains which figures it contains and how '
            'you influence them — because almost every figure comes out '
            'of something you have in your own hands.',
          ),
          BulletsBlock([
            'Delivery quality: was the parcel handed over or left in the '
                'right place and documented cleanly?',
            'Driving behaviour from Mentor: braking, accelerating, '
                'cornering, phone use, seatbelt',
            'Reliability: punctual start, route driven in full, correct '
                'hand-back',
            'Customer feedback: complaints and praise also end up in the '
                'evaluation',
          ]),
          ParagraphBlock(
            'Quality and performance are two different things that are '
            'often confused. Performance is the volume: how many stops '
            'in how much time. Quality is how cleanly each individual '
            'stop was completed. A driver with high performance and poor '
            'quality creates more work than he saves — every complaint '
            'costs the company many times over the minute that was saved '
            'up front.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'The most expensive mistake is the quick one',
            text: 'Leaving a parcel in the wrong place and driving off '
                'quickly saves you a minute and costs the company a '
                'complaint, an investigation and, if it comes to it, the '
                'value of the goods.',
          ),
          RevealBlock(
            prompt: 'Case study: the customer does not answer and you '
                'still have 30 stops ahead of you. You put the parcel '
                'behind the wheelie bin and quickly take a photo of the '
                'front door. Why is that a problem?',
            answer: 'On two counts. First, the place you left it does '
                'not match what you documented — if the customer does '
                'not find the parcel, your delivery stands there '
                'unproven. Second, behind a wheelie bin is not a '
                'suitable place: it is visible from the street and it '
                'gets emptied. The right thing is to follow the '
                'procedure laid down — neighbour, safe place with the '
                'customer\'s consent, or return — and to document '
                'exactly what you actually did. The one minute saved '
                'stands against a complaint that costs you, the customer '
                'and the company considerably more each.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Vehicle care, accidents, cleaning and upkeep',
        blocks: [
          ParagraphBlock(
            'The van is your workplace and the most expensive tool the '
            'company entrusts to you. How you treat it is a point of its '
            'own on the checklist on the second day — in three parts.',
          ),
          SubheadBlock('1 — Avoiding damage'),
          BulletsBlock([
            'Reverse only when there is no other way — and then slowly, '
                'checking both mirrors',
            'If the situation is unclear, get out and look instead of '
                'guessing',
            'Narrow entrances, low branches, underground car parks and '
                'bollards are the most common sources of damage',
            'Keep your distance and brake with foresight — that spares '
                'the vehicle and the Scorecard at the same time',
          ]),
          SubheadBlock('2 — If something does happen'),
          StepsBlock([
            'Stop, make the scene safe: hazard lights, hi-vis vest, '
                'warning triangle.',
            'Look after anyone injured; always call 112 if people are '
                'hurt.',
            'Change nothing, take photos: the overall scene, the damage, '
                'registration plates, surroundings.',
            'If another vehicle is involved or fault is unclear, call '
                'the police — even for minor damage.',
            'Inform your responsible dispatcher immediately and report '
                'the incident in CoDriver.',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Never drive on',
            text: 'Even a small scratch on someone else\'s vehicle is a '
                'hit-and-run if it is not reported — a criminal offence. '
                'A note under the windscreen wiper is not legally '
                'sufficient.',
          ),
          SubheadBlock('3 — Cleaning and upkeep'),
          BulletsBlock([
            'Clear out the cab every day: no rubbish, no bottles, no '
                'paperwork',
            'Sweep out the load area and check for forgotten parcels',
            'Keep windows and mirrors clean — poor visibility is a '
                'safety problem, not a cosmetic flaw',
            'Report fluid levels and unusual noises, do not ignore them',
          ]),
          RevealBlock(
            prompt: 'Case study: while manoeuvring you clip a bollard. '
                'There is a scratch on the vehicle, nothing else, and '
                'nobody saw it. Do you report it?',
            answer: 'Yes, always and on the same day. It is not about '
                'blame but about attribution: a reported scratch is an '
                'incident that gets processed. The same scratch, found '
                'the next morning by another driver during his '
                'inspection, is unexplained damage — and that becomes '
                'unpleasant for everyone involved, including you, '
                'because suspicion ends up falling on the last user '
                'anyway. The obvious mistake is "nobody will notice". It '
                'will be noticed at the next inspection; that is what it '
                'is there for.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Green Book / driving record book',
        blocks: [
          ParagraphBlock(
            'The Green Book is your driving record book: the daily '
            'control sheets under § 1 Abs. 6 Fahrpersonalverordnung '
            '(FPersV — the German driving personnel regulation), with '
            'which you prove your driving times, breaks from driving and '
            'rest periods. This too is not a rule of your station but '
            'applicable driving personnel law — it applies in the same '
            'way in every company. It is expressly not a vehicle check: '
            'the Green Book is solely about times, your times.',
          ),
          BulletsBlock([
            'One sheet per working day, filled in by hand and signed',
            'Recorded are the start and end of the drive, odometer '
                'readings, driving times, breaks and rest periods',
            'Fill it in straight away, do not reconstruct it from memory '
                'in the evening',
            'The records of the last few days are carried with you and '
                'must be produced during a roadside check',
          ]),
          ParagraphBlock(
            'On the second day the trainer shows you where the sheet is '
            'kept, how it is filled in and where the completed sheets '
            'are handed in. Everything beyond that is not covered here: '
            'the DA Academy has its own "Green Book" training for it — '
            'with the mandatory entries, the driving and rest periods, '
            'the duty to carry the records and the consequences of '
            'breaches. Work through it instead of trying to memorise the '
            'details in the vehicle on the second day.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'The record itself is the obligation',
            text: 'Whether you kept to the times cannot be established '
                'during a check if nothing is there. A missing sheet is '
                'therefore just as much a breach as an exceeded driving '
                'time.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Special cases: password parcels and ATLAS parcels',
        blocks: [
          SubheadBlock('Password parcels'),
          ParagraphBlock(
            'Some consignments may only be handed over against a '
            'password or a code that the customer received beforehand. '
            'Typical cases are high-value goods and anything that is '
            'particularly at risk of theft. Flex flags this to you at '
            'the stop.',
          ),
          BulletsBlock([
            'The customer says or shows you the code — you do not read '
                'it out and you do not say it first',
            'No correct code, no hand-over: no exception, not even to a '
                'neighbour',
            'No leaving it at the door and no dropping it in the hallway',
            'If the code is wrong, the consignment is returned along the '
                'prescribed route and documented',
          ]),
          SubheadBlock('ATLAS parcels'),
          ParagraphBlock(
            'ATLAS consignments are likewise parcels that get special '
            'treatment: they follow their own process with additional '
            'steps in the scanning and hand-over sequence. What matters '
            'for you is that you recognise them, store them separately '
            'and within easy reach, and do not cut short the prescribed '
            'sequence. What the process looks like in your station and '
            'which steps Flex takes you through is shown to you by the '
            'trainer on the second day with a real parcel.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Sort special parcels in first',
            text: 'You do not want to be hunting for either type of '
                'parcel at the stop among 90 other consignments. Put '
                'them aside deliberately while loading and remember '
                'where they are.',
          ),
          RevealBlock(
            prompt: 'Case study: the customer is there but does not have '
                'the password to hand — "it is only a formality, I will '
                'sign anything you like". What do you do?',
            answer: 'You do not hand it over. The password is the proof '
                'that the recipient really is the recipient — that is '
                'exactly why it was issued. A signature, an ID document '
                'you are not allowed to check, or friendly persuasion do '
                'not replace it. The obvious mistake is to put '
                'friendliness above the process: if the consignment is '
                'later reported as not received, the hand-over without a '
                'code stands as a mistake in your name. Ask the customer '
                'to look for the code in the order confirmation. If he '
                'cannot find it, you take the parcel back with you and '
                'document it correctly.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Refuelling, charging and the end of the route',
        blocks: [
          SubheadBlock('Refuelling'),
          ParagraphBlock(
            'The van is refuelled according to the company\'s rules: at '
            'the designated stations, with the vehicle\'s fuel card and '
            'with the correct fuel. The receipt belongs with the vehicle '
            'or is handed in where the trainer shows you. When you '
            'refuel comes down to a simple rule: not only once the '
            'reserve light comes on, but so that the next driver does '
            'not have to start with an almost empty tank.',
          ),
          BulletsBlock([
            'Correct fuel type — misfuelling puts the vehicle out of '
                'action for days',
            'The fuel card belongs with the vehicle, not in your private '
                'bag',
            'Keep the receipt and hand it in as instructed',
            'Engine off, no smoking, phone away at the pump',
          ]),
          SubheadBlock('Electric charging'),
          ParagraphBlock(
            'With an electric vehicle, charging takes the place of '
            'refuelling — with one important difference: charging takes '
            'longer and therefore has to be planned. The trainer shows '
            'you where charging is done, which cable belongs to the '
            'vehicle and what state of charge the vehicle should have at '
            'the end of the shift.',
          ),
          BulletsBlock([
            'Keep an eye on the state of charge and plan in good time, '
                'do not wait for the remaining range',
            'After plugging in, check that charging has really started',
            'Coil the cable up tidily and leave no trip hazards behind',
            'At the end of the shift hand the vehicle over as the '
                'company requires — the next driver starts with it',
          ]),
          SubheadBlock('End of the route — as on day 1'),
          StepsBlock([
            'Close the Flex app properly, finish the route, hand in '
                'returns.',
            'Vehicle inspection after the drive: walk-round, new damage, '
                'odometer reading, fuel or charge level.',
            'Load area empty and clean, cab tidied up.',
            'Clock out, hand in the key, complete the Green Book.',
          ]),
          ChecklistBlock(
            title: 'What I take away from day 2',
            items: [
              'The considerably higher number of stops set by my company '
                  '— which I drive and deliver myself',
              'I know what is in the Scorecard and how I influence it',
              'Quality is not the same as performance — both count',
              'I actively avoid damage and report every incident at once',
              'I keep the vehicle clean inside and out',
              'I know the Green Book under § 1 Abs. 6 FPersV and do the '
                  'separate training for it in the DA Academy',
              'I hand over password parcels only against the correct code',
              'I recognise ATLAS parcels and follow the prescribed '
                  'process',
              'I know the rules for refuelling and for electric charging',
              'At the end: close Flex, inspection, clock out',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ra4',
    title: 'Closing and handing in',
    summary: 'The trainer\'s feedback, signatures for each day and '
        'handing in the sheet as a photo',
    asset: '',
    slides: [
      SafetySlide(
        title: 'The trainer\'s feedback',
        blocks: [
          ParagraphBlock(
            'After the second day the trainer sits down with you and '
            'gives feedback on your performance and your driving skills. '
            'That is not a verdict in two words but an assessment: what '
            'is already going smoothly, what you need to work on, what '
            'you should pay particular attention to over the next few '
            'weeks.',
          ),
          BulletsBlock([
            'Driving: calmness, anticipation, reversing, dealing with '
                'tight spots',
            'Delivery: care, documentation, dealing with customers',
            'Organisation: sorting, sense of time, handling the apps',
            'Attitude to work: punctuality, asking questions, taking '
                'advice',
          ]),
          ParagraphBlock(
            'Take the feedback seriously, but not personally. It is the '
            'only occasion on which somebody has watched you for two '
            'full days. Ask if a point is unclear to you, and ask '
            'specifically: "What exactly should I do differently when '
            'reversing?" gets you further than a nod.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'The one question at the end',
            text: 'Ask your trainer at the end: "What is the one thing I '
                'should pay particular attention to in my first week on '
                'my own?" The answer is the most valuable thing to come '
                'out of two days.',
          ),
          RevealBlock(
            prompt: 'Case study: the feedback says you are too hesitant '
                'when manoeuvring and lose time as a result. You think '
                'you were simply being careful. How do you handle that?',
            answer: 'Ask rather than justify. Being careful when '
                'manoeuvring is right — by "hesitant" the trainer '
                'usually means something else: that you spend a long '
                'time thinking instead of getting out and taking a quick '
                'look, or that you shunt back and forth several times '
                'where one reverse with a check of both mirrors would '
                'have done. Ask for a specific example from the day. '
                'Then you have a point you can really work on, instead '
                'of an assessment you merely nod at or fend off.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The sheet: date, names, signatures',
        blocks: [
          ParagraphBlock(
            'The Ride Along checklist is only complete when the header '
            'details are right. Without them the sheet is a piece of '
            'paper with ticks that cannot be attributed to any record.',
          ),
          TableBlock(
            headers: ['Entry', 'What is meant'],
            rows: [
              ['Date', 'Entered separately for each of the two days'],
              ['Name of the trainee', 'Your name — the new driver'],
              ['Name of the instructor', 'The name of your trainer'],
              [
                'Signature',
                'By the trainer, separately per day — not once for both '
                    'days',
              ],
            ],
          ),
          ParagraphBlock(
            'There is a reason for signing per day: each day has its own '
            'list of points. If the second day is cancelled or '
            'postponed, what was completed on the first day is still '
            'cleanly documented. So check for yourself at the end of '
            'each day whether the date and the signature are there.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Check it yourself',
            text: 'The sheet is the proof of your induction. If a '
                'signature is missing, the proof is missing — and '
                'sorting that out after the event is always awkward. One '
                'glance before you finish is enough.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Handing in: photo to the dispatcher',
        blocks: [
          ParagraphBlock(
            'At the end of the second day the completed sheet is handed '
            'in as a photo to your responsible dispatcher. That formally '
            'concludes the Ride Along and documents your induction.',
          ),
          StepsBlock([
            'Put the sheet on a flat surface and find good light.',
            'Photograph it from above, the whole sheet in frame, without '
                'shadows and without cut-off edges.',
            'Check that the ticks, the date, the names and the '
                'signatures are legible.',
            'Hand the photo to the responsible dispatcher — by whatever '
                'route the trainer tells you.',
            'Treat the paper sheet as your company requires: it may be '
                'asked for.',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Illegible is the same as not handed in',
            text: 'A blurred or half cut-off photo has to be taken '
                'again — and by then the two of you may already be at '
                'home. Take one look at it before you send it off.',
          ),
          ChecklistBlock(
            title: 'What I take away from the closing stage',
            items: [
              'After day 2 the trainer gives feedback on performance and '
                  'driving skills',
              'I ask specific questions about anything unclear',
              'The sheet carries the date, the name of the trainee and '
                  'the name of the instructor',
              'The trainer signs separately for each day',
              'At the end of each day I check for myself that everything '
                  'is filled in',
              'At the end of day 2 the sheet is handed in as a legible '
                  'photo to the responsible dispatcher',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ra5',
    title: 'How to prepare',
    summary: 'What you should sort out BEFORE day 1 — logins, kit, '
        'timing and your questions',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Sort out beforehand: logins and technology',
        blocks: [
          ParagraphBlock(
            'The most common reason why a first day gets off to a bad '
            'start is not missing knowledge but a login that does not '
            'work. Sort that out beforehand — then your Ride Along '
            'starts with what it is actually about.',
          ),
          BulletsBlock([
            'Your own account for delivering: credentials to hand and '
                'signed in successfully once',
            'Your company\'s time tracking (e.g. Kenjo): access set up, '
                'you know how to clock in and out',
            'Mentor and Flex: apps installed, sign-in tested, '
                'permissions for location and motion granted',
            'CoDriver: signed in, notifications allowed',
            'Phone: charged, enough storage, charging cable or power '
                'bank for the van with you',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Check the evening before, not in the morning',
            text: 'Resetting a password takes five minutes at 8 p.m. and '
                'half an hour at 6 a.m. in the Waiting Area — if anyone '
                'can be reached at all.',
          ),
          RevealBlock(
            prompt: 'Case study: on the morning of the first day your '
                'delivery app will not let you sign in. The trainer is '
                'waiting, the wave is starting. What is the best '
                'reaction?',
            answer: 'Say straight away that your login does not work — '
                'and say it to the trainer, so that he can bring in your '
                'responsible dispatcher. The obvious mistake is to keep '
                'quietly trying so as not to look incapable. That costs '
                'you the very minutes in which the problem could still '
                'be solved, and in the end you spend the whole day '
                'riding along on the trainer\'s account — which means '
                'the minimum number of stops on your own account is not '
                'met and in the worst case the day has to be repeated. '
                'So: report it early and say clearly what you have '
                'already tried.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Clothing, kit and punctuality',
        blocks: [
          SubheadBlock('What you wear'),
          BulletsBlock([
            'Safety shoes: sturdy, closed work shoes — no trainers, no '
                'sandals',
            'Weatherproof clothing: you are outside all day, even if it '
                'looks dry in the morning',
            'Freedom of movement: you get in and out hundreds of times',
            'Hi-vis vest within reach — it is in the vehicle, but it '
                'belongs in your head',
          ]),
          SubheadBlock('What you bring'),
          BulletsBlock([
            'Driving licence — without it you do not drive, not even on '
                'the first day',
            'ID or residence document, if the company requires it',
            'A drink and something to eat for the break',
            'A pen and a small notebook or notes app',
          ]),
          SubheadBlock('Punctuality'),
          ParagraphBlock(
            'Punctual means: ready to work at the station at the start '
            'of the shift, not arriving at the gate. Add on the time for '
            'parking, walking across the yard and the Waiting Area. '
            'Anyone who is late on the first day pushes the trainer\'s '
            'wave back as well — and that sticks.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Rule of thumb for the first few days',
            text: 'Plan your journey so that you are there a bit early. '
                'Use the quarter of an hour you gain to look around — '
                'toilets, Waiting Area, parking bays.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Your questions — and the checklist beforehand',
        blocks: [
          ParagraphBlock(
            'For two days you have somebody next to you who knows '
            'everything you need to know. That is a situation that will '
            'not come round again. The mistake almost everyone makes: '
            'they do not make a note of their questions, and only think '
            'of them again in week two, alone in the van.',
          ),
          BulletsBlock([
            'Write down what you want to know before day 1 — including '
                'small things',
            'Note the answers during the route, do not rely on your '
                'memory',
            'Photograph nothing containing customer data, but note down '
                'procedures and contacts',
            'Ask at the end of each day: "What have I not seen yet '
                'today?"',
          ]),
          ParagraphBlock(
            'Good questions for the Ride Along are, for example: when '
            'exactly is my Waiting Area slot? Where do I park my own '
            'car? How do I tell whether Mentor is still running? Where '
            'do I record my break? Who do I report damage to first? '
            'Where do I hand in the Green Book? What do I do if a '
            'customer does not have the code for a password parcel?',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Why you did this training',
            text: 'Not so that you can already do everything at the Ride '
                'Along, but so that you know the terms. If you know what '
                'is meant, you can listen — if you are hearing it all '
                'for the first time, all you can do is nod.',
          ),
          RevealBlock(
            prompt: 'Case study: in the morning the trainer explains ten '
                'things one after another. By the evening you remember '
                'three of them. What was the reason — you?',
            answer: 'The method, not you. Having ten new procedures '
                'explained one after another and retaining them does not '
                'work for anybody. What does work: having read the terms '
                'once beforehand — that is exactly what this training is '
                'for — and taking notes as you go. Two keywords per '
                'topic are enough to bring the whole procedure back in '
                'the evening. And whatever is still missing on the '
                'second day you ask about specifically, instead of '
                'hoping it will come back to you by itself.',
          ),
          ChecklistBlock(
            title: 'Before day 1 — to tick off yourself',
            items: [
              'Credentials for my own delivery account tested',
              'Time tracking (e.g. Kenjo), Mentor, Flex and CoDriver '
                  'installed and signed in',
              'Phone charged, charging cable or power bank packed',
              'Safety shoes and weatherproof clothing laid out',
              'Driving licence and required documents in my pocket',
              'A drink and food for the break prepared',
              'Pen and something to write on with me',
              'Journey planned — including parking and the walk to the '
                  'Waiting Area',
              'My questions for the trainer written down',
              'This training worked through, so that I know the terms',
            ],
          ),
        ],
      ),
    ],
  ),
];
