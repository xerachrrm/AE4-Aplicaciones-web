// Componente <dpl-visitas>: consulta /api/visitas (contador persistido en el
// volumen /data del servidor de aplicaciones) y permite recargar el valor.
export class DplVisitas extends HTMLElement {
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

customElements.define("dpl-visitas", DplVisitas);