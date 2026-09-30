# 🚀 Webhook + WebSocket Spring Boot Demo

A practical **event-driven microservices project** built with Spring Boot that demonstrates:

- REST API
- Microservice-to-microservice communication
- Webhooks
- WebSockets
- STOMP
- SockJS
- Real-time browser notifications
- Automated service startup/shutdown
- End-to-end event flow

The project contains three independent Spring Boot services that communicate with each other.

---

## 📌 Architecture

```text
                         CLIENT
                           |
                           | POST /api/orders
                           v
                  +---------------------+
                  |    ORDER SERVICE    |
                  |       :8080         |
                  +----------+----------+
                             |
                             |
                             | HTTP Webhook
                             | POST /webhook/order
                             v
                  +---------------------+
                  |   WEBHOOK SERVICE   |
                  |       :8081         |
                  +----------+----------+
                             |
                             |
                             | HTTP Notification
                             | POST /api/notifications/order
                             v
                  +---------------------+
                  | WEBSOCKET SERVICE   |
                  |       :8082         |
                  +----------+----------+
                             |
                             |
                             | STOMP / WebSocket
                             | /topic/orders
                             v
                  +---------------------+
                  |      BROWSER        |
                  |   Real-time UI      |
                  +---------------------+
```

---

# 📚 Table of Contents

1. [Project Overview](#-project-overview)
2. [Services](#-services)
3. [Technology Stack](#-technology-stack)
4. [Project Structure](#-project-structure)
5. [Complete Event Flow](#-complete-event-flow)
6. [Order Service](#-order-service)
7. [Webhook Service](#-webhook-service)
8. [WebSocket Service](#-websocket-service)
9. [Running the Project](#-running-the-project)
10. [End-to-End Testing](#-end-to-end-testing)
11. [Testing Individual Services](#-testing-individual-services)
12. [Logs](#-logs)
13. [Stop All Services](#-stop-all-services)
14. [Troubleshooting](#-troubleshooting)
15. [Webhook vs WebSocket](#-webhook-vs-websocket)
16. [Why Webhooks](#-why-webhooks)
17. [Why WebSockets](#-why-websockets)
18. [Local Architecture](#-local-architecture)
19. [Future AWS Architecture](#-future-aws-architecture)
20. [Local to AWS Mapping](#-local-to-aws-mapping)
21. [Learning Roadmap](#-learning-roadmap)
22. [Project Status](#-project-status)

---

# 📖 Project Overview

This project demonstrates how multiple Spring Boot services can communicate using different communication patterns.

The main flow is:

```text
Client
  |
  | REST API
  v
Order Service
  |
  | Webhook
  v
Webhook Service
  |
  | HTTP
  v
WebSocket Service
  |
  | STOMP
  v
Browser
```

When a new order is created, the event travels through the services and finally appears in the browser as a real-time notification.

Example:

```text
🔔 Order Created: ORD-12345 | Sony FX3 | Quantity: 2
```

---

# 🧩 Services

## 1. Order Service

Port:

```text
8080
```

Responsibilities:

- Create orders
- Generate Order ID
- Accept REST requests
- Trigger webhook

Endpoint:

```http
POST /api/orders
```

---

## 2. Webhook Service

Port:

```text
8081
```

Responsibilities:

- Receive webhook events
- Process order events
- Forward notification events

Endpoint:

```http
POST /webhook/order
```

---

## 3. WebSocket Service

Port:

```text
8082
```

Responsibilities:

- Accept notification events
- Maintain WebSocket connections
- Broadcast notifications using STOMP
- Provide browser UI

HTTP endpoint:

```http
POST /api/notifications/order
```

WebSocket endpoint:

```text
/ws
```

STOMP topic:

```text
/topic/orders
```

---

# 🛠 Technology Stack

| Technology | Purpose |
|---|---|
| Java 21 | Programming language |
| Spring Boot 3.5.3 | Backend framework |
| Spring Web | REST API |
| Spring WebSocket | WebSocket support |
| STOMP | Messaging protocol |
| SockJS | WebSocket fallback |
| Maven | Build tool |
| HTML | Browser UI |
| JavaScript | WebSocket client |
| curl | API testing |
| Git | Version control |
| GitHub | Source code repository |

---

# 📁 Project Structure

```text
webhook-websocket-demo/
│
├── README.md
├── start-all.sh
├── stop-all.sh
│
├── order-service/
│   ├── pom.xml
│   └── src/
│       └── main/
│           ├── java/
│           │   └── com/
│           │       └── learning/
│           │           └── order/
│           │               ├── OrderServiceApplication.java
│           │               │
│           │               ├── controller/
│           │               │   └── OrderController.java
│           │               │
│           │               ├── model/
│           │               │   └── Order.java
│           │               │
│           │               └── service/
│           │                   └── WebhookService.java
│           │
│           └── resources/
│               └── application.properties
│
├── webhook-service/
│   ├── pom.xml
│   └── src/
│       └── main/
│           ├── java/
│           │   └── com/
│           │       └── learning/
│           │           └── webhook/
│           │               ├── WebhookServiceApplication.java
│           │               │
│           │               ├── controller/
│           │               │   └── WebhookController.java
│           │               │
│           │               ├── model/
│           │               │   └── WebhookEvent.java
│           │               │
│           │               └── service/
│           │                   └── NotificationService.java
│           │
│           └── resources/
│               └── application.properties
│
└── websocket-service/
    ├── pom.xml
    └── src/
        └── main/
            ├── java/
            │   └── com/
            │       └── learning/
            │           └── websocket/
            │               ├── WebSocketServiceApplication.java
            │               │
            │               ├── config/
            │               │   └── WebSocketConfig.java
            │               │
            │               └── controller/
            │                   ├── NotificationController.java
            │                   └── WebSocketController.java
            │
            └── resources/
                ├── application.properties
                └── static/
                    └── index.html
```

---

# 🔄 Complete Event Flow

Suppose the client creates this order:

```json
{
  "product": "Sony FX3",
  "quantity": 2
}
```

The complete flow is:

```text
1. Client
      |
      | POST /api/orders
      v
2. Order Service :8080
      |
      | Generate Order ID
      |
      | POST /webhook/order
      v
3. Webhook Service :8081
      |
      | Receive ORDER_CREATED
      |
      | POST /api/notifications/order
      v
4. WebSocket Service :8082
      |
      | STOMP broadcast
      |
      | /topic/orders
      v
5. Browser
      |
      v
Real-time notification
```

---

# 🟢 Order Service

## Port

```text
8080
```

## Create Order API

```http
POST http://localhost:8080/api/orders
```

Example:

```bash
curl -X POST http://localhost:8080/api/orders \
-H "Content-Type: application/json" \
-d '{
  "product": "Sony FX3",
  "quantity": 2
}'
```

Example response:

```json
{
  "orderId": "ORD-xxxxxxxx",
  "product": "Sony FX3",
  "quantity": 2
}
```

The service generates the Order ID automatically:

```text
ORD-xxxxxxxx-xxxx-xxxx
```

---

# 🔔 Webhook Service

## Port

```text
8081
```

## Webhook Endpoint

```http
POST http://localhost:8081/webhook/order
```

Example:

```bash
curl -X POST http://localhost:8081/webhook/order \
-H "Content-Type: application/json" \
-d '{
  "event": "ORDER_CREATED",
  "orderId": "ORD-200",
  "product": "Sony Camera",
  "quantity": 1
}'
```

The Webhook Service receives the event and forwards it to the WebSocket Service.

---

# 🔌 WebSocket Service

## Port

```text
8082
```

## Notification Endpoint

```http
POST http://localhost:8082/api/notifications/order
```

Example:

```bash
curl -X POST http://localhost:8082/api/notifications/order \
-H "Content-Type: application/json" \
-d '{
  "event": "ORDER_CREATED",
  "orderId": "ORD-500",
  "product": "Sony Camera",
  "quantity": 3
}'
```

---

# 🌐 WebSocket Configuration

The application exposes:

```text
/ws
```

STOMP topic:

```text
/topic/orders
```

The browser subscribes to:

```text
/topic/orders
```

The server broadcasts notifications using:

```java
messagingTemplate.convertAndSend(
    "/topic/orders",
    notification
);
```

---

# 🖥 Browser Client

Open:

```text
http://localhost:8082
```

The browser uses:

```text
SockJS
+
STOMP
+
Spring WebSocket
```

Connection:

```text
/ws
```

Subscription:

```text
/topic/orders
```

After connecting, keep the browser open.

---

# 🚀 Running the Project

## Step 1 — Go to Project

```bash
cd /Users/sourikparui/Desktop/webhook-websocket-demo
```

---

## Step 2 — Make Scripts Executable

```bash
chmod +x start-all.sh
chmod +x stop-all.sh
```

---

## Step 3 — Start Everything

```bash
./start-all.sh
```

The script starts:

```text
Order Service       → 8080
Webhook Service     → 8081
WebSocket Service   → 8082
```

It also performs basic tests.

---

# 🌐 Open Browser

After the services start:

```text
http://localhost:8082
```

Click:

```text
Connect
```

Keep the browser open.

---

# 🧪 End-to-End Test

Now create an order:

```bash
curl -X POST http://localhost:8080/api/orders \
-H "Content-Type: application/json" \
-d '{
  "product": "Sony FX3",
  "quantity": 2
}'
```

Expected response:

```json
{
  "orderId": "ORD-xxxx",
  "product": "Sony FX3",
  "quantity": 2
}
```

---

# 🔎 Expected Logs

## Order Service

```text
Order created: ORD-xxxx
Order webhook sent successfully
```

---

## Webhook Service

```text
================================
       WEBHOOK RECEIVED
================================

Event   : ORDER_CREATED
Order ID: ORD-xxxx
Product : Sony FX3
================================

Notification forwarded to WebSocket service
```

---

## WebSocket Service

```text
================================
   ORDER NOTIFICATION RECEIVED
================================

{event=ORDER_CREATED,
 orderId=ORD-xxxx,
 product=Sony FX3,
 quantity=2}

Notification sent to WebSocket clients
================================
```

---

## Browser

The browser should immediately show:

```text
🔔 Order Created: ORD-xxxx | Sony FX3 | Quantity: 2
```

---

# ⚠️ Important WebSocket Testing Rule

Connect the browser **before** creating the order.

Correct sequence:

```text
Start Services
      ↓
Open Browser
      ↓
Connect WebSocket
      ↓
Create Order
      ↓
Webhook
      ↓
WebSocket
      ↓
Browser Notification
```

If the order is created before a browser is connected, there may be no WebSocket client available to receive that notification.

---

# 🧪 Testing Individual Services

## Test Order Service

```bash
curl -X POST http://localhost:8080/api/orders \
-H "Content-Type: application/json" \
-d '{
  "product": "Sony Camera",
  "quantity": 1
}'
```

---

## Test Webhook Service

```bash
curl -X POST http://localhost:8081/webhook/order \
-H "Content-Type: application/json" \
-d '{
  "event": "ORDER_CREATED",
  "orderId": "ORD-999",
  "product": "Sony Camera",
  "quantity": 1
}'
```

---

## Test WebSocket Notification API

```bash
curl -X POST http://localhost:8082/api/notifications/order \
-H "Content-Type: application/json" \
-d '{
  "event": "ORDER_CREATED",
  "orderId": "ORD-500",
  "product": "Sony Camera",
  "quantity": 3
}'
```

If the browser is connected, it should display the notification.

---

# 📜 Logs

Each service writes its output to a separate log.

## Order Service

```bash
tail -f order-service.log
```

## Webhook Service

```bash
tail -f webhook-service.log
```

## WebSocket Service

```bash
tail -f websocket-service.log
```

Check the last 50 lines:

```bash
tail -50 order-service.log
```

---

# 🛑 Stop All Services

Run:

```bash
./stop-all.sh
```

The script stops all services running on:

```text
8080
8081
8082
```

It also verifies that the ports are free.

---

# 🔍 Check Ports

Check all services:

```bash
lsof -i :8080 -i :8081 -i :8082
```

Individual checks:

```bash
lsof -i :8080
```

```bash
lsof -i :8081
```

```bash
lsof -i :8082
```

---

# 🐛 Troubleshooting

## Port 8080 Already in Use

Check:

```bash
lsof -i :8080
```

Kill the process:

```bash
kill -9 <PID>
```

Or:

```bash
./stop-all.sh
```

Then:

```bash
./start-all.sh
```

---

## Port 8081 Already in Use

```bash
lsof -i :8081
```

Then:

```bash
kill -9 <PID>
```

---

## Port 8082 Already in Use

```bash
lsof -i :8082
```

Then:

```bash
kill -9 <PID>
```

---

# ❌ WebSocket Handshake Error

If you see:

```text
Handshake failed due to invalid Upgrade header
```

make sure your WebSocket configuration uses SockJS:

```java
registry.addEndpoint("/ws")
        .setAllowedOriginPatterns("*")
        .withSockJS();
```

The browser uses:

```javascript
new SockJS('/ws');
```

Therefore the server endpoint must support SockJS.

---

# ❌ Browser Does Not Receive Notification

First verify that the browser is connected.

Check:

```bash
tail -f websocket-service.log
```

You should see something similar to:

```text
processed CONNECT(1)-CONNECTED(1)-DISCONNECT(0)
```

Then create an order:

```bash
curl -X POST http://localhost:8080/api/orders \
-H "Content-Type: application/json" \
-d '{
  "product": "Sony FX3",
  "quantity": 2
}'
```

Check:

```text
Order Service
       ↓
Webhook Service
       ↓
WebSocket Service
       ↓
Browser
```

---

# 🔗 Webhook vs WebSocket

| Feature | Webhook | WebSocket |
|---|---|---|
| Communication | HTTP | Persistent connection |
| Typical direction | Server → Server | Server ↔ Client |
| Connection | Request-based | Persistent |
| Main purpose | Event notification | Real-time communication |
| Example | Order → Webhook Service | Server → Browser |
| Protocol | HTTP | WebSocket/STOMP |

---

# 📡 Why Use Webhooks?

Without a webhook, a service might repeatedly ask:

```text
Did an order get created?
Did an order get created?
Did an order get created?
```

This is polling.

With a webhook:

```text
Order Created
      ↓
Webhook
      ↓
Notification Service
```

The receiving service gets notified when the event occurs.

This reduces unnecessary polling.

---

# ⚡ Why Use WebSockets?

Normal HTTP:

```text
Client → Server
         |
         ↓
       Response
```

WebSocket:

```text
Client ←──────────────→ Server
```

The connection remains open.

The server can therefore send updates to the browser immediately.

Common use cases:

- Live notifications
- Chat applications
- Live dashboards
- Order tracking
- Real-time monitoring
- Stock/price updates
- Online gaming
- Delivery tracking

---

# 🏗 Local Architecture

```text
                    ┌──────────────────┐
                    │     CLIENT       │
                    └────────┬─────────┘
                             │
                             │ REST
                             ▼
                    ┌──────────────────┐
                    │  ORDER SERVICE   │
                    │      :8080       │
                    └────────┬─────────┘
                             │
                             │ Webhook
                             ▼
                    ┌──────────────────┐
                    │ WEBHOOK SERVICE  │
                    │      :8081       │
                    └────────┬─────────┘
                             │
                             │ HTTP
                             ▼
                    ┌──────────────────┐
                    │ WEBSOCKET SERVICE│
                    │      :8082       │
                    └────────┬─────────┘
                             │
                             │ STOMP
                             ▼
                    ┌──────────────────┐
                    │     BROWSER      │
                    └──────────────────┘
```

---

# ☁️ Future AWS Architecture

The local project can later evolve into an AWS event-driven architecture.

A possible production architecture:

```text
                         CLIENT
                           |
                           v
                  ┌─────────────────┐
                  │  API GATEWAY    │
                  └────────┬────────┘
                           |
                           v
                  ┌─────────────────┐
                  │ ORDER SERVICE   │
                  │ ECS / Fargate   │
                  └────────┬────────┘
                           |
                           v
                  ┌─────────────────┐
                  │   SNS TOPIC     │
                  └────────┬────────┘
                           |
                ┌──────────┴──────────┐
                │                     │
                v                     v
        ┌───────────────┐     ┌───────────────┐
        │   SQS QUEUE   │     │ Other Service │
        └───────┬───────┘     └───────────────┘
                |
                v
        ┌───────────────┐
        │ WORKER SERVICE│
        └───────┬───────┘
                |
                v
        ┌───────────────┐
        │ NOTIFICATION  │
        │    SERVICE    │
        └───────┬───────┘
                |
                v
        ┌───────────────┐
        │   WEBSOCKET   │
        └───────┬───────┘
                |
                v
             CLIENT
```

---

# ☁️ Local → AWS Mapping

| Local Component | AWS Option |
|---|---|
| REST API | API Gateway |
| Spring Boot Service | ECS / Fargate |
| Docker Container | ECS |
| Webhook/Event | SNS / EventBridge |
| Queue | SQS |
| Pub/Sub | SNS |
| WebSocket | API Gateway WebSocket / ECS |
| Redis | ElastiCache |
| Database | RDS / DynamoDB |
| Logs | CloudWatch |
| Load Balancing | Application Load Balancer |
| Secrets | AWS Secrets Manager |
| Configuration | Systems Manager Parameter Store |
| Files | S3 |
| CI/CD | GitHub Actions / Jenkins |

---

# 🚀 Future Event-Driven Architecture

The next version of this project can become:

```text
                       API Gateway
                            |
                            v
                     Order Service
                            |
                            v
                       SNS Topic
                            |
              ┌─────────────┼─────────────┐
              │             │             │
              v             v             v
             SQS       Notification    Other
            Queue        Service       Service
              |
              v
           Worker
              |
              v
       ┌──────┼─────────┐
       │      │         │
       v      v         v
     Email    SMS     WhatsApp
              |
              v
         WebSocket
              |
              v
           Browser
```

---

# 🧠 What I Learned From This Project

This project demonstrates:

### REST API

```text
Client → Order Service
```

### Webhook

```text
Order Service → Webhook Service
```

### Microservice Communication

```text
Service A → Service B
```

### WebSocket

```text
WebSocket Service → Browser
```

### STOMP

```text
Server
  ↓
/topic/orders
  ↓
Connected Clients
```

### Event-driven architecture

```text
Order Created
     ↓
Event
     ↓
Webhook
     ↓
Notification
     ↓
WebSocket
```

---

# 📈 Learning Roadmap

This project is the foundation for the following AWS implementation:

```text
STEP 1
Spring Boot REST
        ↓
STEP 2
Webhook
        ↓
STEP 3
WebSocket
        ↓
STEP 4
Amazon SNS
        ↓
STEP 5
Amazon SQS
        ↓
STEP 6
Spring Boot SQS Worker
        ↓
STEP 7
Real Email Notification
        ↓
STEP 8
Real SMS Notification
        ↓
STEP 9
WhatsApp Notification
        ↓
STEP 10
Redis / ElastiCache
        ↓
STEP 11
API Gateway
        ↓
STEP 12
Docker
        ↓
STEP 13
ECS / Fargate
        ↓
STEP 14
Application Load Balancer
        ↓
STEP 15
CloudWatch
        ↓
STEP 16
GitHub Actions
        ↓
STEP 17
Jenkins CI/CD
```

---

# 📊 Project Status

| Feature | Status |
|---|---|
| Spring Boot REST API | ✅ Completed |
| Order Service | ✅ Completed |
| Webhook Service | ✅ Completed |
| Webhook Communication | ✅ Completed |
| WebSocket Service | ✅ Completed |
| STOMP | ✅ Completed |
| SockJS | ✅ Completed |
| Browser WebSocket Client | ✅ Completed |
| Real-time Notification | ✅ Completed |
| Start Script | ✅ Completed |
| Stop Script | ✅ Completed |
| End-to-End Testing | ✅ Completed |
| AWS SNS | ⏳ Next |
| AWS SQS | ⏳ Next |
| Real Email | ⏳ Next |
| Real SMS | ⏳ Next |
| WhatsApp | ⏳ Next |
| Redis / ElastiCache | ⏳ Next |
| API Gateway | ⏳ Next |
| ECS / Fargate | ⏳ Next |
| ALB | ⏳ Next |
| CloudWatch | ⏳ Next |
| GitHub Actions | ⏳ Next |
| Jenkins | ⏳ Next |

---

# 🔧 Useful Commands

## Start everything

```bash
./start-all.sh
```

## Stop everything

```bash
./stop-all.sh
```

## Make scripts executable

```bash
chmod +x start-all.sh stop-all.sh
```

## Check Java

```bash
java -version
```

## Check Maven

```bash
mvn -version
```

## Check ports

```bash
lsof -i :8080 -i :8081 -i :8082
```

## View Order logs

```bash
tail -f order-service.log
```

## View Webhook logs

```bash
tail -f webhook-service.log
```

## View WebSocket logs

```bash
tail -f websocket-service.log
```

---

# 👨‍💻 Author

**Sourik Parui**

Learning and implementing:

- Java
- Spring Boot
- Microservices
- AWS
- DevOps
- Event-Driven Architecture
- Docker
- Webhooks
- WebSockets
- SNS
- SQS
- Redis
- CI/CD

---

# ⭐ Project Goal

The main goal of this project is to understand how modern distributed systems communicate using:

```text
REST
  +
Webhooks
  +
Messaging
  +
WebSockets
  +
Event-Driven Architecture
```

The final objective is to transform this local Spring Boot implementation into a production-style AWS architecture using:

```text
API Gateway
     +
ECS / Fargate
     +
SNS
     +
SQS
     +
Redis
     +
WebSocket
     +
CloudWatch
     +
CI/CD
```

---

## 🎯 Final Event Flow

```text
                         USER
                          |
                          v
                    API Gateway
                          |
                          v
                   Order Service
                          |
                          v
                       SNS
                          |
                          v
                       SQS
                          |
                          v
                      Worker
                          |
                          v
                  Notification Service
                          |
                 ┌────────┼────────┐
                 |        |        |
                 v        v        v
               Email     SMS    WhatsApp
                          |
                          v
                     WebSocket
                          |
                          v
                       Browser
```

This repository starts with the local implementation and will progressively evolve into a production-style AWS event-driven microservice architecture.