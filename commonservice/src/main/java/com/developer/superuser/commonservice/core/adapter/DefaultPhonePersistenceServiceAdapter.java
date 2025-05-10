package com.developer.superuser.commonservice.core.adapter;

import com.developer.superuser.commonservice.phone.Phone;
import com.developer.superuser.commonservice.phone.PhonePersistenceService;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

public class DefaultPhonePersistenceServiceAdapter implements PhonePersistenceService {
    @Override
    public void registerPhone(Phone phone) {
        throw new ResponseStatusException(HttpStatus.NOT_IMPLEMENTED);
    }

    @Override
    public boolean verifyPhone(Long id, String number) {
        throw new ResponseStatusException(HttpStatus.NOT_IMPLEMENTED);
    }

    @Override
    public Long findByNumberAndCountryCode(String number, String countryCode) {
        throw new ResponseStatusException(HttpStatus.NOT_IMPLEMENTED);
    }

    @Override
    public boolean isExist(Long id) {
        throw new ResponseStatusException(HttpStatus.NOT_IMPLEMENTED);
    }
}
