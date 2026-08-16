// lib/data/safety_training/green_book_content_en.dart
//
// Content of the Green Book training — English version.
// The structure is identical to the German master: chapters gb1–gb6,
// the same slides, the same blocks and the same values.
//
// The Green Book is the driver’s record book: the collection of daily
// control sheets under § 1 Abs. 6 Fahrpersonalverordnung (FPersV — the
// German drivers’ hours regulation). It proves driving times, breaks,
// working time and rest periods — it is NOT a vehicle inspection.
// There are no illustrations for this topic, hence `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> greenBookContentEn = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'gb1',
    title: 'What the Green Book is',
    summary: 'The driver’s record book under § 1 Abs. 6 FPersV — and why '
        'it is compulsory for you',
    asset: '',
    slides: [
      SafetySlide(
        title: 'A record of times, not a vehicle check',
        blocks: [
          ParagraphBlock(
            'The ‘Green Book’ is your driver’s record book. In it you '
            'collect the daily control sheets: one sheet for every working '
            'day, showing when you were driving, when you took your break '
            'and when your rest period began.',
          ),
          ParagraphBlock(
            'It is expressly not a vehicle check. Tyres, lights and '
            'bodywork are documented elsewhere. The Green Book is about '
            'times only — your times.',
          ),
          BulletsBlock([
            'One sheet for every day on which you drive a vehicle that is '
                'subject to the recording duty',
            'Written by hand, in permanent ink, and signed',
            'It proves that you kept to driving times, breaks and rest '
                'periods',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'In short',
            text: 'The Green Book answers a single question: when were you '
                'at the wheel, and when were you not? Nothing else belongs '
                'in it.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Who has to keep records',
        blocks: [
          ParagraphBlock(
            'The duty comes from § 1 Abs. 6 of the '
            'Fahrpersonalverordnung (FPersV — the German drivers’ hours '
            'regulation). It attaches not to you personally but to the '
            'vehicle and the purpose of the journey: commercial carriage of '
            'goods with a vehicle over 2,8 t up to 3,5 t maximum '
            'permissible mass. That is exactly the typical delivery van.',
          ),
          FactsBlock([
            FactItem('under 2,8 t', 'no recording duty under § 1 '
                'Abs. 6 FPersV'),
            FactItem('2,8–3,5 t', 'daily control sheet — your Green Book'),
            FactItem('from 3,5 t', 'digital tachograph instead of paper'),
          ]),
          ParagraphBlock(
            'What counts is the maximum permissible mass stated in the '
            'vehicle registration document — not how heavily the van is '
            'actually loaded today. A half-empty 3,5-tonner still has to '
            'be recorded.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'The legal basis',
            text: '§ 1 Abs. 6 FPersV requires you to record driving times, '
                'breaks in driving as well as working and rest periods. If '
                'you drive without this sheet you breach the regulation — '
                'regardless of whether you kept to the times.',
          ),
        ],
      ),
      SafetySlide(
        title: 'What the record is good for',
        blocks: [
          ParagraphBlock(
            'The rule is not there for its own sake. It exists because '
            'overtired drivers are dangerous on the road — to themselves '
            'and to everyone else. The sheet makes it visible whether your '
            'working days are even planned so they can be kept.',
          ),
          BulletsBlock([
            'Protection against fatigue: if you have to document the '
                'break, you are more likely to actually take it',
            'Proof for you: the sheet shows that you drove correctly — '
                'even months later',
            'Proof against assertions: without a record, your memory '
                'stands against whatever the check assumes',
            'A basis for tour planning: tours that are repeatedly too '
                'tight show up on the sheet',
          ]),
          RevealBlock(
            prompt: 'Case study: today you kept to the times — break on '
                'time, finished on time. You just did not fill in the '
                'sheet, because everything was in order anyway. A check in '
                'the afternoon. Is that a problem?',
            answer: 'Yes. A recording duty means that the proof itself is '
                'the duty. Nobody at a roadside check can establish '
                'whether you actually kept to the times — there is nothing '
                'to produce. From the point of view of the check, a '
                'missing sheet is treated exactly like an exceeded time '
                'limit: there is a breach, and it is penalised. Keeping to '
                'the rules only helps you if you can prove it.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist: the basic understanding',
        blocks: [
          ChecklistBlock(
            title: 'What I take away from chapter 1',
            items: [
              'I know that the Green Book documents times and not the '
                  'condition of the vehicle',
              'I know the legal basis: § 1 Abs. 6 FPersV',
              'I know that vehicles over 2,8 t up to 3,5 t are affected',
              'I know that the maximum permissible mass counts, not '
                  'today’s load',
              'I know that from 3,5 t the digital tachograph applies',
              'I understand that a missing sheet is a breach in itself',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'One sentence for the road',
            text: '‘What I have not written down, I cannot prove.’',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'gb2',
    title: 'What exactly gets entered',
    summary: 'Every compulsory entry — and how to fill it in cleanly',
    asset: '',
    slides: [
      SafetySlide(
        title: 'The compulsory entries on the sheet',
        blocks: [
          ParagraphBlock(
            'A daily control sheet is only proof if every prescribed entry '
            'is on it. If one of them is missing, the sheet counts as '
            'incomplete — with the same consequences as a missing sheet.',
          ),
          BulletsBlock([
            'Surname, first name and address of the driver',
            'Official registration number of the vehicle',
            'The date of the day',
            'Odometer reading at the start and at the end of the journey',
            'Place where the journey started and place where it ended',
            'Driving times and rest periods with the hours stated',
            'Breaks in driving (the rest breaks)',
            'Your signature',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Complete means complete',
            text: '§ 1 Abs. 6 FPersV lists the entries exhaustively. A '
                'sheet without a registration number, without an address '
                'or without a signature does not satisfy the recording '
                'duty — even if the times are entered correctly.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Filling it in step by step',
        blocks: [
          ParagraphBlock(
            'The order below is deliberately chosen so that you forget '
            'nothing: first the fixed details, then the times as the day '
            'goes on, and the closing entries last.',
          ),
          StepsBlock([
            'Before setting off: enter the date, surname, first name, '
                'address and registration number',
            'Read the odometer and enter it as the starting reading — do '
                'not estimate it',
            'Enter the place where the journey starts (depot, site, place '
                'name)',
            'Enter the start of driving time with the clock time as soon '
                'as you drive off',
            'Enter every break in driving straight away with start and '
                'end — not in the evening',
            'At the end of the tour: enter the place where the journey '
                'ends and the closing odometer reading',
            'Enter the end of driving time and the start of the rest '
                'period',
            'Read the sheet through, check it for gaps and sign it',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Write in permanent ink',
            text: 'Ballpoint pen, not pencil. An entry that can be rubbed '
                'out is not proof. A slip of the pen is crossed out once '
                'and rewritten next to it — not painted over and not '
                'covered up.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Entering times cleanly',
        blocks: [
          ParagraphBlock(
            'Most things go wrong with the times. Every block of time in '
            'the day belongs on its own line, with a from–to clock time. '
            'This is what a normal delivery day looks like:',
          ),
          TableBlock(
            headers: ['From–to', 'Type', 'Note'],
            rows: [
              ['06:30–07:00', 'Working time', 'Loading at the depot, not '
                  'yet driving time'],
              ['07:00–11:30', 'Driving time', '4,5 hours — the break is '
                  'now due'],
              ['11:30–12:15', 'Break in driving', '45 minutes in one go'],
              ['12:15–16:45', 'Driving time', 'second block, 9 hours in '
                  'total'],
              ['16:45–17:15', 'Working time', 'handover, returns, closing '
                  'up'],
              ['from 17:15', 'Rest period', 'at least 11 hours until the '
                  'next start'],
            ],
          ),
          BulletsBlock([
            'Driving time is only the time at the wheel while the vehicle '
                'is moving',
            'Loading, unloading, scanning and waiting at the stop is '
                'working time, but not driving time',
            'A break in driving is only a rest break if you genuinely do '
                'not work during it',
          ]),
          RevealBlock(
            prompt: 'Case study: you stand at the ramp for 40 minutes '
                'waiting to be unloaded. You sit in the cab and do '
                'nothing. May you enter that as a break in driving?',
            answer: 'Only if you can genuinely dispose of that time freely '
                'and perform no work — and if you know that in advance. If '
                'you have to be ready at any moment because it could carry '
                'on straight away, that is waiting time and not a rest '
                'break. The obvious mistake: ‘I did nothing, so it was a '
                'break.’ What matters is not whether you moved, but '
                'whether the time was yours to dispose of. If in doubt you '
                'enter it as working time — that is always the safe side.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist: is the sheet complete?',
        blocks: [
          ChecklistBlock(
            title: 'Before I sign',
            items: [
              'Surname, first name and address are on the sheet',
              'The registration number matches the vehicle I actually '
                  'drove',
              'The date is entered',
              'Starting and closing odometer readings are read off the '
                  'instrument',
              'The place of departure and the place of arrival are on it',
              'All driving times are entered with from–to clock times',
              'All breaks in driving are entered',
              'The start of the rest period is entered',
              'Everything in ballpoint pen, nothing rubbed out, no gap',
              'Signature added',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'gb3',
    title: 'Driving times, breaks, rest periods',
    summary: 'The numbers your working day has to keep to',
    asset: '',
    slides: [
      SafetySlide(
        title: 'The numbers that count',
        blocks: [
          ParagraphBlock(
            'The Green Book documents times — but only so that it can be '
            'seen whether you kept within the limits. You need to carry '
            'those limits in your head, not just on paper.',
          ),
          FactsBlock([
            FactItem('9 h', 'driving time per day as a rule'),
            FactItem('10 h', 'allowed twice a week as an exception'),
            FactItem('4,5 h', 'driving in one go, then the break is due'),
          ]),
          FactsBlock([
            FactItem('45 min', 'break in driving after 4,5 hours'),
            FactItem('15 + 30', 'permitted split — in this order'),
            FactItem('11 h', 'daily rest period, at least'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'What the rule requires',
            text: 'Driving time is at most 9 hours a day; twice a week it '
                'may be extended to 10 hours. After 4,5 hours of driving '
                'time at the latest you must take a break in driving of at '
                'least 45 minutes. The daily rest period is at least 11 '
                'hours.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Placing the break correctly',
        blocks: [
          ParagraphBlock(
            'The 45 minutes are the normal case. You may split them — but '
            'only into exactly two parts and only in a particular order: '
            'first at least 15 minutes, then at least 30 minutes. The '
            'other way round does not count.',
          ),
          DoDontBlock(
            doTitle: 'This makes the break valid',
            dos: [
              '45 minutes in one go after 4,5 hours of driving at the '
                  'latest',
              'Or 15 minutes first, then 30 minutes',
              'Both parts within the same 4,5-hour block',
              'Both parts entered on the sheet with from–to clock times',
            ],
            dontTitle: 'This does not count',
            donts: [
              '30 minutes first and 15 minutes afterwards — wrong order',
              'Three short breaks of 15 minutes each',
              'Twice 20 minutes — the second part is too short',
              'A break only after 5 hours of driving because the stop '
                  'fitted better',
            ],
          ),
          BulletsBlock([
            'The 4,5 hours are pure driving time — stops for delivery do '
                'not count towards them',
            'The break has to come before the limit is exceeded, not after',
            'After the complete break a new 4,5-hour block begins',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'The most common error in thinking',
            text: 'The break is not due when you have been on duty for 4,5 '
                'hours, but when you have driven for 4,5 hours. Anyone who '
                'counts duty time usually takes the break too early — and '
                'then once more too late.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Doing the maths on a delivery day',
        blocks: [
          ParagraphBlock(
            'In everyday work you are not counting one long block but many '
            'short drives between the stops. Add them up — together they '
            'make your driving time.',
          ),
          RevealBlock(
            prompt: 'Case study: you start at 07:00. By 09:30 you have '
                'spent 2 hours at the wheel and the rest at the stops. By '
                '12:00 another 2 hours of driving time are added, and by '
                '13:00 a further 30 minutes. When is your break due at '
                'the latest?',
            answer: 'At 13:00. At that point you have reached 2 + 2 + 0,5 '
                '= 4,5 hours of pure driving time — now you may not drive '
                'another metre before the break in driving is done. The '
                'obvious mistake would be to count six hours of duty from '
                '07:00 and put the break at 11:30. The clock that counts '
                'only runs while the vehicle is moving.',
          ),
          RevealBlock(
            prompt: 'Case study: you have already driven 10 hours twice '
                'this week. It is Friday, you are at 8,5 hours of driving '
                'time and have two stops left, roughly 40 minutes of '
                'driving in total. Can you still do it?',
            answer: 'No. You may only use the extension to 10 hours twice '
                'a week, and those two are used up. Today the standard '
                'limit of 9 hours applies again — so you have 30 minutes '
                'of driving time left, not 40. You drive the stop you can '
                'reach, report the rest to your dispatcher and end your '
                'driving time. The obvious mistake: ‘I am entitled to the '
                '10 hours every day.’ They are an exception with a weekly '
                'quota.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist: times under control',
        blocks: [
          ChecklistBlock(
            title: 'What I take away from chapter 3',
            items: [
              'I know that 9 hours of driving time is the rule',
              'I know that 10 hours are allowed only twice a week',
              'I count the 4,5 hours as pure driving time, not as duty '
                  'time',
              'I take at least 45 minutes as a break in driving',
              'I split the break into at most 15 + 30 minutes, in that '
                  'order',
              'I keep at least 11 hours of daily rest',
              'I enter every break straight away, not in the evening',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Remember',
            text: '4,5 – 45 – 9 – 11. Four numbers that give your day its '
                'shape. If you know them you do not have to calculate, '
                'only write things down.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'gb4',
    title: 'Typical mistakes when filling in',
    summary: 'The six mistakes that show up at every check',
    asset: '',
    slides: [
      SafetySlide(
        title: 'The six most common mistakes',
        blocks: [
          ParagraphBlock(
            'Almost all sheets that are objected to fail not on the times '
            'but on the way they were kept. These six mistakes make an '
            'otherwise correct sheet worthless.',
          ),
          DoDontBlock(
            doTitle: 'This is how you keep the sheet properly',
            dos: [
              'Make every entry straight away, when the block of time ends',
              'Use a ballpoint pen, permanent ink',
              'Enter breaks with the actual from–to clock times',
              'Read the odometer off the instrument',
              'Sign at the end of the day',
              'The sheet stays in the vehicle, with you',
            ],
            dontTitle: 'This is how the sheet gets objected to',
            donts: [
              'Writing up the whole week on Friday evening',
              'Writing in pencil so you can ‘correct it later’',
              'Estimating breaks (‘roughly three quarters of an hour’)',
              'Writing the odometer reading down from memory',
              'Forgetting the signature',
              'Leaving the sheets at home or at the depot',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'The most expensive mistake is the most convenient one',
            text: 'Filling in afterwards feels harmless — it is the '
                'mistake that is spotted fastest and weighs the most.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Why late entries stand out',
        blocks: [
          ParagraphBlock(
            'A sheet written up in one sitting looks different from one '
            'that grew over the course of the day. Inspectors see both '
            'every day and spot the difference at once.',
          ),
          BulletsBlock([
            'The same handwriting, the same pen, the same pressure on '
                'every line',
            'Strikingly round times: everything ends on the half or full '
                'hour',
            'Odometer readings that do not fit the route entered',
            'Entries that contradict the delivery notes, scans or fuel '
                'receipts',
            'Breaks that always last exactly 45 minutes — even on days '
                'when that was impossible',
          ]),
          ParagraphBlock(
            'On top of that: at a check on the premises the sheets lie '
            'next to all the other paperwork. Contradictions are not '
            'spotted by you but by the authority.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Wrong is worse than empty',
            text: 'An incomplete sheet is a breach of the recording duty. '
                'A sheet deliberately filled in falsely is more than that '
                '— there it is no longer just a regulatory offence but a '
                'question of deception. Better to enter that you drove too '
                'long than to invent a time.',
          ),
          RevealBlock(
            prompt: 'Case study: on Thursday you notice that Tuesday’s '
                'lunch break was not entered. You remember it exactly: '
                '12:10 to 12:55. What do you do?',
            answer: 'You add it — but visibly as a late entry, with the '
                'date of the addition and a short note, and you inform '
                'your dispatcher. An honest, recognisable correction is '
                'permitted and clearly better than a gap. The obvious '
                'mistake would be to slip the entry in as though it had '
                'been made on Tuesday — that is precisely the step from '
                'carelessness to falsification.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist: kept properly',
        blocks: [
          ChecklistBlock(
            title: 'My sheet will stand up to a check',
            items: [
              'I enter every block of time straight away, not in the '
                  'evening',
              'I write with a ballpoint pen',
              'I read off clock times and odometer readings instead of '
                  'estimating them',
              'I sign every sheet',
              'My sheets are always with me in the vehicle',
              'I make corrections visibly and dated, never invisibly',
              'I would rather enter a breach than invent a time',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'gb5',
    title: 'Carrying, handing in, keeping',
    summary: '28 days with the driver, one year at the company',
    asset: '',
    slides: [
      SafetySlide(
        title: 'The two periods',
        blocks: [
          ParagraphBlock(
            'A completed sheet is only worth something when it is in the '
            'right place at the right moment. There are two periods for '
            'that, and you have to keep them apart.',
          ),
          FactsBlock([
            FactItem('28 days', 'the driver carries the records along'),
            FactItem('1 year', 'the operator keeps them at the company'),
          ]),
          BulletsBlock([
            'The 28 days concern you: you have to carry the records for '
                'the current day and the preceding 28 days',
            'The one-year period concerns the company: it has to keep the '
                'sheets for a year and produce them on request',
            'Both apply at the same time — the sheets only go into the '
                'archive once the duty to carry them has expired',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Duty to carry',
            text: 'The records of the last 28 days belong in the vehicle — '
                'not in your locker, not at home and not in the office. If '
                'they are missing at a check, it does not help that they '
                'were kept properly.',
          ),
        ],
      ),
      SafetySlide(
        title: 'The roadside check',
        blocks: [
          ParagraphBlock(
            'Checks are carried out by the BAG — the Bundesamt für '
            'Logistik und Mobilität, the German federal office for '
            'logistics and mobility — and by the police. Both may check at '
            'the roadside, and the BAG may also check at the company.',
          ),
          StepsBlock([
            'Pull over, engine off, window down, keep your hands visible',
            'Stay calm — a check is routine, not suspicion',
            'Produce your driving licence, the vehicle documents and the '
                'records of the last 28 days',
            'Answer questions factually, invent nothing and embellish '
                'nothing',
            'If something is objected to: let it be recorded, do not '
                'argue',
            'Afterwards inform your dispatcher and document the matter at '
                'the company',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Preparation beats explanation',
            text: 'A check takes a few minutes if the sheets are complete '
                'and in the vehicle. Anything else costs you and the '
                'company the whole afternoon.',
          ),
          RevealBlock(
            prompt: 'Case study: at the roadside the inspector asks for '
                'the last 28 days. You only have the current week with '
                'you — the older sheets you handed in properly at the '
                'depot. Is that enough?',
            answer: 'No. The duty to carry covers the current day and the '
                'preceding 28 days. The fact that the older sheets are '
                'filed properly at the company satisfies the duty to keep '
                'them, but not the duty to carry them — they are two '
                'separate duties. The right way: copies or originals of '
                'the last 28 days stay with you, and only after that do '
                'they go into the archive. Agree with your dispatcher how '
                'you organise this at the company.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Handing in at the company',
        blocks: [
          ParagraphBlock(
            'The operator can only meet the duty to keep the records if '
            'the sheets actually reach him. That is why handing them in is '
            'not paperwork for its own sake but part of your recording '
            'duty.',
          ),
          BulletsBlock([
            'Hand the sheets in completely once the carrying period has '
                'expired, not in a pile at the end of the month',
            'Throw nothing away, not even sheets with mistakes or '
                'corrections',
            'If a sheet is missing, say so straight away — a reported gap '
                'is better than a discovered one',
            'Do not simply leave out holiday, sick and office days; mark '
                'them as the company requires',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Gaps stay gaps',
            text: 'A day without a sheet cannot be reconstructed later. If '
                'you let handing in slide, you produce exactly the gaps '
                'that show up at a check on the premises.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist: paperwork under control',
        blocks: [
          ChecklistBlock(
            title: 'Before every shift and after every week',
            items: [
              'The records of the last 28 days are in the vehicle',
              'Today’s sheet has been started and is within reach',
              'Driving licence and vehicle documents are with me',
              'I have handed in expired sheets at the company',
              'I have thrown no sheet away, not even one with corrections',
              'I know who I have to inform if there is a check',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'gb6',
    title: 'Consequences of breaches',
    summary: 'Fines, the company’s responsibility, internal escalation',
    asset: '',
    slides: [
      SafetySlide(
        title: 'What you face legally',
        blocks: [
          ParagraphBlock(
            'A missing or incomplete daily control sheet is a regulatory '
            'offence. How high the fine turns out depends on how serious '
            'the breach was and how often it happened.',
          ),
          FactsBlock([
            FactItem('from 100 €', 'fine for missing or incomplete '
                'sheets'),
            FactItem('depending on severity', 'higher amounts for several '
                'or repeated breaches'),
          ]),
          BulletsBlock([
            'It is not only the driver who is affected — the company also '
                'carries responsibility for the records',
            'For serious or repeated breaches, proceedings about the '
                'company’s reliability may follow',
            'Checks are carried out by the BAG and the police, at the '
                'roadside and at the company',
            'Objections from a company check affect all drivers, not just '
                'the one who was checked',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Two addressees, one duty',
            text: 'The FPersV places drivers and operators under a joint '
                'obligation: you have to record and carry, the company has '
                'to keep and monitor. If either of the two fails, the side '
                'responsible is liable.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Escalation within the company',
        blocks: [
          ParagraphBlock(
            'Regardless of whether an authority finds anything, a fixed '
            'sequence applies within the company. It is the same for '
            'everyone and it is documented.',
          ),
          StepsBlock([
            'First stage: a verbal warning from the dispatcher',
            'Second stage: a written warning in the personnel file',
            'Third stage: employment-law consequences up to dismissal',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'The breach is the missing sheet',
            text: 'The stages run regardless of whether anything happened '
                'or whether a check took place. The sheet not being kept '
                'is itself the breach.',
          ),
          RevealBlock(
            prompt: 'Case study: the dispatcher pushes: ‘Do the two stops, '
                'just write the break in, otherwise we will not get '
                'through.’ What applies?',
            answer: 'The instruction changes nothing about your duty. You '
                'are the one who records and signs — with your signature '
                'you confirm the content. A verbal instruction protects '
                'you neither at the check nor later at the company. The '
                'right way: take the break, enter it correctly, report the '
                'remaining stops and document the instruction. The company '
                'is obliged to make compliance possible — not to get '
                'around it.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checklist: wrapping up',
        blocks: [
          ChecklistBlock(
            title: 'What I take away from the training',
            items: [
              'The Green Book is the driver’s record book under § 1 Abs. 6 '
                  'FPersV',
              'I know all the compulsory entries and fill them in fully',
              'I keep to 9 h driving time, 4,5 h until the break, 45 min '
                  'break and 11 h rest period',
              'I enter things straight away, in ballpoint pen, and I sign',
              'I carry the records of the last 28 days with me',
              'I hand in expired sheets at the company',
              'I know that a missing sheet can trigger a fine from 100 '
                  'euros',
              'I know that an instruction does not cancel my recording '
                  'duty',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'One sentence for the road',
            text: '‘The sheet writes along while I drive — not when I have '
                'finished.’',
          ),
        ],
      ),
    ],
  ),
];
