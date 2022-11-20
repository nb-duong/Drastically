CREATE OR ALTER FUNCTION dbo.udf_whatsUpLocks ( @spid INT = NULL )
RETURNS TABLE
AS
RETURN (
		SELECT 
			dtl.request_mode,
			locked_object = 
				CASE dtl.resource_type
					 WHEN N'OBJECT' 
					 THEN OBJECT_NAME(dtl.resource_associated_entity_id)
					 ELSE OBJECT_NAME(p.object_id)
				END,
			index_name = 
				ISNULL(i.name, N'OBJECT'),
			dtl.resource_type,
			dtl.request_status,
			total_locks = 
				COUNT_BIG(*)
		FROM sys.dm_tran_locks AS dtl WITH(NOLOCK)
		LEFT JOIN sys.partitions AS p WITH(NOLOCK) ON p.hobt_id = dtl.resource_associated_entity_id
		LEFT JOIN sys.indexes AS i WITH(NOLOCK) ON  p.object_id = i.object_id AND p.index_id  = i.index_id
		WHERE (dtl.request_session_id = @spid OR @spid IS NULL)
			AND	dtl.resource_type <> N'DATABASE'
		GROUP BY 
			CASE dtl.resource_type
					WHEN N'OBJECT' 
					THEN OBJECT_NAME(dtl.resource_associated_entity_id)
					ELSE OBJECT_NAME(p.object_id)
			END,
			ISNULL(i.name, N'OBJECT'), dtl.resource_type, dtl.request_mode, dtl.request_status
)
