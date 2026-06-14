# MECANICA-ENFORCEMENT — Enforcement documental de Diligencia v1.16.2

Sistema de enforcement en 3 capas que garantiza la integridad documental en todos los proyectos adaptados. Centraliza lo que antes estaba disperso en ADR-003, GUIA_DE_ADAPTACION, /version, /adaptar, scripts y GitHub Actions.

---

## Índice

| # | Sección | Contenido |
|---|---------|-----------|
| [§1](#1-arquitectura-general) | Arquitectura general | Diagrama de 3 capas + flujo de propagación |
| [§2](#2-capa-1---runtime-opencodejsonc) | Capa 1 — Runtime | Instrucciones globales en opencode.jsonc |
| [§3](#3-capa-2---pre-commit-check-docsjs) | Capa 2 — Pre-commit | Script check-docs.js y hook de pre-commit |
| [§4](#4-capa-3---cicd-github-actions) | Capa 3 — CI/CD | GitHub Actions workflow |
| [§5](#5-cableado-en-adaptar) | Cableado en /adaptar | Flujo A paso 11.5 (nuevo proyecto) y Flujo C paso 4 (upgrade) |
| [§6](#6-enforcement-en-la-propia-diligencia) | Enforcement en Diligencia | Cómo se aplica a sí misma |
| [§7](#7-verificación-y-mantenimiento) | Verificación y mantenimiento | Cómo diagnosticar y reparar enforcement roto |

---

## 1. Arquitectura general

```
                    ┌─────────────────────────────────────┐
                    │         CAPA 1: RUNTIME              │
                    │  opencode.jsonc instructions (7 reglas)│
                    │  Se inyectan en TODA sesión OpenCode  │
                    └──────────────┬──────────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────────────┐
                    │         CAPA 2: PRE-COMMIT           │
                    │  scripts/check-docs.js               │
                    │  .husky/pre-commit hook              │
                    │  Se ejecuta antes de cada commit     │
                    └──────────────┬──────────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────────────┐
                    │         CAPA 3: CI/CD                │
                    │  .github/workflows/diligencia-check  │
                    │  Se ejecuta en push y pull request   │
                    └─────────────────────────────────────┘
```

### Flujo de propagación

```
/adaptar (proyecto nuevo)
    └── Capa 1: instrucciones agregadas a opencode.jsonc del proyecto
    └── Capa 2: check-docs.js + pre-commit hook copiados
    └── Capa 3: workflow CI copiado a .github/workflows/

/version (upgrade de proyecto existente)
    └── Verifica que las 3 capas existan
    └── Si falta alguna: sugiere ejecutar Flujo C de /adaptar
```

---

## 2. Capa 1 — Runtime (opencode.jsonc)

### Origen

`~/.config/opencode/opencode.jsonc` — bloque `instructions` con reglas que OpenCode inyecta como contexto de sistema en toda sesión.

### Reglas actuales

1. Usar `/updoc` antes de `/version` para sincronizar documentación
2. Mantener CHANGELOG.md actualizado
3. Mantener CHECKLIST.md actualizado
4. Mantener ROADMAP.md actualizado
5. Cumplir ADR-003 (estructura estándar)
6. No hardcodear rutas — usar `$variables` de AGENTS.md
7. Siempre responde en español

### Cómo verificar

```bash
# Ver instrucciones activas
type ~/.config/opencode/opencode.jsonc
```

### Cómo modificar

Editar `~/.config/opencode/opencode.jsonc` y agregar/quitar reglas en el array `instructions`. El cambio aplica a todas las sesiones futuras de todos los proyectos.

---

## 3. Capa 2 — Pre-commit (check-docs.js)

### check-docs.js

Ubicación: `scripts/check-docs.js`

Valida:
1. **INDEX.md** existe y está actualizado
2. **CHANGELOG.md** tiene entrada para la versión actual
3. **Headers** de guías/mecánicas coinciden con la versión de INDEX.md
4. **Variables** de AGENTS.md resuelven a archivos reales

### Pre-commit hook

Ubicación: `.husky/pre-commit` (si se instaló con Husky)

Ejecuta `scripts/check-docs.js` antes de cada commit. Si falla, bloquea el commit.

### Cómo instalar/ reparar

```bash
# Desde la raíz del proyecto adaptado
npm install husky --save-dev
npx husky install
npx husky add .husky/pre-commit "node scripts/check-docs.js"
```

Para proyectos sin Node.js: ejecutar `node scripts/check-docs.js` manualmente antes de commitear.

---

## 4. Capa 3 — CI/CD (GitHub Actions)

### Workflow

Ubicación: `.github/workflows/diligencia-check.yml`

Se ejecuta en:
- `push` a `main` o `master`
- `pull_request` contra `main` o `master`
- `workflow_dispatch` (manual)

### Qué valida

Categoría A de ADR-003 — estructura de archivos obligatorios:
- `ROADMAP.md`, `CHECKLIST.md`, `CHANGELOG.md`, `AGENTS.md`, `DILIGENCIA.md`
- `.markdownlint.json`
- `doc/arch/`, `doc/guias/`
- `.opencode/`, `.opencode/HARNESS.md`

### Cómo instalar en un proyecto

Es copiado automáticamente por `/adaptar` Flujo A (proyecto nuevo) y sugerido en Flujo C (upgrade).

Para instalación manual:

```bash
# Copiar desde template
cp ~/.config/opencode/templates/doc-base/.github/workflows/diligencia-check.yml .github/workflows/
```

---

## 5. Cableado en /adaptar

### Flujo A — Proyecto nuevo (paso 11.5)

Después de copiar todos los archivos base:

1. Agregar instructions al `opencode.jsonc` del proyecto (Capa 1)
2. Copiar `scripts/check-docs.js` al proyecto (Capa 2)
3. Copiar `.husky/pre-commit` template si existe (Capa 2)
4. Copiar `.github/workflows/diligencia-check.yml` (Capa 3)

### Flujo C — Upgrade de proyecto (paso 4)

En la Fase 1 de sync:

1. Verificar existencia de `opencode.jsonc` con instructions → si falta, cablear
2. Verificar existencia de `scripts/check-docs.js` → si falta, copiar
3. Verificar existencia de `.github/workflows/diligencia-check.yml` → sugerir copia
4. Verificar existencia de `.husky/pre-commit` → sugerir instalación

---

## 6. Enforcement en la propia Diligencia

Diligencia es su propio primer cliente. Esto significa:

| Capa | Estado | Notas |
|---|---|---|
| Capa 1 — Runtime | ✅ | opencode.jsonc con 7 instructions |
| Capa 2 — Pre-commit | ⚠️ Sin Husky | check-docs.js existe pero no hay hook automático. Ejecutar manualmente antes de commit. |
| Capa 3 — CI/CD | ✅ | `.github/workflows/diligencia-check.yml` presente |

El script `check-docs.js` se ejecuta manualmente como parte del flujo `/CBP updoc` antes de versionar.

---

## 7. Verificación y mantenimiento

### Diagnóstico rápido

```bash
# Capa 1
rg "instructions" ~/.config/opencode/opencode.jsonc

# Capa 2
Test-Path "scripts/check-docs.js"
Test-Path ".husky/pre-commit"

# Capa 3
Test-Path ".github/workflows/diligencia-check.yml"
```

### Reparación

| Problema | Solución |
|---|---|
| Falta Capa 1 | Editar `opencode.jsonc` y agregar instructions |
| Falta Capa 2 (script) | `/adaptar` Flujo C o copiar desde template |
| Falta Capa 2 (hook) | `npx husky install && npx husky add .husky/pre-commit "node scripts/check-docs.js"` |
| Falta Capa 3 | Copiar desde `template/doc-base/.github/workflows/diligencia-check.yml` |
| Las 3 capas caídas | Ejecutar `/adaptar` Flujo C sobre el proyecto |

## Archivos relacionados
- `doc/mecanicas/MECANICA-DOCUMENTAL.md` — mecánica documental general
- `doc/mecanicas/MECANICA-CALIDAD.md` — mecánica de calidad documental
- `scripts/check-docs.js` — script de validación documental
