---
name: implement-backlog-task
description: Implement an Arcania backlog task already marked STARTED, verify it, and record completion. Use when asked to implement a picked or in-flight backlog item.
---

# Implement Backlog Task

Read `docs/12-improvements-backlog.md`. Use the requested ID or the most recent `STARTED:` Changelog entry. If no matching started entry exists, stop and ask the user to pick a task first. Confirm it is not still open in a priority table.

Report the ID, source date, and acceptance criteria. Follow `docs/11-scoped-release.md`, `docs/10-development-roadmap.md`, `docs/08-technical-architecture.md`, and the relevant design bible. Use `implement-godot-feature` for Godot work and `check-roadmap-scope` if the phase is unclear. Verify relevant tests and parser/linter errors before recording completion.

On success, add the task to the Completed section, append a Changelog row, and update Last updated. If verification is incomplete, restore the priority-table row with `🔄`, document what remains, increment its open count, and append a `PARTIAL:` Changelog entry. Do not commit changes.
