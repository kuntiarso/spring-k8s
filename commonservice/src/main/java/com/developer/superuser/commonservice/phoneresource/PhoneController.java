package com.developer.superuser.commonservice.phoneresource;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("phone")
public class PhoneController {

    @GetMapping("number")
    public ResponseEntity<?> getPhoneNumber() {
        return ResponseEntity.ok("This is a phone number");
    }
}
