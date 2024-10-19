package pl.codeleak.demos.sbt.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import pl.codeleak.demos.sbt.entity.Product;

import java.lang.annotation.Native;

public interface ProductRepository extends JpaRepository<Product, Long> {

    @Query(value = "select * from product where id = ? ", nativeQuery = true)
    Product getAllProduct(@Param("id") Long id);
}
