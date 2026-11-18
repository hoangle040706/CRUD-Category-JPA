package vn.iotstar.service;

import vn.iotstar.dao.IVideoDao;
import vn.iotstar.dao.VideoDao;
import vn.iotstar.entity.Video;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class VideoServiceImpl implements IVideoService {

    private final IVideoDao videoDao;

    public VideoServiceImpl() {
        this.videoDao = new VideoDao();
    }

    public VideoServiceImpl(IVideoDao videoDao) {
        this.videoDao = videoDao;
    }

    @Override
    public void insert(Video video) {
        videoDao.insert(video);
    }

    @Override
    public void update(Video video) {
        videoDao.update(video);
    }

    @Override
    public void delete(String videoId) throws Exception {
        videoDao.delete(videoId);
    }

    @Override
    public Video findById(String videoId) {
        return videoDao.findById(videoId);
    }

    @Override
    public List<Video> findAll() {
        return videoDao.findAll();
    }

    @Override
    public List<Video> findAll(int page, int pageSize) {
        return videoDao.findAll(page, pageSize);
    }

    @Override
    public int count() {
        return videoDao.count();
    }

    @Override
    public List<Video> findTop10Latest() {
        return videoDao.findTop10Latest();
    }

    @Override
    public List<Video> findPublicVideosWithPaging(int page, int pageSize) {
        return videoDao.findPublicVideosWithPaging(page, pageSize);
    }

    @Override
    public int countPublicVideos() {
        return videoDao.countPublicVideos();
    }

    @Override
    public List<Video> findVideosByUserIdWithPaging(int page, int pageSize, int userId) {
        return videoDao.findVideosByUserIdWithPaging(page, pageSize, userId);
    }

    @Override
    public int countVideosByUserId(int userId) {
        return videoDao.countVideosByUserId(userId);
    }

    @Override
    public boolean updateByUser(Video video, int userId) {
        return videoDao.updateByUser(video, userId);
    }

    @Override
    public boolean deleteByUser(String videoId, int userId) {
        return videoDao.deleteByUser(videoId, userId);
    }

    @Override
    public boolean adminUpdateActive(String videoId, int active) {
        return videoDao.adminUpdateActive(videoId, active);
    }

    @Override
    public void incrementViews(String videoId) {
        videoDao.incrementViews(videoId);
    }

    @Override
    public String normalizeYouTubeEmbedUrl(String rawUrl) {
        if (rawUrl == null || rawUrl.trim().isEmpty()) {
            return null;
        }
        String trimmed = rawUrl.trim();
        if (trimmed.contains("youtube.com/embed/")) {
            return trimmed;
        }
        Pattern pattern = Pattern.compile(
                "(?:https?:\\/\\/)?(?:www\\.)?(?:youtube\\.com\\/(?:watch\\?.*v=|embed\\/|v\\/)|youtu\\.be\\/)([a-zA-Z0-9_-]{11})");
        Matcher matcher = pattern.matcher(trimmed);
        if (matcher.find()) {
            String ytid = matcher.group(1);
            return "https://www.youtube.com/embed/" + ytid;
        }
        return trimmed;
    }

    @Override
    public String extractYouTubeThumbnailUrl(String rawUrlOrEmbedPath) {
        if (rawUrlOrEmbedPath == null || rawUrlOrEmbedPath.trim().isEmpty()) {
            return null;
        }
        Pattern pattern = Pattern.compile(
                "(?:https?:\\/\\/)?(?:www\\.)?(?:youtube\\.com\\/(?:watch\\?.*v=|embed\\/|v\\/)|youtu\\.be\\/)([a-zA-Z0-9_-]{11})");
        Matcher matcher = pattern.matcher(rawUrlOrEmbedPath.trim());
        if (matcher.find()) {
            String ytid = matcher.group(1);
            return "https://img.youtube.com/vi/" + ytid + "/hqdefault.jpg";
        }
        return null;
    }
}
