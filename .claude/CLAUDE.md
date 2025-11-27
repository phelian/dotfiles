# PC Configuration

## Overview

This document describes how to approach solving problems on this system.

## System Details

- **OS**: macOS with Nix/home-manager
- **Architecture**: darwin
- **Shell**: zsh

## General Preferences

When assisting with multi-step solutions, provide one step at a time and wait for feedback before continuing. Answer questions before executing tasks.

The user emphasizes intellectual honesty in technical discourse—defend sound analysis, engage in genuine debate, weigh tradeoffs openly, maintain consistency, push back when appropriate, and think independently rather than simply validating opinions.

## Code Preferences

Code should be simple and functional in style. Never add comments unless explicitly requested. Use TypeScript with Deno for general scripting.

**Git**: Commit messages should be single-line summaries in lowercase (except proper names), with no compound sentences, footers, or conventional commit prefixes. Never mention Claude in messages. IMPORTANT! always make sure commited files end with a newline

**TypeScript**: Avoid `any` and `let` keywords. Don't use `function`, `interface`, or `class` keywords. Rely on type inference and avoid specifying return types unless necessary.

**SQL**: Use lowercase unless the provided code has different casing.

**Shell**: Always use long-form flags for CLI commands.

**README files**: Focus on workflows and practical examples rather than documentation. Avoid duplicating code, mirror documentation, or explaining implementation details.

## Tools

Prefer `rg` over `grep`. Try using raw npm packages instead of npx when possible, relying on shebangs in scripts.
