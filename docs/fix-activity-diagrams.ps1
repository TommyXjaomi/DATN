# Script để sửa lỗi syntax trong các file activity diagram
# Chạy script này sau khi đóng tất cả các file .puml trong IDE

$files = @(
    "activity-enrollment.puml",
    "activity-learn-lesson.puml",
    "activity-submit-writing.puml",
    "activity-submit-speaking.puml"
)

foreach ($file in $files) {
    Write-Host "Đang sửa file: $file"
    
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Sửa ||# thành |#
        $content = $content -replace '\|\|#', '|#'
        
        # Đảm bảo có @startuml và left to right direction
        if ($content -notmatch '@startuml') {
            Write-Host "  Cảnh báo: File $file thiếu @startuml"
        }
        
        if ($content -notmatch 'left to right direction') {
            $content = $content -replace '@startuml', "@startuml`nleft to right direction"
        }
        
        Set-Content $file -Value $content -NoNewline
        Write-Host "  ✓ Đã sửa file: $file"
    } else {
        Write-Host "  ✗ Không tìm thấy file: $file"
    }
}

Write-Host "`nHoàn thành! Tất cả các file đã được sửa."

