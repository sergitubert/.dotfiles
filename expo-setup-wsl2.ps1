# ==============================================================================
# setup-expo-wsl2.ps1
# Sets up Windows networking so Expo (React Native) works from WSL2 on LAN.
# Run this as Administrator after a fresh Windows install.
# ==============================================================================

#Requires -RunAsAdministrator

$ExpoPortS = @(8081, 8082, 8083, 8084, 8085, 19000, 19001, 19002, 19003)
$FirewallRuleName = "Expo WSL2 Dev Server"

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Expo + WSL2 Network Setup Script  " -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------------------------
# 1. Set WiFi network profile to Private
# ------------------------------------------------------------------------------
Write-Host "[1/4] Setting WiFi network profile to Private..." -ForegroundColor Yellow

$wifiAdapter = Get-NetConnectionProfile | Where-Object { $_.InterfaceAlias -like "*Wi*Fi*" -or $_.InterfaceAlias -like "*WiFi*" -or $_.InterfaceAlias -like "*Wireless*" }

if ($wifiAdapter) {
    Set-NetConnectionProfile -InterfaceAlias $wifiAdapter.InterfaceAlias -NetworkCategory Private
    Write-Host "      OK — '$($wifiAdapter.InterfaceAlias)' set to Private" -ForegroundColor Green
} else {
    Write-Host "      WARN — No WiFi adapter found. Connect to WiFi first and re-run, or set manually." -ForegroundColor Red
}

# ------------------------------------------------------------------------------
# 2. Ensure IP Helper service is running (required for portproxy)
# ------------------------------------------------------------------------------
Write-Host "[2/4] Ensuring IP Helper service (iphlpsvc) is running..." -ForegroundColor Yellow

$iphlpsvc = Get-Service -Name iphlpsvc
if ($iphlpsvc.StartType -eq "Disabled") {
    Set-Service iphlpsvc -StartupType Automatic
}
if ($iphlpsvc.Status -ne "Running") {
    Start-Service iphlpsvc
}
Restart-Service iphlpsvc
Write-Host "      OK — IP Helper service is running" -ForegroundColor Green

# ------------------------------------------------------------------------------
# 3. Set up portproxy rules (0.0.0.0 -> 127.0.0.1 for each Expo port)
# ------------------------------------------------------------------------------
Write-Host "[3/4] Adding portproxy rules for Expo ports..." -ForegroundColor Yellow

# Clear any existing rules for these ports first to avoid duplicates
foreach ($port in $ExpoPorts) {
    netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=$port 2>$null
}

foreach ($port in $ExpoPorts) {
    netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=$port connectaddress=127.0.0.1 connectport=$port
    Write-Host "      OK — portproxy 0.0.0.0:$port -> 127.0.0.1:$port" -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 4. Add Windows Firewall inbound rule
# ------------------------------------------------------------------------------
Write-Host "[4/4] Adding Windows Firewall inbound rule..." -ForegroundColor Yellow

# Remove existing rule with the same name to avoid duplicates
$existing = Get-NetFirewallRule -DisplayName $FirewallRuleName -ErrorAction SilentlyContinue
if ($existing) {
    Remove-NetFirewallRule -DisplayName $FirewallRuleName
    Write-Host "      Removed old firewall rule" -ForegroundColor Gray
}

New-NetFirewallRule `
    -DisplayName $FirewallRuleName `
    -Direction Inbound `
    -Action Allow `
    -Protocol TCP `
    -LocalPort $ExpoPorts `
    -Profile Private `
    | Out-Null

Write-Host "      OK — Firewall rule added for ports $($ExpoPorts -join ', ') (Private profile)" -ForegroundColor Green

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  All done! Verifying setup...       " -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Portproxy rules:" -ForegroundColor White
netsh interface portproxy show all

Write-Host ""
Write-Host "Firewall rule:" -ForegroundColor White
Get-NetFirewallRule -DisplayName $FirewallRuleName | Select-Object DisplayName, Enabled, Profile, Direction, Action | Format-Table

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Make sure your .wslconfig has:  networkingMode=mirrored"
Write-Host "  2. Run: wsl --shutdown  (then reopen WSL)"
Write-Host "  3. Run: npx expo start --host lan"
Write-Host "  4. Scan the QR code with Expo Go"
Write-Host ""
