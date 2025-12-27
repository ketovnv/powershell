$configPath = "C:\Users\ketov\Scoop\apps\redis\current\redis.conf"

Write-Host "`n=== Порт и Bind ===" -ForegroundColor Cyan
Get-Content $configPath | Select-String -Pattern "^port|^bind"

Write-Host "`n=== Проверка процессов ===" -ForegroundColor Cyan
Get-Process | Where-Object { $_.ProcessName -like "*redis*" }

Write-Host "`n=== Проверка порта 6379 ===" -ForegroundColor Cyan
netstat -ano | findstr ":6379"

Write-Host "`n=== Запуск Redis с логами ===" -ForegroundColor Yellow
Write-Host "Сейчас запущу Redis, смотри на вывод..." -ForegroundColor Green
redis-server.exe --loglevel verbose --logfile "C:\Users\ketov\Scoop\apps\redis\current\redis.log"`"`"
