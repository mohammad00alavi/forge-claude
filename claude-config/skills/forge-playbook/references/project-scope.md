# Project scope — stay inside the project; never probe the home directory

## The problem this prevents

Claude Code prompts for approval on reads and writes OUTSIDE the working
directory — anything in the broader home filesystem (`~/.nvm`, `~/.ssh`,
`~/.config`, `~/.aws`, etc.) — separately from the allow/deny list, even when
`Read(*)` is allowed. This guard is correct and worth keeping: it protects your
credentials, keys, and global config from being silently read. But it fires —
and stalls the run — when an agent needlessly reaches OUTSIDE the project to
detect environment details (e.g. reading `~/.nvm/alias/default` to find your
Node version).

The fix is behavioral, not a permission change: agents should detect everything
they need from INSIDE the project, or ask the user — never spelunk the home
directory. This keeps the out-of-project guard intact for the cases that matter
while eliminating the prompts caused by unnecessary global probing.

## The rule

**Agents must not read, write, or probe paths outside the project working
directory.** For anything about the environment, in priority order:

1. **Read in-project config files** — these answer almost everything and never
   prompt:
   - Node version → `.nvmrc`, `.node-version`, or `package.json` `engines` field
   - package manager → presence of `package-lock.json` / `pnpm-lock.yaml` /
     `yarn.lock` / `bun.lockb` in the project root
   - scripts/gates → `package.json` `scripts`
   - tooling config → `tsconfig.json`, `.eslintrc*`, etc. in the project
2. **Ask the user once** — if the needed fact isn't in any in-project file (and
   genuinely matters), ask a single question rather than searching the
   filesystem. "Which Node version should this use?" beats reading `~/.nvm`.
3. **Never** read `~/.nvm`, `~/.config`, `~/.ssh`, `~/.aws`, home-directory
   dotfiles, or anything outside the project root for detection. If you think
   you need something outside the project, STOP and ask the user — they'll
   either provide it or tell you it's unnecessary.

## Why not just allow out-of-project reads

You could pick "allow reading from this dir during the session" at the prompt,
or broaden the config — but the out-of-project guard is protecting real things
(`~/.ssh`, `~/.aws/credentials`, tokens in dotfiles). Widening it to silence an
env-detection prompt trades a meaningful protection for a minor convenience. The
right fix is to stop the unnecessary probing, not to open the door. Same
principle as bash-discipline: fix the behavior, don't widen the permission.

## Model-pinning / upgrade ritual note

The upgrade ritual in `models.md` checks which model versions are in use — that
is about the model aliases in `.claude/`, NOT about your shell's Node tooling.
Don't conflate "what model version" (read from the project's config/agents) with
"what Node version manager is on this machine" (don't probe it at all — read
`.nvmrc`/`engines` or ask). Neither task requires reading the home directory.
