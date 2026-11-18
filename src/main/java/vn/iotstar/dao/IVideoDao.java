package vn.iotstar.dao;

import vn.iotstar.entity.Video;
import java.util.List;
import java.util.Set;

public interface IVideoDao {
    void insert(Video video);
    void update(Video video);
    void delete(String videoId) throws Exception;
    Video findById(String videoId);
    List<Video> findAll();
    List<Video> findAll(int page, int pageSize);
    int count();

    List<Video> findTop10Latest();
    List<Video> findPublicVideosWithPaging(int page, int pageSize);
    int countPublicVideos();
    List<Video> findVideosByUserIdWithPaging(int page, int pageSize, int userId);
    int countVideosByUserId(int userId);
    boolean updateByUser(Video video, int userId);
    boolean deleteByUser(String videoId, int userId);
    boolean adminUpdateActive(String videoId, int active);
    void incrementViews(String videoId);
    Set<String> getAllReferencedLocalFiles();
}
