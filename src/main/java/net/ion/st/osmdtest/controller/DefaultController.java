package net.ion.st.osmdtest.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/")
public class DefaultController
{
    @GetMapping({"/", "", "/home", "/index"})
    public String home()
    {
        return "home-mobile";
    }

    @GetMapping("/mobile")
    public String homeMobile()
    {
        return "home-mobile";
    }
}
