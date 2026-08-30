// lib/services/work_contracts/work_contract_texts.dart
//
// Vertragstexte für Work Contracts (Arion Logistics GmbH).
//
// Quelle: Ogletree-Muster "Befristeter/Unbefristeter Arbeitsvertrag
// Vollzeit oder Teilzeit" (Jan/Feb 2025). Auf Vorgabe von Arion wurden die
// Abschnitte "Auslagen" und "Pauschaler Verpflegungsmehraufwand" komplett
// entfernt — Spesen tauchen in keinem Vertrag auf.
//
// Die Paragraphen werden fortlaufend nummeriert; Querverweise werden über
// Platzhalter-Tokens ({S_*}) gesetzt und nach der Nummerierung aufgelöst,
// damit sie bei Varianten (mit/ohne Zusatzparagraph) immer stimmen.
//
// ⚠️ Die Zusatzparagraphen "Werkstudent" und "Geringfügige Beschäftigung"
// sind KEINE Ogletree-Texte, sondern Entwürfe auf Basis üblicher Klauseln —
// vor produktiver Nutzung anwaltlich prüfen lassen.

import 'work_contract_model.dart';

class WcSection {
  WcSection(this.title, this.clauses, {this.token});
  final String title;
  final List<String> clauses;

  /// Für Querverweise, z. B. 'S_POSITION'.
  final String? token;
}

/// Präambel (vor § 1, unnummeriert).
const String wcPreamble =
    'Der Arbeitnehmer soll als Paketzusteller für den Arbeitgeber tätig '
    'werden. Voraussetzung für die Ausübung der Tätigkeit des Arbeitnehmers '
    'ist die Teilnahme an einem zweitägigen Training beim Kunden und das '
    'erfolgreiche Bestehen einer am zweiten Tag stattfindenden Prüfung, was '
    'in der Regel einige Tage vor der Arbeitsaufnahme erfolgt. Im Anschluss '
    'an die Prüfung findet ein zweitägiges Ride Along statt, in dessen '
    'Rahmen der Arbeitnehmer an einer oder mehreren Touren zu '
    'Beobachtungszwecken teilnimmt. Zwischen Training und Ride Along und '
    'der eigentlichen Arbeitsaufnahme wird keine Arbeitsleistung und keine '
    'Vergütung geschuldet.\n\n'
    'Vor diesem Hintergrund vereinbaren die Parteien folgendes:';

/// Baut die nummerierten Paragraphen für die gewählte Variante.
List<WcSection> wcBuildSections(WorkContractData d) {
  final s = <WcSection>[];

  // ── § Position / Beginn / Befristung ────────────────────────────────
  final pos = <String>[
    'Der Arbeitnehmer wird als Paketzusteller eingestellt. In dieser '
        'Funktion erbringt der Arbeitnehmer sämtliche Aufgaben, die mit der '
        'Auslieferung von Paketen im Zusammenhang stehen (u.a. das Führen '
        'von Fahrzeugen, Auslieferung/Zustellung von Paketen und '
        'Warensendungen, Wagenpflege, Be- und Entladen der Fahrzeuge, '
        'Betanken der Fahrzeuge).',
    'Das Arbeitsverhältnis beginnt am ersten Tag des Trainings, welches '
        'voraussichtlich in der KW ${d.trainingWeek.isEmpty ? '____' : d.trainingWeek} '
        'stattfindet. Das genaue Datum und Uhrzeit des Trainings wird der '
        'Arbeitgeber dem Arbeitnehmer angemessen im Voraus mitteilen. Für '
        'die Teilnahme am Training und der Prüfung sowie für das Ride Along '
        'erhält der Arbeitnehmer eine Vergütung in Höhe von EUR '
        '${wcEur(d.hourlyWage)} brutto pro Stunde, zahlbar mit dem '
        'regulären Gehaltslauf des Folgemonats.',
    'Der Arbeitnehmer nimmt seine Tätigkeit am ${wcDate(d.startDate)}, '
        'frühestens jedoch nach Bestehen der Prüfung und nach Teilnahme am '
        'Ride Along auf („Arbeitsaufnahme“). Das Bestehen der Prüfung ist '
        'Voraussetzung für die Arbeitsaufnahme und Ausübung der Tätigkeit '
        'des Arbeitnehmers. Zwischen Training und Ride Along auf der einen '
        'Seite und Arbeitsaufnahme auf der anderen Seite wird weder '
        'Arbeitsleistung noch Vergütung oder Urlaub geschuldet.',
    if (d.fixedTerm)
      'Das Arbeitsverhältnis ist befristet bis zum ${wcDate(d.endDate)} '
          'und endet mit Ablauf der Befristung, ohne dass es einer '
          'Kündigung bedarf.',
    'Der Arbeitnehmer erbringt seine Tätigkeit an verschiedenen Orten, '
        'abhängig von der jeweiligen Tourenplanung.',
    'Der Arbeitgeber ist berechtigt, soweit dies zumutbar ist, den '
        'Arbeitnehmer jederzeit im Rahmen billigen Ermessens ein anderes, '
        'seinen Fähigkeiten und Qualifikationen entsprechendes Aufgaben- '
        'und Verantwortungsgebiet ohne Einschränkung seiner Vergütung zu '
        'übertragen und/oder den Arbeitnehmer an einen anderen Ort zu '
        'versetzen, soweit die übertragene Tätigkeit gleichwertig ist. Im '
        'Falle der Versetzung an einen anderen Arbeitsort wird der '
        'Arbeitgeber eine angemessene Ankündigungsfrist einhalten.',
  ];
  s.add(WcSection(
    d.fixedTerm
        ? 'Position, Beginn des Arbeitsverhältnisses, Training, '
            'Arbeitsaufnahme, Befristung, Arbeitsort, Versetzungsvorbehalt'
        : 'Position, Beginn des Arbeitsverhältnisses, Training, '
            'Arbeitsaufnahme, Arbeitsort, Versetzungsvorbehalt',
    pos,
    token: 'S_POSITION',
  ));

  // ── § Arbeitszeit ───────────────────────────────────────────────────
  s.add(WcSection(
    'Arbeitszeit, Mehrarbeit und Überstunden, Anordnung von Kurzarbeit',
    [
      'Die regelmäßige wöchentliche Arbeitszeit beträgt '
          '${wcHours(d.hoursPerWeek)} Stunden'
          '${d.type.daysPerWeek < 5 ? ', verteilt auf ${d.type.daysPerWeek} Arbeitstage pro Woche' : ''}.',
      'Die Lage der Arbeitszeit sowie der Pausen richtet sich nach dem '
          'betrieblichen Bedarf unter Berücksichtigung der dafür geltenden '
          'gesetzlichen Bestimmungen.',
      'Bei einer täglichen Arbeitszeit von mehr als 6 Stunden hat der '
          'Arbeitnehmer Anspruch auf eine unbezahlte Ruhepause von '
          'mindestens 30 Minuten (bzw. bei einer täglichen Arbeitszeit von '
          'mehr als 9 Stunden von 45 Minuten). Die Ruhepausen können in '
          'mehrere Abschnitte von mindestens 15 Minuten aufgeteilt werden. '
          'Spätestens nach 6 Stunden Arbeit ist die Arbeit durch eine '
          'Ruhepause zu unterbrechen. Nach Beendigung der täglichen '
          'Arbeitszeit ist eine Ruhezeit von mindestens 11 Stunden '
          'einzuhalten.',
      'Der Arbeitnehmer ist verpflichtet, soweit betriebliche Belange dies '
          'erfordern, im Rahmen des gesetzlich Zulässigen auf Anordnung des '
          'Arbeitgebers Mehrarbeit und Überstunden zu leisten. Der '
          'Arbeitnehmer ist jedoch nicht dazu berechtigt, Mehrarbeit und '
          'Überstunden zu leisten, ohne dass diese ausdrücklich angeordnet '
          'oder vorab genehmigt wurden. Bei der Anordnung von Mehrarbeit '
          'und Überstunden hat der Arbeitgeber die berechtigten Belange des '
          'Arbeitnehmers zu berücksichtigen. Die tägliche Arbeitszeit darf '
          'dabei im Regelfall maximal 10 Stunden betragen. Die maximale '
          'Wochenarbeitszeit darf im Durchschnitt von 6 Kalendermonaten '
          'bzw. 24 Kalenderwochen 48 Stunden nicht überschreiten.',
      'Der Arbeitnehmer verpflichtet sich und erklärt sich bereit, auf '
          'entsprechende Anordnung des Arbeitgebers hin auch Kurzarbeit zu '
          'leisten für den Fall, dass die Voraussetzungen für die Gewährung '
          'von Kurzarbeitergeld erfüllt sind; bei der Anordnung von '
          'Kurzarbeit hat der Arbeitgeber gegenüber dem Arbeitnehmer eine '
          'Ankündigungsfrist von 4 Wochen einzuhalten. Die Kurzarbeit kann '
          'nur für die Dauer von bis zu 12 Monaten und nur mit Kurzarbeit '
          'von mindestens 50% der bisherigen Arbeitszeit angeordnet werden '
          'und nur dann, wenn entweder der ganze Betrieb oder zumindest die '
          'Betriebsabteilung des Arbeitnehmers betroffen ist und die in '
          'Satz 1 genannten Voraussetzungen erfüllt sind.',
    ],
  ));

  // ── § Vergütung ─────────────────────────────────────────────────────
  final payClause = d.pay == WcPay.monthly
      ? 'Der Arbeitnehmer erhält für seine Tätigkeit eine monatliche '
          'Bruttogrundvergütung in Höhe von EUR ${wcEur(d.monthlySalary)}. '
          'Die Vergütung ist jeweils zum 15. des Folgemonats fällig. Die '
          'Zahlung erfolgt bargeldlos auf ein von dem Arbeitnehmer zu '
          'benennendes Konto.'
      : 'Der Arbeitnehmer erhält für seine Tätigkeit eine Vergütung in '
          'Höhe von EUR ${wcEur(d.hourlyWage)} brutto pro Stunde. Die '
          'Vergütung ist jeweils zum 15. des Folgemonats fällig. Die '
          'Zahlung erfolgt bargeldlos auf ein von dem Arbeitnehmer zu '
          'benennendes Konto.';
  s.add(WcSection(
    'Vergütung, Überstunden, Freiwilligkeitsvorbehalt, Abtretungs- und '
        'Verpfändungsverbot, Gehaltspfändung',
    [
      payClause,
      'Angeordnete bzw. genehmigte Mehrarbeits- und Überstunden werden '
          'nach Wahl des Arbeitgebers in Geld oder durch Freizeit '
          'ausgeglichen. Soweit der Ausgleich in Geld erfolgt, berechnet '
          'sich die Vergütung nach der anteiligen '
          '${d.pay == WcPay.monthly ? 'Bruttogrundvergütung' : 'Bruttovergütung'} '
          'gem. Abs. 1. Eine etwaige Überstundenvergütung wird dem '
          'Arbeitnehmer jeweils mit der Gehaltsabrechnung des Folgemonats '
          'überwiesen.',
      'Für den Fall, dass der Arbeitgeber zusätzlich zu der nach diesem '
          'Arbeitsvertrag geschuldeten Vergütung etwaige Sonderleistungen '
          'erbringen sollte, handelt es sich um freiwillige Leistungen, auf '
          'die der Arbeitnehmer keinen Rechtsanspruch hat. Auch aus einer '
          'einmaligen oder mehrmaligen Gewährung einer etwaigen '
          'Sonderleistung entsteht kein Rechtsanspruch des Arbeitnehmers '
          'für die Zukunft. Die Sätze 1 und 2 gelten nicht, wenn die '
          'Leistungen auf einer individuellen Vertragsabrede mit dem '
          'Arbeitnehmer beruhen.',
      'Eine Abtretung oder Verpfändung aller Ansprüche aus dem '
          'Arbeitsverhältnis ist ausgeschlossen. Der Arbeitnehmer darf '
          'seine Vergütungsansprüche oder sonstige Ansprüche gegen den '
          'Arbeitgeber weder abtreten noch verpfänden. Der Arbeitgeber ist '
          'im Falle einer Pfändung berechtigt, 3% des jeweils '
          'einbehaltenen und an den Gläubiger abzuführenden Betrages als '
          'Ersatz der entstehenden Kosten zu berechnen und einzubehalten. '
          'Dieser Anspruch gilt jeweils als vor der Gehaltszahlung '
          'entstanden. Dem Arbeitnehmer bleibt der Nachweis gestattet, dass '
          'dem Arbeitgeber überhaupt kein Schaden entstanden ist oder ein '
          'niedrigerer Schaden als die 3% des jeweils einbehaltenen und an '
          'den Gläubiger abzuführenden Betrags.',
      'Zu viel gezahltes Gehalt ist dem Arbeitgeber unverzüglich in voller '
          'Höhe, d.h. einschließlich hierauf entrichteter Steuern und '
          'Sozialversicherungsbeiträge, zurückzuzahlen. Der Arbeitnehmer '
          'verzichtet gegenüber diesem Anspruch des Arbeitgebers auf den '
          'Einwand, er sei nicht mehr bereichert und der Anspruch sei '
          'insoweit ausgeschlossen. Die Arbeitsvertragsparteien '
          'vereinbaren, dass von der vertraglichen Ausschlussfrist nach '
          '§ {S_AUSSCHLUSS} dieses Arbeitsvertrages Rückzahlungsansprüche '
          'wegen überzahlten Gehalts nicht erfasst werden.',
    ],
    token: 'S_VERGUETUNG',
  ));

  // ── § Urlaub ────────────────────────────────────────────────────────
  s.add(WcSection(
    'Urlaub',
    [
      'Der Arbeitnehmer hat Anspruch auf den gesetzlichen Mindesturlaub. '
          'Der gesetzliche Mindesturlaub beträgt auf Basis einer '
          '${d.type.daysPerWeek}-Tage-Woche ${d.vacationDays} Arbeitstage. '
          'Verteilt sich die regelmäßige Arbeitszeit auf weniger als 5 '
          'Arbeitstage pro Woche, berechnet sich der gesetzliche '
          'Mindesturlaub anteilig.',
      'Der Zeitpunkt des Urlaubs wird vom Arbeitgeber unter '
          'Berücksichtigung der betrieblichen Notwendigkeiten und der '
          'persönlichen Wünsche des Arbeitnehmers festgelegt.',
      'Für den Verfall des gesetzlichen Mindesturlaubs gelten die '
          'gesetzlichen Vorschriften. Über den gesetzlichen Mindesturlaub '
          'hinausgehender vertraglicher Urlaub verfällt, wenn er nicht bis '
          'zum 31. Dezember des jeweiligen Kalenderjahres genommen wird.',
      'Bei Beendigung des Arbeitsverhältnisses erfolgt eine etwaige '
          'Urlaubsabgeltung ausschließlich bis zur Höhe des gesetzlichen '
          'Urlaubsanspruchs. Ein etwa bereits genommener Urlaub wird auf '
          'den gesetzlichen Urlaubsanspruch angerechnet.',
    ],
  ));

  // ── § Arbeitsverhinderung ───────────────────────────────────────────
  s.add(WcSection(
    'Arbeitsverhinderung, Entgeltfortzahlung',
    [
      'Der Arbeitnehmer ist trotz der Einführung der elektronischen '
          'Arbeitsunfähigkeitsbescheinigung verpflichtet, dem Arbeitgeber '
          'jede Arbeitsverhinderung und ihre voraussichtliche Dauer '
          'unverzüglich anzuzeigen. Dabei hat der Arbeitnehmer den '
          'Arbeitgeber auf vordringlich zu erledigende Aufgaben '
          'hinzuweisen. Auf Verlangen sind die Gründe der '
          'Arbeitsverhinderung mitzuteilen.',
      'Jede krankheitsbedingte Arbeitsunfähigkeit hat der Arbeitnehmer '
          'sich ab dem ersten Tag der Erkrankung durch ein ärztliches '
          'Attest über das Bestehen der Arbeitsunfähigkeit sowie deren '
          'voraussichtlicher Dauer („Arbeitsunfähigkeitsbescheinigung“) '
          'bescheinigen zu lassen. Über die Dauer der bescheinigten '
          'Arbeitsunfähigkeit hat der Arbeitnehmer den Arbeitgeber '
          'unverzüglich (am selben Tag) zu informieren. Dauert die '
          'Arbeitsunfähigkeit länger als in der '
          'Arbeitsunfähigkeitsbescheinigung angegeben, ist der '
          'Arbeitnehmer verpflichtet, an dem auf das bescheinigte Ende der '
          'Arbeitsunfähigkeit folgenden Arbeitstag eine neue '
          'Arbeitsunfähigkeitsbescheinigung einzuholen. Auch in diesem Fall '
          'hat der Arbeitnehmer das Überschreiten der bescheinigten Zeit '
          'der Arbeitsunfähigkeit unverzüglich mitzuteilen.',
      'Beruht die Arbeitsunfähigkeit des Arbeitnehmers auf einer '
          'Verletzung oder sonstigen Beeinträchtigung durch einen Dritten, '
          'tritt der Arbeitnehmer hiermit dem Arbeitgeber alle gegen den '
          'Dritten bestehenden Schadensersatzansprüche insoweit ab, als der '
          'Arbeitgeber dem Arbeitnehmer das Arbeitsentgelt fortzahlt. Der '
          'Arbeitnehmer hat dem Arbeitgeber die zur Geltendmachung des '
          'Schadensersatzanspruchs gegenüber dem Dritten erforderlichen '
          'Informationen zu erteilen.',
      'Die Entgeltfortzahlung im Krankheitsfall richtet sich nach den '
          'gesetzlichen Bestimmungen.',
      'Ein Vergütungsanspruch gem. § 616 BGB für den Fall der '
          'kurzfristigen Arbeitsverhinderung ist ausgeschlossen. Dies gilt '
          'insbesondere auch für eine Verhinderung wegen der Pflege kranker '
          'Angehöriger.',
    ],
  ));

  // ── § Probezeit, Kündigung ──────────────────────────────────────────
  s.add(WcSection(
    'Probezeit, Kündigung, Freistellung',
    [
      if (d.fixedTerm)
        'Unbeschadet der in § {S_POSITION} vereinbarten Befristung ist das '
            'Arbeitsverhältnis für beide Parteien nach Maßgabe der '
            'nachstehenden Bestimmungen ordentlich kündbar.',
      'Es wird eine Probezeit von ${d.probationMonths} Monaten ab Beginn '
          'des Arbeitsverhältnisses vereinbart. Während der Probezeit kann '
          'das Arbeitsverhältnis von beiden Seiten mit einer Frist von 2 '
          'Wochen gekündigt werden.',
      'Nach Ablauf der Probezeit kann das Arbeitsverhältnis von beiden '
          'Parteien unter Einhaltung der gesetzlichen Kündigungsfrist gem. '
          '§ 622 BGB gekündigt werden. Eine für den Arbeitgeber kraft '
          'Gesetzes verbindliche Verlängerung der Kündigungsfrist oder eine '
          'Veränderung des Kündigungstermins gem. § 622 Abs. 2 BGB ist auch '
          'für den Arbeitnehmer verbindlich.',
      'Im Übrigen richtet sich das bei Kündigung einzuhaltende Verfahren, '
          'soweit in diesem Arbeitsvertrag nichts Abweichendes geregelt '
          'ist, nach den jeweils geltenden gesetzlichen Bestimmungen. Auf '
          'die 3-wöchige Klagefrist gem. §§ 4 KSchG, 17 TzBfG wird '
          'hingewiesen.',
      'Das Recht zur außerordentlichen Kündigung gem. § 626 BGB bleibt '
          'unberührt.',
      'Jede Kündigung bedarf gem. § 623 BGB der Schriftform.',
      'Unbeschadet der Möglichkeit, das Arbeitsverhältnis ordentlich zu '
          'kündigen, endet das Arbeitsverhältnis ohne Kündigung auch mit '
          'Ablauf des Monats, in dem der Arbeitnehmer die Altersgrenze für '
          'eine Regelaltersrente in der gesetzlichen Rentenversicherung '
          'erreicht hat, oder wenn dauerhaft eine volle Erwerbsminderung im '
          'Sinne des § 43 SGB VI festgestellt wird.',
      'Der Arbeitnehmer wird den Arbeitgeber unverzüglich über den Zugang '
          'eines Rentenbescheids unterrichten.',
      'Der Arbeitgeber ist im Falle der Kündigung des Arbeitsverhältnisses '
          'durch eine der Parteien dazu berechtigt, den Arbeitnehmer bei '
          'Vorliegen eines schutzwürdigen Interesses von seiner weiteren '
          'Tätigkeit für den Arbeitgeber freizustellen. Während der Zeit '
          'der Freistellung behält der Arbeitnehmer seinen Anspruch auf die '
          'vertragliche Vergütung. Im Falle einer unwiderruflichen '
          'Freistellung wird die Freistellungszeit auf etwaige Urlaubs- '
          'oder Freizeitausgleichansprüche angerechnet. Zwischenverdienst '
          'wird gem. § 615 S. 2 BGB angerechnet.',
    ],
  ));

  // ── § Verschwiegenheit ──────────────────────────────────────────────
  s.add(WcSection(
    'Verschwiegenheitspflicht, Behandlung von Gegenständen und Haftung',
    [
      'Der Arbeitnehmer ist verpflichtet, alle vertraulichen '
          'Angelegenheiten, insbesondere Betriebs- und '
          'Geschäftsgeheimnisse, des Arbeitgebers und mit ihm verbundener '
          'Unternehmen sowie insbesondere Informationen hinsichtlich der '
          'Auftraggeber des Arbeitgebers einschließlich dessen Endkunden, '
          'welche ihm bei Ausübung seiner Tätigkeiten für den Arbeitgeber '
          'zur Kenntnis gelangen (beispielsweise Geschäftsplanungen, '
          'Preise, Kosten, Routen und Einsatzpläne sowie Kunden- und '
          'Lieferantenlisten einschließlich der Adressen), oder die von dem '
          'Arbeitgeber als vertraulich bezeichnet werden, streng geheim zu '
          'halten. Dem Arbeitnehmer ist es nicht gestattet, vertrauliche '
          'Informationen des Arbeitgebers und der mit ihm verbundenen '
          'Unternehmen für andere Zwecke als für die Erfüllung seiner '
          'Verpflichtungen nach diesem Arbeitsvertrag zu verwenden. Im '
          'Zweifel ist der Arbeitnehmer verpflichtet, eine Weisung der '
          'Geschäftsleitung einzuholen, ob eine bestimmte Tatsache als '
          'vertraulich zu behandeln ist.',
      'Die Verpflichtung nach Abs. 1 gilt auch nach Beendigung des '
          'Arbeitsverhältnisses. Sollte die nachvertragliche '
          'Verschwiegenheitspflicht den Arbeitnehmer in seinem beruflichen '
          'Fortkommen unangemessen behindern, hat der Arbeitnehmer gegen '
          'den Arbeitgeber einen Anspruch auf Freistellung von dieser '
          'Pflicht.',
      'Der Arbeitgeber wird dem Arbeitnehmer bei Beginn des '
          'Arbeitsverhältnisses die zur Ausübung seiner Tätigkeiten '
          'erforderlichen Arbeitsmittel zur Verfügung stellen. Die Übergabe '
          'der Arbeitsmittel wird in einem Protokoll dokumentiert. Alle dem '
          'Arbeitnehmer überlassenen Arbeitsmittel (z.B. Dienstkleidung, '
          'Scanner, Handy, Autoschlüssel, Laptop usw.) stehen im '
          'Alleineigentum des Arbeitgebers und müssen sorgfältig behandelt '
          'werden und sind ausschließlich zu dienstlichen Zwecken zu '
          'verwenden.',
      'Zum Zeitpunkt der Beendigung des Arbeitsverhältnisses oder einer '
          'unwiderruflichen Freistellung wird der Arbeitnehmer dem '
          'Arbeitgeber unaufgefordert, während des Bestehens seines '
          'Arbeitsverhältnisses auf Aufforderung, alle in seinem Besitz '
          'befindlichen und in Abs. 3 genannten Gegenstände zurückgeben. '
          'Zurückbehaltungsrechte des Arbeitnehmers an diesen Gegenständen '
          'sind ausgeschlossen.',
      'Der Arbeitnehmer haftet für alle durch ihn verursachten Schäden an '
          'den Arbeitsmitteln nach den Grundsätzen des innerbetrieblichen '
          'Schadensausgleichs.',
    ],
    token: 'S_VERSCHWIEGENHEIT',
  ));

  // ── § Vertragsstrafe ────────────────────────────────────────────────
  s.add(WcSection(
    'Vertragsstrafe',
    [
      'Verstößt der Arbeitnehmer gegen die Verschwiegenheitspflicht aus '
          '§ {S_VERSCHWIEGENHEIT} Abs. 1 u. 2 dieses Arbeitsvertrages, so '
          'gilt für jeden Fall der Zuwiderhandlung eine Vertragsstrafe in '
          'Höhe eines Bruttomonatsgehalts als vereinbart. Die '
          'Geltendmachung weitergehender Schadensersatzansprüche durch den '
          'Arbeitgeber ist nicht ausgeschlossen.',
      'Tritt der Arbeitnehmer das Arbeitsverhältnis schuldhaft '
          'vertragswidrig nicht oder verspätet an, oder verweigert er '
          'vorübergehend unberechtigt die Arbeit, löst er das '
          'Arbeitsverhältnis ohne Einhaltung der maßgeblichen '
          'Kündigungsfrist auf oder wird der Arbeitgeber durch '
          'vertragswidriges Verhalten des Arbeitnehmers zur '
          'außerordentlichen Kündigung veranlasst, so hat der Arbeitnehmer '
          'dem Arbeitgeber eine Vertragsstrafe zu zahlen. Als '
          'Vertragsstrafe wird für den Fall der unterlassenen oder '
          'verspäteten Aufnahme der Arbeit, der vorübergehenden '
          'Arbeitsverweigerung und der Auflösung des Arbeitsverhältnisses '
          'ohne Einhaltung der maßgeblichen Kündigungsfrist gem. Satz 1 ein '
          'sich aus der Vergütung nach § {S_VERGUETUNG} Abs. 1 dieses '
          'Arbeitsvertrages zu errechnendes Bruttotagegeld für jeden Tag '
          'der Zuwiderhandlung vereinbart, insgesamt jedoch nicht mehr als '
          'die in der gesetzlichen Mindestkündigungsfrist ansonsten zu '
          'zahlende Vergütung. Im Übrigen beträgt die Vertragsstrafe ein '
          'Bruttomonatsgehalt.',
      'Die Geltendmachung eines über die Vertragsstrafe hinausgehenden '
          'Schadens bleibt hiervon ebenso unberührt wie das Recht des '
          'Arbeitgebers, das Arbeitsverhältnis zu kündigen.',
    ],
  ));

  // ── § Alkohol/Drogen ────────────────────────────────────────────────
  s.add(WcSection(
    'Alkohol-, Drogen-, Rauschmittel- und Rauchverbot',
    [
      'Der Arbeitnehmer ist darüber belehrt, dass in dem Betrieb des '
          'Arbeitgebers aus Sicherheitsgründen ein striktes Alkoholverbot '
          'und ein Verbot der Einnahme sonstiger Drogen/Rauschmittel '
          'bestehen. Der Konsum von Alkohol, Drogen oder Rauschmitteln '
          'während der Arbeitszeit ist untersagt. Ebenfalls untersagt ist '
          'die Arbeitsaufnahme unter Einwirkung alkoholischer Getränke, '
          'Drogen oder Rauschmitteln, die das Reaktionsvermögen oder die '
          'Arbeitsfähigkeit beeinflussen können.',
      'In allen Fahrzeugen gilt ein absolutes Rauchverbot.',
    ],
  ));

  // ── § Untersuchungen ────────────────────────────────────────────────
  s.add(WcSection(
    'Verdachtsunabhängige ärztliche Untersuchungen, Teilnahme an Alkohol- '
        'oder Drogenscreenings, Entbindung von der Schweigepflicht',
    [
      'Der Arbeitnehmer verpflichtet sich, sich auf Verlangen des '
          'Arbeitgebers regelmäßig hinsichtlich der gesundheitlichen '
          'Eignung für die übernommene/n Arbeitsaufgabe/n ärztlich oder '
          'nicht-ärztlich untersuchen zu lassen. Dies erfasst auch '
          '(Blut-)Untersuchungen bzw. die Teilnahme an Alkohol- bzw. '
          'Drogenscreenings zur (vorbeugenden) Klärung des Bestehens einer '
          'Alkohol- bzw. Drogenabhängigkeit oder Arbeitsunfähigkeit.',
      'Außerhalb der regelmäßigen Untersuchungen bzw. Teilnahme an '
          'Alkohol- oder Drogenscreenings nach Abs. 1 erklärt sich der '
          'Arbeitnehmer darüber hinaus bereit, sich auf Verlangen des '
          'Arbeitgebers hinsichtlich der gesundheitlichen Eignung für die '
          'übernommene/n Arbeitsaufgabe/n untersuchen zu lassen bzw. an '
          'Alkohol- oder Drogenscreenings teilzunehmen, wenn tatsächliche '
          'Anhaltspunkte dafür vorliegen (z.B. Verhaltensauffälligkeit, '
          'Alkoholgeruch), die Zweifel an der fortdauernden Eignung des '
          'Arbeitnehmers, Bestehen einer Alkohol- oder Drogenabhängigkeit '
          'oder der Arbeitsfähigkeit des Arbeitnehmers begründen bzw. ein '
          'Wechsel der Tätigkeit oder des Arbeitsplatzes beabsichtigt ist.',
      'Die durch eine ärztliche Untersuchung oder Teilnahme an den '
          'Alkohol- oder Drogenscreenings nach Abs. 1 bzw. Abs. 2 '
          'anfallenden Kosten werden vom Arbeitgeber übernommen. Der '
          'Arbeitnehmer entbindet – für den Fall einer ärztlichen '
          'Untersuchung – den untersuchenden Arzt insoweit von der '
          'ärztlichen Schweigepflicht, als dass das Untersuchungsergebnis '
          'Einfluss auf die Erfüllung der arbeitsvertraglich '
          'vorausgesetzten Einsatzfähigkeit des Arbeitnehmers haben kann. '
          'Er wird alle erforderlichen Erklärungen unverzüglich abgeben, '
          'damit der Arzt dem Arbeitgeber (nur) das Ergebnis der '
          'Untersuchung (Eignung oder Nichteignung für die geschuldete '
          'Tätigkeit) mitteilt.',
    ],
  ));

  // ── § Dienstfahrzeug ────────────────────────────────────────────────
  s.add(WcSection(
    'Dienstfahrzeug, Fahrerlaubnis, Mitführen von Ausweisdokumenten',
    [
      'Der Arbeitgeber stellt dem Arbeitnehmer zur Erfüllung seiner '
          'vertraglichen Pflichten nach Maßgabe der jeweils geltenden '
          'betrieblichen Bestimmungen ein Dienstfahrzeug zur Verfügung. '
          'Eine private Nutzung des Dienstfahrzeugs ist nicht gestattet. '
          'Der Arbeitgeber weist darauf hin, dass zur untersagten privaten '
          'Nutzung auch die Nutzung des Dienstfahrzeuges für den Weg von '
          'der Wohnung des Arbeitnehmers zum Ort der Arbeitsaufnahme '
          'gehört.',
      'Das Dienstfahrzeug ist im Rahmen des vertraglichen '
          'Verwendungszwecks sachgemäß und schonend zu behandeln, stets in '
          'einem betriebs- und verkehrssicheren Zustand zu erhalten und vor '
          'unberechtigtem Zugriff Dritter zu schützen. Auch eine '
          'Überlassung an andere Mitarbeiter des Arbeitgebers ist nur mit '
          'dessen ausdrücklicher Zustimmung gestattet.',
      'Bei einer unbefugten Überlassung des Dienstfahrzeuges an eine '
          'dritte Person haftet der Arbeitnehmer für jeden Schaden '
          'unabhängig von eigenem Verschulden, soweit nicht eine '
          'Versicherung eintritt.',
      'Der Arbeitnehmer ist verpflichtet, am Dienstfahrzeug auftretende '
          'Mängel oder Beschädigungen, Unfälle oder Diebstahl unverzüglich '
          'dem Arbeitgeber mitzuteilen. Bei sämtlichen '
          'Kraftfahrzeugunfällen ist in jedem Fall die Polizei '
          'hinzuzuziehen, unabhängig davon, wer den Unfall verschuldet hat. '
          'Die Abgabe eines Schuldanerkenntnisses ist dem Arbeitnehmer '
          'nicht gestattet. Der Arbeitnehmer haftet dem Arbeitgeber '
          'gegenüber nach den Grundsätzen des innerbetrieblichen '
          'Schadensausgleichs.',
      'Auf Verlangen des Arbeitgebers hat der Arbeitnehmer das '
          'Dienstfahrzeug unverzüglich an den Arbeitgeber herauszugeben. '
          'Die Rückgabe des Dienstfahrzeuges hat an den Arbeitgeber an '
          'dessen Geschäftssitz oder auf Anweisung des Arbeitgebers an '
          'einem anderen Ort zu erfolgen.',
      'Ein Zurückbehaltungsrecht des Arbeitnehmers, gleich aus welchem '
          'Grund, ist ausgeschlossen.',
      'Der Arbeitnehmer versichert unter Vorlage seines Führerscheins, '
          'dass er im Besitz einer gültigen Fahrerlaubnis ist, die ihn '
          'berechtigt, ein Kraftfahrzeug zu führen.',
      'Der Arbeitnehmer ist verpflichtet, bei – auch nur vorübergehendem – '
          'Verlust seiner Fahrerlaubnis oder bei sonstiger Beschränkung '
          'unverzüglich die Nutzung des Dienstfahrzeuges einzustellen und '
          'den Arbeitgeber von dem Verlust bzw. der Beschränkung '
          'einschließlich vorübergehender Fahrverbote in Textform zu '
          'informieren. Darüber hinaus ist der Arbeitnehmer auf Verlangen '
          'des Arbeitgebers stets zur Vorlage seines Führerscheins zum '
          'Zweck des Nachweises der Fahrerlaubnis verpflichtet.',
      'Der Arbeitnehmer hat alle sich aus dem Betrieb und der Haltung des '
          'Dienstfahrzeuges ergebenden gesetzlichen Verpflichtungen zu '
          'erfüllen. Dies gilt insbesondere für die Vorschriften des '
          'Straßenverkehrsgesetzes (StVG), der Straßenverkehrsordnung '
          '(StVO) und der Straßenverkehrszulassungsordnung (StVZO). Diese '
          'Verpflichtungen bestehen auch unmittelbar gegenüber dem '
          'Arbeitgeber. Der Arbeitnehmer wird darauf hingewiesen, dass er '
          'verpflichtet ist, seinen Personalausweis, Pass, Passersatz oder '
          'Ausweisersatz mitzuführen und diesen auf Verlangen den Behörden '
          'der Zollverwaltung vorzulegen.',
    ],
  ));

  // ── § Dienstkleidung ────────────────────────────────────────────────
  s.add(WcSection(
    'Dienstkleidung',
    [
      'Der Arbeitnehmer ist dazu verpflichtet, die ihm vom Arbeitgeber zur '
          'Verfügung gestellte Dienstkleidung während seiner Tätigkeit für '
          'den Arbeitgeber zu tragen.',
      'Dem Arbeitnehmer ist es nicht gestattet, die Dienstkleidung '
          'außerhalb seiner Arbeitszeit zu tragen. Ausgenommen hiervon ist '
          'der Weg von der Wohnung des Arbeitnehmers zum Ort der '
          'Arbeitsaufnahme.',
      'Der Arbeitnehmer hat auf ein gepflegtes Äußeres zu achten. Er hat '
          'die Dienstkleidung sorgfältig zu behandeln und zu pflegen. Auf '
          '§ {S_VERSCHWIEGENHEIT} Abs. 3 und 4 dieses Arbeitsvertrages '
          'wird verwiesen.',
    ],
  ));

  // ── § Ausschlussfristen ─────────────────────────────────────────────
  s.add(WcSection(
    'Ausschlussfristen',
    [
      'Alle beiderseitigen Ansprüche aus dem Arbeitsverhältnis und solche, '
          'die mit dem Arbeitsverhältnis in Verbindung stehen, verfallen, '
          'wenn sie nicht innerhalb von 3 Monaten nach der Fälligkeit '
          'gegenüber der anderen Vertragspartei mindestens in Textform '
          'erhoben werden. Die Nichteinhaltung dieser Ausschlussfrist führt '
          'zum Verlust des Anspruchs.',
      'Lehnt die Gegenseite die Erfüllung des Anspruchs ab oder erklärt '
          'sie sich nicht innerhalb von 2 Wochen nach der Geltendmachung '
          'des Anspruchs, so verfällt dieser, wenn er nicht innerhalb von 3 '
          'Monaten nach der Ablehnung oder dem Fristablauf gerichtlich '
          'geltend gemacht wird. Die Nichteinhaltung dieser Ausschlussfrist '
          'führt zum Verlust des Anspruchs.',
      'Diese Ausschlussfristen der Abs. 1 u. 2 finden keine Anwendung auf '
          'unverzichtbare Rechte, z.B. nach dem Mindestlohngesetz, '
          'Arbeitnehmerentsendegesetz, Arbeitnehmerüberlassungsgesetz oder '
          'andere nach staatlichem Recht zwingende '
          'Mindestarbeitsbedingungen, Ansprüche aus Vorsatz oder '
          'unerlaubter Handlung, Ansprüche, die aus einer Verletzung des '
          'Lebens, des Körpers oder der Gesundheit resultieren sowie '
          'sonstige Ansprüche auf Grundlage von Gesetzen, Tarifverträgen '
          'und Betriebsvereinbarungen, auf die nicht oder nicht ohne die '
          'Zustimmung Dritter verzichtet werden kann.',
    ],
    token: 'S_AUSSCHLUSS',
  ));

  // ── § Vertraulichkeit (DSGVO) ───────────────────────────────────────
  s.add(WcSection(
    'Verpflichtung zur Vertraulichkeit',
    [
      'Der Arbeitnehmer verpflichtet sich bei der Verarbeitung '
          'personenbezogener Daten zur Vertraulichkeit. Die '
          'Verpflichtungserklärung zur Vertraulichkeit und zur Einhaltung '
          'der datenschutzrechtlichen Anforderungen nach der '
          'Datenschutz-Grundverordnung (DSGVO) ist diesem Arbeitsvertrag '
          'als Anlage beigefügt.',
    ],
  ));

  // ── § Nebentätigkeit ────────────────────────────────────────────────
  s.add(WcSection(
    'Nebentätigkeit und Wettbewerb',
    [
      'Der Arbeitnehmer verpflichtet sich, ohne vorherige Zustimmung des '
          'Arbeitgebers keine Nebentätigkeiten aufzunehmen. Der Arbeitgeber '
          'hat seine Zustimmung zu geben, wenn nicht seine berechtigten '
          'Interessen dagegensprechen. Der Arbeitgeber ist berechtigt, eine '
          'erteilte Zustimmung zu einer Nebentätigkeit für die Zukunft zu '
          'widerrufen, wenn die Voraussetzungen für ihre Erteilung nicht '
          'oder nicht mehr vorliegen.',
      'Während des Bestehens dieses Arbeitsvertrages ist es dem '
          'Arbeitnehmer untersagt, direkt oder indirekt (z.B. als '
          'Leiharbeitnehmer), als freier Mitarbeiter oder als Arbeitnehmer '
          'für ein mit dem Arbeitgeber in Wettbewerb stehendes Unternehmen '
          'zu arbeiten oder eigene unternehmerische Tätigkeiten zu '
          'entfalten, die mit dem Arbeitgeber in Konkurrenz treten '
          'könnten.',
      'Während des Bestehens dieses Arbeitsvertrages ist es dem '
          'Arbeitnehmer ebenfalls nicht gestattet, sich direkt oder '
          'indirekt (z.B. über Dritte) an einem im Wettbewerb zu dem '
          'Arbeitgeber stehenden Unternehmen zu beteiligen. Ausgenommen '
          'hiervon sind bloße Finanzbeteiligungen.',
    ],
  ));

  // ── § Werkstudent (nur Werkstudenten-Vertrag) ───────────────────────
  if (d.isWerkstudent) {
    s.add(WcSection(
      'Werkstudentenstatus',
      [
        'Die Beschäftigung erfolgt als Werkstudententätigkeit. '
            'Voraussetzung für den Abschluss und den Fortbestand dieses '
            'Arbeitsvertrages ist, dass der Arbeitnehmer als ordentlicher '
            'Studierender an einer Hochschule oder Fachhochschule '
            'immatrikuliert ist. Der Arbeitnehmer legt dem Arbeitgeber zu '
            'Beginn des Arbeitsverhältnisses sowie unaufgefordert zu Beginn '
            'jedes weiteren Semesters eine aktuelle '
            'Immatrikulationsbescheinigung vor.',
        'Während der Vorlesungszeit darf die wöchentliche Arbeitszeit 20 '
            'Stunden nicht überschreiten. In der vorlesungsfreien Zeit kann '
            'die Arbeitszeit im Rahmen der gesetzlichen Bestimmungen '
            'erhöht werden.',
        'Der Arbeitnehmer verpflichtet sich, dem Arbeitgeber die '
            'Exmatrikulation, die Beendigung oder Unterbrechung des '
            'Studiums sowie sonstige Umstände, die den Werkstudentenstatus '
            'im Sinne der sozialversicherungsrechtlichen Regelungen '
            'entfallen lassen, unverzüglich mitzuteilen.',
      ],
    ));
  }

  // ── § Geringfügige Beschäftigung (nur Minijob) ──────────────────────
  if (d.isMinijob) {
    s.add(WcSection(
      'Geringfügige Beschäftigung',
      [
        'Die Beschäftigung erfolgt als geringfügig entlohnte Beschäftigung '
            'im Sinne des § 8 Abs. 1 Nr. 1 SGB IV. Das regelmäßige '
            'monatliche Arbeitsentgelt darf die jeweils geltende '
            'gesetzliche Geringfügigkeitsgrenze nicht überschreiten.',
        'Der Arbeitnehmer ist verpflichtet, dem Arbeitgeber weitere '
            'bestehende oder neu aufgenommene Beschäftigungen — '
            'einschließlich weiterer geringfügiger Beschäftigungen — '
            'unverzüglich anzuzeigen, damit die '
            'sozialversicherungsrechtliche Beurteilung der Beschäftigung '
            'korrekt erfolgen kann.',
        'Die Beschäftigung ist rentenversicherungspflichtig. Der '
            'Arbeitnehmer kann sich auf Antrag von der '
            'Rentenversicherungspflicht befreien lassen (§ 6 Abs. 1b '
            'SGB VI); ein entsprechender Antrag ist an den Arbeitgeber zu '
            'richten.',
      ],
    ));
  }

  // ── § Schlussbestimmungen ───────────────────────────────────────────
  s.add(WcSection(
    'Schlussbestimmungen',
    [
      'Der Arbeitnehmer wird dem Arbeitgeber alle Änderungen über die '
          'Angaben zu seiner Person, soweit sie für das Arbeitsverhältnis '
          'von Bedeutung sind, unverzüglich mitteilen. Der Arbeitnehmer '
          'versichert, unter der jeweils angegebenen Adresse postalisch '
          'erreichbar zu sein und dem Arbeitgeber Änderungen der '
          'Zustelladresse unverzüglich schriftlich mitzuteilen. Aus der '
          'Nichtbeachtung dieser Verpflichtung etwa entstehende Nachteile '
          'gehen zu Lasten des Arbeitnehmers.',
      'Dieser Arbeitsvertrag ersetzt sämtliche vorherigen Vereinbarungen '
          'der Parteien in Bezug auf das Arbeitsverhältnis, insbesondere '
          'vorherige Arbeitsverträge. Änderungen oder Ergänzungen dieses '
          'Arbeitsvertrages, einschließlich dieser Vorschrift, bedürfen zu '
          'ihrer Rechtswirksamkeit der Textform, sofern gesetzlich keine '
          'strengere Form zwingend ist. Davon abweichend sind auch formlos '
          'getroffene Änderungen und Ergänzungen dieses Arbeitsvertrages '
          'wirksam, wenn es sich hierbei um Individualabreden im Sinne von '
          '§ 305b BGB handelt.',
      'Sollte eine Bestimmung dieses Vertrages und/oder seine Änderung '
          'bzw. Ergänzungen unwirksam sein, so wird dadurch die Wirksamkeit '
          'des Vertrages im Übrigen nicht berührt. Die Vertragsparteien '
          'sind im Falle einer unwirksamen Bestimmung verpflichtet, über '
          'eine wirksame und zumutbare Ersatzregelung zu verhandeln, die '
          'dem von den Vertragsparteien mit der unwirksamen Bestimmung '
          'verfolgten wirtschaftlichen Zweck möglichst nahekommt. Dasselbe '
          'gilt für den Fall einer vertraglichen Lücke.',
      'Der Arbeitnehmer hat eine Ausfertigung dieses Arbeitsvertrages '
          'nebst Anlagen erhalten.',
    ],
  ));

  // ── § Aufenthaltserlaubnis (aufschiebende Bedingung) ────────────────
  s.add(WcSection(
    'Arbeits-/Aufenthaltserlaubnis, aufschiebende Bedingung',
    [
      'Dieser Arbeitsvertrag steht unter der aufschiebenden Bedingung, '
          'dass der Arbeitnehmer die rechtlichen Voraussetzungen für die '
          'Aufnahme und Ausübung der in § {S_POSITION} vorgesehenen '
          'Tätigkeit für den Arbeitgeber erfüllt und die gegebenenfalls '
          'notwendigen Arbeits- und/oder Aufenthaltsgenehmigung durch den '
          'Arbeitnehmer sowie sonstiger für die Aufnahme und Ausübung der '
          'vertraglichen Tätigkeit erforderlichen gesetzlich oder '
          'behördlich vorgeschriebenen Genehmigungen und/oder Atteste '
          'vorliegen. Der Arbeitnehmer wird dem Arbeitgeber eine Kopie der '
          'erforderlichen Arbeits- und/oder Aufenthaltsgenehmigung oder '
          'sonstigen erforderlichen Genehmigungen und/oder Atteste vor '
          'Arbeitsantritt übergeben. Er ist verpflichtet, jede Änderung, '
          'insbesondere den Wegfall der Arbeits- und/oder '
          'Aufenthaltsgenehmigung, unverzüglich dem Arbeitgeber '
          'anzuzeigen.',
    ],
  ));

  return _resolveRefs(s);
}

/// Ersetzt {S_*}-Tokens durch die tatsächlichen Paragraphennummern.
List<WcSection> _resolveRefs(List<WcSection> sections) {
  final numbers = <String, int>{};
  for (var i = 0; i < sections.length; i++) {
    final t = sections[i].token;
    if (t != null) numbers[t] = i + 1;
  }
  String fix(String text) {
    var out = text;
    numbers.forEach((token, n) {
      out = out.replaceAll('{$token}', '$n');
    });
    return out;
  }

  return [
    for (final sec in sections)
      WcSection(fix(sec.title), [for (final c in sec.clauses) fix(c)]),
  ];
}

/// Anlage: DSGVO-Verpflichtung (identisch in Alt-Verträgen und
/// Ogletree-Mustern).
const String wcDsgvoAnnexTitle =
    'Verpflichtung zur Vertraulichkeit und zur Einhaltung der '
    'datenschutzrechtlichen Anforderungen nach der '
    'Datenschutz-Grundverordnung (DSGVO)';

const List<String> wcDsgvoAnnexBody = [
  'Der Arbeitnehmer verpflichtet sich, im Rahmen des mit dem Arbeitgeber '
      'geschlossenen Arbeitsverhältnisses, personenbezogene Daten nicht '
      'unbefugt zu erheben, zu verarbeiten oder zu nutzen. Ihm ist bekannt, '
      'dass es zu seinen arbeitsvertraglichen Aufgaben gehören kann, im '
      'Rahmen der Tätigkeit personenbezogene Daten, insbesondere '
      'Kundendaten, zu erheben, zu verarbeiten oder zu nutzen. Er hat dabei '
      'sämtliche Weisungen des Arbeitgebers zu beachten. Die im '
      'Zusammenhang mit der Tätigkeit des Arbeitnehmers vom Arbeitnehmer '
      'verarbeiteten Daten dürfen nur im Rahmen des Arbeitsverhältnisses '
      'genutzt werden. Dritten darf der Arbeitnehmer diese Daten nicht '
      'zugänglich machen.',
  'Vor diesem Hintergrund verpflichtet sich der Arbeitnehmer im Hinblick '
      'auf alle im Zusammenhang mit dem Arbeitsverhältnis verarbeiteter '
      'Daten auf die Wahrung der Vertraulichkeit personenbezogener Daten '
      'nach Art. 5 Abs. 1 f, Art. 32 Abs. 4 der '
      'Datenschutz-Grundverordnung (DSGVO).',
  'Diese Verpflichtung besteht auch nach Beendigung des '
      'Arbeitsverhältnisses fort.',
  'Verstöße gegen die Vertraulichkeit und vorgenannten Verpflichtungen '
      'können nach Art. 83 Abs. 4 DSGVO, §§ 42, 43 BDSG sowie ggf. nach '
      'anderen strafrechtlichen Vorschriften mit Geld- oder Freiheitsstrafe '
      'geahndet werden. Zudem kann eine Verletzung der Vertraulichkeit und '
      'der vorgenannten Verpflichtungen eine Verletzung '
      'arbeitsvertraglicher Pflichten darstellen, die arbeitsrechtliche '
      'Schritte bis hin zu einer außerordentlichen Kündigung nach sich '
      'ziehen kann.',
];

/// Zeitkontovereinbarung (Ogletree-Vorlage 08/2026), Klauseln 1–13.
/// Platzhalter werden beim Erzeugen gefüllt.
List<String> wcZeitkontoClauses(WorkContractData d) => [
      'Der Arbeitgeber führt zum Ausgleich von Auslastungsschwankungen für '
          'den Arbeitnehmer ein elektronisches Arbeitszeitkonto '
          '(„Arbeitszeitkonto“). Auf diesem wird die Abweichung zwischen '
          'der individuellen wöchentlichen Arbeitszeit '
          '(${wcHours(d.hoursPerWeek)} Stunden/Woche) und der tatsächlich '
          'geleisteten Arbeitszeit des Arbeitnehmers erfasst und dem '
          'Arbeitnehmer ein verstetigtes Arbeitsentgelt auf Basis der '
          'individuellen Arbeitszeit gezahlt.',
      'In das Arbeitszeitkonto werden Plus- und Minusstunden eingestellt. '
          'Plusstunden sind die über die individuelle wöchentliche '
          'Arbeitszeit hinaus geleisteten Arbeitsstunden/Woche des '
          'Arbeitnehmers („Zeitguthaben“). Minusstunden sind die von der '
          'individuellen Arbeitszeit abweichend weniger geleisteten '
          'Arbeitsstunden/Woche des Arbeitnehmers („Zeitschulden“). Die auf '
          'das Arbeitszeitkonto eingestellten Arbeitsstunden dürfen '
          'monatlich jeweils 50 % der vertraglich vereinbarten Arbeitszeit '
          'nicht übersteigen.',
      'Das Arbeitszeitkonto darf ein maximales Zeitguthaben in Höhe von 80 '
          'Plusstunden und eine maximale Zeitschuld in Höhe von 40 '
          'Minusstunden aufweisen („Spannbreite des Arbeitszeitkontos“). '
          'Auf dem Arbeitszeitkonto erfasste Plus- und Minusstunden werden '
          'automatisch miteinander saldiert.',
      'Sofern das Arbeitszeitkonto eine Zeitschuld von mehr als 40 Stunden '
          'ausweist, wird das monatliche Bruttogrundentgelt des '
          'Arbeitnehmers bei der nächsten Gehaltsauszahlung – bzw. sofern '
          'erforderlich, bei den nächsten Gehaltszahlungen – entsprechend '
          'um den 40 Minusstunden übersteigenden Gegenwert gekürzt.',
      'Ein Aufbau von Zeitguthaben über 80 Plusstunden hinaus ist nicht '
          'möglich, d.h. darüber hinausgehende Plusstunden werden nicht '
          'erfasst, sondern nach Wahl des Arbeitgebers in Freizeit '
          'ausgeglichen bzw. ausgezahlt.',
      'Zeitsalden innerhalb des Arbeitszeitkontos sind keine Mehrarbeit '
          'und werden dementsprechend ohne Zuschlag vergütet.',
      'Im Falle von Krankheit, Urlaub oder sonstiger Freistellung von der '
          'Arbeit auf Grundlage von verbindlichen internen Regelungen oder '
          'Gesetzen wird dem Arbeitszeitkonto des Arbeitnehmers seine für '
          'den entsprechenden Arbeitstag vorgesehene Sollarbeitszeit '
          'gutgeschrieben.',
      'Das Arbeitszeitkonto soll mindestens einmal im jeweiligen '
          'Kalenderjahr auf ein Zeitguthaben kleiner 40 Plusstunden '
          'zurückgeführt werden. In jedem Fall sind die auf dem '
          'Arbeitszeitkonto gutgeschriebenen Arbeitszeitstunden spätestens '
          'innerhalb eines Ausgleichszeitraums von 12 Kalendermonaten nach '
          'ihrer Erfassung auszugleichen.',
      'Zeitguthaben sind vorrangig durch Freizeitnahme, Zeitschulden durch '
          'Mehrarbeit auszugleichen. Der Arbeitgeber ist berechtigt, eine '
          'Freizeitnahme im Rahmen des billigen Ermessens (etwa bei '
          'niedriger Arbeitsauslastung) anzuordnen. Soweit der Ausgleich in '
          'Geld erfolgt, beträgt die Bruttovergütung EUR '
          '${wcEur(d.hourlyWage)} pro Stunde.',
      'Ist ein Zeitausgleich vor Beendigung des Arbeitsverhältnisses '
          'aufgrund betrieblicher Gründe nicht möglich, wird das '
          'Zeitguthaben auf dem Arbeitszeitkonto entsprechend § 7 Abs. 4 '
          'BUrlG abgegolten. Stellt der Arbeitgeber den Arbeitnehmer '
          '(einseitig oder einvernehmlich) von der Arbeitsleistung bis zur '
          'Beendigung des Arbeitsverhältnisses unwiderruflich frei, werden '
          'etwaige Zeitguthaben auf die Zeit der Freistellung angerechnet.',
      'Zeitschulden sind vor der Beendigung des Arbeitsverhältnisses durch '
          'den Arbeitnehmer auszugleichen. Ein etwaig negativer Restsaldo '
          'wird mit dem dem Arbeitnehmer noch zustehenden Entgeltanspruch '
          'verrechnet.',
      'Mündliche Nebenabreden bestehen nicht. Änderungen oder Ergänzungen '
          'dieser Vereinbarung, einschließlich dieser Bestimmung, bedürfen '
          'zu ihrer Wirksamkeit der Textform, es sei denn, diese wurden '
          'nachweislich zwischen den Parteien ausgehandelt.',
      'Sollte eine Bestimmung dieser Vereinbarung ganz oder teilweise '
          'unwirksam sein oder werden, so wird hiervon die Wirksamkeit der '
          'übrigen Bestimmungen nicht berührt. An die Stelle der '
          'unwirksamen Bestimmung tritt die gesetzlich zulässige '
          'Bestimmung, die dem mit der unwirksamen Bestimmung Gewollten '
          'wirtschaftlich am nächsten kommt. Entsprechendes gilt für den '
          'Fall einer vertraglichen Lücke.',
      'Diese Vereinbarung tritt mit Wirkung zum ${wcDate(d.startDate)} in '
          'Kraft.',
    ];

/// Kamera-DSGVO (VAS Road Safety — Fahrer-Datenschutzerklärung), Abschnitte
/// mit gefüllten Platzhaltern (Arion-Daten).
List<WcSection> wcCameraPrivacySections(WorkContractData d) => [
      WcSection('Verantwortlichkeit und Kontaktdaten', [
        '${WcEmployer.name}, ${WcEmployer.street}, ${WcEmployer.zipCity}, '
            '${WcEmployer.email} („wir“) dient als Verantwortlicher für '
            'Ihre personenbezogenen Daten. Sie können unseren '
            'Datenschutz-Kontakt über ${WcEmployer.email} erreichen.',
      ]),
      WcSection('Arten von personenbezogenen Daten', [
        'Wir können die folgenden Arten personenbezogener Daten über Sie '
            'verarbeiten: Identifikationsdaten (z. B. Namen, Bilder); '
            'Kontaktdaten (z. B. E-Mail-Adresse); Videoaufzeichnungen '
            '(z. B. Außenansichten der Straßenumgebung und Innenansichten '
            'des Fahrzeuginnenraums); Fahrzeugbetriebsdaten (z. B. '
            'Standort, Geschwindigkeit, Beschleunigung, Bremsvorgänge, '
            'Kurvenfahrten, Abstand zum vorausfahrenden Fahrzeug); Daten zu '
            'Sicherheitsvorfällen (z. B. festgestelltes unsicheres '
            'Fahrverhalten, einschließlich Geschwindigkeitsüberschreitungen, '
            'abruptes Bremsen, Beschleunigen und Abbiegen, Kollisionen, zu '
            'dichtes Auffahren, abgelenktes Fahren, Schläfrigkeit, '
            'Kamerabehinderung, Vorwärtskollisionswarnungen, Erkennung von '
            'Rollstopps sowie Verstöße gegen Verkehrszeichen oder Ampeln); '
            'Interaktionsdaten (z. B. Ihre Interaktionen mit dem '
            'Verkehrssicherheitstechnologien-System und der App, '
            'einschließlich etwaiger Behinderungen der Kamera). In '
            'Ausnahmefällen können wir Gesundheitsdaten von Ihnen '
            'verarbeiten (z. B. sichtbare Verletzungen bei einem '
            'Verkehrsunfall).',
      ]),
      WcSection('Zwecke', [
        'Wir können Ihre personenbezogenen Daten für folgende Zwecke '
            'verarbeiten: zur Verbesserung der Verkehrssicherheit, '
            'einschließlich der Sicherheit unserer Fahrer und anderer '
            'Verkehrsteilnehmer, sowie zur Vermeidung von Schäden für unser '
            'Unternehmen; zur Analyse von Vorfällen im Straßenverkehr und '
            'zur Prüfung von Rechtsansprüchen; und zur Erfüllung '
            'gesetzlicher Verpflichtungen.',
      ]),
      WcSection('Rechtsgrundlagen', [
        'Wir verarbeiten Ihre personenbezogenen Daten in Übereinstimmung '
            'mit den geltenden Datenschutzvorschriften, einschließlich der '
            'Datenschutz-Grundverordnung („DSGVO“). Wir verarbeiten Ihre '
            'personenbezogenen Daten auf der Grundlage unserer berechtigten '
            'Interessen (Art. 6 Abs. 1 lit. f DSGVO). Unsere berechtigten '
            'Interessen sind: Schutz der Gesundheit und der körperlichen '
            'Unversehrtheit unserer Fahrer und anderer Verkehrsteilnehmer '
            '(z. B. Fußgänger); die Verringerung von rechtlichen Risiken '
            '(z. B. Rechtsansprüchen), finanziellen Risiken (z. B. erhöhten '
            'Versicherungsprämien oder Reparaturkosten) und '
            'Reputationsrisiken (z. B. der Wahrnehmung von Lieferfahrzeugen '
            'als rücksichtslos fahrend), die sich aus Verkehrsunfällen '
            'ergeben; und die Analyse von Verkehrsunfällen und die '
            'effektive Bearbeitung von Rechtsansprüchen.',
        'Wenn wir Ihre personenbezogenen Daten zur Erfüllung gesetzlicher '
            'Verpflichtungen verarbeiten, nutzen wir Art. 6 Abs. 1 lit. c '
            'DSGVO. Im Falle eines schweren Verkehrsunfalls können wir in '
            'Ausnahmefällen Gesundheitsdaten (z. B. sichtbare Verletzungen) '
            'verarbeiten. In solchen Fällen verarbeiten wir diese Daten '
            'besonderer Art, da dies für die Geltendmachung, Ausübung oder '
            'Abwehr von Rechtsansprüchen erforderlich ist (Art. 9 Abs. 2 '
            'Buchstabe f DSGVO).',
      ]),
      WcSection('Arten von Empfängern', [
        'Soweit dies für die oben beschriebenen Zwecke erforderlich ist, '
            'geben wir Ihre personenbezogenen Daten unter Umständen an: '
            'unseren Anbieter für Verkehrssicherheitstechnologien, der die '
            'für den Betrieb der Verkehrssicherheitstechnologien '
            'erforderliche Kamerahardware, Cloud-Plattform und die für den '
            'Fahrer bestimmte mobile Anwendung bereitstellt; Behörden und '
            'öffentliche Einrichtungen (z. B. Gerichte, '
            'Strafverfolgungsbehörden) im Rahmen von Gerichtsverfahren; '
            'sowie Versicherer und Vertragspartner (einschließlich deren '
            'Rechtsanwälten), soweit dies zur Prüfung von Vorfällen im '
            'Straßenverkehr oder zur Abwicklung von Rechtsansprüchen '
            'erforderlich ist.',
      ]),
      WcSection('Übermittlung an Drittländer', [
        'Wir verarbeiten Ihre personenbezogenen Daten in der Regel '
            'innerhalb der EU/des EWR. Wenn wir Ihre personenbezogenen '
            'Daten an Länder außerhalb der EU/des EWR („Drittländer“) '
            'übermitteln, wie beispielsweise an unseren Anbieter für '
            'Verkehrssicherheitstechnologien in den Vereinigten Staaten, '
            'stützen wir uns in der Regel auf Standardvertragsklauseln '
            'gemäß Art. 46 Abs. 2 Buchstabe c DSGVO (den Wortlaut der '
            'Standardvertragsklauseln finden Sie unter '
            'https://ec.europa.eu/info/law/law-topic/data-protection/'
            'international-dimension-data-protection/standard-contractual-'
            'clauses-scc_en). Darüber hinaus haben wir zusätzliche '
            'Schutzmaßnahmen getroffen, um ein angemessenes Schutzniveau '
            'für Ihre personenbezogenen Daten zu gewährleisten, '
            'insbesondere die Verschlüsselung der Daten bei Übertragung und '
            'im zugriffslosen Zustand. Für weitere Einzelheiten zu unserer '
            'Datenübermittlung an Drittländer oder für einen Auszug dieser '
            'Erklärung wenden Sie sich bitte an uns unter den in Abschnitt '
            '9 dieser Datenschutzerklärung angegebenen Kontaktdaten.',
      ]),
      WcSection('Aufbewahrungsfristen', [
        'Wir speichern Ihre personenbezogenen Daten nicht länger, als es '
            'für die oben beschriebenen Zwecke erforderlich ist. Die '
            'konkreten Aufbewahrungsfristen hängen vom Zweck der '
            'Verarbeitung ab: Zur Verbesserung der Verkehrssicherheit: Wir '
            'speichern alle auf den lokalen Geräten der Lieferfahrzeuge '
            'gespeicherten Kameraaufnahmen für einige Tage und alle in der '
            'Cloud unseres Anbieters gespeicherten Kameraaufnahmen (die '
            'sich ausschließlich auf erkannte Sicherheitsvorfälle beziehen) '
            'für einige Wochen, bevor beide automatisch gelöscht werden. '
            'Zur Untersuchung von Verkehrsunfällen und zur Prüfung von '
            'Rechtsansprüchen: Wir speichern die entsprechenden '
            'personenbezogenen Daten für die Dauer der geltenden '
            'Verjährungsfrist, einschließlich bis zur vollständigen '
            'Beilegung damit verbundener Rechtsstreitigkeiten und etwaiger '
            'Berufungsverfahren, sowie für jeden weiteren Zeitraum, der '
            'gesetzlich vorgeschrieben oder für Angelegenheiten nach der '
            'Beilegung erforderlich ist. Nach Ablauf unserer geltenden '
            'Aufbewahrungsfristen werden wir Ihre personenbezogenen Daten '
            'löschen oder anonymisieren.',
      ]),
      WcSection('Quellen personenbezogener Daten', [
        'Wir erheben personenbezogene Daten nur unmittelbar von Ihnen, '
            'wenn Sie der Nutzung unserer Verkehrssicherheitstechnologien '
            'nicht widersprechen (Opt-Out). Ihre Teilnahme an den '
            'Verkehrssicherheitstechnologien ist freiwillig. Sofern Sie '
            'sich zu einem beliebigen Zeitpunkt gegen die Teilnahme an den '
            'Verkehrssicherheitstechnologien entscheiden (siehe Abschnitt 9 '
            'dieser Datenschutzerklärung), entstehen Ihnen hierdurch keine '
            'Nachteile.',
      ]),
      WcSection('Rechte der betroffenen Person und Fragen', [
        'Gemäß der DSGVO stehen Ihnen folgende Rechte zu: Recht auf '
            'Auskunft über personenbezogene Daten (Art. 15 DSGVO); Recht '
            'auf Berichtigung (Art. 16 DSGVO); Recht auf Löschung (Art. 17 '
            'DSGVO); Recht auf Einschränkung der Verarbeitung (Art. 18 '
            'DSGVO); Widerspruchsrecht: Sie können der Verarbeitung Ihrer '
            'personenbezogenen Daten jederzeit widersprechen (Art. 21 '
            'DSGVO).',
        'Zusätzlich zu Ihrem Widerspruchsrecht gemäß Art. 21 DSGVO '
            'gewähren wir Ihnen das Recht, den '
            'Verkehrssicherheitstechnologien jederzeit zu widersprechen. '
            'Dafür müssen Sie keine Gründe angeben. Die Ausübung Ihres '
            'Widerspruchsrechts ist für Sie mit keinerlei Nachteilen in '
            'Ihrem Beschäftigungsverhältnis verbunden. Wenn Sie von Ihrem '
            'Widerspruchsrecht Gebrauch machen, werden wir die Verarbeitung '
            'Ihrer personenbezogenen Daten einstellen, es sei denn, die '
            'Verarbeitung ist zur Geltendmachung, Ausübung oder Abwehr von '
            'Rechtsansprüchen erforderlich.',
        'Wenn Sie diese Rechte geltend machen möchten oder Fragen zu '
            'dieser Datenschutzerklärung haben, kontaktieren Sie uns bitte '
            'über ${WcEmployer.email}. Bitte beachten Sie, dass Ihre Rechte '
            'in bestimmten Situationen eingeschränkt sein können. In einem '
            'solchen Fall werden wir Sie über den Grund für die '
            'Einschränkung informieren. Sollten Sie Bedenken hinsichtlich '
            'der Verarbeitung Ihrer personenbezogenen Daten haben, wenden '
            'Sie sich gerne an uns. Unabhängig davon haben Sie das Recht, '
            'bei der zuständigen Aufsichtsbehörde gemäß Art. 77 DSGVO eine '
            'Beschwerde einzureichen.',
      ]),
    ];
