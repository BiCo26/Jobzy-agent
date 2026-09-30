-- Start a transaction so these changes succeed or fail together.
BEGIN;

-- Allow an evaluation without a legitimacy assessment.
-- NULL means "not assessed," not a score of zero.
ALTER TABLE job_evaluations
    ALTER COLUMN legitimacy_score DROP NOT NULL;

-- Allow scam risk to remain unknown until assessed.
-- NULL does not mean the job is safe.
ALTER TABLE job_evaluations
    ALTER COLUMN scam_risk DROP NOT NULL;

-- Allow ghost-job likelihood to remain unknown until assessed.
ALTER TABLE job_evaluations
    ALTER COLUMN ghost_job_likelihood DROP NOT NULL;

-- Document what an empty legitimacy score means.
COMMENT ON COLUMN job_evaluations.legitimacy_score IS
    'Posting legitimacy score from 0 to 100; NULL means not assessed.';

-- Document what an empty scam-risk rating means.
COMMENT ON COLUMN job_evaluations.scam_risk IS
    'Scam risk: low, medium, or high; NULL means not assessed.';

-- Document what an empty ghost-job rating means.
COMMENT ON COLUMN job_evaluations.ghost_job_likelihood IS
    'Ghost-job likelihood: low, medium, or high; NULL means not assessed.';

-- Record that migration 008 has been applied.
INSERT INTO schema_migrations (version, migration_name)
VALUES (8, 'job_fit_evaluation_storage');

-- Save all changes in this transaction.
COMMIT;