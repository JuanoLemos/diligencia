INSTRUCCION: Escanear agentes en busca de reglas desactualizadas. NO modificar archivos sin confirmacion.

# /subadaptar — Sincronizar agentes con ultima version de reglas

Escanea las definiciones de agentes en busca de secciones obsoletas (referencias a /paloma, /propagar, "NUNCA BUILD", "Modo paloma") y las actualiza al modelo R1-R10 actual.

## Subcomandos

`/subadaptar --check` — solo escanea y muestra tabla de agentes stale.
`/subadaptar --aplicar` — aplica fixes automaticos sin preguntar.
`/subadaptar` — modo interactivo: muestra tabla y pregunta antes de aplicar.

## Que detecta

- Secciones "Modo paloma" que contradicen R1-R10
- Prohibiciones "NUNCA propongo BUILD, ni /commit, ni /version"
- Autorreferencias como "agente paloma"
- Referencias a /propagar (deprecado)

## Que NO modifica

- Permisos de los agentes (`edit: deny/allow`) — eso depende del rol, no de la version
- Referencias a paloma que sean correctas (R3-R4: auditoria cruzada entre proyectos)
- Agentes que ya estan alineados con R1-R10

## Que hace

1. LEE DILIGENCIA.md — version actual
2. LEE AGENTS.md — reglas R1-R10 actuales
3. PARA CADA agente en ~/.config/opencode/agents/:
   - Busca "Modo paloma", "NUNCA propongo BUILD", "agente paloma"
   - Si encuentra: marca como stale
   - Si no: OK
4. MUESTRA tabla: Agente | Hallazgo | Accion
5. PREGUNTA: "Aplicar fixes en N agentes?"
6. SI si: reemplaza las secciones obsoletas por texto actualizado
7. REPORTA: "N agentes actualizados. Cerrar y reabrir chats afectados para que carguen las nuevas reglas."

## Archivos que modifica
- ~/.config/opencode/agents/*.md — solo agentes con reglas stale
