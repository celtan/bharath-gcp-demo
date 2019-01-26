package com.bharath.controller;

import com.bharath.converter.UserConverter;
import com.bharath.dto.UserDTO;
import com.bharath.model.User;
import com.bharath.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
public class UserController {

    private final Logger LOGGER = LoggerFactory.getLogger(UserController.class);
    private final UserService userService;
    private final UserConverter userConverter;

    @Autowired
    public UserController(UserService userService, UserConverter userConverter) {
        this.userService = userService;
        this.userConverter = userConverter;
    }

    @RequestMapping
    public ResponseEntity<List<User>> loadAll() {
        LOGGER.info("event=loadAllUsers");
        try {
            long start = System.currentTimeMillis();
            List<User> users = userService.findAll();
            long end = System.currentTimeMillis();
            LOGGER.info("event=searchAll, method=GET, count={}, elapsed_time_ms={}", users.size(), (end-start));
            return new ResponseEntity<>(users, HttpStatus.OK);
        } catch (DataAccessException e) {
            LOGGER.error("message="+e.getMessage());
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @RequestMapping("/{id}")
    public ResponseEntity<UserDTO> loadOne(@PathVariable int id) {
        try {
            long start = System.currentTimeMillis();
            User user = userService.find(id);
            long end = System.currentTimeMillis();
            LOGGER.info("event=searchOne, METHOD=GET, username={}, id={}, elapsed_time_ms={}", user.getUsername(), id, (end-start));
            return new ResponseEntity<>(userConverter.userToDTO(user), HttpStatus.OK);
        } catch (DataAccessException e) {
            LOGGER.error("message="+e.getMessage());
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @RequestMapping(method = RequestMethod.POST)
    public ResponseEntity<UserDTO> create(@RequestBody UserDTO userDTO) {
        try {
            long start = System.currentTimeMillis();
            User user = userService.create(userConverter.DTOtoUser(userDTO));
            long end = System.currentTimeMillis();
            LOGGER.info("event=createUser, method=CREATE, username={}, elapsed_time_ms={}", userDTO.getUsername(), (end-start));
            return new ResponseEntity<>(userConverter.userToDTO(user), HttpStatus.CREATED);
        } catch (DataAccessException e) {
            LOGGER.info(e.getMessage());
            return new ResponseEntity<>(HttpStatus.NOT_ACCEPTABLE);
        }
    }

    @RequestMapping(value = "/{id}", method = RequestMethod.PUT)
    public ResponseEntity<UserDTO> update(@PathVariable int id, @RequestBody UserDTO userDTO) {
        try {
            long start = System.currentTimeMillis();
            User user = userService.update(id, userConverter.DTOtoUser(userDTO));
            long end = System.currentTimeMillis();
            LOGGER.info("event=createUserAtId, method=UPDATE, username={}, id={}, elapsed_time_ms={}", userDTO.getUsername(), id, (end-start));
            return new ResponseEntity<>(userConverter.userToDTO(user), HttpStatus.OK);
        } catch (DataAccessException e) {
            LOGGER.info(e.getMessage());
            return new ResponseEntity<>(HttpStatus.NOT_ACCEPTABLE);
        }
    }

    @RequestMapping(value = "/{id}", method = RequestMethod.DELETE)
    public ResponseEntity delete(@PathVariable int id) {
        long start = System.currentTimeMillis();
        if (userService.delete(id)) {
            long end = System.currentTimeMillis();
            LOGGER.info("event=deleteUserAtId, method=DELETE, id={}, elapsed_time_ms={}", id, (end-start));
            return new ResponseEntity(HttpStatus.OK);
        }
        return new ResponseEntity(HttpStatus.BAD_REQUEST);
    }
}
