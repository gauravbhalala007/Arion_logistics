// lib/data/safety_training/operating_instructions_en.dart
//
// Betriebsanweisungen — englische Fassung (uebersetzt aus DE-Master).
// Generisch für Zustellbetriebe formuliert; betriebsspezifische Angaben
// (Ansprechpartner, Standort der Verbandkästen, Sammelplatz) ergänzt
// der jeweilige Betrieb.

import 'operating_instructions.dart';

const List<OperatingInstruction> operatingInstructionsEn = [
  // ─────────────────────────────────────────── Fahrzeug / Vehicle
  OperatingInstruction(
    id: 'baw_transporter',
    title: 'Driving the van up to 3,5 t',
    subtitle: 'Driving, manoeuvring and parking the delivery vehicle',
    category: InstructionCategory.vehicle,
    scope: 'Applies to all employees who drive delivery vehicles up to '
        '3,5 t permissible gross mass.',
    hazards: [
      'Road traffic accidents caused by distraction, time pressure and '
          'fatigue',
      'Hitting people when reversing — blind spot',
      'Load slipping when braking and in bends',
      'Falls when getting in and out',
      'Exceeding the permissible gross mass',
    ],
    protection: [
      'Carry a valid driving licence',
      'Pre-departure check before setting off: lights, tyres, brakes, '
          'vision, load securing',
      'Adjust seat, mirrors and head restraint before your first drive',
      'Put on your seat belt — also on short hops between two stops',
      'No alcohol, no drugs, no medication that impairs you before or '
          'during the drive',
      'Mobile phone only with a hands-free kit, enter addresses only when '
          'stopped',
      'Reverse only with a banksman where others are at risk; if in doubt '
          'get out and check what is around you',
      'Secure the load against slipping, heavy consignments low down and '
          'against the bulkhead',
      'Always lock the vehicle once you have left it, never leave the key '
          'in it',
      'Keep to the rules on breaks and driving times',
    ],
    onFailure: [
      'Warning lights or unusual noises: head for a safe place and stop',
      'Switch on the hazard lights, put on your high-visibility vest, set '
          'up the warning triangle (approx. 100 m, motorway 150–400 m)',
      'Inform the dispatcher, call out the breakdown service through the '
          'route laid down for it',
      'Do not repair it yourself — tow only with a tow bar',
      'Do not move a vehicle with an obvious defect any further',
    ],
    onAccident: [
      'Stop, secure the scene, high-visibility vest before you get out',
      'Give first aid, call 112',
      'Police for personal injury, high property damage or suspected '
          'alcohol/drugs',
      'Exchange personal and insurance details, secure photos and '
          'witnesses',
      'Inform your employer without delay; enter even small injuries in '
          'the Verbandbuch (first aid log)',
    ],
    maintenance: [
      'Report and document defects immediately',
      'Keep the vehicle clean, keep glass and steps free of snow, ice and '
          'dirt',
      'Check the first aid kit, warning triangle and high-visibility vest '
          'for completeness and expiry date',
      'Keep to service and inspection dates',
    ],
  ),

  // ─────────────────────────────────────────── PSA / PPE
  OperatingInstruction(
    id: 'baw_sicherheitsschuhe',
    title: 'Safety shoes',
    subtitle: 'Foot protection in delivery work',
    category: InstructionCategory.ppe,
    scope: 'Applies to all employees in delivery, the warehouse and the '
        'vehicle yard.',
    hazards: [
      'Falling consignments and parts of the load',
      'Treading on pointed or sharp-edged objects',
      'Twisted ankles and ligament injuries when getting out, on kerbs '
          'and on uneven paths',
      'Slipping on wet and icy surfaces',
      'Crush injuries from roll cages and pallet trucks',
    ],
    protection: [
      'Wear safety shoes for the whole of your working time — at the '
          'station as much as on the route, all year round and whatever '
          'they feel like',
      'Prefer the ankle-high version — it supports the joint against '
          'twisting',
      'Protection class S1 as a minimum; S2 in the wet, S3 where there is '
          'a risk of penetration',
      'Lace the shoes fully and wear them closed',
      'Check for defects before you start work: tread, cracks, sole grip',
      'Do not modify the shoes yourself',
      'Never work in trainers or open shoes',
    ],
    onFailure: [
      'Worn tread, cracks or a damaged sole: stop using the shoes',
      'Report shoes that pinch or rub — there are other models and sizes; '
          'switching to your own trainers is not a solution',
      'Ask your supervisor for a replacement — the employer provides PPE '
          'free of charge',
    ],
    onAccident: [
      'Have foot injuries treated straight away, even apparently minor '
          'ones',
      'Entry in the Verbandbuch (first aid log)',
      'For puncture wounds see a doctor — have your tetanus cover checked',
    ],
    maintenance: [
      'Clean the shoes regularly and let them dry',
      'Replace heavily soiled or soaked shoes',
      'Replacement interval as specified by the manufacturer and by wear',
    ],
  ),

  OperatingInstruction(
    id: 'baw_warnweste',
    title: 'High-visibility vest',
    subtitle: 'Being seen on the road',
    category: InstructionCategory.ppe,
    scope: 'Applies to all employees who are on the road, in the yard or '
        'at loading areas.',
    hazards: [
      'Being overlooked by other road users',
      'Poor visibility at dusk, in the dark, in rain and fog',
      'Manoeuvring traffic on the station site',
    ],
    protection: [
      'Carry the vest within reach in the cab — not in the load '
          'compartment',
      'Put it on before you get out at a breakdown, an accident and every '
          'stop on the road',
      'Wear it on the station site and at loading areas where vehicles '
          'are moving',
      'Use a class 2 or 3 vest and close it fully',
      'In the dark also make sure the lights and side lights are on',
    ],
    onFailure: [
      'Replace a dirty, faded or damaged vest — the reflective strips '
          'have to work',
      'Report a missing vest before setting off and have it replaced',
    ],
    onAccident: [
      'After an accident on the road keep the vest on until the scene has '
          'been cleared',
      'Report and document injuries',
    ],
    maintenance: [
      'Keep the vest clean, wash it as the manufacturer specifies',
      'Check that it is in the vehicle — part of the pre-departure check',
    ],
  ),

  // ─────────────────────────────────────────── Handhabung / Handling
  OperatingInstruction(
    id: 'baw_heben_tragen',
    title: 'Lifting and carrying',
    subtitle: 'Moving consignments without damaging your back',
    category: InstructionCategory.handling,
    scope: 'Applies to lifting, carrying and setting down consignments '
        'and load carriers by hand.',
    hazards: [
      'Damage to the spine and discs from poor lifting technique',
      'Muscle and tendon injuries from jerky movements',
      'Crushed hands and feet when setting a load down',
      'Tripping because a large consignment blocks your view',
    ],
    protection: [
      'Estimate the weight before lifting and clear your path',
      'Step close to the load, feet shoulder-width apart',
      'Lift with your legs: bend your knees, keep your back straight',
      'Carry the load close to your body, not at arm\'s length',
      'Do not lift and twist at the same time — move your feet instead',
      'Move heavy or bulky consignments with a second person or with aids '
          '(roll cage, sack truck, pallet truck)',
      'Keep your view clear while carrying; if in doubt make two trips',
      'Wear gloves for sharp-edged consignments',
    ],
    onFailure: [
      'Do not move a load that is too heavy or unwieldy on your own — ask '
          'for help',
      'Do not use defective aids (jammed castors, a damaged sack truck) '
          'and report them',
    ],
    onAccident: [
      'Stop the activity at once if you feel sudden pain in your back',
      'Inform your supervisor, entry in the Verbandbuch (first aid log)',
      'If the trouble persists, see a Durchgangsarzt (accident doctor)',
    ],
    maintenance: [
      'Check transport aids regularly for proper function',
      'Keep traffic routes and loading areas clear and slip-resistant',
    ],
  ),

  OperatingInstruction(
    id: 'baw_winter',
    title: 'Winter road conditions',
    subtitle: 'Driving and delivering in snow, ice and wet',
    category: InstructionCategory.vehicle,
    scope: 'Applies to delivery and driving in winter conditions.',
    hazards: [
      'Longer braking distance, skidding, aquaplaning',
      'Falls on icy pavements, ramps and steps',
      'Getting chilled during longer spells outdoors',
      'Restricted vision from iced-up windows and mirrors',
    ],
    protection: [
      'Clear the vehicle completely of snow and ice before setting off — '
          'including the roof, headlights and number plates',
      'Winter-capable tyres; carry snow chains and traction aids where '
          'needed',
      'Check the antifreeze in the coolant and screen wash, ice scraper '
          'on board',
      'Reduce your speed considerably, at least double your distance',
      'Brake, steer and accelerate gently',
      'Clear snow off steps and footholds before using them',
      'Wear warm, weatherproof clothing and slip-resistant footwear',
      'Avoid time pressure — better to arrive late than not at all',
    ],
    onFailure: [
      'If roads are impassable, break off the route and inform the '
          'dispatcher',
      'If the vehicle gets stuck, do not force it free — ask for help',
    ],
    onAccident: [
      'Secure the scene particularly carefully — set the warning triangle '
          'further away',
      'Report and document fall injuries even with mild symptoms',
    ],
    maintenance: [
      'Check the wiper blades and lights regularly',
      'Look after the door seals, de-ice the locks',
    ],
  ),

  // ────────────────────────────── Gefahrstoffe / Hazardous substances
  OperatingInstruction(
    id: 'baw_adblue',
    title: 'AdBlue (urea solution)',
    subtitle: 'Topping up AdBlue on the delivery vehicle',
    category: InstructionCategory.hazardous,
    scope: 'Applies to topping up and handling AdBlue on vehicles with '
        'SCR exhaust treatment.',
    hazards: [
      'Irritation of eyes, skin and airways on contact',
      'Slip hazard from spilled liquid',
      'Crystallisation and corrosion on vehicle parts',
      'Environmental damage if it gets into the ground or the drains',
    ],
    protection: [
      'Use only the blue filler neck provided — never fill it into the '
          'diesel tank',
      'Wear protective gloves, avoid skin contact',
      'Top up only outdoors or with good ventilation, engine switched off',
      'Close the container cleanly, do not store it in the sun',
      'Wash your hands thoroughly after handling it',
    ],
    onFailure: [
      'Dilute spilled liquid with water immediately and pick it up',
      'Use an absorbent, do not flush it into the drains',
      'If the wrong tank has been filled, do not start the vehicle and '
          'report it at once',
    ],
    onAccident: [
      'Eye contact: rinse with water for at least 15 minutes, see a '
          'doctor',
      'Skin contact: rinse off with plenty of water, change any clothing '
          'that is wet with it',
      'Swallowing: rinse your mouth, drink water, see a doctor',
      'Report the incident and enter it in the Verbandbuch (first aid '
          'log)',
    ],
    maintenance: [
      'Keep the container and the filler area clean',
      'Dispose of empty containers as specified',
    ],
  ),

  // ─────────────────────────────────────────── Hygiene
  OperatingInstruction(
    id: 'baw_hautschutz',
    title: 'Skin protection & hand hygiene',
    subtitle: 'Protecting your hands in customer contact and loading',
    category: InstructionCategory.hygiene,
    scope: 'Applies to all employees whose hands are frequently in '
        'contact with consignments, vehicles and customers.',
    hazards: [
      'Drying out and cracking from frequent washing and disinfecting',
      'Skin irritation from dirt, cold and cleaning agents',
      'Passing on infections through customer contact',
      'Cuts and grazes on cardboard edges',
    ],
    protection: [
      'Apply a skin protection product before you start work',
      'Wash your hands after using the toilet, before breaks and after '
          'loading work',
      'Rub disinfectant in completely and let it dry — do not wipe it off',
      'Use a skin care product after washing',
      'Protective gloves for sharp-edged or dirty consignments',
      'Take off rings and watches for loading work',
    ],
    onFailure: [
      'Report the activity if redness, itching or cracks persist',
      'Stop using a product you cannot tolerate — ask for an alternative',
    ],
    onAccident: [
      'Clean and dress cuts and grazes immediately',
      'Entry in the Verbandbuch (first aid log), even for small injuries',
      'See a doctor if there are signs of inflammation',
    ],
    maintenance: [
      'Check the fill level of the soap, disinfectant and skin care '
          'dispensers',
      'Report empty or defective dispensers',
    ],
  ),

  // ─────────────────────────────────────────── Arbeitsplatz / Workplace
  OperatingInstruction(
    id: 'baw_bildschirm',
    title: 'Display screen workstation',
    subtitle: 'Dispatch planning and office work',
    category: InstructionCategory.workplace,
    scope: 'Applies to employees who work mainly at a screen — in '
        'particular dispatchers and administration.',
    hazards: [
      'Eye trouble from glare and long periods of focusing',
      'Tension in the neck, shoulders and back',
      'Tendon sheath irritation from an awkward hand and arm position',
      'Tripping over cables',
    ],
    protection: [
      'Top edge of the screen roughly at eye level, viewing distance '
          '50–70 cm',
      'Place the screen sideways on to the window — not in front of it or '
          'facing it',
      'Choose a seat height where your forearms and upper arms form '
          'roughly a right angle',
      'Feet flat on the floor or on a footrest',
      'Change your posture regularly, short breaks looking into the '
          'distance',
      'Route and secure the cables',
    ],
    onFailure: [
      'Report flickering or defective screens and lights',
      'Stop using defective chairs',
    ],
    onAccident: [
      'Inform your supervisor if the trouble persists',
      'Have your entitlement to occupational health care and to display '
          'screen glasses checked',
    ],
    maintenance: [
      'Keep the screen and input devices clean',
      'Check the workplace lighting regularly',
    ],
  ),
];
