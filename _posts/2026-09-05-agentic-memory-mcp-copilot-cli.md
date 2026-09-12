---
layout: post
title: "Building an Agentic Memory MCP Server for Copilot CLI"
author: "James Ockenden - Engineering Lead"
date: 2026-09-05 07:00:00 +0000
categories: [AI, Development, Copilot]
tags: [mcp, copilot-cli, sqlite, vector-search, rrf, agentic-memory]

Whenever you open a fresh terminal session, your AI coding CLI starts from square one. It has zero memory of your past projects, no awareness of previous mistakes, and no easy way to recall specific workflows without you pasting the same context over and over.
To fix this, I built a custom Agentic Memory MCP Server for Copilot CLI. The goal was simple: create an agentic memory engine that enables Copilot to Recall, Reason, Act, Learn, and Store all while keeping token consumption and API credit usage as low as possible.

---

### The Core Architecture: Memory Without Token Bloat
To prevent dumping massive files into every prompt, I split the memory layer into three distinct document types:
```text
                         ┌─────────────────────────┐
                         │       Copilot CLI       │
                         └────────────┬────────────┘
                                      │
                         ┌─────────────────────────┐
                         │    Agentic Memory MCP   │
                         └────────────┬────────────┘
                                      │
           ┌──────────────────────────┴──────────────────────────┐
┌─────────────────────────┐                           ┌─────────────────────────┐
│ Vector Search           │                           │ Full-Text Search (FTS5) │
│ (sqlite-vec)            │                           │ Exact Keywords & Symbols│
└──────────┬──────────────┘                           └──────────┬──────────────┘
           │                                                     │
           └──────────────────────────┬──────────────────────────┘
                                      │
                         ┌─────────────────────────┐
                         │  Reciprocal Rank Fusion │
                         │      (RRF Cross-Ref)    │
                         └────────────┬────────────┘
                                      │
        ┌─────────────────────────────┼─────────────────────────────┐
┌─────────────────────────┐ ┌─────────────────────────┐ ┌─────────────────────────┐
│ Durable Knowledge       │ │ Short-Lived Context     │ │ Task Skills             │
│ (Markdown OKF Format)   │ │ (Notes, Fixes, Lessons) │ │ (Workflows & Procedures)│
└─────────────────────────┘ └─────────────────────────┘ └─────────────────────────┘
```
Hybrid Retrieval Pipeline (SQLite Vector + FTS5 + RRF)
Instead of scanning every document on every query, retrieval happens through a hybrid engine:
Dual Search Channels: Incoming prompts trigger a vector search (`sqlite-vec`) for conceptual intent and a full-text search (`FTS5`) for exact syntax, variables, and error codes.
Cross-Referencing via RRF: Results are merged using Reciprocal Rank Fusion (RRF) directly in SQL, surfacing only high-confidence entries.
Precision Injection: Copilot receives only the top ranked snippets, keeping prompt tokens strict.

---

### The 3 Memory Tiers: How the Agent Learns

The MCP server organises memory into three functional tiers:

#### **1. Durable Knowledge**
- **Format:** Structured Markdown using Google OKF  
- **Content:** Architecture, API rules, project structure, static parameters  
- **Purpose:** Provides long term ground truth the agent can rely on

#### **2. Short Lived Context**
- **Format:** Episodic notes, decisions, runtime fixes, lessons learned  
- **Content:** Temporary insights from recent sessions  
- **Purpose:** Prevents repeated mistakes and preserves continuity across terminal sessions

#### **3. Task Skills**
- **Format:** Step by step procedures and reusable workflows  
- **Content:** Deployment routines, build steps, custom scripts  
- **Purpose:** Ensures consistent execution of recurring technical tasks


---

### The Execution Cycle: Recall > Reason & Act > Learn & Store
This 3 tier setup powers an autonomous learning loop during every CLI interaction:

```text
┌──────────┐     ┌────────────────┐     ┌───────────────┐
│  RECALL  │ ──► │  REASON & ACT  │ ──► │ LEARN & STORE │
└──────────┘     └────────────────┘     └───────────────┘
  Fetch OKF        Execute skill,        Log new fixes,
  & lessons        apply workflow        update OKF/skills
```

**Recall**: Upon receiving a command, the MCP server runs hybrid search over the SQLite index to pull relevant OKF knowledge files, previous fixes, and active lessons learned.  
**Reason & Act**: Copilot evaluates the prompt against historical decisions and task skills, running step-by-step procedures safely without re-inventing execution steps.  
**Learn & Store**: When a session produces a new fix, workaround, or optimised routine, Copilot stores it back into the memory system as a short lived note or a permanent skill definition.

---

### "Why Not Just Use Dedicated Agents?"
If you need specific context for an application, why not just build a specialised agent?
I do build domain specific agents, but an agentic memory layer solves a different problem altogether:  
Specialised Agents define who the AI is and what tools it can touch.
Agentic Memory captures what happened, what failed, and how the project evolved.
A specialised agent without memory is still stateless. Every new terminal session is Day 1. By pairing specialised agents with an Agentic Memory MCP server, your agents don't just execute within their domain they accumulate past lessons, recall prior decisions, and adapt to your personal workflow over time without inflating token costs.

---

### Why This Matters: Low Credits, High Efficiency
A big win is token conservation. Pushing raw conversation histories into an LLM context window burns through credits rapidly and causes context rot.
By delegating indexing to SQLite, fact storage to Markdown OKF files, and execution logic to Task Skills, the server injects only a minimal, highly targeted block of context per request.
#### Key Benefits
No Cold Starts: Copilot opens every session with full context of past project decisions.  
Continuous Improvement: Lessons learned ensure the CLI gets sharper and avoids repeating   previous errors.  
Minimal Token Costs: RRF retrieval keeps API usage low while keeping output accuracy high.  
Standardised Workflows: Complex, recurring technical tasks run consistently via structured skills.  

By pairing Copilot CLI with a structured local memory layer, it stops acting like a basic auto complete tool and becomes a true long term AI pairing partner.  

---

<img src="https://github.com/Jamesockenden.png" alt="James" width="80" style="border-radius:50%;">

**Written by James Ockenden**  
Engineering Lead  
GitHub: https://github.com/Jamesockenden
