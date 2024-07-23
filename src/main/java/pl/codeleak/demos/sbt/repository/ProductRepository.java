package pl.codeleak.demos.sbt.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pl.codeleak.demos.sbt.entity.Product;

public interface ProductRepository extends JpaRepository<Product, Long> {

}
