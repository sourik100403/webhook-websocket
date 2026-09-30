#!/bin/bash

# ==========================================================
# Stop Webhook + WebSocket Learning Project
# ==========================================================

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

PID_FILE="$ROOT_DIR/.service-pids"

echo ""
echo "=================================================="
echo "STOPPING ALL SERVICES"
echo "=================================================="
echo ""

# ==========================================================
# Stop processes from PID file
# ==========================================================

if [ -f "$PID_FILE" ]; then

    while read PID
    do

        if [ -n "$PID" ]; then

            if kill -0 "$PID" 2>/dev/null; then

                echo "Stopping PID $PID"

                kill "$PID" 2>/dev/null

            fi

        fi

    done < "$PID_FILE"

else

    echo "PID file not found."
    echo "Checking ports directly..."
fi

# ==========================================================
# Give processes time to stop
# ==========================================================

sleep 3

# ==========================================================
# Make sure ports are free
# ==========================================================

for PORT in 8080 8081 8082
do

    PID=$(lsof -ti tcp:$PORT)

    if [ -n "$PID" ]; then

        echo "Force stopping PID $PID on port $PORT"

        kill -9 "$PID" 2>/dev/null

    fi

done

# ==========================================================
# Remove PID file
# ==========================================================

rm -f "$PID_FILE"

# ==========================================================
# Verify
# ==========================================================

echo ""
echo "=================================================="
echo "PORT STATUS"
echo "=================================================="
echo ""

for PORT in 8080 8081 8082
do

    PID=$(lsof -ti tcp:$PORT)

    if [ -n "$PID" ]; then

        echo "❌ Port $PORT is still in use"

    else

        echo "✅ Port $PORT is free"

    fi

done

echo ""
echo "=================================================="
echo "ALL SERVICES STOPPED"
echo "=================================================="
echo ""