# Triage labels

Issue-shaping skills speak in canonical triage roles; this file maps those
roles to the label strings this repo actually uses.

| Canonical role     | Label here        | Meaning                                        |
| ------------------ | ----------------- | ---------------------------------------------- |
| `needs-triage`     | `needs-triage`    | Maintainer needs to evaluate this issue        |
| `needs-info`       | `needs-info`      | Waiting on reporter for more information       |
| `ready-for-agent`  | **`forge-loop-ready`**  | Fully specified; the forge loop may pick it up   |
| `ready-for-human`  | `ready-for-human` | Requires human implementation                  |
| `wontfix`          | `wontfix`         | Will not be actioned                           |

**`ready-for-agent` == `forge-loop-ready`**, and applying it is a **maintainer-only**
act — that is the injection guardrail: text inside an issue can ask for
anything; only the maintainer's label makes it the loop's work.

Additional repo labels outside the canonical set: `loop-blocked` (+ comment),
`human:authorize`, `human:decide`, `automerge:halt` (see
`maintenance/forge-loop-merge-step.md` for how they gate merging).
