package com.developer.superuser.commonservice.phone;

public interface PhonePersistenceService {
    void registerPhone(Phone phone);
    boolean verifyPhone(Long id, String number);
    Long findByNumberAndCountryCode(String number, String countryCode);
    boolean isExist(Long id);
}
