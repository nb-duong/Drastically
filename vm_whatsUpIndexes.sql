CREATE OR ALTER VIEW dbo.WhatsUpIndexes
AS
	SELECT TOP (2147483647)
		view_name = 'WhatsUpIndexes',
		database_name = DB_NAME(),
		schema_name = s.name,
		table_name = OBJECT_NAME(ps.object_id),
		index_name = i.name,
		in_row_pages_mb = ( ps.reserved_page_count * 8. / 1024. ),
		lob_pages_mb = ( ps.lob_reserved_page_count * 8. / 1024. ),
		ps.in_row_used_page_count,
		ps.row_count
	FROM sys.dm_db_partition_stats AS ps
	JOIN sys.objects AS so ON  ps.object_id = so.object_id AND so.is_ms_shipped = 0 AND so.type <> 'TF'
	JOIN sys.schemas AS s ON s.schema_id = so.schema_id
	JOIN sys.indexes AS i ON  ps.object_id = i.object_id AND ps.index_id  = i.index_id
	ORDER BY ps.object_id, ps.index_id, ps.partition_number
;
