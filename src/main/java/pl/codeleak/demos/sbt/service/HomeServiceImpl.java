package pl.codeleak.demos.sbt.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import pl.codeleak.demos.sbt.dto.request.DoUongRequest;
import pl.codeleak.demos.sbt.dto.request.PageableDTO;
import pl.codeleak.demos.sbt.entity.DoUong;
import pl.codeleak.demos.sbt.repository.DoUongRepo;

import java.util.Collections;
import java.util.List;

@Service
public class HomeServiceImpl implements HomeService{
    @Autowired
    DoUongRepo doUongRepo;


    @Override
    public Page<DoUong> findPaginated(PageableDTO pageable) {
        try {
            int pageSize = pageable.getPageSize();
            int currentPage = pageable.getPageNumber();
            int startItem = currentPage * pageSize;
            List<DoUong> doUongs = doUongRepo.findAll();
            List<DoUong> list;

            if (doUongs.size() < startItem) {
                list = Collections.emptyList();
            } else {
                int toIndex = Math.min(startItem + pageSize, doUongs.size());
                list = doUongs.subList(startItem, toIndex);
            }

            return new PageImpl<DoUong>(list, PageRequest.of(currentPage, pageSize), doUongs.size());
        }catch (Exception e){
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Boolean SaveDoUong(DoUongRequest doUongRequest) {
        try{
            DoUong doUong = new DoUong();
            doUong.setTen(doUongRequest.getProductName());
            doUong.setGia(doUongRequest.getPrice());
            doUongRepo.save(doUong);
        }catch (Exception e){
            e.printStackTrace();
        }
        return false;
    }

}
