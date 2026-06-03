# Status de Salud — Diligencia v1.13.0

Generado por `/salud` BUILD.

## Indicadores

| Indicador | Valor | Estado |
|---|---|---|
| Versión actual | v1.13.0 | ✅ |
| Docs informativos totales | 16 | ✅ |
| Docs al día (label = versión actual) | 4 | ⚠️ |
| Docs STALE (label < versión actual) | 8 | ⚠️ |
| Docs SIN LABEL | 0 | ✅ |
| Gaps cross-ref (D1) | 0 | ✅ |
| Gaps cross-ref (D3) | 3 | ⚠️ |

## Docs STALE

| Archivo | Label actual | Última versión |
|---|---|---|
| `doc/guias/GUIA_DE_COMANDOS.md` | v1.13.0 | v1.13.0 (corregido) |
| `doc/guias/GUIA_REFERENCIA_RAPIDA.md` | v1.13.0 | v1.13.0 (corregido) |
| `doc/guias/GUIA_DE_USO.md` | v1.10.3 | v1.13.0 |
| `doc/guias/GUIA_DE_ADAPTACION.md` | v1.10.3 | v1.13.0 |
| `doc/guias/GUIA_DE_REVISION.md` | v1.10.3 | v1.13.0 |
| `doc/guias/GUIA_DE_BUENAS_PRACTICAS.md` | v1.12.0 | v1.13.0 |
| `doc/guias/GUIA_ECOSISTEMAS.md` | v1.10.3 | v1.13.0 |
| `doc/mecanicas/MECANICA-DOCUMENTAL.md` | v1.10.3 | v1.13.0 |
| `doc/mecanicas/MECANICA-CIRCUITO.md` | v1.11.0 | v1.13.0 |
| `doc/guias/ESTANDAR-COMANDOS.md` | v1.10.3 | v1.13.0 |

## Gaps cross-ref detectados (D3)

| Documento nuevo | No referenciado en |
|---|---|
| `doc/arch/ADR_SUMMARY.md` | `/explica` scope, INDEX.md |
| `doc/guias/identidad.md` | `/explica` scope |
| `doc/mecanicas/MANDATO.md` | `/explica` scope |

## Recomendaciones

1. Bumpear labels de 8 docs STALE que no requieren cambios de contenido.
2. Agregar ADR_SUMMARY.md, identidad.md y MANDATO.md al scope de `/explica` para que sean descubribles.
3. Próximo /circuito completo incluirá /doctor para cerrar D3.
