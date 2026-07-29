# Jobzy-Agent

Jobzy-Agent is an AI-powered job-search assistant that reviews job alerts, evaluates qualification fit, prioritizes opportunities, tailors resumes without inventing experience, and sends each opportunity to the user for approval.

## Project Status

Planning and initial setup.

## Table of Contents

- [Vision](#vision)
- [Core Capabilities](#core-capabilities)
- [Application Lifecycle Management](#Application-Lifecycle-Management) 
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Development Roadmap](#development-roadmap)
- [Security](#security)

## Vision

Build a personal AI job-search agent that:

1. Reviews job-alert emails from Gmail.
2. Extracts job descriptions and posting details (including date it was posted to understand urgency).
3. Removes duplicate opportunities.
4. Compares each job against a verified master resume.
5. Scores (consider all jobs I am 85% => qualified for) and prioritizes jobs by qualification fit.
6. Tailors a resume without fabricating experience.
7. Generates a Microsoft Word resume.
8. Sends the JD (high level summary bullets of the most important pieces of information for the JD, brief about the company, salary) , evaluation, and resume for approval.
9. Track each application throughout its lifecycle by combining manual status updates with automated monitoring of Gmail responses. The agent will detect recruiter communications (e.g., interview invitations, assessment requests, follow-ups, offers, and rejections), notify the user of meaningful updates, and persist all application activity and status changes in the PostgreSQL DB.

## Core Capabilities

- Gmail job-alert intake
- Job-description extraction
- Duplicate detection
- Qualification scoring
- Job prioritization
- Resume tailoring
- Microsoft Word document generation
- Human approval workflow
- PostgreSQL job tracking
- Agent-run logging

## Application Lifecycle Management

- Track every submitted application
- Monitor Gmail for recruiter responses
- Detect interviews
- Detect assessment requests
- Detect offers
- Detect rejections
- Recommend follow-ups
- Notify the user of important updates
- Persist application history in PostgreSQL

## Architecture

```text
Gmail
   ↓
n8n
   ↓
AI Model
   ↓
PostgreSQL
   ↓
Python Resume Generator
   ↓
Google Drive
   ↓
Gmail Approval Email
```

## Technology Stack

| Purpose | Tool |
|---|---|
| Repository and version control | GitHub |
| Code editor | Visual Studio Code |
| Workflow automation | n8n |
| Programming language | Python |
| Relational database | PostgreSQL |
| Database administration | DBeaver Community |
| AI model | OpenAI API |
| Email integration | Gmail |
| File storage | Google Drive |
| Word-document generation | python-docx |
| Database migrations | Alembic |
| Python testing | pytest |
| Code quality | Ruff |
| Type checking | mypy |
| Local containers | Docker Desktop |
| Continuous integration | GitHub Actions |

## Project Structure

```text
jobzy-agent/
│
├── README.md
├── .gitignore
├── docs/
│   ├── Vision.md
│   ├── ProductRequirements.md
│   ├── Architecture.md
│   ├── AgentDefinition.md
│   ├── DataModel.md
│   ├── Roadmap.md
│   ├── DecisionLog.md
│   └── ADRs/
│
├── agents/
│   ├── orchestrator/
│   ├── recruiter/
│   ├── resume-writer/
│   └── career-coach/
│
├── prompts/
├── workflows/
├── integrations/
│   ├── gmail/
│   ├── google-drive/
│   └── postgresql/
│
├── database/
│   ├── migrations/
│   ├── schema/
│   └── seeds/
│
├── resume/
│   ├── templates/
│   └── generated/
│
├── src/
├── tests/
├── config/
└── assets/
```

## Development Roadmap

### Phase 1 — Repository and documentation

Create the repository structure and define the product vision, requirements, agent responsibilities, and architecture.

### Phase 2 — Local development environment

Install and configure Python, Docker Desktop, PostgreSQL, DBeaver, and n8n.

### Phase 3 — Gmail intake

Connect Gmail to n8n and capture job-alert emails.

### Phase 4 — Database

Create PostgreSQL tables for jobs, companies, evaluations, resumes, applications, and agent runs.

### Phase 5 — Job evaluation

Extract job requirements, calculate qualification scores, identify strengths and gaps, and prioritize opportunities.

### Phase 6 — Resume generation

Tailor verified resume content and generate Microsoft Word documents.

### Phase 7 — Approval workflow

Send the job description, match evaluation, and tailored resume to the user for review.

### Phase 8 — Deployment

Deploy the personal-use application so it can operate when the local computer is off.

## Security

- Never commit passwords, API keys, tokens, resumes, or personal data.
- Store local secrets in a `.env` file.
- Keep `.env` in `.gitignore`.
- Store production secrets in the deployment platform or secret manager.
- Do not automatically submit job applications without explicit user approval.
