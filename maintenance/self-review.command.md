---
description: Forge maintainer-only — run the daily self-review (health + evals + gated machinery fixes + digest). NOT shipped to installs.
---

Run Forge's self-review for THIS repo. Read and execute `maintenance/self-review.md`.

You are maintaining Forge's own machinery. Wide autonomy on what you inspect;
narrow on what you change. You may edit machinery, run the eval gate, and open a
PR — never push, merge, tag, or cut a release. Stop at the human.

<!--
This is the optional `/self-review` slash command for the FORGE REPO ONLY.
Copy it to `.claude/commands/self-review.md` in the forge repo to enable it:
    cp maintenance/self-review.command.md .claude/commands/self-review.md
It deliberately is NOT in claude-config/, so install.sh never ships it to users.
-->
