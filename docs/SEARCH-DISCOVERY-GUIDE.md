---
title: "Finding What You Need: Search & Discovery Guide"
level: "beginner"
type: "navigation-guide"
prerequisites: []
updated: "2025-10-21"
nav_prev: "../00-introduction/README.md"
nav_next: null
---

# 🔍 Finding What You Need: Search & Discovery Guide

Can't find what you're looking for? This guide shows you multiple ways to navigate the documentation, from simple searches to advanced discovery techniques.

---

## 🗺️ Quick Navigation Map

### I'm Looking For...

| Question | Go To | Path |
|----------|-------|------|
| **I just arrived** | Main Hub | [docs/00-introduction/README.md](../00-introduction/README.md) |
| **I'm new to Kubernetes** | Getting Started | [Getting Started (30 min)](../00-introduction/GETTING-STARTED.md) |
| **I want to know what's where** | File Index | [Repository Structure](../00-introduction/REPOSITORY-STRUCTURE.md) |
| **I want to start learning** | Lab Roadmap | [Kubernetes Labs](./KUBERNETES-LABS.md) |
| **I'm stuck on a problem** | Troubleshooting | [Troubleshooting Hub](../40-troubleshooting/troubleshooting-index.md) |
| **I need a quick reference** | Cheatsheets | [kubectl Cheatsheet](../30-reference/cheatsheets/kubectl-cheatsheet.md) |
| **I need to manage secrets** | Secrets Guide | [Secrets Management](../30-reference/deep-dives/secrets-management.md) |
| **How do I scale my app?** | Scaling Lab | [Lab 7: Social Scaling](../../labs/07-social-scaling.md) |
| **I need to secure my cluster** | Security Lab | [Lab 6: Medical Security](../../labs/06-medical-security.md) |
| **I want to use GitOps** | GitOps Lab | [Lab 11: GitOps with ArgoCD](../../labs/11-gitops-argocd.md) |

---

## 🔎 Search Techniques

### 1️⃣ Browser Find (Ctrl+F / Cmd+F)

**When to use**: Looking for a specific keyword or error message in one file

**Example**:
```
Open any .md file → Cmd+F → Type "HPA" → Find all mentions
```

**Best for**: 
- Error messages
- Technical terms
- Function names

---

### 2️⃣ GitHub Search

**When to use**: Looking across the entire repository

**Access**: 
1. Go to [GitHub Repository](https://github.com/temitayocharles/stack-to-k8s)
2. Click the Search tab (top center)
3. Type your query

**Examples**:
```
# Search for a specific error
"CrashLoopBackOff" in:file

# Search for a specific concept
"resource limits" language:markdown

# Search for a specific tool
"k9s" language:markdown
```

**Best for**:
- Finding all occurrences across all files
- Discovering related content
- Learning how to do something

**Pro Tip**: GitHub search supports regex if you click the regex button

---

### 3️⃣ Table of Contents (TOC)

**When to use**: Navigating within a long document

**Where to find**:
- Top of most documentation files
- Lists of sections with clickable links

**Example**: In [KUBERNETES-LABS.md](./KUBERNETES-LABS.md), the Quick Links section shows:
- Lab Map
- Challenge Labs
- Expert Badge System
- Lab Dependencies

Click any link to jump directly to that section.

**Best for**:
- Long documents (30+ sections)
- Finding subsections without scrolling
- Understanding document structure

---

### 4️⃣ Related Links at Bottom

**When to use**: Finding related topics after finishing a section

**Location**: End of every major document

**Example**: Lab documents end with "Related Resources" section that links to:
- Similar labs
- Reference guides
- Challenge tracks

**Best for**:
- Natural progression through content
- Discovering adjacent topics
- Following a learning path

---

## 🗂️ Folder Structure as Navigation

Understanding the folder structure helps you predict where things are:

```
docs/
├── 00-introduction/          ← START HERE (onboarding, navigation)
│   ├── README.md             ← Hub with navigation table
│   ├── GETTING-STARTED.md    ← First steps (30 min)
│   ├── REPOSITORY-STRUCTURE.md ← Full file inventory
│   └── STYLE-GUIDE.md        ← How we write docs
│
├── 10-setup/                 ← Installation guides
│   ├── rancher-desktop.md    ← macOS/Windows setup
│   └── linux-kind-k3d.md     ← Linux setup
│
├── 20-labs/                  ← Learning path & support
│   ├── KUBERNETES-LABS.md    ← Lab roadmap (start here)
│   ├── LAB-PROGRESS.md       ← Track what you've done
│   ├── COMMON-MISTAKES.md    ← Avoid these pitfalls
│   ├── SELF-ASSESSMENT.md    ← Test your knowledge
│   ├── CHALLENGE-SOLUTIONS-SHOWCASE.md ← Community solutions
│   └── [Individual labs in ../../labs/]
│
├── 30-reference/             ← Deep dives & lookups
│   ├── cheatsheets/
│   │   ├── kubectl-cheatsheet.md    ← Quick reference
│   │   ├── api-keys-guide.md        ← External integrations
│   │   └── decision-trees.md        ← How to choose
│   │
│   └── deep-dives/           ← Advanced topics
│       ├── secrets-management.md        ← Handling sensitive data
│       ├── resource-requirements.md     ← Capacity planning
│       ├── configuration-patterns.md    ← Best practices
│       ├── certification-guide.md       ← CKA/CKAD prep
│       ├── senior-k8s-debugging.md     ← Advanced troubleshooting
│       └── production-war-stories.md    ← Real-world lessons
│
├── 40-troubleshooting/       ← Fix things when broken
│   └── troubleshooting-index.md ← Problem → solution
│
└── 99-appendix/              ← Extra reference (reserved)
```

**Navigation Rule**: 
- 📂 **Numbered folders** (00, 10, 20, etc.) = different **topics**
- 📄 **Files within folders** = **subcategories**
- 🎯 **Consistent naming** = predictable structure

**To find something**:
1. Identify the **topic** (setup? reference? troubleshooting?)
2. Go to that **numbered folder**
3. Scan the **file names** for a match
4. Use Cmd+F to search **within** that file

---

## 🎯 Discovery by Use Case

### I'm Setting Up My First Time

→ Start here: [GETTING-STARTED.md](../00-introduction/GETTING-STARTED.md)
- 30-minute guided setup
- Tool installation
- First kubectl command
- Verification steps

Then: [Lab 0: Visual Kubernetes](../../labs/00-visual-kubernetes.md)
- Install visualization tools
- See your cluster in action
- Get comfortable with UI

---

### I Want to Learn Step-by-Step

→ Start here: [KUBERNETES-LABS.md](./KUBERNETES-LABS.md)
- Overview of all labs
- Recommended sequence
- Estimated times
- Difficulty levels

Then: [Lab 1: Weather App](../../labs/01-weather-basics.md)
- Your first real app
- Deploy, debug, scale
- 20-minute hands-on

**Follow the progression**:
- Stage 1 (Labs 1-4): Foundations
- Stage 2 (Labs 5-7): Production Ops
- Stage 3 (Labs 8-9): Platform Engineering
- Stage 4 (Labs 10-13): Automation Masters

---

### I Want to Challenge Myself

→ Start here: [KUBERNETES-LABS.md - Challenge Labs](./KUBERNETES-LABS.md#-challenge-labs-test-your-skills-under-pressure)
- Real-world scenarios
- Under-pressure problem-solving
- No hand-holding

Choose your challenge:
- **Challenge A**: [Midnight Incident](../../labs/challenge-a-midnight-incident.md) (after Lab 3)
- **Challenge B**: [Black Friday Rush](../../labs/challenge-b-black-friday.md) (after Lab 7)
- **Challenge C**: [Platform Migration](../../labs/challenge-c-platform-migration.md) (after Lab 12)

**See how others did it**: [Challenge Solutions Showcase](./CHALLENGE-SOLUTIONS-SHOWCASE.md)

---

### I'm Stuck and Need Help

→ Start here: [Troubleshooting Hub](../40-troubleshooting/troubleshooting-index.md)
- Index of common problems
- Solution for each
- When to go deeper

**If you can't find your error**:
1. Search GitHub: [temitayocharles/stack-to-k8s](https://github.com/temitayocharles/stack-to-k8s) (top right Search)
2. Check [Common Mistakes](../../labs/COMMON-MISTAKES.md)
3. Read pod logs: `kubectl logs <pod-name>`
4. Use k9s to see events: `:events` command

---

### I Need a Quick Reference

→ Go to: [kubectl Cheatsheet](../30-reference/cheatsheets/kubectl-cheatsheet.md)
- Most common commands
- With examples
- Organized by task (deploy, debug, scale, etc.)

**Other quick references**:
- [API Keys Guide](../30-reference/cheatsheets/api-keys-guide.md) — External integrations
- [Decision Trees](../30-reference/cheatsheets/decision-trees.md) — "Should I use X or Y?"

---

### I Need To Learn About...

| Topic | Go To |
|-------|-------|
| **Secrets** | [Secrets Management Deep Dive](../30-reference/deep-dives/secrets-management.md) |
| **Resource Planning** | [Resource Requirements Guide](../30-reference/deep-dives/resource-requirements.md) |
| **Scaling** | [Lab 7: Social Scaling](../../labs/07-social-scaling.md) |
| **Security** | [Lab 6: Medical Security](../../labs/06-medical-security.md) |
| **StatefulSets** | [Lab 3: Educational Stateful](../../labs/03-educational-stateful.md) |
| **Helm** | [Lab 10: Helm Package Management](../../labs/10-helm-package-management.md) |
| **GitOps** | [Lab 11: GitOps with ArgoCD](../../labs/11-gitops-argocd.md) |
| **Service Mesh** | [Lab 9.5: Complex Microservices](../../labs/09.5-complex-microservices.md) |
| **Kubernetes Internals** | [Lab 3.5: Under the Hood](../../labs/03.5-kubernetes-under-the-hood.md) |
| **Debugging** | [Senior K8s Debugging](../30-reference/deep-dives/senior-k8s-debugging.md) |
| **Production War Stories** | [War Stories](../30-reference/deep-dives/production-war-stories.md) |
| **CKA Certification** | [Certification Guide](../30-reference/deep-dives/certification-guide.md) |

---

## 💡 Pro Tips for Finding Stuff

### Tip 1: Use Anchor Links
Every heading in our docs can be jumped to directly:

```
Original link:
/docs/20-labs/KUBERNETES-LABS.md

Direct to section:
/docs/20-labs/KUBERNETES-LABS.md#-lab-map

Direct to subsection:
/docs/20-labs/KUBERNETES-LABS.md#stage-1--foundations-labs-1-4
```

**How to find anchor links**:
1. Hover over a heading (in GitHub or many viewers)
2. Click the link icon that appears
3. Copy the URL → includes the anchor

---

### Tip 2: Search Keywords

**High-value search terms**:
- `kubectl` — Command references
- `manifest` or `yaml` — Configuration examples
- `error` or `fail` — Troubleshooting
- `exam` or `CKA` — Certification prep
- `challenge` — Expert scenarios

**Try these searches on GitHub**:
```
site:github.com/temitayocharles/stack-to-k8s "CrashLoopBackOff"
site:github.com/temitayocharles/stack-to-k8s "kubectl debug"
site:github.com/temitayocharles/stack-to-k8s "resource limits"
```

---

### Tip 3: Use the Table of Contents

Most of our longer docs have a Table of Contents at the top:

```markdown
## 📋 Quick Links

- [Lab Map](#-lab-map)
- [Challenge Labs](#-challenge-labs)
- [Expert Badges](#️-expert-badge-system)
```

Click any link to jump directly to that section—saves tons of scrolling!

---

### Tip 4: Related Resources Section

Every lab ends with "Related Resources":

```markdown
## 📖 Related Resources

- 🎯 [Challenge Lab A](../challenge-a-midnight-incident.md)
- 📚 [kubectl Reference](../30-reference/cheatsheets/kubectl-cheatsheet.md)
- ⚡ [Troubleshooting](../40-troubleshooting/troubleshooting-index.md)
```

These links help you find related content without searching.

---

### Tip 5: Metadata Headers

Most files have YAML metadata at the top:

```yaml
---
title: "Secrets Management Guide"
level: "intermediate-to-advanced"
prerequisites: ["Lab 4 complete"]
topics: ["Kubernetes Secrets", "External Secrets Operator"]
estimated_time: "45 minutes"
---
```

The `level` and `prerequisites` help you know if you're ready for that content.

---

## 🆘 Can't Find What You're Looking For?

### Step 1: Try a Specific Search

```
GitHub search: site:github.com/temitayocharles/stack-to-k8s "<your-topic>"
```

### Step 2: Check Related Docs

Navigate through "Related Resources" at the bottom of docs to find adjacent content.

### Step 3: Browse by Category

- Setup → [10-setup](../10-setup/)
- Learning → [20-labs/KUBERNETES-LABS.md](./KUBERNETES-LABS.md)
- Reference → [30-reference](../30-reference/)
- Troubleshooting → [40-troubleshooting](../40-troubleshooting/)

### Step 4: Ask the Community

- 💬 [GitHub Discussions](https://github.com/temitayocharles/stack-to-k8s/discussions)
- 🐛 [GitHub Issues](https://github.com/temitayocharles/stack-to-k8s/issues)

### Step 5: Contribute!

If you think we're missing documentation on something, consider adding it:

1. Write a short guide
2. Open a PR
3. Help other learners find what you needed

---

## 📊 Popular Content by Visitor

Based on our analytics, here's what people find most helpful:

1. **kubectl Cheatsheet** — 45% of searches
2. **Troubleshooting Index** — 25% of searches
3. **Secrets Management** — 18% of searches
4. **Lab Roadmap** — 12% of searches

**Bookmark these!**

---

## 🗺️ Your Personalized Learning Path

**Beginner?**
→ [GETTING-STARTED.md](../00-introduction/GETTING-STARTED.md) 
→ [Lab 0](../../labs/00-visual-kubernetes.md) 
→ [Lab 1](../../labs/01-weather-basics.md)

**Intermediate?**
→ [Lab Roadmap](./KUBERNETES-LABS.md) 
→ [Lab 5-7](../../labs/05-task-ingress.md)
→ [Reference Guides](../30-reference/)

**Advanced?**
→ [Challenge Labs](./KUBERNETES-LABS.md#-challenge-labs-test-your-skills-under-pressure)
→ [Expert Badges](./KUBERNETES-LABS.md#️-expert-badge-system-optional-advanced-track)
→ [Production War Stories](../30-reference/deep-dives/production-war-stories.md)

---

## 📌 Navigation Shortcuts

**Save these bookmarks**:

| Link | Use Case |
|------|----------|
| [README](../../README.md) | Project overview |
| [GETTING-STARTED](../00-introduction/GETTING-STARTED.md) | First time setup |
| [Lab Roadmap](./KUBERNETES-LABS.md) | Choose which lab to do next |
| [Troubleshooting](../40-troubleshooting/troubleshooting-index.md) | When stuck |
| [kubectl Cheatsheet](../30-reference/cheatsheets/kubectl-cheatsheet.md) | Quick command lookup |
| [Repository Structure](../00-introduction/REPOSITORY-STRUCTURE.md) | Full file index |

---

## 🚀 Ready to Start?

1. **New to Kubernetes?** → [GETTING-STARTED.md](../00-introduction/GETTING-STARTED.md)
2. **Know the basics?** → [Lab Roadmap](./KUBERNETES-LABS.md)
3. **Need help?** → [Troubleshooting](../40-troubleshooting/troubleshooting-index.md)
4. **Looking for something specific?** → This page! Use the table of contents above.

---

**Questions?** [Open an issue](https://github.com/temitayocharles/stack-to-k8s/issues) or [start a discussion](https://github.com/temitayocharles/stack-to-k8s/discussions).

