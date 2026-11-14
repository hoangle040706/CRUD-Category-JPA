package vn.iotstar.service;

import java.sql.Date;
import java.util.List;
import vn.iotstar.dao.IUserDao;
import vn.iotstar.dao.UserDao;
import vn.iotstar.entity.User;

public class UserServiceImpl implements IUserService {

    private final IUserDao userDao = new UserDao();

    @Override
    public User login(String username, String password) {
        User user = userDao.findByUsername(username);
        if (user != null && password.equals(user.getPassword())) {
            return user;
        }
        return null;
    }

    @Override
    public User get(int id) {
        return userDao.findById(id);
    }

    @Override
    public User get(String username) {
        return userDao.findByUsername(username);
    }

    @Override
    public void insert(User user) {
        userDao.insert(user);
    }

    @Override
    public void update(User user) {
        userDao.update(user);
    }

    @Override
    public boolean register(String email, String password, String username, String fullname, String phone) {
        if (userDao.checkExistUsername(username) || userDao.checkExistEmail(email)) {
            return false;
        }
        User user = new User();
        user.setEmail(email);
        user.setUsername(username);
        user.setFullname(fullname);
        user.setPassword(password);
        user.setRoleid(5);
        user.setPhone(phone);
        user.setAvatar("user.png");
        user.setCreatedDate(new Date(System.currentTimeMillis()));
        userDao.insert(user);
        return true;
    }

    @Override
    public boolean checkExistEmail(String email) {
        return userDao.checkExistEmail(email);
    }

    @Override
    public boolean checkExistUsername(String username) {
        return userDao.checkExistUsername(username);
    }

    @Override
    public boolean checkExistPhone(String phone) {
        return userDao.checkExistPhone(phone);
    }

    @Override
    public List<User> getAll() {
        return userDao.findAll();
    }
}
