package com.developer.superuser.commonservice.phoneadapter.persistence;

import com.developer.superuser.commonservice.phone.Phone;
import com.developer.superuser.commonservice.phone.PhonePersistenceService;
import com.google.common.base.Objects;
import com.google.common.base.Preconditions;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.time.LocalDateTime;

@RequiredArgsConstructor
@Slf4j
public class PhonePersistenceServiceAdapter implements PhonePersistenceService {
    private final PhoneRepository phoneRepository;

    @Override
    public void registerPhone(Phone phone) {
        phoneRepository.save(PhoneEntityMapper.map(phone));
    }

    @Override
    public boolean verifyPhone(Long id, String number) {
        boolean isVerified;
        PhoneEntity phoneEntity = phoneRepository.findById(id).orElseThrow(EntityNotFoundException::new);
        log.info("registered number vs incoming number --- {},{}", phoneEntity.getNumber(), number);
        Preconditions.checkArgument(Objects.equal(phoneEntity.getNumber(), number), "Phone number does not match");
        LocalDateTime expiredDateTime = phoneEntity.getCreatedAt().plusMinutes(1);
        if (expiredDateTime.isAfter(LocalDateTime.now())) {
            log.info("Verification time is effective");
            phoneEntity.setVerifiedAt(LocalDateTime.now());
            isVerified = true;
        } else {
            log.info("Verification time has expired");
            phoneEntity.setExpiredAt(LocalDateTime.now());
            isVerified = false;
        }
        phoneRepository.save(phoneEntity);
        return isVerified;
    }

    @Override
    public Long findByNumberAndCountryCode(String number, String countryCode) {
        return phoneRepository.findByNumberAndCountryCode(number, countryCode).orElseThrow(EntityNotFoundException::new);
    }

    @Override
    public boolean isExist(Long id) {
        return phoneRepository.existsById(id);
    }
}
