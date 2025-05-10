package com.developer.superuser.commonservice.core.config;

import com.developer.superuser.commonservice.phoneadapter.client.PhoneFeignClient;
import feign.Logger;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableFeignClients(basePackageClasses = {PhoneFeignClient.class})
public class OpenFeignConfig {
    @Bean
    public Logger.Level feignLoggerLevel() {
        return Logger.Level.FULL;
    }
}
