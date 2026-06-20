---
description: MAINTAIN MODE setup. Prepare an existing project for maintenance (explore it, set up state, optionally configure triggers for always-running) — $ARGUMENTS
---

Set up maintenance mode for the existing project: $ARGUMENTS

Use this ONCE to bring an existing codebase under Forge maintenance (it's the
maintain-mode counterpart to /assess for build mode). For a single fix, use
/fix directly.

Steps:
1. **Survey** — spawn `explorer` to map the project at a high level: stack,
   structure, where the gates are (test/lint/build commands), the main risk
   areas. If gates are missing, note what's needed.
2. **Establish state** — create/confirm the project's STATE.md with:
   - the gate commands (so the fixer/verifier can run them)
   - a "Dead ends (don't retry)" section (starts empty)
   - **a Denied paths list (OPTIONAL)** — the git-gate (local commit free, push
     human-only) is the real protection, so this is belt-and-suspenders for the
     few paths where even a local edit must be impossible (commonly auth,
     payments, billing, secrets/keys, plus any domain-specific high-risk logic).
     An empty list is fine — the push gate still holds. When used, paths go in
     settings.json deny AND are listed here so every agent knows.
   - Cross-verify setting (none/codex/gemini)
3. **Harden settings for THIS project** — propose deny-list additions to
   `.claude/settings.json` for the project's irreversible/sensitive paths.
   Show me the additions; I approve. (Irreversible/safety-critical paths denied
   outright.)
4. **Optional: triggers (always-running)** — if I want unattended maintenance,
   explain the trigger options (see references/maintenance-mode.md):
   - run on CI failure, on a schedule, or on an error-spike
   - **and confirm I understand:** triggers control WHEN it runs, never WHAT it
     can do. An unattended run investigates + fixes + gates + commits locally +
     opens a PR — then STOPS. It can never `git push`/merge/deploy (those are
     denied); only I push, after reviewing locally. That separation — wide
     autonomy, push denied to agents — is what makes always-running safe.
   Triggers may auto-commit locally and open a PR (reversible, local), but can
   NEVER auto-push or auto-deploy — push is denied to agents by design.

After setup, day-to-day maintenance is just /fix (manually) or the trigger
firing /fix (unattended) — both ending at my approval gate.
