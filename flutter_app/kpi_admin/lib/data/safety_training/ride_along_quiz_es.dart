// lib/data/safety_training/ride_along_quiz_es.dart
//
// Preguntas del test final del Ride Along — versión española.
// La estructura es idéntica a la versión alemana (máster): quince
// preguntas, repartidas entre los cinco capítulos de
// ride_along_content_es.dart (ra1 … ra5), tres preguntas por capítulo,
// el mismo orden de las opciones y las mismas respuestas correctas.
//
// Compatible con varios operadores: en ningún sitio se pregunta por
// cifras específicas de una empresa (número de paradas, horarios de la
// Waiting Area, lado de aparcamiento) — solo por lo que es válido en
// todas partes. Las excepciones con base legal: § 4 ArbZG (las pausas) y
// § 1 apdo. 6 FPersV (Green Book).

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> rideAlongQuestionsEs = [
  // ══════════════════════════ ra1 — Qué es el Ride Along
  DrivingQuestion(
    moduleId: 'ra1',
    question: '¿Qué es el Ride Along?',
    options: [
      'Una instrucción teórica en la oficina antes del primer día de '
          'trabajo',
      'Dos días de trabajo de ruta acompañada con un conductor con '
          'experiencia como formador',
      'Un examen oficial de conducción sin el cual no puedes ser asignado '
          'a un servicio',
    ],
    correctIndex: 1,
    explanation: 'El Ride Along son dos días de trabajo reales en la empresa '
        'en los que un conductor con experiencia te acompaña, te explica '
        'todo y después te deja hacerlo a ti. No es ni una formación de '
        'oficina ni un examen de una autoridad — es la integración en la '
        'operativa real, que sin embargo se evalúa y se documenta.',
  ),
  DrivingQuestion(
    moduleId: 'ra1',
    question: '¿Cuántas paradas tienes que hacer en los dos días?',
    options: [
      'Lo fija tu empresa o tu estación — el formador te dice la '
          'indicación',
      'Siempre exactamente 20 el primer día y 70 el segundo, igual en '
          'todas las empresas',
      'Tantas como te veas capaz — no hay ninguna indicación',
    ],
    correctIndex: 0,
    explanation: 'Es habitual un número menor el primer día y bastantes más '
        'el segundo (a menudo unas 20 y unas 70), pero son valores '
        'orientativos de empresas concretas. Lo único vinculante es lo que '
        'fije tu estación. El error típico es tomar una cifra que has oído '
        'por una ley general — pregunta a tu formador por la cifra que se '
        'te aplica a ti.',
  ),
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'El primer día vas bastante más lento de lo previsto y '
        'cometes varios errores al ordenar. ¿Cómo repercute eso en la '
        'evaluación?',
    options: [
      'El Ride Along se considera entonces no superado y hay que repetirlo',
      'No importa, porque el primer día todavía no se evalúa nada',
      'Lo decisivo es si preguntas y corriges después el error — no el '
          'ritmo',
    ],
    correctIndex: 2,
    explanation: 'Nadie espera ritmo el primer día; justo para eso está el '
        'número menor de paradas. Se evalúa tu disposición a aprender: '
        '¿preguntas, aceptas las indicaciones, cometes el mismo error '
        'también a la tercera? El error es peligroso en ambos sentidos: no '
        'es ni un examen con guillotina ni un día sin evaluación.',
  ),

  // ══════════════════════════ ra2 — El primer día
  DrivingQuestion(
    moduleId: 'ra2',
    question: '¿Por qué las paradas del Ride Along tienen que hacerse con '
        'tu propia cuenta?',
    options: [
      'Porque el formador no puede usar su cuenta esos días',
      'Porque solo así se ve cómo es tu propia entrega — cuenta a tu '
          'nombre',
      'Porque la cuenta del formador ya no admite paradas nuevas',
    ],
    correctIndex: 1,
    explanation: 'Todo lo que entregas esos días va a tu nombre — igual que '
        'después en el día a día. Solo así ven el formador y la empresa tu '
        'forma real de trabajar, y solo así cuentan las paradas para tu '
        'formación inicial. Por eso un acceso que no funciona por la mañana '
        'no es un detalle, sino un motivo para avisar de inmediato.',
  ),
  DrivingQuestion(
    moduleId: 'ra2',
    question: '¿Qué rige para la duración de grabación de Mentor?',
    options: [
      'Mentor graba unas 4 horas seguidas y después hay que volver a '
          'arrancarlo',
      'Mentor, una vez arrancado, funciona hasta el final del turno',
      'Mentor se arranca automáticamente en cuanto el vehículo se mueve',
    ],
    correctIndex: 0,
    explanation: 'La grabación dura unas cuatro horas cada vez. Después '
        'tienes que volver a arrancarla, si no el resto de la ruta queda '
        'sin registrar. El error más frecuente de los principiantes es '
        'justamente creer que la app funciona sola: arrancada bien por la '
        'mañana, no reactivada después de la pausa — y medio día falta en '
        'la evaluación.',
  ),
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Ese día trabajas 9,5 horas. ¿Cuánto tiene que durar tu pausa '
        'como mínimo?',
    options: [
      '30 minutos, porque los 45 minutos rigen solo a partir de 10 horas',
      'Basta con hacer varias pausas cortas de 5 a 10 minutos cada una',
      '45 minutos, porque el tiempo de trabajo supera las 9 horas',
    ],
    correctIndex: 2,
    explanation: 'Según el § 4 ArbZG, con más de 6 horas se prescriben al '
        'menos 30 minutos y con más de 9 horas al menos 45 minutos de '
        'pausa — 9,5 horas están por encima del límite. La pausa se puede '
        'repartir, pero cada parte debe durar al menos 15 minutos; cinco '
        'minutos sueltos no cuentan.',
  ),

  // ══════════════════════════ ra3 — El segundo día
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Un cliente con un paquete con contraseña no tiene el código '
        'a mano, pero quiere firmar. ¿Qué haces?',
    options: [
      'No entregas — sin el código correcto no hay ninguna excepción',
      'Entregas contra firma, porque también es una prueba',
      'Dejas el paquete en casa del vecino e informas al cliente',
    ],
    correctIndex: 0,
    explanation: 'La contraseña es la prueba de que el destinatario es '
        'realmente el destinatario — para eso se asignó. Una firma o unas '
        'buenas palabras no la sustituyen, y mucho menos dejarlo en casa '
        'del vecino. Si más tarde se comunica que el envío no se ha '
        'recibido, la entrega sin código consta como error tuyo. Lo '
        'correcto es: hacer que busque el código y, si no, devolver el '
        'paquete correctamente y documentarlo.',
  ),
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Al maniobrar rozas un bolardo. Queda un arañazo en la '
        'furgoneta y nadie lo ha visto. ¿Qué es lo correcto?',
    options: [
      'No hacer nada — con un arañazo sin daños a terceros no hay nada que '
          'notificar',
      'Esperar primero a ver si se nota siquiera en la siguiente '
          'inspección',
      'Notificarlo el mismo día y documentarlo en CoDriver',
    ],
    correctIndex: 2,
    explanation: 'Un daño notificado es un incidente que se tramita; ese '
        'mismo daño, que a la mañana siguiente encuentra otra persona en su '
        'inspección, es un daño sin aclarar — y la sospecha acaba recayendo '
        'igualmente sobre el último usuario. El error «esto no se nota» no '
        'se sostiene: justo para eso está la inspección antes y después de '
        'cada ruta.',
  ),
  DrivingQuestion(
    moduleId: 'ra3',
    question: '¿Cuál es la diferencia entre rendimiento y calidad en la '
        'Scorecard?',
    options: [
      'Ambos significan lo mismo — la Scorecard solo mide el número de '
          'paradas',
      'El rendimiento es la cantidad en el tiempo; la calidad es lo '
          'limpiamente que se cerró cada parada',
      'La calidad afecta solo al vehículo y el rendimiento solo a la '
          'entrega',
    ],
    correctIndex: 1,
    explanation: 'El rendimiento es la cantidad: cuántas paradas en cuánto '
        'tiempo. La calidad es el cuidado en cada parada: lugar correcto, '
        'documentación correcta, sin reclamaciones. Quien equipara las dos '
        'cosas ahorra un minuto al principio y genera después una '
        'investigación que le cuesta a la empresa varias veces más.',
  ),

  // ══════════════════════════ ra4 — Cierre y entrega
  DrivingQuestion(
    moduleId: 'ra4',
    question: '¿Cuántas veces firma el formador la lista de verificación '
        'del Ride Along?',
    options: [
      'Una vez al final del segundo día para los dos días juntos',
      'Ninguna — solo firma el dispatcher al recibirla',
      'Una por día, cada vez con fecha',
    ],
    correctIndex: 2,
    explanation: 'Cada día tiene su propia lista de puntos y por eso se '
        'cierra por separado con fecha y firma. Tiene un motivo práctico: '
        'si el segundo día se cae o se aplaza, queda igualmente bien '
        'documentado lo que se hizo el primer día. Una firma conjunta al '
        'final haría eso imposible.',
  ),
  DrivingQuestion(
    moduleId: 'ra4',
    question: '¿Qué pasa con la lista de verificación cumplimentada al '
        'final del segundo día?',
    options: [
      'Se entrega como foto al dispatcher responsable',
      'Te la llevas a casa y la guardas de forma privada',
      'Se queda en el vehículo para que el siguiente formador la continúe',
    ],
    correctIndex: 0,
    explanation: 'La hoja se fotografía al final del segundo día y se '
        'entrega al dispatcher responsable — con eso el Ride Along queda '
        'formalmente cerrado y tu formación inicial documentada. En el '
        'vehículo o en tu casa, la prueba no le sirve de nada a la empresa. '
        'Fíjate en que las marcas, la fecha, los nombres y las firmas se '
        'lean bien en la foto.',
  ),
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'En el feedback te dicen que eres demasiado dubitativo al '
        'maniobrar. ¿Cuál es la reacción más sensata?',
    options: [
      'Explicar que ibas con cuidado a propósito y dar el tema por '
          'zanjado',
      'Preguntar por un ejemplo concreto de la jornada',
      'Tomar nota del feedback y maniobrar más rápido la próxima vez',
    ],
    correctIndex: 1,
    explanation: 'Ir con cuidado al maniobrar está bien — «dubitativo» suele '
        'referirse a otra cosa, por ejemplo a pensárselo mucho en lugar de '
        'bajarse un momento y mirar. Con un ejemplo concreto tienes un '
        'punto en el que puedes trabajar. Justificarse no sirve de nada, y '
        'simplemente maniobrar más rápido sería la más peligrosa de las '
        'tres reacciones.',
  ),

  // ══════════════════════════ ra5 — Así te preparas
  DrivingQuestion(
    moduleId: 'ra5',
    question: '¿Cuándo deberías comprobar si funcionan tus accesos al '
        'registro horario, Mentor, Flex y CoDriver?',
    options: [
      'La mañana del primer día junto con el formador',
      'Solo cuando aparezca realmente un problema durante el trabajo',
      'Antes del primer día, preferiblemente la víspera',
    ],
    correctIndex: 2,
    explanation: 'Restablecer una contraseña lleva minutos la víspera y media '
        'hora por la mañana en la Waiting Area — si es que hay alguien '
        'localizable. El error típico es dejárselo al formador: él no puede '
        'ayudarte con un acceso bloqueado, y ese tiempo falta después en '
        'las paradas con tu propia cuenta.',
  ),
  DrivingQuestion(
    moduleId: 'ra5',
    question: '¿Qué significa «puntual» en el Ride Along?',
    options: [
      'Listo para trabajar en la estación al inicio del turno — el '
          'aparcamiento y el camino ya están contados',
      'Llegar a la puerta de la estación al inicio del turno',
      'Estar allí como muy tarde cuando se llame a la Waiting Area',
    ],
    correctIndex: 0,
    explanation: 'Al inicio del turno estás listo para trabajar, no de '
        'camino. Quien llega solo hasta la puerta pierde tiempo aparcando y '
        'cruzando el patio y se salta su franja de la Waiting Area — y con '
        'ello retrasa también la ola del formador. Por eso, cuenta '
        'conscientemente el tiempo de aparcar y de caminar.',
  ),
  DrivingQuestion(
    moduleId: 'ra5',
    question: '¿Por qué merece la pena apuntar las preguntas para el '
        'formador ya antes del día 1?',
    options: [
      'Porque el formador tiene que hacer que las preguntas se presenten '
          'antes por escrito',
      'Porque diez procesos explicados uno detrás de otro no los retiene '
          'nadie — apuntados preguntas de forma concreta',
      'Porque, si no, las preguntas no formuladas se anotan de forma '
          'negativa en la evaluación',
    ],
    correctIndex: 1,
    explanation: 'El formador explica muchísimo de golpe en dos días; por la '
        'tarde, sin notas, queda poco de todo eso. Quien prepara sus '
        'preguntas y anota sobre la marcha dos palabras clave por tema saca '
        'de esos dos días un rendimiento mucho mayor. No es una obligación '
        'formal — y nadie anota de forma negativa las preguntas no '
        'formuladas. Justo por eso tienes que ocuparte tú mismo.',
  ),
];
