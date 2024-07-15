package pl.codeleak.demos.sbt.dto.response;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor

public class FileResponseDTO {
    private String fileName;
    private String fileDownloadUri;
    private String fileType;
    private long size;

    public FileResponseDTO(String fileName, String fileDownloadUri, String fileType, long size) {
        this.fileName = fileName; this.fileDownloadUri = fileDownloadUri; this.fileType = fileType;
        this.size = size;
    }

}
