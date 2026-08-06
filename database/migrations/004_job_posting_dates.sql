BEGIN;

ALTER TABLE job_sources
ADD COLUMN source_posted_at timestamptz;

COMMENT ON COLUMN jobs.posted_at IS
    'Posting date reported by the employer or selected authoritative source.';

COMMENT ON COLUMN job_sources.source_posted_at IS
    'Posting date reported by this specific intake source.';

CREATE INDEX jobs_active_posted_at_idx
    ON jobs (posted_at DESC)
    WHERE status IN ('new', 'active')
      AND posted_at IS NOT NULL;

CREATE INDEX job_sources_job_posted_at_idx
    ON job_sources (job_id, source_posted_at DESC)
    WHERE source_posted_at IS NOT NULL;

INSERT INTO schema_migrations (version, migration_name)
VALUES (4, 'job_posting_dates');

COMMIT;