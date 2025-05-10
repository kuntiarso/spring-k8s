package com.developer.superuser.commonservice.phoneadapter.client;

import feign.RequestInterceptor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class PhoneFeignClientConfig {
    @Value("${randommer.api.header.key.name}")
    private String apiKeyName;
    @Value("${randommer.api.header.key.value}")
    private String apiKeyValue;

    @Bean
    public RequestInterceptor requestInterceptor() {
        return requestTemplate -> requestTemplate.header(apiKeyName, apiKeyValue);
    }
}
