package pl.codeleak.demos.sbt.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Service;
import pl.codeleak.demos.sbt.dto.request.DoUongRequest;
import pl.codeleak.demos.sbt.dto.request.PageableDTO;
import pl.codeleak.demos.sbt.entity.DoUong;
import pl.codeleak.demos.sbt.repository.DoUongRepo;

import java.util.List;
import java.util.Optional;


public interface HomeService {
    Page<DoUong> findPaginated(PageableDTO pageable);

    Boolean SaveDoUong(DoUongRequest doUongRequest);

}
