package com.bellybutton.web;

import com.bellybutton.entity.Users;
import com.bellybutton.repository.UsersRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin
@RestController
@RequestMapping("/userresource")

public class UserResource {
    @Autowired
    private UsersRepository usersRepository;

    @PostMapping("/users")
    public Users createUser(@RequestBody Users user) {
        return usersRepository.save(user);
    }

    @GetMapping("/users")
    public List<Users> getAllUsers() {
        return usersRepository.findAll();
    }
    @GetMapping("/users/{id}")
    public Users getUserById(@PathVariable Long id) {
        return usersRepository.findById(id).orElse(null);
    }
    @PutMapping("/users/{id}")
    public Users updateUser(@PathVariable Long id, @RequestBody Users userDetails) {
        return usersRepository.findById(id).map(user -> {
            user.setName(userDetails.getName());
            user.setEmail(userDetails.getEmail());
            user.setPassword(userDetails.getPassword());
            return usersRepository.save(user);
        }).orElse(null);
    }
    @DeleteMapping("/users/{id}")
    public String deleteUser(@PathVariable Long id) {
        usersRepository.deleteById(id);
        return "User with id " + id + " deleted successfully!";
    }

    @PostMapping("/login")
    public String loginUser(@RequestBody Users loginRequest) {
        Users user = usersRepository.findByEmail(loginRequest.getEmail());
        if(user != null && user.getPassword().equals(loginRequest.getPassword())) {
            return "Login successful for user: " + user.getName();
        } else {
            return "Invalid email or password!";
        }
    }
}
