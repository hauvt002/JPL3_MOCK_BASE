package pl.codeleak.demos.sbt.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import pl.codeleak.demos.sbt.entity.DoUong;

import java.util.List;
import java.util.Optional;
@Repository
public interface DoUongRepo extends JpaRepository<DoUong,Long> {


    @Override
    long count();

    @Query(value = "select  n from DoUong n ")
    List<DoUong> getListDoUong();

    @Query(value = "select  ten from DoUong where id =:id", nativeQuery = true)
     String getNameById(@Param("id") Long id);
}
