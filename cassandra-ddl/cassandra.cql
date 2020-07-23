-- Create keyspace
DROP KEYSPACE IF EXISTS events;
CREATE KEYSPACE IF NOT EXISTS events WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 1};

-- Create tables