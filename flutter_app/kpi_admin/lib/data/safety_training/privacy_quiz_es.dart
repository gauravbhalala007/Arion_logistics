// lib/data/safety_training/privacy_quiz_es.dart
//
// Preguntas del test final de la formación en protección de datos —
// versión en español. La estructura es idéntica a la versión alemana
// (master, privacy_quiz_de.dart): dieciocho preguntas, repartidas de
// forma uniforme entre los seis capítulos de privacy_content_es.dart
// (tres preguntas por capítulo, ds1 … ds6), el mismo orden de las
// opciones y las mismas respuestas correctas. Cualquier cambio
// estructural se hace primero en el archivo alemán y se traslada
// después aquí.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> privacyQuestionsEs = [
  // ══════════════════════════ ds1 — Por qué la protección de datos te afecta
  DrivingQuestion(
    moduleId: 'ds1',
    question: '¿Cuál de los siguientes datos NO es un dato personal en el '
        'sentido del DSGVO (RGPD)?',
    options: [
      'El número total de paquetes entregados hoy en la ruta',
      'La indicación «Deja el paquete detrás del cubo de basura» junto con '
          'la dirección correspondiente',
      'La foto de entrega delante de la puerta de un destinatario',
    ],
    correctIndex: 0,
    explanation: 'Una simple cifra de unidades, sin relación con una '
        'persona, no es un dato personal. La indicación de depósito, en '
        'cambio, dice algo sobre la situación de vivienda de una persona '
        'concreta, y la foto de entrega está asociada a una dirección. El '
        'error más habitual es considerar personales solo los nombres — es '
        'dato personal cualquier información con la que se pueda '
        'identificar a una persona.',
  ),
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Por la tarde cuentas entre amigos en qué calle vive un '
        'deportista conocido cuyo paquete has entregado. ¿Cómo se valora '
        'esto?',
    options: [
      'Sin problema, mientras no publiques el nombre en internet',
      'Una infracción de la limitación de la finalidad y de la '
          'confidencialidad según el Art. 5 DSGVO',
      'Sin problema, porque una dirección es de todos modos pública',
    ],
    correctIndex: 1,
    explanation: 'Conoces la dirección exclusivamente por tu trabajo. '
        'Comunicarla a terceros es una revelación para un fin ajeno y '
        'vulnera el Art. 5 apdo. 1 lit. b y lit. f DSGVO. El error más '
        'habitual es pensar que un pequeño círculo privado no cuenta — el '
        'DSGVO no pregunta por el tamaño del público.',
  ),
  DrivingQuestion(
    moduleId: 'ds1',
    question: '¿De qué normas se deriva que la empresa tiene que formarte '
        'en protección de datos?',
    options: [
      'Del § 12 apdo. 1 de la ArbSchG (la ley alemana de seguridad y salud '
          'laboral) — la protección de datos forma parte de la instrucción '
          'anual de seguridad',
      'De una obligación expresa de formación en el Art. 30 DSGVO',
      'De forma indirecta, del Art. 32, el Art. 39 apdo. 1 lit. b y el '
          'Art. 5 apdo. 2 DSGVO',
    ],
    correctIndex: 2,
    explanation: 'El DSGVO no contiene ninguna obligación expresa de '
        'formación. Se deriva de forma indirecta: el Art. 32 exige medidas '
        'organizativas, el Art. 39 apdo. 1 lit. b menciona la '
        'sensibilización y la formación como tarea del delegado de '
        'protección de datos, y el Art. 5 apdo. 2 exige la prueba del '
        'cumplimiento. El Art. 30, en cambio, se refiere al registro de '
        'las actividades de tratamiento, y la ArbSchG regula la seguridad '
        'laboral, no la protección de datos.',
  ),

  // ══════════════════════════ ds2 — Fotos y comprobantes de entrega
  DrivingQuestion(
    moduleId: 'ds2',
    question: '¿Qué puede verse en una foto de entrega?',
    options: [
      'El destinatario, si ha dado su consentimiento verbal a la toma',
      'El paquete en el lugar de depósito, más la puerta o el número de la '
          'casa como referencia del sitio',
      'El paquete y la matrícula del vehículo aparcado delante, para una '
          'mejor asignación',
    ],
    correctIndex: 1,
    explanation: 'La foto responde exactamente a una pregunta: ¿dónde está '
        'el paquete? Todo lo que vaya más allá vulnera la minimización de '
        'datos del Art. 5 apdo. 1 lit. c DSGVO. Las personas no deben '
        'aparecer en el comprobante ni siquiera con consentimiento verbal, '
        'y una matrícula es un dato personal que no es necesario para el '
        'fin.',
  ),
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'El escáner falla. Fotografías el lugar de depósito con la '
        'cámara normal de tu móvil y subes después la imagen a la app de '
        'trabajo. ¿Qué falla en eso?',
    options: [
      'Nada — lo decisivo es solo que la imagen acabe en la app',
      'Solo la calidad de la imagen; jurídicamente no hay reparos',
      'La imagen queda después de forma permanente en la galería privada, '
          'a menudo además en una nube privada',
    ],
    correctIndex: 2,
    explanation: 'La subida no elimina la copia: el original permanece en '
        'la galería privada y con frecuencia se guarda automáticamente en '
        'una nube. Así, hay datos personales fuera del control de la '
        'empresa. El error más habitual es pensar que solo cuenta el '
        'estado final — lo decisivo es cada copia que surge por el camino.',
  ),
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'Después de cerrar la parada te das cuenta de que en la foto '
        'subida se reconoce a una vecina. ¿Qué haces?',
    options: [
      'Informar al dispatcher o a la dirección de operaciones para que la '
          'imagen se borre en el sistema',
      'Nada — la parada está cerrada y la imagen ya no se puede cambiar de '
          'todos modos',
      'Llamar al día siguiente a la puerta de la vecina y pedirle permiso',
    ],
    correctIndex: 0,
    explanation: 'Solo si la empresa lo sabe puede borrar la imagen y '
        'documentar el suceso. El error más habitual es pensar que ya no '
        'merece la pena avisar una vez cerrada la parada. Un '
        'consentimiento posterior no sana la infracción y además no es una '
        'base jurídica sólida en el contexto laboral.',
  ),

  // ══════════════════════════ ds3 — Manejo de los datos de los destinatarios
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Haces una captura de pantalla de la lista de direcciones '
        'para recordar mejor el orden. Nadie más la ve. ¿Está permitido?',
    options: [
      'Sí, mientras borres la captura al final de la ruta',
      'Sí, porque de todos modos puedes tratar esos datos por motivos de '
          'trabajo',
      'No — una captura de pantalla es una copia fuera del sistema y, por '
          'tanto, no está permitida',
    ],
    correctIndex: 2,
    explanation: 'Con la captura de pantalla surge una copia de datos '
        'personales que la empresa ya no puede controlar. Que puedas ver '
        'los datos por motivos de trabajo no te permite guardarlos fuera '
        'del sistema. La intención de borrarlos más tarde tampoco cambia '
        'nada en el tratamiento no permitido.',
  ),
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Un vecino recoge un paquete y pregunta qué hay dentro y si '
        'el destinatario sigue viviendo allí. ¿Qué le dices?',
    options: [
      'Solo el nombre del destinatario y el número de la casa — sobre el '
          'contenido y demás datos, ninguna información',
      'Todo lo que pone en la etiqueta, ya que al fin y al cabo él recoge '
          'el paquete',
      'Nada, tampoco el nombre del destinatario',
    ],
    correctIndex: 0,
    explanation: 'Para la entrega a un vecino son necesarios el nombre y '
        'el número de la casa — sin ellos el vecino no puede entregar el '
        'paquete. Todo lo que vaya más allá, en especial el contenido o la '
        'confirmación de una situación de vivienda, es una revelación sin '
        'base jurídica según el Art. 6 DSGVO. No decir nada en absoluto, '
        'en cambio, sería poco realista y haría inviable la entrega.',
  ),
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'La ruta ha terminado y la lista de ruta en papel ya no hace '
        'falta. ¿Cómo la eliminas correctamente?',
    options: [
      'En el contenedor de papel de tu propio edificio, en cuanto llegues '
          'a casa',
      'Por la vía prevista en la empresa — contenedor de protección de '
          'datos o destructora de documentos',
      'Rota, en la basura general de la gasolinera, para que nadie pueda '
          'leerla ya',
    ],
    correctIndex: 1,
    explanation: 'En la lista figuran nombres y direcciones; debe '
        'eliminarse de forma que no se pueda reconstruir — en la empresa, '
        'mediante contenedor de protección de datos o destructora de '
        'documentos. El error más habitual es pensar que una lista ya '
        'utilizada carece de valor. Los contenedores de acceso público '
        'quedan descartados y, además, la lista no deberías habértela '
        'llevado a casa.',
  ),

  // ══════════════════════════ ds4 — Datos propios y datos de los compañeros
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Un compañero te pide una captura de pantalla de una '
        'evaluación interna en la que aparecen todos los conductores con '
        'nombres y cifras. Solo quiere ver su propia fila. ¿Cómo '
        'reaccionas?',
    options: [
      'Negarte y remitirle a la dirección de operaciones — solo tiene '
          'derecho a sus propios datos',
      'Enviársela, porque él mismo figura en la lista y por eso está '
          'autorizado a acceder',
      'Enviársela, pero tapando antes los nombres de los demás y borrando '
          'después la captura',
    ],
    correctIndex: 0,
    explanation: 'Con la captura recibiría los datos de rendimiento de '
        'todos los compañeros — una comunicación de datos de empleados sin '
        'base jurídica. Su derecho de acceso según el Art. 15 DSGVO se '
        'refiere exclusivamente a sus propios datos. Un tachado casero '
        'tampoco cambia el hecho de que has creado una copia no '
        'permitida.',
  ),
  DrivingQuestion(
    moduleId: 'ds4',
    question: '¿Por qué están especialmente protegidas las bajas por '
        'enfermedad de los compañeros?',
    options: [
      'Porque en el contrato de trabajo se designan expresamente como '
          'confidenciales',
      'Porque son secretos de empresa según la GeschGehG (la ley alemana '
          'de protección de secretos empresariales)',
      'Porque los datos de salud son categorías especiales de datos '
          'personales según el Art. 9 DSGVO',
    ],
    correctIndex: 2,
    explanation: 'Los datos de salud entran en el Art. 9 DSGVO y están '
        'sujetos a una protección más estricta que los datos ordinarios. '
        'Ya el hecho mismo de la enfermedad es uno de esos datos; el '
        'motivo, con mayor razón. Los secretos de empresa, en cambio, '
        'afectan al conocimiento empresarial, no a los datos de salud de '
        'los empleados.',
  ),
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Quieres saber qué datos ha guardado tu empresa sobre ti. '
        '¿Qué derecho utilizas para ello?',
    options: [
      'El derecho a la portabilidad de los datos según el Art. 20 DSGVO',
      'El derecho de acceso según el Art. 15 DSGVO',
      'El derecho de oposición según el Art. 21 DSGVO',
    ],
    correctIndex: 1,
    explanation: 'El Art. 15 DSGVO te da derecho a un resumen de los datos '
        'guardados sobre tu persona y de sus finalidades. El Art. 20 se '
        'refiere a la entrega en un formato portable y el Art. 21 a la '
        'oposición a un tratamiento — ninguno de los dos responde a la '
        'pregunta de qué hay guardado. La solicitud debe responderse, por '
        'regla general, en el plazo de un mes.',
  ),

  // ══════════════════════════ ds5 — Brecha de datos
  DrivingQuestion(
    moduleId: 'ds5',
    question: '¿Cuál de estos incidentes NO es una brecha de datos?',
    options: [
      'Has entregado un paquete al destinatario equivocado, que lo ha '
          'abierto',
      'Te has equivocado al contar el número de devoluciones en el parte '
          'diario',
      'Has dejado la lista de ruta a la vista en el vehículo sin cerrar',
    ],
    correctIndex: 1,
    explanation: 'Un error de recuento en las devoluciones no afecta a '
        'ningún dato personal ni los hace accesibles a nadie. En los otros '
        'dos casos, personas no autorizadas pudieron conocer nombres, '
        'direcciones o contenidos de los envíos — eso es una violación de '
        'la seguridad de los datos personales.',
  ),
  DrivingQuestion(
    moduleId: 'ds5',
    question: '¿Qué dice el plazo de 72 horas del Art. 33 DSGVO?',
    options: [
      'La empresa debe notificar una brecha de datos a la autoridad de '
          'control, a ser posible en un plazo de 72 horas desde que tiene '
          'conocimiento de ella',
      'El conductor tiene 72 horas para comunicar el incidente en la '
          'empresa',
      'Los afectados deben reclamar ante la empresa en un plazo de 72 '
          'horas; si no, pierden su derecho',
    ],
    correctIndex: 0,
    explanation: 'El plazo vincula a la empresa frente a la autoridad de '
        'control y corre desde que esta tiene conocimiento del hecho. '
        'Justo por eso tienes que avisar de inmediato — cada hora que '
        'esperas se la quitas a la empresa. El error más habitual es leer '
        'las 72 horas como un margen de tiempo propio del conductor.',
  ),
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Por la tarde te has dado cuenta de que un paquete ha '
        'acabado en el destinatario equivocado y allí se ha abierto. ¿Qué '
        'es lo correcto?',
    options: [
      'Recogerlo mañana temprano con discreción y entregarlo bien — así el '
          'error queda subsanado',
      'Mencionarlo en la próxima reunión de servicio, porque de todos '
          'modos ya no se puede cambiar nada',
      'Informar el mismo día al dispatcher o a la dirección de operaciones '
          'y no emprender nada por tu cuenta',
    ],
    correctIndex: 2,
    explanation: 'Ya existe una brecha de datos: una persona ajena ha '
        'conocido el nombre, la dirección y el contenido del envío. La '
        'empresa tiene que valorar, documentar y, en su caso, notificar '
        'según el Art. 33 DSGVO — y para eso necesita la información de '
        'inmediato. La corrección silenciosa parece inofensiva, pero '
        'impide exactamente esos pasos. Quien avisa enseguida actúa '
        'correctamente.',
  ),

  // ══════════════════════════ ds6 — Confidencialidad y lealtad
  DrivingQuestion(
    moduleId: 'ds6',
    question: '¿Qué manifestación NO está amparada por la libertad de '
        'expresión?',
    options: [
      'La afirmación de que una ruta no se puede hacer habitualmente en el '
          'tiempo previsto',
      'La advertencia de que un vehículo no se ha reparado pese a haberlo '
          'comunicado varias veces',
      'La afirmación deliberadamente falsa de que la empresa estafa '
          'sistemáticamente a sus conductores en las horas',
    ],
    correctIndex: 2,
    explanation: 'Las opiniones y la crítica veraz están protegidas por el '
        'Art. 5 apdo. 1 GG (la Constitución alemana), aunque resulten '
        'incómodas. Las afirmaciones de hechos deliberadamente falsas no '
        'lo están: pueden justificar un despido disciplinario según el '
        '§ 626 BGB y, en caso de difamación, ser además punibles según el '
        '§ 186 StGB.',
  ),
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'Comunicas de buena fe una irregularidad en la empresa. Al '
        'final resulta que tu sospecha no era cierta. ¿Qué ocurre?',
    options: [
      'La protección decae con efecto retroactivo, porque la comunicación '
          'era falsa',
      'Sigues protegido frente a represalias por la HinSchG (la ley '
          'alemana de protección de denunciantes)',
      'La protección solo rige si además has presentado la comunicación '
          'externamente',
    ],
    correctIndex: 1,
    explanation: 'La HinSchG (en vigor desde el 2 de julio de 2023) '
        'protege frente a represalias como el despido, la amonestación o '
        'el perjuicio a los empleados que comunican infracciones. La '
        'protección solo decae en caso de comunicaciones incorrectas '
        'hechas a sabiendas o con negligencia grave — no ante una sospecha '
        'seria que al final no se confirma. Para ello no es necesaria una '
        'comunicación externa.',
  ),
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'En el grupo de chat de conductores se discute sobre '
        'supuestos recortes salariales. Tú mismo estás descontento. ¿Cuál '
        'es el camino correcto?',
    options: [
      'Nombrar tu propio caso concreto y llevarlo al dispatcher, a la '
          'dirección de operaciones o al canal interno de denuncia',
      'Confirmar la afirmación en el grupo para que los compañeros estén '
          'advertidos',
      'Publicar la acusación en un portal de valoraciones para que algo se '
          'mueva',
    ],
    correctIndex: 0,
    explanation: 'El caso propio y comprobable es verdadero, objetivo y '
        'está protegido por la HinSchG — y es el que antes se resuelve '
        'internamente. Confirmar una afirmación que tú mismo no has vivido '
        'es una afirmación de hechos falsa; y un grupo de chat cerrado no '
        'es un espacio protegido en cuanto circula una captura de '
        'pantalla. El camino hacia fuera solo entra en consideración '
        'cuando internamente no ocurre nada.',
  ),
];
