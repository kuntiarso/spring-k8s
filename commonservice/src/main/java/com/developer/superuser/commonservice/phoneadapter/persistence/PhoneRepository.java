package com.developer.superuser.commonservice.phoneadapter.persistence;

import com.developer.superuser.commonservice.CommonserviceConstants;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface PhoneRepository extends JpaRepository<PhoneEntity, Long> {
    @Query(value = CommonserviceConstants.FIND_BY_NUMBER_AND_COUNTRY_CODE_QUERY, nativeQuery = true)
    Optional<Long> findByNumberAndCountryCode(String number, String countryCode);
}
