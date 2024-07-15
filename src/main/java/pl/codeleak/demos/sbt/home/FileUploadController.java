package pl.codeleak.demos.sbt.home;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import pl.codeleak.demos.sbt.dto.response.FileResponseDTO;
import pl.codeleak.demos.sbt.service.FileStorageService;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@RestController

public class FileUploadController {
    @Autowired
    private FileStorageService fileStorageService;
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
