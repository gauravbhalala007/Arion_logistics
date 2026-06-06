// lib/data/driver_faq_keys.dart

class DriverFaqNode {
  final String qKey;
  final String aKey;
  final List<DriverFaqNode> children;

  const DriverFaqNode({
    required this.qKey,
    required this.aKey,
    this.children = const [],
  });
}

class DriverFaqKeys {
  /// Root FAQ tree (supports nested sub-questions like 7 -> 7.1 -> 7.1.1 ...)
  static const items = <DriverFaqNode>[
    DriverFaqNode(qKey: 'faq_q1', aKey: 'faq_a1'),
    DriverFaqNode(qKey: 'faq_q2', aKey: 'faq_a2'),
    DriverFaqNode(qKey: 'faq_q3', aKey: 'faq_a3'),
    DriverFaqNode(qKey: 'faq_q4', aKey: 'faq_a4'),
    DriverFaqNode(qKey: 'faq_q5', aKey: 'faq_a5'),

    // 7 - Weekly Scorecard (has sub sections in the PDF)
    DriverFaqNode(
      qKey: 'faq_q7',
      aKey: 'faq_a7',
      children: [
        DriverFaqNode(
          qKey: 'faq_q7_1',
          aKey: 'faq_a7_1',
          children: [
            DriverFaqNode(qKey: 'faq_q7_1_1', aKey: 'faq_a7_1_1'),
            DriverFaqNode(qKey: 'faq_q7_1_2', aKey: 'faq_a7_1_2'),
            DriverFaqNode(qKey: 'faq_q7_1_3', aKey: 'faq_a7_1_3'),
            DriverFaqNode(qKey: 'faq_q7_1_4', aKey: 'faq_a7_1_4'),
          ],
        ),
        DriverFaqNode(
          qKey: 'faq_q7_2',
          aKey: 'faq_a7_2',
          children: [
            DriverFaqNode(qKey: 'faq_q7_2_1', aKey: 'faq_a7_2_1'),
            DriverFaqNode(qKey: 'faq_q7_2_2', aKey: 'faq_a7_2_2'),
          ],
        ),
        DriverFaqNode(
          qKey: 'faq_q7_3',
          aKey: 'faq_a7_3',
          children: [
            DriverFaqNode(qKey: 'faq_q7_3_1', aKey: 'faq_a7_3_1'),
          ],
        ),
        DriverFaqNode(qKey: 'faq_q7_4', aKey: 'faq_a7_4'),
        DriverFaqNode(qKey: 'faq_q7_5', aKey: 'faq_a7_5'),
        DriverFaqNode(qKey: 'faq_q7_6', aKey: 'faq_a7_6'),
        DriverFaqNode(qKey: 'faq_q7_7', aKey: 'faq_a7_7'),
        DriverFaqNode(qKey: 'faq_q7_8', aKey: 'faq_a7_8'),
      ],
    ),

    DriverFaqNode(qKey: 'faq_q8', aKey: 'faq_a8'),
    DriverFaqNode(qKey: 'faq_q9', aKey: 'faq_a9'),
    DriverFaqNode(qKey: 'faq_q10', aKey: 'faq_a10'),
    DriverFaqNode(qKey: 'faq_q11', aKey: 'faq_a11'),
    DriverFaqNode(qKey: 'faq_q12', aKey: 'faq_a12'),
    DriverFaqNode(qKey: 'faq_q13', aKey: 'faq_a13'),
    DriverFaqNode(qKey: 'faq_q14', aKey: 'faq_a14'),
    DriverFaqNode(qKey: 'faq_q15', aKey: 'faq_a15'),
    DriverFaqNode(qKey: 'faq_q16', aKey: 'faq_a16'),
    DriverFaqNode(qKey: 'faq_q17', aKey: 'faq_a17'),
    DriverFaqNode(qKey: 'faq_q18', aKey: 'faq_a18'),
    DriverFaqNode(qKey: 'faq_q19', aKey: 'faq_a19'),
    DriverFaqNode(qKey: 'faq_q20', aKey: 'faq_a20'),
  ];
}
