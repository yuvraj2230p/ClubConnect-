FROM python:3.12-slim

WORKDIR /app

# Install system dependencies (build tools, cmake, and OpenCV/Pillow libs)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    g++ \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, and wheel so binary wheels install cleanly
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install Python requirements
COPY backend/requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy all backend code & pre-compiled flutter_web static files
COPY backend/ .

ENV PORT=8000
EXPOSE 8000

CMD ["sh", "-c", "python manage.py migrate --noinput && python seed_data.py && gunicorn config.wsgi:application --bind 0.0.0.0:$PORT --workers 2"]
