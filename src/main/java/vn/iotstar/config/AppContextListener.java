package vn.iotstar.config;

import java.util.concurrent.*;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

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
                        Thread thread = new Thread(r, "mail-worker-" + count++);
                        thread.setDaemon(true);
                        return thread;
                    }
                },
                new ThreadPoolExecutor.AbortPolicy());
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
    }

    public static ThreadPoolExecutor getMailExecutor() {
        return mailExecutor;
    }
}
