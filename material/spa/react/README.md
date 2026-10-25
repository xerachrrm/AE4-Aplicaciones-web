# Microproyecto SPA React

Aplicación mínima React con Vite: contador local + mensaje de la API Django
(`/api/mensaje`). Su objetivo es practicar el **despliegue de una SPA** con
nginx y `try_files` (enrutado SPA), no el desarrollo React.

## Estructura

```text
react/
├── package.json        # dependencias (react, react-dom, vite — orientativas)
├── index.html          # página raíz del proyecto en desarrollo
├── vite.config.js      # plugin de React para Vite
├── src/
│   ├── main.jsx        # punto de entrada: monta React en #app
│   └── App.jsx         # componente: contador + mensaje de la API
├── dist/               # BUILD PRECOMPILADO (lo que sirve nginx)
│   ├── index.html
│   └── assets/app.js
└── README.md
```

## Build real (solo si quieres recompilar)

```bash
cd spa/react
npm install
npm run build           # regenera dist/
```

## Despliegue con nginx

1. Copia el contenido de `dist/` al DocumentRoot del servidor Web (en el
   material: `/usr/share/nginx/html` dentro de la imagen nginx).
2. La configuración debe incluir `try_files $uri $uri/ /index.html;` para
   que las rutas de la SPA (por ejemplo `/ruta/inventada`) devuelvan
   `index.html` y no un 404. Ejemplo en [nginx/default.conf](../../nginx/default.conf).
3. Comprueba con `curl -sf http://localhost:8000/` y
   `curl -sf http://localhost:8000/ruta/inventada` (ambas devuelven la página).

## Estado de verificación

**Verificado en ejecución** por el agente verificador del curso:

- El `dist/` incluido (build manual) se sirvió con nginx + `try_files`: 200 en `/`, en `/assets/app.js` y en la ruta interna `/ruta/inventada` (patrón SPA correcto).
- **`npm run build` ejecutado desde `src/`** en contenedor `node:22` (vite 6.4.3, 26 módulos transformados, exit 0): regenera `dist/` y el build resultante también responde 200 con nginx + `try_files`.

Autoría: imagen oficial de Node — https://hub.docker.com/_/node