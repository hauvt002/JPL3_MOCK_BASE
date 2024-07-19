package pl.codeleak.demos.sbt.home;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import pl.codeleak.demos.sbt.dto.response.FileResponseDTO;
import pl.codeleak.demos.sbt.service.FileStorageService;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/files/")
public class FileUploadController {
    @Autowired
    private FileStorageService fileStorageService;

    @GetMapping("/uploadFile")
    public String loadUpLoadFile(Model model){
        model.addAttribute("message", null);
        return "th-upload-form";
    }


    @PostMapping("/uploadFilePF")
    public String uploadFile(Model model,@RequestParam("file") MultipartFile file) {
        String message = "";
        try{
            String fileName = fileStorageService.storeFile(file);
            String fileDownloadUri = ServletUriComponentsBuilder.fromCurrentContextPath()
                    .path("/downloadFile/")
                    .path(fileName).toUriString();
            message = "Uploaded the file successfully: " + file.getOriginalFilename();
            model.addAttribute("message", message);
        }catch (Exception e){
            message = "Could not upload the file: " + file.getOriginalFilename() + ". Error: " +
                    e.getMessage();
            model.addAttribute("message", message);
        }
        return "th-upload-form";
    }


    @PostMapping("/uploadFile")
    public FileResponseDTO uploadFile(@RequestParam("file") MultipartFile file) {
        String fileName = fileStorageService.storeFile(file);
        String fileDownloadUri = ServletUriComponentsBuilder.fromCurrentContextPath()
                .path("/downloadFile/")
                .path(fileName).toUriString();


        return new FileResponseDTO(fileName, fileDownloadUri, file.getContentType(), file.getSize());
    }


    @PostMapping("/uploadMultipleFiles")
    public List<FileResponseDTO> uploadMultipleFiles(@RequestParam("files") MultipartFile[] files) {
        return Arrays.asList(files).stream().map(file -> uploadFile(file)).collect(Collectors.toList());
    }



}
