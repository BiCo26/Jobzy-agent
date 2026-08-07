# Jobzy-Agent Product Requirements

## Document Status

- **Status:** Draft
- **Product:** Jobzy-Agent
- **Primary User:** Bianca Cortes
- **Initial Release:** Personal-use MVP
- **Last Updated:** August 2026

## Purpose

This document defines the functional and non-functional requirements for Jobzy-Agent.

Jobzy-Agent is an AI-powered career assistant that receives job opportunities, evaluates qualification fit, researches legitimacy, prioritizes opportunities, tailors resumes using verified experience, and prepares approval packages while keeping the user in control of important decisions.

## Problem Statement

Reviewing job alerts, comparing qualifications, researching companies, tailoring resumes, and tracking applications requires substantial manual effort.

Jobzy-Agent should reduce that effort while protecting the user from:

- Low-quality or duplicate opportunities
- Job scams
- Possible ghost-job postings
- Expired or stale postings
- Poorly matched roles
- Fabricated resume content
- Lost application history
- Missed recruiter messages and follow-up actions

## Primary User

The initial user is Bianca Cortes.

The architecture should support additional users in the future, but multi-user functionality is outside the initial MVP.

## Product Goals

Jobzy-Agent shall:

1. Receive job opportunities from multiple intake sources.
2. Normalize job information into a consistent format.
3. Compare each opportunity against a verified master resume.
4. Evaluate qualification fit using configurable criteria.
5. Consider posting age and application urgency.
6. assess posting legitimacy using collected evidence.
7. Prioritize qualified and credible opportunities.
8. Tailor resumes without fabricating experience.
9. Generate versioned Microsoft Word resumes.
10. Prepare an approval package for each recommended opportunity.
11. Keep the user in control of application decisions.
12. Track application activity in PostgreSQL.
13. Monitor Gmail for meaningful application responses.
14. Generate career-performance insights over time.

## Non-Goals for the Initial MVP

The initial MVP will not:

- Automatically submit job applications.
- Automatically send messages to recruiters.
- Scrape LinkedIn or Indeed in violation of their terms.
- Change explicit user preferences without approval.
- Modify or overwrite the master resume.
- Claim that a job is fraudulent based on one weak signal.
- Provide a complete public-facing application.
- Support multiple users.
- Train a custom machine-learning model.

## MVP Scope

The first usable version will support:

- Manual JD submission through an n8n form
- Job posting URL submission
- Job-description text submission
- PostgreSQL job storage
- Qualification assessment
- Strength and gap analysis
- Basic company and legitimacy research
- Tailored resume generation
- Microsoft Word output
- Google Drive resume storage
- Gmail approval delivery
- Manual approval decisions

Gmail job-alert intake and automated application-response tracking may be added immediately after the first manual-intake workflow is operational.

# Functional Requirements

## 1. Job Intake

### FR-INT-001 — Manual Job Description Submission

The system shall provide a form where the user can paste a complete job description.

### FR-INT-002 — Job URL Submission

The system shall allow the user to submit a job-posting URL.

### FR-INT-003 — Gmail Intake

The system shall support receiving job opportunities from labeled Gmail job-alert messages.

### FR-INT-004 — Future Intake Methods

The architecture shall allow future support for:

- PDF upload
- Word-document upload
- Browser-assisted submission
- Company career-page integrations
- Approved job-data APIs

### FR-INT-005 — Input Validation

The system shall identify missing or unusable information, including:

- Missing job title
- Missing company name
- Missing job description
- Invalid URL
- Inaccessible posting
- Expired posting

Incomplete opportunities shall be marked for manual review.

### FR-INT-006 — Input Normalization

All intake sources shall be converted into a common internal job format before evaluation.

Normalized information should include:

- Job title
- Company
- Job description
- Job URL
- Source
- Location
- Work arrangement
- Employment type
- Salary information
- Posting date
- Closing date
- First-seen date
- Required qualifications
- Preferred qualifications

## 2. Job Dates and Freshness

### FR-DATE-001 — Source Posting Date

The system shall capture the date the source states that the job was posted, when available.

### FR-DATE-002 — Discovery Date

The system shall separately record when Jobzy-Agent first discovered the opportunity.

### FR-DATE-003 — Last-Seen Date

The system shall record the most recent date on which the posting remained available.

### FR-DATE-004 — Closing Date

The system shall capture the application deadline or posting-end date when available.

### FR-DATE-005 — Freshness Calculation

The system shall calculate the approximate age of the posting.

### FR-DATE-006 — Prioritization

Posting freshness and application urgency shall influence prioritization.

Freshness shall not override:

- Poor qualification fit
- Missing hard requirements
- High scam risk
- Evidence that the posting has expired

## 3. Duplicate Detection

### FR-DUP-001 — Exact Duplicate Detection

The system shall detect duplicate opportunities using identifiers such as:

- Source job ID
- Canonical job URL
- Company and requisition number

### FR-DUP-002 — Probable Duplicate Detection

The system shall identify probable duplicates using combinations of:

- Company
- Job title
- Location
- Description similarity
- Posting history

### FR-DUP-003 — Duplicate Preservation

Duplicate records shall not be silently deleted.

The system shall preserve source history and link duplicate sources to the normalized job record.

## 4. Qualification Evaluation

### FR-EVAL-001 — Resume Comparison

The system shall compare each job against a verified master resume and supported experience library.

### FR-EVAL-002 — Required and Preferred Qualifications

The system shall distinguish required qualifications from preferred qualifications.

### FR-EVAL-003 — Hard Requirements

The system shall identify hard requirements the user does not meet.

### FR-EVAL-004 — Qualification Score

The system shall assign a configurable qualification score from 0 to 100.

### FR-EVAL-005 — Minimum Threshold

The user shall be able to configure a minimum qualification threshold.

The initial default threshold is 85%.

### FR-EVAL-006 — Match Explanation

Every evaluation shall identify:

- Supported qualifications
- Strong matches
- Partial matches
- Experience gaps
- Missing hard requirements
- Assumptions
- Confidence level

### FR-EVAL-007 — Recommendation

The Recruiter Agent shall recommend one of the following:

- Apply
- Review
- Reject

### FR-EVAL-008 — No Fabricated Qualifications

The system shall not treat unsupported skills, credentials, responsibilities, or experience as qualifications.

## 5. User Preferences

### FR-PREF-001 — Explicit Preferences

The system shall support explicit user preferences, including:

- Minimum salary
- Target salary range
- Preferred job titles
- Preferred industries
- Preferred locations
- Remote, hybrid, or on-site preference
- Employment type
- Travel tolerance
- Company size
- Minimum qualification score
- Notification preferences

### FR-PREF-002 — Configuration

Preferences shall be stored as configurable data rather than hardcoded into prompts or architecture documents.

### FR-PREF-003 — Preference Precedence

Explicit user preferences shall take precedence over inferred preferences.

### FR-PREF-004 — Preference Changes

The system shall not change explicit preferences without user confirmation.

## 6. Legitimacy and Risk Assessment

### FR-LEG-001 — Company Verification

The system shall attempt to verify:

- Official company website
- Company identity
- Company career page
- Consistency between the company and posting

### FR-LEG-002 — URL Verification

The system shall evaluate whether the application URL belongs to:

- The company
- A recognized applicant-tracking system
- Another credible destination

### FR-LEG-003 — Scam Signals

The system shall evaluate signals such as:

- Requests for payment
- Requests for unnecessary sensitive information
- Suspicious email domains
- Typosquatted domains
- Unrealistic compensation
- High-pressure recruiting language
- Inconsistent company branding
- Vague or contradictory job details

### FR-LEG-004 — Ghost-Job Signals

The system shall evaluate signals such as:

- Repeated reposting
- Unusually old postings
- Long-running evergreen listings
- Duplicate listings across sources
- Evidence of hiring freezes
- Inability to confirm that the requisition remains active

### FR-LEG-005 — Evidence Collection

Every legitimacy assessment shall record:

- Source name
- Source URL
- Date checked
- Verified facts
- Risk signals
- Unverified information
- Conflicting evidence
- Confidence level

### FR-LEG-006 — Risk Outputs

The system shall produce:

- Legitimacy score
- Scam-risk level
- Ghost-job likelihood
- Confidence level
- Evidence-based explanation
- Recommended action

### FR-LEG-007 — Evidence Rules

The system shall not:

- Declare confirmed fraud based on one weak signal.
- Treat missing information as proof of fraud.
- Present assumptions as verified facts.
- Hide conflicting evidence.

High-risk or conflicting results shall be escalated for manual review.

## 7. Job Prioritization

### FR-PRI-001 — Prioritization Factors

The system shall consider:

- Qualification score
- Hard requirements
- Salary alignment
- Title alignment
- Location and work arrangement
- Posting freshness
- Application deadline
- Legitimacy assessment
- User preferences

### FR-PRI-002 — Explainability

The system shall explain why one opportunity is prioritized above another.

### FR-PRI-003 — Configurable Weights

Prioritization weights shall be configurable in future releases.

## 8. Resume Tailoring

### FR-RES-001 — Verified Source

Every tailored resume shall start from the verified master resume or verified experience library.

### FR-RES-002 — Factual Accuracy

The Resume Writer Agent shall not invent:

- Experience
- Employers
- Employment dates
- Responsibilities
- Results
- Skills
- Tools
- Credentials
- Education

### FR-RES-003 — Targeted Alignment

The system may:

- Reorder supported information
- Rephrase supported experience
- Emphasize relevant accomplishments
- Improve ATS keyword alignment
- Correct typographical errors

### FR-RES-004 — Master Resume Protection

The system shall never overwrite the master resume.

### FR-RES-005 — Versioning

Every tailored resume shall receive a unique version associated with:

- Job
- Company
- Creation date
- Source master resume
- Prompt version
- AI model
- Approval status

### FR-RES-006 — Word Generation

The system shall generate a Microsoft Word `.docx` resume.

### FR-RES-007 — Visual Verification

Generated resumes shall be checked for:

- Clipping
- Overlapping content
- Broken bullets
- Unexpected page breaks
- Formatting inconsistencies
- Missing content

### FR-RES-008 — Change History

The system should record significant wording changes made during tailoring.

## 9. Approval Package

### FR-APR-001 — Package Contents

The approval package shall include:

- Job title
- Company
- Posting URL
- Posting date and age
- Salary information
- Location and work arrangement
- Job-description summary
- Company overview
- Qualification score
- Strengths
- Gaps
- Missing hard requirements
- Legitimacy assessment
- Supporting sources
- Recommendation
- Tailored resume

### FR-APR-002 — User Decisions

The user shall be able to choose:

- Approve
- Reject
- Request changes
- Save for later
- Mark for manual review

### FR-APR-003 — Decision History

The system shall record:

- Decision
- Timestamp
- Related job
- Resume version
- Optional reason
- Whether the user overrode the AI recommendation

### FR-APR-004 — Submission Restriction

Approval of a recommendation shall not automatically submit a job application in the MVP.

## 10. Application Lifecycle Management

### FR-APP-001 — Application Record

The system shall create or update an application record when the user confirms that an application was submitted.

### FR-APP-002 — Manual Updates

The user shall be able to update application status manually.

### FR-APP-003 — Gmail Monitoring

The system shall monitor authorized Gmail messages for application-related responses.

### FR-APP-004 — Detected Events

The system should detect:

- Application received
- Recruiter outreach
- Recruiter screening
- Assessment request
- Interview invitation
- Follow-up request
- Additional-information request
- Offer
- Rejection
- Background check
- Withdrawal
- No response after a configurable period

### FR-APP-005 — Human Confirmation

AI-detected status changes with low confidence shall require user confirmation.

### FR-APP-006 — Status History

The system shall append status-history records rather than overwrite historical events.

### FR-APP-007 — Notifications

The system shall notify the user when:

- Action is required
- An interview is requested
- An assessment is received
- An offer is received
- A rejection is received
- A follow-up may be appropriate

## 11. Career Intelligence

### FR-CI-001 — Metrics

Future releases shall calculate:

- Application-to-interview conversion rate
- Interview-to-offer conversion rate
- Recruiter-response rate
- Average response time
- Resume-version performance
- Job-title performance
- Industry performance
- Salary trends
- Rejection trends

### FR-CI-002 — Recommendations

Career Intelligence recommendations shall be explainable and based on stored historical data.

## 12. Preference Learning

### FR-PL-001 — Decision Learning

Future releases may analyze approval and rejection patterns.

### FR-PL-002 — Inferred Preferences

Inferred preferences shall remain separate from explicit preferences.

### FR-PL-003 — User Confirmation

The system shall request confirmation before promoting an inferred preference to an explicit preference.

### FR-PL-004 — Automation

Preference learning shall not enable automatic job submission.

# Non-Functional Requirements

## NFR-001 — Security

Passwords, API keys, tokens, and credentials shall not be committed to GitHub.

## NFR-002 — Privacy

The system shall store only the personal information needed to perform its functions.

## NFR-003 — Least Privilege

Gmail, Google Drive, database, and AI integrations shall receive only the permissions required for their tasks.

## NFR-004 — Auditability

Important workflows and decisions shall be traceable.

Audit information should include:

- Workflow ID
- Agent
- Action
- Timestamp
- Input reference
- Output reference
- AI model
- Prompt version
- Confidence
- User decision
- Errors

## NFR-005 — Reliability

Workflows shall preserve their current state when a recoverable failure occurs.

## NFR-006 — Retry Safety

Retrying a workflow shall not create duplicate jobs, applications, or resume versions.

## NFR-007 — Explainability

Recommendations shall identify the factors and evidence that influenced them.

## NFR-008 — Maintainability

Agents, integrations, prompts, database migrations, and workflows shall be modular and version-controlled.

## NFR-009 — Replaceable Providers

The architecture shall allow AI, storage, and integration providers to be replaced without redesigning the entire system.

## NFR-010 — Performance

The manual MVP should return an initial assessment within a reasonable interactive waiting period.

## NFR-011 — Availability

The local MVP will operate only while the user’s Mac and Docker services are running.

Cloud deployment may provide continuous availability in a future release.

## NFR-012 — Accessibility

Future user interfaces should support readable labels, keyboard navigation, clear status messages, and accessible color contrast.

# Success Metrics

The MVP will be considered successful when:

1. A user can submit a pasted JD or job URL.
2. The system creates a normalized PostgreSQL job record.
3. Posting and discovery dates are stored separately.
4. The system produces a structured qualification assessment.
5. The assessment identifies strengths, gaps, and unsupported requirements.
6. The system produces an evidence-based legitimacy assessment.
7. A tailored `.docx` resume is generated without invented experience.
8. The resume is stored with version metadata.
9. The user receives an approval package.
10. The user’s decision is recorded.
11. A failed workflow can be investigated using logs.
12. Duplicate processing does not create duplicate job records.

# Assumptions and Dependencies

The MVP assumes:

- Docker Desktop is running.
- PostgreSQL and n8n containers are available.
- The user has a verified master resume.
- An AI API account and credential are configured.
- Gmail and Google Drive credentials are configured when those integrations are enabled.
- External job pages may be inaccessible or incomplete.
- Some job dates and salary information may remain unavailable.
- The user will review every tailored resume before applying.

# Risks

## AI Hallucination

The model may generate unsupported claims.

**Mitigation:** Restrict tailoring to verified resume evidence and require user review.

## Incorrect Job Parsing

Job pages and emails may contain incomplete or misleading information.

**Mitigation:** Preserve source content, store confidence, and allow manual correction.

## Scam Misclassification

A legitimate job may be incorrectly flagged, or a scam may appear credible.

**Mitigation:** Require evidence, use multiple signals, and escalate uncertainty.

## Stale Postings

A job may remain visible after active hiring has ended.

**Mitigation:** Track posting age, last-seen date, reposting, and application deadlines.

## Credential Exposure

Secrets may be accidentally committed or displayed.

**Mitigation:** Use `.env`, n8n credentials, `.gitignore`, and least-privilege access.

## Resume Over-Tailoring

Excessive tailoring may distort the user’s actual experience.

**Mitigation:** Preserve the master resume, version every output, and prohibit fabricated claims.

# MVP Acceptance Criteria

The personal-use MVP is complete when:

- [ ] Manual JD form is operational.
- [ ] Job URL and pasted text are accepted.
- [ ] Intake data is normalized.
- [ ] PostgreSQL stores the job.
- [ ] Duplicate detection runs.
- [ ] Posting date and discovery date are preserved.
- [ ] Qualification scoring runs.
- [ ] Strengths and gaps are generated.
- [ ] Legitimacy evidence is collected.
- [ ] A recommendation is generated.
- [ ] A tailored Word resume is created.
- [ ] The master resume remains unchanged.
- [ ] Resume metadata is stored.
- [ ] The resume is saved to Google Drive.
- [ ] A Gmail approval package is sent.
- [ ] The user’s decision is stored.
- [ ] Errors and agent decisions are logged.

# Future Enhancements

Future releases may include:

- Automated Gmail job-alert intake
- Automated recruiter-response detection
- PDF and Word JD uploads
- Browser-assisted applications
- Final submission approval
- Cover-letter generation
- Interview preparation
- Recruiter follow-up assistance
- Salary-negotiation support
- Career analytics dashboard
- Preference learning
- Confidence-based automation
- Additional job-source integrations
- Direct ATS integrations
- Multi-model AI routing
- Mobile-friendly interface
