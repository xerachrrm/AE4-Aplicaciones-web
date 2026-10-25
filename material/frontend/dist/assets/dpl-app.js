// Build de demostración del frontend DPL (dist/ generado manualmente,
// NO verificado con npm build). El build real se regenera desde la carpeta
// frontend/ con:
//   npm install && npm run build
// (requiere Node.js 22 o superior, versión orientativa).
//
// Este fichero equivale al bundle que Vite generaría: registra los dos
// Web Components de la aplicación (dpl-mensaje y dpl-visitas) que consumen
// la API Django a través del proxy inverso de nginx.

function escapar(texto) {
  return String(texto).replace(/[&<>"']/g, (c) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
  }[c]));
}

class DplMensaje extends HTMLElement {
  connectedCallback() {
    this.attachShadow({ mode: "open" });
    this.shadowRoot.innerHTML = `<p>Cargando mensaje…</p>`;
    this._cargar();
  }

  async _cargar() {
    try {
      const respuesta = await fetch("/api/mensaje");
      if (!respuesta.ok) {
        throw new Error(`HTTP ${respuesta.status}`);
      }
      const datos = await respuesta.json();
      this.shadowRoot.innerHTML = `
        <h2>${escapar(datos.mensaje)}</h2>
        <p>Servido desde el contenedor <strong>${escapar(datos.hostname)}</strong></p>
        <p><small>${escapar(datos.fecha)}</small></p>`;
    } catch (error) {
      this.shadowRoot.innerHTML =
        `<p>No se pudo cargar /api/mensaje: ${error.message}</p>`;
    }
  }
}

class DplVisitas extends HTMLElement {
  connectedCallback() {
    this.attachShadow({ mode: "open" });
    this.shadowRoot.innerHTML = `
      <style>
        :host { display: block; margin-top: 1rem; }
        .visitas { font-size: 1.1rem; }
        button { margin-top: 0.5rem; cursor: pointer; }
      </style>
      <p class="visitas">Cargando visitas…</p>
      <button type="button">Recargar</button>`;
    this.shadowRoot
      .querySelector("button")
      .addEventListener("click", () => this._cargar());
    this._cargar();
  }

  async _cargar() {
    try {
      const respuesta = await fetch("/api/visitas");
      if (!respuesta.ok) {
        throw new Error(`HTTP ${respuesta.status}`);
      }
      const datos = await respuesta.json();
      this.shadowRoot.querySelector(".visitas").textContent =
        `Visitas totales: ${datos.visitas}`;
    } catch (error) {
      this.shadowRoot.querySelector(".visitas").textContent =
        `No se pudo cargar /api/visitas: ${error.message}`;
    }
  }
}

customElements.define("dpl-mensaje", DplMensaje);
customElements.define("dpl-visitas", DplVisitas);