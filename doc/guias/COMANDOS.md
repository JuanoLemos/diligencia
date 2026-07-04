# COMANDOS — Diligencia v2.6.6

## CREAR (4)
/adaptar       Adaptar proyecto a Diligencia
/+rm           Agregar item al ROADMAP
/doc           Crear/actualizar guia o mecanica
/propagar      Propagar updates a proyectos

## PLANIFICAR (8)
/plan          Planificar tarea o grupo (--ola)
/rm            Top 10 tareas por prioridad
/next          Plan de ejecucion por olas
/consejo       Consultar al consejero
/circuito      Revisar integridad logica y UX
/explica       Explicar concepto
/foco          Enfocar agente en area
/head          Preparar edicion de seccion

## EJECUTAR (6)
/commit        Commit formateado (--push)
/version       Cerrar sesion: bump + doc sync
/reanudar      Recuperar sesion
/estado        Reporte rapido del proyecto
/backup        Backup (--all zip completo)
/updoc         Actualizar documentacion

## REVISAR (5)
/informe-salud Salud de todos los proyectos
/reportar      Reportar bug o incidente
/mutacion      Absorber mutaciones externas
/revision      Revisar mutaciones del proyecto
/debug         Analisis profundo de codigo

## CUIDAR (6)
/salud         Cuidado integral (8 fases)
/documentar    Auditoria documental (24 checks)
/health        Verificar sintaxis y consistencia
/diligencia-check  Validar estructura Diligencia
/deprecar      Mover obsoleto a .old/
/limpiar       Eliminar temporales

## AGENTES (8 agentes + 2 comandos + 3 circuitos)

### Agentes de razonamiento (DeepSeek V4 Pro)
@consejero         Decisiones de proyecto, trayectoria, dominio
                   /consejo [--explorar <url>]  investigar fuentes externas
@sdd-architect     Diseno de sistemas, propuestas, plan de tareas
                   /plan [--ola N] [--sub-fases]  planificar tarea o grupo
@sdd-reviewer      Revision de codigo con contexto fresco
@documentador      Auditoria documental (24 checks, 6 categorias)
                   /documentar [--legales]  solo checks legales

### Agentes de ejecucion (DeepSeek V4 Flash)
@sdd-implement     Aplica cambios de codigo segun plan
@sdd-verify        Ejecuta tests y verifica RED->GREEN->REFACTOR
@circuito          Integridad logica y UX (handlers, rutas, navegacion)
                   /circuito [area]  enfocar en seccion

### Agentes multimodales
@disenador         Diseno UI/UX con MiniMax M3 + image-01

### Invocacion y sincronizacion
/paloma            Invocar agente y registrar reporte (paloma)
                   --news              ver palomas pendientes
                   --new @agente "consulta"  crear paloma-plan
                   --publish PNNN       publicar plan como paloma
                   --aplicar PNNN "motivo"  marcar como actuado
                   --revisar PNNN, --archivar PNNN, --reabrir PNNN
                   --descartar PNNN    descartar paloma-plan sin publicar
                   --pendiente PNNN    revertir revision
/agentes-sync      Sincronizar agentes con mecanicas y guias
                   --dry-run           solo reporte sin modificar
                   --fase 1|2          solo agentes o solo $PROYECTOS

### Circuitos de calidad
SDD:             @sdd-architect -> @sdd-implement -> @sdd-verify -> @sdd-reviewer
Paloma:          @agente -> /paloma --new -> --publish -> Pendiente -> Aplicado/Archivado
Documental:      @documentador -> /documentar -> /agentes-sync
Integridad:      @circuito -> /circuito [area] -> reporte de handlers/rutas/navegacion

## Archivos relacionados
- `GUIA_REFERENCIA_RAPIDA.md` — guia con categorias y workflows
- `GUIA_DE_COMANDOS.md` — referencia completa
- `AGENTS.md` — tabla original de comandos
- `MECANICA-TASK-ROUTER.md` — enrutador tarea->agente->modelo->API
