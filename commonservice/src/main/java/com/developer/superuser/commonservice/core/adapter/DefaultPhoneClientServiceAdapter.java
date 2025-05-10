package com.developer.superuser.commonservice.core.adapter;

import com.developer.superuser.commonservice.phone.PhoneClientService;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

public class DefaultPhoneClientServiceAdapter implements PhoneClientService {
    @Override
    public String generateNumber(String countryCode) {
        throw new ResponseStatusException(HttpStatus.NOT_IMPLEMENTED);
    }

    @Override
    public Boolean validateNumber(String number, String countryCode) {
        throw new ResponseStatusException(HttpStatus.NOT_IMPLEMENTED);
    }
}