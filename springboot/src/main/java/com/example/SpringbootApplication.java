package com.example;


import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.example.mapper") // 指定 MyBatis Mapper 接口所在的包，Spring 会自动创建代理实现
public class SpringbootApplication {

    /**
     * 应用入口方法
     * 通过 SpringApplication.run 启动 Spring Boot 应用
     * @param args 命令行参数
     */
    public static void main(String[] args) {
        SpringApplication.run(SpringbootApplication.class, args);
    }

}
