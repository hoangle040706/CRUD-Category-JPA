package vn.iotstar.config;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import vn.iotstar.entity.Category;
import vn.iotstar.entity.Video;

public class Test {
    public static void main(String[] args) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        Category cate = new Category();
        cate.setCategoryname("Iphone");
        cate.setImages("abc.jpg");
        cate.setStatus(1);

        Video video = new Video();
        video.setVideoId("v01");
        video.setTitle("test");
        video.setCategory(cate);

        try {
            trans.begin();
            enma.persist(cate);
            Video existing = enma.find(Video.class, "v01");
            if (existing != null) {
                enma.remove(existing);
                enma.flush();
            }
            enma.persist(video);
            trans.commit();
            System.out.println("SUCCESS: Persisted Category and Video into database via JPA!");
        } catch (Exception e) {
            e.printStackTrace();
            trans.rollback();
            throw e;
        } finally {
            enma.close();
            System.exit(0);
        }
    }
}
