BEGIN;

CREATE TABLE job_evaluations (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id uuid NOT NULL
        REFERENCES jobs(id) ON DELETE RESTRICT,
    user_id uuid NOT NULL
        REFERENCES users(id) ON DELETE RESTRICT,
    resume_version_id uuid
        REFERENCES resume_versions(id) ON DELETE RESTRICT,
    qualification_score numeric(5, 2) NOT NULL,
    legitimacy_score numeric(5, 2) NOT NULL,
    scam_risk text NOT NULL,
    ghost_job_likelihood text NOT NULL,
    confidence_level text NOT NULL,
    recommendation text NOT NULL,
    strengths jsonb NOT NULL,
    gaps jsonb NOT NULL,
    explanation text NOT NULL,
    model_version text NOT NULL,
    prompt_version text NOT NULL,
    evaluated_at timestamp with time zone NOT NULL DEFAULT now(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),

    CONSTRAINT job_evaluations_qualification_score_check
        CHECK (qualification_score BETWEEN 0 AND 100),

    CONSTRAINT job_evaluations_legitimacy_score_check
        CHECK (legitimacy_score BETWEEN 0 AND 100),

    CONSTRAINT job_evaluations_scam_risk_check
        CHECK (scam_risk IN ('low', 'medium', 'high')),

    CONSTRAINT job_evaluations_ghost_job_likelihood_check
        CHECK (ghost_job_likelihood IN ('low', 'medium', 'high')),

    CONSTRAINT job_evaluations_confidence_level_check
        CHECK (confidence_level IN ('low', 'medium', 'high')),

    CONSTRAINT job_evaluations_recommendation_check
        CHECK (recommendation IN ('apply', 'review', 'reject')),

    CONSTRAINT job_evaluations_strengths_array_check
        CHECK (jsonb_typeof(strengths) = 'array'),

    CONSTRAINT job_evaluations_gaps_array_check
        CHECK (jsonb_typeof(gaps) = 'array'),

    CONSTRAINT job_evaluations_explanation_check
        CHECK (length(trim(explanation)) > 0),

    CONSTRAINT job_evaluations_model_version_check
        CHECK (length(trim(model_version)) > 0),

    CONSTRAINT job_evaluations_prompt_version_check
        CHECK (length(trim(prompt_version)) > 0)
);

CREATE INDEX job_evaluations_job_evaluated_at_idx
    ON job_evaluations (job_id, evaluated_at DESC);

CREATE INDEX job_evaluations_user_recommendation_idx
    ON job_evaluations (user_id, recommendation, evaluated_at DESC);

CREATE INDEX job_evaluations_resume_version_id_idx
    ON job_evaluations (resume_version_id)
    WHERE resume_version_id IS NOT NULL;

CREATE INDEX job_evaluations_risk_idx
    ON job_evaluations (
        scam_risk,
        ghost_job_likelihood,
        evaluated_at DESC
    );

COMMENT ON TABLE job_evaluations IS
    'Immutable, versioned assessments of job qualification fit and posting legitimacy.';

COMMENT ON COLUMN job_evaluations.strengths IS
    'JSON array of qualifications supported by verified resume experience.';

COMMENT ON COLUMN job_evaluations.gaps IS
    'JSON array of missing, unsupported, or uncertain qualifications.';

CREATE TABLE verification_evidence (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id uuid NOT NULL
        REFERENCES jobs(id) ON DELETE RESTRICT,
    job_evaluation_id uuid NOT NULL
        REFERENCES job_evaluations(id) ON DELETE RESTRICT,
    verification_source_id uuid NOT NULL
        REFERENCES verification_sources(id) ON DELETE RESTRICT,
    evidence_class text NOT NULL,
    evidence_type text NOT NULL,
    summary text NOT NULL,
    source_url text,
    observed_at timestamp with time zone,
    checked_at timestamp with time zone NOT NULL DEFAULT now(),
    score_effect numeric(5, 2) NOT NULL,
    confidence_score numeric(5, 2) NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),

    CONSTRAINT verification_evidence_class_check
        CHECK (
            evidence_class IN (
                'verified_fact',
                'risk_signal',
                'conflicting_evidence',
                'unverified_information'
            )
        ),

    CONSTRAINT verification_evidence_type_check
        CHECK (
            evidence_type IN (
                'company',
                'url',
                'recruiter',
                'compensation',
                'reputation',
                'posting_history',
                'other'
            )
        ),

    CONSTRAINT verification_evidence_summary_check
        CHECK (length(trim(summary)) > 0),

    CONSTRAINT verification_evidence_source_url_check
        CHECK (
            source_url IS NULL
            OR length(trim(source_url)) > 0
        ),

    CONSTRAINT verification_evidence_score_effect_check
        CHECK (score_effect BETWEEN -100 AND 100),

    CONSTRAINT verification_evidence_confidence_score_check
        CHECK (confidence_score BETWEEN 0 AND 100)
);

CREATE INDEX verification_evidence_evaluation_id_idx
    ON verification_evidence (job_evaluation_id);

CREATE INDEX verification_evidence_job_id_idx
    ON verification_evidence (job_id);

CREATE INDEX verification_evidence_source_id_idx
    ON verification_evidence (verification_source_id);

CREATE INDEX verification_evidence_class_type_idx
    ON verification_evidence (evidence_class, evidence_type);

COMMENT ON TABLE verification_evidence IS
    'Observable facts, risks, conflicts, and unverified information supporting a job legitimacy assessment.';

COMMENT ON COLUMN verification_evidence.score_effect IS
    'Signed contribution from -100 to 100 indicating how the evidence affects the legitimacy score.';

INSERT INTO schema_migrations (version, migration_name)
VALUES (6, 'job_evaluations_and_verification_evidence');

COMMIT;