package vn.iotstar.entity;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotEmpty;
import lombok.*;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Data
@Table(name = "categories")
@NamedQuery(name = "Category.findAll", query = "SELECT c FROM Category c")
public class Category implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "CategoryId")
    private int categoryid;

    @Column(name = "CategoryName", columnDefinition = "nvarchar(255) not null")
    @NotEmpty(message = "Không được phép rỗng")
    private String categoryname;

    @Column(name = "Images", columnDefinition = "nvarchar(500) null")
    private String images;

    @Column(name = "status")
    private int status;

    @OneToMany(mappedBy = "category", cascade = CascadeType.ALL)
    private List<Video> videos = new ArrayList<>();

    public Video addVideo(Video video) {
        if (videos == null) {
            videos = new ArrayList<>();
        }
        videos.add(video);
        video.setCategory(this);
        return video;
    }

    public Video removeVideo(Video video) {
        if (videos != null) {
            videos.remove(video);
            video.setCategory(null);
        }
        return video;
    }

    public int getCategoryId() {
        return this.categoryid;
    }

    public void setCategoryId(int categoryId) {
        this.categoryid = categoryId;
    }

    public int getCategoryid() {
        return this.categoryid;
    }

    public void setCategoryid(int categoryid) {
        this.categoryid = categoryid;
    }

    public int getId() {
        return this.categoryid;
    }

    public void setId(int id) {
        this.categoryid = id;
    }

    public String getName() {
        return this.categoryname;
    }

    public void setName(String name) {
        this.categoryname = name;
    }

    public String getIcon() {
        return this.images;
    }

    public void setIcon(String icon) {
        this.images = icon;
    }

    public String getIcons() {
        return this.images;
    }

    public void setIcons(String icons) {
        this.images = icons;
    }
}
