// lib/data/safety_training/privacy_content_en.dart
//
// Content of the privacy (GDPR) training — English version.
// The structure is identical to the German master
// (privacy_content_de.dart): chapters ds1–ds6, the same slides, the same
// blocks and the same values. Keep both files in sync.
//
// Legal background: the GDPR contains no explicit "training obligation",
// but requires it indirectly — Art. 32 GDPR (organisational measures for
// the security of processing), Art. 39(1)(b) GDPR (awareness-raising and
// training by the data protection officer) and Art. 5(2) GDPR
// (accountability). Supervisory authorities regularly treat missing
// staff training as evidence of insufficient measures, especially after
// a data breach. Best practice is an annual basic training plus
// event-driven refreshers and the induction of new employees. The
// documentation of the training — test and signature — serves as proof
// under Art. 5(2) GDPR.
//
// Structure as in the Green Book: several slides per chapter built from
// typed blocks — legal notes (CalloutTone.law), case studies to think
// about (Reveal), Do/Don't and a checklist at the end of each chapter.
// There are no illustrations for this topic, hence `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> privacyContentEn = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ds1',
    title: 'Why data protection concerns you',
    summary: 'Personal data in everyday delivery work and the principles '
        'of Art. 5 GDPR',
    asset: '',
    slides: [
      SafetySlide(
        title: 'You work with other people\'s data all day',
        blocks: [
          ParagraphBlock(
            'Data protection sounds like offices, filing cabinets and '
            'lawyers. In reality, hardly anyone is as close to personal '
            'data as you are. From the first scan in the morning to the '
            'last stop in the evening, you are handling other people\'s '
            'names, addresses and phone numbers — plus photos of other '
            'people\'s front doors.',
          ),
          ParagraphBlock(
            'Personal data is any information that can identify a person. '
            'Not just the name: the combination of address, time and '
            'parcel contents also says something about a person. That is '
            'exactly why there are rules for it.',
          ),
          BulletsBlock([
            'Recipient names and addresses on labels, scanner and list',
            'Phone numbers for contacting customers before delivery',
            'Signatures on the scanner as proof of receipt',
            'Photos as proof of delivery at the door',
            'Location data from the scanner and the vehicle',
            'Details of neighbours you have left a parcel with',
            'Notes like "please leave the parcel behind the bin" — that '
                'too is information about someone\'s living situation',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'In short',
            text: 'Everything you learn about a recipient, you only '
                'learned because you deliver the parcel. For anything '
                'else, you were never given that information.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Three principles that matter every day',
        blocks: [
          ParagraphBlock(
            'Art. 5 GDPR sets out six principles. Three of them decide '
            'practically every day whether you are acting correctly or '
            'not. In plain language:',
          ),
          TableBlock(
            headers: ['Principle', 'What it means for you'],
            rows: [
              [
                'Purpose limitation',
                'Use data only for the purpose you were given it for: the '
                    'delivery. Not for anything private.',
              ],
              [
                'Data minimisation',
                'Collect and show only as much as necessary. No photo '
                    'showing more than needed, no list longer than needed.',
              ],
              [
                'Confidentiality',
                'What you see stays with you and within the company. Not '
                    'in the chat group, not at the kitchen table, not '
                    'online.',
              ],
            ],
          ),
          ParagraphBlock(
            'On top of that come accuracy (correct wrong details instead '
            'of carrying them along), storage limitation (keep nothing '
            'longer than necessary) and accountability — that last one '
            'concerns the company and is the reason for this training.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'The legal basis',
            text: 'Art. 5(1) GDPR requires, among other things, purpose '
                'limitation (point b), data minimisation (point c) and '
                'integrity and confidentiality (point f). These '
                'principles apply to everyone who handles personal data '
                'on behalf of the company — including you on your route.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Why this training exists',
        blocks: [
          ParagraphBlock(
            'Nowhere does the GDPR literally say "employees must be '
            'trained". It requires it anyway — just via three other '
            'routes. That is why you are sitting here, and why your '
            'completion is documented.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Where the training obligation comes from',
            text: 'Art. 32 GDPR obliges the company to take technical '
                'and organisational measures for the security of '
                'processing — trained employees are such a measure. '
                'Art. 39(1)(b) GDPR explicitly names awareness-raising '
                'and training as a task of the data protection officer. '
                'And Art. 5(2) GDPR requires the company to be able to '
                'demonstrate compliance — accountability.',
          ),
          ParagraphBlock(
            'Supervisory authorities look at this closely during an '
            'audit. They regularly treat missing staff training as '
            'evidence that the measures were insufficient — especially '
            'once something has already happened. After a data breach, '
            'the first question is almost always: were the staff '
            'trained, and can you prove it?',
          ),
          BulletsBlock([
            'Annual basic training for everyone — your completion is '
                'valid for twelve months',
            'Event-driven training when something changes or something '
                'has happened',
            'Induction of new employees before their first solo day',
            'Documentation of test and signature as proof under '
                'Art. 5(2) GDPR',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Where the line runs in everyday work',
        blocks: [
          RevealBlock(
            prompt: 'Case study: On your route there is a parcel for a '
                'well-known local footballer. In the evening you tell '
                'your friends which street he lives in — nothing more, no '
                'name on social media, just among friends. Is that a data '
                'protection violation?',
            answer: 'Yes. The address is personal data, and you only '
                'know it from your work. Passing it on to third parties '
                'violates purpose limitation (Art. 5(1)(b) GDPR) and '
                'confidentiality (point f). The obvious mistake is to '
                'think a private circle "doesn\'t count" — the GDPR does '
                'not ask how big your audience was, but whether you '
                'disclosed the data for a purpose other than the one it '
                'was given to you for. And if one of your friends passes '
                'it on, you have no control at all any more.',
          ),
          DoDontBlock(
            doTitle: 'Right',
            dos: [
              'Use recipient data only for the delivery and leave it in '
                  'the system afterwards',
              'Refer queries about a shipment to the dispatcher or '
                  'operations management',
              'Hold the scanner and paper list so that others cannot '
                  'read along',
              'Raise unclear situations instead of deciding on your own',
            ],
            dontTitle: 'Wrong',
            donts: [
              'Sharing addresses or names in your private circle — not '
                  'even "just among friends"',
              'Making celebrities or unusual shipments a topic of '
                  'conversation',
              'Looking up recipient data out of curiosity without a work '
                  'reason to do so',
              'Relying on the idea that "nobody will ever find out"',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist chapter 1',
        blocks: [
          ParagraphBlock(
            'Go through the points briefly. If you hesitate on one, flip '
            'back — exactly these situations come up again in the test.',
          ),
          ChecklistBlock(
            title: 'What I take away from chapter 1',
            items: [
              'I know which data on my route is personal data',
              'I know purpose limitation, data minimisation and '
                  'confidentiality',
              'I know that recipient data does not belong in my private '
                  'life',
              'I know why this training is documented (Art. 5(2) GDPR)',
              'I understand that the training is repeated every year',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ds2',
    title: 'Photos and proof of delivery',
    summary: 'What may be in the picture, what may not — and where the '
        'photo belongs',
    asset: '',
    slides: [
      SafetySlide(
        title: 'The photo has exactly one purpose',
        blocks: [
          ParagraphBlock(
            'The delivery photo is meant to answer a single question: '
            'where is the parcel? Nothing else. Anything beyond that is '
            'more information than necessary — and therefore a violation '
            'of data minimisation.',
          ),
          ParagraphBlock(
            'In practice that means: camera down towards the parcel, '
            'close enough that the drop-off spot is recognisable, and '
            'far enough away from anything that shows people or makes '
            'them identifiable.',
          ),
          DoDontBlock(
            doTitle: 'May be in the picture',
            dos: [
              'The parcel itself at the drop-off spot',
              'A bit of house wall, door or steps for location context',
              'The house number, if it is needed to match the address',
              'With a drop-off permission: the agreed drop-off spot',
            ],
            dontTitle: 'Must not be in the picture',
            donts: [
              'People — not even the recipient, not even from behind',
              'Licence plates of parked vehicles',
              'Windows, balconies and views into interiors',
              'Children, pets, visitors, neighbours in the background',
              'Name plates of third parties not related to the shipment',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'The legal basis',
            text: 'Art. 5(1)(c) GDPR requires data minimisation: data '
                'must be adequate for the purpose and limited to what is '
                'necessary. A photo showing people, licence plates or '
                'home interiors goes beyond the purpose of "proof of '
                'delivery". In addition, for people in the picture the '
                'right to one\'s own image applies.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Where the photo belongs — and where not',
        blocks: [
          ParagraphBlock(
            'Just as important as what is in the picture is where it is '
            'stored. The photo is taken in the work app and stays there. '
            'It has no place in your private gallery, and certainly not '
            'in a messenger.',
          ),
          BulletsBlock([
            'Take the photo only in the work app — never with the camera '
                'app first and then upload it',
            'No copy in your private gallery, no cloud backup on your '
                'private phone',
            'No sending via WhatsApp, Telegram, Signal or a driver chat '
                'group',
            'Do not keep a photo "just in case" for yourself — the proof '
                'lives in the system',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'The most common mistake',
            text: 'Taking the photo with the normal camera first and '
                'then uploading it into the app. That leaves the photo '
                'permanently in your private gallery — often also in a '
                'cloud abroad. That is unlawful processing, even if you '
                'never show it to anyone.',
          ),
        ],
      ),
      SafetySlide(
        title: 'If someone ends up in the picture anyway',
        blocks: [
          ParagraphBlock(
            'It happens: the neighbour steps out of the door at the very '
            'moment you press the shutter, or a child runs through the '
            'frame. That is no drama — as long as you act immediately.',
          ),
          StepsBlock([
            'Delete the photo immediately, before you complete the stop',
            'Take a new one, this time without a person in the picture',
            'If the picture is already uploaded: inform the dispatcher '
                'or operations management so it can be deleted from the '
                'system',
            'If you are unsure whether someone is recognisable: better '
                'to report than to hope',
          ]),
          RevealBlock(
            prompt: 'Case study: You drop off a parcel in a rear '
                'courtyard. The photo shows the parcel — and in the '
                'background, through a floor-to-ceiling window, a living '
                'room with two people on the sofa. You have already '
                'completed the stop and are standing in the next '
                'courtyard. What do you do?',
            answer: 'You report it. The picture shows an interior and '
                'identifiable people — it goes far beyond the purpose of '
                '"proof of delivery" and has to be removed from the '
                'system. The obvious mistake is to think that reporting '
                'is no longer worth it because the stop is already '
                'completed. It is exactly the other way round: only if '
                'the company knows about it can it delete the picture '
                'and document the incident. Whoever reports it does '
                'everything right — whoever stays silent lets a '
                'violation stand.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist chapter 2',
        blocks: [
          ChecklistBlock(
            title: 'Before every delivery photo',
            items: [
              'I only take photos in the work app',
              'No person is visible in the picture',
              'No licence plate, no window, no interior in the picture',
              'The parcel and the drop-off spot are clearly recognisable',
              'No picture ends up in my private gallery or in a chat',
              'If someone is accidentally in the picture: delete, '
                  'retake, report',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ds3',
    title: 'Handling recipient data',
    summary: 'Scanner, phone and paper lists — work equipment, not '
        'personal property',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Scanner and work phone are not private devices',
        blocks: [
          ParagraphBlock(
            'The scanner and the work phone hold the data of hundreds of '
            'people every day. Both devices belong to the company and '
            'are exclusively for work — during breaks too, and even when '
            'you take them home.',
          ),
          BulletsBlock([
            'No private apps, no private login, no private cloud on the '
                'work device',
            'Do not pass the device on — not even briefly to colleagues, '
                'family or acquaintances',
            'Keep the screen lock active and never leave the device '
                'unattended',
            'When leaving the vehicle: take the scanner with you or stow '
                'it securely, not visible on the seat',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Absolutely forbidden',
            text: 'No screenshots of address lists, route overviews or '
                'recipient data. Not even to send them to yourself, not '
                'even "as a memory aid". A screenshot is a copy outside '
                'the system — exactly what the company can no longer '
                'control.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Information for neighbours and strangers',
        blocks: [
          ParagraphBlock(
            'People will ask you at the door. That is normal and usually '
            'meant harmlessly. Still: you only reveal as much as is '
            'necessary for the delivery — no more.',
          ),
          TableBlock(
            headers: ['Situation', 'How far you may go'],
            rows: [
              [
                'A neighbour accepts a parcel',
                'Give the recipient\'s name and house number — that is '
                    'all they need.',
              ],
              [
                'A neighbour asks what is inside',
                'No information. The contents are only the recipient\'s '
                    'business.',
              ],
              [
                'Someone asks whether person X lives here',
                'No information. You do not confirm home addresses.',
              ],
              [
                'Someone asks when you will come again',
                'Answer in general terms, no details about other '
                    'shipments or recipients.',
              ],
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'The legal basis',
            text: 'Passing recipient data on to third parties is a '
                'disclosure within the meaning of Art. 4(2) GDPR and '
                'needs a legal basis under Art. 6 GDPR. For handing a '
                'parcel to a neighbour, stating name and address is '
                'necessary for the performance of the contract — for '
                'parcel contents, phone numbers or information about '
                'other recipients there is none.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Paper is the underestimated risk',
        blocks: [
          ParagraphBlock(
            'Digital data is at least protected by a screen lock. A '
            'piece of paper in the vehicle is not. A route list behind '
            'the windscreen can be read from outside — with the names '
            'and addresses of two hundred households.',
          ),
          BulletsBlock([
            'Never leave paper lists lying open in the vehicle, and '
                'certainly not visible through the window',
            'When leaving the vehicle, take lists with you or stow them '
                'away locked',
            'At the end of the route: hand lists in at the depot, do not '
                'take them home',
            'Disposal only via the designated route at the depot — not '
                'in your household waste, not in the bin at the petrol '
                'station',
            'Treat labels from returns and misrouted parcels the same '
                'way as lists',
          ]),
          RevealBlock(
            prompt: 'Case study: You have finished the route and the '
                'route list is nothing but waste paper now. On the way '
                'home you throw it into the paper bin at your own house. '
                'Is that okay?',
            answer: 'No. The list contains names and addresses — '
                'personal data. It must be disposed of in a way that '
                'nobody can recover it, usually via a data protection '
                'bin or the shredder at the depot. The obvious mistake '
                'is to think a finished list is "worthless". For data '
                'protection, being finished changes nothing: the data is '
                'the same, and an open paper bin is a publicly '
                'accessible place. On top of that, you should never have '
                'taken the list home in the first place.',
          ),
          DoDontBlock(
            doTitle: 'Right',
            dos: [
              'Hand lists in at the depot and dispose of them properly '
                  'there',
              'Lock the scanner before you leave the vehicle',
              'Refer queries about other people\'s shipments to '
                  'operations management',
            ],
            dontTitle: 'Wrong',
            donts: [
              'Taking or sending screenshots of address lists',
              'Taking route lists home or disposing of them privately',
              'Passing recipient data on to neighbours, acquaintances or '
                  'third parties',
              'Handing the work device to someone else',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist chapter 3',
        blocks: [
          ChecklistBlock(
            title: 'At the end of every route',
            items: [
              'No screenshot of address data on my device',
              'Scanner and work phone are locked and stowed securely',
              'No paper list is lying open in the vehicle',
              'All lists and labels have been handed in at the depot',
              'I have not passed any recipient data on to third parties',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ds4',
    title: 'Your own data and your colleagues\' data',
    summary: 'Sick notes, time tracking, personnel file — and your rights '
        'as a data subject',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Data protection protects you too',
        blocks: [
          ParagraphBlock(
            'It is not only recipients who have data in the system — you '
            'do too. And some of it is considerably more sensitive than '
            'a delivery address.',
          ),
          BulletsBlock([
            'Performance metrics from your delivery work',
            'Sick notes and absences',
            'Time tracking, shift plans, break times',
            'Driving licence and ID data from the personnel file',
            'Photos showing you or your colleagues',
          ]),
          ParagraphBlock(
            'The company may process this data as far as it is necessary '
            'for the employment relationship. But it may not pass it on '
            'at will — and neither may you, when it concerns colleagues.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'The legal basis',
            text: 'Employee data is processed on the basis of '
                'Art. 6(1)(b) and (f) GDPR in conjunction with § 26 BDSG '
                '(German Federal Data Protection Act) — lawful only as '
                'far as necessary for the employment relationship. '
                'Health data such as sick notes are special categories '
                'under Art. 9 GDPR and particularly strictly protected.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Colleagues\' data is not yours',
        blocks: [
          ParagraphBlock(
            'At the depot you pick up a lot: who is off sick, who had '
            'trouble with a route, who got a written warning. Picking it '
            'up is one thing — passing it on is another.',
          ),
          DoDontBlock(
            doTitle: 'Right',
            dos: [
              'Talk about your own numbers as much as you like',
              'Sort out problems with a colleague directly with them or '
                  'with operations management',
              'Take and share a photo with colleagues only if everyone '
                  'in the picture agrees',
              'Report observed violations internally instead of '
                  'spreading them around the depot',
            ],
            dontTitle: 'Wrong',
            donts: [
              'Passing on colleagues\' performance data or evaluations',
              'Talking about the reason a colleague is off sick — even '
                  'if you know it',
              'Posting photos or videos of colleagues in chat groups '
                  'without their consent',
              'Sharing screenshots from internal lists or evaluations',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Particularly sensitive',
            text: 'Sick notes. The fact that someone is off sick is '
                'health data under Art. 9 GDPR. The reason even more so. '
                'Passing it on to other drivers is not allowed even if '
                'the person concerned has already talked about it '
                'themselves.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Your rights as a data subject',
        blocks: [
          ParagraphBlock(
            'The GDPR gives you rights towards your employer. You do not '
            'have to justify them, and exercising them must not put you '
            'at a disadvantage.',
          ),
          TableBlock(
            headers: ['Right', 'What you can request'],
            rows: [
              [
                'Access (Art. 15)',
                'An overview of what data is stored about you and what '
                    'for.',
              ],
              [
                'Rectification (Art. 16)',
                'Correction of wrong details, such as an incorrect '
                    'personnel number or address.',
              ],
              [
                'Erasure (Art. 17)',
                'Deletion of data that is no longer needed and not '
                    'subject to a retention period.',
              ],
            ],
          ),
          ParagraphBlock(
            'Your point of contact is operations management or the '
            'company\'s data protection officer. As a rule, a request '
            'must be answered within one month.',
          ),
          RevealBlock(
            prompt: 'Case study: A colleague asks you to send him a '
                'screenshot of an internal evaluation — one that lists '
                'all drivers with names and numbers. He only wants to '
                'see where he himself stands. Do you do it?',
            answer: 'No. The screenshot contains the performance data of '
                'all colleagues; that is a disclosure of employee data '
                'without a legal basis. That the colleague only wants to '
                'see his own row changes nothing — he still gets '
                'everyone else\'s data along with it. The right way: he '
                'requests his own numbers from operations management. '
                'His right of access under Art. 15 GDPR covers his own '
                'data only.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist chapter 4',
        blocks: [
          ChecklistBlock(
            title: 'When handling colleagues\' data',
            items: [
              'I do not pass on colleagues\' performance data',
              'I do not talk about other people\'s sick notes',
              'I do not post photos of colleagues without their consent',
              'I do not take screenshots from internal evaluations',
              'I know who to contact if I want access to my own data',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ds5',
    title: 'When something goes wrong — data breach',
    summary: '72-hour notification deadline: why you must report '
        'immediately',
    asset: '',
    slides: [
      SafetySlide(
        title: 'What a data breach is',
        blocks: [
          ParagraphBlock(
            'A data breach is not just the big hacker attack. In '
            'delivery work it is almost always small, everyday mishaps '
            '— and exactly those count too.',
          ),
          BulletsBlock([
            'Work phone or scanner lost or stolen',
            'Parcel handed to the wrong recipient, who has opened it',
            'Parcel with a readable address label left open in a '
                'hallway or on the street',
            'Photo or address list accidentally sent to the wrong '
                'person',
            'Route list lost or left lying open in the vehicle',
            'Scanner left unattended and accessible while unlocked',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Rule of thumb',
            text: 'As soon as personal data has become accessible to '
                'someone who should not have access to it, it is a data '
                'breach. Whether any actual harm was done in the end is '
                'not for you to decide — the company assesses that.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The 72-hour deadline',
        blocks: [
          ParagraphBlock(
            'The decisive point for you is the clock. As soon as the '
            'company learns of a data breach, a very short deadline '
            'starts running — and it runs regardless of whether it is '
            'after hours, the weekend or a public holiday.',
          ),
          FactsBlock([
            FactItem('72 hrs', 'the company\'s deadline for notifying '
                'the supervisory authority under Art. 33 GDPR'),
            FactItem('now', 'your report to the dispatcher or operations '
                'management — on the same day'),
            FactItem('0', 'disadvantages for you if you report your own '
                'mistake immediately'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'The legal basis',
            text: 'Art. 33(1) GDPR obliges the company to notify the '
                'supervisory authority of a personal data breach without '
                'undue delay and, where feasible, within 72 hours of '
                'becoming aware of it. Where there is a high risk, the '
                'people affected must additionally be informed under '
                'Art. 34 GDPR. The company can only meet this deadline '
                'if you report immediately.',
          ),
        ],
      ),
      SafetySlide(
        title: 'How to report correctly',
        blocks: [
          StepsBlock([
            'Call the dispatcher or operations management immediately — '
                'do not wait until the end of the day',
            'Say what happened, when it happened and which data is '
                'affected',
            'Say who may have seen the data',
            'Do not try to fix anything on your own: no deleting logs, '
                'no retrieving things without agreement',
            'If possible, preserve the situation — for example, do not '
                'move the wrongly delivered parcel before it is agreed '
                'how to proceed',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'The most important point in this chapter',
            text: 'Whoever reports a mistake immediately is doing the '
                'right thing. Reporting is expressly wanted and is not '
                'an admission of incompetence. Staying silent, on the '
                'other hand, turns a small mishap into a real problem — '
                'for the people affected, for the company and in the end '
                'for you too.',
          ),
          DoDontBlock(
            doTitle: 'Right',
            dos: [
              'Report immediately, even if it is embarrassing',
              'Describe everything fully, including your own mistakes',
              'Ask whether there is anything else you should do',
            ],
            dontTitle: 'Wrong',
            donts: [
              'Waiting to see whether anyone even notices',
              'Only saying something on the next working day',
              'Playing the incident down or leaving parts out',
              'Trying to retrieve the parcel or the photo on your own',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Case study and checklist',
        blocks: [
          RevealBlock(
            prompt: 'Case study: In the evening you notice that you '
                'delivered a parcel to house number 14 instead of 41. '
                'The recipient there has already opened it. You plan to '
                'simply collect it tomorrow morning and deliver it '
                'correctly — then nobody will notice. What is wrong with '
                'that?',
            answer: 'Two things. First, a data breach has already '
                'happened: a stranger has learned the name, address and '
                'contents of the shipment. That has to be assessed for '
                'notification, and the 72-hour deadline of Art. 33 GDPR '
                'runs from the moment the company becomes aware of it. '
                'Second, by waiting you prevent exactly what the company '
                'would have to do — assess, document and, if necessary, '
                'inform the affected recipient. The obvious mistake is '
                'to think a quiet correction harms no one. In fact it '
                'does: if the incident comes out later, the company is '
                'left without a timely notification — and you concealed '
                'the mistake instead of reporting it.',
          ),
          ChecklistBlock(
            title: 'Whenever I suspect a data breach',
            items: [
              'I report it the same day, not tomorrow',
              'I say what happened, when, and which data is affected',
              'I do not gloss over anything and leave nothing out',
              'I do not take any action on my own',
              'I understand: reporting is right, concealing makes it '
                  'worse',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'ds6',
    title: 'Confidentiality and loyalty',
    summary: 'What may go outside, what may not — and why factual '
        'criticism is expressly allowed',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Business secrets stay in the business',
        blocks: [
          ParagraphBlock(
            'Besides personal data there is a second group of '
            'information that does not belong outside: internal figures '
            'and trade and business secrets. That includes a lot of what '
            'gets discussed at the depot as a matter of course.',
          ),
          BulletsBlock([
            'Prices, terms and contracts with clients',
            'Internal metrics and evaluations',
            'Route plans, routing logic and capacity figures',
            'Internal instructions, training materials and process '
                'specifications',
            'Photos from the depot showing lists, screens or shipments',
          ]),
          ParagraphBlock(
            'This applies equally in every channel: in personal '
            'conversation, on social networks and in driver chat '
            'groups. A WhatsApp group with sixty drivers is not a '
            'private conversation.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'The legal basis',
            text: 'Trade secrets are protected by the German Trade '
                'Secrets Act (GeschGehG). Independently of that, your '
                'employment contract carries a duty of confidentiality '
                'as an ancillary contractual duty under § 241(2) BGB. '
                'For personal data, confidentiality under Art. 5(1)(f) '
                'GDPR applies on top.',
          ),
        ],
      ),
      SafetySlide(
        title: 'False claims about the company',
        blocks: [
          ParagraphBlock(
            'This is where people often mix up what is allowed and what '
            'is not. The line does not run between "positive" and '
            '"negative", but between true and knowingly false, between '
            'criticism and abuse.',
          ),
          ParagraphBlock(
            'Knowingly false statements of fact about the company, '
            'supervisors or colleagues are not covered by freedom of '
            'expression. The same goes for insults and abusive '
            'criticism — statements that are no longer about the issue '
            'but only about putting someone down.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'The legal basis',
            text: 'Art. 5(1) of the German Basic Law (GG) protects '
                'expressions of opinion, but not knowingly false '
                'statements of fact and not abusive criticism. Such '
                'statements can justify summary dismissal under § 626 '
                'BGB. Defamation can additionally be a criminal offence '
                'under § 186 StGB; knowingly false claims fall under '
                '§ 187 StGB (malicious defamation).',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Typical misunderstandings',
            text: 'A private profile is not private once others can read '
                'along. A closed chat group is not protected once a '
                'screenshot of it gets passed on. And "that was just my '
                'opinion" does not help if the statement was a claim of '
                'fact that is demonstrably untrue.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Factual criticism is expressly allowed',
        blocks: [
          ParagraphBlock(
            'Just as important as the line is what lies on this side of '
            'it — and that is a lot. You may voice criticism, even '
            'bluntly, even when it is uncomfortable. You may say that a '
            'route is planned too tightly, that a vehicle is in poor '
            'condition or that an announcement at the depot was wrong.',
          ),
          ParagraphBlock(
            'And whoever reports genuine wrongdoing is not left '
            'unprotected: since 2 July 2023 the German Whistleblower '
            'Protection Act (HinSchG) has been in force. It prohibits '
            'reprisals against employees who report violations — '
            'dismissal, written warnings, transfer or disadvantage '
            'because of the report.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Whistleblower protection',
            text: 'The HinSchG protects people who report violations in '
                'a work context from reprisals. Protection is lost only '
                'for knowingly or grossly negligently false reports. So '
                'whoever seriously reports a problem to the best of '
                'their knowledge is protected — even if the suspicion '
                'turns out to be unfounded in the end.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'The difference in one sentence',
            text: 'Say what you experienced — not what you piece '
                'together. Truthful criticism is protected, invented '
                'accusations are not.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The constructive route',
        blocks: [
          ParagraphBlock(
            'Almost everything drivers take outside could be solved '
            'faster internally. So the internal route is not only the '
            'safer one, but usually also the more effective one.',
          ),
          StepsBlock([
            'Talk to the dispatcher first — most problems are planning '
                'problems and can be solved there',
            'If nothing comes back: contact operations management, '
                'ideally in writing, with a date and a concrete incident',
            'For more serious violations: use the internal reporting '
                'channel under the HinSchG',
            'Only if nothing happens internally do external bodies come '
                'into play — and then factually and with verifiable '
                'facts',
          ]),
          DoDontBlock(
            doTitle: 'Allowed and wanted',
            dos: [
              'Saying that a route regularly cannot be completed on time',
              'Pointing out a technical defect on the vehicle — '
                  'repeatedly if necessary',
              'Describing a concrete incident you experienced yourself',
              'Reporting a violation via the internal reporting channel',
              'Following up when nothing happens after a report',
            ],
            dontTitle: 'Not covered',
            donts: [
              'Making claims you know are not true',
              'Insulting or demeaning supervisors or colleagues',
              'Making internal figures, contracts or evaluations public',
              'Spreading rumours in chat groups without knowing the '
                  'facts',
              'Fighting conflicts out on review portals or social '
                  'networks before anyone has even been asked internally',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Case study and checklist',
        blocks: [
          RevealBlock(
            prompt: 'Case study: In the driver chat group someone writes '
                'that the company deliberately withholds paid hours. You '
                'have never experienced that yourself, but you are '
                'annoyed about your roster right now and write: '
                '"True, they systematically cheat us all." The next day '
                'a screenshot of the group is going around. How should '
                'this be assessed?',
            answer: 'Critically — not because of the criticism, but '
                'because of the form. You made a statement of fact '
                '("they systematically cheat us") that you cannot prove '
                'and never experienced. Knowingly false statements of '
                'fact are not covered by freedom of expression and can '
                'have consequences under employment law up to summary '
                'dismissal under § 626 BGB; defamation additionally '
                'falls under § 186 StGB. The screenshot also shows that '
                'a closed group is not a protected space. The right way '
                'would have been to state your own case — "I am missing '
                'two hours in July, I reported it and have had no '
                'answer so far" — and take it to the dispatcher, '
                'operations management or the internal reporting '
                'channel. That statement is true, verifiable and '
                'protected by the HinSchG. Result: the same '
                'dissatisfaction, but voiced correctly, cannot harm you.',
          ),
          ChecklistBlock(
            title: 'Before I take anything outside',
            items: [
              'I know from my own experience that it is true',
              'I describe the incident factually, without insults',
              'I do not reveal internal figures, contracts or '
                  'evaluations',
              'I raised it internally first — dispatcher, operations '
                  'management or reporting channel',
              'I understand: reporting genuine wrongdoing is protected, '
                  'claiming made-up things is not',
            ],
          ),
        ],
      ),
    ],
  ),
];
