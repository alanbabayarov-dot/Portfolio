# dev-share.ps1 — запустить / остановить локальную трансляцию портфолио

$port = 7654
$root = $PSScriptRoot

# ── Найти локальный IP ─────────────────────────────────────────
$ip = (Get-NetIPAddress -AddressFamily IPv4 |
       Where-Object { $_.IPAddress -notmatch '^127\.' -and $_.PrefixOrigin -ne 'WellKnown' } |
       Select-Object -First 1).IPAddress

# ── Проверить, запущен ли уже сервер ──────────────────────────
$running = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue

if($running){
    # ── СТОП ──────────────────────────────────────────────────
    Write-Host ""
    Write-Host "  Stopping dev server on :$port..." -ForegroundColor Yellow
    $pids = (Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue).OwningProcess | Sort-Object -Unique
    foreach($p in $pids){ Stop-Process -Id $p -Force -ErrorAction SilentlyContinue }
    Write-Host "  Stopped." -ForegroundColor Red
    Write-Host ""
} else {
    # ── СТАРТ ─────────────────────────────────────────────────
    Write-Host ""
    Write-Host "  Starting dev server..." -ForegroundColor Cyan
    Start-Process python -ArgumentList "-m", "http.server", $port -WorkingDirectory $root -WindowStyle Hidden
    Start-Sleep -Milliseconds 800

    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║                                          ║" -ForegroundColor Green
    Write-Host "  ║   http://$ip`:$port          ║" -ForegroundColor Green
    Write-Host "  ║                                          ║" -ForegroundColor Green
    Write-Host "  ║   Открой с телефона (тот же Wi-Fi)       ║" -ForegroundColor Green
    Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Запусти скрипт ещё раз чтобы остановить." -ForegroundColor DarkGray
    Write-Host ""
}
