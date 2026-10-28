package com.example.common;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

/**
 * 通用 Bean 配置
 */
@Configuration
public class AppConfig {

    /**
     * RestTemplate：用于跨语言调用 Python 推荐服务
     * <p>
     * 这里**必须**显式设置超时时间。
     * RestTemplate 默认使用 SimpleClientHttpRequestFactory，超时时间是 -1（无限等待），
     * 一旦 Python 服务卡死，Spring Boot 线程会被一直占用，最终拖垮整个后端的线程池。
     * 设置成 连接 1.5s / 读取 2.5s 之后，最坏情况 4s 内一定返回，配合 RecommendService 的降级逻辑，
     * 可以保证首页最多"慢 4 秒"而不会"白屏"。
     */
    @Bean
    public RestTemplate restTemplate() {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        // 建立 TCP 连接的超时时间（毫秒）
        factory.setConnectTimeout(1500);
        // 等待服务端响应的超时时间（毫秒）
        factory.setReadTimeout(2500);
        return new RestTemplate(factory);
    }
}
