# Jamesockenden.github.io

## Welcome

This repo holds articles created when I have time. Its use is just to share with others, my learnings, and experience in the hope that it may be useful, interesting or just entertaining.

## Sections

Posts belongs to one of the following sections:

- `engineering-lead`
- `dad-and-husband`
- `myself`

`Note to self` section and section permalinks should be added to new posts:

```yaml
---
layout: post
title: "Article title"
date: 2026-09-13 09:00:00 +0000
section: engineering-lead
permalink: /engineering-lead/article-title/
categories: [Optional, Technical, Categories]
tags: [optional, discovery, tags]
---
```

The `section` value controls the section landing page and homepage grouping. Technical `categories` and `tags` remain separate metadata for article classification and discovery.

## Pre-publish checks

Install the Linux Ruby toolchain in WSL once:

```powershell
wsl -d Debian -- sudo apt update
wsl -d Debian -- sudo apt install -y ruby-full ruby-bundler build-essential
```

Run the checks from PowerShell before publishing:

```powershell
.\run-checks-wsl.ps1
```

The script runs markdownlint, a strict Jekyll build, and HTMLProofer against the generated `_site` directory. Use `-Distro` if your WSL distribution has a different name.
