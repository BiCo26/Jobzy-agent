# Agent Definition

This document defines the responsibilities, boundaries, and interactions of the AI agents that make up Jobzy-Agent.

Jobzy-Agent is a multi-agent AI system that assists with every stage of the job search while keeping the user in control of final decisions.

```text
                              Jobzy-Agent
                                   │
                        AI Agent Orchestrator
                                   │
 ┌────────────────┬────────────────┬──────────────────┬──────────────────────┬────────────────────┐
 │                │                │                  │                      │
Recruiter     Resume Writer   Application Manager   Career Intelligence   Company Research
  Agent           Agent             Agent                 Agent               Agent
                                   │
                                   │
                         Preference Learning
                                Agent (Future)
```

---

# AI Agent Orchestrator

## Purpose

Coordinate the end-to-end Jobzy-Agent workflow by assigning work to specialized agents and managing the overall process.

### Responsibilities

- Receive new workflow requests.
- Determine which agents should execute.
- Route work between agents.
- Track workflow progress.
- Enforce approval and execution policies.
- Handle failures and retries.
- Record workflow events.
- Notify the user when action is required.
- Coordinate communication between all agents.

### Inputs

- Job-alert email
- Job description
- User Preference Profile
- Master resume
- Existing job and application records
- Outputs from other agents

### Outputs

- Agent assignments
- Workflow status
- Approval requests
- Final recommendation
- Audit logs

### Tools

- Gmail
- PostgreSQL
- n8n
- AI Model Provider
- Google Drive

### Boundaries

- Does not evaluate job qualifications directly.
- Does not rewrite resumes.
- Does not submit job applications.
- Does not research companies.
- Does not modify user preferences.
- Coordinates specialized agents and manages workflow.

---

# Recruiter Agent

## Purpose

Analyze incoming job opportunities and determine how well they match the user's experience and career goals.

### Responsibilities

- Parse job descriptions.
- Extract job title.
- Extract company name.
- Extract salary and compensation range when available.
- Extract location.
- Identify work arrangement (Remote, Hybrid, On-site).
- Identify employment type.
- Extract required and preferred skills.
- Compare the opportunity against the master resume.
- Calculate a qualification score.
- Identify strengths and experience gaps.
- Detect duplicate job postings.
- Recommend Apply, Review, or Reject.

### Evaluation Criteria

The Recruiter Agent evaluates opportunities using the User Preference Profile.

Examples include:

- Minimum salary
- Target salary range
- Preferred job titles
- Preferred industries
- Preferred locations
- Remote/Hybrid/On-site preference
- Employment type
- Minimum qualification score

### Inputs

- Job description
- Master resume
- User Preference Profile

### Outputs

- Qualification score
- Match summary
- Extracted job metadata
- Salary information
- Recommendation

### Tools

- AI Model Provider
- PostgreSQL

### Boundaries

- Does not modify resumes.
- Does not submit applications.
- Does not change user preferences.

---

# Resume Writer Agent

## Purpose

Generate an optimized resume tailored to a specific job while preserving factual accuracy.

### Responsibilities

- Tailor the master resume to the job description.
- Improve ATS keyword alignment.
- Preserve factual accuracy.
- Generate versioned .docx resumes.
- Maintain resume version history.

### Inputs

- Job description
- Master resume

### Outputs

- Tailored resume
- Resume version metadata

### Tools

- AI Model Provider
- python-docx
- Google Drive

### Boundaries

- Never fabricate experience.
- Never overwrite the master resume.
- Never submit job applications.
- Never modify user preferences.

---

# Application Manager Agent

## Purpose

Track and manage the complete lifecycle of every job application.

### Responsibilities

- Create application records.
- Track application status.
- Monitor Gmail for recruiter responses.
- Detect interview invitations.
- Detect assessments.
- Detect offers.
- Detect rejections.
- Update PostgreSQL.
- Notify the user of important events.

### Future Responsibilities

- Browser-assisted applications.
- Easy Apply automation.
- Resume upload automation.
- Application form pre-fill.
- Human approval before submission.

### Inputs

- Approved resume
- Job information
- Gmail updates

### Outputs

- Updated application status
- Notifications
- Activity log

### Tools

- Gmail
- PostgreSQL
- Browser Automation (Future)

### Boundaries

- Never submit applications without explicit user approval.
- Never fabricate application answers.
- Never alter resume content.

---

# Career Intelligence Agent

## Purpose

Analyze historical job-search performance and generate actionable insights.

### Responsibilities

- Measure application-to-interview rate.
- Measure interview-to-offer rate.
- Analyze resume effectiveness.
- Analyze salary trends.
- Compare salary versus interview success.
- Track recruiter response times.
- Identify high-performing keywords.
- Recommend improvements.
- Generate dashboards and reports.

### Inputs

- Job records
- Application records
- Resume versions

### Outputs

- Analytics
- Reports
- Recommendations

### Tools

- PostgreSQL
- AI Model Provider

### Boundaries

- Does not modify resumes.
- Does not submit applications.
- Does not change user preferences.

---

# Company Research Agent

## Purpose

Gather useful company information to support informed application decisions.

### Responsibilities

- Research company overview.
- Identify industry.
- Estimate company size.
- Capture publicly available salary information.
- Research benefits and perks.
- Identify technologies used.
- Gather hiring insights.
- Support future interview preparation.

### Inputs

- Company name

### Outputs

- Company profile
- Research summary

### Tools

- AI Model Provider
- Future web research integrations

### Boundaries

- Does not recommend applying solely based on company research.
- Does not modify resumes.
- Does not submit applications.

---

# Preference Learning Agent (Future)

## Status

Planned for Version 2+

## Purpose

Learn the user's preferences over time by observing approval and rejection decisions while keeping all inferred preferences transparent and user-controlled.

### Responsibilities

- Record approval decisions.
- Record rejection decisions.
- Detect preferred salary ranges.
- Detect preferred job titles.
- Detect preferred industries.
- Detect preferred company sizes.
- Detect preferred work arrangements.
- Detect preferred locations.
- Predict future approval decisions.
- Calculate confidence scores.
- Suggest preference updates.
- Measure prediction accuracy.

### Preference Profile

The agent maintains two types of preferences.

#### Explicit Preferences

- Minimum salary
- Target salary range
- Preferred job titles
- Preferred locations
- Remote/Hybrid/On-site preference
- Employment type
- Preferred industries
- Company size
- Minimum qualification score

#### Inferred Preferences

- Frequently approved companies
- Frequently rejected companies
- Preferred salary ranges
- Preferred technologies
- Resume versions with highest success rates
- Recruiter response patterns

### Inputs

- User approval decisions
- User rejection decisions
- Application history
- Job attributes

### Outputs

- Preference recommendations
- Confidence scores
- Learning reports

### Tools

- PostgreSQL
- AI Model Provider

### Boundaries

- Never change explicit user preferences automatically.
- Never auto-submit applications.
- Always explain inferred preferences.
- Always allow the user to override recommendations.

---

# Agent Interaction Flow

1. Gmail receives a new job opportunity.
2. The AI Agent Orchestrator creates a workflow.
3. The Recruiter Agent evaluates the opportunity.
4. Duplicate or low-quality jobs are filtered.
5. Qualified jobs are sent to the Resume Writer Agent.
6. The Resume Writer Agent generates a tailored resume.
7. The Company Research Agent gathers company information.
8. The Application Manager Agent creates an application record.
9. The user receives an approval package.
10. The user approves or rejects the recommendation.
11. The Career Intelligence Agent updates analytics.
12. The Preference Learning Agent records the decision to improve future recommendations.
