package vn.iotstar.entity;

import java.io.Serializable;
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

    @Column(name = "Active")
    private int active;

    @Column(name = "Description", columnDefinition = "nvarchar(500) null")
    private String description;

    @Column(name = "Poster", columnDefinition = "nvarchar(500) null")
    private String poster;

    @Column(name = "Title", columnDefinition = "nvarchar(500) null")
    private String title;

    @Column(name = "Views")
    private int views;

    @ManyToOne
    @JoinColumn(name = "CategoryId")
    private Category category;

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
