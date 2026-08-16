// lib/data/safety_training/safety_texts_es.dart
//
// Instrucción de seguridad — textos en español. Mismo juego de claves que
// safety_texts_de.dart.

const Map<String, String> safetyTextsEs = {
  'ask_anytime':
      '¿Tienes preguntas? Dirígete en cualquier momento a tu manager, a tu dispatcher o a la dirección — mejor preguntar una vez de más que hacer algo mal.',
  // ── Meta / UI ──
  'training_title': 'Instrucción de seguridad',
  'training_subtitle':
      'Prevención de riesgos laborales para repartidores — instrucción anual',
  'training_intro':
      'Esta instrucción te protege: en unos 15–20 minutos aprendes las '
      'reglas más importantes para trabajar y conducir con seguridad. Al '
      'final hay un test breve (20 preguntas, 80 % para aprobar) y '
      'confirmas tu participación con tu firma.',
  'chapters_overview_title': 'Índice de capítulos',
  'chapters_overview_hint': 'Ve trabajando los capítulos en orden. El test se desbloquea en cuanto los hayas leído todos.',
  'chapter_pages': '{n} páginas',
  'btn_overview': 'Resumen',
  'btn_chapter_done': 'Finalizar capítulo',
  'btn_test_locked': 'Lee primero todos los capítulos',
  'chapter_label': 'Capítulo {n} de {m}',
  'btn_start': 'Empezar la instrucción',
  'btn_next': 'Continuar',
  'btn_back': 'Atrás',
  'btn_start_test': 'Al test',
  'btn_submit_test': 'Comprobar respuestas',
  'btn_retry': 'Intentarlo de nuevo',
  'btn_finish': 'Finalizar',
  'test_title': 'Test final',
  'test_intro':
      '20 preguntas — como mínimo un 80 % (16 correctas) para aprobar. '
      'Puedes repetir el test tantas veces como quieras.',
  'test_passed': 'Aprobado — ¡{score} de {total} correctas!',
  'test_failed':
      'Lamentablemente no has aprobado ({score} de {total}). Repasa los '
      'capítulos e inténtalo de nuevo.',
  'signature_title': 'Confirmar la participación',
  'signature_hint':
      'Con tu firma confirmas que has participado en la instrucción y que '
      'has entendido el contenido. Has tenido ocasión de hacer preguntas.',
  'confirm_checkbox':
      'He entendido la instrucción y confirmo mi participación.',
  'btn_clear': 'Borrar',
  'btn_sign_submit': 'Firmar y finalizar',
  'cert_done_title': '¡Instrucción finalizada!',
  'cert_done_body':
      'Tu certificado se ha creado y se ha guardado en tus documentos. '
      'La instrucción tiene una validez de 12 meses.',
  'status_valid_until': 'Válido hasta el {date}',
  'status_expired': 'Caducada — por favor, vuelve a realizarla',
  'status_open': 'Todavía no realizada',

  // ── Capítulos ──
  'ch01_title': 'Fundamentos y tus obligaciones',
  'ch01_body': 'La prevención de riesgos laborales está regulada por ley '
      '(Arbeitsschutzgesetz + normas DGUV) y protege tu vida y tu salud. '
      'Tú también tienes obligaciones:\n'
      '• Cumplir las Betriebsanweisungen de tu empresa\n'
      '• Comunicar de inmediato accidentes y casi accidentes\n'
      '• Prestar primeros auxilios o apoyar en ellos\n'
      '• Comunicar averías y deficiencias (p. ej. cables rotos, aparatos '
      'defectuosos)\n'
      '• Utilizar el equipo de protección (calzado de seguridad, guantes, '
      'chaleco reflectante) conforme a su uso previsto\n'
      '• Nada de alcohol, drogas ni medicamentos que mermen tu capacidad — '
      'no puedes ponerte en peligro a ti ni a los demás.',
  'ch02_title': 'Betriebsanweisungen',
  'ch02_body': 'Las Betriebsanweisungen son instrucciones vinculantes de tu '
      'empresa para el manejo de vehículos, equipos y sustancias '
      'peligrosas.\n'
      '• Te protegen de accidentes y daños para la salud\n'
      '• Quien las incumple arriesga la corresponsabilidad en caso de '
      'accidente\n'
      '• Ejemplos del día a día al volante: marcha atrás con riesgo solo '
      'con una persona que dirija la maniobra · cerrar siempre el vehículo '
      'con llave al abandonarlo · remolcar únicamente con barra de remolque '
      '· comunicar cualquier accidente sin demora\n'
      '• Pregunta si una instrucción no te queda clara — antes de trabajar.',
  'ch03_title': '10 reglas para trabajar con seguridad',
  'ch03_body': 'Estas diez reglas rigen cada día:\n'
      '1. Trabajar de forma segura y prudente\n'
      '2. Control previo antes de cada salida\n'
      '3. Asegurar la carga en el vehículo\n'
      '4. Conducir de forma profesional, respetar el StVO (código de '
      'circulación alemán)\n'
      '5. Ponerse siempre el cinturón de seguridad\n'
      '6. Mantener en orden vehículo, herramientas y equipo\n'
      '7. Trabajar solo con calzado adecuado\n'
      '8. Trato cortés con compañeros y clientes\n'
      '9. Cumplir el régimen de pausas\n'
      '10. Tratarse con tolerancia y respeto',
  'ch04_title': 'Calzado de seguridad y equipo de protección',
  'ch04_body': 'El calzado de seguridad facilitado por la empresa debe '
      'llevarse — es obligatorio (§ 15 ArbSchG, ley alemana de '
      'prevención).\n'
      '• Protege de la caída de paquetes, de golpes, de pisar objetos '
      'punzantes, de la humedad y de los resbalones\n'
      '• Clases de protección: S1 (antiestático, suela resistente a los '
      'carburantes) · S2 (además impermeable al menos 60 min) · S3 (además '
      'suela antiperforación y con relieve)\n'
      '• Revisa tus zapatos con regularidad: suela desgastada o daños → '
      'pide que te los cambien\n'
      '• Especialmente importante en rampas, caminos irregulares, con '
      'jaulas rodantes y transpaletas\n'
      '• Chaleco reflectante al alcance de la mano en el vehículo — '
      'obligatorio en caso de avería o accidente.',
  'ch05_title': 'Actuación en caso de incendio',
  'ch05_body': 'Manejar el extintor: 1. quitar el pasador · 2. accionar el '
      'botón percutor · 3. apretar la manguera de descarga.\n'
      '• Extinguir en el sentido del viento, los incendios de superficie '
      'desde delante, varios extintores a la vez en lugar de uno detrás de '
      'otro\n'
      '• Un extintor dura solo segundos (polvo de 6 kg: 15–23 s) — haz '
      'recargar siempre los extintores usados\n'
      '• Incendio de vehículo: NO parar en túneles ni en puentes — si es '
      'posible salir de ellos, después luces de emergencia, detenerse y '
      'salir\n'
      '• Llamar de inmediato a los bomberos, 112: ¿Dónde? ¿Qué arde? '
      '¿Heridos? ¿Qué lleva cargado? No cuelgues — la central es quien '
      'finaliza la conversación\n'
      '• Abrir el capó solo con guantes y con cuidado, apenas una rendija — '
      'riesgo de llamarada por el oxígeno.',
  'ch06_title': 'Primeros auxilios',
  'ch06_body': 'Toda persona está obligada por ley a prestar primeros '
      'auxilios (§ 323c StGB, código penal alemán) — dentro de lo '
      'razonablemente exigible.\n'
      '• Quien ayuda, en principio no hace nada mal: como primer '
      'interviniente estás cubierto por el seguro de accidentes y no '
      'respondes por los errores — comete delito solo quien NO ayuda\n'
      '• Reglas básicas: mantener la calma · primero tu propia seguridad · '
      'señalizar el lugar del accidente · después ayudar\n'
      '• Emergencias 112 — las preguntas clave: ¿Dónde? ¿Qué? ¿Cuántos '
      'heridos? ¿Quién llama? ¡Espera a que te pregunten!\n'
      '• Toda lesión — también los cortes pequeños — se atiende de '
      'inmediato y se anota en el libro de curas\n'
      '• Si la baja laboral supera los 3 días, la empresa debe comunicar el '
      'accidente a la mutua profesional — por eso avísala siempre.',
  'ch07_title': 'Sentarse y moverse correctamente',
  'ch07_body': 'Estar mucho tiempo mal sentado cansa, provoca contracturas '
      'y ralentiza tu reacción.\n'
      '• Ajusta bien el asiento antes de conducir: altura, distancia, '
      'respaldo, apoyo lumbar, reposacabezas, volante, recorrido del '
      'cinturón\n'
      '• Espalda bien pegada al respaldo, sentado erguido, cambiando '
      'ligeramente la postura una y otra vez («sentarse de forma '
      'dinámica»)\n'
      '• Aprovecha las pausas para ejercicios cortos: estirar los brazos '
      'hacia arriba (unos 8 s, 3–5×) · manos en la nuca, codos hacia atrás '
      '· sentado, separar con fuerza las manos en el volante (3–6 s)\n'
      '• Una espalda entrenada es bastante menos propensa a las molestias.',
  'ch08_title': 'Carga psíquica',
  'ch08_body': 'Presión de plazos, atascos, búsqueda de aparcamiento, '
      'conflictos — el día a día del conductor puede pesar. Es normal y no '
      'es un fracaso personal.\n'
      '• El estrés continuado provoca agotamiento, problemas de sueño, '
      'errores y enfermedad — toma en serio las señales de alarma\n'
      '• Habla abiertamente de las cargas: con tu dispatcher, en una '
      'entrevista con personal o de forma anónima\n'
      '• Rutas realistas, responsabilidades claras y feedback son tarea de '
      'la empresa — los avisos ayudan a todos\n'
      '• Pedir ayuda es fuerza, no debilidad. En crisis agudas: '
      'Telefonseelsorge 0800 111 0 111 (gratuito, 24 horas).',
  'ch09_title': 'Conducción segura y control previo a la salida',
  'ch09_body': 'Antes de CADA trayecto: un breve control previo — dura 2 '
      'minutos y puede salvar vidas.\n'
      '• Vuelta al vehículo: alumbrado delantero/trasero · neumáticos '
      '(presión, dibujo) · espejos y lunas limpios · sin fugas · '
      'puertas/lonas cerradas · matrículas limpias\n'
      '• ¿Carga asegurada? Amarres en buen estado, masa máxima autorizada '
      'respetada\n'
      '• Puesto de trabajo: asiento y espejos ajustados, prueba de frenado, '
      'sistemas de asistencia activados\n'
      '• En invierno: neumáticos adecuados, anticongelante, rascador de '
      'hielo a bordo\n'
      '• En ruta: ponte el cinturón, respeta el StVO, guarda la distancia — '
      'nunca conduzcas bajo los efectos del alcohol o las drogas.',
  'ch10_title': 'Averías y accidentes',
  'ch10_body': 'Regla básica: la protección propia antes que la de los '
      'demás — las personas antes que las cosas.\n'
      '• Avería: luces de emergencia pronto, a ser posible hasta un '
      'aparcamiento o pegado a la derecha, ponte el chaleco reflectante '
      'ANTES de bajar, coloca el triángulo (unos 100 m, en autopista '
      '150–400 m)\n'
      '• Accidente: 1. detenerse · 2. señalizar · 3. primeros auxilios · '
      '4. llamar al 112 · 5. intercambiar los datos personales · 6. con '
      'heridos o daños elevados, la policía · 7. fotos + testigos · '
      '8. informar a la empresa\n'
      '• ¿Has rozado un coche aparcado y no hay nadie? Espera al menos 30 '
      'minutos; después una nota NO basta: acude sin demora a la policía — '
      'si no, es un delito de fuga\n'
      '• Por cierto, las lesiones más frecuentes no ocurren en el tráfico, '
      'sino al bajar del vehículo: más del 50 % son caídas — no saltes '
      'nunca, usa siempre los estribos y los asideros.',

  // ── Preguntas del test ──
  'q01': '¿Qué haces en primer lugar en un accidente con heridos?',
  'q01_a': 'Llamar de inmediato a la empresa',
  'q01_b': 'Detenerse, señalizar el lugar del accidente (chaleco '
      'reflectante, triángulo) y después primeros auxilios y llamada de '
      'emergencia',
  'q01_c': 'Hacer fotos y seguir la marcha',
  'q02': '¿A qué número de emergencia llamas en caso de incendio o de '
      'heridos?',
  'q02_a': '110',
  'q02_b': '112',
  'q02_c': '116117',
  'q03': 'Rozas un coche aparcado y el titular no está. ¿Qué es lo '
      'correcto?',
  'q03_a': 'Dejar una nota con el número de móvil en el parabrisas y seguir '
      'la marcha',
  'q03_b': 'Esperar al menos 30 minutos y después comunicar el accidente '
      'sin demora a la policía',
  'q03_c': 'Seguir la marcha si el daño parece pequeño',
  'q04': '¿A qué distancia colocas el triángulo de señalización en la '
      'autopista?',
  'q04_a': 'Justo detrás del vehículo',
  'q04_b': 'unos 50 m',
  'q04_c': 'de 150 a 400 m',
  'q05': '¿Cuál es la regla básica en el lugar de una avería o de un '
      'accidente?',
  'q05_a': 'La protección de las cosas es lo primero, para evitar costes',
  'q05_b': 'La protección propia antes que la de los demás, las personas '
      'antes que las cosas',
  'q05_c': 'Primero asegurar la carga y después ayudar a las personas',
  'q06': '¿Cuándo te pones el chaleco reflectante en caso de avería?',
  'q06_a': 'Solo de noche',
  'q06_b': 'Solo en la autopista',
  'q06_c': 'Siempre — ya antes de bajar del vehículo',
  'q07': '¿Te pueden sancionar si cometes un error prestando primeros '
      'auxilios?',
  'q07_a': 'Sí, quien presta primeros auxilios responde siempre por los '
      'errores',
  'q07_b': 'No — quien ayuda, en principio no hace nada mal. Comete delito '
      'solo quien no ayuda en absoluto',
  'q07_c': 'Sí, por eso solo deberían intervenir personas con formación',
  'q08': '¿Qué pasa con las lesiones pequeñas (p. ej. un corte) en el '
      'trabajo?',
  'q08_a': 'Nada, las lesiones pequeñas son asunto privado',
  'q08_b': 'Atenderlas de inmediato y anotarlas en el libro de curas',
  'q08_c': 'Comunicarlas al médico solo si se infectan',
  'q09': '¿Cómo atacas un fuego con el extintor?',
  'q09_a': 'Contra el viento, de atrás hacia delante',
  'q09_b': 'En el sentido del viento, los incendios de superficie desde '
      'delante, varios extintores a la vez',
  'q09_c': 'Desde arriba hacia el centro de las llamas, empleando los '
      'extintores uno detrás de otro',
  'q10': '¿Dónde ocurren la mayoría de los accidentes declarables de los '
      'conductores?',
  'q10_a': 'En el tráfico, a alta velocidad',
  'q10_b': 'Al bajar del vehículo — caídas, tropiezos, torceduras (más del '
      '50 %)',
  'q10_c': 'Al repostar el vehículo',
  'q11': '¿Qué forma parte del control previo antes de cada trayecto?',
  'q11_a': 'Solo un vistazo al depósito',
  'q11_b': 'Comprobar alumbrado, neumáticos, frenos, espejos, sujeción de '
      'la carga y ajuste del asiento',
  'q11_c': 'El control solo es necesario después de pasar por el taller',
  'q12': '¿Qué rige sobre el alcohol y las drogas en el día a día como '
      'conductor?',
  'q12_a': 'Una cerveza en la pausa del mediodía está permitida',
  'q12_b': 'Prohibido — nadie puede ponerse en peligro a sí mismo ni a los '
      'demás por sustancias que alteren su estado',
  'q12_c': 'Prohibido solo durante la conducción, permitido en la pausa',
  'q13': 'Un compañero está en el suelo del patio tras una caída. Un primer '
      'interviniente formado de la estación ya está con él y lo atiende. '
      '¿Qué rige para ti?',
  'q13_a': 'Nada más — hay un primer interviniente, así que tu obligación '
      'está cumplida',
  'q13_b': 'Debes asegurarte de que realmente se está ayudando y avisar a '
      'los servicios de emergencia o guiarlos — la obligación de avisar '
      'subsiste siempre',
  'q13_c': 'Debes atenderlo tú mismo porque fuiste el primero en verlo',
  'q14': 'De un recipiente cae líquido ardiendo por la pared exterior. '
      '¿Cómo extingues?',
  'q14_a': 'De abajo hacia arriba, para que el charco se apague primero',
  'q14_b': 'De lado, atravesando las llamas',
  'q14_c': 'Empezando arriba, en el punto de salida, y trabajando hacia '
      'abajo',
  'q15': 'Bajas del vehículo con un paquete en la mano izquierda. ¿Cuál es '
      'el error?',
  'q15_a': 'Con un paquete en la mano solo quedan dos puntos de contacto — '
      'primero dejar la carga, después bajar',
  'q15_b': 'No hay error mientras te sujetes con la mano derecha',
  'q15_c': 'No hay error mientras bajes despacio',
  'q16': 'Has usado un extintor de polvo de 6 kg, pero solo has apretado un '
      'momento. El extintor parece seguir lleno. ¿Qué haces?',
  'q16_a': 'Volver a colgarlo en el soporte de pared, total, sigue lleno',
  'q16_b': 'Entregarlo para su recarga y comunicar que hace falta un '
      'repuesto — un extintor usado no vuelve nunca a la pared',
  'q16_c': 'Llevarlo en el vehículo como reserva',
  'q17': 'Llevas tres semanas en una ruta que habitualmente no se puede '
      'terminar. ¿Cuál es el camino correcto?',
  'q17_a': 'Aguantar, eso forma parte del trabajo',
  'q17_b': 'Simplemente conducir más despacio y saltarse paradas',
  'q17_c': 'Comunicar al dispatcher en concreto qué no funciona y dónde — '
      'cuanto más exacto, más probable es que cambie la planificación',
  'q18': '¿Cuándo debe la empresa comunicar un accidente de trabajo a la '
      'mutua profesional?',
  'q18_a': 'Con cualquier lesión, por pequeña que sea',
  'q18_b': 'Cuando la baja laboral dura más de 3 días naturales — la '
      'declaración debe hacerse en un plazo de 3 días',
  'q18_c': 'Solo en accidentes mortales',
  'q19': '¿Qué significa la clase de protección S3 en el calzado de '
      'seguridad?',
  'q19_a': 'Impermeable durante al menos 60 minutos más suela '
      'antiperforación y con relieve',
  'q19_b': 'Solo antiestático, con suela resistente a los carburantes',
  'q19_c': 'Fabricado totalmente de goma',
  'q20': '¿Por qué rige al bajar del vehículo la regla «mover solo un '
      'punto»?',
  'q20_a': 'Para que vaya más rápido',
  'q20_b': 'Porque tres puntos deben mantener siempre sujeción firme — si '
      'uno resbala, te sostienes con los otros',
  'q20_c': 'Porque así se cuida el estribo',
};
