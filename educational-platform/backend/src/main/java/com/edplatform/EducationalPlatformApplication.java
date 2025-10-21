/*
 * ===============================================================
 * PROPRIETARY EDUCATIONAL PLATFORM - SPRING BOOT APPLICATION
 * ===============================================================
 * 
 * COPYRIGHT (c) 2025 Temitayo Charles Akinniranye
 * All Rights Reserved. Patent Pending.=============================================================
 * PROPRIETARY EDUCATIONAL PLATFORM - SPRING BOOT APPLICATION
 * ===============================================================
 * 
 * COPYRIGHT (c) 2025 [Your Full Legal Name]. All Rights Reserved.
 * PATENT PENDING - Commercial Use Strictly Prohibited
 * 
 * This Java Spring Boot educational platform is protected 
 * intellectual property. Unauthorized commercial use will 
 * result in legal action.
 * 
 * For licensing inquiries: [your-email@domain.com]
 * ===============================================================
 */

package com.edplatform;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@SpringBootApplication
@EnableJpaAuditing
@EnableCaching
@EnableAsync
@EnableTransactionManagement
public class EducationalPlatformApplication {

    public static void main(String[] args) {
        SpringApplication.run(EducationalPlatformApplication.class, args);
    }
}
