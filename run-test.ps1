Write-Host "Running markdownlint auto-fix..." -ForegroundColor Cyan
npx markdownlint-cli2 --fix "**/*.md"

Write-Host "Building site with strict rules..." -ForegroundColor Green
bundle exec jekyll build --strict
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if (Get-Command wsl -ErrorAction SilentlyContinue) {
	wsl -e true 2>$null
	if ($LASTEXITCODE -eq 0) {
		Write-Host "Syncing site and Gemfile into WSL for HTMLProofer..." -ForegroundColor Green

		$winPath = $PWD.Path
		$driveLetter = $winPath.Substring(0,1).ToLower()
		$restOfPath = $winPath.Substring(2) -replace '\\', '/'
		$wslPath = "/mnt/$driveLetter$restOfPath"

		wsl mkdir -p ~/htmlproofer-check
		wsl rm -rf ~/htmlproofer-check/_site
		wsl cp -r "$wslPath/_site" ~/htmlproofer-check/_site
		wsl cp "$wslPath/Gemfile" ~/htmlproofer-check/
		wsl cp "$wslPath/Gemfile.lock" ~/htmlproofer-check/

		Write-Host "Running HTMLProofer via WSL..." -ForegroundColor Green
		wsl bash -lc "cd ~/htmlproofer-check && bundle install --jobs 4 && bundle exec htmlproofer ./_site --disable-external"
		if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
	} else {
		Write-Error "WSL is installed but not available; HTMLProofer was not run. Make sure WSL is set up and rerun this script."
		exit 1
	}
} else {
	Write-Error "WSL is not installed. HTMLProofer 5 requires libcurl on Windows; install WSL (wsl --install) or run the check in a Linux environment."
	exit 1
}

Write-Host "Local validation passed. Starting Jekyll local server..." -ForegroundColor Green
bundle exec jekyll serve --livereload
