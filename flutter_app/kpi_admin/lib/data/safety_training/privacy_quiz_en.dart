// lib/data/safety_training/privacy_quiz_en.dart
//
// Questions of the privacy training final test — English version.
// Eighteen questions spread evenly over the six chapters from
// privacy_content_en.dart (three questions per chapter ds1 … ds6). The
// structure is identical to the German master (privacy_quiz_de.dart):
// same order, same options, same correct answers. Keep both in sync.
//
// The aim of the questions: scenarios from everyday delivery work and
// questions about legal consequences. Several options deliberately
// sound plausible — in each case it comes down to one detail. The
// `explanation` always explains both: why the correct answer is correct
// and why the obvious mistake is wrong.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> privacyQuestionsEn = [
  // ══════════════════════════ ds1 — Why data protection concerns you
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Which of the following is NOT personal data within the '
        'meaning of the GDPR?',
    options: [
      'The total number of parcels delivered on the route today',
      'The note "please leave the parcel behind the bin" together with '
          'the corresponding address',
      'The delivery photo taken at a recipient\'s front door',
    ],
    correctIndex: 0,
    explanation: 'A plain count with no link to a person is not personal '
        'data. The drop-off note, however, says something about the '
        'living situation of a specific person, and the delivery photo '
        'is linked to an address. The obvious mistake is to think only '
        'names are personal data — personal data is any information '
        'that can identify a person.',
  ),
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'In the evening you tell your friends which street a '
        'well-known athlete lives in, after delivering a parcel to him. '
        'How should this be assessed?',
    options: [
      'Unproblematic, as long as you do not post the name online',
      'A violation of purpose limitation and confidentiality under '
          'Art. 5 GDPR',
      'Unproblematic, because an address is publicly known anyway',
    ],
    correctIndex: 1,
    explanation: 'You only know the address from your work. Passing it '
        'on to third parties is a disclosure for the wrong purpose and '
        'violates Art. 5(1)(b) and (f) GDPR. The obvious mistake is to '
        'think a small private circle does not count — the GDPR does '
        'not ask about the size of the audience.',
  ),
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Which provisions require the company to train you in data '
        'protection?',
    options: [
      '§ 12(1) of the German Occupational Safety Act — data protection '
          'is part of the annual safety briefing',
      'An explicit training obligation in Art. 30 GDPR',
      'Indirectly, Art. 32, Art. 39(1)(b) and Art. 5(2) GDPR',
    ],
    correctIndex: 2,
    explanation: 'The GDPR contains no explicit training obligation. It '
        'follows indirectly: Art. 32 requires organisational measures, '
        'Art. 39(1)(b) names awareness-raising and training as a task '
        'of the data protection officer, and Art. 5(2) requires proof '
        'of compliance. Art. 30, by contrast, concerns the record of '
        'processing activities, and the Occupational Safety Act covers '
        'workplace safety, not data protection.',
  ),

  // ══════════════════════════ ds2 — Photos and proof of delivery
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'What may be visible on a delivery photo?',
    options: [
      'The recipient, if they verbally agreed to the picture',
      'The parcel at the drop-off spot, plus the door or house number '
          'for location context',
      'The parcel and the licence plate of the vehicle parked in front, '
          'for easier matching',
    ],
    correctIndex: 1,
    explanation: 'The photo answers exactly one question: where is the '
        'parcel? Anything beyond that violates data minimisation under '
        'Art. 5(1)(c) GDPR. People do not belong on the proof even with '
        'verbal consent, and a licence plate is personal data that is '
        'not necessary for the purpose.',
  ),
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'The scanner is acting up. You photograph the drop-off '
        'with your normal phone camera and then upload the picture into '
        'the work app. What is wrong with that?',
    options: [
      'Nothing — all that matters is that the picture ends up in the '
          'app',
      'Only the image quality; legally it is fine',
      'The picture then stays permanently in your private gallery, '
          'often also in a private cloud',
    ],
    correctIndex: 2,
    explanation: 'The upload does not remove the copy: the original '
        'stays in your private gallery and is often backed up '
        'automatically to a cloud. That puts personal data outside the '
        'company\'s control. The obvious mistake is to think only the '
        'end state counts — what matters is every copy created along '
        'the way.',
  ),
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'After completing the stop, you notice that a neighbour is '
        'recognisable on the uploaded photo. What do you do?',
    options: [
      'Inform the dispatcher or operations management so the picture '
          'can be deleted from the system',
      'Nothing — the stop is completed, the picture cannot be changed '
          'any more anyway',
      'Ring the neighbour\'s doorbell the next day and ask for '
          'permission',
    ],
    correctIndex: 0,
    explanation: 'Only if the company knows about it can it delete the '
        'picture and document the incident. The obvious mistake is to '
        'think that reporting is no longer worth it once the stop is '
        'completed. Consent after the fact does not cure the violation '
        'and is not a solid legal basis in an employment context '
        'anyway.',
  ),

  // ══════════════════════════ ds3 — Handling recipient data
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'You take a screenshot of the address list to remember the '
        'order of stops more easily. Nobody else gets to see it. Is that '
        'allowed?',
    options: [
      'Yes, as long as you delete the screenshot at the end of the '
          'route',
      'Yes, because you are allowed to process the data for work anyway',
      'No — a screenshot is a copy outside the system and therefore not '
          'allowed',
    ],
    correctIndex: 2,
    explanation: 'The screenshot creates a copy of personal data that '
        'the company can no longer control. Being allowed to see the '
        'data for work does not allow you to store it outside the '
        'system. The intention to delete it later changes nothing about '
        'the unlawful processing either.',
  ),
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'A neighbour accepts a parcel and asks what is inside and '
        'whether the recipient even still lives there. What do you say?',
    options: [
      'Only the recipient\'s name and house number — no information '
          'about the contents or anything else',
      'Everything on the label, since he is accepting the parcel after '
          'all',
      'Nothing, not even the recipient\'s name',
    ],
    correctIndex: 0,
    explanation: 'For handing a parcel to a neighbour, the name and '
        'house number are necessary — without them the neighbour cannot '
        'pass the parcel on. Anything beyond that, especially the '
        'contents or confirming who lives where, is a disclosure '
        'without a legal basis under Art. 6 GDPR. Saying nothing at '
        'all, on the other hand, would be impractical and make the '
        'handover impossible.',
  ),
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'The route is finished and the paper route list is no '
        'longer needed. How do you dispose of it correctly?',
    options: [
      'In the paper bin at your own house, once you get home',
      'Via the designated route at the depot — data protection bin or '
          'shredder',
      'Torn up in the general waste bin at the petrol station, so '
          'nobody can read it any more',
    ],
    correctIndex: 1,
    explanation: 'The list contains names and addresses; it must be '
        'disposed of so that it cannot be recovered — at the depot via '
        'the data protection bin or shredder. The obvious mistake is to '
        'think a finished list is worthless. Publicly accessible bins '
        'are out of the question, and you should never have taken the '
        'list home in the first place.',
  ),

  // ══════════════════════════ ds4 — Your own and colleagues' data
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'A colleague asks you for a screenshot of an internal '
        'evaluation that lists all drivers with names and numbers. He '
        'only wants to see his own row. How do you respond?',
    options: [
      'Decline and refer him to operations management — he is only '
          'entitled to his own data',
      'Send it, because he is on the list himself and therefore '
          'entitled to access it',
      'Send it, but black out the other names first and delete the '
          'screenshot afterwards',
    ],
    correctIndex: 0,
    explanation: 'With the screenshot he would receive the performance '
        'data of all colleagues — a disclosure of employee data without '
        'a legal basis. His right of access under Art. 15 GDPR covers '
        'his own data only. A home-made redaction changes nothing about '
        'the fact that you created an unlawful copy.',
  ),
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Why are colleagues\' sick notes particularly protected?',
    options: [
      'Because the employment contract explicitly labels them as '
          'confidential',
      'Because they are trade secrets under the GeschGehG (German Trade '
          'Secrets Act)',
      'Because health data is a special category of personal data under '
          'Art. 9 GDPR',
    ],
    correctIndex: 2,
    explanation: 'Health data falls under Art. 9 GDPR and is subject to '
        'stricter protection than ordinary data. The mere fact of being '
        'ill is already such data, the reason even more so. Trade '
        'secrets, by contrast, concern company knowledge, not '
        'employees\' health data.',
  ),
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'You want to know what data your employer has stored about '
        'you. Which right do you use for that?',
    options: [
      'The right to data portability under Art. 20 GDPR',
      'The right of access under Art. 15 GDPR',
      'The right to object under Art. 21 GDPR',
    ],
    correctIndex: 1,
    explanation: 'Art. 15 GDPR entitles you to an overview of the data '
        'stored about you and the purposes. Art. 20 concerns receiving '
        'your data in a portable format, Art. 21 objecting to a '
        'processing operation — neither answers the question of what is '
        'stored in the first place. As a rule, the request must be '
        'answered within one month.',
  ),

  // ══════════════════════════ ds5 — Data breach
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Which of these incidents is NOT a data breach?',
    options: [
      'You delivered a parcel to the wrong recipient, who opened it',
      'You miscounted the number of returns in the daily report',
      'You left the route list lying open in the unlocked vehicle',
    ],
    correctIndex: 1,
    explanation: 'A counting error in the returns involves no personal '
        'data and makes none accessible to anyone. In the other two '
        'cases, unauthorised people could see names, addresses or '
        'shipment contents — that is a breach of the protection of '
        'personal data.',
  ),
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'What does the 72-hour deadline of Art. 33 GDPR say?',
    options: [
      'The company must notify the supervisory authority of a data '
          'breach, where feasible within 72 hours of becoming aware of '
          'it',
      'The driver has 72 hours to report the incident to the company',
      'Affected people must complain to the company within 72 hours or '
          'lose their claim',
    ],
    correctIndex: 0,
    explanation: 'The deadline binds the company towards the '
        'supervisory authority and runs from the moment of becoming '
        'aware. That is exactly why you must report immediately — every '
        'hour you wait is an hour the company loses. The obvious '
        'mistake is to read the 72 hours as the driver\'s own time '
        'window.',
  ),
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'In the evening you realised that a parcel ended up with '
        'the wrong recipient and was opened there. What is the right '
        'thing to do?',
    options: [
      'Quietly collect it tomorrow morning and deliver it correctly — '
          'then the mistake is fixed',
      'Only mention it at the next team meeting, since nothing can be '
          'changed any more anyway',
      'Inform the dispatcher or operations management the same day and '
          'take no action on your own',
    ],
    correctIndex: 2,
    explanation: 'A data breach has already occurred: a stranger has '
        'learned the name, address and contents of the shipment. The '
        'company must assess, document and, if necessary, notify under '
        'Art. 33 GDPR — for that it needs the information immediately. '
        'The quiet correction looks harmless but prevents exactly these '
        'steps. Whoever reports immediately is doing the right thing.',
  ),

  // ══════════════════════════ ds6 — Confidentiality and loyalty
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'Which statement is NOT covered by freedom of expression?',
    options: [
      'Saying that a route regularly cannot be completed in the planned '
          'time',
      'Pointing out that a vehicle has not been repaired despite '
          'repeated reports',
      'The knowingly false claim that the company systematically cheats '
          'its drivers out of their hours',
    ],
    correctIndex: 2,
    explanation: 'Expressions of opinion and truthful criticism are '
        'protected by Art. 5(1) of the German Basic Law (GG), even when '
        'they are uncomfortable. Knowingly false statements of fact are '
        'not: they can justify summary dismissal under § 626 BGB and, '
        'in the case of defamation, additionally be a criminal offence '
        'under § 186 StGB.',
  ),
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'You report a problem in the company to the best of your '
        'knowledge. In the end, your suspicion turns out to be '
        'unfounded. What applies?',
    options: [
      'The protection lapses retroactively because the report was wrong',
      'You remain protected from reprisals by the German Whistleblower '
          'Protection Act',
      'The protection only applies if you additionally filed the report '
          'externally',
    ],
    correctIndex: 1,
    explanation: 'The HinSchG (in force since 2 July 2023) protects '
        'employees who report violations from reprisals such as '
        'dismissal, written warnings or disadvantage. Protection is '
        'lost only for knowingly or grossly negligently false reports — '
        'not for a serious suspicion that is not confirmed in the end. '
        'An external report is not required for that.',
  ),
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'The driver chat group is discussing alleged wage cuts. '
        'You are dissatisfied yourself. What is the right way to '
        'proceed?',
    options: [
      'State your own concrete case and take it to the dispatcher, '
          'operations management or the internal reporting channel',
      'Confirm the claim in the group so your colleagues are warned',
      'Post the accusation publicly on a review portal so that '
          'something finally happens',
    ],
    correctIndex: 0,
    explanation: 'Your own verifiable case is true, factual and '
        'protected by the HinSchG — and solved fastest internally. '
        'Confirming a claim you have not experienced yourself is a '
        'false statement of fact; a closed chat group is no protected '
        'space once a screenshot goes around. Going external only comes '
        'into play if nothing happens internally.',
  ),
];
