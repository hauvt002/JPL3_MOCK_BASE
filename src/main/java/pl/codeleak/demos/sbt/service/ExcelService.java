package pl.codeleak.demos.sbt.service;

import org.springframework.web.multipart.MultipartFile;

import java.io.OutputStream;
import java.util.List;

public interface ExcelService {
    public void save(MultipartFile file);

    void exportDataToExcelTemplate(OutputStream outputStream);
}
