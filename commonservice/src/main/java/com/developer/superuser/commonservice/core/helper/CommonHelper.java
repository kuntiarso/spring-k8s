package com.developer.superuser.commonservice.core.helper;

import com.developer.superuser.commonservice.CommonserviceConstants;
import com.google.common.base.Preconditions;
import com.google.common.base.Strings;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class CommonHelper {
    private final HttpServletRequest httpServletRequest;

    public String getCorrelationId() {
        return httpServletRequest.getHeader(CommonserviceConstants.CORRELATION_ID);
    }

    public void checkCorrelationId() {
        String correlationId = getCorrelationId();
        log.info("Header correlationId --- {}", correlationId);
        Preconditions.checkState(!Strings.isNullOrEmpty(correlationId), "missing correlationId in the header");
    }
}
