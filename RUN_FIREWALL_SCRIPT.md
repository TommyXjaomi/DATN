# ✅ HƯỚNG DẪN CHẠY SCRIPT (FIXED)

## 🔧 File script đã được sửa lại

**File:** `open-firewall-ports.ps1`  
**Status:** ✅ Syntax chính xác, sẵn sàng chạy

---

## 🚀 CÁCH CHẠY

### **Step 1: Mở PowerShell as ADMINISTRATOR**

1. Nhấn **Windows key** (⊞)
2. Gõ: `powershell`
3. Khi thấy **Windows PowerShell**, nhấp chuột phải
4. Chọn **"Run as Administrator"**

### **Step 2: Chạy Script**

Trong PowerShell Administrator, chạy lệnh:

```powershell
cd D:\nam4_2025\DATN
.\open-firewall-ports.ps1
```

### **Step 3: Xác Nhận**

Script sẽ:
- ✅ Mở port 8080 (API Gateway)
- ✅ Mở port 8081 (Auth Service)
- ✅ Mở port 8082-8087 (Services khác)
- ✅ Mở port 3000 (Frontend)
- ✅ Mở port databases & tools

Output sẽ như thế này:

```
Opening Windows Firewall for Docker Services...

Opening port 8080 for API Gateway...
  [OK] Port 8080 opened
Opening port 8081 for Auth Service...
  [OK] Port 8081 opened
...
Firewall configuration complete!

Opened ports:
  [+] Port 8080 - API Gateway
  [+] Port 8081 - Auth Service
  ...

You can now connect from tablet:
  Frontend: http://10.20.4.99:3000
  API: http://10.20.4.99:8080
```

---

## 📱 Sau Đó Test Trên Tablet

**Mở Browser và truy cập:**
```
http://10.20.4.99:3000
```

**Expected Result:**
- ✅ IELTS Platform login page hiển thị
- ✅ Không có toast error "Failed to connect"
- ✅ Có thể đăng nhập thành công

---

## 🆘 Nếu Gặp Lỗi

### "Access is denied"
- Chắc chắn chạy PowerShell **as Administrator**
- Click "Yes" khi được hỏi UAC

### Script vẫn không chạy
```powershell
# Tạm cho phép chạy script
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Chạy lại
.\open-firewall-ports.ps1
```

---

## ✅ Checklist

- [ ] Mở PowerShell as Administrator
- [ ] Chạy script `open-firewall-ports.ps1`
- [ ] Xem output "Firewall configuration complete!"
- [ ] Test trên tablet: http://10.20.4.99:3000
- [ ] Login thành công (không có error)

---

**✨ Xong! Tablet sẽ kết nối được ngay**

