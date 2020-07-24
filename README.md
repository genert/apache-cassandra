Apache Cassandra is an open source, distributed, decentralized, elastically scalable, highly available, fault-tolerant, tuneably consistent, row-oriented database. Cassandra bases its distribution design on Amazon’s Dynamo and its data model on Google’s Bigtable, with a query language similar to SQL. Created at Facebook, it now powers cloud-scale applications across many industries

## Cassandra features

1. Cassandra naturally handles keyspace, table, and column names as lowercase. When you enter names in mixed case, Cassandra stores them as all lowercase.
1. Keyspaces are meant to group tables (like a database). You just define some attributes how data is replicated.
    1. Cassandra will convert the name of the keyspace to be lower case, unless you put the name in single quotes.
1. Cassandra tables contain partitions. A partition is a set of rows that share a partition key. **Therefore all queries must contain at least the entire partition key!** Cassandra hashes the partition key to locate the partition within the cluster. Hashing is very fast, which is what makes Cassandra scale so well. Cassandra stores all rows with the same partition key in the same partition. So, without the partition key, Cassandra would have to do a full table scan to locate the specified rows. Such a scan on a production table would not be performant.
1. Upsert (aka items get overwritten when partition and clustering column are same for new insert):
    1. First, when Cassandra writes, it does not do a read first - that would be too slow.
    1. Second, a row's primary key values uniquely identify the row - and none of the other columns in the row count towards uniqueness.
1. Clustering columns are alphabetically ordered.
1. You can create compound partition key by surrounding both column names in the primary key definition with parenthesis to designate the partition key.
1. Cassandra supports sparse rows (null values) for non-primary columns. In other words, rows only require values in the primary key fields. And, Cassandra does this with no space penalty - only the columns that have values require space.
1. It has Cassandra Query Language (CQL), which provides a way to define schema via a syntax similar to the Structured Query Language (SQL) familiar to those coming from a relational background. You can do CRUD with it as well.
1. When we use clustering columns, we must use them in the order specified when we created the table.
    For example, for a following table:
    ```cql
    CREATE KEYSPACE user_management WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};

    CREATE TABLE user_management.users (
        last_name text,
        first_name text,
        email text,
        address text,
        PRIMARY KEY (last_name, first_name, email)
    );
    ```

    Following query would result error:
    ```cql
    SELECT * FROM users
    WHERE last_name = 'Smith'
    AND email = 'asmith@gmail.com';
    ```
    We see that this query doesn't work either because when we use clustering columns, we must use them in the order specified when we created the table!
    Therefore, following will work:
    ```cql
    SELECT email, address FROM users
    WHERE last_name = 'Smith'
    AND first_name = 'Bailey';
    ```
1. You cannot update primary keys nor clustering columns.
1. When updating non existant row, an upsert occurs instead and new row is created. Again, Cassandra does not read a row before writing the row. So, an UPDATE doesn't check to see if the row exists before changing it. Instead, Cassandra just writes the values. 
1. You cannot delete primary keys nor clustering columns.
1. It's a good practice in Cassandra to name tables based on what they contain as well as their partition key.
1. **In Cassandra, we create each table to handle a specific query. So, when you want to create a Cassandra schema, start by thinking about the use-cases of your app. Then use the use-cases to help you identify the queries your app needs. Finally, use the queries to help you define the tables.**
1. While CQL does not support joins, it can be done either on application side or by performing join before creating the table.
1. The SELECT and DELETE commands can operate in terms of one or more rows within a partition, an entire partition, or even multiple partitions by using the WHERE and IN clauses.
1. One very powerful feature that Cassandra provides is the ability to expire data that is no longer needed. This expiration is very flexible and works at the level of individual column values. The time to live (or TTL) is a value that Cassandra stores for each column value to indicate how long to keep the value. The TTL value defaults to null, meaning that data that is written will not expire.
1. If you want to set TTL across an entire row, you must provide a value for every non‐primary key column in your INSERT or UPDATE command.
1. Cassandra provides data type called `counter`. Cassandra is one of the few data‐ bases that provides race-free increments across data centers. Counters are frequently used for tracking statistics such as numbers of page views, tweets, log messages, and so on. The counter type has some special restrictions. It cannot be used as part of a primary key. If a counter is used, all of the columns other than primary key columns must be counters.
1. Cassandra gives you a way to define your own types to extend its data model. These user-defined types (UDTs) are easier to use than tuples since you can specify the val‐ ues by name rather than position. Create your own address type:
    ```cql
    cqlsh:my_keyspace> CREATE TYPE address ( street text,
    city text,
    state text,
    zip_code int);
    ```
    A UDT is scoped by the keyspace in which it is defined. You could have written CRE ATE TYPE my_keyspace.address. If you run the command DESCRIBE KEYSPACE my_keyspace, you’ll see that the address type is part of the keyspace definition.
1. To name each table, identify the primary entity type for which you are querying, and use that to start the entity name. If you are querying by attributes of other related entities, you append those to the table name, separated with _by_. For example, hotels_by_poi.

## Designing rules

1. Don't minimize the number of writes. Writes in Cassandra aren't free, but they're awfully cheap. Cassandra is optimized for high write throughput, and almost all writes are equally efficient
1. Don't minimize data duplication. Denormalization and duplication of data is a fact of life with Cassandra.
1. Spread data evenly around the cluster. This is done with partition key.
1. **Model around queries.** Determine what queries to support and try to create a table where you can satisfy your query by reading (roughly) one partition.
1. Secondary indexes (perferably SASIIndex) can be used when change is required, although data denormalization is encouraged.


## Example services
1. https://github.com/jeffreyscarpenter/reservation-service
