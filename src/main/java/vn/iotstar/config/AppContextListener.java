package vn.iotstar.config;

import java.io.File;
import java.util.Set;
import java.util.concurrent.*;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import vn.iotstar.dao.IVideoDao;
import vn.iotstar.dao.VideoDao;
import vn.iotstar.util.Constant;

@WebListener
public class AppContextListener implements ServletContextListener {
    private static ThreadPoolExecutor mailExecutor;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        BlockingQueue<Runnable> queue = new ArrayBlockingQueue<>(100);
        mailExecutor = new ThreadPoolExecutor(
                2,
                4,
                60L,
                TimeUnit.SECONDS,
                queue,
                new ThreadFactory() {
                    private int count = 1;

                    @Override
                    public Thread newThread(Runnable r) {
                        Thread thread = new Thread(r, "app-worker-" + count++);
                        thread.setDaemon(true);
                        return thread;
                    }
                },
                new ThreadPoolExecutor.AbortPolicy());

        // Asynchronous Startup Orphan File Cleaner
        mailExecutor.submit(() -> {
            try {
                // Cho phép database khởi tạo hoàn chỉnh trước khi quét
                Thread.sleep(5000);
                cleanOrphanFiles();
            } catch (Exception e) {
                System.err.println("[AppContextListener] Cleanup orphan files warning: " + e.getMessage());
            }
        });
    }

    private void cleanOrphanFiles() {
        try {
            IVideoDao videoDao = new VideoDao();
            Set<String> referencedFiles = videoDao.getAllReferencedLocalFiles();
            long now = System.currentTimeMillis();
            long oneHourAgo = now - (60L * 60L * 1000L);

            cleanDirectory(new File(Constant.getPosterDir()), referencedFiles, oneHourAgo);
            cleanDirectory(new File(Constant.getVideoDir()), referencedFiles, oneHourAgo);
        } catch (Exception e) {
            System.err.println("[AppContextListener] Failed to scan orphan files: " + e.getMessage());
        }
    }

    private void cleanDirectory(File dir, Set<String> referencedFiles, long cutoffTime) {
        if (!dir.exists() || !dir.isDirectory()) {
            return;
        }
        File[] files = dir.listFiles();
        if (files == null) {
            return;
        }
        for (File file : files) {
            if (file.isFile()) {
                String fileName = file.getName();
                if (fileName.equals(Constant.DEFAULT_FILENAME) || fileName.equals(Constant.DEFAULT_POSTER)) {
                    continue;
                }
                if (file.lastModified() < cutoffTime && !referencedFiles.contains(fileName)) {
                    try {
                        file.delete();
                    } catch (Exception ignored) {
                    }
                }
            }
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (mailExecutor != null && !mailExecutor.isShutdown()) {
            mailExecutor.shutdown();
            try {
                if (!mailExecutor.awaitTermination(5, TimeUnit.SECONDS)) {
                    mailExecutor.shutdownNow();
                }
            } catch (InterruptedException e) {
                mailExecutor.shutdownNow();
                Thread.currentThread().interrupt();
            }
        }
        JpaConfig.closeFactory();
    }

    public static ThreadPoolExecutor getMailExecutor() {
        return mailExecutor;
    }
}
