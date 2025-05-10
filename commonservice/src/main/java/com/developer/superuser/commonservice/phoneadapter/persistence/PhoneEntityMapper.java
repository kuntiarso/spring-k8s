package com.developer.superuser.commonservice.phoneadapter.persistence;

import com.developer.superuser.commonservice.phone.Phone;
import lombok.experimental.UtilityClass;

@UtilityClass
public class PhoneEntityMapper {
    public PhoneEntity map(Phone phone) {
        return PhoneEntity.builder()
                .number(phone.getNumber())
                .countryCode(phone.getCountryCode())
                .build();
    }
}
