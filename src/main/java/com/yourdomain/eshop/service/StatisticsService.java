package com.yourdomain.eshop.service;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface StatisticsService {
    
    // 平台统计
    Map<String, Object> getPlatformStats();
    
    // 店铺统计概览
    Map<String, Object> getShopStats(Long shopId, LocalDate startDate, LocalDate endDate);
    
    // 平台销售统计（按日期范围）
    Map<String, Object> getPlatformSalesStats(LocalDate startDate, LocalDate endDate);
    
    // 获取平台每日销售趋势
    List<Map<String, Object>> getPlatformDailySales(LocalDate startDate, LocalDate endDate);
    
    // 获取平台订单状态分布
    Map<String, Long> getPlatformOrderStatusDistribution(LocalDate startDate, LocalDate endDate);
    
    // 获取平台最新活动
    List<Map<String, Object>> getRecentActivities(int limit);
}
