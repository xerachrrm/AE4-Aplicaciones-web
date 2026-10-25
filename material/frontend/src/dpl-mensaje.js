// Componente <dpl-mensaje>: pide /api/mensaje y pinta el resultado en su
// shadow DOM. El trabajo asíncrono (fetch + promesas) se estudia en DWEC.
export class DplMensaje extends HTMLElement {
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
        <h2>${this._escapar(datos.mensaje)}</h2>
        <p>Servido desde el contenedor <strong>${this._escapar(datos.hostname)}</strong></p>
        <p><small>${this._escapar(datos.fecha)}</small></p>`;
    } catch (error) {
      this.shadowRoot.innerHTML =
        `<p>No se pudo cargar /api/mensaje: ${error.message}</p>`;
    }
  }

  _escapar(texto) {
    return String(texto).replace(/[&<>"']/g, (c) => ({
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#39;",
    }[c]));
  }
}

customElements.define("dpl-mensaje", DplMensaje);