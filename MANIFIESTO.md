# MANIFIESTO — Diligencia

Metodología abierta, plural y re-adaptable.

Quien use, adapte o redistribuya este proyecto se compromete con estos principios:

## 1. Respetar la estructura
Mantener el árbol estándar de documentación: ROADMAP, CHANGELOG, ADRs, guías y mecánicas en sus carpetas definidas por ADR-003.

## 2. No romper el circuito
Preservar /CBP como orquestador central del flujo de trabajo. Los workflows de cierre de sesión, Meta-PLAN y BUILD son parte esencial de la metodología.

## 3. Mantener el enforcement
Conservar las 3 capas de validación documental: runtime (instrucciones de sesión), pre-commit (validación local) y CI/CD (integración continua). La calidad documental no es opcional. Su implementación concreta se documenta en `doc/mecanicas/MECANICA-ENFORCEMENT.md`.

## 4. Respetar la disciplina de ejecución
BUILD aplica cambios pero NO commitea: solo `/commit`, `/CBP` y `/version` ejecutan git commit. Los agentes investigatorios son read-only y entregan **palomas** (reportes); solo el chat MAIN decide y ejecuta. Ninguna acción se asume sin confirmación.

## 5. Trazar las decisiones
Toda decisión arquitectónica se registra como ADR en `doc/arch/`. Las decisiones deben sobrevivir al olvido y al compaction: lo que no está trazado, no ocurrió.

## 6. Ser plural
Esta metodología acepta adaptaciones de stack, idioma, proveedor de IA y flujo. No impone un solo modelo ni una sola forma de trabajar.

## 7. Documentar los cambios
Versionar toda modificación con CHANGELOG actualizado y tags semánticos. La documentación debe reflejar el estado real del proyecto.

## 8. No cerrar la metodología
Todo derivado de Diligencia debe permanecer abierto bajo AGPL-3.0 o compatible. La metodología es de la comunidad.

---

*Diligencia — v2.4.2*
