<script setup>
// Microproyecto Vue: contador local + mensaje de la API Django.
import { ref } from "vue";

const visitas = ref(0);
const mensaje = ref("Cargando…");

fetch("/api/mensaje")
  .then((respuesta) => respuesta.json())
  .then((datos) => {
    mensaje.value = datos.mensaje;
  })
  .catch(() => {
    mensaje.value = "API no disponible";
  });
</script>

<template>
  <main>
    <h1>Microproyecto Vue</h1>
    <p>{{ mensaje }}</p>
    <p>Contador: {{ visitas }}</p>
    <button type="button" @click="visitas++">Sumar 1</button>
  </main>
</template>