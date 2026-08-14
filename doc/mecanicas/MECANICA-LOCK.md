# MECANICA-LOCK — Manifiesto de sincronización con el template v1.0.0

Define cómo un proyecto adaptado sabe, con certeza, si sus copias de mecánicas y guías
canónicas siguen sincronizadas con el template de Diligencia — y qué hacer cuando no lo están.

---

## 1. El problema que resuelve

`/adaptar` copia mecánicas y guías canónicas desde el template a cada proyecto. Después de
eso, dos cosas pueden pasar por separado:

- El **template avanza** (Diligencia mejora una mecánica).
- El **proyecto customiza** su copia local (override intencional).

Sin registro, `/adaptar` no puede distinguir un caso del otro: comparar solo la versión del
header falla si alguien editó el contenido sin tocar el header, y falla al revés si el
template subió de versión sin cambios reales. El resultado es que se pisan customizaciones
o se conservan archivos viejos, en silencio.

**Analogía:** es la diferencia entre "este documento dice v1.0 igual que el original, así que
asumo que es idéntico" y "le saqué una huella digital cuando lo copié, así que sé exactamente
si alguien lo tocó".

## 2. El archivo `diligencia-lock.json`

Vive en la **raíz de cada proyecto adaptado**. Registra la huella (checksum SHA-256) de cada
archivo en el momento en que se copió desde el template.

```json
{
  "diligencia_version": "4.2.0",
  "generated": "2026-08-14",
  "generator": "/adaptar",
  "files": {
    "doc/mecanicas/MECANICA-AUDIO.md": {
      "sha256": "3f8a2c...",
      "template_version": "1.0.0",
      "synced_at": "2026-08-14"
    },
    "doc/mecanicas/MANDATO.md": {
      "sha256": "9b1e40...",
      "template_version": "1.17.2",
      "synced_at": "2026-08-14"
    }
  }
}
```

**Regla de propiedad:** lo que está en `files` viene del template y es candidato a sincronizarse.
**Todo lo demás es del proyecto** y `/adaptar` no lo toca nunca — no hace falta declararlo.

> Diligencia (el proyecto) **no tiene** `diligencia-lock.json`: es la fuente de verdad, no
> consume del template. El lock existe solo en proyectos adaptados.

## 3. Cómo se calcula una huella

```bash
sha256sum "doc/mecanicas/MECANICA-AUDIO.md" | cut -d' ' -f1
```

Disponible en Git Bash sin instalar nada. No requiere Node, Python ni runtime del proyecto —
la metodología sigue siendo Markdown puro.

## 4. Comparación de tres vías

Con tres valores — lo que dice el lock, el archivo actual del proyecto, y el archivo del
template — se determina el estado real sin ambigüedad:

| Lock vs actual | Lock vs template | Significado | Acción de `/adaptar` |
|---|---|---|---|
| = | = | En sync | Nada |
| = | ≠ | El template avanzó, el local quedó intacto | **Actualizar** (seguro, sin pérdida) |
| ≠ | = | El proyecto customizó su copia | **Conservar local** (override intencional) |
| ≠ | ≠ | Ambos cambiaron | ⚠️ **CONFLICTO** — mostrar diff y preguntar |
| *(sin entrada)* | — | Archivo nuevo en el template | **Copiar** y registrar en el lock |

Solo el último renglón de conflicto interrumpe al usuario. Los otros cuatro se resuelven solos.

## 5. Ciclo de vida

| Momento | Qué pasa con el lock |
|---|---|
| `/adaptar` Flujo A (proyecto nuevo) | Se **crea** con la huella de todo lo copiado |
| `/adaptar` Flujo C (ya adaptado) | Se **lee** para la comparación de 3 vías, y se **regenera** con las huellas post-sincronización |
| Proyecto sin lock (adaptado antes de v4.2.0) | Se **genera por primera vez** tomando el estado actual como base — asume que lo que hay es correcto y arranca a trackear desde ahí |
| Edición manual de una mecánica | El lock queda desactualizado a propósito: es justamente la señal de "esto lo customizó el proyecto" |

**El lock nunca se edita a mano.** Lo genera y actualiza `/adaptar`.

## 6. Qué NO cubre

- **Comandos, skills y agentes globales** (`~/.claude/`): no se copian a los proyectos, por
  diseño (ver `CLAUDE.md` §Nota de arquitectura). No hay nada que trackear.
- **Documentos del proyecto** (ROADMAP, CHANGELOG, mecánicas de dominio): son del proyecto
  desde el día uno, nunca vinieron del template.
- **Detección de por qué cambió**: el lock dice *que* cambió, no *qué* cambió. Para eso, diff.

## Archivos relacionados
- `MECANICA-DOCUMENTAL.md` — motor documental del sistema
- `MECANICA-CALIDAD.md` — estándares de calidad y Definición de Hecho
- `~/.claude/commands/adaptar.md` — Fase 2.5, único generador/consumidor del lock
- `INDEX.md` — catálogo de documentación del proyecto
