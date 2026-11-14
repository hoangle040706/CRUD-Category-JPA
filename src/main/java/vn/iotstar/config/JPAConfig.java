package vn.iotstar.config;

import jakarta.persistence.EntityManager;

public class JPAConfig extends JpaConfig {
    public static EntityManager getEntityManager() {
        return JpaConfig.getEntityManager();
    }
}
