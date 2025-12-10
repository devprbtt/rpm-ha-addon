# Use a simpler base image without s6
FROM python:3.9-alpine

# Stage 1: Build the React frontend
FROM node:18-slim AS frontend
WORKDIR /frontend
COPY ./frontend/package*.json ./
RUN npm ci --no-progress
COPY ./frontend/ ./
RUN npm run build

# Stage 2: Create the Python backend
FROM python:3.9-alpine
ENV PYTHONUNBUFFERED=1 \
    INSTANCE_PATH=/data
WORKDIR /app

# System deps for building pillow/reportlab and running bash scripts
RUN apk add --no-cache \
    bash \
    build-base \
    freetype-dev \
    jpeg-dev \
    lcms2-dev \
    libffi-dev \
    libpng-dev \
    openjpeg-dev \
    tiff-dev \
    zlib-dev

# Install backend dependencies
COPY ./backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend source and then overlay fresh frontend build
COPY ./backend/ ./
COPY --from=frontend /frontend/dist ./static

# Create the data directory for SQLite
RUN mkdir -p /data

# Simple run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]

EXPOSE 5000