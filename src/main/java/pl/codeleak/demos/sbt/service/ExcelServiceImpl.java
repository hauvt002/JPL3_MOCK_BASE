package pl.codeleak.demos.sbt.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import pl.codeleak.demos.sbt.entity.DoUong;
import pl.codeleak.demos.sbt.exeption.FileNotFoundException;
import pl.codeleak.demos.sbt.helper.ExcelHelper;
import pl.codeleak.demos.sbt.repository.DoUongRepo;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.jxls.common.Context;
import org.jxls.util.JxlsHelper;


@Service
public class ExcelServiceImpl implements ExcelService{

    @Autowired
    DoUongRepo doUongRepo;

    public void save(MultipartFile file) {
        try {
            List<DoUong> doUongs = ExcelHelper.excelToTutorials(file.getInputStream());
            doUongRepo.saveAll(doUongs);
        } catch (IOException e) {
            throw new RuntimeException("fail to store excel data: " + e.getMessage());
        }
    }

    @Override
    public void exportDataToExcelTemplate(OutputStream outputStream) {
        List<DoUong> data = initializeData();

        Map<String, Object> doUongs = new HashMap<>();
        doUongs.put("data", data);

        try(InputStream inputStream = this.getClass().getResourceAsStream("/template_exports/template_server_list_for_export2.xlsx")) {
            Context context = new Context();
            context.toMap().putAll(doUongs);
            JxlsHelper.getInstance().processTemplate(inputStream, outputStream, context);
        } catch(NullPointerException e) {
            throw new FileNotFoundException("Template not found in resources/templates_exports",e);
        }
        catch (Exception e) {
            throw new RuntimeException(e);
        }
    }


    private List<DoUong> initializeData() {
        try {
            List<DoUong> doUongs = doUongRepo.findAll();
            return doUongs;
        }catch (Exception e)
        {
            e.printStackTrace();
        }
        return null;
    }

}
