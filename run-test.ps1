Write-Host "Running markdownlint auto-fix..." -ForegroundColor Cyan
npx markdownlint-cli2 --fix "**/*.md"

Write-Host "Starting Jekyll local server..." -ForegroundColor Green
bundle exec jekyll serve --livereload
