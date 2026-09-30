package com.learning.webhook.controller;

import com.learning.webhook.model.WebhookEvent;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/webhook")
public class WebhookController {

    @PostMapping("/order")
    public String receiveOrderWebhook(
            @RequestBody WebhookEvent event) {

        System.out.println("========== WEBHOOK RECEIVED ==========");
        System.out.println("Event: " + event.getEvent());
        System.out.println("Order ID: " + event.getOrderId());
        System.out.println("Product: " + event.getProduct());
        System.out.println("======================================");

        return "Webhook received successfully";
    }
}