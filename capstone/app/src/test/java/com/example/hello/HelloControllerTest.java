package com.example.hello;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

class HelloControllerTest {
    @Test
    void returnsGreeting() {
        var response = new HelloController().hello();
        assertEquals("Hello DevOps!", response.get("message"));
        assertEquals("hello-app", response.get("service"));
    }
}
