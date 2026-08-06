BEGIN;

CREATE TABLE schema_migrations (
    version integer PRIMARY KEY CHECK (version > 0),
    migration_name text NOT NULL UNIQUE
        CHECK (length(trim(migration_name)) > 0),
    applied_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO schema_migrations (version, migration_name)
VALUES
    (1, 'foundation'),
    (2, 'migration_tracking');

COMMIT;