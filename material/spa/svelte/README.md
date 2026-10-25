# Microproyecto SPA Svelte

Aplicación mínima Svelte 5 con Vite: contador local + mensaje de la API
Django (`/api/mensaje`). Su objetivo es practicar el **despliegue de una
SPA** con nginx y `try_files` (enrutado SPA), no el desarrollo Svelte.

## Estructura

```text
svelte/
├── package.json        # dependencias (svelte, vite — orientativas)
├── index.html          # página raíz del proyecto en desarrollo
├── vite.config.js      # plugin de Svelte para Vite
├── src/
│   ├── main.js         # punto de entrada: monta Svelte en #app
│   └── App.svelte      # componente: contador + mensaje de la API
├── dist/               # BUILD PRECOMPILADO (lo que sirve nginx)
│   ├── index.html
│   └── assets/app.js
└── README.md
```

## Build real (solo si quieres recompilar)

```bash
cd spa/svelte
npm install
npm run build           # regenera dist/
```

## Despliegue con nginx

1. Copia el contenido de `dist/` al DocumentRoot del servidor Web (en el
   material: `/usr/share/nginx/html` dentro de la imagen nginx).
2. La configuración debe incluir `try_files $uri $uri/ /index.html;` para
   que las rutas de la SPA devuelvan `index.html` y no un 404. Ejemplo en
   [nginx/default.conf](../../nginx/default.conf).
3. Comprueba con `curl -sf http://localhost:8000/` y
   `curl -sf http://localhost:8000/ruta/inventada`.

## Estado de verificación

El `dist/` incluido (build manual) está **verificado en ejecución** por el
agente verificador del curso: servido en contenedor (`python3 -m http.server`)
responde 200 en `/` y en `/assets/app.js`; el patrón SPA `try_files` (rutas
internas → `index.html`) es el de `nginx/default.conf` y quedó validado con
nginx en el despliegue principal. **`npm run build` sobre `src/` no se ha
ejecutado**. El código fuente (`src/`) es un proyecto Vite + Svelte real.

Autoría: imagen oficial de Python — https://hub.docker.com/_/python