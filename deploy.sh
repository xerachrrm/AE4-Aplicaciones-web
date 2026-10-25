#!/usr/bin/env bash
# Script de despliegue automatizado para la AE4

set -e

echo "=== 1. Construyendo los contenedores ==="
docker compose build

echo "=== 2. Arrancando los servicios con Docker Compose ==="
docker compose up -d

echo "=== 3. Esperando a que la aplicación esté lista (/healthz) ==="
intentos=1
while [ $intentos -le 30 ]; do
  if curl -sf http://localhost:8000/healthz > /dev/null; then
    echo "¡La aplicación está en línea y funcionando correctamente!"
    exit 0
  fi
  echo "Esperando a que la app responda... intento $intentos/30"
  sleep 2
  intentos=$((intentos + 1))
done

echo "Error: La aplicación no respondió a tiempo."
exit 1