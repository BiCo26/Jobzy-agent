BEGIN;

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

CREATE TABLE users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    display_name text NOT NULL CHECK (length(trim(display_name)) > 0),
    email text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX users_email_unique
    ON users (lower(email))
    WHERE email IS NOT NULL;

CREATE TABLE companies (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    display_name text NOT NULL CHECK (length(trim(display_name)) > 0),
    normalized_name text NOT NULL CHECK (length(trim(normalized_name)) > 0),
    website_domain text,
    careers_url text,
    industry text,
    company_size text,
    verification_status text NOT NULL DEFAULT 'unverified'
        CHECK (
            verification_status IN (
                'unverified',
                'verified',
                'conflicting',
                'rejected'
            )
        ),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX companies_normalized_name_idx
    ON companies (normalized_name);

CREATE UNIQUE INDEX companies_website_domain_unique
    ON companies (lower(website_domain))
    WHERE website_domain IS NOT NULL;

CREATE TABLE verification_sources (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    source_name text NOT NULL CHECK (length(trim(source_name)) > 0),
    source_type text NOT NULL
        CHECK (
            source_type IN (
                'official_company',
                'trusted_ats',
                'government_registry',
                'search_result',
                'review_site',
                'other'
            )
        ),
    base_url text,
    authority_level text NOT NULL
        CHECK (
            authority_level IN (
                'primary',
                'authoritative_third_party',
                'secondary',
                'anonymous'
            )
        ),
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE resumes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    resume_name text NOT NULL CHECK (length(trim(resume_name)) > 0),
    resume_type text NOT NULL
        CHECK (resume_type IN ('master', 'supporting_source')),
    is_active boolean NOT NULL DEFAULT true,
    drive_file_id text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX resumes_user_id_idx
    ON resumes (user_id);

CREATE TRIGGER users_set_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER companies_set_updated_at
BEFORE UPDATE ON companies
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER verification_sources_set_updated_at
BEFORE UPDATE ON verification_sources
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER resumes_set_updated_at
BEFORE UPDATE ON resumes
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

COMMIT;