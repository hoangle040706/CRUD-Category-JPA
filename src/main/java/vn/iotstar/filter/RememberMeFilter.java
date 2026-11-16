package vn.iotstar.filter;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import vn.iotstar.service.IUserService;
import vn.iotstar.service.IUserService.RememberResult;
import vn.iotstar.service.UserServiceImpl;
import vn.iotstar.util.Constant;

@WebFilter(filterName = "RememberMeFilter", urlPatterns = { "/*" })
public class RememberMeFilter implements Filter {

    private final IUserService userService = new UserServiceImpl();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getServletPath();
        if (isStaticResource(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            Cookie[] cookies = req.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if (Constant.COOKIE_REMEMBER.equals(cookie.getName())) {
                        String rawToken = cookie.getValue();
                        if (rawToken != null && !rawToken.trim().isEmpty()) {
                            RememberResult result = userService.loginWithToken(rawToken.trim());
                            if (result != null && result.getUser() != null) {
                                HttpSession newSession = req.getSession(true);
                                newSession.setAttribute("account", result.getUser());
                                newSession.setAttribute(Constant.SESSION_USER, result.getUser());

                                Cookie newCookie = new Cookie(Constant.COOKIE_REMEMBER, result.getNewRawToken());
                                newCookie.setMaxAge(30 * 24 * 3600);
                                String cookiePath = req.getContextPath();
                                newCookie.setPath(cookiePath == null || cookiePath.isEmpty() ? "/" : cookiePath);
                                newCookie.setHttpOnly(true);
                                if (req.isSecure()) {
                                    newCookie.setSecure(true);
                                }
                                resp.addCookie(newCookie);
                            } else {
                                Cookie delCookie = new Cookie(Constant.COOKIE_REMEMBER, "");
                                delCookie.setMaxAge(0);
                                String cookiePath = req.getContextPath();
                                delCookie.setPath(cookiePath == null || cookiePath.isEmpty() ? "/" : cookiePath);
                                delCookie.setHttpOnly(true);
                                resp.addCookie(delCookie);
                            }
                        }
                        break;
                    }
                }
            }
        }

        chain.doFilter(request, response);
    }

    private boolean isStaticResource(String path) {
        if (path == null) {
            return false;
        }
        String lower = path.toLowerCase();
        return lower.endsWith(".css") || lower.endsWith(".js")
                || lower.endsWith(".png") || lower.endsWith(".jpg")
                || lower.endsWith(".jpeg") || lower.endsWith(".gif")
                || lower.endsWith(".ico") || lower.endsWith(".svg")
                || lower.endsWith(".woff") || lower.endsWith(".woff2")
                || lower.startsWith("/assets/") || lower.startsWith("/uploads/");
    }
}
