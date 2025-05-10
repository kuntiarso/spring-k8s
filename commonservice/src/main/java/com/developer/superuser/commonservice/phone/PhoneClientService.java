package com.developer.superuser.commonservice.phone;

public interface PhoneClientService {
    String generateNumber(String countryCode);
    Boolean validateNumber(String number, String countryCode);
}
