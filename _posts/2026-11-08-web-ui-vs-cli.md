---
layout: post
title: "Web UI vs. CLI: The Blurred Lines of AI"
author: "James Ockenden - Engineering Lead"
date: 2026-11-07 08:00:00 +0000
section: engineering-lead
permalink: /engineering-lead/:title/
categories: [Engineering Leadership]
tags: [agentic, cli, copilot, token-efficiency, multi-agent]
---

When talking to people about AI outside the engineering space, it's now quite rare to find someone who isn't using it in some form. Most people's experience, however, is through the browser based chat interface and what is referred to as 'Generative AI'.

When I explain that AI can also call tools, read and modify files, and generate or update code, many of these people assume I'm talking about copying and pasting content from a chat window, or uploading a file through a web interface. What they often haven't encountered is that that AI can operate beyond the chat window itself.

Once you introduce these concepts, local file access, tool calling, and workflow automation, the conversation often moves towards terms like Agent AI and Agentic AI. This is where things can become confusing, because these terms are frequently presented as completely separate categories. However in reality, they increasingly overlap, and much more so today than when AI first became mainstream.

When AI originally appeared in the public spotlight, it was easier to draw distinctions. Generative AI was primarily focused on producing content such as text, code, images, or summaries in response to prompts. Agent based systems, by contrast, were designed to take actions by interacting with tools, files, APIs, and external systems.

As AI technology has evolved, those boundaries have become increasingly blurred. Modern chat interfaces can now search the web, analyse documents, call tools, execute code, interact with external services, and automate workflows. At the same time, agentic systems still rely on the same underlying generative models to reason, communicate, and make decisions.

Rather than viewing Generative AI, Agent AI, and Agentic AI as entirely separate categories, it is more useful to think of them as points along a spectrum of capability:

- **Generative AI** creates content in response to a request.
- **Agent AI** creates content and can use tools to perform actions.
- **Agentic AI** creates content, uses tools, plans actions, reasons across multiple steps, and executes workflows with varying degrees of autonomy.

In practice, many modern AI products combine all three capabilities, which is why the terminology can sometimes feel unclear.

The real difference isn't just the screen you're looking at, it's how much the AI is allowed to do on its own. A browser chat and a terminal tool work differently, but the bigger question is, can it only suggest what to do next, or can it actually carry out the steps itself?

Can it only give you an answer, or can it look at what's happening, make a call, use tools, work with your files, run tasks, and adjust based on what it finds?

While cloud vendors increasingly add tools, integrations, and workflow capabilities to their chat interfaces, and often market these experiences as "agents", there remains an important distinction between an AI that primarily generates responses and one that can independently plan actions, invoke tools, interact with local or remote resources, and execute multi-step tasks on a user's behalf. The line between the two is becoming increasingly blurred, but the underlying capabilities remain meaningfully different.

### 1.  Web UI vs. Local CLI

When a browser chat window (such as Microsoft 365 Copilot in a web session) is equipped with server side tools like web search, document analysis, or a sandboxed runtime, it can feel like an agent. Behind the scenes, it follows a structured loop: plan a step, take an action, observe the result, and respond.

However, where the work happens, and what the tool is allowed to touch makes a major difference in day to day use:

| Dimension | Web Chat Interface (e.g., M365 Copilot) | Terminal CLI Agent (e.g., GitHub Copilot CLI) |
| :--- | :--- | :--- |
| **Where It Runs** | Cloud environment managed by the vendor | Directly on your local machine or target environment |
| **System Access** | Limited to approved connectors, files, and sandboxes | Works with local files, commands, Git, and build tools |
| **Handling Errors** | Often stops and waits for you to copy errors back in | Can run a command, read the error, adjust, and re-test |
| **Context & State** | Mostly tied to the chat session or connected cloud items | Can work across local project files, Git history, and scripts |

In a browser chat, the AI doesn't work directly on your local files, you are still the coordinator. When a step hits an issue or an error appears, things usually pause until you step in, pass text and files back and forth, and decide what to try next.

In the terminal, a local agent works directly on your files inside your workspace. It can run a build or command, read what went wrong on your machine, edit the actual file in place, run the check again, and come back to you once everything passes.

## 2. Copy Paste Issues and Hidden Formatting Bugs

Moving text or code manually between a browser chat and your working environment introduces everyday risks and subtle bugs that are easy to miss.

Even when moving content between a Windows host, a WSL2 environment, or a local folder and a web prompt, a few common issues show up repeatedly:

- **Hidden Formatting & Line Endings:** Differences in line endings (such as Windows vs. Unix style), missing trailing lines, smart quotes, or invisible characters can break strict parsers and formats like Python, YAML, or JSON.
- **Cut Off Output & Context Drift:** Long outputs can get truncated in display boxes or partially missed when selecting text by hand, leaving you to piece things back together.
- **Manual Copy Mistakes:** Skipping a line, shifting indentation in whitespace sensitive files, or forgetting an accompanying file happens easily when doing repetitive transfers by hand.

A local CLI agent avoids much of that manual back and forth by writing changes directly to files on disk, letting you inspect changes cleanly (for example via Git diffs), and checking syntax or tests in place.

## 3. Token Efficiency: Don't Pay AI to Do Basic File Chores

Once you have a capable local agent, it is tempting to ask it to handle every routine file task for you:

- *"Find all log files older than 7 days and rename them with today's date."*
- *"Check every file in this folder to make sure it has a `version` key."*
- *"Pull the second column out of this CSV and sort it."*

An AI *can* do those things, but using it directly for straightforward, repeatable tasks is wasteful. Sending raw file contents or long lists of files through an AI model just to handle predictable sorting, renaming, or text manipulation burns tokens and time on work that does not require AI intelligence.

Instead, it is much better to ask the AI to create a script once, such as a Bash, PowerShell, or Python script, that you can run directly on your machine. You get the AI to do the heavy lifting of writing the logic once, and then your computer runs the script repeatedly with zero AI overhead and cost.

Ultimately, this isn't about abandoning browser chat interfaces or running everything through a terminal. It's about finding the right balance. Once you understand the difference between a chat window and a terminal agent working directly on your local files, it becomes much easier to pick the right tool for the job, using the terminal where genuine reasoning, iteration, and local context actually matter, and leaving simple, predictable tasks to standard scripts (unless, of course, token costs and money are no object).
