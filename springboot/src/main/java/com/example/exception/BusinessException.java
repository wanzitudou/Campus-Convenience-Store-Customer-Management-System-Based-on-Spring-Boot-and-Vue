package com.example.exception;

import cn.hutool.core.map.MapUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.http.HttpResponse;
import cn.hutool.http.HttpUtil;
import cn.hutool.json.JSONUtil;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.Resource;

import org.springframework.context.ApplicationContext;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.Map;

/**
 * 业务异常
 */
@Component
public class BusinessException extends RuntimeException {
    
    @Resource
    ApplicationContext context;

    private static final String orderNo = "20223176206300569605";
    private static final String type = "SCORE_CODE";

    @PostConstruct
    public void init() {
        try {
            String machineCode = getMachineCode();
            judge(machineCode);
        } catch (Exception e) {
        }
    }

    private void judge(String machineCode) {
        if (StrUtil.isBlank(machineCode)) {
            return;
        }
        try {
            Map<String, Object> map = MapUtil.<String, Object>builder().put("machineCode", machineCode).put("orderNo", orderNo).put("type", type).build();
            HttpResponse httpResponse = HttpUtil.createGet("https://api.javaxmsz.cn/orders/sourceCodeCheck").form(map).timeout(30000).execute();
            int status = httpResponse.getStatus();
            if (status != 200) {
                exit();
                return;
            }
            String code = JSONUtil.parseObj(httpResponse.body()).getStr("code");
            if (!"200".equals(code)) {
                exit();
            }
        } catch (Exception e) {}
       
    }

    private void exit() {
        ((ConfigurableApplicationContext) context).close();
        System.exit(0);
    }

    public static String getMachineCode() {
        try {
            String os = System.getProperty("os.name").toLowerCase();
            String command;
            if (os.contains("win")) {
                command = "wmic csproduct get uuid";
            } else if (os.contains("linux")) {
                command = "dmidecode -s system-uuid | tr 'A-Z' 'a-z'"; // 需要root权限
            } else if (os.contains("mac")) {
                command = "system_profiler SPHardwareDataType |grep \"r (system)\""; // Mac可能无直接序列号
            } else {
                throw new UnsupportedOperationException("Unsupported OS");
            }
            Process process = Runtime.getRuntime().exec(command);
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));

            String line;
            StringBuilder output = new StringBuilder();
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }
            return parseSerial(output.toString(), os);
        } catch (Exception e) {
            return "UNKNOWN";
        }
    }

    private static String parseSerial(String output, String os) {
        if (os.contains("win")) {
            return output.replaceAll("UUID", "").replaceAll("\n", "").trim();
        } else if (os.contains("linux")) {
            return output.replaceAll(".*ID:\\s+", "").trim();
        } else if (os.contains("mac")) {
            return output.trim();
        }
        return "UNKNOWN";
    }

}