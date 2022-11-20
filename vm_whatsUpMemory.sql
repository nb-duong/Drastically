CREATE OR ALTER VIEW dbo.vm_whatsUpMemory
AS
	SELECT TOP (2147483647)
		view_name = 'WhatsUpMemory',
		database_name = DB_NAME(),
		schema_name = SCHEMA_NAME(x.schema_id),
		x.object_name,
		x.index_name,    
		in_row_pages_mb = SUM ( CASE WHEN x.type IN (1, 3) THEN 1 ELSE 0 END ) * 8. / 1024.,
		lob_pages_mb = SUM ( CASE WHEN x.type = 2 THEN 1 ELSE 0 END ) * 8. / 1024.,
		buffer_cache_pages_total = COUNT_BIG(*)
	FROM 
	(
		SELECT       
			o.schema_id,
			object_name = o.name,
			index_name = i.name,
			au.type,
			au.allocation_unit_id 
		FROM sys.allocation_units AS au
		JOIN sys.partitions AS p ON au.container_id = p.hobt_id AND au.type =1
		JOIN sys.objects AS o ON p.object_id = o.object_id
		JOIN sys.indexes AS i ON  o.object_id = i.object_id AND p.index_id = i.index_id
		WHERE au.type > 0 AND o.is_ms_shipped = 0
    
		UNION ALL
    
		SELECT       
			o.schema_id,
			object_name = o.name,
			index_name = i.name,
			au.type,
			au.allocation_unit_id 
		FROM sys.allocation_units AS au
		JOIN sys.partitions AS p ON au.container_id = p.hobt_id AND au.type = 3
		JOIN sys.objects AS o ON p.object_id = o.object_id
		JOIN sys.indexes AS i ON  o.object_id = i.object_id AND p.index_id = i.index_id
		WHERE au.type > 0 AND o.is_ms_shipped = 0
    
		UNION ALL
    
		SELECT       
			o.schema_id,
			object_name = o.name,
			index_name = i.name,
			au.type,
			au.allocation_unit_id 
		FROM sys.allocation_units AS au
		JOIN sys.partitions AS p ON au.container_id = p.partition_id AND au.type = 2
		JOIN sys.objects AS o ON p.object_id = o.object_id
		JOIN sys.indexes AS i ON  o.object_id = i.object_id AND p.index_id = i.index_id
		WHERE au.type > 0 AND o.is_ms_shipped = 0
	) AS x
	JOIN sys.dm_os_buffer_descriptors AS obd ON x.allocation_unit_id = obd.allocation_unit_id
	GROUP BY 
		SCHEMA_NAME(x.schema_id), 
		x.object_name, 
		x.index_name
	ORDER BY COUNT_BIG(*) DESC
;
