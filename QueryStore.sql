   
 -- query store never captured the ddl like alter, drop table etc
 -- query store only user databases

 --Query store capture mode 
   
    --1.all  2.auto 3.custm 4.none

    -- AUTO is the default for PAAS (MI & AZ SQL)

    -- AUTO is also default only from 2019

    -- ALL is 2016/2017 

    -- All means its capture the every thing adhoc, store procedure , from application team work load etc

    -- Auto means it dont capture adhoc queries like select * from tablename 
    -- (if this query run more than 29 times then it capture) 
    -- and sql server also consider weightage of query

    -- custom is there from 2019 we can customize the 

 --1. query store configuration

     ALTER DATABASE YourDatabase
    SET QUERY_STORE (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    INTERVAL_LENGTH_MINUTES = 60,
    MAX_STORAGE_SIZE_MB = 2048
    );
    --note: This keeps Query Store data for 30 days before automatic cleanup.


 --2. how to see queries in query store
       
    select * from sys.query_store_query_text


--3.Get execution plan for a query 

    SELECT
    q.query_id,
    p.plan_id,
    CAST(p.query_plan AS XML) AS QueryPlan
    FROM sys.query_store_query q
    JOIN sys.query_store_plan p
    ON q.query_id = p.query_id
    WHERE q.query_id = 123;


    select * from sys.query_store_plan

--4.Check All Forced Plans

    SELECT
    q.query_id,
    p.plan_id,
    p.is_forced_plan,
    p.force_failure_count,
    p.last_force_failure_reason_desc,
    qt.query_sql_text
FROM sys.query_store_plan p
JOIN sys.query_store_query q
    ON p.query_id = q.query_id
JOIN sys.query_store_query_text qt
    ON q.query_text_id = qt.query_text_id
WHERE p.is_forced_plan = 1;

/* What keeps it active:

It survives SQL Server restarts
It survives Query Store data cleanup
It survives plan cache flushes (DBCC FREEPROCCACHE)


What can break it:
Situation                                              EffectObject 
changes (index drop, table alter)            SQL Server may ignore the forced plan and compile a new one 
Query text changes                           Force no longer applies(new query gets a new query hash)
You manually unforce                         itRemoved immediatelyQuery 
Store is disabled or cleared                        Force is lost */