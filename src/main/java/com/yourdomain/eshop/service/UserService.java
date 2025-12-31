package com.yourdomain.eshop.service;

import com.yourdomain.eshop.entity.User;
import org.springframework.security.core.userdetails.UserDetailsService;
import java.util.List;

/**
 * 将 UserService 从类转换为接口。
 * 实现类（如 UserServiceImpl）负责具体实现这些方法。
 */
public interface UserService extends UserDetailsService {

	/**
	 * 注册新用户
	 */
	User registerUser(String username, String password, String email, String phone);

	/**
	 * 根据ID获取用户
	 */
	User getUserById(Long id);

	/**
	 * 根据用户名获取用户
	 */
	User getUserByUsername(String username);

	/**
	 * 保存/更新用户实体（例如用于持久化密码已编码的用户）
	 */
	User saveUser(User user);

	/**
	 * 更新用户信息（新签名，包含所有字段）
	 */
	User updateUser(Long id, String username, String password, String email, String phone, User.Role role);

	/**
	 * 删除用户
	 */
	void deleteUser(Long id);

	/**
	 * 获取所有用户列表
	 */
	List<User> getAllUsers();

	/**
	 * 检查用户名是否存在
	 */
	boolean existsByUsername(String username);

	/**
	 * 检查邮箱是否存在
	 */
	boolean existsByEmail(String email);

	/**
	 * 获取当前登录用户
	 * @return 当前登录用户，如果未登录则返回null
	 */
	User getCurrentUser();

	/**
	 * 获取当前登录用户，如果未登录则抛出异常
	 * @return 当前登录用户
	 * @throws RuntimeException 如果用户未登录
	 */
	User getCurrentUserOrThrow();

	/**
	 * 获取当前登录用户的ID
	 * @return 当前登录用户ID，如果未登录则返回null
	 */
	Long getCurrentUserId();

	/**
	 * 获取当前登录用户的ID，如果未登录则抛出异常
	 * @return 当前登录用户ID
	 * @throws RuntimeException 如果用户未登录
	 */
	Long getCurrentUserIdOrThrow();

	/**
	 * 获取所有用户（支持分页）
	 */
	List<User> getAllUsers(int page, int size);

	public boolean isCurrentUserConsumer();
	public boolean isCurrentUserAdmin();
	public boolean isCurrentUserMerchant() ;
}