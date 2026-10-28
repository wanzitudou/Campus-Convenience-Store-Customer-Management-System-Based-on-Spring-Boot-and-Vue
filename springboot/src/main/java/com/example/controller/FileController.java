package com.example.controller;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.io.FileUtil;
import cn.hutool.core.lang.Dict;
import com.example.common.Result;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.MediaTypeFactory;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

/**
 * 文件上传下载文件相关操作接口
 */
@RestController
@RequestMapping("/files")
public class FileController {

    // 表示本地磁盘文件的存储路径
    private static final String filePath = System.getProperty("user.dir") + "/files/";

    @Value("${fileBaseUrl}")
    private String fileBaseUrl;

    @Value("${server.port}")
    private String port;

    /**
     * 文件上传
     */
    @PostMapping("/upload")
    public Result upload(MultipartFile file) {
        // 定义文件的唯一标识
        String fileName = System.currentTimeMillis() + "-" + file.getOriginalFilename();
        // 拼接完整的文件存储路径
        String realFilePath = filePath + fileName;
        try {
            if (!FileUtil.isDirectory(filePath)) {
                FileUtil.mkdir(filePath);
            }
            FileUtil.writeBytes(file.getBytes(), realFilePath);
        } catch (IOException e) {
            System.out.println("文件上传错误");
        }

        // 返回文件下载的地址
        String url = fileBaseUrl + ":" + port + "/files/download/" + fileName;
        return Result.success(url);
    }

    /**
     * 文件下载 / 预览
     * <p>
     * 这里必须根据文件扩展名设置正确的 Content-Type。
     * 否则响应里没有 Content-Type，浏览器在 {@code <img src>} 场景下：
     * 对 png/jpg 还能靠文件魔数嗅探出来，但 svg 会直接拒绝渲染（表现为图片空白）。
     * 同时把 Content-Disposition 设为 inline，让图片/PDF 直接在浏览器里预览，
     * 只有无法预览的类型才退化成附件下载。
     */
    @GetMapping("/download/{fileName}")
    public void download(@PathVariable String fileName, HttpServletResponse response) {
        // 1. 拼接完整的文件存储路径
        String realFilePath = filePath + fileName;
        if (!FileUtil.exist(realFilePath)) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // 2. 根据扩展名推断 MIME 类型
        MediaType mediaType = resolveMediaType(fileName);
        response.setContentType(mediaType.toString());

        // 3. 图片 / PDF 直接内联展示，其他类型作为附件下载
        String disposition = "inline";
        if (!mediaType.getType().equals("image") && !"pdf".equals(mediaType.getSubtype())) {
            disposition = "attachment";
        }
        response.setHeader("Content-Disposition",
                disposition + ";filename=" + URLEncoder.encode(fileName, StandardCharsets.UTF_8));

        try {
            byte[] bytes = FileUtil.readBytes(realFilePath);
            response.setContentLength(bytes.length);
            ServletOutputStream os = response.getOutputStream();
            os.write(bytes);
            os.flush();
            os.close();
        } catch (IOException e) {
            System.out.println("文件下载错误：" + e.getMessage());
        }
    }

    /**
     * 扩展名 -> MIME 类型映射。
     * 优先交给 Spring 的 MediaTypeFactory（内置了几百种常见类型），
     * 匹配不到时再兜底成 application/octet-stream。
     */
    private MediaType resolveMediaType(String fileName) {
        return MediaTypeFactory.getMediaType(fileName)
                .orElse(MediaType.APPLICATION_OCTET_STREAM);
    }

    /**
     * wang-editor编辑器文件上传接口
     */
    @PostMapping("/wang/upload")
    public Map<String, Object> wangEditorUpload(MultipartFile file) {
        String flag = System.currentTimeMillis() + "";
        String fileName = file.getOriginalFilename();
        try {
            // 文件存储形式：时间戳-文件名
            FileUtil.writeBytes(file.getBytes(), filePath + flag + "-" + fileName);
            System.out.println(fileName + "--上传成功");
            Thread.sleep(1L);
        } catch (Exception e) {
            System.err.println(fileName + "--文件上传失败");
        }
        String http = fileBaseUrl + ":" + port  + "/files/download/";
        Map<String, Object> resMap = new HashMap<>();
        // wangEditor上传图片成功后， 需要返回的参数
        resMap.put("errno", 0);
        resMap.put("data", CollUtil.newArrayList(Dict.create().set("url", http + flag + "-" + fileName)));
        return resMap;
    }

}
