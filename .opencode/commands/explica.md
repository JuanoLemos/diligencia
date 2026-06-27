INSTRUCCIÓN: EJECUTAR las instrucciones de abajo. NO mostrar este archivo como output. ENTREGAR SOLO la explicación breve.

# /explica — Explicación directa

Explica cualquier concepto de Diligencia en formato compacto: definición + ubicación + impacto.

## Argumentos

`/explica <concepto>`

Ejemplos:
- `/explica roadmap` — qué es el ROADMAP
- `/explica +mec` — qué hace el comando +mec
- `/explica $CHECKLIST` — qué variable es
- `/explica updoc` — flujo del comando /updoc

## Qué hace

1. LEER el concepto del argumento AHORA
2. BUSCAR en la documentación de Diligencia: AGENTS.md, GUIA_DE_COMANDOS.md, ESTANDAR-COMANDOS.md, GUIA_DE_USO.md, GUIA_DE_ADAPTACION.md, GUIA_DE_REVISION.md, ROADMAP.md, bugs.md, incidentes.md, ADR-001.md, ADR-002.md, ADR-003.md, MECANICA-CBP.md, MECANICA-DOCUMENTAL.md, MECANICA-ENFORCEMENT.md, GUIA_DE_BUENAS_PRACTICAS.md, GUIA_ECOSISTEMAS.md, GUIA_REFERENCIA_RAPIDA.md, GUIA_DE_CONTRIBUCION.md, ADR_SUMMARY.md, identidad.md, MANDATO.md, status-salud.md, README.md
3. IDENTIFICAR la información más clara
4. REDACTAR cuatro líneas:

   **→** Definición directa, 1 línea. Responde "¿qué es?" Sin jerga técnica. Con analogías si ayuda (ej: "es como una lista de compras").

   **📄** Ubicación: archivo, comando, variable, o dato preciso. Responde "¿dónde está / cómo se usa?"

   **⚠️** Impacto: 1 línea sobre qué pasa si se ignora. Consecuencia práctica para el proyecto.

   **🧭** Implicancia estratégica: Si el proyecto está adaptado a Diligencia ($RM, $MANDATO), cargar `skill("diligencia-consejo")` y agregar 1 línea: ¿qué decisión de proyecto impacta entender este concepto?

5. Si el concepto no tiene documentación formal pero aparece en ROADMAP.md, CHANGELOG.md o DILIGENCIA.md, inferir su propósito y marcarlo como "Idea de roadmap".

## Formato de salida

→ [definición directa, 1 línea]

📄 [archivo, comando o ubicación]

⚠️ [consecuencia si se ignora]

🧭 [implicancia estratégica — solo si proyecto adaptado a Diligencia]

Si el concepto no se encuentra en ningún lado:
**Ese concepto no aparece en la documentación de Diligencia.**

## Validación

- Las cuatro líneas están presentes (o justificar por qué alguna no aplica)
- La definición (→) no tiene jerga técnica (ni "comando", "variable", "dependencia", "flujo")
- 📄 solo aparece si el concepto tiene un archivo, comando o formato asociado
- ⚠️ es una oración clara de consecuencia práctica
- No se excede de 1 línea por punto

## Anti-patrones

- NO usar jerga en la definición (→) — lenguaje llano, sin "orquestador", "workflow", "binding", "meta-PLAN"
- NO omitir ⚠️ — el usuario necesita saber qué pasa si ignora el concepto
- NO mezclar las líneas — cada una responde una pregunta distinta
- NO inventar definiciones si no hay base documental
- NO dar opiniones personales en 📄 — solo hechos

## Archivos que lee

Same as current (AGENTS.md, GUIA_DE_COMANDOS.md, etc.)
