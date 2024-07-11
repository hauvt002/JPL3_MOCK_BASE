package pl.codeleak.demos.sbt.home;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import pl.codeleak.demos.sbt.entity.DoUong;
import pl.codeleak.demos.sbt.service.HomeService;
import pl.codeleak.demos.sbt.service.HomeServiceIMPL;

import java.time.LocalDateTime;
import java.util.List;

@Controller
class HomeController {


    @GetMapping("/")
    String index(Model model) {
        model.addAttribute("now", LocalDateTime.now());
        return "index";
    }

    @GetMapping("properties")
    @ResponseBody
    java.util.Properties properties() {
        return System.getProperties();
    }

}
