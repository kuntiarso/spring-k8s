package com.developer.superuser.commonservice.phoneresource;

import com.developer.superuser.commonservice.core.helper.CommonHelper;
import com.developer.superuser.commonservice.phone.Phone;
import com.developer.superuser.commonservice.phone.PhoneClientService;
import com.developer.superuser.commonservice.phone.PhonePersistenceService;
import com.google.common.base.Preconditions;
import com.google.common.base.Strings;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class PhoneHandler {
    private final PhoneClientService phoneClientService;
    private final PhonePersistenceService phonePersistenceService;
    private final CommonHelper commonHelper;

    public ResponseEntity<Map<String, String>> generateNumber(String countryCode) {
        try {
            commonHelper.checkCorrelationId();
            log.info("Checking incoming arguments");
            Preconditions.checkArgument(!Strings.isNullOrEmpty(countryCode), "countryCode cannot be null or empty");
            log.info("Generating new number");
            String newNumber = phoneClientService.generateNumber(countryCode);
            Preconditions.checkState(!Strings.isNullOrEmpty(newNumber), "not able to get phone number");
            Phone newPhone = Phone.builder().number(newNumber).countryCode(countryCode).build();
            log.info("Registering new number");
            phonePersistenceService.registerPhone(newPhone);
            return ResponseEntity.status(HttpStatus.CREATED).body(ImmutableMap.<String, String>builder()
                    .put("correlationId", commonHelper.getCorrelationId())
                    .put("number", newNumber)
                    .build());
        } catch (Exception ex) {
            log.error("Error has occurred in generateNumber process --- {}", ex.getMessage(), ex);
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, ex.getLocalizedMessage());
        }
    }

    public ResponseEntity<String> validateNumber(String number, String countryCode) {
        try {
            commonHelper.checkCorrelationId();
            log.info("Checking incoming arguments");
            Preconditions.checkArgument(!Strings.isNullOrEmpty(number), "number cannot be null or empty");
            Preconditions.checkArgument(!Strings.isNullOrEmpty(countryCode), "countryCode cannot be null or empty");
            log.info("Checking if number is available in the database");
            long id = phonePersistenceService.findByNumberAndCountryCode(number, countryCode);
            log.info("Validating the number");
            boolean isNumberValid = phoneClientService.validateNumber(number, countryCode);
            Preconditions.checkState(isNumberValid, "number is not valid");
            log.info("Setting the number status as a verified");
            boolean isVerified = phonePersistenceService.verifyPhone(id, number);
            return ResponseEntity.ok().body(isVerified ? "Verified" : "Expired");
        } catch (Exception ex) {
            log.error("Error has occurred in validateNumber process --- {}", ex.getMessage(), ex);
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, ex.getLocalizedMessage());
        }
    }
}
