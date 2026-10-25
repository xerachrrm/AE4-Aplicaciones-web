# Frontend de la aplicación DPL (UT4) — build de Vite con Web Components

Frontend sin framework: dos **Web Components** con *shadow DOM* (`<dpl-mensaje>`
y `<dpl-visitas>`) que consumen la API del servidor de aplicaciones con
`fetch` (vínculo con el trabajo asíncrono de DWEC). Se sirve como contenido
estático por nginx; el alumno **despliega `dist/`, no compila**.

## Estructura

```text
frontend/
├── package.json          # dependencias y scripts (Vite, orientativo)
├── index.html            # página raíz del proyecto en desarrollo
├── src/                  # código fuente del frontend
│   ├── main.js           # punto de entrada: registra los componentes
│   ├── dpl-mensaje.js    # componente: /api/mensaje (mensaje, hostname, fecha)
│   └── dpl-visitas.js    # componente: /api/visitas (contador persistido)
└── dist/                 # BUILD PRECOMPILADO (lo que sirve nginx)
    ├── index.html
    └── assets/dpl-app.js
```

## Cómo se genera el build real (solo si quieres recompilar)

```bash
cd frontend
npm install          # instala Vite (Node.js 22 o superior, orientativo)
npm run build        # genera dist/ de nuevo
```

## Estado de verificación

El `dist/` incluido es un **build generado manualmente** (HTML + JS estático
equivalente al bundle de Vite). **Verificado en ejecución** por el agente
verificador del curso: servido por nginx en el despliegue real responde 200
(la página incluye `dpl-visitas` y los assets se cargan). No se ha ejecutado
`npm run build` sobre `src/`; para el despliegue del curso no necesitas
recompilar: nginx copia `dist/` tal cual.

## Despliegue

El `dist/` se copia a la imagen de nginx (`nginx/Dockerfile.nginx` →
`/usr/share/nginx/html`) y las rutas `/api/*` y `/healthz` se reenvían por
proxy al servicio Django. Detalles en [Material de la UT4](../index.md).