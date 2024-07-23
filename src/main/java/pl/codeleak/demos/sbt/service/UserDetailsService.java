package pl.codeleak.demos.sbt.service;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

public interface UserDetailsService {
    public UserDetails loadUserByUsername(String username);
}
