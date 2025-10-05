# Documentation Style Guide ✍️

Use this guide before shipping a new lab, README, or troubleshooting playbook. Consistency keeps the workspace scannable and friendly for learners.

## Headings 🎯

- Use a single, relevant emoji on `H1` or `H2` only. Avoid emoji clutter on deeper headings.
- Keep headings short (≤ 60 characters) and action-oriented.
- Start each page with a single `H1` that clearly names the page (for example, "Lab 03 — Scaling Deployments").

## Tone 🗣️

- Write in the active voice with short sentences.
- Explain "why" before "how"—context first, command second.
- Prefer confident verbs ("Run", "Inspect", "Deploy") over passive constructions.

## Structure 🧱

- Default page order: **Overview → Prerequisites → Steps → Validation → Next Steps**.
- Break long procedures into numbered lists of 3–7 steps max; add subheadings if more detail is needed.
- Highlight pitfalls in blockquotes starting with `> ⚠️`.

## Visual rhythm 🖼️

- Use tables sparingly; prefer bullet lists for short callouts.
- Limit inline emojis: 1 per 2 sentences on average. Maintain professional tone.
- Always declare a language for code blocks for consistent highlighting.

## Quality checks ✅

- Run `scripts/validate-links.sh` on the pages you touched.
- Confirm lab commands succeed inside Rancher Desktop/kind before publishing.
- Add backlinks to related labs or references when they help the learner jump ahead.

## Pull requests 🤝

- Summarise the change, the motivation, and any new validation results.
- Mention the lab number or document name in the PR title.
- Tag reviewers who maintain the affected lab or subsystem.
