# Execution Policy

## Purpose

This document defines the operational rules that govern how Jobzy-Agent executes workflows, makes recommendations, and interacts with external systems.

These policies ensure the system remains transparent, auditable, and user-controlled.

---

# Core Principles

- Human remains in control of important decisions.
- AI assists but does not replace user judgment.
- Every important action must be explainable.
- Every workflow must be auditable.
- Automation should increase only after trust has been established.

---

# Approval Levels

## Level 0 — Fully Automatic

The system may perform these actions without approval.

Examples:

- Read Gmail job alerts
- Parse job descriptions
- Research companies
- Calculate qualification scores
- Detect duplicate jobs
- Detect possible scams
- Store information in PostgreSQL
- Generate analytics
- Create draft resumes

---

## Level 1 — User Review Required

The system prepares work but waits for approval.

Examples:

- Tailored resume generation
- Company summaries
- Application recommendations
- Cover letters
- Preference updates
- Browser form completion (future)

---

## Level 2 — Explicit Approval Required

> **Note:** Some actions below are planned for future releases and are not part of the current MVP.

- Submit job applications *(Future)*
- Send recruiter emails *(Future)*
- Send follow-up messages *(Future)*
- Modify the master resume
- Delete application history
- Change user preferences

---

# AI Decision Rules

Jobzy-Agent should:

- Explain every recommendation.
- Include supporting evidence.
- Distinguish facts from assumptions.
- Identify uncertainty.
- Escalate conflicting evidence.
- Recommend manual review when confidence is low.

---

# Preference Learning Policy

Preference learning begins only after sufficient decision history exists.

The system may:

- Learn approval patterns.
- Learn rejection patterns.
- Recommend preference updates.

The system may not:

- Automatically change explicit preferences.
- Automatically submit applications.
- Hide inferred preferences from the user.

---

# Browser Automation Policy (Future)

Browser automation may:

- Open job pages.
- Complete forms.
- Upload resumes.
- Save drafts.

Browser automation may not:

- Submit applications without explicit approval.
- Accept employment agreements.
- Electronically sign documents.
- Enter payment information.
- Answer application questions by inventing experience.

---

# Resume Policy

The system must:

- Preserve the master resume.
- Version every generated resume.
- Never fabricate experience.
- Never exaggerate accomplishments.
- Record which resume version was used for each application.

---

# Security Policy

The system must:

- Store credentials securely.
- Never expose secrets.
- Use least-privilege access.
- Protect personal information.
- Record security-sensitive actions.

---

# Audit Policy

Every workflow should record:

- Workflow ID
- Agent
- Timestamp
- Inputs
- Outputs
- Decision
- Confidence
- User approval
- Errors

---

# Future Automation Policy

As confidence improves, Jobzy-Agent may recommend increasing automation.

Any increase must be explicitly approved by the user.
