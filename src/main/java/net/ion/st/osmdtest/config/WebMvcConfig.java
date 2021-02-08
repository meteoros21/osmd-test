package net.ion.st.osmdtest.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.web.servlet.config.annotation.ContentNegotiationConfigurer;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurationSupport;
import org.springframework.web.servlet.view.InternalResourceViewResolver;

@Configuration
public class WebMvcConfig extends WebMvcConfigurationSupport
{
    @Value("${resources.upload-path}")
    String uploadPath;
    @Value("${resources.upload-url}")
    String uploadUrl;

    @Bean(name="viewResolver")
    public InternalResourceViewResolver getViewResolver() {
        InternalResourceViewResolver viewResolver = new InternalResourceViewResolver();
        viewResolver.setPrefix("/WEB-INF/views/");
        viewResolver.setSuffix(".jsp");
        return viewResolver;
    }

    @Override
    protected void addResourceHandlers(ResourceHandlerRegistry registry)
    {
        //super.addResourceHandlers(registry);
        registry.addResourceHandler(uploadUrl + "/**")
                .addResourceLocations("file://" + uploadPath + "/");
        registry.addResourceHandler("/data/**").addResourceLocations("/data/");
        registry.addResourceHandler("/css/**").addResourceLocations("/css/");
        registry.addResourceHandler("/js/**").addResourceLocations("/js/");
        registry.addResourceHandler("/img/**").addResourceLocations("/img/");
        registry.addResourceHandler("/inspinia/**").addResourceLocations("/inspinia/");
    }

    /**
     * pathValue에 email이 들어가면 오류가 발생한다(406).
     * '.com'과 같이 '.'을 Spring은 파일 확장자로 취급하나보다.
     * 예를 들어 @RequestMapping에서 produces = {"application/json", "application/xml"} 로
     * JSON과 XML을 동시에 생산해내는 컨트롤러에서 /path/name/test.json, /path/name/test.xml 등으로
     * 컨트롤러를 호출할 수 있나보다.
     * @param configurer
     */
    @Override
    protected void configureContentNegotiation(ContentNegotiationConfigurer configurer)
    {
        //super.configureContentNegotiation(configurer);
        configurer.favorPathExtension(true)
                .favorParameter(false)
                .ignoreAcceptHeader(true)
                .useJaf(false)
                .defaultContentType(MediaType.APPLICATION_JSON_UTF8);
    }
}
