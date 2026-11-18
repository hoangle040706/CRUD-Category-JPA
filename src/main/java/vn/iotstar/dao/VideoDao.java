package vn.iotstar.dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.Query;
import jakarta.persistence.TypedQuery;
import vn.iotstar.config.JpaConfig;
import vn.iotstar.entity.Video;
import vn.iotstar.entity.VideoSourceType;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class VideoDao implements IVideoDao {

    @Override
    public void insert(Video video) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            enma.persist(video);
            trans.commit();
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
    public void update(Video video) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            enma.merge(video);
            trans.commit();
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
    public void delete(String videoId) throws Exception {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            Video video = enma.find(Video.class, videoId);
            if (video != null) {
                enma.remove(video);
            }
            trans.commit();
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
    public Video findById(String videoId) {
        EntityManager enma = JpaConfig.getEntityManager();
        try {
            TypedQuery<Video> query = enma.createQuery(
                    "SELECT v FROM Video v LEFT JOIN FETCH v.category LEFT JOIN FETCH v.user WHERE v.videoId = :id",
                    Video.class);
            query.setParameter("id", videoId);
            List<Video> results = query.getResultList();
            return results.isEmpty() ? null : results.get(0);
        } finally {
            enma.close();
        }
    }

    @Override
    public List<Video> findAll() {
        EntityManager enma = JpaConfig.getEntityManager();
        try {
            TypedQuery<Video> query = enma.createQuery(
                    "SELECT v FROM Video v LEFT JOIN FETCH v.category LEFT JOIN FETCH v.user ORDER BY v.createdDate DESC, v.videoId DESC",
                    Video.class);
            return query.getResultList();
        } finally {
            enma.close();
        }
    }

    @Override
    public List<Video> findAll(int page, int pageSize) {
        EntityManager enma = JpaConfig.getEntityManager();
        try {
            TypedQuery<Video> query = enma.createQuery(
                    "SELECT v FROM Video v LEFT JOIN FETCH v.category LEFT JOIN FETCH v.user ORDER BY v.createdDate DESC, v.videoId DESC",
                    Video.class);
            query.setFirstResult((page - 1) * pageSize);
            query.setMaxResults(pageSize);
            return query.getResultList();
        } finally {
            enma.close();
        }
    }

    @Override
    public int count() {
        EntityManager enma = JpaConfig.getEntityManager();
        try {
            Query query = enma.createQuery("SELECT COUNT(v) FROM Video v");
            return ((Long) query.getSingleResult()).intValue();
        } finally {
            enma.close();
        }
    }

    @Override
    public List<Video> findTop10Latest() {
        EntityManager enma = JpaConfig.getEntityManager();
        try {
            TypedQuery<Video> query = enma.createQuery(
                    "SELECT v FROM Video v LEFT JOIN FETCH v.category LEFT JOIN FETCH v.user " +
                            "WHERE v.active = 1 AND v.videoPath IS NOT NULL AND TRIM(v.videoPath) != '' " +
                            "ORDER BY v.createdDate DESC, v.videoId DESC",
                    Video.class);
            query.setMaxResults(10);
            return query.getResultList();
        } finally {
            enma.close();
        }
    }

    @Override
    public List<Video> findPublicVideosWithPaging(int page, int pageSize) {
        EntityManager enma = JpaConfig.getEntityManager();
        try {
            TypedQuery<Video> query = enma.createQuery(
                    "SELECT v FROM Video v LEFT JOIN FETCH v.category LEFT JOIN FETCH v.user " +
                            "WHERE v.active = 1 AND v.videoPath IS NOT NULL AND TRIM(v.videoPath) != '' " +
                            "ORDER BY v.createdDate DESC, v.videoId DESC",
                    Video.class);
            query.setFirstResult((page - 1) * pageSize);
            query.setMaxResults(pageSize);
            return query.getResultList();
        } finally {
            enma.close();
        }
    }

    @Override
    public int countPublicVideos() {
        EntityManager enma = JpaConfig.getEntityManager();
        try {
            Query query = enma.createQuery(
                    "SELECT COUNT(v) FROM Video v WHERE v.active = 1 AND v.videoPath IS NOT NULL AND TRIM(v.videoPath) != ''");
            return ((Long) query.getSingleResult()).intValue();
        } finally {
            enma.close();
        }
    }

    @Override
    public List<Video> findVideosByUserIdWithPaging(int page, int pageSize, int userId) {
        EntityManager enma = JpaConfig.getEntityManager();
        try {
            TypedQuery<Video> query = enma.createQuery(
                    "SELECT v FROM Video v LEFT JOIN FETCH v.category LEFT JOIN FETCH v.user " +
                            "WHERE v.user.id = :userId " +
                            "ORDER BY v.createdDate DESC, v.videoId DESC",
                    Video.class);
            query.setParameter("userId", userId);
            query.setFirstResult((page - 1) * pageSize);
            query.setMaxResults(pageSize);
            return query.getResultList();
        } finally {
            enma.close();
        }
    }

    @Override
    public int countVideosByUserId(int userId) {
        EntityManager enma = JpaConfig.getEntityManager();
        try {
            Query query = enma.createQuery(
                    "SELECT COUNT(v) FROM Video v WHERE v.user.id = :userId");
            query.setParameter("userId", userId);
            return ((Long) query.getSingleResult()).intValue();
        } finally {
            enma.close();
        }
    }

    @Override
    public boolean updateByUser(Video video, int userId) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            Video existing = enma.find(Video.class, video.getVideoId());
            if (existing == null || existing.getUser() == null || existing.getUser().getId() != userId) {
                trans.rollback();
                return false;
            }
            existing.setTitle(video.getTitle());
            existing.setDescription(video.getDescription());
            if (video.getPoster() != null) {
                existing.setPoster(video.getPoster());
            }
            if (video.getVideoPath() != null) {
                existing.setVideoPath(video.getVideoPath());
                existing.setSourceType(video.getSourceType());
            }
            existing.setCategory(video.getCategory());
            // Moderation policy: updating video resets active = 0 (pending re-approval)
            existing.setActive(0);
            enma.merge(existing);
            trans.commit();
            return true;
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
    public boolean deleteByUser(String videoId, int userId) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            Video existing = enma.find(Video.class, videoId);
            if (existing == null || existing.getUser() == null || existing.getUser().getId() != userId) {
                trans.rollback();
                return false;
            }
            enma.remove(existing);
            trans.commit();
            return true;
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
    public boolean adminUpdateActive(String videoId, int active) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            Video existing = enma.find(Video.class, videoId);
            if (existing == null) {
                trans.rollback();
                return false;
            }
            existing.setActive(active);
            enma.merge(existing);
            trans.commit();
            return true;
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
    public void incrementViews(String videoId) {
        EntityManager enma = JpaConfig.getEntityManager();
        EntityTransaction trans = enma.getTransaction();
        try {
            trans.begin();
            Query query = enma.createQuery("UPDATE Video v SET v.views = v.views + 1 WHERE v.videoId = :id");
            query.setParameter("id", videoId);
            query.executeUpdate();
            trans.commit();
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
        } finally {
            enma.close();
        }
    }

    @Override
    public Set<String> getAllReferencedLocalFiles() {
        Set<String> files = new HashSet<>();
        EntityManager enma = JpaConfig.getEntityManager();
        try {
            Query query = enma.createQuery("SELECT v.poster, v.videoPath, v.sourceType FROM Video v");
            List<?> rows = query.getResultList();
            for (Object item : rows) {
                if (item instanceof Object[] row) {
                    String poster = (String) row[0];
                    String videoPath = (String) row[1];
                    VideoSourceType sourceType = (VideoSourceType) row[2];

                    if (poster != null && !poster.trim().isEmpty() && !poster.startsWith("http")) {
                        files.add(poster.trim());
                    }
                    if (sourceType == VideoSourceType.LOCAL && videoPath != null && !videoPath.trim().isEmpty() && !videoPath.startsWith("http")) {
                        files.add(videoPath.trim());
                    }
                }
            }
        } finally {
            enma.close();
        }
        return files;
    }
}
