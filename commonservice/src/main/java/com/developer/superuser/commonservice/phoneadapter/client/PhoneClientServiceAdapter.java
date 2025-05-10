package com.developer.superuser.commonservice.phoneadapter.client;

import com.developer.superuser.commonservice.phone.PhoneClientService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RequiredArgsConstructor
@Slf4j
public class PhoneClientServiceAdapter implements PhoneClientService {
    private final PhoneFeignClient phoneFeignClient;

    @Override
    public String generateNumber(String countryCode) {
        log.info("Calling randommer api to generate number");
        return phoneFeignClient.generateNumber(countryCode, 1).getFirst();
    }

    @Override
    public Boolean validateNumber(String number, String countryCode) {
        log.info("Calling randommer api to validate number");
        return phoneFeignClient.validateNumber(number, countryCode);
    }
}
