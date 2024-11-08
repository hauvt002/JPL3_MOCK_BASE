package pl.codeleak.demos.sbt.repository;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;
import pl.codeleak.demos.sbt.entity.User;

public interface UserRepo extends CrudRepository<User, Long> {

    @Query("SELECT u FROM User u WHERE u.email = :username")
    public User getUserByUsername(@Param("username") String username);
}
