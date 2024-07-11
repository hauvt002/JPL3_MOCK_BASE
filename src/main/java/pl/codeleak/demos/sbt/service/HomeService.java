package pl.codeleak.demos.sbt.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Service;
import pl.codeleak.demos.sbt.entity.DoUong;
import pl.codeleak.demos.sbt.repository.DoUongRepo;

import java.util.List;
import java.util.Optional;


public interface HomeService {

    Page<DoUong> getDoUongs(Integer pageNumber,Integer limitNumberOfPage);


}
