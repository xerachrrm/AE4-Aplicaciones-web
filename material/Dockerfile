# Imagen del servidor de aplicaciones Django (curso DPL, UT4) — versión de referencia
#
# Este Dockerfile está pensado para construirse desde la RAÍZ del proyecto
# (contexto raíz: COPY app/...), una variante útil si tu entrega sitúa el
# Dockerfile en la raíz. El compose.yml del material construye la imagen
# desde ./app usando app/Dockerfile (misma receta, contexto app/); ambos son
# equivalentes.
#
# Uso: docker compose up -d    (o manualmente: docker build -t dpl-app:local .)
#
# Imagen base: python:3.12-slim (versión orientativa). Alternativa coherente
# con el resto del curso: FROM ubuntu:24.04 + apt-get install -y python3
# python3-pip (ver docs/introduccion/entorno.md).
FROM python:3.12-slim

# Carpeta de trabajo dentro del contenedor
WORKDIR /app

# 1) Dependencias primero: solo se reinstalan si cambia requirements.txt
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 2) Código del proyecto Django (manage.py, config/, api/)
COPY app/ .

# 3) Usuario sin privilegios (buena práctica) y carpeta de datos propia
RUN useradd --create-home --uid 1000 appuser \
    && mkdir -p /data \
    && chown appuser:appuser /data
USER appuser

# Puerto interno del servidor de aplicaciones (Gunicorn)
EXPOSE 8000

# Arranque: Gunicorn sirve la aplicación WSGI de Django (config.wsgi).
# --workers 2: dos procesos para atender peticiones en paralelo (orientativo).
# --access-logfile - : registra cada petición en la salida estándar (logs).
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "2", "--access-logfile", "-"]