use TestBase

-- Чистим от предыдущих экспериментов
DROP FUNCTION IF EXISTS dbo.fn_CalculateArea
GO
GO

CREATE ASSEMBLY MyClassLibrary
FROM 'E:\MyClassLibrary.dll'
WITH PERMISSION_SET = SAFE;  

-- Посмотреть подключенные сборки (SSMS: <DB> -> Programmability -> Assemblies)
SELECT * FROM sys.assemblies

-- Подключить функцию из dll - AS EXTERNAL NAME
CREATE FUNCTION dbo.fn_CalculateArea(@ax int, @ay int, @bx int, @by int, @cx int, @cy int)  
RETURNS nvarchar(100)
AS EXTERNAL NAME [MyClassLibrary].[MyClassLibrary.Triangle].CalculateAreaTriangle;
GO 

-- Используем функцию
declare @ax int, @ay int, @bx int, @by int, @cx int, @cy int
set @ax = -3
set @ay = -1
set @bx = 2
set @by = 5
set @cx = 8
set @cy = -2

SELECT dbo.fn_CalculateArea(@ax, @ay, @bx, @by, @cx, @cy)
