-- Apply these changes together as one transaction.
BEGIN;

-- Store the complete parsed evaluation without losing any fields.
-- Existing evaluations remain NULL because their full output is unknown.
ALTER TABLE job_evaluations
    ADD COLUMN evaluation_details jsonb;

-- Require an object when evaluation details are supplied.
-- SQL NULL is allowed for older evaluations.
ALTER TABLE job_evaluations
    ADD CONSTRAINT job_evaluations_details_object_check
    CHECK (
        evaluation_details IS NULL
        OR jsonb_typeof(evaluation_details) = 'object'
    );

-- Explain the purpose of this column for future developers.
COMMENT ON COLUMN job_evaluations.evaluation_details IS
    'Complete parsed job-fit evaluation, including transferable qualifications and missing evidence; NULL for historical evaluations without preserved output.';

-- Record that migration 009 has been applied.
INSERT INTO schema_migrations (version, migration_name)
VALUES (9, 'evaluation_details');

-- Save all changes if the transaction succeeds.
COMMIT;