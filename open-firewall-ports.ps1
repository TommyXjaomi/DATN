# Firewall Configuration Script
# Run as Administrator to open Docker ports

Write-Host "Opening Windows Firewall for Docker Services..." -ForegroundColor Cyan
Write-Host ""

# Ports to open
$ports = @(
    @{Port="8080"; Name="API Gateway"},
    @{Port="8081"; Name="Auth Service"},
    @{Port="8082"; Name="User Service"},
    @{Port="8083"; Name="Course Service"},
    @{Port="8084"; Name="Exercise Service"},
    @{Port="8085"; Name="AI Service"},
    @{Port="8086"; Name="Notification Service"},
    @{Port="8087"; Name="Storage Service"},
    @{Port="3000"; Name="Frontend Next.js"},
    @{Port="5050"; Name="PgAdmin"},
    @{Port="5432"; Name="PostgreSQL"},
    @{Port="6379"; Name="Redis"},
    @{Port="9000"; Name="MinIO API"},
    @{Port="9001"; Name="MinIO Console"},
    @{Port="15672"; Name="RabbitMQ Management"}
)

# Open each port
foreach ($item in $ports) {
    $displayName = "Allow Docker - $($item.Name) (Port $($item.Port))"
    
    Write-Host "Opening port $($item.Port) for $($item.Name)..." -ForegroundColor Yellow
    
    try {
        New-NetFirewallRule `
            -DisplayName $displayName `
            -Direction Inbound `
            -Action Allow `
            -Protocol TCP `
            -LocalPort $item.Port `
            -RemoteAddress Any `
            -ErrorAction Stop | Out-Null
        
        Write-Host "  [OK] Port $($item.Port) opened" -ForegroundColor Green
    }
    catch {
        Write-Host "  [ERROR] Port $($item.Port): $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Firewall configuration complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Opened ports:" -ForegroundColor Cyan
foreach ($item in $ports) {
    Write-Host "  [+] Port $($item.Port) - $($item.Name)" -ForegroundColor Green
}

Write-Host ""
Write-Host "You can now connect from tablet:" -ForegroundColor Yellow
Write-Host "  Frontend: http://10.20.4.99:3000" -ForegroundColor Cyan
Write-Host "  API: http://10.20.4.99:8080" -ForegroundColor Cyan
Write-Host ""
