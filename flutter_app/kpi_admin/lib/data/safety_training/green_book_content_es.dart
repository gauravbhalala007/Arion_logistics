// lib/data/safety_training/green_book_content_es.dart
//
// Contenido de la formación Green Book — versión española.
// La estructura es idéntica a la versión alemana (máster): capítulos
// gb1–gb6, las mismas diapositivas, los mismos bloques y los mismos
// valores.
//
// El «Green Book» es el libro de control de trayectos: la colección de
// las hojas de control diarias según el § 1 apdo. 6 de la
// Fahrpersonalverordnung (FPersV — el reglamento alemán sobre el
// personal de conducción). Sirve para acreditar los tiempos de
// conducción, las interrupciones de la conducción y los tiempos de
// trabajo y de descanso — NO es una revisión del vehículo.

import 'safety_blocks.dart';

const List<SafetyChapterContent> greenBookContentEs = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'gb1',
    title: 'Qué es el Green Book',
    summary: 'Libro de control de trayectos según el § 1 apdo. 6 FPersV — '
        'y por qué es obligatorio para ti',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Libro de trayectos, no revisión del vehículo',
        blocks: [
          ParagraphBlock(
            'El «Green Book» es tu libro de control de trayectos. En él '
            'reúnes las hojas de control diarias: una hoja por cada día de '
            'trabajo, en la que consta cuándo has conducido, cuándo has '
            'hecho la pausa y cuándo ha comenzado tu tiempo de descanso.',
          ),
          ParagraphBlock(
            'No es en absoluto una revisión del vehículo. Los neumáticos, '
            'las luces y la carrocería se documentan en otro sitio. En el '
            'Green Book se trata exclusivamente de tiempos: tus tiempos.',
          ),
          BulletsBlock([
            'Una hoja por cada día en el que conduces un vehículo sujeto a '
                'la obligación de registro',
            'Cumplimentada a mano, con escritura indeleble y firmada',
            'Acredita que has respetado los tiempos de conducción, las '
                'pausas y los tiempos de descanso',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'En pocas palabras',
            text: 'El Green Book responde a una única pregunta: ¿cuándo '
                'estabas al volante y cuándo no? Todo lo demás no pertenece '
                'a esta hoja.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Quién tiene que registrar',
        blocks: [
          ParagraphBlock(
            'La obligación procede del § 1 apdo. 6 de la '
            'Fahrpersonalverordnung (FPersV). No depende de ti como '
            'persona, sino del vehículo y de la finalidad del trayecto: '
            'transporte comercial de mercancías con un vehículo de más de '
            '2,8 t hasta 3,5 t de masa máxima autorizada. Esa es justamente '
            'la furgoneta de reparto típica.',
          ),
          FactsBlock([
            FactItem('menos de 2,8 t', 'sin obligación de registro según el '
                '§ 1 apdo. 6 FPersV'),
            FactItem('2,8–3,5 t', 'hoja de control diaria — tu Green Book'),
            FactItem('desde 3,5 t', 'tacógrafo digital en lugar de hoja de '
                'papel'),
          ]),
          ParagraphBlock(
            'Lo determinante es la masa máxima autorizada que figura en el '
            'permiso de circulación, no lo cargada que vaya hoy realmente '
            'la furgoneta. Una de 3,5 t medio vacía sigue estando sujeta a '
            'la obligación de registro.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'La base legal',
            text: 'El § 1 apdo. 6 FPersV te obliga a registrar los tiempos '
                'de conducción, las interrupciones de la conducción y los '
                'tiempos de trabajo y de descanso. Si conduces sin esa '
                'hoja, infringes el reglamento, con independencia de que '
                'hayas respetado o no los tiempos.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Para qué sirve el registro',
        blocks: [
          ParagraphBlock(
            'La norma no es un fin en sí misma. Existe porque los '
            'conductores agotados son peligrosos en el tráfico, para sí '
            'mismos y para todos los demás. La hoja hace visible si tus '
            'jornadas de trabajo están planificadas de forma que se puedan '
            'cumplir.',
          ),
          BulletsBlock([
            'Protección frente al agotamiento: quien tiene que documentar '
                'la pausa también la hace de verdad con más frecuencia',
            'Prueba a tu favor: la hoja demuestra que has conducido '
                'correctamente, incluso meses después',
            'Prueba frente a afirmaciones: sin registro, tu recuerdo se '
                'enfrenta a lo que suponga el control',
            'Base para la planificación de rutas: las rutas repetidamente '
                'demasiado ajustadas se notan en la hoja',
          ]),
          RevealBlock(
            prompt: 'Caso práctico: hoy has respetado los tiempos — pausa '
                'puntual, fin de jornada a su hora. Solo que no has '
                'rellenado la hoja, porque de todos modos todo estaba en '
                'orden. Control por la tarde. ¿Es eso un problema?',
            answer: 'Sí. Obligación de registro significa que la prueba en '
                'sí misma es la obligación. Nadie puede comprobar en un '
                'control de carretera si realmente has respetado los '
                'tiempos: no hay nada que presentar. Desde el punto de '
                'vista del control, una hoja que falta se trata exactamente '
                'igual que un margen de tiempo superado: existe una '
                'infracción y se sanciona. Haber cumplido solo te sirve si '
                'puedes acreditarlo.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de comprobación: las nociones básicas',
        blocks: [
          ChecklistBlock(
            title: 'Esto me llevo del capítulo 1',
            items: [
              'Sé que el Green Book documenta tiempos y no el estado del '
                  'vehículo',
              'Conozco la base legal: § 1 apdo. 6 FPersV',
              'Sé que están afectados los vehículos de más de 2,8 t hasta '
                  '3,5 t',
              'Sé que cuenta la masa máxima autorizada, no el peso de la '
                  'carga actual',
              'Sé que a partir de 3,5 t se aplica el tacógrafo digital',
              'Tengo claro que una hoja que falta ya es por sí sola una '
                  'infracción',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Una frase para la ruta',
            text: '«Lo que no he anotado, no lo puedo demostrar.»',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'gb2',
    title: 'Qué se anota exactamente',
    summary: 'Todos los campos obligatorios — y cómo rellenarlos bien',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Los datos obligatorios de la hoja',
        blocks: [
          ParagraphBlock(
            'Una hoja de control diaria solo es una prueba si contiene '
            'todos los datos prescritos. Si falta uno de ellos, la hoja se '
            'considera incompleta, con las mismas consecuencias que una '
            'hoja que falta.',
          ),
          BulletsBlock([
            'Apellidos, nombre y dirección del conductor',
            'Matrícula oficial del vehículo',
            'Fecha del día',
            'Kilometraje al inicio y al final del trayecto',
            'Lugar de inicio y lugar de fin del trayecto',
            'Tiempos de conducción y de descanso con indicación horaria',
            'Interrupciones de la conducción (las pausas)',
            'Tu firma',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Completa significa completa',
            text: 'El § 1 apdo. 6 FPersV enumera los datos de forma '
                'exhaustiva. Una hoja sin matrícula, sin dirección o sin '
                'firma no cumple la obligación de registro, aunque los '
                'tiempos estén anotados correctamente.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Rellenar paso a paso',
        blocks: [
          ParagraphBlock(
            'El orden que sigue está elegido a propósito para que no se te '
            'olvide nada: primero los datos fijos, después los tiempos a lo '
            'largo del día y, al final, el cierre.',
          ),
          StepsBlock([
            'Antes de arrancar: anota la fecha, los apellidos, el nombre, '
                'la dirección y la matrícula',
            'Lee el kilometraje en el cuentakilómetros y anótalo como '
                'kilometraje inicial — no lo estimes',
            'Anota el lugar de inicio del trayecto (base, ubicación, '
                'localidad)',
            'Anota el inicio del tiempo de conducción con la hora en cuanto '
                'arrancas',
            'Anota cada interrupción de la conducción de inmediato, con su '
                'inicio y su fin — no por la noche',
            'Al terminar la ruta: anota el lugar de fin del trayecto y el '
                'kilometraje final',
            'Anota el fin del tiempo de conducción y el inicio del tiempo '
                'de descanso',
            'Lee la hoja entera, comprueba que no haya huecos y fírmala',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Escribe con tinta indeleble',
            text: 'Bolígrafo, no lápiz. Una anotación que se puede borrar '
                'no es una prueba. Un error de escritura se tacha una vez y '
                'se vuelve a escribir al lado, no se repasa por encima ni '
                'se tapa con una pegatina.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Anotar los tiempos con limpieza',
        blocks: [
          ParagraphBlock(
            'Lo que más falla es lo de los tiempos. Cada bloque de tiempo '
            'del día va en su propia línea, con la hora de inicio y de fin. '
            'Así se ve un día de reparto normal:',
          ),
          TableBlock(
            headers: ['De–a', 'Tipo', 'Observación'],
            rows: [
              ['06:30–07:00', 'Tiempo de trabajo', 'Carga en la base, '
                  'todavía no es tiempo de conducción'],
              ['07:00–11:30', 'Tiempo de conducción', '4,5 horas — ahora '
                  'toca la pausa'],
              ['11:30–12:15', 'Interrupción de la conducción', '45 minutos '
                  'seguidos'],
              ['12:15–16:45', 'Tiempo de conducción', 'segundo bloque, en '
                  'total 9 horas'],
              ['16:45–17:15', 'Tiempo de trabajo', 'Devolución, retornos, '
                  'cierre'],
              ['desde 17:15', 'Tiempo de descanso', 'como mínimo 11 horas '
                  'hasta el siguiente inicio'],
            ],
          ),
          BulletsBlock([
            'El tiempo de conducción es solo el tiempo al volante con el '
                'vehículo en marcha',
            'Cargar y descargar, escanear y esperar en la parada es tiempo '
                'de trabajo, pero no tiempo de conducción',
            'Una interrupción de la conducción solo es una pausa si durante '
                'ese tiempo realmente no trabajas',
          ]),
          RevealBlock(
            prompt: 'Caso práctico: estás 40 minutos en el muelle esperando '
                'a que descarguen. Estás sentado en la cabina sin hacer '
                'nada. ¿Puedes anotarlo como interrupción de la conducción?',
            answer: 'Solo si durante ese tiempo puedes disponer libremente '
                'de él y no prestas ninguna actividad laboral, y siempre '
                'que lo sepas de antemano. Si tienes que estar disponible '
                'en todo momento porque en cualquier instante se puede '
                'continuar, eso es tiempo de espera y no una pausa. El '
                'error habitual: «no he hecho nada, así que fue pausa.» Lo '
                'decisivo no es si te has movido, sino si podías disponer '
                'de ese tiempo. En caso de duda lo anotas como tiempo de '
                'trabajo: esa es siempre la opción segura.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de comprobación: ¿hoja completa?',
        blocks: [
          ChecklistBlock(
            title: 'Antes de firmar',
            items: [
              'Constan los apellidos, el nombre y la dirección',
              'La matrícula del vehículo coincide con el vehículo conducido',
              'La fecha está anotada',
              'El kilometraje inicial y final están leídos del '
                  'cuentakilómetros',
              'Constan el lugar de inicio y el lugar de fin del trayecto',
              'Todos los tiempos de conducción están anotados con la hora '
                  'de inicio y de fin',
              'Todas las interrupciones de la conducción están anotadas',
              'El inicio del tiempo de descanso está anotado',
              'Todo con bolígrafo, sin borrones, sin huecos',
              'Firma puesta',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'gb3',
    title: 'Tiempos de conducción, pausas y descansos',
    summary: 'Las cifras que tu jornada laboral tiene que respetar',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Las cifras que cuentan',
        blocks: [
          ParagraphBlock(
            'El Green Book documenta tiempos, pero solo para que se pueda '
            'comprobar si has respetado unos límites. Esos límites tienes '
            'que llevarlos en la cabeza, no solo sobre el papel.',
          ),
          FactsBlock([
            FactItem('9 h', 'tiempo de conducción diario por regla general'),
            FactItem('10 h', 'permitido dos veces por semana como '
                'excepción'),
            FactItem('4,5 h', 'conducción seguida, después toca la pausa'),
          ]),
          FactsBlock([
            FactItem('45 min', 'interrupción de la conducción tras 4,5 '
                'horas'),
            FactItem('15 + 30', 'división permitida — en este orden'),
            FactItem('11 h', 'descanso diario, como mínimo'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Lo que exige la norma',
            text: 'El tiempo de conducción es de 9 horas diarias como '
                'máximo; dos veces por semana puede ampliarse a 10 horas. '
                'Tras 4,5 horas de conducción como muy tarde hay que hacer '
                'una interrupción de la conducción de 45 minutos como '
                'mínimo. El descanso diario es de 11 horas como mínimo.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Colocar bien la pausa',
        blocks: [
          ParagraphBlock(
            'Los 45 minutos son el caso normal. Puedes dividirlos, pero '
            'solo en exactamente dos tramos y solo en un orden '
            'determinado: primero un mínimo de 15 minutos y después un '
            'mínimo de 30 minutos. Al revés no cuenta.',
          ),
          DoDontBlock(
            doTitle: 'Así la pausa es válida',
            dos: [
              '45 minutos seguidos tras 4,5 horas de conducción como muy '
                  'tarde',
              'O bien 15 minutos primero y 30 minutos después',
              'Ambas partes dentro del mismo bloque de 4,5 horas',
              'Ambas partes anotadas en la hoja con hora de inicio y de fin',
            ],
            dontTitle: 'Así no cuenta',
            donts: [
              '30 minutos primero y 15 minutos después — orden incorrecto',
              'Tres pausas cortas de 15 minutos cada una',
              'Dos veces 20 minutos — la segunda parte es demasiado corta',
              'La pausa solo tras 5 horas de conducción porque la parada '
                  'venía mejor',
            ],
          ),
          BulletsBlock([
            'Las 4,5 horas son tiempo de conducción puro — las paradas con '
                'entrega no cuentan',
            'La pausa tiene que estar antes de superar el límite, no '
                'después',
            'Tras la interrupción completa comienza un nuevo bloque de 4,5 '
                'horas',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'El error de razonamiento más frecuente',
            text: 'La pausa no toca cuando llevas 4,5 horas de servicio, '
                'sino cuando has conducido 4,5 horas. Quien calcula por '
                'tiempo de servicio suele hacer la pausa demasiado pronto y '
                'después, otra vez, demasiado tarde.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Calcular en el día a día del reparto',
        blocks: [
          ParagraphBlock(
            'En el día a día no calculas con un solo bloque, sino con '
            'muchos trayectos cortos entre las paradas. Súmalos: el '
            'resultado es tu tiempo de conducción.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: empiezas a las 07:00. Hasta las 09:30 '
                'pasas 2 horas al volante y el resto en las paradas. Hasta '
                'las 12:00 se añaden otras 2 horas de conducción y hasta '
                'las 13:00 otros 30 minutos más. ¿Cuándo toca tu pausa como '
                'muy tarde?',
            answer: 'A las 13:00. En ese momento has alcanzado 2 + 2 + 0,5 '
                '= 4,5 horas de conducción pura; a partir de ahí no puedes '
                'recorrer ni un metro más antes de haber hecho la '
                'interrupción de la conducción. El error habitual sería '
                'contar seis horas de servicio desde las 07:00 y colocar la '
                'pausa a las 11:30. El reloj que cuenta solo corre cuando '
                'el vehículo circula.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: esta semana ya has conducido dos veces '
                '10 horas. Hoy es viernes, llevas 8,5 horas de conducción y '
                'te quedan dos paradas, unos 40 minutos de trayecto en '
                'total. ¿Te da tiempo?',
            answer: 'No. La ampliación a 10 horas solo puedes utilizarla '
                'dos veces por semana, y ya están agotadas. Hoy vuelve a '
                'regir el límite general de 9 horas, así que te quedan 30 '
                'minutos de conducción, no 40. Vas a la parada que puedas '
                'alcanzar, comunicas el resto a tu planificador y finalizas '
                'el tiempo de conducción. El error habitual: «las 10 horas '
                'me corresponden todos los días.» Son una excepción con un '
                'contingente semanal.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de comprobación: tiempos bajo control',
        blocks: [
          ChecklistBlock(
            title: 'Esto me llevo del capítulo 3',
            items: [
              'Sé que 9 horas de conducción son la regla',
              'Sé que 10 horas solo están permitidas dos veces por semana',
              'Cuento las 4,5 horas como tiempo de conducción puro, no como '
                  'tiempo de servicio',
              'Hago como mínimo 45 minutos de interrupción de la conducción',
              'Divido la pausa como máximo en 15 + 30 minutos, en ese orden',
              'Respeto como mínimo 11 horas de descanso diario',
              'Anoto cada pausa de inmediato, no por la noche',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Regla mnemotécnica',
            text: '4,5 – 45 – 9 – 11. Cuatro cifras que estructuran tu día. '
                'Quien las conoce no tiene que calcular, solo anotar.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'gb4',
    title: 'Errores típicos al rellenarla',
    summary: 'Los seis errores que se detectan en cualquier control',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Los seis errores más frecuentes',
        blocks: [
          ParagraphBlock(
            'Casi todas las hojas objetadas no fallan por los tiempos, sino '
            'por la forma en que se han llevado. Estos seis errores dejan '
            'sin valor una hoja que por lo demás sería correcta.',
          ),
          DoDontBlock(
            doTitle: 'Así llevas la hoja correctamente',
            dos: [
              'Haz cada anotación de inmediato, en cuanto termina el bloque '
                  'de tiempo',
              'Usa bolígrafo, con tinta indeleble',
              'Anota las pausas con la hora real de inicio y de fin',
              'Lee el kilometraje en el cuentakilómetros',
              'Firma al final del día',
              'La hoja se queda en el vehículo, contigo',
            ],
            dontTitle: 'Así se objeta la hoja',
            donts: [
              'Rellenar toda la semana el viernes por la noche',
              'Escribir con lápiz para poder «corregir después»',
              'Estimar las pausas («unos tres cuartos de hora, más o '
                  'menos»)',
              'Escribir el kilometraje de memoria',
              'Olvidar la firma',
              'Dejar las hojas en casa o en la base',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'El error más caro es el más cómodo',
            text: 'Rellenar a posteriori parece inofensivo, y es el error '
                'que antes se descubre y más pesa.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Por qué se notan las anotaciones a posteriori',
        blocks: [
          ParagraphBlock(
            'Una hoja escrita de una sentada al final tiene otro aspecto '
            'que una que ha ido naciendo a lo largo del día. Los '
            'inspectores ven ambas cosas a diario y reconocen la diferencia '
            'al instante.',
          ),
          BulletsBlock([
            'La misma letra, el mismo bolígrafo y la misma presión en todas '
                'las líneas',
            'Tiempos llamativamente redondos: todo termina en medias horas '
                'y horas en punto',
            'Kilometrajes que no encajan con el recorrido anotado',
            'Datos que contradicen los albaranes, los escaneos o los '
                'tiques de combustible',
            'Pausas que duran siempre exactamente 45 minutos, incluso en '
                'días en los que eso no era posible',
          ]),
          ParagraphBlock(
            'A eso se suma que, en un control en la empresa, las hojas '
            'están junto al resto de la documentación. Las contradicciones '
            'no las detectas tú, sino la autoridad.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Falso es peor que vacío',
            text: 'Una hoja incompleta es una infracción de la obligación '
                'de registro. Una hoja rellenada de forma deliberadamente '
                'falsa es más que eso: ahí ya no se trata solo de una '
                'infracción administrativa, sino de la cuestión del engaño. '
                'Anota mejor que has conducido demasiado tiempo antes que '
                'inventarte una hora.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: el jueves te das cuenta de que el '
                'martes no anotaste la pausa del mediodía. Lo recuerdas con '
                'exactitud: de 12:10 a 12:55. ¿Qué haces?',
            answer: 'La anotas después, pero visiblemente como anotación '
                'posterior, con la fecha de la incorporación y una breve '
                'observación, e informas a tu planificador. Una corrección '
                'honesta y reconocible está permitida y es claramente mejor '
                'que un hueco. El error habitual sería insertar la '
                'anotación como si se hubiera hecho el martes: justo ese es '
                'el paso del descuido a la falsificación.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de comprobación: llevada con limpieza',
        blocks: [
          ChecklistBlock(
            title: 'Mi hoja resiste un control',
            items: [
              'Anoto cada bloque de tiempo de inmediato, no por la noche',
              'Escribo con bolígrafo',
              'Leo las horas y los kilometrajes en lugar de estimarlos',
              'Firmo cada hoja',
              'Mis hojas están siempre conmigo en el vehículo',
              'Hago las correcciones de forma visible y fechada, nunca '
                  'invisible',
              'Prefiero anotar una infracción antes que inventarme una hora',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'gb5',
    title: 'Llevar encima, entregar, conservar',
    summary: '28 días con el conductor, un año en la empresa',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Los dos plazos',
        blocks: [
          ParagraphBlock(
            'La hoja rellenada solo vale algo si está en el lugar correcto '
            'en el momento correcto. Para eso hay dos plazos que tienes que '
            'distinguir.',
          ),
          FactsBlock([
            FactItem('28 días', 'el conductor lleva consigo los registros'),
            FactItem('1 año', 'el empresario los conserva en la empresa'),
          ]),
          BulletsBlock([
            'Los 28 días te afectan a ti: tienes que llevar contigo los '
                'registros del día en curso y de los 28 días anteriores',
            'El plazo de un año afecta a la empresa: tiene que conservar '
                'las hojas durante un año y presentarlas cuando se le '
                'requiera',
            'Ambas cosas rigen a la vez — las hojas pasan al archivo solo '
                'cuando vence la obligación de llevarlas encima',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Obligación de llevarlas encima',
            text: 'Los registros de los últimos 28 días van en el vehículo, '
                'no en la taquilla, ni en casa, ni en la oficina. Si faltan '
                'en un control, de nada sirve que se hayan llevado '
                'correctamente.',
          ),
        ],
      ),
      SafetySlide(
        title: 'El control de carretera',
        blocks: [
          ParagraphBlock(
            'El control lo realizan la BAG — la Oficina Federal de '
            'Logística y Movilidad — y la policía. Ambas pueden controlar '
            'en la carretera; la BAG, además, en la empresa.',
          ),
          StepsBlock([
            'Detente, apaga el motor, baja la ventanilla y deja las manos a '
                'la vista',
            'Mantén la calma: un control es rutina, no una sospecha',
            'Presenta el permiso de conducir, la documentación del vehículo '
                'y los registros de los últimos 28 días',
            'Responde a las preguntas de forma objetiva, sin inventar ni '
                'adornar nada',
            'Si hay una objeción: deja que levanten el acta, no discutas',
            'Después informa a tu planificador y documenta el hecho en la '
                'empresa',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'La preparación gana a la explicación',
            text: 'Un control dura pocos minutos si las hojas están '
                'completas en el vehículo. Cualquier otra cosa os cuesta a '
                'ti y a la empresa toda la tarde.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: en el arcén el inspector te pide los '
                'últimos 28 días. Solo llevas la semana actual: las hojas '
                'más antiguas las has entregado correctamente en la base. '
                '¿Es suficiente?',
            answer: 'No. La obligación de llevarlas encima abarca el día en '
                'curso y los 28 días anteriores. Que las hojas más antiguas '
                'estén debidamente en la empresa cumple la obligación de '
                'conservación, pero no la de llevarlas encima: son dos '
                'obligaciones distintas. Lo correcto es que las copias o '
                'los originales de los últimos 28 días se queden contigo y '
                'solo después pasen al archivo. Aclara con tu planificador '
                'cómo lo organizáis en la empresa.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Entregar en la empresa',
        blocks: [
          ParagraphBlock(
            'El empresario solo puede cumplir su obligación de conservación '
            'si también recibe las hojas. Por eso la entrega no es papeleo, '
            'sino parte de tu obligación de registro.',
          ),
          BulletsBlock([
            'Entrega las hojas íntegramente cuando vence el plazo de '
                'llevarlas encima, no a montones a final de mes',
            'No tires nada, tampoco las hojas con errores o correcciones',
            'Si te falta una hoja, dilo enseguida: un hueco comunicado es '
                'mejor que uno descubierto',
            'No dejes sin más los días de vacaciones, de baja o de oficina, '
                'sino márcalos según las indicaciones de la empresa',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Los huecos siguen siendo huecos',
            text: 'Un día sin hoja no se puede reconstruir después. Quien '
                'descuida la entrega produce justamente los huecos que se '
                'detectan en un control en la empresa.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de comprobación: documentación bajo control',
        blocks: [
          ChecklistBlock(
            title: 'Antes de cada turno y después de cada semana',
            items: [
              'Los registros de los últimos 28 días están en el vehículo',
              'La hoja de hoy está iniciada y a mano',
              'Llevo el permiso de conducir y la documentación del vehículo',
              'He entregado en la empresa las hojas cuyo plazo ha vencido',
              'No he tirado ninguna hoja, tampoco las que tienen '
                  'correcciones',
              'Sé a quién tengo que informar en caso de control',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'gb6',
    title: 'Consecuencias de las infracciones',
    summary: 'Multa, responsabilidad de la empresa, escalado interno',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Lo que amenaza legalmente',
        blocks: [
          ParagraphBlock(
            'Una hoja de control diaria que falta o está incompleta es una '
            'infracción administrativa. El importe de la multa depende de '
            'la gravedad y de la frecuencia con la que se haya infringido '
            'la norma.',
          ),
          FactsBlock([
            FactItem('desde 100 €', 'multa por hojas que faltan o están '
                'incompletas'),
            FactItem('según la gravedad', 'importes más altos en caso de '
                'infracciones múltiples o reiteradas'),
          ]),
          BulletsBlock([
            'No solo está afectado el conductor: la empresa también asume '
                'responsabilidad por los registros',
            'En caso de infracciones graves o reiteradas cabe un '
                'procedimiento sobre la fiabilidad de la empresa',
            'El control lo realizan la BAG y la policía, en la carretera y '
                'en la empresa',
            'Las objeciones de un control en la empresa afectan a todos los '
                'conductores, no solo al controlado',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Dos destinatarios, una obligación',
            text: 'La FPersV obliga conjuntamente al conductor y al '
                'empresario: tú tienes que registrar y llevar los registros '
                'contigo, la empresa tiene que conservarlos y supervisarlos. '
                'Si falla una de las dos cosas, responde la parte '
                'responsable en cada caso.',
          ),
        ],
      ),
      SafetySlide(
        title: 'El escalado en la empresa',
        blocks: [
          ParagraphBlock(
            'Con independencia de que una autoridad constate algo, en la '
            'empresa rige una secuencia fija. Es igual para todos y se '
            'documenta.',
          ),
          StepsBlock([
            'Primer nivel: amonestación verbal por parte del planificador',
            'Segundo nivel: advertencia escrita en el expediente personal',
            'Tercer nivel: consecuencias laborales hasta el despido',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'La infracción es la hoja que falta',
            text: 'Los niveles se aplican con independencia de que haya '
                'ocurrido algo o de que haya habido un control. La propia '
                'hoja no llevada es ya la infracción.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: el planificador insiste: «Haz aún esas '
                'dos paradas, la pausa simplemente la escribes, si no, no '
                'llegamos.» ¿Qué rige?',
            answer: 'La instrucción no cambia nada de tu obligación. Tú '
                'eres quien registra y firma: con tu firma confirmas el '
                'contenido. Una instrucción verbal no te protege ni en el '
                'control ni después en la empresa. Lo correcto es hacer la '
                'pausa, anotarla correctamente, comunicar las paradas '
                'pendientes y documentar la instrucción. La empresa está '
                'obligada a hacer posible el cumplimiento, no a eludirlo.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de comprobación: cierre',
        blocks: [
          ChecklistBlock(
            title: 'Esto me llevo de la formación',
            items: [
              'El Green Book es el libro de control de trayectos según el '
                  '§ 1 apdo. 6 FPersV',
              'Conozco todos los datos obligatorios y los relleno por '
                  'completo',
              'Respeto 9 h de conducción, 4,5 h hasta la pausa, 45 min de '
                  'interrupción y 11 h de descanso',
              'Anoto de inmediato, con bolígrafo, y firmo',
              'Llevo conmigo los registros de los últimos 28 días',
              'Entrego en la empresa las hojas cuyo plazo ha vencido',
              'Sé que una hoja que falta puede acarrear una multa a partir '
                  'de 100 euros',
              'Sé que una instrucción no suprime mi obligación de registro',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Una frase para la ruta',
            text: '«La hoja se escribe mientras conduzco, no cuando he '
                'terminado.»',
          ),
        ],
      ),
    ],
  ),
];
