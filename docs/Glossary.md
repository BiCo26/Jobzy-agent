# Jobzy-Agent Glossary

This living glossary explains technical terms used while designing and building Jobzy-Agent.

## Database and SQL Terms

### Database

An organized system for storing and retrieving information. Jobzy-Agent uses PostgreSQL as its database.

### Database Management System (DBMS)

Software that manages databases. PostgreSQL is a relational DBMS.

### Relational Database

A database that stores structured data in tables and connects records through relationships.

### SQL

Structured Query Language. The language used to create, read, update, and delete relational data.

### Schema

The defined structure of a database, including its tables, columns, relationships, constraints, indexes, and other objects.

PostgreSQL also uses the word `schema` for a namespace inside a database. Jobzy-Agent initially uses PostgreSQL’s default `public` schema.

### Migration

A numbered, version-controlled file that changes the database schema in a repeatable way.

Example:

```text
001_foundation.sql
002_migration_tracking.sql
003_jobs.sql
```

### Statement

One complete SQL instruction, usually ending with a semicolon.

Example:

```sql
CREATE TABLE users (...);
```

### Transaction

A group of database changes treated as one operation. Either all changes succeed or none are retained.

### `BEGIN`

Starts a database transaction.

### `COMMIT`

Permanently saves all successful changes in the current transaction.

### Rollback

Cancels uncommitted changes in a transaction, usually after an error.

### Table

A structured collection of related records.

Examples:

- `users`
- `companies`
- `jobs`

### Row

One complete record in a table.

One row in `jobs` represents one normalized job opportunity.

### Column

One named attribute stored for every row in a table.

Examples:

- `title`
- `company_id`
- `status`

### Data Type

A rule defining what kind of value a column can store.

Examples:

- `text`
- `uuid`
- `boolean`
- `bigint`
- `numeric`
- `timestamptz`

### `text`

A PostgreSQL data type for character-based values of varying length.

### `uuid`

Universally Unique Identifier. A 128-bit identifier designed to be unique across systems.

Example:

```text
8df57d20-1f4c-4ff8-92ab-d196c02e878e
```

### `gen_random_uuid()`

A PostgreSQL function that creates a random UUID.

### `boolean`

A data type whose value is `true` or `false`.

### `bigint`

A whole-number data type with a large range. Jobzy-Agent uses it for monetary amounts stored in the smallest currency unit.

### `numeric(4,1)`

A precise numeric value with up to four total digits and one digit after the decimal point.

Examples:

```text
5.0
12.5
999.9
```

### `timestamptz`

A PostgreSQL date-and-time type that represents a precise moment and accounts for timezone conversion.

PostgreSQL commonly stores the moment in UTC and displays it according to the connection’s timezone.

### Primary Key

A column—or set of columns—that uniquely identifies every row in a table.

Example:

```sql
id uuid PRIMARY KEY
```

### Foreign Key

A column that references the primary key of another table and creates a relationship.

Example:

```sql
company_id uuid REFERENCES companies(id)
```

### Constraint

A database-enforced rule that rejects invalid data.

### `NOT NULL`

Requires a column to contain a value.

### `DEFAULT`

Provides a value automatically when an insert does not specify one.

Example:

```sql
created_at timestamptz NOT NULL DEFAULT now()
```

### `CHECK`

Defines a rule that inserted or updated values must satisfy.

Example:

```sql
CHECK (qualification_score >= 0 AND qualification_score <= 100)
```

### `UNIQUE`

Prevents duplicate values—or duplicate combinations of values—in specified columns.

### `REFERENCES`

Declares that a column is a foreign key pointing to another table.

### `ON DELETE RESTRICT`

Prevents deletion of a parent record while related child records still reference it.

For example, a user cannot be deleted while that user still owns resume records.

### Index

A database structure that speeds up searches, filtering, joins, and sorting. Indexes require additional storage and make writes slightly more expensive.

### Unique Index

An index that also prevents duplicate indexed values.

### Partial Index

An index covering only rows that meet a condition.

Example:

```sql
CREATE UNIQUE INDEX ...
WHERE canonical_url IS NOT NULL;
```

### Trigger

A database action that runs automatically when a specified event occurs.

Jobzy-Agent uses triggers to update `updated_at` when a row changes.

### Function

Reusable logic stored in PostgreSQL.

The `set_updated_at()` function sets a record’s update time to the current time.

### `CREATE TABLE`

Creates a new database table.

### `CREATE INDEX`

Creates an index.

### `CREATE TRIGGER`

Creates an automatic database event.

### `INSERT`

Adds one or more rows to a table.

### `SELECT`

Reads information from one or more tables without changing it.

### `UPDATE`

Changes existing rows.

### `DELETE`

Removes rows. Jobzy-Agent generally prefers archival or historical states over hard deletion.

### `WHERE`

Limits an SQL operation to rows meeting specified conditions.

### `IN`

Tests whether a value is one of several allowed values.

Example:

```sql
CHECK (status IN ('new', 'active', 'expired'))
```

### `IS NULL`

Tests whether a value is missing.

SQL uses `IS NULL`, not `= NULL`.

### `AND`

Requires multiple conditions to be true.

### `OR`

Requires at least one condition to be true.

### `~`

PostgreSQL’s regular-expression matching operator.

Example:

```sql
salary_currency ~ '^[A-Z]{3}$'
```

This requires exactly three uppercase letters.

### Regular Expression

A pattern used to validate or find text.

Example:

```text
^[A-Z]{3}$
```

means exactly three uppercase letters from beginning to end.

### `trim()`

Removes spaces from the beginning and end of text.

### `length()`

Returns the number of characters in text.

### Normalization

Converting inconsistent source data into a consistent internal representation.

Examples:

- `Sr Product Mgr` → `Senior Product Manager`
- `REMOTE` → `remote`

### Denormalization

Intentionally storing a value in a more directly accessible location, even when it can be derived elsewhere.

For example, `applications.current_status` provides fast access while the complete status history remains in another table.

### Hash

A fixed-length value derived from input content. Hashes help detect duplicates or verify that content has not changed.

A hash is not the same as encryption and generally cannot restore the original content.

### Deduplication

Detecting multiple records that represent the same real-world item and preventing unnecessary duplicates.

### Controlled Value

A value restricted to an approved list through a constraint.

Example:

```text
remote
hybrid
on_site
unspecified
```

### Snake Case

A naming convention using lowercase words separated by underscores.

Examples:

```text
job_sources
qualification_score
created_at
```

### System of Record

The authoritative location for a category of data. PostgreSQL is Jobzy-Agent’s system of record for structured job-search information.

### Immutable Record

A historical record that should not be silently changed after creation. A correction creates another record or an auditable correction event.

### Append-Only

A data-history approach where new events are added instead of replacing prior events.

### Idempotency

The property that safely repeating the same operation does not create unintended duplicate results.

### Idempotency Key

A stable identifier used to recognize that an event or workflow has already been processed.

### Data Dictionary

Documentation describing a system’s specific tables, columns, data types, meanings, and rules.

### Entity Relationship Diagram (ERD)

A visual model showing database entities and the relationships between them.

### Cardinality

The number of records allowed on each side of a relationship.

Examples:

- One company may have many jobs.
- One application may have many status-history events.