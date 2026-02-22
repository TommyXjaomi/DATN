# 📱 HƯỚNG DẪN KẾT NỐI TỪ TABLET/ĐIỆN THOẠI BÊN NGOÀI

## 🌐 **THÔNG TIN KẾT NỐI**

### **Địa Chỉ IP Máy Tính**

| Loại Kết Nối | IP Address | Dùng Khi |
|------------|-----------|---------|
| **Wi-Fi (Khuyên Dùng)** | `10.20.4.99` | Tablet/Phone cùng Wi-Fi |
| **Radmin VPN** | `26.234.197.58` | Kết nối từ xa (VPN) |
| **Hostname** | `TranDucNguyenB21DCVT333` | DNS/mDNS resolution |

---

## ✅ **CÁCH 1: KẾT NỐI QUA WI-FI (TRÊ VÀO MẠNG CÙNG MÁY TÍNH)**

### **Bước 1: Đảm Bảo Cùng Mạng Wi-Fi**
✔️ Máy tính: Kết nối Wi-Fi `10.20.4.99`  
✔️ Tablet/Phone: Kết nối cùng Wi-Fi network

### **Bước 2: Truy Cập Ứng Dụng**

**Frontend (Next.js):**
```
http://10.20.4.99:3000
```

**API Gateway:**
```
http://10.20.4.99:8080
```

**PgAdmin (Quản lý Database):**
```
http://10.20.4.99:5050
```

**MinIO (Storage):**
```
http://10.20.4.99:9000
```

**RabbitMQ Management:**
```
http://10.20.4.99:15672
```

### **Bước 3: Test Kết Nối**

**Tablet/Phone (trên cùng Wi-Fi):**
```bash
# Test API Gateway
curl http://10.20.4.99:8080/health

# Test Frontend
ping 10.20.4.99
```

---

## 🔒 **CÁCH 2: KẾT NỐI QUA VPN (TỪ XA)**

### **Bước 1: Cài Đặt Radmin VPN**
- 📥 Tải: https://www.radmin-vpn.com
- ✅ Cài đặt & tạo tài khoản

### **Bước 2: Tham Gia VPN**
- Radmin VPN ID: `TranDucNguyenB21DCVT333`
- IP trong VPN: `26.234.197.58`

### **Bước 3: Truy Cập**
```
http://26.234.197.58:3000   (Frontend)
http://26.234.197.58:8080   (API)
```

---

## 📋 **TẤT CẢ PORT KHẢ DỤNG**

| Port | Service | URL | Trạng Thái |
|------|---------|-----|-----------|
| **3000** | Frontend (Next.js) | http://10.20.4.99:3000 | ✅ |
| **5050** | PgAdmin | http://10.20.4.99:5050 | ✅ |
| **5432** | PostgreSQL | 10.20.4.99:5432 | ✅ (DB Direct) |
| **6379** | Redis | 10.20.4.99:6379 | ✅ (Cache) |
| **8080** | API Gateway | http://10.20.4.99:8080 | ✅ |
| **8081** | Auth Service | http://10.20.4.99:8081 | ✅ |
| **8082** | User Service | http://10.20.4.99:8082 | ✅ |
| **8083** | Course Service | http://10.20.4.99:8083 | ✅ |
| **8084** | Exercise Service | http://10.20.4.99:8084 | ✅ |
| **8085** | AI Service | http://10.20.4.99:8085 | ✅ |
| **8086** | Notification Service | http://10.20.4.99:8086 | ✅ |
| **8087** | Storage Service | http://10.20.4.99:8087 | ✅ |
| **9000** | MinIO (Storage) | http://10.20.4.99:9000 | ✅ |
| **9001** | MinIO Console | http://10.20.4.99:9001 | ✅ |
| **15672** | RabbitMQ Management | http://10.20.4.99:15672 | ✅ |

---

## 🧪 **TEST KẾT NỐI**

### **1. Test Health Check API**
```bash
curl http://10.20.4.99:8080/health
```

**Response (nếu thành công):**
```json
{
  "status": "healthy",
  "service": "api-gateway",
  "version": "1.0.0"
}
```

### **2. Test Login**
```bash
curl -X POST http://10.20.4.99:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email":"admin@ieltsplatform.com",
    "password":"password123"
  }'
```

### **3. Test Frontend (Browser)**
```
http://10.20.4.99:3000
```
Bạn sẽ thấy trang login IELTS Platform

---

## 🔐 **TÀI KHOẢN TEST**

| Email | Password | Role |
|-------|----------|------|
| admin@ieltsplatform.com | password123 | ADMIN ⭐ |
| instructor1@ieltsplatform.com | password123 | INSTRUCTOR |
| student1@ieltsplatform.com | password123 | STUDENT |

---

## ⚠️ **FIREWALL CONFIGURATION (NẾUSTK)**

Nếu bạn không thể truy cập, cần mở Firewall:

### **Windows Defender Firewall**
```powershell
# Allow port 3000 (Frontend)
New-NetFirewallRule -DisplayName "Allow Frontend 3000" `
  -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3000

# Allow port 8080 (API Gateway)
New-NetFirewallRule -DisplayName "Allow API Gateway 8080" `
  -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8080

# Allow all Docker ports
New-NetFirewallRule -DisplayName "Allow Docker Services" `
  -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8081-8087
```

### **Or Disable Firewall (Không An Toàn - Chỉ Dùng Local)**
```powershell
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled $false
```

---

## 📱 **ANDROID APP CONFIGURATION**

Nếu bạn muốn test Android App từ khác device:

### **File: `android/app/src/main/res/values/strings.xml`**
```xml
<string name="api_base_url">http://10.20.4.99:8080</string>
```

### **Hoặc Runtime (SharedPreferences):**
```kotlin
val prefs = context.getSharedPreferences("config", Context.MODE_PRIVATE)
prefs.edit().putString("api_url", "http://10.20.4.99:8080").apply()
```

### **Test từ Android Emulator/Device:**
```bash
# Nếu dùng emulator, cần map từ 10.0.2.2 (default gateway)
# Nhưng với tablet thực → dùng 10.20.4.99 trực tiếp
```

---

## 🌟 **QUICK REFERENCE**

### **Truy Cập Nhanh**
```
📱 Frontend: http://10.20.4.99:3000
🔌 API: http://10.20.4.99:8080
💾 Database Admin: http://10.20.4.99:5050
📦 Storage: http://10.20.4.99:9000
📨 Message Queue: http://10.20.4.99:15672
```

### **Đăng Nhập**
```
Email: admin@ieltsplatform.com
Password: password123
Role: ADMIN
```

### **Device Tương Thích**
- ✅ Tablet (iOS/Android)
- ✅ Smartphone
- ✅ Laptop/PC trên mạng
- ✅ Remote device (qua VPN)

---

## 🐛 **TROUBLESHOOTING**

### **Vấn Đề: "Không thể kết nối"**

**Kiểm tra:**
1. Tablet & PC cùng Wi-Fi chưa? 
   ```bash
   # Trên tablet
   ping 10.20.4.99
   ```

2. Docker services chạy chưa?
   ```bash
   docker ps | grep -E "api-gateway|frontend"
   ```

3. Firewall có chặn không?
   - Disable Windows Defender Firewall (test) 
   - Hoặc thêm firewall rules

4. IP có thay đổi không?
   - Nếu IP thay đổi → dùng hostname:
   ```
   http://TranDucNguyenB21DCVT333:3000
   ```

### **Vấn Đề: "Slow Connection"**
- Kiểm tra Wi-Fi signal strength
- Restart Docker services
- Clear browser cache

---

## 📌 **GỢI Ý**

**Dùng Hostname để Tránh Thay Đổi IP:**
```
http://TranDucNguyenB21DCVT333:3000
```

Nếu không work → cần cấu hình mDNS hoặc hosts file trên tablet.

---

**✅ Sẵn sàng! Truy cập từ tablet ngay với IP: `10.20.4.99`**

