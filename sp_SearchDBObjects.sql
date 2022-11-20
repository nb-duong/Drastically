CREATE PROCEDURE dbo.sp_SearchDBObjects (@String varchar(max))  
AS   
BEGIN  

  SELECT 
     CASE WHEN O.TYPE = 'TR' THEN 'Trigger'
        WHEN O.TYPE = 'FN' THEN 'Scalar Function'
        WHEN O.TYPE = 'IF' THEN 'Table Valued Function'
        WHEN O.TYPE = 'V' THEN 'View'
        WHEN O.TYPE = 'P' THEN 'Stored Procedure'
      ELSE NULL END AS [Object Type],  
     S.NAME + '.' + O.NAME AS [Object Name],
     M.DEFINITION AS [Object Code]
  FROM SYS.SQL_MODULES AS m
     INNER JOIN SYS.OBJECTS AS O ON M.OBJECT_ID = O.OBJECT_ID
     INNER JOIN SYS.SCHEMAS AS S ON O.SCHEMA_ID = S.SCHEMA_ID
  WHERE O.TYPE IN ('TR', 'FN', 'IF', 'V', 'P')
  AND M.DEFINITION LIKE '%' + @String + '%'
  
END
