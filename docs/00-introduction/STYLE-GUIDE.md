# Documentation Style Guide ✍️

Use this guide before shipping a new lab, README, or troubleshooting playbook. Consistency keeps everything skimmable and friendly for learners.

## Headings 🎯

- One H1 per page. Keep it short and specific (for example, "Lab 03 — Educational Stateful").
- Use a single, relevant emoji on H1 or H2 only. Avoid emoji on deeper headings unless it adds clear scannability.
- Prefer Title case for H1, sentence case for H2+ (e.g., "What you'll learn").

## Tone 🗣️

- Write in active voice with short sentences.
- Explain "why" before "how"—context first, command second.
- Use imperative mood for steps: "Run", "Inspect", "Deploy".

## Structure 🧱

- Default page order: Overview → Prerequisites → Steps → Validation → Troubleshooting → Next steps.
- Break long procedures into numbered lists of 3–7 steps; add subheadings if more detail is needed.
- Highlight pitfalls and notes with blockquotes: `> ⚠️`, `> 💡`, `> ✅`.

## Formatting ✨

- Declare a language on all code blocks (```bash, ```yaml, ```json, etc.).
- Use relative links within this repo (e.g., `../20-labs/01-weather-basics.md`).
- Wrap long lines softly at ~100 characters; avoid trailing whitespace.
- One blank line before and after headings and fenced code blocks.
- One space after list markers (`- `, `1. `).

### Engaging intros

- Start each lab with a short, attention‑grabbing intro (1–2 sentences) that explains why it matters and what users will build. Keep it punchy.
- Example: “In 20 minutes, go from empty cluster to a working weather service—with real validation, not toy hello worlds.”

### Challenge track sequencing

- After the main Steps section, present advanced sections in this order:
	1) Quick check 2) Break & Fix 3) Troubleshooting flow 4) Observability check 5) Expert mode 6) Test your knowledge 7) Next lab
- Add a short callout near the top that links to the expert section and lists this sequence.

### Long code and output

- Prefer multiple small code blocks over one very long block.
- Wrap verbose output or optional steps in collapsible sections:
	<details><summary>Show output</summary>
	…
	</details>

## Visual rhythm 🖼️

- Prefer bullet lists over tables for short callouts; use tables only when they clarify comparisons.
- Keep emoji usage minimal and purposeful (about 1 per paragraph or heading where helpful).
- Use callout sections for repeated patterns (Validation, Cleanup, Next steps).

## Accessibility ♿

- Provide alt text for images (brief and descriptive).
- Avoid using color alone to convey meaning.
- Ensure link text is meaningful out of context (avoid "click here").

## Quality checks ✅

- Validate links with `./scripts/run-link-check-full.sh` (or `./scripts/_run-link-check-per-file.sh <path>` for a single file).
- Smoke-test commands in a local cluster (Rancher Desktop, kind, or k3d) before publishing.
- Add backlinks to related labs or references when they help the learner jump ahead.

## Pull requests 🤝

- Summarize the change, the motivation, and any new validation results.
- Mention the lab number or document name in the PR title.
- Tag reviewers who maintain the affected lab or subsystem.

## Common fixes 🔧

- Replace garbled characters like `�` introduced by copy/paste with the intended emoji or plain text.
- Keep one H1 per file; demote secondary top-level headings to H2.
- Normalize headings like "What You'll Learn" → "What you'll learn" and "Next Lab" → "Next lab".
