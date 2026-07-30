# Architecture

This document describes the architecture of Jobzy-Agent.


## Overview

Jobzy-Agent is a modular, AI-driven career assistant that automates and enhances the job search process through specialized AI agents. The system is designed around a multi-agent architecture, allowing each agent to focus on a specific business capability while the AI Agent Orchestrator coordinates the overall workflow.

The architecture emphasizes:

- Modular design
- Human approval before irreversible actions
- Extensibility
- Auditability
- Separation of concerns

---

# High-Level Architecture

```text
                    External Systems
─────────────────────────────────────────────────────────────

 Gmail      LinkedIn      Indeed      Company ATSs
   │             │             │              │
   └─────────────┴─────────────┴──────────────┘
                         │
                         ▼
                  AI Agent Orchestrator
                         │
     ┌──────────┬─────────┬─────────┬──────────┬─────────┐
     │          │         │         │          │
Recruiter   Resume    Application  Career   Company
 Agent      Writer      Manager   Intelligence Research
     │          │         │         │          │
     └──────────┴─────────┴─────────┴──────────┘
                         │
                    PostgreSQL
                         │
                 Google Drive (.docx)
                         │
                    User Approval
```

---

# Core Components

## AI Agent Orchestrator

Coordinates every workflow and routes work to specialized agents.

Responsibilities:

- Workflow orchestration
- Error handling
- State management
- Notifications
- Audit logging

---

## Specialized AI Agents

The Orchestrator delegates work to:

- Recruiter Agent
- Resume Writer Agent
- Application Manager Agent
- Career Intelligence Agent
- Company Research Agent
- Preference Learning Agent (Future)

---

## Data Layer

Primary Database

- PostgreSQL

Stores:

- Jobs
- Companies
- Applications
- Resume Versions
- User Preferences
- Analytics
- Workflow History

---

## Document Storage

Google Drive

Stores:

- Master Resume
- Resume Versions
- Cover Letters (Future)

---

## External Integrations

Current

- Gmail
- Google Drive

Future

- LinkedIn
- Indeed
- Workday
- Greenhouse
- Lever
- Ashby
- Browser Automation

---

# End-to-End Workflow

## Step 1

Job alert arrives in Gmail.

↓

## Step 2

The AI Agent Orchestrator creates a new workflow.

↓

## Step 3

Recruiter Agent:

- Reads the job description
- Extracts metadata
- Scores the opportunity
- Detects duplicates

↓

## Step 4

If the opportunity meets the qualification threshold:

Resume Writer Agent generates a tailored resume.

Otherwise:

Archive the opportunity.

↓

## Step 5

Company Research Agent gathers company information.

↓

## Step 6

Application Manager Agent creates an application record.

↓

## Step 7

Approval Package is generated containing:

- Match Score
- Salary
- Resume
- Company Summary
- Recommendation

↓

## Step 8

User chooses:

Approve

or

Reject

↓

## Step 9

Career Intelligence Agent updates metrics.

↓

## Step 10

Preference Learning Agent records the decision.

---

# Data Flow

```text
Gmail
   │
   ▼
Recruiter Agent
   │
   ▼
PostgreSQL
   │
   ▼
Resume Writer
   │
   ▼
Google Drive (.docx)
   │
   ▼
Application Manager
   │
   ▼
Career Intelligence
```

---

# Security Principles

- Human approval before submission
- Never fabricate resume experience
- Version every generated resume
- Maintain audit logs
- Preserve historical application data
- Never overwrite the master resume

---

# Design Principles

- Single Responsibility Principle
- Modular architecture
- AI agents
```
