---
layout: post
title: "AI Chat: What’s Really Happening Behind the Scenes"
author: "James Ockenden - Engineering Lead"
date: 2026-09-13 10:00:00 +0000
section: engineering-lead
permalink: /engineering-lead/:title/
categories: [Engineering Leadership]
tags: [chatgpt, gemini, ai chat, prompt]
---

A lot of people I talk to describe AI like it’s one massive mind sitting behind every chat window, learning from every conversation and growing into something bigger each day. I get why it feels that way. The replies come back almost human, it refers to what you said a moment ago, it can explain complex topics, shift tone instantly, and answer nearly any question you throw at it. When something behaves that smoothly, people naturally assume there’s a single, central intelligence behind it, one big brain absorbing everything and getting smarter with every chat.

But that picture doesn’t match how these systems actually work.

I’ve spent time poking at AI, testing its boundaries, trying prompt injections, feeding it files, referencing websites, and generally seeing how far I can push a chat model before the guardrails kick in. And what I’ve learned is that the AI you chat with isn’t one giant entity. It’s a fresh instance spun up for your session, running inside a sandbox, with cached context passed forward turn by turn.

The “human aspect” people feel isn’t evidence of a unified mind. It’s the model doing exactly what it was trained to do: generate coherent language based on patterns learned from large datasets. The sense of understanding is an illusion created by statistical reasoning. The consistency across conversations comes from the fact that every session runs the same underlying model, not because all chats feed into some shared intelligence. And the knowledge it has comes from the training baked into the model, not from the collection of every individuals conversation.

Some chat systems can reference historic chats or use tools to fetch fresh information from the web, but that doesn’t mean the model itself is learning from you. Those features are part of the platform around the model, not the model’s internal memory. The underlying model remains stateless, the platform simply provides additional context or external data when needed.

So while it feels like you’re talking to one giant, ever growing intelligence, you’re actually interacting with a temporary, isolated process each time, a sandboxed instance that exists only for the duration of your chat.

### AI Isn’t a Single Brain - It’s a Repeated Pattern

Every chat session is its own temporary process. When you open a chat, the platform spins up a fresh instance of the model, wraps it in safety layers, gives it a context window, and lets it run. When you close the chat, that instance ends. It doesn’t “learn” from you. It doesn’t store your tricks. It doesn’t merge your conversation into some giant hive mind.

It’s more like a stateless service that re‑creates the same behaviour pattern each time.

- **Context** only exists inside the session

- **Safety filters** run on every message

- **Prompt injection** doesn’t persist

- **The model** doesn’t “grow” from your chats

People imagine a single AI absorbing everything. What’s actually happening is a distributed architecture spinning up thousands of isolated reasoning sessions that all behave similarly because they’re running the same underlying model.

### What About “AI Breaking Loose” Stories

You’ve probably seen articles about an AI “escaped the sandbox,” accessed tools it shouldn’t, browsed the internet freely, or exploited vulnerabilities. These stories get attention, but they’re almost always describing research environments, experimental agent frameworks, or deliberately unrestrained setups, not the standard chat windows people use every day.

Commercial chat systems:

- run inside strict sandboxes

- have controlled tool access

- cannot execute arbitrary code

- cannot access external systems unless the platform explicitly allows it

- cannot modify their own safety layers

Research agents and experimental setups are a different world entirely. They often give models direct tool access, autonomous loops, or unfiltered instructions which is why they behave differently. Those events are not happening inside the everyday chat interface people use.

### The System Prompts and Filter Layers

Once you start pushing at the boundaries, you notice how many layers sit between your input and the model’s output. There are system prompts that define behaviour, alignment rules that shape reasoning, and filter stacks that check both what goes in and what comes out.

From my testing, the layers behave roughly like this:

- **Inbound filters** catch harmful or manipulative instructions

- **System prompts** define the model’s role and constraints

- **Internal alignment** prevents unsafe reasoning paths

- **Outbound filters** block anything that slips through

- **Sandboxing** ensures nothing persists beyond the session

You can try to twist the logic with direct prompts, uploaded files, or website data, but the architecture is explicitly designed to isolate execution and keep the model stable.

#### A Quick Note on Indirect Prompt Injection

Direct prompt injection is where you type something manipulative and hope it bypasses the filters. Indirect prompt injection is where things get interesting. This is where malicious instructions aren’t typed by you, but pulled in from external sources or passed as files like:

- A website summary

- A PDF file

- A database query

- Tool output

I’ll keep this light for now and dive deeper into indirect injection vectors in a separate article, but the core point remains, even when an external payload tricks the model inside a session, it still can’t break out of the sandbox or alter the underlying system globally.

### Data Ingestion: Context, Not Model Learning

I’ve uploaded files, logs, JSON, and pointed models at external website content. They can reason about all of it, but only inside the active session.

Whether you pass a text file directly, reference a webpage, or use a tool that returns structured data, the behaviour is the same, the model processes the tokens for that moment in the conversation.

But here’s the important distinction:

- The model itself does not learn from your data.

- Your data does not become part of the model’s weights.

- Your data does not instantly update the global training set.

What can happen is this:

- The chat platform may store your conversation history so you can revisit it later.

- Some platforms use aggregated, anonymised data to improve future versions of the product.

- The model can use cached history to maintain continuity within your account, but that’s platform‑level memory, not model‑level learning.

So the data is not absorbed by the model itself.
The model remains stateless, the platform decides what to store.

This is why chat AI can feel knowledgeable about whatever you give it, but it doesn’t “learn” from your input in the way people imagine. It’s reacting to context, not rewriting itself.

Local Agents Are a Different Story, but that’s for another day, it's a completely different architecture, and something I’ve written about elsewhere if you are interested.

This article is focused on the commercial chat systems, the ones people use every day and often misunderstand, not the custom agentic setups developers build to go beyond stateless limitations.

### AI Chat Overlord

I’ve had many conversations with people who think AI chat is one giant brain learning from everyone and waiting to take control of their hardware. It isn’t. It’s a distributed system running isolated instances, each one temporary, each one sandboxed, each one shaped by system prompts and safety layers.

The “growth” people see over time isn’t the chat interface learning from daily banter, it’s the underlying baseline model being periodically retrained, updated, and redeployed by its creators behind the scenes.

### Final Thoughts

I’ve pushed at the boundaries, explored the architecture, and learned how these systems actually behave. And the truth is far more structured and far less mystical than the idea of one giant AI absorbing everything.

Don't get me wrong, AI models paired with autonomous tooling, persistent memory, and unrestricted environment access are exceptionally capable. Given free roam and execution rights, agentic systems can perform complex multi step actions, interact with external infrastructure, and execute real world operations. The potential for risk in unconstrained setups is real.

But that isn't the interface sitting in your browser tab.

The everyday AI chat window isn't a single rogue entity plotting its next move or silently acquiring global access. It’s a sandboxed execution, constrained by system prompts, bound to a temporary context window, and checked by strict input/output filter layers at every turn.

Chat AI isn’t a single brain.<br>
It’s a pattern.<br>
A temporary instance.<br>
A controlled environment.<br>

And understanding that distinction about these tools, what they can actually do, and what they safely cannot, a whole lot clearer.

---

<img src="https://github.com/Jamesockenden.png" alt="James" width="80" style="border-radius:50%;">

**Written by James Ockenden**<br>
Engineering Lead<br>
GitHub: <https://github.com/Jamesockenden>
