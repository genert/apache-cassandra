-- Create keyspace
CREATE KEYSPACE IF NOT EXISTS events WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 1};

-- Lambda invocation type.
CREATE TYPE IF NOT EXISTS events.lambda_invocation (
    version text,
    request_id text,
    duration double,
    billed_duration double,
    memory_size double,
    max_memory_used double,
    init_duration double,
    );

-- Events table
CREATE TABLE IF NOT EXISTS events.events
(
    id              text,
    account_id      text,
    created_at      timestamp,
    function_arn    text,
    is_cold_start   boolean,
    is_error        boolean,
    is_retry        boolean,
    is_empty        boolean,
    log_group_name  text,
    log_lines       int,
    log_stream_name text,
    s3bucket        text,
    s3key           text,
    data            lambda_invocation,

    PRIMARY KEY ((id), created_at)
) WITH COMMENT = 'Q2: Look up an event by account and event id.' AND CLUSTERING ORDER BY (created_at ASC);

CREATE CUSTOM INDEX events_is_error_idx ON events.events (is_error)
    USING 'org.apache.cassandra.index.sasi.SASIIndex'
            WITH OPTIONS = {'mode': 'CONTAINS'};


-- Events by account id.
CREATE TABLE IF NOT EXISTS events.events_by_account_id
(
    account_id      text,
    event_id        text,
    created_at      timestamp,
    function_arn    text,
    is_cold_start   boolean,
    is_error        boolean,
    is_retry        boolean,
    is_empty        boolean,
    log_group_name  text,
    log_lines       int,
    log_stream_name text,
    s3bucket        text,
    s3key           text,
    data            lambda_invocation,

    PRIMARY KEY ((account_id), event_id, created_at)
) WITH COMMENT = 'Q1: Find all events by account id.' AND CLUSTERING ORDER BY (event_id ASC, created_at ASC);

-- Cold start event by account id.
CREATE TABLE IF NOT EXISTS events.cold_start_events_by_account_id
(
    account_id      text,
    event_id        text,
    created_at      timestamp,
    function_arn    text,
    is_cold_start   boolean,
    is_error        boolean,
    is_retry        boolean,
    is_empty        boolean,
    log_group_name  text,
    log_lines       int,
    log_stream_name text,
    s3bucket        text,
    s3key           text,
    data            lambda_invocation,

    PRIMARY KEY ((account_id), event_id, created_at)
) WITH COMMENT = 'Q3: Find all cold start events by account id.' AND CLUSTERING ORDER BY (event_id ASC, created_at ASC);

-- Error events by account id.
CREATE TABLE IF NOT EXISTS events.error_events_by_account_id
(
    account_id      text,
    event_id        text,
    created_at      timestamp,
    function_arn    text,
    is_cold_start   boolean,
    is_error        boolean,
    is_retry        boolean,
    is_empty        boolean,
    log_group_name  text,
    log_lines       int,
    log_stream_name text,
    s3bucket        text,
    s3key           text,
    data            lambda_invocation,

    PRIMARY KEY ((account_id), event_id, created_at)
) WITH COMMENT = 'Q4: Find all error events by account id.' AND CLUSTERING ORDER BY (event_id ASC, created_at ASC);

-- Empty events by account id.
CREATE TABLE IF NOT EXISTS events.empty_events_by_account_id
(
    account_id      text,
    event_id        text,
    created_at      timestamp,
    function_arn    text,
    is_cold_start   boolean,
    is_error        boolean,
    is_retry        boolean,
    is_empty        boolean,
    log_group_name  text,
    log_lines       int,
    log_stream_name text,
    s3bucket        text,
    s3key           text,
    data            lambda_invocation,

    PRIMARY KEY ((account_id), event_id, created_at)
) WITH COMMENT = 'Q5: Find all empty events by account id.' AND CLUSTERING ORDER BY (event_id ASC, created_at ASC);

-- Retry events by account id.
CREATE TABLE IF NOT EXISTS events.retry_events_by_account_id
(
    account_id      text,
    event_id        text,
    created_at      timestamp,
    function_arn    text,
    is_cold_start   boolean,
    is_error        boolean,
    is_retry        boolean,
    is_empty        boolean,
    log_group_name  text,
    log_lines       int,
    log_stream_name text,
    s3bucket        text,
    s3key           text,
    data            lambda_invocation,

    PRIMARY KEY ((account_id), event_id, created_at)
) WITH COMMENT = 'Q6: Find all retry events by account id.' AND CLUSTERING ORDER BY (event_id ASC, created_at ASC);
