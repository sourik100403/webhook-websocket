package com.learning.websocket.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
public class WebSocketController {

    @MessageMapping("/hello")
    @SendTo("/topic/messages")
    public String sendMessage(String message) {

        System.out.println(
                "WebSocket message received: " + message
        );

        return "Server received: " + message;
    }
}