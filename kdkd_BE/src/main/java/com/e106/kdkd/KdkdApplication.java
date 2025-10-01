package com.e106.kdkd;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class KdkdApplication {

    public static void main(String[] args) {
        SpringApplication.run(KdkdApplication.class, args);
    }

}
