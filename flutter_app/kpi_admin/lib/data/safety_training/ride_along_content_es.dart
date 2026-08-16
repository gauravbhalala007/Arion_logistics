// lib/data/safety_training/ride_along_content_es.dart
//
// Contenidos de la formación Ride Along — versión española.
// La estructura es idéntica a la versión alemana (máster): los capítulos
// ra1–ra5, las mismas diapositivas, los mismos bloques y los mismos
// valores.
//
// El «Ride Along» es la ruta de acompañamiento de dos días para los
// conductores nuevos: el día 1 con un número menor de paradas, el día 2
// con bastantes más. El formador va repasando una lista de verificación,
// firma cada punto y al final da un feedback; la hoja se entrega como
// foto al dispatcher responsable.
//
// Objetivo de esta formación: LA PREPARACIÓN. Quien la repasa antes no
// oye por primera vez los temas de esos dos días, sino que puede
// preguntar de forma concreta y aprovechar la ruta de acompañamiento de
// forma consciente.
//
// Compatible con varios operadores: SIN nombres de personas, sin nombres
// de estaciones, sin cifras específicas de una empresa como regla. El
// número de paradas, los horarios de la Waiting Area, el inicio de la
// jornada y el lado de aparcamiento son indicaciones de cada estación —
// las comunica el formador. Las herramientas de la empresa, como el
// registro horario, aparecen solo como ejemplo («p. ej. Kenjo»). Pueden
// seguir siendo concretas: las herramientas de Amazon (Flex, Mentor,
// ATLAS, Scorecard), la app CoDriver, las reglas de pausa según el § 4
// ArbZG (ley alemana de jornada laboral) y el Green Book según el § 1
// apdo. 6 FPersV — las tres son válidas en cualquier empresa. Para este
// tema no hay ilustraciones, por eso `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> rideAlongContentEs = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ra1',
    title: 'Qué es el Ride Along',
    summary: 'Dos días de ruta acompañada: objetivo, desarrollo, quién '
        'participa y cómo se evalúa',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Dos días junto a un conductor con experiencia',
        blocks: [
          ParagraphBlock(
            'El Ride Along es tu ruta de acompañamiento al empezar: dos '
            'días de trabajo en los que un conductor con experiencia te '
            'acompaña como formador. No conoces la ruta a través de una '
            'presentación, sino exactamente allí donde ocurre: en la '
            'estación, en la Loading Area y en la calle.',
          ),
          FactsBlock([
            FactItem('2 días', 'ruta acompañada con un formador'),
            FactItem('Día 1', 'menor número de paradas — en muchas empresas '
                'unas 20'),
            FactItem('Día 2', 'bastantes más paradas — en muchas empresas '
                'unas 70'),
          ]),
          ParagraphBlock(
            'Los dos días se apoyan el uno en el otro. El primer día se '
            'centra en los procesos: cómo se entra en la estación, qué '
            'apps se abren y cuándo, cómo se carga, cuándo toca la pausa. '
            'El segundo día la cantidad sube claramente y conduces y '
            'entregas tú mismo — el formador te acompaña, pero no te '
            'sustituye.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Las cifras de paradas son valores orientativos',
            text: 'Cuántas paradas están previstas realmente el día 1 y el '
                'día 2 lo fija tu empresa o tu estación. Es habitual unas '
                '20 el primer día y unas 70 el segundo — pero lo único '
                'vinculante es la indicación que te dé tu formador o tu '
                'dispatcher responsable.',
          ),
          BulletsBlock([
            'Los dos días se hacen con tu propia cuenta, no con la del '
                'formador',
            'Las paradas cuentan como trabajo real, no como un simulacro',
            'El formador explica, te lo muestra y después te deja hacerlo a '
                'ti',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'En pocas palabras',
            text: 'El Ride Along es tu integración en la operativa real. Al '
                'final deberías poder hacer una ruta solo — esa es la vara '
                'de medir a la que se orienta todo.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Quién participa y quién hace qué',
        blocks: [
          ParagraphBlock(
            'En el Ride Along intervienen tres roles. Si sabes quién es '
            'responsable de qué, no preguntas a la persona equivocada y no '
            'pierdes tiempo.',
          ),
          TableBlock(
            headers: ['Rol', 'Tarea'],
            rows: [
              [
                'Tú',
                'Conduces, entregas, preguntas, participas — los dos días '
                    'con tu propia cuenta',
              ],
              [
                'Formador',
                'Conductor con experiencia: explica cada punto, te lo '
                    'muestra, te observa, marca la lista de verificación y '
                    'firma',
              ],
              [
                'Dispatcher',
                'Planifica los dos días, es la persona de contacto ante '
                    'problemas y al final recibe la foto de la lista de '
                    'verificación',
              ],
            ],
          ),
          ParagraphBlock(
            'El formador no es tu superior ni tu examinador en el sentido '
            'de una autoridad. Es el compañero que mejor conoce la '
            'estación. Justo por eso es la dirección correcta para '
            'cualquier pregunta que se te ocurra durante los dos días — '
            'también para las que te parezcan banales.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Preguntar no cuesta nada',
            text: 'Una pregunta en el Ride Along es barata. Esa misma '
                'pregunta en la tercera semana, solo en la ruta y con un '
                'reparto lleno por delante, es cara.',
          ),
        ],
      ),
      SafetySlide(
        title: 'La lista de verificación y el feedback',
        blocks: [
          ParagraphBlock(
            'El formador va repasando una hoja fija: la lista de '
            'verificación del Ride Along. En ella figura, para cada uno de '
            'los dos días, qué se tiene que haber explicado y mostrado: '
            'desde la inspección del vehículo y las reglas de pausa hasta '
            'los paquetes con contraseña. Cada punto se firma y cada día se '
            'cierra con fecha y firma.',
          ),
          BulletsBlock([
            'La lista de verificación es la prueba de que has sido formado',
            'También te protege a ti: lo que está marcado, se te ha '
                'explicado',
            'Después del segundo día el formador da un feedback sobre tu '
                'rendimiento y tus capacidades de conducción',
          ]),
          ParagraphBlock(
            'No es un examen con guillotina. Nadie espera que el primer día '
            'hagas la ruta como un conductor con tres años de experiencia. '
            'Pero sí se evalúa: el formador anota cómo trabajas y la hoja '
            'llega a la empresa. Quien piensa de forma visible, es puntual '
            'y acepta las indicaciones recibe un buen feedback — aunque '
            'vaya lento.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'La diferencia que importa',
            text: 'No se evalúa si ya sabes hacerlo todo, sino si estás '
                'dispuesto a aprender y si te tomas las reglas en serio. '
                'Los errores son normales. Que te expliquen un error dos '
                'veces y aun así lo ignores, no lo es.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: el primer día confundes dos veces el '
                'orden de los paquetes en el carro y necesitas bastante más '
                'tiempo del previsto para tus paradas. Estás convencido de '
                'que con eso el Ride Along se ha ido al traste. ¿Es así?',
            answer: 'No. Para eso está justamente el primer día. El formador '
                'espera algo de ritmo apenas a partir del segundo día y de '
                'verdad en las semanas siguientes. Lo que evalúa el primer '
                'día es otra cosa: ¿preguntas cuando no estás seguro? '
                '¿Cometes el mismo error también a la tercera? ¿Después '
                'ordenas mejor por iniciativa propia? Quien menciona el '
                'error y en el siguiente carro procede conscientemente de '
                'otra manera deja mejor impresión que alguien rápido que no '
                'cuestiona nada.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Lista de verificación: capítulo 1',
        blocks: [
          ChecklistBlock(
            title: 'Esto me llevo del capítulo 1',
            items: [
              'El Ride Along son dos días de trabajo con un formador',
              'El día 1 menos paradas, el día 2 bastantes más — la cifra '
                  'exacta la fija mi empresa (es habitual unas 20 y unas 70)',
              'Los dos días se hacen con mi propia cuenta',
              'El formador explica, me lo muestra y me deja hacerlo a mí',
              'Marca una lista de verificación y firma cada día',
              'Después del día 2 hay un feedback sobre rendimiento y '
                  'capacidades de conducción',
              'Es una integración, pero se evalúa — la disposición a '
                  'aprender cuenta más que el ritmo',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Una frase para los dos días',
            text: '«Prefiero preguntar una vez de más que una de menos: '
                'para eso están estos dos días.»',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ra2',
    title: 'El primer día',
    summary: 'Primeras paradas, arranque de las apps, inspección, Loading '
        'Area, pausas y llaves del vehículo',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Las primeras paradas con tu propia cuenta',
        blocks: [
          ParagraphBlock(
            'El primer día tiene un número mínimo de paradas que debes '
            'haber conducido y entregado — con tu propia cuenta. Se '
            'mantiene bajo a propósito (en muchas empresas unas 20); la '
            'cifra vinculante te la dice tu formador para tu estación. El '
            'día 1 no se trata de cantidad, sino de que cada movimiento te '
            'salga bien una vez.',
          ),
          ParagraphBlock(
            'Lo importante es la cuenta propia. No la del formador, no un '
            'acceso colectivo. Todo lo que entregas ese día va a tu nombre '
            '— exactamente igual que cuenta después. Solo así ven el '
            'formador y la empresa cómo es realmente tu entrega.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Sin acceso no hay Ride Along',
            text: 'Si tu cuenta no funciona por la mañana, dilo enseguida — '
                'antes de salir, no en la primera parada. Un acceso sin '
                'aclarar cuesta el día entero.',
          ),
          SubheadBlock('La app CoDriver'),
          ParagraphBlock(
            'CoDriver es la app de la empresa — la app en la que estás '
            'leyendo ahora mismo. Está separada de las herramientas de '
            'Amazon: Amazon gestiona la ruta, CoDriver todo lo relacionado '
            'con tu trabajo en la empresa. El formador la repasa contigo el '
            'primer día.',
          ),
          BulletsBlock([
            'Plan de turnos y wave plan: cuándo trabajas y en qué ola '
                'empiezas',
            'Comunicar ausencias y bajas por enfermedad',
            'DA Academy: formaciones como esta, además de las instrucciones '
                'de servicio',
            'Mensajes y notificaciones de la empresa',
            'Partes de accidentes y de daños',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Recuerda',
            text: 'Las apps de Amazon gestionan la ruta. CoDriver gestiona '
                'tu relación laboral. Necesitas las dos a diario, y las dos '
                'hay que mirarlas una vez a fondo el día 1.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Llegar: horarios, lado de aparcamiento, Waiting Area',
        blocks: [
          ParagraphBlock(
            'El día no empieza con la primera parada, sino con la llegada a '
            'la estación. Hay tres cosas que el formador te recalca el '
            'primer día, porque se repiten cada día de trabajo.',
          ),
          SubheadBlock('1 — Horarios de trabajo'),
          ParagraphBlock(
            'Tu turno tiene un inicio fijo. Está en el plan de turnos en '
            'CoDriver, y «inicio» significa: a esa hora estás listo para '
            'trabajar en la estación, no de camino hacia allí. Las horas '
            'concretas de tu estación te las dice el formador; varían según '
            'la ubicación y la ola.',
          ),
          SubheadBlock('2 — Lado de aparcamiento'),
          ParagraphBlock(
            'Cada estación tiene una regulación sobre dónde pueden estar '
            'los vehículos privados y en qué lado se colocan las furgonetas. '
            'No es una manía: en el patio maniobran muchos vehículos a la '
            'vez, a menudo marcha atrás y con mala visibilidad. Quien '
            'aparca mal bloquea un carril o se queda en el ángulo muerto de '
            'quien está maniobrando. El formador te enseña el lado que te '
            'corresponde.',
          ),
          SubheadBlock('3 — Horarios de la Waiting Area'),
          ParagraphBlock(
            'La Waiting Area es la zona en la que esperas hasta que se '
            'llame a tu carro o a tu posición de carga. Para ello hay '
            'franjas horarias fijas por ola. Quien llega demasiado pronto '
            'colapsa la zona; quien llega tarde pierde su llamada y retrasa '
            'toda la ola. Las horas exactas de tu estación te las dice el '
            'formador el primer día — apúntatelas.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Los tres datos que deberías anotar',
            text: 'Inicio de turno, lado de aparcamiento y tu franja de la '
                'Waiting Area. Esos tres datos los necesitas cada mañana a '
                'partir del día siguiente — y entonces ya nadie te lo tiene '
                'que preguntar.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: llegas puntual a la puerta al inicio '
                'del turno, pero luego tardas diez minutos en encontrar '
                'aparcamiento porque has buscado en el lado equivocado. Con '
                'eso llegas tarde a la Waiting Area. ¿Qué gravedad tiene?',
            answer: 'Más de la que parece. La llamada en la Waiting Area '
                'está cadenciada: si pierdes tu franja, te quedas por '
                'detrás de los demás conductores de tu ola. Tu carro '
                'espera, tu vehículo puede estar bloqueando una posición y '
                'tu salida se retrasa más que los diez minutos que has '
                'perdido. Por eso el lado de aparcamiento y la hora de la '
                'Waiting Area van juntos: «puntual en la puerta» no es lo '
                'mismo que «puntual en la Waiting Area». Cuenta también el '
                'tiempo de aparcar y de caminar.',
          ),
        ],
      ),
      SafetySlide(
        title: 'El arranque: registro horario, Mentor y Flex',
        blocks: [
          ParagraphBlock(
            'Tres sistemas tienen que estar en marcha al principio del '
            'turno — a tiempo y en este orden. Cada uno tiene una finalidad '
            'distinta y cada uno causa problemas si se arranca demasiado '
            'tarde.',
          ),
          StepsBlock([
            'El registro horario de tu empresa (p. ej. Kenjo): fichar la '
                'entrada al inicio del turno. Lo que no arranques aquí no '
                'es tiempo de trabajo remunerado y después falta en tu '
                'nómina. Qué sistema usa tu empresa te lo enseña el '
                'formador.',
            'Mentor — la app de comportamiento al volante de Amazon: tiene '
                'que estar en marcha antes de que salgas. Registra tu forma '
                'de conducir y aporta los datos de tu score.',
            'Flex — la app de reparto de Amazon: aquí recibes tu ruta, '
                'escaneas los paquetes y documentas cada entrega.',
          ]),
          SubheadBlock('Las 4 horas de Mentor'),
          ParagraphBlock(
            'Mentor no funciona de forma ilimitada: la app graba unas '
            'cuatro horas seguidas cada vez. Después tienes que volver a '
            'arrancarla, si no el resto de tu ruta queda sin registrar. '
            'Justo ese es el error más frecuente de los principiantes: la '
            'app se arrancó bien por la mañana, pero después de la pausa no '
            'se volvió a activar. El formador te enseña el primer día en '
            'qué se nota que Mentor sigue funcionando.',
          ),
          FactsBlock([
            FactItem('4 h', 'duración de grabación de Mentor seguida'),
            FactItem('antes de salir', 'arrancar Mentor — no ya en ruta'),
            FactItem('tras la pausa', 'comprobar Mentor y volver a '
                'arrancarlo'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'El error más frecuente del primer día',
            text: 'Flex funciona, Mentor no. Entonces haces tu ruta, pero '
                'tu forma de conducir no se registra — y en la empresa un '
                'tiempo de Mentor que falta llama tanto la atención como un '
                'mal valor.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: a las 14 h te das cuenta de que Mentor '
                'no funciona desde la pausa. ¿Qué haces: seguir hasta el '
                'final del turno y hacerlo mejor mañana, o reaccionar de '
                'inmediato?',
            answer: 'Reaccionar de inmediato: parar en el siguiente sitio '
                'seguro, volver a arrancar Mentor y continuar. El error '
                'típico es pensar que medio día sin grabación da igual '
                'porque uno ha conducido correctamente. No da igual: para '
                'la empresa un hueco parece un hueco, no una buena '
                'conducción. Y seguir conduciendo significa agrandar ese '
                'hueco cada hora. Comunícaselo además a tu formador o a tu '
                'dispatcher responsable, para que el hueco quede explicado.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Inspección del vehículo y Loading Area',
        blocks: [
          SubheadBlock('La inspección del vehículo'),
          ParagraphBlock(
            'Antes de salir se revisa el vehículo — y después de la ruta '
            'otra vez. La inspección es una revisión visual con '
            'documentación: das una vuelta alrededor de la furgoneta, miras '
            'cada lado, compruebas las funciones y dejas constancia de lo '
            'que ves.',
          ),
          BulletsBlock([
            'Vuelta por fuera: carrocería, parachoques, espejos, cristales '
                '— cada abolladura y cada arañazo',
            'Neumáticos: dibujo, daños visibles, impresión de la presión',
            'Luces: cruce, freno, intermitentes, luz de marcha atrás',
            'Habitáculo y zona de carga: limpieza, piezas sueltas, mampara',
            'Equipamiento: triángulo, chaleco reflectante, botiquín',
            'Kilometraje y nivel de combustible o de carga',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Por qué cuenta la inspección ANTES de la ruta',
            text: 'Un daño que documentas antes es un daño previo. Ese '
                'mismo daño sin documentar es, por la tarde, tu daño. Los '
                'dos minutos de la vuelta al vehículo son el seguro más '
                'barato de tu jornada.',
          ),
          SubheadBlock('Cargar el carro en la Loading Area'),
          ParagraphBlock(
            'En la Loading Area está tu carro con los paquetes de tu ruta. '
            'Cómo lo colocas en la furgoneta decide todo tu día: quien '
            'carga sin ordenar busca en cada parada — y eso, a lo largo de '
            'una ruta completa, suma horas.',
          ),
          BulletsBlock([
            'Cargar en el orden de la ruta: lo que sale primero entra el '
                'último y queda delante',
            'Paquetes pesados abajo, ligeros arriba — no al revés',
            'Asegurar la carga: nada debe deslizarse hacia delante al '
                'frenar',
            'No apilar nada en el pasillo ni delante de la puerta corredera',
            'Paquetes especiales (contraseña, ATLAS, mercancía voluminosa) '
                'aparte y a mano',
            'Devolver el carro vacío a donde corresponde — no dejarlo en '
                'cualquier sitio',
          ]),
          DoDontBlock(
            doTitle: 'Así se hace bien',
            dos: [
              'Al cargar, pensar ya en cuál es la primera parada',
              'Al levantar, doblar las rodillas y llevar la carga pegada al '
                  'cuerpo',
              'Preguntar cuando no sepas dónde va un paquete',
            ],
            dontTitle: 'Esto te cuesta tiempo después',
            donts: [
              'Meterlo todo de cualquier manera y «ordenar sobre la marcha»',
              'Poner paquetes sobre la mampara o en la zona del conductor',
              'Dejar el carro en medio del carril',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Pausas, llaves y cierre automático',
        blocks: [
          SubheadBlock('Pausas: 30 y 45 minutos'),
          ParagraphBlock(
            'Hay dos duraciones de pausa, y cuál se aplica a ti depende '
            'únicamente de tu tiempo de trabajo ese día. A diferencia de '
            'los horarios de la Waiting Area o de las cifras de paradas, '
            'esto no lo fija tu estación, sino la ley: el § 4 de la ley '
            'alemana de jornada laboral (ArbZG). La regla es por tanto '
            'igual en cualquier empresa y no es negociable.',
          ),
          FactsBlock([
            FactItem('30 min', 'con más de 6 y hasta 9 horas de trabajo'),
            FactItem('45 min', 'con más de 9 horas de trabajo'),
            FactItem('15 min', 'pausa parcial mínima computable'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 4 ArbZG — la base legal',
            text: 'La ley de jornada laboral prescribe, con más de 6 horas '
                'de trabajo, al menos 30 minutos de pausa, y con más de 9 '
                'horas al menos 45 minutos. Trabajar más de 6 horas sin '
                'pausa está expresamente prohibido.',
          ),
          ParagraphBlock(
            'La pausa se puede repartir, pero cada parte debe durar al '
            'menos 15 minutos — dos veces 15 minutos dan por tanto la pausa '
            'de 30, y tres veces 15 minutos la de 45. Cinco minutos sueltos '
            'no cuentan. Además, es importante: la pausa tiene que haber '
            'empezado antes de que transcurran seis horas de trabajo, no al '
            'final del turno.',
          ),
          ParagraphBlock(
            'Por qué hay que registrarla: tu pausa no es tiempo de trabajo '
            'remunerado, y la empresa tiene que poder demostrar que '
            'realmente la has hecho. Por eso se anota en el registro '
            'horario — no por desconfianza, sino porque una pausa no '
            'documentada se considera, en una inspección, una pausa no '
            'disfrutada. Eso es una infracción de la que responde la '
            'empresa. El formador te enseña dónde la anotas exactamente.',
          ),
          SubheadBlock('Cierre automático y la llave'),
          ParagraphBlock(
            'Muchas Sprinter se cierran automáticamente: si la puerta se '
            'cierra de golpe o el vehículo empieza a rodar, el cierre '
            'centralizado se activa solo. Es una protección antirrobo para '
            'tu carga — y es exactamente el motivo por el que la llave va '
            'siempre encima.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'La llave va en tu cuerpo',
            text: 'Ni en el asiento, ni en la bandeja, ni en el bolsillo de '
                'la chaqueta que se queda dentro del vehículo. Llave en el '
                'bolsillo del pantalón o en la cinta del cinturón — cada '
                'vez que te bajas.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: paras un momento, dejas la llave puesta '
                'en el contacto, coges dos paquetes y cierras la puerta '
                'corredera con el pie. El cierre centralizado se activa. '
                '¿Qué pasa ahora?',
            answer: 'Te quedas con dos paquetes delante de una furgoneta '
                'cerrada en la que están tu llave, tu móvil, el resto de la '
                'carga y normalmente también tus documentos. El día se ha '
                'acabado: necesitas ayuda de la estación o un cerrajero, '
                'toda tu ruta se para y los paquetes que hay dentro no '
                'llegan hoy a sus clientes. El error típico es pensar «si '
                'solo me alejo diez segundos» — el cierre automático no '
                'distingue entre diez segundos y diez minutos. Por eso rige '
                'sin excepción: llave fuera, llave encima, y solo entonces '
                'bajarse.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Fin de ruta: cerrar Flex e inspección',
        blocks: [
          ParagraphBlock(
            'El día no termina en la última parada, sino en la estación. '
            'Allí hay dos cosas en la lista de verificación del formador — '
            'y las dos se olvidan con facilidad, porque uno está cansado y '
            'quiere irse a casa.',
          ),
          StepsBlock([
            'Cerrar la app Flex correctamente: finalizar la ruta, entregar '
                'las devoluciones y salir de la app — no basta con guardar '
                'el móvil.',
            'Inspección del vehículo después de la ruta: la misma vuelta '
                'que por la mañana, ahora mirando daños nuevos, kilometraje '
                'y nivel de combustible o de carga.',
            'Entregar el vehículo limpio y vacío, revisar la zona de carga '
                '— no se queda ningún paquete dentro.',
            'Fichar la salida en el registro horario de tu empresa (p. ej. '
                'Kenjo) y dejar la llave donde corresponde.',
          ]),
          ParagraphBlock(
            'La inspección final es la contrapartida de la inspección de la '
            'mañana. Solo con las dos juntas queda claro qué ha pasado ese '
            'día en el vehículo — y qué no. Si falta la de la tarde, a la '
            'mañana siguiente ya no se le puede atribuir un daño a nadie, y '
            'el siguiente conductor hereda tu problema o tú el suyo.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Frase para el final de la jornada',
            text: 'Flex cerrado, vuelta al vehículo, zona de carga vacía, '
                'salida fichada, llave entregada. Solo entonces se acaba la '
                'jornada.',
          ),
          ChecklistBlock(
            title: 'Esto me llevo del día 1',
            items: [
              'El número de paradas que fija mi empresa, hechas con mi '
                  'propia cuenta',
              'Conozco la app CoDriver y sé qué encuentro en ella',
              'Conozco el inicio de mi turno, la regulación de aparcamiento '
                  'de mi estación y mi franja de la Waiting Area',
              'Arranco el registro horario (p. ej. Kenjo), Mentor y Flex a '
                  'tiempo y en este orden',
              'Sé que Mentor graba unas 4 horas y que después hay que '
                  'volver a arrancarlo',
              'Hago la inspección del vehículo antes y después de la ruta',
              'Cargo el carro en el orden de la ruta, lo pesado abajo, la '
                  'carga asegurada',
              'Conozco la regla de pausas según el § 4 ArbZG: 30 minutos a '
                  'partir de más de 6 horas, 45 minutos a partir de más de '
                  '9 horas — y la anoto',
              'La llave va siempre encima, porque la Sprinter se cierra '
                  'automáticamente',
              'Al final cierro Flex, hago la inspección y ficho la salida',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ra3',
    title: 'El segundo día',
    summary: 'Bastantes más paradas por tu cuenta, Scorecard, protección '
        'del vehículo, Green Book, paquetes especiales, repostaje y carga',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Bastantes más paradas — conduces tú, entregas tú',
        blocks: [
          ParagraphBlock(
            'El segundo día la relación se invierte. El número de paradas '
            'sube claramente — en muchas empresas hasta unas 70; lo '
            'vinculante es lo que fije tu estación — y realizas las paradas '
            'por tu cuenta: conduces, navegas, escaneas, entregas, '
            'documentas. El formador va al lado y solo interviene cuando '
            'hace falta.',
          ),
          FactsBlock([
            FactItem('más', 'paradas que el día 1 — la cifra según lo que '
                'fije la empresa'),
            FactItem('tú mismo', 'conducir y entregar — el formador solo '
                'acompaña'),
            FactItem('1 día', 'hasta tu primera ruta propia'),
          ]),
          ParagraphBlock(
            'Ese es el verdadero sentido del segundo día: que hayas vivido '
            'una vez cómo se siente una ruta completa — con el ritmo, el '
            'ordenar entre parada y parada, los clientes que no abren y la '
            'sensación de que el reloj corre. Cuando lo has hecho una vez '
            'con alguien al lado, la primera vez a solas ya solo es la '
            'mitad de grande.',
          ),
          BulletsBlock([
            'No dejes que te quiten nada que puedas hacer tú mismo — aunque '
                'vaya más lento',
            'Pregunta enseguida por cada parada que te haya resultado rara',
            'Fíjate en lo que tienes que apuntar: códigos, procesos, '
                'personas de contacto',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'La vara de medir del día 2',
            text: 'No «¿hace la ruta en tiempo récord?», sino «¿se le '
                'podría mandar solo mañana?». Eso es exactamente lo que '
                'valora el formador.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Scorecard, calidad y rendimiento',
        blocks: [
          ParagraphBlock(
            'Tu trabajo se mide. La Scorecard de Amazon resume semana a '
            'semana cómo habéis conducido tú y tu empresa. El segundo día '
            'el formador te explica qué valores aparecen en ella y cómo '
            'influyes en ellos — porque casi todos los valores nacen de '
            'algo que tienes tú mismo en la mano.',
          ),
          BulletsBlock([
            'Calidad de entrega: ¿se entregó o se dejó el paquete en el '
                'lugar correcto y se documentó bien?',
            'Comportamiento al volante según Mentor: frenadas, '
                'aceleraciones, curvas, uso del móvil, cinturón',
            'Fiabilidad: salida puntual, ruta completada, devolución '
                'correcta',
            'Valoraciones de clientes: las quejas y los elogios también '
                'acaban en la evaluación',
          ]),
          ParagraphBlock(
            'Calidad y rendimiento son dos cosas distintas que se confunden '
            'a menudo. El rendimiento es la cantidad: cuántas paradas en '
            'cuánto tiempo. La calidad es lo limpiamente que se cerró cada '
            'parada. Un conductor con mucho rendimiento y mala calidad '
            'genera más trabajo del que ahorra — cada reclamación le cuesta '
            'a la empresa varias veces el minuto que se ahorró al '
            'principio.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'El error más caro es el error rápido',
            text: 'Dejar un paquete en el sitio equivocado y seguir '
                'rápidamente te ahorra un minuto y le cuesta a la empresa '
                'una reclamación, una investigación y, en caso de duda, el '
                'valor de la mercancía.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: el cliente no abre, todavía te quedan '
                '30 paradas. Dejas el paquete detrás del cubo de basura y '
                'haces rápidamente una foto de la puerta. ¿Por qué es un '
                'problema?',
            answer: 'Por partida doble. Primero, el lugar donde lo has '
                'dejado no coincide con lo que has documentado — si el '
                'cliente no encuentra el paquete, tu entrega queda sin '
                'justificar. Segundo, dejarlo detrás de un cubo de basura '
                'no es un lugar adecuado: se ve desde la calle y el cubo se '
                'vacía. Lo correcto es seguir la vía prevista — vecino, '
                'lugar seguro autorizado por el cliente o devolución — y '
                'documentar exactamente lo que has hecho de verdad. Ese '
                'minuto ahorrado se enfrenta a una reclamación que os '
                'cuesta bastante más a ti, al cliente y a la empresa.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Protección del vehículo, accidentes, limpieza y cuidado',
        blocks: [
          ParagraphBlock(
            'La furgoneta es tu puesto de trabajo y la herramienta más cara '
            'que te confía la empresa. Cómo la tratas es el segundo día un '
            'punto propio de la lista de verificación — en tres partes.',
          ),
          SubheadBlock('1 — Evitar daños'),
          BulletsBlock([
            'Marcha atrás solo cuando no haya otra opción — y entonces '
                'despacio, mirando por los dos espejos',
            'Ante una situación poco clara, bajarse y mirar en lugar de '
                'adivinar',
            'Entradas estrechas, ramas bajas, aparcamientos subterráneos y '
                'bolardos son las fuentes de daños más frecuentes',
            'Mantener la distancia y frenar con previsión — eso cuida el '
                'vehículo y la Scorecard a la vez',
          ]),
          SubheadBlock('2 — Si aun así pasa algo'),
          StepsBlock([
            'Parar y señalizar: luces de emergencia, chaleco reflectante, '
                'triángulo.',
            'Atender a los heridos; si hay daños personales, llamar siempre '
                'al 112.',
            'No cambiar nada, hacer fotos: situación general, daños, '
                'matrículas, entorno.',
            'Si hay un vehículo ajeno o la culpa no está clara, avisar a la '
                'policía — también con daños pequeños.',
            'Informar de inmediato a tu dispatcher responsable y notificar '
                'el incidente en CoDriver.',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Nunca seguir conduciendo',
            text: 'Incluso un arañazo pequeño en un vehículo ajeno es, sin '
                'notificarlo, una fuga tras un accidente: un delito. Una '
                'nota bajo el limpiaparabrisas no basta legalmente.',
          ),
          SubheadBlock('3 — Limpieza y cuidado'),
          BulletsBlock([
            'Vaciar la cabina a diario: sin basura, sin botellas, sin '
                'papeles',
            'Barrer la zona de carga y comprobar si hay paquetes olvidados',
            'Mantener limpios cristales y espejos — la mala visibilidad es '
                'un problema de seguridad, no un defecto estético',
            'Comunicar los consumibles y los ruidos llamativos, no '
                'ignorarlos',
          ]),
          RevealBlock(
            prompt: 'Caso práctico: al maniobrar rozas un bolardo. El '
                'vehículo tiene un arañazo, nada más, y nadie lo ha visto. '
                '¿Lo notificas?',
            answer: 'Sí, siempre y el mismo día. No se trata de culpa, sino '
                'de atribución: un arañazo notificado es un incidente que '
                'se tramita. Ese mismo arañazo, que a la mañana siguiente '
                'encuentra otro conductor en su inspección, es un daño sin '
                'aclarar — y eso resulta desagradable para todos los '
                'implicados, también para ti, porque al final la sospecha '
                'recae igualmente sobre el último usuario. El error típico '
                'es pensar «esto no se nota». Se nota en la siguiente '
                'inspección, para eso está.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Green Book / libro de control',
        blocks: [
          ParagraphBlock(
            'El Green Book es tu libro de control de conducción: las hojas '
            'de control diario según el § 1 apdo. 6 del reglamento alemán '
            'de personal de conducción (FPersV), con las que acreditas tus '
            'tiempos de conducción, tus interrupciones y tus descansos. '
            'Tampoco esto es una regla de tu estación, sino derecho vigente '
            'sobre personal de conducción — se aplica igual en cualquier '
            'empresa. Expresamente no es una revisión del vehículo: en el '
            'Green Book se trata exclusivamente de tiempos, de tus tiempos.',
          ),
          BulletsBlock([
            'Una hoja por día de trabajo, cumplimentada a mano y firmada',
            'Se anotan el inicio y el final de la conducción, los '
                'kilometrajes, los tiempos de conducción, las '
                'interrupciones y los descansos',
            'Rellenarla al momento, no reconstruirla de memoria por la '
                'tarde',
            'Los registros de los últimos días se llevan encima y hay que '
                'presentarlos en un control',
          ]),
          ParagraphBlock(
            'El formador te enseña el segundo día dónde está la hoja, cómo '
            'se rellena y dónde se entregan las hojas terminadas. Todo lo '
            'demás no está aquí: en la DA Academy hay para ello una '
            'formación propia, «Green Book», con los datos obligatorios, '
            'los tiempos de conducción y descanso, la obligación de '
            'llevarlo encima y las consecuencias en caso de infracción. '
            'Trabájatela en lugar de querer memorizar los detalles el '
            'segundo día dentro del vehículo.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'El propio registro es la obligación',
            text: 'Si no hay nada que presentar, en un control nadie puede '
                'comprobar si has respetado los tiempos. Por eso una hoja '
                'que falta es tanto una infracción como un tiempo de '
                'conducción excedido.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Casos especiales: paquetes con contraseña y paquetes ATLAS',
        blocks: [
          SubheadBlock('Paquetes con contraseña'),
          ParagraphBlock(
            'Algunos envíos solo pueden entregarse a cambio de una '
            'contraseña o un código que el cliente ha recibido antes. Es '
            'típico en mercancía de valor y en todo lo que corre especial '
            'riesgo de robo. Flex te avisa de ello en la parada.',
          ),
          BulletsBlock([
            'El cliente te dice o te enseña el código — tú no lo lees en '
                'voz alta ni lo mencionas primero',
            'Sin el código correcto no hay entrega: ninguna excepción, '
                'tampoco al vecino',
            'Nada de dejarlo en la puerta ni de depositarlo en el portal',
            'Si el código no coincide, el envío se devuelve por la vía '
                'prevista y se documenta',
          ]),
          SubheadBlock('Paquetes ATLAS'),
          ParagraphBlock(
            'Los envíos ATLAS son también paquetes con un tratamiento '
            'especial: siguen un proceso propio con pasos adicionales en el '
            'escaneo y en la entrega. Para ti lo importante es que los '
            'reconozcas, los guardes aparte y a mano y no te saltes pasos '
            'del proceso previsto. Cómo es el proceso concretamente en tu '
            'estación y qué pasos te marca Flex te lo enseña el formador el '
            'segundo día con un paquete real.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Colocar primero los paquetes especiales',
            text: 'No querrás buscar ninguno de esos dos tipos de paquete '
                'en la parada entre otros 90 envíos. Colócalos aparte '
                'conscientemente al cargar y recuerda su posición.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: el cliente está, pero no tiene su '
                'contraseña a mano: «si es solo una formalidad, le firmo lo '
                'que haga falta». ¿Qué haces?',
            answer: 'No entregas. La contraseña es la prueba de que el '
                'destinatario es realmente el destinatario — justo para eso '
                'se asignó. Una firma, un documento de identidad que no '
                'puedes comprobar o unas buenas palabras no la sustituyen. '
                'El error típico es poner la amabilidad por encima del '
                'proceso: si más tarde se comunica que el envío no se ha '
                'recibido, la entrega sin código consta como error a tu '
                'nombre. Pídele al cliente que busque el código en su '
                'confirmación de pedido. Si no lo encuentra, te llevas el '
                'paquete de vuelta y lo documentas correctamente.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Repostaje, carga eléctrica y fin de ruta',
        blocks: [
          SubheadBlock('Repostaje'),
          ParagraphBlock(
            'La furgoneta se reposta según las reglas de la empresa: en las '
            'estaciones previstas, con la tarjeta de carburante del '
            'vehículo y con el combustible correcto. El justificante '
            'pertenece al vehículo o se entrega donde te indique el '
            'formador. Cuándo repostas depende de una regla sencilla: no '
            'esperar a que se encienda la luz de reserva, sino hacerlo de '
            'forma que el siguiente conductor no tenga que salir con el '
            'depósito casi vacío.',
          ),
          BulletsBlock([
            'Tipo de combustible correcto — un repostaje equivocado deja el '
                'vehículo parado durante días',
            'La tarjeta de carburante pertenece al vehículo, no a tu bolsa '
                'privada',
            'Guardar el justificante y entregarlo según lo indicado',
            'Motor apagado, no fumar, móvil guardado en el surtidor',
          ]),
          SubheadBlock('Carga eléctrica'),
          ParagraphBlock(
            'En un vehículo eléctrico la carga ocupa el lugar del repostaje '
            '— con una diferencia importante: cargar lleva más tiempo y por '
            'eso hay que planificarlo. El formador te enseña dónde se '
            'carga, qué cable pertenece al vehículo y con qué nivel de '
            'carga debe quedar el vehículo al final del turno.',
          ),
          BulletsBlock([
            'Vigilar el nivel de carga y planificar a tiempo, no reaccionar '
                'solo con la autonomía restante',
            'Después de enchufar, comprobar si la carga ha arrancado de '
                'verdad',
            'Recoger el cable con orden y no dejar puntos donde tropezar',
            'Al final del turno, entregar el vehículo como establece la '
                'empresa — el siguiente conductor sale con él',
          ]),
          SubheadBlock('Fin de ruta — como el día 1'),
          StepsBlock([
            'Cerrar la app Flex correctamente, finalizar la ruta, entregar '
                'las devoluciones.',
            'Inspección del vehículo después de la ruta: vuelta al '
                'vehículo, daños nuevos, kilometraje, nivel de combustible '
                'o de carga.',
            'Zona de carga vacía y limpia, cabina recogida.',
            'Fichar la salida, entregar la llave, completar el Green Book.',
          ]),
          ChecklistBlock(
            title: 'Esto me llevo del día 2',
            items: [
              'El número de paradas, claramente mayor, que fija mi empresa '
                  '— y que conduzco y entrego yo mismo',
              'Sé qué aparece en la Scorecard y cómo influyo en ella',
              'La calidad no es lo mismo que el rendimiento — cuentan las '
                  'dos',
              'Evito los daños activamente y notifico cada incidente de '
                  'inmediato',
              'Mantengo el vehículo limpio por dentro y por fuera',
              'Conozco el Green Book según el § 1 apdo. 6 FPersV y hago '
                  'para ello la formación propia en la DA Academy',
              'Los paquetes con contraseña solo los entrego contra el '
                  'código correcto',
              'Reconozco los paquetes ATLAS y sigo el proceso previsto',
              'Conozco las reglas para repostar y para la carga eléctrica',
              'Al final: cerrar Flex, inspección, fichar la salida',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ra4',
    title: 'Cierre y entrega',
    summary: 'Feedback del formador, firmas por día y la entrega de la '
        'hoja como foto',
    asset: '',
    slides: [
      SafetySlide(
        title: 'El feedback del formador',
        blocks: [
          ParagraphBlock(
            'Después del segundo día el formador se sienta contigo y da un '
            'feedback sobre tu rendimiento y tus capacidades de conducción. '
            'No es un veredicto de dos palabras, sino una valoración: qué '
            'funciona ya bien, en qué tienes que trabajar y a qué debes '
            'prestar especial atención en las próximas semanas.',
          ),
          BulletsBlock([
            'Conducción: calma, previsión, marcha atrás, manejo de sitios '
                'estrechos',
            'Entrega: cuidado, documentación, trato con los clientes',
            'Organización: ordenar, sentido del tiempo, manejo de las apps',
            'Actitud en el trabajo: puntualidad, preguntar, trato con las '
                'indicaciones',
          ]),
          ParagraphBlock(
            'Tómate el feedback en serio, pero no como algo personal. Es la '
            'única ocasión en la que alguien te ha observado durante dos '
            'días completos. Pregunta cuando un punto no te quede claro, y '
            'pregunta en concreto: «¿Qué debo hacer exactamente de otra '
            'manera al dar marcha atrás?» te aporta más que asentir con la '
            'cabeza.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'La pregunta final',
            text: 'Pregúntale a tu formador al terminar: «¿Cuál es la única '
                'cosa a la que debo prestar especial atención en mi primera '
                'semana solo?» La respuesta es lo más valioso de esos dos '
                'días.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: en el feedback te dicen que eres '
                'demasiado dubitativo al maniobrar y que por eso pierdes '
                'tiempo. Tú crees que simplemente ibas con cuidado. ¿Cómo '
                'lo gestionas?',
            answer: 'Preguntando en vez de justificarte. Ir con cuidado al '
                'maniobrar está bien — con «dubitativo» el formador suele '
                'referirse a otra cosa: a que te lo piensas mucho en lugar '
                'de bajarte y echar un vistazo rápido, o a que haces varios '
                'intentos donde habría bastado una maniobra atrás mirando '
                'por los dos espejos. Pide un ejemplo concreto de la '
                'jornada. Así tienes un punto en el que puedes trabajar de '
                'verdad, en lugar de una valoración que solo asientes o '
                'rechazas.',
          ),
        ],
      ),
      SafetySlide(
        title: 'La hoja: fecha, nombres, firmas',
        blocks: [
          ParagraphBlock(
            'La lista de verificación del Ride Along solo está completa '
            'cuando los datos de cabecera son correctos. Sin ellos, la hoja '
            'es un papel con marcas que no se puede atribuir a ningún '
            'justificante.',
          ),
          TableBlock(
            headers: ['Dato', 'Qué significa'],
            rows: [
              ['Fecha', 'Anotada por separado para cada uno de los dos días'],
              ['Nombre del alumno', 'Tu nombre — el conductor nuevo'],
              ['Nombre del instructor', 'El nombre de tu formador'],
              [
                'Firma',
                'Del formador, una por día — no una sola para los dos días',
              ],
            ],
          ),
          ParagraphBlock(
            'Que se firme por día tiene un motivo: cada día tiene su propia '
            'lista de puntos. Si el segundo día se cae o se aplaza, queda '
            'igualmente bien documentado lo que se hizo el primer día. Por '
            'eso, comprueba tú mismo al final de cada día si están anotadas '
            'la fecha y la firma.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Míralo tú mismo',
            text: 'La hoja es la prueba de tu formación inicial. Si falta '
                'una firma, falta la prueba — y arreglarlo a posteriori '
                'siempre es engorroso. Basta con una mirada antes de irte a '
                'casa.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Entrega: foto al dispatcher',
        blocks: [
          ParagraphBlock(
            'Al final del segundo día, la hoja cumplimentada se entrega '
            'como foto a tu dispatcher responsable. Con eso el Ride Along '
            'queda formalmente cerrado y tu formación inicial documentada.',
          ),
          StepsBlock([
            'Poner la hoja sobre una superficie plana y buscar buena luz.',
            'Fotografiar desde arriba, con toda la hoja en la imagen, sin '
                'sombras y sin bordes cortados.',
            'Comprobar que las marcas, la fecha, los nombres y las firmas '
                'se leen bien.',
            'Entregar la foto al dispatcher responsable — por la vía que os '
                'indique el formador.',
            'Tratar la hoja de papel como establezca tu empresa: pueden '
                'pedírtela.',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ilegible es como no entregado',
            text: 'Una foto movida o cortada por la mitad hay que repetirla '
                '— y para entonces quizá los dos ya estéis en casa. Míralo '
                'una vez antes de enviarlo.',
          ),
          ChecklistBlock(
            title: 'Esto me llevo del cierre',
            items: [
              'Después del día 2 el formador da un feedback sobre '
                  'rendimiento y capacidades de conducción',
              'Pregunto en concreto por los puntos que no me queden claros',
              'En la hoja constan la fecha, el nombre del alumno y el '
                  'nombre del instructor',
              'El formador firma cada día por separado',
              'Compruebo yo mismo al final de cada día si está todo anotado',
              'La hoja se entrega al final del día 2 como foto legible al '
                  'dispatcher responsable',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ra5',
    title: 'Así te preparas',
    summary: 'Qué deberías aclarar ANTES del día 1 — accesos, equipo, '
        'planificación del tiempo y tus preguntas',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Aclarar antes: accesos y tecnología',
        blocks: [
          ParagraphBlock(
            'El motivo más frecuente de que un primer día empiece mal no es '
            'la falta de conocimientos, sino un acceso que no funciona. '
            'Acláralo antes — así tu Ride Along empieza con lo que '
            'realmente importa.',
          ),
          BulletsBlock([
            'Tu propia cuenta para el reparto: datos de acceso disponibles '
                'y sesión iniciada con éxito una vez',
            'Registro horario de tu empresa (p. ej. Kenjo): acceso '
                'configurado, sabes cómo fichar la entrada y la salida',
            'Mentor y Flex: apps instaladas, inicio de sesión probado, '
                'permisos de ubicación y de movimiento concedidos',
            'CoDriver: sesión iniciada, notificaciones permitidas',
            'Móvil: cargado, memoria suficiente, cable de carga o batería '
                'externa para la furgoneta',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Comprobarlo la víspera, no por la mañana',
            text: 'Restablecer una contraseña lleva cinco minutos a las 20 '
                'h y media hora a las 6 h en la Waiting Area — si es que '
                'hay alguien localizable.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: la mañana del primer día tu app de '
                'reparto no te deja iniciar sesión. El formador espera, la '
                'ola está arrancando. ¿Cuál es la mejor reacción?',
            answer: 'Decir enseguida que el acceso no funciona — y '
                'decírselo al formador, para que pueda avisar a tu '
                'dispatcher responsable. El error típico es seguir '
                'probando en silencio para no parecer incapaz. Eso cuesta '
                'los minutos en los que el problema todavía tendría '
                'solución, y al final acabas todo el día circulando con la '
                'cuenta del formador — con lo que el número mínimo de '
                'paradas con tu propia cuenta no se cumple y, en el peor de '
                'los casos, hay que repetir el día. Por eso: avisar pronto '
                'y decir con claridad qué has probado ya.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ropa, equipo y puntualidad',
        blocks: [
          SubheadBlock('Qué te pones'),
          BulletsBlock([
            'Calzado de seguridad: zapato de trabajo firme y cerrado — nada '
                'de zapatillas ni sandalias',
            'Ropa resistente al tiempo: estás todo el día fuera, aunque por '
                'la mañana parezca que no va a llover',
            'Libertad de movimiento: subes y bajas cientos de veces',
            'Chaleco reflectante a mano — está en el vehículo, pero tiene '
                'que estar en tu cabeza',
          ]),
          SubheadBlock('Qué llevas contigo'),
          BulletsBlock([
            'Carné de conducir — sin él no conduces, tampoco el primer día',
            'DNI o documento de residencia, si la empresa lo exige',
            'Bebida y algo de comer para la pausa',
            'Bolígrafo y una libreta pequeña o app de notas',
          ]),
          SubheadBlock('Puntualidad'),
          ParagraphBlock(
            'Puntual significa: listo para trabajar en la estación al '
            'inicio del turno, no llegando a la puerta. Cuenta también el '
            'tiempo de aparcar, el camino por el patio y la Waiting Area. '
            'Quien llega tarde el primer día retrasa también la ola del '
            'formador — y eso se recuerda.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Regla práctica para los primeros días',
            text: 'Planifica el trayecto de forma que llegues más bien '
                'pronto. El cuarto de hora que ganas lo usas para orientarte '
                '— aseos, Waiting Area, plazas de colocación.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tus preguntas — y la lista de verificación previa',
        blocks: [
          ParagraphBlock(
            'Durante dos días tienes al lado a alguien que sabe todo lo que '
            'necesitas saber. Es una situación que no se vuelve a repetir '
            'así. El error que comete casi todo el mundo: no apuntan sus '
            'preguntas y estas les vuelven a la cabeza en la segunda '
            'semana, solos en la furgoneta.',
          ),
          BulletsBlock([
            'Apunta ya antes del día 1 lo que quieres saber — también las '
                'cosas pequeñas',
            'Anota las respuestas durante la ruta, no te fíes de la memoria',
            'No fotografíes datos de clientes, pero sí anota procesos y '
                'personas de contacto',
            'Pregunta al final de cada día: «¿Qué no he visto hoy '
                'todavía?»',
          ]),
          ParagraphBlock(
            'Buenas preguntas para el Ride Along son, por ejemplo: ¿cuándo '
            'es exactamente mi franja de la Waiting Area? ¿Dónde aparco mi '
            'coche privado? ¿Cómo reconozco si Mentor sigue funcionando? '
            '¿Dónde anoto mi pausa? ¿A quién notifico primero un daño? '
            '¿Dónde entrego el Green Book? ¿Qué hago si un cliente no tiene '
            'el código en un paquete con contraseña?',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Por qué has hecho esta formación',
            text: 'No para que en el Ride Along ya lo sepas todo, sino para '
                'que conozcas los términos. Quien sabe de qué se está '
                'hablando puede escuchar — quien lo oye todo por primera '
                'vez solo puede asentir.',
          ),
          RevealBlock(
            prompt: 'Caso práctico: el formador te explica por la mañana '
                'diez cosas seguidas. Por la tarde te acuerdas de tres. ¿A '
                'qué se debió — a ti?',
            answer: 'Al método, no a ti. Que te expliquen diez procesos '
                'nuevos uno detrás de otro y retenerlos no le funciona a '
                'nadie. Lo que sí funciona: haber leído antes los términos '
                'una vez — justo para eso está esta formación — y tomar '
                'notas sobre la marcha. Con dos palabras clave por tema '
                'basta para recuperar por la tarde todo el proceso. Y lo '
                'que aún falte el segundo día lo preguntas de forma '
                'concreta, en lugar de esperar que vuelva solo.',
          ),
          ChecklistBlock(
            title: 'Antes del día 1 — para marcar tú mismo',
            items: [
              'Datos de acceso de mi propia cuenta de reparto probados',
              'Registro horario (p. ej. Kenjo), Mentor, Flex y CoDriver '
                  'instalados y con sesión iniciada',
              'Móvil cargado, cable de carga o batería externa en la mochila',
              'Calzado de seguridad y ropa resistente al tiempo preparados',
              'Carné de conducir y documentos necesarios en el bolsillo',
              'Bebida y comida para la pausa preparadas',
              'Bolígrafo y algo para tomar notas conmigo',
              'Trayecto planificado — incluidos el aparcamiento y el camino '
                  'a la Waiting Area',
              'Mis preguntas para el formador apuntadas',
              'Esta formación trabajada, para conocer los términos',
            ],
          ),
        ],
      ),
    ],
  ),
];
