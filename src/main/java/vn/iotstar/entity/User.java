package vn.iotstar.entity;

import java.io.Serializable;
import java.sql.Date;
import jakarta.persistence.*;
import lombok.*;

@NoArgsConstructor
@AllArgsConstructor
@Data
@Entity
@Table(name = "users")
@NamedQuery(name = "User.findAll", query = "SELECT u FROM User u")
public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(length = 100, unique = true, nullable = false)
    private String email;

    @Column(length = 50, unique = true, nullable = false)
    private String username;

    @Column(length = 100)
    private String fullname;

    @Column(length = 100, nullable = false)
    private String password;

    @Column(length = 255)
    private String avatar;

    private int roleid;

    @Column(length = 20)
    private String phone;

    private Date createdDate;

    private int status;

    @Column(length = 10)
    private String code;

    @Temporal(TemporalType.TIMESTAMP)
    private java.util.Date otpExpired;

    private int otpAttempts;

    @Column(length = 20)
    private String otpType;

    @Temporal(TemporalType.TIMESTAMP)
    private java.util.Date otpCooldownAt;

    @Column(length = 64)
    private String rememberTokenHash;

    @Temporal(TemporalType.TIMESTAMP)
    private java.util.Date rememberTokenExpiry;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getUserName() {
        return this.username;
    }

    public void setUserName(String username) {
        this.username = username;
    }

    public String getFullname() {
        return fullname;
    }

    public void setFullname(String fullname) {
        this.fullname = fullname;
    }

    public String getFullName() {
        return this.fullname;
    }

    public void setFullName(String fullname) {
        this.fullname = fullname;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPassWord() {
        return this.password;
    }

    public void setPassWord(String password) {
        this.password = password;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public int getRoleid() {
        return roleid;
    }

    public void setRoleid(int roleid) {
        this.roleid = roleid;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public Date getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public java.util.Date getOtpExpired() {
        return otpExpired;
    }

    public void setOtpExpired(java.util.Date otpExpired) {
        this.otpExpired = otpExpired;
    }

    public int getOtpAttempts() {
        return otpAttempts;
    }

    public void setOtpAttempts(int otpAttempts) {
        this.otpAttempts = otpAttempts;
    }

    public String getOtpType() {
        return otpType;
    }

    public void setOtpType(String otpType) {
        this.otpType = otpType;
    }

    public java.util.Date getOtpCooldownAt() {
        return otpCooldownAt;
    }

    public void setOtpCooldownAt(java.util.Date otpCooldownAt) {
        this.otpCooldownAt = otpCooldownAt;
    }

    public String getRememberTokenHash() {
        return rememberTokenHash;
    }

    public void setRememberTokenHash(String rememberTokenHash) {
        this.rememberTokenHash = rememberTokenHash;
    }

    public java.util.Date getRememberTokenExpiry() {
        return rememberTokenExpiry;
    }

    public void setRememberTokenExpiry(java.util.Date rememberTokenExpiry) {
        this.rememberTokenExpiry = rememberTokenExpiry;
    }

    public String getRoleName() {
        if (roleid == 1) {
            return "ADMIN";
        }
        if (roleid == 2) {
            return "MANAGER";
        }
        return "USER";
    }
}
