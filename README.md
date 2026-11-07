# assisted-by

A git commit-msg hook that implements the **AI-assisted contributor class** — the fourth
contributor class, distinct from human authors, human co-authors, and bot accounts.

Vendor tools stamp commits with `Co-Authored-By: Claude`, `Co-authored-by: Copilot`, and
friends — putting a brand in a human-credit slot. The usual fix is stripping the trailer,
which erases provenance. `assisted-by` offers the third option: **rewrite the ad into a
neutral, conformant disclosure**.

```text
Before:  Co-Authored-By: Claude <noreply@anthropic.com>
         🤖 Generated with Claude Code

After:   Assisted-by: my-agent
```

Human co-authors are never touched. `Co-authored-by` is never emitted for a tool. The
class never gates: the hook transforms attribution, it never blocks a commit.

Companion to the position paper **"The Missing Contributor Class: A Fourth Contributor
Taxonomy for AI-Assisted Commits"** (Jordan Newell, 2026) —
[DOI 10.5281/zenodo.24031381](https://zenodo.org/records/24031381).

**Cite this software:** DOI `10.5281/zenodo.24034440` (concept DOI — all releases) ·
[v1.0.0 record](https://zenodo.org/records/24034441)

## The class, in one table

| Class | Mechanism | Renders as |
|---|---|---|
| Human author | commit author field | avatar, contributor graphs |
| Human co-author | `Co-authored-by:` trailer | avatar chip |
| Bot | `[bot]`-suffix account | bot badge |
| **AI-assisted** | **`Assisted-by:` trailer (this spec)** | **distinct, never a human avatar — rendering contract in [SPEC.md](SPEC.md)** |

## Grammar

```text
Assisted-by: <agent-name> [; tool=<tool>] [; model=<model>]
           [; mode=generated|edited|reviewed] [; id=<operator-local-id>]
```

- `<agent-name>`: operator-chosen, no registry, no verification — a model name, a fleet
  agent name, or anything. `Assisted-by: the robots` is fully conformant.
- `mode` is the only field with fixed semantics: `generated`, `edited`, or `reviewed`.
- Everything is optional. Default is absent — nothing stamps itself.
- `Signed-off-by` remains human-only (DCO, kernel precedent).

Full normative text: [SPEC.md](SPEC.md).

## Setup

Requires: git 2.x, bash, GNU grep/awk (Linux, macOS, or Git Bash on Windows).

```bash
git clone https://github.com/JordanNewell/assisted-by.git
cd assisted-by
./install.sh
```

`install.sh` copies the hook into `~/.assisted-by/`, sets `core.hooksPath` (preserving any
existing hooks by chaining), and writes the policy config. See the script for options.

## Usage

Per-repo or global, via git config:

```bash
git config --global aiattr.policy rewrite   # strip (default) | rewrite | off
git config --global aiattr.agent  my-agent     # default: assistant
```

| Policy | Behavior |
|---|---|
| `strip` | Delete vendor AI trailers. History stays clean and silent. |
| `rewrite` | Delete vendor trailers, stamp one conformant `Assisted-by: <agent>` if the message showed AI involvement. |
| `off` | Leave messages untouched. |

Tests:

```bash
bash test-commit-msg.sh    # 16 cases; exit 0 = all pass
```

## Contributing

PRs welcome — main branch is PR-only (CI required: tests + gitleaks, no review gate).
Keep the non-gating constraint absolute: nothing in this tool may block a commit based
on what it discloses. Bug reports and grammar proposals via issues.

## Why "the fourth class"?

Author, co-author, bot — and nothing for AI agents. The result: agents either masquerade
as human co-authors (vendor default-on trailers) or are erased (strip hooks). Both are
dishonest, and the 2025–2026 attribution war (kernel, VS Code, GCC, QEMU) is the noise
that gap produces. The full argument, the kernel post-mortem, the prior-art survey, and
the falsifiable adoption criteria are in the paper.

## License

MIT — see [LICENSE](LICENSE).
