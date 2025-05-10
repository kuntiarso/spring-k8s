package com.developer.superuser.commonservice.phone;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder(toBuilder = true)
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@ToString
public class Phone {
    @EqualsAndHashCode.Include
    private Long id;
    @EqualsAndHashCode.Include
    private String number;
    private String countryCode;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime verifiedAt;
    private LocalDateTime expiredAt;
    private String createdBy;
    private String updatedBy;
}
