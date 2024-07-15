package pl.codeleak.demos.sbt.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.DefaultResourceLoader;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;
import pl.codeleak.demos.sbt.configs.FileStorageProperties;
import pl.codeleak.demos.sbt.exeption.FileNotFoundException;
import pl.codeleak.demos.sbt.exeption.FileStorageException;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

@Service
public class FileStorageServiceImpl implements FileStorageService{
    private final Path fileStorageLocation;


    @Autowired
    public FileStorageServiceImpl(FileStorageProperties fileStorageProperties, FileStorageProperties fileStorageProperties1) {
        this.fileStorageLocation = Paths.get(fileStorageProperties.getUploadDir()).
                toAbsolutePath().normalize();


        try {
            Files.createDirectories(this.fileStorageLocation);
        } catch (Exception ex) {
            throw new FileStorageException("Could not create the directory where the " +
                    "uploaded files will be stored.", ex);
        }
    }

    @Override
    public String storeFile(MultipartFile file) {
        // Normalize file name
        String fileName = StringUtils.cleanPath(file.getOriginalFilename());
        try {
            // Check if the file's name contains invalid characters
            if (fileName.contains("..")) {
                throw new FileStorageException("Sorry! Filename contains invalid path sequence "
                        + fileName);
            }
            // Copy file to the target location (Replacing existing file with the same name) Path targetLocation = this.fileStorageLocation.resolve(fileName);
            Path targetLocation = this.fileStorageLocation.resolve(fileName);
            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);

            return fileName;

        } catch (IOException ex) {
            throw new FileStorageException("Could not store file "
                    + fileName + ". Please try again!", ex);
        }
    }
    @Override
    public Path load(String filename) {
        return fileStorageLocation.resolve(filename);
    }

    @Override
    public Resource loadAsResource(String filename) {
        try {
            Path file = load(filename);
            Resource resource = new UrlResource(file.toUri());
            if (resource.exists() || resource.isReadable()) {
                return resource;
            }
            else {
                throw new FileStorageException(
                        "Could not read file: " + filename);

            }
        }
        catch (MalformedURLException e) {
            throw new FileStorageException("Could not read file: " + filename, e);
        } catch (FileNotFoundException e) {
            throw new RuntimeException(e);
        }
    }
}
