// lib/data/safety_training/driving_safety_content_es.dart
//
// Contenidos de la formación DSP de seguridad vial — versión española.
// La estructura es idéntica a la versión alemana (máster): módulos
// M1–M10, las mismas diapositivas y los mismos bloques. Las rutas de
// las imágenes no cambian.

import 'safety_blocks.dart';

const List<SafetyChapterContent> drivingSafetyContentEs = [
  // ══════════════════════════════════════════════════ M1
  SafetyChapterContent(
    id: 'm1',
    title: 'Cultura de seguridad y responsabilidad',
    summary: 'Entender la seguridad como decisión propia, no como una '
        'norma impuesta',
    asset: 'assets/academy/driving/m01_sicherheitskultur.svg',
    slides: [
      SafetySlide(
        title: 'Tu ruta, tu responsabilidad',
        blocks: [
          ParagraphBlock(
            'Cada día recorres cientos de kilómetros y te detienes '
            'decenas de veces. Cada trayecto, cada parada, cada bajada '
            'del vehículo es una decisión. La buena noticia: casi todos '
            'los accidentes se pueden evitar. La seguridad no empieza al '
            'volante, sino en la cabeza — antes de arrancar.',
          ),
          FactsBlock([
            FactItem('120+', 'paradas en un día normal de reparto'),
            FactItem('250+', 'veces que subes y bajas por ruta'),
            FactItem('1', 'segundo de distracción basta para un '
                'accidente'),
          ]),
          ParagraphBlock(
            'Con esa cantidad de repeticiones, no es tu habilidad la que '
            'decide cómo va el día, sino tu rutina. Una buena rutina te '
            'protege también cuando estás cansado o bajo presión — una '
            'mala rutina acabará saliéndote cara.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'La idea central',
            text: 'La seguridad no es algo que haces aparte. Es la forma '
                'en que haces tu trabajo.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lo que de verdad pasa en el reparto',
        blocks: [
          ParagraphBlock(
            'El reparto es una de las profesiones con más accidentes de '
            'trabajo y in itinere. Los incidentes más frecuentes no son '
            'espectaculares: alcances en retención, daños al dar marcha '
            'atrás, caídas al bajar del vehículo, espaldas cargadas, '
            'tobillos torcidos. Cotidianos — y precisamente por eso se '
            'subestiman.',
          ),
          FactsBlock([
            FactItem('70 %', 'de los daños en furgonetas se producen '
                'maniobrando y dando marcha atrás'),
            FactItem('N.º 1', 'tropiezos, resbalones y caídas son la '
                'causa de lesión más frecuente en el reparto'),
            FactItem('24', 'días de baja de media tras una caída'),
          ]),
          ParagraphBlock(
            'Llama la atención una cosa: casi todos estos incidentes '
            'ocurren a baja velocidad o con el vehículo parado. No son '
            'maniobras dramáticas, sino gestos normales que una vez se '
            'hicieron mal.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Despacio no significa inofensivo',
            text: 'Un daño maniobrando al paso le cuesta a la empresa '
                'enseguida una cifra de cuatro dígitos — y a ti medio '
                'día de problemas.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Las tres actitudes básicas',
        blocks: [
          ParagraphBlock(
            'De todo lo que viene en esta formación se pueden extraer '
            'tres actitudes. Si solo te llevas estas tres, ya has hecho '
            'la mayor parte.',
          ),
          BulletsBlock([
            'Anticipar — reconocer los peligros antes de que aparezcan. '
                'Quien solo reacciona siempre llega tarde',
            'El tiempo es tuyo — ningún paquete vale un accidente. La '
                'presión de tiempo es un problema de planificación, no '
                'una excusa',
            'Dar ejemplo — tu comportamiento protege a compañeros, '
                'peatones y niños. En la vía eres un profesional, no un '
                'conductor particular',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Para recordar',
            text: 'El mejor conductor no es el más rápido, sino aquel al '
                'que nunca le pasa nada — porque lo ve venir.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Cada trayecto es una cadena de decisiones',
        asset: 'assets/academy/driving/m01b_entscheidung.svg',
        blocks: [
          ParagraphBlock(
            'Un accidente rara vez es un solo error. Casi siempre son '
            'cinco o seis pequeñas decisiones que por separado parecen '
            'inofensivas — y que al final se suman. Justo por eso puedes '
            'romper la cadena en cualquier punto.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: son las 17:40, te quedan 22 paradas '
                'pendientes. La zona de carga está desordenada, el móvil '
                'vibra en el soporte y delante de ti la calle se '
                'estrecha. ¿Dónde está aquí el riesgo real?',
            answer: 'No en el estrechamiento que tienes delante, sino en '
                'todo lo anterior. La zona de carga desordenada te cuesta '
                'tiempo en cada parada, el tiempo genera presión, la '
                'presión reduce tu atención y el móvil se lleva lo que '
                'queda. La decisión correcta tocaba dos horas antes: '
                'ordenar la carga, silenciar el móvil, marcar un ritmo '
                'realista. Ahora solo ayuda una cosa: parar, respirar, '
                'seguir parada a parada y después informar del problema '
                'de planificación.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Romper la cadena',
            text: 'Cada vez que algo te dé mala espina, pregúntate: '
                '¿cuál es el eslabón que puedo quitar ahora mismo con 30 '
                'segundos de esfuerzo?',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dar ejemplo en el equipo',
        asset: 'assets/academy/driving/m01c_vorbild.svg',
        blocks: [
          ParagraphBlock(
            'La cultura de seguridad no nace de los carteles, sino de lo '
            'que los compañeros se copian unos a otros. Quien empieza '
            'nuevo imita lo que hacen los veteranos — también lo malo.',
          ),
          DoDontBlock(
            doTitle: 'Cultura que sostiene',
            dos: [
              'Hablar abiertamente de los casi accidentes, sin que nadie '
                  'reciba miradas raras',
              'Enseñar activamente a los nuevos dónde están los '
                  'estribos, los asideros y el ángulo muerto',
              'Comunicar los defectos de inmediato, aunque la ruta '
                  'empiece más tarde',
              'Maniobrar de forma visiblemente limpia también cuando hay '
                  'prisa',
            ],
            dontTitle: 'Cultura que perjudica',
            donts: [
              '«Aquí siempre lo hacemos así» como argumento',
              'Reírse del compañero que se baja a mirar',
              'Arreglar los daños pequeños entre compañeros en vez de '
                  'comunicarlos',
              'Practicar atajos que nunca le enseñarías a un novato',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Los casi accidentes valen oro',
            text: 'Cada casi accidente comunicado es un accidente que ya '
                'no le ocurrirá al siguiente compañero. Comunicar es '
                'fortaleza, no chivarse.',
          ),
        ],
      ),
      SafetySlide(
        title: '¿Quién responde en realidad?',
        blocks: [
          ParagraphBlock(
            'Al volante eres el conductor del vehículo — y por tanto el '
            'responsable personal. La empresa te facilita un vehículo '
            'seguro, te forma y planifica la ruta. Si guardas distancia, '
            'te pones el cinturón y te bajas antes de dar marcha atrás, '
            'lo decides únicamente tú.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Lo que la ley espera de ti',
            text: 'El § 1 StVO (código de circulación alemán) exige '
                'prudencia constante y consideración mutua. El § 3 Abs. 1 '
                'StVO exige que solo circules tan rápido como para poder '
                'detenerte dentro del tramo que puedes ver. Ambas cosas '
                'valen con independencia de lo que ponga la señal.',
          ),
          BulletsBlock([
            'Las multas y los puntos te afectan a ti personalmente, no a '
                'la empresa',
            'En caso de negligencia grave, el seguro puede repetir '
                'contra ti una parte del daño',
            'Si pones en peligro a otros, una infracción puede '
                'convertirse en delito (§ 315c StGB, código penal '
                'alemán)',
            'Una retirada del permiso significa para ti, como conductor '
                'profesional: sin trabajo',
          ]),
          RevealBlock(
            prompt: 'Por la mañana te das cuenta de que una luz de freno '
                'no funciona. El planificador te dice: «Sal igualmente, '
                'no tenemos a nadie más.» ¿Quién asume el riesgo?',
            answer: 'Tú. Como conductor respondes del estado seguro del '
                'vehículo que mueves — una instrucción verbal no lo '
                'anula. Lo correcto es: comunicar el defecto, exigir un '
                'vehículo de sustitución o la reparación y dejar '
                'constancia del aviso. Además, una luz de freno rota en '
                'una furgoneta es justo el defecto que acaba en un '
                'alcance por detrás.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de control: tu actitud',
        blocks: [
          ChecklistBlock(
            title: 'Esto me llevo del módulo 1',
            items: [
              'Sé que la mayoría de los daños ocurren despacio y en '
                  'situaciones cotidianas',
              'Anticipo en vez de limitarme a reaccionar',
              'Trato la presión de tiempo como problema de '
                  'planificación, no de conducción',
              'Comunico defectos y casi accidentes, también los '
                  'pequeños',
              'Sé que como conductor respondo personalmente',
              'Soy consciente de que los compañeros nuevos me copian',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Una frase para la ruta',
            text: '«Conduzco de forma que todos lleguen sanos a casa — '
                'yo incluido.»',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M2
  SafetyChapterContent(
    id: 'm2',
    title: 'Revisión del vehículo y sujeción de la carga',
    summary: 'Antes de la ruta, revisar el vehículo y asegurar la carga '
        'para que nada se convierta en un peligro',
    asset: 'assets/academy/driving/m02_fahrzeugcheck.svg',
    slides: [
      SafetySlide(
        title: 'Por qué la revisión no es un trámite',
        blocks: [
          ParagraphBlock(
            'La vuelta al vehículo antes de la ruta dura dos minutos. '
            'Evita averías en mitad del recorrido, multas en un control '
            'y, en el peor de los casos, un accidente que podrías haber '
            'visto venir antes de arrancar.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Obligación de revisión antes del turno',
            text: 'Según la DGUV Vorschrift 70 (Fahrzeuge — norma alemana '
                'de prevención sobre vehículos) debes revisar tu vehículo '
                'antes de empezar cada turno para detectar defectos '
                'evidentes. Si encuentras defectos que comprometen la '
                'seguridad, no puedes salir — los comunicas.',
          ),
          FactsBlock([
            FactItem('2 min', 'dura la vuelta completa al vehículo'),
            FactItem('4', 'estaciones: neumáticos, luces, líquidos, '
                'carga'),
          ]),
          ParagraphBlock(
            'Importante: la revisión no sustituye a una inspección de '
            'taller. Buscas lo que salta a la vista, no defectos '
            'ocultos.',
          ),
        ],
      ),
      SafetySlide(
        title: 'La vuelta al vehículo — cuatro estaciones',
        asset: 'assets/academy/driving/m02b_rundgang.svg',
        blocks: [
          ParagraphBlock(
            'Rodea siempre el vehículo en el mismo orden. Un orden fijo '
            'es la única manera de no olvidar nada cuando por la mañana '
            'hay estrés.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/load01_reifen.svg',
              title: '1 · Neumáticos y ruedas',
              caption: 'Da una vuelta completa y mira los cuatro '
                  'neumáticos: ¿alguno visiblemente desinflado, grietas, '
                  'cuerpos extraños, dibujo suficiente? Un neumático que '
                  'ya por la mañana parece blando no aguanta una ruta '
                  'entera.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load02_licht.svg',
              title: '2 · Alumbrado y matrícula',
              caption: 'Comprueba luces de posición, cortas, '
                  'intermitentes, luces de freno y de marcha atrás — las '
                  'de freno, si hace falta, por el reflejo en una pared o '
                  'con un compañero. La matrícula debe estar libre y '
                  'legible.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load03_fluessigkeiten.svg',
              title: '3 · Líquidos y suelo',
              caption: 'Una mirada bajo el vehículo: restos de aceite, '
                  'refrigerante o líquido de frenos en el suelo son '
                  'siempre motivo de aviso. Además, rellena el '
                  'limpiaparabrisas — en invierno con anticongelante.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load04_ladung.svg',
              title: '4 · Zona de carga y mercancía',
              caption: 'Abre las puertas y mira dentro: ¿está todo '
                  'firme, están tensas la red separadora y las cinchas, '
                  'no hay nada suelto encima? Lo que aquí está flojo sale '
                  'volando hacia delante en el primer frenazo.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Neumáticos: tu único contacto con la carretera',
        blocks: [
          ParagraphBlock(
            'Cuatro superficies de contacto, cada una del tamaño '
            'aproximado de una postal — no hay más que una a tu furgoneta '
            'cargada con el asfalto. Todo lo que aprendas sobre frenada, '
            'dirección y agarre depende de esas cuatro superficies.',
          ),
          FactsBlock([
            FactItem('1,6 mm', 'profundidad mínima legal del dibujo'),
            FactItem('3 mm', 'dibujo mínimo recomendado en verano'),
            FactItem('4 mm', 'dibujo mínimo recomendado en invierno'),
            FactItem('60 € + 1 pto.', 'por dibujo insuficiente'),
          ]),
          BulletsBlock([
            'Comprueba el dibujo con una moneda de 1 euro: el borde '
                'dorado mide 3 mm — si desaparece dentro del dibujo, aún '
                'tienes suficiente',
            'Comprueba la presión con los neumáticos fríos y ajústala a '
                'la carga — cargado necesitas más presión que vacío',
            'Fíjate en el desgaste irregular: gastado por un lado indica '
                'problema de alineación o de presión',
            'Comunica de inmediato bultos, grietas y tornillos clavados',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Poca presión es más peligrosa que demasiada',
            text: 'Un neumático poco inflado flexiona, se calienta y '
                'puede reventar con el vehículo a plena carga. Además, '
                'aumenta la distancia de frenado y crece el riesgo de '
                'aquaplaning.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Luces, lunas y espejos',
        blocks: [
          ParagraphBlock(
            'Que te vean es tan importante como ver. Una luz de freno '
            'fundida en la furgoneta es la causa clásica de un alcance '
            'por detrás en el que tú no eres el causante — pero aun así '
            'te llevas el daño.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'La visibilidad libre es obligatoria',
            text: 'Según el § 23 Abs. 1 StVO debes asegurarte de que la '
                'visión y el oído no estén limitados — ni por la carga, '
                'ni por los ocupantes, ni por lunas heladas o sucias. Una '
                'simple «mirilla» rascada no basta expresamente.',
          ),
          BulletsBlock([
            'Ajusta los espejos con el vehículo parado, antes de arrancar '
                'el motor — nunca en marcha',
            'Ajusta los retrovisores exteriores de forma que se vea una '
                'franja estrecha del propio vehículo: es tu punto de '
                'referencia',
            'Mantén lunas y espejos limpios por dentro y por fuera — la '
                'grasa en la cara interior deslumbra muchísimo de noche',
            'Manda cambiar de inmediato las escobillas que dejan estelas',
          ]),
          RevealBlock(
            prompt: 'Durante la vuelta al vehículo ves que el retrovisor '
                'derecho baila y tiene una grieta. Aún te quedan 190 '
                'paradas. ¿Sales o no?',
            answer: 'No salgas antes de comunicarlo. El retrovisor '
                'derecho es exactamente el que te cubre el ángulo muerto '
                'hacia ciclistas y acera — y ahí es donde ocurren los '
                'accidentes graves al girar. Un espejo agrietado y suelto '
                'es un defecto que afecta a la seguridad vial. '
                'Comunicarlo, cambiarlo o cambiar de vehículo.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Sujeción de la carga: entender las fuerzas',
        blocks: [
          ParagraphBlock(
            'La carga debe ir sujeta de forma que no se desplace ni '
            'siquiera con un frenazo a fondo o una maniobra evasiva '
            'repentina. Lo que eso significa en concreto está en las '
            'reglas técnicas reconocidas — y estas trabajan con valores '
            'claros.',
          ),
          FactsBlock([
            FactItem('0,8 g', 'fuerza hacia delante contra la que hay '
                'que asegurar'),
            FactItem('0,5 g', 'fuerza hacia atrás y hacia los lados'),
            FactItem('16 kg', 'fuerza de retención que necesita solo un '
                'paquete de 20 kg al frenar'),
          ]),
          ParagraphBlock(
            'Traducido: un paquete de 20 kg empuja hacia delante con unos '
            '16 kg en un frenazo a fondo — como si hubieras lanzado una '
            'caja de botellas llena contra el mamparo. Con veinte '
            'paquetes así son más de 300 kg que quieren moverse hacia '
            'delante a la vez.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 22 StVO — la carga',
            text: 'La carga debe estibarse y asegurarse de modo que ni '
                'siquiera con un frenazo a fondo o un cambio de dirección '
                'repentino pueda desplazarse, volcar, rodar de un lado a '
                'otro o caerse. La carga sin asegurar se sanciona con '
                'multa y, si hay peligro, con puntos — y le cae al '
                'conductor.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lo que hacen 20 kg en un caso real',
        blocks: [
          ParagraphBlock(
            'Los 0,8 g valen para frenar y esquivar. En un impacto real '
            'actúan deceleraciones bastante mayores durante un tiempo muy '
            'corto — la fuerza de impacto de un paquete sin asegurar '
            'supera entonces varias veces su propio peso.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: en el asiento del acompañante llevas '
                'un envío de 12 kg porque es la próxima parada. En ciudad '
                'tienes que frenar a fondo ante un niño. ¿Qué pasa con el '
                'paquete?',
            answer: 'Sigue moviéndose a tu velocidad inicial hasta que '
                'algo lo detenga — el salpicadero, el parabrisas o tu '
                'cabeza en un impacto lateral. Incluso con una frenada de '
                'emergencia normal sale del asiento hacia el hueco de los '
                'pies y puede acabar debajo del pedal de freno. Justo por '
                'eso ningún envío va delante: la próxima parada se '
                'preclasifica en la zona de carga, no se deja de paso en '
                'el asiento del acompañante.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Nada en la cabina',
            text: 'Ningún paquete, ninguna caja rodante, ninguna '
                'herramienta suelta en la cabina. Un objeto bajo el pedal '
                'de freno te quita el freno justo en el momento en que lo '
                'necesitas.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Así se carga correctamente',
        asset: 'assets/academy/driving/m02c_ladung.svg',
        blocks: [
          ParagraphBlock(
            'La regla básica: lo pesado abajo, lo pesado delante, el peso '
            'repartido de forma uniforme sobre los ejes. Una furgoneta '
            'cargada en altura tiene el centro de gravedad alto — y eso '
            'decide si en una curva todavía derrapas o ya vuelcas.',
          ),
          DoDontBlock(
            doTitle: 'Asegurado',
            dos: [
              'Paquetes pesados abajo y delante, contra el mamparo',
              'Peso repartido uniformemente entre izquierda y derecha',
              'Cargar sin huecos — cerrar espacios para que nada coja '
                  'carrerilla',
              'Cinchas y red separadora tensas, también cuando la zona de '
                  'carga se vacía',
              'Controlar brevemente después de cada recarga',
            ],
            dontTitle: 'Sin asegurar',
            donts: [
              'Paquetes pesados apilados sueltos encima',
              'Envíos en el hueco de los pies o en el asiento del '
                  'acompañante',
              'Meterlo todo «de cualquier manera», con huecos abiertos',
              'Red separadora suelta porque molesta al coger la '
                  'mercancía',
              'Carga «sujeta» solo con el propio peso del cuerpo',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'La zona de carga vacía es la más peligrosa',
            text: 'Cuanto menos hay dentro, más recorrido tiene el '
                'paquete que queda para coger velocidad. Medio vacío no '
                'significa medio peligroso — significa volver a '
                'asegurar.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Orden en la cabina y cinturón',
        blocks: [
          ParagraphBlock(
            'Bebida, móvil, escáner, albaranes — todo tiene su sitio '
            'fijo. Lo que rueda, traquetea o vuela te aparta la vista de '
            'la carretera. Un puesto de conducción ordenado es un puesto '
            'de conducción seguro.',
          ),
          FactsBlock([
            FactItem('30 €', 'multa por circular sin cinturón'),
            FactItem('Cada', 'parada: cinturón otra vez puesto, aunque '
                'sean 200 metros'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 21a StVO — obligación de cinturón',
            text: 'El cinturón de seguridad debe llevarse puesto durante '
                'la marcha — sin excepción para trayectos cortos entre '
                'dos paradas. Además, en un accidente sin cinturón se te '
                'puede imputar una concurrencia de culpa.',
          ),
          ParagraphBlock(
            'Precisamente en el reparto el cinturón es el sistema de '
            'seguridad que más se omite — porque entre dos paradas solo '
            'hay unos cientos de metros. Pero es justo ahí donde ocurren '
            'la mayoría de las colisiones urbanas.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de control antes de salir',
        blocks: [
          ChecklistBlock(
            title: 'Antes de arrancar',
            items: [
              'He dado la vuelta al vehículo en el orden fijo',
              'Neumáticos: dibujo, presión y daños comprobados',
              'Alumbrado comprobado por completo, matrícula legible',
              'Sin rastros de líquidos bajo el vehículo',
              'Lunas y espejos limpios, espejos ajustados',
              'Paquetes pesados abajo y delante, peso repartido',
              'Cinchas y red separadora tensas',
              'Nada suelto en la cabina, móvil en el soporte',
              'Chaleco reflectante a mano, triángulos a bordo',
              'Cinturón puesto',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M3
  SafetyChapterContent(
    id: 'm3',
    title: 'Conducción defensiva y anticipativa',
    summary: 'Controlar distancia, velocidad y atención para tener '
        'siempre un margen',
    asset: 'assets/academy/driving/m03_defensiv.svg',
    slides: [
      SafetySlide(
        title: 'Distancia de detención = reacción + frenado',
        blocks: [
          ParagraphBlock(
            'La distancia de detención es el trecho desde el momento en '
            'que detectas el peligro hasta que el vehículo se para. Consta '
            'de dos partes: la distancia de reacción, que recorres aún a '
            'plena velocidad, y la distancia de frenado propiamente '
            'dicha.',
          ),
          FactsBlock([
            FactItem('aprox. 1 s', 'tiempo de reacción de un conductor '
                'despierto y sobrio'),
            FactItem('× 3', 'distancia de reacción = velocidad ÷ 10, por '
                '3'),
            FactItem('²', 'distancia de frenado = (velocidad ÷ 10) al '
                'cuadrado'),
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Las reglas rápidas',
            text: 'Distancia de reacción = (km/h ÷ 10) × 3. Distancia de '
                'frenado = (km/h ÷ 10) × (km/h ÷ 10). La suma de ambas es '
                'la distancia de detención. En una frenada de emergencia, '
                'la distancia de frenado se reduce a la mitad.',
          ),
          ParagraphBlock(
            'El punto decisivo: la distancia de frenado no crece de forma '
            'proporcional a la velocidad, sino al cuadrado. El doble de '
            'velocidad significa cuatro veces la distancia de frenado — '
            'por eso 20 km/h de más en una calle residencial lo cambian '
            'todo.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Calcular en vez de estimar',
        blocks: [
          TableBlock(
            headers: ['Velocidad', 'Reacción', 'Frenado', 'Detención'],
            rows: [
              ['30 km/h', '9 m', '9 m', '18 m'],
              ['50 km/h', '15 m', '25 m', '40 m'],
              ['70 km/h', '21 m', '49 m', '70 m'],
              ['100 km/h', '30 m', '100 m', '130 m'],
            ],
          ),
          ParagraphBlock(
            'Para comparar: una Sprinter mide unos 6 metros. A 50 km/h '
            'necesitas por tanto unas siete longitudes de vehículo hasta '
            'detenerte — y las dos primeras y media transcurren antes de '
            'que llegues siquiera a tocar el pedal.',
          ),
          RevealBlock(
            prompt: 'Cálculo: circulas a 50 km/h por una calle '
                'residencial. A 20 metros, un niño sale a la calzada '
                'entre dos coches aparcados. ¿Consigues detenerte?',
            answer: 'No. Solo tu distancia de reacción es de 15 metros, '
                'después vienen 25 metros de frenado — en total 40 '
                'metros. Ni siquiera con frenada de emergencia (15 m + '
                '12,5 m = 27,5 m) bastan 20 metros. A 30 km/h, en cambio: '
                '9 m de reacción + 9 m de frenado = 18 metros — te paras '
                'dos metros antes. Exactamente esa es la diferencia entre '
                'un susto y un accidente grave.',
          ),
        ],
      ),
      SafetySlide(
        title: 'La regla de los dos segundos',
        asset: 'assets/academy/driving/m03b_abstand.svg',
        blocks: [
          ParagraphBlock(
            'La distancia no es cortesía, sino tu tiempo de reacción '
            'medido en metros. Y como se piensa en segundos, se adapta '
            'automáticamente a tu velocidad.',
          ),
          StepsBlock([
            'Busca un punto fijo al borde de la vía — una señal, una '
                'farola, una marca vial',
            'Cuando el vehículo de delante pase ese punto, empieza a '
                'contar: «mil uno, mil dos»',
            'Si llegas al punto antes de «mil dos», vas demasiado pegado',
            'Con lluvia, niebla u oscuridad, aumenta a tres segundos',
          ]),
          FactsBlock([
            FactItem('2 s', 'distancia mínima con calzada seca'),
            FactItem('3 s+', 'con lluvia, niebla u oscuridad'),
            FactItem('28 m', 'equivalen a 2 segundos a 50 km/h'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 4 Abs. 1 StVO — distancia',
            text: 'La distancia con el vehículo precedente debe ser, por '
                'regla general, tan grande como para poder detenerse '
                'detrás de él aunque frene de forma repentina. Como regla '
                'rápida, fuera de poblado vale la mitad del valor del '
                'velocímetro en metros.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Cuando falta la distancia',
        blocks: [
          RevealBlock(
            prompt: 'Caso práctico: en carretera nacional mantienes '
                'limpiamente 40 metros a 80 km/h. Un turismo se mete en '
                'el hueco y luego frena. ¿Qué es lo correcto ahora?',
            answer: 'No enfadarse, no pitar, no pegarse — sino levantar '
                'el pie y reconstruir la distancia. Eso te cuesta unos '
                'segundos y es la única reacción que reduce tu riesgo. '
                'Quien en cambio se acerca para «defender» el hueco ya no '
                'tiene 40 metros a 80 km/h, sino quizá 15 — menos que la '
                'propia distancia de reacción de 24 metros.',
          ),
          DoDontBlock(
            doTitle: 'Con temple',
            dos: [
              'Reconstruir la distancia con calma tras una incorporación',
              'Si te pegan por detrás: mantente a la derecha y déjalo '
                  'pasar',
              'Levantar el pie pronto ante semáforos y obras',
              'En retención, dejar hueco con el de delante para poder '
                  'salir',
            ],
            dontTitle: 'Arriesgado',
            donts: [
              'Pegarse para impedir que otro se incorpore',
              'Ráfagas y claxon como método educativo',
              'En el pare y arranca, rodar hasta pegarte al parachoques',
              'Estimar la distancia solo por sensación en vez de por '
                  'segundos',
            ],
          ),
          FactsBlock([
            FactItem('hasta 400 €', 'de multa por infracciones de '
                'distancia, además de puntos y retirada del permiso'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Mirada lejos, muy por delante',
        asset: 'assets/academy/driving/m03c_blickfuehrung.svg',
        blocks: [
          ParagraphBlock(
            'No mires el parachoques que tienes delante, sino de 12 a 15 '
            'segundos por delante — en ciudad, unas dos manzanas. Así ves '
            'pronto luces de freno, semáforos, peatones y estrechamientos '
            'y no tienes que reaccionar con prisas.',
          ),
          BulletsBlock([
            'Un niño en el bordillo que aún no ha mirado',
            'Un ciclista que va a rodear un coche aparcado',
            'Una puerta de coche con alguien sentado dentro — luces '
                'traseras encendidas, cabeza en el retrovisor interior',
            'Luces de freno tres vehículos más adelante',
            'Contenedores al borde de la calzada: indicio de maniobras',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'La mirada dirige el vehículo',
            text: 'Vas hacia donde miras. Por eso, al esquivar, mira '
                'siempre al hueco libre — nunca al obstáculo.',
          ),
          ParagraphBlock(
            'Cada pocos segundos, una mirada rápida a los espejos forma '
            'parte del trabajo. Así sabes en todo momento qué pasa detrás '
            'de ti y no tienes que mirar por primera vez en plena '
            'emergencia.',
          ),
        ],
      ),
      SafetySlide(
        title: 'La velocidad es física',
        blocks: [
          ParagraphBlock(
            'La velocidad permitida es un máximo, no un objetivo. En '
            'zonas residenciales, junto a colegios, con coches aparcados '
            'y en calles estrechas, ir más despacio de lo permitido suele '
            'ser la única opción correcta.',
          ),
          FactsBlock([
            FactItem('×4', 'distancia de frenado al doble de velocidad'),
            FactItem('18 m', 'distancia de detención a 30 km/h'),
            FactItem('40 m', 'distancia de detención a 50 km/h'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 3 Abs. 1 StVO — conducir según la visibilidad',
            text: 'Solo puedes circular tan rápido como para poder '
                'detenerte dentro del tramo que alcanzas a ver. Con '
                'niebla, de noche o en una curva sin visibilidad, eso es '
                'bastante menos de lo que permite la señal.',
          ),
          ParagraphBlock(
            'Haz el cálculo de lo que aporta correr: en diez kilómetros '
            'de recorrido urbano ahorras entre 50 y 60 km/h dos minutos '
            'como mucho — que te quita el siguiente semáforo en rojo.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Por qué tu furgoneta cargada se comporta distinto',
        blocks: [
          ParagraphBlock(
            'Una furgoneta a plena carga es un vehículo distinto del '
            'mismo coche vacío por la mañana. Más masa significa más '
            'energía cinética que el freno debe disipar — y un centro de '
            'gravedad más alto significa menos margen en curva.',
          ),
          FactsBlock([
            FactItem('3,5 t', 'masa máxima autorizada de tu furgoneta'),
            FactItem('hasta 1,4 t', 'de carga útil — más de la mitad de '
                'la tara'),
            FactItem('alto', 'centro de gravedad: las furgonetas vuelcan '
                'donde un turismo aún derrapa'),
          ]),
          BulletsBlock([
            'Cargado, frena antes y con más suavidad — el freno necesita '
                'más tiempo para la misma deceleración',
            'En curva, claramente más despacio: la carga se desplaza '
                'hacia fuera y aumenta la tendencia a volcar',
            'En maniobras evasivas no contravires bruscamente — eso es '
                'justo lo que hace volcar a los vehículos altos',
            'Entra en rotondas y salidas de autopista con bastante menos '
                'velocidad de la habitual',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'El vuelco llega sin avisar',
            text: 'A diferencia de un turismo, una furgoneta alta apenas '
                'anuncia el vuelco. Si oyes que la carga se desplaza, ya '
                'vas demasiado rápido — quita velocidad antes de entrar '
                'en la curva, no dentro de ella.',
          ),
        ],
      ),
      SafetySlide(
        title: 'El ángulo muerto',
        asset: 'assets/academy/driving/m03d_toterwinkel.svg',
        blocks: [
          ParagraphBlock(
            'Tu furgoneta tiene ángulos muertos grandes — sobre todo a la '
            'derecha, al lado y en diagonal detrás de la cabina. Ahí cabe '
            'un ciclista entero con su bicicleta sin que lo veas por el '
            'espejo.',
          ),
          FactsBlock([
            FactItem('derecha', 'el mayor ángulo muerto en las '
                'furgonetas'),
            FactItem('1,5 m', 'distancia lateral mínima al adelantar a '
                'ciclistas en poblado'),
            FactItem('2 m', 'distancia mínima fuera de poblado'),
          ]),
          ParagraphBlock(
            'Ajustar bien los espejos reduce el ángulo muerto, pero no lo '
            'elimina. Por eso, en cada cambio de carril y cada giro toca '
            'mirar activamente por encima del hombro — una mirada breve y '
            'real hacia atrás, no un simple gesto de cabeza hacia el '
            'espejo.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Nunca des por hecho que te han visto',
            text: 'El contacto visual es la única prueba fiable de que '
                'alguien te ha percibido. Un intermitente es una '
                'intención, no una garantía.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Girar: el momento más peligroso',
        blocks: [
          ParagraphBlock(
            'La mayoría de las colisiones graves con ciclistas y peatones '
            'ocurren al girar a la derecha. El motivo es siempre el '
            'mismo: el ciclista sigue recto y se encuentra justo en la '
            'zona que el conductor deja de ver al iniciar el giro.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: quieres girar a la derecha en un '
                'semáforo. Un ciclista te ha adelantado por la izquierda '
                'y está a tu lado. El semáforo se pone en verde. ¿Qué '
                'haces primero?',
            answer: 'Quedarte parado y dejarlo pasar. En cuanto arrancas '
                'y giras, él pasa al ángulo muerto de la derecha — y '
                'además la parte trasera de tu vehículo barre hacia su '
                'carril al girar. Lo correcto es: mirada por encima del '
                'hombro a la derecha antes de arrancar, dejar pasar a '
                'ciclistas y peatones, luego girar despacio y volver a '
                'mirar por el espejo derecho durante el giro. Quien se fía '
                'solo del espejo deja de verlo justo cuando importa.',
          ),
          DoDontBlock(
            doTitle: 'Girar con seguridad',
            dos: [
              'Señalizar pronto y reducir claramente la velocidad',
              'Mirada por encima del hombro antes de girar — no solo el '
                  'espejo',
              'Volver a controlar la derecha durante el giro',
              'En caso de duda, parar y dejar pasar',
            ],
            dontTitle: 'Arriesgado',
            donts: [
              'Girar con impulso para aprovechar el hueco',
              'Confiar solo en la mirada al espejo',
              'Suponer que los ciclistas se quedarán detrás de ti',
              'Poner el intermitente cuando ya estás girando',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Al girar y dar la vuelta',
            text: '§ 9 Abs. 5 StVO: al entrar en una propiedad, al '
                'cambiar de sentido y al dar marcha atrás debes excluir '
                'cualquier peligro para otros usuarios de la vía — si es '
                'necesario, haciéndote guiar por otra persona.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de control: conducción defensiva',
        blocks: [
          ChecklistBlock(
            title: 'Esto lo aplico desde hoy',
            items: [
              'Conozco las reglas rápidas de distancia de reacción y de '
                  'frenado',
              'Compruebo mi distancia con un punto fijo y dos segundos',
              'Con lluvia y oscuridad la aumento a tres segundos',
              'Miro de 12 a 15 segundos por delante en vez de al '
                  'parachoques',
              'Cargado voy más despacio en curva y freno antes',
              'Antes de cada giro y cambio de carril miro de verdad por '
                  'encima del hombro',
              'Mantengo 1,5 m de distancia al adelantar a ciclistas en '
                  'poblado',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M4
  SafetyChapterContent(
    id: 'm4',
    title: 'Marcha atrás y maniobras',
    summary: 'Dominar la fuente de daños más frecuente — dar marcha atrás '
        'y maniobrar con seguridad en sitios estrechos',
    asset: 'assets/academy/driving/m04_rueckwaerts.svg',
    slides: [
      SafetySlide(
        title: 'La fuente de daños número 1',
        blocks: [
          ParagraphBlock(
            'La mayoría de los daños en furgonetas se producen despacio — '
            'dando marcha atrás y maniobrando: bolardos, muros, farolas, '
            'otros coches, puertas abiertas. Y en los peores casos, '
            'personas que están en el ángulo muerto detrás del vehículo.',
          ),
          FactsBlock([
            FactItem('70 %', 'de todos los daños en furgonetas ocurren '
                'maniobrando'),
            FactItem('< 10 km/h', 'velocidad a la que se producen la '
                'mayoría de los daños de maniobra'),
            FactItem('ciego', 'una zona de varios metros justo detrás del '
                'vehículo'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Por qué precisamente aquí',
            text: 'Al dar marcha atrás te falta lo que normalmente te '
                'protege: la visión libre. Al mismo tiempo se siente '
                'lento y por tanto inofensivo — la combinación más '
                'peligrosa del día a día del reparto.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Evitar la marcha atrás en vez de dominarla',
        blocks: [
          ParagraphBlock(
            'La marcha atrás más segura es la que no haces. Piensa ya al '
            'llegar a la parada en cómo vas a salir de ahí — así al final '
            'no tendrás ni que maniobrar.',
          ),
          BulletsBlock([
            'Si es posible, aparca de frente y sal también de frente',
            'Mejor parar 40 metros más allá que dar marcha atrás en una '
                'entrada estrecha',
            'En callejones sin salida y patios: piensa antes de entrar '
                'cómo vas a salir',
            'Memoriza los sitios donde puedes dar la vuelta en la ruta — '
                'son los mismos todos los días',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Lo que exigen la ley y la DGUV',
            text: '§ 9 Abs. 5 StVO: al dar marcha atrás debes excluir '
                'cualquier peligro para otros y, si es necesario, hacerte '
                'guiar. La DGUV Vorschrift 70 (Fahrzeuge) exige lo mismo: '
                'dar marcha atrás solo si está descartado cualquier '
                'peligro para personas.',
          ),
        ],
      ),
      SafetySlide(
        title: 'GOAL — Get Out And Look',
        asset: 'assets/academy/driving/m04b_goal.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'GOAL',
            text: '«Get Out And Look» — parar, bajar, mirar detrás del '
                'vehículo y solo entonces dar marcha atrás. Eso te '
                'descubre justo las cosas que desde el asiento nunca '
                'ves.',
          ),
          ParagraphBlock(
            'La vuelta dura de diez a quince segundos. En ese tiempo ves '
            'bolardos bajos, bordillos, desniveles, tapas de alcantarilla '
            'sueltas, niños jugando y la altura del portón de entrada. '
            'Nada de eso te lo muestra de forma fiable una cámara de '
            'marcha atrás.',
          ),
          FactsBlock([
            FactItem('15 s', 'dura una vuelta GOAL'),
            FactItem('90 cm', 'altura por debajo de la cual un niño '
                'queda invisible detrás del vehículo'),
          ]),
          ParagraphBlock(
            'Y algo más: lo que has visto al bajar se te queda en la '
            'cabeza. Después no vas hacia lo desconocido, sino hacia una '
            'imagen que ya conoces.',
          ),
        ],
      ),
      SafetySlide(
        title: 'GOAL paso a paso',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/goal01_stopp.svg',
              title: '1 · Parar',
              caption: 'Antes de meter la marcha atrás, detente por '
                  'completo y asegura el vehículo. Quien ya está rodando '
                  'no decide — solo reacciona.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal02_aussteigen.svg',
              title: '2 · Bajar',
              caption: 'Baja del vehículo en vez de contorsionarte en el '
                  'asiento. Usa el estribo y los asideros — la regla de '
                  'los tres puntos de apoyo vale también aquí.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal03_umschauen.svg',
              title: '3 · Mirar alrededor',
              caption: 'Da una vuelta completa al vehículo: ¿qué hay bajo '
                  'la altura del portón trasero, cuánto mide la entrada, '
                  'dónde hay pendiente, hay niños o animales cerca? '
                  'Memoriza distancias y puntos de referencia.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal04_zurueck.svg',
              title: '4 · Atrás despacio',
              caption: 'Solo ahora da marcha atrás — al paso, mirando por '
                  'encima del hombro y por ambos espejos. En caso de '
                  'duda, para otra vez y vuelve a mirar.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Despacio no significa inofensivo',
        blocks: [
          StepsBlock([
            'Ir al paso — nunca más rápido, tampoco en un patio vacío',
            'Bajar la ventanilla para oír: gritos, bocinas, niños',
            'Mirar por encima del hombro y por ambos espejos, '
                'alternando',
            'Usar la cámara solo como complemento, nunca como única '
                'fuente',
            'Ante cualquier duda: parar, bajar y volver a mirar',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'El engaño de la cámara',
            text: 'La cámara de marcha atrás muestra un recorte, '
                'distorsiona las distancias y se queda ciega con lluvia, '
                'nieve y suciedad. No ve nada de lo que entra en tu '
                'trayectoria por el lateral. No sustituye a GOAL.',
          ),
          FactsBlock([
            FactItem('al paso', 'velocidad máxima al maniobrar'),
            FactItem('2 s', 'tarda un niño en meterse en la zona detrás '
                'del vehículo'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Usar bien a quien te guía',
        blocks: [
          ParagraphBlock(
            'Una persona que te guía solo ayuda si las reglas están '
            'claras de antemano. Un compañero que está en algún punto '
            'detrás del vehículo haciendo señas no es seguridad — es un '
            'riesgo añadido.',
          ),
          BulletsBlock([
            'Acordad las señales antes: parar, despacio, sigue, cuánto '
                'espacio queda',
            'Quien guía se coloca de lado, nunca justo detrás del '
                'vehículo',
            'Tienes que verlo permanentemente por el espejo — si no, '
                'toca parar',
            'Solo guía una persona, no varias a la vez',
            'Quien guía lleva chaleco reflectante, sobre todo al '
                'atardecer',
          ]),
          RevealBlock(
            prompt: 'Estás dando marcha atrás en una entrada estrecha y '
                'tu compañero te guía. De repente dejas de verlo por el '
                'espejo. ¿Qué haces?',
            answer: 'Parar de inmediato — no ir más despacio, sino '
                'detenerte. Sin contacto visual no hay señal válida. '
                'Quizá ha pasado por detrás del vehículo, ha resbalado o '
                'un peatón le ha dado conversación. Solo sigue cuando '
                'vuelvas a verlo y te dé una nueva señal.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Caso práctico: el patio estrecho',
        blocks: [
          RevealBlock(
            prompt: 'Caso práctico: la última parada está en un patio '
                'interior. La entrada es estrecha, detrás de ti espera un '
                'coche, llueve y llevas 40 minutos de retraso. De frente '
                'entras — pero salir solo se puede marcha atrás, pasando '
                'junto a un muro y tres coches aparcados. ¿Cuál es la '
                'decisión correcta?',
            answer: 'No entrar siquiera. Para en la calle, lleva los '
                'últimos metros a pie o usa la carretilla. Si ya estás '
                'dentro: pon los intermitentes de emergencia, baja, '
                'observa la situación, si hace falta pide al conductor '
                'que espera que retroceda y sal maniobrando en varios '
                'movimientos cortos con controles intermedios. El '
                'conductor que espera detrás de ti no es motivo para '
                'correr — el daño te lo apuntan a ti, no a él. Los 40 '
                'minutos de retraso no los recupera ninguna maniobra, '
                'pero un golpe de chapa te cuesta el resto del día.',
          ),
          DoDontBlock(
            doTitle: 'Maniobrar bien',
            dos: [
              'En varios movimientos cortos en vez de uno largo',
              'Parar en medio y volver a evaluar la situación',
              'Intermitentes de emergencia al maniobrar en zona de '
                  'tráfico',
              'Mejor parar más lejos y hacer los últimos metros a pie',
            ],
            dontTitle: 'Mal',
            donts: [
              'Maniobrar más rápido por la presión de quien espera',
              'Hacerlo «de una sola vez» porque si no da vergüenza',
              'Confiar solo en la cámara o en los sensores',
              'Maniobrar mientras hay peatones cruzando la zona',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de control: marcha atrás y maniobras',
        blocks: [
          ChecklistBlock(
            title: 'Antes de cada maniobra marcha atrás',
            items: [
              'Primero compruebo si puedo evitar la marcha atrás',
              'Me detengo por completo antes de meter la marcha atrás',
              'Bajo del vehículo y miro detrás (GOAL)',
              'Doy marcha atrás solo al paso',
              'Miro por encima del hombro y por ambos espejos, no solo a '
                  'la cámara',
              'Bajo la ventanilla para oír',
              'Paro de inmediato si dejo de ver a quien me guía',
              'Comunico cada daño de maniobra, también la abolladura '
                  'pequeña',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M5
  SafetyChapterContent(
    id: 'm5',
    title: 'Clima, visibilidad y condiciones difíciles',
    summary: 'Adaptar la conducción a lluvia, calzada mojada, niebla, '
        'nieve, oscuridad y calor',
    asset: 'assets/academy/driving/m05_wetter.svg',
    slides: [
      SafetySlide(
        title: 'El agua lo cambia todo',
        blocks: [
          ParagraphBlock(
            'Sobre calzada mojada el agarre baja notablemente — la '
            'distancia de frenado se alarga de forma considerable, en '
            'muchas situaciones hasta casi el doble. Especialmente '
            'crítica es la primera lluvia tras una larga sequía: el '
            'aceite y el caucho del asfalto forman con el agua una '
            'película resbaladiza.',
          ),
          FactsBlock([
            FactItem('hasta ×2', 'se alarga la distancia de frenado con '
                'la calzada mojada'),
            FactItem('3 s+', 'distancia mínima en vez de 2 segundos'),
            FactItem('−20 %', 'de velocidad como orientación '
                'aproximada'),
          ]),
          BulletsBlock([
            'Frenar antes y con más suavidad, nunca dentro de la curva',
            'Hacer los movimientos de volante suaves, no bruscos',
            'Cuidado con las marcas viales, las tapas de alcantarilla y '
                'los raíles del tranvía — ahí es donde más resbala',
            'Evitar las roderas, ahí es donde se acumula el agua',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'La velocidad es obligación, no elección',
            text: 'El § 3 Abs. 1 StVO exige que adaptes la velocidad al '
                'estado de la vía, al tráfico, a la visibilidad y a la '
                'meteorología. En un accidente sobre calzada mojada, el '
                'límite permitido no te sirve de nada.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Aquaplaning: lo que realmente ocurre',
        asset: 'assets/academy/driving/m05b_aquaplaning.svg',
        blocks: [
          ParagraphBlock(
            'Aquaplaning significa: entre el neumático y la calzada se '
            'mete una película de agua. El neumático flota. A partir de '
            'ese momento la dirección y el freno dejan de tener efecto — '
            'no menos efecto, sino ninguno.',
          ),
          ParagraphBlock(
            'Las ranuras del dibujo tienen exactamente una tarea: evacuar '
            'el agua por delante del neumático. A velocidades altas, un '
            'neumático debe desplazar varios litros de agua por segundo. '
            'Cuanto más liso el dibujo y más alta la velocidad, antes '
            'deja de conseguirlo.',
          ),
          FactsBlock([
            FactItem('1,6 mm', 'mínimo legal — para el aquaplaning ya es '
                'demasiado poco'),
            FactItem('3 mm', 'límite práctico inferior con tiempo '
                'lluvioso'),
            FactItem('Velocidad²', 'así crece el riesgo de aquaplaning '
                'con la velocidad'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Cómo lo notas a tiempo',
            text: 'La dirección se vuelve de repente ligera, el ruido de '
                'rodadura cambia, las revoluciones suben sin motivo. Esos '
                'son los segundos en los que todavía puedes levantar el '
                'pie.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Aquaplaning: la reacción correcta',
        blocks: [
          DoDontBlock(
            doTitle: 'Con agua acumulada, así sí',
            dos: [
              'Levantar el pie del acelerador — solo eso, sin soltarlo de '
                  'golpe',
              'Mantener el volante quieto y recto',
              'Pisar el embrague o dejar que desembrague',
              'Dejar rodar hasta que los neumáticos vuelvan a agarrar',
              'Solo después girar o frenar con cuidado',
            ],
            dontTitle: 'Mal',
            donts: [
              'Frenar con fuerza — las ruedas se bloquean sin efecto',
              'Girar o contravirar bruscamente',
              'Acelerar para «pasar de largo»',
              'Cambiar de carril mientras los neumáticos flotan',
            ],
          ),
          RevealBlock(
            prompt: 'Caso práctico: en la carretera nacional hay agua '
                'acumulada en la rodera derecha tras una tormenta. Vas a '
                '80 km/h y detrás te viene un turismo pegado. ¿Qué '
                'haces?',
            answer: 'Levantar claramente el pie antes de entrar en el '
                'agua — no dentro de ella. Mantén el volante recto y deja '
                'que el de atrás se pegue lo que quiera; un alcance por '
                'detrás tiene arreglo, salir al carril contrario no. '
                'Quien en cambio frena o esquiva en medio del agua '
                'provoca justo la pérdida de control que quiere evitar. '
                'Si puedes: después del agua, mantente a la derecha y '
                'deja pasar al que te viene pegado.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Un neumático que flota no dirige',
            text: 'Mientras la película de agua sostiene, cualquier '
                'movimiento de volante es inútil — y actúa de golpe '
                'cuando el neumático vuelve a agarrar. De ahí nace '
                'exactamente el derrape.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Profundidad del dibujo y neumáticos de invierno',
        blocks: [
          TableBlock(
            headers: ['Situación', 'Dibujo / neumático'],
            rows: [
              ['Mínimo legal', '1,6 mm — todo el año'],
              ['Verano, calzada mojada', 'recomendado desde 3 mm'],
              ['Invierno, nieve y barro', 'recomendado desde 4 mm'],
              ['Hielo, nieve, placas', 'neumático invernal con símbolo '
                  'alpino'],
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Obligación situacional de neumáticos de invierno',
            text: 'Según el § 2 Abs. 3a StVO, con placas de hielo, nieve '
                'pisada, aguanieve o escarcha solo puedes circular con '
                'neumáticos aptos para invierno. Las infracciones cuestan '
                'multa y un punto — más si además entorpeces a otros.',
          ),
          BulletsBlock([
            'Los neumáticos de invierno se reconocen por el símbolo '
                'alpino (montaña con copo de nieve)',
            'Incluso los neumáticos aptos para invierno apenas sirven si '
                'les queda poco dibujo',
            'Ten en cuenta la edad del neumático: el caucho se endurece '
                'y pierde agarre aunque el dibujo siga ahí',
            'Comunica el dibujo escaso antes de la primera helada — no a '
                'la mañana siguiente',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Nieve, hielo y rascar la luna',
        asset: 'assets/academy/driving/m05c_winter.svg',
        blocks: [
          ParagraphBlock(
            'Con hielo vale para todo lo mismo: suavidad. Arrancar suave, '
            'frenar suave, girar suave. Cualquier movimiento brusco '
            'supera el poco agarre que hay. Los puentes, las zonas de '
            'bosque y los tramos en sombra se hielan primero — y se '
            'deshielan los últimos.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Nada de «mirillas»',
            text: 'Todas las lunas, los espejos, las luces y la matrícula '
                'deben estar despejados (§ 23 Abs. 1 StVO). Una «mirilla» '
                'rascada es una infracción — y en un accidente, un '
                'reproche de culpa grave. La nieve del techo también '
                'tiene que caer antes de arrancar.',
          ),
          DoDontBlock(
            doTitle: 'Rutina de invierno',
            dos: [
              'Rascar por completo todas las lunas y los espejos',
              'Quitar la nieve del techo, las luces y la matrícula',
              'Limpiar de hielo y barro los estribos y los asideros',
              'Rellenar el limpiaparabrisas con anticongelante',
              'Salir bastante antes en vez de recuperar por el camino',
            ],
            dontTitle: 'Errores de invierno',
            donts: [
              'Arrancar mientras la luna aún se está deshelando',
              'Echar agua caliente sobre la luna',
              'Frenar y girar a la vez sobre aguanieve',
              'Ignorar los estribos helados — ahí es donde te caes',
            ],
          ),
          FactsBlock([
            FactItem('0 °C', 'a partir de aquí, primero los puentes y '
                'los tramos en sombra'),
            FactItem('×2 a ×10', 'se alarga la distancia de frenado '
                'sobre nieve y hielo'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Niebla, crepúsculo y oscuridad',
        blocks: [
          ParagraphBlock(
            'Con mala visibilidad no solo es más difícil ver, también que '
            'te vean. Enciende las luces a tiempo — en caso de duda, '
            'media hora antes de lo necesario.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Regla rápida con niebla',
            text: 'La visibilidad en metros equivale a la velocidad '
                'máxima en km/h. Si solo ves 50 metros, circulas como '
                'mucho a 50 km/h — y con visibilidad inferior a 50 metros '
                'rige de todos modos el límite de 50 km/h.',
          ),
          BulletsBlock([
            'Antinieblas delanteros solo con visibilidad realmente '
                'reducida, no como alumbrado permanente',
            'Antiniebla trasera solo por debajo de 50 metros de '
                'visibilidad — deslumbra mucho al de atrás',
            'Usa los hitos de arcén como orientación',
            'Al atardecer, atención especial a los peatones con ropa '
                'oscura',
            'Luz interior apagada y lunas limpias por dentro — ambas '
                'cosas te quitan visión nocturna',
          ]),
          FactsBlock([
            FactItem('50 m', 'distancia entre dos hitos de arcén fuera '
                'de poblado'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Temporal y viento lateral',
        blocks: [
          ParagraphBlock(
            'Tu furgoneta es una superficie grande y alta — con viento '
            'lateral se comporta de forma totalmente distinta a un '
            'turismo. Especialmente peligrosos son los puntos donde el '
            'viento aparece de golpe: puentes, salidas de zonas '
            'boscosas, huecos entre edificios y al ser adelantado por un '
            'camión.',
          ),
          BulletsBlock([
            'Reducir claramente la velocidad, las dos manos al volante',
            'En los puntos de viento conocidos, afianzar el agarre antes '
                'y contar con una racha',
            'Tras adelantar a un camión, contar con un golpe de viento',
            'Con temporal, no aparcar bajo árboles ni junto a andamios',
            'Sujetar las puertas con viento — se abren de golpe y se '
                'dañan',
          ]),
          RevealBlock(
            prompt: 'Caso práctico: aviso de temporal, circulas vacío por '
                'un puente de autopista. ¿Por qué es crítico precisamente '
                'ir vacío?',
            answer: 'Porque al vehículo le falta el peso que lo mantiene '
                'sobre la calzada. Una furgoneta vacía ofrece la misma '
                'superficie al viento que una cargada, pero pesa un '
                'tercio menos — una racha la desplaza mucho más. Lo '
                'correcto es: quitar velocidad antes del puente, las dos '
                'manos al volante, contar con el golpe de viento al final '
                'del puente y no circular al lado de un camión.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Calor y rutas largas',
        blocks: [
          ParagraphBlock(
            'En verano trabajas en un vehículo que se calienta mucho al '
            'sol y además caminas muchos kilómetros. Un conductor '
            'sobrecalentado y deshidratado reacciona de forma '
            'medible más lenta — el efecto es comparable al del '
            'cansancio.',
          ),
          FactsBlock([
            FactItem('2–3 l', 'de líquido por turno con calor'),
            FactItem('> 60 °C', 'temperatura interior de un vehículo '
                'parado al sol'),
          ]),
          BulletsBlock([
            'Bebe con regularidad, antes de sentir sed',
            'Descansos a la sombra, no en una cabina recalentada',
            'Gorra y protección solar en los recorridos a pie largos',
            'Si tienes problemas circulatorios, comunícalo enseguida y '
                'haz una pausa',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Nunca dejar a nadie dentro',
            text: 'Nunca dejes a un animal o a una persona en un vehículo '
                'recalentado — tampoco «solo cinco minutos» ni con la '
                'ventanilla entreabierta. El interior alcanza en minutos '
                'temperaturas mortales.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de control: condiciones difíciles',
        blocks: [
          ChecklistBlock(
            title: 'Con mal tiempo y mala visibilidad',
            items: [
              'Adapto velocidad y distancia, no solo a lo que dice la '
                  'señal',
              'Con calzada mojada aumento a un mínimo de 3 segundos de '
                  'distancia',
              'Con aquaplaning: pie fuera, recto, sin frenar',
              'Conozco la profundidad de mi dibujo y comunico pronto los '
                  'neumáticos gastados',
              'Rasco todas las lunas, nada de mirillas',
              'Quito la nieve del techo, de las luces y de la matrícula',
              'Cuento con viento lateral en puentes y salidas de bosque',
              'Bebo lo suficiente y hago las pausas a la sombra',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M6
  SafetyChapterContent(
    id: 'm6',
    title: 'Distracción, cansancio y presión de tiempo',
    summary: 'Reconocer las principales causas humanas de accidente y '
        'contrarrestarlas activamente',
    asset: 'assets/academy/driving/m06_ablenkung.svg',
    slides: [
      SafetySlide(
        title: 'Móvil al volante: PROHIBIDO',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'El móvil en la mano está prohibido durante la marcha',
            text: 'Ni para hablar, ni para escribir, ni para consultar — '
                'y tampoco para elegir música, pódcast o mensajes.',
          ),
          ParagraphBlock(
            'Con toda claridad y sin excepciones. No es solo una norma de '
            'nuestra empresa, es la ley. Y vale para cualquier aparato '
            'electrónico que sirva para comunicar, informar u organizar — '
            'es decir, también para el escáner.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 23 Abs. 1a StVO',
            text: 'Quien conduce un vehículo solo puede usar un aparato '
                'electrónico si para ello no lo coge ni lo sostiene. Ya '
                'el simple hecho de cogerlo o sostenerlo en la mano es la '
                'infracción — con independencia de lo que hagas con él.',
          ),
        ],
      ),
      SafetySlide(
        title: 'El tramo a ciegas',
        asset: 'assets/academy/driving/m06b_handy.svg',
        blocks: [
          ParagraphBlock(
            'Una mirada a la pantalla no es un segundo — dura de media de '
            'dos a tres segundos, y leer un mensaje más bien cinco. '
            'Durante ese tiempo conduces con los ojos cerrados. Calcúlalo '
            'en metros.',
          ),
          FactsBlock([
            FactItem('14 m/s', 'recorres por segundo a 50 km/h'),
            FactItem('28 m', 'a ciegas con 2 segundos de mirada al '
                'móvil'),
            FactItem('aprox. 70 m', 'a ciegas si lees un mensaje'),
          ]),
          RevealBlock(
            prompt: 'Cálculo: circulas a 30 km/h por una calle '
                'residencial de prioridad peatonal y miras 3 segundos el '
                'escáner. ¿Cuánto recorres a ciegas — y basta eso para un '
                'accidente?',
            answer: 'A 30 km/h recorres unos 8 metros por segundo, es '
                'decir, en 3 segundos unos 25 metros. Eso es más que la '
                'distancia de detención completa a esa velocidad (18 '
                'metros). Dicho de otro modo: atraviesas a ciegas un '
                'tramo en el que, viendo, ya habrías podido detenerte. '
                'Quien piensa que a poca velocidad una mirada no es '
                'crítica confunde lento con seguro — precisamente en '
                'estas calles los niños salen a la calzada sin avisar.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Música, navegador, escáner — todo antes',
        blocks: [
          ParagraphBlock(
            'La música y los pódcast están bien — pero no con el móvil en '
            'la mano. Todo se elige y se pone en marcha antes de arrancar, '
            'con el vehículo parado: lista de reproducción, volumen, '
            'destino del navegador, próxima parada. Una vez está en '
            'marcha, durante la conducción no se toca nada del aparato.',
          ),
          DoDontBlock(
            doTitle: 'Permitido',
            dos: [
              'Ajustar lista y volumen antes, con el vehículo parado',
              'Introducir el destino del navegador antes de salir',
              'Dejar el móvil en el soporte y limitarse a mirarlo',
              'Hablar con manos libres',
              'Para todo lo demás, parar un momento',
            ],
            dontTitle: 'Prohibido',
            donts: [
              'Cambiar de canción o de pódcast durante la marcha',
              'Leer o escribir un mensaje durante la marcha',
              'Coger el móvil en un semáforo en rojo',
              'Manejar el escáner o la lista de paradas en movimiento',
              'Sacar el aparato del soporte para verlo mejor',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Nada de auriculares',
            text: 'Nada de cascos ni auriculares durante la marcha — '
                'tampoco en un solo oído. Tienes que oír el tráfico, las '
                'bocinas, los gritos y los vehículos de emergencia. Al '
                'maniobrar, tu oído suele ser el único aviso.',
          ),
        ],
      ),
      SafetySlide(
        title: 'La única excepción: parado y con el motor apagado',
        blocks: [
          ParagraphBlock(
            'El móvil, el escáner y el navegador solo se manejan con el '
            'vehículo parado de forma segura. La secuencia práctica en la '
            'parada: detenerse, apagar el motor, manejar el aparato y '
            'luego bajar. Y antes de salir: subir, ajustar destino y '
            'música, y después arrancar.',
          ),
          RevealBlock(
            prompt: '¿Desde cuándo cuenta jurídicamente como «parado» — y '
                'qué pasa con el sistema de arranque y parada automático '
                'en un semáforo en rojo?',
            answer: 'Jurídicamente solo cuenta como parado cuando el '
                'motor está apagado. La excepción expresamente no se '
                'aplica si el motor solo está en reposo por una función '
                'automática de arranque y parada. Es decir, en un '
                'semáforo en rojo no puedes coger el aparato — tampoco si '
                'el motor está en ese momento en silencio.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Excepción solo con el motor apagado',
            text: 'El manejo solo está permitido si el vehículo está '
                'parado y el motor apagado. Una desconexión automática de '
                'arranque y parada no basta para ello.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lo que cuesta',
        blocks: [
          FactsBlock([
            FactItem('100 € + 1 punto', 'móvil en la mano durante la '
                'marcha'),
            FactItem('150 € + 2 puntos', 'con peligro, más 1 mes de '
                'retirada del permiso'),
            FactItem('200 € + 2 puntos', 'con daños materiales, más 1 '
                'mes de retirada del permiso'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Periodo de prueba',
            text: 'Durante el periodo de prueba del permiso se añaden un '
                'seminario de perfeccionamiento y la prórroga del periodo '
                'de prueba a 4 años.',
          ),
          ParagraphBlock(
            'Para ti, como conductor profesional, una retirada del '
            'permiso significa: un mes sin trabajo. Y si de la distracción '
            'sale un accidente con heridos, la cosa no se queda en una '
            'multa — entonces entra en juego la acusación de poner en '
            'peligro la circulación (§ 315c StGB), y eso es un delito.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'El seguro más barato',
            text: 'Dejar el móvil a un lado no cuesta nada y protege tu '
                'permiso, tu puesto de trabajo y, llegado el caso, una '
                'vida.',
          ),
        ],
      ),
      SafetySlide(
        title: 'La distracción tiene muchas formas',
        blocks: [
          ParagraphBlock(
            'No solo el móvil: comer, beber, buscar paquetes, conversar, '
            'el enfado con el último cliente, pensar en la próxima '
            'parada. Distracción es todo lo que aparta de la carretera '
            'los ojos, las manos o la cabeza.',
          ),
          DoDontBlock(
            doTitle: 'Bien durante la marcha',
            dos: [
              'Mirar a la carretera',
              'Hablar con manos libres',
              'Miradas breves a los espejos',
              'Para todo lo demás, parar un momento',
            ],
            dontTitle: 'Mal',
            donts: [
              'Desenvolver comida o bebida',
              'Buscar el siguiente paquete en la zona de carga',
              'Manejar el escáner o la lista de paradas conduciendo',
              'Reorganizar mentalmente la ruta mientras conduces en vez '
                  'de parar un momento',
            ],
          ),
          RevealBlock(
            prompt: 'Caso práctico: al arrancar te das cuenta de que has '
                'cogido el envío equivocado. La parada correcta está 300 '
                'metros más allá. ¿Qué haces?',
            answer: 'Ir hasta el siguiente sitio seguro, parar, apagar el '
                'motor y cambiarlo entonces en la zona de carga. Estirar '
                'el brazo hacia atrás durante la marcha es la situación '
                'clásica en la que los conductores se salen de su carril '
                '— porque giras a la vez la cabeza y el tronco. Un rodeo '
                'de 300 metros dura 30 segundos; un roce, el resto del '
                'día.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Cansancio: tu cuerpo no negocia',
        asset: 'assets/academy/driving/m06c_muedigkeit.svg',
        blocks: [
          ParagraphBlock(
            'El cansancio no es un problema de voluntad. A partir de '
            'cierto punto tu cerebro se desconecta brevemente — quieras o '
            'no. Lo traicionero: es justo en esa fase cuando más '
            'sobreestimas tu propio estado de alerta.',
          ),
          SubheadBlock('Las señales de alarma que debes tomar en serio'),
          BulletsBlock([
            'Bostezos frecuentes, ojos que escuecen o pesan',
            'No recuerdas los últimos kilómetros',
            'Te saltas desvíos o paradas',
            'La postura del asiento te parece de repente mal, te '
                'reacomodas sin parar',
            'Circulas inestable en el carril o corriges continuamente',
            'Frío y tensión en la nuca sin motivo externo',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Horas de riesgo',
            text: 'Las más peligrosas son las primeras horas de la '
                'mañana, el bajón después de comer y la última hora de la '
                'ruta. Planifica tus pausas justo ahí.',
          ),
        ],
      ),
      SafetySlide(
        title: 'El microsueño en metros',
        blocks: [
          ParagraphBlock(
            'Un microsueño dura normalmente de dos a cinco segundos. '
            'Suena a poco — hasta que lo calculas en metros.',
          ),
          FactsBlock([
            FactItem('56 m', 'a 50 km/h en 4 segundos de microsueño'),
            FactItem('89 m', 'a 80 km/h en 4 segundos'),
            FactItem('111 m', 'a 100 km/h en 4 segundos'),
          ]),
          RevealBlock(
            prompt: 'Cálculo: circulas a 80 km/h por carretera comarcal y '
                'das una cabezada de 4 segundos. ¿Cuánto recorres sin '
                'control — y qué hay en ese tramo?',
            answer: '80 km/h son unos 22 metros por segundo, es decir, en '
                '4 segundos unos 89 metros. En ese tramo, en una '
                'carretera comarcal, suele haber una curva, una hilera de '
                'árboles y el tráfico en sentido contrario. Y a '
                'diferencia de la mirada al móvil, en ese tiempo no '
                'diriges — el vehículo se sale del carril. Por eso contra '
                'el microsueño solo sirve una cosa: parar antes.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'No existe una versión pequeña de esto',
            text: 'Quien ha dado una cabezada volverá a darla — casi '
                'siempre en pocos minutos. El trayecto termina aquí, no '
                'en la próxima parada.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lo que ayuda — y lo que no',
        blocks: [
          DoDontBlock(
            doTitle: 'Funciona de verdad',
            dos: [
              'Parar y cerrar los ojos de 15 a 20 minutos',
              'Bajar, caminar, aire fresco y movimiento',
              'Comer y beber algo',
              'Avisar de la ruta y pedir apoyo si con eso no basta',
            ],
            dontTitle: 'No funciona (o solo unos minutos)',
            donts: [
              'Ventanilla abierta y música alta',
              'Café como sustituto del sueño',
              'Mantenerse despierto conversando',
              'Ir más rápido para acabar antes',
            ],
          ),
          ParagraphBlock(
            'Una siesta corta de 15 a 20 minutos con movimiento después '
            'es la única medida que a corto plazo aporta algo de verdad. '
            'Todo lo demás solo desplaza el problema unos kilómetros.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Incapacidad para conducir',
            text: 'Quien sigue conduciendo pese a un cansancio evidente '
                'conduce en estado de incapacidad. Si con ello se genera '
                'un peligro, ya no es una multa, sino un delito (§ 315c '
                'StGB).',
          ),
        ],
      ),
      SafetySlide(
        title: 'Gestionar bien la presión de tiempo y lista de control',
        blocks: [
          ParagraphBlock(
            'La presión de tiempo es real — pero correr y agobiarse '
            'apenas ahorra tiempo y añade mucho riesgo. La ganancia de '
            'tiempo por ir más rápido en tráfico urbano se mide en '
            'minutos; un solo daño maniobrando te cuesta una hora.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Cuando el plan no cuadra',
            text: 'Eso no es un problema de seguridad, es un asunto de '
                'planificación — comunícalo pronto en vez de compensarlo '
                'al volante. Un aviso a las 13:00 ayuda; uno a las 18:00, '
                'ya no.',
          ),
          ChecklistBlock(
            title: 'Esto me llevo del módulo 6',
            items: [
              'No toco el móvil durante la marcha',
              'Ajusto música, navegador y escáner antes de arrancar',
              'Sé que «parado» solo cuenta con el motor apagado',
              'No llevo auriculares',
              'Conozco mis señales personales de cansancio',
              'Con cansancio paro en vez de aguantar',
              'Comunico pronto y con honestidad un plan poco realista',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M7
  SafetyChapterContent(
    id: 'm7',
    title: 'Accidentes laborales: subir y bajar, levantar y caídas',
    summary: 'Evitar lesiones más allá de la conducción — foco en subir y '
        'bajar del vehículo con seguridad',
    asset: 'assets/academy/driving/m07_ein_aussteigen.svg',
    slides: [
      SafetySlide(
        title: 'Por qué es el gesto más importante del día',
        blocks: [
          ParagraphBlock(
            'Subes y bajas del vehículo decenas de veces por ruta — es el '
            'movimiento que más repites. Justo por eso aquí se producen '
            'la mayoría de las lesiones: torceduras, resbalones en el '
            'borde del estribo, caídas desde el vehículo, un mal paso '
            'hacia la calzada.',
          ),
          FactsBlock([
            FactItem('100.000', 'accidentes por resbalón, tropiezo y '
                'caída entre conductores profesionales al año'),
            FactItem('24', 'días de baja de media por caída'),
            FactItem('N.º 1', 'tipo de lesión más frecuente en el '
                'reparto'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'La BG Verkehr advierte',
            text: 'La BG Verkehr (mutua alemana de accidentes de trabajo '
                'del sector transporte) advierte expresamente de que las '
                'caídas al subir y bajar del vehículo provocan lesiones '
                'graves y a veces mortales.',
          ),
          ParagraphBlock(
            'La diferencia entre una bajada segura y una peligrosa son '
            'dos segundos. Calculado sobre 250 bajadas al día, son unos '
            'ocho minutos — el seguro más barato para tu cuerpo.',
          ),
        ],
      ),
      SafetySlide(
        title: 'La regla de los 3 puntos (2+1)',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Dos manos y un pie — siempre',
            text: 'La regla central de la BG Verkehr: dos manos y un pie '
                'están siempre en contacto con el vehículo — «2+1».',
          ),
          ParagraphBlock(
            'Así tienes en todo momento tres puntos de apoyo firmes antes '
            'de soltar el siguiente. De este modo un simple resbalón '
            'nunca puede convertirse en caída, porque siempre te '
            'sostienen otros dos puntos. Mueve siempre un solo punto, '
            'nunca dos a la vez.',
          ),
          RevealBlock(
            prompt: '¿Qué tres puntos de apoyo son y qué no cuenta '
                'expresamente como tal?',
            answer: 'Mano izquierda en el asidero, mano derecha en el '
                'asidero, un pie en el estribo. No cuentan: el volante, '
                'el canto de la puerta, el asiento, el neumático y el '
                'buje de la rueda. El canto de la puerta y el volante '
                'ceden o giran justo cuando los necesitas.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Para recordar',
            text: 'Primero bajar, después coger. Deja los objetos primero '
                'en el vehículo y baja con las manos libres.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Bien al subir, bien al bajar',
        blocks: [
          BulletsBlock([
            'Al subir: de frente hacia el vehículo',
            'Al bajar: de espaldas, con la cara hacia el vehículo — como '
                'en una escalera, nunca girándote de espaldas a la '
                'puerta',
            'Usar todos los estribos — no saltarse ninguno',
            'Usar los asideros, no el canto de la puerta ni el volante '
                'como agarre de emergencia',
            'Al bajar de la zona de carga, la misma regla: cara hacia el '
                'vehículo, escalón a escalón',
          ]),
          StepsBlock([
            'Detenerse y asegurar el vehículo',
            'Dejar los objetos dentro del vehículo',
            'Comprobar el tráfico por el hombro y por el espejo',
            'Abrir la puerta de forma controlada',
            'Darse la vuelta, cara hacia el vehículo',
            'Establecer tres puntos de apoyo',
            'Bajar escalón a escalón',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Nunca saltar',
        asset: 'assets/academy/driving/m07b_springen.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Saltar es el error más frecuente',
            text: 'Saltar desde la cabina o desde la zona de carga es la '
                'causa más frecuente de tobillos torcidos y de lesiones '
                'de rodilla y espalda en el reparto.',
          ),
          ParagraphBlock(
            'El piso de carga de una furgoneta está, según el modelo, '
            'entre unos 55 y 75 centímetros por encima del asfalto. Al '
            'saltar, en el aterrizaje actúa un múltiplo de tu peso '
            'corporal sobre tobillo, rodilla y columna — y eso en cada '
            'salto.',
          ),
          FactsBlock([
            FactItem('55–75 cm', 'altura del piso de carga sobre el '
                'asfalto'),
            FactItem('250+', 'bajadas por ruta — cada una cuenta para '
                'tus articulaciones'),
          ]),
          RevealBlock(
            prompt: 'Caso práctico: llueve y saltas desde la zona de '
                'carga a una acera en pendiente con hojas mojadas. ¿Qué '
                'sale mal exactamente?',
            answer: 'Al saltar ya no puedes corregir el aterrizaje — '
                'estás en el aire y lo que pase debajo lo decide el '
                'suelo. Las hojas mojadas en pendiente casi no ofrecen '
                'rozamiento: el pie resbala al apoyar y la articulación '
                'se tuerce hacia un lado. Quien en cambio baja escalón a '
                'escalón con tres puntos de apoyo nota el suelo '
                'resbaladizo antes de poner todo su peso encima — y '
                'todavía puede detenerse.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Los errores típicos',
        blocks: [
          DoDontBlock(
            doTitle: 'Bien',
            dos: [
              'Dejar primero los objetos en el vehículo',
              'Bajar con las manos libres y tres puntos de apoyo',
              'Mantener limpios y libres los bordes de los estribos y '
                  'los asideros',
              'Con humedad y hielo, limpiar antes los escalones',
              'Tomarse el tiempo — también en la parada 180',
            ],
            dontTitle: 'Mal',
            donts: [
              'Saltar en vez de bajar',
              'Manos llenas — móvil, escáner, café, paquetes',
              'Usar el neumático o el buje como escalón',
              'Mirar el móvil mientras bajas',
              'Ignorar los bordes de estribo mojados, helados o sucios',
              'Girarse de lado para salir directamente desde el asiento',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'La parada de después es la más peligrosa',
            text: 'Tras una parada larga, las piernas están rígidas y la '
                'concentración se ha ido. Justo entonces llega el mal '
                'paso — concéntrate un momento y luego baja.',
          ),
        ],
      ),
      SafetySlide(
        title: 'El lado del tráfico: el momento subestimado',
        blocks: [
          ParagraphBlock(
            'En las furgonetas bajas el problema no suele ser la altura, '
            'sino el paso hacia el tráfico en circulación. Si es posible, '
            'baja por el lado de la acera o por el lado seguro. No abras '
            'la puerta de par en par antes de haber mirado.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 14 Abs. 1 StVO — subir y bajar',
            text: 'Quien sube o baja de un vehículo debe comportarse de '
                'forma que quede excluido cualquier peligro para otros '
                'usuarios de la vía. En un accidente con la puerta, la '
                'responsabilidad recae prácticamente siempre en quien '
                'baja.',
          ),
          RevealBlock(
            prompt: 'Paras junto al bordillo y un ciclista se acerca por '
                'detrás. ¿Cómo bajas?',
            answer: 'Antes de abrir la puerta, mira por encima del hombro '
                'y por el espejo, deja pasar al ciclista y abre la puerta '
                'solo de forma controlada y con la mano más alejada. El '
                'llamado «gesto holandés» — abrir la puerta con la mano '
                'derecha — gira tu tronco automáticamente hacia atrás y '
                'te obliga a mirar. Ciclistas y patinetes pasan muy '
                'pegados al vehículo y no cuentan con una puerta que se '
                'abre.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Calzado y superficie',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Recomendación de la BG Verkehr',
            text: 'Calzado que envuelva el pie y sea antideslizante. Nada '
                'de zapatos abiertos o desgastados. El calzado de '
                'seguridad que cubre el tobillo sujeta justo la '
                'articulación que se tuerce al bajar.',
          ),
          ParagraphBlock(
            'Antes de bajar, fíjate un momento en la superficie: '
            'bordillo, pendiente, hojas, humedad, hielo, gravilla. Con '
            'nieve y hielo, mantén libres asideros y escalones. Si es '
            'posible, para en llano y con luz.',
          ),
          ChecklistBlock(
            title: 'Antes de bajar',
            items: [
              'Calzado firme y antideslizante puesto',
              'Superficie comprobada — bordillo, pendiente, humedad, '
                  'hielo',
              'Manos libres, objetos dejados dentro',
              'Tráfico comprobado por el hombro y por el espejo',
              'Estribos limpios y despejados',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Levantar y transportar correctamente',
        blocks: [
          ParagraphBlock(
            'La espalda es el segundo riesgo de baja más frecuente '
            'después de las caídas. Y a diferencia de una caída, la '
            'lesión de disco no ocurre en un día — se produce por miles '
            'de levantamientos mal hechos.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/lift01_nah.svg',
              title: '1 · La carga pegada al cuerpo',
              caption: 'Acércate al paquete antes de levantarlo. Cada '
                  'centímetro de distancia al cuerpo multiplica la carga '
                  'sobre los discos intervertebrales.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift02_hocke.svg',
              title: '2 · Ponerse en cuclillas',
              caption: 'Dobla las rodillas y ponte en cuclillas en vez de '
                  'inclinarte hacia delante desde la cadera. La fuerza '
                  'viene de las piernas — son el músculo más potente que '
                  'tienes.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift03_ruecken.svg',
              title: '3 · Mantener la espalda recta',
              caption: 'Mantén la espalda recta y la mirada al frente '
                  'mientras te incorporas con las piernas. Una espalda '
                  'curvada bajo carga es la postura clásica de la hernia '
                  'discal.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift04_drehen.svg',
              title: '4 · No girar el tronco — mover los pies',
              caption: 'Nunca gires el tronco con la carga. Mueve en su '
                  'lugar los pies y gira todo el cuerpo. Levantar y girar '
                  'a la vez es la combinación más peligrosa para la '
                  'columna.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: '¿Cuánto es demasiado peso?',
        blocks: [
          ParagraphBlock(
            'La ley no fija límites de kilos concretos — lo decisivo es '
            'la combinación de peso, postura, frecuencia y entorno. En la '
            'práctica, sin embargo, se han asentado valores '
            'orientativos.',
          ),
          FactsBlock([
            FactItem('aprox. 25 kg', 'orientación para levantar de forma '
                'ocasional (hombres)'),
            FactItem('aprox. 15 kg', 'orientación para levantar de forma '
                'ocasional (mujeres)'),
            FactItem('por encima', 'usar medios auxiliares o llevarlo '
                'entre dos'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Normativa sobre manipulación manual de cargas',
            text: 'El empresario debe evitar en lo posible el '
                'levantamiento y transporte manual y poner a disposición '
                'medios auxiliares adecuados. Tú, a su vez, tienes que '
                'usarlos — no están ahí de adorno.',
          ),
          DoDontBlock(
            doTitle: 'Transportar bien',
            dos: [
              'Usar carretilla o caja rodante en vez de hacer dos viajes',
              'Llevar entre dos los envíos voluminosos',
              'Mantener libre el campo de visión — no mirar por encima '
                  'de la pila',
              'Antes de levantar, definir el recorrido y el punto donde '
                  'lo dejarás',
            ],
            dontTitle: 'Transportar mal',
            donts: [
              'Espalda curvada y brazos estirados',
              'Girar el tronco con la carga',
              'Coger impulso y levantar de golpe',
              'Llevar torres que te tapan la vista del camino',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Tropiezos, resbalones y caídas en el camino',
        blocks: [
          ParagraphBlock(
            'Tropezar, resbalar y caerse es la causa de lesión más '
            'frecuente en el reparto — más que cualquier accidente de '
            'tráfico. Y casi siempre ocurre en los últimos metros entre '
            'el vehículo y la puerta del domicilio.',
          ),
          FactsBlock([
            FactItem('N.º 1', 'tipo de accidente más frecuente en el '
                'reparto'),
            FactItem('últimos 30 m', 'entre el vehículo y la puerta — el '
                'tramo más peligroso'),
          ]),
          BulletsBlock([
            'Llevar calzado firme y antideslizante — todos los días, '
                'también en verano',
            'Con suelo resbaladizo, dar pasos cortos y apoyar todo el '
                'pie',
            'Mirar también al camino, no solo al paquete o al móvil',
            'De noche, usar linterna o la luz del móvil para el camino',
            'Recordar los puntos con riesgo de tropiezo conocidos de la '
                'ruta',
          ]),
          RevealBlock(
            prompt: 'Caso práctico: llevas dos paquetes uno encima del '
                'otro hasta una puerta con tres escalones. ¿Cuál es aquí '
                'el problema real?',
            answer: 'No ves ni tus propios pies ni el borde de los '
                'escalones. Una escalera sin visión del peldaño es la '
                'situación clásica de caída — y con las manos llenas no '
                'puedes agarrarte al pasamanos ni amortiguar la caída. Lo '
                'correcto: llevarlos de uno en uno, mantener la pila tan '
                'baja que veas los escalones, o usar la carretilla. Hacer '
                'dos viajes cuesta 40 segundos.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tomarse en serio las lesiones pequeñas',
        blocks: [
          ParagraphBlock(
            'Una espalda cargada o un pie torcido empeoran si sigues. Una '
            'nimiedad se convierte en semanas en una baja de verdad — y a '
            'posteriori muchas veces ya no se puede demostrar la relación '
            'con el trabajo.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Documentar te protege',
            text: 'Toda lesión debe anotarse en el libro de primeros '
                'auxilios — también la pequeña. Si necesitas atención '
                'médica tras un accidente de trabajo, acudes al médico '
                'especialista designado. Sin documentación, el '
                'reconocimiento posterior como accidente laboral es '
                'difícil.',
          ),
          RevealBlock(
            prompt: '¿Por qué deberías comunicar de inmediato las '
                'molestias pequeñas — aunque puedas seguir trabajando?',
            answer: 'Primero, por lo médico: un problema de ligamentos '
                'sin tratar cura peor y vuelve. Segundo, por lo jurídico: '
                'solo lo documentado cuenta después como accidente '
                'laboral. Tercero, por todos: solo los incidentes '
                'comunicados muestran dónde hay que mejorar un escalón, '
                'un asidero o un procedimiento en la empresa. Comunicar '
                'es fortaleza, no debilidad.',
          ),
          ChecklistBlock(
            title: 'Esto me llevo del módulo 7',
            items: [
              'Bajo de espaldas, con la cara hacia el vehículo',
              'Mantengo siempre tres puntos de apoyo (2 manos + 1 pie)',
              'Nunca salto desde la cabina ni desde la zona de carga',
              'Dejo los objetos antes de bajar',
              'Miro por encima del hombro antes de abrir la puerta',
              'Levanto con las piernas y no giro el tronco con carga',
              'Uso medios auxiliares en vez de hacer heroicidades',
              'Comunico cada lesión, también la pequeña',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M8
  SafetyChapterContent(
    id: 'm8',
    title: 'En la puerta: perros, personas y entorno',
    summary: 'Actuar con seguridad en el punto de entrega — con animales, '
        'personas y el entorno',
    asset: 'assets/academy/driving/m08_haustuer.svg',
    slides: [
      SafetySlide(
        title: 'El punto de entrega: terreno ajeno',
        blocks: [
          ParagraphBlock(
            'En cuanto sales del vehículo pisas un terreno ajeno que no '
            'conoces y que nadie ha asegurado para ti: caminos '
            'desconocidos, losas sueltas, escaleras oscuras, animales y '
            'personas de cualquier humor.',
          ),
          FactsBlock([
            FactItem('120+', 'propiedades ajenas por ruta'),
            FactItem('30 m', 'de recorrido a pie de media por parada'),
            FactItem('0', 'de ellas están preparadas para ti'),
          ]),
          ParagraphBlock(
            'Por eso, en el punto de entrega rige la misma actitud básica '
            'que al volante: primero mirar, después actuar. Y en caso de '
            'duda: no entregar. Un envío que no llega es un trámite — una '
            'lesión es una baja.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Valorar bien a los perros',
        asset: 'assets/academy/driving/m08b_hund.svg',
        blocks: [
          ParagraphBlock(
            'Los perros están entre las causas de lesión más frecuentes '
            'entre repartidores. Desde el punto de vista del perro eres '
            'un intruso que se mueve rápido, huele a desconocido y lleva '
            'un objeto grande — su reacción es defensa, no maldad.',
          ),
          BulletsBlock([
            'No mirarlo fijamente a los ojos — para el perro es una '
                'amenaza',
            'No salir corriendo ni levantar la voz, sino quedarse quieto '
                'con calma',
            'Ponerse de lado hacia el perro, no de frente',
            'Brazos tranquilos pegados al cuerpo, sin movimientos '
                'bruscos',
            'El paquete puede servir de barrera entre el perro y tú',
            'Retroceder despacio sin perder de vista al perro',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'La calma es tu mejor equipo',
            text: 'Un perro reacciona al movimiento y al tono de voz, no '
                'a los argumentos. Despacio, en voz baja y de lado — esa '
                'es toda la técnica.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Cuando la cosa se pone seria',
        blocks: [
          RevealBlock(
            prompt: 'Caso práctico: en la verja del jardín hay un perro '
                'grande ladrando. La verja solo está entornada y el '
                'cliente ha escrito «el perro es bueno» en las '
                'indicaciones de entrega. ¿Qué haces?',
            answer: 'No entras en la propiedad. Una indicación de entrega '
                'no es una autorización de seguridad — el cliente conoce '
                'a su perro con la familia, no con un hombre desconocido '
                'que lleva un paquete. Lo correcto: apartarte de la '
                'verja, intentar llamar al timbre o por teléfono, dejar '
                'el envío sin entregar de forma documentada y anotar el '
                'aviso en el sistema para que el siguiente compañero esté '
                'prevenido. Un mordisco te cuesta semanas — el envío le '
                'cuesta al cliente un día.',
          ),
          DoDontBlock(
            doTitle: 'Bien',
            dos: [
              'Antes de abrir la verja, atender a ruidos de perro y a los '
                  'comederos',
              'Con un perro suelto, no entrar siquiera',
              'Dejar avisos para los compañeros en el sistema',
              'Ante mordisco o arañazo: comunicarlo de inmediato y '
                  'acudir al médico',
            ],
            dontTitle: 'Mal',
            donts: [
              'Acariciar o dar de comer al perro',
              'Pasar por encima del animal para llegar a la puerta',
              'Salir corriendo o golpear al perro con el paquete',
              'Fiarse del «no hace nada»',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Todo mordisco de perro va al médico',
            text: 'Incluso un mordisco o arañazo pequeño puede '
                'infectarse. Limpiar de inmediato, acudir al médico, '
                'anotarlo en el libro de primeros auxilios y comunicarlo '
                '— por muy inofensivo que parezca.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Caminos seguros en la propiedad',
        asset: 'assets/academy/driving/m08c_stolperfallen.svg',
        blocks: [
          ParagraphBlock(
            'El camino hasta la puerta no es un puesto de trabajo que '
            'alguien haya revisado para ti. Usa los caminos señalizados y '
            'no cortes por césped mojado, losas sueltas o taludes '
            'empinados.',
          ),
          BulletsBlock([
            'Mangueras de jardín, cables y celosías en el suelo',
            'Losas sueltas o hundidas',
            'Hojas mojadas, musgo y algas en caminos sombríos',
            'Grava y gravilla sobre losas lisas',
            'Escaleras sin iluminación y sin pasamanos',
            'Tragaluces, alcantarillas abiertas y respiraderos de sótano',
            'Juguetes, bicicletas y contenedores en medio',
          ]),
          FactsBlock([
            FactItem('últimos 30 m', 'aquí ocurren la mayoría de las '
                'caídas'),
            FactItem('1 mano', 'debería quedar libre para el pasamanos'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Cortar cuesta más de lo que ahorra',
            text: 'El atajo por el césped ahorra diez segundos. Una caída '
                'ahí cuesta de media 24 días de baja.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Escaleras, sótanos y oscuridad',
        blocks: [
          ParagraphBlock(
            'En las escaleras y los patios interiores se juntan dos '
            'cosas: mala luz y alturas de peldaño desconocidas. Ambas '
            'juntas son la situación de caída más frecuente fuera del '
            'vehículo.',
          ),
          BulletsBlock([
            'Mantener siempre una mano libre para el pasamanos',
            'Encender la luz en vez de pensar «así también se puede»',
            'Usar linterna o la luz del móvil — pero sin mirar la '
                'pantalla mientras caminas',
            'En escaleras, mantener la pila tan baja que veas los '
                'peldaños',
            'Atención a las alturas de peldaño desiguales en edificios '
                'antiguos',
          ]),
          RevealBlock(
            prompt: 'Tienes que entregar en un pasillo de sótano oscuro. '
                'El interruptor de la luz no funciona. ¿Cuál es la '
                'decisión correcta?',
            answer: 'No entrar. Un pasillo sin luz con escalones '
                'desconocidos, respiraderos y trastos no es un sitio en '
                'el que entrar con un paquete en la mano — y en caso de '
                'apuro nadie sabe que estás ahí. Lo correcto: llamar al '
                'timbre del cliente, entregar en un lugar seguro o dejar '
                'el envío sin entregar de forma documentada. La luz del '
                'móvil no sustituye a la iluminación, porque para ella '
                'necesitas una mano que te hace falta en el pasamanos.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Personas: desescalar en vez de ganar',
        blocks: [
          ParagraphBlock(
            'Para el cliente eres la cara de todo un grupo empresarial — '
            'y por eso a veces recibes un enfado que no va contigo. '
            'Mantenerte amable, tranquilo y profesional no es solo '
            'cortesía: es tu medida de seguridad más eficaz.',
          ),
          StepsBlock([
            'Voz tranquila, ritmo de habla pausado, postura corporal '
                'abierta',
            'Escuchar y nombrar la petición en vez de contradecir de '
                'inmediato',
            'Ceñirse a lo que tú puedes hacer — no prometer nada en '
                'nombre de otros',
            'Mantener la distancia: al menos el largo de un brazo, con '
                'la vía de salida libre',
            'Si escala: terminar la conversación y volver al vehículo',
          ]),
          RevealBlock(
            prompt: 'Alguien alza la voz, se te acerca mucho y bloquea el '
                'camino hacia tu vehículo. ¿Qué rige?',
            answer: 'Tu seguridad está por encima de cualquier entrega. '
                'No discutir, no querer tener razón, no provocar contacto '
                'físico. Retroceder, crear distancia, exigir distancia en '
                'voz alta y clara y, en caso de emergencia, salir a un '
                'lugar público y llamar a la policía. Después: comunicar '
                'el incidente para que la parada quede marcada para los '
                'compañeros. Ningún paquete justifica un enfrentamiento '
                'físico.',
          ),
        ],
      ),
      SafetySlide(
        title: 'El vehículo como lugar seguro',
        blocks: [
          ParagraphBlock(
            'Tu vehículo es herramienta, almacén y refugio. Cuando lo '
            'dejas, tiene que quedar seguro — y si te sientes amenazado, '
            'es el lugar al que vuelves.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 14 Abs. 2 StVO',
            text: 'Quien abandona su vehículo debe adoptar las medidas '
                'necesarias para evitar accidentes y perturbaciones del '
                'tráfico, y asegurarlo contra un uso no autorizado.',
          ),
          DoDontBlock(
            doTitle: 'Bien estacionado',
            dos: [
              'Motor apagado, llave contigo, vehículo cerrado',
              'En pendiente, freno de mano bien puesto y ruedas giradas',
              'Intermitentes de emergencia al parar en zona de tráfico',
              'Cerrar la puerta de carga cuando estés fuera del campo de '
                  'visión',
            ],
            dontTitle: 'Arriesgado',
            donts: [
              'Motor en marcha, puerta abierta — «así es más rápido»',
              'Llave puesta mientras estás en la puerta del cliente',
              'Estacionar en cuesta sin girar las ruedas',
              'Dejar la zona de carga abierta en zonas concurridas',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de control en el punto de entrega',
        blocks: [
          ChecklistBlock(
            title: 'En cada parada',
            items: [
              'Motor apagado, llave conmigo, vehículo cerrado',
              'Asegurado en pendiente, ruedas giradas',
              'Antes de entrar he mirado si hay perros y avisos',
              'He usado los caminos señalizados, sin atajos',
              'Una mano libre para el pasamanos',
              'Pila tan baja que veo los escalones',
              'Con oscuridad me he procurado luz',
              'Ante agresión: distancia, retirada, aviso',
              'Ante mordisco, caída o casi accidente: comunicado',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M9
  SafetyChapterContent(
    id: 'm9',
    title: 'Emergencia y actuación tras un accidente',
    summary: 'Actuar con calma, correctamente y con seguridad jurídica en '
        'caso de emergencia',
    asset: 'assets/academy/driving/m09_notfall.svg',
    slides: [
      SafetySlide(
        title: 'Señalizar — avisar — auxiliar',
        blocks: [
          ParagraphBlock(
            'Tras un accidente o ante una avería rige siempre el mismo '
            'orden: primero asegurar el lugar, después la llamada de '
            'emergencia, después los primeros auxilios. Ese orden no es '
            'un formalismo — evita el segundo accidente, en el que los '
            'que ayudan se convierten en víctimas.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Recuerda el orden',
            text: 'Señalizar → avisar → auxiliar. Quien corre de '
                'inmediato hacia el herido sin señalizar acaba atropellado '
                'él mismo en una carretera comarcal o en la autopista.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 34 StVO — tras un accidente de tráfico',
            text: 'Debes detenerte sin demora, asegurar el tráfico, en '
                'caso de daño leve retirar el vehículo de la zona de '
                'peligro, auxiliar a los heridos y permitir que se '
                'identifiquen tu persona y tu vehículo.',
          ),
          ParagraphBlock(
            'Y muy importante: calma. Los diez primeros segundos tras un '
            'golpe deciden los diez minutos siguientes. Respira una vez y '
            'después ve por orden.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Los cinco primeros pasos',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/acc01_absichern.svg',
              title: '1 · Intermitentes de emergencia',
              caption: 'Nada más detenerte, enciende los intermitentes de '
                  'emergencia — son la primera señal para todos los que '
                  'vienen por detrás. De noche, deja además encendidas '
                  'las luces de posición.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc02_warnweste.svg',
              title: '2 · Ponerse el chaleco',
              caption: 'El chaleco te lo pones antes de bajar — no '
                  'después. Por eso va a mano en la cabina y no atrás, en '
                  'la zona de carga.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc03_dreieck.svg',
              title: '3 · Colocar el triángulo',
              caption: 'Camina por detrás del quitamiedos o por el borde '
                  'de la calzada, en sentido contrario a la marcha, y '
                  'coloca el triángulo a suficiente distancia — en '
                  'poblado unos 50 m, fuera de poblado 100 m, en '
                  'autopista 150–200 m.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc04_notruf.svg',
              title: '4 · Llamar al 112',
              caption: 'Di dónde estás, qué ha pasado, cuántos heridos '
                  'hay y qué lesiones ves — y no cuelgues hasta que la '
                  'central no tenga más preguntas.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc05_erstehilfe.svg',
              title: '5 · Prestar primeros auxilios',
              caption: 'Hablar a la persona, comprobar la respiración, '
                  'detener hemorragias, abrigar y quedarse con el herido. '
                  'También las medidas sencillas ayudan — no hacer nada '
                  'es la única decisión equivocada.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Intermitentes, chaleco, triángulo',
        blocks: [
          TableBlock(
            headers: ['Zona', 'Distancia del triángulo'],
            rows: [
              ['En poblado', 'aprox. 50 m'],
              ['Fuera de poblado', 'aprox. 100 m'],
              ['Autopista', 'aprox. 150–200 m'],
              ['Antes de un cambio de rasante o curva', 'delante, no '
                  'detrás'],
            ],
          ),
          ParagraphBlock(
            'Lo decisivo no es el valor exacto en metros, sino que el '
            'tráfico que viene detrás te vea a tiempo. Antes de un cambio '
            'de rasante o una curva, el triángulo va delante — si no, '
            'solo se ve cuando ya es tarde.',
          ),
          FactsBlock([
            FactItem('1', 'chaleco reflectante es obligatorio en el '
                'vehículo (§ 53a StVZO)'),
            FactItem('antes', 'ponte el chaleco antes de bajar'),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Caminar por detrás del quitamiedos',
            text: 'En autopista y carretera comarcal nunca vayas por la '
                'calzada a colocar el triángulo, sino por detrás del '
                'quitamiedos o por el arcén — en sentido contrario a la '
                'marcha, para ver el tráfico.',
          ),
          DoDontBlock(
            doTitle: 'Bien en el lugar del accidente',
            dos: [
              'Intermitentes de emergencia de inmediato, chaleco antes '
                  'de bajar',
              'Caminar por detrás del quitamiedos, en sentido contrario '
                  'a la marcha',
              'Colocar el triángulo antes del cambio de rasante o de la '
                  'curva',
              'Tras señalizar, ponerte tú mismo a salvo',
            ],
            dontTitle: 'Errores típicos',
            donts: [
              'Bajar sin chaleco y mirar «solo un momento»',
              'Caminar por la calzada hasta el triángulo',
              'Quedarse parado entre los vehículos',
              'Hacer fotos primero en vez de señalizar',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Corredor de emergencia',
        blocks: [
          ParagraphBlock(
            'El corredor de emergencia se forma en cuanto el tráfico se '
            'ralentiza — no cuando ya se ven las luces azules. Entonces '
            'suele ser tarde, porque ya nadie tiene sitio.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 11 Abs. 2 StVO',
            text: 'En autopistas y carreteras fuera de poblado con al '
                'menos dos carriles por sentido, el corredor se forma '
                'siempre entre el carril más a la izquierda y el '
                'inmediatamente contiguo a su derecha — con independencia '
                'de cuántos carriles haya.',
          ),
          FactsBlock([
            FactItem('izq. + 1', 'así se forma el corredor'),
            FactItem('desde 200 €', 'de multa si no se forma el '
                'corredor'),
            FactItem('2 puntos', 'más, por regla general, 1 mes de '
                'retirada del permiso'),
          ]),
          RevealBlock(
            prompt: 'En una autopista de tres carriles el tráfico está '
                'parado. ¿Dónde está exactamente el corredor de '
                'emergencia — y puedes circular por él si vas a salir en '
                'la próxima salida?',
            answer: 'Siempre entre el carril izquierdo y el carril '
                'central — nunca entre el central y el derecho, y nunca '
                'por el arcén. Y no: el corredor de emergencia es '
                'exclusivamente para los vehículos de emergencia. Quien '
                'lo usa para llegar antes a la salida paga una multa '
                'parecida a la de quien no lo forma y se arriesga a la '
                'retirada del permiso. El arcén no es una alternativa — '
                'por ahí circulan los servicios de rescate cuando el '
                'corredor está bloqueado.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Cómo llamar bien al 112',
        blocks: [
          FactsBlock([
            FactItem('112', 'emergencias en toda Europa, también sin '
                'saldo'),
            FactItem('110', 'policía — en caso de daños solo materiales'),
          ]),
          StepsBlock([
            '¿Dónde ha ocurrido? — localidad, carretera, punto '
                'kilométrico, sentido de la marcha, puntos destacados',
            '¿Qué ha ocurrido? — tipo de accidente, vehículos '
                'implicados, peligros como fuga de combustible',
            '¿Cuántos heridos hay?',
            '¿Qué lesiones? — inconsciente, sangrando, atrapado',
            'Esperar a las repreguntas — la central termina la '
                'conversación',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Prestar auxilio es obligatorio',
            text: 'La omisión del deber de socorro es un delito (§ 323c '
                'StGB). Se espera lo que te resulte exigible — llamar a '
                'emergencias, señalizar, hablar con el herido, '
                'acompañarlo. Nadie exige que te pongas tú mismo en '
                'peligro.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Primeros auxilios: lo que de verdad cuenta',
        blocks: [
          ParagraphBlock(
            'No hace falta que seas sanitario. Las medidas decisivas '
            'puede hacerlas cualquiera — y son las que deciden entre la '
            'vida y la muerte antes de que llegue la ambulancia.',
          ),
          StepsBlock([
            'Hablarle y sacudirle con cuidado el hombro — ¿reacciona la '
                'persona?',
            'Sin reacción: liberar las vías respiratorias, extender la '
                'cabeza hacia atrás, comprobar la respiración 10 '
                'segundos',
            'Respiración normal: posición lateral de seguridad, '
                'abrigarla y quedarse con ella',
            'Sin respiración normal: empezar de inmediato con las '
                'compresiones torácicas y no parar',
            'Hemorragia intensa: comprimir directamente y colocar un '
                'vendaje compresivo',
          ]),
          FactsBlock([
            FactItem('100–120', 'compresiones por minuto'),
            FactItem('5–6 cm', 'profundidad de compresión en adultos'),
            FactItem('10 s', 'bastan para comprobar la respiración'),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Casco y personas atrapadas',
            text: 'Un casco de moto solo se quita si la persona no '
                'respira con normalidad — entonces no hay alternativa. A '
                'las personas atrapadas no las muevas, salvo que haya '
                'peligro inmediato por fuego.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Después de un golpe de chapa',
        blocks: [
          ParagraphBlock(
            'También con daños pequeños — una abolladura de maniobra, un '
            'espejo arrancado, un arañazo en un coche aparcado — vale el '
            'programa completo. El daño se comunica siempre, aunque '
            'parezca pequeño y nadie lo haya visto.',
          ),
          ChecklistBlock(
            title: 'Después de un golpe de chapa',
            items: [
              'Detenerse y asegurar el vehículo',
              'Intermitentes de emergencia y, si hace falta, chaleco y '
                  'triángulo',
              'Intercambiar datos o esperar al titular del vehículo',
              'Fotos desde varios ángulos, lugar, hora, matrícula',
              'Anotar testigos y sus datos de contacto',
              'No firmar ningún reconocimiento de culpa',
              'Comunicar el daño en la empresa — el mismo día',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Nunca seguir sin más',
            text: 'Quien se aleja del lugar del accidente sin permitir '
                'que se identifique su persona comete abandono del lugar '
                'del accidente (§ 142 StGB) — un delito castigado con '
                'multa o prisión, también por una abolladura pequeña.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: maniobrando rozas el retrovisor de un '
                'coche aparcado. No hay nadie. ¿Basta con una nota bajo '
                'el limpiaparabrisas?',
            answer: 'No. Jurídicamente una nota no cuenta como '
                'identificación suficiente — puede volarse, mojarse o ser '
                'retirada. Lo correcto es: esperar un tiempo razonable en '
                'el lugar (según la situación se toman unos 30 minutos '
                'como valor orientativo) y, si no aparece nadie, informar '
                'a la policía y declarar allí el daño. Dejar además una '
                'nota es buena práctica, pero no sustituye ni la espera '
                'ni el aviso.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Mantener la calma, comunicar, aprender',
        blocks: [
          ParagraphBlock(
            'Respirar hondo, ordenar la situación, informar al '
            'planificador y a la empresa. Un aviso honesto y rápido '
            'siempre es mejor que ocultar — te protege a ti, protege a la '
            'empresa, y de cada incidente aprendemos para la próxima '
            'ruta.',
          ),
          ChecklistBlock(
            title: 'Esto me llevo del módulo 9',
            items: [
              'Conozco el orden: señalizar, avisar, auxiliar',
              'Me pongo el chaleco antes de bajar',
              'Coloco el triángulo a suficiente distancia',
              'Formo el corredor de emergencia entre el carril izquierdo '
                  'y el contiguo en cuanto el tráfico se ralentiza',
              'Conozco los cinco datos de la llamada al 112',
              'Sé que no hacer nada es la única decisión equivocada',
              'Comunico cada daño el mismo día — también la abolladura '
                  'pequeña',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M10
  SafetyChapterContent(
    id: 'm10',
    title: 'Resumen y compromiso personal',
    summary: 'Afianzar lo aprendido y convertirlo en una actitud personal',
    asset: 'assets/academy/driving/m10_selbstverpflichtung.svg',
    slides: [
      SafetySlide(
        title: 'Tus 7 reglas fundamentales',
        blocks: [
          BulletsBlock([
            'Anticipar gana a reaccionar rápido',
            'La distancia y una velocidad adaptada te dan siempre un '
                'margen',
            'Al dar marcha atrás: bajar, mirar, despacio (GOAL)',
            'Móvil y distracciones solo con el vehículo parado y el '
                'motor apagado',
            'Tomarse en serio el cansancio y la presión de tiempo — la '
                'seguridad antes que el plan',
            'Bajar, levantar y caminar bien — tu cuerpo es tu '
                'herramienta',
            'En una emergencia: señalizar, avisar, auxiliar',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Si solo te llevas una regla',
            text: 'Tómate el tiempo que necesites. Casi todos los '
                'accidentes en el reparto surgen en el momento en que '
                'alguien quiso ahorrarse dos segundos.',
          ),
          DoDontBlock(
            doTitle: 'Así es un día seguro',
            dos: [
              'Vuelta al vehículo, carga asegurada, cinturón puesto',
              'Dos segundos de distancia, mirada lejos por delante',
              'Antes de cada maniobra marcha atrás, bajar y mirar',
              'Móvil en el soporte, pausa si hay cansancio',
              'Bajar de espaldas con tres puntos de apoyo',
            ],
            dontTitle: 'Los cinco atajos más caros',
            donts: [
              'Saltarse la vuelta al vehículo «solo por hoy»',
              'No volver a asegurar la carga después de recargar',
              'Mirar un momento la pantalla porque la calle está libre',
              'Saltar desde la zona de carga porque es más rápido',
              'No comunicar un daño de maniobra',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Las cifras que deberían quedarse',
        blocks: [
          FactsBlock([
            FactItem('2 s', 'distancia mínima'),
            FactItem('2 + 1', 'puntos de apoyo al bajar'),
            FactItem('112', 'emergencias con heridos'),
          ]),
          TableBlock(
            headers: ['Cifra', 'Significado'],
            rows: [
              ['2 segundos', 'distancia mínima, con calzada mojada 3+'],
              ['18 / 40 m', 'distancia de detención a 30 / 50 km/h'],
              ['28 m', 'a ciegas con 2 s de mirada al móvil a 50 km/h'],
              ['89 m', 'microsueño de 4 s a 80 km/h'],
              ['0,8 g', 'fuerza de sujeción hacia delante para la carga'],
              ['2 + 1', 'puntos de apoyo al subir y bajar'],
              ['70 %', 'de los daños se producen maniobrando'],
              ['112', 'emergencias con heridos'],
            ],
          ),
          ParagraphBlock(
            'Estas ocho cifras son el núcleo duro de la formación. Quien '
            'las tiene en la cabeza toma la decisión correcta también '
            'cuando no hay tiempo para pensar.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tu autoevaluación personal',
        asset: 'assets/academy/driving/m10b_selbstcheck.svg',
        blocks: [
          ParagraphBlock(
            'Repasa esta lista una vez con honestidad — no para la '
            'empresa, sino para ti. Cada casilla sin marcar es algo '
            'concreto que puedes cambiar mañana.',
          ),
          ChecklistBlock(
            title: 'Mi autoevaluación de seguridad',
            items: [
              'Doy la vuelta al vehículo cada mañana, aunque haya prisa',
              'Vuelvo a asegurar la carga cuando la zona de carga se '
                  'vacía',
              'Mantengo dos segundos de distancia y lo compruebo con un '
                  'punto fijo',
              'Bajo y miro antes de cada maniobra marcha atrás',
              'No toco el móvil durante la marcha',
              'Paro cuando me entra el cansancio',
              'Bajo siempre de espaldas con tres puntos de apoyo',
              'Levanto con las piernas y uso medios auxiliares',
              'Comunico daños, casi accidentes y lesiones',
              'Aviso cuando un plan no se puede hacer con seguridad',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Caso práctico: el día en que todo se junta',
        blocks: [
          RevealBlock(
            prompt: 'Caso práctico: viernes, lluvia, 190 paradas. '
                'Empiezas 25 minutos tarde, la zona de carga está sin '
                'ordenar desde el turno de noche, el móvil te suena sin '
                'parar y a las 16:00 te das cuenta de que no has comido '
                'nada desde el desayuno. ¿Cuál es ahora el orden '
                'correcto?',
            answer: 'Para y ordena primero la zona de carga — eso lo '
                'recuperas en un cuarto de hora y te ahorras 190 '
                'búsquedas. Después: móvil en silencio, en el soporte, '
                'las llamadas en la próxima pausa. Luego diez minutos '
                'para comer y beber, porque a partir de ahora tu atención '
                'caería cada hora. Y después un aviso honesto a '
                'planificación de que hoy el plan no sale completo. Lo '
                'que no haces: intentar recuperar el tiempo en la '
                'carretera, saltarte pausas, acortar las maniobras. El '
                'día ya no se salva — tu espalda, tu permiso y tu '
                'vehículo, sí.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'El verdadero examen',
            text: 'Conducir con seguridad un buen día lo hace cualquiera. '
                'La diferencia se ve el día en que todo sale mal a la '
                'vez.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tu compromiso personal',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Tu promesa',
            text: '«Conduzco de forma que todos lleguen sanos a casa — yo '
                'incluido.»',
          ),
          ParagraphBlock(
            'La seguridad no es un libro de normas, sino tu decisión '
            'diaria. Nadie está a tu lado cuando a las seis de la mañana '
            'decides si das la vuelta al vehículo, ni cuando a las siete '
            'de la tarde decides si te bajas otra vez antes de dar marcha '
            'atrás. Precisamente eso hace que esas decisiones sean tan '
            'importantes.',
          ),
          ChecklistBlock(
            title: 'Me comprometo a',
            items: [
              'Cumplir las reglas también cuando nadie mira',
              'Tomarme los segundos que cuesta la seguridad',
              'Comunicar con honestidad en vez de ocultar',
              'Ayudar a los compañeros nuevos a hacerlo bien desde el '
                  'principio',
              'Volver sano a casa cada tarde',
            ],
          ),
        ],
      ),
    ],
  ),
];
