// lib/data/safety_training/green_book_quiz_en.dart
//
// Questions of the Green Book final test (the driver’s record book under
// § 1 Abs. 6 FPersV) — English version. The structure is identical to the
// German master: the same number of questions, the same order, the same
// correct answers.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> greenBookQuestionsEn = [
  // ══════════════════════════ gb1 — What the Green Book is
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'What do you document in the Green Book?',
    options: [
      'The condition of the vehicle before setting off',
      'The number of parcels delivered and returns collected',
      'Driving times, breaks in driving as well as working and rest '
          'periods',
    ],
    correctIndex: 2,
    explanation: 'The Green Book is the driver’s record book — the '
        'collection of daily control sheets under § 1 Abs. 6 FPersV. It '
        'proves times and nothing else. The condition of the vehicle is '
        'documented elsewhere and expressly does not belong here.',
  ),
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Which vehicles does the recording duty under § 1 Abs. 6 '
        'FPersV apply to?',
    options: [
      'Over 2,8 t up to 3,5 t maximum permissible mass in commercial '
          'carriage of goods',
      'Every vehicle used to transport parcels commercially',
      'Only from 3,5 t maximum permissible mass upwards',
    ],
    correctIndex: 0,
    explanation: 'The duty applies in the range over 2,8 t up to 3,5 t — '
        'exactly the typical delivery van. Below 2,8 t there is no such '
        'duty, and from 3,5 t the digital tachograph takes over the '
        'recording.',
  ),
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'According to its registration document your van has a '
        'maximum permissible mass of 3,5 t, but today it is loaded with '
        'only 900 kg. What applies?',
    options: [
      'No recording duty — the actual weight is below 2,8 t',
      'The recording duty still applies',
      'The duty only applies from a daily distance of 100 kilometres',
    ],
    correctIndex: 1,
    explanation: 'What counts is the maximum permissible mass from the '
        'registration document, not today’s load. The obvious mistake is '
        'to work it out afresh each day from the load — that does not '
        'change how the vehicle is classified.',
  ),

  // ══════════════════════════ gb2 — What exactly gets entered
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Which entry is NOT one of the compulsory entries on the '
        'daily control sheet?',
    options: [
      'Odometer reading at the start and at the end of the journey',
      'Number of consignments delivered',
      'Place where the journey started and where it ended',
    ],
    correctIndex: 1,
    explanation: 'Prescribed are, among others, the surname, first name '
        'and address of the driver, the registration number, the date, the '
        'odometer readings, the places, the times and the signature. Piece '
        'counts are a company metric and do not belong on the sheet.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'What do you fill the daily control sheet in with?',
    options: [
      'With a ballpoint pen, in permanent ink',
      'With a pencil, so that mistakes can be corrected cleanly',
      'The pen does not matter as long as it can be read',
    ],
    correctIndex: 0,
    explanation: 'An entry that can be rubbed out is not proof. That is '
        'exactly why a pencil is not allowed — even if the correction is '
        'well meant. A mistake is crossed out once and rewritten next to '
        'it.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'All times and odometer readings are entered, only the '
        'signature is missing. What applies to this sheet?',
    options: [
      'It is valid — the signature is a pure formality',
      'It counts as incomplete and does not satisfy the recording duty',
      'The dispatcher can countersign it afterwards at the company',
    ],
    correctIndex: 1,
    explanation: 'The signature is one of the prescribed entries — with it '
        'you confirm the content. Without it the sheet is incomplete, with '
        'the same consequences as a missing sheet. Somebody else’s '
        'signature does not replace yours.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'You wait 40 minutes at the ramp. You do nothing, but you '
        'have to be ready at any moment because it could carry on at '
        'once. How do you enter this time?',
    options: [
      'As a break in driving — after all, you did not work',
      'As the start of the daily rest period',
      'As working time',
    ],
    correctIndex: 2,
    explanation: 'A break in driving is only a rest break if you can '
        'dispose of the time freely and know that in advance. Standing by '
        'is waiting time and therefore working time. The obvious mistake '
        'is ‘I did nothing, so it was a break’ — what matters is not the '
        'activity but the availability.',
  ),

  // ══════════════════════════ gb3 — Driving times, breaks, rest
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'How long may you drive at most on a normal day?',
    options: [
      '9 hours',
      '10 hours',
      '8 hours, and after that only with the dispatcher’s approval',
    ],
    correctIndex: 0,
    explanation: 'The daily driving time is at most 9 hours. The 10 hours '
        'are not a second standard limit but a narrowly limited exception '
        '— and approval from the company plays no part at all in where the '
        'limit lies.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'How often may you extend the driving time to 10 hours?',
    options: [
      'Once a week',
      'Twice a week',
      'On every day on which the tour requires it',
    ],
    correctIndex: 1,
    explanation: 'Twice a week the daily driving time may be extended to '
        '10 hours. It is a weekly quota, not a daily right — and the size '
        'of the tour does not extend it.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'You want to split the 45-minute break in driving. Which '
        'split is permitted?',
    options: [
      'First 30 minutes, then 15 minutes',
      'Three times 15 minutes spread over the day',
      'First 15 minutes, then 30 minutes',
    ],
    correctIndex: 2,
    explanation: 'The split is only permitted in two parts and only in '
        'this order: first at least 15, then at least 30 minutes. The '
        'reverse order does not count, and neither do three short parts — '
        'even if the total adds up.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'You start at 07:00. By 09:30 you have spent 2 hours at the '
        'wheel, by 12:00 another 2 hours of driving time are added, and by '
        '13:00 a further 30 minutes. When is the break in driving due at '
        'the latest?',
    options: [
      'At 11:30, that is 4,5 hours after the start of duty',
      'At 12:00, because lunchtime is meant for it',
      'At 13:00',
    ],
    correctIndex: 2,
    explanation: '2 + 2 + 0,5 hours make exactly 4,5 hours of pure driving '
        'time at 13:00 — now you may not drive another metre before the '
        'break is done. The obvious mistake is to count from the start of '
        'duty: the clock only runs while the vehicle is moving.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'You end your driving time at 17:15. When may you start '
        'again at the earliest?',
    options: [
      'At 02:15 — 9 hours of rest are enough',
      'At 04:15',
      'As soon as you feel rested, there is no fixed limit',
    ],
    correctIndex: 1,
    explanation: 'The daily rest period is at least 11 hours, so 04:15 at '
        'the earliest. The 9 hours are the limit for driving time, not for '
        'the rest period — the two numbers are regularly mixed up.',
  ),

  // ══════════════════════════ gb4 — Typical mistakes
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'A colleague fills in the whole week’s sheets on Friday '
        'evening. The times are correct in substance. How is that to be '
        'judged?',
    options: [
      'It is a breach and it shows up at a check',
      'Unproblematic, as long as the times entered are true',
      'A matter of tidiness only, with no legal significance',
    ],
    correctIndex: 0,
    explanation: 'Recording means recording promptly. Sheets written up '
        'afterwards are recognised by identical handwriting, strikingly '
        'round times and odometer readings that do not fit the route. The '
        'times being correct does not cure the breach of the recording '
        'duty.',
  ),
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'On Thursday you notice that Tuesday’s lunch break was not '
        'entered. You are certain about the clock times. What do you do?',
    options: [
      'Enter it as a late entry with the date of the addition and inform '
          'the dispatcher',
      'Slip the entry in so that it looks as if it was written on Tuesday',
      'Leave the gap — a late entry only makes it worse',
    ],
    correctIndex: 0,
    explanation: 'An honest, recognisably dated correction is permitted '
        'and better than a gap. Shaping the entry as though it had been '
        'made on Tuesday is the step from carelessness to deception — and '
        'weighs considerably more heavily.',
  ),
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Today you drove 9,5 hours although your weekly quota for 10 '
        'hours was already used up. What do you enter?',
    options: [
      'Exactly 9,0 hours — so that the sheet looks compliant',
      'The 9,5 hours you actually drove',
      'Nothing at all for that day, then it will not be noticed',
    ],
    correctIndex: 1,
    explanation: 'You always enter the actual times. A polished entry '
        'turns an overrun into a false statement and makes things worse. A '
        'missing sheet is a breach in its own right as well — leaving it '
        'out does not help.',
  ),

  // ══════════════════════════ gb5 — Carrying, handing in, keeping
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Which records do you have to carry in the vehicle?',
    options: [
      'Only the sheet for the current day',
      'The sheets for the current calendar week',
      'The current day and the preceding 28 days',
    ],
    correctIndex: 2,
    explanation: 'You have to carry the records of the last 28 days '
        'including the current day. The fact that older sheets are filed '
        'properly at the company satisfies the duty to keep them, but not '
        'the duty to carry them — those are two separate duties.',
  ),
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'How long does the operator have to keep the daily control '
        'sheets at the company?',
    options: [
      'One year',
      '28 days, after that they may be destroyed',
      'Three months from the end of the quarter',
    ],
    correctIndex: 0,
    explanation: 'The operator keeps the records for a year and produces '
        'them on request. The 28 days are the period for the driver to '
        'carry them — it is frequently confused with the period for '
        'keeping them.',
  ),
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Who checks compliance with the recording duty?',
    options: [
      'Only the police, and only at roadside checks',
      'The BAG and the police — at roadside checks and at the company',
      'The TÜV as part of the vehicle’s main inspection',
    ],
    correctIndex: 1,
    explanation: 'Checks are carried out by the BAG (Bundesamt für '
        'Logistik und Mobilität, the German federal office for logistics '
        'and mobility) and the police, both at the roadside and at the '
        'company. The main inspection concerns the technical condition of '
        'the vehicle and has nothing to do with the records.',
  ),

  // ══════════════════════════ gb6 — Consequences
  DrivingQuestion(
    moduleId: 'gb6',
    question: 'What can you expect if sheets are missing or incomplete?',
    options: [
      'A fine from 100 euros, and higher depending on the severity',
      'No consequence at all — it is a purely internal company rule',
      'A free caution with no further consequences',
    ],
    correctIndex: 0,
    explanation: 'Missing or incomplete records are a regulatory offence; '
        'the fine starts at around 100 euros and rises with the severity. '
        'For serious or repeated breaches, proceedings about the '
        'reliability of the company may also be opened.',
  ),
  DrivingQuestion(
    moduleId: 'gb6',
    question: 'The dispatcher says: ‘Do the two stops, you can just write '
        'the break in.’ How do you react?',
    options: [
      'Follow the instruction — the dispatcher then carries the '
          'responsibility',
      'Skip the break, but at least enter honestly that it is missing',
      'Take the break, enter it correctly and report the open stops',
    ],
    correctIndex: 2,
    explanation: 'A verbal instruction does not cancel your recording duty '
        '— you sign the sheet and thereby confirm its content. '
        'Deliberately dropping the break would also breach the driving '
        'time rules. The company has to make compliance possible, not get '
        'around it.',
  ),
];
