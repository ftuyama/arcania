---
name: pick-backlog-task
description: Select the highest-priority open Arcania backlog item and mark it started without implementing it. Use when asked to pick a backlog task or choose what to work on next.
---

# Pick Backlog Task

Read `docs/12-improvements-backlog.md` in full. If the user supplies an ID, select it if open; otherwise select the first open item under Suggested Timeline → Next 1 Week, then P0 through P3, preferring smaller effort within a tier. Cross-check `docs/11-scoped-release.md`; skip out-of-scope items unless explicitly requested.

Before editing, report the chosen ID, priority, why now, scope verdict, and acceptance criteria. Then delete the item row, remove it from Suggested Timeline, decrement the priority’s open count, append `STARTED: [ID]` to the Changelog with today’s date, and update Last updated. Stop after recording the start; do not implement or run tests.
