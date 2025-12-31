/* 个人中心编辑功能JavaScript */

// 打开编辑个人信息模态框
function openEditProfileModal() {
    const modal = document.getElementById('editProfileModal');
    if (modal) {
        modal.classList.add('active');
        // 阻止背景滚动
        document.body.style.overflow = 'hidden';
    }
}

// 关闭编辑个人信息模态框
function closeEditProfileModal() {
    const modal = document.getElementById('editProfileModal');
    if (modal) {
        modal.classList.remove('active');
        // 恢复背景滚动
        document.body.style.overflow = '';
        // 重置表单错误状态
        resetFormErrors();
    }
}

// 重置表单错误状态
function resetFormErrors() {
    const form = document.getElementById('editProfileForm');
    if (form) {
        const inputs = form.querySelectorAll('.form-control');
        inputs.forEach(input => {
            input.classList.remove('error');
        });
        
        const errorMessages = form.querySelectorAll('.error-message');
        errorMessages.forEach(error => error.remove());
    }
}

// 显示表单错误
function showFormError(inputId, message) {
    const input = document.getElementById(inputId);
    if (input) {
        input.classList.add('error');
        
        // 移除现有错误消息
        const existingError = input.parentNode.querySelector('.error-message');
        if (existingError) {
            existingError.remove();
        }
        
        // 添加新错误消息
        const errorDiv = document.createElement('div');
        errorDiv.className = 'error-message';
        errorDiv.textContent = message;
        errorDiv.style.color = '#e74c3c';
        errorDiv.style.fontSize = '0.85rem';
        errorDiv.style.marginTop = '5px';
        
        input.parentNode.appendChild(errorDiv);
    }
}

// 表单提交处理
function initEditProfileForm() {
    const form = document.getElementById('editProfileForm');
    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // 重置错误状态
            resetFormErrors();
            
            // 获取表单数据
            const email = document.getElementById('editEmail').value.trim();
            const phone = document.getElementById('editPhone').value.trim();
            
            // 验证邮箱
            if (!email) {
                showFormError('editEmail', '邮箱不能为空');
                return;
            }
            
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                showFormError('editEmail', '请输入有效的邮箱地址');
                return;
            }
            
            // 验证手机号（可选）
            if (phone && !/^1[3-9]\d{9}$/.test(phone)) {
                showFormError('editPhone', '请输入11位有效手机号');
                return;
            }
            
            // 创建FormData对象
            const formData = new FormData(form);
            
            // 发送AJAX请求
            fetch(form.action, {
                method: 'POST',
                body: formData,
                headers: {
                    'Accept': 'application/json',
                }
            })
            .then(response => {
                if (response.ok) {
                    return response.json();
                } else {
                    throw new Error('服务器响应错误');
                }
            })
            .then(data => {
                if (data.success) {
                    // 成功：关闭模态框并显示成功消息
                    closeEditProfileModal();
                    showSuccessMessage(data.message || '个人信息更新成功');
                    
                    // 延迟刷新页面以显示更新后的信息
                    setTimeout(() => {
                        window.location.reload();
                    }, 1500);
                } else {
                    // 失败：显示错误消息
                    showFormError('editEmail', data.message || '更新失败，请重试');
                }
            })
            .catch(error => {
                console.error('更新个人信息失败:', error);
                showFormError('editEmail', '网络错误，请重试');
            });
        });
    }
}

// 显示成功消息
function showSuccessMessage(message) {
    // 创建成功消息提示
    const successDiv = document.createElement('div');
    successDiv.className = 'success-message';
    successDiv.innerHTML = `
        <div style="
            position: fixed;
            top: 20px;
            right: 20px;
            background: #28a745;
            color: white;
            padding: 15px 20px;
            border-radius: 8px;
            box-shadow: 0 5px 15px rgba(40, 167, 69, 0.3);
            z-index: 1100;
            display: flex;
            align-items: center;
            gap: 10px;
        ">
            <i class="fas fa-check-circle"></i>
            <span>${message}</span>
        </div>
    `;
    
    document.body.appendChild(successDiv);
    
    // 3秒后自动移除
    setTimeout(() => {
        successDiv.remove();
    }, 3000);
}

// 点击模态框外部关闭
function initModalCloseOnOutsideClick() {
    const modal = document.getElementById('editProfileModal');
    if (modal) {
        modal.addEventListener('click', function(e) {
            if (e.target === this) {
                closeEditProfileModal();
            }
        });
    }
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
    // 初始化编辑表单
    initEditProfileForm();
    
    // 初始化模态框外部点击关闭
    initModalCloseOnOutsideClick();
    
    // 监听ESC键关闭模态框
    document.addEventListener('keydown', function(e) {
        const modal = document.getElementById('editProfileModal');
        if (modal && modal.classList.contains('active') && e.key === 'Escape') {
            closeEditProfileModal();
        }
    });
});
