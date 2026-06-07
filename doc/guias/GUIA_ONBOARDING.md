# GUIA_ONBOARDING — Diligencia v1.16.3

Primeros pasos para usar un asistente de IA con OpenCode y Diligencia. Sin jerga, sin humo, sin suposiciones.

---

## 1. ¿Qué es todo esto?

Vas a trabajar con un **asistente de IA** (como OpenCode + DeepSeek) que te ayuda a documentar proyectos, organizar ideas y mantener el orden. No es magia: es un programa al que le hablás en español y te contesta cosas útiles.

**OpenCode** es la terminal donde hablás con la IA. **Diligencia** es un conjunto de reglas para que tu proyecto esté ordenado y cualquier IA (o humano) pueda entenderlo.

No necesitás saber programar. Solo escribir y leer.

---

## 2. Lo que necesitás

- **Windows** (el asistente corre en PowerShell)
- **OpenCode instalado** — si no lo tenés, preguntale a quien te guíe o buscá `opencode install` en tu buscador
- **Una API key de tu proveedor de IA** (por ejemplo: DeepSeek, OpenAI, Anthropic — una clave que le dice al sistema "este usuario puede usar la IA")
- **Nada más**. No necesitás Node.js, Python, Git, ni ningún otro lenguaje.

---

## 3. Tu primera sesión

Abrí una terminal (PowerShell) y escribí:

```
opencode -c
```

Esto abre el chat con el asistente. Cuando el asistente te pregunte qué querés hacer, decí:

```
/adaptar
```

El asistente te va a preguntar:
- **Nombre del proyecto** — poné el nombre de tu proyecto
- **Stack** — si tiene código, decí el lenguaje (ej: "Python", "JavaScript"); si no, decí "documentación nomas"
- **Áreas de roadmap** — son categorías para organizar tareas (ej: "Técnico, UX")

Cuando termine, vas a tener una carpeta con la estructura de Diligencia lista para usar.

---

## 4. 5 comandos para arrancar

| Comando | Para qué sirve | Ejemplo |
|---|---|---|
| `/ +rm "crear pantalla de login"` | Agregar una tarea al plan del proyecto | `/ +rm "diseñar el logo"` |
| `/plan quiero agregar una seccion de precios` | Pedirle a la IA que planifique antes de hacer cambios | Cualquier cosa que quieras construir |
| `/doctor` | Revisar que todo esté bien en el proyecto | Hacelo después de editar archivos |
| `/version patch` | Guardar una versión de tu trabajo (como un "checkpoint") | Antes de cerrar la sesión |
| `/reanudar` | Recuperar la sesión si se cortó la conexión | Apenas abrís de nuevo |

Regla de oro: si no sabés qué hacer, decí `/plan` + lo que quieras lograr y el asistente te guía.

---

## 5. ¿Qué hago si...?

| Situación | Hacé esto |
|---|---|
| **El asistente no me entiende** | Reformulá en frases más cortas. Decí exactamente qué archivo querés cambiar y qué querés que pase. |
| **Se cortó la conexión** | Cerra la terminal, abrí de nuevo, poné `/reanudar`. El asistente retoma donde quedó. |
| **Tiró un error** | Copiá el error y pegáselo al asistente. No hace falta que lo entiendas. |
| **Me perdí, no sé qué comandos hay** | Decí `/explica comandos` y te los lista con descripciones. |
| **Quiero volver atrás** | Decí `/plan` con lo que querés deshacer. Si hay un backup, el asistente lo usa. |
| **No sé qué hacer ahora** | Decí `/next` y el asistente te muestra los próximos pasos más relevantes. |

---

## 6. Siguientes pasos

Cuando ya te sientas cómodo con lo básico:

- `GUIA_DE_USO.md` — el manual completo con todos los comandos y flujos
- `GUIA_DE_BUENAS_PRACTICAS.md` — hábitos para trabajar mejor entre sesiones
- `GUIA_REFERENCIA_RAPIDA.md` — la chuleta de 1 página para usar todos los días

## 8. Personalización visual

Podés cambiar colores, temas y la apariencia de OpenCode. Ver `GUIA_THEMES.md`.

---

*Última actualización: 2026-06-06*
