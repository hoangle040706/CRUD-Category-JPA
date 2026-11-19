package vn.iotstar.filter;

import org.sitemesh.builder.SiteMeshFilterBuilder;
import org.sitemesh.config.ConfigurableSiteMeshFilter;

/**
 * SiteMesh 3 filter: decorates all pages with the Bootstrap 5 master template.
 * Excludes streaming, image-serving, and static-asset paths.
 */
public class MySiteMeshFilter extends ConfigurableSiteMeshFilter {

    @Override
    protected void applyCustomConfiguration(SiteMeshFilterBuilder builder) {
        builder
            .setDecoratorPrefix("")
            // Map all requests to the master decorator
            .addDecoratorPath("/*", "/views/decorators/web.jsp")
            // Exclude binary / streaming endpoints that must not be decorated
            .addExcludedPath("/video/stream*")
            .addExcludedPath("/image*")
            .addExcludedPath("/assets/*")
            .addExcludedPath("/views/decorators/*");
    }
}
