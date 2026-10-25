<script>
  // Microproyecto Svelte: contador local + mensaje de la API Django.
  let visitas = 0;
  let mensaje = "Cargando…";

  fetch("/api/mensaje")
    .then((respuesta) => respuesta.json())
    .then((datos) => {
      mensaje = datos.mensaje;
    })
    .catch(() => {
      mensaje = "API no disponible";
    });
</script>

<main>
  <h1>Microproyecto Svelte</h1>
  <p>{mensaje}</p>
  <p>Contador: {visitas}</p>
  <button type="button" onclick={() => (visitas += 1)}>Sumar 1</button>
</main>