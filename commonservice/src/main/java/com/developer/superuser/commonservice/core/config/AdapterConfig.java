package com.developer.superuser.commonservice.core.config;

import com.developer.superuser.commonservice.core.adapter.DefaultPhoneClientServiceAdapter;
import com.developer.superuser.commonservice.core.adapter.DefaultPhonePersistenceServiceAdapter;
import com.developer.superuser.commonservice.phone.PhoneClientService;
import com.developer.superuser.commonservice.phone.PhonePersistenceService;
import com.developer.superuser.commonservice.phoneadapter.client.PhoneClientServiceAdapter;
import com.developer.superuser.commonservice.phoneadapter.client.PhoneFeignClient;
import com.developer.superuser.commonservice.phoneadapter.persistence.PhonePersistenceServiceAdapter;
import com.developer.superuser.commonservice.phoneadapter.persistence.PhoneRepository;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AdapterConfig {
    @Bean
    public PhoneClientService phoneClientService(PhoneFeignClient phoneFeignClient) {
        return new PhoneClientServiceAdapter(phoneFeignClient);
    }

    @Bean
    @ConditionalOnMissingBean(PhoneClientService.class)
    public PhoneClientService defaultPhoneClientService() {
        return new DefaultPhoneClientServiceAdapter();
    }

    @Bean
    public PhonePersistenceService phonePersistenceService(PhoneRepository phoneRepository) {
        return new PhonePersistenceServiceAdapter(phoneRepository);
    }

    @Bean
    @ConditionalOnMissingBean(PhonePersistenceService.class)
    public PhonePersistenceService defaultPhonePersistenceService() {
        return new DefaultPhonePersistenceServiceAdapter();
    }
}
