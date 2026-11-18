package vn.iotstar;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class TestBootstrapHelper {
    private static final Object LOCK = new Object();
    private static volatile boolean bootstrapped = false;

    public static void ensureTestDatabaseReady() {
        if (!bootstrapped) {
            synchronized (LOCK) {
                if (!bootstrapped) {
                    runBootstrapSql();
                    bootstrapped = true;
                }
            }
        }
    }

    private static void runBootstrapSql() {
        String host = System.getProperty("DB_HOST", "localhost");
        String port = System.getProperty("DB_PORT", "3306");
        String user = System.getProperty("jakarta.persistence.jdbc.user", "root");
        String pass = System.getProperty("jakarta.persistence.jdbc.password", "123456");

        String rootJdbcUrl = "jdbc:mysql://" + host + ":" + port
                + "/?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&allowMultiQueries=true";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            InputStream is = TestBootstrapHelper.class.getResourceAsStream("/database-test-bootstrap.sql");
            if (is == null) {
                throw new RuntimeException("Cannot find /database-test-bootstrap.sql in classpath");
            }

            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    String trimmed = line.trim();
                    if (trimmed.startsWith("--") || trimmed.isEmpty()) {
                        continue;
                    }
                    sb.append(line).append("\n");
                }
            }

            String fullSql = sb.toString();
            try (Connection conn = DriverManager.getConnection(rootJdbcUrl, user, pass);
                 Statement stmt = conn.createStatement()) {
                String[] statements = fullSql.split(";");
                for (String sql : statements) {
                    String trimmed = sql.trim();
                    if (!trimmed.isEmpty()) {
                        stmt.execute(trimmed);
                    }
                }
            }
            System.out.println("[TestBootstrapHelper] servletjpa_test successfully bootstrapped.");
        } catch (Exception e) {
            System.err.println("[TestBootstrapHelper] Bootstrap failed: " + e.getMessage());
            throw new RuntimeException("Could not bootstrap test database", e);
        }
    }
}
