package com.yourdomain.eshop.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MailConfig {

    @Value("${app.email.sender.name:E-Shop}")
    private String senderName;

    @Value("${app.email.sender.address:2495727389@qq.com}")
    private String senderAddress;

    @Value("${app.email.base-url:http://localhost:8080}")
    private String baseUrl;

    // 只保留这个自定义的属性 Bean
    @Bean
    public EmailProperties emailProperties() {
        EmailProperties properties = new EmailProperties();
        properties.setSenderName(senderName);
        properties.setSenderAddress(senderAddress);
        properties.setBaseUrl(baseUrl);
        return properties;
    }

    public static class EmailProperties {
        private String senderName;
        private String senderAddress;
        private String baseUrl;

        public String getSenderName() { return senderName; }
        public void setSenderName(String senderName) { this.senderName = senderName; }
        public String getSenderAddress() { return senderAddress; }
        public void setSenderAddress(String senderAddress) { this.senderAddress = senderAddress; }
        public String getBaseUrl() { return baseUrl; }
        public void setBaseUrl(String baseUrl) { this.baseUrl = baseUrl; }
    }
}