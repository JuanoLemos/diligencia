import { readFileSync, existsSync } from 'node:fs';
import { resolve } from 'node:path';
import { homedir } from 'node:os';

const ROOT = resolve(import.meta.dirname, '..');
let warnings = 0;

function warn(msg) {
  console.warn(`  \u26a0\ufe0f  ${msg}`);
  warnings++;
}

function readFirstLine(path) {
  try {
    return readFileSync(path, 'utf-8').split('\n')[0].trim();
  } catch {
    return null;
  }
}

// Quita tildes y normaliza mayúsculas — "Versión" === "version" === "Versión" con typo de acento
function normalizeText(s) {
  return s.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '').trim();
}

function findColumnIndex(headerLine, columnName) {
  if (!headerLine) return -1;
  const cols = headerLine.split('|').map(c => normalizeText(c));
  return cols.findIndex(c => c === normalizeText(columnName));
}

// M7 fix: la columna se busca por nombre de encabezado, no por posición fija (cols[2]).
// Layouts distintos (| archivo | versión | fecha |) vs (| archivo | fecha | versión |)
// antes leían la celda equivocada — con el layout del propio template no validaba nada.
function extractTableValue(table, name, colIndex) {
  if (colIndex === -1) return null;
  const row = table.find(r => r.startsWith('|') && r.includes(name));
  if (!row) return null;
  const cols = row.split('|').map(c => c.trim());
  return cols[colIndex] || null;
}

console.log('\u2500\u2500 Documental integrity check \u2500\u2500');

// 1. INDEX.md vs CHANGELOG.md
const indexPath = resolve(ROOT, 'INDEX.md');
let index;
try {
  index = readFileSync(indexPath, 'utf-8');
} catch {
  warn('INDEX.md not found');
  process.exit(0);
}
const indexLines = index.split('\n').filter(l => l.includes('|') && !l.includes('---'));
const headerLine = indexLines.find(l => /\bArchivo\b/i.test(l));
const table = indexLines.filter(l => l !== headerLine);
const versionColIdx = findColumnIndex(headerLine, 'Versión');
const indexVer = extractTableValue(table, 'CHANGELOG.md', versionColIdx);
const indexDilig = extractTableValue(table, 'DILIGENCIA.md', versionColIdx);

// M8 fix: varios formatos de CHANGELOG, no solo Keep-a-Changelog. El primer patrón que
// matchee gana — los changelogs listan lo más nuevo primero, así que el primer match es
// la versión vigente en cualquiera de los formatos.
const CHANGELOG_PATTERNS = [
  /^##\s*\[(\d+\.\d+\.\d+)\]/m,   // Keep a Changelog: ## [X.Y.Z]
  /^##\s*v(\d+\.\d+\.\d+)/mi,    // ## vX.Y.Z
  /^\S+\s*v(\d+\.\d+\.\d+)\b/m,  // prefijo/bullet + vX.Y.Z (ej. "🔹 v3.17.0 — ...")
];
const changelogPath = resolve(ROOT, 'CHANGELOG.md');
let latestTag = null;
try {
  const changelog = readFileSync(changelogPath, 'utf-8');
  for (const pattern of CHANGELOG_PATTERNS) {
    const match = changelog.match(pattern);
    if (match) { latestTag = match[1]; break; }
  }
} catch {}
if (indexVer && latestTag && indexVer !== latestTag && indexVer !== `v${latestTag}`) {
  warn(`INDEX.md reports CHANGELOG.md v${indexVer}, but latest CHANGELOG tag is v${latestTag}`);
}
if (!latestTag) warn('Could not determine latest version from CHANGELOG.md — formato no reconocido (se esperaba "## [X.Y.Z]", "## vX.Y.Z", o una línea de release con "vX.Y.Z")');

// 2. INDEX.md vs DILIGENCIA.md
const diligPath = resolve(ROOT, 'DILIGENCIA.md');
const firstLine = readFirstLine(diligPath);
let diligVer = null;
if (firstLine) {
  const m = firstLine.match(/v(\d+\.\d+\.\d+)/);
  if (m) diligVer = `v${m[1]}`;
}
if (indexDilig && indexDilig !== '\u2014' && diligVer && indexDilig !== diligVer) {
  warn(`INDEX.md reports DILIGENCIA.md ${indexDilig}, but DILIGENCIA.md header says ${diligVer}`);
}
if (indexDilig === '\u2014' && diligVer) {
  warn(`INDEX.md has DILIGENCIA.md as "\u2014", but file exists with version ${diligVer}`);
}

// 3. No methodology versions in project doc headers
for (const f of ['doc/guias/identidad.md', 'doc/mecanicas/MANDATO.md']) {
  const p = resolve(ROOT, f);
  if (!existsSync(p)) continue;
  const line = readFirstLine(p);
  if (!line) continue;
  const m = line.match(/v(\d+\.\d+\.\d+)/);
  if (m) {
    const ver = m[1];
    if (latestTag && ver !== latestTag && `v${ver}` !== `v${latestTag}`) {
      warn(`${f} has version v${ver} that differs from project version v${latestTag} \u2014 methodology version leaks into project`);
    }
  }
}

// 4. $VARIABLES resolvable from CLAUDE.md
const agentsPath = resolve(ROOT, 'CLAUDE.md');
try {
  const agents = readFileSync(agentsPath, 'utf-8');
  for (const line of agents.split('\n')) {
    const m = line.match(/^\|\s*\$(\w+)\s*\|\s*(.+?)\s*\|/);
    if (m) {
      const rawPath = m[2].trim().replace(/^`|`$/g, '');
      // Skip non-path values: URLs, numbers, placeholders, multi-value lists
      if (/^https?:\/\//.test(rawPath)) continue;
      if (/^\d+$/.test(rawPath)) continue;
      if (rawPath.startsWith('*(')) continue;
      if (rawPath.includes(',')) continue;

      // M6 fix: separar el ancla (#seccion) ANTES de resolver \u2014 antes se pasaba la ruta
      // cruda a existsSync, as\u00ed que "ROADMAP.md#tecnico" se reportaba inexistente aunque
      // el archivo y la secci\u00f3n existieran.
      const [filePart, anchor] = rawPath.split('#');
      const full = filePart.startsWith('~/') || filePart.startsWith('~\\')
        ? resolve(homedir(), filePart.slice(2))
        : resolve(ROOT, filePart);

      if (!existsSync(full)) {
        warn(`$${m[1]} \u2192 ${filePart} does not exist`);
        continue;
      }
      if (anchor) {
        const slugs = readFileSync(full, 'utf-8')
          .split('\n')
          .filter(l => l.startsWith('#'))
          .map(l => normalizeText(l.replace(/^#+\s*/, ''))
            .replace(/[^\w\s-]/g, '')
            .replace(/\s+/g, '-'));
        if (!slugs.includes(anchor.toLowerCase())) {
          warn(`$${m[1]} \u2192 ancla #${anchor} no existe en ${filePart}`);
        }
      }
    }
  }
} catch {}

if (warnings === 0) {
  console.log('  \u2705  No warnings');
}
console.log('');
process.exit(0);
