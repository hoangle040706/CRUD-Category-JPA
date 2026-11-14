package vn.iotstar.service;

import java.util.List;
import vn.iotstar.entity.Category;

public interface ICategoryService {

    void insert(Category category);

    int count();

    List<Category> findAll(int page, int pagesize);

    List<Category> searchByName(String catname);

    List<Category> findAll();

    Category findById(int cateid);

    void delete(int cateid) throws Exception;

    void update(Category category);

    Category findByCategoryname(String name);

    default Category get(int id) {
        return findById(id);
    }

    default List<Category> getAll() {
        return findAll();
    }

    default List<Category> search(String keyword) {
        return searchByName(keyword);
    }
}
