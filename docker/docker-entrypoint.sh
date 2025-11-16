#!/bin/bash
set -e
# Docker entrypoint to prepare .env from .sample.env and inject env vars when present
cd /app
# Copy sample env if .env not present
if [ ! -f .env ]; then
    if [ -f .sample.env ]; then
        cp .sample.env .env
        echo "Copied .sample.env to .env"
    fi
fi
# Helper to set or replace key=value in .env
set_env_var() {
    KEY=$1
    VALUE=$2
    if [ -z "$VALUE" ]; then
        return
    fi
    if grep -qE "^${KEY}=" .env; then
        sed -i "s|^${KEY}=.*|${KEY}=${VALUE}|" .env
    else
        echo "${KEY}=${VALUE}" >> .env
    fi
}
# Environment variables to bootstrap into .env if provided
set_env_var "BROKER_API_KEY" "$BROKER_API_KEY"
set_env_var "BROKER_API_SECRET" "$BROKER_API_SECRET"
set_env_var "REDIRECT_URL" "$REDIRECT_URL"
set_env_var "DATABASE_URL" "$DATABASE_URL"
set_env_var "LOGS_DATABASE_URL" "$LOGS_DATABASE_URL"
set_env_var "LATENCY_DATABASE_URL" "$LATENCY_DATABASE_URL"
set_env_var "SANDBOX_DATABASE_URL" "$SANDBOX_DATABASE_URL"
# Ensure data/db exists and is writable if a persistent volume is mounted
mkdir -p /data/db || true
# Hand off to the standard start script
exec /app/start.sh
