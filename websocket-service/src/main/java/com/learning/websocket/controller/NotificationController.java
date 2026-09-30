package com.learning.websocket.controller;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final SimpMessagingTemplate messagingTemplate;

    public NotificationController(
            SimpMessagingTemplate messagingTemplate) {

        this.messagingTemplate = messagingTemplate;
    }

    @PostMapping("/order")
    public String sendOrderNotification(
            @RequestBody Map<String, Object> notification) {

        System.out.println();
        System.out.println("================================");
        System.out.println("   ORDER NOTIFICATION RECEIVED");
        System.out.println("================================");

        System.out.println(notification);

        // Send notification to all WebSocket clients
        messagingTemplate.convertAndSend(
                "/topic/orders",
                notification
        );

        System.out.println("Notification sent to WebSocket clients");
        System.out.println("================================");

        return "Notification sent";
    }
}