-- Start a database transaction.
-- If any command fails, PostgreSQL can roll back the entire migration.
BEGIN;


-- ============================================================
-- APPLICATIONS TABLE
-- Stores the current state of each job application.
-- ============================================================

-- Create the applications table.
CREATE TABLE applications (

    -- Create a universally unique identifier for every application.
    -- gen_random_uuid() automatically generates the value.
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Identify the user who owns this application.
    -- This value must match an existing row in the users table.
    -- ON DELETE RESTRICT prevents deleting a user who still has applications.
    user_id uuid NOT NULL
        REFERENCES users(id) ON DELETE RESTRICT,

    -- Identify the job associated with this application.
    -- This value must match an existing row in the jobs table.
    -- ON DELETE RESTRICT protects application history from accidental deletion.
    job_id uuid NOT NULL
        REFERENCES jobs(id) ON DELETE RESTRICT,

    -- Identify the tailored résumé version used for the application.
    -- This field is optional because a résumé may not be selected yet.
    resume_version_id uuid
        REFERENCES resume_versions(id) ON DELETE RESTRICT,

    -- Store the latest known stage of the application.
    -- New application records begin with the planned status.
    current_status text NOT NULL DEFAULT 'planned',

    -- Record how the application was submitted.
    -- This is optional until the user confirms the submission method.
    submission_method text,

    -- Record when the application was submitted.
    -- This remains empty until the user confirms that they applied.
    applied_at timestamp with time zone,

    -- Record when the application process ended.
    -- This remains empty while the application is active.
    closed_at timestamp with time zone,

    -- Record when Jobzy created the application record.
    created_at timestamp with time zone NOT NULL DEFAULT now(),

    -- Record when Jobzy last updated the application record.
    updated_at timestamp with time zone NOT NULL DEFAULT now(),

    -- Name the rule that controls permitted current-status values.
    CONSTRAINT applications_current_status_check

        -- Require current_status to contain one approved value.
        CHECK (
            current_status IN (

                -- The user intends to apply.
                'planned',

                -- The user is preparing application materials.
                'preparing',

                -- The application was submitted.
                'applied',

                -- The candidate is in recruiter or initial screening.
                'screening',

                -- The candidate is participating in interviews.
                'interviewing',

                -- The candidate received an assignment or assessment.
                'assessment',

                -- The company extended an offer.
                'offer',

                -- The candidate accepted the offer.
                'accepted',

                -- The company declined the application.
                'rejected',

                -- The candidate withdrew from consideration.
                'withdrawn',

                -- The application process ended for another reason.
                'closed'
            )
        ),

    -- Name the rule that controls permitted submission methods.
    CONSTRAINT applications_submission_method_check

        -- Permit an empty submission method or one approved value.
        CHECK (
            submission_method IS NULL
            OR submission_method IN (

                -- The user submitted the application manually.
                'manual',

                -- Jobzy assisted through a browser workflow.
                'browser_assisted',

                -- The application was submitted through an applicant tracking system.
                'ats',

                -- The application used another submission method.
                'other'
            )
        ),

    -- Name the rule that validates the application closing date.
    CONSTRAINT applications_closed_at_check

        -- Allow an application without a closing date.
        -- Also allow planned records that do not yet have an application date.
        -- When both dates exist, closed_at cannot occur before applied_at.
        CHECK (
            closed_at IS NULL
            OR applied_at IS NULL
            OR closed_at >= applied_at
        ),

    -- Prevent the same user from having two application records
    -- for the exact same job.
    CONSTRAINT applications_user_job_unique
        UNIQUE (user_id, job_id)
);


-- Create an index for quickly finding a user's applications by status.
CREATE INDEX applications_user_status_idx
    ON applications (user_id, current_status);


-- Create an index for quickly finding an application for a specific job.
CREATE INDEX applications_job_id_idx
    ON applications (job_id);


-- Create an index for displaying a user's submitted applications
-- from newest to oldest.
CREATE INDEX applications_user_applied_at_idx
    ON applications (user_id, applied_at DESC)

    -- Only include rows that have an application date.
    WHERE applied_at IS NOT NULL;


-- Create a trigger that runs before an application is updated.
CREATE TRIGGER applications_set_updated_at

-- Run the trigger before PostgreSQL updates the row.
BEFORE UPDATE ON applications

-- Run the trigger once for each updated row.
FOR EACH ROW

-- Call the timestamp function created in migration 001.
-- The function sets updated_at to the current time.
EXECUTE FUNCTION set_updated_at();


-- Add a human-readable explanation to the applications table.
COMMENT ON TABLE applications IS
    'The current application record for one user and one job.';


-- Document the purpose of the current_status column.
COMMENT ON COLUMN applications.current_status IS
    'The latest known stage of the application lifecycle.';


-- Document the purpose of the applied_at column.
COMMENT ON COLUMN applications.applied_at IS
    'When the user confirmed that the application was submitted.';



-- ============================================================
-- APPLICATION STATUS HISTORY TABLE
-- Stores every status change without overwriting history.
-- ============================================================

-- Create the application_status_history table.
CREATE TABLE application_status_history (

    -- Create a unique identifier for each status-change event.
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Identify the application whose status changed.
    -- The application must already exist.
    -- ON DELETE RESTRICT preserves the historical record.
    application_id uuid NOT NULL
        REFERENCES applications(id) ON DELETE RESTRICT,

    -- Store the status before the change.
    -- It may be empty for the first status-history event.
    previous_status text,

    -- Store the new status after the change.
    new_status text NOT NULL,

    -- Record how Jobzy learned about the status change.
    event_source text NOT NULL,

    -- Record Jobzy's confidence in an automatically detected change.
    -- Manual updates may leave this field empty.
    confidence_score numeric(5, 2),

    -- Store an optional explanation or supporting information.
    notes text,

    -- Record when the status change actually occurred.
    occurred_at timestamp with time zone NOT NULL DEFAULT now(),

    -- Record when Jobzy saved the event in PostgreSQL.
    recorded_at timestamp with time zone NOT NULL DEFAULT now(),

    -- Name the rule that controls previous-status values.
    CONSTRAINT application_history_previous_status_check

        -- Allow no previous status for the first event.
        -- Otherwise, require an approved status.
        CHECK (
            previous_status IS NULL
            OR previous_status IN (
                'planned',
                'preparing',
                'applied',
                'screening',
                'interviewing',
                'assessment',
                'offer',
                'accepted',
                'rejected',
                'withdrawn',
                'closed'
            )
        ),

    -- Name the rule that controls new-status values.
    CONSTRAINT application_history_new_status_check

        -- Require the new status to be an approved value.
        CHECK (
            new_status IN (
                'planned',
                'preparing',
                'applied',
                'screening',
                'interviewing',
                'assessment',
                'offer',
                'accepted',
                'rejected',
                'withdrawn',
                'closed'
            )
        ),

    -- Name the rule that controls event-source values.
    CONSTRAINT application_history_event_source_check

        -- Require the event source to be an approved value.
        CHECK (
            event_source IN (

                -- The user entered the status manually.
                'manual',

                -- Jobzy inferred the status from an authorized Gmail message.
                'gmail',

                -- A Jobzy agent proposed or recorded the status.
                'agent',

                -- The status came from an applicant tracking system.
                'ats',

                -- The status came from another source.
                'other'
            )
        ),

    -- Name the rule that validates confidence scores.
    CONSTRAINT application_history_confidence_score_check

        -- Allow no confidence score for manual updates.
        -- Otherwise, require a score between 0 and 100.
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    -- Name the rule that validates optional notes.
    CONSTRAINT application_history_notes_check

        -- Allow notes to be empty.
        -- When notes are provided, prevent whitespace-only values.
        CHECK (
            notes IS NULL
            OR length(trim(notes)) > 0
        )
);


-- Create an index for retrieving one application's complete history
-- from newest event to oldest event.
CREATE INDEX application_history_application_occurred_idx
    ON application_status_history (
        application_id,
        occurred_at DESC
    );


-- Create an index for finding all events with a particular status
-- from newest event to oldest event.
CREATE INDEX application_history_status_occurred_idx
    ON application_status_history (
        new_status,
        occurred_at DESC
    );


-- Add a human-readable explanation to the history table.
COMMENT ON TABLE application_status_history IS
    'Immutable history of every recorded application-status change.';


-- Document the purpose and supported values of event_source.
COMMENT ON COLUMN application_status_history.event_source IS
    'How the status change was learned: manual, Gmail, agent, ATS, or other.';



-- ============================================================
-- MIGRATION TRACKING
-- ============================================================

-- Record migration 007 in the schema_migrations table.
-- This lets Jobzy know that the migration has already been applied.
INSERT INTO schema_migrations (version, migration_name)
VALUES (7, 'application_lifecycle');


-- Permanently apply every successful change in this transaction.
-- If an earlier command failed, PostgreSQL will not reach this point.
COMMIT;