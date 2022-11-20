SELECTt.name AS TableName, t.[object_id], 
SUM ( CASE WHEN i.is_primary_key = 1 THEN 1 ELSE 0 END ) AS Primarykey, 
SUM ( CASE WHEN i.[type] = 1 THEN 1 ELSE 0 END ) AS ClusteredIndex, 
SUM ( CASE WHEN i.[type] = 2 THEN 1 ELSE 0 END ) AS NonClusteredIndex, 
SUM ( CASE WHEN i.[type] = 0 THEN 1 ELSE 0 END ) AS HeapIndex, 
COUNT ( * ) TotalNoofIndex
FROM   sys.tables t
       LEFT OUTER JOIN sys.indexes i
            ON  i.[object_id] = t.[object_id]
GROUP BY
       t.name, t.[object_id]
