package pl.codeleak.demos.sbt.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.LocalDateTime;

@Controller
class HomeController {


    @GetMapping("/")
    String index(Model model) {
        model.addAttribute("now", LocalDateTime.now());
        return "index";
    }

    @GetMapping("/login")
    String login() {
        return "login/login";
    }

    @GetMapping("properties")
    @ResponseBody
    java.util.Properties properties() {
        return System.getProperties();
    }

}
