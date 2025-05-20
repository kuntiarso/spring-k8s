package com.developer.superuser.commonservice;

import lombok.experimental.UtilityClass;

@UtilityClass
public class CommonserviceConstants {
    public final String PHONE_ENTITY = "\"phone\"";
    public final String FIND_BY_NUMBER_AND_COUNTRY_CODE_QUERY = "SELECT id FROM phone WHERE number = :number AND country_code = :countryCode";
    public final String CORRELATION_ID = "correlationId";
}
