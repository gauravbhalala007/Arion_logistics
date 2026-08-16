// lib/data/safety_training/privacy_content_es.dart
//
// Contenidos de la formación en protección de datos — versión en español.
// La estructura es idéntica a la versión alemana (master,
// privacy_content_de.dart): capítulos ds1–ds6, las mismas diapositivas,
// los mismos bloques y los mismos valores. Cualquier cambio estructural
// se hace primero en el archivo alemán y se traslada después aquí.
//
// Las referencias legales se mantienen en su forma alemana (Art. 5 DSGVO,
// § 26 BDSG, etc.), con una breve explicación en español allí donde el
// texto lo requiere. Para este tema no hay ilustraciones, por eso
// `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> privacyContentEs = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ds1',
    title: 'Por qué la protección de datos te afecta',
    summary: 'Los datos personales en el día a día del reparto y los '
        'principios del Art. 5 DSGVO (RGPD)',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Trabajas todo el día con datos ajenos',
        blocks: [
          ParagraphBlock(
            'La protección de datos suena a oficina, archivador y '
            'abogados. En realidad, casi nadie está tan cerca de los datos '
            'personales como tú. Desde el primer escaneo de la mañana '
            'hasta la última parada de la tarde tienes en tus manos '
            'nombres, direcciones y números de teléfono ajenos — y, '
            'además, fotos de las puertas de casas de otras personas.',
          ),
          ParagraphBlock(
            'Es dato personal cualquier información con la que se pueda '
            'identificar a una persona. No solo el nombre: también la '
            'combinación de dirección, hora y contenido del paquete dice '
            'algo sobre un ser humano. Precisamente por eso existen reglas '
            'para ello.',
          ),
          BulletsBlock([
            'Nombres de los destinatarios y direcciones en la etiqueta, el '
                'escáner y la lista',
            'Números de teléfono para contactar antes de la entrega',
            'Firmas en el escáner como confirmación de recepción',
            'Fotos como comprobante de entrega delante de la puerta',
            'Datos de localización del escáner y del vehículo',
            'Indicaciones sobre vecinos a los que has dejado un paquete',
            'Avisos como «Deja el paquete detrás del cubo de basura» — '
                'también eso es una información sobre la situación de '
                'vivienda de una persona',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'En pocas palabras',
            text: 'Todo lo que averiguas sobre un destinatario lo has '
                'averiguado únicamente porque le llevas el paquete. Para '
                'cualquier otra cosa no has recibido esa información.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tres principios que cuentan en el día a día',
        blocks: [
          ParagraphBlock(
            'El Art. 5 DSGVO establece seis principios. Tres de ellos '
            'deciden prácticamente cada día si actúas bien o mal. En '
            'lenguaje sencillo:',
          ),
          TableBlock(
            headers: ['Principio', 'Qué significa para ti'],
            rows: [
              [
                'Limitación de la finalidad',
                'Usar los datos solo para el fin por el que los has '
                    'recibido: la entrega. No para asuntos privados.',
              ],
              [
                'Minimización de datos',
                'Recoger y mostrar solo lo necesario. Ninguna foto de más '
                    'de lo necesario, ninguna lista más larga de lo '
                    'necesario.',
              ],
              [
                'Confidencialidad',
                'Lo que ves se queda contigo y en la empresa. No en el '
                    'grupo de chat, no en la mesa de la cocina, no en la '
                    'red.',
              ],
            ],
          ),
          ParagraphBlock(
            'A ello se suman la exactitud (corregir los datos erróneos en '
            'lugar de arrastrarlos), la limitación del plazo de '
            'conservación (no guardar nada más tiempo del necesario) y la '
            'responsabilidad proactiva — este último punto afecta a la '
            'empresa y es la razón de esta formación.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'La base legal',
            text: 'El Art. 5 apdo. 1 DSGVO exige, entre otras cosas, la '
                'limitación de la finalidad (lit. b), la minimización de '
                'datos (lit. c) y la integridad y confidencialidad '
                '(lit. f). Estos principios rigen para todo aquel que '
                'maneje datos personales por encargo de la empresa — es '
                'decir, también para ti en la ruta.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Por qué existe esta formación',
        blocks: [
          ParagraphBlock(
            'El DSGVO no dice en ningún sitio literalmente «los empleados '
            'deben ser formados». Aun así lo exige — solo que por tres '
            'vías distintas. Por eso estás aquí, y por eso se documenta la '
            'finalización.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'De dónde se deriva la obligación de formación',
            text: 'El Art. 32 DSGVO obliga a la empresa a adoptar medidas '
                'técnicas y organizativas para la seguridad del '
                'tratamiento — los empleados formados son una de esas '
                'medidas. El Art. 39 apdo. 1 lit. b DSGVO menciona '
                'expresamente la sensibilización y la formación como tarea '
                'del delegado de protección de datos. Y el Art. 5 apdo. 2 '
                'DSGVO exige que la empresa pueda demostrar el '
                'cumplimiento — responsabilidad proactiva.',
          ),
          ParagraphBlock(
            'Las autoridades de control se fijan mucho en esto durante una '
            'inspección. La falta de formación de los empleados la valoran '
            'habitualmente como indicio de que las medidas eran '
            'insuficientes — sobre todo cuando ya ha ocurrido algo. Tras '
            'una brecha de datos, la primera pregunta es casi siempre: '
            '¿estaba la gente formada y podéis acreditarlo?',
          ),
          BulletsBlock([
            'Formación básica anual para todos — tu certificación vale '
                'doce meses',
            'Formación puntual cuando algo cambia o cuando ha ocurrido '
                'algo',
            'Instrucción de los nuevos empleados antes de su primer día '
                'por su cuenta',
            'Documentación del test y de la firma como prueba conforme al '
                'Art. 5 apdo. 2 DSGVO',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Dónde está la línea en el día a día',
        blocks: [
          RevealBlock(
            prompt: 'Caso práctico: en tu ruta hay un paquete para un '
                'futbolista conocido de la región. Por la tarde cuentas '
                'entre amigos en qué calle vive — nada más, ningún nombre '
                'en redes sociales, solo entre amigos. ¿Es eso una '
                'infracción de protección de datos?',
            answer: 'Sí. La dirección es un dato personal y la conoces '
                'exclusivamente por tu trabajo. Comunicarla a terceros '
                'vulnera la limitación de la finalidad (Art. 5 apdo. 1 '
                'lit. b DSGVO) y la confidencialidad (lit. f). El error '
                'más habitual es pensar que un círculo privado «no '
                'cuenta» — el DSGVO no pregunta cuán grande era tu '
                'público, sino si has revelado los datos para un fin '
                'ajeno. Y si uno de tus amigos lo cuenta a su vez, además '
                'ya no tienes ningún control.',
          ),
          DoDontBlock(
            doTitle: 'Correcto',
            dos: [
              'Usar los datos del destinatario solo para la entrega y '
                  'dejarlos después en el sistema',
              'Ante preguntas sobre un envío, remitir al dispatcher o a la '
                  'dirección de operaciones',
              'Sostener el escáner y la lista en papel de modo que '
                  'terceros no puedan leerlos',
              'Plantear las situaciones dudosas en vez de decidir por tu '
                  'cuenta',
            ],
            dontTitle: 'Incorrecto',
            donts: [
              'Contar direcciones o nombres en el entorno privado — '
                  'tampoco «solo entre amigos»',
              'Convertir a personas famosas o envíos llamativos en tema de '
                  'conversación',
              'Consultar datos de destinatarios por curiosidad, sin que '
                  'exista un encargo para ello',
              'Confiar en que «total, nadie se va a enterar»',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de control capítulo 1',
        blocks: [
          ParagraphBlock(
            'Repasa los puntos brevemente. Si dudas en alguno, vuelve una '
            'vez atrás — en el test aparecen exactamente estas '
            'situaciones.',
          ),
          ChecklistBlock(
            title: 'Esto me llevo del capítulo 1',
            items: [
              'Sé qué datos de mi ruta son datos personales',
              'Conozco la limitación de la finalidad, la minimización de '
                  'datos y la confidencialidad',
              'Sé que los datos de los destinatarios no pertenecen al '
                  'ámbito privado',
              'Sé por qué se documenta esta formación '
                  '(Art. 5 apdo. 2 DSGVO)',
              'Tengo claro que la formación se repite cada año',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ds2',
    title: 'Fotos y comprobantes de entrega',
    summary: 'Qué puede salir en la imagen, qué no — y dónde debe estar la '
        'foto',
    asset: '',
    slides: [
      SafetySlide(
        title: 'La foto tiene exactamente una finalidad',
        blocks: [
          ParagraphBlock(
            'La foto de entrega debe responder a una única pregunta: '
            '¿dónde está el paquete? Nada más. Todo lo que vaya más allá '
            'es más información de la necesaria — y, con ello, una '
            'infracción de la minimización de datos.',
          ),
          ParagraphBlock(
            'En la práctica esto significa: cámara hacia abajo, sobre el '
            'paquete, lo bastante cerca como para reconocer el lugar de '
            'depósito y lo bastante lejos de todo lo que muestre a '
            'personas o las haga identificables.',
          ),
          DoDontBlock(
            doTitle: 'Puede salir en la imagen',
            dos: [
              'El paquete en sí, en el lugar de depósito',
              'Un trozo de pared, puerta o escalera como referencia del '
                  'sitio',
              'El número de la casa, si es necesario para la asignación',
              'Con autorización de depósito: el lugar acordado',
            ],
            dontTitle: 'No puede salir en la imagen',
            donts: [
              'Personas — tampoco el destinatario, tampoco de espaldas',
              'Matrículas de vehículos aparcados',
              'Ventanas, balcones y vistas al interior de las viviendas',
              'Niños, mascotas, visitas o vecinos al fondo',
              'Placas con nombres de terceros, si no pertenecen al envío',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'La base legal',
            text: 'El Art. 5 apdo. 1 lit. c DSGVO exige la minimización de '
                'datos: los datos deben ser adecuados al fin y limitarse a '
                'lo necesario. Una foto que muestre personas, matrículas o '
                'interiores de viviendas va más allá del fin «comprobante '
                'de entrega». Además, cuando aparecen personas entra en '
                'juego el derecho a la propia imagen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dónde debe estar la foto — y dónde no',
        blocks: [
          ParagraphBlock(
            'Igual de importante que el contenido de la imagen es el lugar '
            'donde se guarda. La foto se crea en la app de trabajo y se '
            'queda ahí. No tiene nada que hacer en tu galería privada y '
            'mucho menos en un mensajero.',
          ),
          BulletsBlock([
            'Hacer la foto exclusivamente en la app de trabajo — no '
                'primero con la app de cámara y subirla después',
            'Ninguna copia en la galería privada, ninguna copia de '
                'seguridad en la nube del móvil privado',
            'Ningún envío por WhatsApp, Telegram, Signal o un grupo de '
                'chat de conductores',
            'No guardarte ninguna foto «por si acaso» — el comprobante '
                'está en el sistema',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'El error más frecuente',
            text: 'Fotografiar primero con la cámara normal y subir '
                'después la imagen a la app. Así la foto queda de forma '
                'permanente en tu galería privada — a menudo, además, en '
                'una nube en el extranjero. Eso es un tratamiento no '
                'permitido, aunque nunca se la enseñes a nadie.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Si al final sale alguien en la foto',
        blocks: [
          ParagraphBlock(
            'Pasa: la vecina sale por la puerta justo en el momento del '
            'disparo, o un niño cruza la imagen. No es ningún drama — '
            'siempre que actúes de inmediato.',
          ),
          StepsBlock([
            'Borrar la foto enseguida, antes de cerrar la parada',
            'Volver a fotografiar, esta vez sin ninguna persona en la '
                'imagen',
            'Si la imagen ya está subida: informar al dispatcher o a la '
                'dirección de operaciones para que pueda borrarse en el '
                'sistema',
            'Si no estás seguro de si alguien es reconocible: mejor avisar '
                'que confiar en la suerte',
          ]),
          RevealBlock(
            prompt: 'Caso práctico: dejas un paquete en el patio trasero. '
                'En la foto se ve el paquete — y al fondo, a través de una '
                'ventana que llega al suelo, un salón con dos personas en '
                'el sofá. Ya has cerrado la parada y estás en el patio '
                'siguiente. ¿Qué haces?',
            answer: 'Lo comunicas. La imagen muestra un interior y a '
                'personas identificables — va, por tanto, mucho más allá '
                'del fin «comprobante de entrega» y debe eliminarse del '
                'sistema. El error más habitual es pensar que ya no merece '
                'la pena avisar porque la parada está cerrada. Es '
                'exactamente al revés: solo si la empresa lo sabe puede '
                'borrar la imagen y documentar el suceso. Quien lo '
                'comunica lo hace todo bien — quien calla deja una '
                'infracción en pie.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de control capítulo 2',
        blocks: [
          ChecklistBlock(
            title: 'Antes de cada foto de entrega',
            items: [
              'Fotografío únicamente en la app de trabajo',
              'En la imagen no se ve a ninguna persona',
              'Ninguna matrícula, ninguna ventana, ningún interior en la '
                  'imagen',
              'El paquete y el lugar de depósito se reconocen con claridad',
              'Ninguna imagen acaba en mi galería privada ni en un chat',
              'Si sale alguien por descuido: borrar, repetir, comunicar',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ds3',
    title: 'Manejo de los datos de los destinatarios',
    summary: 'Escáner, teléfono y listas en papel — medios de trabajo, no '
        'asunto privado',
    asset: '',
    slides: [
      SafetySlide(
        title: 'El escáner y el móvil de empresa no son aparatos privados',
        blocks: [
          ParagraphBlock(
            'En el escáner y en el teléfono de empresa están los datos de '
            'cientos de personas al día. Ambos aparatos pertenecen a la '
            'empresa y están ahí exclusivamente para el trabajo — también '
            'en la pausa y también cuando te los llevas a casa.',
          ),
          BulletsBlock([
            'Ninguna app privada, ningún inicio de sesión privado, ninguna '
                'nube privada en el dispositivo de empresa',
            'No ceder el dispositivo — tampoco un momento a compañeros, '
                'familiares o conocidos',
            'Mantener activo el bloqueo de pantalla y no dejar nunca el '
                'dispositivo sin vigilancia',
            'Al salir del vehículo: llevarte el escáner o guardarlo de '
                'forma segura, no visible sobre el asiento',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Prohibición absoluta',
            text: 'Ninguna captura de pantalla de listas de direcciones, '
                'resúmenes de ruta o datos de destinatarios. Tampoco para '
                'enviártela a ti mismo, tampoco «como ayuda para la '
                'memoria». Una captura de pantalla es una copia fuera del '
                'sistema — exactamente lo que la empresa ya no puede '
                'controlar.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Información a vecinos y desconocidos',
        blocks: [
          ParagraphBlock(
            'En la puerta te preguntan. Es normal y casi siempre con buena '
            'intención. Aun así rige lo siguiente: solo revelas lo '
            'necesario para la entrega — nada más.',
          ),
          TableBlock(
            headers: ['Situación', 'Hasta dónde puedes llegar'],
            rows: [
              [
                'Un vecino recoge un paquete',
                'Decir el nombre del destinatario y el número de la casa — '
                    'no necesita más.',
              ],
              [
                'El vecino pregunta qué hay dentro',
                'Sin información. El contenido solo le incumbe al '
                    'destinatario.',
              ],
              [
                'Alguien pregunta si la persona X vive aquí',
                'Sin información. Tú no confirmas domicilios.',
              ],
              [
                'Alguien pregunta cuándo vuelves',
                'Responder en general, sin datos sobre otros envíos o '
                    'destinatarios.',
              ],
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'La base legal',
            text: 'Comunicar datos de destinatarios a terceros es una '
                'revelación en el sentido del Art. 4 n.º 2 DSGVO y '
                'necesita una base jurídica según el Art. 6 DSGVO. Para la '
                'entrega a un vecino, indicar el nombre y la dirección es '
                'necesario para la ejecución del contrato — para el '
                'contenido de los paquetes, los números de teléfono o '
                'información sobre otros destinatarios no existe ninguna.',
          ),
        ],
      ),
      SafetySlide(
        title: 'El papel es el peligro subestimado',
        blocks: [
          ParagraphBlock(
            'Los datos digitales están protegidos al menos por un bloqueo '
            'de pantalla. Un papel en el vehículo no lo está. Una lista de '
            'ruta detrás del parabrisas se lee desde fuera — con nombres y '
            'direcciones de doscientos hogares.',
          ),
          BulletsBlock([
            'No dejar nunca listas en papel a la vista en el vehículo, y '
                'mucho menos visibles a través del cristal',
            'Al salir del vehículo, llevarte las listas o guardarlas bajo '
                'llave',
            'Al final de la ruta: entregar las listas en la empresa, no '
                'llevarlas a casa',
            'Eliminación solo por la vía prevista en la empresa — no en la '
                'basura doméstica, no en la papelera de la gasolinera',
            'Tratar las etiquetas de devoluciones y paquetes erróneos '
                'igual que las listas',
          ]),
          RevealBlock(
            prompt: 'Caso práctico: has terminado la ruta y la lista de '
                'ruta ya no es más que papel usado. De camino a casa la '
                'tiras al contenedor de papel de tu edificio. ¿Está bien '
                'así?',
            answer: 'No. En la lista figuran nombres y direcciones — datos '
                'personales. Deben eliminarse de forma que nadie pueda '
                'reconstruirlos, por regla general mediante un contenedor '
                'de protección de datos o la destructora de documentos de '
                'la empresa. El error más habitual es pensar que una lista '
                'ya utilizada «no vale nada». Para la protección de datos, '
                'que esté hecha no cambia nada: los datos son los mismos y '
                'un contenedor de papel abierto es un lugar de acceso '
                'público. Además, la lista no deberías habértela llevado a '
                'casa siquiera.',
          ),
          DoDontBlock(
            doTitle: 'Correcto',
            dos: [
              'Entregar las listas en la empresa y eliminarlas allí '
                  'debidamente',
              'Bloquear el escáner antes de salir del vehículo',
              'Ante preguntas sobre envíos ajenos, remitir a la dirección '
                  'de operaciones',
            ],
            dontTitle: 'Incorrecto',
            donts: [
              'Hacer o enviar capturas de pantalla de listas de direcciones',
              'Llevarte las listas de ruta a casa o tirarlas en privado',
              'Comunicar datos de destinatarios a vecinos, conocidos o '
                  'terceros',
              'Pasarle el dispositivo de empresa a otra persona',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de control capítulo 3',
        blocks: [
          ChecklistBlock(
            title: 'Al final de cada ruta',
            items: [
              'Ninguna captura de datos de direcciones en mi dispositivo',
              'El escáner y el móvil de empresa están bloqueados y '
                  'guardados de forma segura',
              'Ninguna lista en papel queda a la vista en el vehículo',
              'Todas las listas y etiquetas están entregadas en la empresa',
              'No he comunicado datos de destinatarios a terceros',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ds4',
    title: 'Tus propios datos y los de tus compañeros',
    summary: 'Baja por enfermedad, registro de jornada, expediente '
        'personal — y tus derechos como interesado',
    asset: '',
    slides: [
      SafetySlide(
        title: 'La protección de datos también te protege a ti',
        blocks: [
          ParagraphBlock(
            'No solo los destinatarios tienen datos en el sistema — tú '
            'también. Y en parte son bastante más sensibles que una '
            'dirección de entrega.',
          ),
          BulletsBlock([
            'Indicadores de rendimiento de tu actividad de reparto',
            'Bajas por enfermedad y ausencias',
            'Registro de jornada, planes de turnos, tiempos de pausa',
            'Datos del permiso de conducir y del DNI del expediente '
                'personal',
            'Fotos en las que apareces tú o tus compañeros',
          ]),
          ParagraphBlock(
            'La empresa puede tratar estos datos en la medida en que sea '
            'necesario para la relación laboral. Pero no puede '
            'comunicarlos a su antojo — y tú tampoco, cuando se trata de '
            'tus compañeros.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'La base legal',
            text: 'Los datos de los empleados se tratan sobre la base del '
                'Art. 6 apdo. 1 lit. b y f DSGVO en relación con el § 26 '
                'BDSG (la ley alemana de protección de datos, que regula '
                'el tratamiento de datos en el ámbito laboral) — solo son '
                'admisibles en la medida en que sean necesarios para la '
                'relación laboral. Los datos de salud, como las bajas por '
                'enfermedad, son categorías especiales según el Art. 9 '
                'DSGVO y están especialmente protegidos.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Los datos de tus compañeros no te pertenecen',
        blocks: [
          ParagraphBlock(
            'En el depósito uno se entera de muchas cosas: quién está de '
            'baja, quién ha tenido problemas con una ruta, quién ha '
            'recibido una amonestación. Enterarse es una cosa — contarlo, '
            'otra.',
          ),
          DoDontBlock(
            doTitle: 'Correcto',
            dos: [
              'Hablar de tus propios datos tanto como quieras',
              'Aclarar los problemas con un compañero directamente con él '
                  'o con la dirección de operaciones',
              'Hacer y compartir una foto con compañeros solo si todos los '
                  'que aparecen están de acuerdo',
              'Comunicar internamente las infracciones observadas en lugar '
                  'de ir contándolas por el depósito',
            ],
            dontTitle: 'Incorrecto',
            donts: [
              'Comunicar datos de rendimiento o evaluaciones de compañeros',
              'Hablar del motivo de la baja de un compañero — aunque lo '
                  'conozcas',
              'Publicar fotos o vídeos de compañeros en grupos de chat sin '
                  'su consentimiento',
              'Compartir capturas de pantalla de listas o evaluaciones '
                  'internas',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Especialmente delicado',
            text: 'Las bajas por enfermedad. Que alguien esté enfermo es '
                'un dato de salud según el Art. 9 DSGVO. El motivo, con '
                'mayor razón. Comunicarlo a otros conductores tampoco está '
                'permitido cuando el propio afectado ya lo ha contado.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tus derechos como interesado',
        blocks: [
          ParagraphBlock(
            'El DSGVO te da derechos frente a tu empresa. No tienes que '
            'justificarlos y su ejercicio no puede perjudicarte.',
          ),
          TableBlock(
            headers: ['Derecho', 'Qué puedes exigir'],
            rows: [
              [
                'Acceso (Art. 15)',
                'Un resumen de qué datos hay guardados sobre ti y para qué.',
              ],
              [
                'Rectificación (Art. 16)',
                'La corrección de datos erróneos, por ejemplo un número de '
                    'personal o una dirección incorrectos.',
              ],
              [
                'Supresión (Art. 17)',
                'La supresión de datos que ya no se necesitan y que no '
                    'están sujetos a ningún plazo de conservación.',
              ],
            ],
          ),
          ParagraphBlock(
            'La persona de contacto es la dirección de operaciones o el '
            'delegado de protección de datos de la empresa. Una solicitud '
            'debe responderse, por regla general, en el plazo de un mes.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: un compañero te pide que le mandes una '
                'captura de pantalla de una evaluación interna — en la que '
                'aparecen todos los conductores con nombres y cifras. Solo '
                'quiere ver dónde está él. ¿Lo haces?',
            answer: 'No. En la captura figuran los datos de rendimiento de '
                'todos los compañeros; eso es una comunicación de datos de '
                'empleados sin base jurídica. Que el compañero solo quiera '
                'ver su propia fila no cambia nada — de todos modos recibe '
                'también todos los demás. Lo correcto es: que consulte sus '
                'propios datos a la dirección de operaciones. Su derecho '
                'de acceso según el Art. 15 DSGVO se refiere '
                'exclusivamente a sus propios datos.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de control capítulo 4',
        blocks: [
          ChecklistBlock(
            title: 'En el manejo de los datos de mis compañeros',
            items: [
              'No comunico datos de rendimiento de compañeros',
              'No hablo de las bajas por enfermedad de otros',
              'No publico fotos de compañeros sin su consentimiento',
              'No hago capturas de pantalla de evaluaciones internas',
              'Sé a quién dirigirme si quiero información sobre mis '
                  'propios datos',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ds5',
    title: 'Cuando algo sale mal — brecha de datos',
    summary: 'Plazo de notificación de 72 horas: por qué tienes que avisar '
        'de inmediato',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Qué es una brecha de datos',
        blocks: [
          ParagraphBlock(
            'Una brecha de datos no es solo el gran ataque informático. En '
            'el reparto son casi siempre pequeños percances cotidianos — y '
            'precisamente esos también cuentan.',
          ),
          BulletsBlock([
            'Teléfono de empresa o escáner perdido o robado',
            'Paquete entregado al destinatario equivocado, que lo ha '
                'abierto',
            'Paquete con la etiqueta de dirección legible dejado a la '
                'vista en el portal o en la calle',
            'Foto o lista de direcciones enviada por error a la persona '
                'equivocada',
            'Lista de ruta perdida o dejada a la vista en el vehículo',
            'Escáner accesible sin vigilancia y desbloqueado',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Regla práctica',
            text: 'En cuanto unos datos personales han quedado accesibles '
                'para alguien que no debería tener acceso a ellos, es una '
                'brecha de datos. Si al final se ha producido realmente un '
                'daño no lo decides tú — eso lo evalúa la empresa.',
          ),
        ],
      ),
      SafetySlide(
        title: 'El plazo de 72 horas',
        blocks: [
          ParagraphBlock(
            'El punto decisivo para ti es el reloj. En cuanto la empresa '
            'tiene conocimiento de una brecha de datos empieza a correr un '
            'plazo muy corto — y corre con independencia de que sea el '
            'final de la jornada, fin de semana o festivo.',
          ),
          FactsBlock([
            FactItem('72 h', 'plazo de notificación de la empresa a la '
                'autoridad de control según el Art. 33 DSGVO'),
            FactItem('de inmediato', 'tu aviso al dispatcher o a la '
                'dirección de operaciones — el mismo día'),
            FactItem('0', 'perjuicios para ti si comunicas de inmediato un '
                'error propio'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'La base legal',
            text: 'El Art. 33 apdo. 1 DSGVO obliga a la empresa a notificar '
                'a la autoridad de control cualquier violación de la '
                'seguridad de los datos personales sin dilación indebida y, '
                'de ser posible, en un plazo de 72 horas desde que tuvo '
                'conocimiento de ella. En caso de alto riesgo hay que '
                'informar además a los interesados según el Art. 34 DSGVO. '
                'La empresa solo puede cumplir ese plazo si tú avisas de '
                'inmediato.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Así se avisa correctamente',
        blocks: [
          StepsBlock([
            'Llamar de inmediato al dispatcher o a la dirección de '
                'operaciones — no esperar al final de la jornada',
            'Decir qué ha pasado, cuándo ha pasado y qué datos están '
                'afectados',
            'Decir quién ha podido ver los datos',
            'No arreglar nada por tu cuenta: ningún borrado de registros, '
                'ninguna recuperación sin acordarlo',
            'Si es posible, conservar la situación — por ejemplo, no mover '
                'el paquete mal entregado antes de acordar cómo proceder',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Lo más importante de este capítulo',
            text: 'Quien comunica un error de inmediato actúa '
                'correctamente. Avisar es expresamente deseado y no es '
                'ninguna confesión de incompetencia. Callar, en cambio, '
                'convierte un pequeño percance en un problema de verdad — '
                'para los afectados, para la empresa y, al final, también '
                'para ti.',
          ),
          DoDontBlock(
            doTitle: 'Correcto',
            dos: [
              'Avisar de inmediato, aunque dé vergüenza',
              'Describirlo todo, también los errores propios',
              'Preguntar si debes hacer algo más',
            ],
            dontTitle: 'Incorrecto',
            donts: [
              'Esperar a ver si alguien se da cuenta',
              'Avisar solo al siguiente día de trabajo',
              'Quitarle importancia al incidente u omitir partes',
              'Intentar por tu cuenta recuperar el paquete o la foto',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Caso práctico y lista de control',
        blocks: [
          RevealBlock(
            prompt: 'Caso práctico: por la tarde te das cuenta de que has '
                'dejado un paquete en el número 14 en lugar del 41. El '
                'destinatario de allí ya lo ha abierto. Quieres recogerlo '
                'mañana temprano sin más y entregarlo bien — así nadie se '
                'dará cuenta. ¿Qué falla en ese plan?',
            answer: 'Dos cosas. Primero, ya se ha producido una brecha de '
                'datos: una persona ajena ha conocido el nombre, la '
                'dirección y el contenido del envío. Hay que evaluar si es '
                'notificable, y el plazo de 72 horas del Art. 33 DSGVO '
                'corre desde el momento en que la empresa tiene '
                'conocimiento de ello. Segundo, con la espera impides '
                'exactamente lo que la empresa debería hacer — valorar, '
                'documentar y, en su caso, informar al destinatario '
                'afectado. El error más habitual es pensar que una '
                'corrección silenciosa no perjudica a nadie. En realidad '
                'sí perjudica: si el incidente se conoce después, la '
                'empresa se queda sin notificación en plazo — y tú has '
                'ocultado el error en vez de haberlo comunicado.',
          ),
          ChecklistBlock(
            title: 'Ante cualquier sospecha de brecha de datos',
            items: [
              'Aviso el mismo día, no mañana',
              'Digo qué ha pasado, cuándo y qué datos están afectados',
              'No maquillo nada ni omito nada',
              'No emprendo nada por mi cuenta',
              'Tengo claro: avisar es lo correcto, callar lo empeora',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'ds6',
    title: 'Confidencialidad y lealtad',
    summary: 'Qué puede salir al exterior y qué no — y por qué la crítica '
        'objetiva está expresamente permitida',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Los secretos de empresa se quedan en la empresa',
        blocks: [
          ParagraphBlock(
            'Junto a los datos personales hay un segundo grupo de '
            'informaciones que no deben salir al exterior: las cifras '
            'internas y los secretos empresariales y comerciales. Ahí '
            'entra mucho de lo que en el depósito se comenta con toda '
            'naturalidad.',
          ),
          BulletsBlock([
            'Precios, condiciones y contratos con los clientes',
            'Indicadores y evaluaciones internos',
            'Planes de ruta, lógica de rutas y cifras de capacidad',
            'Instrucciones internas, material de formación y '
                'especificaciones de procesos',
            'Fotos del depósito en las que se reconozcan listas, pantallas '
                'o envíos',
          ]),
          ParagraphBlock(
            'Esto vale igual en cualquier canal: en la conversación '
            'personal, en las redes sociales y en los grupos de chat de '
            'conductores. Un grupo de WhatsApp con sesenta conductores no '
            'es una conversación privada.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'La base legal',
            text: 'Los secretos comerciales están protegidos por la '
                'GeschGehG (la ley alemana de protección de secretos '
                'empresariales). Con independencia de ello, del contrato '
                'de trabajo se deriva un deber de confidencialidad como '
                'obligación accesoria conforme al § 241 apdo. 2 BGB (el '
                'Código Civil alemán). Para los datos personales rige '
                'además la confidencialidad del Art. 5 apdo. 1 lit. f '
                'DSGVO.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Afirmaciones falsas sobre la empresa',
        blocks: [
          ParagraphBlock(
            'Aquí se confunde a menudo lo que está permitido y lo que no. '
            'La línea no pasa entre «positivo» y «negativo», sino entre lo '
            'verdadero y lo deliberadamente falso, entre la crítica y el '
            'insulto.',
          ),
          ParagraphBlock(
            'Las afirmaciones de hechos deliberadamente falsas sobre la '
            'empresa, los superiores o los compañeros no están amparadas '
            'por la libertad de expresión. Lo mismo vale para los insultos '
            'y la crítica injuriosa — es decir, manifestaciones en las que '
            'ya no se trata del asunto, sino solo de menospreciar a '
            'alguien.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'La base legal',
            text: 'El Art. 5 apdo. 1 GG (la Constitución alemana) protege '
                'las opiniones, pero no las afirmaciones de hechos '
                'deliberadamente falsas ni la crítica injuriosa. Tales '
                'manifestaciones pueden justificar un despido disciplinario '
                'según el § 626 BGB. En caso de difamación se añade la '
                'responsabilidad penal según el § 186 StGB (el Código Penal '
                'alemán); ante afirmaciones deliberadamente falsas se '
                'aplica el § 187 StGB (calumnia).',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Malentendidos habituales',
            text: 'Un perfil privado deja de ser privado en cuanto otros '
                'pueden leerlo. Un grupo de chat cerrado no está protegido '
                'en cuanto circula una captura de pantalla. Y «solo era mi '
                'opinión» no sirve de nada si la afirmación era un hecho '
                'que demostrablemente no es cierto.',
          ),
        ],
      ),
      SafetySlide(
        title: 'La crítica objetiva está expresamente permitida',
        blocks: [
          ParagraphBlock(
            'Igual de importante que el límite es lo que queda de este '
            'lado — y es mucho. Puedes expresar críticas, también con '
            'claridad, también incómodas. Puedes decir que una ruta está '
            'planificada de forma demasiado ajustada, que un vehículo está '
            'en mal estado o que una indicación en el depósito era '
            'errónea.',
          ),
          ParagraphBlock(
            'Y quien comunica irregularidades reales no está indefenso: '
            'desde el 2 de julio de 2023 rige la HinSchG (la ley alemana '
            'de protección de denunciantes). Prohíbe las represalias '
            'contra los empleados que comunican infracciones — es decir, '
            'despido, amonestación, traslado o perjuicio a causa de la '
            'comunicación.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Protección del denunciante',
            text: 'La HinSchG protege frente a represalias a las personas '
                'que comunican infracciones en el contexto profesional. La '
                'protección solo decae en caso de comunicaciones '
                'incorrectas hechas a sabiendas o con negligencia grave. '
                'Quien comunica una irregularidad en serio y según su leal '
                'saber y entender está protegido — también cuando la '
                'sospecha finalmente no se confirma.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'La diferencia en una frase',
            text: 'Di lo que has vivido — no lo que te imaginas. La '
                'crítica veraz está protegida; las acusaciones inventadas, '
                'no.',
          ),
        ],
      ),
      SafetySlide(
        title: 'El camino constructivo',
        blocks: [
          ParagraphBlock(
            'Casi todo lo que los conductores sacan al exterior podría '
            'resolverse más rápido internamente. Por eso el camino hacia '
            'dentro no solo es el más seguro, sino casi siempre también el '
            'más eficaz.',
          ),
          StepsBlock([
            'Hablar primero con el dispatcher — la mayoría de los '
                'problemas son problemas de planificación y ahí se '
                'resuelven',
            'Si no hay respuesta: dirigirse a la dirección de operaciones, '
                'preferiblemente por escrito, con fecha y el incidente '
                'concreto',
            'En infracciones más graves: usar el canal interno de denuncia '
                'según la HinSchG',
            'Solo cuando internamente no ocurre nada entran en '
                'consideración las instancias externas — pero entonces de '
                'forma objetiva y con hechos demostrables',
          ]),
          DoDontBlock(
            doTitle: 'Permitido y deseado',
            dos: [
              'Decir que una ruta no se puede hacer de forma habitual',
              'Señalar un defecto técnico del vehículo — también '
                  'repetidamente',
              'Describir un incidente concreto que hayas vivido tú mismo',
              'Comunicar una infracción a través del canal interno de '
                  'denuncia',
              'Insistir cuando tras un aviso no ocurre nada',
            ],
            dontTitle: 'No amparado',
            donts: [
              'Hacer afirmaciones que sabes que no son ciertas',
              'Insultar o menospreciar a superiores o compañeros',
              'Hacer públicos cifras, contratos o evaluaciones internos',
              'Difundir rumores en grupos de chat sin conocerlos',
              'Dirimir conflictos en portales de valoración o redes '
                  'sociales antes de haber preguntado siquiera a alguien '
                  'internamente',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Caso práctico y lista de control',
        blocks: [
          RevealBlock(
            prompt: 'Caso práctico: en el grupo de chat de conductores '
                'alguien escribe que la empresa no paga las horas a '
                'propósito. Tú nunca lo has vivido, pero estás enfadado '
                'justo ahora por tu plan de turnos y escribes: «Cierto, '
                'nos estafan a todos sistemáticamente». Al día siguiente '
                'circula una captura de pantalla del grupo. ¿Cómo se '
                'valora esto?',
            answer: 'Es delicado — no por la crítica, sino por la forma. '
                'Has hecho una afirmación de hechos («nos estafan '
                'sistemáticamente») que tú mismo no puedes acreditar y que '
                'no has vivido. Las afirmaciones de hechos deliberadamente '
                'falsas no están amparadas por la libertad de expresión y '
                'pueden tener consecuencias laborales hasta el despido '
                'disciplinario según el § 626 BGB; en caso de difamación '
                'se añade el § 186 StGB. La captura de pantalla demuestra, '
                'además, que un grupo cerrado no es un espacio protegido. '
                'Lo correcto habría sido: nombrar tu propio caso — «En '
                'julio me faltan dos horas, lo he comunicado y hasta ahora '
                'no he recibido respuesta» — y llevarlo al dispatcher, a '
                'la dirección de operaciones o al canal interno de '
                'denuncia. Esa afirmación es verdadera, comprobable y está '
                'protegida por la HinSchG. Resultado: el mismo descontento, '
                'pero expresado correctamente, no puede perjudicarte.',
          ),
          ChecklistBlock(
            title: 'Antes de sacar algo al exterior',
            items: [
              'Sé por experiencia propia que es cierto',
              'Describo el incidente de forma objetiva, sin insultos',
              'No revelo cifras, contratos ni evaluaciones internos',
              'Lo he planteado primero internamente — dispatcher, '
                  'dirección de operaciones o canal de denuncia',
              'Tengo claro: comunicar irregularidades reales está '
                  'protegido, afirmar cosas inventadas no',
            ],
          ),
        ],
      ),
    ],
  ),
];
