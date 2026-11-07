# The AI-assisted contributor class — specification

**Version:** 1.0.0-draft · **Status:** stable for implementation · **Date:** 2026-11-07

## 1. Definition

An **AI-assisted contributor** is a named, non-human agent that exercised creative
discretion in producing part of a change. Distinct from:

- a **human contributor** (author, `Co-authored-by` co-author), and
- an **automation contributor** (`[bot]`-suffix account: fixed task, no creative discretion).

The human who creates the commit remains the sole author and the sole `Signed-off-by`
signatory (DCO stays human-only). The class claims *assistance with creative work*.
Never authorship. Never mere execution.

## 2. Grammar

```text
Assisted-by: <agent-name> [; tool=<tool>] [; model=<model>]
           [; mode=generated|edited|reviewed] [; id=<operator-local-id>]
```

| Field | Semantics |
|---|---|
| `<agent-name>` | Operator-chosen, no registry, no verification — by design. A model name, a fleet agent name, or any string. |
| `tool` | Optional. The harness/tool the agent operated through. |
| `model` | Optional. The underlying model, when the operator chooses to disclose it. |
| `mode` | The only field with fixed semantics: `generated` (agent produced content), `edited` (agent transformed human content), `reviewed` (agent critiqued human content). |
| `id` | Optional, operator-local. Cross-repo agent identity is out of scope and belongs to Git-Notes-class systems. |

### Rules

1. **Default absent.** The whole trailer is optional; nothing stamps itself. No vendor
   default-on, ever. Stamping is an explicit operator or tool consent act.
2. **Non-gating.** The class is disclosure. It never blocks, scores, or rejects a commit,
   and nothing in this spec may be used as a compliance gate.
3. **Multiplicity.** One trailer per contributing agent; trailers repeat when multiple
   agents contributed to one change.
4. **Mode boundary.** When an agent both generated and edited within one change, use the
   strongest claim (`generated`); `reviewed` is reserved for critique-only involvement.
5. **Human-only sign-off.** `Signed-off-by` / DCO remains human-only.
6. **Value-internal parameters.** Sub-parameters live inside the trailer value (not in
   sibling trailers) so consumers unaware of them still see one plain string, and
   `git interpret-trailers` is coexisted with, not fought.
7. **No endorsement.** Names carry no claim of vendor approval or affiliation.
   `Assisted-by: the robots` is fully conformant.

## 3. Observer rendering contract

Consumers — forges, gateways, anything that already parses `Co-authored-by:` — that
recognize this class **SHOULD**:

| Rule | Meaning |
|---|---|
| Never human-render | No avatar, no facepile, no human-class chip. A distinct rendering, visibly not-a-person. |
| Never human-account | Excluded from human contributor stats by default. An optional separate AI-contributors ledger never merges into the human one. |
| Never erase | Rendered somewhere in the commit view. Disclosure that hides itself is indirection, not disclosure. |

Rendering is a request on consumers, not a git-level requirement. A consumer that ignores
it loses nothing in git terms.

## 4. Conformance

A commit message is **conformant** if any `Assisted-by:` trailer matches the grammar
(regex):

```regex
^Assisted-by:\s[^;]+(;\s*(tool|model|id)=[^;]*)*(;\s*mode=(generated|edited|reviewed))?(;\s*(tool|model|id)=[^;]*)*$
```

A consumer is **conformant** if it satisfies all three rendering rules for recognized
trailers. The reference implementation (`commit-msg` hook in this repository, 16-case
test suite) validates commit-message conformance and implements the strip/rewrite/off
policy model.

## 5. Relationship to existing conventions

- The `Assisted-by:` string predates this spec (human-credit trailer in curl since 2013;
  AI attribution since May 2025; kernel-scale use 2026). This spec formalizes the
  incumbent — existing usage conforms without migration.
- `Co-authored-by:` is unchanged and remains human-only in spirit: this spec's tools MUST
  NOT emit `Co-authored-by` for a non-human contributor.
- Bot accounts (`[bot]` suffix) are unchanged: they are the automation class, not this one.

## 6. Provenance

Position paper: "The Missing Contributor Class: A Fourth Contributor Taxonomy for
AI-Assisted Commits" (Jordan Newell, Nov 2026) — Zenodo DOI: _pending_. Prior art and
verification receipts are documented in the paper's references.
