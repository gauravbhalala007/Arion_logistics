// lib/data/safety_training/driving_safety_quiz_en.dart
//
// DSP driving safety training questions — English version.
// The structure is identical to the German master: the same number of
// questions, the same order, the same correct answers.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> drivingQuestionsEn = [
  // ── M1 ──
  DrivingQuestion(
    moduleId: 'm1',
    question: 'You are 20 stops behind schedule. Which reaction matches '
        'the safety culture in the company?',
    options: [
      'Drive faster between the stops but stay careful at the stops '
          'themselves',
      'Report the delay and carry on at your usual safe pace',
      'Shorten the checks when manoeuvring but leave your driving '
          'unchanged',
    ],
    correctIndex: 1,
    explanation: 'Time pressure is a planning problem and gets '
        'reported, not made up for at the wheel. The other two answers '
        'sound like a compromise but only move the risk around: a '
        'higher speed between stops lengthens exactly the stopping '
        'distance, and shortened manoeuvring checks hit the activity in '
        'which 70 % of all damage occurs.',
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Your dispatcher instructs you to set off with a defective '
        'brake light. Who bears the responsibility if that leads to a '
        'rear-end collision?',
    options: [
      'The dispatcher, because he gave the instruction',
      'The company, because it provides the vehicle',
      'Nobody — a single brake light is not a safety-relevant defect',
      'You, as the driver in charge',
    ],
    correctIndex: 3,
    explanation: 'As the driver in charge you are responsible for the '
        'roadworthy condition of the vehicle you move — a verbal '
        'instruction does not cancel that out. The fact that the '
        'company provides the vehicle sounds convincing but does not '
        'let you off: fines and penalty points hit you personally. The '
        'right thing is to report the defect and ask for another '
        'vehicle.',
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'While manoeuvring you missed a bollard by just a few '
        'centimetres — nothing happened. What is right?',
    options: [
      'Report it as a near miss',
      'Do nothing, after all there was no damage and nobody was '
          'endangered',
      'Only report it if a colleague or a camera noticed it',
    ],
    correctIndex: 0,
    explanation: 'A near miss reveals a hazard before it hits someone — '
        'once reported, it is defused for the next colleague. The '
        'thought "no damage, no issue" is the most common reason why '
        'the same spot does cause damage weeks later.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'During which activity does around 70 % of all van damage '
        'occur?',
    options: [
      'On motorways and country roads at high speed',
      'When turning at junctions in town traffic',
      'While manoeuvring and reversing',
    ],
    correctIndex: 2,
    explanation: 'The vast majority of damage happens at walking pace '
        'while manoeuvring. High speed causes the most serious '
        'accidents but not the most damage — and it is exactly that '
        'confusion which leads to too little care while manoeuvring.',
  ),

  // ── M2 ──
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Under the recognised rules of engineering a load must be '
        'secured against 0.8 g towards the front. Roughly what '
        'restraining force does that mean for a 20 kg parcel?',
    options: [
      'about 2 kg',
      'about 8 kg',
      'about 16 kg',
      'about 200 kg',
    ],
    correctIndex: 2,
    explanation: '0.8 × 20 kg gives around 16 kg of restraining force. '
        '"About 2 kg" dramatically underestimates the force and is the '
        'reason why parcels are thought to be harmless; "200 kg" '
        'confuses the securing requirement with the impact force in a '
        'real collision, which is in fact far higher still.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'How do you load the load space correctly?',
    options: [
      'Heavy at the bottom and forward against the bulkhead, weight '
          'spread evenly',
      'Heavy on top, so that the heavy parcels are not underneath the '
          'light ones when you reach in',
      'Heavy at the back by the door, so that the heavy consignments '
          'come out first',
    ],
    correctIndex: 0,
    explanation: 'Heavy + low + forward keeps the centre of gravity low '
        'and the mass where the bulkhead can catch it. The other two '
        'versions are thought out around the work routine, not around '
        'physics: weight on top increases the tendency to tip, weight '
        'at the back unloads the front axle and worsens the steering.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Two thirds of the way through the round the load space is '
        'half empty. What applies to load securing now?',
    options: [
      'It matters less, because there is far less weight on board',
      'It has to be redone — the remaining parcels now have more '
          'distance in which to build up speed',
      'It applies unchanged, there is nothing to do',
    ],
    correctIndex: 1,
    explanation: 'The emptier the load space, the greater the distance '
        'over which a parcel can accelerate before it hits something. '
        '"Less weight, less danger" sounds logical but is wrong: what '
        'matters is not the total mass but the single unsecured '
        'parcel.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'What does DGUV Vorschrift 70 (vehicles) require of you '
        'before the start of the shift?',
    options: [
      'A technical inspection with a vehicle lift and a brake test '
          'bench',
      'A check of the vehicle for obvious defects',
      'A check only on vehicles you are driving for the first time',
    ],
    correctIndex: 1,
    explanation: 'What is required is the check for obvious defects '
        'before the shift — exactly what the walk-around delivers. The '
        'technical inspection is the garage\'s job and does not replace '
        'your walk-around; and the duty applies to every vehicle on '
        'every day, not only to unfamiliar ones.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'What minimum tread depth does the law prescribe — and '
        'what makes sense on a wet road?',
    options: [
      '3 mm by law; in the wet 1.6 mm is then enough',
      '1.6 mm by law; that is still enough in the wet',
      '4 mm by law, all year round for all tyres',
      '1.6 mm by law; in the wet at least 3 mm makes sense',
    ],
    correctIndex: 3,
    explanation: 'The legal minimum is 1.6 mm, in practice at least '
        '3 mm makes sense in the wet. The answer "1.6 mm is enough in '
        'the wet too" is the classic error: the minimum is the boundary '
        'to an offence, not the boundary to safety — at 1.6 mm the tyre '
        'barely displaces any water.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'The next stop is lying on the passenger seat so that you '
        'can grab it quickly. What is the main problem with that?',
    options: [
      'Under braking the parcel becomes a projectile and can end up '
          'under the brake pedal',
      'It looks untidy at a roadside check',
      'It is permitted as long as the parcel weighs less than 10 kg',
    ],
    correctIndex: 0,
    explanation: 'Everything in the cab carries on at your original '
        'speed under braking — in the worst case into the footwell and '
        'under the pedal. There is no weight limit for that: even a '
        'light parcel blocks a pedal.',
  ),

  // ── M3 ──
  DrivingQuestion(
    moduleId: 'm3',
    question: 'You are driving at 80 km/h on a dry road outside a '
        'built-up area. What is the minimum correct gap to the vehicle '
        'in front?',
    options: [
      'About 20 metres — that is three vehicle lengths',
      'About 45 metres — roughly two seconds or half the speedometer '
          'reading',
      'About 10 metres, as long as you are alert and the road is clear',
    ],
    correctIndex: 1,
    explanation: 'At 80 km/h two seconds equal around 45 metres, half '
        'the speedometer reading 40 metres — the two match up. Twenty '
        'metres look like a lot on the road but are less than the '
        'thinking distance alone of 24 metres: you would have hit the '
        'vehicle before the brakes even bite.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'How long is the stopping distance at 50 km/h according to '
        'the rules of thumb (normal braking)?',
    options: [
      '15 metres',
      '25 metres',
      '40 metres',
      '65 metres',
    ],
    correctIndex: 2,
    explanation: 'Thinking distance (50 ÷ 10) × 3 = 15 m plus braking '
        'distance (50 ÷ 10)² = 25 m gives 40 m. Anyone who says 25 '
        'metres has only worked out the braking distance and forgotten '
        'the thinking distance — that is the most common calculation '
        'error and exactly the part of the distance you cover at full '
        'speed.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'How do you work out the thinking distance using the rule '
        'of thumb?',
    options: [
      '(speed ÷ 10) × 3',
      '(speed ÷ 10) × (speed ÷ 10)',
      'speed ÷ 2',
    ],
    correctIndex: 0,
    explanation: 'The thinking distance is (km/h ÷ 10) × 3. The second '
        'formula is the braking distance, the third the rule of thumb '
        'for the safe following distance — they look similar but '
        'describe completely different things.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'You double your speed from 30 to 60 km/h. How does the '
        'braking distance alone change?',
    options: [
      'It doubles',
      'It quadruples',
      'It triples',
      'It stays almost the same, because the brakes bite harder at '
          'higher speeds',
    ],
    correctIndex: 1,
    explanation: 'The braking distance grows with the square of the '
        'speed: 9 metres become 36 metres. The obvious answer "doubles" '
        'underestimates exactly that — and it explains why 20 km/h more '
        'in a residential street feels harmless.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Why do you have to take bends considerably slower in a '
        'fully loaded van than in a car?',
    options: [
      'Because the high centre of gravity greatly increases the '
          'tendency to tip',
      'Because the steering becomes less precise when loaded',
      'Because the tyres go softer under load and have more grip',
    ],
    correctIndex: 0,
    explanation: 'A highly loaded panel van tips over where a car still '
        'slides — and gives almost no warning. The steering precision '
        'does change too, but that is not the real risk: tipping '
        'happens suddenly and ends off the road.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'You want to turn right at a set of traffic lights and a '
        'cyclist is standing to your right. The lights turn green. What '
        'do you do first?',
    options: [
      'Move off briskly and turn before the cyclist gets going',
      'Look in the right-hand wing mirror and then turn in',
      'Shoulder check to the right and let the cyclist go through',
    ],
    correctIndex: 2,
    explanation: 'As soon as you move off and turn in, the cyclist '
        'moves into the blind spot — and your rear end also swings into '
        'their lane. Looking in the mirror sounds right but is no '
        'longer enough at exactly the moment it matters: the mirror '
        'does not show the whole area to the right of the cab.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'What minimum side clearance must you keep when overtaking '
        'a cyclist in a built-up area?',
    options: [
      '1.0 metre',
      '1.5 metres',
      '2.0 metres',
    ],
    correctIndex: 1,
    explanation: 'In built-up areas it is 1.5 metres, outside them 2.0 '
        'metres. Anyone who takes 2.0 metres for the built-up-area '
        'figure is mixing the two up — and anyone overtaking with 1.0 '
        'metre falls below the minimum clearance and is liable if the '
        'cyclist falls.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'How far ahead should you be looking while driving?',
    options: [
      'At the bumper of the vehicle in front, so that you see it '
          'braking immediately',
      'At your own bonnet, because that keeps you most accurately in '
          'lane',
      '12–15 seconds ahead',
    ],
    correctIndex: 2,
    explanation: 'Looking far ahead buys you time: you see traffic '
        'lights, brake lights and pedestrians before you have to react. '
        'Looking at the bumper feels attentive but turns you into a '
        'pure reactor — you only learn about the hazard once the '
        'vehicle in front is already braking.',
  ),

  // ── M4 ──
  DrivingQuestion(
    moduleId: 'm4',
    question: 'What does GOAL stand for when reversing?',
    options: [
      '"Get Out And Look" — stop, get out, look behind the vehicle',
      '"Go Only At Low speed" — reverse exclusively at walking pace',
      '"Guide On A Line" — take your bearings from a ground marking',
    ],
    correctIndex: 0,
    explanation: 'GOAL means getting out and looking — it reveals low '
        'bollards, slopes and children that you never see from the '
        'seat. Walking pace is compulsory too, but it does not replace '
        'looking: even at walking pace you are driving into an area you '
        'cannot see.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Your vehicle has a reversing camera. What does that '
        'change about GOAL?',
    options: [
      'GOAL is no longer needed, because the camera shows the area '
          'behind the vehicle',
      'Nothing',
      'GOAL is then only needed in darkness and poor visibility',
    ],
    correctIndex: 1,
    explanation: 'The camera shows only a section, distorts distances '
        'and goes blind in rain, snow and dirt — above all it does not '
        'see what walks into your path from the side. It adds to GOAL, '
        'it never replaces it.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Where does a banksman stand correctly?',
    options: [
      'Directly behind the vehicle, because from there he can judge '
          'the distance best',
      'In front of the vehicle, so that he can stop the traffic at the '
          'same time',
      'To the side, so that you can see him in the mirror at all times',
    ],
    correctIndex: 2,
    explanation: 'Only someone standing to the side and permanently '
        'visible can guide you safely. The position directly behind the '
        'vehicle looks closest to the action but is exactly the area in '
        'which the banksman himself gets run over as soon as you lose '
        'sight of him.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'You suddenly can no longer see your banksman in the '
        'mirror. What do you do?',
    options: [
      'Carry on more slowly until he reappears',
      'Stop immediately',
      'Sound the horn briefly and carry on so that he shows himself '
          'again',
    ],
    correctIndex: 1,
    explanation: 'No visual contact means no valid signal — so stop, do '
        'not just slow down. "Carry on more slowly" sounds cautious but '
        'means you keep driving into an area that nobody is watching '
        'for you any more.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'What does § 9 (5) StVO require when reversing?',
    options: [
      'Switching on the hazard lights',
      'Driving at no more than walking pace',
      'Ruling out any danger to others — with a banksman if necessary',
    ],
    correctIndex: 2,
    explanation: 'The rule demands that every danger be ruled out, if '
        'necessary with a banksman — so the standard is the result, not '
        'a particular speed. Walking pace and hazard lights are good '
        'practice but do not fulfil the duty on their own.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'The last stop is in a tight inner courtyard: you can get '
        'in forwards, but only out in reverse past a wall. What is the '
        'safest decision?',
    options: [
      'Stop on the street and go the last few metres on foot or with '
          'the sack truck',
      'Drive in forwards, because then you already know the entrance '
          'for the way back',
      'Reverse in briskly while the street is still clear',
    ],
    correctIndex: 0,
    explanation: 'The safest reversing manoeuvre is the one that never '
        'happens. The idea that you "know the entrance once you have '
        'driven in" is a fallacy: on the way out the critical points '
        'are behind you, and the waiting traffic adds pressure on top.',
    moduleOnly: true,
  ),

  // ── M5 ──
  DrivingQuestion(
    moduleId: 'm5',
    question: 'The steering suddenly goes light and the tyres are '
        'floating on a film of water. What do you do?',
    options: [
      'Brake hard and steer against it',
      'Ease off the accelerator, hold the steering calm and straight, '
          'let it roll out',
      'Accelerate to leave the water quickly',
    ],
    correctIndex: 1,
    explanation: 'As long as the film of water carries the tyre, brakes '
        'and steering have no effect — they only take effect all at '
        'once when the tyre grips again, and that is exactly how a skid '
        'starts. Braking and steering against it is the intuitive but '
        'wrong reaction.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'What does the risk of aquaplaning depend on most '
        'strongly?',
    options: [
      'On the weight of the load',
      'On the age of the vehicle and its brakes',
      'On tread depth, water depth and above all speed',
    ],
    correctIndex: 2,
    explanation: 'The risk rises disproportionately with speed and '
        'falls with tread depth — the tread has to channel the water '
        'away in front of the tyre. The load plays a minor role: more '
        'weight does press the tyre onto the road harder, but it does '
        'not change the fact that a shallow tread displaces no more '
        'water at speed.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'In fog you can still see about 40 metres. How fast may '
        'you drive at most?',
    options: [
      'No more than 40 km/h',
      'Up to the posted speed limit, as long as your lights are on',
      'No more than 80 km/h if the rear fog light is switched on',
    ],
    correctIndex: 0,
    explanation: 'Rule of thumb: your visibility in metres is your '
        'upper limit in km/h — so with 40 metres of visibility, '
        '40 km/h. Lights and the rear fog light make you more visible '
        'but do not extend your own visibility and therefore not the '
        'permitted speed either.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'When does § 2 (3a) StVO require winter-capable tyres?',
    options: [
      'Always from October to Easter, regardless of the weather',
      'In black ice, packed snow, slush, ice or frost',
      'Only when there is an unbroken covering of snow on the road',
    ],
    correctIndex: 1,
    explanation: 'In Germany the duty is situational: it depends on the '
        'state of the road, not on the calendar. "October to Easter" is '
        'only a practical reminder for changing tyres and is not a '
        'legal basis — and slush is already enough, there does not have '
        'to be an unbroken covering.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'It is freezing cold and you are under time pressure. You '
        'only scrape the driver\'s side of the windscreen clear. What '
        'applies?',
    options: [
      'Allowed, as long as you drive considerably slower',
      'Allowed, if the heater clears the rest while you drive',
      'Not allowed — all windows, mirrors, lights and the number plate '
          'must be clear',
    ],
    correctIndex: 2,
    explanation: 'The scraped "peephole" is an offence and, in an '
        'accident, a serious allegation of fault. The heater catching '
        'up is no exception: what counts is the state of the vehicle '
        'when you set off, not three minutes later.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Why is an EMPTY panel van particularly at risk in a '
        'storm?',
    options: [
      'Because it lacks the weight of the load that keeps it on the '
          'road',
      'Because the air resistance is greater without a load',
      'Because the tyre pressure is higher when it is empty',
    ],
    correctIndex: 0,
    explanation: 'The surface exposed to the wind is the same empty as '
        'loaded, but the mass is far smaller — so the same gust pushes '
        'the vehicle aside more. The air resistance is not changed at '
        'all by the load inside, and that is the error in reasoning.',
    moduleOnly: true,
  ),

  // ── M6 ──
  DrivingQuestion(
    moduleId: 'm6',
    question: 'May you pick up your phone while driving to change the '
        'music?',
    options: [
      'Yes, if it only takes a second and the road is clear',
      'Only at a red light',
      'No',
    ],
    correctIndex: 2,
    explanation: 'Picking the device up or holding it is already the '
        'offence — regardless of what for. A red light is no exception '
        'as long as the engine is running. Music, destination and '
        'volume are set before the drive while stationary.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'When may you legally pick up your phone or the scanner?',
    options: [
      'Only when the vehicle is stationary AND the engine is switched '
          'off',
      'As soon as the vehicle is stationary — the automatic stop-start '
          'is enough for that',
      'Briefly while driving, when the road is straight and clear',
    ],
    correctIndex: 0,
    explanation: 'The exception only applies with the vehicle '
        'stationary and the engine switched off. The automatic '
        'stop-start expressly does not count — and that is exactly what '
        'many people rely on at a red light, where they collect their '
        'fine.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'You are driving at 50 km/h and look at the display for 2 '
        'seconds. How far do you drive without seeing the road?',
    options: [
      'about 8 metres',
      'about 28 metres',
      'about 14 metres',
      'about 50 metres',
    ],
    correctIndex: 1,
    explanation: '50 km/h is around 14 metres per second, so about 28 '
        'metres in 2 seconds. Anyone who picks "14 metres" has only '
        'worked out one second — a typical error that makes the blind '
        'stretch look half as long.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'You nod off for 4 seconds at 80 km/h. What distance do '
        'you cover out of control?',
    options: [
      'about 30 metres',
      'about 50 metres',
      'about 90 metres',
      'about 160 metres',
    ],
    correctIndex: 2,
    explanation: '80 km/h is around 22 metres per second, times 4 gives '
        'about 89 metres. Unlike a glance at the phone, you are not '
        'steering at all during that time — the vehicle drifts out of '
        'its lane. That is why the idea of a "short" nod-off is so '
        'dangerous.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'What really helps against acute fatigue at the wheel?',
    options: [
      'Opening the window and playing loud music',
      'Drinking coffee and driving faster to finish earlier',
      'Stopping, a 15–20 minute nap, then some movement',
    ],
    correctIndex: 2,
    explanation: 'Only sleep and movement restore your attention. Fresh '
        'air and loud music work for a few minutes at most and fake '
        'alertness while doing so — and it is in exactly that phase '
        'that you overestimate yourself the most.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'One earbud for hands-free calls, the other ear free — is '
        'that acceptable while driving?',
    options: [
      'Yes, one free ear is enough for traffic',
      'Yes, as long as the volume is set low',
      'No',
    ],
    correctIndex: 2,
    explanation: 'You have to be able to locate horns, shouts and '
        'emergency vehicles reliably — and for that you need both ears; '
        'when manoeuvring, your hearing is often the only warning. A '
        'low volume does not change the fact that one ear is occupied.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'What do you face if you endanger another road user while '
        'holding your phone?',
    options: [
      '100 € and 1 penalty point',
      '150 €, 2 penalty points and a 1-month driving ban',
      'A verbal warning with no record',
    ],
    correctIndex: 1,
    explanation: '100 € and 1 point is the basic offence without '
        'endangerment; if endangerment is added it rises to 150 €, 2 '
        'points and a one-month driving ban. For you as a professional '
        'driver the money is not the problem — the driving ban is.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Today\'s round plan cannot be completed safely. What is '
        'the right reaction?',
    options: [
      'Carry on working safely and report the planning problem early',
      'Cut out breaks and shorten the checks when manoeuvring',
      'Drive faster between stops and make the time up there',
    ],
    correctIndex: 0,
    explanation: 'The plan gets adjusted, not your safety. The timing '
        'also matters: a report in the early afternoon can still change '
        'something, one in the evening cannot. Cutting out breaks makes '
        'the problem worse, because that is exactly when your attention '
        'drops.',
    moduleOnly: true,
  ),

  // ── M7 ──
  DrivingQuestion(
    moduleId: 'm7',
    question: 'What is the BG Verkehr 3-point rule ("2+1") for getting '
        'in and out?',
    options: [
      'One hand and two feet are always on the vehicle',
      'Two hands and one foot are always in contact with the vehicle',
      'Both feet are on the ground before you let go of the handles',
    ],
    correctIndex: 1,
    explanation: 'Two hands plus one foot make three firm points, so '
        'that a single slip never leads to a fall. "Both feet on the '
        'ground first" describes exactly the moment when you have no '
        'hold at all — that is the jumping version.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'How do you get out of the cab correctly?',
    options: [
      'Forwards, with your back to the door, jumping the last step',
      'Twisting sideways out of the seat and landing on both feet',
      'Backwards, facing the vehicle, like on a ladder',
    ],
    correctIndex: 2,
    explanation: 'Only facing the vehicle can you use the grab handles '
        'and the step and keep three points of contact. Twisting out of '
        'the seat looks quicker but loads your knee and ankle with your '
        'full body weight at once — it is the most common mistake when '
        'getting out.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Which of these holds does NOT count as a safe point of '
        'contact?',
    options: [
      'The grab handle on the A-pillar',
      'The door edge',
      'The grab handle on the door frame',
    ],
    correctIndex: 1,
    explanation: 'The door edge is part of a moving component: the door '
        'can give way or swing shut, precisely when you shift your '
        'weight onto it. The same applies to the steering wheel, seat, '
        'tyre and wheel hub — the only safe points are the grab handles '
        'provided for the purpose.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'You have the scanner and a parcel in your hands and want '
        'to climb out of the load space. What is right?',
    options: [
      'Put both down first, then climb down with free hands',
      'Tuck the parcel under your arm and hold on with your free hand',
      'Get out briskly, it is only two steps after all',
    ],
    correctIndex: 0,
    explanation: 'With your hands full you do not have three points of '
        'contact and cannot break a fall. The one-handed version sounds '
        'like a compromise but is exactly the situation in which a slip '
        'leads straight to a fall: one point does not hold you.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'You have stopped at the kerb and want to open the '
        'driver\'s door. What protects a cyclist coming up behind you '
        'best?',
    options: [
      'Opening the door just a crack and waiting briefly',
      'Opening the door quickly and wide so that it is clearly visible',
      'Taking a quick look in the wing mirror before opening',
      'Shoulder check and mirror — and opening the door with your far '
          'hand',
    ],
    correctIndex: 3,
    explanation: 'Reaching across with your far hand automatically '
        'turns your upper body to the rear and forces you to look. A '
        'quick glance in the mirror alone is not enough, because a '
        'cyclist in the blind spot is invisible at exactly that moment; '
        'and opening the door a crack warns nobody who is already '
        'beside you.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'What is the most dangerous combination for your spine '
        'when lifting?',
    options: [
      'Lifting while twisting your upper body',
      'Lifting from a squat with sharply bent knees',
      'Lifting with the load close to your body',
    ],
    correctIndex: 0,
    explanation: 'Load plus twisting stresses the discs on one side and '
        'is the classic cause of acute back injuries — move your feet '
        'round instead. Squatting and keeping the load close to your '
        'body are, by contrast, exactly the right technique.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'You twist your ankle slightly while getting out but can '
        'carry on working. What is right?',
    options: [
      'Wait and only report it if it still hurts the next day',
      'Do nothing — it was only a twist with no time off',
      'Report it immediately and enter it in the first-aid record book',
    ],
    correctIndex: 2,
    explanation: 'Only documented incidents count later as a workplace '
        'accident, and an untreated ligament problem heals worse. '
        'Waiting until the next day is common and is exactly why the '
        'connection with work often is no longer recognised later.',
    moduleOnly: true,
  ),

  // ── M8 ──
  DrivingQuestion(
    moduleId: 'm8',
    question: 'A large dog is barking at the garden gate. The customer '
        'has noted in the delivery instructions: "the dog is friendly." '
        'What do you do?',
    options: [
      'Walk in calmly — the customer knows their dog best',
      'Do not enter the property, try to make contact and leave a note '
          'for colleagues',
      'Put the parcel over the fence and drive on',
    ],
    correctIndex: 1,
    explanation: 'A delivery note is not a safety clearance: the '
        'customer knows their dog around the family, not around a '
        'stranger carrying a large object. Putting the parcel over the '
        'fence is also not a proper delivery.',
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'A loose dog comes towards you barking. What is right?',
    options: [
      'Stand still and stay calm, look away, turn your side towards it '
          'and back away slowly',
      'Run back to the vehicle quickly and close the door',
      'Raise your voice and hold the parcel up to fend it off',
    ],
    correctIndex: 0,
    explanation: 'Calm, an averted gaze and slowly backing away take '
        'away the dog\'s reason to act. Running to the vehicle sounds '
        'sensible but is wrong: running away triggers the chase reflex, '
        'and the dog is faster than you.',
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'The shortest route to the front door goes across a wet '
        'lawn. What do you do?',
    options: [
      'Cut across — with 120 stops the detours add up considerably',
      'Cut across, but only in daylight and dry weather',
      'Take the made-up path',
    ],
    correctIndex: 2,
    explanation: 'Tripping, slipping and falling is the most common '
        'cause of injury in delivery work, and it almost always happens '
        'on the last few metres. The time calculation does not add up: '
        'the detour costs seconds, a fall costs 24 days off work on '
        'average.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'What applies when you leave the vehicle for a delivery?',
    options: [
      'Engine off, take the key, lock up, turn the wheels in on a '
          'slope',
      'The engine may run as long as you stay within sight',
      'It is enough to apply the handbrake firmly',
    ],
    correctIndex: 0,
    explanation: 'Anyone leaving their vehicle must secure it against '
        'unauthorised use and avoid accidents. "Within sight" is no '
        'exception — a running, open vehicle is gone in seconds, and on '
        'a slope the handbrake alone does not reliably hold a loaded '
        'van.',
  ),

  // ── M9 ──
  DrivingQuestion(
    moduleId: 'm9',
    question: 'In what order do you act at an accident scene with '
        'casualties?',
    options: [
      'Give first aid, then make the scene safe, then call the '
          'emergency services',
      'Make safe, then call, then first aid',
      'Call, then take photos for the insurer, then first aid',
    ],
    correctIndex: 1,
    explanation: 'Make the scene safe first, otherwise one accident '
        'becomes two — with you as the casualty. Running straight to '
        'the injured person feels humanly right but is life-threatening '
        'on country roads and motorways; photos have no place at all at '
        'this stage.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'At what distance do you set up the warning triangle on '
        'the motorway?',
    options: [
      'approx. 50 metres',
      'approx. 100 metres',
      'approx. 150–200 metres',
    ],
    correctIndex: 2,
    explanation: 'Around 50 m in built-up areas, around 100 m outside '
        'them, 150–200 m on the motorway — the higher the speed, the '
        'earlier the warning has to stand. Anyone using the '
        'outside-built-up-area figure gives the traffic behind barely '
        'three seconds at 120 km/h. Before crests and bends the '
        'triangle belongs in front of them, not behind.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Traffic slows to a crawl on a three-lane motorway. Where '
        'do you form the emergency corridor?',
    options: [
      'Between the left-hand and the middle lane',
      'Between the middle and the right-hand lane',
      'On the hard shoulder',
      'In the middle of the carriageway, regardless of the number of '
          'lanes',
    ],
    correctIndex: 0,
    explanation: 'The corridor is always between the far left lane and '
        'the lane immediately to its right — no matter how many lanes '
        'there are. The hard shoulder is no alternative: emergency '
        'services drive there when the corridor is blocked.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'When must the emergency corridor be formed?',
    options: [
      'Only once blue lights can be seen or heard',
      'As soon as traffic slows to a crawl',
      'Only once it is ordered on the overhead signs',
    ],
    correctIndex: 1,
    explanation: 'The corridor is created as traffic slows, not when '
        'the blue lights arrive. If you wait for the emergency vehicle, '
        'the vehicles are long since too close together — and then '
        'nobody has room to move aside.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'While manoeuvring you damage a parked car and nobody is '
        'around. Is a note under the windscreen wiper enough?',
    options: [
      'Yes, if your name and telephone number are on it',
      'Yes, a note is the route provided for by law',
      'No — it is only enough if you take photos as well',
      'No — you have to wait a reasonable time and otherwise inform '
          'the police',
    ],
    correctIndex: 3,
    explanation: 'In law a note does not count as sufficient '
        'establishment of identity — it can blow away or be removed; '
        'anyone relying on it risks being accused of leaving the scene '
        'of an accident. Photos do document the damage but replace '
        'neither the waiting nor the report.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'After the accident a person is not breathing normally. '
        'What do you do?',
    options: [
      'Start chest compressions immediately, about 100–120 times per '
          'minute',
      'Put the person in the recovery position and cover them up',
      'Wait for the ambulance — as a layperson you must not do '
          'anything',
    ],
    correctIndex: 0,
    explanation: 'Without normal breathing every minute counts, and '
        'compressions are the only measure that helps. The recovery '
        'position is right — but only when normal breathing is present. '
        'And doing nothing is the only wrong decision: failure to give '
        'assistance is a criminal offence.',
  ),

  // ── M10 ──
  DrivingQuestion(
    moduleId: 'm10',
    question: 'What best sums up the attitude behind this training?',
    options: [
      'Rules apply above all when someone is checking',
      'Safety is my daily decision, so that everyone gets home safely',
      'The main thing is that the round is finished on time',
    ],
    correctIndex: 1,
    explanation: 'Safety is an attitude, not a compulsory exercise — '
        'and it shows precisely when nobody is watching. Anyone who '
        'ties rules to inspections has not understood them, only put up '
        'with them.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm10',
    question: 'How many points of contact do you keep when getting in '
        'and out — and how many seconds of gap as a minimum on a dry '
        'road?',
    options: [
      '2 points of contact and 1 second',
      '3 points of contact and 1 second',
      '3 points of contact (2 hands + 1 foot) and 2 seconds',
    ],
    correctIndex: 2,
    explanation: 'Three points of contact ("2+1") and a two-second '
        'gap — three in the wet. At 50 km/h a one-second gap is exactly '
        'the thinking distance alone: you would hit the vehicle in '
        'front with no braking reserve at all.',
  ),
];
