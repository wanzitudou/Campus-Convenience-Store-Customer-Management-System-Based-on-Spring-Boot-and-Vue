package com.example.common;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

/**
 * 跨域配置类
 * 用于解决前后端分离时，浏览器同源策略限制导致的跨域请求问题。
 * 通过配置CORS过滤器，允许指定域名的前端访问后端接口。
 */
@Configuration
public class CorsConfig {
    @Bean
    public CorsFilter corsFilter() {
        // 1. 创建基于URL的CORS配置源
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        // 2. 创建CORS配置对象
        CorsConfiguration corsConfiguration = new CorsConfiguration();
        // 3. 允许所有来源的请求（生产环境建议替换为具体的前端域名）
        corsConfiguration.addAllowedOrigin("*"); // 3. 允许所有来源的请求（生产环境建议替换为具体的前端域名）
        corsConfiguration.addAllowedHeader("*"); // 4. 允许所有请求头
        corsConfiguration.addAllowedMethod("*");  // 5. 允许所有HTTP方法（GET、POST、PUT、DELETE等）
        source.registerCorsConfiguration("/**", corsConfiguration); // 6. 对所有接口路径应用该跨域配置
        return new CorsFilter(source);
    }
}