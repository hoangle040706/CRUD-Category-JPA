package vn.iotstar.entity;

import java.io.Serializable;
import java.util.Date;
import jakarta.persistence.*;
import lombok.*;

@NoArgsConstructor
@AllArgsConstructor
@Data
@Entity
@Table(name = "videos")
@NamedQuery(name = "Video.findAll", query = "SELECT v FROM Video v")
public class Video implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "VideoId", length = 50)
    private String videoId;

    @Column(name = "Title", length = 500, nullable = false)
    private String title;

    @Column(name = "Description", length = 500)
    private String description;

    @Column(name = "Poster", length = 500)
    private String poster;

    @Column(name = "Views")
    private int views;

    @Column(name = "Active")
    private int active;

    @Column(name = "VideoPath", length = 500)
    private String videoPath;

    @Enumerated(EnumType.STRING)
    @Column(name = "SourceType", length = 20, nullable = false)
    private VideoSourceType sourceType = VideoSourceType.LOCAL;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "CreatedDate")
    private Date createdDate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CategoryId")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Category category;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "UserId")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private User user;

    @PrePersist
    protected void onCreate() {
        if (this.createdDate == null) {
            this.createdDate = new Date();
        }
        if (this.sourceType == null) {
            this.sourceType = VideoSourceType.LOCAL;
        }
    }

    public Category getCategories() {
        return this.category;
    }

    public void setCategories(Category category) {
        this.category = category;
    }

    public boolean getActiveBool() {
        return this.active == 1;
    }

    public void setActive(boolean active) {
        this.active = active ? 1 : 0;
    }

    public void setActive(int active) {
        this.active = active;
    }
}
