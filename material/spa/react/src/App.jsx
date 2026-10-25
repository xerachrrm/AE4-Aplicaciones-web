import { useEffect, useState } from "react";

// Microproyecto React: contador local + mensaje de la API Django.
export default function App() {
  const [visitas, setVisitas] = useState(0);
  const [mensaje, setMensaje] = useState("Cargando…");

  useEffect(() => {
    fetch("/api/mensaje")
      .then((respuesta) => respuesta.json())
      .then((datos) => setMensaje(datos.mensaje))
      .catch(() => setMensaje("API no disponible"));
  }, []);

  return (
    <main>
      <h1>Microproyecto React</h1>
      <p>{mensaje}</p>
      <p>Contador: {visitas}</p>
      <button type="button" onClick={() => setVisitas(visitas + 1)}>
        Sumar 1
      </button>
    </main>
  );
}