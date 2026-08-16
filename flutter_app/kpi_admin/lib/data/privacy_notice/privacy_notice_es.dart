// lib/data/privacy_notice/privacy_notice_es.dart
//
// Información sobre protección de datos para conductores conforme al
// Art. 13 DSGVO (RGPD) — versión en español. Traducción 1:1 de la
// versión maestra alemana (`privacy_notice_de.dart`): mismas secciones,
// mismo orden, mismos bloques.
//
// IMPORTANTE: esto es una INFORMACIÓN con confirmación de que se ha
// tomado conocimiento, no una declaración con la que el conductor
// autorice un tratamiento. Por eso, en todo el texto: «se te informa» /
// «he leído y entendido» — nunca una formulación que suene a permiso
// concedido por el conductor.
//
// Las referencias jurídicas se mantienen en su forma original alemana
// (Art. 6 Abs. 1 lit. b DSGVO, § 26 BDSG, § 16 Abs. 2 ArbZG, § 147 AO …),
// con una breve explicación entre paréntesis.

import '../safety_training/safety_blocks.dart';
import 'privacy_notice_content.dart';

const List<PrivacyNoticeSection> privacyNoticeSectionsEs = [
  // ══════════════════════════════════════════════════════════════ 1
  PrivacyNoticeSection(
    id: 'verantwortlich',
    title: 'Quién trata tus datos',
    summary: 'Responsable, encargado del tratamiento y dónde se guardan '
        'los datos',
    blocks: [
      ParagraphBlock(
        'Para que puedas trabajar en CoDriver se tratan datos sobre ti. '
        'Conforme al Art. 13 DSGVO (RGPD, Reglamento General de '
        'Protección de Datos) tienes derecho a saber desde el principio '
        'cuáles son esos datos, para qué se tratan, en qué se basa ese '
        'tratamiento y cuánto tiempo se conservan. Exactamente eso es lo '
        'que figura en las páginas siguientes.',
      ),
      SubheadBlock('Responsable del tratamiento'),
      ParagraphBlock(
        'El responsable de tus datos es tu empleador: el Delivery '
        'Service Partner (DSP) en el que estás contratado. Su nombre '
        'aparece arriba, en esta página. A él diriges todas las '
        'cuestiones relacionadas con tus datos; si ha designado a un '
        'delegado o una delegada de protección de datos, puedes '
        'dirigirte directamente a esa persona.',
      ),
      SubheadBlock('Quién explota el software'),
      ParagraphBlock(
        'CoDriver es puesto a disposición por ARION Logistics GmbH. Esta '
        'empresa trata tus datos exclusivamente por encargo y siguiendo '
        'las instrucciones de tu empleador — como encargada del '
        'tratamiento conforme al Art. 28 DSGVO (RGPD), sobre la base de '
        'un contrato de encargo de tratamiento. No persigue fines '
        'propios con tus datos.',
      ),
      SubheadBlock('Dónde se almacenan los datos'),
      ParagraphBlock(
        'Los datos se guardan en Google Firebase dentro de la Unión '
        'Europea (región de Firestore eur3, centros de datos de '
        'Fráncfort y Bélgica; Cloud Functions en europe-west3, '
        'Fráncfort). Están cifrados tanto en tránsito como en reposo. No '
        'se produce ninguna transferencia a un tercer país fuera de la '
        'UE.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Esto es una información, no un permiso que tú concedes',
        text: 'Aquí se te informa. Tu firma al final confirma '
            'únicamente que has leído y entendido esta información. Que '
            'tus datos puedan tratarse no depende de tu firma, sino de '
            'las bases jurídicas que se indican en cada apartado. Por '
            'qué es así se explica en el último apartado.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 2
  PrivacyNoticeSection(
    id: 'stammdaten',
    title: 'Tus datos maestros',
    summary: 'Nombre, número de personal, ID de transportista y datos de '
        'contacto',
    blocks: [
      ParagraphBlock(
        'Sin un perfil de conductor nadie puede planificarte, asignarte '
        'un turno ni localizarte. Tu perfil es la base de todo lo demás '
        'en la aplicación.',
      ),
      SubheadBlock('Qué datos'),
      BulletsBlock([
        'Nombre y apellidos',
        'ID de transportista (Transporter-ID) — tu identificador en el '
            'sistema de Amazon y, a la vez, tu clave en CoDriver',
        'Número de personal, si tu empleador te ha asignado uno',
        'Dirección de correo electrónico profesional — es al mismo '
            'tiempo tu acceso a la aplicación',
        'Número de teléfono para poder localizarte durante el servicio',
        'Fecha de nacimiento y nacionalidad, en la medida en que se '
            'hayan tomado del onboarding o de tu candidatura',
        'Foto de perfil, si añades una',
        'Idioma elegido en la aplicación',
        'Estado de tu relación laboral (activo, inactivo, baja)',
      ]),
      SubheadBlock('Para qué'),
      ParagraphBlock(
        'Para poder asignarte de forma inequívoca a turnos, vehículos, '
        'tiempos y justificantes, para la comunicación entre tú y el '
        'departamento de planificación y para gestionar tu acceso a la '
        'aplicación.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Base jurídica',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (RGPD; ejecución de tu '
            'contrato de trabajo) en relación con el § 26 Abs. 1 BDSG '
            '(la ley alemana de protección de datos: tratamiento de '
            'datos para fines de la relación laboral).',
      ),
      SubheadBlock('Cuánto tiempo'),
      ParagraphBlock(
        'Durante la vigencia de la relación laboral y los plazos legales '
        'de conservación. Después, tu perfil se suprime o se bloquea.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 3
  PrivacyNoticeSection(
    id: 'zeiterfassung',
    title: 'Registro de jornada y comprobación de ubicación',
    summary: 'Fichar con comprobación de geovalla — y qué no se guarda '
        'en ningún caso',
    blocks: [
      ParagraphBlock(
        'Tu empleador está legalmente obligado a registrar tu tiempo de '
        'trabajo de forma objetiva, fiable y accesible — así lo '
        'establecen el § 16 ArbZG (ley alemana de jornada laboral) y la '
        'sentencia del Tribunal de Justicia de la Unión Europea C-55/18. '
        'Cuando fichas en CoDriver («iniciar turno», «pausa», «finalizar '
        'turno»), la aplicación comprueba si tu dispositivo se encuentra '
        'en el lugar de servicio acordado.',
      ),
      SubheadBlock('Qué datos se registran en cada fichaje'),
      BulletsBlock([
        'El momento, como marca de tiempo del servidor',
        'Tu ID de transportista',
        'Si has concedido el permiso de ubicación en tu dispositivo',
        'Resultado de la comprobación de geovalla: dentro o fuera de la '
            'zona del hub',
        'Identificador de la zona del hub, p. ej. «DBY5_main»',
        'Precisión de la localización en metros',
        'ID del hub y número de versión del código QR escaneado',
        'Plataforma del dispositivo y versión de la aplicación',
        'Tu dirección IP, guardada únicamente como valor hash SHA-256, '
            'nunca en texto claro',
      ]),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Lo que expresamente NO se guarda',
        text: 'Tus coordenadas GPS exactas no se guardan. Se transmiten '
            'una sola vez al servidor en el momento del fichaje, allí se '
            'evalúan para la comprobación de geovalla y después se '
            'descartan. Solo queda la respuesta «estaba en la zona del '
            'hub / no estaba en la zona del hub». No hay seguimiento de '
            'ubicación en segundo plano ni perfil de movimientos entre '
            'dos fichajes.',
      ),
      SubheadBlock('Para qué'),
      BulletsBlock([
        'Documentación jurídicamente segura de tu tiempo de trabajo '
            'conforme al § 16 ArbZG',
        'Cálculo correcto del salario y de la seguridad social',
        'Protección frente a manipulaciones al fichar',
      ]),
      SubheadBlock('El permiso de ubicación es voluntario'),
      ParagraphBlock(
        'Que le concedas o no el permiso de ubicación a tu dispositivo '
        'lo decides tú, y puedes cambiarlo en cualquier momento en los '
        'ajustes del dispositivo. Sin permiso de ubicación puedes fichar '
        'igualmente: el registro se marca entonces como «ubicación no '
        'confirmada» y la planificación lo revisa manualmente. De ello '
        'no se derivan para ti desventajas laborales.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Base jurídica',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (RGPD; ejecución del contrato '
            'de trabajo), Art. 6 Abs. 1 lit. c DSGVO (obligación legal '
            'derivada del § 16 ArbZG), Art. 6 Abs. 1 lit. f DSGVO '
            '(interés legítimo en evitar manipulaciones) y § 26 BDSG '
            '(ley alemana de protección de datos, tratamiento en el '
            'marco de la relación laboral).',
      ),
      SubheadBlock('Cuánto tiempo'),
      TableBlock(
        headers: ['Datos', 'Conservación', 'Fundamento'],
        rows: [
          ['Registros de tiempo individuales', '2 años', '§ 16 Abs. 2 ArbZG'],
          ['Valores mensuales (previsto/real/saldo)', '6 años', '§ 147 AO'],
          ['Registro de modificaciones', '2 años', 'Trazabilidad'],
          ['Solicitudes de corrección', '2 años', 'Trazabilidad'],
        ],
      ),
      SubheadBlock('Ninguna decisión automatizada sobre ti'),
      ParagraphBlock(
        'No se produce ninguna decisión automatizada con efectos '
        'jurídicos conforme al Art. 22 DSGVO (RGPD). Los avisos de la '
        'aplicación, por ejemplo sobre una pausa excedida, son '
        'meramente informativos; sobre las consecuencias decide siempre '
        'una persona. Antes de implantar el registro de jornada se '
        'realizó una evaluación de impacto relativa a la protección de '
        'datos conforme al Art. 35 DSGVO; el riesgo residual se valoró '
        'como bajo, porque no se guardan ni coordenadas en bruto ni '
        'perfiles de movimiento.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 4
  PrivacyNoticeSection(
    id: 'academy',
    title: 'DA Academy — formaciones y justificantes',
    summary: 'Resultados de los tests, certificados y tu firma en ellos',
    blocks: [
      ParagraphBlock(
        'En la DA Academy realizas instrucciones y formaciones — por '
        'ejemplo la instrucción de seguridad, el Green Book, la '
        'formación en protección de datos o las instrucciones de '
        'servicio. Tu empleador debe poder acreditar que has recibido '
        'esa instrucción.',
      ),
      SubheadBlock('Qué datos'),
      BulletsBlock([
        'Qué formación has empezado y terminado, y cuándo',
        'Resultado del test final: puntuación obtenida, porcentaje, '
            'apto o no apto, número de intentos',
        'Fecha de superación y fin de la validez',
        'Idioma en el que has realizado la formación',
        'Tu firma manuscrita como archivo de imagen',
        'El PDF justificativo generado a partir de ello, con nombre, '
            'número de personal, ID de transportista, fecha y firma',
        'Confirmaciones de instrucciones de servicio y reglas concretas',
      ]),
      SubheadBlock('Para qué'),
      ParagraphBlock(
        'Para acreditar la instrucción ante autoridades, la mutua de '
        'accidentes de trabajo y el cliente, para gestionar las '
        'formaciones de reciclaje que vayan venciendo y para cumplir la '
        'responsabilidad proactiva de tu empleador.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Base jurídica',
        text: 'Art. 6 Abs. 1 lit. c DSGVO (RGPD; obligación legal '
            'derivada del derecho de prevención de riesgos laborales y '
            'de protección de datos, entre otros § 12 ArbSchG, § 4 DGUV '
            'Vorschrift 1, Art. 5 Abs. 2 y Art. 32 DSGVO), Art. 6 Abs. 1 '
            'lit. b DSGVO (ejecución del contrato de trabajo) y § 26 '
            'BDSG (ley alemana de protección de datos, tratamiento en el '
            'marco de la relación laboral).',
      ),
      SubheadBlock('Cuánto tiempo'),
      ParagraphBlock(
        'Durante la vigencia de la relación laboral y los plazos legales '
        'de conservación. Los justificantes de las instrucciones se '
        'conservan al menos mientras sean necesarios para acreditarlas '
        'ante las autoridades.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 5
  PrivacyNoticeSection(
    id: 'dokumente',
    title: 'Tus documentos',
    summary: 'Permiso de conducir, documento de identidad, permiso de '
        'residencia y otros justificantes',
    blocks: [
      ParagraphBlock(
        'Para trabajar como conductor deben existir determinados '
        'justificantes y estar en vigor. Tú o el departamento de '
        'planificación los guardáis en tu perfil de conductor.',
      ),
      SubheadBlock('Qué datos'),
      BulletsBlock([
        'Permiso de conducir — anverso y reverso',
        'Documento nacional de identidad o pasaporte',
        'Permiso de residencia y permiso de trabajo, si son necesarios',
        'Número de identificación fiscal',
        'Justificante de la seguridad social',
        'Contrato de trabajo',
        'Fechas de caducidad y de validez de estos documentos',
      ]),
      SubheadBlock('Para qué'),
      ParagraphBlock(
        'Para comprobar si puedes prestar servicio — sobre todo el '
        'control del permiso de conducir, que es una obligación del '
        'empleador como titular del vehículo —, para cumplir '
        'obligaciones de registro, fiscales y de seguridad social, y '
        'para avisarte a tiempo antes de que caduque un documento.',
      ),
      CalloutBlock(
        tone: CalloutTone.warning,
        title: 'Especial diligencia',
        text: 'Los documentos de identidad contienen datos sensibles. '
            'Solo son visibles para ti y para el departamento de '
            'planificación de tu empresa, se guardan cifrados en la UE y '
            'no se comunican a terceros, salvo que una autoridad lo '
            'exija sobre una base legal.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Base jurídica',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (RGPD; ejecución del contrato '
            'de trabajo), Art. 6 Abs. 1 lit. c DSGVO (obligaciones '
            'legales, entre otras el § 21 StVG sobre la responsabilidad '
            'del titular del vehículo, así como el derecho de '
            'extranjería, fiscal y de seguridad social), Art. 6 Abs. 1 '
            'lit. f DSGVO (interés legítimo en la aptitud para el '
            'servicio) y § 26 BDSG (ley alemana de protección de datos, '
            'tratamiento en el marco de la relación laboral).',
      ),
      SubheadBlock('Cuánto tiempo'),
      ParagraphBlock(
        'Durante la vigencia de la relación laboral y los plazos legales '
        'de conservación.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 6
  PrivacyNoticeSection(
    id: 'abwesenheiten',
    title: 'Ausencias, vacaciones y bajas por enfermedad',
    summary: 'Solicitudes, aprobaciones y certificados de incapacidad '
        'laboral',
    blocks: [
      ParagraphBlock(
        'Las vacaciones, la baja por enfermedad y otras ausencias las '
        'comunicas en la aplicación; la planificación decide sobre ellas '
        'y organiza el trabajo en consecuencia.',
      ),
      SubheadBlock('Qué datos'),
      BulletsBlock([
        'Tipo de ausencia — vacaciones, enfermedad, permiso no '
            'retribuido y otros motivos',
        'Periodo de … a … y número de días',
        'Estado: solicitada, aprobada, denegada',
        'Tu comentario sobre la solicitud y la respuesta de la '
            'planificación',
        'Tu derecho a vacaciones y la parte ya consumida',
        'Certificado de incapacidad laboral subido, si presentas uno',
      ]),
      CalloutBlock(
        tone: CalloutTone.warning,
        title: 'Las bajas por enfermedad están especialmente protegidas',
        text: 'Solo se registra QUE estás en situación de incapacidad '
            'laboral y durante qué periodo. No tienes que indicar ningún '
            'diagnóstico, ni el certificado destinado al empleador '
            'contiene ninguno. Los datos de salud son datos de '
            'categorías especiales conforme al Art. 9 DSGVO (RGPD) y '
            'solo los consultan las personas que realmente los '
            'necesitan para el mantenimiento de la retribución y para la '
            'planificación.',
      ),
      SubheadBlock('Para qué'),
      ParagraphBlock(
        'Para planificar el servicio, para calcular el derecho a '
        'vacaciones y el mantenimiento de la retribución, y para '
        'acreditarlo ante las entidades de la seguridad social.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Base jurídica',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (RGPD; ejecución del contrato '
            'de trabajo), Art. 6 Abs. 1 lit. c DSGVO (entre otras la '
            'BUrlG, ley federal de vacaciones, y la EntgFG, ley sobre el '
            'mantenimiento de la retribución) y, para los datos sobre la '
            'incapacidad laboral, el Art. 9 Abs. 2 lit. b DSGVO en '
            'relación con el § 26 Abs. 3 BDSG (ejercicio de derechos y '
            'obligaciones derivados del derecho laboral y del derecho de '
            'la seguridad social).',
      ),
      SubheadBlock('Cuánto tiempo'),
      ParagraphBlock(
        'Durante la vigencia de la relación laboral y los plazos legales '
        'de conservación. Los certificados de incapacidad laboral se '
        'suprimen en cuanto dejan de ser necesarios para el '
        'mantenimiento de la retribución y como justificante.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 7
  PrivacyNoticeSection(
    id: 'planung',
    title: 'Planificación de turnos y oleadas',
    summary: 'Quién conduce, cuándo, en qué oleada, en qué ruta y con qué '
        'vehículo',
    blocks: [
      ParagraphBlock(
        'La planificación organiza cada día quién trabaja, en qué oleada '
        'empiezas y con qué vehículo vas de ruta. Ese plan es visible '
        'para ti y para el departamento de planificación.',
      ),
      SubheadBlock('Qué datos'),
      BulletsBlock([
        'Tu asignación por día — planificado, libre, ausencia',
        'Hora de la oleada y hora de inicio',
        'Ruta o tour asignados',
        'Vehículo asignado con su matrícula',
        'Confirmación de que has tomado conocimiento de tu plan',
        'Cambios en el plan y quién los ha realizado',
        'Tareas y comunicaciones que se te asignan, junto con la '
            'confirmación de lectura',
      ]),
      SubheadBlock('Para qué'),
      ParagraphBlock(
        'Para organizar el día a día, para asignar vehículo y ruta y '
        'para poder reconstruir quién condujo qué tour y cuándo.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Base jurídica',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (RGPD; ejecución del contrato '
            'de trabajo) y Art. 6 Abs. 1 lit. f DSGVO (interés legítimo '
            'en un funcionamiento correcto de la empresa), en cada caso '
            'en relación con el § 26 BDSG (ley alemana de protección de '
            'datos, tratamiento en el marco de la relación laboral).',
      ),
      SubheadBlock('Cuánto tiempo'),
      ParagraphBlock(
        'Durante la vigencia de la relación laboral y los plazos legales '
        'de conservación.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 8
  PrivacyNoticeSection(
    id: 'scorecard',
    title: 'Datos de rendimiento de la Scorecard',
    summary: 'Indicadores de seguridad, calidad y entrega',
    blocks: [
      ParagraphBlock(
        'El cliente facilita semanalmente indicadores sobre tu actividad '
        'de reparto. CoDriver importa esa Scorecard y os la muestra a ti '
        'y al departamento de planificación.',
      ),
      SubheadBlock('Qué datos'),
      BulletsBlock([
        'Indicadores de seguridad como la puntuación de conducción '
            'FICO, los eventos de velocidad por cada 100 tours y el uso '
            'de Mentor',
        'Indicadores de cumplimiento como el control del vehículo y el '
            'respeto de los tiempos de trabajo',
        'Indicadores de calidad como la tasa de entrega, los envíos no '
            'entregados y la tasa de pérdidas',
        'Indicadores de calidad de entrega como la foto como '
            'justificante de entrega y el cumplimiento en el contacto '
            'con el cliente',
        'Comentarios de clientes y escalados',
        'Valoración global de cada semana y su evolución',
      ]),
      SubheadBlock('Para qué'),
      ParagraphBlock(
        'Para cumplir el contrato entre tu empleador y el cliente, para '
        'detectar riesgos de seguridad, para una formación específica y '
        'para darte a ti una devolución.',
      ),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Ningún automatismo por encima de ti',
        text: 'De un indicador no se deriva ninguna medida automática. '
            'Las valoraciones y las conversaciones las lleva siempre una '
            'persona, y tú puedes exponer tu punto de vista. No se '
            'produce ninguna decisión automatizada conforme al Art. 22 '
            'DSGVO (RGPD).',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Base jurídica',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (RGPD; ejecución del contrato '
            'de trabajo) y Art. 6 Abs. 1 lit. f DSGVO (interés legítimo '
            'en la seguridad vial, el aseguramiento de la calidad y el '
            'cumplimiento de las obligaciones contractuales frente al '
            'cliente), en relación con el § 26 BDSG (ley alemana de '
            'protección de datos, tratamiento en el marco de la relación '
            'laboral).',
      ),
      SubheadBlock('Cuánto tiempo'),
      ParagraphBlock(
        'Durante la vigencia de la relación laboral y los plazos legales '
        'de conservación.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 9
  PrivacyNoticeSection(
    id: 'empfaenger',
    title: 'Quién ve tus datos',
    summary: 'Destinatarios dentro y fuera de la empresa',
    blocks: [
      SubheadBlock('Dentro de la empresa'),
      BulletsBlock([
        'La dirección de tu empleador',
        'El departamento de planificación y los dispatchers autorizados '
            'por él — en cada caso solo para su propia empresa',
        'Tú mismo: tus propios datos los ves en la aplicación en '
            'cualquier momento',
      ]),
      SubheadBlock('Fuera de la empresa'),
      BulletsBlock([
        'Google Ireland/Google LLC como proveedor de hosting (encargo '
            'de tratamiento, servidores en la UE)',
        'ARION Logistics GmbH como operadora de CoDriver (encargo de '
            'tratamiento)',
        'Asesoría fiscal y gestoría de nóminas, en la medida en que tu '
            'empleador recurra a ellas — en cada caso sobre la base de '
            'un contrato de encargo de tratamiento',
        'El cliente, en la medida en que los indicadores de la '
            'Scorecard procedan de todos modos de allí',
        'Autoridades, entidades de la seguridad social y la mutua de '
            'accidentes de trabajo — solo cuando una base legal les '
            'faculte para ello',
      ]),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Ni se venden ni se usan para publicidad',
        text: 'Tus datos no se venden, no se utilizan con fines '
            'publicitarios y no se ceden a terceros que quieran usarlos '
            'para sus propios fines.',
      ),
      SubheadBlock('De dónde proceden los datos'),
      ParagraphBlock(
        'La mayoría de los datos proceden de ti mismo — de tu '
        'candidatura, del onboarding y de tu uso diario de la '
        'aplicación. Los indicadores de la Scorecard proceden del '
        'cliente; los datos de plan y de turno, del departamento de '
        'planificación.',
      ),
      SubheadBlock('¿Estás obligado a facilitar los datos?'),
      ParagraphBlock(
        'Algunos datos son necesarios para que la relación laboral pueda '
        'llevarse a cabo — por ejemplo el nombre, el permiso de conducir '
        'y los tiempos de trabajo. Sin ellos no puedes prestar servicio. '
        'Otros datos, como la foto de perfil, son voluntarios; de ello '
        'no se deriva ninguna desventaja para ti.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 10
  PrivacyNoticeSection(
    id: 'rechte',
    title: 'Tus derechos',
    summary: 'Acceso, rectificación, supresión, oposición y reclamación',
    blocks: [
      ParagraphBlock(
        'Frente a tu empleador, como responsable del tratamiento, te '
        'corresponden los siguientes derechos. Ejercerlos es gratuito y '
        'no te supone ninguna desventaja.',
      ),
      BulletsBlock([
        'Acceso (Art. 15 DSGVO): puedes saber si se tratan datos sobre '
            'ti y cuáles son, y solicitar una copia de ellos.',
        'Rectificación (Art. 16 DSGVO): debes poder hacer que se '
            'corrijan los datos incorrectos y que se completen los '
            'incompletos — para los registros de tiempo existe para ello '
            'la solicitud de corrección en la aplicación.',
        'Supresión (Art. 17 DSGVO): los datos que ya no son necesarios y '
            'que no están sujetos a ninguna obligación de conservación '
            'se suprimen a petición tuya.',
        'Limitación del tratamiento (Art. 18 DSGVO): si es objeto de '
            'controversia si los datos son correctos o si pueden '
            'tratarse, puedes exigir que hasta su aclaración solo se '
            'conserven.',
        'Portabilidad de los datos (Art. 20 DSGVO): los datos que hayas '
            'facilitado los recibes en un formato habitual y legible por '
            'máquina.',
        'Oposición (Art. 21 DSGVO): contra los tratamientos que se '
            'basan en un interés legítimo — por ejemplo la comprobación '
            'automática de geovalla — puedes oponerte por motivos '
            'relacionados con tu situación particular.',
        'Reclamación (Art. 77 DSGVO): puedes reclamar en cualquier '
            'momento ante una autoridad de control de protección de '
            'datos.',
      ]),
      SubheadBlock('A quién te diriges'),
      ParagraphBlock(
        'Primero a tu empleador — el DSP cuyo nombre aparece arriba en '
        'esta página. Si ha designado a un delegado o una delegada de '
        'protección de datos, puedes dirigirte directamente a esa '
        'persona; los datos de contacto te los facilita la dirección. '
        'Para una reclamación es competente la autoridad de control de '
        'protección de datos del estado federado en el que tu empresa '
        'tiene su sede; también puedes dirigirte a la autoridad de tu '
        'lugar de residencia o del lugar de la presunta infracción.',
      ),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'En cuánto tiempo recibes respuesta',
        text: 'Por regla general, el responsable debe responderte a una '
            'solicitud en el plazo de un mes. Solo en casos complejos '
            'puede prorrogar el plazo, y entonces debe informarte de '
            'ello.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 11
  PrivacyNoticeSection(
    id: 'bedeutung',
    title: 'Qué significa tu confirmación',
    summary: 'Por qué aquí se te informa y no autorizas nada',
    blocks: [
      ParagraphBlock(
        'Ahora vas a firmar. Para que quede claro qué es lo que firmas: '
        'confirmas únicamente que has leído y entendido esta '
        'información. Con ello no autorizas ningún tratamiento ni '
        'liberas nada.',
      ),
      SubheadBlock('Por qué esto es importante'),
      ParagraphBlock(
        'En una relación laboral te encuentras en una situación de '
        'dependencia respecto de tu empleador. Por eso, una declaración '
        'con la que autorizaras un tratamiento casi nunca sería '
        'realmente voluntaria — y podrías retirarla en cualquier '
        'momento, lo que haría imposible el registro de jornada o la '
        'nómina. Por eso tu trabajo en CoDriver no se apoya en una '
        'declaración así, sino en lo que rige de todos modos: la '
        'ejecución de tu contrato de trabajo (Art. 6 Abs. 1 lit. b '
        'DSGVO), las obligaciones legales de tu empleador (Art. 6 Abs. 1 '
        'lit. c DSGVO) y los intereses legítimos de la empresa '
        '(Art. 6 Abs. 1 lit. f DSGVO), en cada caso en relación con el '
        '§ 26 BDSG (ley alemana de protección de datos, tratamiento en '
        'el marco de la relación laboral).',
      ),
      DoDontBlock(
        doTitle: 'Esto es lo que confirmas',
        dos: [
          'He sido informado sobre el tratamiento de mis datos conforme '
              'al Art. 13 DSGVO.',
          'He leído y entendido esta información sobre protección de '
              'datos.',
          'Sé a quién debo dirigirme con preguntas y solicitudes.',
        ],
        dontTitle: 'Esto es lo que no confirmas',
        donts: [
          'Ninguna autorización para un tratamiento — las bases '
              'jurídicas figuran en cada apartado.',
          'Ninguna renuncia a tus derechos de los Art. 15 a 21 DSGVO.',
          'Ninguna renuncia a tu derecho de reclamación del Art. 77 '
              'DSGVO.',
        ],
      ),
      CalloutBlock(
        tone: CalloutTone.key,
        title: '¿Y si algo cambia?',
        text: 'Si el contenido de esta información cambia, se incrementa '
            'su número de versión y se te vuelve a presentar en el '
            'siguiente inicio de sesión. Así sabes siempre sobre qué se '
            'te ha informado — y cuándo.',
      ),
      ParagraphBlock(
        'La propia confirmación también se documenta: se guardan tu ID '
        'de transportista, el número de versión, la fecha y la hora, el '
        'idioma de esta vista y el PDF justificativo con tu firma. La '
        'base para ello es la responsabilidad proactiva conforme al '
        'Art. 5 Abs. 2 DSGVO.',
      ),
    ],
  ),
];
