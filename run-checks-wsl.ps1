param(
  [string]$Distro = "Debian"
)

$ErrorActionPreference = "Stop"

Write-Host "Running markdownlint..." -ForegroundColor Cyan
npx markdownlint-cli2 "**/*.md"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if (-not (wsl.exe -l -q | Where-Object { $_.Trim() -eq $Distro })) {
    Write-Error "WSL distribution '$Distro' was not found. Run 'wsl -l -q' to list available distributions."
    exit 1
}

$windowsPath = (Get-Location).Path
$linuxPath = "/mnt/" + $windowsPath.Substring(0, 1).ToLower() + $windowsPath.Substring(2).Replace("\", "/")
$wslCommand = @"
set -e
if ! ruby --version >/dev/null 2>&1 || ! bundle --version >/dev/null 2>&1; then
  echo "Ruby and Bundler are required inside WSL. Install them with:"
  echo "  sudo apt update && sudo apt install -y ruby-full ruby-bundler build-essential"
  exit 1
fi
cd '$linuxPath'
bundle install --jobs 4
bundle exec jekyll build --strict
bundle exec htmlproofer ./_site --disable-external
"@
$wslCommand = $wslCommand -replace "`r`n", "`n"

Write-Host "Running Jekyll and HTMLProofer in WSL ($Distro)..." -ForegroundColor Green
wsl.exe -d $Distro bash -lc $wslCommand
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "All pre-publish checks passed." -ForegroundColor Green
