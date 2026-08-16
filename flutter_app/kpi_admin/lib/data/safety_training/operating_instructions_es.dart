// lib/data/safety_training/operating_instructions_es.dart
//
// Betriebsanweisungen — spanische Fassung (uebersetzt aus DE).
// Generisch für Zustellbetriebe formuliert; betriebsspezifische Angaben
// (Ansprechpartner, Standort der Verbandkästen, Sammelplatz) ergänzt
// der jeweilige Betrieb.

import 'operating_instructions.dart';

const List<OperatingInstruction> operatingInstructionsEs = [
  // ─────────────────────────────────────────── Fahrzeug
  OperatingInstruction(
    id: 'baw_transporter',
    title: 'Conducir la furgoneta de hasta 3,5 t',
    subtitle: 'Conducir, maniobrar y estacionar el vehículo de reparto',
    category: InstructionCategory.vehicle,
    scope: 'Se aplica a todas las personas empleadas que conducen '
        'vehículos de reparto de hasta 3,5 t de masa máxima autorizada.',
    hazards: [
      'Accidentes de tráfico por distracción, presión de tiempo y fatiga',
      'Atropello de personas al dar marcha atrás — ángulo muerto',
      'Desplazamiento de la carga al frenar y en las curvas',
      'Caídas al subir y bajar del vehículo',
      'Superación de la masa máxima autorizada',
    ],
    protection: [
      'Lleva siempre contigo el permiso de conducir en vigor',
      'Control previo a la salida: alumbrado, neumáticos, frenos, '
          'visibilidad, sujeción de la carga',
      'Ajusta el asiento, los espejos y el reposacabezas antes del primer '
          'trayecto',
      'Ponte el cinturón de seguridad — también en los trayectos cortos '
          'entre dos paradas',
      'Nada de alcohol, nada de drogas, ningún medicamento que merme tu '
          'capacidad, ni antes ni durante la conducción',
      'El móvil solo con manos libres, la introducción de direcciones '
          'solo con el vehículo parado',
      'Marcha atrás con riesgo solo con una persona que te guíe; en caso '
          'de duda, baja y comprueba el entorno',
      'Asegura la carga contra el desplazamiento, los envíos pesados '
          'abajo y contra el mamparo delantero',
      'Cierra el vehículo siempre que lo abandones, no dejes nunca la '
          'llave puesta',
      'Respeta las normas sobre pausas y tiempos de conducción',
    ],
    onFailure: [
      'Si se encienden testigos de aviso o se oyen ruidos extraños: '
          'busca un lugar seguro y detente',
      'Enciende las luces de emergencia, ponte el chaleco reflectante y '
          'coloca el triángulo de emergencia (unos 100 m, en autopista '
          '150–400 m)',
      'Informa al dispatcher y solicita la asistencia en carretera por el '
          'canal previsto',
      'No repares por tu cuenta — remolcar solo con barra de remolque',
      'No sigas moviendo un vehículo con un defecto reconocible',
    ],
    onAccident: [
      'Detente, señaliza el lugar del accidente, chaleco reflectante '
          'antes de bajar',
      'Presta primeros auxilios, llama al 112',
      'Avisa a la policía si hay daños personales, daños materiales '
          'elevados o sospecha de alcohol/drogas',
      'Intercambia datos personales y del seguro, haz fotos y busca '
          'testigos',
      'Informa al empresario sin demora; anota también las lesiones leves '
          'en el libro de primeros auxilios (Verbandbuch)',
    ],
    maintenance: [
      'Comunica y documenta los defectos de inmediato',
      'Mantén el vehículo limpio, con las superficies de visión y los '
          'estribos libres de nieve, hielo y suciedad',
      'Comprueba que el botiquín, el triángulo de emergencia y el '
          'chaleco reflectante estén completos y no caducados',
      'Cumple los plazos de mantenimiento e inspección',
    ],
  ),

  // ─────────────────────────────────────────── PSA
  OperatingInstruction(
    id: 'baw_sicherheitsschuhe',
    title: 'Calzado de seguridad',
    subtitle: 'Protección de los pies en el reparto',
    category: InstructionCategory.ppe,
    scope: 'Se aplica a todas las personas empleadas en reparto, almacén '
        'y campa de vehículos.',
    hazards: [
      'Caída de envíos y partes de la carga',
      'Pisar objetos punzantes o con bordes cortantes',
      'Torceduras y lesiones de ligamentos del tobillo al bajar del '
          'vehículo, en bordillos y en caminos irregulares',
      'Resbalones sobre superficies mojadas o heladas',
      'Aplastamientos por contenedores rodantes y transpaletas manuales',
    ],
    protection: [
      'Lleva el calzado de seguridad durante toda la jornada — tanto en '
          'la estación como en la ruta, todo el año e independientemente '
          'de lo cómodo que resulte',
      'Prefiere el modelo que cubre el tobillo — sujeta la articulación '
          'y evita las torceduras',
      'Como mínimo clase de protección S1; con humedad S2, con riesgo de '
          'perforación S3',
      'Ata el calzado por completo y llévalo cerrado',
      'Antes de empezar el trabajo, comprueba si tiene defectos: dibujo '
          'de la suela, grietas, adherencia',
      'No hagas modificaciones por tu cuenta en el calzado',
      'No trabajes nunca con zapatillas deportivas ni con calzado abierto',
    ],
    onFailure: [
      'Dibujo desgastado, grietas o suela defectuosa: deja de usar el '
          'calzado',
      'Comunica si el calzado aprieta o roza — hay otros modelos y '
          'tallas; recurrir a las zapatillas propias no es una solución',
      'Pide el recambio a tu responsable — el empresario facilita los EPI '
          'de forma gratuita',
    ],
    onAccident: [
      'Haz que te atiendan enseguida cualquier lesión en el pie, aunque '
          'parezca leve',
      'Anótalo en el libro de primeros auxilios (Verbandbuch)',
      'En caso de heridas por perforación, acude al médico — haz que '
          'comprueben la protección antitetánica',
    ],
    maintenance: [
      'Limpia el calzado con regularidad y déjalo secar',
      'Sustituye el calzado muy sucio o empapado',
      'Intervalo de sustitución según indicación del fabricante y '
          'desgaste',
    ],
  ),

  OperatingInstruction(
    id: 'baw_warnweste',
    title: 'Chaleco reflectante',
    subtitle: 'Que te vean en la vía pública',
    category: InstructionCategory.ppe,
    scope: 'Se aplica a todas las personas empleadas que permanecen en la '
        'vía pública, en la campa o en las zonas de carga.',
    hazards: [
      'Que otros usuarios de la vía no te vean',
      'Mala visibilidad al amanecer o anochecer, de noche, con lluvia y '
          'niebla',
      'Tráfico de maniobras en el recinto de la estación',
    ],
    protection: [
      'Lleva el chaleco reflectante a mano en la cabina — no en la zona '
          'de carga',
      'Póntelo antes de bajar en caso de avería, accidente y en cualquier '
          'parada en la vía pública',
      'Llévalo en el recinto de la estación y en las zonas de carga '
          'cuando allí circulen vehículos',
      'Utiliza un chaleco de clase 2 o 3 y ciérralo por completo',
      'De noche, presta además atención al alumbrado y a las luces de '
          'posición',
    ],
    onFailure: [
      'Sustituye el chaleco sucio, descolorido o dañado — las bandas '
          'reflectantes tienen que ser eficaces',
      'Si falta el chaleco, comunícalo antes de salir y haz que te lo '
          'repongan',
    ],
    onAccident: [
      'Tras un accidente en la vía pública, mantén puesto el chaleco '
          'hasta que se haya despejado el lugar',
      'Comunica y documenta las lesiones',
    ],
    maintenance: [
      'Mantén el chaleco limpio, lávalo según indicación del fabricante',
      'Comprueba que esté en el vehículo — forma parte del control previo '
          'a la salida',
    ],
  ),

  // ─────────────────────────────────────────── Handhabung
  OperatingInstruction(
    id: 'baw_heben_tragen',
    title: 'Levantar y transportar',
    subtitle: 'Mover envíos sin dañarte la espalda',
    category: InstructionCategory.handling,
    scope: 'Se aplica al levantamiento, transporte y depósito manual de '
        'envíos y soportes de carga.',
    hazards: [
      'Daños en la columna vertebral y en los discos intervertebrales por '
          'una técnica de levantamiento incorrecta',
      'Lesiones musculares y de tendones por movimientos bruscos',
      'Aplastamientos en manos y pies al depositar la carga',
      'Tropiezos por visibilidad reducida con envíos grandes',
    ],
    protection: [
      'Antes de levantar, calcula el peso y despeja el camino',
      'Acércate a la carga, pies a la anchura de los hombros',
      'Levanta con las piernas: flexiona las rodillas y mantén la espalda '
          'recta',
      'Lleva la carga pegada al cuerpo, no con los brazos estirados',
      'No levantes y gires a la vez — cambia de posición con los pies',
      'Mueve los envíos pesados o voluminosos entre dos personas o con '
          'medios auxiliares (contenedor rodante, carretilla de mano, '
          'transpaleta manual)',
      'Mantén la visibilidad libre al transportar; en caso de duda, haz '
          'dos viajes',
      'Usa guantes con envíos de bordes cortantes',
    ],
    onFailure: [
      'No muevas solo una carga demasiado pesada o difícil de manejar — '
          'pide ayuda',
      'No utilices medios auxiliares defectuosos (ruedas atascadas, '
          'carretilla dañada) y comunícalo',
    ],
    onAccident: [
      'Si sientes un dolor repentino en la espalda, interrumpe la tarea '
          'de inmediato',
      'Informa a tu responsable, anótalo en el libro de primeros auxilios '
          '(Verbandbuch)',
      'Si las molestias persisten, acude al médico especialista '
          'autorizado (Durchgangsarzt)',
    ],
    maintenance: [
      'Comprueba con regularidad el funcionamiento de los medios '
          'auxiliares de transporte',
      'Mantén las vías de circulación y las superficies de carga libres y '
          'antideslizantes',
    ],
  ),

  OperatingInstruction(
    id: 'baw_winter',
    title: 'Condiciones invernales de la calzada',
    subtitle: 'Conducir y repartir con nieve, hielo y humedad',
    category: InstructionCategory.vehicle,
    scope: 'Se aplica al reparto y a la conducción en condiciones '
        'invernales.',
    hazards: [
      'Distancia de frenado más larga, derrapes, aquaplaning',
      'Caídas en aceras, rampas y peldaños helados',
      'Hipotermia por permanecer mucho tiempo al aire libre',
      'Visibilidad reducida por lunas y espejos helados',
    ],
    protection: [
      'Antes de salir, retira por completo la nieve y el hielo del '
          'vehículo — también del techo, los faros y la matrícula',
      'Neumáticos aptos para el invierno; lleva cadenas y ayudas de '
          'arranque si es necesario',
      'Comprueba el anticongelante del refrigerante y del limpiaparabrisas, '
          'lleva rascador a bordo',
      'Reduce la velocidad de forma clara y duplica como mínimo la '
          'distancia de seguridad',
      'Frena, gira y acelera con suavidad',
      'Retira la nieve de los estribos y accesos antes de usarlos',
      'Lleva ropa de abrigo e impermeable y calzado antideslizante',
      'Evita la presión de tiempo — mejor llegar tarde que no llegar',
    ],
    onFailure: [
      'Si las calles son intransitables, interrumpe la ruta e informa al '
          'dispatcher',
      'Si el vehículo se queda atascado, no lo fuerces para salir — pide '
          'ayuda',
    ],
    onAccident: [
      'Señaliza el lugar del accidente con especial cuidado — coloca el '
          'triángulo de emergencia más lejos',
      'Comunica y documenta las lesiones por caída, aunque los síntomas '
          'sean leves',
    ],
    maintenance: [
      'Controla con regularidad las escobillas del limpiaparabrisas y el '
          'alumbrado',
      'Cuida las juntas de las puertas, descongela las cerraduras',
    ],
  ),

  // ─────────────────────────────────────────── Gefahrstoffe
  OperatingInstruction(
    id: 'baw_adblue',
    title: 'AdBlue (solución de urea)',
    subtitle: 'Rellenar AdBlue en el vehículo de reparto',
    category: InstructionCategory.hazardous,
    scope: 'Se aplica al rellenado y a la manipulación de AdBlue en '
        'vehículos con depuración de gases de escape SCR.',
    hazards: [
      'Irritación de ojos, piel y vías respiratorias en caso de contacto',
      'Riesgo de resbalón por líquido derramado',
      'Cristalización y corrosión en piezas del vehículo',
      'Contaminación del medio ambiente si llega al suelo o al '
          'alcantarillado',
    ],
    protection: [
      'Utiliza únicamente la boca de llenado azul prevista — no lo eches '
          'nunca en el depósito de gasóleo',
      'Usa guantes de protección y evita el contacto con la piel',
      'Rellena solo al aire libre o en un lugar bien ventilado, con el '
          'motor parado',
      'Cierra bien el recipiente y no lo guardes al sol',
      'Lávate bien las manos después de manipularlo',
    ],
    onFailure: [
      'Diluye el líquido derramado enseguida con agua y recógelo',
      'Utiliza absorbente, no lo eches al alcantarillado',
      'En caso de repostaje equivocado, no arranques el vehículo y '
          'comunícalo de inmediato',
    ],
    onAccident: [
      'Contacto con los ojos: enjuaga con agua al menos 15 minutos y '
          'acude al médico',
      'Contacto con la piel: aclara con abundante agua y cámbiate la ropa '
          'mojada',
      'Ingestión: enjuágate la boca, bebe agua y acude al médico',
      'Comunica el incidente y anótalo en el libro de primeros auxilios '
          '(Verbandbuch)',
    ],
    maintenance: [
      'Mantén limpios el recipiente y la zona de llenado',
      'Elimina los envases vacíos según lo establecido',
    ],
  ),

  // ─────────────────────────────────────────── Hygiene
  OperatingInstruction(
    id: 'baw_hautschutz',
    title: 'Protección de la piel e higiene de manos',
    subtitle: 'Protege tus manos en el contacto con clientes y en la carga',
    category: InstructionCategory.hygiene,
    scope: 'Se aplica a todas las personas empleadas con contacto '
        'frecuente de las manos con envíos, vehículos y clientes.',
    hazards: [
      'Sequedad y grietas por lavados y desinfecciones frecuentes',
      'Irritaciones de la piel por suciedad, frío y productos de limpieza',
      'Transmisión de infecciones en el contacto con clientes',
      'Cortes y rozaduras en los bordes del cartón',
    ],
    protection: [
      'Aplícate el producto de protección cutánea antes de empezar a '
          'trabajar',
      'Lávate las manos después de ir al baño, antes de las pausas y '
          'después de la carga',
      'Extiende el desinfectante por completo y deja que se seque — no lo '
          'retires con un paño',
      'Después de lavarte, usa crema hidratante para las manos',
      'Guantes de protección con envíos de bordes cortantes o sucios',
      'Quítate los anillos y el reloj de pulsera durante la carga',
    ],
    onFailure: [
      'Si el enrojecimiento, el picor o las grietas persisten, comunícalo',
      'No sigas usando un producto que no toleres — pide una alternativa',
    ],
    onAccident: [
      'Limpia y venda enseguida los cortes y las rozaduras',
      'Anótalo en el libro de primeros auxilios (Verbandbuch), también '
          'las lesiones pequeñas',
      'Si hay signos de infección, acude al médico',
    ],
    maintenance: [
      'Comprueba el nivel de llenado de los dosificadores de jabón, '
          'desinfectante y crema',
      'Comunica los dosificadores vacíos o averiados',
    ],
  ),

  // ─────────────────────────────────────────── Arbeitsplatz
  OperatingInstruction(
    id: 'baw_bildschirm',
    title: 'Puesto de trabajo con pantalla',
    subtitle: 'Planificación y trabajo de oficina',
    category: InstructionCategory.workplace,
    scope: 'Se aplica a las personas empleadas que trabajan '
        'principalmente con pantalla — en especial dispatchers y '
        'administración.',
    hazards: [
      'Molestias oculares por deslumbramiento y enfoque prolongado',
      'Tensiones en la nuca, los hombros y la espalda',
      'Irritación de las vainas tendinosas por una postura desfavorable '
          'de manos y brazos',
      'Tropiezos con los cables',
    ],
    protection: [
      'Borde superior de la pantalla aproximadamente a la altura de los '
          'ojos, distancia visual de 50–70 cm',
      'Coloca la pantalla lateralmente respecto a la ventana — no delante '
          'ni de espaldas a ella',
      'Elige la altura del asiento de modo que antebrazos y brazos formen '
          'aproximadamente un ángulo recto',
      'Pies planos en el suelo o sobre un reposapiés',
      'Cambia de postura con regularidad, haz pausas breves mirando a lo '
          'lejos',
      'Guía y sujeta los cables',
    ],
    onFailure: [
      'Comunica las pantallas y luminarias que parpadeen o estén '
          'averiadas',
      'No sigas usando las sillas defectuosas',
    ],
    onAccident: [
      'Si las molestias persisten, informa a tu responsable',
      'Haz que comprueben tu derecho a la vigilancia de la salud laboral '
          'y a gafas específicas para trabajo con pantalla',
    ],
    maintenance: [
      'Mantén limpios la pantalla y los dispositivos de entrada',
      'Comprueba con regularidad la iluminación del puesto de trabajo',
    ],
  ),
];
