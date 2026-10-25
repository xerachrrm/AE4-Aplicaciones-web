#!/usr/bin/env python3
"""check_api.py — Comprobación de la API con peticiones reales (requests).

Vínculo con el módulo DWES: las mismas comprobaciones del check.sh hechas
con un cliente HTTP de Python. Uso (desde el directorio del despliegue):

    python3 check_api.py

Requiere el paquete 'requests' (instalado en el contenedor dpl-cliente del
curso; en tu equipo: pip install requests). Puerto configurable:

    DPL_BASE_URL=http://localhost:8080 python3 check_api.py

Si tu despliegue no tiene capa de datos, omite la comprobación de
/api/lugares con la variable DPL_SIN_BD=1.

Salida: 0 si todo OK, 1 si algo falla.
"""

import os
import sys

import requests

BASE = os.environ.get("DPL_BASE_URL", "http://localhost:8000")


def comprobar(descripcion, condicion):
    if condicion:
        print(f"[OK] {descripcion}")
        return 0
    print(f"[ERROR] {descripcion}")
    return 1


def main():
    fallos = 0

    # 1) Página principal servida por nginx (build de Vite)
    respuesta = requests.get(f"{BASE}/", timeout=5)
    fallos += comprobar(
        "la página / responde 200 e incluye el componente dpl-visitas",
        respuesta.status_code == 200 and "dpl-visitas" in respuesta.text,
    )

    # 2) Endpoint de salud
    respuesta = requests.get(f"{BASE}/healthz", timeout=5)
    try:
        salud_ok = respuesta.status_code == 200 and "status" in respuesta.json()
    except ValueError:
        salud_ok = False
    fallos += comprobar("/healthz responde 200 con JSON de estado", salud_ok)

    # 3) API /api/mensaje: JSON con mensaje, hostname y fecha
    respuesta = requests.get(f"{BASE}/api/mensaje", timeout=5)
    try:
        datos = respuesta.json()
        mensaje_ok = (
            respuesta.status_code == 200
            and all(clave in datos for clave in ("mensaje", "hostname", "fecha"))
        )
    except ValueError:
        datos = {}
        mensaje_ok = False
    fallos += comprobar(
        "/api/mensaje devuelve JSON {mensaje, hostname, fecha}", mensaje_ok
    )
    if mensaje_ok:
        print(f"        mensaje: {datos['mensaje']}  (hostname: {datos['hostname']})")

    # 4) Contador persistente: dos llamadas seguidas deben incrementar
    try:
        primera = requests.get(f"{BASE}/api/visitas", timeout=5).json()
        segunda = requests.get(f"{BASE}/api/visitas", timeout=5).json()
        incrementa = (
            "visitas" in primera
            and "visitas" in segunda
            and segunda["visitas"] > primera["visitas"]
        )
    except ValueError:
        incrementa = False
    fallos += comprobar("el contador /api/visitas incrementa entre llamadas", incrementa)

    # 5) Capa de datos: /api/lugares devuelve las filas de PostgreSQL
    #    (se omite si el despliegue no tiene base de datos: DPL_SIN_BD=1)
    if os.environ.get("DPL_SIN_BD") == "1":
        print("[AVISO] /api/lugares omitido (DPL_SIN_BD=1)")
    else:
        respuesta = requests.get(f"{BASE}/api/lugares", timeout=5)
        try:
            datos = respuesta.json()
            lugares_ok = (
                respuesta.status_code == 200
                and isinstance(datos.get("lugares"), list)
                and len(datos["lugares"]) > 0
            )
        except ValueError:
            lugares_ok = False
        fallos += comprobar(
            "/api/lugares devuelve los datos de PostgreSQL", lugares_ok
        )
        if lugares_ok:
            print(f"        lugares recuperados: {len(datos['lugares'])}")

    print()
    if fallos == 0:
        print("=== RESULTADO: TODO OK ===")
        return 0
    print("=== RESULTADO: CON ERRORES ===")
    return 1


if __name__ == "__main__":
    sys.exit(main())