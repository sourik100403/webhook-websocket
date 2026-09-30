package com.learning.order.service;

import com.learning.order.model.Order;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.Map;

@Service
public class WebhookService {

    private final RestClient restClient;

    public WebhookService(RestClient.Builder builder) {
        this.restClient = builder.build();
    }

    public void sendOrderCreatedWebhook(Order order) {

        Map<String, Object> event = Map.of(
                "event", "ORDER_CREATED",
                "orderId", order.getOrderId(),
                "product", order.getProduct(),
                "quantity", order.getQuantity()
        );

        restClient
                .post()
                .uri("http://localhost:8081/webhook/order")
                .body(event)
                .retrieve()
                .toBodilessEntity();

        System.out.println(
                "Order webhook sent successfully"
        );
    }
}