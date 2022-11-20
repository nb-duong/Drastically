DOCUMENT: https://learn.microsoft.com/en-us/sql/t-sql/functions/string-functions-transact-sql?view=sql-server-ver16


TAKE CARE
    - Execution Plan
    - TIME
    - IO

* SET STATISTICS IO ON
* SET STATISTICS TIME ON
* SET ANSI_NULLS ON;
* SET ANSI_PADDING ON;
* SET ANSI_WARNINGS ON;
* SET ARITHABORT ON;
* SET CONCAT_NULL_YIELDS_NULL ON;
* SET QUOTED_IDENTIFIER ON;
* SET STATISTICS TIME, IO OFF;
* INSERT INTO #PerfmonTable WITH(TABLOCK)

* How do nested loop, hash, and merge joins work? Databases for Developers Performance #7
    - https://youtu.be/pJWCwfv983Q

Automatic tuning
    - https://learn.microsoft.com/en-us/sql/relational-databases/automatic-tuning/automatic-tuning?view=sql-server-ver16

REVIEW INDEXES
MAXDOP RECOMMEND QUERY    

PAGE: 
    1.Index all the predicates in JOIN, WHERE, ORDER BY and GROUP BY clauses.
    2.Avoid using functions in predicates
    3.Avoid using wildcard (%) at the beginning of a predicate
    4.Avoid unnecessary columns in SELECT clause
    5.Use inner join, instead of outer join if possible.
    6.DISTINCT and UNION should be used only if it is necessary.
    7.Oracle 10g and 11g requires that the CLOB/BLOB columns must be put at the end of the statements
    8.The ORDER BY clause is mandatory in SQL if the sorted result set is expected

PAGE: https://red9.com/sql-performance-tuning/
    * FRIST_VALUES => CROSS APPLY (NOT ROW_NUMBER)
    * FORCE INDEX JOIN
        SELECT blah FROM TABLE1, TABLE2
        WHERE TABLE2.ForiegnKeyID = TABLE1.ID
        WITH (INDEX (index_name))

    * NOT IN => NOT EXISTS
    * USE CTE if possible
    * USE tempdb if possible
    * USE UNION, UNION ALL if possible
    * UPDATE STATISTICS 
        EXEC sp_updatestats;

    * CREATE NONCLUSTERED INDEX [IX_...] 
        ON [TABLE](... DESC/ ASC)
        INCLUDE(...)
        WITH (
            PAD_INDEX = OFF, 
            STATISTICS_NORECOMPUTE = OFF, 
            SORT_IN_TEMPDB = ON/OFF,
            IGNORE_DUP_KEY = OFF, 
            DROP_EXISTING = ON/OFF, 
            ONLINE = ON, 
            ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON/OFF, 
            FILLFACTOR = 100,
            DATA_COMPRESSION = PAGE,
            MAXDOP = 16
        ) ON (INDEXES)


    * Added a non-clustered index on table [<removed>Transaction.
    * A subquery became a Common Table Expression (CTE)
    * Using indexes to improve sort performance
    * Split a subquery into four parts using UNION
    * Replaced ISNULL function in WHERE clause
            SELECT SUM(Records)
            FROM 
            (
                SELECT 1
                FROM dbo.Users AS u
                WHERE u.Age < 18

                UNION ALL

                SELECT 1
                FROM dbo.Users AS u
                WHERE u.Age IS NULL
            ) x (Records)   
            OPTION(QUERYTRACEON 8649); // NOT USE PROD
            
    * If possible, avoid cursors!
    * A new index. Scan operation can be tuned into becoming a seek (a lot more efficient)
    * Merge two indexes into a single one
    * Removed SQL function from where clause (subquery)
    * Removed unused columns from a temporary tables
    * Replaced two temporary tables with CTE;
    * Problem: SP is performing multiple index scans and causing too much Disk Operations.
    * INDEXES (https://github.com/nb-duong/Sql.Darling):
        1. adding missing indexes.
        2. dropping unused indexes.
        3. merging several indexes into a single one. Why? because indexing is not free. The less indexes you can get away with, the faster your SQL Server run.
        4. Reviewing over & under indexing.
        5. Hypothetical indexes, usually we just drop them.
        6. Migrating most hit indexes to the fastest storage you have on the server.
        7. Creating new file groups, splitting/balancing storage workload properly through multiple disks.
        8. Index compression.
            => https://github.com/erikdarlingdata/DarlingData/blob/main/helpers/WhatsUpMemory.sql
        9. Indexing Foreign Keys.
        10. And couple other things I am probably forgetting now.

OUTCOME:
    - In-Memory OLTP in Azure SQL Database: expensive
    - SQL SERVER 2019: recommend used temp table (enable) (unavailable AZURE)
        ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA = ON;
        (https://sqlperformance.com/2019/08/tempdb/tempdb-enhancements-in-sql-server-2019)
    - https://learn.microsoft.com/en-us/sql/t-sql/functions/string-functions-transact-sql?view=sql-server-ver16


sp_helpindex 'N_Task'

How do nested loop, hash, and merge joins work? Databases for Developers Performance #7
    https://www.youtube.com/watch?v=pJWCwfv983Q&list=PL78V83xV2fYlT11CJXE77H0LD7C_gZmyf&index=7

https://learn.microsoft.com/en-us/archive/blogs/turgays/exec-vs-sp_executesql
https://dba.stackexchange.com/questions/165149/exec-vs-sp-executesql-performance
https://www.mantralabsglobal.com/blog/sql-query-optimization-tips/



- QUERY:

    SELECT *
    FROM sys.configurations
    WHERE configuration_id = 1589;


    SELECT
    	[qsq].[query_id], 
    	[qsp].[plan_id],
    	OBJECT_NAME([qsq].[object_id]) AS [ObjectName],
    	[rs].[count_executions],
    	[rs].[last_execution_time],
    	[rs].[avg_duration],
    	[rs].[avg_logical_io_reads],
    	[qst].[query_sql_text]
    FROM [sys].[query_store_query] [qsq] 
    JOIN [sys].[query_store_query_text] [qst]
    	ON [qsq].[query_text_id] = [qst].[query_text_id]
    JOIN [sys].[query_store_plan] [qsp] 
    	ON [qsq].[query_id] = [qsp].[query_id]
    JOIN [sys].[query_store_runtime_stats] [rs] 
    	ON [qsp].[plan_id] = [rs].[plan_id]
    WHERE ([qsq].[object_id] = OBJECT_ID('Sales.usp_OrderInfoTT'))
        OR ([qsq].[object_id] = OBJECT_ID('Sales.usp_OrderInfoTV'))
        OR ([qsq].[object_id] = OBJECT_ID('Sales.usp_OrderInfoTTALT'))
    ORDER BY [qsq].[query_id], [rs].[last_execution_time];