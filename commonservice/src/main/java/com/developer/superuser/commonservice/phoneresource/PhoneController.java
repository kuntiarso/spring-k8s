package com.developer.superuser.commonservice.phoneresource;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("phone")
@RequiredArgsConstructor
@Slf4j
public class PhoneController {
    private final PhoneHandler phoneHandler;

    @PostMapping(value = "generate", consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
    public ResponseEntity<?> generatePhone(@RequestParam("countryCode") String countryCode) {
        log.info("request params --- {}", countryCode);
        return phoneHandler.generateNumber(countryCode);
    }

    @PostMapping(value = "validate", consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
    public ResponseEntity<?> validatePhone(@RequestParam("number") String number, @RequestParam("countryCode") String countryCode) {
        log.info("request params --- {},{}", number, countryCode);
        return phoneHandler.validateNumber(number, countryCode);
    }
}
