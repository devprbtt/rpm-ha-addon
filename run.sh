#!/bin/sh

echo "Starting Roehn Automacao..."

cd /app

export FLASK_APP=app.py
export FLASK_ENV=production
export INSTANCE_PATH=/data

python3 -m flask run --host=0.0.0.0 --port=5000