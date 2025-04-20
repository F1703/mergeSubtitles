# 🎬 Combine SRT Files Using Puppeteer

Este script automatiza el proceso de combinar archivos `.srt` utilizando la herramienta online de [subtitletools.com](https://subtitletools.com/merge-subtitles-online), permitiendo incluso aplicar colores personalizados a cada subtítulo.

---

## 📦 Instalación

Instalá Puppeteer:

```bash
npm install puppeteer@latest
```

Hacelo ejecutable si querés correrlo directamente:

```bash
chmod +x mergeSubtitle.js
```

---

## 🧪 Uso básico

```bash
node mergeSubtitle.js -b archivo1.srt -m archivo2.srt -s combinado.srt
```

---

## 🎨 Colores personalizados

Podés aplicar un color distinto a cada subtítulo con los flags `-cb` (color base) y `-cm` (color merge):

```bash
node mergeSubtitle.js -b archivo1.srt -m archivo2.srt -s combinado.srt -cb "#ffff54" -cm "#54ffff" -v
```

> ⚠️ **Importante**: usá comillas dobles alrededor de los valores hexadecimales (`"#ffff54"`) para evitar que el `#` sea interpretado como comentario por la shell.

---

## 🛠️ Parámetros

| Opción    | Descripción                                                  |
|-----------|--------------------------------------------------------------|
| `-b`      | Archivo base `.srt`                                          |
| `-m`      | Archivo a combinar `.srt`                                    |
| `-s`      | Archivo de salida `.srt`                                     |
| `-cb`     | Color del subtítulo base (ej. `"#ffff54"`)                   |
| `-cm`     | Color del subtítulo combinado (ej. `"#54ffff"`)              |
| `-v`      | Modo verboso (muestra información detallada del proceso)     |
| `-h`      | Muestra la ayuda                                             |

---

## 🔁 Ejemplo completo

```bash
node mergeSubtitle.js -b ep01.en.srt -m ep01.es.srt -s ep01.combined.srt -cb "#ffff54" -cm "#54ffff" -v
```

 
![](img/file04.png)
 
---
 


¡Hecho con ❤️, `puppeteer` y unos buenos subtítulos!