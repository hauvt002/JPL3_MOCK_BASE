package pl.codeleak.demos.sbt.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import pl.codeleak.demos.sbt.entity.DoUong;
import pl.codeleak.demos.sbt.repository.DoUongRepo;

import java.awt.print.PageFormat;
import java.awt.print.Pageable;
import java.awt.print.Printable;
import java.util.List;

@Service
public class HomeServiceIMPL implements HomeService{
    @Autowired
    DoUongRepo doUongRepo;

    @Override
    public Page<DoUong> getDoUongs(Integer pageNumber,Integer limitNumberOfPage) {
        try{
            Page<DoUong> doUongs = doUongRepo.findAll(PageRequest.of(pageNumber,limitNumberOfPage));
            return doUongs;
        }catch (Exception e){
            e.printStackTrace();
        }
        return null;
    }
}
