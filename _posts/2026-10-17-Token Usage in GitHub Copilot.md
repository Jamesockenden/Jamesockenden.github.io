---
layout: post
title: "Understanding Token Usage in GitHub Copilot CLI: A Look into Context Passing"
author: "James Ockenden - Engineering Lead"
date: 2026-10-17 08:00:00 +0000
section: engineering-lead
permalink: /engineering-lead/:title/
categories: [Engineering Leadership]
tags: [copilot-cli, tokens, optimization, engineering-leadership, mcp, best-practices]
---

With free tier limits and rising AI usage costs, token efficiency has shifted from a nice to have optimisation to a practical concern. I've become more aware of how my own usage consumes context and AI credits, and, as an Engineering Lead, how the same can affect my teams.

When customising GitHub Copilot CLI with repository instructions, skills, custom agents, or Model Context Protocol (MCP) servers, it helps to understand what context the CLI makes available to the model, when it loads that context, and how context can grow during a session.

**A key distinction**: context window, input token processing, and billed usage are related, but they are not the same thing. A piece of text may occupy the context window when a request is made, and repeated processing contributes to cumulative input token usage. The exact billing or AI credit effect depends on the model and GitHub's current usage rules.

This article covers documented behavior alongside some deductions where GitHub's public documentation does not specify internal implementation details.

### Context is assembled for model requests

An LLM does not independently remember a CLI session between requests in the way a person remembers a conversation. The application must provide the relevant conversation and working context for each model request. In Copilot CLI, this includes the conversation, applicable instructions, and available tools.

A useful conceptual model is:
  Request Context &approx; System Instructions + Applicable Custom Instructions + Available Tool Definitions + Conversation History + Current Input

This is a model for thinking about context, not a literal description of the API payload. The contents vary with the task, configuration, tool loading behaviour, and session history.

### The baseline: instructions, tools, and discovery

There is no single, universal fixed token count for every Copilot CLI session. The starting context depends on the CLI version, selected model, configuration, repository, and enabled capabilities.

The main sources of overhead are as follows:

- **Base system instructions and built-in tools**
  Copilot CLI needs operating instructions and built in capabilities to work as an agent. These form part of the baseline context, but GitHub does not publish a token count for them, and the amount can change as the product evolves.

- **Repository and user instructions** (`copilot-instructions.md`, `AGENTS.md`, and related files)
  Copilot CLI uses instruction files to guide how it works. The main files to understand are:
  - `/.copilot/copilot-instructions.md` - Instructions that apply across sessions.
  - `.github/copilot-instructions.md` - Repository-level instructions.
  - `AGENTS.md` - Agents that can be placed at the repository root or in subdirectories to provide instructions for the relevant scope.
  - `.github/instructions/*.instructions.md` - Modular instruction files that can use an `applyTo` pattern to target specific files or paths.

  When instructions are loaded into the model's context, their content consumes tokens. However, characters do not equal tokens, standard English text typically tokenises at roughly 4 characters per token, meaning a 1,500 character instruction file will consume closer to 350 400 tokens. However, different models use different tokenisers (e.g., Anthropics tokenisers vs. OpenAIs variants), meaning the exact token weight for the exact same instruction file can vary from model to model. If that content is included in subsequent model requests, it can contribute repeatedly to input token usage.

  The key is scope: repository wide rules belong in `copilot-instructions.md` or a root `AGENTS.md`, while specialised guidance can live in scoped `AGENTS.md` or `*.instructions.md` files. This avoids loading task specific instructions when they are not needed. You can use `/instructions` to inspect the instruction files discovered by your CLI session.

- **MCP tool definitions and deferred loading**
  Model Context Protocol (MCP) tools expose names, descriptions, and parameter schemas. When multiple servers are connected, these definitions can quietly consume a substantial portion of your context window.

  Normally, all MCP tool definitions and schemas are injected directly into the initial prompt upfront. However, runtimes handle larger tool ecosystems through **deferred tool loading and dynamic tool search**:

  - **The 30-Tool Threshold & Tool Search:** Below approximately 30 total tools, the CLI bypasses search and loads all tool definitions upfront. Above this threshold, supported models (such as Claude Sonnet) automatically engage tool search. Instead of stuffing heavy schemas into the initial turn, the agent uses a lightweight discovery mechanism and loads full parameter schemas on demand only when a task requires them.

  - **Configuration & Overrides (`deferTools`):** The `deferTools` setting defaults to `"auto"`. If you want to force a server's tools to load upfront regardless of the threshold, you can set `deferTools: "never"` (or `false`) within your `mcp-config.json`. Conversely, keeping it on `"auto"` allows efficient token conservation for larger multi-server setups, though it introduces a minor latency round-trip when discovering new tools.

- **Skill discovery metadata and triggers**
  Skills introduce a distinct loading dynamic. Each skill relies on its `name` and YAML `description` in the frontmatter to help Copilot decide whether a workflow is relevant. The full `SKILL.md` body remains unloaded until Copilot selects that skill or you explicitly invoke it via command.

  **The role of triggers in discovery:** While the formal frontmatter structure centers on name and description fields, effective skill design relies on embedding clear *trigger intent*, such as specific user phrases, scenario boundaries, or keywords like *"Use when asked to..."*, directly into the description. This gives the model's selection mechanism the contextual cues it needs to match ambiguous prompts to the right tool without loading every full workflow upfront.

### How your configuration is used

Running the `/context` command in the CLI displays context into categories. The mapping below combines documented CLI behaviour with observations.

| Configuration or content | Likely category | What can safely be concluded |
| --- | --- | --- |
| Core Copilot CLI operating instructions | `System Prompt` | These contribute to the baseline prompt. GitHub does not publish a universal token count for them. |
| `copilot-instructions.md`, and applicable `*.instructions.md` files | `System Prompt` | Applicable instructions add context to the system prompt or custom instruction tracking. |
| Custom agent definitions (`*.agent.md`) and agent personas | `System Prompt` | Agent instructions and configuration influence the active session persona, grouping their tokens under prompt/instruction context. |
| Built in Copilot CLI tools | `System Tools` | Built in or system tools. |
| MCP tool names, descriptions, and parameter schemas | `MCP Tools` | Tool search and deferred loading (`deferTools`) directly govern this footprint. |
| Skill discovery metadata (names, descriptions, and trigger intent/keywords) | `System Prompt` | Registering local skills increases the `System Prompt` token allocation. |
| Full `SKILL.md` after a skill is selected or explicitly invoked | `Messages` | Skill details are injected into active execution rather than inflating baseline system prompts. |
| User prompt, retained conversation, agent responses, and tool results | `Messages`, where retained as conversation context | These form the conversational history side of the context. |
| `Buffer` and `Free Space` | Capacity/allocation indicators | Context window accounting. |

#### Interpreting a real `/context` snapshot

For example, a snapshot might show `System Prompt: 6.6k`, `System Tools: 9.1k`, `MCP Tools: 2.5k`, and `Messages: 0`. Live session testing demonstrates that:

1. Adding an MCP server scales `MCP Tools` predictably.
2. Registering a skill subtly increases the `System Prompt` baseline.
3. Executing a prompt or invoking a skill populates the `Messages` history stream.

To investigate the source of a category, compare controlled sessions and use the related CLI commands:

- `/context` - Inspect the current context allocation.
- `/instructions` - Inspect discovered instruction files and enable or disable them.
- `/skills list` and `/skills info <name>` - Inspect available skills and their descriptions/details.
- `/mcp` - Inspect MCP functionality and server configurations.
- `/usage` - Compare session token and AI Credit usage.

### How context can grow during a session

Context does not grow only because a user types more. It can also grow when the agent reads files, invokes tools, loads a skill, or brings additional tool definitions into scope.

| Stage | What may be added to context | Effect |
| --- | --- | --- |
| **First request** | Baseline instructions, applicable custom instructions, built in tools, and initial tool definitions | Starting overhead before useful work begins |
| **Follow up request** | Current prompt, relevant conversation history, and active context | History increases the amount of context processed |
| **An MCP tool is needed** | Matching tool results enter the conversation | First use latency spike, followed by possible reuse of the loaded definition |
| **A skill is invoked** | The skill's full `SKILL.md` instructions become available to the agent via the active message stream | Additional context injected into the execution payload |
| **More files or tools are used** | File contents, command output, and tool results | Potentially significant growth depending on output size |
| **Context is compacted** | The CLI summarises older conversation content to free space | Older details are condensed, and context is reorganised |

### Context compaction: what it does and doesn't solve

Copilot CLI provides `/context` to inspect context usage and `/compact` to manually compress conversation history. GitHub documents that the CLI also begins background compaction as a session approaches its context limit.

Compaction is not the same as shrinking every configuration file on disk. It manages conversation context to free space by summarising older history while retaining recent material.

### Optimisation checklist

- **Keep global instructions lean:** Put stable project conventions, architecture constraints, and non negotiable standards in `copilot-instructions.md` or `AGENTS.md`. Move lengthy procedures and specialist workflows into skills or supporting documents.
- **Use path specific instructions:** A rule that only applies to a particular part of the codebase should use modular instruction files and `applyTo` patterns to narrow its scope.
- **Review MCP servers and tool definitions:** Disable unused servers. Give tools clear names and concise descriptions. Where supported, change tool search defer via `"true"`, or `"false"`.
- **Keep skill descriptions useful and bodies focused:** Ensure descriptions give Copilot enough detail and trigger intent to recognise when a skill applies, while keeping the full `SKILL.md` focused strictly on the workflow.
- **Avoid duplicating guidance:** Put each rule at the narrowest sensible scope rather than repeating rules across global instructions, agent profiles, and skills.
- **Measure before and after:** Use `/context` and `/usage` with controlled comparisons. Token counts depend heavily on the model, CLI version, and enabled capabilities.

### Managing the Pipeline: Pre Context Token Reduction

While our architectural model treats Conversation History as a flat accumulator of past turns and tool results, raw terminal interactions introduce massive token bloat. Unfiltered command outputs (git diff, test suite tracebacks, or recursive file lists) can consume thousands of input tokens per interaction.

Integrating a CLI layer like rtk (rtk-ai/rtk) solves this by intercepting shell outputs and applying structural compression, such as reducing test runs to failures only, grouping file changes, and stripping whitespace, it ensures that what eventually lands in the model's Conversation History remains cost effective without modifying how your agent executes tools.

### The takeaway

Token efficiency is not simply about writing shorter prompts. It is about controlling how much context an agent needs, when it needs it, and how much of that context remains useful as work progresses.

Keep always applicable instructions lean, defer specialist instructions where possible, configure MCP tool loading intentionally, and measure real sessions. Most importantly, combine documented behavior with testing to make token optimisation reliable for your engineering teams.

### References

- Using GitHub Copilot CLI - context management, `/context`, `/usage`, and `/compact`.
- Adding custom instructions for GitHub Copilot CLI - instruction discovery, scope, and path specific instructions.
- Adding agent skills for GitHub Copilot CLI - skill discovery, descriptions, and invocation.
- Loading tools on demand with tool search - MCP tool loading, deferral, and tool search behaviour.

---

<img src="https://github.com/Jamesockenden.png" alt="James" width="80" style="border-radius:50%;">

**Written by James Ockenden**<br>
Engineering Lead<br>
GitHub: <https://github.com/Jamesockenden>
