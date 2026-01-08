# Hướng Dẫn Cài Đặt và Chạy Android Emulator cho IELTSGo

## Yêu Cầu Hệ Thống

### Tối Thiểu
- **CPU**: Intel Core i5 hoặc tương đương (hỗ trợ VT-x/AMD-V)
- **RAM**: 8GB (khuyến nghị 16GB)
- **Storage**: 20GB dung lượng trống (cho SDK + emulator)
- **OS**: Windows 10/11, macOS, hoặc Linux

### Tối Ưu
- **CPU**: Intel Core i7+ hoặc AMD Ryzen 7+
- **RAM**: 16GB trở lên
- **Storage**: SSD với 50GB dung lượng trống
- **GPU**: NVIDIA/AMD GPU hỗ trợ hardware acceleration

---

## Bước 1: Cài Đặt Android Studio

### 1.1 Tải Android Studio
1. Truy cập: https://developer.android.com/studio
2. Nhấn **Download Android Studio**
3. Chọn phiên bản cho hệ điều hành của bạn (Windows/Mac/Linux)

### 1.2 Cài Đặt Trên Windows
1. Chạy file `android-studio-*.exe`
2. Làm theo wizard cài đặt (Next → Next)
3. Chọn vị trí cài đặt (mặc định: `C:\Program Files\Android\Android Studio`)
4. Chọn tùy chọn cài đặt:
   - ✓ Android Virtual Device
   - ✓ Android SDK
   - ✓ Android SDK Platform-Tools
5. Hoàn thành cài đặt

### 1.3 Cài Đặt Trên macOS
```bash
brew install android-studio
```

### 1.4 Cài Đặt Trên Linux
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install android-studio

# Fedora
sudo dnf install android-studio
```

---

## Bước 2: Cấu Hình Android SDK

### 2.1 Mở Android Studio
1. Khởi chạy Android Studio
2. Nếu lần đầu tiên, chọn **Do not import settings**
3. Hoàn thành Welcome Wizard

### 2.2 Mở SDK Manager
```
Tools → SDK Manager
```

### 2.3 Cài Đặt SDK Components

#### Platform (Bắt Buộc)
- ✓ Android API 33 (Android 13) - Tối thiểu
- ✓ Android API 34 (Android 14) - Khuyến nghị
- ✓ Android API 35 (Android 15) - Mới nhất

#### Tools
- ✓ Android SDK Tools
- ✓ Android SDK Platform-Tools
- ✓ Android SDK Build-Tools (phiên bản mới nhất)
- ✓ Android Emulator
- ✓ Google USB Driver (chỉ Windows)

#### Extras
- ✓ Google Play services
- ✓ Google USB Driver (Windows)

### 2.4 Kích Hoạt Virtualization
**Windows (VT-x):**
```powershell
# Mở PowerShell as Administrator
Enable-WindowsOptionalFeature -Online -FeatureName Hyper-V
# Hoặc vào BIOS/UEFI: Enable VT-x
```

**macOS (Không cần - mặc định enabled)**

**Linux (KVM):**
```bash
# Ubuntu/Debian
sudo apt-get install qemu-kvm libvirt-daemon libvirt-daemon-system
```

---

## Bước 3: Tạo Android Virtual Device (AVD)

### 3.1 Mở AVD Manager
```
Tools → Device Manager
```

Hoặc nhấn icon **Device Manager** trên thanh công cụ

### 3.2 Tạo Thiết Bị Ảo Mới

#### Option 1: Sử dụng Template Có Sẵn
1. Nhấn **+ Create Virtual Device**
2. Chọn thiết bị (ví dụ: **Pixel 6 Pro**)
3. Nhấn **Next**

#### Option 2: Tùy Chỉnh Chi Tiết
1. **Select Hardware**: Chọn **Pixel 6 Pro** (khuyến nghị)
   - Screen: 6.7" FHD+
   - RAM: 4GB
2. **System Image**: Chọn phiên bản Android
   - API 34 (Android 14) - Khuyến nghị
   - API 33 hoặc cao hơn
3. **Emulated Performance**:
   - Graphics: **Hardware - ANGLE** (nhanh nhất)
   - Boot: Nhanh
4. **Advanced Settings** (Tùy Chọn):
   - Device Frame: ✓ (hiển thị viền điện thoại)
   - Network: NAT (kết nối Internet)
5. Nhấn **Finish**

### 3.3 Cấu Hình Tối Ưu Cho Máy Ảo

Chỉnh sửa file `~/.android/avd/<device_name>/config.ini`:

```ini
# Tăng RAM
hw.ramSize=4096

# Kích hoạt GPU
gpu.enabled=yes
gpu.mode=auto

# Tăng tốc độ
hw.cpu.ncore=4

# Bật QEMU2 (engine tốt hơn)
image.sysdir.1=system-images/android-34/default/x86_64/

# Boot tối ưu
fastboot.forceFastBoot=yes
```

---

## Bước 4: Chạy Android Emulator

### 4.1 Khởi Chạy Emulator

**Cách 1: Từ Android Studio**
1. Mở **Device Manager**
2. Tìm AVD bạn vừa tạo
3. Nhấn icon ▶️ **Play**
4. Chờ emulator khởi động (2-5 phút lần đầu)

**Cách 2: Từ Command Line**

```powershell
# Windows
$ANDROID_SDK_ROOT = "C:\Users\YourUsername\AppData\Local\Android\Sdk"
& "$ANDROID_SDK_ROOT\emulator\emulator.exe" -avd Pixel_6_Pro_API_34
```

```bash
# macOS/Linux
export ANDROID_SDK_ROOT=~/Library/Android/sdk
$ANDROID_SDK_ROOT/emulator/emulator -avd Pixel_6_Pro_API_34
```

### 4.2 Chờ Emulator Sẵn Sàng

Emulator đã khởi động khi:
- ✓ Boot animation kết thúc
- ✓ Lock screen hiển thị
- ✓ Máy tính để bàn Android hiển thị

---

## Bước 5: Chạy IELTSGo Trên Emulator

### 5.1 Mở Project Trong Android Studio
```powershell
cd d:\nam4_2025\DATN\ieltsapp
code .
```

Hoặc từ Android Studio:
```
File → Open → Chọn thư mục ieltsapp
```

### 5.2 Build và Chạy Ứng Dụng

**Cách 1: Sử dụng Android Studio**
1. Chọn emulator từ dropdown **Select Deployment Target**
2. Nhấn **Run** (▶️ icon xanh)
3. Chọn **Pixel_6_Pro_API_34**
4. Chờ build hoàn thành (~1-3 phút)

**Cách 2: Sử dụng Command Line**

```powershell
cd d:\nam4_2025\DATN\ieltsapp

# Build APK
./gradlew.bat assembleDebug

# Chạy trên emulator
adb install -r app\build\outputs\apk\debug\app-debug.apk
adb shell am start -n com.example.ieltsapp/.ui.auth.LoginActivity
```

```bash
# macOS/Linux
cd ~/path/to/ieltsapp

# Build APK
./gradlew assembleDebug

# Chạy trên emulator
adb install -r app/build/outputs/apk/debug/app-debug.apk
adb shell am start -n com.example.ieltsapp/.ui.auth.LoginActivity
```

### 5.3 Xác Nhận Ứng Dụng Chạy
- Ứng dụng sẽ tự động cài đặt trên emulator
- Launch screen IELTSGo sẽ xuất hiện
- Login screen sẽ hiển thị

---

## Troubleshooting (Khắc Phục Sự Cố)

### Vấn Đề: Emulator Chạy Chậm

**Giải Pháp 1: Kích Hoạt Hardware Acceleration**
```powershell
# Check if VT-x is enabled
systeminfo | findstr /I "virtualization"
```

Nếu không kích hoạt:
- Windows: Restart → F2/DEL → BIOS → Enable VT-x
- Khởi động lại và thử lại

**Giải Pháp 2: Giảm RAM/CPU**
```ini
# ~/.android/avd/<device_name>/config.ini
hw.ramSize=2048
hw.cpu.ncore=2
```

### Vấn Đề: Emulator Không Khởi Động

**Giải Pháp 1: Xóa và Tạo Lại**
```powershell
# Liệt kê AVD
emulator -list-avds

# Xóa AVD
emulator -delete-avd Pixel_6_Pro_API_34

# Tạo lại từ Device Manager
```

**Giải Pháp 2: Xóa Cache**
```powershell
# Windows
rmdir /s "%USERPROFILE%\.android\avd\Pixel_6_Pro_API_34\cache"

# macOS/Linux
rm -rf ~/.android/avd/Pixel_6_Pro_API_34/cache
```

### Vấn Đề: ADB Không Nhận Emulator

```powershell
# Khởi động lại ADB server
adb kill-server
adb start-server

# Kiểm tra thiết bị
adb devices
```

### Vấn Đề: Ứng Dụng Không Chạy Trên Emulator

```powershell
# Kiểm tra logs
adb logcat

# Gỡ cài đặt và cài lại
adb uninstall com.example.ieltsapp
adb install -r app\build\outputs\apk\debug\app-debug.apk
```

### Vấn Đề: "INSTALL_FAILED_INSUFFICIENT_STORAGE"

```powershell
# Xóa tệp lớn
adb shell pm trim-caches 100000000

# Hoặc xóa AVD và tạo lại với dung lượng lớn hơn
```

---

## Performance Tips (Mẹo Tối Ưu Hiệu Suất)

### 1. Sử Dụng x86_64 Thay Vì ARM
- x86_64 nhanh hơn 2-3 lần trên Intel/AMD
- Chọn **x86_64** khi tạo AVD

### 2. Kích Hoạt GPU Acceleration
```ini
gpu.enabled=yes
gpu.mode=auto
```

### 3. Sử Dụng Emulator Nhanh Hơn
```powershell
emulator -avd <name> -no-snapshot-save
```

### 4. Tăng Snapshot Boot
- Tạo snapshot: Tools → Device Manager → Settings
- Lần sau sẽ boot từ snapshot (nhanh hơn 10x)

### 5. Giới Hạn Background Apps
```powershell
adb shell pm disable-user com.android.vending
```

---

## Kiểm Tra Kết Nối Internet Trên Emulator

```powershell
# Ping Google DNS
adb shell ping 8.8.8.8

# Kiểm tra IP
adb shell getprop net.change

# Mở Chrome trên emulator
adb shell am start -a android.intent.action.VIEW -d https://www.google.com
```

---

## Cài Đặt Google Play Store (Tùy Chọn)

Nếu muốn cài đặt ứng dụng từ Play Store:

1. **Chọn System Image với Google APIs**
   - Khi tạo AVD, chọn "Google APIs" thay vì "AOSP"
   
2. **Đăng Nhập Google Account**
   - Từ emulator: Settings → Accounts → Add account
   - Email: test@gmail.com (hoặc tài khoản của bạn)

---

## Script Tự Động Hóa (Optional)

Tạo file `run_emulator.ps1` (Windows):

```powershell
# run_emulator.ps1
param(
    [string]$avdName = "Pixel_6_Pro_API_34",
    [string]$appModule = "ieltsapp"
)

Write-Host "Starting emulator: $avdName"
$env:ANDROID_SDK_ROOT = "$env:USERPROFILE\AppData\Local\Android\Sdk"
& "$env:ANDROID_SDK_ROOT\emulator\emulator.exe" -avd $avdName &

Write-Host "Building and running app..."
cd d:\nam4_2025\DATN\ieltsapp
./gradlew.bat installDebug runDebug
```

**Chạy:**
```powershell
.\run_emulator.ps1
```

---

## Tài Liệu Tham Khảo

- [Android Studio Documentation](https://developer.android.com/studio/intro)
- [Android Emulator Documentation](https://developer.android.com/studio/run/emulator)
- [Android Virtual Device (AVD) Configuration](https://developer.android.com/studio/run/managing-avds)
- [Performance Best Practices](https://developer.android.com/studio/run/emulator-acceleration)

---

## Quick Reference (Tham Chiếu Nhanh)

```powershell
# Liệt kê AVD
emulator -list-avds

# Khởi chạy AVD
emulator -avd <name>

# Kiểm tra ADB
adb devices

# Cài đặt APK
adb install -r <path_to_apk>

# Gỡ cài đặt ứng dụng
adb uninstall com.example.ieltsapp

# Xem logs
adb logcat

# Kiểm tra kết nối
adb shell ping 8.8.8.8
```

---

**Tham Khảo Thêm:** [README.md](README.md), [QUICK_START.md](QUICK_START.md)
