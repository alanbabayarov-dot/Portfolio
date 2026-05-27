#Requires -Version 5.1
# build-export.ps1 — produce standalone HTML exports for desktop and mobile

$ErrorActionPreference = 'Stop'
$root  = $PSScriptRoot
$outDir = Join-Path $root "export"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$html = [IO.File]::ReadAllText((Join-Path $root "Portfolio v6.html"), [Text.Encoding]::UTF8)

# ── 1. Embed images ────────────────────────────────────────────
Write-Host "Embedding images..."
foreach($img in (Get-ChildItem (Join-Path $root "assets") -Filter "*.jpg")){
    $bytes = [IO.File]::ReadAllBytes($img.FullName)
    $b64   = [Convert]::ToBase64String($bytes)
    $html  = $html.Replace("assets/$($img.Name)", "data:image/jpeg;base64,$b64")
}

# ── 2. Fetch & inline Google Fonts ────────────────────────────
Write-Host "Fetching Google Fonts CSS..."
$fontsUrl = "https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,500;0,600;0,700;1,300;1,400;1,500;1,600;1,700&family=Bebas+Neue&family=Special+Elite&family=JetBrains+Mono:wght@300;400;500&family=Bowlby+One+SC&display=swap"

$wc = New-Object System.Net.WebClient
$wc.Headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"
$fontsCss = $wc.DownloadString($fontsUrl)

Write-Host "Embedding font files..."
$fontUrls = [regex]::Matches($fontsCss, "url\((https://fonts\.gstatic\.com/[^)]+)\)") |
            ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
$cache = @{}
foreach($url in $fontUrls){
    try{
        $bytes = $wc.DownloadData($url)
        $b64   = [Convert]::ToBase64String($bytes)
        $ext   = if($url -match '\.woff2$'){'woff2'} elseif($url -match '\.woff$'){'woff'} else{'truetype'}
        $cache[$url] = "data:font/$ext;base64,$b64"
        Write-Host "  ok $($url.Split('/')[-1])"
    } catch {
        Write-Warning "  skip $url"
    }
}
foreach($url in $cache.Keys){
    $fontsCss = $fontsCss.Replace("url($url)", "url($($cache[$url]))")
}

# Replace the three <link> font tags with an inline <style>
$linkPattern = '(?s)<link rel="preconnect" href="https://fonts\.googleapis\.com">.*?<link href="https://fonts\.googleapis\.com[^"]*" rel="stylesheet">'
$inlineFonts = "<style>`n/* Google Fonts inlined for offline use */`n$fontsCss`n</style>"
$html = [regex]::Replace($html, $linkPattern, $inlineFonts)

# ── 3. Strip tweaks dev panel ─────────────────────────────────
Write-Host "Removing tweaks panel..."
$marker = "<!-- ═══ TWEAKS ═══"
$idx = $html.IndexOf($marker)
if($idx -gt 0){
    $html = $html.Substring(0, $idx).TrimEnd() + "`n`n</body>`n</html>`n"
}

# ── 4. Desktop export ─────────────────────────────────────────
Write-Host "Writing desktop export..."
$desktopPath = Join-Path $outDir "portfolio-desktop.html"
[IO.File]::WriteAllText($desktopPath, $html, [Text.Encoding]::UTF8)

# ── 5. Mobile export ──────────────────────────────────────────
Write-Host "Writing mobile export..."
$mobileMeta = @"
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="mobile-web-app-capable" content="yes">
<meta name="format-detection" content="telephone=no">
"@
$mobileHtml = $html -replace '(<meta charset="UTF-8">)', "`$1`n$mobileMeta"
$mobilePath = Join-Path $outDir "portfolio-mobile.html"
[IO.File]::WriteAllText($mobilePath, $mobileHtml, [Text.Encoding]::UTF8)

# ── Summary ───────────────────────────────────────────────────
$dkb = [Math]::Round((Get-Item $desktopPath).Length / 1KB)
$mkb = [Math]::Round((Get-Item $mobilePath).Length  / 1KB)
Write-Host ""
Write-Host "Export complete." -ForegroundColor Green
Write-Host "  Desktop : export/portfolio-desktop.html  ($dkb KB)"
Write-Host "  Mobile  : export/portfolio-mobile.html   ($mkb KB)"
