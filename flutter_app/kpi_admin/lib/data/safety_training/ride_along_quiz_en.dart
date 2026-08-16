// lib/data/safety_training/ride_along_quiz_en.dart
//
// Questions of the Ride Along final test — English version. Fifteen
// questions spread over the five chapters from ride_along_content_en.dart
// (ra1 … ra5), three questions per chapter. The structure is identical to
// the German master: same order, same options, same correct answers.
//
// The aim of the questions: scenarios from the two accompanied days.
// Several options deliberately sound plausible — in each case it comes
// down to one detail. The `explanation` always explains both: why the
// correct answer is correct and why the obvious mistake is wrong.
//
// Multi-client capable: nowhere are company-specific figures (stop
// counts, waiting area times, parking side) asked for — only what
// applies everywhere. Exceptions with a legal basis: § 4 ArbZG (breaks)
// and § 1 Abs. 6 FPersV (Green Book).

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> rideAlongQuestionsEn = [
  // ══════════════════════════ ra1 — What the Ride Along is
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'What is the Ride Along?',
    options: [
      'A theoretical briefing in the office before the first working day',
      'Two working days of accompanied driving with an experienced '
          'driver as trainer',
      'An official driving test without which you may not be deployed',
    ],
    correctIndex: 1,
    explanation: 'The Ride Along is two real working days in the company '
        'on which an experienced driver accompanies you, explains '
        'everything and then lets you do it yourself. It is neither an '
        'office course nor an official examination — it is induction in '
        'live operation, but it is assessed and documented.',
  ),
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'How many stops do you have to drive on the two days?',
    options: [
      'That is set by your company or your station — the trainer tells '
          'you the requirement',
      'Always exactly 20 on the first and 70 on the second day, the same '
          'in every company',
      'As many as you feel up to — there is no requirement',
    ],
    correctIndex: 0,
    explanation: 'A smaller number on the first day and considerably more '
        'on the second is common (often around 20 and around 70), but '
        'those are guide values from individual companies. The only '
        'binding figure is the one set by your station. The obvious '
        'mistake is to take a number you have heard for a general rule — '
        'ask your trainer for the figure that applies to you.',
  ),
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'On the first day you are much slower than planned and make '
        'several mistakes while sorting. How does that affect the '
        'assessment?',
    options: [
      'The Ride Along counts as failed and has to be repeated',
      'It makes no difference, because nothing at all is assessed on the '
          'first day',
      'What matters is whether you ask and then stop making the mistake '
          '— not your speed',
    ],
    correctIndex: 2,
    explanation: 'Nobody expects speed on the first day; that is exactly '
        'what the smaller number of stops is for. What is assessed is '
        'your willingness to learn: do you ask, do you take advice on '
        'board, are you still making the same mistake the third time '
        'round? The mistake is dangerous in both directions — it is '
        'neither a pass-or-fail exam nor a day without assessment.',
  ),

  // ══════════════════════════ ra2 — The first day
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Why do the stops during the Ride Along have to run on your '
        'own account?',
    options: [
      'Because the trainer is not allowed to use his account on those '
          'days',
      'Because that is the only way to see what your own delivery work '
          'looks like — it counts under your name',
      'Because the trainer\'s account cannot take any more new stops',
    ],
    correctIndex: 1,
    explanation: 'Everything you deliver on those days runs under your '
        'name — exactly as it will later in day-to-day work. That is the '
        'only way the trainer and the company see how you actually work, '
        'and the only way the stops count towards your induction. That '
        'is why a login that does not work in the morning is not a '
        'detail but a reason to say so immediately.',
  ),
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'What applies to Mentor\'s recording time?',
    options: [
      'Mentor records around 4 hours in one go and has to be restarted '
          'afterwards',
      'Once started, Mentor runs through to the end of the shift',
      'Mentor starts itself as soon as the vehicle moves',
    ],
    correctIndex: 0,
    explanation: 'The recording runs for around four hours at a time. '
        'After that you have to restart it, otherwise the rest of the '
        'route goes unrecorded. The most common beginner\'s mistake is '
        'exactly that misconception, that the app keeps running by '
        'itself: started correctly in the morning, not reactivated after '
        'the break — and half the day is missing from the evaluation.',
  ),
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'You work 9.5 hours on this day. How long does your break '
        'have to be as a minimum?',
    options: [
      '30 minutes, because 45 minutes only apply from 10 hours',
      'It is enough to take several short breaks of 5 to 10 minutes each',
      '45 minutes, because the working time is over 9 hours',
    ],
    correctIndex: 2,
    explanation: 'Under § 4 ArbZG (the German Working Hours Act) at least '
        '30 minutes are required for more than 6 hours and at least 45 '
        'minutes for more than 9 hours — 9.5 hours is over the '
        'threshold. The break may be split, but each part must last at '
        'least 15 minutes; five minutes here and there do not count.',
  ),

  // ══════════════════════════ ra3 — The second day
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'A customer with a password parcel does not have the code to '
        'hand but is willing to sign. What do you do?',
    options: [
      'You do not hand it over — without the correct code there is no '
          'exception',
      'You hand it over against a signature, because that is proof just '
          'the same',
      'You leave the parcel with the neighbour and inform the customer',
    ],
    correctIndex: 0,
    explanation: 'The password is the proof that the recipient really is '
        'the recipient — that is what it was issued for. A signature or '
        'friendly persuasion do not replace it, and leaving it with a '
        'neighbour certainly does not. If the consignment is later '
        'reported as not received, the hand-over without a code stands '
        'as your mistake. The right way: let the customer look for the '
        'code, otherwise return the parcel correctly and document it.',
  ),
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'While manoeuvring you clip a bollard. There is a scratch on '
        'the van and nobody saw it. What is the right thing to do?',
    options: [
      'Do nothing — with a scratch and no third-party damage there is '
          'nothing to report',
      'Wait and see whether it is even noticed at the next inspection',
      'Report it the same day and document it in CoDriver',
    ],
    correctIndex: 2,
    explanation: 'Reported damage is an incident that gets processed; the '
        'same damage found the next morning by somebody else during '
        'their inspection is unexplained damage — and suspicion ends up '
        'falling on the last user anyway. The idea that "nobody will '
        'notice" does not hold: that is exactly what the inspection '
        'before and after every route is there for.',
  ),
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'What is the difference between performance and quality in '
        'the Scorecard?',
    options: [
      'They mean the same thing — the Scorecard only measures the number '
          'of stops',
      'Performance is the volume in the time available, quality is how '
          'cleanly each individual stop was completed',
      'Quality only concerns the vehicle, performance only the delivery',
    ],
    correctIndex: 1,
    explanation: 'Performance is the volume — how many stops in how much '
        'time. Quality is the care taken at each individual stop: right '
        'place, correct documentation, no complaint. Treat the two as '
        'the same and you save a minute up front and create an '
        'investigation at the back that costs the company many times '
        'over.',
  ),

  // ══════════════════════════ ra4 — Closing and handing in
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'How often does the trainer sign the Ride Along checklist?',
    options: [
      'Once at the end of the second day for both days together',
      'Not at all — only the dispatcher signs when it is handed in',
      'Separately for each day, each time with the date',
    ],
    correctIndex: 2,
    explanation: 'Each day has its own list of points and is therefore '
        'closed individually with a date and a signature. There is a '
        'practical reason for that: if the second day is cancelled or '
        'postponed, what was completed on the first day is still cleanly '
        'documented. A single collective signature at the end would make '
        'exactly that impossible.',
  ),
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'What happens to the completed checklist at the end of the '
        'second day?',
    options: [
      'It is handed in as a photo to the responsible dispatcher',
      'You take it home with you and keep it privately',
      'It stays in the vehicle so that the next trainer can continue it',
    ],
    correctIndex: 0,
    explanation: 'At the end of the second day the sheet is photographed '
        'and handed in to the responsible dispatcher — that formally '
        'concludes the Ride Along and documents your induction. Left in '
        'the vehicle or privately at home, the proof is worthless to the '
        'company. Make sure the ticks, the date, the names and the '
        'signatures are legible in the photo.',
  ),
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'The feedback says you are too hesitant when manoeuvring. '
        'What is the most sensible reaction?',
    options: [
      'Explain that you were deliberately being careful and close the '
          'subject there',
      'Ask for a specific example from the day',
      'Note the feedback and manoeuvre faster next time',
    ],
    correctIndex: 1,
    explanation: 'Being careful when manoeuvring is right — "hesitant" '
        'usually means something else, such as thinking about it for a '
        'long time instead of briefly getting out and looking. With a '
        'specific example you have a point you can work on. Justifying '
        'yourself gets you nowhere, and simply manoeuvring faster would '
        'be the most dangerous of the three reactions.',
  ),

  // ══════════════════════════ ra5 — How to prepare
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'When should you check that your logins for time tracking, '
        'Mentor, Flex and CoDriver work?',
    options: [
      'On the morning of the first day together with the trainer',
      'Only once a problem actually comes up while working',
      'Before the first day, ideally the evening before',
    ],
    correctIndex: 2,
    explanation: 'Resetting a password takes minutes the evening before '
        'and half an hour in the morning in the Waiting Area — if anyone '
        'can be reached at all. The obvious mistake is to leave it to '
        'the trainer: he cannot help you with a blocked login, and the '
        'time is then missing from the stops on your own account.',
  ),
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'What does "punctual" mean during the Ride Along?',
    options: [
      'Ready to work at the station at the start of the shift — parking '
          'and the walk are already factored in',
      'Arriving at the station gate at the start of the shift',
      'Being there at the latest when the Waiting Area is called',
    ],
    correctIndex: 0,
    explanation: 'At the start of the shift you are ready to work, not on '
        'your way. Anyone who only arrives at the gate loses time '
        'parking and walking across the yard and misses their Waiting '
        'Area slot — and thereby pushes the trainer\'s wave back as '
        'well. So plan the time for parking and walking deliberately.',
  ),
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Why is it worth writing down your questions for the trainer '
        'before day 1?',
    options: [
      'Because the trainer has to have the questions submitted in '
          'writing beforehand',
      'Because nobody retains ten procedures explained one after another '
          '— written down, you can ask specifically',
      'Because questions left unasked are otherwise noted negatively in '
          'the assessment',
    ],
    correctIndex: 1,
    explanation: 'Over two days the trainer explains a great deal at once; '
        'by the evening little of it remains without notes. Anyone who '
        'prepares their questions and jots down two keywords per topic '
        'along the way gets many times more out of the two days. It is '
        'not a formal obligation — and nobody notes unasked questions '
        'negatively. That is exactly why you have to see to it '
        'yourself.',
  ),
];
