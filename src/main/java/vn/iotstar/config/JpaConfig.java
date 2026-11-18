package vn.iotstar.config;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

import java.util.HashMap;
import java.util.Map;

public class JpaConfig {
    private static volatile EntityManagerFactory factory;
    private static final Object LOCK = new Object();

    protected JpaConfig() {
    }

    private static EntityManagerFactory initFactory() {
        if (factory == null) {
            synchronized (LOCK) {
                if (factory == null) {
                    Map<String, Object> props = new HashMap<>();
                    String testUrl = System.getProperty("jakarta.persistence.jdbc.url");
                    if (testUrl != null && !testUrl.trim().isEmpty()) {
                        props.put("jakarta.persistence.jdbc.url", testUrl.trim());
                    }
                    String testUser = System.getProperty("jakarta.persistence.jdbc.user");
                    if (testUser != null && !testUser.trim().isEmpty()) {
                        props.put("jakarta.persistence.jdbc.user", testUser.trim());
                    }
                    String testPass = System.getProperty("jakarta.persistence.jdbc.password");
                    if (testPass != null) {
                        props.put("jakarta.persistence.jdbc.password", testPass.trim());
                    }

                    try {
                        factory = Persistence.createEntityManagerFactory("jpa-hibernate-mysql", props);
                    } catch (Throwable ex) {
                        System.err.println("Initial EntityManagerFactory creation failed: " + ex);
                        throw new RuntimeException("Could not initialize EntityManagerFactory", ex);
                    }
                }
            }
        }
        return factory;
    }

    public static EntityManager getEntityManager() {
        return initFactory().createEntityManager();
    }

    public static void reconfigureForTest(String jdbcUrl, String user, String password) {
        synchronized (LOCK) {
            closeFactory();
            Map<String, Object> props = new HashMap<>();
            if (jdbcUrl != null) props.put("jakarta.persistence.jdbc.url", jdbcUrl);
            if (user != null) props.put("jakarta.persistence.jdbc.user", user);
            if (password != null) props.put("jakarta.persistence.jdbc.password", password);
            factory = Persistence.createEntityManagerFactory("jpa-hibernate-mysql", props);
        }
    }

    public static void closeFactory() {
        synchronized (LOCK) {
            if (factory != null && factory.isOpen()) {
                factory.close();
            }
            factory = null;
        }
    }
}
