declare 
@ObjectFilter varchar(128)
,@SchemaName varchar(28)
,@TableName varchar(100)

SET @ObjectFilter = 'N_Task'; --Can be in the form on [schema name].[table name]
SET @TableName = PARSENAME(@ObjectFilter, 1); -- Captures the unquoted table name
SET @SchemaName = PARSENAME(@ObjectFilter, 2); -- Captures the unquoted schema name; NULL is handled

SELECT
	cols.name
   ,cols.column_id
   ,cols.max_length AS size
   ,cols.precision
   ,cols.scale
   ,cols.is_identity
   ,cols.is_nullable
   ,tipus.name AS [type]
   ,domain.name AS [user_type]
   ,(SELECT
			key_ordinal
		FROM sys.index_columns AS ic
		WHERE ic.object_id = (SELECT
				parent_object_id
			FROM sys.key_constraints
			WHERE type = 'PK'
			AND parent_object_id = cols.object_id)
		AND ic.index_id = (SELECT
				unique_index_id
			FROM sys.key_constraints
			WHERE type = 'PK'
			AND parent_object_id = cols.object_id)
		AND ic.column_id = cols.column_id)
	AS pk_ordinal
FROM sys.columns AS cols
LEFT JOIN sys.types AS tipus
	ON tipus.system_type_id = cols.system_type_id
		AND tipus.user_type_id = cols.system_type_id
		AND tipus.is_user_defined = 0
LEFT JOIN sys.types AS domain
	ON domain.user_type_id = cols.user_type_id
		AND domain.is_user_defined = 1
WHERE cols.object_id = (SELECT
		object_id
	FROM sys.tables
	WHERE name = @TableName
	AND (@SchemaName IS NULL
	OR OBJECT_SCHEMA_NAME(object_id) = @SchemaName))
ORDER BY cols.column_id
