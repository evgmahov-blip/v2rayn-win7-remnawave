Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'

function Write-Header([string]$Name) { Write-Host ('#################### НАЧАЛО ВЫВОДА: ' + $Name + ' ####################') }
function Write-Footer([string]$Name) { Write-Host ('#################### КОНЕЦ ВЫВОДА: ' + $Name + ' ####################') }
function Enable-Tls12 { try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072 } catch {} }
function New-WebClient {
    Enable-Tls12
    $wc = New-Object Net.WebClient
    $wc.Headers.Add('User-Agent','v2rayn-win7-remnawave')
    return $wc
}
function Download-File([string]$Url,[string]$Path) {
    $wc = New-WebClient
    try { $wc.DownloadFile($Url,$Path) } finally { $wc.Dispose() }
}
function Get-Text([string]$Url) {
    $wc = New-WebClient
    try { return $wc.DownloadString($Url) } finally { $wc.Dispose() }
}
function ConvertFrom-JsonCompat([string]$Json) {
    Add-Type -AssemblyName System.Web.Extensions
    $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
    $ser.MaxJsonLength = 67108864
    return $ser.DeserializeObject($Json)
}
function Expand-ZipCompat([string]$Zip,[string]$Destination) {
    if (Test-Path $Destination) { Remove-Item $Destination -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    $shell = New-Object -ComObject Shell.Application
    $src = $shell.NameSpace($Zip)
    $dst = $shell.NameSpace($Destination)
    if ($src -eq $null -or $dst -eq $null) { throw 'Не удалось открыть ZIP через Shell.Application' }
    $expected = $src.Items().Count
    $dst.CopyHere($src.Items(), 16)
    $deadline = (Get-Date).AddMinutes(5)
    do {
        Start-Sleep -Milliseconds 500
        $count = @(Get-ChildItem $Destination -Recurse -ErrorAction SilentlyContinue).Count
        if ((Get-Date) -gt $deadline) { throw 'Таймаут распаковки ZIP.' }
    } while ($count -lt $expected)
}
function Get-Sha256([string]$Path) {
    $sha = [Security.Cryptography.SHA256]::Create()
    $stream = [IO.File]::OpenRead($Path)
    try {
        $hash = $sha.ComputeHash($stream)
        return ([BitConverter]::ToString($hash)).Replace('-','').ToLowerInvariant()
    } finally { $stream.Dispose(); $sha.Dispose() }
}
function Assert-Win7x64 {
    $os = Get-WmiObject Win32_OperatingSystem
    if ($os.Version -notlike '6.1.*') { throw ('Поддерживается только Windows 7 (6.1.x). Обнаружено: ' + $os.Caption + ' ' + $os.Version) }
    if ($env:PROCESSOR_ARCHITECTURE -ne 'AMD64' -and $env:PROCESSOR_ARCHITEW6432 -ne 'AMD64') { throw 'Поддерживается только Windows 7 x64.' }
}
function Get-LatestXrayWin7Asset {
    $json = Get-Text 'https://api.github.com/repos/XTLS/Xray-core/releases?per_page=20'
    $releases = ConvertFrom-JsonCompat $json
    foreach ($r in $releases) {
        $assets = $r['assets']
        foreach ($a in $assets) {
            if ($a['name'] -eq 'Xray-win7-64.zip') {
                $digest = $null
                if ($a.ContainsKey('digest')) { $digest = $a['digest'] }
                return New-Object PSObject -Property @{ Tag=$r['tag_name']; Url=$a['browser_download_url']; Digest=$digest }
            }
        }
    }
    throw 'В последних релизах XTLS не найден Xray-win7-64.zip. Обычный Windows core использовать не буду.'
}
function Install-XrayWin7([string]$InstallDir) {
    $asset = Get-LatestXrayWin7Asset
    Write-Host ('[INFO] Xray Win7: ' + $asset.Tag)
    $tmp = Join-Path $env:TEMP ('xray-win7-' + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Force -Path $tmp | Out-Null
    try {
        $zip = Join-Path $tmp 'Xray-win7-64.zip'
        Download-File $asset.Url $zip
        if ($asset.Digest -and $asset.Digest.ToString().StartsWith('sha256:')) {
            $expected = $asset.Digest.ToString().Substring(7).ToLowerInvariant()
            $actual = Get-Sha256 $zip
            if ($actual -ne $expected) { throw ('SHA256 Xray не совпал. expected=' + $expected + ' actual=' + $actual) }
            Write-Host '[OK] SHA256 Xray проверен.'
        }
        $unpack = Join-Path $tmp 'xray'
        Expand-ZipCompat $zip $unpack
        $target = Join-Path $InstallDir 'bin\xray'
        New-Item -ItemType Directory -Force -Path $target | Out-Null
        Get-ChildItem $unpack | Where-Object { -not $_.PSIsContainer } | ForEach-Object { Copy-Item $_.FullName (Join-Path $target $_.Name) -Force }
        $exe = Join-Path $target 'xray.exe'
        if (-not (Test-Path $exe)) { throw 'После распаковки xray.exe не найден.' }
        $ver = & $exe version 2>&1 | Select-Object -First 1
        if ($LASTEXITCODE -ne 0) { throw 'Win7 Xray не запускается.' }
        Write-Host ('[OK] ' + $ver)
        Set-Content -Path (Join-Path $InstallDir 'WIN7-XRAY-CORE.txt') -Value ($asset.Tag + "`r`nDO NOT REPLACE WITH Xray-windows-64.zip`r`n") -Encoding ASCII
    } finally { if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue } }
}
