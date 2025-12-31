package com.yourdomain.eshop.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import com.yourdomain.eshop.entity.Order;
import com.yourdomain.eshop.entity.User;
import com.yourdomain.eshop.config.MailConfig.EmailProperties;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.io.UnsupportedEncodingException;
@Service
public class EmailService {
    
    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    
    private final JavaMailSender mailSender;
    private final EmailProperties emailProperties;
    
    public EmailService(JavaMailSender mailSender,
                       EmailProperties emailProperties) {
        this.mailSender = mailSender;
        this.emailProperties = emailProperties;
    }
    
    /**
     * 发送订单支付成功邮件
     */
    public void sendPaymentConfirmation(Order order) {
        User user = order.getUser();
        String subject = "订单支付成功 - 订单号: " + order.getId();
        
        try {
            String htmlContent = buildPaymentEmailHtml(order, user);
            sendHtmlEmail(user.getEmail(), subject, htmlContent);
            
            logger.info("支付成功邮件已发送到: {}", user.getEmail());
        } catch (Exception e) {
            logger.error("发送支付成功邮件失败: {}", e.getMessage(), e);
        }
    }
    
    /**
     * 发送订单发货通知邮件
     */
    public void sendShippingNotification(Order order) {
        User user = order.getUser();
        String subject = "您的订单已发货 - 订单号: " + order.getId();
        
        try {
            String htmlContent = buildShippingEmailHtml(order, user);
            sendHtmlEmail(user.getEmail(), subject, htmlContent);
            
            logger.info("发货通知邮件已发送到: {}", user.getEmail());
        } catch (Exception e) {
            logger.error("发送发货通知邮件失败: {}", e.getMessage(), e);
        }
    }
    
    /**
     * 发送订单创建确认邮件
     */
    public void sendOrderConfirmation(Order order) {
        User user = order.getUser();
        String subject = "订单创建成功 - 订单号: " + order.getId();
        
        try {
            String htmlContent = buildOrderConfirmationEmailHtml(order, user);
            sendHtmlEmail(user.getEmail(), subject, htmlContent);
            
            logger.info("订单确认邮件已发送到: {}", user.getEmail());
        } catch (Exception e) {
            logger.error("发送订单确认邮件失败: {}", e.getMessage(), e);
        }
    }
    
    /**
     * 发送HTML邮件
     */
   private void sendHtmlEmail(String to, String subject, String htmlContent) 
        throws MessagingException, UnsupportedEncodingException { // 添加这个声明
    MimeMessage message = mailSender.createMimeMessage();
    MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
    
    // 现在这里不会报错了
    helper.setFrom(emailProperties.getSenderAddress(), emailProperties.getSenderName()); 
    
    helper.setTo(to);
    helper.setSubject(subject);
    helper.setText(htmlContent, true);
    
    mailSender.send(message);
}
    
    /**
     * 构建支付成功邮件的HTML内容
     */
    private String buildPaymentEmailHtml(Order order, User user) {
        String orderItemsHtml = buildOrderItemsHtml(order);
        
        return "<!DOCTYPE html>" +
               "<html>" +
               "<head><meta charset='UTF-8'><title>订单支付成功</title></head>" +
               "<body>" +
               "<h2>订单支付成功</h2>" +
               "<p>尊敬的 " + user.getUsername() + "，您好！</p>" +
               "<p>您的订单支付已成功完成。</p>" +
               "<h3>订单信息</h3>" +
               "<p><strong>订单号：</strong>" + order.getId() + "</p>" +
               "<p><strong>支付金额：</strong>¥" + String.format("%.2f", order.getTotalAmount()) + "</p>" +
               "<p><strong>支付时间：</strong>" + order.getCreateTime().format(DATE_FORMATTER) + "</p>" +
               "<p><strong>支付方式：</strong>" + order.getPaymentMethod() + "</p>" +
               "<h3>收货信息</h3>" +
               "<p><strong>收货人：</strong>" + order.getReceiverName() + "</p>" +
               "<p><strong>联系电话：</strong>" + order.getReceiverPhone() + "</p>" +
               "<p><strong>收货地址：</strong>" + order.getShippingAddress() + "</p>" +
               "<h3>商品清单</h3>" + orderItemsHtml +
               "<p>您可以通过以下链接查看订单详情：</p>" +
               "<a href='" + emailProperties.getBaseUrl() + "/orders/" + order.getId() + "'>查看订单详情</a>" +
               "<p><br/>此邮件由系统自动发送，请勿回复。</p>" +
               "</body></html>";
    }
    
    /**
     * 构建发货通知邮件的HTML内容
     */
    private String buildShippingEmailHtml(Order order, User user) {
        String orderItemsHtml = buildOrderItemsHtml(order);
        String trackingNumber = "ES" + String.format("%010d", order.getId()) + "CN";
        
        return "<!DOCTYPE html>" +
               "<html>" +
               "<head><meta charset='UTF-8'><title>订单已发货</title></head>" +
               "<body>" +
               "<h2>您的订单已发货！</h2>" +
               "<p>尊敬的 " + user.getUsername() + "，您好！</p>" +
               "<p>您的订单已从仓库发出，正在由快递公司揽收中。</p>" +
               "<h3>发货信息</h3>" +
               "<p><strong>订单号：</strong>" + order.getId() + "</p>" +
               "<p><strong>发货时间：</strong>" + java.time.LocalDateTime.now().format(DATE_FORMATTER) + "</p>" +
               "<p><strong>收货人：</strong>" + order.getReceiverName() + "</p>" +
               "<p><strong>联系电话：</strong>" + order.getReceiverPhone() + "</p>" +
               "<p><strong>收货地址：</strong>" + order.getShippingAddress() + "</p>" +
               "<h3>物流跟踪信息</h3>" +
               "<p><strong>物流单号：</strong>" + trackingNumber + "</p>" +
               "<p><strong>预计送达时间：</strong>" + java.time.LocalDate.now().plusDays(3) + "</p>" +
               "<h3>商品清单</h3>" + orderItemsHtml +
               "<p>您可以通过以下链接查看订单详情和物流跟踪：</p>" +
               "<a href='" + emailProperties.getBaseUrl() + "/orders/" + order.getId() + "'>查看订单详情</a>" +
               "<p><br/>温馨提示：快递员配送时请核对商品信息，签收前请检查商品是否完好。</p>" +
               "<p><br/>此邮件由系统自动发送，请勿回复。</p>" +
               "</body></html>";
    }
    
    /**
     * 构建订单确认邮件的HTML内容
     */
    private String buildOrderConfirmationEmailHtml(Order order, User user) {
        String orderItemsHtml = buildOrderItemsHtml(order);
        String expiryTime = order.getCreateTime().plusHours(24).format(DATE_FORMATTER);
        
        return "<!DOCTYPE html>" +
               "<html>" +
               "<head><meta charset='UTF-8'><title>订单创建成功</title></head>" +
               "<body>" +
               "<h2>订单创建成功！</h2>" +
               "<p>尊敬的 " + user.getUsername() + "，您好！</p>" +
               "<p>您的订单已成功创建，请及时完成支付以确认订单。</p>" +
               "<div style='background-color:#fff3cd; padding:15px; border:1px solid #ffc107; margin:15px 0;'>" +
               "<h3>重要提示</h3>" +
               "<p>请在以下时间前完成支付，否则订单将自动取消：</p>" +
               "<p style='color:#dc3545; font-weight:bold;'>" + expiryTime + "</p>" +
               "<p>支付剩余时间：<strong>24小时</strong></p>" +
               "</div>" +
               "<h3>订单信息</h3>" +
               "<p><strong>订单号：</strong>" + order.getId() + "</p>" +
               "<p><strong>订单金额：</strong>¥" + String.format("%.2f", order.getTotalAmount()) + "</p>" +
               "<p><strong>下单时间：</strong>" + order.getCreateTime().format(DATE_FORMATTER) + "</p>" +
               "<p><strong>支付方式：</strong>" + order.getPaymentMethod() + "</p>" +
               "<h3>收货信息</h3>" +
               "<p><strong>收货人：</strong>" + order.getReceiverName() + "</p>" +
               "<p><strong>联系电话：</strong>" + order.getReceiverPhone() + "</p>" +
               "<p><strong>收货地址：</strong>" + order.getShippingAddress() + "</p>" +
               "<h3>商品清单</h3>" + orderItemsHtml +
               "<p>请点击以下按钮完成支付：</p>" +
               "<a href='" + emailProperties.getBaseUrl() + "/orders/" + order.getId() + "/pay' style='background-color:#dc3545; color:white; padding:10px 20px; text-decoration:none; border-radius:5px; display:inline-block; margin-right:10px;'>立即支付</a>" +
               "<a href='" + emailProperties.getBaseUrl() + "/orders/" + order.getId() + "' style='background-color:#6c757d; color:white; padding:10px 20px; text-decoration:none; border-radius:5px; display:inline-block;'>查看订单详情</a>" +
               "<p><br/>温馨提示：支付完成后，您将收到支付成功邮件；发货后您将收到发货通知邮件。</p>" +
               "<p><br/>此邮件由系统自动发送，请勿回复。</p>" +
               "</body></html>";
    }
    
    /**
     * 构建订单商品列表HTML
     */
    private String buildOrderItemsHtml(Order order) {
        StringBuilder html = new StringBuilder();
        html.append("<table border='1' cellpadding='8' cellspacing='0' style='border-collapse:collapse; width:100%; margin:10px 0;'>");
        html.append("<tr><th>商品名称</th><th>数量</th><th>单价</th><th>小计</th></tr>");
        
        for (var item : order.getOrderItems()) {
            BigDecimal itemTotal = item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
            html.append("<tr>")
                .append("<td>").append(item.getProduct().getName()).append("</td>")
                .append("<td align='center'>").append(item.getQuantity()).append("</td>")
                .append("<td align='right'>¥").append(String.format("%.2f", item.getPrice())).append("</td>")
                .append("<td align='right'>¥").append(String.format("%.2f", itemTotal)).append("</td>")
                .append("</tr>");
        }
        
        html.append("</table>");
        return html.toString();
    }
    
    /**
     * 发送纯文本邮件
     */
   @Async
public void sendSimpleEmail(String to, String subject, String text) {
    try {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, false, "UTF-8");
        
        // 处理别名编码异常
        helper.setFrom(emailProperties.getSenderAddress(), emailProperties.getSenderName());
        
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(text);
        
        mailSender.send(message);
    } catch (MessagingException | UnsupportedEncodingException e) { // 捕获多个异常
        logger.error("发送纯文本邮件失败: {}", e.getMessage(), e);
    }
}
}
