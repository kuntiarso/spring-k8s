package com.developer.superuser.commonservice.actuator;

import lombok.RequiredArgsConstructor;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

@Component("db")
@RequiredArgsConstructor
public class DatabaseHealthIndicator implements HealthIndicator {
    private final DataSource dataSource;

    @Override
    public Health health() {
        try (Connection connection = dataSource.getConnection()) {
            if (connection != null && connection.isValid(1)) {
                return Health.up().withDetail("message", "Database is up and running").build();
            } else {
                return Health.down().withDetail("error", "Failed to connect to the database").build();
            }
        } catch (SQLException e) {
            return Health.down(e).withDetail("error", "Database connection error: " + e.getMessage()).build();
        }
    }
}