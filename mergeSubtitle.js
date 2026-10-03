// #!/usr/bin/env node

// npm install puppeteer@latest
// chmod +x mergeSubtitle.js
// node mergeSubtitle.js -b archivo1.srt -m archivo2.srt -s combinado.srt

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

// Parseo básico de argumentos
const args = process.argv.slice(2);
let baseFile = null;
let mergeFile = null;
let verbose = false;
let outputFile = 'sub.srt';
let baseColor = '#ffff54';
let mergeColor = '#ffffff';
let timeout = 120000;

function vLog(...args) {
  if (verbose) console.log(...args);
}

for (let i = 0; i < args.length; i++) {
  switch (args[i]) {
    case '-v':
      verbose = true;
      break;
    case '-b':
      baseFile = args[++i];
      break;
    case '-m':
      mergeFile = args[++i];
      break;
    case '-s':
      outputFile = args[++i];
      break;
    case '-cb':
      baseColor = args[++i] || baseColor;
      break;
    case '-cm':
      mergeColor = args[++i] || mergeColor;
      break;
    case '-h':
      console.log(`Uso: node mergeSubtitle.js -b base.srt -m merge.srt [-s output.srt] [-cb "#ffff54"] [-cm "#54ffff"] [-v]`);
      process.exit(0);
  }
}

if (!baseFile || !mergeFile) {
  console.error('[-] Faltan argumentos obligatorios. Usá -h para ayuda.');
  process.exit(1);
}

(async () => {
  // const browser = await puppeteer.launch({ headless: false, slowMo: 50 });  
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();

  // Deshabilitar carga de imágenes y recursos pesados
  await page.setRequestInterception(true);
  page.on('request', (request) => {
    if (['image', 'stylesheet', 'font'].includes(request.resourceType())) {
      request.abort();
    } else {
      request.continue();
    }
  });

  await page.goto('https://subtitletools.com/merge-subtitles-online', { waitUntil: 'networkidle0', timeout: timeout });

  // Subir archivos
  const input1 = await page.$('input[name="subtitles"]');
  await input1.uploadFile(path.resolve(baseFile));

  const input2 = await page.$('input[name="second-subtitle"]');
  await input2.uploadFile(path.resolve(mergeFile));

  await page.waitForSelector('input[name="shouldColorBaseSubtitle"]');


  // Activar color para el subtitle "merge"
  if (mergeColor) {
    vLog(`[+] Aplicando color al subtitle merge: ${mergeColor}`);
    await page.evaluate((color) => {
      const colorCheckbox = document.querySelector('input[name="shouldColorMergeSubtitle"]');
      if (colorCheckbox && !colorCheckbox.checked) {
        colorCheckbox.click();
      }
      const colorInput = document.querySelector('input[name="mergeSubtitleColor"]');
      if (colorInput) colorInput.value = color;
    }, mergeColor);
  }

  // Activar color para el subtitle "base"
  if (baseColor) {
    vLog(`[+] Aplicando color al subtitle base: ${baseColor}`);
    await page.evaluate((color) => {
      const colorCheckbox = document.querySelector('input[name="shouldColorBaseSubtitle"]');
      if (colorCheckbox && !colorCheckbox.checked) {
        colorCheckbox.click();
      }
      const colorInput = document.querySelector('input[name="baseSubtitleColor"]');
      if (colorInput) colorInput.value = color;
    }, baseColor);
  }


  // Submitear el formulario
  vLog('[+] Enviando formulario...');
  await Promise.all([
    page.click('button[type="submit"]'),
    page.waitForNavigation({ waitUntil: 'networkidle0' }),
  ]);

  // Esperar el formulario de descarga
  vLog('[+] Esperando formulario de descarga...');
  // if (verbose) await page.screenshot({ path: 'debug_form.png', fullPage: true });
  await page.waitForSelector('form[action*="download-file-job"]', { timeout: timeout });

  // Enviar el formulario de descarga
  vLog('[+] Descargando subtítulo combinado...');

  const downloadResult = await page.$eval('form[action*="download-file-job"]', async (form) => {
    const formData = new FormData(form);
    const response = await fetch(form.action, { method: form.method.toUpperCase() || 'POST', body: formData });
    const contentType = response.headers.get('content-type') || '';
    const body = await response.text();

    return {
      ok: response.ok,
      status: response.status,
      contentType,
      body
    };
  }
  );

  if (!downloadResult.ok) {
    throw new Error(`Error al descargar: HTTP ${downloadResult.status}\n${downloadResult.body}`);
  }

  if (downloadResult.contentType.includes('text/html') || downloadResult.body.includes('<!DOCTYPE html')) {
    throw new Error('El servidor devolvió HTML en lugar del subtítulo combinado. Revisá la respuesta.');
  }

  fs.writeFileSync(outputFile, downloadResult.body, 'utf8');

  vLog(`[+] Subtítulo combinado guardado en: ${outputFile}`);

  await page.waitForSelector('body');
  await browser.close();

})();
