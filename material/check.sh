#!/usr/bin/env bash
# check.sh — Comprobación objetiva del despliegue dpl-app (curso DPL, UT4)
# Uso: ejecutar en el directorio donde está compose.yml:
#   ./check.sh
# Salida: 0 si todo OK, 1 si algo falla (con mensajes claros).
# Puerto configurable: PUERTO=8080 ./check.sh
set -euo pipefail

PUERTO="${PUERTO:-8000}"
BASE="http://localhost:${PUERTO}"
PGADMIN_URL="http://localhost:${PGADMIN_PUERTO:-5050}"
FALLO=0

echo "=== Comprobación del despliegue: dpl-app en el puerto ${PUERTO} ==="

# 0) ¿Estamos en la carpeta del despliegue?
if [ ! -f compose.yml ]; then
    echo "[ERROR] No se encuentra compose.yml en el directorio actual."
    echo "        Ejecuta el script desde la carpeta donde está el despliegue."
    exit 1
fi

# Servicios definidos en compose.yml (condicionan las comprobaciones)
SERVICIOS="$(docker compose config --services 2>/dev/null || true)"

# 1) ¿Están en ejecución todos los servicios definidos?
ESPERADOS="$(printf '%s\n' "${SERVICIOS}" | grep -c . || true)"
EN_MARCHA="$(docker compose ps --format '{{.Service}}' 2>/dev/null | grep -c . || true)"
if [ "${ESPERADOS}" -gt 0 ] && [ "${EN_MARCHA}" -ge "${ESPERADOS}" ]; then
    echo "[OK] Los ${EN_MARCHA} servicios definidos están en ejecución (Up)"
else
    echo "[ERROR] Servicios en ejecución: ${EN_MARCHA} de ${ESPERADOS} esperados."
    echo "        Revisa: docker compose ps   y   docker compose logs --tail=20"
    FALLO=1
fi

# 2) Capa de datos: PostgreSQL (solo si el servicio "db" está definido)
if printf '%s\n' "${SERVICIOS}" | grep -qx "db"; then
    if docker compose exec -T db pg_isready -U alumno -d travelroad >/dev/null 2>&1; then
        echo "[OK] PostgreSQL responde (pg_isready -U alumno -d travelroad)"
    else
        echo "[ERROR] PostgreSQL no responde."
        echo "        Revisa: docker compose logs db --tail=20"
        FALLO=1
    fi
fi

# 3) ¿La página principal (build de Vite servido por nginx) responde?
PAGINA="$(curl -sf "${BASE}/" || true)"
if printf '%s' "${PAGINA}" | grep -q "dpl-visitas"; then
    echo "[OK] La página / responde e incluye el componente dpl-visitas"
else
    echo "[ERROR] La página / no responde o no incluye el componente dpl-visitas"
    FALLO=1
fi

# 4) ¿El endpoint de salud /healthz devuelve 200?
if curl -sf "${BASE}/healthz" > /dev/null; then
    echo "[OK] El endpoint /healthz responde 200"
else
    echo "[ERROR] El endpoint /healthz no responde (esperado 200)"
    FALLO=1
fi

# 5) ¿La API /api/mensaje devuelve JSON con "mensaje"?
MENSAJE="$(curl -sf "${BASE}/api/mensaje" || true)"
if printf '%s' "${MENSAJE}" | grep -q '"mensaje"'; then
    echo "[OK] La API /api/mensaje devuelve JSON"
else
    echo "[ERROR] La API /api/mensaje no devuelve JSON válido"
    FALLO=1
fi

# 6) ¿La API /api/lugares devuelve los datos de PostgreSQL? (si hay "db")
if printf '%s\n' "${SERVICIOS}" | grep -qx "db"; then
    LUGARES="$(curl -sf "${BASE}/api/lugares" || true)"
    if printf '%s' "${LUGARES}" | grep -q '"lugares"'; then
        echo "[OK] La API /api/lugares devuelve los datos de PostgreSQL"
    else
        echo "[ERROR] La API /api/lugares no devuelve los datos de PostgreSQL"
        echo "        Revisa: docker compose logs django --tail=20"
        FALLO=1
    fi
fi

# 7) ¿El contador /api/visitas incrementa (persistencia del volumen)?
V1=$(curl -s "${BASE}/api/visitas" | grep -o '"visitas": *[0-9]*' | grep -o '[0-9]*' || true)
V2=$(curl -s "${BASE}/api/visitas" | grep -o '"visitas": *[0-9]*' | grep -o '[0-9]*' || true)
if [ -n "${V1}" ] && [ -n "${V2}" ] && [ "${V2}" -gt "${V1}" ]; then
    echo "[OK] El contador /api/visitas incrementa (${V1} -> ${V2})"
else
    echo "[ERROR] El contador /api/visitas no incrementa"
    FALLO=1
fi

# 8) pgAdmin (solo si el servicio está definido): espera hasta 180 s a /misc/ping
if printf '%s\n' "${SERVICIOS}" | grep -qx "pgadmin"; then
    PGADMIN_OK=0
    INTENTOS=0
    while [ "${INTENTOS}" -lt 36 ]; do
        PING="$(curl -sf "${PGADMIN_URL}/misc/ping" 2>/dev/null || true)"
        if printf '%s' "${PING}" | grep -q "PING"; then
            PGADMIN_OK=1
            break
        fi
        INTENTOS=$((INTENTOS + 1))
        sleep 5
    done
    if [ "${PGADMIN_OK}" -eq 1 ]; then
        echo "[OK] pgAdmin responde en ${PGADMIN_URL} (login con las credenciales del entorno)"
    else
        echo "[ERROR] pgAdmin no responde en ${PGADMIN_URL}"
        echo "        Revisa: docker compose logs pgadmin --tail=20"
        FALLO=1
    fi
fi

# 9) Script Python opcional con requests (vínculo DWES), si está disponible
if python3 -c "import requests" 2>/dev/null; then
    # check_api.py debe usar el mismo puerto que este script (DPL_BASE_URL) y
    # omitir /api/lugares cuando el despliegue no define el servicio "db".
    SIN_BD=1
    if printf '%s\n' "${SERVICIOS}" | grep -qx "db"; then
        SIN_BD=0
    fi
    if DPL_BASE_URL="${BASE}" DPL_SIN_BD="${SIN_BD}" python3 check_api.py; then
        echo "[OK] check_api.py (requests) superado"
    else
        echo "[ERROR] check_api.py (requests) ha fallado"
        FALLO=1
    fi
else
    echo "[AVISO] python3 con 'requests' no disponible; se omite check_api.py"
fi

# 10) Últimas líneas de los registros (informativo)
echo "--- Últimas líneas de docker compose logs ---"
docker compose logs --tail=10 2>/dev/null || echo "(no hay logs disponibles)"

echo ""
if [ "${FALLO}" -eq 0 ]; then
    echo "=== RESULTADO: TODO OK ==="
    exit 0
fi
echo "=== RESULTADO: CON ERRORES (revisa los mensajes anteriores) ==="
exit 1
