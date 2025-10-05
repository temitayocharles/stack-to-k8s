# Documentation Style Guide ✍️

Use this guide before shipping a new lab, README, or troubleshooting playbook. Consistency keeps the workspace scannable and friendly for learners.

## Headings 🎯

- Apply a single, relevant emoji to each top-level or second-level heading. Skip emojis on lower levels.
- Keep headings short (under 60 characters) and action oriented where possible.
- Start each page with an `H1` that names the artifact (for example, "Lab 03 — Scaling Deployments").

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
- Limit inline emojis to one every two sentences to avoid visual noise.
- Code blocks must declare a language for syntax highlighting.

## Quality checks ✅

- Run `scripts/validate-links.sh` on the pages you touched.
- Confirm lab commands succeed inside Rancher Desktop/kind before publishing.
- Add backlinks to related labs or references when they help the learner jump ahead.

## Pull requests 🤝

- Summarise the change, the motivation, and any new validation results.
- Mention the lab number or document name in the PR title.
- Tag reviewers who maintain the affected lab or subsystem.
