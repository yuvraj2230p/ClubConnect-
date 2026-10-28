FROM python:3.11-slim

WORKDIR /app

# Install system dependencies for Pillow, ZXing, and OpenCV
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy all backend code & pre-compiled flutter_web static files
COPY backend/ .

ENV PORT=8000
EXPOSE 8000

CMD ["sh", "-c", "python manage.py migrate --noinput && python seed_data.py && gunicorn config.wsgi:application --bind 0.0.0.0:$PORT --workers 3"]
