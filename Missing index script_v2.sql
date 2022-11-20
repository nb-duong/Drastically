SELECT id.[statement] AS [database.schema.table]
       ,id.[equality_columns]
       ,id.[inequality_columns]
       ,id.[included_columns]
       ,gs.[unique_compiles]
       ,gs.[user_seeks]
       ,gs.[user_scans]
       ,gs.[last_user_seek]
       ,gs.[last_user_scan]
       ,gs.[avg_total_user_cost]
       ,gs.[avg_user_impact]
       ,gs.[system_seeks]
       ,gs.[system_scans]
       ,gs.[last_system_seek]
       ,gs.[last_system_scan]
       ,gs.[avg_total_system_cost]
       ,gs.[avg_system_impact]
       ,gs.[user_seeks] * gs.[avg_total_user_cost] * (gs.[avg_user_impact] * 0.01) AS [index_advantage]
       ,'CREATE INDEX [Missing_IXNC_' + OBJECT_NAME(id.[object_id], db.[database_id]) + '_' + REPLACE(REPLACE(REPLACE(ISNULL(id.[equality_columns], ''), ', ', '_'), '[', ''), ']', '') + CASE
             WHEN id.[equality_columns] IS NOT NULL
                    AND id.[inequality_columns] IS NOT NULL
                    THEN '_'
             ELSE ''
             END + REPLACE(REPLACE(REPLACE(ISNULL(id.[inequality_columns], ''), ', ', '_'), '[', ''), ']', '') + '_' + LEFT(CAST(NEWID() AS [nvarchar](64)), 5) + ']' + ' ON ' + id.[statement] + ' (' + ISNULL(id.[equality_columns], '') + CASE
             WHEN id.[equality_columns] IS NOT NULL
                    AND id.[inequality_columns] IS NOT NULL
                    THEN ','
             ELSE ''
             END + ISNULL(id.[inequality_columns], '') + ')' + ISNULL(' INCLUDE (' + id.[included_columns] + ')', '') AS [proposed_index]
FROM [sys].[dm_db_missing_index_group_stats] gs WITH (NOLOCK)
INNER JOIN [sys].[dm_db_missing_index_groups] ig WITH (NOLOCK) ON gs.[group_handle] = ig.[index_group_handle]
INNER JOIN [sys].[dm_db_missing_index_details] id WITH (NOLOCK) ON ig.[index_handle] = id.[index_handle]
INNER JOIN [sys].[databases] db WITH (NOLOCK) ON db.[database_id] = id.[database_id]
WHERE id.[database_id] = DB_ID()
ORDER BY [index_advantage] DESC
OPTION (RECOMPILE);