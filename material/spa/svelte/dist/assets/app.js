// Build de demostración del microproyecto Svelte (dist/ generado manualmente,
// NO verificado con npm build). El build real se regenera desde spa/svelte/:
//   npm install && npm run build
// (requiere Node.js 22 o superior, versión orientativa).
//
// Este fichero equivale al bundle que Vite + Svelte producirían: contador
// local y mensaje de la API Django (/api/mensaje). Se sirve con nginx y
// `try_files ... /index.html` (enrutado SPA).

let visitas = 0;
const contador = document.getElementById("contador");
const mensaje = document.getElementById("mensaje");

document.getElementById("sumar").addEventListener("click", () => {
  visitas += 1;
  contador.textContent = String(visitas);
});

fetch("/api/mensaje")
  .then((respuesta) => respuesta.json())
  .then((datos) => {
    mensaje.textContent = datos.mensaje;
  })
  .catch(() => {
    mensaje.textContent = "API no disponible";
  });