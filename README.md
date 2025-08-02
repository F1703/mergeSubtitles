# 🎬 Combine SRT Files Using Puppeteer

Este script automatiza el proceso de combinar archivos `.srt` utilizando la herramienta online de [subtitletools.com](https://subtitletools.com/merge-subtitles-online), permitiendo incluso aplicar colores personalizados a cada subtítulo.

---

## 📌 Instalación y dependencias

- **1. Instalá npm (el gestor de paquetes de Node.js)**

    ```bash
    sudo apt update
    sudo apt install -y npm
    ```

- **2. Instalá n (gestor de versiones de Node.js)**

    `n` permite instalar y cambiar entre distintas versiones de Node.js fácilmente:

    ```bash
    sudo npm install -g n
    ```


- **3. Instalá Node.js 18 (o la versión LTS más reciente)**

    Podés instalar la última versión LTS (Long-Term Support):

    ```bash
    sudo npm install -g n
    ```

   O bien, una versión específica (por ejemplo, Node.js 18):


    ```bash
    sudo n 18
    ```

    > 💡 Nota: Si después de instalar n no podés usar node o npm, puede deberse a que `/usr/local/bin` no esté en tu `$PATH`.

    Verificá si está presente:

    ```bash
    echo $PATH
    ```

    Si no lo está, agregalo manualmente a tu entorno:

    ```bash
    echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    ```

- **4. Instalá Puppeteer**

    Una vez que tengas Node.js correctamente instalado, podés instalar Puppeteer:

    ```bash
    npm install puppeteer@latest
    ```

- **5. Hacelo ejecutable (opcional)**

    Si querés ejecutar directamente el script:

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