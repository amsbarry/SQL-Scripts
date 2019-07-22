USE Master;
GO 
SELECT  @@SERVERNAME AS [Server Name] ,
        DB_NAME() AS [Database Name] ,
        a2.name AS [Table Name] ,
        a1.rows AS [Row Count] ,
        ( CASE WHEN ( a1.used + ISNULL(a4.used, 0) ) > a1.data
               THEN ( a1.used + ISNULL(a4.used, 0) ) - a1.data
               ELSE 0
          END ) * 8 / 1024 AS [Index Size MB]
FROM    ( SELECT    ps.object_id ,
                    SUM(CASE WHEN ( ps.index_id < 2 ) THEN row_count
                             ELSE 0
                        END) AS [rows] ,
                    SUM(ps.reserved_page_count) AS reserved ,
                    SUM(CASE WHEN ( ps.index_id < 2 )
                             THEN ( ps.in_row_data_page_count
                                    + ps.lob_used_page_count
                                    + ps.row_overflow_used_page_count )
                             ELSE ( ps.lob_used_page_count
                                    + ps.row_overflow_used_page_count )
                        END) AS data ,
                    SUM(ps.used_page_count) AS used
          FROM      sys.dm_db_partition_stats ps
          GROUP BY  ps.object_id
        ) AS a1
        LEFT OUTER JOIN ( SELECT    it.parent_id ,
                                    SUM(ps.reserved_page_count) AS reserved ,
                                    SUM(ps.used_page_count) AS used
                          FROM      sys.dm_db_partition_stats ps
                                    INNER JOIN sys.internal_tables it ON ( it.object_id = ps.object_id )
                          WHERE     it.internal_type IN ( 202, 204 )
                          GROUP BY  it.parent_id
                        ) AS a4 ON ( a4.parent_id = a1.object_id )
        INNER JOIN sys.all_objects a2 ON ( a1.object_id = a2.object_id )
        INNER JOIN sys.schemas a3 ON ( a2.schema_id = a3.schema_id )
WHERE   a2.type <> N'S'
        AND a2.type <> N'IT'
        AND a2.is_ms_shipped <> 1
ORDER BY [Row Count] DESC ,
        [Table Name];
			GO
