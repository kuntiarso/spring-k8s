package com.developer.superuser.commonservice.phoneadapter.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@FeignClient(name = "randommer-rest-client", url = "${randommer.api.url}", configuration = PhoneFeignClientConfig.class)
public interface PhoneFeignClient {
    @GetMapping("${randommer.api.endpoint.generate-phone}")
    List<String> generateNumber(@RequestParam("CountryCode") String countryCode, @RequestParam("Quantity") int quantity);

    @GetMapping("${randommer.api.endpoint.validate-phone}")
    Boolean validateNumber(@RequestParam("telephone") String telephone, @RequestParam("CountryCode") String countryCode);
}
