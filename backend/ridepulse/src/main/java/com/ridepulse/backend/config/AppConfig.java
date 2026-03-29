package com.ridepulse.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.client.RestTemplate;
import org.springframework.boot.web.client.RestTemplateBuilder;

import java.time.Duration;

@Configuration
@EnableScheduling   // Activates all @Scheduled methods in the project
public class AppConfig {

    /**
     * RestTemplate with sensible timeouts for LSTM service calls.
     * OOP Encapsulation: timeout config hidden here — callers
     * just autowire RestTemplate.
     */
    @Bean
    public RestTemplate restTemplate(RestTemplateBuilder builder) {
        return builder
                .setConnectTimeout(Duration.ofSeconds(10))  // LSTM startup can be slow
                .setConnectTimeout(Duration.ofSeconds(60))     // batch prediction takes time
                .build();
    }
}