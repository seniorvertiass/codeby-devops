package com.mycompany.app;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class AppTest {

    @Test
    void testMessage() {
        App app = new App();

        assertEquals("Hello Devops_2!", app.getMessage());
    }
}
