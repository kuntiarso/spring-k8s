package com.developer.superuser.commonservice.core.config;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@Configuration
@EnableJpaRepositories(basePackages = "com.developer.superuser", includeFilters = @ComponentScan.Filter(type = FilterType.REGEX, pattern = ".*Repository$"))
@EnableTransactionManagement
@EnableJpaAuditing
public class JpaConfig {
}
