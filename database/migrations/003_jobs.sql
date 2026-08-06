BEGIN;

CREATE TABLE jobs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
    title text NOT NULL CHECK (length(trim(title)) > 0),
    normalized_title text NOT NULL CHECK (length(trim(normalized_title)) > 0),
    description text NOT NULL CHECK (length(trim(description)) > 0),
    canonical_url text,
    external_posting_id text,
    location_text text,
    work_arrangement text NOT NULL DEFAULT 'unspecified'
        CHECK (
            work_arrangement IN (
                'remote',
                'hybrid',
                'on_site',
                'unspecified'
            )
        ),
    employment_type text NOT NULL DEFAULT 'unspecified'
        CHECK (
            employment_type IN (
                'full_time',
                'part_time',
                'contract',
                'temporary',
                'internship',
                'other',
                'unspecified'
            )
        ),
    salary_min_minor bigint CHECK (salary_min_minor >= 0),
    salary_max_minor bigint CHECK (salary_max_minor >= 0),
    salary_currency text,
    salary_period text
        CHECK (
            salary_period IN (
                'hourly',
                'monthly',
                'annual',
                'other'
            )
        ),
    posted_at timestamptz,
    closes_at timestamptz,
    first_seen_at timestamptz NOT NULL DEFAULT now(),
    last_seen_at timestamptz NOT NULL DEFAULT now(),
    status text NOT NULL DEFAULT 'new'
        CHECK (
            status IN (
                'new',
                'active',
                'expired',
                'duplicate',
                'suspicious',
                'archived',
                'rejected'
            )
        ),
    description_hash text NOT NULL
        CHECK (length(trim(description_hash)) > 0),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT jobs_salary_range_valid
        CHECK (
            salary_min_minor IS NULL
            OR salary_max_minor IS NULL
            OR salary_min_minor <= salary_max_minor
        ),

    CONSTRAINT jobs_salary_currency_required
        CHECK (
            (salary_min_minor IS NULL AND salary_max_minor IS NULL)
            OR (
                salary_currency IS NOT NULL
                AND salary_currency ~ '^[A-Z]{3}$'
            )
        ),

    CONSTRAINT jobs_last_seen_valid
        CHECK (last_seen_at >= first_seen_at),

    CONSTRAINT jobs_closing_date_valid
        CHECK (
            posted_at IS NULL
            OR closes_at IS NULL
            OR closes_at >= posted_at
        )
);

CREATE INDEX jobs_company_id_idx
    ON jobs (company_id);

CREATE INDEX jobs_normalized_title_idx
    ON jobs (normalized_title);

CREATE INDEX jobs_status_first_seen_idx
    ON jobs (status, first_seen_at);

CREATE INDEX jobs_description_hash_idx
    ON jobs (description_hash);

CREATE UNIQUE INDEX jobs_company_external_posting_unique
    ON jobs (company_id, external_posting_id)
    WHERE external_posting_id IS NOT NULL;

CREATE UNIQUE INDEX jobs_canonical_url_unique
    ON jobs (canonical_url)
    WHERE canonical_url IS NOT NULL;

CREATE TRIGGER jobs_set_updated_at
BEFORE UPDATE ON jobs
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TABLE job_sources (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id uuid NOT NULL REFERENCES jobs(id) ON DELETE RESTRICT,
    source_type text NOT NULL
        CHECK (
            source_type IN (
                'gmail',
                'manual_paste',
                'url',
                'linkedin',
                'indeed',
                'ats',
                'other'
            )
        ),
    source_reference text NOT NULL
        CHECK (length(trim(source_reference)) > 0),
    source_url text,
    received_at timestamptz NOT NULL DEFAULT now(),
    raw_content_hash text NOT NULL
        CHECK (length(trim(raw_content_hash)) > 0),
    created_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT job_sources_type_reference_unique
        UNIQUE (source_type, source_reference)
);

CREATE INDEX job_sources_job_id_idx
    ON job_sources (job_id);

CREATE INDEX job_sources_raw_content_hash_idx
    ON job_sources (raw_content_hash);

CREATE TABLE job_requirements (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id uuid NOT NULL REFERENCES jobs(id) ON DELETE RESTRICT,
    requirement_type text NOT NULL
        CHECK (
            requirement_type IN (
                'skill',
                'experience',
                'education',
                'certification',
                'responsibility',
                'other'
            )
        ),
    requirement_name text NOT NULL
        CHECK (length(trim(requirement_name)) > 0),
    requirement_text text NOT NULL
        CHECK (length(trim(requirement_text)) > 0),
    priority text NOT NULL
        CHECK (priority IN ('required', 'preferred')),
    minimum_years numeric(4,1)
        CHECK (minimum_years >= 0),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX job_requirements_job_priority_idx
    ON job_requirements (job_id, priority);

INSERT INTO schema_migrations (version, migration_name)
VALUES (3, 'jobs');

COMMIT;