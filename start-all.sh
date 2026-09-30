#!/bin/bash

# ==========================================================
# Webhook + WebSocket Learning Project
# Start + Test All Services
# ==========================================================

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

ORDER_DIR="$ROOT_DIR/order-service"
WEBHOOK_DIR="$ROOT_DIR/webhook-service"
WEBSOCKET_DIR="$ROOT_DIR/websocket-service"

ORDER_PORT=8080
WEBHOOK_PORT=8081
WEBSOCKET_PORT=8082

ORDER_LOG="$ROOT_DIR/order-service.log"
WEBHOOK_LOG="$ROOT_DIR/webhook-service.log"
WEBSOCKET_LOG="$ROOT_DIR/websocket-service.log"

PID_FILE="$ROOT_DIR/.service-pids"

# ==========================================================
# Functions
# ==========================================================

print_header() {

    echo ""
    echo "=================================================="
    echo "$1"
    echo "=================================================="
    echo ""
}

check_port_free() {

    PORT=$1
    SERVICE=$2

    PID=$(lsof -ti tcp:$PORT)

    if [ -n "$PID" ]; then

        echo "❌ Port $PORT is already used by PID $PID"
        echo "Service: $SERVICE"

        echo ""
        echo "Run:"
        echo "lsof -i :$PORT"
        echo ""

        exit 1
    fi
}

wait_for_service() {

    PORT=$1
    SERVICE=$2
    LOG_FILE=$3

    echo "Waiting for $SERVICE on port $PORT..."

    for i in {1..40}
    do

        if lsof -i tcp:$PORT >/dev/null 2>&1; then

            echo "✅ $SERVICE is running"

            return 0
        fi

        sleep 1

        echo -n "."

    done

    echo ""
    echo ""
    echo "❌ $SERVICE failed to start."
    echo ""

    echo "Last 40 lines of $SERVICE log:"
    echo ""

    tail -40 "$LOG_FILE"

    echo ""

    return 1
}

# ==========================================================
# Header
# ==========================================================

print_header "WEBHOOK + WEBSOCKET LOCAL ENVIRONMENT"

# ==========================================================
# Check directories
# ==========================================================

echo "Checking project directories..."

if [ ! -f "$ORDER_DIR/pom.xml" ]; then
    echo "❌ order-service/pom.xml not found"
    exit 1
fi

if [ ! -f "$WEBHOOK_DIR/pom.xml" ]; then
    echo "❌ webhook-service/pom.xml not found"
    exit 1
fi

if [ ! -f "$WEBSOCKET_DIR/pom.xml" ]; then
    echo "❌ websocket-service/pom.xml not found"
    exit 1
fi

echo "✅ All projects found."

# ==========================================================
# Check ports
# ==========================================================

print_header "CHECKING PORTS"

check_port_free $ORDER_PORT "Order Service"
check_port_free $WEBHOOK_PORT "Webhook Service"
check_port_free $WEBSOCKET_PORT "WebSocket Service"

echo "✅ Ports 8080, 8081 and 8082 are free."

# ==========================================================
# Remove old PID file
# ==========================================================

rm -f "$PID_FILE"

# ==========================================================
# Clear old logs
# ==========================================================

> "$ORDER_LOG"
> "$WEBHOOK_LOG"
> "$WEBSOCKET_LOG"

# ==========================================================
# Start Order Service
# ==========================================================

print_header "STARTING ORDER SERVICE :8080"

cd "$ORDER_DIR"

mvn spring-boot:run > "$ORDER_LOG" 2>&1 &

ORDER_PID=$!

echo "$ORDER_PID" >> "$PID_FILE"

echo "Order Service PID: $ORDER_PID"

# ==========================================================
# Wait Order
# ==========================================================

if ! wait_for_service \
    $ORDER_PORT \
    "Order Service" \
    "$ORDER_LOG"; then

    echo "Stopping failed startup..."
    kill "$ORDER_PID" 2>/dev/null

    exit 1
fi

# ==========================================================
# Start Webhook
# ==========================================================

print_header "STARTING WEBHOOK SERVICE :8081"

cd "$WEBHOOK_DIR"

mvn spring-boot:run > "$WEBHOOK_LOG" 2>&1 &

WEBHOOK_PID=$!

echo "$WEBHOOK_PID" >> "$PID_FILE"

echo "Webhook Service PID: $WEBHOOK_PID"

# ==========================================================
# Wait Webhook
# ==========================================================

if ! wait_for_service \
    $WEBHOOK_PORT \
    "Webhook Service" \
    "$WEBHOOK_LOG"; then

    echo "Stopping services..."

    kill "$ORDER_PID" 2>/dev/null
    kill "$WEBHOOK_PID" 2>/dev/null

    exit 1
fi

# ==========================================================
# Start WebSocket
# ==========================================================

print_header "STARTING WEBSOCKET SERVICE :8082"

cd "$WEBSOCKET_DIR"

mvn spring-boot:run > "$WEBSOCKET_LOG" 2>&1 &

WEBSOCKET_PID=$!

echo "$WEBSOCKET_PID" >> "$PID_FILE"

echo "WebSocket Service PID: $WEBSOCKET_PID"

# ==========================================================
# Wait WebSocket
# ==========================================================

if ! wait_for_service \
    $WEBSOCKET_PORT \
    "WebSocket Service" \
    "$WEBSOCKET_LOG"; then

    echo "Stopping services..."

    kill "$ORDER_PID" 2>/dev/null
    kill "$WEBHOOK_PID" 2>/dev/null
    kill "$WEBSOCKET_PID" 2>/dev/null

    exit 1
fi

# ==========================================================
# All Services Running
# ==========================================================

print_header "ALL SERVICES RUNNING"

echo "✅ Order Service     : http://localhost:8080"
echo "✅ Webhook Service   : http://localhost:8081"
echo "✅ WebSocket Service : http://localhost:8082"

echo ""
echo "PID file:"
echo "$PID_FILE"

# ==========================================================
# TEST 1 - Order Service
# ==========================================================

print_header "TEST 1 - ORDER SERVICE"

echo "POST /api/orders"
echo ""

ORDER_RESPONSE=$(curl -s -X POST \
    http://localhost:8080/api/orders \
    -H "Content-Type: application/json" \
    -d '{
        "product": "Sony ZV-E10",
        "quantity": 2
    }')

echo "Response:"
echo "$ORDER_RESPONSE"

# ==========================================================
# TEST 2 - Webhook Service
# ==========================================================

print_header "TEST 2 - WEBHOOK SERVICE"

echo "POST /webhook/order"
echo ""

WEBHOOK_RESPONSE=$(curl -s -X POST \
    http://localhost:8081/webhook/order \
    -H "Content-Type: application/json" \
    -d '{
        "event": "ORDER_CREATED",
        "orderId": "ORD-MANUAL-001",
        "product": "Webhook Test Camera",
        "quantity": 1
    }')

echo "Response:"
echo "$WEBHOOK_RESPONSE"

# ==========================================================
# TEST 3 - WebSocket/SockJS
# ==========================================================

print_header "TEST 3 - WEBSOCKET SERVICE"

echo "GET /ws/info"
echo ""

WS_RESPONSE=$(curl -s \
    http://localhost:8082/ws/info)

echo "Response:"
echo "$WS_RESPONSE"

# ==========================================================
# TEST 4 - COMPLETE END-TO-END
# ==========================================================

print_header "TEST 4 - COMPLETE END-TO-END FLOW"

echo "Creating real order..."
echo ""

FINAL_RESPONSE=$(curl -s -X POST \
    http://localhost:8080/api/orders \
    -H "Content-Type: application/json" \
    -d '{
        "product": "End-To-End Sony Camera",
        "quantity": 3
    }')

echo "Order API Response:"
echo "$FINAL_RESPONSE"

echo ""
echo "Expected flow:"
echo ""
echo "Order Service :8080"
echo "       ↓"
echo "Webhook Service :8081"
echo "       ↓"
echo "WebSocket Service :8082"
echo "       ↓"
echo "Browser"
echo ""

# ==========================================================
# Final Port Check
# ==========================================================

print_header "FINAL SERVICE STATUS"

if lsof -i tcp:8080 >/dev/null 2>&1; then
    echo "✅ Order Service     :8080"
else
    echo "❌ Order Service     :8080"
fi

if lsof -i tcp:8081 >/dev/null 2>&1; then
    echo "✅ Webhook Service   :8081"
else
    echo "❌ Webhook Service   :8081"
fi

if lsof -i tcp:8082 >/dev/null 2>&1; then
    echo "✅ WebSocket Service :8082"
else
    echo "❌ WebSocket Service :8082"
fi

# ==========================================================
# Browser Instructions
# ==========================================================

print_header "BROWSER WEBSOCKET TEST"

echo "Open:"
echo ""
echo "http://localhost:8082"
echo ""
echo "Then:"
echo "1. Click Connect"
echo "2. Keep browser open"
echo "3. Create another order from terminal"
echo ""
echo "Example:"
echo ""
echo "curl -X POST http://localhost:8080/api/orders \\"
echo "-H \"Content-Type: application/json\" \\"
echo "-d '{"
echo "  \"product\": \"Sony FX3\","
echo "  \"quantity\": 1"
echo "}'"

print_header "START COMPLETE"

echo "All services are running."
echo ""
echo "To stop everything:"
echo "./stop-all.sh"
echo ""
echo "To view logs:"
echo "tail -f order-service.log"
echo "tail -f webhook-service.log"
echo "tail -f websocket-service.log"