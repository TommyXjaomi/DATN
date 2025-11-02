# 📸 Hướng dẫn Copy Screenshots

Các ảnh screenshot được lưu tạm trong thư mục của browser extension, sau đó được copy vào thư mục `screenshots/` trong project.

## 📍 Vị trí lưu ảnh

Tất cả ảnh được lưu trong: `Frontend-IELTSGo/screenshots/`

## 🔄 Quy trình tự động

1. Browser extension chụp ảnh → lưu vào temp folder
2. Script tự động copy vào `screenshots/` với cấu trúc:
   ```
   screenshots/
   ├── 01-public/
   ├── 02-dashboard/
   ├── 03-courses/
   ├── 04-exercises/
   ├── 05-progress/
   ├── 06-tools/
   ├── 07-social/
   └── 08-profile/
   ```

## ✅ Kiểm tra ảnh đã chụp

```bash
cd Frontend-IELTSGo
find screenshots -name "*.png" | sort
```

## 📝 Naming Convention

Format: `[number]_[section]_[page]_[description].png`

Ví dụ:
- `01_homepage_logged_out.png`
- `02_register_form.png`
- `03_login_form.png`
- `01_dashboard_overview.png`

