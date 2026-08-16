// lib/data/safety_training/green_book_quiz_es.dart
//
// Preguntas del test final del Green Book (libro de control de trayectos
// según el § 1 apdo. 6 FPersV) — versión española.
// La estructura es idéntica a la versión alemana (máster): el mismo
// número de preguntas, el mismo orden y las mismas respuestas correctas.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> greenBookQuestionsEs = [
  // ══════════════════════════ gb1 — Qué es el Green Book
  DrivingQuestion(
    moduleId: 'gb1',
    question: '¿Qué documentas en el Green Book?',
    options: [
      'El estado del vehículo antes de iniciar el trayecto',
      'El número de paquetes entregados y de retornos',
      'Los tiempos de conducción, las interrupciones de la conducción y '
          'los tiempos de trabajo y de descanso',
    ],
    correctIndex: 2,
    explanation: 'El Green Book es el libro de control de trayectos: la '
        'colección de las hojas de control diarias según el § 1 apdo. 6 '
        'FPersV. Acredita exclusivamente tiempos. El estado del vehículo se '
        'documenta en otro sitio y expresamente no pertenece aquí.',
  ),
  DrivingQuestion(
    moduleId: 'gb1',
    question: '¿Para qué vehículos rige la obligación de registro según el '
        '§ 1 apdo. 6 FPersV?',
    options: [
      'Más de 2,8 t hasta 3,5 t de masa máxima autorizada en el transporte '
          'comercial de mercancías',
      'Para cualquier vehículo con el que se transporten paquetes de forma '
          'comercial',
      'Solo a partir de 3,5 t de masa máxima autorizada',
    ],
    correctIndex: 0,
    explanation: 'La obligación se aplica en el tramo de más de 2,8 t hasta '
        '3,5 t, justamente la furgoneta de reparto típica. Por debajo de '
        '2,8 t no existe; a partir de 3,5 t el tacógrafo digital asume el '
        'registro.',
  ),
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Tu furgoneta tiene, según el permiso de circulación, 3,5 t '
        'de masa máxima autorizada, pero hoy solo lleva 900 kg de carga. '
        '¿Qué rige?',
    options: [
      'Sin obligación de registro: el peso real está por debajo de 2,8 t',
      'La obligación de registro se mantiene',
      'La obligación rige solo a partir de un recorrido diario de 100 '
          'kilómetros',
    ],
    correctIndex: 1,
    explanation: 'Lo determinante es la masa máxima autorizada que figura en '
        'el permiso de circulación, no el peso de la carga de hoy. El error '
        'habitual es recalcular cada día según la carga: la clasificación '
        'del vehículo no cambia por ello.',
  ),

  // ══════════════════════════ gb2 — Qué se anota exactamente
  DrivingQuestion(
    moduleId: 'gb2',
    question: '¿Qué dato NO forma parte de los datos obligatorios de la '
        'hoja de control diaria?',
    options: [
      'El kilometraje al inicio y al final del trayecto',
      'El número de envíos entregados',
      'El lugar de inicio y de fin del trayecto',
    ],
    correctIndex: 1,
    explanation: 'Están prescritos, entre otros, los apellidos, el nombre y '
        'la dirección del conductor, la matrícula, la fecha, los '
        'kilometrajes, los lugares, los tiempos y la firma. Las cantidades '
        'de bultos son un indicador interno de la empresa y no figuran en '
        'la hoja.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: '¿Con qué rellenas la hoja de control diaria?',
    options: [
      'Con bolígrafo, con tinta indeleble',
      'Con lápiz, para poder corregir los errores con limpieza',
      'El instrumento de escritura da igual mientras se pueda leer',
    ],
    correctIndex: 0,
    explanation: 'Una anotación que se puede borrar no es una prueba. '
        'Justamente por eso el lápiz no está permitido, aunque la '
        'corrección tenga buena intención. Un error se tacha una vez y se '
        'vuelve a escribir al lado.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Todos los tiempos y kilometrajes están anotados, solo falta '
        'la firma. ¿Qué rige para esa hoja?',
    options: [
      'Es válida: la firma es un puro formalismo',
      'Se considera incompleta y no cumple la obligación de registro',
      'El planificador puede refrendarla después en la empresa',
    ],
    correctIndex: 1,
    explanation: 'La firma es uno de los datos prescritos: con ella '
        'confirmas el contenido. Sin ella la hoja está incompleta, con las '
        'mismas consecuencias que una hoja que falta. La firma de otra '
        'persona no sustituye a la tuya.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Esperas 40 minutos en el muelle. No haces nada, pero tienes '
        'que estar disponible en todo momento porque se puede continuar de '
        'inmediato. ¿Cómo anotas ese tiempo?',
    options: [
      'Como interrupción de la conducción — al fin y al cabo no has '
          'trabajado',
      'Como inicio del tiempo de descanso diario',
      'Como tiempo de trabajo',
    ],
    correctIndex: 2,
    explanation: 'Una interrupción de la conducción solo es una pausa si '
        'puedes disponer libremente de ese tiempo y lo sabes de antemano. '
        'Estar disponible es tiempo de espera y, por tanto, tiempo de '
        'trabajo. El error habitual es «no he hecho nada, así que fue '
        'pausa»: lo decisivo no es la actividad, sino la disponibilidad.',
  ),

  // ══════════════════════════ gb3 — Conducción, pausas, descansos
  DrivingQuestion(
    moduleId: 'gb3',
    question: '¿Cuánto tiempo puedes conducir como máximo en un día normal?',
    options: [
      '9 horas',
      '10 horas',
      '8 horas, y después solo con la autorización del planificador',
    ],
    correctIndex: 0,
    explanation: 'El tiempo de conducción diario es de 9 horas como máximo. '
        'Las 10 horas no son un segundo límite general, sino una excepción '
        'estrictamente limitada, y una autorización interna de la empresa '
        'no juega ningún papel en ese límite.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: '¿Con qué frecuencia puedes ampliar el tiempo de conducción a '
        '10 horas?',
    options: [
      'Una vez por semana',
      'Dos veces por semana',
      'Cualquier día en el que la ruta lo exija',
    ],
    correctIndex: 1,
    explanation: 'Dos veces por semana puede ampliarse el tiempo de '
        'conducción diario a 10 horas. Es un contingente semanal, no un '
        'derecho diario, y el volumen de la ruta no lo amplía.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Quieres dividir la interrupción de la conducción de 45 '
        'minutos. ¿Qué división está permitida?',
    options: [
      'Primero 30 minutos y después 15 minutos',
      'Tres veces 15 minutos repartidos a lo largo del día',
      'Primero 15 minutos y después 30 minutos',
    ],
    correctIndex: 2,
    explanation: 'La división solo está permitida en dos tramos y solo en '
        'ese orden: primero un mínimo de 15 minutos y después un mínimo de '
        '30. El orden inverso no cuenta, y tres tramos cortos tampoco, '
        'aunque la suma cuadre.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Empiezas a las 07:00. Hasta las 09:30 pasas 2 horas al '
        'volante, hasta las 12:00 se añaden otras 2 horas de conducción y '
        'hasta las 13:00 otros 30 minutos más. ¿Cuándo toca la interrupción '
        'de la conducción como muy tarde?',
    options: [
      'A las 11:30, es decir, 4,5 horas después del inicio del servicio',
      'A las 12:00, porque la hora del mediodía está prevista para eso',
      'A las 13:00',
    ],
    correctIndex: 2,
    explanation: '2 + 2 + 0,5 horas dan a las 13:00 exactamente 4,5 horas de '
        'conducción pura: a partir de ahí no puedes recorrer ni un metro '
        'más antes de haber hecho la pausa. El error habitual es contar '
        'desde el inicio del servicio: el reloj solo corre cuando el '
        'vehículo circula.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Finalizas el tiempo de conducción a las 17:15. ¿Cuándo '
        'puedes volver a empezar como muy pronto?',
    options: [
      'A las 02:15 — bastan 9 horas de descanso',
      'A las 04:15',
      'En cuanto te sientas descansado, no hay un límite fijo',
    ],
    correctIndex: 1,
    explanation: 'El descanso diario es de 11 horas como mínimo, es decir, '
        'como muy pronto a las 04:15. Las 9 horas son el límite del tiempo '
        'de conducción, no del descanso: las dos cifras se confunden con '
        'frecuencia.',
  ),

  // ══════════════════════════ gb4 — Errores típicos
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Un compañero rellena las hojas de toda la semana el viernes '
        'por la noche. Los tiempos son correctos en cuanto al contenido. '
        '¿Cómo se valora eso?',
    options: [
      'Es una infracción y se detecta en un control',
      'No hay problema mientras los tiempos anotados se correspondan con la '
          'verdad',
      'Solo es una cuestión de orden, pero sin relevancia jurídica',
    ],
    correctIndex: 0,
    explanation: 'Registrar significa registrar sin demora. Las hojas '
        'escritas a posteriori se reconocen por la misma letra, por tiempos '
        'llamativamente redondos y por kilometrajes que no encajan con el '
        'recorrido. Que los tiempos sean correctos no subsana la infracción '
        'de la obligación de registro.',
  ),
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'El jueves te das cuenta de que el martes no anotaste la '
        'pausa del mediodía. Recuerdas la hora con seguridad. ¿Qué haces?',
    options: [
      'Anotarla como incorporación posterior con la fecha de la '
          'incorporación e informar al planificador',
      'Insertar la anotación de modo que parezca escrita el martes',
      'Dejar el hueco: una anotación posterior solo lo empeora',
    ],
    correctIndex: 0,
    explanation: 'Una corrección honesta y visiblemente fechada está '
        'permitida y es mejor que un hueco. Presentar la anotación como si '
        'se hubiera hecho el martes es el paso del descuido al engaño, y '
        'pesa claramente más.',
  ),
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Hoy has conducido 9,5 horas, aunque tu contingente semanal '
        'para las 10 horas ya estaba agotado. ¿Qué anotas?',
    options: [
      'Exactamente 9,0 horas, para que la hoja parezca conforme a las '
          'normas',
      'Las 9,5 horas realmente conducidas',
      'Nada para ese día, así no se nota',
    ],
    correctIndex: 1,
    explanation: 'Siempre anotas los tiempos reales. Una anotación '
        'maquillada convierte un exceso en una declaración falsa y empeora '
        'las cosas. Una hoja que falta es además una infracción propia: '
        'omitir no ayuda.',
  ),

  // ══════════════════════════ gb5 — Llevar encima, entregar, conservar
  DrivingQuestion(
    moduleId: 'gb5',
    question: '¿Qué registros tienes que llevar contigo en el vehículo?',
    options: [
      'Solo la hoja del día en curso',
      'Las hojas de la semana natural en curso',
      'El día en curso y los 28 días anteriores',
    ],
    correctIndex: 2,
    explanation: 'Hay que llevar consigo los registros de los últimos 28 '
        'días, incluido el día en curso. Que las hojas más antiguas estén '
        'debidamente en la empresa cumple la obligación de conservación, '
        'pero no la de llevarlas encima: son dos obligaciones distintas.',
  ),
  DrivingQuestion(
    moduleId: 'gb5',
    question: '¿Cuánto tiempo tiene que conservar el empresario las hojas '
        'de control diarias en la empresa?',
    options: [
      'Un año',
      '28 días, después pueden destruirse',
      'Tres meses desde el final del trimestre',
    ],
    correctIndex: 0,
    explanation: 'El empresario conserva los registros durante un año y los '
        'presenta cuando se le requiere. Los 28 días son el plazo para que '
        'el conductor los lleve consigo: se confunden a menudo con el plazo '
        'de conservación.',
  ),
  DrivingQuestion(
    moduleId: 'gb5',
    question: '¿Quién controla el cumplimiento de la obligación de '
        'registro?',
    options: [
      'Exclusivamente la policía, y solo en los controles de carretera',
      'La BAG y la policía — en los controles de carretera y en la empresa',
      'El TÜV en el marco de la inspección técnica del vehículo',
    ],
    correctIndex: 1,
    explanation: 'El control lo realizan la BAG (Oficina Federal de '
        'Logística y Movilidad) y la policía, tanto en la carretera como en '
        'la empresa. La inspección técnica se refiere al estado técnico del '
        'vehículo y no tiene nada que ver con los registros.',
  ),

  // ══════════════════════════ gb6 — Consecuencias
  DrivingQuestion(
    moduleId: 'gb6',
    question: '¿Con qué hay que contar si faltan hojas o están incompletas?',
    options: [
      'Con una multa a partir de 100 euros, y más alta según la gravedad',
      'Con ninguna consecuencia: es una norma puramente interna de la '
          'empresa',
      'Con un aviso gratuito sin más consecuencias',
    ],
    correctIndex: 0,
    explanation: 'Los registros que faltan o están incompletos son una '
        'infracción administrativa; la multa empieza en torno a los 100 '
        'euros y aumenta con la gravedad. En caso de infracciones graves o '
        'reiteradas puede incoarse además un procedimiento sobre la '
        'fiabilidad de la empresa.',
  ),
  DrivingQuestion(
    moduleId: 'gb6',
    question: 'El planificador dice: «Haz aún esas dos paradas, la pausa '
        'simplemente la escribes.» ¿Cómo reaccionas?',
    options: [
      'Seguir la instrucción — la responsabilidad la asume entonces el '
          'planificador',
      'Omitir la pausa, pero al menos anotar honestamente que falta',
      'Hacer la pausa, anotarla correctamente y comunicar las paradas '
          'pendientes',
    ],
    correctIndex: 2,
    explanation: 'Una instrucción verbal no suprime tu obligación de '
        'registro: tú firmas la hoja y confirmas con ello el contenido. '
        'Suprimir la pausa a sabiendas sería además una infracción de las '
        'normas sobre tiempos de conducción. La empresa tiene que hacer '
        'posible el cumplimiento, no eludirlo.',
  ),
];

// La selección del idioma y el filtrado por capítulos se realizan en la
// capa de datos de la formación — véase green_book_quiz_de.dart.
