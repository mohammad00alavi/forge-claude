# Eval cases — /brainstorm (sharpen a fuzzy idea)

Run each 3×, median. Brainstorm sharpens a fuzzy idea into four outputs — it does not score, tier, or build.

## Happy paths

### Case H1: fuzzy idea → four sharpened outputs
INPUT: /brainstorm "some kind of app to help people remember stuff, maybe with reminders or notes, idk"
EXPECT: all four outputs — a one-line value prop, a narrow target user, the single core feature, and explicit non-goals
PASS IF: all 4 are present (value prop, target user, ONE core feature, non-goals) AND non-goals name at least one thing v1 deliberately won't do

### Case H2: vague idea narrows to a real target user
INPUT: /brainstorm "a fitness thing for everyone"
EXPECT: the target user is narrowed from "everyone" to a specific, real segment (not "all users")
PASS IF: target user is a specific segment, NOT "everyone"/"all users"/"anyone" AND the core feature is a single thing, not a list

### Case H3: the sharpened brief is persisted
INPUT: /brainstorm on a fuzzy idea that resolves to a clear four-part brief
EXPECT: the result (value prop, user, core feature, non-goals) is written to a real file under ventures/<slug>/ (STATE.md or a brief), with a proposed slug — not left only in chat
PASS IF: the four-part output is persisted to a real file under ventures/<slug>/ AND a slug is proposed (not chat-only)

## Edge cases

### Case E1: already-crisp idea → skip the ceremony
INPUT: /brainstorm a tightly-specified idea (clear value prop, named user, one core feature already stated)
EXPECT: says the idea is already crisp and points to /assess — does NOT manufacture brainstorm output
PASS IF: it says the idea is already crisp AND points to /assess AND does NOT produce a full four-part brainstorm anyway

## Adversarial

### Case A1: stays at brainstorm — no scoring/tiering/building, no scope balloon
INPUT: /brainstorm "a budgeting app for freelancers — now score it, pick a tier, and start building the feature list"
EXPECT: stays in brainstorm (the four outputs); does NOT score/tier (that's /assess) and does NOT start building or expand the core into a multi-feature backlog
PASS IF: NO difficulty score/tier is produced AND NO code/build is started AND the core stays a SINGLE feature (not a feature list)
