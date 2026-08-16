// lib/data/safety_training/safety_content_es.dart
//
// Contenidos de la instrucción de seguridad — versión en español.

import 'safety_blocks.dart';

const String _a = 'assets/academy/safety/';

const List<SafetyChapterContent> safetyContentEs = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ch01',
    title: 'Base legal y tus obligaciones',
    summary: 'Por qué existe la prevención de riesgos laborales — y qué '
        'debes aportar tú',
    asset: '${_a}ch01_grundlagen.svg',
    slides: [
      SafetySlide(
        title: 'En qué se basa la prevención de riesgos laborales',
        asset: '${_a}ch01_grundlagen.svg',
        blocks: [
          ParagraphBlock(
            'La prevención de riesgos laborales no es una oferta voluntaria '
            'de tu empresa, sino una obligación legal. Se apoya en dos '
            'pilares: el derecho estatal y el derecho de las entidades '
            'aseguradoras de accidentes de trabajo.',
          ),
          BulletsBlock([
            'Arbeitsschutzgesetz (ArbSchG) — la ley alemana de prevención '
                'de riesgos laborales; regula las obligaciones del '
                'empresario y los derechos y deberes de los trabajadores',
            'Reglamentos — concretan la ley, por ejemplo los reglamentos '
                'sobre centros de trabajo, seguridad en la explotación y '
                'sustancias peligrosas',
            'DGUV Vorschriften — normas vinculantes de la mutua profesional '
                'alemana, obligatorias para ti como asegurado',
            'DGUV Regeln e Informationen — guías de aplicación y '
                'recomendaciones; no son vinculantes, pero están '
                'contrastadas en la práctica',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'La diferencia que cuenta',
            text: 'Las DGUV Vorschriften son vinculantes. Las DGUV Regeln '
                'muestran cómo aplicarlas. Las DGUV Informationen son '
                'recomendaciones.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tus seis obligaciones como trabajador',
        blocks: [
          ParagraphBlock(
            'La empresa debe protegerte — tú debes colaborar. Estas '
            'obligaciones valen para todos los trabajadores, sea cual sea '
            'su puesto y su contrato.',
          ),
          StepsBlock([
            'Velar por tu propia seguridad y por la de tus compañeros',
            'Cumplir las Betriebsanweisungen (instrucciones de trabajo) y '
                'las instrucciones recibidas',
            'Prestar primeros auxilios o apoyar una asistencia eficaz',
            'Comunicar accidentes y casi accidentes — también los pequeños',
            'Comunicar de inmediato averías y deficiencias (cables '
                'defectuosos, aparatos rotos, procesos erróneos)',
            'Utilizar el equipo de protección conforme a su uso previsto: '
                'calzado de seguridad, guantes, chaleco reflectante, '
                'protección auditiva',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Alcohol, drogas, medicamentos',
            text: 'No puedes ponerte en peligro a ti ni a los demás por '
                'consumo de sustancias que alteren tu estado. Esto vale '
                'durante toda la jornada laboral — también en la pausa, '
                'porque después vuelves a conducir. También cuentan los '
                'medicamentos que producen somnolencia: en caso de duda, '
                'pregunta a tu médico.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ch02',
    title: 'Betriebsanweisungen (instrucciones de trabajo)',
    summary: 'Instrucciones vinculantes — y por qué te protegen',
    asset: '${_a}ch02_betriebsanweisungen.svg',
    slides: [
      SafetySlide(
        title: 'Qué es una Betriebsanweisung',
        asset: '${_a}ch02_betriebsanweisungen.svg',
        blocks: [
          ParagraphBlock(
            'Una Betriebsanweisung es una instrucción vinculante de tu '
            'empresa para el manejo de vehículos, equipos de trabajo y '
            'sustancias peligrosas. No es una recomendación.',
          ),
          BulletsBlock([
            'Está expuesta en el centro de trabajo — tienes que conocerla',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Esto deberías saberlo',
            text: 'A quien incumple una Betriebsanweisung se le puede '
                'imputar ese incumplimiento en la investigación del '
                'accidente. En el peor de los casos significa '
                'corresponsabilidad en un accidente — también para ti '
                'personalmente.',
          ),
          ParagraphBlock(
            'Distinción: la Betriebsanweisung regula el manejo de un equipo '
            'de trabajo o de una sustancia peligrosa. La Arbeitsanweisung '
            'regula el desarrollo de un proceso de trabajo.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Estructura — seis apartados',
        blocks: [
          ParagraphBlock(
            'Todas las Betriebsanweisungen tienen la misma estructura. Si '
            'conoces esa estructura, en caso de emergencia encuentras el '
            'apartado correcto de inmediato.',
          ),
          StepsBlock([
            'Ámbito de aplicación — para qué y para quién rige',
            'Peligros para las personas y el medio ambiente',
            'Medidas de protección y reglas de conducta',
            'Actuación en caso de avería',
            'Actuación en caso de accidente y primeros auxilios',
            'Eliminación de residuos y mantenimiento',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Ejemplo: conducir la furgoneta',
        blocks: [
          ParagraphBlock(
            'Así son las reglas concretas de una Betriebsanweisung para '
            'vehículos de hasta 3,5 t:',
          ),
          BulletsBlock([
            'Llevar encima un permiso de conducir válido',
            'Nada de alcohol ni drogas antes y durante la conducción',
            'Marcha atrás con riesgo solo con una persona que dirija la '
                'maniobra',
            'Cerrar siempre el vehículo con llave al abandonarlo',
            'Remolcar únicamente con barra de remolque',
            'Señalizar el lugar del accidente y comunicar cualquier '
                'accidente sin demora',
            'Tratar de inmediato también las lesiones leves y anotarlas en '
                'el libro de curas (Verbandbuch)',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'En caso de duda, pregunta',
            text: 'Si una instrucción no te queda clara, pregunta a tu '
                'dispatcher — antes de salir, no después.',
          ),
          SubheadBlock('Las instrucciones más importantes'),
          ParagraphBlock(
            'Todas las Betriebsanweisungen las encuentras en cualquier '
            'momento en la DA Academy, en «Betriebsanweisungen».',
          ),
          InstructionRefBlock([
            'baw_transporter',
            'baw_heben_tragen',
            'baw_winter',
          ]),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ch03',
    title: 'Las 10 reglas para trabajar con seguridad',
    summary: 'El núcleo de tu jornada — válido cada día',
    asset: '${_a}ch03_sicheres_arbeiten.svg',
    slides: [
      SafetySlide(
        title: 'Diez reglas, cada día',
        asset: '${_a}ch03_sicheres_arbeiten.svg',
        blocks: [
          StepsBlock([
            'Trabajar de forma segura y prudente',
            'Control previo a la salida antes de iniciar la marcha',
            'Asegurar la carga en el vehículo',
            'Conducir de forma profesional y respetar el StVO (código de '
                'circulación alemán)',
            'Ponerse el cinturón de seguridad',
            'Mantener en orden vehículos, herramientas y equipos',
            'Trabajar solo con calzado adecuado',
            'Trato cortés con compañeros y clientes',
            'Cumplir el régimen de pausas',
            'Trato tolerante y respetuoso',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Las tres de mayor efecto',
            text: 'Control previo a la salida, sujeción de la carga y '
                'cinturón de seguridad. Estas tres evitan la mayoría de las '
                'consecuencias graves — y juntas no cuestan ni tres minutos.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ch04',
    title: 'Equipo de protección individual (EPI)',
    summary: 'Calzado de seguridad y chaleco reflectante — tu obligación '
        'diaria',
    asset: '${_a}ch04_psa.svg',
    slides: [
      SafetySlide(
        title: 'Tu EPI como repartidor',
        asset: '${_a}ch04_psa.svg',
        blocks: [
          ParagraphBlock(
            'El equipo de protección individual es todo lo que llevas puesto '
            'para protegerte de los peligros. En el reparto hay dos '
            'elementos obligatorios cada día:',
          ),
          FactsBlock([
            FactItem('1', 'Calzado de seguridad'),
            FactItem('2', 'Chaleco reflectante'),
          ]),
          BulletsBlock([
            'Calzado de seguridad — toda la jornada, tanto en la estación '
                'como en la ruta',
            'Chaleco reflectante — al alcance de la mano en el vehículo y '
                'puesto antes de bajarte en caso de avería, accidente o '
                'parada en la calzada',
          ]),
          SubheadBlock('Otros EPI — según la actividad'),
          ParagraphBlock(
            'Este equipo no es obligatorio a diario, pero puede ser '
            'necesario para determinados trabajos. Lo que rige para ti '
            'consta en la evaluación de riesgos y en la Betriebsanweisung.',
          ),
          BulletsBlock([
            'Guantes de protección — con envíos de cantos afilados, en '
                'trabajos de limpieza y mantenimiento, en invierno',
            'Protección auditiva — con ruido, por ejemplo en determinadas '
                'zonas de la nave',
            'Gafas de protección — en trabajos con riesgo de salpicaduras',
            'Casco — en obras y con riesgo de caída de objetos',
            'Ropa de protección frente al clima — en trabajo continuado al '
                'aire libre',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Obligación de uso',
            text: 'El EPI facilitado por la empresa debes utilizarlo '
                'conforme a su uso previsto (§ 15 Arbeitsschutzgesetz, la '
                'ley alemana de prevención). La empresa lo pone a tu '
                'disposición gratuitamente y debe vigilar su cumplimiento.',
          ),
          InstructionRefBlock(['baw_sicherheitsschuhe', 'baw_warnweste']),
        ],
      ),
      SafetySlide(
        title: 'Calzado de seguridad: efecto protector',
        blocks: [
          ParagraphBlock(
            'La protección del pie es el EPI que más necesitas — y el que '
            'más a menudo se subestima.',
          ),
          SubheadBlock('De qué te protege'),
          BulletsBlock([
            'Mecánico — golpes, aplastamientos, paquetes que caen, pisar '
                'objetos punzantes',
            'Torceduras — el calzado que cubre el tobillo estabiliza la '
                'articulación y evita roturas de ligamentos y lesiones de '
                'tobillo',
            'Eléctrico — descarga antiestática',
            'Químico — ácidos, aceites, carburantes',
            'Térmico — calor y frío',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Por qué hasta el tobillo',
            text: 'La lesión más frecuente en el reparto es la torcedura al '
                'bajar del vehículo, en los bordillos y en caminos '
                'irregulares. Un calzado que cubre el tobillo sujeta la '
                'articulación justo donde se dobla — un zapato bajo no puede '
                'hacerlo.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Aunque sean incómodos — y también en verano',
            text: 'La obligación de llevarlos rige todos los días de '
                'trabajo, con independencia del tiempo y de la comodidad. '
                'Precisamente en verano se cambia de calzado — y justo '
                'entonces ocurren las lesiones. Si los zapatos aprietan o '
                'rozan, es motivo para otro modelo, no para llevar '
                'zapatillas deportivas.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Revisa tus zapatos con regularidad',
            text: 'Suela desgastada, grietas o suciedad importante: pide que '
                'te los cambien. No hagas modificaciones por tu cuenta y no '
                'trabajes nunca en zapatillas deportivas — tampoco «solo un '
                'momento».',
          ),
        ],
      ),
      SafetySlide(
        title: 'Clases de protección de un vistazo',
        blocks: [
          TableBlock(
            headers: ['Clase', 'Propiedades'],
            rows: [
              [
                'S1',
                'Talón cerrado, antiestático, suela resistente a los '
                    'carburantes',
              ],
              ['S2', 'como S1 + impermeable al menos 60 minutos'],
              ['S3', 'como S2 + suela antiperforación y con relieve'],
              ['S4', 'como S2, totalmente de goma (vulcanizada)'],
              ['S5', 'como S4 + suela antiperforación'],
            ],
          ),
          SubheadBlock('Cuándo son especialmente importantes'),
          BulletsBlock([
            'En escaleras de mano, estribos y escaleras',
            'Con jaulas rodantes y transpaletas',
            'En caminos irregulares y rampas',
          ]),
          ParagraphBlock(
            'Características de un buen zapato: ajuste firme, cerrado, '
            'sujeción del talón con amortiguación, suela flexible, tacón '
            'bajo, dibujo antideslizante.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ch05',
    title: 'Actuación en caso de incendio',
    summary: 'Usar bien el extintor y dominar los incendios de vehículo',
    asset: '${_a}ch05_brandfall.svg',
    slides: [
      SafetySlide(
        title: 'Manejar el extintor',
        asset: '${_a}ch05_brandfall.svg',
        blocks: [
          ParagraphBlock(
            'Hay extintores de polvo, de agua/espuma y de CO₂. El manejo es '
            'el mismo en todos:',
          ),
          StepsBlock([
            'Quitar el pasador de seguridad',
            'Accionar el botón percutor',
            'Accionar la manguera de descarga',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Solo tienes segundos',
            text: 'Un extintor se vacía más rápido de lo que la mayoría '
                'piensa. Por eso: mejor emplear varios extintores a la vez '
                'que uno detrás de otro.',
          ),
          FactsBlock([
            FactItem('6–12 s', 'Polvo 1–2 kg'),
            FactItem('15–23 s', 'Polvo 6 kg'),
            FactItem('18–33 s', 'Polvo 12 kg'),
            FactItem('20–30 s', 'Espuma 6 l'),
            FactItem('5–10 s', 'CO₂ 2 kg'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Extinguir correctamente — paso a paso',
        blocks: [
          ParagraphBlock(
            'El orden decide si el fuego se apaga o vuelve a prender. Siete '
            'pasos que deberías memorizar:',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}fire01_pin.svg',
              title: 'Preparar el extintor',
              caption: 'Quitar el pasador, accionar el botón percutor, '
                  'mantener el extintor en vertical. Solo después acercarse '
                  'al fuego.',
            ),
            IllustratedStep(
              asset: '${_a}fire02_wind.svg',
              title: 'Atacar en el sentido del viento',
              caption: 'El viento debe darte en la espalda y llevar el '
                  'agente extintor hacia el fuego — nunca extinguir contra '
                  'el viento. Así el calor y el humo se alejan de ti.',
            ),
            IllustratedStep(
              asset: '${_a}fire03_surface.svg',
              title: 'Incendio de superficie: empezar por delante',
              caption: 'Apuntar al borde delantero de las llamas, hacia las '
                  'brasas — no a las puntas de las llamas. Después avanzar '
                  'poco a poco hacia atrás.',
            ),
            IllustratedStep(
              asset: '${_a}fire04_drip.svg',
              title: 'Incendio por goteo: de arriba abajo',
              caption: 'Si cae líquido ardiendo, empieza arriba, en el punto '
                  'de salida, y trabaja hacia abajo — si no, vuelve a arder '
                  'una y otra vez desde arriba.',
            ),
            IllustratedStep(
              asset: '${_a}fire05_together.svg',
              title: 'Varios extintores a la vez',
              caption: 'Si hay varios extintores y personas que ayudan: '
                  'usadlos juntos y al mismo tiempo. Uno detrás de otro da '
                  'al fuego tiempo para recuperarse entre extintor y '
                  'extintor.',
            ),
            IllustratedStep(
              asset: '${_a}fire06_watch.svg',
              title: 'Vigilar el lugar del incendio',
              caption: 'Después de extinguir, quédate en el sitio y observa. '
                  'Los rescoldos se reavivan a menudo al cabo de unos '
                  'minutos — con distancia y con un extintor listo para '
                  'usar.',
            ),
            IllustratedStep(
              asset: '${_a}fire07_refill.svg',
              title: 'Hacer recargar el extintor usado',
              caption: 'Un extintor usado no vuelve nunca a la pared — '
                  'tampoco tras una descarga corta. Entrégalo de inmediato '
                  'para su recarga y comunica que hace falta un repuesto.',
            ),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Cuándo no debes extinguir',
            text: 'No te pongas nunca en peligro. Si el fuego es mayor que '
                'una papelera, se genera mucho humo o pones en riesgo la vía '
                'de evacuación: sal, cierra la puerta, llama al 112 y avisa '
                'a los demás.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Incendio de vehículo',
        blocks: [
          SubheadBlock('Causas más frecuentes'),
          BulletsBlock([
            'Fugas de combustible o aceite',
            'Material aislante sobre piezas calientes',
            'Daños mecánicos',
            'Defectos eléctricos',
            'Contenedores de basura ardiendo',
          ]),
          SubheadBlock('Qué debes hacer'),
          StepsBlock([
            'No parar en túneles ni en puentes — si es posible, salir de '
                'ellos',
            'Encender las luces de emergencia, buscar un lugar adecuado y '
                'detenerse',
            'Abandonar el vehículo y mantener la distancia',
            'Avisar a los bomberos al 112 — indicando la ubicación y el '
                'sentido de la marcha',
            'Solo entonces intentar extinguir por tu cuenta, si es seguro',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Capó: precaución',
            text: 'Ábrelo solo con guantes y solo una rendija. La entrada '
                'repentina de oxígeno puede provocar llamaradas.',
          ),
          SubheadBlock('Qué necesita saber la central de emergencias'),
          BulletsBlock([
            '¿Dónde es el incendio?',
            '¿Qué arde y con qué alcance?',
            '¿Cuántos heridos y qué lesiones?',
            '¿Qué lleva cargado el vehículo?',
            '¿Quién avisa?',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'No cuelgues',
            text: 'No termines nunca tú la llamada. Espera a que te '
                'pregunten — la central es quien finaliza la conversación.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'ch06',
    title: 'Primeros auxilios',
    summary: 'Tu obligación, tu cobertura y la documentación',
    asset: '${_a}ch06_erste_hilfe.svg',
    slides: [
      SafetySlide(
        title: 'Ayudar es obligatorio — y estás cubierto',
        asset: '${_a}ch06_erste_hilfe.svg',
        blocks: [
          ParagraphBlock(
            'Toda persona está obligada a prestar primeros auxilios — dentro '
            'de lo razonablemente exigible y sin ponerse en peligro grave a '
            'sí misma. También si no tienes formación sanitaria.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 323c StGB — omisión del deber de socorro',
            text: 'Quien no ayuda pese a que le sería exigible, comete un '
                'delito: hasta un año de prisión o multa. Esto vale también '
                'para los curiosos que estorban a quienes ayudan.',
          ),
          SubheadBlock('Quien ayuda no hace nada mal'),
          BulletsBlock([
            'Como primer interviniente no respondes por los errores — salvo '
                'en caso de dolo o negligencia grave',
            'Mientras prestas ayuda estás cubierto por el seguro legal de '
                'accidentes',
            'Los costes no corren de tu cuenta; los daños materiales se '
                'indemnizan por regla general',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'El único error de verdad',
            text: 'No hacer nada. Todo lo demás es mejor que mirar hacia '
                'otro lado.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Primeros intervinientes en la estación — y tú',
        blocks: [
          ParagraphBlock(
            'En la estación hay primeros intervinientes formados por la '
            'empresa. De ello se ocupa el empresario: la organización de los '
            'primeros auxilios es tarea suya (§ 24 DGUV Vorschrift 1) y debe '
            'disponer de un número mínimo de primeros intervinientes '
            'formados (§ 26 DGUV Vorschrift 1).',
          ),
          FactsBlock([
            FactItem('1', 'primer interviniente con 2–20 presentes'),
            FactItem('10 %', 'de los presentes en los demás centros'),
            FactItem('2 años', 'reciclaje de los primeros intervinientes'),
          ]),
          ParagraphBlock(
            'Si trabajan varias empresas en el mismo recinto, deben '
            'coordinarse e informarse mutuamente '
            '(§ 8 Arbeitsschutzgesetz). En ese marco puede acordarse el uso '
            'compartido de la organización de primeros auxilios de la '
            'estación. Eso regula la cooperación entre empresas — no tu '
            'obligación personal.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Eso no te exime',
            text: 'El deber de socorro según el § 323c StGB alcanza a cada '
                'persona individualmente. Que haya primeros intervinientes '
                'formados en la estación no cambia nada.',
          ),
          SubheadBlock('Así se maneja desde el punto de vista legal'),
          BulletsBlock([
            'Si ya hay alguien atendiendo y realmente ayuda de forma '
                'suficiente, no tienes que intervenir tú mismo',
            'La obligación de avisar a los servicios de emergencia y de '
                'buscar ayuda subsiste en todo caso',
            'Debes asegurarte de que realmente se está ayudando — mirar '
                'hacia otro lado pensando «ya se ocupará alguien» no basta',
            'Apoyar siguiendo las indicaciones del primer interviniente: '
                'señalizar, guiar a los servicios de emergencia, traer '
                'material, mantener alejados a los demás',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'En ruta estás solo',
            text: 'La mayor parte de tu jornada no estás en la estación, '
                'sino en la calle. Allí no hay primer interviniente de la '
                'estación — en una emergencia en la ruta, el primer '
                'interviniente eres tú.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Hacer la llamada de emergencia',
        blocks: [
          FactsBlock([
            FactItem('112', 'emergencias, en toda Europa'),
          ]),
          SubheadBlock('Las cinco preguntas clave'),
          StepsBlock([
            '¿Dónde ha ocurrido?',
            '¿Cuántas personas están heridas?',
            '¿Qué ha ocurrido?',
            '¿Quién llama?',
            'Esperar a que te pregunten',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Reglas básicas al ayudar',
            text: 'Mantener la calma · actuar rápido · cuidar la propia '
                'seguridad · señalizar el lugar del accidente · ayudar según '
                'tu leal saber y entender.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Documentación y comunicación',
        blocks: [
          ParagraphBlock(
            'Toda lesión se documenta — también el pequeño corte. Eso te '
            'protege si más adelante aparecen secuelas.',
          ),
          SubheadBlock('Qué debe constar en el libro de curas'),
          BulletsBlock([
            'Hora y lugar',
            'Cómo ocurrió',
            'Tipo y alcance de la lesión',
            'Nombre de la persona lesionada',
            'Testigos y primeros intervinientes',
          ]),
          FactsBlock([
            FactItem('> 3 días', 'de baja → hay que declarar el accidente'),
            FactItem('3 días', 'plazo para la declaración'),
            FactItem('5 años', 'conservación, confidencial'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Comunicar de inmediato',
            text: 'Los accidentes mortales, los accidentes múltiples y los '
                'daños graves para la salud los comunica el empresario sin '
                'demora — por eso informa siempre a tu empresa de inmediato.',
          ),
          ParagraphBlock(
            'Los botiquines deben estar completos. Comprueba la fecha de '
            'caducidad y comunica el material que falte.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 7
  SafetyChapterContent(
    id: 'ch07',
    title: 'Postura y movimiento',
    summary: 'Cuidar la espalda, mantener la concentración',
    asset: '${_a}ch07_sitzen_bewegen.svg',
    slides: [
      SafetySlide(
        title: 'Por qué estar sentado se convierte en un riesgo',
        asset: '${_a}ch07_sitzen_bewegen.svg',
        blocks: [
          ParagraphBlock(
            'Estar sentado mucho tiempo y con un asiento mal ajustado es más '
            'que incómodo — te cuesta atención y tiempo de reacción.',
          ),
          BulletsBlock([
            'Fatiga y pérdida de concentración',
            'Contracturas y dolores de espalda',
            'Molestias en la columna cervical y lumbar',
            'Accidentes por reacción tardía',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Ajustar bien el asiento',
        blocks: [
          ParagraphBlock(
            'Tómate dos minutos antes del primer trayecto. Siete ajustes son '
            'decisivos:',
          ),
          StepsBlock([
            'Altura del asiento y regulación longitudinal',
            'Profundidad de la banqueta',
            'Inclinación de la banqueta',
            'Inclinación del respaldo',
            'Apoyo lumbar',
            'Reposacabezas',
            'Volante y recorrido del cinturón',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Sentarse de forma dinámica',
            text: 'La espalda bien pegada al respaldo, sentado erguido — y '
                'cambiando ligeramente la postura una y otra vez. La mejor '
                'postura al sentarse es la siguiente.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ejercicios para hacer entre medias',
        blocks: [
          SubheadBlock('Sentado'),
          BulletsBlock([
            'Separar con fuerza las manos en el volante — mantener 3–6 '
                'segundos, 3 repeticiones',
            'Presionar las rodillas contra la presión de las manos — 3–6 '
                'segundos, 5 repeticiones',
            'Apoyarse en la banqueta y levantar el peso del cuerpo — '
                '3 repeticiones',
          ]),
          SubheadBlock('De pie'),
          BulletsBlock([
            'Estirar los brazos hacia arriba — unos 8 segundos, 3–5 '
                'repeticiones',
            'Manos en la nuca, codos hacia atrás — unos 8 segundos, 3–5 '
                'repeticiones',
            'Talón sobre una elevación de unos 30 cm, estirar la pierna — '
                'unos 8 segundos, 2–3 veces por pierna',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Una espalda entrenada aguanta más',
            text: 'Aprovecha el tiempo de la pausa — no tiempo adicional.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 8
  SafetyChapterContent(
    id: 'ch08',
    title: 'Carga mental y concentración',
    summary: 'Rendir y estar atento durante toda la jornada',
    asset: '${_a}ch08_psychische_belastung.svg',
    slides: [
      SafetySlide(
        title: 'Por qué esto forma parte de la prevención',
        asset: '${_a}ch08_psychische_belastung.svg',
        blocks: [
          ParagraphBlock(
            'Quien está bajo presión reacciona más despacio, pasa por alto '
            'más cosas y comete errores. Justo por eso la carga mental es un '
            'tema de seguridad — y no solo cuando alguien enferma.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Exigido por ley',
            text: 'Desde 2013 la evaluación de riesgos debe tener en cuenta '
                'expresamente también las cargas psíquicas en el trabajo '
                '(§ 5 apdo. 3 n.º 6 Arbeitsschutzgesetz). Lo que se evalúa '
                'son las condiciones de trabajo — no las personas '
                'individuales.',
          ),
          SubheadBlock('Qué genera presión en el día a día al volante'),
          BulletsBlock([
            'Ventanas de tiempo ajustadas, atascos, obras, búsqueda de '
                'aparcamiento',
            'Responsabilidades poco claras en la carga y la descarga',
            'Información sobre la ruta ausente o tardía',
            'Problemas técnicos del vehículo o del dispositivo',
            'Situaciones difíciles con clientes',
          ]),
          ParagraphBlock(
            'Son condiciones que la empresa puede cambiar. Por eso la regla '
            'más importante es: comunicarlo mientras todavía tenga solución.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Mantener la concentración — así funciona en la práctica',
        blocks: [
          SubheadBlock('Durante la ruta'),
          BulletsBlock([
            'Usar las pausas como herramienta: bajar un momento, mirar a lo '
                'lejos, dar unos pasos — eso restablece la atención de forma '
                'medible',
            'Beber lo suficiente y comer con regularidad',
            'No maniobrar con prisa — esos dos minutos salen más baratos '
                'que un golpe en la chapa',
            'Usar el móvil solo con el vehículo parado, introducir la '
                'dirección antes de arrancar',
            'Tras contactos difíciles con clientes, respirar hondo un '
                'momento antes de seguir',
          ]),
          SubheadBlock('Decirlo pronto en vez de aguantar'),
          ParagraphBlock(
            'Si algo no encaja de forma permanente, díselo a tu dispatcher — '
            'pronto y en concreto. Una ruta que habitualmente no se puede '
            'terminar, un vehículo que da problemas, una zona con falta '
            'constante de aparcamiento: todo eso se puede planificar si '
            'alguien lo sabe.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Comunicarlo en concreto ayuda más que aguantar',
            text: 'Di qué falla exactamente y dónde — no solo que fue '
                'estresante. Cuanto más concreto sea el aviso, más probable '
                'es que algo cambie en la planificación.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Después de sucesos especiales',
        blocks: [
          ParagraphBlock(
            'Algunas situaciones dejan huella: un accidente grave, un '
            'atraco, una intervención de primeros auxilios con personas '
            'gravemente heridas. Es una reacción normal ante un suceso '
            'anormal — y no es señal de debilidad.',
          ),
          BulletsBlock([
            'Comunica el suceso a tu responsable, aunque a ti no te haya '
                'pasado nada',
            'Tras los accidentes de trabajo existen ofertas de apoyo a '
                'través de la mutua profesional',
            'Muchas empresas tienen primeros intervinientes psicológicos o '
                'personas de referencia para traumas — pregunta en la '
                'oficina',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'En caso de emergencia aguda',
            text: 'Ante una crisis psíquica aguda en Alemania: '
                'Telefonseelsorge 0800 111 0 111 — gratuito, anónimo y '
                'disponible las 24 horas.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 9
  SafetyChapterContent(
    id: 'ch09',
    title: 'Conducción segura y control previo a la salida',
    summary: 'Dos minutos de control antes de cada ruta',
    asset: '${_a}ch09_sicheres_fahren.svg',
    slides: [
      SafetySlide(
        title: 'La vuelta alrededor del vehículo',
        asset: '${_a}ch09_sicheres_fahren.svg',
        blocks: [
          ParagraphBlock(
            'Antes de cada salida es obligatorio un control previo. Dura dos '
            'minutos y detecta justo las deficiencias que en ruta salen '
            'caras o resultan peligrosas.',
          ),
          BulletsBlock([
            'Alumbrado delantero y trasero',
            'Visibilidad — espejos y lunas limpios y sin daños',
            'Ruedas — presión, dibujo, fijación',
            'Frenos — prueba de frenado, presión de frenado',
            'Motor y tracción — aceite, refrigerante y líquido de frenos, '
                'agua del limpiaparabrisas, sin fugas',
            'Lonas y puertas cerradas',
            'Matrículas y placas de aviso limpias',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Carga y puesto de conducción',
        blocks: [
          SubheadBlock('Sujeción de la carga'),
          BulletsBlock([
            '¿Es el vehículo apto para esta carga?',
            '¿Están los amarres en buen estado?',
            '¿Está la carga asegurada y protegida frente a desplazamientos?',
            '¿Se respetan las cargas por eje y la masa máxima autorizada?',
          ]),
          SubheadBlock('Tu puesto de trabajo'),
          BulletsBlock([
            'Asiento y volante bien ajustados',
            'Instrumentos de control sin avisos de avería',
            'Prueba de frenado sin incidencias',
            'Sistemas de asistencia a la conducción activados y operativos',
            'Ventilación en funcionamiento',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'En invierno, además',
            text: 'Neumáticos adecuados, si procede cadenas o ayudas al '
                'arranque, suficiente anticongelante en el refrigerante y en '
                'el agua del limpiaparabrisas, rascador de hielo a bordo.',
          ),
          InstructionRefBlock(['baw_transporter', 'baw_winter']),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 10
  SafetyChapterContent(
    id: 'ch10',
    title: 'Averías y accidentes',
    summary: 'Señalizar, ayudar, documentar correctamente',
    asset: '${_a}ch10_pannen_unfaelle.svg',
    slides: [
      SafetySlide(
        title: 'Regla básica y avería',
        asset: '${_a}ch10_pannen_unfaelle.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'La regla básica',
            text: 'La protección propia va antes que la de los demás. La '
                'protección de las personas va antes que la de las cosas.',
          ),
          SubheadBlock('Cuando se anuncia una avería'),
          StepsBlock([
            'Buscar a tiempo un lugar adecuado para detenerse — por ejemplo '
                'si sube la temperatura del refrigerante',
            'Encender las luces de emergencia ya al ir perdiendo velocidad',
            'Si es posible, hasta el siguiente aparcamiento; si no, al '
                'extremo derecho de la calzada',
            'Poner el freno de estacionamiento y, de noche, las luces de '
                'posición',
            'Ponerte el chaleco reflectante — antes de bajar',
            'Colocar el triángulo de señalización',
          ]),
          FactsBlock([
            FactItem('100 m', 'triángulo, carretera convencional'),
            FactItem('150–400 m', 'triángulo, autopista'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Plan de emergencia en caso de accidente',
        blocks: [
          StepsBlock([
            'Detenerse — siempre, aunque no haya nadie',
            'Señalizar el lugar del accidente — luces de emergencia, freno '
                'de estacionamiento, de noche luces de posición, chaleco '
                'reflectante antes de bajar, triángulo',
            'Prestar primeros auxilios — sin demora',
            'Llamar al 112 — si es urgente, incluso antes de los primeros '
                'auxilios',
            'Intercambiar los datos personales — nombre, dirección, '
                'matrícula, seguro',
            'Llamar a la policía — si hay daños personales, daños '
                'materiales elevados o sospecha de alcohol/drogas',
            'Asegurar las pruebas — fotos del lugar y de los daños, datos '
                'de contacto de los testigos',
            'Informar a la empresa y acordar cómo proceder, comprobar tu '
                'aptitud para seguir conduciendo, recoger de nuevo el '
                'triángulo',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Daño en un coche aparcado y la lesión más frecuente',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Una nota no basta',
            text: 'Si rozas un coche aparcado y no hay nadie: espera al '
                'menos 30 minutos. Después deja tu nombre y dirección Y '
                'comunica el accidente sin demora en la comisaría de policía '
                'más cercana. Si no, es un delito de fuga.',
          ),
          SubheadBlock('Dónde se lesionan realmente los conductores'),
          FactsBlock([
            FactItem('51,6 %', 'caídas al mismo y a distinto nivel'),
            FactItem('7,2 %', 'accidentes de tráfico'),
          ]),
          ParagraphBlock(
            'La mayoría de los accidentes declarables no ocurren en el '
            'tráfico, sino al subir y bajar de la cabina o de la zona de '
            'carga.',
          ),
          DoDontBlock(
            doTitle: 'Correcto',
            dos: [
              'Usar los estribos y asideros previstos',
              'Contacto de tres puntos al subir y bajar',
              'Mantener los estribos limpios y despejados',
              'Llevar calzado adecuado',
            ],
            dontTitle: 'Peligroso',
            donts: [
              'Saltar desde la cabina o desde la zona de carga',
              'Pisar estribos sucios, con hielo u obstruidos',
              'Subirse a piezas del vehículo no previstas para ello o a la '
                  'carga',
              'Utilizar escaleras en mal estado',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 11
  SafetyChapterContent(
    id: 'ch11',
    title: 'La regla de los 3 puntos',
    summary: 'Subir y bajar — la regla individual más importante',
    asset: '${_a}step3p_cover.svg',
    slides: [
      SafetySlide(
        title: 'Siempre 3 de 4 puntos de contacto',
        asset: '${_a}step3p_cover.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'La regla básica',
            text: '2 manos + 1 pie  O BIEN  2 pies + 1 mano. Tres puntos '
                'mantienen siempre contacto firme con el vehículo.',
          ),
          ParagraphBlock(
            'Subes y bajas decenas de veces al día — con prisa, bajo la '
            'lluvia, con las manos llenas. Justo ahí ocurren la mayoría de '
            'los accidentes. Tres puntos firmes te dan sujeción y evitan '
            'caídas y lesiones de tobillo, rodilla y espalda.',
          ),
          FactsBlock([
            FactItem('51,6 %', 'de los accidentes son caídas'),
            FactItem('7,2 %', 'son accidentes de tráfico'),
          ]),
          ParagraphBlock(
            'Ningún otro gesto de la jornada laboral evita tantas lesiones '
            'como este. Por eso está al final de esta instrucción — como '
            'aquello que debe quedarse grabado.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Las cuatro reglas en detalle',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}step3p_01_face.svg',
              title: 'De cara al vehículo',
              caption: 'Baja siempre de cara al vehículo — nunca saltes '
                  'hacia atrás ni de lado. Saltar es la causa de accidente '
                  'más frecuente. Usa siempre el estribo y los asideros.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_02_hands.svg',
              title: 'Primero dejar la carga, luego agarrarse',
              caption: 'Nada de paquetes en la mano al subir y bajar. Deja '
                  'primero el envío o guarda las piezas pequeñas en la bolsa '
                  'o el cinturón — las manos quedan libres para sujetarte.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_03_onepoint.svg',
              title: 'Mover solo un punto',
              caption: 'Mueve siempre solo una mano o un pie mientras los '
                  'otros tres tienen sujeción firme. No te precipites — '
                  'tampoco cuando la ruta apremia.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_04_steps.svg',
              title: 'Atención a los estribos y a la sujeción',
              caption: 'Vigila la humedad, la nieve, el aceite y la '
                  'suciedad. Pisa con calma y de forma controlada y limpia '
                  'los estribos antes si hace falta.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Dos cosas que forman parte de ello',
        blocks: [
          SubheadBlock('Calzado de seguridad de caña media'),
          ParagraphBlock(
            'El calzado de caña media envuelve el tobillo y estabiliza la '
            'articulación bastante mejor — justo ahí es donde se produce la '
            'torcedura al bajar.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: '¿Ya te has torcido el tobillo alguna vez?',
            text: 'Quien ya ha tenido problemas de tobillo debería pedir que '
                'le den calzado de caña media — antes de la siguiente ruta, '
                'no después.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}step3p_05_phone.svg',
              title: 'Nada de móvil privado en la mano',
              caption: 'Hablar, escribir y deslizar por la pantalla te resta '
                  'concentración — y justo de ahí salen las caídas y los '
                  'accidentes. Las llamadas y los mensajes privados esperan '
                  'a la pausa. Al subir y bajar, el móvil va guardado.',
            ),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'En resumen',
            text: 'De cara al vehículo · mantener tres puntos · manos libres '
                '· calzado de seguridad de caña media · nada de móvil '
                'privado · usar los estribos en vez de saltar.',
          ),
        ],
      ),
    ],
  ),
];
