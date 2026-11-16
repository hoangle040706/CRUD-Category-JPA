package vn.iotstar.dao;

import java.util.Date;
import java.util.List;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import vn.iotstar.config.JpaConfig;
import vn.iotstar.entity.User;

public class UserDao implements IUserDao {

    @Override
    public void insert(User user) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            enma.persist(user);
            trans.commit();
        } catch (Exception e) {
            e.printStackTrace();
            if (trans.isActive()) {
                trans.rollback();
            }
            throw e;
        } finally {
            enma.close();
        }
    }

    @Override
    public void update(User user) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            enma.merge(user);
            trans.commit();
        } catch (Exception e) {
            e.printStackTrace();
            if (trans.isActive()) {
                trans.rollback();
            }
            throw e;
        } finally {
            enma.close();
        }
    }

    @Override
    public void delete(int id) throws Exception {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            User user = enma.find(User.class, id);
            if (user != null) {
                enma.remove(user);
            } else {
                throw new Exception("Không tìm thấy user");
            }
            trans.commit();
        } catch (Exception e) {
            e.printStackTrace();
            if (trans.isActive()) {
                trans.rollback();
            }
            throw e;
        } finally {
            enma.close();
        }
    }

    @Override
    public User findById(int id) {
        EntityManager enma = JpaConfig.getEntityManager();
        try {
            return enma.find(User.class, id);
        } finally {
            enma.close();
        }
    }

    @Override
    public User findByUsername(String username) {
        EntityManager enma = JpaConfig.getEntityManager();
        String jpql = "SELECT u FROM User u WHERE u.username = :username";
        try {
            TypedQuery<User> query = enma.createQuery(jpql, User.class);
            query.setParameter("username", username);
            List<User> list = query.getResultList();
            if (list.isEmpty()) {
                return null;
            }
            return list.get(0);
        } finally {
            enma.close();
        }
    }

    @Override
    public User findByEmail(String email) {
        EntityManager enma = JpaConfig.getEntityManager();
        String jpql = "SELECT u FROM User u WHERE u.email = :email";
        try {
            TypedQuery<User> query = enma.createQuery(jpql, User.class);
            query.setParameter("email", email);
            List<User> list = query.getResultList();
            if (list.isEmpty()) {
                return null;
            }
            return list.get(0);
        } finally {
            enma.close();
        }
    }

    @Override
    public User findByRememberTokenHash(String rememberTokenHash) {
        EntityManager enma = JpaConfig.getEntityManager();
        String jpql = "SELECT u FROM User u WHERE u.rememberTokenHash = :tokenHash";
        try {
            TypedQuery<User> query = enma.createQuery(jpql, User.class);
            query.setParameter("tokenHash", rememberTokenHash);
            List<User> list = query.getResultList();
            if (list.isEmpty()) {
                return null;
            }
            return list.get(0);
        } finally {
            enma.close();
        }
    }

    @Override
    public List<User> findAll() {
        EntityManager enma = JpaConfig.getEntityManager();
        try {
            TypedQuery<User> query = enma.createNamedQuery("User.findAll", User.class);
            return query.getResultList();
        } finally {
            enma.close();
        }
    }

    @Override
    public boolean checkExistEmail(String email) {
        return findByEmail(email) != null;
    }

    @Override
    public boolean checkExistUsername(String username) {
        return findByUsername(username) != null;
    }

    @Override
    public boolean checkExistPhone(String phone) {
        EntityManager enma = JpaConfig.getEntityManager();
        String jpql = "SELECT u FROM User u WHERE u.phone = :phone";
        try {
            TypedQuery<User> query = enma.createQuery(jpql, User.class);
            query.setParameter("phone", phone);
            List<User> list = query.getResultList();
            return !list.isEmpty();
        } finally {
            enma.close();
        }
    }

    @Override
    public int lockOtpRequest(String email, String otp, String otpType, Date cooldownThreshold, Date now) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            String jpql = "UPDATE User u SET u.otpCooldownAt = :now, u.code = :otp, u.otpExpired = NULL, u.otpAttempts = 0, u.otpType = :otpType "
                    + "WHERE u.email = :email AND (u.otpCooldownAt IS NULL OR u.otpCooldownAt < :cooldownThreshold)";
            int rows = enma.createQuery(jpql)
                    .setParameter("now", now)
                    .setParameter("otp", otp)
                    .setParameter("otpType", otpType)
                    .setParameter("email", email)
                    .setParameter("cooldownThreshold", cooldownThreshold)
                    .executeUpdate();
            trans.commit();
            enma.clear();
            return rows;
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            throw e;
        } finally {
            enma.close();
        }
    }

    @Override
    public int setOtpExpiry(String email, String otp, Date expiry) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            String jpql = "UPDATE User u SET u.otpExpired = :expiry WHERE u.email = :email AND u.code = :otp AND u.otpExpired IS NULL";
            int rows = enma.createQuery(jpql)
                    .setParameter("expiry", expiry)
                    .setParameter("email", email)
                    .setParameter("otp", otp)
                    .executeUpdate();
            trans.commit();
            enma.clear();
            return rows;
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            throw e;
        } finally {
            enma.close();
        }
    }

    @Override
    public int cancelOtp(String email, String otp) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            String jpql = "UPDATE User u SET u.code = NULL, u.otpExpired = NULL, u.otpCooldownAt = NULL, u.otpType = NULL "
                    + "WHERE u.email = :email AND u.code = :otp";
            int rows = enma.createQuery(jpql)
                    .setParameter("email", email)
                    .setParameter("otp", otp)
                    .executeUpdate();
            trans.commit();
            enma.clear();
            return rows;
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            throw e;
        } finally {
            enma.close();
        }
    }

    @Override
    public int consumeRegisterOtp(String email, String otp, Date now) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            String jpql = "UPDATE User u SET u.status = 1, u.code = NULL, u.otpExpired = NULL, u.otpAttempts = 0, u.otpType = NULL "
                    + "WHERE u.email = :email AND u.code = :otp AND u.otpExpired > :now AND u.otpAttempts < 5 AND u.otpType = 'REGISTER'";
            int rows = enma.createQuery(jpql)
                    .setParameter("email", email)
                    .setParameter("otp", otp)
                    .setParameter("now", now)
                    .executeUpdate();
            trans.commit();
            enma.clear();
            return rows;
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            throw e;
        } finally {
            enma.close();
        }
    }

    @Override
    public int consumeForgotPasswordOtp(String email, String otp, String newHashedPassword, Date now) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            String jpql = "UPDATE User u SET u.password = :newHashedPassword, u.code = NULL, u.otpExpired = NULL, u.otpAttempts = 0, u.otpType = NULL "
                    + "WHERE u.email = :email AND u.code = :otp AND u.otpExpired > :now AND u.otpAttempts < 5 AND u.otpType = 'FORGOT_PASSWORD'";
            int rows = enma.createQuery(jpql)
                    .setParameter("newHashedPassword", newHashedPassword)
                    .setParameter("email", email)
                    .setParameter("otp", otp)
                    .setParameter("now", now)
                    .executeUpdate();
            trans.commit();
            enma.clear();
            return rows;
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            throw e;
        } finally {
            enma.close();
        }
    }

    @Override
    public int incrementOtpAttempts(String email, String otpType, Date now) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            String jpql1 = "UPDATE User u SET u.otpAttempts = u.otpAttempts + 1 "
                    + "WHERE u.email = :email AND u.otpType = :type AND u.code IS NOT NULL AND u.otpExpired > :now AND u.otpAttempts < 4";
            int rows1 = enma.createQuery(jpql1)
                    .setParameter("email", email)
                    .setParameter("type", otpType)
                    .setParameter("now", now)
                    .executeUpdate();
            if (rows1 > 0) {
                trans.commit();
                enma.clear();
                return 1;
            }

            String jpql2 = "UPDATE User u SET u.otpAttempts = 5, u.code = NULL, u.otpExpired = NULL, u.otpType = NULL "
                    + "WHERE u.email = :email AND u.otpType = :type AND u.code IS NOT NULL AND u.otpExpired > :now AND u.otpAttempts = 4";
            int rows2 = enma.createQuery(jpql2)
                    .setParameter("email", email)
                    .setParameter("type", otpType)
                    .setParameter("now", now)
                    .executeUpdate();
            trans.commit();
            enma.clear();
            if (rows2 > 0) {
                return 2;
            }
            return 0;
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            throw e;
        } finally {
            enma.close();
        }
    }

    @Override
    public int rotateRememberToken(String oldHash, String newHash, Date newExpiry, Date now) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            String jpql = "UPDATE User u SET u.rememberTokenHash = :newHash, u.rememberTokenExpiry = :newExpiry "
                    + "WHERE u.rememberTokenHash = :oldHash AND u.rememberTokenExpiry > :now AND u.status = 1";
            int rows = enma.createQuery(jpql)
                    .setParameter("newHash", newHash)
                    .setParameter("newExpiry", newExpiry)
                    .setParameter("oldHash", oldHash)
                    .setParameter("now", now)
                    .executeUpdate();
            trans.commit();
            enma.clear();
            return rows;
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            throw e;
        } finally {
            enma.close();
        }
    }

    @Override
    public void clearRememberToken(int userId) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            String jpql = "UPDATE User u SET u.rememberTokenHash = NULL, u.rememberTokenExpiry = NULL WHERE u.id = :id";
            enma.createQuery(jpql).setParameter("id", userId).executeUpdate();
            trans.commit();
            enma.clear();
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            throw e;
        } finally {
            enma.close();
        }
    }

    @Override
    public void updatePassword(int userId, String newHashedPassword) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            String jpql = "UPDATE User u SET u.password = :password WHERE u.id = :id";
            enma.createQuery(jpql)
                    .setParameter("password", newHashedPassword)
                    .setParameter("id", userId)
                    .executeUpdate();
            trans.commit();
            enma.clear();
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            throw e;
        } finally {
            enma.close();
        }
    }
}
