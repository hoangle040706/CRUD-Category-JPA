package vn.iotstar.service;

import java.util.List;
import vn.iotstar.entity.User;

public interface IUserService {

    User login(String username, String password);

    User get(int id);

    User get(String username);

    void insert(User user);

    void update(User user);

    boolean register(String email, String password, String username, String fullname, String phone);

    boolean checkExistEmail(String email);

    boolean checkExistUsername(String username);

    boolean checkExistPhone(String phone);

    List<User> getAll();
}
