package com.learning.order.controller;

import com.learning.order.model.Order;
import com.learning.order.service.WebhookService;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final WebhookService webhookService;

    public OrderController(WebhookService webhookService) {
        this.webhookService = webhookService;
    }

    @PostMapping
    public Order createOrder(@RequestBody Order order) {

        order.setOrderId(
                "ORD-" + UUID.randomUUID()
        );

        System.out.println(
                "Order created: " + order.getOrderId()
        );

        webhookService.sendOrderCreatedWebhook(order);

        return order;
    }
}