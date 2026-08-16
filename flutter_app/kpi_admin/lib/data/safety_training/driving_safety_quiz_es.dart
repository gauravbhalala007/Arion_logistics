// lib/data/safety_training/driving_safety_quiz_es.dart
//
// Preguntas de la formación DSP de seguridad vial — versión española.
// La estructura es idéntica a la versión alemana (máster): el mismo
// número de preguntas, el mismo orden y las mismas respuestas correctas.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> drivingQuestionsEs = [
  // ══════════════════════════════════ M1 — Cultura de seguridad
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Llevas 20 paradas de retraso respecto al plan. ¿Qué '
        'reacción se corresponde con la cultura de seguridad de la '
        'empresa?',
    options: [
      'Ir más rápido entre paradas, pero mantener el cuidado en las '
          'paradas mismas',
      'Comunicar el retraso y continuar la ruta al ritmo seguro de '
          'siempre',
      'Acortar los tiempos de control al maniobrar, pero dejar la '
          'conducción sin cambios',
    ],
    correctIndex: 1,
    explanation: 'La presión de tiempo es un problema de planificación y '
        'se comunica, no se compensa al volante. Las otras dos '
        'respuestas suenan a compromiso, pero solo desplazan el riesgo: '
        'más velocidad entre paradas alarga precisamente la distancia de '
        'detención, y recortar los controles de maniobra afecta a la '
        'actividad en la que se produce el 70 % de todos los daños.',
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Tu planificador te ordena salir con una luz de freno '
        'averiada. ¿Quién es responsable si por eso se produce un alcance '
        'por detrás?',
    options: [
      'El planificador, porque dio la instrucción',
      'La empresa, porque pone el vehículo a disposición',
      'Nadie — una sola luz de freno no es un defecto relevante para la '
          'seguridad',
      'Tú, como conductor del vehículo',
    ],
    correctIndex: 3,
    explanation: 'Como conductor respondes del estado seguro del vehículo '
        'que mueves — una instrucción verbal no lo anula. Que la empresa '
        'ponga el vehículo suena razonable, pero no te exime: la multa y '
        'los puntos te caen a ti personalmente. Lo correcto es comunicar '
        'el defecto y exigir otro vehículo.',
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Maniobrando faltaron solo unos centímetros para chocar con '
        'un bolardo — no ha pasado nada. ¿Qué es lo correcto?',
    options: [
      'Comunicarlo como casi accidente',
      'No hacer nada, no se ha producido ningún daño y nadie ha corrido '
          'peligro',
      'Comunicarlo solo si lo ha visto un compañero o una cámara',
    ],
    correctIndex: 0,
    explanation: 'Un casi accidente señala un punto peligroso antes de '
        'que alcance a alguien — comunicado, queda neutralizado para el '
        'siguiente compañero. La idea de «sin daño, sin tema» es el '
        'motivo más frecuente de que ese mismo punto acabe provocando un '
        'daño semanas después.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: '¿En qué actividad se produce alrededor del 70 % de todos '
        'los daños en furgonetas?',
    options: [
      'En autopista y carretera comarcal a alta velocidad',
      'Al girar en cruces en el tráfico urbano',
      'Al maniobrar y dar marcha atrás',
    ],
    correctIndex: 2,
    explanation: 'La gran mayoría de los daños se produce al paso, '
        'maniobrando. La alta velocidad causa los accidentes más graves, '
        'pero no la mayoría de los daños — y es justo esa confusión la '
        'que lleva a prestar poca atención al maniobrar.',
  ),

  // ══════════════════════════════════ M2 — Revisión y carga
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Según las reglas técnicas reconocidas, la carga debe '
        'asegurarse contra 0,8 g hacia delante. ¿A qué fuerza de '
        'retención equivale eso aproximadamente en un paquete de 20 kg?',
    options: [
      'unos 2 kg',
      'unos 8 kg',
      'unos 16 kg',
      'unos 200 kg',
    ],
    correctIndex: 2,
    explanation: '0,8 × 20 kg da unos 16 kg de fuerza de retención. '
        '«Unos 2 kg» subestima la fuerza de forma dramática y es la razón '
        'por la que los paquetes se consideran inofensivos; «200 kg» '
        'confunde el valor de sujeción con la fuerza de impacto en una '
        'colisión real, que de hecho está muy por encima.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: '¿Cómo cargas correctamente la zona de carga?',
    options: [
      'Lo pesado abajo y delante, contra el mamparo, con el peso '
          'repartido de forma uniforme',
      'Lo pesado arriba, para que los paquetes pesados no queden debajo '
          'de los ligeros al cogerlos',
      'Lo pesado atrás, junto a la puerta, para que los envíos pesados '
          'salgan primero',
    ],
    correctIndex: 0,
    explanation: 'Pesado + abajo + delante mantiene el centro de gravedad '
        'bajo y la masa donde el mamparo puede retenerla. Las otras dos '
        'variantes están pensadas desde el flujo de trabajo, no desde la '
        'física: el peso arriba aumenta la tendencia a volcar, y el peso '
        'atrás descarga el eje delantero y empeora la dirección.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Tras dos tercios de la ruta, la zona de carga está medio '
        'vacía. ¿Qué rige ahora para la sujeción de la carga?',
    options: [
      'Es menos importante, porque hay bastante menos peso a bordo',
      'Hay que rehacerla — los paquetes que quedan tienen ahora más '
          'recorrido para coger velocidad',
      'Sigue valiendo igual, no hay nada que hacer',
    ],
    correctIndex: 1,
    explanation: 'Cuanto más vacía está la zona de carga, mayor es el '
        'trecho en el que un paquete puede acelerar antes de golpear. '
        '«Menos peso, menos peligro» suena lógico, pero es falso: lo '
        'decisivo no es la masa total, sino el paquete suelto sin '
        'asegurar.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: '¿Qué te exige la DGUV Vorschrift 70 (Fahrzeuge) antes de '
        'empezar el turno de trabajo?',
    options: [
      'Una revisión técnica con elevador y banco de frenos',
      'Una revisión del vehículo en busca de defectos evidentes',
      'Una revisión solo en los vehículos que conduces por primera vez',
    ],
    correctIndex: 1,
    explanation: 'Lo que se exige es el control de defectos evidentes '
        'antes del turno — justo lo que aporta la vuelta al vehículo. La '
        'revisión técnica es cosa del taller y no sustituye tu vuelta; y '
        'la obligación vale para cada vehículo y cada día, no solo para '
        'los desconocidos.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: '¿Qué profundidad de dibujo exige la ley como mínimo — y '
        'qué es razonable con la calzada mojada?',
    options: [
      '3 mm por ley; con calzada mojada bastan entonces 1,6 mm',
      '1,6 mm por ley; eso sigue bastando con la calzada mojada',
      '4 mm por ley, todo el año y para todos los neumáticos',
      '1,6 mm por ley; con calzada mojada son razonables al menos 3 mm',
    ],
    correctIndex: 3,
    explanation: 'El mínimo legal es 1,6 mm; en la práctica, con calzada '
        'mojada, son razonables al menos 3 mm. La respuesta «1,6 mm '
        'bastan también con lluvia» es el error clásico: el mínimo es el '
        'límite con la infracción, no el límite con la seguridad — con '
        '1,6 mm el neumático apenas desplaza agua.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Llevas la próxima parada en el asiento del acompañante '
        'para poder cogerla rápido. ¿Cuál es el problema principal?',
    options: [
      'En una frenada, el paquete se convierte en un proyectil y puede '
          'acabar bajo el pedal de freno',
      'En un control de tráfico da una impresión de desorden',
      'Está permitido mientras el paquete pese menos de 10 kg',
    ],
    correctIndex: 0,
    explanation: 'Todo lo que hay en la cabina sigue moviéndose en una '
        'frenada a tu velocidad inicial — en el peor de los casos hasta '
        'el hueco de los pies, bajo el pedal. Para esto no hay ningún '
        'límite de peso: también un paquete ligero bloquea un pedal.',
  ),

  // ══════════════════════════════════ M3 — Conducción defensiva
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Circulas fuera de poblado a 80 km/h con la calzada seca. '
        '¿Qué distancia mínima con el vehículo de delante es correcta?',
    options: [
      'Unos 20 metros — equivalen a tres longitudes de vehículo',
      'Unos 45 metros — unos dos segundos o la mitad del valor del '
          'velocímetro',
      'Unos 10 metros, mientras estés atento y la carretera esté libre',
    ],
    correctIndex: 1,
    explanation: 'Dos segundos equivalen a unos 45 metros a 80 km/h, y la '
        'mitad del valor del velocímetro son 40 metros — ambas cosas '
        'encajan. Veinte metros parecen mucho en la carretera, pero '
        'quedan por debajo de la mera distancia de reacción de 24 metros: '
        'habrías colisionado antes de que el freno llegue a actuar.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: '¿Cuál es la distancia de detención a 50 km/h según las '
        'reglas rápidas (frenada normal)?',
    options: [
      '15 metros',
      '25 metros',
      '40 metros',
      '65 metros',
    ],
    correctIndex: 2,
    explanation: 'Distancia de reacción (50 ÷ 10) × 3 = 15 m más '
        'distancia de frenado (50 ÷ 10)² = 25 m dan 40 m. Quien dice 25 '
        'metros ha calculado solo el frenado y ha olvidado la reacción — '
        'es el error de cálculo más frecuente y justo la parte del tramo '
        'que recorres a plena velocidad.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: '¿Cómo calculas la distancia de reacción según la regla '
        'rápida?',
    options: [
      '(velocidad ÷ 10) × 3',
      '(velocidad ÷ 10) × (velocidad ÷ 10)',
      'velocidad ÷ 2',
    ],
    correctIndex: 0,
    explanation: 'La distancia de reacción es (km/h ÷ 10) × 3. La segunda '
        'fórmula es la distancia de frenado, y la tercera es el valor '
        'orientativo de la distancia de seguridad — se parecen, pero '
        'describen cosas totalmente distintas.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Duplicas tu velocidad de 30 a 60 km/h. ¿Cómo cambia la '
        'distancia de frenado propiamente dicha?',
    options: [
      'Se duplica',
      'Se cuadruplica',
      'Se triplica',
      'Se mantiene casi igual, porque a más velocidad el freno agarra '
          'con más fuerza',
    ],
    correctIndex: 1,
    explanation: 'La distancia de frenado crece con el cuadrado de la '
        'velocidad: de 9 metros se pasa a 36 metros. La respuesta '
        'evidente, «se duplica», subestima justamente eso — y explica por '
        'qué 20 km/h de más en una calle residencial se perciben como '
        'inofensivos.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: '¿Por qué con la furgoneta a plena carga tienes que tomar '
        'las curvas bastante más despacio que con un turismo?',
    options: [
      'Porque el centro de gravedad alto aumenta mucho la tendencia a '
          'volcar',
      'Porque la dirección se vuelve menos precisa con carga',
      'Porque los neumáticos se ablandan bajo carga y agarran más',
    ],
    correctIndex: 0,
    explanation: 'Una furgoneta cargada en altura vuelca donde un turismo '
        'todavía derrapa — y casi no lo anuncia. La precisión de la '
        'dirección también cambia, pero no es el riesgo real: el vuelco '
        'ocurre de repente y acaba fuera de la calzada.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Quieres girar a la derecha en un semáforo y un ciclista '
        'está a tu derecha. El semáforo se pone en verde. ¿Qué haces '
        'primero?',
    options: [
      'Arrancar con decisión y girar antes de que el ciclista coja '
          'velocidad',
      'Mirar por el retrovisor derecho y luego girar',
      'Mirar por encima del hombro a la derecha y dejar pasar al '
          'ciclista',
    ],
    correctIndex: 2,
    explanation: 'En cuanto arrancas y giras, el ciclista pasa al ángulo '
        'muerto — y además tu parte trasera barre hacia su carril. Mirar '
        'por el espejo suena correcto, pero deja de bastar justo cuando '
        'importa: el espejo no muestra por completo la zona a la derecha '
        'de la cabina.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: '¿Qué distancia lateral mínima debes mantener en poblado al '
        'adelantar a un ciclista?',
    options: [
      '1,0 metro',
      '1,5 metros',
      '2,0 metros',
    ],
    correctIndex: 1,
    explanation: 'En poblado son 1,5 metros; fuera de poblado, 2,0 '
        'metros. Quien toma 2,0 metros como valor urbano confunde ambos — '
        'y quien adelanta a 1,0 metro incumple la distancia mínima y '
        'responde si el ciclista se cae.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: '¿A qué distancia por delante debería estar dirigida tu '
        'mirada al conducir?',
    options: [
      'Al parachoques del vehículo de delante, para ver enseguida cuándo '
          'frena',
      'Al propio capó, porque así mantienes el carril con más precisión',
      'De 12 a 15 segundos por delante',
    ],
    correctIndex: 2,
    explanation: 'La mirada lejana te da tiempo: ves semáforos, luces de '
        'freno y peatones antes de tener que reaccionar. Mirar al '
        'parachoques da sensación de atención, pero te convierte en un '
        'mero reaccionador — te enteras del peligro cuando el de delante '
        'ya está frenando.',
  ),

  // ══════════════════════════════════ M4 — Marcha atrás y maniobras
  DrivingQuestion(
    moduleId: 'm4',
    question: '¿Qué significa GOAL al dar marcha atrás?',
    options: [
      '«Get Out And Look» — parar, bajar y mirar detrás del vehículo',
      '«Go Only At Low speed» — dar marcha atrás exclusivamente al paso',
      '«Guide On A Line» — orientarse por una marca en el suelo',
    ],
    correctIndex: 0,
    explanation: 'GOAL significa bajar y mirar — descubre bolardos bajos, '
        'desniveles y niños a los que desde el asiento nunca ves. Ir al '
        'paso también es obligatorio, pero no sustituye el mirar: incluso '
        'al paso entras en una zona que no puedes ver.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Tu vehículo tiene cámara de marcha atrás. ¿Qué cambia eso '
        'respecto a GOAL?',
    options: [
      'GOAL deja de ser necesario, porque la cámara muestra la zona de '
          'detrás del vehículo',
      'Nada',
      'GOAL solo hace falta entonces de noche y con mala visibilidad',
    ],
    correctIndex: 1,
    explanation: 'La cámara solo muestra un recorte, distorsiona las '
        'distancias y se queda ciega con lluvia, nieve y suciedad — sobre '
        'todo, no ve lo que entra en tu trayectoria por el lateral. '
        'Complementa a GOAL, nunca lo sustituye.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: '¿Dónde se coloca correctamente quien te guía?',
    options: [
      'Justo detrás del vehículo, porque desde ahí valora mejor la '
          'distancia',
      'Delante del vehículo, para parar al mismo tiempo el tráfico',
      'De lado, de forma que lo veas permanentemente por el espejo',
    ],
    correctIndex: 2,
    explanation: 'Solo quien está de lado y permanentemente visible puede '
        'guiar con seguridad. La posición justo detrás del vehículo '
        'parece la más cercana a la acción, pero es exactamente la zona '
        'en la que quien guía acaba arrollado en cuanto lo pierdes de '
        'vista.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'De repente dejas de ver por el espejo a quien te guía. '
        '¿Qué haces?',
    options: [
      'Seguir más despacio hasta que vuelva a aparecer',
      'Parar de inmediato',
      'Tocar brevemente el claxon y seguir para que vuelva a mostrarse',
    ],
    correctIndex: 1,
    explanation: 'Sin contacto visual no hay señal válida — es decir, '
        'parar, no solo ir más despacio. «Seguir más despacio» suena '
        'prudente, pero significa que sigues entrando en una zona que ya '
        'nadie vigila por ti.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: '¿Qué exige el § 9 Abs. 5 StVO al dar marcha atrás?',
    options: [
      'Encender los intermitentes de emergencia',
      'Circular como mucho al paso',
      'Excluir cualquier peligro para otros — si es necesario, con '
          'alguien que guíe',
    ],
    correctIndex: 2,
    explanation: 'La norma exige excluir todo peligro, si hace falta '
        'mediante una persona que guíe — el criterio es por tanto el '
        'resultado, no una velocidad determinada. Ir al paso y poner los '
        'intermitentes son buena práctica, pero por sí solos no cumplen '
        'la obligación.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'La última parada está en un patio interior estrecho: de '
        'frente entras, pero salir solo se puede marcha atrás pasando '
        'junto a un muro. ¿Cuál es la decisión más segura?',
    options: [
      'Parar en la calle y hacer los últimos metros a pie o con la '
          'carretilla',
      'Entrar de frente, porque así ya conoces la entrada para la '
          'salida',
      'Entrar rápido marcha atrás mientras la calle siga libre',
    ],
    correctIndex: 0,
    explanation: 'La marcha atrás más segura es la que no llega a '
        'producirse. Que «conoces la entrada después de haber entrado» es '
        'un espejismo: al salir, los puntos críticos quedan detrás de ti, '
        'y el tráfico que espera añade presión.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M5 — Clima y visibilidad
  DrivingQuestion(
    moduleId: 'm5',
    question: 'La dirección se vuelve de repente ligera, los neumáticos '
        'flotan sobre una película de agua. ¿Qué haces?',
    options: [
      'Frenar con fuerza y contravirar',
      'Levantar el pie, mantener el volante quieto y recto, dejar rodar',
      'Acelerar para salir rápido de la zona con agua',
    ],
    correctIndex: 1,
    explanation: 'Mientras la película de agua sostiene, el freno y la '
        'dirección no actúan — y lo hacen de golpe cuando el neumático '
        'vuelve a agarrar; de ahí nace el derrape. Frenar y contravirar '
        'es la reacción intuitiva, pero equivocada.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: '¿De qué depende sobre todo el riesgo de aquaplaning?',
    options: [
      'Del peso de la carga',
      'De la antigüedad del vehículo y del sistema de frenos',
      'De la profundidad del dibujo, la altura del agua y, sobre todo, '
          'la velocidad',
    ],
    correctIndex: 2,
    explanation: 'El riesgo crece de forma más que proporcional con la '
        'velocidad y baja con la profundidad del dibujo — el dibujo tiene '
        'que evacuar el agua por delante del neumático. La carga es '
        'secundaria: más peso aprieta más el neumático contra el asfalto, '
        'pero no cambia que un dibujo liso a cierta velocidad ya no '
        'desplaza agua.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Con niebla ves todavía unos 40 metros. ¿A qué velocidad '
        'puedes circular como máximo?',
    options: [
      'Como mucho a 40 km/h',
      'Hasta el límite permitido, mientras lleves las luces encendidas',
      'Como mucho a 80 km/h si llevas la antiniebla trasera encendida',
    ],
    correctIndex: 0,
    explanation: 'Regla rápida: la visibilidad en metros es tu límite en '
        'km/h — con 40 metros de visibilidad, por tanto, 40 km/h. Las '
        'luces y la antiniebla trasera te hacen más visible, pero no '
        'alargan tu visibilidad ni, con ella, la velocidad permitida.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: '¿Cuándo exige el § 2 Abs. 3a StVO neumáticos aptos para '
        'invierno?',
    options: [
      'Siempre en el periodo de octubre a Semana Santa, con independencia '
          'del tiempo',
      'Con placas de hielo, nieve pisada, aguanieve o escarcha',
      'Solo si hay una capa cerrada de nieve sobre la calzada',
    ],
    correctIndex: 1,
    explanation: 'En Alemania rige una obligación situacional: depende '
        'del estado de la vía, no del calendario. «De octubre a Semana '
        'Santa» es solo una regla práctica para el cambio de neumáticos y '
        'no una base legal — y el aguanieve ya basta, no hace falta una '
        'capa cerrada.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Hace un frío helador y vas justo de tiempo. Rascas solo el '
        'lado del conductor del parabrisas. ¿Qué rige?',
    options: [
      'Permitido, mientras circules claramente más despacio',
      'Permitido, si la calefacción despeja el resto durante la marcha',
      'No permitido — todas las lunas, los espejos, las luces y la '
          'matrícula deben estar despejados',
    ],
    correctIndex: 2,
    explanation: 'La «mirilla» rascada es una infracción y, en un '
        'accidente, un reproche de culpa grave. Que la calefacción vaya '
        'despejando después no es ninguna excepción: lo determinante es '
        'el estado al arrancar, no tres minutos más tarde.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: '¿Por qué una furgoneta VACÍA corre especial peligro con '
        'temporal?',
    options: [
      'Porque le falta el peso de la carga que la mantiene sobre la '
          'calzada',
      'Porque la resistencia al aire es mayor sin carga',
      'Porque la presión de los neumáticos es más alta en vacío',
    ],
    correctIndex: 0,
    explanation: 'La superficie expuesta al viento es igual de grande '
        'vacía que cargada, pero la masa es mucho menor — de modo que la '
        'misma racha desplaza más al vehículo. La resistencia al aire no '
        'cambia en absoluto por la carga que va dentro: ahí está el error '
        'de razonamiento.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M6 — Distracción y cansancio
  DrivingQuestion(
    moduleId: 'm6',
    question: '¿Puedes coger el móvil durante la marcha para cambiar de '
        'música?',
    options: [
      'Sí, si solo dura un segundo y la carretera está libre',
      'Solo en un semáforo en rojo',
      'No',
    ],
    correctIndex: 2,
    explanation: 'Ya el simple hecho de coger o sostener el aparato es la '
        'infracción — con independencia de para qué. El semáforo en rojo '
        'no es una excepción mientras el motor esté en marcha. La música, '
        'el destino y el volumen se ajustan antes de salir, con el '
        'vehículo parado.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: '¿Cuándo puedes coger legalmente el móvil o el escáner?',
    options: [
      'Solo si el vehículo está parado Y el motor apagado',
      'En cuanto el vehículo está parado — el sistema de arranque y '
          'parada basta para ello',
      'Un momento durante la marcha, si el tramo es recto y está libre',
    ],
    correctIndex: 0,
    explanation: 'La excepción solo se aplica con el vehículo parado y el '
        'motor apagado. El sistema automático de arranque y parada '
        'expresamente no cuenta — y es justo en eso en lo que muchos '
        'confían en el semáforo en rojo, donde se llevan la multa.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Circulas a 50 km/h y miras 2 segundos la pantalla. '
        '¿Cuánto recorres sin ver la carretera?',
    options: [
      'unos 8 metros',
      'unos 28 metros',
      'unos 14 metros',
      'unos 50 metros',
    ],
    correctIndex: 1,
    explanation: '50 km/h son unos 14 metros por segundo, es decir, en 2 '
        'segundos unos 28 metros. Quien elige «14 metros» ha calculado '
        'solo un segundo — un error típico que hace parecer la mitad el '
        'tramo recorrido a ciegas.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Das una cabezada de 4 segundos a 80 km/h. ¿Qué distancia '
        'recorres sin control?',
    options: [
      'unos 30 metros',
      'unos 50 metros',
      'unos 90 metros',
      'unos 160 metros',
    ],
    correctIndex: 2,
    explanation: '80 km/h son unos 22 metros por segundo; por 4 dan unos '
        '89 metros. A diferencia de la mirada al móvil, en ese tiempo no '
        'diriges en absoluto — el vehículo se sale del carril. Por eso la '
        'idea de una cabezada «corta» es tan peligrosa.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: '¿Qué ayuda de verdad contra el cansancio agudo al volante?',
    options: [
      'Abrir la ventanilla y poner música alta',
      'Tomar café e ir más rápido para acabar antes',
      'Parar, dormir de 15 a 20 minutos y después moverse',
    ],
    correctIndex: 2,
    explanation: 'Solo el sueño y el movimiento restablecen la atención. '
        'El aire fresco y la música alta funcionan como mucho unos '
        'minutos y además fingen un estado de alerta — y es justo en esa '
        'fase cuando más se sobreestima uno.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Un auricular para el manos libres y el otro oído libre: '
        '¿está bien durante la marcha?',
    options: [
      'Sí, un oído libre basta para el tráfico',
      'Sí, mientras el volumen esté bajo',
      'No',
    ],
    correctIndex: 2,
    explanation: 'Tienes que poder localizar con seguridad bocinas, '
        'gritos y vehículos de emergencia — y para eso necesitas ambos '
        'oídos; al maniobrar, el oído suele ser el único aviso. Un '
        'volumen bajo no cambia que un oído está ocupado.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: '¿Qué te expones si con el móvil en la mano pones en '
        'peligro a otro usuario de la vía?',
    options: [
      '100 € y 1 punto',
      '150 €, 2 puntos y 1 mes de retirada del permiso',
      'Una advertencia verbal sin registro',
    ],
    correctIndex: 1,
    explanation: '100 € y 1 punto son el supuesto básico sin peligro; si '
        'se añade una situación de peligro, sube a 150 €, 2 puntos y un '
        'mes de retirada del permiso. Para ti, como conductor '
        'profesional, el problema no es el dinero, sino la retirada del '
        'permiso.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Hoy el plan de ruta no se puede hacer con seguridad. ¿Cuál '
        'es la reacción correcta?',
    options: [
      'Seguir trabajando con seguridad y comunicar pronto el problema de '
          'planificación',
      'Suprimir las pausas y acortar los controles al maniobrar',
      'Ir más rápido entre paradas y recuperar ahí el tiempo',
    ],
    correctIndex: 0,
    explanation: 'Se adapta el plan, no la seguridad. Además, lo decisivo '
        'es el momento: un aviso a primera hora de la tarde todavía puede '
        'servir de algo; uno por la noche, ya no. Suprimir las pausas '
        'agrava el problema, porque tu atención cae justamente entonces.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M7 — Subir/bajar y levantar
  DrivingQuestion(
    moduleId: 'm7',
    question: '¿Cómo dice la regla de los 3 puntos («2+1») de la BG '
        'Verkehr al subir y bajar del vehículo?',
    options: [
      'Una mano y dos pies están siempre en el vehículo',
      'Dos manos y un pie están siempre en contacto con el vehículo',
      'Ambos pies están en el suelo antes de soltar los asideros',
    ],
    correctIndex: 1,
    explanation: 'Dos manos más un pie dan tres puntos firmes, de modo '
        'que un simple resbalón nunca acaba en caída. «Primero ambos pies '
        'en el suelo» describe justo el momento en el que no tienes '
        'ningún apoyo — esa es la variante del salto.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: '¿Cómo bajas correctamente de la cabina?',
    options: [
      'De frente, de espaldas a la puerta, dando un salto en el último '
          'paso',
      'Girándote de lado desde el asiento y cayendo sobre ambos pies',
      'De espaldas, con la cara hacia el vehículo, como en una escalera',
    ],
    correctIndex: 2,
    explanation: 'Solo con la cara hacia el vehículo puedes usar los '
        'asideros y el estribo y mantener tres puntos de apoyo. Girarse '
        'desde el asiento parece más rápido, pero carga de golpe rodillas '
        'y tobillos con todo el peso corporal — es el error de bajada más '
        'frecuente.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: '¿Cuál de estos agarres NO cuenta como punto de apoyo '
        'seguro?',
    options: [
      'El asidero del montante A',
      'El canto de la puerta',
      'El asidero del marco de la puerta',
    ],
    correctIndex: 1,
    explanation: 'El canto de la puerta pertenece a una pieza móvil: la '
        'puerta puede ceder o cerrarse, justo cuando cargas tu peso sobre '
        'ella. Lo mismo vale para el volante, el asiento, el neumático y '
        'el buje — los puntos seguros son solo los asideros previstos '
        'para ello.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Llevas el escáner y un paquete en las manos y quieres '
        'bajar de la zona de carga. ¿Qué es lo correcto?',
    options: [
      'Dejar primero ambas cosas y bajar después con las manos libres',
      'Sujetar el paquete bajo el brazo y agarrarte con la mano libre',
      'Bajar rápido, total, solo son dos escalones',
    ],
    correctIndex: 0,
    explanation: 'Con las manos llenas no tienes tres puntos de apoyo y '
        'no puedes amortiguar una caída. La variante de una mano suena a '
        'compromiso, pero es exactamente la situación en la que un '
        'resbalón acaba directamente en caída: un punto no te sostiene.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Paras junto al bordillo y quieres abrir la puerta del '
        'conductor. ¿Qué protege mejor a un ciclista que viene por '
        'detrás?',
    options: [
      'Abrir la puerta solo una rendija y esperar un momento',
      'Abrir la puerta rápido y de par en par, para que se vea bien',
      'Antes de abrir, mirar un momento por el retrovisor exterior',
      'Mirada por encima del hombro y por el espejo — y abrir la puerta '
          'con la mano más alejada',
    ],
    correctIndex: 3,
    explanation: 'Agarrar con la mano más alejada gira tu tronco '
        'automáticamente hacia atrás y fuerza la mirada. La breve mirada '
        'al espejo por sí sola no basta, porque un ciclista en el ángulo '
        'muerto no es visible justo entonces; y abrir una rendija no '
        'avisa a quien ya está a tu lado.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: '¿Cuál es la combinación más peligrosa para la columna al '
        'levantar peso?',
    options: [
      'Levantar y girar el tronco al mismo tiempo',
      'Levantar desde cuclillas, con las rodillas muy flexionadas',
      'Levantar con la carga pegada al cuerpo',
    ],
    correctIndex: 0,
    explanation: 'Carga más giro sobrecarga los discos de forma '
        'asimétrica y es la causa clásica de las lesiones agudas de '
        'espalda — en su lugar hay que mover los pies. Las cuclillas y la '
        'carga pegada al cuerpo son, en cambio, exactamente la técnica '
        'correcta.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Al bajar te tuerces ligeramente el tobillo, pero puedes '
        'seguir trabajando. ¿Qué es lo correcto?',
    options: [
      'Esperar y comunicarlo solo si al día siguiente sigue doliendo',
      'No hacer nada — solo fue una torcedura sin baja',
      'Comunicarlo de inmediato y anotarlo en el libro de primeros '
          'auxilios',
    ],
    correctIndex: 2,
    explanation: 'Solo los incidentes documentados cuentan después como '
        'accidente laboral, y un problema de ligamentos sin tratar cura '
        'peor. Esperar al día siguiente está muy extendido y es justo el '
        'motivo de que después muchas veces ya no se reconozca la '
        'relación con el trabajo.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M8 — Puerta y entorno
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Un perro grande ladra en la verja del jardín. El cliente '
        'ha anotado en las indicaciones de entrega: «el perro es bueno». '
        '¿Qué haces?',
    options: [
      'Entrar con calma — el cliente conoce mejor a su perro',
      'No entrar en la propiedad, intentar contactar y dejar el aviso '
          'para los compañeros',
      'Dejar el paquete al otro lado de la valla y seguir',
    ],
    correctIndex: 1,
    explanation: 'Una indicación de entrega no es una autorización de '
        'seguridad: el cliente conoce a su perro con la familia, no con '
        'una persona desconocida que lleva un objeto grande. Además, '
        'dejar el paquete por encima de la valla no es una entrega '
        'correcta.',
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Un perro suelto viene ladrando hacia ti. ¿Qué es lo '
        'correcto?',
    options: [
      'Quedarse quieto con calma, apartar la mirada, ponerse de lado y '
          'retroceder despacio',
      'Volver rápido al vehículo y cerrar la puerta',
      'Levantar la voz y alzar el paquete para defenderte',
    ],
    correctIndex: 0,
    explanation: 'La calma, la mirada apartada y el retroceso lento le '
        'quitan al perro el motivo. Correr hacia el vehículo suena '
        'razonable, pero es un error: huir dispara el instinto de caza, y '
        'el perro es más rápido que tú.',
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'El camino más corto hasta la puerta pasa por un césped '
        'mojado. ¿Qué haces?',
    options: [
      'Cortar — con 120 paradas, el rodeo suma bastante',
      'Cortar, pero solo con luz de día y tiempo seco',
      'Tomar el camino pavimentado',
    ],
    correctIndex: 2,
    explanation: 'Tropezar, resbalar y caerse es la causa de lesión más '
        'frecuente en el reparto, y casi siempre ocurre en los últimos '
        'metros. La cuenta del tiempo no sale: el rodeo cuesta segundos; '
        'una caída, 24 días de baja de media.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: '¿Qué rige cuando dejas el vehículo para hacer una '
        'entrega?',
    options: [
      'Motor apagado, llave contigo, cerrar y, en pendiente, girar las '
          'ruedas',
      'El motor puede quedar en marcha mientras estés a la vista',
      'Basta con poner bien el freno de mano',
    ],
    correctIndex: 0,
    explanation: 'Quien abandona su vehículo debe asegurarlo contra un '
        'uso no autorizado y evitar accidentes. «A la vista» no es '
        'ninguna excepción — un vehículo en marcha y abierto desaparece '
        'en segundos, y en pendiente el freno de mano por sí solo no '
        'retiene con fiabilidad una furgoneta cargada.',
  ),

  // ══════════════════════════════════ M9 — Emergencia y accidente
  DrivingQuestion(
    moduleId: 'm9',
    question: '¿En qué orden actúas en el lugar de un accidente con '
        'heridos?',
    options: [
      'Prestar primeros auxilios, después señalizar, después llamar a '
          'emergencias',
      'Señalizar, después llamar a emergencias, después primeros '
          'auxilios',
      'Llamar a emergencias, después hacer fotos para el seguro, después '
          'primeros auxilios',
    ],
    correctIndex: 1,
    explanation: 'Primero asegurar el lugar, si no de un accidente sale '
        'un segundo — contigo como víctima. Correr de inmediato hacia el '
        'herido parece lo humanamente correcto, pero en carretera '
        'comarcal y en autopista es mortalmente peligroso; las fotos no '
        'tienen ningún lugar en esta fase.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: '¿A qué distancia colocas el triángulo de emergencia en la '
        'autopista?',
    options: [
      'aprox. 50 metros',
      'aprox. 100 metros',
      'aprox. 150–200 metros',
    ],
    correctIndex: 2,
    explanation: 'En poblado unos 50 m, fuera de poblado unos 100 m, en '
        'autopista 150–200 m — cuanto mayor es la velocidad, antes tiene '
        'que estar el aviso. Quien toma el valor de fuera de poblado deja '
        'al tráfico que viene detrás a 120 km/h apenas tres segundos. '
        'Antes de un cambio de rasante o una curva, el triángulo va '
        'delante, no detrás.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'En una autopista de tres carriles el tráfico se ralentiza. '
        '¿Dónde formas el corredor de emergencia?',
    options: [
      'Entre el carril izquierdo y el central',
      'Entre el carril central y el derecho',
      'En el arcén',
      'En el centro de la calzada, con independencia del número de '
          'carriles',
    ],
    correctIndex: 0,
    explanation: 'El corredor está siempre entre el carril más a la '
        'izquierda y el inmediatamente contiguo a su derecha — con '
        'independencia de cuántos carriles haya. El arcén no es una '
        'alternativa: por ahí circulan los servicios de emergencia cuando '
        'el corredor está bloqueado.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: '¿Cuándo hay que formar el corredor de emergencia?',
    options: [
      'Solo cuando se ven o se oyen las luces azules',
      'En cuanto el tráfico se ralentiza',
      'Solo cuando se ordena por el panel informativo',
    ],
    correctIndex: 1,
    explanation: 'El corredor se forma al ralentizarse el tráfico, no con '
        'las luces azules. Si se espera al vehículo de emergencia, los '
        'coches ya están demasiado juntos — y entonces nadie tiene sitio '
        'para apartarse.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Maniobrando dañas un coche aparcado y no hay nadie cerca. '
        '¿Basta con una nota bajo el limpiaparabrisas?',
    options: [
      'Sí, si lleva escritos el nombre y el número de teléfono',
      'Sí, la nota es la vía prevista por la ley',
      'No — solo basta si además haces fotos',
      'No — tienes que esperar un tiempo razonable y, si no, informar a '
          'la policía',
    ],
    correctIndex: 3,
    explanation: 'Jurídicamente una nota no cuenta como identificación '
        'suficiente — puede volarse o ser retirada; quien se fía de ella '
        'se arriesga a la acusación de abandono del lugar del accidente. '
        'Las fotos documentan el daño, pero no sustituyen ni la espera ni '
        'el aviso.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Tras el accidente, una persona no respira con normalidad. '
        '¿Qué haces?',
    options: [
      'Empezar de inmediato con las compresiones torácicas, unas 100–120 '
          'por minuto',
      'Colocar a la persona en posición lateral de seguridad y abrigarla',
      'Esperar a la ambulancia — como profano no puedes hacer nada',
    ],
    correctIndex: 0,
    explanation: 'Sin respiración normal cuenta cada minuto, y comprimir '
        'es la única medida que ayuda. La posición lateral de seguridad '
        'es correcta — pero solo si hay respiración normal. Y no hacer '
        'nada es la única decisión equivocada: la omisión del deber de '
        'socorro es delito.',
  ),

  // ══════════════════════════════════ M10 — Resumen
  DrivingQuestion(
    moduleId: 'm10',
    question: '¿Qué resume mejor la actitud de esta formación?',
    options: [
      'Las reglas valen sobre todo cuando hay controles',
      'La seguridad es mi decisión diaria, para que todos lleguen sanos '
          'a casa',
      'Lo importante es terminar la ruta puntualmente',
    ],
    correctIndex: 1,
    explanation: 'La seguridad es una actitud, no un trámite obligatorio '
        '— y se demuestra precisamente cuando nadie mira. Quien vincula '
        'las reglas a los controles no las ha entendido, solo las ha '
        'soportado.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm10',
    question: '¿Cuántos puntos de apoyo mantienes al subir y bajar del '
        'vehículo — y cuántos segundos de distancia como mínimo con la '
        'calzada seca?',
    options: [
      '2 puntos de apoyo y 1 segundo',
      '3 puntos de apoyo y 1 segundo',
      '3 puntos de apoyo (2 manos + 1 pie) y 2 segundos',
    ],
    correctIndex: 2,
    explanation: 'Tres puntos de apoyo («2+1») y dos segundos de '
        'distancia — con calzada mojada, tres. Un segundo de distancia '
        'equivale a 50 km/h exactamente a la mera distancia de reacción: '
        'colisionarías sin ninguna reserva de frenado.',
  ),
];

// La resolución de idioma, `drivingQuestionsForModule()` y
// `buildDrivingExam()` viven en driving_safety_data.dart.
