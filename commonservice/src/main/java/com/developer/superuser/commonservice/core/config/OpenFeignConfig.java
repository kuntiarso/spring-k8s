package com.developer.superuser.commonservice.core.config;

import com.developer.superuser.commonservice.phoneadapter.client.PhoneFeignClient;
import feign.Logger;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableFeignClients(basePackageClasses = {PhoneFeignClient.class})
@Slf4j
public class OpenFeignConfig {
    @Bean
    public Logger.Level feignLoggerLevel() {
        log.info("Setting feign logger level to --- {}", Logger.Level.FULL.name());
        return Logger.Level.FULL;
    }
}
