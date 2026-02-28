package com.ridepulse.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Main Application Class
 * @SpringBootApplication combines:
 * - @Configuration
 * - @EnableAutoConfiguration
 * - @ComponentScan
 */
@SpringBootApplication
public class RidepulseApplication {

    public static void main(String[] args) {
        SpringApplication.run(RidepulseApplication.class, args);
    }
}