BEGIN;

CREATE TABLE resume_versions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    resume_id uuid NOT NULL
        REFERENCES resumes(id) ON DELETE RESTRICT,
    job_id uuid
        REFERENCES jobs(id) ON DELETE RESTRICT,
    parent_version_id uuid
        REFERENCES resume_versions(id) ON DELETE RESTRICT,
    version_number integer NOT NULL,
    status text NOT NULL DEFAULT 'draft',
    drive_file_id text,
    file_name text,
    content_hash text NOT NULL,
    change_summary text NOT NULL,
    model_version text,
    prompt_version text,
    created_at timestamp with time zone NOT NULL DEFAULT now(),

    CONSTRAINT resume_versions_version_number_check
        CHECK (version_number > 0),

    CONSTRAINT resume_versions_status_check
        CHECK (
            status IN (
                'draft',
                'approved',
                'rejected',
                'superseded',
                'used'
            )
        ),

    CONSTRAINT resume_versions_content_hash_check
        CHECK (length(trim(content_hash)) > 0),

    CONSTRAINT resume_versions_change_summary_check
        CHECK (length(trim(change_summary)) > 0),

    CONSTRAINT resume_versions_resume_version_unique
        UNIQUE (resume_id, version_number),

    CONSTRAINT resume_versions_parent_not_self_check
        CHECK (parent_version_id IS NULL OR parent_version_id <> id)
);

CREATE INDEX resume_versions_resume_id_idx
    ON resume_versions (resume_id);

CREATE INDEX resume_versions_job_id_idx
    ON resume_versions (job_id)
    WHERE job_id IS NOT NULL;

CREATE INDEX resume_versions_parent_version_id_idx
    ON resume_versions (parent_version_id)
    WHERE parent_version_id IS NOT NULL;

CREATE INDEX resume_versions_status_created_at_idx
    ON resume_versions (status, created_at DESC);

COMMENT ON TABLE resume_versions IS
    'Immutable, versioned resume documents generated or manually revised from a source resume.';

COMMENT ON COLUMN resume_versions.parent_version_id IS
    'Optional prior resume version used as the starting point for this version.';

COMMENT ON COLUMN resume_versions.content_hash IS
    'Hash used to verify content integrity and identify duplicate resume content.';

INSERT INTO schema_migrations (version, migration_name)
VALUES (5, 'resume_versions');

COMMIT;