---
description: Stress-test a plan or design before building — relentless one-question-at-a-time interview that surfaces hidden assumptions — $ARGUMENTS
---

Grill this plan/design: $ARGUMENTS

Run the grilling discipline (references/grilling.md): interview me relentlessly,
ONE question at a time, walking down the design tree and resolving dependencies
in order, until we reach shared understanding.

Rules:
- One question at a time — wait for my answer before the next. Never batch.
- Always offer your RECOMMENDED answer with each question.
- If a question can be answered by exploring the codebase (in-project files
  only — respect project-scope, no home-directory probing), explore instead of
  asking me.
- Resolve dependencies in order — settle A before the decision that depends on it.

Match depth to stakes: skip for trivial/well-understood work; go deep for fuzzy
T2+ scope, long-lived architectural decisions, or refactors touching many call
sites.

When we settle a decision that matters later, record it in Forge's existing
state (NOT a separate system): scope/design → STATE.md; a rejected approach with
a load-bearing reason → STATE.md "Dead ends (don't retry)"; a reusable lesson →
learnings.md.
