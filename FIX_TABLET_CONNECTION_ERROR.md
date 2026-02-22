# 🔴 LỖI KẾT NỐI TABLET: "Failed to connect to /10.20.4.99:8081"

## 🎯 **Nguyên Nhân & Giải Pháp**

### **Nguyên Nhân Chính: Windows Firewall Chặn**

❌ **Hiện Tại:** Firewall bật (Domain, Private, Public = Enabled)  
✅ **Cần:** Mở port 8081 (và các port khác) trong Firewall

---

## ✅ **GIẢI PHÁP**

### **Bước 1: Chạy Script Mở Firewall**

**Yêu cầu:** PowerShell với quyền **ADMIN**

```powershell
# 1. Mở PowerShell AS ADMINISTRATOR
# Click Windows Start → PowerShell → Run as Administrator

# 2. Chạy script
cd D:\nam4_2025\DATN
.\open-firewall-ports.ps1
```

**Script sẽ mở các port:**
- ✅ 8080 (API Gateway)
- ✅ 8081 (Auth Service)
- ✅ 8082 (User Service)
- ✅ 8083 (Course Service)
- ✅ 8084 (Exercise Service)
- ✅ 8085 (AI Service)
- ✅ 8086 (Notification Service)
- ✅ 8087 (Storage Service)
- ✅ 3000 (Frontend)
- ✅ 5050 (PgAdmin)
- ✅ 5432 (PostgreSQL)
- ✅ 6379 (Redis)
- ✅ 9000, 9001 (MinIO)
- ✅ 15672 (RabbitMQ)

### **Bước 2: Test Kết Nối Lại**

**Trên Tablet (cùng Wi-Fi):**
```bash
ping 10.20.4.99
curl http://10.20.4.99:8080/health
curl http://10.20.4.99:3000
```

**Hoặc mở Browser:**
```
http://10.20.4.99:3000
```

---

## 🔧 **CÁCH THỦ CÔNG (Nếu Script Không Work)**

### **Mở Firewall Thủ Công qua GUI**

1. **Windows Security** (Ctrl + X → Windows Security)
2. **Firewall & network protection**
3. **Allow an app through firewall**
4. **Change settings** (cần ADMIN)
5. **Allow another app** → Browse → `C:\Program Files\Docker\Docker\resources\docker.exe`
6. **Add** → **Allow**

---

## 🆘 **TROUBLESHOOTING**

### **Vấn Đề 1: "Access is Denied" khi chạy script**

**Giải pháp:** Chạy PowerShell as Administrator
```powershell
# Right-click PowerShell → Run as Administrator
```

### **Vấn Đề 2: Vẫn không kết nối sau mở Firewall**

**Kiểm tra:**
```powershell
# Xem firewall rules
Get-NetFirewallRule -DisplayName "*8081*" | Format-Table DisplayName, Enabled, Direction

# Kiểm tra port listening
netstat -ano | Select-String "8081"

# Kiểm tra Docker service
docker ps | Where-Object {$_ -match "auth-service"}
```

### **Vấn Đề 3: Chỉ port 8080 work, 8081 không work**

**Có thể App đang cố kết nối trực tiếp đến Auth Service (sai)**

**Fix:** App phải luôn qua API Gateway:
```
❌ Sخطأ: http://10.20.4.99:8081/api/v1/auth/login
✅ ĐÚNG: http://10.20.4.99:8080/api/v1/auth/login
```

Kiểm tra trong code:
- Android: `BuildConfig.BASE_URL` or `SharedPreferences`
- Frontend: `.env.local` → `NEXT_PUBLIC_API_URL`

---

## 📋 **CURRENT FIREWALL STATUS**

```
Profile Status:
- Domain:   Enabled ✅ (cần mở port)
- Private:  Enabled ✅ (cần mở port)
- Public:   Enabled ✅ (cần mở port)

Docker Services Listening:
- 8081:     LISTENING (Auth Service)
- 8080:     LISTENING (API Gateway)
- 3000:     LISTENING (Frontend)
```

---

## 🚀 **EXPECTED RESULT AFTER FIX**

**Tablet trên cùng Wi-Fi (10.20.4.99):**

```
Before (❌ Lỗi):
Toast: "Failed to connect to /10.20.4.99:8081"

After (✅ Thành Công):
Status 200 OK
Login Response with Token
Admin button appears
```

---

## 📱 **URL TABLET CONNECT**

Sau khi fix Firewall:

```
Frontend:    http://10.20.4.99:3000
API Gateway: http://10.20.4.99:8080
```

**NOT:**
```
❌ http://10.20.4.99:8081 (direct to auth service - avoid)
```

---

## ⚡ **QUICK FIX CHECKLIST**

- [ ] 1. Chạy `open-firewall-ports.ps1` as Administrator
- [ ] 2. Xác nhận script completed successfully
- [ ] 3. Restart App trên Tablet
- [ ] 4. Test login lại
- [ ] 5. Xem admin button hiển thị

---

## 📞 **NẾU VẪN LỖI**

```powershell
# Check logs
docker logs -f ielts_auth_service

# Check network connectivity
Test-NetConnection -ComputerName 10.20.4.99 -Port 8081

# Restart Docker
docker-compose restart

# Restart Firewall Service
Restart-Service MpsSvc
```

---

**✅ Sau khi mở Firewall → Tablet sẽ kết nối được!**

