Write-Host "Running markdownlint auto-fix..." -ForegroundColor Cyan
npx markdownlint-cli2 --fix "**/*.md"

Write-Host "Building site with strict rules..." -ForegroundColor Green
bundle exec jekyll build --strict
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if (Get-Command docker -ErrorAction SilentlyContinue) {
	docker info *> $null
	if ($LASTEXITCODE -eq 0) {
		Write-Host "Running HTMLProofer in the CI-compatible Ruby container..." -ForegroundColor Green
		docker run --rm -v "${PWD}:/site" -w /site ruby:3.3 bash -lc "bundle install --jobs 4 && bundle exec htmlproofer ./_site --disable-external"
		if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
	} else {
		Write-Error "Docker is installed but its engine is unavailable; HTMLProofer was not run. Start Docker Desktop and rerun this script."
		exit 1
	}
} else {
	Write-Error "Docker is not installed. HTMLProofer 5 requires libcurl on Windows; install Docker Desktop or run the check in a Linux environment."
	exit 1
}

Write-Host "Local validation passed. Starting Jekyll local server..." -ForegroundColor Green
bundle exec jekyll serve --livereload
